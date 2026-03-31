/*******************************************************************************
* Project:  Experiential Learning Namibia
* File:     02_analysis.do
* Purpose:  Replicates manuscript figures and appendix tables/figures
* Data:     processed/survey_explearning.dta
*
* Notes:	This script is organized by paper output.
*******************************************************************************/


clear all
set more off


/*****************************************************************************
* 1. Load analysis data
*****************************************************************************/

use "$projectdir/processed/survey_explearning.dta", clear
xtset ind_ID followup

/*******************************************************************************
* 2. Common globals
*******************************************************************************/

global controls gender_female age_above34 married educ_level role_gov
global outcomes z_threat z_selfeff z_outeff z_costs intergen_empathy_dum intergen_image_dum intergen_approval_dum intergen_concern_dum info_impact_dum info_strat_dum


/*******************************************************************************
* 3. Main manuscript figures
*******************************************************************************/

*------------------------------------------------------------------------------*
* Figure 3: * Distribution of outcome measures across all surveyed participants
*------------------------------------------------------------------------------*
stripplot z_threat_norm z_selfeff_norm z_outeff_norm z_costs_norm if followup==0, ///
    msymbol(oh) mcolor(black%30) ///
    yla(0(20)100, labsize(medsmall) nogrid) msize(medium) ///
    xtitle("") ytitle("Score", size(medium)) ///
    vertical center cumul cumprob bar boffset(0) ///
    refline(lw(medium) lc(red) lp(dash)) reflinestretch(0.01) ///
    xlabel(1 "Threat Appraisal" ///
           2 "Self-efficacy" ///
           3 "Outcome efficacy" ///
           4 "Perceived costs", ///
           labsize(small) noticks) ///
    yla(, ang(h)) jitter(0.5) ///
    title("{bf: A} Threat Appraisal and Perceived Behavior Control", placement(left) margin(0 0 5 0)) ///
    xsize(5) ysize(2.5)
gr save "$projectdir/results/intermediate/Figure3_panelA.gph", replace

graph hbar intergen_empathy_pct intergen_image_pct intergen_approval_pct intergen_concern_pct info_impact_pct info_strat_pct if followup==0, bargap(50) ylabel(0 "0%" 20 "20%" 40 "40%" 60 "60%" 80 "80%" 100 "100%", angle(horizontal) labsize(medsmall)) blabel(bar, format(%2.0f) size(medsmall) color(black)) ///
    legend(position(6) cols(1) ///
        label(1 "Empathy of future generations") ///
        label(2 "Imagination of future generations") ///
        label(3 "Importance of social approval from future & current generations") ///
        label(4 "Consideration of future & current concerns") ///
        label(5 "Information demand: Impacts") ///
        label(6 "Information demand: Adaptation strategies")) ///
    title("{bf:B} Intergenerational Dimensions and Information Demand", ///
        placement(left) margin(0 0 5 0)) ///
    bar(1, color(gs0)) bar(2, color(gs3)) bar(3, color(gs6)) bar(4, color(gs9)) bar(5, color(gs12)) bar(6, color(gs13)) ///
    xsize(5) ysize(2.5)
gr save "$projectdir/results/intermediate/Figure3_panelB.gph", replace

graph combine "$projectdir/results/intermediate/Figure3_panelA.gph" ///
              "$projectdir/results/intermediate/Figure3_panelB.gph", ///
              cols(2) xsize(12) ysize(5) imargin(1 1 1 1) ///
              saving("$projectdir/results/intermediate/Figure3.gph", replace)
    graph export "$projectdir/results/figures/Figure3_distribution_outcomes.png", replace width(4000)

*------------------------------------------------------------------------------*
* Figure 4
* Main workshop-day effects of the intervention on experiential-learning outcomes
*------------------------------------------------------------------------------*
eststo clear
foreach y of varlist $outcomes {
    qui reg `y' i.time_treat $controls i.site_ID if followup == 0, vce(cluster site_ID)
    eststo `y'
}

coefplot ///
(z_threat, label("Threat appraisal") msize(medium) mcolor(gs8) levels(95 90) ciopts(color(gs8 gs8) lw(0.4 1))) ///
(z_selfeff, label("Self-efficacy") msize(medium) mcolor(gs8) levels(95 90) ciopts(color(gs8 gs8) lw(0.4 1))) ///
(z_outeff, label("Outcome-efficacy") msize(medium) mcolor(gs8) levels(95 90) ciopts(color(gs8 gs8) lw(0.4 1))) ///
(z_costs, label("Perceived costs") msize(medium) mcolor(gs8) levels(95 90) ciopts(color(gs8 gs8) lw(0.4 1))) ///
(intergen_empathy_dum, label("Empathy toward future generation") msize(medium) mcolor(gs8) levels(95 90) ciopts(color(gs8 gs8) lw(0.4 0.8))) ///
(intergen_image_dum, label("Imagination of future generations") msize(medium) mcolor(gs8) levels(95 90) ciopts(color(gs8 gs8) lw(0.4 1))) ///
(intergen_approval_dum, label("Care about today's & future's social approval") msize(medium) mcolor(gs8) levels(95 90) ciopts(color(gs8 gs8) lw(0.4 1))) ///
(intergen_concern_dum, label("Consideration of immediate & future concerns") msize(medium) mcolor(gs8) levels(95 90) ciopts(color(gs8 gs8) lw(0.4 1))) ///
(info_impact_dum, label("Information demand about impacts of cc") msize(medium) mcolor(gs8) levels(95 90) ciopts(color(gs8 gs8) lw(0.4 1))) ///
(info_strat_dum, label("Information demand about adaptation strategies") msize(medium) mcolor(gs8) levels(95 90) ciopts(color(gs8 gs8) lw(0.4 1))) ///
, keep(1.time_treat) ///
  ylabel(0.6 "Threat appraisal" 0.69 "Self-efficacy" 0.78 "Outcome-efficacy" 0.87 "Perceived costs" 0.96 `" "Empathy toward" "future generation" "' 1.05 `" "Imagination of" "future generations" "' 1.14 `" "Care about generations" "of today and in future" "' 1.23 `" "Consideration of immediate" "& future concerns" "' 1.32 `" "Information demand" "about impacts of cc" "' 1.41 `" "Information demand about" "adaptation strategies" "', valuelabel labsize(small)) ///
  xlabel(-0.6(0.2)0.8, labsize(small)) ///
  title("{bf: A} T1 - After game", size() margin(b+2)) ///
  coeflabels(1.time_treat = " ") ///
  xline(0) legend(off) scale(1) xsize(3) ysize(2) ///
saving("$projectdir/results/intermediate/Figure4_T1.gph", replace)

