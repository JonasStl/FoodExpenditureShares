********************************************************************************
*								Analysis: Cross-section				*
********************************************************************************

use "${datadir}/FESdatabase_quintiles_analysis.dta", clear

keep if latest_fes == 1

bysort countrycode Surveyyear: egen FES_p1 = max(cond(Percentile==1, FES, .))
bysort countrycode Surveyyear: egen FES_p5 = max(cond(Percentile==5, FES, .))
gen FES_gap = FES_p1 - FES_p5
drop FES_p1 FES_p5

preserve
replace Surveyyear = string(year) if Surveyyear == ""
collapse (firstnm) Surveyyear, by(countrycode)

lab var Surveyyear "Survey year"
export excel using "${tabledir}/TableS1.xlsx", replace firstrow(varlabels)
putexcel set "${tabledir}/TableS1.xlsx", modify
putexcel A1:H1, bold

restore
preserve
collapse (mean) mean_FES = FES mean_FES_gap = FES_gap ///
         (sd)   sd_FES   = FES sd_FES_gap = FES_gap ///
         (count) n_FES   = FES n_FES_gap = FES_gap ///
         , by(Percentile)

gen incomelevel = "World"

tempfile worldmean
save `worldmean'

restore
collapse (mean) mean_FES = FES mean_FES_gap = FES_gap ///
         (sd)   sd_FES   = FES sd_FES_gap = FES_gap ///
         (count) n_FES   = FES n_FES_gap = FES_gap ///
         , by(Percentile incomelevel)

append using `worldmean'

gen se_FES = sd_FES / sqrt(n_FES)
gen ci_lb = mean_FES - invttail(n_FES-1,0.025)*se_FES
gen ci_ub = mean_FES + invttail(n_FES-1,0.025)*se_FES

gen se_FES_gap = sd_FES_gap / sqrt(n_FES_gap)
gen ci_lb_gap = mean_FES_gap - invttail(n_FES_gap-1,0.025)*se_FES_gap
gen ci_ub_gap = mean_FES_gap + invttail(n_FES_gap-1,0.025)*se_FES_gap

drop if incomelevel == ""
gen lbl = string(mean_FES, "%9.2f") + "%"

graph set window fontface "Helvetica"

