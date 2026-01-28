# DATE:
# NAME:
# NOTES:

# Returns assembled data as a csv file in /open_data
# and as an rds file in /assembled

# SECTION 1: Define county
# Modify county variable to include the county for which to assemble data

# SECTION 2: Check csv file and rds file are identical

# SECTION 3: Check for duplicate TIMESTAMP

library(data.table)
library(dplyr)
library(lubridate)
library(purrr)
library(sensorstrings)

# SECTION 1: Define counties and submission date --------------------------

county <- "inverness"
file_date <- as.character(Sys.Date())

path <- file.path("R:/data_branches/wave")

# print Warning if there are files in the /new folder
dat_new <- list.files(
  paste0(path, "/processed_data/deployment_data/", county, "/new"),
  pattern = "rds"
)

if(length(dat_new) > 0) {
  warning(paste0("There are ", length(dat_new), " files in the /new folder.
               \nMove these to the county folder to assemble"))
}

# Assemble county dataset ------------------------------------------------

# Import data
dat_raw <- list.files(
  paste0(path, "/processed_data/deployment_data/", county),
  pattern = "rds",
  full.names = TRUE
) %>%
  unlist() %>%
  map_dfr(readRDS)

# open data portal (summary flags) -------------------------------------------
# remove the qc_test_variable columns (leaving only the max flag col)
keep_cols <- c(
  "waterbody", "station", "deployment_id", "timestamp_utc",
  "sea_surface_wave_significant_height_m",
  "sea_surface_wave_peak_period_s", "sea_surface_wave_from_direction_degree",
  "sea_water_speed_m_s", "sea_water_to_direction_degree",
  "sensor_depth_below_surface_m",
  "grossrange_flag_sea_surface_wave_significant_height_m",
  "grossrange_flag_sea_surface_wave_peak_period_s",
  "grossrange_flag_sea_surface_wave_from_direction_degree",
  "grossrange_flag_sea_water_speed_m_s",
  "grossrange_flag_sea_water_to_direction_degree",
  "grossrange_flag_sensor_depth_below_surface_m"
)

dat_raw %>%
  select(all_of(keep_cols)) %>%
  qaqcmar::qc_assign_flag_labels() %>%
  ss_export_county_files(
    county = county,
    output_path = paste0(path, "/open_data/"),
    export_rds = FALSE
  )

# cmar county data (all flags) --------------------------------------------

# remove columns that are all NA
dat_raw %>%
  select_if(~ !all(is.na(.))) %>%
  ss_export_county_files(
    county = county,
    output_path = paste0(path, "/processed_data/assembled/"),
    export_csv = FALSE
  )


