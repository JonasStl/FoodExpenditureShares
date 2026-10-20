version 17.0
clear all
set more off

********************************************************************************
* 1. Survey observations and annual country-quintile panel
********************************************************************************

use "${datadir}/FESdatabase_quintiles.dta", clear
keep if inrange(Percentile, 1, 5)

isid countrycode year Percentile

clonevar FES_reported = FES
tempfile complete_shapes reconstructed_quintiles

preserve
    keep countrycode year Percentile FES
    reshape wide FES, i(countrycode year) j(Percentile)
    egen byte n_reported = rownonmiss(FES1 FES2 FES3 FES4 FES5)
    keep if n_reported == 5
    rename year reference_year
    forvalues q = 1/5 {
        rename FES`q' FES_ref`q'
    }
    keep countrycode reference_year ///
        FES_ref1 FES_ref2 FES_ref3 FES_ref4 FES_ref5
    save `complete_shapes', replace
restore

preserve
    keep countrycode year Percentile FES
    reshape wide FES, i(countrycode year) j(Percentile)
    egen byte n_reported = rownonmiss(FES1 FES2 FES3 FES4 FES5)
    keep if inrange(n_reported, 2, 4)
    joinby countrycode using `complete_shapes'
    gen int reference_distance = abs(year - reference_year)

    gen double sum_reference = 0
    gen double sum_reported = 0
    forvalues q = 1/5 {
        replace sum_reference = sum_reference + FES_ref`q' ///
            if !missing(FES`q')
        replace sum_reported = sum_reported + FES`q' if !missing(FES`q')
    }
    gen double mean_reference = sum_reference / n_reported
    gen double mean_reported = sum_reported / n_reported
    gen double sxx = 0
    gen double sxy = 0
    forvalues q = 1/5 {
        replace sxx = sxx + (FES_ref`q' - mean_reference)^2 ///
            if !missing(FES`q')
        replace sxy = sxy + (FES_ref`q' - mean_reference) * ///
            (FES`q' - mean_reported) if !missing(FES`q')
    }
    gen double transfer_slope = sxy / sxx if sxx > 1e-10
    gen double transfer_intercept = mean_reported - ///
        transfer_slope * mean_reference if transfer_slope > 0 & ///
        !missing(transfer_slope)
    gen byte transfer_valid = transfer_slope > 0 & ///
        !missing(transfer_intercept)

    forvalues q = 1/5 {
        gen double FES_fill`q' = transfer_intercept + ///
            transfer_slope * FES_ref`q' if missing(FES`q') & transfer_valid
        replace transfer_valid = 0 if !missing(FES_fill`q') & ///
            !inrange(FES_fill`q', 0, 100)
    }
    forvalues q = 1/5 {
        replace FES_fill`q' = . if !transfer_valid
    }

    keep if transfer_valid
    gsort countrycode year reference_distance reference_year
    by countrycode year: keep if _n == 1
    keep countrycode year reference_year ///
        FES_fill1 FES_fill2 FES_fill3 FES_fill4 FES_fill5
    reshape long FES_fill, i(countrycode year reference_year) j(Percentile)
    keep if !missing(FES_fill)
    rename FES_fill FES_reconstructed
    rename reference_year within_wave_reference_year
    gen byte within_wave_reconstructed = 1
    isid countrycode year Percentile
    save `reconstructed_quintiles', replace
restore

merge 1:1 countrycode year Percentile using `reconstructed_quintiles', ///
    keep(master match) nogen
replace within_wave_reconstructed = 0 if missing(within_wave_reconstructed)
replace FES = FES_reconstructed if within_wave_reconstructed
label var FES_reported "FES reported directly in source"
label var FES_reconstructed "FES reconstructed from another complete wave"
label var within_wave_reconstructed "Missing survey quintile reconstructed"
label var within_wave_reference_year "Complete wave used for reconstruction"

egen long countryquintile_enc = group(countrycode Percentile)
xtset countryquintile_enc year
tsfill, full
keep if year <= 2025
replace within_wave_reconstructed = 0 if missing(within_wave_reconstructed)

foreach variable of varlist Country countrycode Percentile {
    bysort countryquintile_enc: egen long first_`variable' = ///
        min(cond(!missing(`variable'), _n, .))
    bysort countryquintile_enc: replace `variable' = ///
        `variable'[first_`variable'] if missing(`variable')
    drop first_`variable'
}

********************************************************************************
* 2. Macroeconomic covariates
********************************************************************************

merge m:1 countrycode year using "${auxdir}/PIP.dta", ///
    keepusing(consexp_pc_d headcount spr) keep(master match) nogen

merge m:1 countrycode year using "${auxdir}/WDI.dta", ///
    keepusing(regionname incomelevel incomelevelname) ///
    keep(master match) nogen

merge m:1 countrycode year using "${auxdir}/food_cpi.dta", ///
    keepusing(fao_rel_food_cpi_infl) keep(master match) nogen

replace incomelevel = "LIC" if Country == "Ethiopia" & incomelevel == "INX"
replace incomelevelname = "Low income" if Country == "Ethiopia" & ///
    incomelevelname == "Not classified"

gen double rel_food_infl = fao_rel_food_cpi_infl
gen byte rel_food_infl_fallback = 0 if !missing(rel_food_infl)

bysort year regionname incomelevelname: egen double median_price = ///
    median(rel_food_infl)
replace rel_food_infl = median_price if missing(rel_food_infl) & ///
    !missing(median_price) & regionname != "" & incomelevelname != ""
replace rel_food_infl_fallback = 1 if missing(rel_food_infl_fallback) & ///
    !missing(rel_food_infl)
drop median_price

bysort year regionname: egen double median_price = median(rel_food_infl)
replace rel_food_infl = median_price if missing(rel_food_infl) & ///
    !missing(median_price) & regionname != ""
replace rel_food_infl_fallback = 2 if missing(rel_food_infl_fallback) & ///
    !missing(rel_food_infl)
drop median_price

bysort year: egen double median_price = median(rel_food_infl)
replace rel_food_infl = median_price if missing(rel_food_infl) & ///
    !missing(median_price)
replace rel_food_infl_fallback = 3 if missing(rel_food_infl_fallback) & ///
    !missing(rel_food_infl)
drop median_price

label define rel_food_fallback_lbl ///
    0 "Original country-year value" ///
    1 "Income-region-year median" ///
    2 "Region-year median" ///
    3 "Global-year median"
label values rel_food_infl_fallback rel_food_fallback_lbl
label var rel_food_infl ///
    "Annual inflation in FAOSTAT food CPI relative to general CPI (%)"
label var rel_food_infl_fallback "Fallback used for relative food inflation"

egen byte price_countryyear_tag = tag(countrycode year)
quietly summarize rel_food_infl if rel_food_infl_fallback == 0 & ///
    price_countryyear_tag, detail
scalar rel_food_p1 = r(p1)
scalar rel_food_p99 = r(p99)

gen double rel_food_infl_w = max(rel_food_p1, ///
    min(rel_food_p99, rel_food_infl)) if !missing(rel_food_infl)
gen byte rel_food_infl_winsorized = !missing(rel_food_infl) & ///
    rel_food_infl != rel_food_infl_w
label var rel_food_infl_w "Winsorized annual relative food CPI inflation (%)"
label var rel_food_infl_winsorized ///
    "Relative food inflation winsorized at p1/p99"

drop price_countryyear_tag
scalar drop rel_food_p1 rel_food_p99

gen double ln_consexp_pc_d = ln(consexp_pc_d) if consexp_pc_d > 0
encode countrycode, gen(countrycode_enc)
encode incomelevel, gen(incomelevel_enc)

gen byte mi_covariates_complete = !missing(ln_consexp_pc_d, headcount, spr, ///
    rel_food_infl_w, incomelevel_enc, countrycode_enc, Percentile, year)
label var mi_covariates_complete "All imputation covariates observed"

keep Country countrycode year Percentile FES FES_reported FES_reconstructed ///
    within_wave_reconstructed within_wave_reference_year countryquintile_enc ///
    countrycode_enc incomelevel_enc ln_consexp_pc_d headcount spr ///
    rel_food_infl rel_food_infl_w rel_food_infl_fallback ///
    rel_food_infl_winsorized mi_covariates_complete

tempfile model_data baseline two_survey
save `model_data', replace

********************************************************************************
* 3. Baseline multiple imputation
********************************************************************************

gen double FES_original = FES_reported
gen double eta_FES = log(min(max(FES, 0.01), 99.99) / ///
    (100 - min(max(FES, 0.01), 99.99))) if !missing(FES)
drop FES

sort countrycode year Percentile
mi set mlong
mi register imputed eta_FES
mi register regular Country countrycode countrycode_enc countryquintile_enc ///
    year Percentile FES_original FES_reported FES_reconstructed ///
    within_wave_reconstructed within_wave_reference_year ///
    incomelevel_enc ln_consexp_pc_d headcount spr ///
    rel_food_infl rel_food_infl_w rel_food_infl_fallback ///
    rel_food_infl_winsorized mi_covariates_complete

mi impute regress eta_FES = ///
    i.countrycode_enc##c.year##i.Percentile ///
    c.year#i.incomelevel_enc ///
    c.rel_food_infl_w ///
    c.ln_consexp_pc_d ///
    c.headcount ///
    c.spr ///
    if mi_covariates_complete, rseed(12345) add(100)

tempvar FES_draw
gen double `FES_draw' = 100 * invlogit(eta_FES) if _mi_m > 0
bysort _mi_id: egen double FES_imp = median(`FES_draw')
bysort _mi_id: egen double FES_imp_p10 = pctile(`FES_draw'), p(10)
bysort _mi_id: egen double FES_imp_p90 = pctile(`FES_draw'), p(90)

keep if _mi_m == 0
mi unset, asis
drop eta_FES
save `baseline', replace

********************************************************************************
* 4. Conservative extrapolation for countries with two survey waves
********************************************************************************

use `model_data', clear
gen double FES_original = FES_reported

bysort countrycode year: egen byte observed_survey_year = max(!missing(FES))
bysort countrycode year: gen byte countryyear_tag = _n == 1
gen byte observed_survey_tag = observed_survey_year & countryyear_tag
bysort countrycode: egen int n_country_surveys = total(observed_survey_tag)
bysort countrycode: egen int first_survey_year = ///
    min(cond(observed_survey_year, year, .))
bysort countrycode: egen int last_survey_year = ///
    max(cond(observed_survey_year, year, .))
drop countryyear_tag observed_survey_tag observed_survey_year

replace FES = . if n_country_surveys == 2 & year == first_survey_year
gen double FES_model_observed = FES
gen double eta_FES = log(min(max(FES, 0.01), 99.99) / ///
    (100 - min(max(FES, 0.01), 99.99))) if !missing(FES)
drop FES

sort countrycode year Percentile
mi set mlong
mi register imputed eta_FES
mi register regular Country countrycode countrycode_enc countryquintile_enc ///
    year Percentile FES_original FES_reported FES_reconstructed ///
    within_wave_reconstructed within_wave_reference_year ///
    FES_model_observed n_country_surveys ///
    first_survey_year last_survey_year incomelevel_enc ln_consexp_pc_d ///
    headcount spr rel_food_infl rel_food_infl_w rel_food_infl_fallback ///
    rel_food_infl_winsorized mi_covariates_complete

mi impute regress eta_FES = ///
    i.countrycode_enc##c.year##i.Percentile ///
    c.year#i.incomelevel_enc ///
    c.rel_food_infl_w ///
    c.ln_consexp_pc_d ///
    c.headcount ///
    c.spr ///
    if mi_covariates_complete, rseed(12345) add(100)

tempvar FES_draw_post
gen double `FES_draw_post' = 100 * invlogit(eta_FES) if _mi_m > 0
bysort _mi_id: egen double FES_post = median(`FES_draw_post')
bysort _mi_id: egen double FES_post_p10 = pctile(`FES_draw_post'), p(10)
bysort _mi_id: egen double FES_post_p90 = pctile(`FES_draw_post'), p(90)

keep if _mi_m == 0
mi unset, asis
keep countryquintile_enc year n_country_surveys first_survey_year ///
    last_survey_year FES_post FES_post_p10 FES_post_p90
save `two_survey', replace

********************************************************************************
* 5. Point estimates and direct multiple-imputation intervals
********************************************************************************

use `baseline', clear
merge 1:1 countryquintile_enc year using `two_survey', assert(match) nogen

gen double FES_final = cond(!missing(FES_original), FES_original, ///
    cond(within_wave_reconstructed, FES_reconstructed, FES_imp))
gen double FES_final_p10 = cond(!missing(FES_original), FES_original, ///
    cond(within_wave_reconstructed, FES_reconstructed, FES_imp_p10))
gen double FES_final_p90 = cond(!missing(FES_original), FES_original, ///
    cond(within_wave_reconstructed, FES_reconstructed, FES_imp_p90))

replace FES_final = FES_post if n_country_surveys == 2 & ///
    year > last_survey_year & missing(FES_original)
replace FES_final_p10 = FES_post_p10 if n_country_surveys == 2 & ///
    year > last_survey_year & missing(FES_original)
replace FES_final_p90 = FES_post_p90 if n_country_surveys == 2 & ///
    year > last_survey_year & missing(FES_original)

gen str7 note = cond(!missing(FES_original), "Raw", "Imputed")

********************************************************************************
* 6. Empirical support and extrapolation uncertainty
********************************************************************************

gen double FES_anchor = FES_original
replace FES_anchor = FES_reconstructed if within_wave_reconstructed
bysort countryquintile_enc: egen int n_FES_anchors = ///
    total(!missing(FES_anchor))
bysort countryquintile_enc: egen int first_anchor_year = ///
    min(cond(!missing(FES_anchor), year, .))
bysort countryquintile_enc: egen int last_anchor_year = ///
    max(cond(!missing(FES_anchor), year, .))

gen byte interval_type = .
replace interval_type = 1 if !missing(FES_original)
replace interval_type = 5 if within_wave_reconstructed
replace interval_type = 2 if missing(FES_original) & ///
    !within_wave_reconstructed & n_FES_anchors >= 2 & ///
    inrange(year, first_anchor_year + 1, last_anchor_year - 1)
replace interval_type = 3 if missing(FES_original) & ///
    !within_wave_reconstructed & n_FES_anchors >= 1 & ///
    (year < first_anchor_year | year > last_anchor_year)
replace interval_type = 4 if missing(FES_original) & ///
    !within_wave_reconstructed & n_FES_anchors == 0
label define interval_type_lbl ///
    1 "Observed survey value" ///
    2 "Interpolation" ///
    3 "Extrapolation" ///
    4 "No survey anchor" ///
    5 "Within-wave reconstructed quintile"
label values interval_type interval_type_lbl
label var interval_type "Empirical support for interval construction"

gen byte confidencelevel = .
replace confidencelevel = 1 if !missing(FES_original)
replace confidencelevel = 3 if within_wave_reconstructed & !missing(FES_final)
replace confidencelevel = 2 if missing(FES_original) & ///
    !within_wave_reconstructed & !missing(FES_final) & n_FES_anchors >= 3
replace confidencelevel = 3 if missing(FES_original) & ///
    !within_wave_reconstructed & !missing(FES_final) & n_FES_anchors == 2 & ///
    inrange(year, first_anchor_year + 1, last_anchor_year - 1)
replace confidencelevel = 4 if missing(FES_original) & ///
    !within_wave_reconstructed & !missing(FES_final) & n_FES_anchors <= 1
replace confidencelevel = 4 if missing(FES_original) & ///
    !within_wave_reconstructed & !missing(FES_final) & n_FES_anchors == 2 & ///
    (year < first_anchor_year | year > last_anchor_year)
label define confidencelevel_lbl ///
    1 "Observed FES" ///
    2 "Modelled: at least three anchors" ///
    3 "Reconstructed or interpolation between two anchors" ///
    4 "Zero/one-anchor estimate or two-anchor extrapolation"
label values confidencelevel confidencelevel_lbl
label var confidencelevel "Confidence Category"

gen int single_anchor_distance = abs(year - first_anchor_year) ///
    if n_FES_anchors == 1
gen byte single_anchor_within_two_years = confidencelevel == 4 & ///
    n_FES_anchors == 1 & single_anchor_distance <= 2
label var single_anchor_distance "Years from sole country-quintile anchor"
label var single_anchor_within_two_years ///
    "Category 4 estimate within two years of sole anchor"

tempfile survey_anchors survey_distances
preserve
    keep if !missing(FES_anchor)
    keep countryquintile_enc year
    rename year anchor_year
    save `survey_anchors', replace
restore

preserve
    keep countryquintile_enc year
    duplicates drop
    joinby countryquintile_enc using `survey_anchors'
    gen int survey_distance = abs(year - anchor_year)
    collapse (min) survey_distance, by(countryquintile_enc year)
    save `survey_distances', replace
restore

merge 1:1 countryquintile_enc year using `survey_distances', ///
    keep(master match) nogen
gen byte no_survey_anchor = interval_type == 4

gen int uncertainty_distance = survey_distance if interval_type == 3
replace uncertainty_distance = 0 if inlist(interval_type, 1, 2, 5)
gen double uncertainty_factor = 1 if !missing(FES_final)
replace uncertainty_factor = sqrt(1 + 0.25 * (survey_distance - 2)) ///
    if interval_type == 3 & survey_distance > 2 & !missing(FES_final)
gen byte interval_distance_widened = interval_type == 3 & ///
    uncertainty_factor > 1 & !missing(FES_final)
label var survey_distance "Years to nearest country-quintile FES anchor"
label var no_survey_anchor "No raw or reconstructed survey anchor"
label var uncertainty_distance "Distance used for extrapolation uncertainty"
label var uncertainty_factor "Delayed logit-scale interval multiplier"
label var interval_distance_widened "Extrapolation interval widened"

keep if inrange(year, 2015, 2025)

drop if inlist(countrycode, "ARG", "COK", "TKL") & note != "Raw"
sort countrycode year Percentile
isid countrycode year Percentile

clonevar FES_final_p10_base = FES_final_p10
clonevar FES_final_p90_base = FES_final_p90
label var FES_final_p10_base "Direct MI p10 before distance widening"
label var FES_final_p90_base "Direct MI p90 before distance widening"

tempvar eta_mid eta_lower eta_upper
gen double `eta_mid' = log(FES_final / (100 - FES_final)) ///
    if inrange(FES_final, 0.0001, 99.9999)
gen double `eta_lower' = log(FES_final_p10 / (100 - FES_final_p10)) ///
    if inrange(FES_final_p10, 0.0001, 99.9999)
gen double `eta_upper' = log(FES_final_p90 / (100 - FES_final_p90)) ///
    if inrange(FES_final_p90, 0.0001, 99.9999)

replace FES_final_p10 = 100 * invlogit(`eta_mid' - uncertainty_factor * ///
    (`eta_mid' - `eta_lower')) if interval_distance_widened & ///
    !missing(`eta_mid', `eta_lower')
replace FES_final_p90 = 100 * invlogit(`eta_mid' + uncertainty_factor * ///
    (`eta_upper' - `eta_mid')) if interval_distance_widened & ///
    !missing(`eta_mid', `eta_upper')
drop `eta_mid' `eta_lower' `eta_upper'

********************************************************************************
* 7. Quintile-order adjustment
********************************************************************************

tempfile order_adjustments
preserve
    keep Country countrycode year Percentile FES_original FES_final ///
        FES_final_p10 FES_final_p90 FES_final_p10_base FES_final_p90_base
    reshape wide FES_original FES_final FES_final_p10 FES_final_p90 ///
        FES_final_p10_base FES_final_p90_base, ///
        i(Country countrycode year) j(Percentile)

    egen byte n_raw_quintiles = rownonmiss(FES_original1 FES_original2 ///
        FES_original3 FES_original4 FES_original5)
    egen byte n_final_quintiles = rownonmiss(FES_final1 FES_final2 ///
        FES_final3 FES_final4 FES_final5)
    gen byte raw_all_five = n_raw_quintiles == 5
    gen byte raw_order_violation = raw_all_five & ///
        (FES_original1 < FES_original2 | FES_original2 < FES_original3 | ///
         FES_original3 < FES_original4 | FES_original4 < FES_original5)
    gen byte raw_endpoints_observed = ///
        !missing(FES_original1, FES_original5)
    gen byte raw_endpoint_violation = raw_endpoints_observed & ///
        FES_original1 < FES_original5
    gen byte final_order_violation = n_final_quintiles == 5 & ///
        (FES_final1 < FES_final2 | FES_final2 < FES_final3 | ///
         FES_final3 < FES_final4 | FES_final4 < FES_final5)
    gen byte final_endpoint_violation = n_final_quintiles == 5 & ///
        FES_final1 < FES_final5

    bysort countrycode: egen byte country_raw_order_tested = max(raw_all_five)
    bysort countrycode: egen byte country_raw_order_violation = ///
        max(raw_order_violation)
    bysort countrycode: egen byte country_raw_endpoint_tested = ///
        max(raw_endpoints_observed)
    bysort countrycode: egen byte country_raw_endpoint_violation = ///
        max(raw_endpoint_violation)

    gen byte full_monotone_adjusted = final_order_violation & ///
        n_raw_quintiles == 0 & country_raw_order_tested & ///
        !country_raw_order_violation
    gen byte endpoint_adjusted = final_endpoint_violation & ///
        n_raw_quintiles == 0 & country_raw_endpoint_tested & ///
        !country_raw_endpoint_violation & !full_monotone_adjusted
    gen byte monotone_adjusted = full_monotone_adjusted | endpoint_adjusted

    forvalues q = 1/5 {
        gen double FES_before`q' = FES_final`q'
    }

    mata:
    real rowvector fes_pava_decreasing(real rowvector y)
    {
        real scalar n, i, k, j
        real rowvector level, weight, low, high, out
        n = cols(y)
        level = J(1,n,.)
        weight = J(1,n,.)
        low = J(1,n,.)
        high = J(1,n,.)
        k = 0
        for (i=1; i<=n; i++) {
            k = k + 1
            level[k] = y[i]
            weight[k] = 1
            low[k] = i
            high[k] = i
            while (k>1) {
                if (level[k-1] < level[k]) {
                    level[k-1] = (weight[k-1]*level[k-1] + ///
                        weight[k]*level[k]) / (weight[k-1]+weight[k])
                    weight[k-1] = weight[k-1] + weight[k]
                    high[k-1] = high[k]
                    k = k - 1
                }
                else break
            }
        }
        out = J(1,n,.)
        for (j=1; j<=k; j++) {
            out[low[j]..high[j]] = J(1,high[j]-low[j]+1,level[j])
        }
        return(out)
    }

    void apply_fes_order_rules()
    {
        real matrix y
        real colvector fulladjust, endpointadjust
        real scalar i, midpoint
        y = st_data(., ("FES_final1","FES_final2","FES_final3", ///
                        "FES_final4","FES_final5"))
        fulladjust = st_data(., "full_monotone_adjusted")
        endpointadjust = st_data(., "endpoint_adjusted")
        for (i=1; i<=rows(y); i++) {
            if (fulladjust[i] == 1) y[i,] = fes_pava_decreasing(y[i,])
            else if (endpointadjust[i] == 1) {
                midpoint = (y[i,1] + y[i,5]) / 2
                y[i,1] = midpoint
                y[i,5] = midpoint
            }
        }
        st_store(., st_varindex(("FES_final1","FES_final2","FES_final3", ///
                                 "FES_final4","FES_final5")), y)
    }

    apply_fes_order_rules()
    end

    forvalues q = 1/5 {
        gen double monotone_shift`q' = FES_final`q' - FES_before`q'
        replace FES_final_p10`q' = max(0, ///
            FES_final_p10`q' + monotone_shift`q') if monotone_adjusted
        replace FES_final_p90`q' = min(100, ///
            FES_final_p90`q' + monotone_shift`q') if monotone_adjusted
        replace FES_final_p10_base`q' = max(0, ///
            FES_final_p10_base`q' + monotone_shift`q') if monotone_adjusted
        replace FES_final_p90_base`q' = min(100, ///
            FES_final_p90_base`q' + monotone_shift`q') if monotone_adjusted
    }

    keep Country countrycode year monotone_adjusted ///
        full_monotone_adjusted endpoint_adjusted ///
        FES_final1 FES_final2 FES_final3 FES_final4 FES_final5 ///
        FES_final_p101 FES_final_p102 FES_final_p103 ///
        FES_final_p104 FES_final_p105 ///
        FES_final_p901 FES_final_p902 FES_final_p903 ///
        FES_final_p904 FES_final_p905 ///
        FES_final_p10_base1 FES_final_p10_base2 FES_final_p10_base3 ///
        FES_final_p10_base4 FES_final_p10_base5 ///
        FES_final_p90_base1 FES_final_p90_base2 FES_final_p90_base3 ///
        FES_final_p90_base4 FES_final_p90_base5
    reshape long FES_final FES_final_p10 FES_final_p90 ///
        FES_final_p10_base FES_final_p90_base, ///
        i(Country countrycode year monotone_adjusted ///
          full_monotone_adjusted endpoint_adjusted) j(Percentile)
    save `order_adjustments', replace
restore

drop FES_final FES_final_p10 FES_final_p90 ///
    FES_final_p10_base FES_final_p90_base
merge 1:1 Country countrycode year Percentile using `order_adjustments', ///
    assert(match) nogen
label var FES_final "Food expenditure share (%)"
label var FES_final_p10 "Lower bound"
label var FES_final_p90 "Upper bound"
label var monotone_adjusted "Any data-supported quintile-order adjustment"
label var full_monotone_adjusted "Full five-quintile PAVA adjustment"
label var endpoint_adjusted "Endpoint-only Q1-Q5 adjustment"
sort countrycode year Percentile
replace FES_final_p10 = max(FES_final_p10, 0) if !missing(FES_final_p10)
replace FES_final_p90 = min(FES_final_p90, 100) if !missing(FES_final_p90)
********************************************************************************
* 8. Save outputs
********************************************************************************

preserve
    keep Country countrycode year Percentile FES_final ///
        FES_final_p10 FES_final_p90 note
    sort Country year Percentile
    order Country countrycode year Percentile FES_final ///
        FES_final_p10 FES_final_p90 note
    format FES_final FES_final_p10 FES_final_p90 %10.0g
    quietly ds
    foreach variable in _dta `r(varlist)' {
        local characteristics : char `variable'[]
        foreach characteristic of local characteristics {
            char `variable'[`characteristic']
        }
    }
    label data ""
    save "${datadir}/FESdatabase_imputed.dta", replace
restore
