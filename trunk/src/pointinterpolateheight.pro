;+
; NAME:
;
;   PointInterpolateHeight
;
; PURPOSE:
;
;   Interpolate return elevations to an irregular grid and derive above-ground height (AGH).
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

PRO PointInterpolateHeight, tileStruct, col_n, row_n, method, null, min_points, sectors, smoothing, outputType

  ; Keywords
  forward_function filterReturns
  
  ; Read tiles
  nTiles = n_elements(tileStruct.name)
  for i = 0L, nTiles-1L, 1L do begin
    if (tileStruct.empty[i] EQ 0) then begin
      cdiff = abs(tileStruct.col[i] - col_n)
      rdiff = abs(tileStruct.row[i] - row_n)
      if (cdiff LE 1 AND rdiff LE 1) then begin
        ReadLAS, tileStruct.name[i], header, data
        if (cdiff EQ 0 AND rdiff EQ 0) then begin
          outFile = tileStruct.name[i]
          cindex = ulindgen(header.nPoints) + n_elements(all_data)
        endif
        all_data = n_elements(all_data) EQ 0 ? temporary(data) : [temporary(all_data), temporary(data)]
      endif
    endif
  endfor
  
  ; Get locations for interpolation
  nPoints = n_elements(all_data)
  gnd = filterReturns(all_data, type=4)
  gindex = where(gnd EQ 1, gcount, complement=vindex, ncomplement=vcount)
  
  ; Do interpolation
  easting = all_data[gindex].(0) * header.xScale + header.xOffset
  northing = all_data[gindex].(1) * header.yScale + header.yOffset
  zdata = all_data[gindex].(2) * header.zScale + header.zOffset
  grid_input, easting, northing, zdata, easting, northing, zdata
  triangulate, easting, northing, triangles
  
  ; Do the interpolation
  if (vcount gt 0) then begin
    case method of
      'NearestNeighbor': begin
        outData = griddata(easting, northing, $
          zdata, method=method, triangles=triangles, missing=null, $
          xout=all_data[vindex].(0) * header.xScale + header.xOffset, yout=all_data[veg_idx].(1) * header.yScale + header.yOffset)
      end
      'Linear': begin
        outData = griddata(easting, northing, $
          zdata, method=method, triangles=triangles, missing=null, $
          xout=all_data[vindex].(0) * header.xScale + header.xOffset, yout=all_data[veg_idx].(1) * header.yScale + header.yOffset)
      end
      'InverseDistance': begin
        outData = griddata(easting, northing, $
          zdata, power=power, method=method, triangles=triangles, min_points=min_points, missing=null, sectors=sectors, empty_sectors=1, $
          xout=all_data[vindex].(0) * header.xScale + header.xOffset, yout=all_data[veg_idx].(1) * header.yScale + header.yOffset, smoothing=smoothing)
      end
      'NaturalNeighbor': begin
        outData = griddata(easting, northing, $
          zdata, method=method, triangles=triangles, missing=null, $
          xout=all_data[vindex].(0) * header.xScale + header.xOffset, yout=all_data[vindex].(1) * header.yScale + header.yOffset)
      end
      'PolynomialRegression': begin
        outData = griddata(easting, northing, $
          zdata, power=power, method=method, triangles=triangles, min_points=min_points, missing=null, sectors=sectors, empty_sectors=1, $
          xout=all_data[vindex].(0) * header.xScale + header.xOffset, yout=all_data[vindex].(1) * header.yScale + header.yOffset)
      end
    endcase
    
    ; Calculate height
    height = fltarr(nPoints)
    height[vindex] = (all_data[vindex].(2) * header.zScale + header.zOffset) - outData
    height = temporary(height) > 0.0
    
  endif else begin
  
    height = fltarr(nPoints)
    
  endelse
  
  ; Sometime crazy interpolations occur at the edges
  ; In these cases set the height value to null
  eindex = where(height GT 150.0, ecount)
  if (ecount GT 0) then height[eindex] = null
  
  ; Write output to file
  ReadLAS, outFile, header, data
  case outputType of
    0: begin ; Point source ID
      data.(8) = 0L
      data.(8) = long(height[cindex] / 0.01D)
      header.systemID = 0B
      header.systemID = byte('Height: Source')
    end
    1: begin ; Elevation
      data.(2) = long(height[cindex] / 0.01D)
      header.systemID = 0B
      header.systemID = byte('Height: Elev')
    end
  endcase
  WriteLAS, outFile, header, data
  
END