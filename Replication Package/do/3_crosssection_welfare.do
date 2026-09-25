********************************************************************************
*					Continuous income data for each quintile					*
********************************************************************************

use "${pipdir}/pip_quintile_welfare_2021ppp.dta", clear

rename country_code countrycode
rename year pip_reporting_year
rename welfare_time pip_welfare_time
rename welfare_type pip_welfare_type
rename quintile Percentile

isid countrycode pip_reporting_year pip_welfare_type Percentile

tempfile pip_quintile pip_distribution pip_match
save `pip_quintile'

keep countrycode pip_reporting_year pip_welfare_time pip_welfare_type
duplicates drop
isid countrycode pip_reporting_year pip_welfare_type
save `pip_distribution'

use "${datadir}/FESdatabase_quintiles.dta", clear

generate byte pip_welfare_type = ///
    cond(lower(strtrim(ranking_variable)) == "income", 2, 1)

label define pip_welfare_type_label ///
    1 "Consumption expenditure" ///
    2 "Income"
label values pip_welfare_type pip_welfare_type_label

preserve
    keep identifier countrycode Surveyyear2 pip_welfare_type
    duplicates drop
    isid identifier

    joinby countrycode pip_welfare_type using `pip_distribution'

    generate double pip_gap = ///
        max(floor(Surveyyear2) - pip_welfare_time, 0)
    replace pip_gap = ///
        max(pip_gap, pip_welfare_time - ceil(Surveyyear2))

    gsort identifier pip_gap -pip_welfare_time -pip_reporting_year
    by identifier: keep if _n == 1
    keep if pip_gap <= 2

    isid identifier
    save `pip_match'
restore

merge m:1 identifier using `pip_match', ///
    keep(master match) gen(_pip_match)

merge m:1 countrycode pip_reporting_year pip_welfare_type Percentile ///
    using `pip_quintile', keep(master match) gen(_pip_welfare)

assert _pip_welfare == 3 if _pip_match == 3

label variable pip_welfare_time ///
    "PIP welfare reference time matched to FES survey"
label variable pip_gap ///
    "Distance between FES survey period and PIP welfare time (years)"

compress
save "${pipdir}/FESdatabase_quintiles_PIPwelfare_2021ppp.dta", replace

local q1_colour "215 25 28"
local q2_colour "253 174 97"
local q3_colour "255 255 191"
local q4_colour "171 217 233"
local q5_colour "44 123 182"

graph set window fontface "Helvetica"

preserve
    keep if _pip_welfare == 3
    keep countrycode identifier Surveyyear2
    duplicates drop
    sort countrycode Surveyyear2 identifier
    by countrycode: keep if _n == _N
    keep identifier

    tempfile latest_matched_set
    save `latest_matched_set'
restore

merge m:1 identifier using `latest_matched_set', ///
    keep(master match) gen(_latest_matched_set)

twoway ///
    (scatter FES ln_welfare_ppp_day if Percentile == 1 & _latest_matched_set == 3, ///
        msymbol(O) msize(tiny) mcolor("`q1_colour'%25")) ///
    (scatter FES ln_welfare_ppp_day if Percentile == 2 & _latest_matched_set == 3, ///
        msymbol(O) msize(tiny) mcolor("`q2_colour'%25")) ///
    (scatter FES ln_welfare_ppp_day if Percentile == 3 & _latest_matched_set == 3, ///
        msymbol(O) msize(tiny) mcolor("`q3_colour'%35")) ///
    (scatter FES ln_welfare_ppp_day if Percentile == 4 & _latest_matched_set == 3, ///
        msymbol(O) msize(tiny) mcolor("`q4_colour'%25")) ///
    (scatter FES ln_welfare_ppp_day if Percentile == 5 & _latest_matched_set == 3, ///
        msymbol(O) msize(tiny) mcolor("`q5_colour'%25")) ///
    (lfit FES ln_welfare_ppp_day if Percentile == 1 & _latest_matched_set == 3, ///
        lcolor("`q1_colour'") lwidth(medthick) lpattern(solid)) ///
    (lfit FES ln_welfare_ppp_day if Percentile == 2 & _latest_matched_set == 3, ///
        lcolor("`q2_colour'") lwidth(medthick) lpattern(solid)) ///
    (lfit FES ln_welfare_ppp_day if Percentile == 3 & _latest_matched_set == 3, ///
        lcolor("`q3_colour'") lwidth(medthick) lpattern(solid)) ///
    (lfit FES ln_welfare_ppp_day if Percentile == 4 & _latest_matched_set == 3, ///
        lcolor("`q4_colour'") lwidth(medthick) lpattern(solid)) ///
    (lfit FES ln_welfare_ppp_day if Percentile == 5 & _latest_matched_set == 3, ///
        lcolor("`q5_colour'") lwidth(medthick) lpattern(solid)) ///
    (lfit FES ln_welfare_ppp_day if _latest_matched_set == 3, ///
        lcolor(black) lwidth(medthick) lpattern(dash)) ///
    , ///
    xtitle("Mean per-capita quintile welfare (2021 PPP dollars per day)", size(7pt)) ///
    ytitle("Food expenditure share (%)", size(7pt)) ///
    xlabel(-0.693 "0.5" 0 "1" 0.693 "2" 1.609 "5" 2.303 "10" ///
           2.996 "20" 3.912 "50" 4.605 "100" 5.298 "200", labsize(7pt)) ///
    ylabel(0(20)100, labsize(7pt)) ///
    legend(order(6 "Q1" 7 "Q2" 8 "Q3" 9 "Q4" 10 "Q5" 11 "All quintiles") ///
           rows(1) position(6) size(7pt)) ///
    graphregion(color(white)) plotregion(color(white)) ///
    scheme(cleanplots) xsize(8cm) ysize(7cm) ///
	subtitle("{bf:b}", size(10pt) position(11) span) ///
    name(FES_continuous_welfare_latest, replace)

graph export ///
    "${graphdir}/Figure1b.png", ///
    replace width(3600)
graph export ///
    "${graphdir}/Figure1b.pdf", ///
    replace
