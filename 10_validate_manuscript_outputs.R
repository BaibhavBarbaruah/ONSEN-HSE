# Validate repository structure and key manuscript-level results.
# Checks repository structure, portability and selected manuscript-level reference values.

source("ONSEN_functions.R")
require_packages(c("readxl", "dplyr", "stringr"))

message_config()

expected_scripts <- c(
  "ONSEN_config.R",
  "ONSEN_functions.R",
  "00_install_packages.R",
  "00_run_pipeline.R",
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

expected_tables <- paste0("Table_S", 1:13, ".xlsx")
expected_metadata <- c(
  "README.md",
  "REPRODUCIBILITY_MATRIX.tsv",
  "INPUT_PROVENANCE.tsv",
  "DATA_AVAILABILITY.md",
  "ONSEN_49bp_sequences.fasta",
  "ONSEN_HSE_units_and_substitutions.csv",
  "ONSEN_Col0_terminal_candidate_windows.csv",
  "ONSEN_Col0_terminal_candidate_windows.saf",
  "Arabidopsis_HSF_models_JASPAR2026.csv"
)

all_expected <- c(expected_scripts, expected_tables, expected_metadata)
missing_files <- all_expected[!file.exists(file.path(REPO_ROOT, all_expected))]
if (length(missing_files)) {
  stop("Repository package is incomplete. Missing files:\n", paste(missing_files, collapse = "\n"))
}

# Confirm that the flat repository contains no broken nested-folder source paths.
r_files <- list.files(REPO_ROOT, pattern = "\\.R$", full.names = TRUE)
r_text <- lapply(r_files, readLines, warn = FALSE)

broken_sources <- unlist(lapply(seq_along(r_files), function(i) {
  bad <- grep('source\\("(config|R|scripts)/', r_text[[i]], value = TRUE)
  if (length(bad)) paste(basename(r_files[[i]]), bad, sep = ": ") else character()
}))
if (length(broken_sources)) {
  stop("Broken nested-folder source statements remain:\n", paste(broken_sources, collapse = "\n"))
}

hardcoded_drives <- unlist(lapply(seq_along(r_files), function(i) {
  bad <- grep("[A-Za-z]:/", r_text[[i]], value = TRUE)
  if (length(bad)) paste(basename(r_files[[i]]), bad, sep = ": ") else character()
}))
# The scripts should contain no hard-coded drive paths.
hardcoded_drives <- hardcoded_drives[!grepl("Sys.setenv", hardcoded_drives, fixed = TRUE)]
if (length(hardcoded_drives)) {
  warning("Potential drive-specific text detected:\n", paste(hardcoded_drives, collapse = "\n"))
}

read_workbook_values <- function(path) {
  sheets <- readxl::excel_sheets(path)

  unlist(
    lapply(sheets, function(sheet) {
      x <- suppressMessages(
        readxl::read_excel(
          path,
          sheet = sheet,
          col_names = FALSE,
          .name_repair = "minimal",
          progress = FALSE
        )
      )
      unlist(x, use.names = FALSE)
    }),
    use.names = FALSE
  )
}

numericize_values <- function(values) {
  text_values <- trimws(as.character(values))
  text_values[text_values %in% c("", "NA", "NaN", "NULL")] <- NA_character_

  # Accept display formatting such as 5,120, percentages and non-breaking spaces.
  text_values <- gsub("\u00A0", "", text_values, fixed = TRUE)
  text_values <- gsub(",", "", text_values, fixed = TRUE)
  text_values <- sub("%$", "", text_values)

  suppressWarnings(as.numeric(text_values))
}

contains_number <- function(
  values,
  target,
  tolerance = max(1e-10, abs(target) * 1e-5)
) {
  numeric_values <- numericize_values(values)
  any(
    is.finite(numeric_values) &
      abs(numeric_values - target) <= tolerance
  )
}

contains_text <- function(values, pattern) {
  any(grepl(pattern, as.character(values), ignore.case = TRUE))
}

checks <- list()
add_check <- function(name, passed, detail) {
  checks[[length(checks) + 1L]] <<- data.frame(
    check = name,
    passed = isTRUE(passed),
    detail = detail,
    stringsAsFactors = FALSE
  )
}

# Table S1: effect counts.
v1 <- read_workbook_values(repo_file("Table_S1.xlsx"))
add_check("Table S1 contains lost count 60", contains_number(v1, 60), "Expected lost motif-model count = 60")
add_check("Table S1 contains gained count 50", contains_number(v1, 50), "Expected gained motif-model count = 50")
add_check("Table S1 contains native HSF count 31", contains_number(v1, 31), "Expected native HSF motif-position hits = 31")
add_check("Table S1 contains designed HSF count 0", contains_number(v1, 0), "Expected designed HSF motif-position hits = 0")

# Table S4: sixteen windows, 48-75 raw hits.
t4 <- readxl::read_excel(repo_file("Table_S4.xlsx"), skip = 1)
add_check("Table S4 has sixteen primary windows", nrow(t4) == 16L, paste("Rows found:", nrow(t4)))
numbers4 <- numericize_values(unlist(t4, use.names = FALSE))
add_check("Table S4 includes minimum raw HSF count 48", any(numbers4 == 48, na.rm = TRUE), "Expected minimum = 48")
add_check("Table S4 includes maximum raw HSF count 75", any(numbers4 == 75, na.rm = TRUE), "Expected maximum = 75")

# Table S5: threshold robustness.
v5 <- read_workbook_values(repo_file("Table_S5.xlsx"))
add_check("Table S5 contains 0.85 ONSEN median 75", contains_number(v5, 75), "Expected threshold-0.85 median = 75")
add_check("Table S5 contains 0.90 ONSEN median 37.5", contains_number(v5, 37.5), "Expected threshold-0.90 median = 37.5")
add_check("Table S5 contains Wilcoxon P approximately 7.33e-12", contains_number(v5, 7.33e-12, 2e-13), "Expected P = 7.33e-12")
add_check("Table S5 contains Cliff delta approximately 0.992", contains_number(v5, 0.992, 0.002), "Expected delta = 0.992")

# Table S6 ordinary-TE control.
v6 <- read_workbook_values(repo_file("Table_S6.xlsx"))
add_check("Table S6 contains ordinary-TE CHH median 15.83", contains_number(v6, 15.83017, 0.02), "Expected median = 15.83017")
add_check("Table S6 contains ONSEN CHH median 53.61", contains_number(v6, 53.61375, 0.02), "Expected median = 53.61375")
add_check("Table S6 contains adjusted P approximately 2.06e-7", contains_number(v6, 2.06436e-7, 1e-9), "Expected adjusted P = 2.06436e-7")

# Table S8 accession counts.
v8 <- read_workbook_values(repo_file("Table_S8.xlsx"))
for (value in c(19, 7, 11, 9, 16, 17, 15, 41)) {
  add_check(
    paste0("Table S8 contains candidate count ", value),
    contains_number(v8, value),
    paste("Expected final accession count:", value)
  )
}

# Table S12 design-space sizes and AP2/ERF value.
v12 <- read_workbook_values(repo_file("Table_S12.xlsx"))
add_check("Table S12 contains 5000 random mutants", contains_number(v12, 5000), "Expected n = 5,000")
add_check("Table S12 contains 5120 exact-GC valid designs", contains_number(v12, 5120), "Expected n = 5,120 including designed mutant")
add_check("Table S12 contains designed AP2/ERF count 61", contains_number(v12, 61), "Expected designed count = 61")
add_check("Table S12 contains random empirical P 0.0166", contains_number(v12, 0.0166, 0.001), "Expected P approximately 0.0166")
add_check("Table S12 contains exact-GC empirical P 0.149", contains_number(v12, 0.149, 0.003), "Expected P approximately 0.149")

# Table S13 non-redundant results.
v13 <- read_workbook_values(repo_file("Table_S13.xlsx"))
add_check("Table S13 contains native raw HSF count 31", contains_number(v13, 31), "Expected native raw count = 31")
add_check("Table S13 contains native non-redundant count 1", contains_number(v13, 1), "Expected native merged count = 1")
for (value in 7:10) {
  add_check(
    paste0("Table S13 contains non-redundant window count ", value),
    contains_number(v13, value),
    paste("Expected window range includes", value)
  )
}

report <- dplyr::bind_rows(checks)
safe_write_csv(report, "repository_validation_report.csv")

if (any(!report$passed)) {
  print(report[!report$passed, ], row.names = FALSE)
  stop(
    "Repository validation failed. Review the failed checks in ",
    out_file("repository_validation_report.csv"),
    "."
  )
}

message("\n============================================================")
message("REPOSITORY VALIDATION PASSED")
message("============================================================")
message("All required flat files are present and key manuscript values were found.")
message("Validation report: ", out_file("repository_validation_report.csv"))
