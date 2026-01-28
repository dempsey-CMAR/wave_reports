# This script generates reports for all deployments in xxx county

# SECTION 1: Read in document history and report files

# SECTION 2: Specify xxxx for which to generate reports

# SECTION 2: Generate report(s)

# SECTION 1: SET UP ---------------------------------------------

library(dplyr)
library(here)
library(readxl)
library(waves)

# SECTION 1: SET UP ---------------------------------------------

county <- "yarmouth"

depls <- list.files(
  paste0("R:/data_branches/wave/processed_data/deployment_data/", county),
  pattern = ".rds",
  full.names = TRUE
) %>%
  wv_extract_deployment_info2()
#depls <- depls$deployment_id


file_name <- paste(
  depls$deployment_id,
  gsub(pattern = " ", "_", depls$station),
  depls$depl_date,
  "wave_report.pdf", sep = "_"
)

hist <- read_excel(
  "R:/tracking_sheets/wave_report_tracker.xlsx", sheet = "Tracking"
) %>%
  filter(Depl_ID %in% depls$deployment_id)

# SECTION 2: GENERATE REPORTS --------------------------------------------------------

report <- here("2_wave_report_template.qmd")

sapply(depls$deployment_id, function(x) {

  quarto::quarto_render(
    input = report,
    output_file = file_name[grep(x, file_name)],
    execute_params = list(
      depl_id = x,
      doc_version = filter(hist, Depl_ID == x)$Version,
      doc_date = as.character(filter(hist, Depl_ID == x)$Date),
      doc_notes = filter(hist, Depl_ID == x)$Amendments
    )
  )
})