twoway ///
    rcap ci_lb ci_ub Percentile if incomelevel=="HIC", lcolor(blue)   || ///
    line mean_FES Percentile if incomelevel=="HIC"   , lwidth(medthick) lcolor(blue) lpattern(solid) || ///
	scatter mean_FES Percentile if incomelevel=="HIC" & Percentile == 1, msymbol(none) mlab(lbl) mlabposition(9) mlabcolor(blue) mlabsize(6pt) mlabformat(%9.2f) || ///
	scatter mean_FES Percentile if incomelevel=="HIC" & Percentile == 5, msymbol(none) mlab(lbl) mlabposition(3) mlabcolor(blue) mlabsize(6pt) mlabformat(%9.2f) || ///
    rcap ci_lb ci_ub Percentile if incomelevel=="LIC", lcolor(green)   || ///
    line mean_FES Percentile if incomelevel=="LIC"   , lwidth(medthick) lcolor(green) lpattern(solid)  || ///
	scatter mean_FES Percentile if incomelevel=="LIC" & Percentile == 1, msymbol(none) mlab(lbl) mlabposition(9) mlabcolor(green) mlabsize(6pt) mlabformat(%9.2f) || ///
	scatter mean_FES Percentile if incomelevel=="LIC" & Percentile == 5, msymbol(none) mlab(lbl) mlabposition(3) mlabcolor(green) mlabsize(6pt) mlabformat(%9.2f) || ///
    rcap ci_lb ci_ub Percentile if incomelevel=="LMIC", lcolor(sienna)   || ///
    line mean_FES Percentile if incomelevel=="LMIC"   , lwidth(medthick) lcolor(sienna) lpattern(solid)  || ///
	scatter mean_FES Percentile if incomelevel=="LMIC" & Percentile == 1, msymbol(none) mlab(lbl) mlabposition(9) mlabcolor(sienna) mlabsize(6pt) mlabformat(%9.2f) || ///
	scatter mean_FES Percentile if incomelevel=="LMIC" & Percentile == 5, msymbol(none) mlab(lbl) mlabposition(3) mlabcolor(sienna) mlabsize(6pt) mlabformat(%9.2f) || ///
    rcap ci_lb ci_ub Percentile if incomelevel=="UMIC", lcolor(cranberry)   || ///
    line mean_FES Percentile if incomelevel=="UMIC"   , lwidth(medthick) lcolor(cranberry) lpattern(solid)  || ///
	scatter mean_FES Percentile if incomelevel=="UMIC" & Percentile == 1, msymbol(none) mlab(lbl) mlabposition(8) mlabcolor(cranberry) mlabsize(6pt) mlabformat(%9.2f) || ///
	scatter mean_FES Percentile if incomelevel=="UMIC" & Percentile == 5, msymbol(none) mlab(lbl) mlabposition(4) mlabcolor(cranberry) mlabsize(6pt) mlabformat(%9.2f) || ///
    rcap ci_lb ci_ub Percentile if incomelevel=="World", lcolor(black) || ///
    line mean_FES Percentile if incomelevel=="World" , lwidth(medthick) lcolor(black) lpattern(dash) || ///
	scatter mean_FES Percentile if incomelevel=="World" & Percentile == 1, msymbol(none) mlab(lbl) mlabposition(10) mlabcolor(black) mlabsize(6pt) mlabformat(%9.2f) || ///
	scatter mean_FES Percentile if incomelevel=="World" & Percentile == 5, msymbol(none) mlab(lbl) mlabposition(3) mlabcolor(black) mlabsize(6pt) mlabformat(%9.2f) || ///
    , ///
    xtitle("Welfare quintile", size(7pt)) ///
    ytitle("Mean FES", size(7pt)) ///
    xlabel(1(1)5) xscale(range(0.4 5)) ///
	ylabel(0(10)70) ///
    legend(size(7pt) rows(1) position(6) order(2 "HIC"  14 "UMIC" 10 "LMIC" 6 "LIC"  18 "World")) ///
	graphregion(margin(r+6)) scheme(cleanplots) xsize(8cm) ysize(7cm) subtitle("{bf:c}", size(10pt) position(11) span)

graph export "${graphdir}/Figure1c.png", replace
graph export "${graphdir}/Figure1c.pdf", replace

use "${datadir}/FESdatabase_quintiles_analysis.dta", clear

keep if latest_fes == 1

drop if year < 2010

bysort countrycode Surveyyear: egen FES_p1 = max(cond(Percentile==1, FES, .))
bysort countrycode Surveyyear: egen FES_p5 = max(cond(Percentile==5, FES, .))
gen FES_gap = FES_p1 - FES_p5
drop FES_p1 FES_p5

preserve
collapse (mean) mean_FES = FES mean_FES_gap = FES_gap ///
         (sd)   sd_FES   = FES sd_FES_gap = FES_gap ///
         (count) n_FES   = FES n_FES_gap = FES_gap ///
         , by(Percentile)

gen incomelevel = "World"

tempfile worldmean
save `worldmean'

restore
collapse (mean) mean_FES = FES mean_FES_gap = FES_gap ///
         (sd)   sd_FES   = FES sd_FES_gap = FES_gap ///
         (count) n_FES   = FES n_FES_gap = FES_gap ///
         , by(Percentile incomelevel)

append using `worldmean'

gen se_FES = sd_FES / sqrt(n_FES)
gen ci_lb = mean_FES - invttail(n_FES-1,0.025)*se_FES
gen ci_ub = mean_FES + invttail(n_FES-1,0.025)*se_FES

gen se_FES_gap = sd_FES_gap / sqrt(n_FES_gap)
gen ci_lb_gap = mean_FES_gap - invttail(n_FES_gap-1,0.025)*se_FES_gap
gen ci_ub_gap = mean_FES_gap + invttail(n_FES_gap-1,0.025)*se_FES_gap

drop if incomelevel == ""
gen lbl = string(mean_FES, "%9.2f") + "%"

graph set window fontface "Helvetica"

