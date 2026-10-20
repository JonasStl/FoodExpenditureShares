********************************************************************************
* Master do-file: replication package
* Project: Food expenditure shares across welfare distributions worldwide
* Author: Jonas Stehl
********************************************************************************

version 17.0
clear all
macro drop _all
set more off
capture log close _all

********************************************************************************
* 1. User path
********************************************************************************

global projectdir "/PATH/TO/FoodExpenditureShares/Replication Package"

if strpos("${projectdir}", "/PATH/TO/") {
	display as error "Edit global projectdir in 0_master.do before running the package."
	exit 198
}

global dofiledir "${projectdir}/do"
global datadir "${projectdir}/data"
global auxdir "${datadir}/aux data"
global shapedir "${datadir}/World Bank Official Boundaries - Admin 0"
global graphdir "${projectdir}/graphs"
global tabledir "${projectdir}/tables"
global logdir "${projectdir}/logs"

capture mkdir "${graphdir}"
capture mkdir "${tabledir}"
capture mkdir "${logdir}"

log using "${logdir}/replication.log", text replace

********************************************************************************
* 2. Required packages
********************************************************************************

capture which esttab
if _rc ssc install estout, replace

capture which coefplot
if _rc ssc install coefplot, replace

capture which labmask
if _rc ssc install labutil, replace

capture findfile scheme-cleanplots.scheme
if _rc ssc install cleanplots, replace

capture findfile lmoremata.mlib
if _rc ssc install moremata, replace

capture which colorpalette
if _rc ssc install palettes, replace

capture which colrspace
if _rc ssc install colrspace, replace

capture which spider
if _rc ssc install spider, replace

capture which geoplot
if _rc ssc install geoplot, replace

********************************************************************************
* 3. Analysis
********************************************************************************

do "${dofiledir}/1_measurement_comparability.do"
do "${dofiledir}/2_crosssection_income_groups.do"
do "${dofiledir}/3_crosssection_welfare.do"
do "${dofiledir}/4_crosssection_prices.do"
do "${dofiledir}/5_crosssection_correlations.do"
do "${dofiledir}/6_crosssection_inequality.do"
do "${dofiledir}/7_time_trends.do"
do "${dofiledir}/8_imputations.do"
do "${dofiledir}/9_imputed_results.do"
do "${dofiledir}/10_maps.do"

log close
