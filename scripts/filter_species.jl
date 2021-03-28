# filter by species

using CSV
using CategoricalArrays
using DataFrames

# read data and remove genus level, uncertain species, and domestic birds
data = CSV.read("data/output/data_species_elevation_summary.csv", DataFrame)
filter!(row -> !(occursin(r"(sp.)|(omestic)|(/)", row.scientific_name)), data)

CSV.write("data/output/data_species_elevation_summary.csv", data)
