# Replication Package

## Can experiential learning enhance perceived behavioral control for climate adaptation? Experimental evidence from rural Namibia

**Authors**: Franziska Auch<sup>1</sup>, Thomas Falk<sup>2,+</sup>, Ivo Steimanis<sup>3</sup>, Meed Mbidzo<sup>4</sup>, Bjorn Vollan<sup>3,+</sup>

<sup>1</sup> Department of Economics and Law, Political Economy of Global Development Lab, University of Stuttgart, 70182 Stuttgart, Germany
<sup>2</sup> Natural Resource and Resilience Unit, International Food Policy Research Institute, USA
<sup>3</sup> Department of Business Administration and Economics, University of Marburg, 35032 Marburg, Germany
<sup>4</sup> Department of Natural Resources Sciences, School of Agriculture and Natural Resources Sciences, Namibia University of Science and Technology, Windhoek Private Bag 13388, Namibia
<sup>+</sup> Corresponding author

**Keywords**: Climate Adaptation; Experiential Learning; Behavioral Control; Future Visioning; Namibia



---

## Overview

This repository contains the data, code, and materials to replicate all tables and figures reported in the paper and appendix. The study uses a lab-in-the-field experiment with 290 villagers across 26 villages in the Zambezi region of northern Namibia to examine whether experiential learning enhance perceived behavioral control for climate adaptation.

---

## Repository Structure

```
.
├── README.md				# This file
├── LICENSE.txt				# CC-BY 4.0 License
├── run.do				# Master script (start here)
│
├── data/                        	# Raw experimental data
│   ├── survey_general.dta      	# Raw general individual survey data
│   ├── survey_outcome.dta       	# Raw outcome variable survey data
│   └── survey_followup.dta     	# Raw outcome variable follow-up data
│
├── packages/				# Bundled Stata ado-files (version-locked)
│
├── processed/
│   └── survey_explearning.dta		# Cleaned analysis-ready datasets
│
├── scripts/                    	# Analysis scripts
│   ├── 01_clean.do             	# Data merging, cleaning and generation
│   ├── 02_analysis.do         		# Main analysis (figures & tables)
│   └── logs/               		# Log-files for scripts
│
└── results/                     # Output files
    ├── figures/                 # All figures (.png)
    ├── tables/                  # All tables (.rtf, .xlsx)
    └── intermediate/            # Intermediate graph files (.gph)
```

---

## Software Requirements

- **Stata** version 18 or higher (backward compatible to version 16)

All community-contributed packages are bundled in `packages/` for offline reproducibility. No internet access is required.

---

## Data Anonymization

To protect participant privacy, personally identifying information has been removed from all data files prior to public release. Dropped variables include: participant names, interviewer names, and phone numbers. Village names and all analysis variables are retained. The full pipeline (`run.do`) executes on the anonymized data without errors.

## Replication Instructions

1. Save this folder to your local drive.
2. Open Stata, set the working directory to this folder, and run `do run.do`.

The master script calls the following scripts in order:
- `01_clean.do`		-- Merges survey datasets, cleans and generates variables for replication
- `02_analysis.do`	-- Replicates manuscript figures and appendix tables/figures

All output is saved to `results/figures/` and `results/tables/`.

---

## Script Descriptions

| Script | Description | Key Outputs |
|--------|-------------|-------------|
| `01_clean.do` | Merge outcome-variables of workshop-day and follow interview with survey data from general-individual interview, generates timing variables, renames, labels and cleans variables; creates, standardizes and normalizes outcome variables| survey_explearning.dta
| `02_analysis.do` | Replicate manuscript figures and appendix tables/figures | Figures and tables in `results/` |


---

## Data Description

### Raw Data Files

| File | Description | Observations |
|------|-------------|-------------|
| `survey_general.dta ` | General individual survey | 511 |
| `survey_outcome.dta  ` | Outcome variable survey data | 290 |
| `survey_followup.dta` | Outcome variable follow-up data (8-months after workshop-day)| 252 |

### Main Analysis Datasets

**`survey_explearning.dta`** (2 rows per participant)

