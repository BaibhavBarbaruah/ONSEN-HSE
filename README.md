# ONSEN HSE regulatory-architecture analyses

This repository contains the analysis code, compact metadata and supplementary tables supporting the Biology Open manuscript:

**Heat-responsive ONSEN long terminal repeats integrate heat shock factor motifs, DNA methylation and natural sequence variation in Arabidopsis**  
Manuscript ID: **bio.062799**

Authors: Baibhav R. Barbaruah, Rahmadani P. Airalangga and Hidetaka Ito.

## Scope

The repository covers the analyses reported in:

- Fig. 1–Fig. 7
- Fig. S1–Fig. S4
- Table S1–Table S13

The implemented workflow includes native-versus-designed 49-bp motif analysis, constrained-mutant sensitivity analysis, Col-0 ONSEN terminal-window analysis, strict transposable-element background comparisons, non-redundant HSF-location analysis, methylation analysis, RNA-seq analysis and natural-accession comparisons.

## Repository layout

All files are placed in the repository root. The scripts create a `reproduced_outputs` directory at run time unless another output directory is specified.

Important files:

- `00_install_packages.R`: installs or checks required R packages
- `00_run_pipeline.R`: runs the complete workflow in order
- `ONSEN_config.R`: path and run-mode configuration
- `ONSEN_functions.R`: shared utility functions
- `01_native_mutated_motif_analysis.R`–`07_accession_analysis.R`: primary analyses
- `08_write_supplementary_tables.R`: supplementary-table reconstruction
- `09_write_session_info.R`: R and package environment capture
- `10_validate_manuscript_outputs.R`: repository and reference-value validation
- `INPUT_PROVENANCE.tsv`: required external and processed inputs
- `REPRODUCIBILITY_MATRIX.tsv`: mapping from manuscript items to scripts and outputs
- `Table_S1.xlsx`–`Table_S13.xlsx`: deposited supplementary tables
- `Final_figures_reference.pdf`: combined figure reference

## Software requirements

The workflow was developed in R 4.4.3. Required CRAN and Bioconductor packages are listed in `R_PACKAGE_REQUIREMENTS.txt`. They can be installed with:

```r
source("00_install_packages.R")
```

## External data

Large reference and sequencing files are not duplicated in the repository. Their accessions, expected filenames and roles in the workflow are listed in `INPUT_PROVENANCE.tsv` and summarized in `DATA_AVAILABILITY.md`.

Principal resources include:

- Arabidopsis thaliana TAIR10 reference genome
- Araport11 gene and transposable-element annotation
- JASPAR 2024/2026 CORE Plants motif collections
- GEO GSE43857 / GSM1085222 Col-0 leaf methylome
- DDBJ DRA013053, runs DRR328576–DRR328581
- chromosome-level assemblies for the natural accessions examined in the study

Place the required external and processed inputs under a single data directory. The scripts search that directory recursively using the filenames listed in `INPUT_PROVENANCE.tsv`.

## Configuration

Set the input and output locations before running the workflow:

```r
Sys.setenv(
  ONSEN_DATA_ROOT = "path/to/ONSEN_HSE_input_data",
  ONSEN_OUTPUT_ROOT = "path/to/ONSEN_HSE_outputs"
)
```

When these variables are not set:

- `ONSEN_DATA_ROOT` defaults to the current working directory
- `ONSEN_OUTPUT_ROOT` defaults to `reproduced_outputs` under the current working directory

Three optional environment variables control execution:

```r
Sys.setenv(
  ONSEN_FORCE_RESCAN = "false",
  ONSEN_RUN_LARGE_STEPS = "false",
  ONSEN_MAKE_FIGURES = "true"
)
```

- `ONSEN_FORCE_RESCAN=true` recomputes motif scans instead of preferring deposited processed scan outputs.
- `ONSEN_RUN_LARGE_STEPS=true` enables computationally intensive raw-data steps where implemented.
- `ONSEN_MAKE_FIGURES=false` suppresses figure generation while retaining tabular analyses.

## Running the workflow

From the repository root:

```r
source("00_install_packages.R")
source("00_run_pipeline.R")
```

The scripts can also be run individually in the following order:

