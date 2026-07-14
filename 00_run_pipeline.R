# Master runner for the complete manuscript analysis package.

source("ONSEN_config.R")
message_config()

steps <- c(
  "01_native_mutated_motif_analysis.R",
  "02_constrained_mutant_sensitivity.R",
  "03_col0_HSF_and_TE_background.R",
  "04_nonredundant_HSF_locations.R",
  "05_methylation_analysis.R",
  "06_rnaseq_analysis.R",
  "07_accession_analysis.R",
  "08_write_supplementary_tables.R",
  "09_write_session_info.R",
  "10_validate_manuscript_outputs.R"
)

message("Run order:")
for (i in seq_along(steps)) message(i, ". ", steps[[i]])

if (!ONSEN_RUN_LARGE_STEPS) {
  message(
    "\nONSEN_RUN_LARGE_STEPS is FALSE.\n",
    "Scripts will preferentially reconstruct the manuscript from existing processed outputs.\n",
    "Set Sys.setenv(ONSEN_RUN_LARGE_STEPS='true') to permit large raw-data scans."
  )
}

for (script in steps) {
  message("\n============================================================")
  message("Running: ", script)
  message("============================================================")
  source(repo_file(script), echo = FALSE)
}
