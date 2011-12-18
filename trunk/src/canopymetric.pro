;+
; NAME:
;
;   CanopyMetric
;
; PURPOSE:
;
;
;
; AUTHOR:
;
;   John Armston
;   Joint Remote Sensing Research Program
;   Centre for Spatial Environmental Research
;   School of Geography, Planning and Environmental Management
;   The University of Queensland
;   Brisbane QLD 4072, Australia
;   http://gpem.uq.edu.au/jrsrp
;
; CATEGORY:
;
;
;
; CALLING SEQUENCE:
;
;
;
; INPUTS:
;
;
;
; KEYWORDS:
;
;
;
; OUTPUTS:
;
;
;
; RESTRICTIONS:
;
;
;
; EXAMPLE:
;
;
;
; MODIFICATION HISTORY:
;
;    Written by John Armston, 2005.
;    Header and licence added for RSC LAS Tools, October 2010.
;
;-
;###########################################################################
;
; LICENSE
;
;   This file is part of RSC LAS Tools
;   Copyright (C) 2010  John Armston.
;
;   This program is free software: you can redistribute it and/or modify
;   it under the terms of the GNU General Public License as published by
;   the Free Software Foundation, either version 3 of the License, or
;   (at your option) any later version.
;
;   This program is distributed in the hope that it will be useful,
;   but WITHOUT ANY WARRANTY; without even the implied warranty of
;   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;   GNU General Public License for more details.
;
;   You should have received a copy of the GNU General Public License
;   along with this program.  If not, see <http://www.gnu.org/licenses/>.
;
;###########################################################################

FUNCTION CanopyMetric, data, height, first, last, single, productType, returnType, height_threshold, $
    weights, null, percentile, rhovg_method, rhovg_percentile, constant, interval, $
    height_threshold_top=height_threshold_top, vbinsize=vbinsize
    
  forward_function HeightProfile, GetPercentile
  
  ; Error handling
  catch, theError
  if theError ne 0 then begin
    catch, /cancel
    return, null
  endif
  
  ; Index return type to use
  no_obs = n_elements(height)
  case returnType of
    'First': index = where(first EQ 1, count)
    'Last': index = where(last EQ 1, count)
    'Singular': index = where(single EQ 1, count)
    'All': begin
      index = dindgen(no_obs)
      count = no_obs
    end
    else: return, null
  endcase
  
  ; Check for upper height threshold
  if not keyword_set(height_threshold_top) then height_threshold_top = max(height)
  if (height_threshold_top le height_threshold_top) then height_threshold_top = max(height)
  
  ; Derive metric
  case productType of
    'Plant Area Index Proxy': begin ; Plant Area Index (Proxy)
      findex = where(first EQ 1, fcount)
      lindex = where(last EQ 1, lcount)
      sindex = where(single EQ 1, scount)
      efe = (fcount GT 0) ? total((Height[findex] GT height_threshold) AND (Height[findex] LE height_threshold_top)) : 0.0
      lfe = (lcount GT 0) ? total((Height[lindex] GT height_threshold) AND (Height[lindex] LE height_threshold_top)) : 0.0
      sfe = (scount GT 0) ? total((Height[sindex] GT height_threshold) AND (Height[sindex] LE height_threshold_top)) : 0.0
      fcover = (count GT 0) ? total((Height[index] GT height_threshold) AND (Height[index] LE height_threshold_top)) / float(count) : 0.0
      metric = ((lfe + sfe) gt 0) ? ((efe / (lfe + sfe)) * fcover) : null
    end
    'Fractional Cover - Count Ratio': begin ; Count Fractional Cover
      metric = (count GT 0) ? total((Height[index] GT height_threshold) AND (Height[index] LE height_threshold_top)) / float(count) : null
    end
    'Fractional Cover - Weighted Sum': begin; Weighted Fractional Cover
      double_veg = total((height GT height_threshold) AND (last EQ 1) AND (single EQ 0))
      single_veg = total((single EQ 1) AND (height GT height_threshold))
      last_idx = where(last EQ 1, last_cnt)
      first_idx = where(first EQ 1, first_cnt)
      if (last_cnt GT 0) then begin
        gnd_veg = total((height[last_idx] LE height_threshold) AND (height[first_idx] GT height_threshold))
      endif else begin
        gnd_veg = 0.0
      endelse
      metric = (weights[0] * double_veg + weights[1] * single_veg + weights[2] * gnd_veg) / float(no_obs)
    end
    'Fractional Cover - Intensity Ratio': begin ; Intensity Fractional Cover
      if (count GT 0) then begin
        iFC = HeightProfile(height[index], data[index].(3), first[index], null, interval, height_threshold, $
          rhovg_method, rhovg_percentile, counts, locations, rhov_rhog, constant)
        if (n_elements(iFC) GT 1) then begin
          iFC = reverse(total(reverse(iFC), /cumulative))
          metric = iFC[where(locations EQ height_threshold)]
        endif else begin
          metric = iFC
        endelse
      endif else begin
        metric = null
      endelse
    end
    'Canopy Openness Index': begin; HCOI
      idx = where(height[index] GT height_threshold, cnt)
      if (count GT 0) then begin
        maxh = max(height[index[idx]])
        n = float(cnt)
        if (maxh GT 0.0) then begin
          value = 1.0 / n * total((replicate(maxh, n) - height[index[idx]]) / maxh)
        endif else begin
          value = 0.0
        endelse
      endif else begin
        value = null
      endelse
    end
    'Canopy Relief Ratio': begin ; Canopy relief ratio
      if (count GT 0) then begin
        idx = where(height[index] GT height_threshold, cnt)
        if (cnt GT 0) then begin
          metric = (mean(height[index[idx]]) - min(height[index[idx]])) / (max(height[index[idx]]) - min(height[index[idx]]))
        endif else begin
          metric = 0.0
        endelse
      endif else begin
        metric = null
      endelse
    end
    'Height Percentile - Counts': begin ; Percentile height (returns)
      if (count GT 0) then begin
        metric = GetPercentile(height[index], percentile, method='Counts')
      endif else begin
        metric = null
      endelse
    end
    'Height Percentile - Intensity': begin ; Percentile height (intensity)
      if (count GT 0) then begin
        metric = GetPercentile(height[index], percentile, intensity=data[index].(3), method='Intensity')
      endif else begin
        metric = null
      endelse
    end
    'Height Percentile - Cover (Counts)': begin ; Percentile height (cover)
      if (count GT 0) then begin
        metric = GetPercentile(height[index], percentile, intensity=data[index].(3), binsize=vbinsize, method='Cover (Counts)')
      endif else begin
        metric = null
      endelse
    end
    else: metric = float(count)
  endcase
  
  return, metric
  
END
