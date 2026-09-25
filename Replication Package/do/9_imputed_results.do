********************************************************************************
*								Analysis: Time - Modelled Estimates				*
********************************************************************************

use "${datadir}/FESdatabase_imputed.dta", clear
drop if inlist(countrycode,"ARG","TKL","COK")

encode countrycode, gen(countrycode_enc)
keep if countrycode_enc <= 84

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
	ylab(0(50)100,labsize(15pt)) xlab(,labsize(15pt) angle(40)) ///
    legend(bmargin(zero) size(8pt) rows(1) position(6) symysize(2) symxsize(3) order(2 "Q1" 1 "Q1: p10-p90" 5 "Q5" 4 "Q5: p10-p90" 3 "Observed value")) ///
    scheme(cleanplots) ysize(21cm) xsize(18cm)

graph export "${graphdir}/FigureS9.png", replace
graph export "${graphdir}/FigureS9.pdf", replace

use "${datadir}/FESdatabase_imputed.dta", clear
drop if inlist(countrycode,"ARG","TKL","COK")

encode countrycode, gen(countrycode_enc)
keep if countrycode_enc > 84

sort countrycode year Percentile
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
	ylab(0(50)100,labsize(15pt)) xlab(,labsize(15pt) angle(40)) ///
    legend(bmargin(zero) size(8pt) rows(1) position(6) symysize(2) symxsize(3) order(2 "Q1" 1 "Q1: p10-p90" 5 "Q5" 4 "Q5: p10-p90" 3 "Observed value")) ///
    scheme(cleanplots) ysize(21cm) xsize(18cm)

graph export "${graphdir}/FigureS10.png", replace
graph export "${graphdir}/FigureS10.pdf", replace

********************************************************************************
* 					Replication of Income group averages for 2025
********************************************************************************

use "${datadir}/FESdatabase_imputed.dta", clear

merge m:1 countrycode year using "${auxdir}/WDI.dta", keep(match master) nogen keepusing(incomelevel incomelevelname)
replace incomelevel = "LIC" if Country == "Ethiopia" & incomelevel == "INX"
replace incomelevelname = "Low income" if Country == "Ethiopia" & incomelevelname == "Not classified"

keep if year == 2025

preserve
collapse (mean) mean_FES = FES_final ///
         (sd)   sd_FES   = FES_final ///
         (count) n_FES   = FES_final  ///
         , by(Percentile)

gen incomelevel = "World"

tempfile worldmean
save `worldmean'

restore
collapse (mean) mean_FES = FES_final  ///
         (sd)   sd_FES   = FES_final  ///
         (count) n_FES   = FES_final  ///
         , by(Percentile incomelevel)

append using `worldmean'

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
	scatter mean_FES Percentile if incomelevel=="UMC" & Percentile == 1, msymbol(none) mlab(lbl) mlabposition(8) mlabcolor(cranberry) mlabformat(%9.2f) || ///
	scatter mean_FES Percentile if incomelevel=="UMC" & Percentile == 5, msymbol(none) mlab(lbl) mlabposition(4) mlabcolor(cranberry) mlabformat(%9.2f) || ///
    rcap ci_lb ci_ub Percentile if incomelevel=="World", lcolor(black) || ///
    line mean_FES Percentile if incomelevel=="World" , lwidth(medthick) lcolor(black) lpattern(dash) || ///
	scatter mean_FES Percentile if incomelevel=="World" & Percentile == 1, msymbol(none) mlab(lbl) mlabposition(10) mlabcolor(black) mlabformat(%9.2f) || ///
	scatter mean_FES Percentile if incomelevel=="World" & Percentile == 5, msymbol(none) mlab(lbl) mlabposition(3) mlabcolor(black) mlabformat(%9.2f) || ///
    , ///
    xtitle("Welfare quintile", size(5pt)) ///
    ytitle("Mean FES", size(5pt)) ///
    xlabel(1(1)5) xscale(range(0.6 5)) ///
	ylabel(0(10)70) ///
    legend(size(7pt) rows(1) position(6) order(2 "HIC"  14 "UMICs" 10 "LMIC" 6 "LIC"  18 "World")) ///
	graphregion(margin(r+6)) scheme(cleanplots) xsize(8.8cm) ysize(5cm) name(g1, replace)

graph export "${graphdir}/FigureS11.png", replace
graph export "${graphdir}/FigureS11.pdf", replace

********************************************************************************
* SOFI reference shares versus country-specific food expenditure shares, 2025
********************************************************************************

