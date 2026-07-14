# Rebuild supplementary workbooks from repository outputs.
# Stable copies of the current journal tables are also included in the repository.

source("ONSEN_functions.R")
require_packages(c("openxlsx", "readxl", "dplyr", "tidyr", "readr"))

message_config()

read_generated <- function(filename, alternatives = character(), required = TRUE) {
  path <- find_any_input(c(filename, alternatives), required = required)
  if (is.na(path)) return(data.frame())
  read_table_auto(path)
}

save_book <- function(workbook, filename) {
  path <- out_file(filename)
  openxlsx::saveWorkbook(workbook, path, overwrite = TRUE)
  message("Saved: ", path)
  invisible(path)
}

# Table S1 --------------------------------------------------------------------
effects <- read_generated(
  "native_vs_mutated_49bp_effect_summary_repository.csv",
  "native_vs_mutated_49bp_effect_summary.csv"
)
families <- read_generated(
  "native_vs_mutated_49bp_family_summary_repository.csv",
  "native_vs_mutated_49bp_family_summary.csv"
)
wb <- openxlsx::createWorkbook()
write_workbook_sheet(
  wb, "S1A_motif_effects",
  "Table S1. Native-versus-mutated 49-bp ONSEN HSE motif-effect and family-level summary.",
  effects
)
write_workbook_sheet(
  wb, "S1B_family_summary",
  "Table S1. Native-versus-mutated 49-bp ONSEN HSE motif-effect and family-level summary.",
  families
)
save_book(wb, "Table_S1.xlsx")

# Tables S2-S3 ---------------------------------------------------------------
motif_effects <- read_generated(
  "native_vs_mutated_49bp_motif_effects_repository.csv",
  "native_vs_mutated_49bp_TF_motif_gain_loss_table.csv"
)

family_col <- c("tf_family", "family")[c("tf_family", "family") %in% names(motif_effects)][1]
effect_col <- c("effect_class", "effect")[c("effect_class", "effect") %in% names(motif_effects)][1]

s2 <- motif_effects |>
  dplyr::filter(
    .data[[family_col]] == "HSF",
    .data[[effect_col]] %in% c("lost", "lost_after_mutation")
  )
wb <- openxlsx::createWorkbook()
write_workbook_sheet(
  wb, "S2_HSF_lost",
  "Table S2. Arabidopsis HSF-family motif models lost after mutation of the 49-bp ONSEN HSE window.",
  s2
)
save_book(wb, "Table_S2.xlsx")

s3 <- motif_effects |>
  dplyr::filter(
    .data[[family_col]] == "AP2/ERF",
    .data[[effect_col]] %in% c(
      "gained", "strengthened",
      "gained_after_mutation", "strengthened_after_mutation"
    )
  )
wb <- openxlsx::createWorkbook()
write_workbook_sheet(
  wb, "S3_AP2ERF_gained",
  "Table S3. AP2/ERF-family motif models gained or strengthened after HSE mutation.",
  s3
)
save_book(wb, "Table_S3.xlsx")

# Table S4 --------------------------------------------------------------------
s4 <- read_generated(
  "Col0_ONSEN_HSF_summary_repository.csv",
  c(
    "Col0_ONSEN_LTRcandidate_JASPAR2026_Arabidopsis_HSF_summary.csv",
    "Col0_ONSEN_LTRcandidate_HSF_summary_complete.csv"
  )
)
if ("threshold" %in% names(s4)) s4 <- s4[s4$threshold == 0.85, , drop = FALSE]
wb <- openxlsx::createWorkbook()
write_workbook_sheet(
  wb, "S4_Col0_HSF",
  "Table S4. Copy-wide Arabidopsis HSF-family motif summary and density across Col-0 ONSEN LTR candidate regions.",
  s4
)
save_book(wb, "Table_S4.xlsx")

# Table S5 --------------------------------------------------------------------
s5_stats <- read_generated(
  "ONSEN_vs_strict_TE_HSF_statistics_repository.csv",
  "ONSEN_vs_strict_TE_only_background_threshold_0p85_0p90_STATS.csv"
)
s5_summary <- read_generated(
  "ONSEN_vs_strict_TE_only_background_threshold_0p85_0p90_summary.csv",
  required = FALSE
)
wb <- openxlsx::createWorkbook()
write_workbook_sheet(
  wb, "S5_TE_background",
  "Table S5. Strict TE-only background comparison and threshold robustness for HSF motif density.",
  s5_stats,
  p_value_columns = names(s5_stats)[grepl("P|p_value", names(s5_stats))]
)
if (nrow(s5_summary)) {
  write_workbook_sheet(
    wb, "S5B_summary",
    "Table S5. Strict TE-only background comparison and threshold robustness for HSF motif density.",
    s5_summary
  )
}
save_book(wb, "Table_S5.xlsx")

