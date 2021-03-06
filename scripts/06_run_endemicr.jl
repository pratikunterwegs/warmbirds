# code to run endemicr from R
using RCall
using CSV
using DataFrames

R"library(sf)
  library(endemicr)
  library(data.table)"

# load wg shapefile
R"hills = st_read('data/spatial/hills_sasia_grid_100km.gpkg')"
R"hills$name = hills$polygon_id"

# ranges
R"ranges = st_read('data/spatial/soi_ranges.gpkg', 
    query = 'SELECT * FROM soi_ranges')"

# get endemicity
R"data = lapply(
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
            message(sprintf('error in %i', as.integer(row_n)))
          }
        )
      )
    }
  )"


# assign names as column
R"names(data) = ranges$SCINAME"

# rbindlist
R"data_copy = data"
R"data_copy = Map(function(df, name, seasonality) {
    df$sciname = name
    df$seasonality = seasonality
    df
  }, 
  data_copy, names(data_copy), ranges$SEASONAL
)"
R"data_copy = data_copy[sapply(data_copy, is.data.frame)]"
R"data_copy = rbindlist(data_copy)"

data = rcopy(R"data_copy")
first(data, 3)

# save
CSV.write("data/output/data_endemicity_passeriformes.csv", data)
