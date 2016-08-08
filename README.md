# Create a polygon mask

Takes ina  raster dataset, changes the values to make it binary (i.e. 1/0) and then out pops a shapefile which adopts the values of the input raster.

The mask passed in is a transformed version of the GIMP DEM as modified following [Morlighem et al. 2014](http://www.nature.com/ngeo/journal/v7/n6/full/ngeo2167.html). The code framework will work for any mask, just change the path and the values which you need to alter to make it 1/0.

The code is taken largely from this post: [https://johnbaumgartner.wordpress.com/2012/07/26/getting-rasters-into-shape-from-r/](https://johnbaumgartner.wordpress.com/2012/07/26/getting-rasters-into-shape-from-r/)

If running on windows, try using the polygonizer function as opposed to gdal_polygonizeR.

Also, this will only work if you have [gdal](http://www.gdal.org/) downloaded locally!