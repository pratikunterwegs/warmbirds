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

# working on grouped data
combine(groupby(data_trait, :range_size), nrow)

# multiple funs to multiple cols
# first make new col
data_trait.bm2 = data_trait.body_mass * 2

# hahahha the ... is an operator essential to applying mean and max to both cols
# also no comma between mean and max, amusing
combine(groupby(data_trait, :range_size),
        ([:body_mass, :bm2] .=> [mean maximum])...)

# try reading a very large file
# it's alright, not too bad
data = CSV.read("../eBirdOccupancy/data/ebird_for_expertise.txt", DataFrame)

# get the max and mean coords per species
names(data)
rename!(data, replace.(names(data), " " => "_"))
coord_summary = combine(groupby(data, [:SCIENTIFIC_NAME]),
            ([:LATITUDE, :LONGITUDE] .=> [mean maximum])...)

# save to file
CSV.write("data/data_coord_summary_test.csv", coord_summary)
