;+
; NAME:
;
;       WriteLAS
;
; PURPOSE:
;
;       This program writes a .las file from the input header, variable length records, and data.
;
;       For more information on the .las lidar data format, see http://www.lasformat.org
;
; AUTHOR:
;
;       David Streutker
;       Boise Center Aerospace Laboratory
;       Idaho State University
;       322 E. Front St., Ste. 240
;       Boise, ID  83702
;       http://geology.isu.edu/BCAL
;
; CALLING SEQUENCE:
;
;       WriteLAS, outputFile, header, data, records=records, check=check, nodata=nodata
;
; RETURN VALUE:
;
;       None.  The procedure creates a .las file using the input header and data structures and optional
;       variable length record structures.
;
;       Set the RECORDS keyword to a named variable that contains a structure or array of structures
;       of the variable length records.
;
;       Set the CHECK keyword to correct any internal inconsistancies in the header before writing the new file.
;
;       Set the NODATA keyword to write only the header and any available variable length records
;
; MODIFICATION HISTORY:
;
;       Written by David Streutker, August 2006.
;       Added CHECK keyword, March 2007.
;       Added RECORDS and NODATA keywords, June 2007.
;       Changed header.softwareID to reflect top level program, March 2008. John Armston.
;       Minor change to check keyword code, March 2008. John Armston.
;       Updated for LAS 1.2 format. 2010. John Armston.
;       Update for LAS 1.3 format. Nov 2010. John Armston.
;
;###########################################################################
;
; LICENSE
;
; This software is OSI Certified Open Source Software.
; OSI Certified is a certification mark of the Open Source Initiative.
;
; Copyright � 2006 David Streutker, Idaho State University.
;
; This software is provided "as-is", without any express or
; implied warranty. In no event will the authors be held liable
; for any damages arising from the use of this software.
;
; Permission is granted to anyone to use this software for any
; purpose, including commercial applications, and to alter it and
; redistribute it freely, subject to the following restrictions:
;
; 1. The origin of this software must not be misrepresented; you must
;    not claim you wrote the original software. If you use this software
;    in a product, an acknowledgment in the product documentation
;    would be appreciated, but is not required.
;
; 2. Altered source versions must be plainly marked as such, and must
;    not be misrepresented as being the original software.
;
; 3. This notice may not be removed or altered from any source distribution.
;
; For more information on Open Source Software, visit the Open Source
; web site: http://www.opensource.org.
;
;###########################################################################

pro WriteLAS, outputFile, header, data, records=records, check=check, nodata=nodata, wdp=wdp

  compile_opt idl2
  
  ; Make sure the header fields are updated
  header.signature  = byte('LASF')
  header.softwareID = byte(strjoin(['RSC LAS Tools', !QRSC_LIDAR_VERSION, ', IDL', !version.release], ' '))
  
  date = bin_date(systime(/utc))
  day  = julday(date[1],date[2],date[0]) - julday(1,1,date[0]) + 1
  header.day  = uint(day)
  header.year = uint(date[0])
  
  ; If requested, perform consistency check
  if keyword_set(check) then begin
  
    ; versionMinor specifics
    case header.versionMinor of
      0: begin
        header.globalEncoding = 0US
        header.headerSize = 227US
        header.dataOffset = 227UL
      end
      1: begin
        header.globalEncoding = 0US
        header.headerSize = 227US
        header.dataOffset = 227UL
      end
      2: begin
        header.globalEncoding = 1US
        header.headerSize = 227US
        header.dataOffset = 227UL
      end
      3: begin
        header.globalEncoding = 128US
        header.headerSize = 235US
        header.dataOffset = 235UL
      end
    endcase
    
    if (n_tags(records) gt 0) then begin
      header.dataOffset += total(records.recordLength, /int) + 54B * n_elements(records)
      if (header.pointFormat ge 4) then header.dataOffset += 26B ; Waveform packet descriptor
      header.nRecords = n_elements(records)
    endif else begin
      header.nRecords = 0
    endelse
    
    if ~ keyword_set(nodata) then begin
    
      header.pointLength = n_tags(data, /data_length)
      case header.pointLength of
        20: header.pointFormat = 0
        28: header.pointFormat = 1
        26: header.pointFormat = 2
        34: header.pointFormat = 3
        57: header.pointFormat = 4
        63: header.pointFormat = 5
      endcase
      
      header.nPoints  = n_elements(data)
      header.nReturns = histogram(ishft(ishft(data.nReturn, 5), -5), min=1, max=5)
      if (total(header.nReturns) ne header.nPoints) then header.nReturns[0] += (header.nPoints - total(header.nReturns))
      
      header.xMax = max(data.x,  min=xMin) * header.xScale + header.xOffset
      header.yMax = max(data.y, min=yMin) * header.yScale + header.yOffset
      header.zMax = max(data.z,  min=zMin) * header.zScale + header.zOffset
      header.xMin = xMin * header.xScale + header.xOffset
      header.yMin = yMin * header.yScale + header.yOffset
      header.zMin = zMin * header.zScale + header.zOffset
      
    endif else begin
    
      case header.pointFormat of
        0: header.pointLength = 20US
        1: header.pointLength = 28US
        2: header.pointLength = 26US
        3: header.pointLength = 34US
        4: header.pointLength = 57US
        5: header.pointLength = 63US
      endcase
      
    endelse
    
  endif
  
  ; Open the output file and write the header
  openw, outputLun, outputFile, /get_lun, /swap_if_big_endian
  writeu, outputLun, header
  
  ; If variable length records are present, write them
  if (n_tags(records) gt 0) then begin
    for a=0,n_elements(records)-1 do begin
      for b=0,4 do writeu, outputLun, records[a].(b)
      if (records[a].recordLength gt 0) then begin
        if (n_tags(*records[a].data) gt 0) then begin
          for b=0,n_tags(*records[a].data)-1 do writeu, outputLun, *records[a].data.(b)
        endif else begin
          writeu, outputLun, *records[a].data
        endelse
      endif
    endfor
  endif
  
  ; Move to the start of the data
  point_lun, outputLun, header.dataOffset
  
  ; Unless the NODATA flag is set, write the data
  if ~ keyword_set(nodata) then begin
  
    ; Write the point data
    writeu, outputLun, data
    
    ; Write the waveform data
    if (header.pointFormat ge 4) then begin
      if (header.wdp gt 0) then begin
      
        ; Write extended length variable record
        ; Extended record length after header is zero because WDP are stored in a separate file
        record = InitRecordLAS(/eVLR,/noData)
        for a=0L,4L do writeu, outputLun, record.(a)
        if arg_present(wdp) then writeu, outputLun, wdp
        
      endif else begin
      
        ; Write wdp file
        if arg_present(wdp) then begin
          fparts = strsplit(outputFile, '.')
          openw, wdpLun, fparts+'.wdp', /get_lun, /swap_if_big_endian
          writeu, wdpLun, wdp
          free_lun, wdpLun
        endif
        
      endelse
      
    endif
    
  endif
  
  ; Close the file
  free_lun, outputLun
  
end
