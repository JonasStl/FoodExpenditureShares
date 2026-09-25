********************************************************************************
*							Analysis: Cross-section - Correlations				*
********************************************************************************

********************************************************************************
* 		Actual correlation plot: Food and poverty related indicators 			*
********************************************************************************
use "${datadir}/FESdatabase_quintiles_analysis.dta", clear

pwcorr FES headcount if Percentile == 1 & data_PIP == 1
local note = round(`r(rho)',0.001)
local note_n = "{it: n = `r(N)'}"
local note = substr("`note'",1,4)
local note = "{it:r = 0`note'}"
twoway ///
	scatter FES headcount if Percentile == 1 & data_PIP == 1 & incomelevel == "LIC", mcolor(cranberry*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES headcount if Percentile == 1 & data_PIP == 1 & incomelevel == "LMIC", mcolor(midblue*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES headcount if Percentile == 1 & data_PIP == 1 & incomelevel == "UMIC", mcolor(forest_green*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES headcount if Percentile == 1 & data_PIP == 1 & incomelevel == "HIC", mcolor(orange*0.7) msize(tiny) msymbol(circle)  || ///
	qfitci FES headcount if Percentile == 1 & data_PIP == 1, lcolor(black) fcolor(black*0.3%20) astyle(background) || ///
	,  xscale(range(0 100)) yscale(range(0 1)) xlabel(0(20)100, format(%9.0gc)) ylabel(0(20)100, format(%9.0gc) angle(0)) ///
	ytitle("Food Expenditure Share Q1", size(7pt)) xtitle("Headcount ratio International Poverty Line (in %)", size(7pt)) title("") ///
	note("`note'" "`note_n'", size(6pt) ring(0) position(4)) ///
	subtitle("{bf:a}", size(10pt) position(11) span) ///
	ylab(,labsize(7pt)) xlab(,labsize(7pt)) ///
	scheme(cleanplots) graphregion(color(white)) legend(off) name(g1, replace)

pwcorr FES spr if Percentile == 1 & data_PIP == 1
local note = round(`r(rho)',0.001)
local note_n = "{it: n = `r(N)'}"
local note = substr("`note'",1,4)
local note = "{it:r = 0`note'}"
twoway ///
	scatter FES spr if Percentile == 1 & data_PIP == 1 & incomelevel == "LIC", mcolor(cranberry*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES spr if Percentile == 1 & data_PIP == 1 & incomelevel == "LMIC", mcolor(midblue*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES spr if Percentile == 1 & data_PIP == 1 & incomelevel == "UMIC", mcolor(forest_green*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES spr if Percentile == 1 & data_PIP == 1 & incomelevel == "HIC", mcolor(orange*0.7) msize(tiny) msymbol(circle)  || ///
	qfitci FES spr if Percentile == 1 & data_PIP == 1, lcolor(black) fcolor(black*0.3%20) astyle(background) || ///
	,  xscale(range(0 100)) yscale(range(0 1)) xlabel(0(20)100, format(%9.0gc)) ylabel(0(20)100, format(%9.0gc) angle(0)) ///
	ytitle("Food Expenditure Share Q1", size(7pt)) xtitle("Headcount ratio Societal Poverty Line (in %)", size(7pt)) title("") ///
	note("`note'" "`note_n'", size(6pt) ring(0) position(4)) ///
	subtitle("{bf:b}", size(10pt) position(11) span) ///
	ylab(,labsize(7pt)) xlab(,labsize(7pt)) ///
	scheme(cleanplots) graphregion(color(white)) legend(off) name(g2, replace) nodraw

pwcorr FES consexp_pc_d_ln if Percentile == 1 & data_PIP == 1
local note = string(`r(rho)', "%6.3f")
local note_n = "{it: n = `r(N)'}"
local note = "{it:r = `note'}"
twoway ///
	scatter FES consexp_pc_d_ln if Percentile == 1 & data_PIP == 1 & incomelevel == "LIC", mcolor(cranberry*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES consexp_pc_d_ln if Percentile == 1 & data_PIP == 1 & incomelevel == "LMIC", mcolor(midblue*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES consexp_pc_d_ln if Percentile == 1 & data_PIP == 1 & incomelevel == "UMIC", mcolor(forest_green*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES consexp_pc_d_ln if Percentile == 1 & data_PIP == 1 & incomelevel == "HIC", mcolor(orange*0.7) msize(tiny) msymbol(circle)  || ///
	qfitci FES consexp_pc_d_ln if Percentile == 1 & data_PIP == 1, lcolor(black) fcolor(black*0.3%20) astyle(background) || ///
	,  xscale(range(0.5 5)) yscale(range(0 1)) xlabel(0(1)5, format(%9.0gc)) ylabel(0(20)100, format(%9.0gc) angle(0)) ///
	ytitle("Food Expenditure Share Q1", size(7pt)) xtitle("Log. Consumption Expenditure per capita per day", size(7pt)) title("") ///
	note("`note'" "`note_n'", size(6pt) ring(0) position(2)) ///
	subtitle("{bf:c}", size(10pt) position(11) span) ///
	ylab(,labsize(7pt)) xlab(,labsize(7pt)) ///
	scheme(cleanplots) graphregion(color(white)) legend(off) name(g3, replace) nodraw

pwcorr FES ny_gdp_pcap_pp_kd_ln if Percentile == 1 & data_WDI == 1
local note = string(`r(rho)', "%6.3f")
local note_n = "{it: n = `r(N)'}"
local note = "{it:r = `note'}"
twoway ///
	scatter FES ny_gdp_pcap_pp_kd_ln if Percentile == 1 & data_WDI == 1 & incomelevel == "LIC", mcolor(cranberry*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES ny_gdp_pcap_pp_kd_ln if Percentile == 1 & data_WDI == 1 & incomelevel == "LMIC", mcolor(midblue*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES ny_gdp_pcap_pp_kd_ln if Percentile == 1 & data_WDI == 1 & incomelevel == "UMIC", mcolor(forest_green*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES ny_gdp_pcap_pp_kd_ln if Percentile == 1 & data_WDI == 1 & incomelevel == "HIC", mcolor(orange*0.7) msize(tiny) msymbol(circle)  || ///
	qfitci FES ny_gdp_pcap_pp_kd_ln if Percentile == 1 & data_WDI == 1, lcolor(black) fcolor(black*0.3%20) astyle(background) || ///
	,  xscale(range(7 12)) yscale(range(0 1)) xlabel(7(1)12, format(%9.0gc)) ylabel(0(20)100, format(%9.0gc) angle(0)) ///
	ytitle("Food Expenditure Share Q1", size(7pt)) xtitle("Log. GDP per capita per day", size(7pt)) title("") ///
	note("`note'" "`note_n'", size(6pt) ring(0) position(2)) ///
	subtitle("{bf:d}", size(10pt) position(11) span) ///
	ylab(,labsize(7pt)) xlab(,labsize(7pt)) ///
	scheme(cleanplots) graphregion(color(white)) legend(off) name(g4, replace) nodraw

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

tempfile corrwide
tempname posth

postfile `posth' str8 series ///
    double quintile intl_poverty societal_poverty log_consexp log_gdppc ///
           cost_healthy_diet cost_energy_diet food_insecurity undernourishment ///
    using `corrwide', replace

forvalues q = 1/5 {

    quietly pwcorr FES headcount if Percentile==`q' & data_PIP==1
    local r1 = abs(r(rho))

    quietly pwcorr FES spr if Percentile==`q' & data_PIP==1
    local r2 = abs(r(rho))

    quietly pwcorr FES consexp_pc_d_ln if Percentile==`q' & data_PIP==1
    local r3 = abs(r(rho))

    quietly pwcorr FES ny_gdp_pcap_pp_kd_ln if Percentile==`q' & data_WDI==1
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

foreach g in 1 2 3 4 {
    local glab = cond(`g'==1,"HIC", cond(`g'==2,"LIC", cond(`g'==3,"LMIC","UMIC")))

    quietly pwcorr FES headcount if Percentile==1 & data_PIP==1 & incomelevel_enc==`g'
    local r1 = abs(r(rho))

    quietly pwcorr FES spr if Percentile==1 & data_PIP==1 & incomelevel_enc==`g'
    local r2 = abs(r(rho))

    quietly pwcorr FES consexp_pc_d_ln if Percentile==1 & data_PIP==1 & incomelevel_enc==`g'
    local r3 = abs(r(rho))

    quietly pwcorr FES ny_gdp_pcap_pp_kd_ln if Percentile==1 & data_WDI==1 & incomelevel_enc==`g'
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
graph export "${graphdir}/Figure3.png", replace
graph export "${graphdir}/Figure3.pdf", replace

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
    bar(1, color("215 25 28")) ///
    bar(2, color("253 174 97")) ///
    bar(3, color("255 255 191")) ///
    bar(4, color("171 217 233")) ///
    bar(5, color("44 123 182")) ///
    bargap(15) ///
    legend(rows(1) ring(0) position(1) size(6pt) symysize(2) symxsize(2)) ///
    ytitle("Pearson Correlation Coefficient", size(7pt)) ///
	ylab(0(0.1)0.8, labsize(6pt))   ///
    scheme(cleanplots)
graph export "${graphdir}/FigureS4.png", replace
graph export "${graphdir}/FigureS4.pdf", replace

