********************************************************************************
*								Analysis: Time									*
********************************************************************************

********************************************************************************
* Figure 3	
********************************************************************************

use "${datadir}/FESdatabase_quintiles.dta", clear
merge m:1 countrycode year using "${datadir}/aux data/WDI.dta", keep(match master) keepusing(incomelevel regionname) nogen // only Argentina (1996), Bhutan (2025), Turkmenistan (1998), Japan(2025), Korea (2025) not matched
replace incomelevel = "UMC" if Country == "Argentina" & incomelevel == ""
replace incomelevel = "LMC" if Country == "Bhutan" & incomelevel == ""
replace incomelevel = "HIC" if Country == "Japan" & incomelevel == ""
replace incomelevel = "HIC" if Country == "Korea" & incomelevel == ""
replace incomelevel = "UMC" if Country == "Turkmenistan" & incomelevel == ""
replace incomelevel = "LIC" if Country == "Ethiopia" & incomelevel == "INX" 
replace regionname = "Latin America and Caribbean" if Country == "Argentina"  
replace regionname = "South Asia" if Country == "Bhutan" 
replace regionname = "East Asia and Pacific" if Country == "Japan" 
replace regionname = "East Asia and Pacific" if Country == "Korea" 
replace regionname = "Central Asia and South Caucasus" if Country == "Turkmenistan" 

replace regionname = "Central Asia and South Caucasus" if inlist(Country,"Kazakhstan", "Kyrgyzstan", "Tajikistan", "Uzbekistan","Armenia","Azerbaijan","Georgia") // assign countries to Central Asia
replace regionname = "Europe" if regionname == "Europe and Central Asia"

encode countrycode, gen(countrycode_enc)
encode incomelevel, gen(incomelevel_enc)
recode incomelevel_enc (1=4 "HIC") (2=1 "LIC") (3=2 "LMIC") (4=3 "UMIC"), gen(incomelevel2)
drop incomelevel_enc

// preparation of variables
gen Q1 = 0 
replace Q1 = 1 if Percentile == 1

gen post_covid = 0
replace post_covid = 1 if Surveyyear2 > 2019.5 & Surveyyear2 < .

* Country weights:
bysort countrycode_enc: gen n_obs = _N
gen w_country = 1 / n_obs 
drop n_obs

 
* Run and store the four models
eststo clear

* (1) Levels + common trend + quintile FE
eststo m1: reg FES i.countrycode_enc c.Surveyyear2 i.Percentile, ///
    vce(cluster countrycode_enc) 

* (2) Rich vs poor only: differential trend for Q1 (sample: P1 or P5)
eststo m2: reg FES i.countrycode_enc c.Surveyyear2##i.Q1 ///
    if inlist(Percentile,1,5), ///
    vce(cluster countrycode_enc)

* (3) Levels + quintile FE + COVID level + COVID slope change
eststo m3: reg FES i.countrycode_enc i.Percentile c.Surveyyear2##i.post_covid, ///
    vce(cluster countrycode_enc)

* (4) Rich vs poor only: COVID interactions with Q1 (sample: P1 or P5)
eststo m4: reg FES i.countrycode_enc c.Surveyyear2##i.post_covid##i.Q1 ///
    if inlist(Percentile,1,5), ///
    vce(cluster countrycode_enc) coeflegend


