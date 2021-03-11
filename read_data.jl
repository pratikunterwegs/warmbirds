# read data in julia

# load revise
using Revise

# load libraries
using CSV
using DataFrames 
using StatsBase # required for mean. wtf
using Statistics
using StatsPlots

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
