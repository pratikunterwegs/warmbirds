# code to try reading shapefiles and use endemicr
using RCall

a = R"(rnorm(10))" # the r string macro

R"scico::scico(n = 9, palette = 'berlin')" # hahaha this is great!

a = R"raster::raster('data/kruger_temperature_UTM.tif')"