| Variable | Description | Label |
|----------|-------------|-------------|
| `site_ID` | Village / site identifier | 1-26 (labeled villages) |
| `player_ID` | Participant identifier within site | 1-20 |
| `ind_ID` | Grouped participant ID (`group(site_ID player_ID)`) | 1-287 |
| `time_treat` | Timing of treatment / interview relative to intervention | 0=Before, 1=After Game, 2=After Workshop |
| `followup` | Interview wave | 0=Baseline/Before, 1=Follow-up/After |
| `time4` | Timing of treatment including follow-up | 0=Baseline, 1=T1:Game, 2=T2:Game+Workshop 3=Follow-up|
| `returned_followup` | Returned in 8-month follow-up | 0/1 |
| `attrited` | Attrited by follow-up | 0/1 |
| `balanced_followup` | Balanced follow-up sample indicator | 0/1 |
| `meditation` | Meditation treatment | 0/1 |
| `framing` | Framing treatment | 0/1 |

### Demographics and Household

| Variable | Description | Values |
|----------|-------------|--------|
| `gender_female` | Female respondent | 0=Male, 1=Female |
| `age` | Age group | 1=Youth (18-24), 2=Young adults (25-34), 3=Adults (35-64), 4=Older adults (65+) |
| `age_above34` | Derived age-group indicators | 0/1 |
| `maritalstatus` | Marital status | 1=Single, 2=Married, 3=Divorced, 4=Widowed |
| `married` | Married indicator | 0/1 |
| `educ_level` | Education level | 0=None, 1=Adult literacy, 2=Lower primary, 3=Upper primary, 4=Junior secondary, 5=Senior secondary, 6=College, 7=University |
| `educ_highest` | Highest grade completed | 0-13 (13=Higher education) |
| `educ_level_group` | Collapsed education category | 1=Low education, 2=Medium education, 3=High education |
| `educ_level_low` | Low education group | 0/1 |
| `educ_level_mid` | Medium education group | 0/1 |
| `educ_level_high` | High education group | 0/1 |
| `language` | Main language spoken | Text/string |
| `hh_size` | Household size | Count |
| `num_children` | Number of children in household | Count |
| `log_num_children` | Log number of children in household | Continuous |
| `num_adults` | Number of adults in household | Count |
| `years_residence_com` | Years living in village / community | Count (years) |

### Economic Background

| Variable | Description | Values |
|----------|-------------|--------|
| `income_employed` | Receives income from employment | 0=No, 1=Yes |
| `income_farming` | Receives income from farming | 0=No, 1=Yes |
| `income_irfarming` | Irrigated farming as income source | 0=No, 1=Yes |
| `income_rainfedfarming` | Rain-fed farming as income source | 0=No, 1=Yes |
| `income_animalhusb` | Animal husbandry as income source | 0=No, 1=Yes |
| `income_farmwage` | Farm wage labor as income source | 0=No, 1=Yes |
| `income_wagelabor` | Off-farm wage labor as income source | 0=No, 1=Yes |
| `income_business` | Business as income source | 0=No, 1=Yes |
| `income_salary` | Salaried employment as income source | 0=No, 1=Yes |
| `income_remittances` | Remittances as income source | 0=No, 1=Yes |
| `income_none` | No income source | 0=No, 1=Yes |
| `income_pca1` | Income index, first principal component | Continuous |
| `income_pca2` | Income index, second principal component | Continuous |
| `food_insec` | Not enough money for food in last 12 months | 0=No, 1=Yes |
| `food_insec_frequency` | Frequency of not having enough money for food | 0=Never, 1=Some months, 2=Almost every month, 3=Almost every week, 4=Almost every day |
| `food_insec_month` | Food insecurity at least monthly | 0=No, 1=Yes |
| `assets_radio` | Household owns radio | 0=No, 1=Yes |
| `assets_television` | Household owns television | 0=No, 1=Yes |
| `assets_smartphone` | Household owns smartphone | 0=No, 1=Yes |
| `assets_fan` | Household owns fan | 0=No, 1=Yes |
| `assets_solarpower` | Household owns solar power | 0=No, 1=Yes |
| `assets_generator` | Household owns generator | 0=No, 1=Yes |
| `assets_car` | Household owns car | 0=No, 1=Yes |
| `assets_pca1` | Asset index, first principal component | Continuous |
| `assets_pca2` | Asset index, second principal component | Continuous |
| `median_SES` | Socio-economic status index | Continuous |
| `SES_above_median` | Socio-economic status above sample median | 0/1 |

### Social and community position

