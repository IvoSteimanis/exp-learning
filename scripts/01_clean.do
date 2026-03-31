
/*******************************************************************************
* Project: Experiential Learning: Evidence from rural Namibia
* File:    01_clean.do
* Purpose: Merges survey datasets, cleans and generate variables for replication
*******************************************************************************/

clear all
set more off


/*******************************************************************************
* 0. Merge / append data
*******************************************************************************/

use "$projectdir/data/survey_outcome.dta", clear
append using "$projectdir/data/survey_followup.dta"

* NOTE: force option resolves string/numeric type mismatches between outcome
* and general survey files (e.g., gender_female, age, educ_level stored as
* string in one file and numeric in another). See string-to-numeric recoding below.
merge m:1 site_ID player_ID using ///
    "$projectdir/data/survey_general.dta", force
	
tab _merge

* Generate individual ID
sort site_ID player_ID
egen ind_ID = group(site_ID player_ID)
order ind_ID, after(player_ID)


/*******************************************************************************
* 1. Harmonize panel and timing variables
*******************************************************************************/

* Recode missing followup values: 0 = on-site interview (workshop day), 1 = follow-up interview
replace followup = 0 if missing(followup)
capture label drop followup_label
label define followup_label 0 "Workshop day" 1 "Follow-up interview"
label values followup followup_label

* Carry on-site treatment timing forward to follow-up observations
bysort ind_ID (time_treat): replace time_treat = time_treat[1] if missing(time_treat)
label define time_treat_lbl 0 "Before" 1 "After Game" 2 "After Workshop", replace
label values time_treat time_treat_lbl

* Treatment timing including follow-up for descriptive figures
capture drop time4
gen time4 = time_treat
replace time4 = 3 if followup == 1
capture label drop time4_lbl
label define time4_lbl 0 "Baseline" 1 "T1: Game" 2 "T2: Game + Workshop" 3 "Follow-up" 
label values time4 time4_lbl

* Count number of survey waves per individual
by ind_ID: gen n_surveys = _N
tab n_surveys

* Attrition variables for follow-up analyses
capture drop returned_followup
capture drop attrited
bysort ind_ID: egen returned_followup = max(followup == 1)
gen attrited = returned_followup == 0 if followup == 0

* Balanced follow-up sample: missing for individuals observed in only one wave
gen balanced_followup = followup
replace balanced_followup = . if n_surveys == 1
label values balanced_followup followup_label
drop n_surveys

/*******************************************************************************
* 2. Missing Value Treatment: correction for missing interviews
*******************************************************************************/

tab _merge // 224 participants did not take part in the outcome-survey
drop if _merge == 2

tab _merge time_treat // 7 participants have been been interviewed in outcome, but not general survey
tab _merge followup // 3 participants have been interviewed in followup, but not general survey
drop _merge

tab time_treat, missing // 4 participants are interviewed at follow-up but not on workshop day
drop if missing(time_treat)

duplicates list ind_ID followup


/*******************************************************************************
* 3. Common label definitions
*******************************************************************************/

capture label define yesno              	0 "No" 1 "Yes", replace
capture label define gender_lbl         	0 "Male" 1 "Female", replace
capture label define age_lbl            	1 "Youth (18-24)" ///
											2 "Young adults (25-34)" ///
											3 "Adults (35-64)" ///
											4 "Older adults (+65)", replace
capture label define marital_lbl        	1 "Single" 2 "Married" ///
											3 "Divorced" 4 "Widowed", replace
capture label define educ_lbl           	0 "None" 1 "Adult literacy" ///
											2 "Lower primary school" ///
											3 "Upper primary school" ///
											4 "Junior secondary school" ///
											5 "Senior secondary school" ///
											6 "College" 7 "University", replace
capture label define educ_group_lbl     	1 "Low education (max primary school)" ///
											2 "Medium education (secondary school)" ///
											3 "High education (college/university)", replace
capture label define adapt_effort_lbl   	0 "No efforts" ///
											1 "By myself or my family" ///
											2 "By community", replace
capture label define respon_group_lbl   	1 "Internal (individual/family/community)" ///
											2 "Both" 3 "External (organization/government)", replace
capture label define trust_lbl          	0 "No one" 1 "Very few" ///
											2 "More than half" 3 "Almost everyone", replace
