# use auk to filter ebird data
library(auk)

# prepare filters
file_ebird = file.path("data/observations/ebd_IN_relSep-2020.txt")
ebd_filters = auk_ebd(file = file_ebird) %>% 
  auk_country(country = "IN") %>% 
  auk_date(c("2015-01-01", "2019-12-31"))

# run filters
file_output = "data/output/data_ebird.txt"
ebd_filtered = auk_filter(
  ebd_filters,
  file = file_output,
  overwrite = FALSE
)
