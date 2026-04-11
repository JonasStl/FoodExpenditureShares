********************************************************************************
*									Maps										*
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

cd "${datadir}/World Bank Official Boundaries - Admin 0"
geoframe create _worldmap, replace

********************************************************************************
* Figure 1a
********************************************************************************

* Join the consumption data onto the ADM1 attribute frame
frame _worldmap: merge m:1 ISO_A3 using `mapdata' , nogen keep(match master)

geoplot ///
    (area _worldmap FES1, color("255 245 240" "254 224 210" "252 187 161" "252 146 114" "251 106 74" "239 59 44" "203 24 29" "165 15 21" "103 0 13") cuts(0 10 20 30 40 50 60 70 80 90) label("@lb - @ub")) || ///
    (area _worldmap FES1 if ISO_A3=="GIN", color("255 245 240" "254 224 210" "252 187 161" "252 146 114" "251 106 74" "239 59 44" "203 24 29" "165 15 21" "103 0 13") cuts(0 10 20 30 40 50 60 70 80 90) label("@lb - @ub")) || ///
    (area _worldmap FES1 if ISO_A3=="LSO", color("255 245 240" "254 224 210" "252 187 161" "252 146 114" "251 106 74" "239 59 44" "203 24 29" "165 15 21" "103 0 13") cuts(0 10 20 30 40 50 60 70 80 90) label("@lb - @ub")) || ///
    (area _worldmap FES1 if ISO_A3=="BDI", color("255 245 240" "254 224 210" "252 187 161" "252 146 114" "251 106 74" "239 59 44" "203 24 29" "165 15 21" "103 0 13") cuts(0 10 20 30 40 50 60 70 80 90) label("@lb - @ub")) || ///
    , tight graphregion(margin(zero)) plotregion(margin(b+5)) legend(title("Food expenditure shares" "Quintile 1 (poorest 20%)", size(small) color(black)) position(sw)) ///
      zoom(2:2 300 250, circle connect(lp(dash)) lcolor(gs3)) /// 
      zoom(3:5 300 300, circle connect(lp(dash)) lcolor(gs3)) ///
	  subtitle("{bf:a}", size(10pt) position(11) span) xsize(16cm) ysize(7cm)
	  
graph export "${workdir}/graphs/Figure1a.png", replace
graph export "${workdir}/graphs/Figure1a.pdf", replace

********************************************************************************
* Figure S3
********************************************************************************

geoplot ///
    (area _worldmap FES_GAP, color("255 245 240" "254 224 210" "252 187 161" "252 146 114" "251 106 74" "239 59 44" "203 24 29" "165 15 21" "103 0 13") cuts(-5 0 5 10 15 20 25 30 35 40) label("@lb - @ub")) || ///
    (area _worldmap FES_GAP if ISO_A3=="HND", color("255 245 240" "254 224 210" "252 187 161" "252 146 114" "251 106 74" "239 59 44" "203 24 29" "165 15 21" "103 0 13") cuts(-5 0 5 10 15 20 25 30 35 40) label("@lb - @ub")) || ///
    (area _worldmap FES_GAP if ISO_A3=="LKA", color("255 245 240" "254 224 210" "252 187 161" "252 146 114" "251 106 74" "239 59 44" "203 24 29" "165 15 21" "103 0 13") cuts(-5 0 5 10 15 20 25 30 35 40) label("@lb - @ub")) || ///
    (area _worldmap FES_GAP if ISO_A3=="BLZ", color("255 245 240" "254 224 210" "252 187 161" "252 146 114" "251 106 74" "239 59 44" "203 24 29" "165 15 21" "103 0 13") cuts(-5 0 5 10 15 20 25 30 35 40) label("@lb - @ub")) || ///
    , tight graphregion(margin(zero)) plotregion(margin(b+5)) legend(title("Food expenditure" "share gap:" "Quintile 1 - Quintile 5", size(small) color(black)) position(sw)) ///
      zoom(4:4 530 10, circle connect(lp(dash)) lcolor(gs3)) /// 
      zoom(3:3 300 300, circle connect(lp(dash)) lcolor(gs3)) ///
      zoom(2:2 500 250, circle connect(lp(dash)) lcolor(gs3)) 
	  
graph export "${workdir}/graphs/FigureS3.png", replace
graph export "${workdir}/graphs/FigureS3.pdf", replace


