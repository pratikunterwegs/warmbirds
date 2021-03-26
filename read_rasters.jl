# test reading spatial data

# load packages
using ArchGDAL
using GeoData
using GeoFormatTypes
# using Plots

# check projection
tempgd = GDALarray("data/kruger_temperature_UTM.tif"; mappedcrs=EPSG(4326)) |> GeoArray
