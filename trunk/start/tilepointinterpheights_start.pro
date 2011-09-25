;+
; NAME:
;
;   tilepointinterpheights_start
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

PRO TilePointInterpHeights_start, event

  Widget_Control, event.top, Get_UValue=info
  
  ; Open log file
  j_fpart = strtrim(round(systime(/julian)*10), 2)
  openw,  loglun, file_dirname(info.infile[0], /mark_directory) + 'AGH_Processing_Notes_' + j_fpart + '.txt', /get_lun, width=200
  printf, loglun, 'Input files: ', info.infile
  start_mem = memory(/current)
  t = systime(1)
  
  ; Derive product
  Widget_Control, info.tmpflag, Get_Value=tmp
  tilexsize = info.tilexsize->Get_Value()
  tileysize = info.tileysize->Get_Value()
  power = info.power->Get_Value()
  null = info.null->Get_Value()
  smoothing = info.smoothing->Get_Value()
  min_points = info.min_points->Get_Value()
  sectors = info.sectors->Get_Value()
  case info.method_droplist->GetSelection() of
    info.interpList[0]: method = 'NearestNeighbor'
    info.interpList[1]: method = 'Linear'
    info.interpList[2]: method = 'InverseDistance'
    info.interpList[3]: method = 'NaturalNeighbor'
  endcase
  Widget_Control, info.output_type, Get_Value=outputType
  Widget_Control, event.top, /Destroy
  TileInterpolateHeight, info.infile, method=method, tilesize=[tilexsize,tileysize], null=null, $
    min_points=min_points, sectors=sectors, smoothing=smoothing, outputType=outputType, tmp=tmp
    
  ; Write to and close log file
  printf, loglun, 'Time required: ', systime(1) - t, ' seconds'
  printf, loglun, 'Memory required: ', memory(/highwater) - start_mem, ' bytes'
  outputTypeStr = (outputType EQ 0) ? 'SourceID' : 'Elev'
  printf, loglun, 'Interpolation method: ', method
  printf, loglun, 'LAS field with AGH: ', outputTypeStr
  printf, loglun, 'Tile size: ', tilexsize, tileysize, ' m'
  free_lun, loglun
  
  ; Make file directory cwd
  cd, file_dirname(info.infile[0])
  
END