twoway ///
    rcap ci_lb ci_ub Percentile if incomelevel=="HIC", lcolor(blue)   || ///
    line mean_FES Percentile if incomelevel=="HIC"   , lwidth(medthick) lcolor(blue) lpattern(solid) || ///
	scatter mean_FES Percentile if incomelevel=="HIC" & Percentile == 1, msymbol(none) mlab(lbl) mlabposition(9) mlabcolor(blue) mlabsize(6pt) mlabformat(%9.2f) || ///
	scatter mean_FES Percentile if incomelevel=="HIC" & Percentile == 5, msymbol(none) mlab(lbl) mlabposition(3) mlabcolor(blue) mlabsize(6pt) mlabformat(%9.2f) || ///
    rcap ci_lb ci_ub Percentile if incomelevel=="LIC", lcolor(green)   || ///
    line mean_FES Percentile if incomelevel=="LIC"   , lwidth(medthick) lcolor(green) lpattern(solid)  || ///
	scatter mean_FES Percentile if incomelevel=="LIC" & Percentile == 1, msymbol(none) mlab(lbl) mlabposition(9) mlabcolor(green) mlabsize(6pt) mlabformat(%9.2f) || ///
	scatter mean_FES Percentile if incomelevel=="LIC" & Percentile == 5, msymbol(none) mlab(lbl) mlabposition(3) mlabcolor(green) mlabsize(6pt) mlabformat(%9.2f) || ///
    rcap ci_lb ci_ub Percentile if incomelevel=="LMIC", lcolor(sienna)   || ///
    line mean_FES Percentile if incomelevel=="LMIC"   , lwidth(medthick) lcolor(sienna) lpattern(solid)  || ///
	scatter mean_FES Percentile if incomelevel=="LMIC" & Percentile == 1, msymbol(none) mlab(lbl) mlabposition(9) mlabcolor(sienna) mlabsize(6pt) mlabformat(%9.2f) || ///
	scatter mean_FES Percentile if incomelevel=="LMIC" & Percentile == 5, msymbol(none) mlab(lbl) mlabposition(3) mlabcolor(sienna) mlabsize(6pt) mlabformat(%9.2f) || ///
    rcap ci_lb ci_ub Percentile if incomelevel=="UMIC", lcolor(cranberry)   || ///
    line mean_FES Percentile if incomelevel=="UMIC"   , lwidth(medthick) lcolor(cranberry) lpattern(solid)  || ///
	scatter mean_FES Percentile if incomelevel=="UMIC" & Percentile == 1, msymbol(none) mlab(lbl) mlabposition(8) mlabcolor(cranberry) mlabsize(6pt) mlabformat(%9.2f) || ///
	scatter mean_FES Percentile if incomelevel=="UMIC" & Percentile == 5, msymbol(none) mlab(lbl) mlabposition(4) mlabcolor(cranberry) mlabsize(6pt) mlabformat(%9.2f) || ///
    rcap ci_lb ci_ub Percentile if incomelevel=="World", lcolor(black) || ///
    line mean_FES Percentile if incomelevel=="World" , lwidth(medthick) lcolor(black) lpattern(dash) || ///
	scatter mean_FES Percentile if incomelevel=="World" & Percentile == 1, msymbol(none) mlab(lbl) mlabposition(10) mlabcolor(black) mlabsize(6pt) mlabformat(%9.2f) || ///
	scatter mean_FES Percentile if incomelevel=="World" & Percentile == 5, msymbol(none) mlab(lbl) mlabposition(3) mlabcolor(black) mlabsize(6pt) mlabformat(%9.2f) || ///
    , ///
    xtitle("Welfare quintile", size(7pt)) ///
    ytitle("Mean FES", size(7pt)) ///
    xlabel(1(1)5) xscale(range(0.4 5)) ///
	ylabel(0(10)70) ///
    legend(size(7pt) rows(1) position(6) order(2 "HIC"  14 "UMIC" 10 "LMIC" 6 "LIC"  18 "World")) ///
	graphregion(margin(r+8)) scheme(cleanplots) xsize(8cm) ysize(6cm) subtitle("{bf:a}", size(10pt) position(11) span)

graph export "${graphdir}/FigureS2a.png", replace
graph export "${graphdir}/FigureS2a.pdf", replace

tempfile historic_incomegroups

import excel using "${auxdir}/OGHIST_2026_07_15.xlsx", ///
	sheet("Country Analytical History") cellrange(A7:AO235) clear