coefplot ///
(z_threat, label("Threat appraisal") msize(medium) mcolor(gs8) levels(95 90) ciopts(color(gs8 gs8) lw(0.4 1))) ///
(z_selfeff, label("Self-efficacy") msize(medium) mcolor(gs8) levels(95 90) ciopts(color(gs8 gs8) lw(0.4 1))) ///
(z_outeff, label("Outcome-efficacy") msize(medium) mcolor(gs8) levels(95 90) ciopts(color(gs8 gs8) lw(0.4 1))) ///
(z_costs, label("Perceived costs") msize(medium) mcolor(gs8) levels(95 90) ciopts(color(gs8 gs8) lw(0.4 1))) ///
(intergen_empathy_dum, label("Empathy toward future generation") msize(medium) mcolor(gs8) levels(95 90) ciopts(color(gs8 gs8) lw(0.4 1))) ///
(intergen_image_dum, label("Imagination of future generations") msize(medium) mcolor(gs8) levels(95 90) ciopts(color(gs8 gs8) lw(0.4 1))) ///
(intergen_approval_dum, label("Care about today's & future's social approval") msize(medium) mcolor(gs8) levels(95 90) ciopts(color(gs8 gs8) lw(0.4 1))) ///
(intergen_concern_dum, label("Consideration of immediate & future concerns") msize(medium) mcolor(gs8) levels(95 90) ciopts(color(gs8 gs8) lw(0.4 1))) ///
(info_impact_dum, label("Information demand about impacts of cc") msize(medium) mcolor(gs8) levels(95 90) ciopts(color(gs8 gs8) lw(0.4 1))) ///
(info_strat_dum, label("Information demand about adaptation strategies") msize(medium) mcolor(gs8) levels(95 90) ciopts(color(gs8 gs8) lw(0.4 1))) ///
, keep(2.time_treat) ///
  ylabel(0.6 "Threat appraisal" 0.69 "Self-efficacy" 0.78 "Outcome-efficacy" 0.87 "Perceived costs" 0.96 `" "Empathy toward" "future generation" "' 1.05 `" "Imagination of" "future generations" "' 1.14 `" "Care about generations" "of today and in future" "' 1.23 `" "Consideration of immediate" "& future concerns" "' 1.32 `" "Information demand" "about impacts of cc" "' 1.41 `" "Information demand about" "adaptation strategies" "', valuelabel labsize(small)) ///
  xlabel(-0.6(0.2)0.8, labsize(small)) ///
  title("{bf: B} T2 - After game & workshop", margin(b+2)) ///
  coeflabels(2.time_treat = " ") ///
  xline(0) legend(off) scale(1) xsize(3) ysize(2) ///
saving("$projectdir/results/intermediate/Figure4_T2.gph", replace)

graph combine "$projectdir/results/intermediate/Figure4_T1.gph" ///
              "$projectdir/results/intermediate/Figure4_T2.gph", ///
              cols(2) xsize(12) ysize(6) imargin(1 1 1 1) ///
              saving("$projectdir/results/intermediate/Figure4.gph", replace)
graph export "$projectdir/results/figures/Figure4_main_effects.png", replace width(4000)

*------------------------------------------------------------------------------*
* Figure 5
* 8-month persistence (within-subject, T2 only)
*------------------------------------------------------------------------------*
eststo clear
foreach y of varlist $outcomes {
    qui reg `y' i.balanced_followup $controls i.site_ID if time_treat == 2, vce(cluster ind_ID)
    eststo `y'_p
}

coefplot ///
(z_threat_p, label("Threat appraisal") msize(medium) mcolor(gs8) levels(95 90) ciopts(color(gs8 gs8) lw(0.4 1))) ///
(z_selfeff_p, label("Self-efficacy") msize(medium) mcolor(gs8) levels(95 90) ciopts(color(gs8 gs8) lw(0.4 1))) ///
(z_outeff_p, label("Outcome-efficacy") msize(medium) mcolor(gs8) levels(95 90) ciopts(color(gs8 gs8) lw(0.4 1))) ///
(z_costs_p, label("Perceived costs") msize(medium) mcolor(gs8) levels(95 90) ciopts(color(gs8 gs8) lw(0.4 1))) ///
(intergen_empathy_dum_p, label("Empathy toward future generation") msize(medium) mcolor(gs8) levels(95 90) ciopts(color(gs8 gs8) lw(0.4 1))) ///
(intergen_image_dum_p, label("Imagination of future generations") msize(medium) mcolor(gs8) levels(95 90) ciopts(color(gs8 gs8) lw(0.4 1))) ///
(intergen_approval_dum_p, label("Care about today's & future's social approval") msize(medium) mcolor(gs8) levels(95 90) ciopts(color(gs8 gs8) lw(0.4 1))) ///
(intergen_concern_dum_p, label("Consideration of immediate & future concerns") msize(medium) mcolor(gs8) levels(95 90) ciopts(color(gs8 gs8) lw(0.4 1))) ///
(info_impact_dum_p, label("Information demand about impacts of cc") msize(medium) mcolor(gs8) levels(95 90) ciopts(color(gs8 gs8) lw(0.4 1))) ///
(info_strat_dum_p, label("Information demand about adaptation strategies") msize(medium) mcolor(gs8) levels(95 90) ciopts(color(gs8 gs8) lw(0.4 1))) ///
, keep(1.balanced_followup) ///
  ylabel(0.6 "Threat appraisal" 0.69 "Self-efficacy" 0.78 "Outcome-efficacy" 0.87 "Perceived costs" 0.96 `" "Empathy toward" "future generation" "' 1.05 `" "Imagination of" "future generations" "' 1.14 `" "Care about generations" "of today and in future" "' 1.23 `" "Consideration of immediate" "& future concerns" "' 1.32 `" "Information demand" "about impacts of cc" "' 1.41 `" "Information demand about" "adaptation strategies" "', valuelabel labsize(small)) ///
  xlabel(-0.6(0.2)1.2, labsize(small)) ///
  coeflabels(1.balanced_followup = " ") ///
  xline(0) legend(off) scale(1.05) xsize(3) ysize(2) ///
  saving("$projectdir/results/intermediate/Figure5.gph", replace) ///
  caption("Regression estimate relative to intervention day")
graph export "$projectdir/results/figures/Figure5_persistence.png", replace width(4000)

/*******************************************************************************
* 4. Appendix figures
*******************************************************************************/

*------------------------------------------------------------------------------*
* Figure A2
* Distributions of index outcome variables over time
*------------------------------------------------------------------------------*
foreach y in z_threat_norm z_selfeff_norm z_outeff_norm z_costs_norm {
    if "`y'" == "z_threat_norm" {
        local ttl "Threat appraisal index over time"
    }
    else if "`y'" == "z_selfeff_norm" {
        local ttl "Self-efficacy index over time"
    }
    else if "`y'" == "z_outeff_norm" {
        local ttl "Outcome-efficacy index over time"
    }
    else if "`y'" == "z_costs_norm" {
        local ttl "Perceived costs index over time"
    }

    stripplot `y', over(time4) variablelabels ///
        msymbol(oh) mcolor(black%30) ///
        yla(0(20)100, labsize(small) nogrid) ///
        msize(medium) ///
        xtitle("") ytitle("Score", size(small)) ///
        vertical center cumul cumprob bar boffset(0) ///
        refline(lw(medium) lc(red) lp(dash)) ///
        reflinestretch(0.01) ///
        xla(, labsize(small) noticks) ///
        yla(, ang(h)) ///
        jitter(0.5) ///
        title("`ttl'", size(medium) placement(left) margin(0 0 5 0)) ///
        saving("$projectdir/results/intermediate/`y'_A2.gph", replace)
}

graph combine "$projectdir/results/intermediate/z_threat_norm_A2.gph" ///
              "$projectdir/results/intermediate/z_selfeff_norm_A2.gph" ///
              "$projectdir/results/intermediate/z_outeff_norm_A2.gph" ///
              "$projectdir/results/intermediate/z_costs_norm_A2.gph", ///
              cols(2)iscale(0.6) xsize(15) ysize(10) ///
              saving("$projectdir/results/intermediate/FigureA2.gph", replace)
