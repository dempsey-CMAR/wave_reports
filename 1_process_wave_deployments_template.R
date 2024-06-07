# DATE:
# NAME: DD
# NOTES:

# This template reads in ADCP wave data txt files and exports formatted csv file
## AND generates the report for each deployment

# Must have the `wave_reports` repository downloaded

# Make sure deployments are included in the Waves Tracking tab of ADCP TRACKING

library(data.table)     # fast data export
library(dplyr)          # data wrangling
library(ggplot2)        # export ggplots
library(googlesheets4)  # read in deployment IDs
library(waves)          # wave data wrangling and visualization

library(tidyr)
library(stringr)

# UPDATE FILE PATHS ------------------------------------------------------------

# path to raw data -- update this
path_import <- file.path("R:/data_branches/wave/raw_data/2024-06-03_process")

# raw data
files <- list.files(
  paste0(path_import, "/data"), full.names = TRUE, pattern = ".txt"
)

# ADCP TRACKING
link <- "https://docs.google.com/spreadsheets/d/1DVfJbraoWL-BW8-Aiypz8GZh1sDS6-HtYCSrnOSW07U/edit#gid=0"

depl_id <- googlesheets4::read_sheet(link, sheet = "Wave Tracking")

# path to report rmd -- update this
#path_rmd <- file.path("C:/Users/Danielle Dempsey/Desktop/RProjects/ADCP Reports/ADCP_Report.Rmd")


# leave these -------------------------------------------------------------

# path to data export
path_export <- file.path("R:/data_branches/wave/processed_data/deployment_data")

# path to generated report
#path_report <- file.path("R:/program_documents/website_documents/wave_reports/drafts/")

# read in files --------------------------------------------------


# compile for Open Data Portal --------------------------------------------
# using j as index so does not get mixed up with index in wave_report_template.Rmd

for(j in seq_along(files)) {

  file_j <- files[j]

  # extract deployment info from the file name
  d_j <- wv_extract_deployment_info(file_j)

  depl_id_j <- depl_id %>%
    filter(depl_date == d_j$depl_date, station == d_j$station)

# read in data & format for Open Data -------------------------------------

  depl_j <- file_j %>%
    wv_read_txt() %>%
    mutate(deployment_id = depl_id_j$depl_id)

# export formatted data to shared drive -----------------------------------

 # depl.j <- select(depl.j, -depth_flag)

  fwrite(
    depl_j,
    file = paste0(
      path_export, "/",
      tolower(depl_id_j$county), "/new/",
      d_j$depl_date, "_",
      d_j$station, "_",
      depl_id_j$depl_id, ".csv"
    )
  )

  # generate report ---------------------------------------------------------

  # be careful with this because it **adds variables*** to the env
  # Document history is saved in Y:\coastal_monitoring_program\tracking_sheets
  # rmarkdown::render(
  #   input = path_rmd,
  #   output_file = paste0(
  #     path_report, "/",
  #     tracking.j$Depl_ID, "_",
  #     d.j$Station_Name, "_",
  #     d.j$Depl_Date, "_",
  #     "_Current_Report.docx"
  #   ),
  #   params = list(dat = depl.j, metadata = tracking.j)
  # )

  print(paste0("Finished ", d_j$depl_date, "_", d_j$station))
}