capture label define foodfreq_lbl       	0 "Never" ///
											1 "Some months but not every month" ///
											2 "Almost every month" ///
											3 "Almost every week" ///
											4 "Almost every day", replace
capture label define severity_lbl       	1 "Not serious at all" ///
											2 "Rather not serious" ///
											3 "Neither serious nor not serious" ///
											4 "Rather serious" ///
											5 "Very serious", replace
capture label define agree_lbl          	1 "Strongly disagree" 2 "Disagree" ///
											3 "Neutral" 4 "Agree" ///
											5 "Strongly agree", replace
capture label define intergen_approval_lbl	1 "Strongly people today" ///
											2 "Rather people today" ///
											3 "Both" ///
											4 "Rather people in the future" ///
											5 "Strongly people in the future", replace
capture label define intergen_concern_lbl  	1 "Strongly immediate concerns" ///
											2 "Rather immediate concerns" ///
											3 "Both" ///
											4 "Rather future concerns" ///
											5 "Strongly future concerns", replace
capture label define both_future_lbl 		0 "Future only" 1 "Both", replace


/*******************************************************************************
* 4. Clean general variables
*******************************************************************************/

* Gender
capture confirm numeric variable gender_female
if _rc {
    replace gender_female = "1" if gender_female == "Female"
    replace gender_female = "0" if gender_female == "Male"
    destring gender_female, replace
}
label values gender_female yesno

* Age
capture confirm string variable age
if !_rc {
    replace age = "1" if age == "youth (18-24)"
    replace age = "2" if age == "young adults (25-34)"
    replace age = "3" if age == "adults (35-64)"
    replace age = "4" if age == "older adults (+65)"
    destring age, replace
}
label values age age_lbl

gen age_above34 = inlist(age, 3, 4) if !missing(age)
label values age_above34 yesno
label var age_above34 "Age above 34"

* Marital status
capture confirm string variable maritalstatus
if !_rc {
    replace maritalstatus = "1" if maritalstatus == "Single"
    replace maritalstatus = "2" if maritalstatus == "Married"
    replace maritalstatus = "3" if maritalstatus == "Divorced"
    replace maritalstatus = "4" if maritalstatus == "Widowed"
    destring maritalstatus, replace
}
label values maritalstatus marital_lbl

gen married = maritalstatus == 2 if !missing(maritalstatus)
label values married yesno

* Education
capture confirm string variable educ_level
if !_rc {
    replace educ_level = "0" if educ_level == "None"
    replace educ_level = "1" if educ_level == "Adult literacy"
    replace educ_level = "2" if educ_level == "Lower primary school"
    replace educ_level = "3" if educ_level == "Upper primary school"
    replace educ_level = "4" if educ_level == "Junior secondary school"
    replace educ_level = "5" if educ_level == "Senior secondary school"
    replace educ_level = "6" if educ_level == "College"
    replace educ_level = "7" if educ_level == "University"
    destring educ_level, replace
}
label values educ_level educ_lbl

gen educ_level_group = .
replace educ_level_group = 1 if inlist(educ_level, 0, 1, 2, 3)
replace educ_level_group = 2 if inlist(educ_level, 4, 5)
replace educ_level_group = 3 if inlist(educ_level, 6, 7)
label values educ_level_group educ_group_lbl

tab educ_level_group, gen(educ_level_group_)
rename educ_level_group_1 educ_level_low
rename educ_level_group_2 educ_level_mid 
rename educ_level_group_3 educ_level_high


* Number of children
capture confirm numeric variable log_num_children
if _rc {
    gen log_num_children = log(num_children)
}

* Income
capture confirm numeric variable income_employed
if _rc {
    egen income_employed = rowmax(income_wagelabor income_farmwagelabor income_salary)
}
capture confirm numeric variable income_farming
if _rc {
    egen income_farming = rowmax(income_irfarming income_rainfedfarming income_animalhusb)
}

capture drop income_pca1 income_pca2
pca income_employed income_farming income_business income_remittances
predict income_pca1 income_pca2

