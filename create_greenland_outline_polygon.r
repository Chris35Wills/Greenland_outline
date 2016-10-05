# create shapefile from raster
# from: https://johnbaumgartner.wordpress.com/2012/07/26/getting-rasters-into-shape-from-r/

library(raster)

#path='/scratch/glacio1/cw14910/synthetic_channels_SCRATCH/separate-channels' # also see O:/..
#maskF=capture.output( cat(path, "/mask_correct_BamberPstere_100m_GRIGGS_dims.tif", sep=''))
path='./raster' 
maskF=capture.output( cat(path, "/mask_correct_BamberPstere_5000m_GRIGGS_dims.tif", sep=''))
mask=raster(maskF)

## amend raster values to 1/0 (land or ice or ice shelf VS. ocean)
## 0 = ocean | 1 = land | 2 = ice | 3 = ice shelf
mask[round(mask)==2]=1
mask[round(mask)==3]=1
mask=round(mask)

## Define the function
gdal_polygonizeR <- function(x, outshape=NULL, gdalformat = 'ESRI Shapefile', pypath=NULL, readpoly=TRUE, quiet=TRUE) {
	  if (isTRUE(readpoly)) require(rgdal)
	  if (is.null(pypath)) {
	    pypath <- Sys.which('gdal_polygonize.py')
	  }
	  if (!file.exists(pypath)) stop("Can't find gdal_polygonize.py on your system.")
	  owd <- getwd()
	  on.exit(setwd(owd))
	  setwd(dirname(pypath))
	  if (!is.null(outshape)) {
	    outshape <- sub('\\.shp$', '', outshape)
	    f.exists <- file.exists(paste(outshape, c('shp', 'shx', 'dbf'), sep='.'))
	    if (any(f.exists))
	      stop(sprintf('File already exists: %s',
	                   toString(paste(outshape, c('shp', 'shx', 'dbf'),
	                                  sep='.')[f.exists])), call.=FALSE)
	  } else outshape <- tempfile()
	  if (is(x, 'Raster')) {
	    require(raster)
	    writeRaster(x, {f <- tempfile(fileext='.tif')})
	    rastpath <- normalizePath(f)
	  } else if (is.character(x)) {
	    rastpath <- normalizePath(x)
	  } else stop('x must be a file path (character string), or a Raster object.')
	  system2('python', args=(sprintf('"%1$s" "%2$s" -f "%3$s" "%4$s.shp"',
	                                  pypath, rastpath, gdalformat, outshape)))
	  if (isTRUE(readpoly)) {
	    shp <- readOGR(dirname(outshape), layer = basename(outshape), verbose=!quiet)
	    return(shp)
	  }
	  return(NULL)
}

polygonizer <- function(x, outshape=NULL, gdalformat = 'ESRI Shapefile', pypath=NULL, readpoly=TRUE, quietish=TRUE) {
  # x: an R Raster layer, or the file path to a raster file recognised by GDAL
  # outshape: the path to the output shapefile (if NULL, a temporary file will be created)
  # gdalformat: the desired OGR vector format
  # pypath: the path to gdal_polygonize.py (if NULL, an attempt will be made to determine the location
  # readpoly: should the polygon shapefile be read back into R, and returned by this function? (logical)
  # quietish: should (some) messages be suppressed? (logical)
  if (isTRUE(readpoly)) require(rgdal)
  if (is.null(pypath)) {
    pypath <- Sys.which('gdal_polygonize.py')
  }
  ## The line below has been commented:
  # if (!file.exists(pypath)) stop("Can't find gdal_polygonize.py on your system.") 
  owd <- getwd()
  on.exit(setwd(owd))
  setwd(dirname(pypath))
  if (!is.null(outshape)) {
    outshape <- sub('\\.shp$', '', outshape)
    f.exists <- file.exists(paste(outshape, c('shp', 'shx', 'dbf'), sep='.'))
    if (any(f.exists)) 
      stop(sprintf('File already exists: %s', 
                   toString(paste(outshape, c('shp', 'shx', 'dbf'), 
                                  sep='.')[f.exists])), call.=FALSE)
  } else outshape <- tempfile()
  if (is(x, 'Raster')) {
    require(raster)
    writeRaster(x, {f <- tempfile(fileext='.asc')})
    rastpath <- normalizePath(f)
  } else if (is.character(x)) {
    rastpath <- normalizePath(x)
  } else stop('x must be a file path (character string), or a Raster object.')
  
  ## Now 'python' has to be substituted by OSGeo4W
  #system2('python',
  system2('C:\\OSGeo4W64\\OSGeo4W.bat',
    args=(sprintf('"%1$s" "%2$s" -f "%3$s" "%4$s.shp"', 
    pypath, rastpath, gdalformat, outshape)))
  if (isTRUE(readpoly)) {
    shp <- readOGR(dirname(outshape), layer = basename(outshape), verbose=!quietish)
    return(shp) 
  }
  return(NULL)
}

## create polygons 
#system.time(p <- gdal_polygonizeR(mask))

#outshape=capture.output(cat("/home/cw14910/Github/Greenland_outline/Greenland_mask_outline_100m.shp", sep=''))
outshape=capture.output(cat("./shp/Greenland_mask_outline_5000m.shp", sep=''))
#system.time(p <- gdal_polygonizeR(mask, outshape=outshape))
gdal_polygonizeR(mask, outshape=outshape)
