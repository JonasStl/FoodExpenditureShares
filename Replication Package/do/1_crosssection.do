********************************************************************************
*								Analysis: Cross-section							*
********************************************************************************

********************************************************************************
* Figure 1b	
********************************************************************************
	
use "${datadir}/FESdatabase_quintiles.dta", clear
drop if year == 2025 | year < 2000 

merge m:1 countrycode year using "${datadir}/aux data/WDI.dta", keep(match master) nogen 
replace incomelevel = "LIC" if Country == "Ethiopia" & incomelevel == "INX" 
replace incomelevelname = "Low income" if Country == "Ethiopia" & incomelevelname == "Not classified"

* Keep most recent year
bysort countrycode: egen max_anyyear  = max(year) 
keep if year == max_anyyear
drop max_anyyear

* Gap
bysort countrycode Surveyyear: egen FES_p1 = max(cond(Percentile==1, FES, .))
bysort countrycode Surveyyear: egen FES_p5 = max(cond(Percentile==5, FES, .))
gen FES_gap = FES_p1 - FES_p5
drop FES_p1 FES_p5
tabstat FES_gap if Percentile==1, by(incomelevel) 
tabstat FES_gap if Percentile==1
	
* Export years used in cross-country analyses
preserve 
replace Surveyyear = string(year) if Surveyyear == ""
collapse (firstnm) Surveyyear, by(countrycode)

* World mean
restore
preserve
collapse (mean) mean_FES = FES mean_FES_gap = FES_gap ///
         (sd)   sd_FES   = FES sd_FES_gap = FES_gap ///
         (count) n_FES   = FES n_FES_gap = FES_gap ///
         , by(Percentile)
		 
gen incomelevel = "World"
		 
tempfile worldmean
save `worldmean'

* Mean by income group
restore
collapse (mean) mean_FES = FES mean_FES_gap = FES_gap ///
         (sd)   sd_FES   = FES sd_FES_gap = FES_gap ///
         (count) n_FES   = FES n_FES_gap = FES_gap ///
         , by(Percentile incomelevel)

append using `worldmean'


* 95% CI using t distribution
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
    rcap ci_lb ci_ub Percentile if incomelevel=="LMC", lcolor(sienna)   || ///
    line mean_FES Percentile if incomelevel=="LMC"   , lwidth(medthick) lcolor(sienna) lpattern(solid)  || ///
	scatter mean_FES Percentile if incomelevel=="LMC" & Percentile == 1, msymbol(none) mlab(lbl) mlabposition(9) mlabcolor(sienna) mlabsize(6pt) mlabformat(%9.2f) || ///
	scatter mean_FES Percentile if incomelevel=="LMC" & Percentile == 5, msymbol(none) mlab(lbl) mlabposition(3) mlabcolor(sienna) mlabsize(6pt) mlabformat(%9.2f) || ///
    rcap ci_lb ci_ub Percentile if incomelevel=="UMC", lcolor(cranberry)   || ///
    line mean_FES Percentile if incomelevel=="UMC"   , lwidth(medthick) lcolor(cranberry) lpattern(solid)  || ///
	scatter mean_FES Percentile if incomelevel=="UMC" & Percentile == 1, msymbol(none) mlab(lbl) mlabposition(8) mlabcolor(cranberry) mlabsize(6pt) mlabformat(%9.2f) || ///
	scatter mean_FES Percentile if incomelevel=="UMC" & Percentile == 5, msymbol(none) mlab(lbl) mlabposition(4) mlabcolor(cranberry) mlabsize(6pt) mlabformat(%9.2f) || ///
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
	graphregion(margin(r+6)) scheme(cleanplots) xsize(8cm) ysize(8cm) subtitle("{bf:b}", size(10pt) position(11) span) 
	
graph export "${workdir}/graphs/Figure1b.png", replace
graph export "${workdir}/graphs/Figure1b.pdf", replace
	

/*
				Correlation with related data
*/

