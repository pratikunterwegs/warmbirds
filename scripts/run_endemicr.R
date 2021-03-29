# code to run endemicr
library(sf)
library(endemicr)
library(data.table)

# load wg shapefile
hills = st_read("data/spatial/shapefile_wg/Nil_Ana_Pal.shp")
hills$name = c("Anamalais", "Nilgiris")

# ranges
ranges = st_read("data/spatial/soi_ranges.gpkg",
                 query = "SELECT * FROM soi_ranges")

# get endemicity
data = lapply(
  seq(nrow(ranges)),
  function(row_n) {
    print(row_n)
    
    suppressWarnings(
      
      tryCatch(
        expr = endemicr::end_check_endemic(
          aoi = hills,
          utm_epsg_code = 32643,
          buffer_distance_km = 0, 
          sp_range = ranges[row_n, ]
        ),
        error = function(e) {
          message(sprintf("error in %i", as.integer(row_n)))
        }
      )
    )
  }
)

# assign names as column
names(data) = ranges$SCINAME

# rbindlist
data_copy = data
data_copy = Map(function(df, name) {
  df$sciname = name
  df
}, data_copy, names(data_copy))
data_copy = data_copy[sapply(data_copy, is.data.frame)]
data_copy = rbindlist(data_copy)
head(data_copy)

# save
fwrite(data_copy, file = "data/output/data_endemicity.csv")
