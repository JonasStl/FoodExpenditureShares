********************************************************************************
*								Analysis: Time				*
********************************************************************************

use "${datadir}/FESdatabase_quintiles_analysis.dta", clear

recode incomelevel_enc (1=4 "HIC") (2=1 "LIC") (3=2 "LMIC") (4=3 "UMIC"), gen(incomelevel2)
drop incomelevel_enc

encode countrycode, gen(countrycode_enc)
keep if !missing(FES, Surveyyear2, countrycode_enc)
egen country_quintile = group(countrycode_enc Percentile)

bysort countrycode_enc Surveyyear: gen byte wave_tag = (_n == 1)
bysort countrycode_enc: egen int n_waves = total(wave_tag)
drop wave_tag
keep if n_waves >= 2

gen double w_country_inverse_waves = 1 / n_waves
label variable w_country_inverse_waves "Inverse number of observed survey waves"

gen Q1 = 0
replace Q1 = 1 if Percentile == 1

gen post2019 = 0
replace post2019 = 1 if Surveyyear2 > 2019.5 & Surveyyear2 < .

eststo clear

eststo m1: reg FES i.country_quintile c.Surveyyear2, ///
    vce(cluster countrycode_enc)

eststo m3: reg FES i.country_quintile c.Surveyyear2##i.post2019, ///
    vce(cluster countrycode_enc)

eststo m2_1: reg FES i.countrycode_enc c.Surveyyear2 ///
    if inlist(Percentile,1), ///
    vce(cluster countrycode_enc)
eststo m2_2: reg FES i.countrycode_enc c.Surveyyear2 ///
    if inlist(Percentile,2), ///
    vce(cluster countrycode_enc)
eststo m2_3: reg FES i.countrycode_enc c.Surveyyear2 ///
    if inlist(Percentile,3), ///
    vce(cluster countrycode_enc)
eststo m2_4: reg FES i.countrycode_enc c.Surveyyear2 ///
    if inlist(Percentile,4), ///
    vce(cluster countrycode_enc)
eststo m2_5: reg FES i.countrycode_enc c.Surveyyear2 ///
    if inlist(Percentile,5), ///
    vce(cluster countrycode_enc)

eststo m4_1: reg FES i.countrycode_enc c.Surveyyear2##i.post2019 ///
    if inlist(Percentile,1), ///
    vce(cluster countrycode_enc) coeflegend
eststo m4_2: reg FES i.countrycode_enc c.Surveyyear2##i.post2019 ///
    if inlist(Percentile,5), ///
    vce(cluster countrycode_enc) coeflegend

graph set window fontface "Helvetica"

foreach m in m1 m2_1 m2_2 m2_3 m2_4 m2_5 m3 m4_1 m4_2 {
    est restore `m'
    local `m'_N = e(N)
}

