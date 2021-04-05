# count obs per polygon per month
using CSV
using DataFrames
using Dates
using RCall

data = CSV.read("data/output/data_observations_passeriformes_polygons.csv",
    DataFrame)

# count per id per polygon
data.month = Dates.month.(data.observation_date)
data_polygon_count = combine(groupby(data, [:polygon, :month]),
    nrow => :count)

# save
CSV.write("data/output/data_polygon_counts.csv", data_polygon_count)

# count per poly per month per species
data_polygon_species_count = combine(groupby(data, [:polygon, :month, :scientific_name]),
nrow => :count)

# save
CSV.write("data/output/data_polygon_species_counts.csv", data_polygon_species_count)
