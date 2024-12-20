# This script generates reports for all deployments in xxx

# SECTION 1: Read in document history and report files

# SECTION 2: Specify xxxx for which to generate reports

# SECTION 2: Generate report(s)

# SECTION 1: SET UP ---------------------------------------------

library(dplyr)
library(here)
library(readxl)
library(waves)

doc_hist <- read_excel(
  "R:/tracking_sheets/wave_report_tracker.xlsx", sheet = "Tracking"
) %>%
  mutate(Date = as.character(Date)) %>%
  select(Depl_ID, Version, Date, Amendments)

report <- here("2_wave_report_template.Rmd")

# SECTION 1: SET UP ---------------------------------------------

county <- "halifax"

depls <- list.files(
  paste0("R:/data_branches/wave/processed_data/deployment_data/", county),
  pattern = ".rds",
  full.names = TRUE
) %>%
  wv_extract_deployment_info2()
depls <- depls$deployment_id

# SECTION 2: GENERATE REPORTS --------------------------------------------------------

sapply(depls, function(x) {

  rmarkdown::render(
    input = report,
    output_file = paste0(x, "_wave_report.docx"),
    params = list(
      depl_id = x,
      doc_hist = filter(doc_hist, Depl_ID == x))
  )
})