rename A countrycode
drop if missing(countrycode)
drop B

local historic_cols C D E F G H I J K L M N O P Q R S T U V W X Y Z ///
	AA AB AC AD AE AF AG AH AI AJ AK AL AM AN AO
local historic_year = 1987
foreach col of local historic_cols {
	rename `col' historic_incomelevel`historic_year'
	local ++historic_year
}

reshape long historic_incomelevel, i(countrycode) j(year)
replace historic_incomelevel = subinstr(historic_incomelevel, "*", "", .)
replace historic_incomelevel = "LIC" if historic_incomelevel == "L"
replace historic_incomelevel = "LMC" if historic_incomelevel == "LM"
replace historic_incomelevel = "UMC" if historic_incomelevel == "UM"
replace historic_incomelevel = "HIC" if historic_incomelevel == "H"
keep if inlist(historic_incomelevel, "LIC", "LMC", "UMC", "HIC")

rename countrycode historic_countrycode
isid historic_countrycode year
save `historic_incomegroups'

use "${datadir}/FESdatabase_quintiles_analysis.dta", clear
keep if latest_fes == 1

gen historic_countrycode = countrycode
replace historic_countrycode = "SDN" if countrycode == "SSD" & year == 2009
merge m:1 historic_countrycode year using `historic_incomegroups'
drop if _merge == 1
drop _merge historic_countrycode

bysort countrycode: egen max_anyyear = max(year)
keep if year == max_anyyear
drop max_anyyear

preserve
collapse (mean) mean_FES = FES ///
		 (sd)   sd_FES   = FES ///
		 (count) n_FES   = FES ///
		 , by(Percentile)

gen historic_incomelevel = "World"
tempfile worldmean_historic
save `worldmean_historic'

restore
collapse (mean) mean_FES = FES ///
		 (sd)   sd_FES   = FES ///
		 (count) n_FES   = FES ///
		 , by(Percentile historic_incomelevel)

append using `worldmean_historic'

gen se_FES = sd_FES / sqrt(n_FES)
gen ci_lb = mean_FES - invttail(n_FES - 1, 0.025) * se_FES
gen ci_ub = mean_FES + invttail(n_FES - 1, 0.025) * se_FES
gen lbl = string(mean_FES, "%9.2f") + "%"

graph set window fontface "Helvetica"