| Variable | Description | Values |
|----------|-------------|--------|
| `role_community` | Role in community | 1=Traditional Authority, 2=Community Governance, 3=Church, 4=Education, 5=Agriculture, 6=Culture/Volunteer |
| `role_community_dum` | Has any community role | 0=No, 1=Yes |
| `role_gov` | Has governance role | 0=No, 1=Yes |
| `leader` | Traditional authority / village head | 0=No, 1=Yes |
| `trust_community` | Trust in community members | 1=No one, 2=Very few, 3=More than half, 4=Almost everyone |
| `trust_high` | High trust in community | 0=No, 1=Yes |

### Adaptation and responsibility

| Variable | Description | Values |
|----------|-------------|--------|
| `adapt_effort_myself` | Individual adaptation effort | 0=No, 1=Yes |
| `adapt_effort_family` | Family adaptation effort | 0=No, 1=Yes |
| `adapt_effort_community` | Community adaptation effort | 0=No, 1=Yes |
| `adapt_effort_no` | No adaptation effort | 0=No, 1=Yes |
| `adapt_effort_na` | Adaptation effort not applicable / unknown | 0=No, 1=Yes |
| `adapt_effort_group` | Main grouping of adaptation effort | 0=No efforts, 1=By myself or my family, 2=By community |
| `respon_individual` | Individual seen as responsible for addressing climate change | 0=No, 1=Yes |
| `respon_family` | Family seen as responsible for addressing climate change | 0=No, 1=Yes |
| `respon_community` | Community seen as responsible for addressing climate change | 0=No, 1=Yes |
| `respon_organization` | Organization seen as responsible for addressing climate change | 0=No, 1=Yes |
| `respon_government` | Government seen as responsible for addressing climate change | 0=No, 1=Yes |
| `respon_dk` | Does not know who is responsible | 0=No, 1=Yes |
| `respon_group` | Main grouping of responsibility for climate change | 1=Internal (individual/family/community), 2=Both, 3=External (organization/government) |
| `respon_external` | Government / external organizations responsible | 0=No, 1=Yes |


### Expectations and Perceived Problems

| Variable | Description | Values |
|----------|-------------|--------|
| `ladder_today` | Current position on economic ladder | 0-10 |
| `ladder_parents` | Parents' position on economic ladder | 0-10 |
| `ladder_10years` | Expected own position in 10 years | 0-10 |
| `ladder_children` | Expected children's position | 0-10 |
| `ladder_futuregen` | Expected position of future generations | 0-10 |
| `severity1_none` | No serious problem in community today | 0=No, 1=Yes |
| `severity1_poverty` | Poverty and hunger are serious problems today | 0=No, 1=Yes |
| `severity1_unempl` | Unemployment is a serious problem today | 0=No, 1=Yes |
| `severity1_corruption` | Corruption is a serious problem today | 0=No, 1=Yes |
| `severity1_climate` | Climate change is a serious problem today | 0=No, 1=Yes |
| `severity1_economy` | Global economic downturn is a serious problem today | 0=No, 1=Yes |
| `severity1_crime` | Crime and violence are serious problems today | 0=No, 1=Yes |
| `severity1_health` | Health and diseases are serious problems today | 0=No, 1=Yes |
| `severity1_landuse` | Improper land use is a serious problem today | 0=No, 1=Yes |
| `severity1_youth` | Youth delinquency is a serious problem today | 0=No, 1=Yes |
| `severity1_childabuse` | Child abuse is a serious problem today | 0=No, 1=Yes |
| `severity1_electricity` | Lack of electricity is a serious problem today | 0=No, 1=Yes |
| `severity1_wildlife` | Wildlife is a serious problem today | 0=No, 1=Yes |
| `severity1_education` | Education is a serious problem today | 0=No, 1=Yes |
| `severity2_none` | No serious problem in community in 20 years | 0=No, 1=Yes |
| `severity2_poverty` | Poverty and hunger will be serious problems in 20 years | 0=No, 1=Yes |
| `severity2_unempl` | Unemployment will be a serious problem in 20 years | 0=No, 1=Yes |
| `severity2_corruption` | Corruption will be a serious problem in 20 years | 0=No, 1=Yes |
| `severity2_climate` | Climate change will be a serious problem in 20 years | 0=No, 1=Yes |
| `severity2_economy` | Global economic downturn will be a serious problem in 20 years | 0=No, 1=Yes |
| `severity2_crime` | Crime and violence will be serious problems in 20 years | 0=No, 1=Yes |
| `severity2_health` | Health and diseases will be serious problems in 20 years | 0=No, 1=Yes |
| `severity2_landuse` | Improper land use will be a serious problem in 20 years | 0=No, 1=Yes |
| `severity2_youth` | Youth delinquency will be a serious problem in 20 years | 0=No, 1=Yes |
| `severity2_childabuse` | Child abuse will be a serious problem in 20 years | 0=No, 1=Yes |
| `severity2_electricity` | Electricity shortage will be a serious problem in 20 years | 0=No, 1=Yes |
| `severity2_overpop` | Overpopulation will be a serious problem in 20 years | 0=No, 1=Yes |
| `severity3` | Perceived seriousness of climate change today | 1=Not serious at all ... 5=Very serious |
| `severity4` | Perceived seriousness of climate change in 20 years | 1=Not serious at all ... 5=Very serious |

