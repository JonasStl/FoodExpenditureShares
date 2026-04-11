********************************************************************************
*						Analysis: Time - Modelled Estimates				*
********************************************************************************
use "${datadir}/FESdatabase_imputed.dta", clear

encode countrycode, gen(countrycode_enc)
keep if countrycode_enc <= 83

sort Country year Percentile
twoway ///
    rarea FES_final_p10 FES_final_p90 year if Percentile==1 , ///
        fcolor(red%15) lcolor(red%15)  || ///
    line FES_final year if Percentile==1 , ///
        lcolor(red) lwidth(medthick) || ///
    scatter FES_final year if Percentile==1 & note=="Raw", ///
        mcolor(black) msize(vsmall) msymbol(D) || ///
    rarea FES_final_p10 FES_final_p90 year if Percentile==5 , ///
        fcolor(blue%15) lcolor(blue%15)   || ///
    line FES_final year if Percentile==5 , ///
        lcolor(blue) lwidth(medthick) || ///
    scatter FES_final year if Percentile==5 & note=="Raw", ///
        mcolor(black) msize(vsmall) msymbol(D) ///
    ,  by(countrycode_enc, cols(6) note("") imargin(tiny) graphregion(margin(t-3 b-3))) ///
    xtitle("Year", size(8pt)) ///
    ytitle("Food expenditure share", size(8pt)) ///
	ylab(,labsize(15pt)) xlab(,labsize(15pt) angle(40)) ///
    legend(bmargin(zero) size(8pt) rows(1) position(6) symysize(2) symxsize(3) order(2 "Q1" 1 "Q1: p10-p90" 5 "Q5" 4 "Q5: p10-p90" 3 "Raw Estimates")) ///
    scheme(cleanplots) ysize(21cm) xsize(18cm) 

graph export "${workdir}/graphs/FigureS10.png", replace
graph export "${workdir}/graphs/FigureS10.pdf", replace



use "${datadir}/FESdatabase_imputed.dta", clear
						   
encode countrycode, gen(countrycode_enc)
keep if countrycode_enc > 83

sort Country year Percentile
twoway ///
    rarea FES_final_p10 FES_final_p90 year if Percentile==1 , ///
        fcolor(red%15) lcolor(red%15)  || ///
    line FES_final year if Percentile==1 , ///
        lcolor(red) lwidth(medthick) || ///
    scatter FES_final year if Percentile==1 & note=="Raw", ///
        mcolor(black) msize(vsmall) msymbol(D) || ///
    rarea FES_final_p10 FES_final_p90 year if Percentile==5 , ///
        fcolor(blue%15) lcolor(blue%15)   || ///
    line FES_final year if Percentile==5 , ///
        lcolor(blue) lwidth(medthick) || ///
    scatter FES_final year if Percentile==5 & note=="Raw", ///
        mcolor(black) msize(vsmall) msymbol(D) ///
    ,  by(countrycode_enc, cols(6) note("") imargin(tiny) graphregion(margin(t-3 b-3))) ///
    xtitle("Year", size(8pt)) ///
    ytitle("Food expenditure share", size(8pt)) ///
	ylab(,labsize(15pt)) xlab(,labsize(15pt) angle(40)) ///
    legend(bmargin(zero) size(8pt) rows(1) position(6) symysize(2) symxsize(3) order(2 "Q1" 1 "Q1: p10-p90" 5 "Q5" 4 "Q5: p10-p90" 3 "Raw Estimates")) ///
    scheme(cleanplots) ysize(21cm) xsize(18cm) 

graph export "${workdir}/graphs/FigureS11.png", replace
graph export "${workdir}/graphs/FigureS11.pdf", replace



********************************************************************************
* Figure S12: Replication of Income group averages for 2019
********************************************************************************
use "${datadir}/FESdatabase_imputed.dta", clear

merge m:1 countrycode year using "${datadir}/aux data/WDI.dta", keep(match master) nogen keepusing(incomelevel incomelevelname) 
replace incomelevel = "LIC" if Country == "Ethiopia" & incomelevel == "INX" 
replace incomelevelname = "Low income" if Country == "Ethiopia" & incomelevelname == "Not classified"

* Keep 2019 or pre data
keep if year == 2019 | Country == "Argentina"

* World mean
preserve
collapse (mean) mean_FES = FES_final ///
         (sd)   sd_FES   = FES_final ///
         (count) n_FES   = FES_final  ///
         , by(Percentile)
		 
gen incomelevel = "World"
		 
