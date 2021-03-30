# plot elevation mean per month per species per year

using CSV
using DataFrames
using RCall
using Gadfly
using Statistics
using StatsBase
using Cairo
using Fontconfig

# read data
data = CSV.read("data/output/data_species_elevation_summary.csv", DataFrame)
data_endemic = CSV.read("data/output/data_endemicity.csv", DataFrame)
# sum endemicity over hills per season
data_endemic = combine(groupby(data_endemic, [:sciname, :seasonality]), 
        :p_range => (f(x) = sum(skipmissing(x)))  => :endemicity)

# combine
data = leftjoin(data, data_endemic, on = :scientific_name => :sciname)

# filter missing
filter!(row -> (!ismissing(row.endemicity)) & (row.seasonality in [1, 3]), data)

# summarise data
data.endemicity_round = round.(data.endemicity, digits = 1)
data_elev_endem_summary = combine(groupby(data, 
    [:seasonality, :endemicity_round, :month]),
        :elevation_mean .=> [mean, std])
# sort data
sort!(data, [:month, :seasonality])
set_default_plot_size(30cm, 18cm)

# plot lines
p = plot(data,
    y = :elevation_mean,
    x = :endemicity_round,
    ygroup = :seasonality,
    xgroup = :month,
    color = :seasonality,
    Geom.subplot_grid(
        Geom.boxplot,
        Coord.cartesian(
        ymin = 1
        ),
    ),
    Scale.x_discrete,
    Scale.color_discrete,
    Theme(
        background_color = "white"
    )
)

# save plot
draw(SVG("figures/fig_elevation_endemicity_month.svg"), p)
R"library(ggplot2)"
# now use ggplot
R"ggplot($data) +
    geom_boxplot(
        aes(x = factor(endemicity_round), y = elevation_mean,
            fill = factor(seasonality))
    ) + 
    facet_grid(seasonality ~ month)"



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