### Main Attitudinal Variables

| Variable | Description | Values |
|----------|-------------|--------|
| `selfeff_impact` | Believes decisions affect future generations | 1=Strongly disagree ... 5=Strongly agree |
| `selfeff_willigness` | Willing to protect community against climate change | 1=Strongly disagree ... 5=Strongly agree |
| `selfeff_knowledge` | Knows how to protect community against climate change | 1=Strongly disagree ... 5=Strongly agree |
| `selfeff_ability` | Feels able to contribute through effort and hard work | 1=Strongly disagree ... 5=Strongly agree |
| `selfeff_opportunities` | Perceives opportunities to protect community | 1=Strongly disagree ... 5=Strongly agree |
| `selfeff_skills` | Has skills to protect community | 1=Strongly disagree ... 5=Strongly agree |
| `outeff1` | Believes individual actions make a difference | 1=Strongly disagree ... 5=Strongly agree |
| `outeff2` | Believes one person cannot make a difference | 1=Strongly disagree ... 5=Strongly agree |
| `cost_monetary` | Economic situation limits environmental protection | 1=Strongly disagree ... 5=Strongly agree |
| `cost_time` | Lack of time limits environmental protection | 1=Strongly disagree ... 5=Strongly agree |
| `intergen_empathy` | Empathy toward future generations | 1=Strongly disagree ... 5=Strongly agree |
| `intergen_image` | Ability to imagine future generations | 1=Strongly disagree ... 5=Strongly agree |
| `intergen_approval` | Concern about how future generations judge current actions | 1=Strongly disagree ... 5=Strongly agree |
| `intergen_concern` | Consideration of future consequences in daily behavior | 1=Strongly disagree ... 5=Strongly agree |
| `adapt_info_strat` | Wants better information about adaptation options | 1=Strongly disagree ... 5=Strongly agree |
| `adapt_info_impact` | Wants better information about climate change impacts | 1=Strongly disagree ... 5=Strongly agree |

### Constructed Indices and Generated Variables

| Variable | Description | Values |
|----------|-------------|--------|
| `threat_pca1` | Threat appraisal index | Continuous |
| `selfeff_pca1` | Self-efficacy index | Continuous |
| `outeff_pca` | Outcome-efficacy principal component score | Continuous |
| `outeff_pca1` | Signed outcome-efficacy index | Continuous |
| `perc_cost_pca1` | Perceived cost barriers index | Continuous |
| `z_threat` | Standardized threat appraisal index | Continuous (z-scores) |
| `z_selfeff` | Standardized self-efficacy index | Continuous (z-scores) |
| `z_outeff` | Standardized outcome-efficacy index | Continuous (z-scores) |
| `z_costs` | Standardized perceived cost barriers index | Continuous (z-scores) |
| `z_threat_norm` | Normalized threat appraisal index | Continuous |
| `z_selfeff_norm` | Normalized self-efficacy index | Continuous |
| `z_outeff_norm` | Normalized outcome-efficacy index | Continuous |
| `z_costs_norm` | Normalized perceived cost barriers index | Continuous |
| `intergen_empathy_dum` | High empathy toward future generations | 0=No, 1=Yes |
| `intergen_image_dum` | High ability to imagine future generations | 0=No, 1=Yes |
| `intergen_approval_dum` | Concern about future generations' approval | 0=No, 1=Yes |
| `intergen_concern_dum` | Future-oriented concern | 0=No, 1=Yes |
| `info_strat_dum` | Requests more information on adaptation options | 0=No, 1=Yes |
| `info_impact_dum` | Requests more information on climate impacts | 0=No, 1=Yes |
| `intergen_empathy_pct` | Relative empathy toward future generations | 0/100 (percentage points) |
| `intergen_image_pct` | Relative ability to imagine future generations | 0/100 (percentage points) |
| `intergen_approval_pct` | Relative concern for future generations' approval | 0/100 (percentage points) |
| `intergen_concern_pct` | Relative future-oriented concern | 0/100 (percentage points) |
| `info_strat_pct` | Relative demand for adaptation information | 0/100 (percentage points) |
| `info_impact_pct` | Relative demand for impact information | 0/100 (percentage points) |


