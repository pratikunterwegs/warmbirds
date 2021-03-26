# code to get max and mean elevation of birds in the dataset per year per month

# load libraries
using CSV
using DataFrames
using Statistics
using StatsBase

# load data
data = CSV.read("../eBirdOccupancy/data/ebird_for_expertise.txt", limit = 1000,
                DataFrame)

# rename cols to remove spaces and make lowercase
rename!(data, replace.(names(data), " " => "_"))
rename!(data, lowercase.(names(data)))

# select species, year, month, and coords
data_small = select(data, :scientific_name, :longitude,
                        :latitude, :observation_date)
