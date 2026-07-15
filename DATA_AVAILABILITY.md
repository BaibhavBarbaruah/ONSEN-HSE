# Data and code availability

## RNA-seq generated for this study

DDBJ Sequence Read Archive project: **DRA013053**

| Condition | Run accessions |
|---|---|
| Col-0 non-stressed controls | DRR328576, DRR328577, DRR328578 |
| Col-0, 37°C for 24 h | DRR328579, DRR328580, DRR328581 |

The repository does not duplicate FASTQ/BAM files. Expected filenames and workflow roles are recorded in `INPUT_PROVENANCE.tsv`.

## Public methylome

- GEO series: **GSE43857**
- sample: **GSM1085222**
- material: unstressed *Arabidopsis thaliana* Col-0 leaf
- expected analysis filename: `GSM1085222_mC_calls_Col_0.tsv.gz`

This dataset is used only to describe basal methylation context. It is not a heat-treated methylome and is not interpreted as a measurement of heat-induced methylation change.

## Reference resources

- *Arabidopsis thaliana* TAIR10 reference genome
- Araport11 gene and transposable-element annotation
- JASPAR 2024 and JASPAR 2026 CORE Plants motif collections
- chromosome-level assemblies used for the accession survey

Exact expected filenames and analysis roles are listed in `INPUT_PROVENANCE.tsv`.

## Natural-accession evidence

The genome scan used a Col-0-derived 49-bp seed allowing up to four mismatches. More divergent ONSEN-related sequences may therefore be absent from the detected candidate set.

Published cross-accession heat-response evidence discussed in the manuscript includes ENA project **PRJEB64476**. It is cited as independent published comparative evidence and is not presented as accession-specific RNA-seq generated in this study. The cited synthesis underlying Table S14 is deposited as `source_data/Table_S14_published_accession_evidence.tsv` and as the journal-numbered TSV source sheet.

## Deposited revision outputs

This repository contains:

- portable R scripts and configuration;
- journal-numbered TSV source sheets used to reconstruct Table S1-Table S14 workbooks;
- compact source-data TSV files for Fig. 7 and Table S8/Fig. S3;
- exact representative JASPAR PFMs used by the Fig. 7D workflow;
- explicit script-to-display-item mappings for all main and supplementary figures;
- input provenance, final-numbering map, checksums and validation code.

Large public/reference inputs and journal submission artwork are not duplicated. The deposited source sheets, compact source data, motif matrices, checksums and reconstruction scripts preserve the exact numerical revision outputs while keeping the repository portable.

## Code repository

https://github.com/BaibhavBarbaruah/ONSEN-HSE
