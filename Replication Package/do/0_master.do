********************************************************************************
* Master do-file: replication package
* Project: Food expenditure shares across consumption distributions worldwide
* Author: Jonas Stehl
********************************************************************************

version 17.0
clear all
macro drop _all
set more off
capture log close _all

/* Data instructions
	•	put main datasets in .../Replication Package/data/
	•	put auxiliary inputs in .../Replication Package/data/aux data/
	•	put shapefiles in .../Replication Package/data/aux data/World Bank Official Boundaries - Admin 0/
*/


********************************************************************************
* 1. USER PATHS
********************************************************************************

* Root folder of the replication package
global workdir "/Users/jonasstehl/ownCloud/Healthy food poverty/FESUpdate2025/Replication Package" // insert your folder path
global datadir "/Users/jonasstehl/ownCloud/Healthy food poverty/FESUpdate2025/Replication Package/data" // insert your folder path

********************************************************************************
* 2. BASIC CHECKS
********************************************************************************

if "${projectdir}" == "/PATH/TO/FESUpdate2025" {
    di as error "You must first edit global projectdir in 0_master.do."
    exit 198
}

********************************************************************************
* 3. CREATE FOLDERS IF THEY DO NOT EXIST
********************************************************************************

cap mkdir "${workdir}/data" // add the data into this directory
cap mkdir "${workdir}/graphs" // output directory
cap mkdir "${workdir}/tables" // output directory

********************************************************************************
* 4. INSTALL REQUIRED PACKAGES
********************************************************************************

* Graphics/table packages used across scripts
cap which esttab
if _rc ssc install estout, replace

cap which coefplot
if _rc ssc install coefplot, replace

cap which spider
if _rc ssc install spider, replace

cap which grc1leg2
if _rc ssc install grc1leg2, replace

cap which cleanplots
if _rc ssc install cleanplots, replace

* Map package and dependencies (required for 9_maps.do)
cap which palettes
if _rc ssc install palettes, replace

cap which colrspace
if _rc ssc install colrspace, replace

cap which moremata
if _rc ssc install moremata, replace

cap which geoplot
if _rc ssc install geoplot, replace


********************************************************************************
* 5. RUN SCRIPTS
********************************************************************************

noi di as text "Running cross-sectional analyses"
do "${workdir}/do/1_crosssection.do"

noi di as text "Running time trends"
do "${workdir}/do/2_time.do"

noi di as text "Running imputations"
do "${workdir}/do/3_imputations.do"

noi di as text "Running imputed data analyses"
do "${workdir}/do/4_time_panel.do"

noi di as text "Creating maps"
do "${workdir}/do/5_maps.do"

