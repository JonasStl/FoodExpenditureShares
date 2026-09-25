********************************************************************************
*								Analysis: Cross-section				*
********************************************************************************

use "${datadir}/FESdatabase_quintiles.dta", clear

bysort countrycode: egen max_anyyear  = max(year)
keep if year == max_anyyear
drop max_anyyear

keep countrycode Percentile FES
reshape wide FES, i(countrycode) j(Percentile)

gen FES_GAP = FES1-FES5

ren countrycode ISO_A3

tempfile mapdata
save `mapdata'

cd "${shapedir}"

capture confirm file "_worldmap.dta"
if _rc {
	spshape2dta "WB_GAD_ADM0", saving("_worldmap") replace
}

geoframe create _worldmap, replace

frame _worldmap: merge m:1 ISO_A3 using `mapdata' , nogen keep(match master)

geoplot ///
    (area _worldmap FES1, color("255 245 240" "254 224 210" "252 187 161" "252 146 114" "251 106 74" "239 59 44" "203 24 29" "165 15 21" "103 0 13") cuts(0 10 20 30 40 50 60 70 80 90) label("@lb - @ub")) || ///
    , tight graphregion(margin(zero)) plotregion(margin(b+5)) legend(title("Food expenditure shares" "Quintile 1 (bottom 20%)", size(small) color(black)) position(sw)) ///
	  subtitle("{bf:a}", size(10pt) position(11) span) xsize(16cm) ysize(7cm)

graph export "${graphdir}/Figure1a.png", replace
graph export "${graphdir}/Figure1a.pdf", replace

geoplot ///
    (area _worldmap FES_GAP, color("255 245 240" "254 224 210" "252 187 161" "252 146 114" "251 106 74" "239 59 44" "203 24 29" "165 15 21" "103 0 13") cuts(-5 0 5 10 15 20 25 30 35 40) label("@lb - @ub")) || ///
    , tight graphregion(margin(zero)) plotregion(margin(b+5)) legend(title("Food expenditure" "share gap:" "Quintile 1 - Quintile 5", size(small) color(black)) position(sw)) ///

graph export "${graphdir}/FigureS1.png", replace
graph export "${graphdir}/FigureS1.pdf", replace
