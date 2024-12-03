# DATE: 2024-11-20
# NAME: DD
# NOTES:

# Export additional files for Open Data Portal:
## The Deployment Information Dataset
## Number of rows expected for each county

library(adcp)
library(dplyr)
library(googlesheets4)
library(readr)
library(stringr)
library(waves)

path <- "R:/data_branches/wave/open_data/"

# ADCP TRACKING -----------------------------------------------------------

# all adcp deployments
metadata <- adcp_compile_deployment_info()

gs4_deauth()
link <- "https://docs.google.com/spreadsheets/d/1DVfJbraoWL-BW8-Aiypz8GZh1sDS6-HtYCSrnOSW07U/edit?gid=1876000833#gid=1876000833"


# adcp deployments with processed current data
current <- googlesheets4::read_sheet(link, sheet = "Current Tracking") %>%
  select(
    deployment_id = depl_id,
    county, waterbody, station, deployment_date = depl_date, processed
  ) %>%
  filter(processed == "Yes") %>%
  select(-processed) %>%
  mutate(current_data = "Current")

# adcp deployments with processed wave data
wave <- googlesheets4::read_sheet(link, sheet = "Wave Tracking") %>%
  select(
    deployment_id = depl_id,
    county, waterbody, station, deployment_date = depl_date, processed
  ) %>%
  filter(processed == "Yes") %>%
  select(-processed) %>%
  mutate(wave_data = "Wave")

# merge
depl_info <- current %>%
  full_join(
    wave,
    by = join_by(deployment_id, county, waterbody, station, deployment_date)
  ) %>%
  left_join(
    metadata, by = c("county", "waterbody", "deployment_date", "station")
  ) %>%
  mutate(
    deployment_date = as.character(deployment_date),
    recovery_date = as.character(recovery_date),
    current_data = if_else(is.na(current_data), "", current_data),
    wave_data = if_else(is.na(wave_data), "", wave_data),
    data_measured = paste(current_data, wave_data, sep = " & "),
    data_measured = if_else(
      data_measured == " & Wave" | data_measured == "Current & ",
      str_remove( data_measured, pattern = " & "), data_measured
    )
  ) %>%
  arrange(deployment_id) %>%
  select(-c(current_data, wave_data)) %>%
  relocate(data_measured, .after = deployment_id)

write_csv(
  depl_info,
  na = "",
  file = paste0(path, "/", Sys.Date(), "_adcp_deployment_info.csv")
)

# Number of rows per county ---------------------

dat <- wv_import_data()

n_rows <- dat %>%
  group_by(county) %>%
  summarize(n_row = n())

write_csv(n_rows, paste0(path, Sys.Date(), "_wave_number_rows.csv"))