* Assets
foreach v of varlist assets_radio assets_television assets_smartphone ///
                    assets_fan assets_solarpower assets_generator assets_car {
    capture confirm string variable `v'
    if !_rc {
        replace `v' = subinstr(`v', " (zero)",  "", .)
        replace `v' = subinstr(`v', " (one)",   "", .)
        replace `v' = subinstr(`v', " (two)",   "", .)
        replace `v' = subinstr(`v', " (three)", "", .)
        replace `v' = subinstr(`v', " (four)",  "", .)
        replace `v' = subinstr(`v', " (five)",  "", .)
        destring `v', replace
    }
}

capture drop assets_pca1 assets_pca2
pca assets_radio assets_television assets_smartphone assets_fan ///
    assets_solarpower assets_generator assets_car
predict assets_pca1 assets_pca2

* Trust
capture confirm string variable trust_community
if !_rc {
    replace trust_community = "0" if trust_community == "No One"
    replace trust_community = "1" if trust_community == "Very Few"
    replace trust_community = "2" if trust_community == "More than half"
    replace trust_community = "3" if trust_community == "Almost Everyone"
    destring trust_community, replace
}
label values trust_community trust_lbl

gen trust_high = inlist(trust_community, 2, 3) if !missing(trust_community)
label values trust_high yesno

* Food insecurity
capture confirm string variable food_insec
if !_rc {
    replace food_insec = "0" if food_insec == "No"
    replace food_insec = "1" if food_insec == "Yes"
    destring food_insec, replace
}
label values food_insec yesno

capture confirm string variable food_insec_frequency
if !_rc {
    replace food_insec_frequency = "0" if food_insec_frequency == "never"
    replace food_insec_frequency = "1" if food_insec_frequency == "some months but not every month"
    replace food_insec_frequency = "2" if food_insec_frequency == "almost every month"
    replace food_insec_frequency = "3" if food_insec_frequency == "almost every week"
    replace food_insec_frequency = "4" if food_insec_frequency == "almost every day"
    destring food_insec_frequency, replace
}
label values food_insec_frequency foodfreq_lbl

gen food_insec_month = inlist(food_insec_frequency, 2, 3, 4) if !missing(food_insec_frequency)
label values food_insec_month yesno

* Leader
capture confirm numeric variable leader
if _rc {
    gen leader = role_community == 1 if !missing(role_community)
}
label values leader yesno

capture confirm numeric variable role_community_dum
if _rc {
    gen role_community_dum = role_community >= 1 if !missing(role_community)
}
label values role_community_dum yesno

capture confirm numeric variable role_gov
if _rc {
    gen role_gov = inlist(role_community, 1, 2) if !missing(role_community)
}
label values role_gov yesno

* Adaptation effort grouping
foreach v of varlist adapt_effort_myself adapt_effort_family adapt_effort_community ///
                    adapt_effort_no adapt_effort_na respon_individual respon_family ///
                    respon_community respon_organization respon_government respon_dk {
    capture confirm string variable `v'
    if !_rc {
        replace `v' = "0" if `v' == "No"
        replace `v' = "1" if `v' == "Yes"
        destring `v', replace
    }
    capture label values `v' yesno
}

gen adapt_effort_group = .
replace adapt_effort_group = 0 if adapt_effort_no == 1 | adapt_effort_na == 1
replace adapt_effort_group = 1 if adapt_effort_family == 1 | adapt_effort_myself == 1
replace adapt_effort_group = 2 if adapt_effort_community == 1
label values adapt_effort_group adapt_effort_lbl

drop adapt_effort

* Responsibility
gen respon_group = .
replace respon_group = 1 if respon_individual == 1 | respon_family == 1 | respon_community == 1
replace respon_group = 3 if respon_organization == 1 | respon_government == 1
replace respon_group = 2 if (respon_individual == 1 | respon_family == 1 | respon_community == 1) & ///
                         (respon_organization == 1 | respon_government == 1)
label values respon_group respon_group_lbl

gen respon_external = respon_group == 3 if !missing(respon_group)
drop responsibility

/*******************************************************************************
* 5. Clean appended outcome/follow-up variables jointly
*******************************************************************************/

* Likert scale items

foreach v of varlist severity3 severity4 {
	capture confirm string variable `v'
    if !_rc {
        replace `v' = "1" if `v' == "not serious at all"
        replace `v' = "2" if `v' == "rather not serious"
        replace `v' = "3" if `v' == "neither serious, nor not serious"
        replace `v' = "4" if `v' == "rather serious"
        replace `v' = "5" if `v' == "very serious"
        destring `v', replace
    }
    capture label values `v' severity_lbl
}

