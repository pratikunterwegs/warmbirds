# get coordinates from ebird observations
# load libraries
using CSV
using DataFrames

# load data
data = CSV.read("data/output/data_ebird.txt", DataFrame)

# rename cols to remove spaces and make lowercase
rename!(data, replace.(names(data), " " => "_"))
rename!(data, lowercase.(names(data)))

# select species, year, month, and coords
data_small = select(data, :scientific_name, :longitude,
                        :latitude, :observation_date)

# filter for coordinates
# filter!(row -> ((row.latitude < 12) || (row.longitude > 90)) , data_small)

# save data
CSV.write("data/output/data_observation_coords.csv", data_small)
