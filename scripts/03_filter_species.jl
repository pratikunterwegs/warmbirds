# filter by species
using CSV
using DataFrames

# read data and remove genus level, uncertain species, and domestic birds
data = CSV.read("data/output/data_observation_elevation.csv", DataFrame)
filter!(row -> !(occursin(r"(sp.)|(omestic)|(/)", row.scientific_name)), data)

# only PASSERIFORMES
# get taxonomy
taxonomy = CSV.read("data/spatial/BOTW/HBW-BirdLife_Checklist_v3_Nov18/HBW-BirdLife_Checklist_Version_3.csv", DataFrame)
rename!(taxonomy, replace.(names(taxonomy), " " => "_"))
rename!(taxonomy, lowercase.(names(taxonomy)))

taxonomy = unique(taxonomy, [:order, :scientific_name])

# merge data
data = leftjoin(data, taxonomy, on = :scientific_name)

# filter PASSERIFORMES
filter!(row -> !(ismissing(row.order)), data)
filter!(row -> (occursin(r"PASSERIFORMES", row.order)), data)

# drop cols
select!(data, [:scientific_name, :longitude, :latitude, :observation_date,
    :elevation, :order, :family_name])

CSV.write("data/output/data_observation_elevation_passeriformes.csv", data)