coefplot ///
    (m1, keep(Surveyyear2) ///
        rename(Surveyyear2 = m1_year)) ///
	(m3, keep(Surveyyear2 1.post2019#c.Surveyyear2) ///
        rename(Surveyyear2                = m3_year ///
               1.post2019#c.Surveyyear2 = m3_postyear)) ///
    (m2_1, keep(Surveyyear2) ///
        rename(Surveyyear2         = m2_1_year ///
               c.Surveyyear2 = m2_1_q1year)) ///
	(m2_2, keep(Surveyyear2) ///
        rename(Surveyyear2         = m2_2_year ///
               c.Surveyyear2 = m2_2_q1year)) ///
	(m2_3, keep(Surveyyear2) ///
        rename(Surveyyear2         = m2_3_year ///
               c.Surveyyear2 = m2_3_q1year)) ///
	(m2_4, keep(Surveyyear2) ///
        rename(Surveyyear2         = m2_4_year ///
               c.Surveyyear2 = m2_4_q1year)) ///
	(m2_5, keep(Surveyyear2) ///
        rename(Surveyyear2         = m2_5_year ///
               c.Surveyyear2 = m2_5_q1year)) ///
    (m4_1, keep(Surveyyear2 c.Surveyyear2 ///
              1.post2019#c.Surveyyear2) ///
        rename(Surveyyear2                         = m4_1_year ///
               1.post2019#c.Surveyyear2        = m4_1_postyear)) ///
	(m4_2, keep(Surveyyear2 c.Surveyyear2 ///
              1.post2019#c.Surveyyear2) ///
        rename(Surveyyear2                         = m4_2_year ///
               1.post2019#c.Surveyyear2        = m4_2_postyear)) ///
    , horizontal ///
    legend(off) ///
    order( ///
        m1_year ///
        m3_year m3_postyear ///
		m2_1_year m2_2_year m2_3_year m2_4_year m2_5_year ///
        m4_1_year m4_1_postyear m4_2_year m4_2_postyear ///
    ) ///
    coeflabels( ///
        m1_year      = "Year" ///
		m3_year      = "Year" ///
        m3_postyear  = "Post 2019 × Year" ///
        m2_1_year      = "Q1 (bottom)" ///
        m2_2_year    = "Q2" ///
		m2_3_year    = "Q3" ///
		m2_4_year    = "Q4" ///
		m2_5_year    = "Q5 (top)" ///
        m4_1_year    = "Q1" ///
        m4_1_postyear  = "Q1 × Post 2019" ///
		m4_2_year    = "Q5" ///
        m4_2_postyear  = "Q5 × Post 2019" ///
    , labsize(6pt)) ///
    headings( ///
        m1_year = "{bf:(1) Pooled}" ///
		m3_year = "{bf:(2) Pooled}" ///
        m2_1_year = "{bf:(3) Quintiles}" ///
        m4_1_year = "{bf:(4) Quintiles}" ///
    , labsize(7pt)) ///
    mlabel(cond(@pval<.01, string(@b,"%9.3f") + "***", ///
           cond(@pval<.05, string(@b,"%9.3f") + "**", ///
           cond(@pval<.1,  string(@b,"%9.3f") + "*",  string(@b,"%9.3f"))))) ///
    mlabposition(11) mlabgap(*1) mlabsize(5pt) mlabcolor(black) ///
    ciopts(recast(rcap) lcolor(midblue)) ///
    msymbol(O) mcolor(midblue) ///
    xline(0, lpattern(dash) lcolor(gs8)) ///
    xtitle("Estimated change in FES per year (pp)", size(7pt)) ///
    ytitle("") ///
    title("")  ///
	text(1 0.7 "{it:n = `m1_N'}" 4 0.7 "{it:n = `m3_N'}" 9 0.7 "{it:n = `m2_1_N'}" 10 0.7 "{it:n = `m2_2_N'}" 11 0.7 "{it:n = `m2_3_N'}"  12 0.7 "{it:n = `m2_4_N'}"  13 0.7 "{it:n = `m2_5_N'}"  16 0.7 "{it:n = `m4_1_N'}" 18 0.7 "{it:n = `m4_2_N'}", size(4pt)) ///
	subtitle("{bf:a}", size(10pt) position(11) span) ///
    scheme(cleanplots) xsize(8cm) ysize(7cm)

graph export "${graphdir}/Figure4a.png", replace
graph export "${graphdir}/Figure4a.pdf", replace

eststo m1_eqwgts: reg FES i.country_quintile c.Surveyyear2 ///
    [aw=w_country_inverse_waves], vce(cluster countrycode_enc)

eststo m3_eqwgts: reg FES i.country_quintile c.Surveyyear2##i.post2019 ///
    [aw=w_country_inverse_waves], vce(cluster countrycode_enc)

eststo m2_1_eqwgts: reg FES i.countrycode_enc c.Surveyyear2 ///
    if Percentile == 1 [aw=w_country_inverse_waves], ///
    vce(cluster countrycode_enc)
eststo m2_2_eqwgts: reg FES i.countrycode_enc c.Surveyyear2 ///
    if Percentile == 2 [aw=w_country_inverse_waves], ///
    vce(cluster countrycode_enc)
eststo m2_3_eqwgts: reg FES i.countrycode_enc c.Surveyyear2 ///
    if Percentile == 3 [aw=w_country_inverse_waves], ///
    vce(cluster countrycode_enc)
eststo m2_4_eqwgts: reg FES i.countrycode_enc c.Surveyyear2 ///
    if Percentile == 4 [aw=w_country_inverse_waves], ///
    vce(cluster countrycode_enc)
eststo m2_5_eqwgts: reg FES i.countrycode_enc c.Surveyyear2 ///
    if Percentile == 5 [aw=w_country_inverse_waves], ///
    vce(cluster countrycode_enc)

eststo m4_1_eqwgts: reg FES i.countrycode_enc c.Surveyyear2##i.post2019 ///
    if Percentile == 1 [aw=w_country_inverse_waves], ///
    vce(cluster countrycode_enc)
eststo m4_2_eqwgts: reg FES i.countrycode_enc c.Surveyyear2##i.post2019 ///
    if Percentile == 5 [aw=w_country_inverse_waves], ///
    vce(cluster countrycode_enc)

foreach m in m1_eqwgts m2_1_eqwgts m2_2_eqwgts m2_3_eqwgts ///
    m2_4_eqwgts m2_5_eqwgts m3_eqwgts m4_1_eqwgts m4_2_eqwgts {
    est restore `m'
    local `m'_N = e(N)
}

coefplot ///
    (m1_eqwgts, keep(Surveyyear2) ///
        rename(Surveyyear2 = m1_year)) ///
	(m3_eqwgts, keep(Surveyyear2 1.post2019#c.Surveyyear2) ///
        rename(Surveyyear2                = m3_year ///
               1.post2019#c.Surveyyear2 = m3_postyear)) ///
    (m2_1_eqwgts, keep(Surveyyear2) ///
        rename(Surveyyear2 = m2_1_year)) ///
	(m2_2_eqwgts, keep(Surveyyear2) ///
        rename(Surveyyear2 = m2_2_year)) ///
	(m2_3_eqwgts, keep(Surveyyear2) ///
        rename(Surveyyear2 = m2_3_year)) ///
	(m2_4_eqwgts, keep(Surveyyear2) ///
        rename(Surveyyear2 = m2_4_year)) ///
	(m2_5_eqwgts, keep(Surveyyear2) ///
        rename(Surveyyear2 = m2_5_year)) ///
    (m4_1_eqwgts, keep(Surveyyear2 1.post2019#c.Surveyyear2) ///
        rename(Surveyyear2                  = m4_1_year ///
               1.post2019#c.Surveyyear2    = m4_1_postyear)) ///
	(m4_2_eqwgts, keep(Surveyyear2 1.post2019#c.Surveyyear2) ///
        rename(Surveyyear2                  = m4_2_year ///
               1.post2019#c.Surveyyear2    = m4_2_postyear)) ///
    , horizontal ///
    legend(off) ///
    order( ///
        m1_year ///
        m3_year m3_postyear ///
		m2_1_year m2_2_year m2_3_year m2_4_year m2_5_year ///
        m4_1_year m4_1_postyear m4_2_year m4_2_postyear ///
    ) ///
    coeflabels( ///
        m1_year       = "Year" ///
		m3_year       = "Year" ///
        m3_postyear   = "Post 2019 × Year" ///
        m2_1_year     = "Q1 (bottom)" ///
        m2_2_year     = "Q2" ///
		m2_3_year     = "Q3" ///
		m2_4_year     = "Q4" ///
		m2_5_year     = "Q5 (top)" ///
        m4_1_year     = "Q1" ///
        m4_1_postyear = "Q1 × Post 2019" ///
		m4_2_year     = "Q5" ///
        m4_2_postyear = "Q5 × Post 2019" ///
    , labsize(6pt)) ///
    headings( ///
        m1_year   = "{bf:(1) Pooled}" ///
		m3_year   = "{bf:(2) Pooled}" ///
        m2_1_year = "{bf:(3) Quintiles}" ///
        m4_1_year = "{bf:(4) Quintiles}" ///
    , labsize(7pt)) ///
    mlabel(cond(@pval<.01, string(@b,"%9.3f") + "***", ///
           cond(@pval<.05, string(@b,"%9.3f") + "**", ///
           cond(@pval<.1,  string(@b,"%9.3f") + "*",  string(@b,"%9.3f"))))) ///
    mlabposition(11) mlabgap(*1) mlabsize(5pt) mlabcolor(black) ///
    ciopts(recast(rcap) lcolor(midblue)) ///
    msymbol(O) mcolor(midblue) ///
    xline(0, lpattern(dash) lcolor(gs8)) ///
    xtitle("Estimated change in FES per year (pp)", size(7pt)) ///
    ytitle("") ///
    title("")  ///
	text(1 0.7 "{it:n = `m1_eqwgts_N'}" 4 0.7 "{it:n = `m3_eqwgts_N'}" 9 0.7 "{it:n = `m2_1_eqwgts_N'}" 10 0.7 "{it:n = `m2_2_eqwgts_N'}" 11 0.7 "{it:n = `m2_3_eqwgts_N'}"  12 0.7 "{it:n = `m2_4_eqwgts_N'}"  13 0.7 "{it:n = `m2_5_eqwgts_N'}"  16 0.7 "{it:n = `m4_1_eqwgts_N'}" 18 0.7 "{it:n = `m4_2_eqwgts_N'}", size(4pt)) ///
	subtitle("{bf:a}", size(10pt) position(11) span) ///
    scheme(cleanplots) xsize(8cm) ysize(7cm)

graph export "${graphdir}/FigureS6a.png", replace
graph export "${graphdir}/FigureS6a.pdf", replace

local groups "1 LIC 2 LMIC 3 UMIC 4 HIC"

foreach g in `groups' {
}

tokenize "`groups'"
while "`1'" != "" {
    local code `1'
    local lab  `2'
    macro shift 2

    eststo `lab'_pool: reg FES i.country_quintile ///
        c.Surveyyear2 ///
        if incomelevel2==`code', ///
        vce(cluster countrycode_enc)

    eststo `lab'_Q1: reg FES i.countrycode_enc ///
        c.Surveyyear2 ///
        if inlist(Percentile,1) & incomelevel2==`code', ///
        vce(cluster countrycode_enc)

	eststo `lab'_Q5: reg FES i.countrycode_enc ///
        c.Surveyyear2 ///
        if inlist(Percentile,5) & incomelevel2==`code', ///
        vce(cluster countrycode_enc)
}

graph set window fontface "Helvetica"

local groups "1 LIC 2 LMIC 3 UMIC 4 HIC"

tokenize "`groups'"
while "`1'" != "" {
	local code `1'
    local lab  `2'
    macro shift 2

   count if incomelevel2 == `code'
   local `lab'_N = r(N)
}

coefplot ///
    (LIC_pool, keep(Surveyyear2) ///
		rename(Surveyyear2 = lic_year)) ///
	(LIC_Q1,  keep(Surveyyear2 c.Surveyyear2) ///
        rename(Surveyyear2 = lic_q1_year)) ///
	(LIC_Q5,  keep(Surveyyear2 c.Surveyyear2) ///
        rename(Surveyyear2 = lic_q5_year)) ///
    (LMIC_pool,  keep(Surveyyear2)  ///
		rename(Surveyyear2 = lmic_year)) ///
	(LMIC_Q1,  keep(Surveyyear2 c.Surveyyear2) ///
        rename(Surveyyear2 = lmic_q1_year)) ///
	(LMIC_Q5,  keep(Surveyyear2 c.Surveyyear2) ///
        rename(Surveyyear2 = lmic_q5_year)) ///
    (UMIC_pool,  keep(Surveyyear2)  ///
		rename(Surveyyear2 = umic_year)) ///
	(UMIC_Q1,  keep(Surveyyear2 c.Surveyyear2) ///
        rename(Surveyyear2 = umic_q1_year)) ///
	(UMIC_Q5,  keep(Surveyyear2 c.Surveyyear2) ///
        rename(Surveyyear2 = umic_q5_year)) ///
    (HIC_pool,  keep(Surveyyear2)  ///
		rename(Surveyyear2 = hic_year)) ///
	(HIC_Q1,  keep(Surveyyear2 c.Surveyyear2) ///
        rename(Surveyyear2 = hic_q1_year)) ///
	(HIC_Q5,  keep(Surveyyear2 c.Surveyyear2) ///
        rename(Surveyyear2 = hic_q5_year)) ///
    , horizontal ///
	legend(off) ///
	mlabel(cond(@pval<.01, string(@b,"%9.3f") + "***", cond(@pval<.05, string(@b,"%9.3f") + "**", cond(@pval<.1, string(@b,"%9.3f") + "*", string(@b,"%9.3f"))))) ///
	format(%9.2f) mlabposition(11) mlabgap(*1) mlabsize(5pt) mlabcolor(black) ///
    xline(0, lpattern(dash) lcolor(gs8)) ///
    xtitle("Estimated change in FES per year (pp)") ///
    ytitle("") ///
    ciopts(recast(rcap) lcolor(midblue)) ///
    msymbol(O) mcolor(midblue) ///
	 coeflabels( ///
        lic_year  = "Pooled"  lic_q1_year  = "Q1"      lic_q5_year  = "Q5" ///
        lmic_year  = "Pooled"  lmic_q1_year   = "Q1"      lmic_q5_year   = "Q5" ///
        umic_year  = "Pooled"  umic_q1_year   = "Q1"      umic_q5_year   = "Q5" ///
        hic_year  = "Pooled"  hic_q1_year   = "Q1"      hic_q5_year   = "Q5" ///
    , labsize(6pt)) ///
    headings( ///
        lic_year  = "{bf:LICs}" ///
        lmic_year   = "{bf:LMICs}" ///
        umic_year   = "{bf:UMICs}" ///
        hic_year   = "{bf:HICs}" ///
    , labsize(7pt)) ///
	subtitle("{bf:b}", size(10pt) position(11) span) ///
	text(2 0.5 "{it:n = `LIC_N'}" 7 0.5 "{it:n = `LMIC_N'}" 12 0.5 "{it:n = `UMIC_N'}" 17 0.5 "{it:n = `HIC_N'}", size(5pt)) ///
    scheme(cleanplots) name(g1, replace) ///
    xsize(8cm) ysize(7cm)

graph export "${graphdir}/Figure4b.png", replace
graph export "${graphdir}/Figure4b.pdf", replace

local groups "1 LIC 2 LMIC 3 UMIC 4 HIC"

tokenize "`groups'"
while "`1'" != "" {
	local code `1'
    local lab  `2'
    macro shift 2

    eststo `lab'_pool_eqwgts: reg FES i.country_quintile ///
        c.Surveyyear2 if incomelevel2 == `code' ///
        [aw=w_country_inverse_waves], vce(cluster countrycode_enc)

    eststo `lab'_Q1_eqwgts: reg FES i.countrycode_enc ///
        c.Surveyyear2 if Percentile == 1 & incomelevel2 == `code' ///
        [aw=w_country_inverse_waves], vce(cluster countrycode_enc)

	eststo `lab'_Q5_eqwgts: reg FES i.countrycode_enc ///
        c.Surveyyear2 if Percentile == 5 & incomelevel2 == `code' ///
        [aw=w_country_inverse_waves], vce(cluster countrycode_enc)
}

coefplot ///
    (LIC_pool_eqwgts, keep(Surveyyear2) ///
		rename(Surveyyear2 = lic_year)) ///
	(LIC_Q1_eqwgts, keep(Surveyyear2) ///
        rename(Surveyyear2 = lic_q1_year)) ///
	(LIC_Q5_eqwgts, keep(Surveyyear2) ///
        rename(Surveyyear2 = lic_q5_year)) ///
    (LMIC_pool_eqwgts, keep(Surveyyear2) ///
		rename(Surveyyear2 = lmic_year)) ///
	(LMIC_Q1_eqwgts, keep(Surveyyear2) ///
        rename(Surveyyear2 = lmic_q1_year)) ///
	(LMIC_Q5_eqwgts, keep(Surveyyear2) ///
        rename(Surveyyear2 = lmic_q5_year)) ///
    (UMIC_pool_eqwgts, keep(Surveyyear2) ///
		rename(Surveyyear2 = umic_year)) ///
	(UMIC_Q1_eqwgts, keep(Surveyyear2) ///
        rename(Surveyyear2 = umic_q1_year)) ///
	(UMIC_Q5_eqwgts, keep(Surveyyear2) ///
        rename(Surveyyear2 = umic_q5_year)) ///
    (HIC_pool_eqwgts, keep(Surveyyear2) ///
		rename(Surveyyear2 = hic_year)) ///
	(HIC_Q1_eqwgts, keep(Surveyyear2) ///
        rename(Surveyyear2 = hic_q1_year)) ///
	(HIC_Q5_eqwgts, keep(Surveyyear2) ///
        rename(Surveyyear2 = hic_q5_year)) ///
    , horizontal ///
	legend(off) ///
	mlabel(cond(@pval<.01, string(@b,"%9.3f") + "***", cond(@pval<.05, string(@b,"%9.3f") + "**", cond(@pval<.1, string(@b,"%9.3f") + "*", string(@b,"%9.3f"))))) ///
	format(%9.2f) mlabposition(11) mlabgap(*1) mlabsize(5pt) mlabcolor(black) ///
    xline(0, lpattern(dash) lcolor(gs8)) ///
    xtitle("Estimated change in FES per year (pp)") ///
    ytitle("") ///
    ciopts(recast(rcap) lcolor(midblue)) ///
    msymbol(O) mcolor(midblue) ///
	 coeflabels( ///
        lic_year  = "Pooled"  lic_q1_year  = "Q1"      lic_q5_year  = "Q5" ///
        lmic_year = "Pooled"  lmic_q1_year = "Q1"      lmic_q5_year = "Q5" ///
        umic_year = "Pooled"  umic_q1_year = "Q1"      umic_q5_year = "Q5" ///
        hic_year  = "Pooled"  hic_q1_year  = "Q1"      hic_q5_year  = "Q5" ///
    , labsize(6pt)) ///
    headings( ///
        lic_year  = "{bf:LICs}" ///
        lmic_year = "{bf:LMICs}" ///
        umic_year = "{bf:UMICs}" ///
        hic_year  = "{bf:HICs}" ///
    , labsize(7pt)) ///
	subtitle("{bf:b}", size(10pt) position(11) span) ///
	text(2 1 "{it:n = `LIC_N'}" 7 1 "{it:n = `LMIC_N'}" 12 1 "{it:n = `UMIC_N'}" 17 1 "{it:n = `HIC_N'}", size(5pt)) ///
    scheme(cleanplots) name(g1_eqwgts, replace) ///
    xsize(8cm) ysize(7cm)

graph export "${graphdir}/FigureS6b.png", replace
graph export "${graphdir}/FigureS6b.pdf", replace

use "${datadir}/FESdatabase_quintiles.dta", clear
append using "${datadir}/FESdatabase_deciles.dta"

bysort countrycode year: gen _tag = _n==1
bysort countrycode: egen n_years = total(_tag)
gen dummy_3years = n_years >= 3
drop _tag n_years

gen EUROSTAT = 1 if  ///
		inlist(Country,"Austria","Belgium","Bulgaria","Croatia","Cyprus","Czech","Denmark","Estonia","Finland")  | ///
		inlist(Country,"France","Germany","Greece","Hungary","Ireland","Latvia","Lithuania","Luxembourg")  | ///
		inlist(Country,"Malta","Netherlands","North Macedonia","Norway","Poland","Portugal","Romania","Slovakia")  | ///
		inlist(Country,"Slovenia","Spain","Sweden","Türkiye","United Kingdom")

bysort countrycode year: egen FES_p1 = max(cond(Percentile==1, FES, .)) if inlist(Incomegroups,"Quintiles")
bysort countrycode year: egen FES_p5 = max(cond(Percentile==5, FES, .)) if inlist(Incomegroups,"Quintiles")
gen FES_gap = FES_p1 - FES_p5 if inlist(Incomegroups,"Quintiles")

preserve
keep if EUROSTAT == . & dummy_3years == 1
graph set window fontface "Helvetica"
twoway ///
	line FES Surveyyear2 if Percentile==1 & inlist(Incomegroups,"Deciles"), lwidth(medthick) lcolor(red*0.3) || ///
    line FES Surveyyear2 if Percentile==10 & inlist(Incomegroups,"Deciles"), lwidth(medthick) lcolor(blue*0.3)  || ///
	scatter FES Surveyyear2 if Percentile==1 & inlist(Incomegroups,"Deciles"), msize(vsmall) mcolor(gs10) lcolor(red) || ///
    scatter FES Surveyyear2 if Percentile==10 & inlist(Incomegroups,"Deciles"), msize(vsmall) mcolor(gs10) lcolor(blue)  || ///
	line FES_gap Surveyyear2 if inlist(Incomegroups,"Quintiles"), lwidth(medthick) lcolor(green*0.5)  || ///
    line FES Surveyyear2 if Percentile==1 & inlist(Incomegroups,"Quintiles"), lwidth(medthick) lcolor(red) || ///
    line FES Surveyyear2 if Percentile==5 & inlist(Incomegroups,"Quintiles"), lwidth(medthick) lcolor(blue)  || ///
	scatter FES Surveyyear2 if Percentile==1 & inlist(Incomegroups,"Quintiles"), msize(vsmall) mcolor(black) lcolor(red) || ///
    scatter FES Surveyyear2 if Percentile==5 & inlist(Incomegroups,"Quintiles"), msize(vsmall) mcolor(black) lcolor(blue)  || ///
    , by(Country, cols(4) note("") imargin(tiny) graphregion(margin(t-3 b-3))) ///
    xtitle("Year", size(8pt)) ///
    ytitle("Mean Food Expenditure Share", size(8pt)) ///
	ylabel(0(15)70) ///
	xlabel(2005(5)2025, angle(40)) ///
    legend(bmargin(zero) size(8pt) rows(2) position(6) order(6 "Q1 (bottom 20%)" 7 "Q5 (top 20%)" 5 "Difference: FES(Q1)-FES(Q5)" 1 "D1 (bottom 10%)" 2 "D10 (top 10%)")) ///
	scheme(cleanplots) xline(2019.5, lcolor(black) lpattern(dash)) xline(2021.5, lcolor(gs10) lpattern(dash))  ysize(20cm) xsize(16cm)

graph export "${graphdir}/FigureS7.png", replace
graph export "${graphdir}/FigureS7.pdf", replace

restore

keep if EUROSTAT == 1 & dummy_3years == 1
graph set window fontface "Helvetica"
twoway ///
	line FES_gap Surveyyear2, lwidth(medthick) lcolor(green*0.5)  || ///
    line FES Surveyyear2 if Percentile==1   , lwidth(medthick) lcolor(red) || ///
    line FES Surveyyear2 if Percentile==5   , lwidth(medthick) lcolor(blue)  || ///
	scatter FES Surveyyear2 if Percentile==1   , msize(vsmall) lcolor(red) || ///
    scatter FES Surveyyear2 if Percentile==5   , msize(vsmall) lcolor(blue)  || ///
    , by(Country, cols(4) note("") imargin(tiny) graphregion(margin(t-3 b-3))) ///
    xtitle("Year", size(8pt)) ///
    ytitle("Mean Food Expenditure Share", size(8pt)) ///
	ylabel(0(15)70) ///
	xlabel(2005(5)2020, angle(40)) ///
    legend(size(8pt) rows(1) position(6) order(2 "Q1 (bottom 20%)" 3 "Q5 (top 20%)" 1 "Difference: FES(Q1)-FES(Q5)")) ///
	scheme(cleanplots) xline(2019.5, lcolor(black) lpattern(dash))  ysize(15cm) xsize(16cm)

graph export "${graphdir}/FigureS8.png", replace
graph export "${graphdir}/FigureS8.pdf", replace
