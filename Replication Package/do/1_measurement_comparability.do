********************************************************************************
*								Measurement and Comparability					*
********************************************************************************

********************************************************************************
*					3.2 Income versus consumption ranking						*
********************************************************************************
use "${datadir}/FESdatabase_income.dta", clear

merge 1:1 Country Surveyyear Incomegroups Percentile using "${datadir}/FESdatabase_quintiles.dta" , nogen keep(match master) keepusing(FES ranking_variable countrycode)

ren FES FES_consexp
gen FES_diff = FES_inc - FES_consexp

preserve

egen country_id_latest = group(Country)
tempfile FES_diff_stats_latest
tempname FES_diff_post_latest
postfile `FES_diff_post_latest' Percentile mean_diff_latest se_diff_latest ///
    lb_diff_latest ub_diff_latest using `FES_diff_stats_latest', replace

forvalues q = 1/5 {
    quietly regress FES_diff if Percentile == `q', vce(cluster country_id_latest)
    local mean = _b[_cons]
    local se = _se[_cons]
    local critical_value = invttail(e(N_clust) - 1, 0.025)
    local lb = `mean' - `critical_value' * `se'
    local ub = `mean' + `critical_value' * `se'
    post `FES_diff_post_latest' (`q') (`mean') (`se') (`lb') (`ub')
}

postclose `FES_diff_post_latest'
merge m:1 Percentile using `FES_diff_stats_latest', nogen
bysort Percentile (Country Surveyyear Incomegroups): gen plot_once_latest = _n == 1
gen mean_diff_label_latest = string(mean_diff_latest, "%5.2f")

set seed 20250826
twoway ///
    (scatter FES_diff Percentile, jitter(4) jitterseed(20250826) msymbol(Oh) msize(small) ///
        mcolor(gs11%55) mlcolor(gs11%55)) ///
    (rcap lb_diff_latest ub_diff_latest Percentile if plot_once_latest, ///
        lcolor(blue) lwidth(medthick)) ///
    (scatter mean_diff_latest Percentile if plot_once_latest, msymbol(D) ///
        msize(medium) mcolor(blue) mlcolor(blue) ///
        mlabel(mean_diff_label_latest) mlabposition(3) mlabgap(small) ///
        mlabcolor(blue) mlabsize(small)), ///
    yline(0, lcolor(gs8) lpattern(dash)) ///
    xlabel(1 "Q1 (low)" 2 "Q2" 3 "Q3" 4 "Q4" 5 "Q5 (high)") ///
    xscale(range(0.75 5.45)) ///
    xtitle("Quintile", size(8pt)) ///
    ytitle("FES difference" "(income - consumption, pp)", size(8pt)) ///
    legend(order(1 "Country" 3 "Mean and 95% CI") ///
        rows(1) ring(0) position(6) size(8pt)) ///
    graphregion(color(white)) plotregion(color(white)) ///
    scheme(cleanplots) xsize(8cm) ysize(7.5cm) ///
	subtitle("{bf:a}", size(10pt) position(11) span)

graph export "${graphdir}/FigureS15a.png", replace
graph export "${graphdir}/FigureS15a.pdf", replace

restore

preserve

keep Country Surveyyear Percentile FES_inc FES_consexp countrycode

reshape wide FES_inc FES_consexp, i(Country Surveyyear) j(Percentile)
gen FES_gradient_consexp = FES_consexp1 - FES_consexp5
gen FES_gradient_inc = FES_inc1 - FES_inc5

quietly summarize FES_gradient_consexp
local axis_min_latest = r(min)
local axis_max_latest = r(max)
quietly summarize FES_gradient_inc
local axis_min_latest = min(`axis_min_latest', r(min))
local axis_max_latest = max(`axis_max_latest', r(max))
local axis_padding_latest = 0.05 * (`axis_max_latest' - `axis_min_latest')
if `axis_padding_latest' == 0 local axis_padding_latest = 0.5
local axis_min_latest = `axis_min_latest' - `axis_padding_latest'
local axis_max_latest = `axis_max_latest' + `axis_padding_latest'

twoway ///
    (function y = x, range(`axis_min_latest' `axis_max_latest') ///
        lcolor(gs8) lpattern(dash)) ///
    (scatter FES_gradient_inc FES_gradient_consexp if !inlist(countrycode,"GTM","PAN"), msymbol(O) msize(medium) ///
        mcolor(blue%65) mlcolor(blue%65) mlab(countrycode) mlabsize(5pt) mlabcolor(black)) ///
		(scatter FES_gradient_inc FES_gradient_consexp if inlist(countrycode,"GTM","PAN"), msymbol(O) msize(medium) ///
        mcolor(blue%65) mlcolor(blue%65) mlab(countrycode) mlabsize(5pt) mlabcolor(black) mlabpos(11)), ///
    xscale(range(`axis_min_latest' `axis_max_latest')) ///
    yscale(range(`axis_min_latest' `axis_max_latest')) ///
    aspectratio(1) ///
    xtitle("FES gradient (Q1 - Q5)" "Consumption ranking", size(9pt)) ///
    ytitle("FES gradient (Q1 - Q5)" "Income ranking", size(9pt)) ///
    legend(order(1 "Equal gradient" 2 "Country") rows(2) ///
        size(8pt) ring(0) position(11)) ///
    graphregion(color(white)) plotregion(color(white) margin(zero)) ///
    scheme(cleanplots) xsize(8cm) ysize(7.5cm) ///
	subtitle("{bf:b}", size(10pt) position(11) span)

graph export "${graphdir}/FigureS15b.png", replace
graph export "${graphdir}/FigureS15b.pdf", replace

restore

********************************************************************************
*							3.3 FAFH comparability						*
********************************************************************************

use "${datadir}/FAFH.dta", clear
keep if Incomegroups == "Deciles"

gen Quintiles = .
replace Quintiles = 1 if inlist(Percentile,1,2)
replace Quintiles = 2 if inlist(Percentile,3,4)
replace Quintiles = 3 if inlist(Percentile,5,6)
replace Quintiles = 4 if inlist(Percentile,7,8)
replace Quintiles = 5 if inlist(Percentile,9,10)

collapse (mean) FAFH, by(Country Surveyyear Surveyyear2 year Incomegroups Quintiles)

gen notes = "Calculated from averages of two deciles"
ren Quintiles Percentile

tempfile quintiles
save `quintiles'

use "${datadir}/FAFH.dta", clear
keep if Incomegroups == "Quintiles"

append using `quintiles'
duplicates tag Country Surveyyear Surveyyear2 year Percentile, gen(_tag)
drop if _tag == 1 & Incomegroups == "Deciles"
drop _tag

merge 1:1 Country Surveyyear Percentile using "${datadir}/FESdatabase_quintiles.dta", nogen keep(match master) keepusing(FES fafh_treatment countrycode)
keep if fafh_treatment == "excluded"

merge m:1 countrycode year using "${auxdir}/WDI.dta", keep(match master) keepusing(incomelevel incomelevelname) nogen
merge m:1 countrycode year using "${auxdir}/PIP.dta", keep(match master) nogen keepusing(consexp_pc_d)

gen FES_including_fafh = FES + FAFH
label variable FES_including_fafh "Food expenditure share including FAFH (%)"

gen surveyyear_numeric = real(substr(Surveyyear, 1, 4))
assert !missing(surveyyear_numeric)
bysort Country (surveyyear_numeric Surveyyear): gen keep_latest_fafh = ///
    Surveyyear == Surveyyear[_N]
keep if keep_latest_fafh
drop surveyyear_numeric keep_latest_fafh

preserve

collapse (mean) FES_without_fafh=FES FES_with_fafh=FES_including_fafh ///
    (sd) sd_without_fafh=FES sd_with_fafh=FES_including_fafh ///
    (count) n_without_fafh=FES n_with_fafh=FES_including_fafh, by(Percentile)

gen se_without_fafh = sd_without_fafh / sqrt(n_without_fafh)
gen se_with_fafh = sd_with_fafh / sqrt(n_with_fafh)
gen lb_without_fafh = FES_without_fafh - ///
    invttail(n_without_fafh - 1, 0.025) * se_without_fafh if n_without_fafh > 1
gen ub_without_fafh = FES_without_fafh + ///
    invttail(n_without_fafh - 1, 0.025) * se_without_fafh if n_without_fafh > 1
gen lb_with_fafh = FES_with_fafh - ///
    invttail(n_with_fafh - 1, 0.025) * se_with_fafh if n_with_fafh > 1
gen ub_with_fafh = FES_with_fafh + ///
    invttail(n_with_fafh - 1, 0.025) * se_with_fafh if n_with_fafh > 1

gen percentile_without_fafh = Percentile - 0.06
gen percentile_with_fafh = Percentile + 0.06

twoway ///
    (rcap lb_without_fafh ub_without_fafh percentile_without_fafh, ///
        lcolor(blue) lwidth(medthin)) ///
    (connected FES_without_fafh percentile_without_fafh, lcolor(blue) ///
        lwidth(medthick) msymbol(O) msize(small) mcolor(blue)) ///
    (rcap lb_with_fafh ub_with_fafh percentile_with_fafh, ///
        lcolor(red) lwidth(medthin)) ///
    (connected FES_with_fafh percentile_with_fafh, lcolor(red) ///
        lwidth(medthick) msymbol(D) msize(small) mcolor(red)), ///
    xlabel(1 "Q1 (lowest)" 2 "Q2" 3 "Q3" 4 "Q4" 5 "Q5 (highest)", labsize(6pt)) ///
	ylab(, labsize(6pt)) ///
    xscale(range(0.75 5.25)) ///
    xtitle("Quintile", size(8pt)) ///
    ytitle("Mean food expenditure share (%)", size(8pt)) ///
    legend(order(2 "FAFH excluded" 4 "FAFH included") rows(1) ///
        size(6pt) ring(0) position(6)) ///
    graphregion(color(white)) plotregion(color(white)) ///
	subtitle("{bf:a}", size(10pt) position(11) span) ///
    scheme(cleanplots) xsize(8cm) ysize(6cm)

graph export "${graphdir}/FigureS14a.png", replace
graph export "${graphdir}/FigureS14a.pdf", replace

restore

preserve

keep if !missing(FAFH, consexp_pc_d) & consexp_pc_d > 0
gen ln_consexp_pc_d = ln(consexp_pc_d)
label variable ln_consexp_pc_d "Log consumption expenditure per capita per day"

tempfile fafh_welfare_slopes
tempname fafh_welfare_post
postfile `fafh_welfare_post' Percentile slope se lb ub n using ///
    `fafh_welfare_slopes', replace

forvalues q = 1/5 {
    quietly regress FAFH ln_consexp_pc_d if Percentile == `q'
    local slope = _b[ln_consexp_pc_d]
    local se = _se[ln_consexp_pc_d]
    local tcrit = invttail(e(df_r), 0.025)
    local lb = `slope' - `tcrit' * `se'
    local ub = `slope' + `tcrit' * `se'
    post `fafh_welfare_post' (`q') (`slope') (`se') (`lb') (`ub') (e(N))
}

postclose `fafh_welfare_post'
use `fafh_welfare_slopes', clear
gen slope_label = string(slope, "%4.2f")

twoway ///
    (rcap lb ub Percentile, lcolor(navy) lwidth(medium)) ///
    (connected slope Percentile, lcolor(black) lwidth(medthick) ///
        msymbol(D) msize(medium) mcolor(black) ///
        mlabel(slope_label) mlabposition(2) mlabcolor(black) mlabsize(6pt)), ///
    yline(0, lcolor(gs8) lpattern(dash)) ///
    xlabel(1 "Q1 (lowest)" 2 "Q2" 3 "Q3" 4 "Q4" 5 "Q5 (highest)", labsize(6pt)) ///
	ylabel(, labsize(6pt)) ///
    xscale(range(0.75 5.45)) ///
    xtitle("Quintile", size(8pt)) ///
    ytitle("Change in FAFH share (pp)" "per log-unit country welfare", size(8pt)) ///
    legend(off) ///
    graphregion(color(white)) plotregion(color(white)) ///
	subtitle("{bf:b}", size(10pt) position(11) span) ///
    scheme(cleanplots) xsize(8.0cm) ysize(6cm)

graph export "${graphdir}/FigureS14b.png", replace
graph export "${graphdir}/FigureS14b.pdf", replace

restore