foreach v of varlist selfeff_impact selfeff_willigness ///
                    selfeff_knowledge selfeff_ability selfeff_opportunities ///
                    selfeff_skills outeff1 outeff2 cost_monetary cost_time ///
                    intergen_empathy intergen_image adapt_info_strat ///
                    adapt_info_impact {
    capture confirm string variable `v'
    if !_rc {
        replace `v' = "1" if `v' == "strongly disagree"
        replace `v' = "2" if `v' == "disagree"
        replace `v' = "3" if `v' == "neutral"
        replace `v' = "4" if `v' == "agree"
        replace `v' = "5" if `v' == "strongly agree"
        destring `v', replace
    }
    capture label values `v' agree_lbl
}


foreach v of varlist intergen_approval {
    capture confirm string variable `v'
    if !_rc {
        replace `v' = "1" if `v' == "1 strongly people today"
        replace `v' = "2" if `v' == "2 rather people today"
        replace `v' = "3" if `v' == "3 both"
        replace `v' = "4" if `v' == "4 rather people in the future"
        replace `v' = "5" if `v' == "5 strongly people in the future"
        destring `v', replace
    }
    capture label values `v' intergen_approval_lbl
}

foreach v of varlist intergen_concern {
    capture confirm string variable `v'
    if !_rc {
        replace `v' = "1" if `v' == "1 strongly immediate concerns"
        replace `v' = "2" if `v' == "2 rather immediate concerns"
        replace `v' = "3" if `v' == "3 both"
        * NOTE: The survey form mislabeled option 4 as "rather immediate concerns";
        * the correct scale direction is "rather future concerns". Both strings map to 4.
        replace `v' = "4" if `v' == "4 rather future concerns" | `v' == "4 rather immediate concerns"
        replace `v' = "5" if `v' == "5 strongly future concerns"
        destring `v', replace force
    }
    capture label values `v' intergen_concern_lbl
}

* Ladder of life
foreach v of varlist ladder_today ladder_parents ladder_10years ///
                    ladder_children ladder_futuregen {
    capture confirm string variable `v'
    if !_rc {
        forvalues i = 0/10 {
            local word : word `=`i'+1' of zero one two three four five six seven eight nine ten
            replace `v' = "`i'" if `v' == "`i' (`word')"
        }
        destring `v', replace
    }
}

* Median SES cut-point and indicator

egen median_SES = median(ladder_today)
gen SES_above_median = ladder_today >= median_SES if followup == 0
label values SES_above_median yesno


/*******************************************************************************
* 6. Generate derived variables and indices for analysis
*******************************************************************************/

* PCA indices
* NOTE: PCA loadings are estimated on baseline (T0) observations only to avoid
* post-treatment contamination (treatment-induced shifts in variance/covariance
* would otherwise feed back into the factor loadings that define outcomes).
* The `predict` command after PCA applies baseline-estimated loadings to all waves.

* Threat appraisal: PC1 retained (4 items)
pca severity1_climate severity2_climate severity3 severity4 if time_treat == 0
predict threat_pca1

* Self-efficacy: PC1 retained (4 items)
pca selfeff_knowledge selfeff_ability selfeff_opportunities selfeff_skills if time_treat == 0
predict selfeff_pca1

* Outcome-efficacy: PC1 retained (2 items); sign flipped so that higher values
* indicate greater perceived efficacy (raw PC1 loads negatively on outeff1)
pca outeff1 outeff2 if time_treat == 0
predict outeff_pca
gen outeff_pca1 = -1 * outeff_pca

* Perceived costs: PC1 retained (2 items)
pca cost_monetary cost_time if time_treat == 0
predict perc_cost_pca1

* Standardized and normalized indices

foreach var in threat_pca1 selfeff_pca1 outeff_pca1 perc_cost_pca1 {
    egen z_`var' = std(`var')
}

rename z_threat_pca1 		z_threat
rename z_selfeff_pca1       z_selfeff
rename z_outeff_pca1        z_outeff
rename z_perc_cost_pca1     z_costs

foreach var in z_threat z_selfeff z_outeff z_costs {
    quietly summarize `var' if !missing(`var')
    gen `var'_norm = (`var' - r(min)) / (r(max) - r(min))*100
}

* Binary and percentage versions of intergenerational and information items

gen intergen_empathy_dum = intergen_empathy == 5 if !missing(intergen_empathy)
label values intergen_empathy_dum yesno

gen intergen_image_dum = intergen_image == 5 if !missing(intergen_image)
label values intergen_image_dum yesno

