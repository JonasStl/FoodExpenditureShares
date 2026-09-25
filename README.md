# Food expenditure shares across welfare distributions worldwide

This repository contains the Stata replication files for *Food expenditure shares across welfare distributions worldwide* by Jonas Stehl.

Only the do-files are distributed through this GitHub repository. Data, figures, tables, logs, and other generated outputs are kept locally and excluded from version control.

## Requirements

- Stata 17 or later
- Internet access on the first run to install missing SSC packages
- Write access to the replication-package directory

The master file installs `estout`, `coefplot`, `labutil`, `cleanplots`, `moremata`, `palettes`, `colrspace`, `spider`, and `geoplot` when required.

## Running the package

1. Open `Replication Package/do/0_master.do`.
2. Replace the value of `projectdir` with the full path to the local `Replication Package` directory.
3. Run `0_master.do` in Stata.

All other paths are derived from `projectdir`. The master file runs the ten analysis files in order and writes a text log to `Replication Package/logs/replication.log`.

## Directory structure

```text
FoodExpenditureShares/
├── README.md
├── LICENSE
├── .gitignore
├── .gitattributes
└── Replication Package/
    ├── do/
    │   ├── 0_master.do
    │   ├── 1_measurement_comparability.do
    │   ├── 2_crosssection_income_groups.do
    │   ├── 3_crosssection_welfare.do
    │   ├── 4_crosssection_prices.do
    │   ├── 5_crosssection_correlations.do
    │   ├── 6_crosssection_inequality.do
    │   ├── 7_time_trends.do
    │   ├── 8_imputations.do
    │   ├── 9_imputed_results.do
    │   └── 10_maps.do
    ├── data/
    ├── graphs/
    ├── tables/
    └── logs/
```

## Outputs

The package creates the manuscript figures as `Figure1a`-`Figure4b` and the supplementary figures as `FigureS1`-`FigureS15b`, in both PNG and PDF format. No exploratory figures are exported.

Additional outputs are:

- `tables/TableS1.xlsx`
- `data/FES Database.xlsx`
- `data/FESdatabase_imputed.dta`, used by the subsequent figure script
- `data/aux data/IncomeQuintiles/FESdatabase_quintiles_PIPwelfare_2021ppp.dta`, an intermediate matched dataset

The map conversion files `_worldmap.dta` and `_worldmap_shp.dta` are generated automatically from the World Bank boundary shapefile stored in the local data directory. All boundary files are excluded from Git.

## Reproducibility notes

- Random-number seeds used for the measurement comparison and multiple imputation are fixed in the corresponding do-files.
- The imputation file exports only the published panel and the intermediate Stata file required for the supplementary figures; internal diagnostic datasets are not created.
- Output directories and generated files can be deleted safely and recreated by rerunning the master file.
- The repository's `.gitignore` permits only `Replication Package/do/*.do` within the replication package; data and outputs remain local.

## License

The code is released under the MIT License. Data and boundary files remain subject to the terms of their respective providers.

## Contact

Jonas Stehl  
Department of Economics, University of Goettingen  
jonas.stehl@uni-goettingen.de
