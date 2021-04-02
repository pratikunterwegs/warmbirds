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

# summarise data using custom round function
function round_any(x, v)
    round(round(x / v, digits = 0) * v, digits = 2)
end

# bin endemicity into 0.05
data.endemicity_round = round_any.(data.endemicity, 0.05)

# classify months as breeding or not
check_season(s, m) = s in m ? "br-summer" : "nb-winter"
data.season = check_season.(data.month, ([3, 4, 5, 6, 7, 8, 9, 10],))

# classify seasonality as range residency
function check_residency(v)
    if v == 1
        "res"
    elseif v == 2
        "br"
    elseif v == 3
        "nb"
    else
        missing
    end
end

data.range_residency = check_residency.(data.seasonality)

# filter for endemicity in correct season
data_filter = filter(row -> row.range_residency == "res" || 
    (row.range_residency == "nb" && row.season == "nb-winter"),
    data)

# read in taxonomy
taxonomy = CSV.read("data/spatial/BOTW/HBW-BirdLife_Checklist_v3_Nov18/HBW-BirdLife_Checklist_Version_3.csv", DataFrame)
rename!(taxonomy, replace.(names(taxonomy), " " => "_"))

# join to filtered data and keep passeriformes
data_filter = leftjoin(data_filter, taxonomy, on = :scientific_name => :Scientific_name)
filter!(row -> row.Order == "PASSERIFORMES", data_filter)

# sort data
sort!(data_filter, [:season, :range_residency, :endemicity_round])
set_default_plot_size(30cm, 18cm)

# plot lines
p = plot(data_filter,
    y = :elevation_mean,
    x = :endemicity_round,
    xgroup = :season,
    color = :range_residency,
    Geom.subplot_grid(
        Geom.boxplot,
        Coord.cartesian(
            xmin = 0,
            xmax = 0.6,
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
draw(SVG("figures/fig_elevation_endemicity_season.svg"), p)