use "${datadir}/FESdatabase_imputed.dta", clear

merge m:1 countrycode year using "${auxdir}/WDI.dta", ///
    keep(match master) nogen keepusing(incomelevel incomelevelname)

replace incomelevel = "LIC" if Country == "Ethiopia" & incomelevel == "INX"
replace incomelevelname = "Low income" if Country == "Ethiopia" ///
    & incomelevelname == "Not classified"

keep if year == 2025

gen byte sofi_reference_quintile = .
replace sofi_reference_quintile = 2 if inlist(incomelevel, "LIC", "LMC")
replace sofi_reference_quintile = 1 if inlist(incomelevel, "UMC", "HIC")
keep if Percentile == sofi_reference_quintile
drop if missing(FES_final)

gen double fes_sofi = .
replace fes_sofi = 63 if incomelevel == "LIC"
replace fes_sofi = 56 if incomelevel == "LMC"
replace fes_sofi = 46 if inlist(incomelevel, "UMC", "HIC")

bysort incomelevel: egen double fes_mean = mean(FES_final)
bysort incomelevel: egen double fes_sd   = sd(FES_final)
bysort incomelevel: egen int    fes_n    = count(FES_final)

gen double fes_sd_lo = max(0, fes_mean - fes_sd)
gen double fes_sd_hi = min(100, fes_mean + fes_sd)
gen double fes_z_sofi = (FES_final - fes_sofi) / fes_sd

sort incomelevel FES_final Country
by incomelevel: gen country_rank = _n

gen byte income_group_order = .
replace income_group_order = 1 if incomelevel == "LIC"
replace income_group_order = 2 if incomelevel == "LMC"
replace income_group_order = 3 if incomelevel == "UMC"
replace income_group_order = 4 if incomelevel == "HIC"
label define income_group_order_lbl ///
    1 "LIC (Q2 FES)" ///
    2 "LMIC (Q2 FES)" ///
    3 "UMIC (Q1 FES)" ///
    4 "HIC (Q1 FES)", replace
label values income_group_order income_group_order_lbl

graph set window fontface "Helvetica"

twoway ///
    (rarea fes_sd_lo fes_sd_hi country_rank, ///
        sort fcolor(gs9%20) lcolor(gs8) lwidth(vthin)) ///
    (line fes_mean country_rank, sort ///
        lcolor(black) lpattern(dash) lwidth(medthick)) ///
    (line fes_sofi country_rank, sort ///
        lcolor(orange) lpattern(solid) lwidth(medthick)) ///
    (scatter FES_final country_rank, ///
        mcolor(blue%60) msymbol(circle) msize(small)), ///
    by(income_group_order, subtitle(,size(7pt)) cols(2) note("") ///
        imargin(tiny) graphregion(color(white))) ///
    ytitle("Food expenditure share (percent)", size(8pt)) ///
    xtitle("Countries, ordered by 2025 modelled FES", size(8pt)) ///
    ylabel(0(10)80, labsize(7pt)) ///
    xlabel(none) ///
    legend(size(7pt) rows(1) position(6) ///
        order(4 "Country estimate" ///
              2 "2025 modeled estimate mean" ///
              1 "Mean +/- 1 SD" ///
              3 "SOFI value")) ///
    scheme(cleanplots) xsize(16cm) ysize(11cm) ///
    name(fes_sofi_country_dispersion, replace)

graph export "${graphdir}/FigureS13.png", replace
graph export "${graphdir}/FigureS13.pdf", replace

********************************************************************************
*		Analysis:  Modelled Estimates and prices for 2021			*
********************************************************************************

use "${datadir}/FESdatabase_imputed.dta", clear
drop if inlist(countrycode,"ARG","TKL","COK")

merge m:1 countrycode using  "${auxdir}/icp_data.dta", nogen keep(match master)
merge m:1 countrycode year using "${auxdir}/CoHD.dta", nogen keep(match master)
merge m:1 countrycode year using "${auxdir}/PIP.dta", nogen keep(match master)

keep if year == 2021

gen FES = FES_final
gen consexp_pc_d_ln = ln(consexp_pc_d)

qui reg FES YR20211101000 YR20211102000 YR20211103000 YR20211105000 YR20211107000 YR20211108000 YR20219060000 YR20219080000 YR20219120000  consexp_pc_d_ln
gen esample = e(sample)

