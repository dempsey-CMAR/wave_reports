# DATE: 2026-01-27
# NAME: DD
# NOTES:

# Export additional files for Open Data Portal:
## The Deployment Information Dataset
## Number of rows expected for each county

library(adcp)
library(dplyr)
library(googlesheets4)
library(lubridate)
library(readr)
library(stringr)
library(waves)

#path <- "R:/data_branches/wave/open_data/"
path <- "R:/data_branches/current/open_data"

# CURRENT & WAVE TRACKING -----------------------------------------------------------
link <- "https://docs.google.com/spreadsheets/d/1DVfJbraoWL-BW8-Aiypz8GZh1sDS6-HtYCSrnOSW07U/edit?gid=496612477#gid=496612477"

# all current + wave deployments
metadata <- adcp_read_tracking()

# adcp deployments with processed current data
current <- googlesheets4::read_sheet(
  link, sheet = "Current Tracking", col_types = "c") %>%
  select(
    deployment_id = depl_id,
    county, waterbody, station, deployment_date = depl_date, processed
  ) %>%
  filter(processed == "Yes") %>%
  select(-processed) %>%
  mutate(current_data = "Current", deployment_date = as_date(deployment_date))

# adcp deployments with processed wave data
wave <- googlesheets4::read_sheet(
  link, sheet = "Wave Tracking", col_types = "c") %>%
  select(
    deployment_id = depl_id,
    county, waterbody, station, deployment_date = depl_date, processed
  ) %>%
  filter(processed == "Yes") %>%
  select(-processed) %>%
  mutate(wave_data = "Wave", deployment_date = as_date(deployment_date))

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
    deployment_date = format(deployment_date),
    retrieval_date = format(retrieval_date),
    current_data = if_else(is.na(current_data), "", current_data),
    wave_data = if_else(is.na(wave_data), "", wave_data),
    data_measured = paste(current_data, wave_data, sep = " & "),
    data_measured = if_else(
      data_measured == " & Wave" | data_measured == "Current & ",
      str_remove( data_measured, pattern = " & "), data_measured
    )
  ) %>%
  arrange(deployment_id) %>%
  select(-c(current_data, wave_data, depl_id, notes)) %>%
  relocate(data_measured, .after = deployment_id)

write_csv(
  depl_info,
  na = "",
  file = paste0(path, "/", Sys.Date(), "_current_wave_deployment_info.csv")
)

# Number of rows per county ---------------------

dat_wv <- wv_import_data()

n_rows_wv <- dat_wv %>%
  group_by(county) %>%
  summarize(n_row = n())

write_csv(n_rows_wv, paste0(path, Sys.Date(), "_wave_number_rows.csv"))



dat <- adcp_import_data()

n_rows <- dat %>%
  group_by(county) %>%
  summarize(n_row = n())

write_csv(n_rows, paste0(path, "/", Sys.Date(), "_current_number_rows.csv"))













