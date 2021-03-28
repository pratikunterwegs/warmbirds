# try reading gdb
library(sf)
library(data.table)
library(glue)

species = unique(
  fread("data/output/data_species_elevation_summary.csv")$scientific_name
)
species = str_c(glue("'{species}'"), collapse = ",")
query_soi = glue("SELECT * FROM All_Species
                  WHERE SCINAME IN ({species})")

data = st_read("data/spatial/botw.gpkg", 
               query = query_soi)

st_write(
  data,
  dsn = "data/spatial/soi_ranges.gpkg"
)