---

## Output Mapping

### Main Manuscript Figures

| Figure | Description | Script | Output File |
|--------|-------------|--------|-------------|
| Figure 3 | Distribution of outcome measures across all surveyed participants | `02_analysis.do` | `Figure3_distribution_outcomes.png` |
| Figure 4 | Main workshop-day effects of the intervention on experiential-learning outcomes | `02_analysis.do` | `Figure4_main_effects.png` |
| Figure 5 | 8-month persistence (within-subject, T2 only) | `02_analysis.do` | `Figure5_persistence.png` |

### Appendix Figures

| Figure | Description | Script | Output File |
|--------|-------------|--------|-------------|
| Figure A2 | Distributions of Index Outcome Variables over Time | `02_analysis.do` | `FigureA2_distribution_index_outcomes.png` |
| Figure A3 | Distributions of Binary Outcome Variables over Time | `02_analysis.do` | `FigureA3_distribution_binary_outcomes.png` |


### Appendix Tables

| Table | Description | Output File |
|-------|-------------|-------------|
| Table A3 | Average socio-economic sample characteristics | `TableA3_sample_characteristics.rtf` |
| Table A4 | Perceived challenges in the community today and in 20 years | `TableA4_severity_today.rtf`, `TableA4_severity_future.rtf` |
| Table A5 | Balance table of socio-economic characteristics across treatment groups | `TableA5_balance_treatment.xlsx` |
| Table A6 | Attrition Rates by Treatment Arm | `TableA6_attrition_rates.xlsx` |
| Table A7 | Balance table by Attrition Status | `TableA7_balance_attrition.xlsx` |
| Table A8 | Pairwise t-tests for outcome variables | `TableA8_pairwise_ttests.xlsx` |
| Table A9 | Main average treatment effects | `TableA9_main_ATE.rtf` |
| Table A10 | Within-subject time trends eight months after the intervention (T2 group) | `TableA10_persistence_T2.rtf` |
| Table A11 | Heterogeneous effects by gender | `TableA11_heterogeneity_gender.rtf` |
| Table A12 | Heterogeneous effects by age | `TableA12_heterogeneity_age.rtf` |
| Table A13 | Heterogeneous effects by education | `TableA13_heterogeneity_education.rtf` |
| Table A14 | Heterogeneous effects by socio-economic status | `TableA14_heterogeneity_ses.rtf` |
| Table A15 | Heterogeneous effects by community leadership | `TableA15_heterogeneity_leadership.rtf` |
| Table A16 | Heterogeneous effects by receiving framing during the workshop day | `TableA16_heterogeneity_framing.rtf` |
| Table A17 | Between-subject comparison by meditation treatment | `TableA17_meditation_comparison.rtf` |
| Table A18 | Robustness: Placebo outcome tests | `TableA18_placebo_tests.rtf` |
| Table A19 | Robustness: Wild cluster bootstrap p-values and Benjamini-Hochberg q-values, immediate effects | `TableA19_wcb_immediate.rtf` |
| Table A20 | Robustness: Wild cluster bootstrap p-values, persistence effects | `TableA20_wcb_persistence.rtf` |
| Table A21 | Robustness: Oster δ, immediate effects | `TableA21_oster_immediate.rtf` |
| Table A22 | Robustness: Oster δ, persistence effects | `TableA22_oster_persistence.rtf` |

---

## Ethics and Funding

- **Ethics approval:** Relevant institutional ethics clearance obtained prior to data collection
- **Data collection:** 2023, Zambezi region, Namibia
- **Informed consent:** All participants provided informed consent

---

## License

The data and code in this repository are licensed under a [Creative Commons Attribution 4.0 International License](https://creativecommons.org/licenses/by/4.0/).

---