twoway ///
	rcap ci_lb ci_ub Percentile if historic_incomelevel == "HIC", lcolor(blue) || ///
	line mean_FES Percentile if historic_incomelevel == "HIC", lwidth(medthick) lcolor(blue) lpattern(solid) || ///
	scatter mean_FES Percentile if historic_incomelevel == "HIC" & Percentile == 1, msymbol(none) mlab(lbl) mlabposition(9) mlabcolor(blue) mlabsize(6pt) mlabformat(%9.2f) || ///
	scatter mean_FES Percentile if historic_incomelevel == "HIC" & Percentile == 5, msymbol(none) mlab(lbl) mlabposition(3) mlabcolor(blue) mlabsize(6pt) mlabformat(%9.2f) || ///
	rcap ci_lb ci_ub Percentile if historic_incomelevel == "LIC", lcolor(green) || ///
	line mean_FES Percentile if historic_incomelevel == "LIC", lwidth(medthick) lcolor(green) lpattern(solid) || ///
	scatter mean_FES Percentile if historic_incomelevel == "LIC" & Percentile == 1, msymbol(none) mlab(lbl) mlabposition(9) mlabcolor(green) mlabsize(6pt) mlabformat(%9.2f) || ///
	scatter mean_FES Percentile if historic_incomelevel == "LIC" & Percentile == 5, msymbol(none) mlab(lbl) mlabposition(3) mlabcolor(green) mlabsize(6pt) mlabformat(%9.2f) || ///
	rcap ci_lb ci_ub Percentile if historic_incomelevel == "LMC", lcolor(sienna) || ///
	line mean_FES Percentile if historic_incomelevel == "LMC", lwidth(medthick) lcolor(sienna) lpattern(solid) || ///
	scatter mean_FES Percentile if historic_incomelevel == "LMC" & Percentile == 1, msymbol(none) mlab(lbl) mlabposition(9) mlabcolor(sienna) mlabsize(6pt) mlabformat(%9.2f) || ///
	scatter mean_FES Percentile if historic_incomelevel == "LMC" & Percentile == 5, msymbol(none) mlab(lbl) mlabposition(3) mlabcolor(sienna) mlabsize(6pt) mlabformat(%9.2f) || ///
	rcap ci_lb ci_ub Percentile if historic_incomelevel == "UMC", lcolor(cranberry) || ///
	line mean_FES Percentile if historic_incomelevel == "UMC", lwidth(medthick) lcolor(cranberry) lpattern(solid) || ///
	scatter mean_FES Percentile if historic_incomelevel == "UMC" & Percentile == 1, msymbol(none) mlab(lbl) mlabposition(8) mlabcolor(cranberry) mlabsize(6pt) mlabformat(%9.2f) || ///
	scatter mean_FES Percentile if historic_incomelevel == "UMC" & Percentile == 5, msymbol(none) mlab(lbl) mlabposition(4) mlabcolor(cranberry) mlabsize(6pt) mlabformat(%9.2f) || ///
	rcap ci_lb ci_ub Percentile if historic_incomelevel == "World", lcolor(black) || ///
	line mean_FES Percentile if historic_incomelevel == "World", lwidth(medthick) lcolor(black) lpattern(dash) || ///
	scatter mean_FES Percentile if historic_incomelevel == "World" & Percentile == 1, msymbol(none) mlab(lbl) mlabposition(10) mlabcolor(black) mlabsize(6pt) mlabformat(%9.2f) || ///
	scatter mean_FES Percentile if historic_incomelevel == "World" & Percentile == 5, msymbol(none) mlab(lbl) mlabposition(3) mlabcolor(black) mlabsize(6pt) mlabformat(%9.2f) || ///
	, ///
	xtitle("Welfare quintile", size(7pt)) ///
	ytitle("Mean FES", size(7pt)) ///
	xlabel(1(1)5) xscale(range(0.4 5)) ///
	ylabel(0(10)70) ///
	legend(size(7pt) rows(1) position(6) order(2 "HIC" 14 "UMIC" 10 "LMIC" 6 "LIC" 18 "World")) ///
	graphregion(margin(r+8)) scheme(cleanplots) xsize(8cm) ysize(6cm) subtitle("{bf:b}", size(10pt) position(11) span)

graph export "${graphdir}/FigureS2b.png", replace
graph export "${graphdir}/FigureS2b.pdf", replace

use "${datadir}/FESdatabase_quintiles_analysis.dta", clear
drop FES_ICP
merge m:1 countrycode using "${auxdir}/icp_fes_data.dta", keep(match) nogen keepusing(FES_ICP)

keep if latest_fes == 1 & Percentile == 1

preserve
collapse (mean) mean_FES = FES_ICP  ///
         (sd)   sd_FES   = FES_ICP ///
         (count) n_FES   = FES_ICP

gen incomelevel = "World"

tempfile worldmean
save `worldmean'

restore
collapse (mean) mean_FES = FES_ICP  ///
         (sd)   sd_FES   = FES_ICP  ///
         (count) n_FES   = FES_ICP  ///
         , by(incomelevel)

append using `worldmean'

gen se_FES = sd_FES / sqrt(n_FES)
gen ci_lb = mean_FES - invttail(n_FES-1,0.025)*se_FES
gen ci_ub = mean_FES + invttail(n_FES-1,0.025)*se_FES

drop if incomelevel == ""
gen lbl = string(mean_FES, "%9.2f") + "%"

graph set window fontface "Helvetica"

gen Percentile = "National accounts"
encode Percentile, gen(Percentile_enc)