gen intergen_approval_dum = .
replace intergen_approval_dum = 1 if intergen_approval == 3
replace intergen_approval_dum = 0 if intergen_approval > 3 & !missing(intergen_approval)
label values intergen_approval_dum both_future_lbl 

gen intergen_concern_dum = .
replace intergen_concern_dum = 1 if intergen_concern == 3
replace intergen_concern_dum = 0 if intergen_concern > 3 & !missing(intergen_concern)
label values intergen_concern_dum both_future_lbl 

gen info_strat_dum = adapt_info_strat == 5 if !missing(adapt_info_strat)
label values info_strat_dum yesno

gen info_impact_dum = adapt_info_impact == 5 if !missing(adapt_info_impact)
label values info_impact_dum yesno

gen intergen_empathy_pct = intergen_empathy_dum * 100
gen intergen_image_pct = intergen_image_dum * 100
gen intergen_approval_pct = intergen_approval_dum * 100 
gen intergen_concern_pct = intergen_concern_dum * 100
gen info_impact_pct = info_impact_dum * 100
gen info_strat_pct = info_strat_dum * 100



/*******************************************************************************
* 7. Organise dataset
*******************************************************************************/

* 1. IDs and sample structure
order site_ID player_ID ind_ID time_treat followup time4 returned_followup attrited balanced_followup meditation framing

* 2. Demographics and household
order gender_female age age_above34 maritalstatus married ///
      educ_level educ_highest educ_level_group educ_level_low educ_level_mid educ_level_high ///
      language hh_size num_children log_num_children num_adults years_residence_com, after(balanced_followup)

* 3. Economic background
order income_employed income_farming income_irfarming income_rainfedfarming ///
      income_animalhusb income_farmwagelabor income_wagelabor income_business ///
      income_salary income_remittances income_none income_pca1 income_pca2 ///
      food_insec food_insec_frequency food_insec_month ///
      assets_radio assets_television assets_smartphone assets_fan ///
      assets_solarpower assets_generator assets_car assets_pca1 assets_pca2 ///
      median_SES SES_above_median, after(years_residence_com)

* 4. Social and community position
order role_community role_community_dum role_gov leader ///
      trust_community trust_high, after(SES_above_median)

* 5. Adaptation and responsibility
order adapt_effort_myself adapt_effort_family adapt_effort_community ///
      adapt_effort_no adapt_effort_na adapt_effort_group ///
      respon_individual respon_family respon_community respon_organization ///
      respon_government respon_dk respon_group respon_external, after(trust_high)

* 6. Expectations and perceived problems
order ladder_today ladder_parents ladder_10years ladder_children ladder_futuregen ///
      severity1_none severity1_poverty severity1_unempl severity1_corruption ///
      severity1_climate severity1_economy severity1_crime severity1_health ///
      severity1_landuse severity1_youth severity1_childabuse severity1_electricity ///
      severity1_wildlife severity1_education ///
      severity2_none severity2_poverty severity2_unempl severity2_corruption ///
      severity2_climate severity2_economy severity2_crime severity2_health ///
      severity2_landuse severity2_youth severity2_childabuse severity2_electricity ///
      severity2_overpop severity3 severity4, after(respon_external)

* 7. Main attitudinal variables
order selfeff_impact selfeff_willigness selfeff_knowledge selfeff_ability ///
      selfeff_opportunities selfeff_skills ///
      outeff1 outeff2 cost_monetary cost_time ///
	  intergen_empathy intergen_image intergen_approval intergen_concern ///
	  adapt_info_strat adapt_info_impact, after(severity4)

* 8. Constructed indices and generated variables
order threat_pca1 selfeff_pca1 outeff_pca outeff_pca1 perc_cost_pca1 ///
      z_threat z_selfeff z_outeff z_costs ///
      z_threat_norm z_selfeff_norm z_outeff_norm z_costs_norm ///
      intergen_empathy_dum intergen_image_dum intergen_approval_dum intergen_concern_dum ///
      info_strat_dum info_impact_dum ///
      intergen_empathy_pct intergen_image_pct intergen_approval_pct intergen_concern_pct ///
      info_strat_pct info_impact_pct, after(adapt_info_impact)
	  
	  
/*******************************************************************************
* 8. Variable labels
*******************************************************************************/

