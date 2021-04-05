# code to add endemicity or some other metric

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
