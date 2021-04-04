# test hexagonal binning of SWG obs
library(data.table)
library(sf)
library(ggplot2)

# read data and remove weird species and non-passeriformes
data = fread("data/output/data_observation_elevation_WG_all.csv")
data = data[
  !stringi::stri_detect_regex(scientific_name,
                             "(sp.)|(omestic)|/")
]

# get taxonomy
taxonomy = fread("data/spatial/BOTW/HBW-BirdLife_Checklist_v3_Nov18/HBW-BirdLife_Checklist_Version_3.csv")
taxonomy = unique(taxonomy[, c("Scientific name", "Order")])
data = merge(data, taxonomy[, c("Order", "Scientific name")],
             by.x = "scientific_name", by.y = "Scientific name", all = F)
data = data[Order == "PASSERIFORMES", ]
data[, Order := NULL]

# load grid
hills_grid = st_read("data/spatial/hills_sasia_grid_100km.gpkg")
bbox = c(range(data$longitude), range(data$latitude))
bbox = st_bbox(c(
  xmin = bbox[1], xmax = bbox[2],
  ymin = bbox[3], ymax = bbox[4]),
  crs = st_crs(4326)
  )
bbox = st_as_sfc(bbox)

# grid for WG
wg_grid = hills_grid[unlist(unclass(
  st_intersects(bbox, hills_grid)
)),]
wg_grid$polygon_id_wg = seq(nrow(wg_grid))

# check intersection
obs_coords = st_as_sf(
  data[, c("longitude", "latitude")],
  coords = c("longitude", "latitude"),
  crs = 4326
)
obs_intersection = st_intersects(obs_coords, wg_grid)

# remove some data
good_rows = unlist(lapply(unclass(obs_intersection), function(x) length(x) > 0))
data = data[good_rows]

# assign polygon id
data$polygon = unlist(unclass(obs_intersection))

# save
fwrite(data, file = "data/data_observations_polygons.csv")

# basic metrics as sanity check
data[, month := month(observation_date)]
data[, season := ifelse(month %in% seq(3, 10), "br-summer", "nb-winter")]
data_summary = data[, .N, by = c("season", "polygon")]

# species endemicity
endemicity = fread("data/output/data_endemicity.csv")
endemicity = endemicity[, list(endemicity = sum(p_range, na.rm = T)),
                        by = c("sciname", "seasonality")]

# keep only 1 and 3 seasonalities and rename
endemicity = endemicity[seasonality %in% c(1, 3),]
endemicity[,range_residency := ifelse(seasonality == 1, "res", "nb")]

# join with obs and check
data_2 = dplyr::left_join(
  data, endemicity,
  by = c("scientific_name" = "sciname")
)
setDT(data_2)

# filter for correct season
data_2 = data_2[range_residency == "res" | 
                  !(season == "br-summer" & range_residency == "nb"),]

# plot elevation per endemicity per season per residency per polygon
data_2[, endemicity := plyr::round_any(endemicity, 0.1)]
data_2[, count := .N,
       by = c("season", "polygon")]
data_2 = data_2[count > 1000, ]
data_2 = data_2[complete.cases(data_2),]

# get body mass
trait_data = readxl::read_excel("data/observations/2020-sheard et al-species-trait-dat.xlsx")
setDT(trait_data)
# 
# # merge traits and data2
# data_2 = merge(data_2, trait_data[, c("Species name", "Body mass (log)")],
#                by.x = "scientific_name", by.y = "Species name")
# data_2[, `:=`(
#   mass = as.double(`Body mass (log)`)
# )]
# data_2 = data_2[complete.cases(data_2),]

# sep by season and polygon and run lm
data_split = split(data_2, by = c("season", "polygon", "range_residency"))
data_split_lm = lapply(data_split, function(df) {
  lm(elevation ~ endemicity, data = df)$coef[2]
})

# match polygon and slope
data_polygon = unique(data_2[, c("season", "polygon", "range_residency")])
data_polygon$coef_endem = unlist(data_split_lm)

# attach to grid cells
wg_grid = dplyr::left_join(wg_grid, data_polygon,
                           by = c("polygon_id_wg" = "polygon"))

# plot polygons
ggplot(wg_grid) +
  geom_sf(
    aes(
      fill = coef_endem
    )
  )+
  facet_grid(range_residency~season)

# ggplot(data_2)+
#   geom_smooth(
#     aes(x = endemicity,
#         y = elevation,
#         group = interaction(polygon, range_residency),
#         col = range_residency),
#     se = F,
#     method = "glm"
#   )+
#   facet_grid( ~ season)
# 
# # sanity check
# wg_grid = dplyr::left_join(wg_grid, data_summary,
#                            by = c("polygon_id_wg" = "polygon"))
# load Sasia
sasia = st_read("data/spatial/hills_sasia_sf.gpkg")
ggplot(sasia)+
  geom_sf(
    fill = "tan",
    colour = NA
  )+
  geom_sf(
    data = wg_grid,
    aes(fill = coef_endem),
    alpha = 0.7,
    colour = NA
  )+
  scale_fill_viridis_c(
    option = "C",
    trans = "log10", direction = -1
  )+
  coord_sf(
    ylim = c(5, 20),
    xlim = c(72, 85)
  )+
  facet_grid(range_residency ~ season)
