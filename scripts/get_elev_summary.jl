# summary stats for species observation elevation

using CSV
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