```r
source("01_native_mutated_motif_analysis.R")
source("02_constrained_mutant_sensitivity.R")
source("03_col0_HSF_and_TE_background.R")
source("04_nonredundant_HSF_locations.R")
source("05_methylation_analysis.R")
source("06_rnaseq_analysis.R")
source("07_accession_analysis.R")
source("08_write_supplementary_tables.R")
source("09_write_session_info.R")
source("10_validate_manuscript_outputs.R")
```

## Validation

Run the validation script after the required repository files are present:

```r
source("10_validate_manuscript_outputs.R")
```

The script checks:

- presence of required scripts, metadata and supplementary tables
- absence of broken nested-folder source statements
- absence of hard-coded drive-specific paths
- selected manuscript-level reference values in Tables S1, S4, S5, S6, S8, S12 and S13

A successful run writes `repository_validation_report.csv` and ends with:

```text
REPOSITORY VALIDATION PASSED
```

## Analysis coverage

### Native and designed 49-bp sequence analysis

`01_native_mutated_motif_analysis.R` performs canonical HSE-unit identification, JASPAR PFM parsing, two-strand PWM scanning, motif-model best-score comparison, motif-position hit summaries and the analyses underlying Figs. 1–2 and Tables S1–S3.

### Constrained-mutant sensitivity analysis

`02_constrained_mutant_sensitivity.R` implements the 5,000-sequence constrained random-mutant analysis and the complete 5,120-sequence valid exact-GC design space used for Fig. S3 and Table S12.

### Col-0 ONSEN and TE-background analysis

`03_col0_HSF_and_TE_background.R` analyzes sixteen 800-bp ONSEN terminal candidate windows, the strict 1,942-element TE background, threshold robustness, Wilcoxon tests, Benjamini–Hochberg adjustment and Cliff's delta for Fig. 3 and Tables S4–S5.

### Non-redundant HSF locations

`04_nonredundant_HSF_locations.R` converts reverse-strand coordinates to forward-sequence coordinates and merges transitively overlapping HSF-model intervals for Fig. S4 and Table S13.

### DNA methylation

`05_methylation_analysis.R` uses the public Col-0 leaf methylome to calculate weighted CG, CHG and CHH methylation, ordinary-TE controls, locus summaries and aggregate profiles for Fig. 4 and Table S6.

### RNA-seq

`06_rnaseq_analysis.R` includes optional Rsubread alignment/counting, DESeq2 analysis and fractional multimapping-aware candidate-window signal analysis for Fig. 5 and Table S7.

### Natural accessions

`07_accession_analysis.R` performs accession seed scanning, candidate-window extraction, HSE architecture analysis, HSF-density analysis, paired structural proxies and natural-variant TF-family comparisons for Figs. 6–7, Figs. S1–S2 and Tables S8–S10.

A complete item-to-script mapping is provided in `REPRODUCIBILITY_MATRIX.tsv`.

## Motif-scoring definition

Position frequency matrices are converted to log2 probability-ratio position weight matrices using:

- pseudocount: `0.8`
- equal A/C/G/T background: `0.25`
- both DNA strands
- relative score:

```text
(raw score - theoretical minimum score) /
(theoretical maximum score - theoretical minimum score)
```

The primary high-confidence threshold is `0.85`. A threshold of `0.90` is used for the reported robustness comparison, and the constrained-mutant analysis additionally evaluates `0.80` and `0.95`.

## Interpretation limits

- Motif matches represent predicted sequence compatibility and do not establish transcription-factor binding or regulatory activity.
- Overlapping HSF PWM model matches are not independent binding sites; non-redundant merged intervals are therefore reported separately.
- The methylome derives from unstressed Col-0 leaves and describes basal methylation context rather than heat-induced methylation change.
- Candidate-window RNA-seq signal is multimapping-aware and is not interpreted as unambiguous copy-specific expression.
- The accession survey uses a Col-0-derived 49-bp seed with up to four mismatches and may not detect more divergent ONSEN-related sequences.
- Paired HSE/LTR candidates are structural proxies rather than definitive copy-number calls.

## Citation and license

Citation metadata are provided in `CITATION.cff`. The code is released under the MIT License.
