# try raster from r

using RCall

elevation_raster = R"raster::raster('data/spatial/elevationHills.tif')"

R"raster::plot($elevation_raster, col = scico::scico(n = 20, palette = 'lajolla'))"