twoway ///
    rcap ci_lb ci_ub Percentile_enc if incomelevel=="HIC", lcolor(blue) lwidth(0.5pt)   || ///
	scatter mean_FES Percentile_enc if incomelevel=="HIC",  mlab(lbl) mlabposition(3) msymbol(smcircle) mcolor(blue) msize(3pt) mlabcolor(blue) mlabsize(6pt) mlabformat(%9.2f) || ///
    rcap ci_lb ci_ub Percentile_enc if incomelevel=="LIC", lcolor(green) lwidth(0.5pt)    || ///
	scatter mean_FES Percentile_enc if incomelevel=="LIC" , mlab(lbl) mlabposition(3) msymbol(smcircle) mcolor(green) msize(3pt) mlabcolor(green) mlabsize(6pt) mlabformat(%9.2f) || ///
    rcap ci_lb ci_ub Percentile_enc if incomelevel=="LMIC", lcolor(sienna) lwidth(0.5pt)    || ///
	scatter mean_FES Percentile_enc if incomelevel=="LMIC" ,  mlab(lbl) mlabposition(3) msymbol(smcircle) mcolor(sienna) msize(3pt) mlabcolor(sienna) mlabsize(6pt) mlabformat(%9.2f) || ///
    rcap ci_lb ci_ub Percentile_enc if incomelevel=="UMIC", lcolor(cranberry) lwidth(0.5pt)    || ///
	scatter mean_FES Percentile_enc if incomelevel=="UMIC" ,  mlab(lbl) mlabposition(4) msymbol(smcircle) mcolor(cranberry) msize(3pt) mlabcolor(cranberry) mlabsize(6pt) mlabformat(%9.2f) || ///
    rcap ci_lb ci_ub Percentile_enc if incomelevel=="World", lcolor(black) lwidth(0.5pt) || ///
	scatter mean_FES Percentile_enc if incomelevel=="World" ,  mlab(lbl) mlabposition(2) msymbol(smcircle) mcolor(black) msize(3pt) mlabcolor(black) mlabsize(6pt) mlabformat(%9.2f) || ///
    , ///
    xtitle("") ///
    ytitle("Food Expenditure Share", size(7pt)) ///
    xlabel(1(1)1, value labsize(7pt)) ///
	ylabel(0(10)50, labsize(7pt)) ///
    legend(size(6pt) ring(1) cols(1) position(3) order(4 "LIC" 6 "LMIC"  10 "World" 8 "UMIC"  2 "HIC")) ///
	scheme(cleanplots) xsize(4cm) ysize(6cm) subtitle("{bf:a}", size(10pt) position(11) span)

graph export "${graphdir}/FigureS3a.png", replace
graph export "${graphdir}/FigureS3a.pdf", replace

use "${datadir}/FESdatabase_quintiles_analysis.dta", clear

twoway ///
	(scatter FES_ICP consexp_pc_d_ln if Percentile == 1 & data_icp ==1, mcolor(green*0.5) msymbol(smsquare)) ///
	(scatter national_FES consexp_pc_d_ln if Percentile == 1 & data_icp ==1, mcolor(black*0.5) msymbol(smcircle)) ///
	(scatter FES consexp_pc_d_ln if Percentile == 1 & data_icp ==1, mcolor("215 25 28*0.5") msymbol(smcircle)) ///
	(scatter FES consexp_pc_d_ln if Percentile == 5 & data_icp ==1, mcolor("44 123 182*0.5") msymbol(smcircle)) ///
	(lowess  FES_ICP consexp_pc_d_ln if Percentile == 1 & data_icp ==1, lpattern(solid) lcolor(green)) ///
	(lowess national_FES consexp_pc_d_ln if Percentile == 1 & data_icp ==1, lpattern(dash) lcolor(black)) ///
	(lowess FES consexp_pc_d_ln if Percentile == 1 & data_icp ==1, lpattern(dash) lcolor("215 25 28")) ///
	(lowess FES consexp_pc_d_ln if Percentile == 5 & data_icp ==1, lpattern(dash) lcolor("44 123 182")) ///
	, ///
	xtitle("Average per-capita welfare (2021 PPP dollars per day, log scale)", size(7pt)) ///
	ytitle("Food Expenditure Shares", size(7pt)) ///
	ylabel(0(10)80, labsize(7pt)) xlab(,labsize(7pt)) ///
	legend(size(6pt) ring(0) cols(1) position(2) order(1 "National accounts average" 2 "Survey-based national average" 3 "Survey-based Q1 average" 4 "Survey-based Q5 average")) ///
	graphregion(margin(r+8)) scheme(cleanplots) xsize(8cm) ysize(6cm) subtitle("{bf:b}", size(10pt) position(11) span)

graph export "${graphdir}/FigureS3b.png", replace
graph export "${graphdir}/FigureS3b.pdf", replace
