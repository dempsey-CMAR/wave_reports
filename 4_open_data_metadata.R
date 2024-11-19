# DATE:
# NAME:
# NOTES:

# Export additional files for Open Data Portal:
## The Deployment Information Dataset
## Number of rows expected for each county

library(dplyr)
library(googlesheets4)
library(readr)
library(waves)

path <- "R:/data_branches/wave/open_data/"

# ADCP TRACKING -----------------------------------------------------------

# all adcp deployments
metadata <- wv_compile_deployment_info()

gs4_deauth()
link <- "https://docs.google.com/spreadsheets/d/1DVfJbraoWL-BW8-Aiypz8GZh1sDS6-HtYCSrnOSW07U/edit?gid=1876000833#gid=1876000833"

# adcp deployments with processed wave data
depl_info <- googlesheets4::read_sheet(link, sheet = "Wave Tracking") %>%
  select(
    deployment_id = depl_id,
    county, waterbody, station, deployment_date = depl_date, processed
  ) %>%
  filter(processed == "Yes") %>%
  select(-processed) %>%
  left_join(
    metadata, by = c("county", "waterbody", "deployment_date", "station")
  ) %>%
  mutate(
    deployment_date = as.character(deployment_date),
    recovery_date = as.character(recovery_date)
  ) %>%
  arrange(deployment_id)

write_csv(
  depl_info,
  na = "",
  file = paste0(path, "/", Sys.Date(), "_wave_deployment_info.csv")
)

# Number of rows per county ---------------------

dat <- wv_import_data()

n_rows <- dat %>%
  group_by(county) %>%
  summarize(n_row = n())

write_csv(n_rows, paste0(path, Sys.Date(), "_wave_number_rows.csv"))