graph export "$projectdir/results/figures/FigureA2_distribution_index_outcomes.png", replace width(4000)

*------------------------------------------------------------------------------*
* Figure A3
* Distributions of binary outcome variables over time
*------------------------------------------------------------------------------*
mylabels 0(20)100, myscale(@) suffix("%") local(pctlabel)
foreach y in intergen_empathy_dum intergen_image_dum intergen_approval_dum intergen_concern_dum info_impact_dum info_strat_dum {
    local ttl : variable label `y'
    catplot, over(`y') over(time4, label()) asyvars stack percent(time4) ///
        ylabel(`pctlabel', nogrid) ///
        blabel(bar, size(small) format(%9.0f) pos(center) color(black)) ///
        title("`ttl'", size(medsmall)) legend(rows(1) position(6)) ///
        bar(1, fcolor(gs6) lcolor(black) lwidth(thin)) ///
        bar(2, fcolor(gs10) lcolor(black) lwidth(thin)) ///
        saving("$projectdir/results/intermediate/`y'_A3.gph", replace)
}

graph combine "$projectdir/results/intermediate/intergen_empathy_dum_A3.gph" ///
              "$projectdir/results/intermediate/intergen_image_dum_A3.gph" ///
              "$projectdir/results/intermediate/intergen_approval_dum_A3.gph" ///
              "$projectdir/results/intermediate/intergen_concern_dum_A3.gph" ///
              "$projectdir/results/intermediate/info_impact_dum_A3.gph" ///
              "$projectdir/results/intermediate/info_strat_dum_A3.gph", ///
              cols(2) iscale(0.4) xsize(15) ysize(10) ///
              saving("$projectdir/results/intermediate/FigureA3.gph", replace)
graph export "$projectdir/results/figures/FigureA3_distribution_binary_outcomes.png", replace width(4000)

/*******************************************************************************
* 5. Appendix tables: descriptives, balance, attrition, main results
*******************************************************************************/

*------------------------------------------------------------------------------*
* Table A3
* Average socio-economic sample characteristics
*------------------------------------------------------------------------------*

estpost summarize gender_female educ_level_low educ_level_mid educ_level_high age ///
    years_residence_com role_gov trust_high income_employed income_farming ///
    income_business income_remittances food_insec_month adapt_effort_no respon_external ///
    if followup == 0

esttab using "$projectdir/results/tables/TableA3_sample_characteristics.rtf", replace ///
    cells("mean(fmt(2)) sd(fmt(2)) count") collabels("Mean" "SD" "N") ///
    nomtitle nonumber noobs label
	
*------------------------------------------------------------------------------*
* Table A4
* Perceived challenges in the community today and in 20 years
*------------------------------------------------------------------------------*
eststo clear

estpost summarize severity1_unempl severity1_poverty severity1_climate ///
                  severity1_electricity severity1_crime severity1_health ///
                  severity1_landuse severity1_economy severity1_corruption ///
                  severity1_youth if followup==0
eststo today
esttab today using "$projectdir/results/tables/TableA4_severity_today.rtf", ///
    cells("mean(fmt(2)) sd(fmt(2)) count(fmt(0))") ///
    label noobs nonumber nomtitle replace


estpost summarize severity2_unempl severity2_climate severity2_poverty ///
                  severity2_health severity2_corruption severity2_crime ///
                  severity2_youth severity2_economy severity2_landuse ///
                  severity2_childabuse severity2_electricity if followup==0
eststo future
esttab future using "$projectdir/results/tables/TableA4_severity_future.rtf", ///
    cells("mean(fmt(2)) sd(fmt(2)) count(fmt(0))") ///
    label noobs nonumber nomtitle replace
	
*------------------------------------------------------------------------------*
* Table A5
* Balance table of socio-economic characteristics across treatment groups
*------------------------------------------------------------------------------*
iebaltab gender_female  age_above34 married educ_level_low educ_level_mid  educ_level_high role_gov if followup==0, vce(robust) grpvar(time_treat) rowvarlabels format(%9.2f) savexlsx("$projectdir/results/tables/TableA5_balance_treatment.xlsx") replace

*------------------------------------------------------------------------------*
* Table A6
* Attrition rates by treatment arm
*------------------------------------------------------------------------------*

preserve
keep if followup == 0

    quietly tab time_treat attrited, chi2
    local p : display %5.3f r(p)

    tempname mem
    tempfile a6
    postfile `mem' str30 treatment_arm int N str18 returned str18 attrited using `a6', replace

    * Overall
    quietly count
    local N = r(N)
    quietly count if attrited == 0
    local nret = r(N)
    quietly count if attrited == 1
    local nattr = r(N)
    local pret  : display %5.2f 100*`nret'/`N'
    local pattr : display %5.2f 100*`nattr'/`N'

    post `mem' ("Overall") (`N') ("`nret' (`pret'%)") ("`nattr' (`pattr'%)")

    * By treatment arm
    levelsof time_treat, local(levels)
    foreach t of local levels {
        local lab : label (time_treat) `t'
        quietly count if time_treat == `t'
        local N = r(N)
        quietly count if time_treat == `t' & attrited == 0
        local nret = r(N)
        quietly count if time_treat == `t' & attrited == 1
        local nattr = r(N)
        local pret  : display %5.2f 100*`nret'/`N'
        local pattr : display %5.2f 100*`nattr'/`N'

        post `mem' ("`lab'") (`N') ("`nret' (`pret'%)") ("`nattr' (`pattr'%)")
    }

    post `mem' ("p-value (chi2 test)") (.) ("") ("`p'")
    postclose `mem'

    use `a6', clear
    export excel using "$projectdir/results/tables/TableA6_attrition_rates.xlsx", firstrow(variables) replace

restore

*------------------------------------------------------------------------------*
* Table A7
* Balance table by attrition status
*------------------------------------------------------------------------------*

iebaltab gender_female  age_above34 married educ_level_low educ_level_mid  educ_level_high role_gov if followup == 0, grpvar(attrited) vce(robust) rowvarlabels format(%9.2f) savexlsx("$projectdir/results/tables/TableA7_balance_attrition.xlsx") replace

*------------------------------------------------------------------------------*
* Table A8
* Pairwise t-tests for outcome variables
*------------------------------------------------------------------------------*
iebaltab $outcomes if followup == 0, grpvar(time_treat) vce(robust) ftest rowvarlabels ///
    format(%9.2f) savexlsx("$projectdir/results/tables/TableA8_pairwise_ttests.xlsx") replace

*------------------------------------------------------------------------------*
* Table A9
* Main average treatment effects
*------------------------------------------------------------------------------*
eststo clear
foreach y of varlist $outcomes {
    
    * Without controls
    qui reg `y' i.time_treat i.site_ID if followup == 0, vce(cluster site_ID)
    eststo `y'_nc
    
    * With controls
    qui reg `y' i.time_treat $controls i.site_ID if followup == 0, vce(cluster site_ID)
    eststo `y'_c
}

* Build model list in outcome order
local models
foreach y of global outcomes {
    local models `models' `y'_nc `y'_c
}