eststo m1: reg FES YR20211101000 YR20211102000 YR20211103000 YR20211105000 YR20211107000 YR20211108000 YR20219060000 YR20219080000 YR20219120000  consexp_pc_d_ln if Percentile == 1
eststo m2: reg FES YR20211101000 YR20211102000 YR20211103000 YR20211105000 YR20211107000 YR20211108000 YR20219060000 YR20219080000 YR20219120000  consexp_pc_d_ln if Percentile == 3
eststo m3: reg FES YR20211101000 YR20211102000 YR20211103000 YR20211105000 YR20211107000 YR20211108000 YR20219060000 YR20219080000 YR20219120000  consexp_pc_d_ln if Percentile == 5

graph set window fontface "Helvetica"
coefplot ///
    (m1, label("Q1 (bottom)") ///
        mcolor("215 25 28") msymbol(O) ///
        ciopts(lcolor("215 25 28") lwidth(0.02cm))) ///
    (m2, label("Q3 (middle)") ///
        mcolor("116 196 118") msymbol(O) ///
        ciopts(lcolor("116 196 118") lwidth(0.02cm))) ///
    (m3, label("Q5 (top)") ///
        mcolor("44 123 182") msymbol(O) ///
        ciopts(lcolor("44 123 182") lwidth(0.02cm))) ///
    , drop(consexp_pc_d_ln _cons) ///
    xline(0, lpattern(dash) lcolor(gs8)) ///
    mlabel(cond(@pval<.01,  "***", ///
           cond(@pval<.05,  "**", ///
           cond(@pval<.1,   "*" , "")))) ///
    mlabposition(12) mlabsize(5pt) mlabcolor(black)  mlabgap(0)  ///
    ciopts(recast(rcap) lwidth(medthin)) ///
    ylab(none, labsize(7pt)) xlab(, labsize(7pt)) xscale(range(-0.6 0.2)) ///
    xtitle("Association with modelled 2021 FES (pp)", size(6pt)) ///
    ytitle("") yscale(off) ///
    legend(ring(0) position(12) rows(3) size(5pt) nobox bcolor(white) lstyle(none) ) ///
    graphregion(color(white)) ///
    plotregion(color(white)) ///
	xsize(8cm) ysize(8cm)  ///
	subtitle("{bf:a}", size(10pt) position(11) span) ///
	text(1 -0.54 "Food &" "non-alc. bev.", size(6pt) justification(left) placement(3)) ///
	text(2 -0.54 "Alcohol, tobacco," "narcotics", size(6pt) justification(left) placement(3)) ///
	text(3 -0.54 "Clothing &" "footwear", size(6pt) justification(left) placement(3)) ///
	text(4 -0.54 "Furnishings &" "household equipment", size(6pt) justification(left) placement(3)) ///
	text(5 -0.54 "Transport", size(6pt) justification(left) placement(3)) ///
	text(6 -0.54 "Communication", size(6pt) justification(left) placement(3)) ///
	text(7 -0.54 "Housing & utilities", size(6pt) justification(left) placement(3)) ///
	text(8 -0.54 "Health", size(6pt) justification(left) placement(3)) ///
	text(9 -0.54 "Education", size(6pt) justification(left) placement(3)) ///
	text(5 -0.59 "{bf:Price level indices in 2021}", orientation(vertical) size(6pt) )  ///
	scheme(cleanplots)

graph export "${graphdir}/FigureS12a.png", replace
graph export "${graphdir}/FigureS12a.pdf", replace

drop esample

qui reg FES YR20211101000 YR20211102000 YR20211103000 YR20211105000 YR20211107000 YR20211108000 YR20219060000 YR20219080000 YR20219120000  consexp_pc_d_ln
gen esample = e(sample)

foreach var in YR20211101000 YR20211102000 YR20211103000 ///
               YR20211105000 YR20211107000 YR20211108000 ///
               YR20219060000 YR20219080000 YR20219120000 ///
               CoHD CoCA CoHD_ss {
    egen z_`var' = std(`var') if esample
}

eststo m1_1: reg FES z_YR20211101000 z_YR20211102000 z_YR20211103000 z_YR20211105000 z_YR20211107000 z_YR20211108000 z_YR20219060000 z_YR20219080000 z_YR20219120000  consexp_pc_d_ln if Percentile == 1
eststo m1_2: reg FES z_CoHD z_YR20211102000 z_YR20211103000 z_YR20211105000 z_YR20211107000 z_YR20211108000 z_YR20219060000 z_YR20219080000 z_YR20219120000  consexp_pc_d_ln if Percentile == 1
eststo m1_3: reg FES z_CoCA z_YR20211102000 z_YR20211103000 z_YR20211105000 z_YR20211107000 z_YR20211108000 z_YR20219060000 z_YR20219080000 z_YR20219120000  consexp_pc_d_ln if Percentile == 1