esttab m1 m2 m3 m4 using "${workdir}/tables/FES_time_regressions_p.rtf", replace ///
    b(%9.3f) p(%9.3f) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    label ///
    mtitles("Baseline + quintile FE" ///
            "Poor vs rich trend" ///
            "COVID break + quintile FE" ///
            "COVID break: poor vs rich") ///
    keep(Surveyyear2 ///
         1.Q1#c.Surveyyear2 ///
         1.post_covid#c.Surveyyear2 ///
         1.post_covid#1.Q1#c.Surveyyear2) ///
    order(Surveyyear2 1.Q1#c.Surveyyear2 ///
          1.post_covid#c.Surveyyear2  ///
          1.post_covid#1.Q1#c.Surveyyear2) ///
	indicate("Country FE = *.countrycode_enc" ///
             "Quintile FE = *.Percentile") ///
    stats(N r2, fmt(%9.0f %9.3f) labels("Observations" "R-squared")) ///
    addnotes("Country fixed effects included but not reported.", ///
             "Standard errors clustered by country.", ///
             "Models 2 and 4 use Percentile ∈ {1,5} only.")			 

graph set window fontface "Helvetica" 

foreach m in m1 m2 m3 m4 {
    est restore `m'
    local `m'_N = e(N)
}

coefplot ///
    (m1, keep(Surveyyear2) ///
        rename(Surveyyear2 = m1_year)) ///
	(m3, keep(Surveyyear2 1.post_covid#c.Surveyyear2) ///
        rename(Surveyyear2                = m3_year ///
               1.post_covid#c.Surveyyear2 = m3_postyear)) ///
    (m2, keep(Surveyyear2 1.Q1#c.Surveyyear2) ///
        rename(Surveyyear2         = m2_year ///
               1.Q1#c.Surveyyear2 = m2_q1year)) ///
    (m4, keep(Surveyyear2 1.Q1#c.Surveyyear2 ///
              1.post_covid#c.Surveyyear2 ///
              1.post_covid#1.Q1#c.Surveyyear2) ///
        rename(Surveyyear2                         = m4_year ///
               1.Q1#c.Surveyyear2                = m4_q1year ///
               1.post_covid#c.Surveyyear2        = m4_postyear ///
               1.post_covid#1.Q1#c.Surveyyear2   = m4_postq1year)) ///
    , horizontal ///
    legend(off) ///
    order( ///
        m1_year ///
        m3_year m3_postyear ///
		m2_year m2_q1year ///
        m4_year m4_q1year m4_postyear m4_postq1year ///
    ) ///
    coeflabels( ///
        m1_year      = "Year" ///
		m3_year      = "Year" ///
        m3_postyear  = "Post 2019 × Year" ///
        m2_year      = "Year" ///
        m2_q1year    = "Q1 × Year" ///
        m4_year      = "Year" ///
        m4_q1year    = "Q1 × Year" ///
        m4_postyear  = "Post 2019 × Year" ///
        m4_postq1year = "Post 2019 × Q1 × Year" ///
    ) ///
    headings( ///
        m1_year = "{bf:(1) Pooled}" ///
		m3_year = "{bf:(2) Pooled}" ///
        m2_year = "{bf:(3) Q1 vs Q5}" ///
        m4_year = "{bf:(4) Q1 vs Q5}" ///
    ) ///
    mlabel(cond(@pval<.01, string(@b,"%9.3f") + "***", ///
           cond(@pval<.05, string(@b,"%9.3f") + "**", ///
           cond(@pval<.1,  string(@b,"%9.3f") + "*",  string(@b,"%9.3f"))))) ///
    mlabposition(11) mlabgap(*1) mlabsize(4pt) mlabcolor(black) ///
    ciopts(recast(rcap) lcolor(midblue)) ///
    msymbol(O) mcolor(midblue) ///
    xline(0, lpattern(dash) lcolor(gs8)) ///
    xtitle("Estimated change in FES per year", size(7pt)) ///
    ytitle("") ///
    title("") ///
	text(1 1.8 "{it:n = `m1_N'}" 4 1.8 "{it:n = `m3_N'}" 8 1.8 "{it:n = `m2_N'}" 12 1.8 "{it:n = `m4_N'}", size(4pt)) ///
    scheme(cleanplots) xsize(9cm) ysize(5cm)

graph export "${workdir}/graphs/Figure3.png", replace
graph export "${workdir}/graphs/Figure3.pdf", replace



********************************************************************************
* Figure S6
********************************************************************************

* Helper locals
local groups "1 LIC 2 LMIC 3 UMIC 4 HIC"

* (A) Pooled within income group
foreach g in `groups' {
}

* Parse triplets:
tokenize "`groups'"
while "`1'" != "" {
    local code `1'
    local lab  `2'
    macro shift 2

    eststo `lab'_pool: reg FES i.countrycode_enc i.Percentile ///
        c.Surveyyear2 ///
        if incomelevel2==`code', ///
        vce(cluster countrycode_enc)

    eststo `lab'_Q1Q5: reg FES i.countrycode_enc ///
        c.Surveyyear2##i.Q1 ///
        if inlist(Percentile,1,5) & incomelevel2==`code', ///
        vce(cluster countrycode_enc)
}

esttab ///
    LIC_pool LIC_Q1Q5 ///
    LMIC_pool LMIC_Q1Q5 ///
    UMIC_pool UMIC_Q1Q5 ///
    HIC_pool HIC_Q1Q5 ///
    using "${workdir}/tables/FES_slopes_by_income_8cols.rtf", replace ///
	b(%9.3f) p(%9.3f) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    mtitles("LIC: pooled" "LIC: Q1 vs Q5" ///
            "LMIC: pooled" "LMIC: Q1 vs Q5" ///
            "UMIC: pooled" "UMIC: Q1 vs Q5" ///
            "HIC: pooled" "HIC: Q1 vs Q5") ///
    keep(Surveyyear2 1.Q1#c.Surveyyear2) ///
    order(Surveyyear2 1.Q1#c.Surveyyear2) ///
    indicate("Country FE = *.countrycode_enc" ///
             "Quintile FE = *.Percentile") ///
    stats(N r2, fmt(%9.0f %9.3f) labels("Observations" "R-squared")) ///
    addnotes("Each column estimated on the indicated income-group subsample.", ///
             "Country fixed effects included but not reported.", ///
             "Pooled columns include quintile fixed effects (not reported).", ///
             "Standard errors clustered by country (countrycode_enc).")

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
    (LIC_pool, keep(Surveyyear2) rename(Surveyyear2 = LIC)) ///
    (LMIC_pool,  keep(Surveyyear2) rename(Surveyyear2 = LMIC)) ///
    (UMIC_pool,  keep(Surveyyear2) rename(Surveyyear2 = UMIC)) ///
    (HIC_pool,  keep(Surveyyear2) rename(Surveyyear2 = HIC)) ///
    , horizontal ///
	legend(off) ///
	mlabel(cond(@pval<.01, string(@b,"%9.3f") + "***", cond(@pval<.05, string(@b,"%9.3f") + "**", cond(@pval<.1, string(@b,"%9.3f") + "*", string(@b,"%9.3f"))))) ///
	format(%9.2f) mlabposition(2) mlabgap(*1) mlabsize(5pt) mlabcolor(black) ///
    xline(0, lpattern(dash) lcolor(gs8)) ///
    xtitle("Time trend in FES") ///
    ytitle("") ///
	title("Pooled") ///
    ciopts(recast(rcap) lcolor(midblue)) ///
    msymbol(O) mcolor(midblue) ///
	subtitle("{bf:a}", size(10pt) position(11) span) ///
	text(1 1 "{it:n = `LIC_N'}" 5 1 "{it:n = `LMIC_N'}" 9 1 "{it:n = `UMIC_N'}" 13 1 "{it:n = `HIC_N'}", size(5pt)) ///
    scheme(cleanplots) name(g1, replace)
	
// interaction	
local groups "1 LIC 2 LMIC 3 UMIC 4 HIC"

tokenize "`groups'"
while "`1'" != "" {
	local code `1'
    local lab  `2'
    macro shift 2
	
   count if incomelevel2 == `code' & inlist(Percentile,1,5) 
   local `lab'_N = r(N)
}
	
coefplot ///
    (LIC_Q1Q5,  keep(Surveyyear2 1.Q1#c.Surveyyear2) ///
        rename(Surveyyear2 = lic_year 1.Q1#c.Surveyyear2 = lic_q1year)) ///
    (LMIC_Q1Q5,   keep(Surveyyear2 1.Q1#c.Surveyyear2) ///
        rename(Surveyyear2 = lmic_year  1.Q1#c.Surveyyear2 = lmic_q1year)) ///
    (UMIC_Q1Q5,   keep(Surveyyear2 1.Q1#c.Surveyyear2) ///
        rename(Surveyyear2 = umic_year  1.Q1#c.Surveyyear2 = umic_q1year)) ///
    (HIC_Q1Q5,   keep(Surveyyear2 1.Q1#c.Surveyyear2) ///
        rename(Surveyyear2 = hic_year  1.Q1#c.Surveyyear2 = hic_q1year)) ///
    , horizontal ///
    legend(off) ///
	mlabel(cond(@pval<.01, string(@b,"%9.3f") + "***", cond(@pval<.05, string(@b,"%9.3f") + "**", cond(@pval<.1, string(@b,"%9.3f") + "*", string(@b,"%9.3f"))))) ///
	format(%9.2f) mlabposition(2) mlabgap(*1) mlabsize(5pt) mlabcolor(black) ///
    coeflabels( ///
        lic_year  = "Year"      lic_q1year  = "Q1 × Year" ///
        lmic_year   = "Year"      lmic_q1year   = "Q1 × Year" ///
        umic_year   = "Year"      umic_q1year   = "Q1 × Year" ///
        hic_year   = "Year"      hic_q1year   = "Q1 × Year" ///
    , labsize(6pt)) ///
    headings( ///
        lic_year  = "LIC" ///
        lmic_year   = "LMIC" ///
        umic_year   = "UMIC" ///
        hic_year   = "HIC" ///
    , labsize(8pt)) ///
    xline(0, lpattern(dash) lcolor(gs8)) ///
    xtitle("Time trend in Q1 FES compared to Q5 FES", size(7pt)) ///
    ytitle("") ///
	title("Q1 versus Q5", size(7pt)) ///
    ciopts(recast(rcap) lcolor(midblue)) ///
    msymbol(O) mcolor(midblue) ///
    subtitle("{bf:b}", size(10pt) position(11) span) ///
	text(1 1 "{it:n = `LIC_N'}" 5 1 "{it:n = `LMIC_N'}" 9 1 "{it:n = `UMIC_N'}" 13 1 "{it:n = `HIC_N'}", size(5pt)) ///
    scheme(cleanplots) name(g2, replace)
	
graph combine g1 g2, graphregion(color(white)) rows(1) ysize(3) xsize(6)
	
graph export "${workdir}/graphs/FigureS6.png", replace
graph export "${workdir}/graphs/FigureS6.pdf", replace



********************************************************************************
* Figure S7
********************************************************************************

encode regionname, gen(regionname_enc)
local groups "1 CASC 2 EAP 3 EUR 4 LAC 5 MENAP 6 NAM 7 SAS 8 SSA"

* (A) Pooled within region
tokenize "`groups'"
while "`1'" != "" {
    local code `1'
    local lab  `2'
    macro shift 2

    eststo `lab'_pool: reg FES i.countrycode_enc i.Percentile ///
        c.Surveyyear2 ///
        if regionname_enc == `code', ///
        vce(cluster countrycode_enc)

    eststo `lab'_Q1Q5: reg FES i.countrycode_enc ///
        c.Surveyyear2##i.Q1 ///
        if inlist(Percentile,1,5) & regionname_enc == `code', ///
        vce(cluster countrycode_enc)
}

esttab ///
    CASC_pool CASC_Q1Q5 ///
    EAP_pool  EAP_Q1Q5  ///
    EUR_pool  EUR_Q1Q5  ///
    LAC_pool  LAC_Q1Q5  ///
    MENAP_pool MENAP_Q1Q5 ///
    NAM_pool  NAM_Q1Q5  ///
    SAS_pool  SAS_Q1Q5  ///
    SSA_pool  SSA_Q1Q5  ///
    using "${workdir}/tables/FES_slopes_by_region_16cols.rtf", replace ///
    b(%9.3f) p(%9.3f) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    mtitles("CASC: pooled" "CASC: Q1 vs Q5" ///
            "EAP: pooled"  "EAP: Q1 vs Q5"  ///
            "EUR: pooled"  "EUR: Q1 vs Q5"  ///
            "LAC: pooled"  "LAC: Q1 vs Q5"  ///
            "MENAP: pooled" "MENAP: Q1 vs Q5" ///
            "NAM: pooled"  "NAM: Q1 vs Q5"  ///
            "SAS: pooled"  "SAS: Q1 vs Q5"  ///
            "SSA: pooled"  "SSA: Q1 vs Q5") ///
    keep(Surveyyear2 1.Q1#c.Surveyyear2) ///
    order(Surveyyear2 1.Q1#c.Surveyyear2) ///
    indicate("Country FE = *.countrycode_enc" ///
             "Quintile FE = *.Percentile") ///
    stats(N r2, fmt(%9.0f %9.3f) labels("Observations" "R-squared")) ///
    addnotes("Each column estimated on the indicated regional subsample.", ///
             "Country fixed effects included but not reported.", ///
             "Pooled columns include quintile fixed effects (not reported).", ///
             "Standard errors clustered by country (countrycode_enc).")
			 
graph set window fontface "Helvetica" 

local groups "1 CASC 2 EAP 3 EUR 4 LAC 5 MENAP 6 NAM 7 SAS 8 SSA"

tokenize "`groups'"
while "`1'" != "" {
	local code `1'
    local lab  `2'
    macro shift 2
	
   count if regionname_enc == `code'
   local `lab'_N = r(N)
}

coefplot ///
    (CASC_pool, keep(Surveyyear2) rename(Surveyyear2 = CASC)) ///
    (EAP_pool,  keep(Surveyyear2) rename(Surveyyear2 = EAP)) ///
    (EUR_pool,  keep(Surveyyear2) rename(Surveyyear2 = EUR)) ///
    (LAC_pool,  keep(Surveyyear2) rename(Surveyyear2 = LAC)) ///
    (MENAP_pool, keep(Surveyyear2) rename(Surveyyear2 = MENAP)) ///
    (NAM_pool,  keep(Surveyyear2) rename(Surveyyear2 = NAM)) ///
    (SAS_pool,  keep(Surveyyear2) rename(Surveyyear2 = SAS)) ///
    (SSA_pool,  keep(Surveyyear2) rename(Surveyyear2 = SSA)), ///
    horizontal ///
	legend(off) ///
	mlabel(cond(@pval<.01, string(@b,"%9.3f") + "***", cond(@pval<.05, string(@b,"%9.3f") + "**", cond(@pval<.1, string(@b,"%9.3f") + "*", string(@b,"%9.3f"))))) ///
	format(%9.2f) mlabposition(2) mlabgap(*1) mlabsize(5pt) mlabcolor(black) ///
    xline(0, lpattern(dash) lcolor(gs8)) ///
    xtitle("Time trend in FES") ///
    ytitle("") ///
	title("Pooled") ///
    ciopts(recast(rcap) lcolor(midblue)) ///
    msymbol(O) mcolor(midblue) ///
	subtitle("{bf:a}", size(10pt) position(11) span) ///
	text(1 1 "{it:n = `CASC_N'}" 2 1 "{it:n = `EAP_N'}" 3 1 "{it:n = `EUR_N'}" 4 1 "{it:n = `LAC_N'}" 5 1 "{it:n = `MENAP_N'}" 6 1 "{it:n = `NAM_N'}" 7 1 "{it:n = `SAS_N'}" 8 1 "{it:n = `SSA_N'}", size(5pt)) ///
    scheme(cleanplots) name(g1, replace)
		
local groups "1 CASC 2 EAP 3 EUR 4 LAC 5 MENAP 6 NAM 7 SAS 8 SSA"

tokenize "`groups'"
while "`1'" != "" {
	local code `1'
    local lab  `2'
    macro shift 2
	
   count if regionname_enc == `code' & inlist(Percentile,1,5) 
   local `lab'_N = r(N)
}
	
coefplot ///
    (CASC_Q1Q5,  keep(Surveyyear2 1.Q1#c.Surveyyear2) ///
        rename(Surveyyear2 = casc_year 1.Q1#c.Surveyyear2 = casc_q1year)) ///
    (EAP_Q1Q5,   keep(Surveyyear2 1.Q1#c.Surveyyear2) ///
        rename(Surveyyear2 = eap_year  1.Q1#c.Surveyyear2 = eap_q1year)) ///
    (EUR_Q1Q5,   keep(Surveyyear2 1.Q1#c.Surveyyear2) ///
        rename(Surveyyear2 = eur_year  1.Q1#c.Surveyyear2 = eur_q1year)) ///
    (LAC_Q1Q5,   keep(Surveyyear2 1.Q1#c.Surveyyear2) ///
        rename(Surveyyear2 = lac_year  1.Q1#c.Surveyyear2 = lac_q1year)) ///
    (MENAP_Q1Q5, keep(Surveyyear2 1.Q1#c.Surveyyear2) ///
        rename(Surveyyear2 = menap_year 1.Q1#c.Surveyyear2 = menap_q1year)) ///
    (NAM_Q1Q5,   keep(Surveyyear2 1.Q1#c.Surveyyear2) ///
        rename(Surveyyear2 = nam_year  1.Q1#c.Surveyyear2 = nam_q1year)) ///
    (SAS_Q1Q5,   keep(Surveyyear2 1.Q1#c.Surveyyear2) ///
        rename(Surveyyear2 = sas_year  1.Q1#c.Surveyyear2 = sas_q1year)) ///
    (SSA_Q1Q5,   keep(Surveyyear2 1.Q1#c.Surveyyear2) ///
        rename(Surveyyear2 = ssa_year  1.Q1#c.Surveyyear2 = ssa_q1year)), ///
    horizontal ///
    legend(off) ///
	mlabel(cond(@pval<.01, string(@b,"%9.3f") + "***", cond(@pval<.05, string(@b,"%9.3f") + "**", cond(@pval<.1, string(@b,"%9.3f") + "*", string(@b,"%9.3f"))))) ///
	format(%9.2f) mlabposition(2) mlabgap(*1) mlabsize(5pt) mlabcolor(black) ///
    coeflabels( ///
        casc_year  = "Year"      casc_q1year  = "Q1 × Year" ///
        eap_year   = "Year"      eap_q1year   = "Q1 × Year" ///
        eur_year   = "Year"      eur_q1year   = "Q1 × Year" ///
        lac_year   = "Year"      lac_q1year   = "Q1 × Year" ///
        menap_year = "Year"      menap_q1year = "Q1 × Year" ///
        nam_year   = "Year"      nam_q1year   = "Q1 × Year" ///
        sas_year   = "Year"      sas_q1year   = "Q1 × Year" ///
        ssa_year   = "Year"      ssa_q1year   = "Q1 × Year" ///
    , labsize(6pt)) ///
    headings( ///
        casc_year  = "CASC" ///
        eap_year   = "EAP" ///
        eur_year   = "EUR" ///
        lac_year   = "LAC" ///
        menap_year = "MENAP" ///
        nam_year   = "NAM" ///
        sas_year   = "SAS" ///
        ssa_year   = "SSA" ///
    , labsize(8pt)) ///
    xline(0, lpattern(dash) lcolor(gs8)) ///
    xtitle("Time trend in Q1 FES compared to Q5 FES", size(7pt)) ///
    ytitle("") ///
	title("Q1 versus Q5", size(7pt)) ///
    ciopts(recast(rcap) lcolor(midblue)) ///
    msymbol(O) mcolor(midblue) ///
    subtitle("{bf:b}", size(10pt) position(11) span) ///
	text(1 1 "{it:n = `CASC_N'}" 5 1 "{it:n = `EAP_N'}" 9 1 "{it:n = `EUR_N'}" 13 1 "{it:n = `LAC_N'}" 17 1 "{it:n = `MENAP_N'}" 21 1 "{it:n = `NAM_N'}" 25 1 "{it:n = `SAS_N'}" 29 1 "{it:n = `SSA_N'}", size(5pt)) ///
    scheme(cleanplots) name(g2, replace)
	
graph combine g1 g2, graphregion(color(white)) rows(1) ysize(3) xsize(6)
	
graph export "${workdir}/graphs/FigureS7.png", replace
graph export "${workdir}/graphs/FigureS7.pdf", replace

	
********************************************************************************
* Figures S8+S9
********************************************************************************
use "${datadir}/FESdatabase_quintiles.dta", clear
append using "${datadir}/FESdatabase_deciles.dta"

* Selection
drop if year == 1996

// countries with at least 3 observations
bysort countrycode year: gen _tag = _n==1
bysort countrycode: egen n_years = total(_tag)
gen dummy_3years = n_years >= 3
drop _tag n_years


// Eurostat countries
gen EUROSTAT = 1 if /*EUROSTAT Countries */ ///
		inlist(Country,"Austria","Belgium","Bulgaria","Croatia","Cyprus","Czech","Denmark","Estonia","Finland")  | ///
		inlist(Country,"France","Germany","Greece","Hungary","Ireland","Latvia","Lithuania","Luxembourg")  | ///
		inlist(Country,"Malta","Netherlands","North Macedonia","Norway","Poland","Portugal","Romania","Slovakia")  | ///
		inlist(Country,"Slovenia","Spain","Sweden","Türkiye","United Kingdom") 

		
* Generate gap variables
bysort countrycode year: egen FES_p1 = max(cond(Percentile==1, FES, .)) if inlist(Incomegroups,"Quintiles","Quintiles, interpolated")
bysort countrycode year: egen FES_p5 = max(cond(Percentile==5, FES, .)) if inlist(Incomegroups,"Quintiles","Quintiles, interpolated")
gen FES_gap = FES_p1 - FES_p5 if inlist(Incomegroups,"Quintiles","Quintiles, interpolated")
			
preserve	
keep if EUROSTAT == . & dummy_3years == 1 
graph set window fontface "Helvetica"
twoway ///
	line FES Surveyyear2 if Percentile==1 & inlist(Incomegroups,"Deciles"), lwidth(medthick) lcolor(red*0.3) || ///
    line FES Surveyyear2 if Percentile==10 & inlist(Incomegroups,"Deciles"), lwidth(medthick) lcolor(blue*0.3)  || ///
	scatter FES Surveyyear2 if Percentile==1 & inlist(Incomegroups,"Deciles"), msize(vsmall) mcolor(gs10) lcolor(red) || ///
    scatter FES Surveyyear2 if Percentile==10 & inlist(Incomegroups,"Deciles"), msize(vsmall) mcolor(gs10) lcolor(blue)  || ///
	line FES_gap Surveyyear2 if inlist(Incomegroups,"Quintiles","Quintiles, interpolated"), lwidth(medthick) lcolor(green*0.5)  || ///
    line FES Surveyyear2 if Percentile==1 & inlist(Incomegroups,"Quintiles","Quintiles, interpolated"), lwidth(medthick) lcolor(red) || ///
    line FES Surveyyear2 if Percentile==5 & inlist(Incomegroups,"Quintiles","Quintiles, interpolated"), lwidth(medthick) lcolor(blue)  || ///
	scatter FES Surveyyear2 if Percentile==1 & inlist(Incomegroups,"Quintiles","Quintiles, interpolated"), msize(vsmall) mcolor(black) lcolor(red) || ///
    scatter FES Surveyyear2 if Percentile==5 & inlist(Incomegroups,"Quintiles","Quintiles, interpolated"), msize(vsmall) mcolor(black) lcolor(blue)  || ///
    , by(Country, cols(4) note("") imargin(tiny) graphregion(margin(t-3 b-3))) ///
    xtitle("Year", size(8pt)) ///
    ytitle("Mean Food Expenditure Share", size(8pt)) ///
	ylabel(0(15)70) ///
	xlabel(2005(5)2025, angle(40)) ///
    legend(bmargin(zero) size(8pt) rows(2) position(6) order(6 "Q1 (poorest 20%)" 7 "Q5 (wealthiest 20%)" 5 "Difference: FES(Q1)-FES(Q5)" 1 "D1 (poorest 10%)" 2 "D10 (wealthiest 10%)")) ///
	scheme(cleanplots) xline(2019.5, lcolor(black) lpattern(dash)) xline(2021.5, lcolor(gs10) lpattern(dash))  ysize(19cm) xsize(15cm) 

graph export "${workdir}/graphs/FigureS8.png", replace
graph export "${workdir}/graphs/FigureS8.pdf", replace
    

* EUROSTAT countries
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
    legend(size(8pt) rows(1) position(6) order(2 "Q1 (poorest 20%)" 3 "Q5 (wealthiest 20%)" 1 "Difference: FES(Q1)-FES(Q5)")) ///
	scheme(cleanplots) xline(2019.5, lcolor(black) lpattern(dash))  ysize(15cm) xsize(15cm) 

graph export "${workdir}/graphs/FigureS9.png", replace
graph export "${workdir}/graphs/FigureS9.pdf", replace
