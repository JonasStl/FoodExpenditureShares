********************************************************************************
*							Analysis: Cross-section - Inequality				*
********************************************************************************

use "${datadir}/FESdatabase_quintiles_analysis.dta", clear

bysort countrycode year: egen FES_p1 = max(cond(Percentile==1, FES, .))
bysort countrycode year: egen FES_p5 = max(cond(Percentile==5, FES, .))
gen FES_gap = FES_p1 - FES_p5
drop FES_p1 FES_p5

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

pwcorr FES_gap headcount if Percentile == 5 & data_PIP == 1
local note = round(`r(rho)',0.001)
local note_n = "{it: n = `r(N)'}"
local note = substr("`note'",1,4)
local note = "{it:r = 0`note'}"
twoway ///
	scatter FES_gap headcount if Percentile == 5 & data_PIP == 1 & incomelevel == "LIC", mcolor(cranberry*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES_gap headcount if Percentile == 5 & data_PIP == 1 & incomelevel == "LMIC", mcolor(midblue*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES_gap headcount if Percentile == 5 & data_PIP == 1 & incomelevel == "UMIC", mcolor(forest_green*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES_gap headcount if Percentile == 5 & data_PIP == 1 & incomelevel == "HIC", mcolor(orange*0.7) msize(tiny) msymbol(circle)  || ///
	qfitci FES_gap headcount if Percentile == 5 & data_PIP == 1, lcolor(black) fcolor(black*0.3%20) astyle(background) || ///
	,  xscale(range(0 100)) yscale(range(0 1)) xlabel(0(20)100, format(%9.0gc)) ylabel(0(10)50, format(%9.0gc) angle(0)) ///
	ytitle("FES Gap Q1-Q5", size(7pt)) xtitle("Headcount ratio International Poverty Line (in %)", size(7pt)) title("") ///
	note("`note'" "`note_n'", size(6pt) ring(0) position(4)) ///
	subtitle("{bf:a}", size(10pt) position(11) span) ///
	ylab(,labsize(7pt)) xlab(,labsize(7pt)) ///
	scheme(cleanplots) graphregion(color(white)) legend(off) name(g1, replace) nodraw

pwcorr FES_gap spr if Percentile == 5 & data_PIP == 1
local note = round(`r(rho)',0.001)
local note_n = "{it: n = `r(N)'}"
local note = substr("`note'",1,4)
local note = "{it:r = 0`note'}"
twoway ///
	scatter FES_gap spr if Percentile == 5 & data_PIP == 1 & incomelevel == "LIC", mcolor(cranberry*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES_gap spr if Percentile == 5 & data_PIP == 1 & incomelevel == "LMIC", mcolor(midblue*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES_gap spr if Percentile == 5 & data_PIP == 1 & incomelevel == "UMIC", mcolor(forest_green*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES_gap spr if Percentile == 5 & data_PIP == 1 & incomelevel == "HIC", mcolor(orange*0.7) msize(tiny) msymbol(circle)  || ///
	qfitci FES_gap spr if Percentile == 5 & data_PIP == 1, lcolor(black) fcolor(black*0.3%20) astyle(background) || ///
	,  xscale(range(0 100)) yscale(range(0 1)) xlabel(0(20)100, format(%9.0gc)) ylabel(0(10)50, format(%9.0gc) angle(0)) ///
	ytitle("FES Gap Q1-Q5", size(7pt)) xtitle("Headcount ratio Societal Poverty Line (in %)", size(7pt)) title("") ///
	note("`note'" "`note_n'", size(6pt) ring(0) position(4)) ///
	subtitle("{bf:b}", size(10pt) position(11) span) ///
	ylab(,labsize(7pt)) xlab(,labsize(7pt)) ///
	scheme(cleanplots) graphregion(color(white)) legend(off) name(g2, replace) nodraw

pwcorr FES_gap consexp_pc_d_ln if Percentile == 5 & data_PIP == 1
local note = string(`r(rho)', "%6.3f")
local note_n = "{it: n = `r(N)'}"
local note = "{it:r = `note'}"
twoway ///
	scatter FES_gap consexp_pc_d_ln if Percentile == 5 & data_PIP == 1 & incomelevel == "LIC", mcolor(cranberry*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES_gap consexp_pc_d_ln if Percentile == 5 & data_PIP == 1 & incomelevel == "LMIC", mcolor(midblue*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES_gap consexp_pc_d_ln if Percentile == 5 & data_PIP == 1 & incomelevel == "UMIC", mcolor(forest_green*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES_gap consexp_pc_d_ln if Percentile == 5 & data_PIP == 1 & incomelevel == "HIC", mcolor(orange*0.7) msize(tiny) msymbol(circle)  || ///
	qfitci FES_gap consexp_pc_d_ln if Percentile == 5 & data_PIP == 1, lcolor(black) fcolor(black*0.3%20) astyle(background) || ///
	,  xscale(range(0.5 5)) yscale(range(0 1)) xlabel(0(1)5, format(%9.0gc)) ylabel(0(10)50, format(%9.0gc) angle(0)) ///
	ytitle("FES Gap Q1-Q5", size(7pt)) xtitle("Log. Consumption Expenditure per capita per day", size(7pt)) title("") ///
	note("`note'" "`note_n'", size(6pt) ring(0) position(2)) ///
	subtitle("{bf:c}", size(10pt) position(11) span) ///
	ylab(,labsize(7pt)) xlab(,labsize(7pt)) ///
	scheme(cleanplots) graphregion(color(white)) legend(off) name(g3, replace) nodraw

pwcorr FES_gap ny_gdp_pcap_pp_kd_ln if Percentile == 5 & data_WDI == 1
local note = string(`r(rho)', "%6.3f")
local note_n = "{it: n = `r(N)'}"
local note = "{it:r = `note'}"
twoway ///
	scatter FES_gap ny_gdp_pcap_pp_kd_ln if Percentile == 5 & data_WDI == 1 & incomelevel == "LIC", mcolor(cranberry*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES_gap ny_gdp_pcap_pp_kd_ln if Percentile == 5 & data_WDI == 1 & incomelevel == "LMIC", mcolor(midblue*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES_gap ny_gdp_pcap_pp_kd_ln if Percentile == 5 & data_WDI == 1 & incomelevel == "UMIC", mcolor(forest_green*0.7) msize(tiny) msymbol(circle)  || ///
	scatter FES_gap ny_gdp_pcap_pp_kd_ln if Percentile == 5 & data_WDI == 1 & incomelevel == "HIC", mcolor(orange*0.7) msize(tiny) msymbol(circle)  || ///
	qfitci FES_gap ny_gdp_pcap_pp_kd_ln if Percentile == 5 & data_WDI == 1, lcolor(black) fcolor(black*0.3%20) astyle(background) || ///
	,  xscale(range(7 12)) yscale(range(0 1)) xlabel(7(1)12, format(%9.0gc)) ylabel(0(10)50, format(%9.0gc) angle(0)) ///
	ytitle("FES Gap Q1-Q5", size(7pt)) xtitle("Log. GDP per capita per day", size(7pt)) title("") ///
	note("`note'" "`note_n'", size(6pt) ring(0) position(2)) ///
	subtitle("{bf:d}", size(10pt) position(11) span) ///
	ylab(,labsize(7pt)) xlab(,labsize(7pt)) ///
	scheme(cleanplots) graphregion(color(white)) legend(off) name(g4, replace) nodraw

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
graph export "${graphdir}/FigureS5.png", replace
graph export "${graphdir}/FigureS5.pdf", replace