# Table S6 --------------------------------------------------------------------
s6_broad <- read_generated(
  "Revision_Fig4_ordinary_TE_methylation_class_summary_repository.csv",
  "Revision_Fig4_ONSEN_vs_ordinary_TE_Col0_leaf_methylation_class_summary.csv"
)
s6_stats <- read_generated(
  "Revision_Fig4_ordinary_TE_methylation_statistics_repository.csv",
  "Revision_Fig4_ONSEN_vs_ordinary_TE_Wilcoxon_BH_statistics.csv"
)
s6_selected <- read_generated(
  "Fig4_selected_loci_methylation_repository.csv",
  "Figure5_candidate_loci_Col0_leaf_methylation_summary_by_context.csv",
  required = FALSE
)
wb <- openxlsx::createWorkbook()
write_workbook_sheet(
  wb, "S6_ordinary_TE_control",
  "Table S6. Public Col-0 leaf weighted methylation summaries for ONSEN LTR candidate regions, HSF-rich non-ONSEN TE outliers and ordinary background TEs.",
  s6_broad
)
write_workbook_sheet(
  wb, "S6B_statistics",
  "Table S6. Public Col-0 leaf weighted methylation summaries for ONSEN LTR candidate regions, HSF-rich non-ONSEN TE outliers and ordinary background TEs.",
  s6_stats,
  p_value_columns = names(s6_stats)[grepl("P|p_value", names(s6_stats))]
)
if (nrow(s6_selected)) {
  write_workbook_sheet(
    wb, "S6C_selected_loci",
    "Table S6. Public Col-0 leaf weighted methylation summaries for ONSEN LTR candidate regions, HSF-rich non-ONSEN TE outliers and ordinary background TEs.",
    s6_selected
  )
}
save_book(wb, "Table_S6.xlsx")

# Table S7 --------------------------------------------------------------------
s7_class <- read_generated(
  "Fig5B_candidate_window_class_replicate_summary_repository.csv",
  "Col0_NS_vs_24h_37C_HS_candidate_TE_class_fractional_count_summary.tsv"
)
s7_window <- read_generated(
  "Fig5C_individual_candidate_window_signal_repository.csv",
  "Fig5C_CLEAN_individual_candidate_window_signal_summary.tsv"
)
s7_stats <- read_generated(
  "Fig5B_candidate_window_class_statistics_repository.csv",
  required = FALSE
)
wb <- openxlsx::createWorkbook()
write_workbook_sheet(
  wb, "S7A_class_signal",
  "Table S7. Fractional multimapping-aware RNA-seq candidate-window summary for Col-0 non-stressed and 24-h 37 C heat-stressed samples.",
  s7_class
)
write_workbook_sheet(
  wb, "S7B_window_signal",
  "Table S7. Fractional multimapping-aware RNA-seq candidate-window summary for Col-0 non-stressed and 24-h 37 C heat-stressed samples.",
  s7_window
)
if (nrow(s7_stats)) {
  write_workbook_sheet(
    wb, "S7C_statistics",
    "Table S7. Fractional multimapping-aware RNA-seq candidate-window summary for Col-0 non-stressed and 24-h 37 C heat-stressed samples.",
    s7_stats,
    p_value_columns = names(s7_stats)[grepl("P|p_value", names(s7_stats))]
  )
}
save_book(wb, "Table_S7.xlsx")

# Table S8 --------------------------------------------------------------------
s8_candidates <- read_generated(
  "accession_candidate_architecture_summary_repository.csv",
  "FIXED_accession_ONSEN_like_mainchr_candidate_windows_JASPAR2026_Arabidopsis_HSF_accession_summary_threshold_0.85.csv"
)
s8_proxy <- read_generated(
  "putative_ONSEN_like_copy_proxy_summary_repository.csv",
  "putative_ONSEN_like_copy_proxy_summary_mismatch_leq4.csv"
)
accession_col_a <- c("accession", "Accession")[c("accession", "Accession") %in% names(s8_candidates)][1]
accession_col_b <- c("accession", "Accession")[c("accession", "Accession") %in% names(s8_proxy)][1]
if (!is.na(accession_col_a) && !is.na(accession_col_b)) {
  s8 <- dplyr::full_join(
    s8_candidates, s8_proxy,
    by = setNames(accession_col_b, accession_col_a)
  )
} else {
  s8 <- s8_candidates
}
wb <- openxlsx::createWorkbook()
write_workbook_sheet(
  wb, "S8_accessions",
  "Table S8. Natural-accession ONSEN-like candidate-window abundance and paired HSE/LTR proxy summary.",
  s8
)
save_book(wb, "Table_S8.xlsx")

# Table S9 --------------------------------------------------------------------
s9 <- read_generated(
  "natural_accession_49bp_variant_accession_summary_repository.csv",
  "natural_accession_49bp_HSE_seed_variant_accession_summary.csv"
)
s9_detail <- read_generated(
  "natural_accession_49bp_variant_summary_repository.csv",
  "natural_accession_49bp_HSE_seed_variant_summary.csv",
  required = FALSE
)
wb <- openxlsx::createWorkbook()
write_workbook_sheet(
  wb, "S9_seed_variants",
  "Table S9. Natural 49-bp ONSEN-like HSE seed-variant accession summary.",
  s9
)
if (nrow(s9_detail)) {
  write_workbook_sheet(
    wb, "S9B_variant_sequences",
    "Table S9. Natural 49-bp ONSEN-like HSE seed-variant accession summary.",
    s9_detail
  )
}
save_book(wb, "Table_S9.xlsx")