esttab `models' ///
    using "$projectdir/results/tables/TableA9_main_ATE.rtf", replace ///
    se(%4.2f) b(%4.2f) star(* 0.10 ** 0.05 *** 0.01) label ///
    keep(1.time_treat 2.time_treat gender_female age_above34 married educ_level role_gov _cons) ///
    stats(N r2_a, fmt(0 3) labels("Observations" "Adj. R-squared")) ///
    mgroups("Threat appraisal" "Self-efficacy" "Outcome-efficacy" "Perceived Costs" "Empathy toward future generation" "Imagination of future generations" "Care about today's & future's social approval" "Consideration of immediate & future concerns" "Information demand about impacts of cc" "Information demand about adaptation strategies", pattern(1 0) span)
*------------------------------------------------------------------------------*
* Table A10
* Within-subject time trends eight months after the intervention (T2 group)
*------------------------------------------------------------------------------*
eststo clear
foreach y of varlist $outcomes {
    qui reg `y' i.balanced_followup $controls i.site_ID if time_treat == 2, vce(cluster ind_ID)
    eststo `y'_p
}

esttab z_threat_p z_selfeff_p z_outeff_p z_costs_p intergen_empathy_dum_p intergen_image_dum_p ///
       intergen_approval_dum_p intergen_concern_dum_p info_impact_dum_p info_strat_dum_p ///
       using "$projectdir/results/tables/TableA10_persistence_T2.rtf", replace ///
	   star(* 0.10 ** 0.05 *** 0.01) se(%4.2f) b(%4.2f) label ///
	   keep(1.balanced_followup gender_female age_above34 married educ_level role_gov _cons) ///
stats(N r2_a, fmt(0 3) labels("Observations" "Adj. R-squared")) addnotes("Notes: Estimates are from linear regression models with site fixed effects and standard errors clustered at individual level including control variables (unbalanced socio-economic characteristics); standard errors in parentheses; * p < 0.10, ** p < 0.05, *** p < 0.01.") mtitles("Threat appraisal" "Self-efficacy" "Outcome-efficacy" "Perceived Costs" "Empathy toward future generation"  "Imagination of future generations" "Care about today's & future's social approval"  "Consideration of immediate & future concerns"    "Information demand about impacts of cc" "Information demand about adaptation strategies") varlabels(,elist(weight:_cons "{break}{hline @width}")) 

/*******************************************************************************
* 6. Appendix tables: heterogeneity
*******************************************************************************/

*------------------------------------------------------------------------------*
* Table A11
* Heterogeneous effects by gender
*------------------------------------------------------------------------------*
eststo clear
foreach y of varlist $outcomes {
    qui reg `y' i.time_treat##i.gender_female age_above34 married educ_level role_gov i.site_ID ///
        if followup == 0, vce(cluster site_ID)
    eststo `y'_g
}

esttab z_threat_g z_selfeff_g z_outeff_g z_costs_g intergen_empathy_dum_g intergen_image_dum_g ///
       intergen_approval_dum_g intergen_concern_dum_g info_impact_dum_g info_strat_dum_g ///
       using "$projectdir/results/tables/TableA11_heterogeneity_gender.rtf", replace ///
       keep(1.time_treat 2.time_treat 1.gender_female 1.time_treat#1.gender_female 2.time_treat#1.gender_female age_above34 married educ_level role_gov _cons) star(* 0.10 ** 0.05 *** 0.01) label se(%4.2f) b(%4.2f) stats(N r2_a, fmt(0 3) labels("Observations" "Adj. R-squared")) addnotes("Notes: Estimates are from linear regression models with site fixed effects and standard errors clustered at site level. * p < 0.10, ** p < 0.05, *** p < 0.01.") mtitles("Threat Appraisal" "Self-efficacy" "Outcome-efficacy" "Perceived Costs" "Empathy toward future generation"  "Imagination of future generations" "Care about today's & future's social approval"  "Consideration of immediate & future concerns" "Information demand about impacts of cc"  "Information demand about adaptation strategies"  ) varlabels(,elist(weight:_cons "{break}{hline @width}"))

*------------------------------------------------------------------------------*
* Table A12
* Heterogeneous effects by age
*------------------------------------------------------------------------------*
eststo clear
foreach y of varlist $outcomes {
    qui reg `y' i.time_treat##i.age_above34 gender_female married educ_level role_gov i.site_ID ///
        if followup == 0, vce(cluster site_ID)
    eststo `y'_a
}

esttab z_threat_a z_selfeff_a z_outeff_a z_costs_a intergen_empathy_dum_a intergen_image_dum_a ///
       intergen_approval_dum_a intergen_concern_dum_a info_impact_dum_a info_strat_dum_a ///
       using "$projectdir/results/tables/TableA12_heterogeneity_age.rtf", replace ///
       keep(1.time_treat 2.time_treat 1.age_above34 1.time_treat#1.age_above34 2.time_treat#1.age_above34 gender_female married educ_level role_gov _cons) star(* 0.10 ** 0.05 *** 0.01) label se(%4.2f)  b(%4.2f)   stats(N r2_a, fmt(0 3) labels("Observations" "Adj. R-squared")) addnotes("Notes: Estimates are from linear regression models with site fixed effects and standard errors clustered at site level. * p < 0.10, ** p < 0.05, *** p < 0.01.") mtitles("Threat Appraisal" "Self-efficacy" "Outcome-efficacy" "Perceived Costs" "Empathy toward future generation"  "Imagination of future generations" "Care about today's & future's social approval"  "Consideration of immediate & future concerns" "Information demand about impacts of cc"  "Information demand about adaptation strategies"  ) varlabels(,elist(weight:_cons "{break}{hline @width}"))

*------------------------------------------------------------------------------*
* Table A13
* Heterogeneous effects by education
*------------------------------------------------------------------------------*
eststo clear
foreach y of varlist $outcomes {
    qui reg `y' i.time_treat##i.educ_level_high gender_female age_above34 married educ_level role_gov i.site_ID ///
        if followup == 0, vce(cluster site_ID)
    eststo `y'_e
}

esttab z_threat_e z_selfeff_e z_outeff_e z_costs_e intergen_empathy_dum_e intergen_image_dum_e ///
       intergen_approval_dum_e intergen_concern_dum_e info_impact_dum_e info_strat_dum_e ///
       using "$projectdir/results/tables/TableA13_heterogeneity_education.rtf", replace ///
       keep(1.time_treat 2.time_treat 1.educ_level_high 1.time_treat#1.educ_level_high 2.time_treat#1.educ_level_high gender_female age_above34 married educ_level role_gov _cons) star(* 0.10 ** 0.05 *** 0.01) label se(%4.2f)  b(%4.2f)   stats(N r2_a, fmt(0 3) labels("Observations" "Adj. R-squared")) addnotes("Notes: Estimates are from linear regression models with site fixed effects and standard errors clustered at site level. * p < 0.10, ** p < 0.05, *** p < 0.01.") mtitles("Threat Appraisal" "Self-efficacy" "Outcome-efficacy" "Perceived Costs" "Empathy toward future generation"  "Imagination of future generations" "Care about today's & future's social approval"  "Consideration of immediate & future concerns" "Information demand about impacts of cc"  "Information demand about adaptation strategies"  ) varlabels(,elist(weight:_cons "{break}{hline @width}"))

*------------------------------------------------------------------------------*
* Table A14
* Heterogeneous effects by socio-economic status
*------------------------------------------------------------------------------*
eststo clear
foreach y of varlist $outcomes {
    qui reg `y' i.time_treat##i.SES_above_median gender_female age_above34 married educ_level role_gov i.site_ID ///
        if followup == 0, vce(cluster site_ID)
    eststo `y'_s
}

esttab z_threat_s z_selfeff_s z_outeff_s z_costs_s intergen_empathy_dum_s intergen_image_dum_s ///
       intergen_approval_dum_s intergen_concern_dum_s info_impact_dum_s info_strat_dum_s ///
       using "$projectdir/results/tables/TableA14_heterogeneity_ses.rtf", replace ///
       keep(1.time_treat 2.time_treat 1.SES_above_median 1.time_treat#1.SES_above_median 2.time_treat#1.SES_above_median gender_female age_above34 married educ_level role_gov _cons) star(* 0.10 ** 0.05 *** 0.01) label se(%4.2f)  b(%4.2f)   stats(N r2_a, fmt(0 3) labels("Observations" "Adj. R-squared")) addnotes("Notes: Estimates are from linear regression models with site fixed effects and standard errors clustered at site level. * p < 0.10, ** p < 0.05, *** p < 0.01.") mtitles("Threat Appraisal" "Self-efficacy" "Outcome-efficacy" "Perceived Costs" "Empathy toward future generation"  "Imagination of future generations" "Care about today's & future's social approval"  "Consideration of immediate & future concerns" "Information demand about impacts of cc"  "Information demand about adaptation strategies"  ) varlabels(,elist(weight:_cons "{break}{hline @width}"))

*------------------------------------------------------------------------------*
* Table A15
* Heterogeneous effects by community leadership
*------------------------------------------------------------------------------*
eststo clear
foreach y of varlist $outcomes {
    qui reg `y' i.time_treat##i.role_gov gender_female age_above34 married educ_level i.site_ID ///
        if followup == 0, vce(cluster site_ID)
    eststo `y'_l
}

esttab z_threat_l z_selfeff_l z_outeff_l z_costs_l intergen_empathy_dum_l intergen_image_dum_l ///
       intergen_approval_dum_l intergen_concern_dum_l info_impact_dum_l info_strat_dum_l ///
       using "$projectdir/results/tables/TableA15_heterogeneity_leadership.rtf", replace ///
       keep(1.time_treat 2.time_treat 1.role_gov 1.time_treat#1.role_gov 2.time_treat#1.role_gov gender_female age_above34 married educ_level _cons) star(* 0.10 ** 0.05 *** 0.01) label se(%4.2f)  b(%4.2f)   stats(N r2_a, fmt(0 3) labels("Observations" "Adj. R-squared")) addnotes("Notes: Estimates are from linear regression models with site fixed effects and standard errors clustered at site level. * p < 0.10, ** p < 0.05, *** p < 0.01.") mtitles("Threat Appraisal" "Self-efficacy" "Outcome-efficacy" "Perceived Costs" "Empathy toward future generation"  "Imagination of future generations" "Care about today's & future's social approval"  "Consideration of immediate & future concerns" "Information demand about impacts of cc"  "Information demand about adaptation strategies"  ) varlabels(,elist(weight:_cons "{break}{hline @width}"))
	   
*------------------------------------------------------------------------------*
* Table A16
* Heterogeneous effects by receiving framing during the workshop day
*------------------------------------------------------------------------------*
eststo clear
foreach y of varlist $outcomes {
    qui reg `y' i.time_treat##i.framing gender_female age_above34 married educ_level role_gov i.site_ID ///
        if followup == 0, vce(cluster site_ID)
    eststo `y'_f
}

esttab z_threat_f z_selfeff_f z_outeff_f z_costs_f intergen_empathy_dum_f intergen_image_dum_f ///
       intergen_approval_dum_f intergen_concern_dum_f info_impact_dum_f info_strat_dum_f ///
       using "$projectdir/results/tables/TableA16_heterogeneity_framing.rtf", replace ///
       keep(1.time_treat 2.time_treat 1.framing 1.time_treat#1.framing 2.time_treat#1.framing ///
            gender_female age_above34 married educ_level role_gov _cons) star(* 0.10 ** 0.05 *** 0.01) label se(%4.2f)  b(%4.2f)   stats(N r2_a, fmt(0 3) labels("Observations" "Adj. R-squared")) addnotes("Notes: Estimates are from linear regression models with site fixed effects and standard errors clustered at site level. * p < 0.10, ** p < 0.05, *** p < 0.01.") mtitles("Threat Appraisal" "Self-efficacy" "Outcome-efficacy" "Perceived Costs" "Empathy toward future generation"  "Imagination of future generations" "Care about today's & future's social approval"  "Consideration of immediate & future concerns" "Information demand about impacts of cc"  "Information demand about adaptation strategies"  ) varlabels(,elist(weight:_cons "{break}{hline @width}"))

*------------------------------------------------------------------------------*
* Table A17
* Between-subject comparison by meditation treatment
*------------------------------------------------------------------------------*

eststo clear
foreach y of varlist $outcomes {
	
	* Without controls
    qui reg `y' i.meditation if time_treat == 1 & followup == 0, vce(cluster site_ID)
    eststo `y'_m_nc
    
	* With controls
    qui reg `y' i.meditation $controls if time_treat == 1 & followup == 0, vce(cluster site_ID)
    eststo `y'_m_c
}

* Build model list in outcome order
local models
foreach y of global outcomes {
    local models `models' `y'_m_nc `y'_m_c
}

esttab `models' ///
    using "$projectdir/results/tables/TableA17_meditation_comparison.rtf", replace ///
    keep(1.meditation gender_female age_above34 married educ_level role_gov _cons) ///
    star(* 0.10 ** 0.05 *** 0.01) label se(%4.2f) b(%4.2f) ///
    stats(N r2_a, fmt(0 3) labels("Observations" "Adj. R-squared"))

