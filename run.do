/*******************************************************************************
* Project: Experiential Learning: Evidence from rural Namibia
* File:    run.do
* Purpose: Runs 01_clean.do and 02_analysis.do for replication
*******************************************************************************/
 	
*   All raw datafiles are stored in /data
*   All figures reported in the main manuscript are outputted to /results/figures
*   All tables are reported in the main manuscript are outputted to /results/tables

*	TO PERFORM A CLEAN RUN, DELETE THE FOLLOWING TWO FOLDERS:
*   /processed
*   /results


/*******************************************************************************
* Set global Working Directory
*******************************************************************************/
* Define this global macro to point where the replication folder is saved locally that includes this run.do script

global projectdir : pwd

di "Working directory: $projectdir"


/*******************************************************************************
* Program Setup
*******************************************************************************/

* Initialize log and record system parameters
clear
set more off
cap mkdir "$projectdir/scripts/logs"
cap log close
local datetime : di %tcCCYY.NN.DD!-HH.MM.SS `=clock("$S_DATE $S_TIME", "DMYhms")'
local logfile "$projectdir/scripts/logs/`datetime'.log.txt"
log using "`logfile'", text

di "Begin date and time: $S_DATE $S_TIME"
di "Stata version: `c(stata_version)'"
di "Updated as of: `c(born_date)'"
di "Variant:       `=cond( c(MP),"MP",cond(c(SE),"SE",c(flavor)) )'"
di "Processors:    `c(processors)'"
di "OS:            `c(os)' `c(osdtl)'"
di "Machine type:  `c(machine_type)'"

* Analyses were run on MacOS using Stata version 18 (backward compatible to version 16)
version 16    // Set Version number for backward compatibility

/*******************************************************************************
* Install community-contributed packages (version-locked)
*******************************************************************************/

* All required ado-files are bundled in /packages so the replication
* package runs without internet access and is immune to future package updates.
* To refresh or populate the local library, uncomment the block below and run once.

cap mkdir "$projectdir/packages"
sysdir set PLUS "$projectdir/packages"
adopath ++ "$projectdir/packages"

/*
foreach pkg in estout catplot coefplot schemepack stripplot outreg2 ///
               mylabels ietoolkit tabout boottest psacalc {
    cap which `pkg'
    if _rc ssc install `pkg', replace
}
*/

* Create directories for output files
cap mkdir "$projectdir/processed"
cap mkdir "$projectdir/results"
cap mkdir "$projectdir/results/intermediate"
cap mkdir "$projectdir/results/tables"
cap mkdir "$projectdir/results/figures"

/*******************************************************************************
* Run processing and analysis scripts
*******************************************************************************/

do "$projectdir/scripts/01_clean.do"
do "$projectdir/scripts/02_analysis.do"

* End log
di "End date and time: $S_DATE $S_TIME"
log close
 

 