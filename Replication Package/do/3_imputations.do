********************************************************************************
*								Imputations										*
********************************************************************************
use "${datadir}/FESdatabase_quintiles.dta", clear

gen countryquintile = countrycode + string(Percentile)
encode countryquintile, gen(countryquintile_enc)

xtset countryquintile_enc year
gen imputed = 0
tsfill, full
replace imputed = 1 if missing(imputed)

* Fill panel-invariant variables within each panel
foreach var of varlist Country countrycode Incomegroups Percentile countryquintile Surveyyear2 {
    by countryquintile_enc: egen first_`var' = min(cond(!missing(`var'), _n, .))
    by countryquintile_enc: egen last_`var'  = max(cond(!missing(`var'), _n, .))
    
    by countryquintile_enc: replace `var' = `var'[first_`var'] if missing(`var') & !missing(first_`var')
    
    drop first_`var' last_`var'
}


* Merge macro variables
merge m:1 countrycode year using "${datadir}/aux data/PIP.dta", keep(match master) nogen 
merge m:1 countrycode year using "${datadir}/aux data/PIP_UMICs.dta", keep(match master) nogen 
merge m:1 countrycode year using "${datadir}/aux data/WDI.dta", keep(match master) nogen // only Argentina (1996), Bhutan (2025), Turkmenistan (1998), Japan(2025), Korea (2025) not matched
merge m:1 countrycode year using "${datadir}/aux data/CoHD.dta", keep(match master) nogen 
merge m:1 countrycode year using "${datadir}/aux data/fao_data.dta", keep(match master) nogen 
merge m:1 countrycode year using "${datadir}/aux data/food_cpi.dta", keep(match master) nogen 

* Replace missing food CPI values by taking the regional median during that year
bysort year regionname incomelevelname: egen median_FCPI = median(Food_CPI)
replace Food_CPI = median_FCPI if Food_CPI == .
drop median_FCPI

replace incomelevel = "LIC" if Country == "Ethiopia" & incomelevel == "INX" 
replace incomelevelname = "Low income" if Country == "Ethiopia" & incomelevelname == "Not classified"
encode incomelevel, gen(incomelevel_enc)
encode regionname, gen(regionname_enc)

gen ln_consexp_pc_d      = ln(consexp_pc_d) if consexp_pc_d>0
xtile Food_CPI_grp = Food_CPI, nq(10) // creating 10 categories, otherwise extreme inflation values (e.g., in Zimbabwe) lead to extreme modelled estimates 
encode countrycode, gen(countrycode_enc)


gen post2019 = 1 if Surveyyear2 > 2019.5 & Surveyyear2 < .
replace post2019 = 0 if Surveyyear2 > 0 & Surveyyear2 < 2020
drop if year == 2025 // we do not have auxiliary data for that year

keep Country countrycode Surveyyear2 year Percentile FES headcount spr Food_CPI_grp incomelevel_enc ln_consexp_pc_d countrycode_enc post2019 countryquintile_enc

* Make sure you have a country-quintile identifier
capture confirm variable countryquintile_enc
if _rc {
    egen countryquintile_enc = group(countrycode_enc Percentile)
}