label variable site_ID                 "Village / site identifier"
label variable player_ID               "Participant identifier within site"
label variable ind_ID                  "Unique individual identifier"
label variable time_treat              "Timing of treatment / interview relative to intervention"
label variable followup                "Interview wave"
label variable time4                   "Treatment timing including follow-up"
label variable returned_followup 	   "Returned in 8-month follow-up"
label variable attrited 			   "Attrited by follow-up"
label variable balanced_followup       "Balanced follow-up sample indicator"
label variable meditation			   "Meditation treatment"
label variable framing				   "Framing treatment"	

label variable gender_female           "Female respondent"
label variable age                     "Age group"
label variable age_above34             "Respondent older than 34"
label variable maritalstatus           "Marital status"
label variable married                 "Respondent is married"

label variable educ_level              "Education level"
label variable educ_highest            "Highest grade completed"
label variable educ_level_group        "Education group"
label variable educ_level_low          "Low education group"
label variable educ_level_mid          "Medium education group"
label variable educ_level_high         "High education group"
label variable language                "Main language spoken"

label variable hh_size                 "Household size"
label variable num_children            "Number of children in household"
label variable log_num_children        "Log number of children in household"
label variable num_adults              "Number of adults in household"
label variable years_residence_com     "Years living in village / community"

label variable income_employed         "Receives income from employment"
label variable income_farming          "Receives income from farming"
label variable income_irfarming        "Irrigated farming as income source"
label variable income_rainfedfarming   "Rain-fed farming as income source"
label variable income_animalhusb       "Animal husbandry as income source"
label variable income_farmwagelabor    "Farm wage labor as income source"
label variable income_wagelabor        "Off-farm wage labor as income source"
label variable income_business         "Business as income source"
label variable income_salary           "Salaried employment as income source"
label variable income_remittances      "Remittances as income source"
label variable income_none             "No income source"
label variable income_pca1             "Income index, first principal component"
label variable income_pca2             "Income index, second principal component"

label variable food_insec              "Not enough money for food in last 12 months"
label variable food_insec_frequency    "Frequency of not having enough money for food"
label variable food_insec_month        "Food insecurity at least monthly"

label variable assets_radio            "Household owns radio"
label variable assets_television       "Household owns television"
label variable assets_smartphone       "Household owns smartphone"
label variable assets_fan              "Household owns fan"
label variable assets_solarpower       "Household owns solar power"
label variable assets_generator        "Household owns generator"
label variable assets_car              "Household owns car"
label variable assets_pca1             "Asset index, first principal component"
label variable assets_pca2             "Asset index, second principal component"
label variable median_SES              "Socio-economic status index"
label variable SES_above_median        "Socio-economic status above sample median"

label variable role_community          "Role in community"
label variable role_community_dum      "Has any community role"
label variable role_gov                "Has governance role"
label variable leader                  "Traditional authority / village head"

label variable trust_community         "Trust in community members"
label variable trust_high              "High trust in community"

label variable adapt_effort_myself     "Individual adaptation effort"
label variable adapt_effort_family     "Family adaptation effort"
label variable adapt_effort_community  "Community adaptation effort"
label variable adapt_effort_no         "No adaptation effort"
label variable adapt_effort_na         "Adaptation effort not applicable / unknown"
label variable adapt_effort_group      "Main grouping of adaptation effort"

label variable respon_individual       "Individual seen as responsible for addressing climate change"
label variable respon_family           "Family seen as responsible for addressing climate change"
label variable respon_community        "Community seen as responsible for addressing climate change"
label variable respon_organization     "Organization seen as responsible for addressing climate change"
label variable respon_government       "Government seen as responsible for addressing climate change"
label variable respon_dk               "Does not know who is responsible"
label variable respon_group            "Main grouping of responsibility for climate change"
label variable respon_external 		   "Government / external organizations responsible"


label variable ladder_today            "Current position on economic ladder"
label variable ladder_parents          "Parents' position on economic ladder"
label variable ladder_10years          "Expected own position in 10 years"
label variable ladder_children         "Expected children's position"
label variable ladder_futuregen        "Expected position of future generations"

