# get observation elevations using R raster
# only works on julia 1.6+
using RCall
using CSV
using DataFrames

elevation_raster = R"raster::raster('data/spatial/elevationHills.tif')"

R"raster::plot($elevation_raster, col = scico::scico(n = 20, palette = 'lajolla'))"
