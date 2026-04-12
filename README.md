# FoodExpenditureShares replication package

This repository contains the Stata code required to reproduce the analysis outputs for the paper title **Food expenditure shares across consumption distributions worldwide** by Jonas Stehl. 
The package is designed to be run from a single master script after users set the local project path and place the required input data in the specified folders.

## Repository structure

```text
FoodExpenditureShares/
├── README.md
├── LICENSE
├── .gitignore
└── Replication Package/
    ├── do/
    │   ├── 0_master.do
    │   ├── 4_analysis_crosssection.do
    │   ├── 5_time.do
    │   ├── 6_imputations.do
    │   ├── 7_time_panel.do
    │   └── 9_maps.do
    ├── data/
    │   ├── FESdatabase_quintiles.dta
    │   ├── FESdatabase_deciles.dta
    │   ├── FESdatabase_raw.dta
    │   ├── aux data/
    │   │   ├── CoHD.dta
    │   │   ├── fao_data.dta
    │   │   ├── food_cpi.dta
    │   │   ├── icp_data.dta
    │   │   ├── PIP.dta
    │   │   ├── PIP_UMICs.dta
    │   │   └── WDI.dta
    │   └── World Bank Official Boundaries - Admin 0
    ├── graphs/
    ├── tables/
    └── logs/
```

## System requirements

### Software
- Stata 17 or later.
- A standard installation of Stata with permission to install SSC packages.

### User-written Stata packages
The master script installs the following user-written packages if they are not already available:
- `estout`
- `coefplot`
- `spider`
- `grc1leg2`
- `cleanplots`
- `palettes`
- `colrspace`
- `moremata`
- `geoplot`

### Operating systems
The code is written in Stata and should run on macOS, Windows, and Linux, subject to valid local paths and Stata availability.

### Versions tested
Stata/SE 17.0.

## Installation guide

1. Clone or download this repository.
2. Create the folder structure shown above if it is not already present.
3. Place the Stata do-files in `Replication Package/do/`.
4. Place the required input datasets in `Replication Package/data/` and `Replication Package/data/aux data/`.
5. If reproducing the maps, place the World Bank boundary files in a separate local folder and set the corresponding path in the master script.
6. Open `0_master.do` in Stata.
7. Edit the global path at the top of `0_master.do` so that `projectdir` points to your local copy of the replication package.
8. If running the maps, edit `shapedir` in `0_master.do` so that it points to the folder containing the world boundary files.
9. Run `0_master.do`.

### Typical installation time
On a standard desktop or laptop computer, installation of the required SSC packages should generally take only a few minutes, depending on internet speed and whether packages are already installed.

## Data inputs

### Data included in the repository
This GitHub repository is intended to contain code and documentation only. Large input datasets and derived outputs are excluded from version control.

### External data archive
Additional data required to run the full replication package will be archived on Zenodo.

**Zenodo record placeholder:** `[Zenodo DOI / URL here]`

### Data placement
Place the input data under the following paths:
- Main analytic datasets: `Replication Package/data/`
- Auxiliary datasets: `Replication Package/data/aux data/`
- Map boundary files for `9_maps.do`: local folder referenced in `global shapedir`

### Core datasets referenced by the current scripts
Main data directory:
- `FESdatabase_quintiles.dta`
- `FESdatabase_deciles.dta`
- `FESdatabase_raw.dta`

Auxiliary data directory (`Replication Package/data/aux data/`):
- `WDI.dta`
- `PIP.dta`
- `PIP_UMICs.dta`
- `CoHD.dta`
- `fao_data.dta`
- `food_cpi.dta`
- `icp_data.dta`

Generated during execution:
- `FESdatabase_imputed.dta` is created by `6_imputations.do` and therefore does not need to be supplied initially if the full workflow is run from the beginning.

## Running the replication package

### Master script
Run the full workflow from:
- `Replication Package/do/0_master.do`

The master script:
- defines user-editable project paths;
- creates the required directories if they do not already exist;
- installs required SSC packages if missing; and
- runs the do-files in sequence.

### Script order
The intended execution order is:
1. `1_crosssection.do`
2. `2_time.do`
3. `3_imputations.do`
4. `4_time_panel.do`
5. `5_maps.do`

### Important path note
The child do-files currently contain hard-coded global path definitions at the top. For the master script to control paths consistently, those path globals should be commented out or removed in the child scripts. In `9_maps.do`, the hard-coded `cd` command for the boundary files should be replaced with:

```stata
cd "${shapedir}"
```

## Replication

### Data
Data is provided through the Zenodo archive via [will be made available upon publication].

### How to run code
1. Download the demo data.
2. Place the demo files in the same directory structure described above.
3. Update `projectdir` in `0_master.do`.
4. Run `0_master.do` in Stata.

### Expected output
Successful execution should produce:
- figures in `Replication Package/graphs/`
- tables and exported spreadsheets in `Replication Package/tables/` or the configured output locations
- any intermediate analytic files generated during the workflow, including `FESdatabase_imputed.dta`.

### Expected runtime
Around 10 minutes using Apple M4 Pro chip.

## Instructions for use on new data
The scripts are structured for this study's data inputs and directory conventions. To apply the workflow to new data, users should:
1. place replacement input files in the same folder structure;
2. preserve variable names and formats expected by the do-files, or revise the scripts accordingly; and
3. update any map-boundary references if different geographic files are used.

## Reproducibility notes
- The repository excludes raw and derived data files from Git version control; these should be obtained from the companion Zenodo archive.
- Users should ensure that path definitions are centralized in the master script.
- Because some scripts export graphs and spreadsheets directly, write permissions are required for the local project folders.

## License
MIT License

## Citation
- add manuscript citation
- add Zenodo DOI for the archived replication materials.

## Contact
jonas.stehl@uni-goettingen.de