label variable severity1_none          "No serious problem in community today"
label variable severity1_poverty       "Poverty and hunger are serious problems today"
label variable severity1_unempl        "Unemployment is a serious problem today"
label variable severity1_corruption    "Corruption is a serious problem today"
label variable severity1_climate       "Climate change is a serious problem today"
label variable severity1_economy       "Global economic downturn is a serious problem today"
label variable severity1_crime         "Crime and violence are serious problems today"
label variable severity1_health        "Health and diseases are serious problems today"
label variable severity1_landuse       "Improper land use is a serious problem today"
label variable severity1_youth         "Youth delinquency is a serious problem today"
label variable severity1_childabuse    "Child abuse is a serious problem today"
label variable severity1_electricity   "Lack of electricity is a serious problem today"
label variable severity1_wildlife      "Wildlife is a serious problem today"
label variable severity1_education     "Education is a serious problem today"

label variable severity2_none          "No serious problem in community in 20 years"
label variable severity2_poverty       "Poverty and hunger will be serious problems in 20 years"
label variable severity2_unempl        "Unemployment will be a serious problem in 20 years"
label variable severity2_corruption    "Corruption will be a serious problem in 20 years"
label variable severity2_climate       "Climate change will be a serious problem in 20 years"
label variable severity2_economy       "Global economic downturn will be a serious problem in 20 years"
label variable severity2_crime         "Crime and violence will be serious problems in 20 years"
label variable severity2_health        "Health and diseases will be serious problems in 20 years"
label variable severity2_landuse       "Improper land use will be a serious problem in 20 years"
label variable severity2_youth         "Youth delinquency will be a serious problem in 20 years"
label variable severity2_childabuse    "Child abuse will be a serious problem in 20 years"
label variable severity2_electricity   "Electricity shortage will be a serious problem in 20 years"
label variable severity2_overpop       "Overpopulation will be a serious problem in 20 years"

label variable severity3               "Perceived seriousness of climate change today"
label variable severity4               "Perceived seriousness of climate change in 20 years"

label variable selfeff_impact          "Today's decisions affect future generations"
label variable selfeff_willigness      "Willing to protect community against climate change"
label variable selfeff_knowledge       "Knows how to protect community against climate change"
label variable selfeff_ability         "Feels able to contribute through effort and hard work"
label variable selfeff_opportunities   "Perceives opportunities to protect community"
label variable selfeff_skills          "Has skills to protect community"
label variable outeff1                 "Believes individual actions make a difference"
label variable outeff2                 "Believes one person cannot make a difference"
label variable cost_monetary           "Economic situation limits environmental protection"
label variable cost_time               "Lack of time limits environmental protection"

label variable intergen_empathy        "Empathy toward future generations"
label variable intergen_image   	   "Ability to imagine future generations"
label variable intergen_approval       "Concern about how future generations judge current actions"
label variable intergen_concern        "Consideration of future consequences in daily behavior"

label variable adapt_info_strat        "Wants better information about adaptation options"
label variable adapt_info_impact       "Wants better information about climate change impacts"

label variable threat_pca1    		   "Threat appraisal index"
label variable selfeff_pca1            "Self-efficacy index"
label variable outeff_pca              "Outcome-efficacy principal component score"
label variable outeff_pca1             "Signed outcome-efficacy index"
label variable perc_cost_pca1          "Perceived cost barriers index"

label variable z_threat                "Standardized threat appraisal index"
label variable z_selfeff               "Standardized self-efficacy index"
label variable z_outeff                "Standardized outcome-efficacy index"
label variable z_costs                 "Standardized perceived cost barriers index"

label variable z_threat_norm           "Normalized threat appraisal index"
label variable z_selfeff_norm          "Normalized self-efficacy index"
label variable z_outeff_norm           "Normalized outcome-efficacy index"
label variable z_costs_norm            "Normalized perceived cost barriers index"

label variable intergen_empathy_dum    "High empathy toward future generations"
label variable intergen_image_dum 	   "High ability to imagine future generations"
label variable intergen_approval_dum   "Future-oriented approval concern"
label variable intergen_concern_dum    "Future-oriented concern"
label variable info_strat_dum          "Requests more information on adaptation options"
label variable info_impact_dum         "Requests more information on climate impacts"

label variable intergen_empathy_pct    "Relative empathy toward future generations"
label variable intergen_image_pct 	   "Relative ability to imagine future generations"
label variable intergen_approval_pct   "Relative concern for future generations' approval"
label variable intergen_concern_pct    "Relative future-oriented concern"
label variable info_strat_pct          "Relative demand for adaptation information"
label variable info_impact_pct         "Relative demand for impact information"
	  
	  
// SAVE

save "$projectdir/processed/survey_explearning.dta", replace

clear all