use "${datadir}/FESdatabase_quintiles.dta", clear
merge m:1 countrycode year using "${datadir}/aux data/PIP.dta", keep(match master) nogen 
merge m:1 countrycode year using "${datadir}/aux data/WDI.dta", keep(match master) nogen // only Argentina (1996), Bhutan (2025), Turkmenistan (1998), Japan(2025), Korea (2025) not matched
merge m:1 countrycode year using "${datadir}/aux data/CoHD.dta", keep(match master) nogen 
merge m:1 countrycode year using "${datadir}/aux data/fao_data.dta", keep(match master) nogen 
merge m:1 countrycode using "${datadir}/aux data/icp_data.dta", keep(match master) nogen 
foreach var of varlist YR20211101000 YR20211101100 YR20211101110 YR20211101120 YR20211101130 YR20211101140 YR20211101150 YR20211101160 YR20211101170 YR20211101180 YR20211101190 YR20211102000 YR20211103000 YR20211105000 YR20211107000 YR20211108000 YR20219060000 YR20219080000 YR20219120000 { // 
	replace `var' = . if year < 2018 // to have +- 3 years around 2021
}


replace incomelevel = "LIC" if Country == "Ethiopia" & incomelevel == "INX" 
replace incomelevel = "LMIC" if incomelevel == "LMC"
replace incomelevel = "UMIC" if incomelevel == "UMC"
replace incomelevelname = "Low income" if Country == "Ethiopia" & incomelevelname == "Not classified"
encode incomelevel, gen(incomelevel_enc)

drop if year == 2025 

* Create variables for which observations shall be used for each graph: WDI and PIP
	bysort countrycode: egen max_anyyear  = max(year) 

	gen data_WDI_PIP = 1 if year == max_anyyear
	drop max_anyyear 

* Create variables for which observations shall be used for each graph: CoHD
	bysort countrycode: egen max_anyyear = ///
	max(cond(!missing(CoHD), year, .))

	gen data_CoHD = 1 if year == max_anyyear
	drop max_anyyear 

* Create variables for which observations shall be used for each graph: CoCA and CoHD_ss
	bysort countrycode: egen max_anyyear = ///
	max(cond(!missing(CoCA), year, .))

	gen data_CoCA = 1 if year == max_anyyear
	drop max_anyyear 
	
* Create variables for which observations shall be used for each graph: Food insecurity
	bysort countrycode: egen max_anyyear = ///
	max(cond(!missing(moderate_fies_perc_fao), year, .))

	gen data_FIES = 1 if year == max_anyyear
	drop max_anyyear 
	
* Create variables for which observations shall be used for each graph: Undernourishment
	bysort countrycode: egen max_anyyear = ///
	max(cond(!missing(undernourished_perc_fao), year, .))

	gen data_undernourish = 1 if year == max_anyyear
	drop max_anyyear 
	
* ICP data
	bysort countrycode: egen max_anyyear = ///
	max(cond(!missing(YR20211101000), year, .))
	gen data_icp = 1 if year == max_anyyear
	drop max_anyyear
	

* Adjust variables
replace headcount = headcount*100
replace spr = spr*100
gen ny_gdp_pcap_pp_kd_ln = ln(ny_gdp_pcap_pp_kd)
gen consexp_pc_d_ln = ln(consexp_pc_d)
	
********************************************************************************
* Figure 2	
********************************************************************************
	
// FES1 & Extreme Poverty
pwcorr FES headcount if Percentile == 1 & data_WDI_PIP == 1
local note = round(`r(rho)',0.001)
local note_n = "{it: n = `r(N)'}"
local note = substr("`note'",1,4)
local note = "{it:r = 0`note'}"
twoway ///
	scatter FES headcount if Percentile == 1 & data_WDI_PIP == 1 & incomelevel == "LIC", mcolor(cranberry*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES headcount if Percentile == 1 & data_WDI_PIP == 1 & incomelevel == "LMIC", mcolor(midblue*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES headcount if Percentile == 1 & data_WDI_PIP == 1 & incomelevel == "UMIC", mcolor(forest_green*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES headcount if Percentile == 1 & data_WDI_PIP == 1 & incomelevel == "HIC", mcolor(orange*0.7) msize(tiny) msymbol(circle)  || ///
	qfitci FES headcount if Percentile == 1 & data_WDI_PIP == 1, lcolor(black) fcolor(black*0.3%20) astyle(background) || ///
	,  xscale(range(0 100)) yscale(range(0 1)) xlabel(0(20)100, format(%9.0gc)) ylabel(0(20)100, format(%9.0gc) angle(0)) ///
	ytitle("Food Expenditure Share Q1", size(7pt)) xtitle("Headcount ratio International Poverty Line (in %)", size(7pt)) title("") ///
	note("`note'" "`note_n'", size(6pt) ring(0) position(4)) ///
	subtitle("{bf:a}", size(10pt) position(11) span) ///
	ylab(,labsize(7pt)) xlab(,labsize(7pt)) ///
	scheme(cleanplots) graphregion(color(white)) legend(off) name(g1, replace) 
	
// FES1 & Societal Poverty
pwcorr FES spr if Percentile == 1 & data_WDI_PIP == 1
local note = round(`r(rho)',0.001)
local note_n = "{it: n = `r(N)'}"
local note = substr("`note'",1,4)
local note = "{it:r = 0`note'}"
twoway ///
	scatter FES spr if Percentile == 1 & data_WDI_PIP == 1 & incomelevel == "LIC", mcolor(cranberry*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES spr if Percentile == 1 & data_WDI_PIP == 1 & incomelevel == "LMIC", mcolor(midblue*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES spr if Percentile == 1 & data_WDI_PIP == 1 & incomelevel == "UMIC", mcolor(forest_green*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES spr if Percentile == 1 & data_WDI_PIP == 1 & incomelevel == "HIC", mcolor(orange*0.7) msize(tiny) msymbol(circle)  || ///
	qfitci FES spr if Percentile == 1 & data_WDI_PIP == 1, lcolor(black) fcolor(black*0.3%20) astyle(background) || ///
	,  xscale(range(0 100)) yscale(range(0 1)) xlabel(0(20)100, format(%9.0gc)) ylabel(0(20)100, format(%9.0gc) angle(0)) ///
	ytitle("Food Expenditure Share Q1", size(7pt)) xtitle("Headcount ratio Societal Poverty Line (in %)", size(7pt)) title("") ///
	note("`note'" "`note_n'", size(6pt) ring(0) position(4)) ///
	subtitle("{bf:b}", size(10pt) position(11) span) ///
	ylab(,labsize(7pt)) xlab(,labsize(7pt)) ///
	scheme(cleanplots) graphregion(color(white)) legend(off) name(g2, replace) nodraw


// FES1 & Log. Average consumption expenditure
pwcorr FES consexp_pc_d_ln if Percentile == 1 & data_WDI_PIP == 1
local note = string(`r(rho)', "%6.3f")
local note_n = "{it: n = `r(N)'}"
local note = "{it:r = `note'}"
twoway ///
	scatter FES consexp_pc_d_ln if Percentile == 1 & data_WDI_PIP == 1 & incomelevel == "LIC", mcolor(cranberry*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES consexp_pc_d_ln if Percentile == 1 & data_WDI_PIP == 1 & incomelevel == "LMIC", mcolor(midblue*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES consexp_pc_d_ln if Percentile == 1 & data_WDI_PIP == 1 & incomelevel == "UMIC", mcolor(forest_green*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES consexp_pc_d_ln if Percentile == 1 & data_WDI_PIP == 1 & incomelevel == "HIC", mcolor(orange*0.7) msize(tiny) msymbol(circle)  || ///
	qfitci FES consexp_pc_d_ln if Percentile == 1 & data_WDI_PIP == 1, lcolor(black) fcolor(black*0.3%20) astyle(background) || ///
	,  xscale(range(0.5 5)) yscale(range(0 1)) xlabel(0(1)5, format(%9.0gc)) ylabel(0(20)100, format(%9.0gc) angle(0)) ///
	ytitle("Food Expenditure Share Q1", size(7pt)) xtitle("Log. Consumption Expenditure per capita per day", size(7pt)) title("") ///
	note("`note'" "`note_n'", size(6pt) ring(0) position(2)) ///
	subtitle("{bf:c}", size(10pt) position(11) span) ///
	ylab(,labsize(7pt)) xlab(,labsize(7pt)) ///
	scheme(cleanplots) graphregion(color(white)) legend(off) name(g3, replace) nodraw

// FES1 & Log. GDP per capita
pwcorr FES ny_gdp_pcap_pp_kd_ln if Percentile == 1 & data_WDI_PIP == 1
local note = string(`r(rho)', "%6.3f")
local note_n = "{it: n = `r(N)'}"
local note = "{it:r = `note'}"
twoway ///
	scatter FES ny_gdp_pcap_pp_kd_ln if Percentile == 1 & data_WDI_PIP == 1 & incomelevel == "LIC", mcolor(cranberry*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES ny_gdp_pcap_pp_kd_ln if Percentile == 1 & data_WDI_PIP == 1 & incomelevel == "LMIC", mcolor(midblue*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES ny_gdp_pcap_pp_kd_ln if Percentile == 1 & data_WDI_PIP == 1 & incomelevel == "UMIC", mcolor(forest_green*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES ny_gdp_pcap_pp_kd_ln if Percentile == 1 & data_WDI_PIP == 1 & incomelevel == "HIC", mcolor(orange*0.7) msize(tiny) msymbol(circle)  || ///
	qfitci FES ny_gdp_pcap_pp_kd_ln if Percentile == 1 & data_WDI_PIP == 1, lcolor(black) fcolor(black*0.3%20) astyle(background) || ///
	,  xscale(range(7 12)) yscale(range(0 1)) xlabel(7(1)12, format(%9.0gc)) ylabel(0(20)100, format(%9.0gc) angle(0)) ///
	ytitle("Food Expenditure Share Q1", size(7pt)) xtitle("Log. GDP per capita per day", size(7pt)) title("") ///
	note("`note'" "`note_n'", size(6pt) ring(0) position(2)) ///
	subtitle("{bf:d}", size(10pt) position(11) span) ///
	ylab(,labsize(7pt)) xlab(,labsize(7pt)) ///
	scheme(cleanplots) graphregion(color(white)) legend(off) name(g4, replace) nodraw

	
// CoHD
pwcorr FES CoHD if Percentile == 1 & data_CoHD == 1
local note = round(`r(rho)',0.001)
local note_n = "{it: n = `r(N)'}"
local note = substr("`note'",1,4)
local note = "{it:r = 0`note'}"
twoway ///
	scatter FES CoHD if Percentile == 1 & data_CoHD == 1 & incomelevel == "LIC", mcolor(cranberry*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES CoHD if Percentile == 1 & data_CoHD == 1 & incomelevel == "LMIC", mcolor(midblue*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES CoHD if Percentile == 1 & data_CoHD == 1 & incomelevel == "UMIC", mcolor(forest_green*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES CoHD if Percentile == 1 & data_CoHD == 1 & incomelevel == "HIC", mcolor(orange*0.7) msize(tiny) msymbol(circle)  || ///
	qfitci FES CoHD if Percentile == 1 & data_CoHD == 1, lcolor(black) fcolor(black*0.3%20) astyle(background) || ///
	,  xscale(range(2 7)) yscale(range(0 1)) xlabel(2(1)7, format(%9.0gc)) ylabel(0(20)100, format(%9.0gc) angle(0)) ///
	ytitle("Food Expenditure Share Q1", size(7pt)) xtitle("Cost of a healthy diet (in PPP-adjusted USD)", size(7pt)) title("") ///
	note("`note'" "`note_n'", size(6pt) ring(0) position(4)) ///
	subtitle("{bf:e}", size(10pt) position(11) span) ///
	ylab(,labsize(7pt)) xlab(,labsize(7pt)) ///
	scheme(cleanplots) graphregion(color(white)) legend(off) name(g5, replace) nodraw
	
	
// Cost an energy sufficient diet
pwcorr FES CoCA if Percentile == 1 & data_CoCA == 1
local note = round(`r(rho)',0.001)
local note_n = "{it: n = `r(N)'}"
local note = substr("`note'",1,4)
local note = "{it:r = 0`note'}"
twoway ///
	scatter FES CoCA if Percentile == 1 & data_CoCA == 1 & incomelevel == "LIC", mcolor(cranberry*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES CoCA if Percentile == 1 & data_CoCA == 1 & incomelevel == "LMIC", mcolor(midblue*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES CoCA if Percentile == 1 & data_CoCA == 1 & incomelevel == "UMIC", mcolor(forest_green*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES CoCA if Percentile == 1 & data_CoCA == 1 & incomelevel == "HIC", mcolor(orange*0.7) msize(tiny) msymbol(circle)  || ///
	qfitci FES CoCA if Percentile == 1 & data_CoCA == 1, lcolor(black) fcolor(black*0.3%20) astyle(background) || ///
	,  xscale(range(0 3)) yscale(range(0 1)) xlabel(0(0.5)3, format(%9.0gc)) ylabel(0(20)100, format(%9.0gc) angle(0)) ///
	ytitle("Food Expenditure Share Q1", size(7pt)) xtitle("Cost of an energy sufficient diet (in PPP-adjusted USD)", size(7pt)) title("") ///
	note("`note'" "`note_n'", size(6pt) ring(0) position(4)) ///
	subtitle("{bf:f}", size(10pt) position(11) span) ///
	ylab(,labsize(7pt)) xlab(,labsize(7pt)) ///
	scheme(cleanplots) graphregion(color(white)) legend(off) name(g6, replace) nodraw
	
// Moderate or severe food insecurity:
pwcorr FES moderate_fies_perc_fao if Percentile == 1 & data_FIES == 1
local note = round(`r(rho)',0.001)
local note_n = "{it: n = `r(N)'}"
local note = substr("`note'",1,4)
local note = "{it:r = 0`note'}"
twoway ///
	scatter FES moderate_fies_perc_fao if Percentile == 1 & data_FIES == 1 & incomelevel == "LIC", mcolor(cranberry*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES moderate_fies_perc_fao if Percentile == 1 & data_FIES == 1 & incomelevel == "LMIC", mcolor(midblue*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES moderate_fies_perc_fao if Percentile == 1 & data_FIES == 1 & incomelevel == "UMIC", mcolor(forest_green*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES moderate_fies_perc_fao if Percentile == 1 & data_FIES == 1 & incomelevel == "HIC", mcolor(orange*0.7) msize(tiny) msymbol(circle)  || ///
	qfitci FES moderate_fies_perc_fao if Percentile == 1 & data_FIES == 1, lcolor(black) fcolor(black*0.3%20) astyle(background) || ///
	,  xscale(range(0 100)) yscale(range(0 1)) xlabel(0(20)100, format(%9.0gc)) ylabel(0(20)100, format(%9.0gc) angle(0)) ///
	ytitle("Food Expenditure Share Q1", size(7pt)) xtitle("Moderate or severe food insecurity (in %)", size(7pt)) title("") ///
	note("`note'" "`note_n'", size(6pt) ring(0) position(4)) ///
	subtitle("{bf:g}", size(10pt) position(11) span) ///
	ylab(,labsize(7pt)) xlab(,labsize(7pt)) ///
	scheme(cleanplots) graphregion(color(white)) legend(off) name(g7, replace) nodraw
		
// Undernourishment
pwcorr FES undernourished_perc_fao if Percentile == 1 & data_undernourish == 1 
local note = round(`r(rho)',0.001)
local note_n = "{it: n = `r(N)'}"
local note = substr("`note'",1,4)
local note = "{it:r = 0`note'}"
twoway ///
	scatter FES undernourished_perc_fao if Percentile == 1 & data_undernourish == 1 & incomelevel == "LIC", mcolor(cranberry*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES undernourished_perc_fao if Percentile == 1 & data_undernourish == 1 & incomelevel == "LMIC", mcolor(midblue*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES undernourished_perc_fao if Percentile == 1 & data_undernourish == 1 & incomelevel == "UMIC", mcolor(forest_green*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES undernourished_perc_fao if Percentile == 1 & data_undernourish == 1 & incomelevel == "HIC", mcolor(orange*0.7) msize(tiny) msymbol(circle)  || ///
	qfitci FES undernourished_perc_fao if Percentile == 1 & data_undernourish == 1, lcolor(black) fcolor(black*0.3%20) astyle(background) || ///
	,  xscale(range(0 60)) yscale(range(0 1)) xlabel(0(10)60, format(%9.0gc)) ylabel(0(20)100, format(%9.0gc) angle(0)) ///
	ytitle("Food Expenditure Share Q1", size(7pt)) xtitle("Undernourishment (in %)", size(7pt)) title("") ///
	note("`note'" "`note_n'", size(6pt) ring(0) position(4)) ///
	subtitle("{bf:h}", size(10pt) position(11) span) ///
	ylab(,labsize(7pt)) xlab(,labsize(7pt)) ///
	scheme(cleanplots) graphregion(color(white)) legend(off) name(g8, replace) nodraw	
	
	
* Radar plot for correlations
tempfile corrwide
tempname posth

postfile `posth' str8 series ///
    double quintile intl_poverty societal_poverty log_consexp log_gdppc ///
           cost_healthy_diet cost_energy_diet food_insecurity undernourishment ///
    using `corrwide', replace

* Global
forvalues q = 1/5 {

    quietly pwcorr FES headcount if Percentile==`q' & data_WDI_PIP==1
    local r1 = abs(r(rho))

    quietly pwcorr FES spr if Percentile==`q' & data_WDI_PIP==1
    local r2 = abs(r(rho))

    quietly pwcorr FES consexp_pc_d_ln if Percentile==`q' & data_WDI_PIP==1
    local r3 = abs(r(rho))

    quietly pwcorr FES ny_gdp_pcap_pp_kd_ln if Percentile==`q' & data_WDI_PIP==1
    local r4 = abs(r(rho))

    quietly pwcorr FES CoHD if Percentile==`q' & data_CoHD==1
    local r5 = abs(r(rho))

    quietly pwcorr FES CoCA if Percentile==`q' & data_CoCA==1
    local r6 = abs(r(rho))

    quietly pwcorr FES moderate_fies_perc_fao if Percentile==`q' & data_FIES==1
    local r7 = abs(r(rho))

    quietly pwcorr FES undernourished_perc_fao if Percentile==`q' & data_undernourish==1
    local r8 = abs(r(rho))

    post `posth' ("Global") (`q') (`r1') (`r2') (`r3') (`r4') (`r5') (`r6') (`r7') (`r8')
}

* Income groups
foreach g in 1 2 3 4 {
    local glab = cond(`g'==1,"HIC", cond(`g'==2,"LIC", cond(`g'==3,"LMIC","UMIC")))

    quietly pwcorr FES headcount if Percentile==1 & data_WDI_PIP==1 & incomelevel_enc==`g'
    local r1 = abs(r(rho))

    quietly pwcorr FES spr if Percentile==1 & data_WDI_PIP==1 & incomelevel_enc==`g'
    local r2 = abs(r(rho))

    quietly pwcorr FES consexp_pc_d_ln if Percentile==1 & data_WDI_PIP==1 & incomelevel_enc==`g'
    local r3 = abs(r(rho))

    quietly pwcorr FES ny_gdp_pcap_pp_kd_ln if Percentile==1 & data_WDI_PIP==1 & incomelevel_enc==`g'
    local r4 = abs(r(rho))

    quietly pwcorr FES CoHD if Percentile==1 & data_CoHD==1 & incomelevel_enc==`g'
    local r5 = abs(r(rho))

    quietly pwcorr FES CoCA if Percentile==1 & data_CoCA==1 & incomelevel_enc==`g'
    local r6 = abs(r(rho))

    quietly pwcorr FES moderate_fies_perc_fao if Percentile==1 & data_FIES==1 & incomelevel_enc==`g'
    local r7 = abs(r(rho))

    quietly pwcorr FES undernourished_perc_fao if Percentile==1 & data_undernourish==1 & incomelevel_enc==`g'
    local r8 = abs(r(rho))

    post `posth' ("`glab'") (1) (`r1') (`r2') (`r3') (`r4') (`r5') (`r6') (`r7') (`r8')
}

postclose `posth'

use `corrwide', clear
list, clean

label variable intl_poverty        "Extreme poverty"
label variable societal_poverty    "Societal poverty"
label variable log_consexp         "Log cons. exp. pc"
label variable log_gdppc           "Log GDP pc"
label variable cost_healthy_diet   "Healthy diet cost"
label variable cost_energy_diet    "Energy diet cost"
label variable food_insecurity     "Food insecurity"
label variable undernourishment    "Undernourishment"
gen order = .
replace order = 1 if series == "Global"
replace order = 2 if series == "LIC"
replace order = 3 if series == "LMIC"
replace order = 4 if series == "UMIC"
replace order = 5 if series == "HIC"
sort order
labmask order, val(series)

spider intl_poverty societal_poverty log_consexp log_gdppc ///
       cost_healthy_diet cost_energy_diet food_insecurity undernourishment if quintile == 1, ///
    over(order) ///
    scale(0(0.2)1) ///
    rline(0.2 0.4 0.6 0.8 1) ///
    lw(thin thin thin thin thin) ///
	rlinewidth(thin thin thin thin thin) ///
	rlinecolor(gs12%40) ///
	palette("black" "cranberry" "midblue" "forest_green" "orange") /// 
	glabposition(0) glabsize(6pt) range(0 0.4 0.6 0.8 1) cuts(5) ///
    msymbol(O O O O O) ///
    msize(vsmall vsmall vsmall vsmall vsmall) ///
    legend(position(6) rows(1) size(7pt)) ///
    title("", size(9pt)) ///
    note("", size(6pt)) ///
	slabsize(5pt)  ///
	subtitle("{bf:i}", size(10pt) position(11) span) rot(20) ///
	note("{bf:Pearson Correlation Coefficients} |{it:r} |", size(7pt) position(12) margin(zero)) ///
    scheme(cleanplots) name(radar1, replace)

graph combine g1 g2 g3 g4 g5 g6 g7 g8 radar1, graphregion(color(white)) ysize(13cm) xsize(18cm) cols(3) imargin(tiny)
graph export "${workdir}/graphs/Figure2.png", replace
graph export "${workdir}/graphs/Figure2.pdf", replace
	
	
********************************************************************************
* Figure S4
********************************************************************************
keep if series == "Global"
gen id = _n

rename intl_poverty      corr1
rename societal_poverty  corr2
rename log_consexp       corr3
rename log_gdppc         corr4
rename cost_healthy_diet corr5
rename cost_energy_diet  corr6
rename food_insecurity   corr7
rename undernourishment  corr8

reshape long corr, i(id quintile) j(indicator)

* labels
label define indlbl ///
    1 "Intl poverty" ///
    2 "Societal poverty" ///
    3 "Log cons. exp." ///
    4 "Log GDP pc" ///
    5 "Healthy diet cost" ///
    6 "Energy diet cost" ///
    7 "Food insecurity" ///
    8 "Undernourishment"
label values indicator indlbl

graph bar corr, ///
    over(quintile, relabel(1 "Q1" 2 "Q2" 3 "Q3" 4 "Q4" 5 "Q5")) ///
    over(indicator, label(labsize(6pt) angle(35))) ///
    asyvars ///
    bargap(15) ///
    legend(rows(1) ring(0) position(1) size(6pt) symysize(2) symxsize(2)) ///
    ytitle("Pearson Correlation Coefficient", size(7pt)) ///
	ylab(0(0.1)0.8, labsize(6pt))   ///
    scheme(cleanplots)
graph export "${workdir}/graphs/FigureS4.png", replace
graph export "${workdir}/graphs/FigureS4.pdf", replace
	


********************************************************************************
* Figure S1
********************************************************************************
use "${datadir}/FESdatabase_quintiles.dta", clear
merge m:1 countrycode year using "${datadir}/aux data/PIP.dta", keep(match master) nogen
merge m:1 countrycode year using "${datadir}/aux data/WDI.dta", keep(match master) nogen // only Argentina (1996), Bhutan (2025), Turkmenistan (1998), Japan(2025), Korea (2025) not matched
merge m:1 countrycode year using "${datadir}/aux data/CoHD.dta", keep(match master) nogen 
merge m:1 countrycode year using "${datadir}/aux data/fao_data.dta", keep(match master) nogen 
merge m:1 countrycode using "${datadir}/aux data/icp_data.dta", keep(match master) nogen 
foreach var of varlist YR20211101000 YR20211101100 YR20211101110 YR20211101120 YR20211101130 YR20211101140 YR20211101150 YR20211101160 YR20211101170 YR20211101180 YR20211101190 YR20211102000 YR20211103000 YR20211105000 YR20211107000 YR20211108000 YR20219060000 YR20219080000 YR20219120000 { // 
	replace `var' = . if year < 2018 // to have +- 3 years around 2021
}

replace incomelevel = "LIC" if Country == "Ethiopia" & incomelevel == "INX" 
replace incomelevel = "LMIC" if incomelevel == "LMC"
replace incomelevel = "UMIC" if incomelevel == "UMC"
replace incomelevelname = "Low income" if Country == "Ethiopia" & incomelevelname == "Not classified"
encode incomelevel, gen(incomelevel_enc)

drop if year == 2025 

* Create variables for which observations shall be used for each graph: WDI and PIP
	bysort countrycode: egen max_anyyear  = max(year) 

	gen data_WDI_PIP = 1 if year == max_anyyear
	drop max_anyyear 

* Create variables for which observations shall be used for each graph: CoHD
	bysort countrycode: egen max_anyyear = ///
	max(cond(!missing(CoHD), year, .))

	gen data_CoHD = 1 if year == max_anyyear
	drop max_anyyear 

* Create variables for which observations shall be used for each graph: CoCA and CoHD_ss
	bysort countrycode: egen max_anyyear = ///
	max(cond(!missing(CoCA), year, .))

	gen data_CoCA = 1 if year == max_anyyear
	drop max_anyyear 
	
* Create variables for which observations shall be used for each graph: Food insecurity
	bysort countrycode: egen max_anyyear = ///
	max(cond(!missing(moderate_fies_perc_fao), year, .))

	gen data_FIES = 1 if year == max_anyyear
	drop max_anyyear 
	
* Create variables for which observations shall be used for each graph: Undernourishment
	bysort countrycode: egen max_anyyear = ///
	max(cond(!missing(undernourished_perc_fao), year, .))

	gen data_undernourish = 1 if year == max_anyyear
	drop max_anyyear 
	
* ICP data
	bysort countrycode: egen max_anyyear = ///
	max(cond(!missing(YR20211101000), year, .))
	gen data_icp = 1 if year == max_anyyear
	drop max_anyyear
	
	
* Adjust variables
replace headcount = headcount*100
replace spr = spr*100
gen ny_gdp_pcap_pp_kd_ln = ln(ny_gdp_pcap_pp_kd)
gen consexp_pc_d_ln = ln(consexp_pc_d)


// Food and non-alcoholic beverages
pwcorr FES YR20211101000 if Percentile == 1 & data_icp == 1
local note = string(`r(rho)', "%6.3f")
local note_n = "{it: n = `r(N)'}"
local note = "{it:r = `note'}"
twoway ///
	scatter FES YR20211101000 if Percentile == 1 & data_icp == 1 & incomelevel == "LIC", mcolor(cranberry*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES YR20211101000 if Percentile == 1 & data_icp == 1 & incomelevel == "LMIC", mcolor(midblue*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES YR20211101000 if Percentile == 1 & data_icp == 1 & incomelevel == "UMIC", mcolor(forest_green*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES YR20211101000 if Percentile == 1 & data_icp == 1 & incomelevel == "HIC", mcolor(orange*0.7) msize(tiny) msymbol(circle)  || ///
	qfitci FES YR20211101000 if Percentile == 1 & data_icp == 1, lcolor(black) fcolor(black*0.3%20) astyle(background) || ///
	,  xscale(range(0 100)) yscale(range(0 1)) xlabel(0(50)350, format(%9.0gc)) ylabel(0(20)100, format(%9.0gc) angle(0)) ///
	ytitle("Food Expenditure Share Q1", size(7pt)) xtitle("Food and non-alc. beverages", size(7pt)) title("") ///
	note("`note'" "`note_n'", size(6pt) ring(0) position(2)) ///
	subtitle("{bf:a}", size(8pt) position(11) span) ///
	ylab(,labsize(7pt)) xlab(,labsize(7pt)) ///
	scheme(cleanplots) graphregion(color(white)) legend(off) name(g1, replace) nodraw
	
// Alcoholic beverages, tobacco and narcotics
pwcorr FES YR20211102000 if Percentile == 1 & data_icp == 1
local note = string(`r(rho)', "%6.3f")
local note_n = "{it: n = `r(N)'}"
local note = "{it:r = `note'}"
twoway ///
	scatter FES YR20211102000 if Percentile == 1 & data_icp == 1 & incomelevel == "LIC", mcolor(cranberry*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES YR20211102000 if Percentile == 1 & data_icp == 1 & incomelevel == "LMIC", mcolor(midblue*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES YR20211102000 if Percentile == 1 & data_icp == 1 & incomelevel == "UMIC", mcolor(forest_green*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES YR20211102000 if Percentile == 1 & data_icp == 1 & incomelevel == "HIC", mcolor(orange*0.7) msize(tiny) msymbol(circle)  || ///
	qfitci FES YR20211102000 if Percentile == 1 & data_icp == 1, lcolor(black) fcolor(black*0.3%20) astyle(background) || ///
	,  xscale(range(0 100)) yscale(range(0 1)) xlabel(0(50)350, format(%9.0gc)) ylabel(0(20)100, format(%9.0gc) angle(0)) ///
	ytitle("Food Expenditure Share Q1", size(7pt)) xtitle("Alcohol, tobacco, narcotics", size(7pt)) title("") ///
	note("`note'" "`note_n'", size(6pt) ring(0) position(2)) ///
	subtitle("{bf:b}", size(8pt) position(11) span) ///
	ylab(,labsize(7pt)) xlab(,labsize(7pt)) ///
	scheme(cleanplots) graphregion(color(white)) legend(off) name(g2, replace) nodraw


// Clothing and footwear
pwcorr FES YR20211103000 if Percentile == 1 & data_icp == 1
local note = string(`r(rho)', "%6.3f")
local note_n = "{it: n = `r(N)'}"
local note = "{it:r = `note'}"
twoway ///
	scatter FES YR20211103000 if Percentile == 1 & data_icp == 1 & incomelevel == "LIC", mcolor(cranberry*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES YR20211103000 if Percentile == 1 & data_icp == 1 & incomelevel == "LMIC", mcolor(midblue*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES YR20211103000 if Percentile == 1 & data_icp == 1 & incomelevel == "UMIC", mcolor(forest_green*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES YR20211103000 if Percentile == 1 & data_icp == 1 & incomelevel == "HIC", mcolor(orange*0.7) msize(tiny) msymbol(circle)  || ///
	qfitci FES YR20211103000 if Percentile == 1 & data_icp == 1, lcolor(black) fcolor(black*0.3%20) astyle(background) || ///
	,  xscale(range(0.5 5)) yscale(range(0 1)) xlabel(0(50)350, format(%9.0gc)) ylabel(0(20)100, format(%9.0gc) angle(0)) ///
	ytitle("Food Expenditure Share Q1", size(7pt)) xtitle("Clothing and footwear", size(7pt)) title("") ///
	note("`note'" "`note_n'", size(6pt) ring(0) position(2)) ///
	subtitle("{bf:c}", size(8pt) position(11) span) ///
	ylab(,labsize(7pt)) xlab(,labsize(7pt)) ///
	scheme(cleanplots) graphregion(color(white)) legend(off) name(g3, replace) nodraw

// Furnishings, household equipment and routine household maintenance
pwcorr FES YR20211105000 if Percentile == 1 & data_icp == 1
local note = string(`r(rho)', "%6.3f")
local note_n = "{it: n = `r(N)'}"
local note = "{it:r = `note'}"
twoway ///
	scatter FES YR20211105000 if Percentile == 1 & data_icp == 1 & incomelevel == "LIC", mcolor(cranberry*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES YR20211105000 if Percentile == 1 & data_icp == 1 & incomelevel == "LMIC", mcolor(midblue*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES YR20211105000 if Percentile == 1 & data_icp == 1 & incomelevel == "UMIC", mcolor(forest_green*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES YR20211105000 if Percentile == 1 & data_icp == 1 & incomelevel == "HIC", mcolor(orange*0.7) msize(tiny) msymbol(circle)  || ///
	qfitci FES YR20211105000 if Percentile == 1 & data_icp == 1, lcolor(black) fcolor(black*0.3%20) astyle(background) || ///
	,  xscale(range(7 12)) yscale(range(0 1)) xlabel(0(50)350, format(%9.0gc)) ylabel(0(20)100, format(%9.0gc) angle(0)) ///
	ytitle("Food Expenditure Share Q1", size(7pt)) xtitle("Furnishings and household equipment", size(7pt)) title("") ///
	note("`note'" "`note_n'", size(6pt) ring(0) position(2)) ///
	subtitle("{bf:d}", size(8pt) position(11) span) ///
	ylab(,labsize(7pt)) xlab(,labsize(7pt)) ///
	scheme(cleanplots) graphregion(color(white)) legend(off) name(g4, replace) nodraw
	
// Transport
pwcorr FES YR20211107000 if Percentile == 1 & data_icp == 1
local note = string(`r(rho)', "%6.3f")
local note_n = "{it: n = `r(N)'}"
local note = "{it:r = `note'}"
twoway ///
	scatter FES YR20211107000 if Percentile == 1 & data_icp == 1 & incomelevel == "LIC", mcolor(cranberry*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES YR20211107000 if Percentile == 1 & data_icp == 1 & incomelevel == "LMIC", mcolor(midblue*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES YR20211107000 if Percentile == 1 & data_icp == 1 & incomelevel == "UMIC", mcolor(forest_green*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES YR20211107000 if Percentile == 1 & data_icp == 1 & incomelevel == "HIC", mcolor(orange*0.7) msize(tiny) msymbol(circle)  || ///
	qfitci FES YR20211107000 if Percentile == 1 & data_icp == 1, lcolor(black) fcolor(black*0.3%20) astyle(background) || ///
	,  xscale(range(2 7)) yscale(range(0 1)) xlabel(0(50)350, format(%9.0gc)) ylabel(0(20)100, format(%9.0gc) angle(0)) ///
	ytitle("Food Expenditure Share Q1", size(7pt)) xtitle("Transport", size(7pt)) title("") ///
	note("`note'" "`note_n'", size(6pt) ring(0) position(2)) ///
	subtitle("{bf:e}", size(8pt) position(11) span) ///
	ylab(,labsize(7pt)) xlab(,labsize(7pt)) ///
	scheme(cleanplots) graphregion(color(white)) legend(off) name(g5, replace) nodraw
	
// Communication
pwcorr FES YR20211108000 if Percentile == 1 & data_icp == 1
local note = string(`r(rho)', "%6.3f")
local note_n = "{it: n = `r(N)'}"
local note = "{it:r = `note'}"
twoway ///
	scatter FES YR20211108000 if Percentile == 1 & data_icp == 1 & incomelevel == "LIC", mcolor(cranberry*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES YR20211108000 if Percentile == 1 & data_icp == 1 & incomelevel == "LMIC", mcolor(midblue*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES YR20211108000 if Percentile == 1 & data_icp == 1 & incomelevel == "UMIC", mcolor(forest_green*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES YR20211108000 if Percentile == 1 & data_icp == 1 & incomelevel == "HIC", mcolor(orange*0.7) msize(tiny) msymbol(circle)  || ///
	qfitci FES YR20211108000 if Percentile == 1 & data_icp == 1, lcolor(black) fcolor(black*0.3%20) astyle(background) || ///
	,  xscale(range(0 3)) yscale(range(0 1)) xlabel(0(50)350, format(%9.0gc)) ylabel(0(20)100, format(%9.0gc) angle(0)) ///
	ytitle("Food Expenditure Share Q1", size(7pt)) xtitle("Communication", size(7pt)) title("") ///
	note("`note'" "`note_n'", size(6pt) ring(0) position(2)) ///
	subtitle("{bf:f}", size(8pt) position(11) span) ///
	ylab(,labsize(7pt)) xlab(,labsize(7pt)) ///
	scheme(cleanplots) graphregion(color(white)) legend(off) name(g6, replace) nodraw

// Housing and utilities
pwcorr FES YR20219060000 if Percentile == 1 & data_icp == 1
local note = string(`r(rho)', "%6.3f")
local note_n = "{it: n = `r(N)'}"
local note = "{it:r = `note'}"
twoway ///
	scatter FES YR20219060000 if Percentile == 1 & data_icp == 1 & incomelevel == "LIC", mcolor(cranberry*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES YR20219060000 if Percentile == 1 & data_icp == 1 & incomelevel == "LMIC", mcolor(midblue*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES YR20219060000 if Percentile == 1 & data_icp == 1 & incomelevel == "UMIC", mcolor(forest_green*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES YR20219060000 if Percentile == 1 & data_icp == 1 & incomelevel == "HIC", mcolor(orange*0.7) msize(tiny) msymbol(circle)  || ///
	qfitci FES YR20219060000 if Percentile == 1 & data_icp == 1, lcolor(black) fcolor(black*0.3%20) astyle(background) || ///
	,  xscale(range(0 100)) yscale(range(0 1)) xlabel(0(50)350, format(%9.0gc)) ylabel(0(20)100, format(%9.0gc) angle(0)) ///
	ytitle("Food Expenditure Share Q1", size(7pt)) xtitle("Housing and utilities", size(7pt)) title("") ///
	note("`note'" "`note_n'", size(6pt) ring(0) position(2)) ///
	subtitle("{bf:g}", size(8pt) position(11) span) ///
	ylab(,labsize(7pt)) xlab(,labsize(7pt)) ///
	scheme(cleanplots) graphregion(color(white)) legend(off) name(g7, replace) nodraw
		
// Health
pwcorr FES YR20219080000 if Percentile == 1 & data_undernourish == 1 
local note = string(`r(rho)', "%6.3f")
local note_n = "{it: n = `r(N)'}"
local note = "{it:r = `note'}"
twoway ///
	scatter FES YR20219080000 if Percentile == 1 & data_icp == 1 & incomelevel == "LIC", mcolor(cranberry*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES YR20219080000 if Percentile == 1 & data_icp == 1 & incomelevel == "LMIC", mcolor(midblue*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES YR20219080000 if Percentile == 1 & data_icp == 1 & incomelevel == "UMIC", mcolor(forest_green*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES YR20219080000 if Percentile == 1 & data_icp == 1 & incomelevel == "HIC", mcolor(orange*0.7) msize(tiny) msymbol(circle)  || ///
	qfitci FES YR20219080000 if Percentile == 1 & data_icp == 1, lcolor(black) fcolor(black*0.3%20) astyle(background) || ///
	,  xscale(range(0 60)) yscale(range(0 1)) xlabel(0(50)350, format(%9.0gc)) ylabel(0(20)100, format(%9.0gc) angle(0)) ///
	ytitle("Food Expenditure Share Q1", size(7pt)) xtitle("Health", size(7pt)) title("") ///
	note("`note'" "`note_n'", size(6pt) ring(0) position(2)) ///
	subtitle("{bf:h}", size(8pt) position(11) span) ///
	ylab(,labsize(7pt)) xlab(,labsize(7pt)) ///
	scheme(cleanplots) graphregion(color(white)) legend(off) name(g8, replace) nodraw	

// Education
pwcorr FES YR20219120000 if Percentile == 1 & data_icp == 1 
local note = string(`r(rho)', "%6.3f")
local note_n = "{it: n = `r(N)'}"
local note = "{it:r = `note'}"
twoway ///
	scatter FES YR20219120000 if Percentile == 1 & data_icp == 1 & incomelevel == "LIC", mcolor(cranberry*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES YR20219120000 if Percentile == 1 & data_icp == 1 & incomelevel == "LMIC", mcolor(midblue*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES YR20219120000 if Percentile == 1 & data_icp == 1 & incomelevel == "UMIC", mcolor(forest_green*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES YR20219120000 if Percentile == 1 & data_icp == 1 & incomelevel == "HIC", mcolor(orange*0.7) msize(tiny) msymbol(circle)  || ///
	qfitci FES YR20219120000 if Percentile == 1 & data_icp == 1, lcolor(black) fcolor(black*0.3%20) astyle(background) || ///
	,  xscale(range(0 60)) yscale(range(0 1)) xlabel(0(50)350, format(%9.0gc)) ylabel(0(20)100, format(%9.0gc) angle(0)) ///
	ytitle("Food Expenditure Share Q1", size(7pt)) xtitle("Education", size(7pt)) title("") ///
	note("`note'" "`note_n'", size(6pt) ring(0) position(2)) ///
	subtitle("{bf:i}", size(8pt) position(11) span) ///
	ylab(,labsize(7pt)) xlab(,labsize(7pt)) ///
	scheme(cleanplots) graphregion(color(white)) legend(off) name(g9, replace) nodraw
	
graph combine g1 g2 g3 g4 g5 g6 g7 g8 g9, graphregion(color(white)) ysize(13cm) xsize(18cm) cols(3) imargin(tiny)
graph export "${workdir}/graphs/FigureS1.png", replace 
graph export "${workdir}/graphs/FigureS1.pdf", replace 

********************************************************************************
* Figure 1c
********************************************************************************
eststo m1: reg FES YR20211101000 YR20211102000 YR20211103000 YR20211105000 YR20211107000 YR20211108000 YR20219060000 YR20219080000 YR20219120000  consexp_pc_d_ln if Percentile == 1 & data_icp == 1 
eststo m2: reg FES YR20211101000 YR20211102000 YR20211103000 YR20211105000 YR20211107000 YR20211108000 YR20219060000 YR20219080000 YR20219120000  consexp_pc_d_ln if Percentile == 3 & data_icp == 1 
eststo m3: reg FES YR20211101000 YR20211102000 YR20211103000 YR20211105000 YR20211107000 YR20211108000 YR20219060000 YR20219080000 YR20219120000  consexp_pc_d_ln if Percentile == 5 & data_icp == 1

graph set window fontface "Helvetica"
coefplot ///
    (m1, label("Q1 (bottom)") ///
        mcolor(cranberry) msymbol(O) ///
        ciopts(lcolor(cranberry))) ///
    (m2, label("Q3 (middle)") ///
        mcolor(midblue) msymbol(O) ///
        ciopts(lcolor(midblue))) ///
    (m3, label("Q5 (top)") ///
        mcolor(forest_green) msymbol(O) ///
        ciopts(lcolor(forest_green))) ///
    , drop(consexp_pc_d_ln _cons) ///
    xline(0, lpattern(dash) lcolor(gs8)) ///
    mlabel(cond(@pval<.01, "***", ///
           cond(@pval<.05, "**", ///
           cond(@pval<.1, "*" , "")))) ///
    mlabposition(12) mlabsize(5pt) mlabcolor(black)  mlabgap(0)  ///
    ciopts(recast(rcap) lwidth(medthin)) ///
    ylab(none, labsize(7pt)) xlab(, labsize(7pt)) xscale(range(-0.6 0.2)) ///
    xtitle("Association with food expenditure shares", size(6pt)) ///
    ytitle("") yscale(off) ///
    legend(ring(0) position(12) rows(3) size(5pt) nobox bcolor(white) lstyle(none) ) ///
    graphregion(color(white)) ///
    plotregion(color(white)) ///
	xsize(8cm) ysize(8cm)  ///
	subtitle("{bf:c}", size(10pt) position(11) span) ///
	text(1 -0.54 "Food &" "non-alc. bev.", size(7pt) justification(left) placement(3)) ///
	text(2 -0.54 "Alcohol, tobacco," "narcotics", size(7pt) justification(left) placement(3)) ///
	text(3 -0.54 "Clothing &" "footwear", size(7pt) justification(left) placement(3)) ///
	text(4 -0.54 "Furnishings &" "household equipment", size(7pt) justification(left) placement(3)) ///
	text(5 -0.54 "Transport", size(7pt) justification(left) placement(3)) ///
	text(6 -0.54 "Communication", size(7pt) justification(left) placement(3)) ///
	text(7 -0.54 "Housing & utilities", size(7pt) justification(left) placement(3)) ///
	text(8 -0.54 "Health", size(7pt) justification(left) placement(3)) ///
	text(9 -0.54 "Education", size(7pt) justification(left) placement(3)) ///
	text(5 -0.59 "{bf:Price level indices in 2021}", orientation(vertical) size(7pt) )  ///
	scheme(cleanplots)

graph export "${workdir}/graphs/Figure1c.png", replace
graph export "${workdir}/graphs/Figure1c.pdf", replace


********************************************************************************
* Figure S2: Replacing Food price estimates with other price indices
********************************************************************************

* Standardization
qui reg FES YR20211101000 YR20211102000 YR20211103000 YR20211105000 YR20211107000 YR20211108000 YR20219060000 YR20219080000 YR20219120000  consexp_pc_d_ln if data_icp == 1 
gen esample = e(sample)

foreach var in YR20211101000 YR20211102000 YR20211103000 ///
               YR20211105000 YR20211107000 YR20211108000 ///
               YR20219060000 YR20219080000 YR20219120000 ///
               CoHD CoCA CoHD_ss {
    egen z_`var' = std(`var') if esample
}

eststo m1_1: reg FES z_YR20211101000 z_YR20211102000 z_YR20211103000 z_YR20211105000 z_YR20211107000 z_YR20211108000 z_YR20219060000 z_YR20219080000 z_YR20219120000  consexp_pc_d_ln if Percentile == 1 & data_icp == 1 
eststo m1_2: reg FES z_CoHD z_YR20211102000 z_YR20211103000 z_YR20211105000 z_YR20211107000 z_YR20211108000 z_YR20219060000 z_YR20219080000 z_YR20219120000  consexp_pc_d_ln if Percentile == 1 & data_icp == 1 
eststo m1_3: reg FES z_CoCA z_YR20211102000 z_YR20211103000 z_YR20211105000 z_YR20211107000 z_YR20211108000 z_YR20219060000 z_YR20219080000 z_YR20219120000  consexp_pc_d_ln if Percentile == 1 & data_icp == 1 
eststo m1_4: reg FES z_CoHD_ss z_YR20211102000 z_YR20211103000 z_YR20211105000 z_YR20211107000 z_YR20211108000 z_YR20219060000 z_YR20219080000 z_YR20219120000  consexp_pc_d_ln if Percentile == 1 & data_icp == 1 

eststo m2_1: reg FES z_YR20211101000 z_YR20211102000 z_YR20211103000 z_YR20211105000 z_YR20211107000 z_YR20211108000 z_YR20219060000 z_YR20219080000 z_YR20219120000  consexp_pc_d_ln if Percentile == 3 & data_icp == 1 
eststo m2_2: reg FES z_CoHD z_YR20211102000 z_YR20211103000 z_YR20211105000 z_YR20211107000 z_YR20211108000 z_YR20219060000 z_YR20219080000 z_YR20219120000  consexp_pc_d_ln if Percentile == 3 & data_icp == 1 
eststo m2_3: reg FES z_CoCA z_YR20211102000 z_YR20211103000 z_YR20211105000 z_YR20211107000 z_YR20211108000 z_YR20219060000 z_YR20219080000 z_YR20219120000  consexp_pc_d_ln if Percentile == 3 & data_icp == 1 
eststo m2_4: reg FES z_CoHD_ss z_YR20211102000 z_YR20211103000 z_YR20211105000 z_YR20211107000 z_YR20211108000 z_YR20219060000 z_YR20219080000 z_YR20219120000  consexp_pc_d_ln if Percentile == 3 & data_icp == 1 

eststo m3_1: reg FES z_YR20211101000 z_YR20211102000 z_YR20211103000 z_YR20211105000 z_YR20211107000 z_YR20211108000 z_YR20219060000 z_YR20219080000 z_YR20219120000  consexp_pc_d_ln if Percentile == 5 & data_icp == 1 
eststo m3_2: reg FES z_CoHD YR20211102000 z_YR20211102000 z_YR20211103000 z_YR20211105000 z_YR20211107000 z_YR20211108000 z_YR20219060000 z_YR20219080000 z_YR20219120000  consexp_pc_d_ln if Percentile == 5 & data_icp == 1 
eststo m3_3: reg FES z_CoCA YR20211102000 z_YR20211102000 z_YR20211103000 z_YR20211105000 z_YR20211107000 z_YR20211108000 z_YR20219060000 z_YR20219080000 z_YR20219120000 consexp_pc_d_ln if Percentile == 5 & data_icp == 1 
eststo m3_4: reg FES z_CoHD_ss YR20211102000 z_YR20211102000 z_YR20211103000 z_YR20211105000 z_YR20211107000 z_YR20211108000 z_YR20219060000 z_YR20219080000 z_YR20219120000  consexp_pc_d_ln if Percentile == 5 & data_icp == 1 

graph set window fontface "Helvetica"
coefplot ///
    (m1_1 m1_2 m1_3 m1_4, label("Q1 (bottom)") ///
        mcolor(cranberry) msymbol(O) ///
        ciopts(lcolor(cranberry))) ///
    (m2_1 m2_2 m2_3 m2_4, label("Q3 (middle)") ///
        mcolor(midblue) msymbol(O) ///
        ciopts(lcolor(midblue))) ///
    (m3_1 m3_2 m3_3 m3_4, label("Q5 (top)") ///
        mcolor(forest_green) msymbol(O) ///
        ciopts(lcolor(forest_green))) ///
    , keep(z_YR20211101000 z_CoHD z_CoCA z_CoHD_ss) ///
    xline(0, lpattern(dash) lcolor(gs8)) ///
    mlabel(cond(@pval<.01, "***", ///
           cond(@pval<.05, "**", ///
           cond(@pval<.1,  "*" , "")))) ///
    mlabposition(12) mlabsize(5pt) mlabcolor(black)  mlabgap(0)  ///
    ciopts(recast(rcap) lwidth(medthin)) ///
    ylab(none, labsize(7pt)) xlab(, labsize(7pt)) xscale(range(-0.6 0.2)) ///
    xtitle("Association with food expenditure shares", size(6pt)) ///
    ytitle("") yscale(off) ///
    legend(ring(1) position(3) rows(3) size(5pt) nobox bcolor(white) lstyle(none) ) ///
    graphregion(color(white) margin(l+20)) ///
    plotregion(color(white) margin(l+20)) ///
	xsize(10cm) ysize(8cm)  ///
	text(1 -7 "CPI Food and non-alc." "beverages index", size(7pt) justification(left) placement(3)) ///
	text(2 -7 "Cost of a" "healthy diet", size(7pt) justification(left) placement(3)) ///
	text(3 -7 "Cost of an" "energy sufficient diet", size(7pt) justification(left) placement(3)) ///
	text(4 -7 "Cost of" "starchy staples", size(7pt) justification(left) placement(3)) ///
	text(2.5 -8 "{bf:Standardized price level indicators}", orientation(vertical) size(7pt) )  ///
	scheme(cleanplots)
		
graph export "${workdir}/graphs/FigureS2.png", replace
graph export "${workdir}/graphs/FigureS2.pdf", replace

	
********************************************************************************
* Figure S5
********************************************************************************
bysort countrycode year: egen FES_p1 = max(cond(Percentile==1, FES, .))
bysort countrycode year: egen FES_p5 = max(cond(Percentile==5, FES, .))
gen FES_gap = FES_p1 - FES_p5
drop FES_p1 FES_p5

* Create variables for which observations shall be used for each graph: WDI and PIP
	bysort countrycode: egen max_anyyear  =  ///
	max(cond(!missing(si_pov_gini), year, .))

	gen data_GINI = 1 if year == max_anyyear
	drop max_anyyear 


pwcorr FES_gap si_pov_gini if Percentile == 5 & data_GINI == 1
local note = round(`r(rho)',0.001)
local note_n = "{it: n = `r(N)'}"
local note = substr("`note'",1,4)
local note = "{it:r = 0`note'}"
twoway ///
	scatter FES_gap si_pov_gini if Percentile == 5 & data_GINI == 1 & incomelevel == "LIC", mcolor(cranberry*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES_gap si_pov_gini if Percentile == 5 & data_GINI == 1 & incomelevel == "LMIC", mcolor(midblue*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES_gap si_pov_gini if Percentile == 5 & data_GINI == 1 & incomelevel == "UMIC", mcolor(forest_green*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES_gap si_pov_gini if Percentile == 5 & data_GINI == 1 & incomelevel == "HIC", mcolor(orange*0.7) msize(tiny) msymbol(circle)  || ///
	qfitci FES_gap si_pov_gini if Percentile == 5 & data_GINI == 1, lcolor(black) fcolor(black*0.3%20) astyle(background) || ///
	,  xscale(range(20 65)) yscale(range(0 1)) xlabel(20(10)65, format(%9.0gc)) ylabel(0(10)50, format(%9.0gc) angle(0)) ///
	ytitle("FES Gap Q1-Q5", size(7pt)) xtitle("Gini index", size(7pt)) title("") ///
	note("`note'" "`note_n'", size(6pt) ring(0) position(4)) ///
	subtitle("{bf:i}", size(10pt) position(11) span) ///
	ylab(,labsize(7pt)) xlab(,labsize(7pt)) ///
	scheme(cleanplots) graphregion(color(white)) legend(off) name(g9, replace) nodraw
	
	
// FES1 & Extreme Poverty
pwcorr FES_gap headcount if Percentile == 5 & data_WDI_PIP == 1
local note = round(`r(rho)',0.001)
local note_n = "{it: n = `r(N)'}"
local note = substr("`note'",1,4)
local note = "{it:r = 0`note'}"
twoway ///
	scatter FES_gap headcount if Percentile == 5 & data_WDI_PIP == 1 & incomelevel == "LIC", mcolor(cranberry*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES_gap headcount if Percentile == 5 & data_WDI_PIP == 1 & incomelevel == "LMIC", mcolor(midblue*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES_gap headcount if Percentile == 5 & data_WDI_PIP == 1 & incomelevel == "UMIC", mcolor(forest_green*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES_gap headcount if Percentile == 5 & data_WDI_PIP == 1 & incomelevel == "HIC", mcolor(orange*0.7) msize(tiny) msymbol(circle)  || ///
	qfitci FES_gap headcount if Percentile == 5 & data_WDI_PIP == 1, lcolor(black) fcolor(black*0.3%20) astyle(background) || ///
	,  xscale(range(0 100)) yscale(range(0 1)) xlabel(0(20)100, format(%9.0gc)) ylabel(0(10)50, format(%9.0gc) angle(0)) ///
	ytitle("FES Gap Q1-Q5", size(7pt)) xtitle("Headcount ratio International Poverty Line (in %)", size(7pt)) title("") ///
	note("`note'" "`note_n'", size(6pt) ring(0) position(4)) ///
	subtitle("{bf:a}", size(10pt) position(11) span) ///
	ylab(,labsize(7pt)) xlab(,labsize(7pt)) ///
	scheme(cleanplots) graphregion(color(white)) legend(off) name(g1, replace) nodraw
	
// FES1 & Societal Poverty
pwcorr FES_gap spr if Percentile == 5 & data_WDI_PIP == 1
local note = round(`r(rho)',0.001)
local note_n = "{it: n = `r(N)'}"
local note = substr("`note'",1,4)
local note = "{it:r = 0`note'}"
twoway ///
	scatter FES_gap spr if Percentile == 5 & data_WDI_PIP == 1 & incomelevel == "LIC", mcolor(cranberry*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES_gap spr if Percentile == 5 & data_WDI_PIP == 1 & incomelevel == "LMIC", mcolor(midblue*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES_gap spr if Percentile == 5 & data_WDI_PIP == 1 & incomelevel == "UMIC", mcolor(forest_green*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES_gap spr if Percentile == 5 & data_WDI_PIP == 1 & incomelevel == "HIC", mcolor(orange*0.7) msize(tiny) msymbol(circle)  || ///
	qfitci FES_gap spr if Percentile == 5 & data_WDI_PIP == 1, lcolor(black) fcolor(black*0.3%20) astyle(background) || ///
	,  xscale(range(0 100)) yscale(range(0 1)) xlabel(0(20)100, format(%9.0gc)) ylabel(0(10)50, format(%9.0gc) angle(0)) ///
	ytitle("FES Gap Q1-Q5", size(7pt)) xtitle("Headcount ratio Societal Poverty Line (in %)", size(7pt)) title("") ///
	note("`note'" "`note_n'", size(6pt) ring(0) position(4)) ///
	subtitle("{bf:b}", size(10pt) position(11) span) ///
	ylab(,labsize(7pt)) xlab(,labsize(7pt)) ///
	scheme(cleanplots) graphregion(color(white)) legend(off) name(g2, replace) nodraw


// FES1 & Log. Average consumption expenditure
pwcorr FES_gap consexp_pc_d_ln if Percentile == 5 & data_WDI_PIP == 1
local note = string(`r(rho)', "%6.3f")
local note_n = "{it: n = `r(N)'}"
local note = "{it:r = `note'}"
twoway ///
	scatter FES_gap consexp_pc_d_ln if Percentile == 5 & data_WDI_PIP == 1 & incomelevel == "LIC", mcolor(cranberry*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES_gap consexp_pc_d_ln if Percentile == 5 & data_WDI_PIP == 1 & incomelevel == "LMIC", mcolor(midblue*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES_gap consexp_pc_d_ln if Percentile == 5 & data_WDI_PIP == 1 & incomelevel == "UMIC", mcolor(forest_green*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES_gap consexp_pc_d_ln if Percentile == 5 & data_WDI_PIP == 1 & incomelevel == "HIC", mcolor(orange*0.7) msize(tiny) msymbol(circle)  || ///
	qfitci FES_gap consexp_pc_d_ln if Percentile == 5 & data_WDI_PIP == 1, lcolor(black) fcolor(black*0.3%20) astyle(background) || ///
	,  xscale(range(0.5 5)) yscale(range(0 1)) xlabel(0(1)5, format(%9.0gc)) ylabel(0(10)50, format(%9.0gc) angle(0)) ///
	ytitle("FES Gap Q1-Q5", size(7pt)) xtitle("Log. Consumption Expenditure per capita per day", size(7pt)) title("") ///
	note("`note'" "`note_n'", size(6pt) ring(0) position(2)) ///
	subtitle("{bf:c}", size(10pt) position(11) span) ///
	ylab(,labsize(7pt)) xlab(,labsize(7pt)) ///
	scheme(cleanplots) graphregion(color(white)) legend(off) name(g3, replace) nodraw

// FES1 & Log. GDP per capita
pwcorr FES_gap ny_gdp_pcap_pp_kd_ln if Percentile == 5 & data_WDI_PIP == 1
local note = string(`r(rho)', "%6.3f")
local note_n = "{it: n = `r(N)'}"
local note = "{it:r = `note'}"
twoway ///
	scatter FES_gap ny_gdp_pcap_pp_kd_ln if Percentile == 5 & data_WDI_PIP == 1 & incomelevel == "LIC", mcolor(cranberry*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES_gap ny_gdp_pcap_pp_kd_ln if Percentile == 5 & data_WDI_PIP == 1 & incomelevel == "LMIC", mcolor(midblue*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES_gap ny_gdp_pcap_pp_kd_ln if Percentile == 5 & data_WDI_PIP == 1 & incomelevel == "UMIC", mcolor(forest_green*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES_gap ny_gdp_pcap_pp_kd_ln if Percentile == 5 & data_WDI_PIP == 1 & incomelevel == "HIC", mcolor(orange*0.7) msize(tiny) msymbol(circle)  || ///
	qfitci FES_gap ny_gdp_pcap_pp_kd_ln if Percentile == 5 & data_WDI_PIP == 1, lcolor(black) fcolor(black*0.3%20) astyle(background) || ///
	,  xscale(range(7 12)) yscale(range(0 1)) xlabel(7(1)12, format(%9.0gc)) ylabel(0(10)50, format(%9.0gc) angle(0)) ///
	ytitle("FES Gap Q1-Q5", size(7pt)) xtitle("Log. GDP per capita per day", size(7pt)) title("") ///
	note("`note'" "`note_n'", size(6pt) ring(0) position(2)) ///
	subtitle("{bf:d}", size(10pt) position(11) span) ///
	ylab(,labsize(7pt)) xlab(,labsize(7pt)) ///
	scheme(cleanplots) graphregion(color(white)) legend(off) name(g4, replace) nodraw
	
// CoHD
pwcorr FES_gap CoHD if Percentile == 5 & data_CoHD == 1
local note = round(`r(rho)',0.001)
local note_n = "{it: n = `r(N)'}"
local note = substr("`note'",1,4)
local note = "{it:r = 0`note'}"
twoway ///
	scatter FES_gap CoHD if Percentile == 5 & data_CoHD == 1 & incomelevel == "LIC", mcolor(cranberry*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES_gap CoHD if Percentile == 5 & data_CoHD == 1 & incomelevel == "LMIC", mcolor(midblue*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES_gap CoHD if Percentile == 5 & data_CoHD == 1 & incomelevel == "UMIC", mcolor(forest_green*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES_gap CoHD if Percentile == 5 & data_CoHD == 1 & incomelevel == "HIC", mcolor(orange*0.7) msize(tiny) msymbol(circle)  || ///
	qfitci FES_gap CoHD if Percentile == 5 & data_CoHD == 1, lcolor(black) fcolor(black*0.3%20) astyle(background) || ///
	,  xscale(range(2 7)) yscale(range(0 1)) xlabel(2(1)7, format(%9.0gc)) ylabel(0(10)50, format(%9.0gc) angle(0)) ///
	ytitle("FES Gap Q1-Q5", size(7pt)) xtitle("Cost of a healthy diet", size(7pt)) title("") ///
	note("`note'" "`note_n'", size(6pt) ring(0) position(2)) ///
	subtitle("{bf:e}", size(10pt) position(11) span) ///
	ylab(,labsize(7pt)) xlab(,labsize(7pt)) ///
	scheme(cleanplots) graphregion(color(white)) legend(off) name(g5, replace) nodraw
	
	
// Cost of an energy sufficient diet
pwcorr FES_gap CoCA if Percentile == 5 & data_CoCA == 1
local note = round(`r(rho)',0.001)
local note_n = "{it: n = `r(N)'}"
local note = substr("`note'",1,4)
local note = "{it:r = 0`note'}"
twoway ///
	scatter FES_gap CoCA if Percentile == 5 & data_CoCA == 1 & incomelevel == "LIC", mcolor(cranberry*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES_gap CoCA if Percentile == 5 & data_CoCA == 1 & incomelevel == "LMIC", mcolor(midblue*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES_gap CoCA if Percentile == 5 & data_CoCA == 1 & incomelevel == "UMIC", mcolor(forest_green*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES_gap CoCA if Percentile == 5 & data_CoCA == 1 & incomelevel == "HIC", mcolor(orange*0.7) msize(tiny) msymbol(circle)  || ///
	qfitci FES_gap CoCA if Percentile == 5 & data_CoCA == 1, lcolor(black) fcolor(black*0.3%20) astyle(background) || ///
	,  xscale(range(0 3)) yscale(range(0 1)) xlabel(0(0.5)3, format(%9.0gc)) ylabel(0(10)50, format(%9.0gc) angle(0)) ///
	ytitle("FES Gap Q1-Q5", size(7pt)) xtitle("Cost of an energy sufficient diet", size(7pt)) title("") ///
	note("`note'" "`note_n'", size(6pt) ring(0) position(2)) ///
	subtitle("{bf:f}", size(10pt) position(11) span) ///
	ylab(,labsize(7pt)) xlab(,labsize(7pt)) ///
	scheme(cleanplots) graphregion(color(white)) legend(off) name(g6, replace) nodraw
	
// Moderate or severe food insecurity
pwcorr FES_gap moderate_fies_perc_fao if Percentile == 5 & data_FIES == 1
local note = round(`r(rho)',0.001)
local note_n = "{it: n = `r(N)'}"
local note = substr("`note'",1,4)
local note = "{it:r = 0`note'}"
twoway ///
	scatter FES_gap moderate_fies_perc_fao if Percentile == 5 & data_FIES == 1 & incomelevel == "LIC", mcolor(cranberry*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES_gap moderate_fies_perc_fao if Percentile == 5 & data_FIES == 1 & incomelevel == "LMIC", mcolor(midblue*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES_gap moderate_fies_perc_fao if Percentile == 5 & data_FIES == 1 & incomelevel == "UMIC", mcolor(forest_green*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES_gap moderate_fies_perc_fao if Percentile == 5 & data_FIES == 1 & incomelevel == "HIC", mcolor(orange*0.7) msize(tiny) msymbol(circle)  || ///
	qfitci FES_gap moderate_fies_perc_fao if Percentile == 5 & data_FIES == 1, lcolor(black) fcolor(black*0.3%20) astyle(background) || ///
	,  xscale(range(0 100)) yscale(range(0 1)) xlabel(0(20)100, format(%9.0gc)) ylabel(0(10)50, format(%9.0gc) angle(0)) ///
	ytitle("FES Gap Q1-Q5", size(7pt)) xtitle("Moderate or severe food insecurity (in %)", size(7pt)) title("") ///
	note("`note'" "`note_n'", size(6pt) ring(0) position(4)) ///
	subtitle("{bf:g}", size(10pt) position(11) span) ///
	ylab(,labsize(7pt)) xlab(,labsize(7pt)) ///
	scheme(cleanplots) graphregion(color(white)) legend(off) name(g7, replace) nodraw
	
// Undernourishment
pwcorr FES_gap undernourished_perc_fao if Percentile == 5 & data_undernourish == 1 
local note = round(`r(rho)',0.001)
local note_n = "{it: n = `r(N)'}"
local note = substr("`note'",1,4)
local note = "{it:r = 0`note'}"
twoway ///
	scatter FES_gap undernourished_perc_fao if Percentile == 5 & data_undernourish == 1 & incomelevel == "LIC", mcolor(cranberry*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES_gap undernourished_perc_fao if Percentile == 5 & data_undernourish == 1 & incomelevel == "LMIC", mcolor(midblue*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES_gap undernourished_perc_fao if Percentile == 5 & data_undernourish == 1 & incomelevel == "UMIC", mcolor(forest_green*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES_gap undernourished_perc_fao if Percentile == 5 & data_undernourish == 1 & incomelevel == "HIC", mcolor(orange*0.7) msize(tiny) msymbol(circle)  || ///
	qfitci FES_gap undernourished_perc_fao if Percentile == 5 & data_undernourish == 1, lcolor(black) fcolor(black*0.3%20) astyle(background) || ///
	,  xscale(range(0 60)) yscale(range(0 1)) xlabel(0(10)60, format(%9.0gc)) ylabel(0(10)50, format(%9.0gc) angle(0)) ///
	ytitle("FES Gap Q1-Q5", size(7pt)) xtitle("Undernourishment (in %)", size(7pt)) title("") ///
	note("`note'" "`note_n'", size(6pt) ring(0) position(4)) ///
	subtitle("{bf:h}", size(10pt) position(11) span) ///
	ylab(,labsize(7pt)) xlab(,labsize(7pt)) ///
	scheme(cleanplots) graphregion(color(white)) legend(off) name(g8, replace) nodraw	
	
graph combine g1 g2 g3 g4 g5 g6 g7 g8 g9, graphregion(color(white)) ysize(13cm) xsize(18cm) cols(3) imargin(tiny)
graph export "${workdir}/graphs/FigureS5.png", replace
graph export "${workdir}/graphs/FigureS5.pdf", replace
		
	
	
	