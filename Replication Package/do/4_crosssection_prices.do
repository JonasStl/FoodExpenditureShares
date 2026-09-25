********************************************************************************
*							Analysis: Cross-section - Prices				*
********************************************************************************

********************************************************************************
* 					Actual correlation plot: Broad COICOP groups 			*
********************************************************************************

use "${datadir}/FESdatabase_quintiles_analysis.dta", clear

qui reg FES YR20211101000 YR20211102000 YR20211103000 YR20211105000 YR20211107000 YR20211108000 YR20219060000 YR20219080000 YR20219120000  consexp_pc_d_ln if data_icp == 1
gen esample = e(sample)

eststo m1: reg FES YR20211101000 YR20211102000 YR20211103000 YR20211105000 YR20211107000 YR20211108000 YR20219060000 YR20219080000 YR20219120000  consexp_pc_d_ln if Percentile == 1 & esample == 1
eststo m2: reg FES YR20211101000 YR20211102000 YR20211103000 YR20211105000 YR20211107000 YR20211108000 YR20219060000 YR20219080000 YR20219120000  consexp_pc_d_ln if Percentile == 3 & esample == 1
eststo m3: reg FES YR20211101000 YR20211102000 YR20211103000 YR20211105000 YR20211107000 YR20211108000 YR20219060000 YR20219080000 YR20219120000  consexp_pc_d_ln if Percentile == 5 & esample == 1

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
    xtitle("Association with food expenditure shares (pp)", size(6pt)) ///
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

graph export "${graphdir}/Figure2a.png", replace
graph export "${graphdir}/Figure2a.pdf", replace

drop esample

qui reg FES YR20211101000 YR20211102000 YR20211103000 YR20211105000 YR20211107000 YR20211108000 YR20219060000 YR20219080000 YR20219120000  consexp_pc_d_ln if data_icp == 1
gen esample = e(sample)

foreach var in YR20211101000 YR20211102000 YR20211103000 ///
               YR20211105000 YR20211107000 YR20211108000 ///
               YR20219060000 YR20219080000 YR20219120000 ///
               CoHD CoCA CoHD_ss {
    egen z_`var' = std(`var') if esample
}

eststo m1_1: reg FES z_YR20211101000 z_YR20211102000 z_YR20211103000 z_YR20211105000 z_YR20211107000 z_YR20211108000 z_YR20219060000 z_YR20219080000 z_YR20219120000  consexp_pc_d_ln if Percentile == 1 & data_icp == 1
eststo m1_2: reg FES z_CoHD z_YR20211102000 z_YR20211103000 z_YR20211105000 z_YR20211107000 z_YR20211108000 z_YR20219060000 z_YR20219080000 z_YR20219120000  consexp_pc_d_ln if Percentile == 1 & data_icp == 1
eststo m1_3: reg FES z_CoCA z_YR20211102000 z_YR20211103000 z_YR20211105000 z_YR20211107000 z_YR20211108000 z_YR20219060000 z_YR20219080000 z_YR20219120000  consexp_pc_d_ln if Percentile == 1 & data_icp == 1

eststo m2_1: reg FES z_YR20211101000 z_YR20211102000 z_YR20211103000 z_YR20211105000 z_YR20211107000 z_YR20211108000 z_YR20219060000 z_YR20219080000 z_YR20219120000  consexp_pc_d_ln if Percentile == 3 & data_icp == 1
eststo m2_2: reg FES z_CoHD z_YR20211102000 z_YR20211103000 z_YR20211105000 z_YR20211107000 z_YR20211108000 z_YR20219060000 z_YR20219080000 z_YR20219120000  consexp_pc_d_ln if Percentile == 3 & data_icp == 1
eststo m2_3: reg FES z_CoCA z_YR20211102000 z_YR20211103000 z_YR20211105000 z_YR20211107000 z_YR20211108000 z_YR20219060000 z_YR20219080000 z_YR20219120000  consexp_pc_d_ln if Percentile == 3 & data_icp == 1

eststo m3_1: reg FES z_YR20211101000 z_YR20211102000 z_YR20211103000 z_YR20211105000 z_YR20211107000 z_YR20211108000 z_YR20219060000 z_YR20219080000 z_YR20219120000  consexp_pc_d_ln if Percentile == 5 & data_icp == 1
eststo m3_2: reg FES z_CoHD YR20211102000 z_YR20211102000 z_YR20211103000 z_YR20211105000 z_YR20211107000 z_YR20211108000 z_YR20219060000 z_YR20219080000 z_YR20219120000  consexp_pc_d_ln if Percentile == 5 & data_icp == 1
eststo m3_3: reg FES z_CoCA YR20211102000 z_YR20211102000 z_YR20211103000 z_YR20211105000 z_YR20211107000 z_YR20211108000 z_YR20219060000 z_YR20219080000 z_YR20219120000 consexp_pc_d_ln if Percentile == 5 & data_icp == 1

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
    xtitle("Association with food expenditure shares (pp)", size(6pt)) ///
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

graph export "${graphdir}/Figure2b.png", replace
graph export "${graphdir}/Figure2b.pdf", replace

