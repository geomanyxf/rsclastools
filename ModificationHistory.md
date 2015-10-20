# RSC LAS Tools Modification History #

## Version 1.9.3 - 23/5/2012 ##
  * Fixed bug in array index for non-ground returns in call to some interpolation methods in interpolation of point heights.
  * Added statement to free lun after KML file is created.

## Version 1.9.2 - 3/2/2012 ##
  * Reading of LAS points now buffered for creation of extent SHP/KML files. Avoids memory issues. Buffer size now an input argument.
  * KML file altitude now clamped to ground rather than relative to ground.
  * Added Nick Goodwin as a contributor.

## Version 1.9.1 - 2/12/2011 ##
  * Fixed minor bug in calculation of fractional cover with buildings/water excluded

## Version 1.9 - 30/11/2011 ##
  * Added Classification, Scan Angle Rank and Source ID to interpolated raster product options
  * Fixed a bug in the LAS to ASCII exporter
  * Added option to exclude building and/or water when generating canopy and statistic point/raster products

## Version 1.8 - 3/10/2011 ##
  * Added min/max bounds to statistic product calculation
  * Fixed a bug in the TLS PTS file import

## Version 1.7 - 29/9/2011 ##
  * Fixed a several bugs reported in Version 1.6
  * Added fractional cover and apparent foliage profiles to raster products
  * Subset by location utility now extracts sites that partially overlap LAS file extent
  * Changed some default values used for canopy metric products

## Version 1.6 - 25/9/2011 ##
  * Added a check box to use the proper temp directory for the operating system (uncheck to use to directory the LAS data is in)
  * Fixed several bugs and made a number of improvements to the code for above-ground height LAS file generation
  * Fixed a major bug in the data binning that resulted in tile edges being apparent in final products based on above-ground height
  * Modified raster generation code to allow multiple layer raster products (e.g. for foliage profiles)
  * Added a canopy density decile metric that may be useful for biomass estimation
  * Fixed bug in creation of LAS extent KML files

## Version 1.5 - 7/1/2011 ##
  * Changed calculation of cumulative gap fraction
  * Fixed bug where incorrect height above ground data was read when generating point ASCII products
  * Fix bug where not all applicable pointFormat versions were recognised for each LAS version. This will solve a problem a number of people have run into.
  * Removed deprecated routines from source code
  * Started using sample LAS data from liblas website for testing.

## Version 1.4 - 6/1/2011 ##
  * Corrected calculation of apparent foliage profiles
  * Fixed bug where incorrect minX and minY header values were assigned during tiling
  * Fixed bug where vertices array used to create extent shp/kml files was 1D instead of 2D
  * Added area, centroid (x,y) and perimeter as attributes in extent shapefiles
  * Added option when creating extent shp/kml to use extents from header instead of point data
  * Rewrote code to merge las files to be more memory efficient and stricter with output LAS header values

## Version 1.3 - 21/12/2010 ##
  * Updated to read/write LAS 1.3 (there is currently no functionality to process waveform data packets)
    * Added variable length record header viewer
    * Removed 3D data viewer.
  * More bug fixes, more to come

## Version 1.2 - 22/11/2010 ##
  * Implemented on-the-fly tiling for:
    * generation of AGH LAS files
    * ground filtering
  * Minor syntax changes
  * Source code added to SVN

## Version 1.1 - 19/11/2010 ##
  * Numerous bug fixes. It now actually works :-/
  * Added function to recalculate LAS header fields

## Version 1.0 - 18/10/2010 ##
  * Added to Google Code for testing