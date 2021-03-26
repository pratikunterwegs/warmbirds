# plot elevation mean per month per species per year

using CSV
using DataFrames
using RCall

# read data
data = CSV.read("data/output/data_species_elevation_summary.csv", DataFrame)

set_default_plot_size(16cm, 9cm)
# plot lines
plot(data,
    y = :elevation_mean,
    x = :month,
    color = :scientific_name,
    Geom.point,
    Theme(
        background_color = "white",
        key_position = :none
    )
) # nice, but no ggplot

# use ggplot because why use something substandard
R"library(ggplot2)"
R"ggplot($data)+
    geom_path(aes(month, elevation_mean,
                    col = scientific_name),
                    show.legend = FALSE)+
    facet_grid(~year)"

# plot elevation mode change
data = CSV.read("data/output/data_species_elev_mode.csv", DataFrame)
# filter for genuses and few counts
filter!(row -> !(occursin(r"sp.", row.scientific_name)), data)
transform!(groupby(data, :scientific_name), nrow => :species_obs)
filter!(row -> row.species_obs > 20, data)

R"ggplot($data)+
    geom_line(aes(factor(month), elev_mode,
                    col = scientific_name,
                    group = interaction(scientific_name, year)),
                    size = 0.1, alpha = 0.4,
                    show.legend = FALSE)+
    facet_grid(~year)"