/*******************************************************************************
* 7. Appendix tables: robustness
*******************************************************************************/

*------------------------------------------------------------------------------*
* Table A18
* Placebo outcome tests:
* 	These variables should NOT be affected by the game/workshop.
* 	- ladder_today: self-assessed current position on ladder of life (1-10)
* 	- food_insec_month: food insecurity at least monthly (general survey, binary)
* 	> A significant treatment coefficient would flag balance problems or
* 	  demand contamination.
*------------------------------------------------------------------------------*
eststo clear
foreach y in ladder_today food_insec_month {
    qui reg `y' i.time_treat $controls i.site_ID if followup == 0, vce(cluster site_ID)
    eststo placebo_`y'
}

esttab placebo_ladder_today placebo_food_insec_month using "$projectdir/results/tables/TableA18_placebo_tests.rtf", replace ///
    keep(1.time_treat 2.time_treat) ///
    star(* 0.10 ** 0.05 *** 0.01) label se(%4.2f) b(%4.2f) ///
    stats(N r2_a, fmt(0 3) labels("Observations" "Adj. R-squared"))

*------------------------------------------------------------------------------*
* Tables A19
* Wild cluster bootstrap p-values and BH q-values:
* 	With only 26 clusters, conventional cluster-robust SEs may over-reject.
* 	Wild cluster bootstrap (Cameron, Gelbach & Miller 2008; Roodman et al.
* 	2019) provides asymptotic refinement for more reliable p-values.
*------------------------------------------------------------------------------*