tempfile worldmean
save `worldmean'

* Mean by income group
restore
collapse (mean) mean_FES = FES_final  ///
         (sd)   sd_FES   = FES_final  ///
         (count) n_FES   = FES_final  ///
         , by(Percentile incomelevel)

append using `worldmean'


* 95% CI using t distribution
gen se_FES = sd_FES / sqrt(n_FES)
gen ci_lb = mean_FES - invttail(n_FES-1,0.025)*se_FES
gen ci_ub = mean_FES + invttail(n_FES-1,0.025)*se_FES

drop if incomelevel == ""
gen lbl = string(mean_FES, "%9.2f") + "%"

graph set window fontface "Helvetica"

twoway ///
    rcap ci_lb ci_ub Percentile if incomelevel=="HIC", lcolor(blue)   || ///
    line mean_FES Percentile if incomelevel=="HIC"   , lwidth(medthick) lcolor(blue) lpattern(solid) || ///
	scatter mean_FES Percentile if incomelevel=="HIC" & Percentile == 1, msymbol(none) mlab(lbl) mlabposition(9) mlabcolor(blue) mlabformat(%9.2f) || ///
	scatter mean_FES Percentile if incomelevel=="HIC" & Percentile == 5, msymbol(none) mlab(lbl) mlabposition(3) mlabcolor(blue) mlabformat(%9.2f) || ///
    rcap ci_lb ci_ub Percentile if incomelevel=="LIC", lcolor(green)   || ///
    line mean_FES Percentile if incomelevel=="LIC"   , lwidth(medthick) lcolor(green) lpattern(solid)  || ///
	scatter mean_FES Percentile if incomelevel=="LIC" & Percentile == 1, msymbol(none) mlab(lbl) mlabposition(9) mlabcolor(green) mlabformat(%9.2f) || ///
	scatter mean_FES Percentile if incomelevel=="LIC" & Percentile == 5, msymbol(none) mlab(lbl) mlabposition(3) mlabcolor(green) mlabformat(%9.2f) || ///
    rcap ci_lb ci_ub Percentile if incomelevel=="LMC", lcolor(sienna)   || ///
    line mean_FES Percentile if incomelevel=="LMC"   , lwidth(medthick) lcolor(sienna) lpattern(solid)  || ///
	scatter mean_FES Percentile if incomelevel=="LMC" & Percentile == 1, msymbol(none) mlab(lbl) mlabposition(9) mlabcolor(sienna) mlabformat(%9.2f) || ///
	scatter mean_FES Percentile if incomelevel=="LMC" & Percentile == 5, msymbol(none) mlab(lbl) mlabposition(3) mlabcolor(sienna) mlabformat(%9.2f) || ///
    rcap ci_lb ci_ub Percentile if incomelevel=="UMC", lcolor(cranberry)   || ///
    line mean_FES Percentile if incomelevel=="UMC"   , lwidth(medthick) lcolor(cranberry) lpattern(solid)  || ///
	scatter mean_FES Percentile if incomelevel=="UMC" & Percentile == 1, msymbol(none) mlab(lbl) mlabposition(10) mlabcolor(cranberry) mlabformat(%9.2f) || ///
	scatter mean_FES Percentile if incomelevel=="UMC" & Percentile == 5, msymbol(none) mlab(lbl) mlabposition(4) mlabcolor(cranberry) mlabformat(%9.2f) || ///
    rcap ci_lb ci_ub Percentile if incomelevel=="World", lcolor(black) || ///
    line mean_FES Percentile if incomelevel=="World" , lwidth(medthick) lcolor(black) lpattern(dash) || ///
	scatter mean_FES Percentile if incomelevel=="World" & Percentile == 1, msymbol(none) mlab(lbl) mlabposition(8) mlabcolor(black) mlabformat(%9.2f) || ///
	scatter mean_FES Percentile if incomelevel=="World" & Percentile == 5, msymbol(none) mlab(lbl) mlabposition(3) mlabcolor(black) mlabformat(%9.2f) || ///
    , ///
    xtitle("Welfare quintile", size(5pt)) ///
    ytitle("Mean FES", size(5pt)) ///
    xlabel(1(1)5) xscale(range(0.6 5)) ///
	ylabel(0(10)70) ///
    legend(size(7pt) rows(1) position(6) order(2 "HIC"  14 "UMICs" 10 "LMIC" 6 "LIC"  18 "World")) ///
	graphregion(margin(r+6)) scheme(cleanplots) xsize(8.8cm) ysize(5cm) name(g1, replace)
	
graph export "${workdir}/graphs/FigureS12.png", replace
graph export "${workdir}/graphs/FigureS12.pdf", replace
