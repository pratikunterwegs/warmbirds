# test hexagonal binning of SWG obs
library(data.table)
library(sf)
library(ggplot2)

# load data
data = fread("data/output/data_observation_elevation_passeriformes.csv")

# load grid
hills_grid = st_read("data/spatial/hills_sasia_grid_100km.gpkg")
bbox = c(range(data$longitude), range(data$latitude))
bbox = st_bbox(c(
  xmin = bbox[1], xmax = bbox[2],
  ymin = bbox[3], ymax = bbox[4]),
  crs = st_crs(4326)
  )
bbox = st_as_sfc(bbox)

# grid for these polygons (only india data for now)
in_grid = hills_grid[unlist(unclass(
  st_intersects(bbox, hills_grid)
)),]
in_grid$polygon_id_ind = seq(nrow(in_grid))

# save
st_write(in_grid, dsn = "data/spatial/hills_sasia_grid_100km.gpkg", append = F)

# check intersection
obs_coords = st_as_sf(
  data[, c("longitude", "latitude")],
  coords = c("longitude", "latitude"),
  crs = 4326
)
obs_intersection = st_intersects(obs_coords, in_grid)

# remove some data
good_rows = unlist(lapply(unclass(obs_intersection), function(x) length(x) > 0))
data = data[good_rows]

# assign polygon id
data$polygon = unlist(unclass(obs_intersection))

# save
fwrite(data, file = "data/ouput/data_observations_passeriformes_polygons.csv")