cap which boottest
if _rc {
    ssc install boottest, replace
}



* Matrix to store results: rows = outcomes, cols = conv_p_T1, wcb_p_T1, conv_p_T2, wcb_p_T2
local nout : word count $outcomes
matrix WCB_immediate = J(`nout', 4, .)
matrix colnames WCB_immediate = "Conv_p_T1" "WCB_p_T1" "Conv_p_T2" "WCB_p_T2"
local rownames ""

local i = 0
foreach v of varlist $outcomes {
    local ++i

    reg `v' i.time_treat $controls i.site_ID if followup==0, vce(cluster site_ID)

    * Conventional p-values from regression
    matrix WCB_immediate[`i', 1] = 2 * ttail(e(df_r), abs(_b[1.time_treat] / _se[1.time_treat]))
    matrix WCB_immediate[`i', 3] = 2 * ttail(e(df_r), abs(_b[2.time_treat] / _se[2.time_treat]))

    * Wild cluster bootstrap for T1 (after game)
    boottest 1.time_treat, cluster(site_ID) boottype(wild) reps(9999) seed(12345)
    matrix WCB_immediate[`i', 2] = r(p)

    * Wild cluster bootstrap for T2 (after game+workshop)
    boottest 2.time_treat, cluster(site_ID) boottype(wild) reps(9999) seed(12345)
    matrix WCB_immediate[`i', 4] = r(p)

    local rownames `rownames' `v'
}

matrix rownames WCB_immediate = `rownames'
matlist WCB_immediate, format(%6.4f) title("Immediate Effects: Conventional vs. Wild Cluster Bootstrap p-values")

* Export WCB results to RTF
* Immediate effects
eststo clear
local i = 0
foreach v of varlist $outcomes {
    local ++i
    reg `v' i.time_treat $controls i.site_ID if followup==0, vce(cluster site_ID)
    estadd scalar wcb_p_t1 = WCB_immediate[`i', 2]
    estadd scalar wcb_p_t2 = WCB_immediate[`i', 4]
    eststo wcb`i'
}

esttab wcb1 wcb2 wcb3 wcb4 wcb5 wcb6 wcb7 wcb8 wcb9 wcb10 ///
    using "$projectdir/results/tables/TableA19_wcb_immediate.rtf", replace ///
    se(%4.2f) b(%4.2f) star(* 0.10 ** 0.05 *** 0.01) label ///
    keep(1.time_treat 2.time_treat) ///
    stats(wcb_p_t1 wcb_p_t2 N r2_a, fmt(2 2 0 2) ///
        labels("WCB p-value: T1" "WCB p-value: T2" "Observations" "Adj. R-squared")) ///
    addnotes("Notes: Wild cluster bootstrap p-values (9,999 replications) using boottest." ///
             "Roodman et al. (2019). Clusters: site_ID (26 clusters).") ///
    mtitles("Severity" "Self-eff" "Out-eff" "Costs" "Empathy" "Imagination" "Approval" "Concern" "Info Impact" "Info Strat")


*------------------------------------------------------------------------------*
* Tables A20
* Wild cluster bootstrap p-values and BH q-values:
* 	With only 26 clusters, conventional cluster-robust SEs may over-reject.
* 	Wild cluster bootstrap (Cameron, Gelbach & Miller 2008; Roodman et al.
* 	2019) provides asymptotic refinement for more reliable p-values.
*------------------------------------------------------------------------------*

local nout : word count $outcomes
matrix WCB_persist = J(`nout', 2, .)
matrix colnames WCB_persist = "Conv_p" "WCB_p"
local rownames ""

local i = 0
foreach v of varlist $outcomes {
    local ++i

    * NOTE: Main persistence spec (Table A10 / Figure 5) clusters at ind_ID
    * (within-subject panel). Here we cluster at site_ID for WCB because
    * site is the level where the few-cluster problem bites (26 clusters).
    * Conventional p-values in this table are therefore not directly comparable
    * to Table A10.
    reg `v' i.balanced_followup $controls i.site_ID if time_treat==2, vce(cluster site_ID)

    matrix WCB_persist[`i', 1] = 2 * ttail(e(df_r), abs(_b[1.balanced_followup] / _se[1.balanced_followup]))

    boottest 1.balanced_followup, cluster(site_ID) boottype(wild) reps(9999) seed(12345)
    matrix WCB_persist[`i', 2] = r(p)

    local rownames `rownames' `v'
}

matrix rownames WCB_persist = `rownames'
matlist WCB_persist, format(%6.4f) title("Persistence Effects: Conventional vs. Wild Cluster Bootstrap p-values")


* Export WCB persistence to RTF
eststo clear
local i = 0
foreach v of varlist $outcomes {
    local ++i
    reg `v' i.balanced_followup $controls i.site_ID if time_treat==2, vce(cluster site_ID)
    estadd scalar wcb_p = WCB_persist[`i', 2]
    eststo wcbp`i'
}

esttab wcbp1 wcbp2 wcbp3 wcbp4 wcbp5 wcbp6 wcbp7 wcbp8 wcbp9 wcbp10 ///
    using "$projectdir/results/tables/TableA20_wcb_persistence.rtf", replace ///
    se(%4.2f) b(%4.2f) star(* 0.10 ** 0.05 *** 0.01) label ///
    keep(1.balanced_followup) ///
    stats(wcb_p N r2_a, fmt(2 0 2) ///
        labels("WCB p-value" "Observations" "Adj. R-squared")) ///
    addnotes("Notes: Wild cluster bootstrap p-values (9,999 replications) using boottest." ///
             "Roodman et al. (2019). Clusters: site_ID (26 clusters)." ///
             "Sample: T2 participants interviewed post-workshop and at 8-month follow-up.") ///
    mtitles("Severity" "Self-eff" "Out-eff" "Costs" "Empathy" "Imagination" "Approval" "Concern" "Info Impact" "Info Strat")




*------------------------------------------------------------------------------*
* Tables A21
* Oster delta:
* 	how strong selection on unobservables must be (relative to observables)
*	to explain away the treatment effect. delta > 1 means
* 	unobservables would need more explanatory power than observables.
* 	Rmax = min(1.3 * R2_full, 1) following Oster's recommendation.
*------------------------------------------------------------------------------*
cap which psacalc
if _rc {
    ssc install psacalc, replace
}

local nout : word count $outcomes
matrix OSTER_immediate = J(`nout', 4, .)
matrix colnames OSTER_immediate = "delta_T1" "delta_T2" "R2_short" "R2_full"
local rownames ""

local i = 0
foreach v of varlist $outcomes {
    local ++i

    * Short regression (treatment + site FE only)
    qui reg `v' i.time_treat i.site_ID if followup==0
    local r2_short = e(r2)

    * Full regression (treatment + controls + site FE)
    qui reg `v' i.time_treat $controls i.site_ID if followup==0
    local r2_full = e(r2)
    local rmax = min(1.3 * `r2_full', 1)

    matrix OSTER_immediate[`i', 3] = `r2_short'
    matrix OSTER_immediate[`i', 4] = `r2_full'

    * Delta for T1 (after game)
    cap psacalc delta 1.time_treat, rmax(`rmax') mcontrol($controls)
    if !_rc {
        matrix OSTER_immediate[`i', 1] = r(delta)
    }
    else {
        matrix OSTER_immediate[`i', 1] = .
    }

    * Delta for T2 (after game+workshop)
    cap psacalc delta 2.time_treat, rmax(`rmax') mcontrol($controls)
    if !_rc {
        matrix OSTER_immediate[`i', 2] = r(delta)
    }
    else {
        matrix OSTER_immediate[`i', 2] = .
    }

    local rownames `rownames' `v'
}

matrix rownames OSTER_immediate = `rownames'
matlist OSTER_immediate, format(%8.3f) title("Oster (2019) delta -- Immediate Effects (Rmax = 1.3 * R2_full)")

* Export Oster immediate to RTF
esttab matrix(OSTER_immediate, fmt(%8.2f)) ///
    using "$projectdir/results/tables/TableA21_oster_immediate.rtf", replace ///
    title("Oster (2019) delta -- Immediate Effects") ///
    addnotes("Notes: delta = ratio of selection on unobservables to selection on observables" ///
             "needed to drive the treatment coefficient to zero. |delta| > 1 is the standard" ///
             "benchmark (Oster 2019, QJE). Rmax = min(1.3 * R2_full, 1)." ///
             "Controls: gender, age, education, marital status, community leadership." ///
             "Negative delta means controls increased the coefficient." ///
             "Caveat: The Oster (2019) framework assumes continuous outcomes;" ///
             "results for binary dummies (empathy, imagination, approval, concern," ///
             "info impact, info strategy) should be interpreted with caution.")


*------------------------------------------------------------------------------*
* Tables A22
* Oster delta:
* 	how strong selection on unobservables must be (relative to observables)
*	to explain away the treatment effect. delta > 1 means
* 	unobservables would need more explanatory power than observables.
* 	Rmax = min(1.3 * R2_full, 1) following Oster's recommendation.
*------------------------------------------------------------------------------*

local nout : word count $outcomes
matrix OSTER_persist = J(`nout', 3, .)
matrix colnames OSTER_persist = "delta" "R2_short" "R2_full"
local rownames ""

local i = 0
foreach v of varlist $outcomes {
    local ++i

    * Short regression
    qui reg `v' i.balanced_followup i.site_ID if time_treat==2
    local r2_short = e(r2)

    * Full regression
    qui reg `v' i.balanced_followup $controls i.site_ID if time_treat==2
    local r2_full = e(r2)
    local rmax = min(1.3 * `r2_full', 1)

    matrix OSTER_persist[`i', 2] = `r2_short'
    matrix OSTER_persist[`i', 3] = `r2_full'

    cap psacalc delta 1.balanced_followup, rmax(`rmax') mcontrol($controls)
    if !_rc {
        matrix OSTER_persist[`i', 1] = r(delta)
    }
    else {
        matrix OSTER_persist[`i', 1] = .
    }

    local rownames `rownames' `v'
}

matrix rownames OSTER_persist = `rownames'
matlist OSTER_persist, format(%8.3f) title("Oster (2019) delta -- Persistence Effects (Rmax = 1.3 * R2_full)")

* Export Oster persistence to RTF
esttab matrix(OSTER_persist, fmt(%8.2f)) ///
    using "$projectdir/results/tables/TableA22_oster_persistence.rtf", replace ///
    title("Oster (2019) delta -- Persistence Effects") ///
    addnotes("Notes: delta = ratio of selection on unobservables to selection on observables" ///
             "needed to drive the treatment coefficient to zero. |delta| > 1 is the standard" ///
             "benchmark (Oster 2019, QJE). Rmax = min(1.3 * R2_full, 1)." ///
             "Controls: gender, age, education, marital status, community leadership." ///
             "Missing (.) means coefficient was unchanged by controls (R2 barely moved)." ///
             "Sample: T2 participants, post-workshop vs. 8-month follow-up." ///
             "Caveat: The Oster (2019) framework assumes continuous outcomes;" ///
             "results for binary dummies should be interpreted with caution.")



*------------------------------------------------------------------------------*
* Add. to Table A19
* Multiple Hypothesis Testing -- Benjamini-Hochberg (FDR)
* 	With 10 outcomes, we correct for MHT within outcome families:
*   	Family 1 (Risk perceptions):     severity, self-eff, out-eff, costs
*  		Family 2 (Intergenerational):    empathy, imagination, approval, concern
*   	Family 3 (Information demand):   info_impact, info_strat
* 	Benjamini-Hochberg controls the False Discovery Rate -- less conservative
* 	than Bonferroni, standard in experimental economics.
* 	BH procedure: sort p-values within family, reject if p_(k) <= (k/m)*q
* 	where m = family size, q = target FDR (0.10). Report sharpened q-values.
*------------------------------------------------------------------------------*

* a. Immediate effects -- BH q-values by family

* Re-run regressions and collect p-values for T1 and T2
* Family 1: Risk perceptions (4 outcomes)
local fam1 z_threat z_selfeff z_outeff z_costs
* Family 2: Intergenerational (4 outcomes)
local fam2 intergen_empathy_dum intergen_image_dum intergen_approval_dum intergen_concern_dum
* Family 3: Information demand (2 outcomes)
local fam3 info_impact_dum info_strat_dum

* Store all p-values in a temporary dataset for BH computation
preserve
clear
set obs 10

gen str32 outcome = ""
gen family = .
gen p_t1 = .
gen p_t2 = .
gen p_persist = .

* Outcome names and family assignments
local allout z_threat z_selfeff z_outeff z_costs intergen_empathy_dum intergen_image_dum intergen_approval_dum intergen_concern_dum info_impact_dum info_strat_dum
local allfam 1 1 1 1 2 2 2 2 3 3

forvalues j = 1/10 {
    local v : word `j' of `allout'
    local f : word `j' of `allfam'
    replace outcome = "`v'" in `j'
    replace family = `f' in `j'
}

* Fill in p-values from WCB matrices (already computed above)
* These are the WCB p-values (more conservative/accurate with 26 clusters)
forvalues j = 1/10 {
    replace p_t1 = WCB_immediate[`j', 2] in `j'
    replace p_t2 = WCB_immediate[`j', 4] in `j'
    replace p_persist = WCB_persist[`j', 2] in `j'
}

* BH procedure for each treatment arm, within each family
foreach arm in t1 t2 persist {
    gen bh_q_`arm' = .

    forvalues f = 1/3 {
        * Count outcomes in this family
        qui count if family == `f'
        local m = r(N)

        * Rank p-values within family (smallest = rank 1)
        egen rank_`arm'_`f' = rank(p_`arm') if family == `f'

        * BH adjusted q-value = p * m / rank
        * Then enforce monotonicity: starting from largest rank,
        * q(k) = min(q(k), q(k+1))
        replace bh_q_`arm' = min(p_`arm' * `m' / rank_`arm'_`f', 1) if family == `f'
    }
    drop rank_`arm'_*
}

* Enforce monotonicity within families (step-up)
foreach arm in t1 t2 persist {
    forvalues f = 1/3 {
        qui count if family == `f'
        local m = r(N)
        * Sort descending by p within family, carry forward minimum
        gsort family -p_`arm'
        by family: replace bh_q_`arm' = min(bh_q_`arm', bh_q_`arm'[_n-1]) if _n > 1 & family == `f'
    }
}

sort family outcome
list outcome family p_t1 bh_q_t1 p_t2 bh_q_t2 p_persist bh_q_persist, sep(4) noobs

* Label and format for display
label var outcome "Outcome"
label var family "Family"
label var p_t1 "WCB p (T1)"
label var bh_q_t1 "BH q (T1)"
label var p_t2 "WCB p (T2)"
label var bh_q_t2 "BH q (T2)"
label var p_persist "WCB p (Persist)"
label var bh_q_persist "BH q (Persist)"

* Format numeric variables so Excel shows decimals
format p_t1 bh_q_t1 p_t2 bh_q_t2 p_persist bh_q_persist %7.2f
format family %1.0f

* Add readable outcome labels
gen str40 outcome_label = ""
replace outcome_label = "Threat appraisal" if outcome == "z_threat"
replace outcome_label = "Self-efficacy"   if outcome == "z_selfeff"
replace outcome_label = "Outcome-efficacy" if outcome == "z_outeff"
replace outcome_label = "Perceived costs" if outcome == "z_costs"
replace outcome_label = "Empathy"         if outcome == "intergen_empathy_dum"
replace outcome_label = "Imagination"     if outcome == "intergen_image_dum"
replace outcome_label = "Approval"        if outcome == "intergen_approval_dum"
replace outcome_label = "Concern"         if outcome == "intergen_concern_dum"
replace outcome_label = "Info: impact"    if outcome == "info_impact_dum"
replace outcome_label = "Info: strategy"  if outcome == "info_strat_dum"

* Add family labels
gen str25 family_label = ""
replace family_label = "Risk perceptions"       if family == 1
replace family_label = "Intergenerational norms" if family == 2
replace family_label = "Information demand"      if family == 3

* Add significance flags
gen str3 sig_t1 = ""
replace sig_t1 = "***" if bh_q_t1 < 0.01
replace sig_t1 = "**"  if bh_q_t1 >= 0.01 & bh_q_t1 < 0.05
replace sig_t1 = "*"   if bh_q_t1 >= 0.05 & bh_q_t1 < 0.10

gen str3 sig_t2 = ""
replace sig_t2 = "***" if bh_q_t2 < 0.01
replace sig_t2 = "**"  if bh_q_t2 >= 0.01 & bh_q_t2 < 0.05
replace sig_t2 = "*"   if bh_q_t2 >= 0.05 & bh_q_t2 < 0.10

gen str3 sig_persist = ""
replace sig_persist = "***" if bh_q_persist < 0.01
replace sig_persist = "**"  if bh_q_persist >= 0.01 & bh_q_persist < 0.05
replace sig_persist = "*"   if bh_q_persist >= 0.05 & bh_q_persist < 0.10

label var outcome_label "Outcome"
label var family_label "Family"
label var sig_t1 "Sig (T1)"
label var sig_t2 "Sig (T2)"
label var sig_persist "Sig (Persist)"

* Export to Excel with proper formatting
sort family outcome
export excel outcome_label family_label ///
    p_t1 bh_q_t1 sig_t1 ///
    p_t2 bh_q_t2 sig_t2 ///
    p_persist bh_q_persist sig_persist ///
    using "$projectdir/results/intermediate/TableA19_mht_bh_qvalues.xlsx", ///
    firstrow(varlabels) replace

restore


* b. Add BH q-values to WCB immediate effects table

* Re-run with q-values added as estadd scalars
eststo clear
local i = 0
local allfam 1 1 1 1 2 2 2 2 3 3

* First, compute BH q-values in matrices
* We need family sizes: fam1=4, fam2=4, fam3=2
local fam_size_1 = 4
local fam_size_2 = 4
local fam_size_3 = 2

* Create matrices for ranks and q-values
matrix BH_T1 = J(10, 3, .)
matrix BH_T2 = J(10, 3, .)
matrix colnames BH_T1 = "p_value" "rank" "bh_q"
matrix colnames BH_T2 = "p_value" "rank" "bh_q"

forvalues j = 1/10 {
    matrix BH_T1[`j', 1] = WCB_immediate[`j', 2]
    matrix BH_T2[`j', 1] = WCB_immediate[`j', 4]
}

* Rank within families and compute q = p * m / rank
* Family 1: rows 1-4, Family 2: rows 5-8, Family 3: rows 9-10
foreach arm in T1 T2 {
    * Family 1
    local fam_rows 1 2 3 4
    local m = 4
    * Simple bubble sort for ranking within family
    forvalues j = 1/4 {
        local rank = 0
        forvalues k = 1/4 {
            if BH_`arm'[`k', 1] <= BH_`arm'[`j', 1] {
                local rank = `rank' + 1
            }
        }
        matrix BH_`arm'[`j', 2] = `rank'
        matrix BH_`arm'[`j', 3] = min(BH_`arm'[`j', 1] * `m' / `rank', 1)
    }

    * Family 2
    local m = 4
    forvalues j = 5/8 {
        local rank = 0
        forvalues k = 5/8 {
            if BH_`arm'[`k', 1] <= BH_`arm'[`j', 1] {
                local rank = `rank' + 1
            }
        }
        matrix BH_`arm'[`j', 2] = `rank'
        matrix BH_`arm'[`j', 3] = min(BH_`arm'[`j', 1] * `m' / `rank', 1)
    }

    * Family 3
    local m = 2
    forvalues j = 9/10 {
        local rank = 0
        forvalues k = 9/10 {
            if BH_`arm'[`k', 1] <= BH_`arm'[`j', 1] {
                local rank = `rank' + 1
            }
        }
        matrix BH_`arm'[`j', 2] = `rank'
        matrix BH_`arm'[`j', 3] = min(BH_`arm'[`j', 1] * `m' / `rank', 1)
    }
}

* Now store regressions with WCB p-values AND BH q-values
local i = 0
foreach v of varlist $outcomes {
    local ++i
    reg `v' i.time_treat $controls i.site_ID if followup==0, vce(cluster site_ID)
    estadd scalar wcb_p_t1 = WCB_immediate[`i', 2]
    estadd scalar wcb_p_t2 = WCB_immediate[`i', 4]
    estadd scalar bh_q_t1 = BH_T1[`i', 3]
    estadd scalar bh_q_t2 = BH_T2[`i', 3]
    eststo wcb`i'
}

esttab wcb1 wcb2 wcb3 wcb4 wcb5 wcb6 wcb7 wcb8 wcb9 wcb10 ///
    using "$projectdir/results/tables/TableA19_wcb_immediate.rtf", replace ///
    se(%4.2f) b(%4.2f) star(* 0.10 ** 0.05 *** 0.01) label ///
    keep(1.time_treat 2.time_treat) ///
    stats(wcb_p_t1 bh_q_t1 wcb_p_t2 bh_q_t2 N r2_a, fmt(2 2 2 2 0 2) ///
        labels("WCB p-value: T1" "BH q-value: T1" ///
               "WCB p-value: T2" "BH q-value: T2" ///
               "Observations" "Adj. R-squared")) ///
    addnotes("Notes: Wild cluster bootstrap p-values (9,999 reps) and Benjamini-Hochberg" ///
             "q-values correcting for MHT within outcome families (risk perceptions [4]," ///
             "intergenerational concerns [4], information demand [2]).") ///
    mtitles("Severity" "Self-eff" "Out-eff" "Costs" "Empathy" "Imagination" "Approval" "Concern" "Info Impact" "Info Strat")




clear all

