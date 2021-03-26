# check simple sdm layers
# this is actually really bad right now

using SimpleSDMLayers
using Plots
using Statistics
using DataFrames
using CSV
using ArchGDAL

file = "../elemove/data/kruger_landsat5_temp.tif"

raster = ArchGDAL.read(file)
ArchGDAL.width(raster)

struct MyConnectivityMap <: SimpleSDMLayers.SimpleSDMSource end
SimpleSDMLayers.latitudes(::Type{MyConnectivityMap}) = (-36, -32.38457)
SimpleSDMLayers.longitudes(::Type{MyConnectivityMap}) = (30.17734, 32.36486)

mp = SimpleSDMLayers.raster(SimpleSDMResponse, MyConnectivityMap(), file)

plot(mp, frame=:grid, c=:vik, clim=(22,30))

# make raster a data frame
temp_df = DataFrame(mp)

data = CSV.read("data/ele_ambient_temp.csv", limit = 1000, DataFrame)

rename!(data, :LATITUDE => :latitude, :LONGITUDE => :longitude)

mp[data]