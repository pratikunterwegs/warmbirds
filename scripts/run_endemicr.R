# code to run endemicr
library(sf)
library(endemicr)

# load wg shapefile
hills = st_read("data/spatial/shapefile_wg/Nil_Ana_Pal.shp")
hills$name = c("Anamalais", "Nilgiris")

# ranges
ranges = st_read("data/spatial/soi_ranges.gpkg")
test1 = ranges[ranges$SCINAME == "Chalcophaps indica",]

data = lapply(
  seq(10),
  function(row_n) {
    endemicr::end_check_endemic(
      aoi = hills,
      utm_epsg_code = 32643,
      buffer_distance_km = 0, 
      sp_range = ranges[row_n, ]
    )
  }
)
