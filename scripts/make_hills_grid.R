# make grids over hills
library(raster)
library(colorspace)
library(sf)
library(stars)

# get raster
elevation = raster("data/spatial/elevation_sasia.tif")
plot(elevation, col = sequential_hcl(20, palette = "Heat2", rev = T))

# subset areas with values > 800
hills_sasia = elevation
hills_sasia = hills_sasia < 800
plot(hills_sasia, col = sequential_hcl(20, palette = "Heat2", rev = T))
writeRaster(hills_sasia, "data/spatial/hills_sasia.tif")

# make stars and subsample
library(stars)
hills_sasia = st_as_stars(hills_sasia)
hills_sf = stars::st_contour(hills_sasia)
hills_sf$name = as.character(seq(nrow(hills_sf)))
hills_sf = hills_sf[hills_sf$name == "1", ]

# save
st_write(hills_sf, dsn = "data/spatial/hills_sasia_sf.gpkg")

# make buffer
hills_sf = st_transform(hills_sf, crs = 32643)
hills_sf_buffer = st_buffer(hills_sf, dist = 50*1e3)
hills_sf_buffer = st_transform(hills_sf_buffer, 4326)

# save
st_write(hills_sf_buffer, dsn = "data/spatial/hills_sasia_buffer.gpkg")

# make grid
hills_grid = st_make_grid(hills_buffer, 
                          cellsize = 50*1e3, square = F, what = "polygons")
# subset by the hills buffer
intersect_grid_hill = st_intersects(hills_buffer, hills_grid)
intersect_grid_hill = unique(unlist(unclass(intersect_grid_hill)))

hills_grid = hills_grid[intersect_grid_hill]

hills_grid = st_as_sf(hills_grid)
hills_grid$polygon_id = sprintf("cell_%i", seq(nrow(hills_grid)))
hills_grid$polygon_number = seq(nrow(hills_grid))

# retransform to WGS84
hills_grid = st_transform(hills_grid, 4326)

# save to file
st_write(hills_grid, dsn = "data/spatial/hills_sasia_grid.gpkg")
