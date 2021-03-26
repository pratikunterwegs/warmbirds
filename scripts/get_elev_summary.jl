# summary stats for species observation elevation

using CSV
using CategoricalArrays
using DataFrames
using Dates
using StatsBase
using Statistics

# read species obs coordinates
data = CSV.read("data/output/data_observation_elevation.csv",
    DataFrame)
# get year month
data.year = Dates.year.(data.observation_date)
data.month = Dates.month.(data.observation_date)

# summarise by species and month-year
data_summary = combine(groupby(data, 
        [:scientific_name, :year, :month]),
            :elevation .=> [mean, maximum, minimum, std])
# write
CSV.write("data/output/data_species_elevation_summary.csv", data_summary)

# get species elevation counts
# round elevation to the nearest 100
data.elev_round = round.(data.elevation, digits = -2)
data_elev_count = combine(groupby(data, 
        [:scientific_name, :year, :month, :elev_round]),
        nrow => :count)
# write also
CSV.write("data/output/data_species_elevation_count.csv", data_elev_count)
