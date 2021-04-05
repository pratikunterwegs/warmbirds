# vis counts per polygon

# load libs
library(data.table)
library(sf)
library(ggplot2)
library(colorspace)

# get data and merge
data = fread("data/output/data_polygon_counts.csv")
polygons = st_read("data/spatial/hills_sasia_grid_100km.gpkg")

# right now doesn't include other sasia only india
polygons = dplyr::left_join(polygons, data, by = c("polygon_id_ind" = "polygon"))

polygons = tidyr::drop_na(polygons)

# visualise
ggplot(polygons)+
  geom_sf(
    aes(fill = count),
    col = NA
  )+
  scale_fill_continuous_sequential(
    palette = "Blue-Yellow",
    trans = "log10", rev = F
  )+
  theme_bw()+
  facet_wrap(~month)