* Preserve a clean base dataset
tempfile base baseline base_post mergefile
save `base', replace


* Preserve original truth
gen FES_original = FES

gen byte FES_missing_original = missing(FES)

    mi set mlong
    mi register imputed FES
    mi register regular ///
        year Percentile countrycode_enc countryquintile_enc ///
        ln_consexp_pc_d post2019 Food_CPI_grp headcount incomelevel_enc spr ///
        Country countrycode

    mi impute regress FES = ///
        i.countrycode_enc##c.year##i.Percentile ///
        c.year#i.post2019 ///
        c.year#i.incomelevel_enc ///
        c.Food_CPI_grp#i.incomelevel_enc  ///
        c.ln_consexp_pc_d ///
        c.headcount ///
        c.spr ///
        if !missing(ln_consexp_pc_d, headcount, Food_CPI_grp), ///
        rseed(12345) add(50)

    * Build median across imputations
    tempvar FES0 miss0 FESimp

    gen `FES0'  = FES if _mi_m == 0
    gen byte `miss0' = missing(FES) if _mi_m == 0
    gen `FESimp' = FES if _mi_m > 0

    bys _mi_id: egen FES_obs = max(`FES0')
    bys _mi_id: egen imputed = max(`miss0')
	bys _mi_id: egen FES_imp_p10 = pctile(`FESimp'), p(10)
	bys _mi_id: egen FES_imp_p90 = pctile(`FESimp'), p(90)
	
    bys _mi_id: egen FES_imp = median(`FESimp')

    replace FES_imp = FES_obs if imputed == 0
	replace FES_imp_p10 = FES_obs if imputed == 0
	replace FES_imp_p90 = FES_obs if imputed == 0

    * Keep one row per original observation
    keep if _mi_m == 0

    * Clean up MI structure entirely
    mi unset, asis

    * Keep only what is needed
	keep Country countrycode countrycode_enc countryquintile_enc ///
		 year Percentile ///
		 FES_original FES_missing_original imputed ///
		 FES_imp FES_imp_p10 FES_imp_p90 ///
		 Food_CPI_grp ln_consexp_pc_d headcount spr ///
		 incomelevel_enc post2019

save `baseline', replace

*============================================================*
* 3. ALTERNATIVE MI FOR SERIES WITH EXACTLY TWO TRUE VALUES
*    (Replace first observed FES with missing)
*============================================================*
use `base', clear

gen FES_original = FES

* Count true observed FES values within each country-quintile
bys countryquintile_enc: egen n_FES_obs = total(!missing(FES))

* First and last observed year within each country-quintile
bys countryquintile_enc: egen first_FES_year = min(cond(!missing(FES), year, .))
bys countryquintile_enc: egen last_FES_year  = max(cond(!missing(FES), year, .))

* Replace first observed FES with missing only for series with exactly two observations
replace FES = . if n_FES_obs == 2 & year == first_FES_year & !missing(FES)

* Keep track of original missingness after this adjustment
gen byte FES_missing_alt = missing(FES)

* Set MI structure
mi set mlong

* Register variables
mi register imputed FES
mi register regular ///
    year Percentile countrycode_enc countryquintile_enc ///
    ln_consexp_pc_d post2019 Food_CPI_grp headcount incomelevel_enc spr ///
    Country countrycode n_FES_obs first_FES_year last_FES_year FES_original

* Run MI again
mi impute regress FES = ///
    i.countrycode_enc##c.year##i.Percentile ///
    c.year#i.post2019 ///
    c.year#i.incomelevel_enc ///
    c.Food_CPI_grp#i.incomelevel_enc  ///
    c.ln_consexp_pc_d ///
    c.headcount ///
    c.spr ///
    if !missing(ln_consexp_pc_d, headcount, Food_CPI_grp), ///
    rseed(12345) add(50)

mi describe

* Build median across imputations
tempvar FES0b miss0b FESimpb

gen `FES0b' = FES if _mi_m == 0
gen byte `miss0b' = missing(FES) if _mi_m == 0
gen `FESimpb' = FES if _mi_m > 0

bys _mi_id: egen FES_obs_alt = max(`FES0b')
bys _mi_id: egen imputed_alt = max(`miss0b')

bys _mi_id: egen FES_post = median(`FESimpb')
bys _mi_id: egen FES_post_p10 = pctile(`FESimpb'), p(10)
bys _mi_id: egen FES_post_p90 = pctile(`FESimpb'), p(90)

replace FES_post = FES_obs_alt if imputed_alt == 0
replace FES_post_p10 = FES_obs_alt if imputed_alt == 0
replace FES_post_p90 = FES_obs_alt if imputed_alt == 0

* Keep only original rows
keep if _mi_m == 0

* Remove MI structure
mi unset, asis

* Keep only what is needed for merge	 
keep countryquintile_enc year ///
     n_FES_obs first_FES_year last_FES_year ///
     FES_post FES_post_p10 FES_post_p90

save `base_post', replace



*============================================================*
* 3. MERGE BOTH RESULTS
*============================================================*
use `baseline', clear

merge 1:1 countryquintile_enc year using `base_post', nogen

* Construct final completed series
gen FES_final = FES_original

* Baseline imputation first
replace FES_final = FES_imp if missing(FES_final)

* For series with exactly two observed values,
* use alternative imputation after the last true observed value
bys countrycode_enc year: egen n_FES_obs_all = max(n_FES_obs)

replace FES_final = FES_post ///
    if n_FES_obs_all == 2 ///
    & year > last_FES_year ///
    & missing(FES_original)

* Lower band
gen FES_final_p10 = FES_original
replace FES_final_p10 = FES_imp_p10 if missing(FES_final_p10)
replace FES_final_p10 = FES_post_p10 ///
    if n_FES_obs_all == 2 ///
    & year > last_FES_year ///
    & missing(FES_original)

* Upper band
gen FES_final_p90 = FES_original
replace FES_final_p90 = FES_imp_p90 if missing(FES_final_p90)
replace FES_final_p90 = FES_post_p90 ///
    if n_FES_obs_all == 2 ///
    & year > last_FES_year ///
    & missing(FES_original)
	

gen note = ""
replace note = "Raw" if FES_original != .
replace note = "Imputed" if FES_original == .

/*
To indicate the degree of empirical support underlying each estimate, we classify observations according to four levels of data certainty: 
	- (1) comprises directly observed FES values from household surveys or secondary literature, 
	- (2) includes modelled estimates for country–quintile series with at least three observed survey years, 
	- (3) contains modelled estimates for series with exactly two observed survey years that lie between the two observed values, 
	- (4) includes modelled estimates for series with only one observed survey year and extrapolated values outside the range of two observed survey years. In this last category, we avoid making strong assumptions about trends by using modelled estimates only based on the last observed value. If countries experienced strong structural changes during the modelled years, these will not be captured.
*/
bys countryquintile_enc: egen n_obs_FES = total(!missing(FES_original))
// First and last observed year within each country-quintile
bys countryquintile_enc: egen first_obs_year = min(cond(!missing(FES_original), year, .))
bys countryquintile_enc: egen last_obs_year  = max(cond(!missing(FES_original), year, .))

* Create certainty/support variable
gen confidencelevel = .
// (1) Directly observed values
replace confidencelevel = 1 if FES_original != .
// (2) Modelled values with >= 3 observed survey years
replace confidencelevel = 2 if missing(FES_original) & n_obs_FES >= 3 & !missing(FES_final)
// (3) Modelled values with exactly 2 observed years, between the two anchors
replace confidencelevel = 3 if missing(FES_original) & n_obs_FES == 2 ///
    & year > first_obs_year & year < last_obs_year ///
    & !missing(FES_final)
// (4) Modelled values with only 1 observed year, or extrapolated values outside the range in 2-observation series
replace confidencelevel = 4 if missing(FES_original) & !missing(FES_final) ///
    & (n_obs_FES == 1 | ///
       (n_obs_FES == 2 & (year < first_obs_year | year > last_obs_year)))	

replace confidencelevel = 4 if confidencelevel == . & Country == "Cambodia" //only raw values for Q1
	   
keep if year >= 2015
drop if Country == "Argentina" & note != "Raw" // no macro data for Argentina. I only use the raw values


* Save
keep  Country countrycode year Percentile FES_final FES_final_p10 FES_final_p90  note confidencelevel
save "${datadir}/FESdatabase_imputed.dta", replace
