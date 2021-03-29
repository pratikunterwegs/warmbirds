# plot elevation mean per month per species per year

using CSV
using DataFrames
using RCall
using Gadfly
using Statistics
using StatsBase

# read data
data = CSV.read("data/output/data_species_elevation_summary.csv", DataFrame)
data_endemic = CSV.read("data/output/data_endemicity.csv", DataFrame)
# combine
data = leftjoin(data, data_endemic, on = :scientific_name => :sciname)

# filter missing
filter!(row -> (!ismissing(row.p_range)) & (row.seasonality != 4), data)

# summarise data
data.endemicity_round = round.(data.p_range, digits = 2)
data_elev_endem_summary = combine(groupby(data, [:seasonality, :endemicity_round]),
        :elevation_mean .=> [mean, std])

set_default_plot_size(25cm, 18cm)
# plot lines
plot(data,
    y = :elevation_mean,
    x = :endemicity_round,
    xgroup = :seasonality,
    color = :seasonality,
    Geom.subplot_grid(
        Geom.boxplot,
        Coord.cartesian(
        ymin = 0
        ),
    ),
    Scale.x_sqrt,
    Scale.color_discrete,
    Theme(
        background_color = "white"
    )
)



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
