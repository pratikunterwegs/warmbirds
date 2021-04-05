# get BOTW ranges of species of interest
library(data.table)
library(sf)
library(stringr)
library(glue)

# get species
data = fread("data/output/data_observation_elevation_passeriformes.csv")
rm(data)

species = unique(data$scientific_name)
species = str_c(glue("'{species}'"), collapse = ",")

query_soi = glue("SELECT * FROM All_Species
                  WHERE SCINAME IN ({species})")

# read BOTW
botw = st_read("data/spatial/botw.gpkg",
               query = query_soi)

st_write(
  botw,
  dsn = "data/spatial/soi_ranges.gpkg",
  append = F
)
