library(here)
library(quarto)
library(rmarkdown)

################ update this ################
path <- file.path("R:/data_branches/wave/raw_data/2024-06-03_process/data/")
#############################################

depls <- list.files(path, pattern = ".txt", full.names = TRUE)

# export html file for each county showing the flagged observations
sapply(depls, function(x) {

  quarto_render(
    input = here("1_compile_and_apply_qc_tests_wave_template.qmd"),
    output_file = paste0(
      wv_extract_deployment_info(x)$depl_date, "_",
      wv_extract_deployment_info(x)$station,
      ".html"
    ),
    execute_params = list(depl_file = x))
})



# Single Deployment -------------------------------------------------------
x <- depls[6]
depl_file <- x
quarto_render(
  input = here("1_compile_and_apply_qc_tests_wave_template.qmd"),
  output_file = paste0(
    sub(".rds", "", sub(".*/", "", x, perl = TRUE)),
    ".html"
  ),
  execute_params = list(depl_file = x))



