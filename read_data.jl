# read data in julia

# load libraries
using CSV
using DataFrames
using StatsBase # required for mean. wtf
using Statistics

# read in species traits
data_trait = CSV.read("data/data_species_trait.csv", DataFrame)

# count by multiple columns
combine(groupby(data_trait, [:range_size, :habitat]), nrow => :count)

# get max bodymass by each groupby
combine(groupby(data_trait, [:range_size, :habitat]),
                    :body_mass .=> [mean, maximum, std])

# try reading a very large file
# it's alright, not too bad
data = CSV.read("../eBirdOccupancy/data/ebird_for_expertise.txt", DataFrame)

# get the max elev per species per year per month
names(data)
rename!(data, replace.(names(data), " " => "_"))
coord_summary = combine(groupby(data, [:SCIENTIFIC_NAME]),
            [:LATITUDE] .=> [mean, maximum],
            [:LONGITUDE] .=> [mean, maximum])

# save to file
CSV.write("data/data_coord_summary_test.csv", coord_summary)
