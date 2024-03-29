;+
; NAME:
;
;   LidarENVISurfaceBinCanopy_GUI
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

PRO LidarENVISurfaceBinCanopy_GUI

  FORWARD_FUNCTION FSC_Droplist, FSC_INPUTFIELD
  
  ; Main
  tlb = WIDGET_BASE(TITLE='ENVI Product: Lidar Canopy Surface', tlb_frame_attr=1, column=3, xpad=3, ypad=3, space=3)
  
  ; Get the input file/s
  inFile = dialog_pickfile(filter='*.las', /fix_filter, /multiple_files, /must_exist, title='Please Select LAS File/s (Ctrl-click to select multiple files)', dialog_parent=tlb)
  if (inFile[0] EQ '') then return
  nFiles = n_elements(inFile)
  
  ; Create list of product types
  productList = ['Fractional Cover', $
    'Height Percentile', $
    'Canopy Openness Index', $
    'Canopy Relief Ratio', $
    'Plant Area Index Proxy', $
    'Density Deciles', $
    'Fractional Cover Profile', $
    'Apparent Foliage Profile']
    
  coverList = ['Count Ratio', $
    'Weighted Sum', $
    'Intensity Ratio']
    
  percentileList = ['Counts', $
    'Intensity', $
    'Cover (Counts)']
    
  ; Create list of return types
  returnList = ['First', $
    'Last', $
    'Singular', $
    'All']
    
  ; Create list of available data products
  projList = ['Map Grid Australia 1994', $
    'British National Grid', $
    'UTM (WGS84)']
    
  ; Create list of hemispheres
  hemiList = ['South', $
    'North']
    
  ; Create list of rhov rhog methods
  rhovgList = ['Mean / Mean', $
    'Max / Mean', $
    'Percentile /  Mean', $
    'Constant /  Mean', $
    'Constant']
    
  ; Work out file bounds
  xMin = dblarr(nFiles)
  xMax = dblarr(nFiles)
  yMin = dblarr(nFiles)
  yMax = dblarr(nFiles)
  for a = 0L, nFiles-1L do begin
    ReadHeaderLAS, inFile[a], header
    xMin[a] = header.xMin
    xMax[a] = header.xMax
    yMin[a] = header.yMin
    yMax[a] = header.yMax
  endfor
  
  ; Create the widget that will record the user parameters
  infile_bn = FILE_BASENAME(inFile)
  infile_dn = FILE_DIRNAME(inFile)
  text = WIDGET_LABEL(tlb, value='Selected LAS Files. Check the bounds for errors.', frame=0, /align_center)
  wTree = WIDGET_TREE(tlb)
  wtRoot = WIDGET_TREE(wTree, VALUE=infile_dn[0], /FOLDER, /EXPANDED)
  file_bm = replicate(0B,16,16,3)
  for i = 0L, nFiles-1L, 1L do begin
    wtFile = WIDGET_TREE(wtRoot, VALUE=infile_bn[i], /FOLDER, /EXPANDED, BITMAP=file_bm)
    wtLeaf = WIDGET_TREE(wtFile, VALUE='UL Easting : ' + strtrim(string(xMin[i],format='(f10.2)'),2), UVALUE='ChangeBounds')
    wtLeaf = WIDGET_TREE(wtFile, VALUE='UL Northing : ' + strtrim(string(yMax[i],format='(f10.2)'),2), UVALUE='ChangeBounds')
    wtLeaf = WIDGET_TREE(wtFile, VALUE='LR Easting : ' + strtrim(string(xMax[i],format='(f10.2)'),2), UVALUE='ChangeBounds')
    wtLeaf = WIDGET_TREE(wtFile, VALUE='LR Northing : ' + strtrim(string(yMin[i],format='(f10.2)'),2), UVALUE='ChangeBounds')
  endfor
  
  tlb1 = widget_base(tlb, column=1, xsize=!QRSC_LIDAR_XSIZE)
  text1 = WIDGET_LABEL(tlb1, value='Raster Settings', frame=0, /align_center)
  Base1 = widget_base(tlb1, column=1, frame=1)
  prod_droplist = FSC_Droplist(Base1, Value=productList, Index=0, title='Product Type : ')
  return_droplist = FSC_Droplist(Base1, Value=returnList, Index=0, title='Return Type : ')
  text = WIDGET_LABEL(Base1, value='Exclude following classes from non-ground returns : ', frame=0, /align_left)
  fields = ['Water','Buildings']
  excludeTable = cw_bgroup(Base1, fields, column=2, /nonexclusive)
  max_height = FSC_INPUTFIELD(Base1, Title='Maximum Height Used (m) : ', Value=100.0, /FloatValue, LabelAlign=1, decimal=2, /positive)
  text = WIDGET_LABEL(Base1, value='Maximum Height Used also defines the maximum height of vertical profile products', frame=0, /align_left)
  resolution = FSC_INPUTFIELD(Base1, Title='Spatial resolution (m) : ', Value=5.0, /FloatValue, /Positive, LabelAlign=1, decimal=2)
  null = FSC_INPUTFIELD(Base1, Title='"No Data" Value * : ', Value=-1.0, /FloatValue, LabelAlign=1, decimal=2)
  text = WIDGET_LABEL(Base1, value='* Must be < elevation minimum.', frame=0, /align_left)
  proj_droplist = FSC_Droplist(Base1, Value=projList, Index=0, title='Projection : ')
  zone = FSC_INPUTFIELD(Base1, Title='MGA/UTM Zone : ', Value=55, /IntegerValue, /Positive, LabelAlign=1)
  hemi_droplist = FSC_Droplist(Base1, Value=hemiList, Index=0, title='UTM hemisphere : ')
  tilexsize = FSC_INPUTFIELD(Base1, Title='X tile size (m) : ', Value=100, /IntegerValue, /Positive, LabelAlign=1)
  tileysize = FSC_INPUTFIELD(Base1, Title='Y tile size (m) : ', Value=100, /IntegerValue, /Positive, LabelAlign=1)
  text = WIDGET_LABEL(Base1, value='For selected LAS files : ', frame=0, /align_left)
  fields = ['Create a single surface from all LAS files', 'Create a separate surface for each LAS file']
  surfacetype = cw_bgroup(Base1, fields, column=1, /exclusive, set_value=0)
  fields = ['Use system directory for temporary files']
  tmpflag = cw_bgroup(Base1, fields, /nonexclusive, SET_VALUE=[1])
  
  tlb3 = widget_base(tlb, column=1, xsize=!QRSC_LIDAR_XSIZE)
  text3 = WIDGET_LABEL(tlb3, value='Lidar Index and Fractional Cover Product Settings', frame=0, /align_center)
  Base3 = widget_base(tlb3, column=1, frame=1)
  cover_droplist = FSC_Droplist(Base3, Value=coverList, Index=0, title='Method : ')
  height_threshold = FSC_INPUTFIELD(Base3, Title='Lower (>) Height Threshold (m) : ', Value=0.5, /FloatValue, LabelAlign=1, decimal=2)
  text = WIDGET_LABEL(Base3, value='Lower height thresold is also used as lower bound of Density Deciles', frame=0, /align_left)
  height_threshold_top = FSC_INPUTFIELD(Base3, Title='Upper (<=) Height Threshold (m) : ', Value=50.0, /FloatValue, LabelAlign=1, decimal=2)
  text = WIDGET_LABEL(Base3, value=' Weights for "Weighted Sum" : ', frame=0, /align_left)
  weight_VegGnd = FSC_INPUTFIELD(Base3, Title=' First Returns Only : ', Value=0.50, /FloatValue, LabelAlign=1, decimal=2)
  weight_Double = FSC_INPUTFIELD(Base3, Title=' First & Last Returns : ', Value=1.00, /FloatValue, LabelAlign=1, decimal=2)
  weight_Single = FSC_INPUTFIELD(Base3, Title=' Singular Returns : ', Value=1.00, /FloatValue, LabelAlign=1, decimal=2)
  text = WIDGET_LABEL(Base3, value='Calibration of "Count Ratio" to cover metrics:', frame=0, /align_left)
  text = WIDGET_LABEL(Base3, value='Note: This has only been tested for a range of sites within Queensland', frame=0, /align_left)
  text = WIDGET_LABEL(Base3, value='(Armston et al., 2009).', frame=0, /align_left)
  fields = ['None', 'Plant Projective Cover', 'Foliage Projective Cover']
  metrictype = cw_bgroup(Base3, fields, column=1, /exclusive, set_value=0)
  
  tlb4 = widget_base(tlb, column=1, xsize=!QRSC_LIDAR_XSIZE)
  text4 = WIDGET_LABEL(tlb4, value='Height Percentile Product Settings', frame=0, /align_center)
  Base4 = widget_base(tlb4, column=1, frame=1)
  height_percentile = FSC_INPUTFIELD(Base4, Title='Height Percentile (0-1) : ', Value=0.95, /FloatValue, LabelAlign=1, decimal=2)
  text = WIDGET_LABEL(Base4, value='Height percentile is also used as upper bound of Density Deciles', frame=0, /align_left)
  percentile_droplist = FSC_Droplist(Base4, Value=percentileList, Index=0, title='Method : ')
  text = WIDGET_LABEL(Base4, value='Settings for the Cover (Counts) method : ', frame=0, /align_left)
  vertical_binsize = FSC_INPUTFIELD(Base4, Title='Vertical Bin Size (m) : ', Value=0.5, /FloatValue, LabelAlign=1, decimal=2)
  text = WIDGET_LABEL(Base4, value='Vertical Bin Size is also used for fractional cover and apparent foliage profiles', frame=0, /align_left)
  
  tlb5 = widget_base(tlb, column=1, xsize=!QRSC_LIDAR_XSIZE)
  text5 = WIDGET_LABEL(tlb5, value='Settings Unique to Intensity Derived Products', frame=0, /align_center, XOFFSET=5)
  Base5 = widget_base(tlb5, column=1, frame=1)
  rhovg_droplist = FSC_Droplist(Base5, Value=rhovgList, Index=0, title='Plant/Ground Reflectivity Ratio : ')
  text = WIDGET_LABEL(Base5, value=' The ratio is calculated from the first returns.', frame=0, /align_left)
  text = WIDGET_LABEL(Base5, value=' Be aware this requires a number of assumptions.', frame=0, /align_left)
  rhovg_percentile = FSC_INPUTFIELD(Base5, Title='Plant Intensity Percentile (0-1) : ', Value=0.99, /FloatValue, LabelAlign=1, decimal=2)
  constant = FSC_INPUTFIELD(Base5, Title='Constant Value : ', Value=1.0, /FloatValue, LabelAlign=1, decimal=2)
  text = WIDGET_LABEL(Base5, value=' e.g. A value determined from field spectra or optimisation.', frame=0, /align_left)
  
  tlb6 = widget_base(tlb, column=1,xsize=!QRSC_LIDAR_XSIZE)
  text6 = WIDGET_LABEL(tlb6, value='Output File Information', frame=0, /align_center)
  Base6 = widget_base(tlb6, column=1, frame=1)
  text = WIDGET_LABEL(Base6, value='Surface creation is more memory efficient and faster than previously.', frame=0, /align_left)
  text = WIDGET_LABEL(Base6, value='LAS files are now split into many tiles before binning.', frame=0, /align_left)
  text = WIDGET_LABEL(Base6, value='All temporary tiles are stored in the system tmp directory', frame=0, /align_left)
  text = WIDGET_LABEL(Base6, value='It is assumed the geographic bounds in the LAS file headers are correct.', frame=0, /align_left)
  text = WIDGET_LABEL(Base6, value='The output filename is:', frame=0, /align_left)
  text = WIDGET_LABEL(Base6, value='RSCLASTools_Canopy_<product>_<return>_<resolution>', frame=0, /align_left)
  text = WIDGET_LABEL(Base6, value='e.g. RSCLASTools_Canopy_Maximum_All_002500 (resolution is in cm)', frame=0, /align_left)
  
  Base7 = widget_base(tlb, column=1,xsize=!QRSC_LIDAR_XSIZE)
  button = Widget_Button(Base7, Value='Start Surface Creation', UValue='StartENVISurfaceBinRasterCanopy')
  button = Widget_Button(Base7, Value='Cancel', UValue='Quit')
  
  ; Do the rest
  Widget_Control, tlb, /Realize, Set_UValue={ $
    prod_droplist:prod_droplist, $ ; product
    resolution:resolution, $ ; bin size
    cover_droplist:cover_droplist, $; cover method
    percentile_droplist:percentile_droplist, $; percentile method
    rhovg_droplist:rhovg_droplist, $ ; rhovg
    hemi_droplist:hemi_droplist, $ ; UTM hemisphere
    proj_droplist:proj_droplist, $ ; projection
    return_droplist:return_droplist, $ ; return type
    vertical_binsize:vertical_binsize, $  ; vertical binsize
    xMax:xMax, $ ; x bounds
    yMax:yMax, $ ; y bounds
    xMin:xMin, $ ; x bounds
    yMin:yMin, $ ; y bounds
    null:null, $ ; null value
    zone:zone, $ ; MGA/UTM zone
    hemiList:hemiList, $ ; UTM hemisphere list
    tilexsize:tilexsize, $ ; tilexsize
    tileysize:tileysize, $ ; tileysize
    infile:infile, $ ; filename/s
    productList:productList, $ ; Products
    coverList:coverList, $ ; Cover methods
    percentileList:percentileList, $ ; Percentile methods
    rhovgList:rhovgList, $ ; rhovg types
    projList:projList, $ ; Projection types
    returnList:returnList, $ ; Return type
    constant:constant, $ ; Constant
    max_height:max_height, $ ; maximum height to consider
    rhovg_percentile:rhovg_percentile, $ ; rhovg percentile
    height_threshold:height_threshold, $ ; height threshold
    height_threshold_top:height_threshold_top, $ ; upper height threshold
    height_percentile:height_percentile, $ ; height percentile
    weight_VegGnd:weight_VegGnd, $ ; weight Veg/Gnd
    weight_Double:weight_Double, $ ; weight Double
    weight_Single:weight_Single, $ ; weight Single
    metrictype:metrictype, $ ; cover metric
    tmpflag:tmpflag, $ ; Temporary file flag
    excludeTable:excludeTable, $ ; Classes to exclude
    surfacetype:surfacetype} ; Single or separate surfaces
  XManager, 'RSC_LAS_Tools', tlb, /No_Block
  
END