eststo m2_1: reg FES z_YR20211101000 z_YR20211102000 z_YR20211103000 z_YR20211105000 z_YR20211107000 z_YR20211108000 z_YR20219060000 z_YR20219080000 z_YR20219120000  consexp_pc_d_ln if Percentile == 3
eststo m2_2: reg FES z_CoHD z_YR20211102000 z_YR20211103000 z_YR20211105000 z_YR20211107000 z_YR20211108000 z_YR20219060000 z_YR20219080000 z_YR20219120000  consexp_pc_d_ln if Percentile == 3
eststo m2_3: reg FES z_CoCA z_YR20211102000 z_YR20211103000 z_YR20211105000 z_YR20211107000 z_YR20211108000 z_YR20219060000 z_YR20219080000 z_YR20219120000  consexp_pc_d_ln if Percentile == 3

eststo m3_1: reg FES z_YR20211101000 z_YR20211102000 z_YR20211103000 z_YR20211105000 z_YR20211107000 z_YR20211108000 z_YR20219060000 z_YR20219080000 z_YR20219120000  consexp_pc_d_ln if Percentile == 5
eststo m3_2: reg FES z_CoHD YR20211102000 z_YR20211102000 z_YR20211103000 z_YR20211105000 z_YR20211107000 z_YR20211108000 z_YR20219060000 z_YR20219080000 z_YR20219120000  consexp_pc_d_ln if Percentile == 5
eststo m3_3: reg FES z_CoCA YR20211102000 z_YR20211102000 z_YR20211103000 z_YR20211105000 z_YR20211107000 z_YR20211108000 z_YR20219060000 z_YR20219080000 z_YR20219120000 consexp_pc_d_ln if Percentile == 5

graph set window fontface "Helvetica"
coefplot ///
    (m1_1 m1_2 m1_3 , label("Q1 (bottom)") ///
        mcolor("215 25 28") msymbol(O) ///
        ciopts(lcolor("215 25 28") lwidth(0.02cm))) ///
    (m2_1 m2_2 m2_3 , label("Q3 (middle)") ///
        mcolor("116 196 118") msymbol(O) ///
        ciopts(lcolor("116 196 118") lwidth(0.02cm))) ///
    (m3_1 m3_2 m3_3 , label("Q5 (top)") ///
        mcolor("44 123 182") msymbol(O) ///
        ciopts(lcolor("44 123 182") lwidth(0.02cm))) ///
    , keep(z_YR20211101000 z_CoHD z_CoCA z_CoHD_ss)  ///
    xline(0, lpattern(dash) lcolor(gs8)) ///
    mlabel(cond(@pval<.01,  "***", ///
           cond(@pval<.05,  "**", ///
           cond(@pval<.1,   "*" , "")))) ///
    mlabposition(12) mlabsize(5pt) mlabcolor(black)  mlabgap(0)  ///
    ciopts(recast(rcap)) msize(large) ///
    ylab(none, labsize(7pt)) xlab(, labsize(7pt)) xscale(range(-5.5 0.2)) ///
    xtitle("Association with modelled 2021 FES (pp)", size(6pt)) ///
    ytitle("") yscale(off) ///
    legend(ring(0) position(3) rows(3) size(5pt) nobox bcolor(white) lstyle(none) ) ///
    graphregion(color(white) margin(l+20)) ///
    plotregion(color(white) margin(l+20)) ///
	xsize(8cm) ysize(4cm)  ///
	subtitle("{bf:b}", size(10pt) position(11) span) ///
	text(1 -7 "ICP Food and non-alc." "beverages index", size(6pt) justification(left) placement(3)) ///
	text(2 -7 "Cost of a" "healthy diet", size(6pt) justification(left) placement(3)) ///
	text(3 -7 "Cost of an" "energy sufficient diet", size(6pt) justification(left) placement(3)) ///
	text(2.5 -8 "{bf:Standardized}" "{bf:price level indicators}", orientation(vertical) size(6pt) )  ///
	scheme(cleanplots)

graph export "${graphdir}/FigureS12b.png", replace
graph export "${graphdir}/FigureS12b.pdf", replace
