# get observation elevations using R raster
# only works on julia 1.6+
using RCall
using CSV
using DataFrames

# load elevation and check
elevation_raster = R"raster::raster('data/spatial/elevationHills.tif')"
R"raster::plot($elevation_raster, col = scico::scico(n = 20, palette = 'lajolla'))"

# load observation data
ebird_observations = CSV.read("data/output/data_observation_coords.csv",
    # limit = 100000,
    DataFrame)
# check R call
coordinate_matrix = R"as.matrix($(select(ebird_observations, :longitude, :latitude)))"

# test overlay plot
some_rows = R"sample(nrow($coordinate_matrix), 1000)"
R"raster::plot($elevation_raster)"
R"points($coordinate_matrix[$some_rows,'longitude'], $coordinate_matrix[$some_rows,'latitude'])"

# get elevation per observation using raster extract
elevation_data = R"raster::extract(x = $elevation_raster, y = $coordinate_matrix)"
# check histogram
R"hist($elevation_data)" # fantastic!
# convert to julia object
elevation_j = rcopy(elevation_data)

# add to df and remove NA rows
ebird_observations.elevation = elevation_j
ebird_observations = dropmissing(ebird_observations)

# save
CSV.write("data/output/data_observation_elevation.csv", ebird_observations)
