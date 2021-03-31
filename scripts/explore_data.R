# intermediate code
library(dplyr)
library(tidyr)
library(readr)
library(ggplot2)
library(colorspace)

data = read_csv("data/output/data_species_elevation_summary.csv")
endemicity = read_csv("data/output/data_endemicity.csv")

# sum endemicity
data_endemic = endemicity %>% 
  group_by(sciname, seasonality) %>% 
  summarise(endemicity = sum(p_range, na.rm = T)) %>%
  filter(seasonality %in% c(1, 2, 3),
         endemicity > 0)

ggplot(data_endemic)+
  geom_histogram(
    aes(x = endemicity,
        fill = factor(seasonality))
  )+
  scale_fill_discrete_qualitative()+
  scale_x_sqrt()+
  facet_grid(~seasonality)

# non breeding months
month_nb = c(11:12, 1:2)

# assign breeding nonbreeding
data = mutate(data,
              season = ifelse(month %in% month_nb, "nb-winter", "br-summer"))
# merge with range endemicity
data = left_join(data, data_endemic,
                 by = c("scientific_name" = "sciname"))

# filter and clear seasonal endemicity that doesn't match the month
data = filter(data, 
              !is.na(endemicity)
) %>% 
  mutate(
    range_residency = case_when(
      seasonality == 1 ~ "res",
      seasonality == 2 ~ "br",
      seasonality == 3 ~ "nb",
      TRUE ~ NA_character_
    )
  )

# filter for range resident or correct season
data_filter = filter(data,
                     range_residency == "res" | 
                       (range_residency == "nb" & season == "nb-winter"))

data_filter = mutate(data_filter, 
                     endemicity_round = round(endemicity / 0.05) * 0.05) %>% 
  filter(range_residency != "br")

# load taxonomy
taxonomy = read_csv("data/spatial/BOTW/HBW-BirdLife_Checklist_v3_Nov18/HBW-BirdLife_Checklist_Version_3.csv")

# link taxonomy and filtered data
data_filter = inner_join(
  data_filter,
  select(taxonomy,
         Order, `Family name`, `Scientific name`),
  by = c("scientific_name" = "Scientific name")
)

# only passeriformes
data_filter = filter(
  data_filter,
  Order %in% c("PASSERIFORMES")
)

# make figure
p = ggplot(data_filter)+
  geom_boxplot(
    aes(x = factor(endemicity_round), 
        y = elevation_mean,
        fill = interaction(range_residency, season)
    ),
    outlier.size = 0,
    outlier.colour = NA
  )+
  scale_fill_discrete_qualitative(
    palette = "harmonic",
    l1 = 50,
    labels = c("Resident sp. ~ summer",
               "Migratory sp. ~ winter",
               "Resident sp. ~ winter")
  )+
  facet_wrap(season ~ range_residency,
             labeller = label_both,
             scales = "free_y")+
  coord_cartesian(
    ylim = c(0, 2500),
    xlim = c(0, 10),
    expand = F
  )+
  theme_classic(base_size = 8)+
  theme(
    legend.position = "top",
    strip.background = element_blank(),
    strip.text = element_blank()#element_text(face = "italic", hjust = 0)
  )+
  labs(
    y = "Obs. Elevation (m)",
    x = "Range restriction",
    fill = "Range residency ~ Season",
    caption = "Higher range restriction = species is more restricted to the S. WG during this season."
  )

ggsave(p, filename = "figures/fig_elevation_endemicity_season.png")

# read coefficient data
data_coef = read_csv("data/observations/data_occupancy_predictor_effect.csv")

# merge with data_filter
data_coef = inner_join(data_coef, 
                       select(data_endemic, sciname,
                              endemicity),
                      by = c("scientific_name" = "sciname"))

ggplot(data_coef)+
  geom_hline(
    yintercept = 0,
    lty = 1,
    lwd = 0.3,
    col = "grey"
  )+
  geom_vline(
    xintercept = 0.1,
    lty = 1,
    lwd = 0.3,
    col = "grey"
  )+
  geom_point(
    aes(x = endemicity, y = coefficient)
  )+
  geom_smooth(
    aes(x = endemicity, y = coefficient),
    se = T,
    method = "lm"
  )+
  scale_x_sqrt(
    breaks = seq(0, 0.5, 0.1)
  )+
  facet_wrap(~predictor, scales = "free")+
  theme_classic(base_size = 8)+
  coord_cartesian(
    xlim = c(0, 0.5),
    ylim = c(-6, 4)
  )+
  theme(
    strip.background = element_blank()
  )
