# read data in julia

# load revise
using Revise

# load libraries
using CSV
using DataFrames 
using Gadfly
using StatsBase
using StatsPlots

# read in species traits
data_trait = CSV.read("data/data_species_trait.csv", DataFrame)

# count by multiple columns
combine(groupby(data_trait, [:range_size, :habitat]), nrow => :count)

# show boxplot