# Table S10 -------------------------------------------------------------------
s10_abs <- read_generated(
  "natural_variant_TF_family_absolute_repository.csv",
  "natural_accession_variant_seed_TF_family_summary_long.csv"
)
s10_delta <- read_generated(
  "natural_variant_TF_family_delta_repository.csv",
  "natural_accession_variant_seed_TF_family_delta_vs_Col0_long.csv"
)
wb <- openxlsx::createWorkbook()
write_workbook_sheet(
  wb, "S10_TF_family",
  "Table S10. Natural seed-variant TF-family motif summary.",
  s10_abs
)
write_workbook_sheet(
  wb, "S10B_delta_vs_Col0",
  "Table S10. Natural seed-variant TF-family motif summary.",
  s10_delta
)
save_book(wb, "Table_S10.xlsx")

# Table S11 is a manually integrated, cited literature table. Preserve the
# stable journal version rather than regenerating literature statements.
file.copy(repo_file("Table_S11.xlsx"), out_file("Table_S11.xlsx"), overwrite = TRUE)

# Table S12 -------------------------------------------------------------------
s12_threshold <- read_generated(
  "mutant_sensitivity_threshold_family_summary_repository.csv",
  "Step2B_validated_v1_sequence_family_threshold_summary.csv"
)
s12_empirical <- read_generated(
  "mutant_sensitivity_empirical_comparison_repository.csv",
  "Step2B_validated_v1_designed_mutant_empirical_comparison.csv"
)
s12_gc <- read_generated(
  "random_mutant_GC_spearman_repository.csv",
  "Step2B_validated_v1_random_mutant_GC_spearman_correlations.csv"
)
s12_exact <- read_generated(
  "Step2C_designed_mutant_vs_complete_exact_GC_design_space.csv",
  required = FALSE
)
wb <- openxlsx::createWorkbook()
write_workbook_sheet(
  wb, "S12A_threshold_summary",
  "Table S12. Constrained-mutant sensitivity and exact-GC control for the in-silico-designed 49-bp ONSEN HSE-disrupted sequence.",
  s12_threshold
)
write_workbook_sheet(
  wb, "S12B_empirical",
  "Table S12. Constrained-mutant sensitivity and exact-GC control for the in-silico-designed 49-bp ONSEN HSE-disrupted sequence.",
  s12_empirical,
  p_value_columns = names(s12_empirical)[grepl("P|p_value", names(s12_empirical))]
)
write_workbook_sheet(
  wb, "S12C_GC_correlation",
  "Table S12. Constrained-mutant sensitivity and exact-GC control for the in-silico-designed 49-bp ONSEN HSE-disrupted sequence.",
  s12_gc,
  p_value_columns = names(s12_gc)[grepl("P|p_value", names(s12_gc))]
)
if (nrow(s12_exact)) {
  write_workbook_sheet(
    wb, "S12D_exact_GC",
    "Table S12. Constrained-mutant sensitivity and exact-GC control for the in-silico-designed 49-bp ONSEN HSE-disrupted sequence.",
    s12_exact,
    p_value_columns = names(s12_exact)[grepl("P|p_value", names(s12_exact))]
  )
}
save_book(wb, "Table_S12.xlsx")

# Table S13 -------------------------------------------------------------------
s13_summary <- read_generated(
  "Revision_R1_2_combined_HSF_raw_vs_nonredundant_summary_threshold_0p85_repository.csv",
  "Revision_R1_2_combined_HSF_raw_vs_nonredundant_summary_threshold_0p85.csv"
)
s13_locations <- read_generated(
  "Revision_R1_2_Col0_ONSEN_HSF_nonredundant_locations_threshold_0p85_repository.csv",
  "Revision_R1_2_Col0_ONSEN_HSF_nonredundant_locations_threshold_0p85.csv"
)
s13_49 <- read_generated(
  "Revision_R1_2_49bp_HSF_nonredundant_locations_threshold_0p85_repository.csv",
  "Revision_R1_2_49bp_HSF_nonredundant_locations_threshold_0p85.csv",
  required = FALSE
)
wb <- openxlsx::createWorkbook()
write_workbook_sheet(
  wb, "S13A_summary",
  "Table S13. Non-redundant HSF-compatible locations in native/mutated 49-bp sequences and Col-0 ONSEN terminal candidate windows.",
  s13_summary
)
write_workbook_sheet(
  wb, "S13B_Col0_locations",
  "Table S13. Non-redundant HSF-compatible locations in native/mutated 49-bp sequences and Col-0 ONSEN terminal candidate windows.",
  s13_locations
)
if (nrow(s13_49)) {
  write_workbook_sheet(
    wb, "S13C_49bp_locations",
    "Table S13. Non-redundant HSF-compatible locations in native/mutated 49-bp sequences and Col-0 ONSEN terminal candidate windows.",
    s13_49
  )
}
save_book(wb, "Table_S13.xlsx")

message("Supplementary workbook reconstruction completed.")
