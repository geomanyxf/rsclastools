# _RSC LAS Tools_ #
**Current version: 1.9.3** ([Modification history](http://code.google.com/p/rsclastools/wiki/ModificationHistory))



## DESCRIPTION ##

Some IDL routines were written pre-2005 for command-line processing of ASCII Optech ALTM 3025 Lidar data in time-sequential format. Subsequent use of these routines for other projects resulted in the development of a GUI interface and support for LAS format files.
This software is not actively developed and better tools now exist for lidar remote sensing of vegetation. If you are interested in further development of open source tools in IDL for processing lidar data, check out BCAL LiDAR Tools (http://code.google.com/p/bcal-lidar-tools/). If you are interested in open source tools for discrete-return and waveform lidar data from a range of terrestrial and airborne platforms, check out SPDLib (http://www.spdlib.org).


## FUNCTIONALITY ##

This software is able to process Lidar data in the LAS 1.0, 1.1, 1.2 and 1.3 format (full waveform data in LAS 1.3 files is currently ignored).
See http://www.asprs.org/society/committees/standards/lidar_exchange_format.html
Image file outputs are ENVI format.

Products can be generated as images at a chosen spatial resolution or as ASCII files for "point" products, e.g. a field site that's been subsetted from the original LAS file.

An on-the-fly tiling procedure suitable for interpolating/binning large or many LAS files is now implemented.

Subsequent masking, mosaicing, visualisation and analysis is then better done using your preferred programming language or software.

  1. Data viewer
    * View and/or fix LAS header.
    * View variable length record headers
  1. Data manipulation and conversion
    * Import ASCII to LAS.
    * Export to ASCII or shapefile.
    * Spatial and temporal tiling.
    * Subset by user defined ellipse/rectangle or by LAS file attribute.
    * Create a shapefile of the spatial extent of the LAS file data.
    * Merge LAS files.
  1. Ground classification (progressive morphological filter)
    * The elevation filter used is based on Zhang _et al_. (2003)
  1. Canopy products
    * Canopy Height Model and intensity image. A faster and more memory efficient on-the-fly tiling procedure suitable for large or many LAS files is now implemented.
    * Fractional cover metrics using return count or intensity ratios. Optional calibration to some foliage cover metrics (Armston _et al_., 2009).
    * Height that a fraction of return counts, summed intensity or projected cover is below (height percentiles).
    * Canopy openness index (Lee and Lucas, 2007), canopy relief ratio (Pike and Wilson, 1971) and a plant area index proxy (Morsdorf _et al_., 2006), and density deciles.
    * Cumulative gap fraction and apparant foliage profiles (plus its relative and derivative profile), and plant/ground reflectance ratio. Note: Where used, the range dependency of the intensity is not accounted for. You need the flight trajectory data to do this.
  1. Terrain products
    * Digital Elevation Model.
    * Slope and aspect
    * Local roughness
  1. Statistics products
    * Minimum, maximum, median, MAD, range.
    * Moments (mean to kurtosis).
    * Return count and density.

Below are brief descriptions of the different interpolation methods used in different parts of this software (IDL made it easy...):
  * Inverse Distance Weighted: Data points closer to the grid points have more effect than those which are further away.
  * Linear: Grid points are linearly interpolated from triangles formed by Delaunay triangulation.
  * Natural Neighbour: Each interpolant is a linear combination of the three vertices of its enclosing Delaunay triangle and their adjacent vertices.
  * Nearest Neighbour: The grid points have the same value as the nearest data point.
  * Quintic Polynomial: Grid points are interpolated with quintic polynomials from triangles formed by Delaunay triangulation.
  * Polynomial Regression: Each interpolant is a least-squares fit of a polynomial in X and Y of the specified power to the specified data points.
  * Kriging: Data points and their spatial variance are used to determine trends which are applied to the grid points.
  * Radial Basis Function: The effects of data points are weighted by a function of their radial distance from a grid point.


## INSTALLATION AND USE ##

This software is open source and the IDL Virtual Machine will run it, so you do not need an IDL licence.
The IDL Virtual Machine can be downloaded from the [ITTVIS website](http://www.ittvis.com/ProductServices/IDL/IDLVirtualMachine.aspx).
You need IDL version 6.3 or greater for this software to work.

If running Windows, then you just need to double click the rsc\_las\_tools.sav file, or run the IDL Virtual Machine from the start menu. Otherwise enter the following on the command line:
```
idl -vm=<filepath>
where <filepath> is the full path to the "rsc_las_tools_yyyymmdd.sav" file
e.g. idl -vm=/usr/people/armstonj/rsc_las_tools_20101207.sav
```


## DEPENDENCIES ##

The LAS format I/O routines were originally sourced from an early version of David Streutkers "ENVI LiDAR Tools" and further developed for this software. See http://bcal.geology.isu.edu/envitools.shtml for the current version of this software.

Several IDL widget programs were sourced from David Fannings website (http://www.dfanning.com).


## TROUBLESHOOTING ##

Make sure that any LAS files created by RSCLASTools are only processed using the same software version. You may run into trouble otherwise.

This software requires the LAS header values to be complete and correct, particularly the point format, byte offset to data and spatial extent values. Unfortunately, many lidar providers do not provide correct or complete LAS header values or even data fields. Please check your LAS files carefully.

LAS files with data projected to geographic coordinates will also cause problems as many routines have default values in metres.

A small number of routines still read the entire LAS file into memory, which is a problem if you don't have much free memory. Subset your LAS file if you run into this problem.

I don't support this software but feel free to contact me if you find any bugs, which you probably will. Please make sure you're using the most recent and not a deprecated version. You may also get frustrated by the lack of documentation and/or monolithic procedural code, so please understand RSCLASTools is only on Google Code as a means to distribute to colleagues who currently use it.


## REFERENCES ##

Some methods that I have used or test and ended up in my IDL code have been sourced from the following publications:

> Lee, A.C. and Lucas, R.M., 2007. _Remote Sensing of Environment_, 111: 493-518.
> A LiDAR-derived canopy density model for tree stem and crown mapping in Australian forests.

> Pike, R.J. and Wilson, S.E., 1971. _Geological Society of America Bulletin_, 82: 1079-1084.
> Elevation relief ratio, hypsometric integral and geomorphic area altitude analysis.

> Morsdorf, F., Kotz, B., Meier, E., Itten, K. and Allgower, B., 2006. _Remote Sensing of Environment_, 104(1): 50-61.
> Estimation of LAI and fractional cover from small footprint airborne laser scanning data based on gap fraction.

> Zhang, K., Chen, S., Whitman, D., Shyu, M., Yan, J. and Zhang, C., 2003. _IEEE Transactions on Geoscience & Remote Sensing_, 41(4).
> A Progressive Morphological Filter for Removing Nonground Measurements from Airborne Lidar Data.


Code included in this software has been used in the following publications:

> Johansen, K., Arroyo, L.A., Armston, J., Phinn, S. and Witte, C. 2010. _Ecological Indicators_, 10(4): 796-807.
> Mapping riparian condition indicators in a sub-tropical savanna environment from discrete return LiDAR data using object-based image analysis.

> Arroyo, L., Johansen, K., Armston, J. and Phinn, S. 2010. _Forest Ecology and Management_, 259(3): 598-606.
> Integration of LiDAR and QuickBird imagery for mapping riparian biophysical parameters and land cover types in Australian tropical savannas.

> Moffiet, T., Armston, J. and Mengerson, K. 2010. _ISPRS Journal of Photogrammetry and Remote Sensing_, 65(1): 26-41.
> Motivation, development and validation of a new spectral greenness index: A spectral dimension related to foliage projective cover.

> Armston, J., Denham, R., Danaher, T., Scarth, P. and Moffiet, T. 2009. _Journal of Applied Remote Sensing_, 3: 033540.
> Prediction and validation of foliage projective cover from Landsat-5 TM and Landsat-7 ETM+ imagery for Queensland, Australia.

> Gill, T., Phinn, S., Armston, J. and Pailthorpe, B. 2009. _International Journal of Remote Sensing_, 30(6): 1547-1565.
> Estimating tree foliage-cover change in Australia: challenges of using the MODIS 250 m vegetation index product.

> Rosette, J., North, P., Suárez, J. and Armston, J. 2009. _International Journal of Remote Sensing_, 30(19): 5229-5237.
> Comparison of biophysical parameter retrieval for forestry using airborne and satellite LiDAR.