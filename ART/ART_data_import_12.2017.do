******************************************************
* Data Cleaning and Transformation Do File
* Global Health Costing Consortium (GHCC)
* 
* Date created: December 4, 2017
*
* Lily Alexander, MPH Student, University of Washington
* lalexan1@uw.edu
* Drew Cameron, PhD Student, UC Berkeley
* drew.cameron@berkeley.edu
******************************************************

********************************************************************************
*Instructions for Future Users
********************************************************************************
* All relevant files should be contained within the same folder named "GCHH"
* And include the following subfolders: 
		* 1. The underlying data extraciton form in .xlsx format for each intervention area:
				* a. VMMC studies
				* b. ART studies
				* c. other study types... 
			* Leave excel files in GHCC/ 
			* Naming convention is: "GHCC_Data_Extraction_[intervention]_v#_day-month-year.xlsx"
		* 2. Other relevant files?
		* 3. Path should contain the following subfolders and structures
				* GHCC/temp_dta
				* GHCC/logs
				* GHCC/outputs
				* GHCC/do_files
				* GHCC/final_dta
				* GHCC/external_data
				* GHCC/UCSR_exports
		* 4. Future user should change path as well as change the name of the excel file
		* 	 (ie. excel file name "GHCC_Data_Extraction_VMMC_v54_16-June-2017") 
		*    in step 1 for both the "Cost data" tab/sheet, and the "Study attributes" tab/sheet 		
		
* Goals are:
		* a. Combine 'study attributes' and 'cost data' tabs to create one "long" dataset 
		*			at "mean_cost" and "input_cost" levels "/long_file.dta"
		* b. Create one dataset relevant for econometric analysis
		* 			reshaped "wide" at the "unit_cost" level (relevant for dynamic 
		*			unit costing tool) "/wide_file.dta"
		* c. Create one dataset for Unit Cost Study Repository structured same as (b) above, 
		*			but including any eliminated subcategories of data (ie. "per visit costs"
		*			for ART, as opposed to the more commonly reported "costs per annum")
********************************************************************************




	*** Still Need to incorporate
	******************************
	* strim (to trim off extra spaces from excel for pre-encoded fields)
	
	
	
*************************************************
* Part I: Load, select, and clean cost-level data 
*************************************************

* 0: Change directory (adjust directory as appropriate)
***********************

// Set Stata preferences 
	clear all
	set more off
	set mem 2g

	* Lily's Path:
	* cd "C:/Users/Lily Alexander/Dropbox/ALL LIFE THINGS/INSP/Work with Sergio/GHCC/post_extraction_processing/"

	* Drew's Path:
	cd "/Users/dcameron03/Documents/Berkeley/`GSI with Jim/Stata/GHCC/ART/"
	
* 1: Load in both data files (change title of excel file as appropriate)
***********************

** lily's import:
//using GHCC_Data_Extraction_ART_v23_23-Oct-2017_DBC
* Costs data sheet
	* import excel ART_12.2017.xlsx, firstrow sh("Cost data") clear

** drew's import:
import excel extraction_templates/GHCC_Data_Extraction_ART_v23_23-Oct-2017, firstrow sh("Cost data") cellrange(A4) case(l)
	
		*Save for working later
		save temp_dta/costs.dta,replace	
		clear
		
* Study Attributes data sheet	
	import excel extraction_templates/GHCC_Data_Extraction_ART_v23_23-Oct-2017, firstrow sh("Study attributes") cellrange(A4) case(l) clear
	
		*Save for working later
		save temp_dta/study_attributes.dta,replace	
		clear
		
		*Will need to import and append additional cost_level datafiles here as they are created

		
* 2: Load any relevant packages
*******************************
	*ssc install labutil2


* 3: Create unique unit_cost variable
*************************************
	*Drop this later
		use temp_dta/costs.dta

	*First concatinate cost level data into unit_cost level observations
		gen _="_"
		gen unit_cost1=id+_+unit_cost
		move unit_cost1 unit_cost
		drop unit_cost
		drop _
		rename unit_cost1 unit_cost
		
	* Replace mean cost as median cost for one study in ART for now: 
		replace mean_cost=median_cost if strpos(id, "hiv102") > 0
		destring mean_cost,replace
		
	*Save for working later
		save temp_dta/costs.dta,replace	


*****************************************************************************
* Part II: Standardizing and inflating costs for analysis of apples to apples
*****************************************************************************

* Start by inflating the prices to 2016 dollars using US CPI
************************************************************
	* First merge in study-attributes data for the currency_year variable
	merge m:1 id using temp_dta/study_attributes.dta
		drop if _merge!=3
		drop if id == "" 
			
	// Get rid of all study attribute data except currency year	
		drop extractor_initials-discount_rate_rs
		drop currency_yr_rs-_merge
			* No need to destring numerics - will deal with rest of data later.


			* START WITH: Inflation to 2016 dollars using the CPI
			*******************************************************************
			** (To find this data, visit the World Bank at the following URL:
			** https://data.worldbank.org/indicator/FP.CPI.TOTL
			** Select data for the United States and deired years (ie. 1990-2016)
			** then download in Excel or CSV, and reshape desired data to create
			** lines of code as per below.
			** Data for this transformation were accessed on 12/14/2017
			*******************************************************************
			gen	cpi_current=110.0670089		
			gen	cpi_old	=.		
			replace	cpi_old=59.91976049	if currency_yr==	1990
			replace	cpi_old=62.45734075	if currency_yr==	1991
			replace	cpi_old=64.34906098	if currency_yr==	1992
			replace	cpi_old=66.24842452	if currency_yr==	1993
			replace	cpi_old=67.9758135	if currency_yr==	1994
			replace	cpi_old=69.88282035	if currency_yr==	1995
			replace	cpi_old=71.93122852	if currency_yr==	1996
			replace	cpi_old=73.61275761	if currency_yr==	1997
			replace	cpi_old=74.75543306	if currency_yr==	1998
			replace	cpi_old=76.39110227	if currency_yr==	1999		
			replace	cpi_old=78.97072076	if currency_yr==	2000
			replace	cpi_old=81.20256846	if currency_yr==	2001
			replace	cpi_old=82.49046688	if currency_yr==	2002
			replace	cpi_old=84.36307882	if currency_yr==	2003
			replace	cpi_old=86.62167812	if currency_yr==	2004
			replace	cpi_old=89.56053237	if currency_yr==	2005
			replace	cpi_old=92.44970508	if currency_yr==	2006
			replace	cpi_old=95.08699238	if currency_yr==	2007
			replace	cpi_old=98.73747739	if currency_yr==	2008
			replace	cpi_old=98.38641997	if currency_yr==	2009
			replace	cpi_old=100	if currency_yr==	2010
			replace	cpi_old=103.1568416	if currency_yr==	2011
			replace	cpi_old=105.2915045	if currency_yr==	2012
			replace	cpi_old=106.8338489	if currency_yr==	2013
			replace	cpi_old=108.5669321	if currency_yr==	2014
			replace	cpi_old=108.695722	if currency_yr==	2015
				* replace all costs to reflect CPI adjustment
				replace	mean_cost=mean_cost*(cpi_current/cpi_old)		
				
					drop cpi_current cpi_old
				
				* This will have to be modified for any pre 1990 studies. 
			
			* NEXT: Inflation to 2016 dollars using GDP Deflator Index
				* data here: https://www.imf.org/external/pubs/ft/weo/2016/01/weodata/download.aspx
			
			
			* All can easily be updated for 2017 dollars later.
			
			
		*Save for working later
		save temp_dta/costs.dta,replace	

*MAY WANT TO RESTART HERE 		
		
		
*
*!******* THIS TO BE REMOVED AFTER BEN FIXES EVERYTHING  -not sure what to do about this yet... 
	* Replace miscategorized "mixed" values for totals in si_ and a_ categories
	foreach i of varlist si_narrow si_broad {
		replace `i'="Combined" if `i'=="Mixed" & ar_broad=="Total"
	}
	foreach i of varlist a_narrow a_broad {
		replace `i'="combo" if `i'=="Mixed" & ar_broad=="Total"
	}
	* Get rid of any sub-category costs in the costing sheet (theyre screwing things up)
		replace mean_cost=. if ar_narrow=="Subtotal" | ar_broad=="Subtotal"

*!******* THIS TO BE REMOVED AFTER BEN FIXES EVERYTHING
*




* Eventually include GDPPC designtations here for study attributes tab 
* (need to also find a clever way to  not sum gdppc during reshape)



*****************************************************	
* Part III: Cleaning (destring, recode, gen new vars)
*****************************************************



* First, encode the for "As Reported" Costs
******************************************

			*Input Broad Categories
			***********************
				*Encode and create categorical
				replace ar_broad = lower(ar_broad)
				encode ar_broad, generate(ar_broad1) label(ar_broad)
				move ar_broad1 ar_broad
				*drop input_broad_cat
				rename ar_broad1 ar_broad2
				rename ar_broad ar_broad1
				rename ar_broad2 ar_broad
				
				*Create binaries for each category
				*set trace on
				tab ar_broad, gen(v_)	
				labellist ar_broad, rc0
				return list
				local K: word count `r(labels)'
				display "`K'"
				forvalues k = 1/`K' {
					qui labellist ar_broad, rc0
					local name : word `k' of `r(labels)'
					local name = strtoname("`name'")
					rename v_`k' `name'		
				} 
			*


			* Narrow 'as reported' input cost categories
			* Applying these directly to the broad categories to break out later
			******************************
			replace ar_narrow = lower(ar_narrow)
			
			* First must simplify some of the var names for easier coding
			replace ar_narrow="admin_support" if ar_narrow=="administration/support"
			replace ar_narrow="admin_equip" if ar_narrow=="administrative equipment"
			replace ar_narrow="unspecified" if ar_narrow=="capital, unspecified"
			replace ar_narrow="key_drugs" if ar_narrow=="drugs - key"
			replace ar_narrow="nonkey_drugs" if ar_narrow=="drugs - non-key"
			replace ar_narrow="maintenance" if ar_narrow=="facility maintenance"
			replace ar_narrow="rental" if ar_narrow=="facility rental"
			replace ar_narrow="hct" if ar_narrow=="hiv counseling and testing"
			replace ar_narrow="indirect" if ar_narrow=="indirect costs"
			replace ar_narrow="inpatient" if ar_narrow=="inpatient service"
			replace ar_narrow="intangible" if ar_narrow=="intangible costs"
			replace ar_narrow="lab consumables" if ar_narrow=="laboratory consumables"
			replace ar_narrow="lab equip" if ar_narrow=="laboratory equipment"
			replace ar_narrow="lab personnel" if ar_narrow=="laboratory personnel"
			replace ar_narrow="lab test" if ar_narrow=="laboratory test"
			replace ar_narrow="maint_and_util" if ar_narrow=="maintenance and utilities"
			replace ar_narrow="mgmt" if ar_narrow=="management"
			replace ar_narrow="mconsult" if ar_narrow=="medical consultation"
			replace ar_narrow="unspecified" if ar_narrow=="overhead, unspecified"
			replace ar_narrow="partial costing" if ar_narrow=="partial costing total"
			replace ar_narrow="unspecified" if ar_narrow=="personnel, unspecified"
			replace ar_narrow="pharmacy" if ar_narrow=="pharmacy personnel"
			replace ar_narrow="unspecified" if ar_narrow=="recurring goods, unspecified"
			replace ar_narrow="unspecified" if ar_narrow=="recurring services, unspecified"
			replace ar_narrow="service delivery" if ar_narrow=="service delivery personnel"
			replace ar_narrow="sterilization" if ar_narrow=="sterilization/cleaning"
			replace ar_narrow="adverse_events" if ar_narrow=="treating adverse event"
			replace ar_narrow="transport" if ar_narrow=="transportation"
			replace ar_narrow="nclinical_consum" if ar_narrow=="non-clinical consumables"
			
			replace ar_narrow="accommodation" if ar_narrow=="accommodations/hospitality"
			replace ar_narrow="clinical_consum" if ar_narrow=="clinical consumables"
			replace ar_narrow="patient_transport" if ar_narrow=="patient transportation"
			replace ar_narrow="equip_maint" if ar_narrow=="equipment maintenance"
			
			******************************
				tostring capital-recurring_services, replace

				foreach i of varlist capital-recurring_services {
					replace `i'="" if `i'=="0"
					replace `i'=ar_narrow if `i'=="1"
					replace `i'= lower(`i')
					encode `i', gen(`i'_1) label(`i')
					drop `i'
					rename `i'_1 `i' 
				}
				
				* Now destring and encode input_narrow_cost 
					encode ar_narrow, gen(ar_narrow1) label(ar_narrow)
					move ar_narrow1 ar_narrow
					*drop input_narrow_cat
					rename ar_narrow1 ar_narrow2
					rename ar_narrow ar_narrow1
					rename ar_narrow2 ar_narrow

					
					
			* Now create binaries for the reshape command (need to finalize)
			*********************************************
				*create prefix
				split ar_broad1, p(" " "_" "-")
				replace ar_broad11=substr(ar_broad11,1,3)
				gen _="_"
				gen prefix=ar_broad11+ar_broad12+_
						drop ar_broad11-_
				*combine prefix with narrow cat var
				gen narrow_cat=prefix+ar_narrow1
					drop prefix
				*encode categorical
				encode narrow_cat, gen(narrow_cat1) label(narrow_cat)
					drop narrow_cat
					rename narrow_cat1 narrow
				
				
				*Now generate binaries
				tab narrow, gen(v_)	
				labellist narrow, rc0
				return list
				local K: word count `r(labels)'
				display "`K'"
				forvalues k = 1/`K' {
					qui labellist narrow, rc0
					local name : word `k' of `r(labels)'
					local name = strtoname("`name'")
					rename v_`k' `name'
				} 
					drop narrow
*!*					*drop _
				*clean up
				foreach i of varlist cap_start_up-tot_partial_costing {
					replace `i'=. if `i'==0
				}
			
			
			*Now replace all cat and subcat binaries with values of mean_cost
				foreach i of varlist capital-recurring_services{
					egen unique`i'=group(`i')
					}
					drop capital-recurring_services
					rename unique* *
					
					*STILL NEED TO REORDER VARS
				foreach i of varlist capital-recurring_services {
					move `i' cap_start_up
				}
				
			* Apply all mean_costs to these variables with missing obs for all 	
				foreach i of varlist capital-tot_partial_costing{
					replace `i'=mean_cost if `i'!=.
				}
			*
			
			*Finally add a prefix to these new variables ar_
			foreach i of varlist capital-tot_partial_costing {
				rename `i'	ar_`i'		
			}
*
	
	
* Next, Encode Procedure for Standardized Inputs
************************************************

save temp_dta/costs.dta,replace	
clear all
use temp_dta/costs.dta


			*Input Broad Categories
			***********************
			replace si_broad = lower(si_broad)			
			*First, make the broad names (that will be in use from HIV) usable
			replace si_broad="recurrent" if si_broad=="recurrent - other"
				***** Should do the same here for TB and similar coding including:
				replace si_broad="pdm" if si_broad=="(patient) direct, medical"
				replace si_broad="pdn" if si_broad=="(patient) direct, non medical"
				replace si_broad="pia" if si_broad=="(patient) indirect, access"
				replace si_broad="pii" if si_broad=="(patient) indirect, illness"
				replace si_broad="pim" if si_broad=="(patient) indirect, mixed"
				replace si_broad="pdx" if si_broad=="(patient) direct, mixed"
				replace si_broad="pmx" if si_broad=="(patient) mixed"
			
				*Encode and create categorical
				encode si_broad, generate(si_broad1) label(si_broad)
				move si_broad1 si_broad
				*drop input_broad_cat
				rename si_broad1 si_broad2
				rename si_broad si_broad1
				rename si_broad2 si_broad
		
				*Create binaries for each category using value labels
					*set trace on
				tab si_broad, gen(v_)	
				labellist si_broad, rc0
				return list
				local K: word count `r(labels)'
				display "`K'"
				forvalues k = 1/`K' {
					qui labellist si_broad, rc0
					local name : word `k' of `r(labels)'
					local name = strtoname("`name'")
					rename v_`k' `name'		
				} 
			*


			* Narrow input cost categories
			* Applying these directly to the broad categories to break out later
			******************************
			replace si_narrow = lower(si_narrow)
			
			* Now fix variable names to get rid of symbols
			replace si_narrow="service_delivery" if si_narrow=="service delivery personnel"
			replace si_narrow="support" if si_narrow=="support personnel"
			replace si_narrow="mixed_unspec" if si_narrow=="personnel - mixed or unspecified"
			replace si_narrow="medical_equip" if si_narrow=="equipment (medical/intervention)"
			replace si_narrow="nonmed_equip" if si_narrow=="equipment (non-medical/non-intervention or unspecified)"
			replace si_narrow="vehicles" if si_narrow=="vehicles, capital"
			replace si_narrow="building_space" if si_narrow=="building/space, capital"
			replace si_narrow="other" if si_narrow=="other capital"
			replace si_narrow="building_space" if si_narrow=="building/space, recurrent"
			replace si_narrow="med_int_supplies" if si_narrow=="supplies (medical/intervention, excl. key drugs)"
			replace si_narrow="key_drugs" if si_narrow=="supplies (key drugs)"
			replace si_narrow="nonmed_int_supplies" if si_narrow=="supplies (non-medical/non-intervention or unspecified)"
			replace si_narrow="other" if si_narrow=="other recurrent"
			
			* Patient costs
			replace si_narrow="pat_fees" if si_narrow=="(patient) fees"
			replace si_narrow="pat_mixed" if si_narrow=="(patient) mixed"
			replace si_narrow="pat_productivity" if si_narrow=="(patient) productivity loss (access: mixed)"
			* Not making changes to the TB categories now b/c not applicable yet and we may adapt these categories first

			tostring capital-recurrent, replace

				foreach i of varlist capital-recurrent {
					replace `i'="" if `i'=="0" | `i'=="."
					replace `i'=si_narrow if `i'=="1"
					replace `i'= lower(`i')
					encode `i', gen(`i'_1) label(`i')
					drop `i'
					rename `i'_1 `i' 
				}
				* Now destring and encode input_narrow_cost 
					encode si_narrow, gen(si_narrow1) label(si_narrow)
					move si_narrow1 si_narrow
					*drop input_narrow_cat
					rename si_narrow1 si_narrow2
					rename si_narrow si_narrow1
					rename si_narrow2 si_narrow

			
			* Now create binaries for the reshape command (need to finalize)
			*********************************************
				*create prefix
				gen si_broad11=si_broad1
				replace si_broad11=substr(si_broad1,1,3)
				gen _="_"
				gen prefix=si_broad11+_
						drop si_broad11-_
				*combine prefix with narrow cat var
				gen narrow_cat=prefix+si_narrow1
					drop prefix
				*encode categorical
				encode narrow_cat, gen(narrow_cat1) label(narrow_cat)
					drop narrow_cat
					rename narrow_cat1 narrow
				
			
				
				*Now generate binaries
				tab narrow, gen(v_)	
				labellist narrow, rc0
				return list
				local K: word count `r(labels)'
				display "`K'"
				forvalues k = 1/`K' {
					qui labellist narrow, rc0
					local name : word `k' of `r(labels)'
					local name = strtoname("`name'")
					rename v_`k' `name'
				} 
					drop narrow
					*drop _
				
				*clean up
				foreach i of varlist cap_other-rec_other {
					replace `i'=. if `i'==0
				}
			
			
			*Now replace all cat and subcat binaries with values of mean_cost
				foreach i of varlist capital-recurrent{
					egen unique`i'=group(`i')
					}
					drop capital-recurrent
					rename unique* *
					
					*STILL NEED TO REORDER VARS
				foreach i of varlist capital-recurrent {
					move `i' cap_other
				}
				
			* Apply all mean_costs to these variables with missing obs for all 	
				foreach i of varlist capital-rec_other{
					replace `i'=mean_cost if `i'!=.
				}
			*
					
			*Finally add a prefix to these new variables si_
			foreach i of varlist capital-rec_other {
				rename `i'	si_`i'		
			}
*	



* Finally, Encode Procedure for Activity Costs
**********************************************
	
save temp_dta/costs.dta,replace	
clear all
use temp_dta/costs.dta
	
	
	
		*Activity Broad Categories
			***********************
			replace a_broad = lower(a_broad)			
			*First, make the broad names (that will be in use from HIV) usable
			replace a_broad="primary_sd" if a_broad=="primary service delivery"
			replace a_broad="secondary_sd" if a_broad=="secondary service delivery"
				***** Would be nice if these were better conceived, but whatever.
			
				*Encode and create categorical
				encode a_broad, generate(a_broad1) label(a_broad)
				move a_broad1 a_broad
				*drop input_broad_cat
				rename a_broad1 a_broad2
				rename a_broad a_broad1
				rename a_broad2 a_broad
		
				*Create binaries for each category
				*set trace on
				tab a_broad, gen(v_)	
				labellist a_broad, rc0
				return list
				local K: word count `r(labels)'
				display "`K'"
				forvalues k = 1/`K' {
					qui labellist a_broad, rc0
					local name : word `k' of `r(labels)'
					local name = strtoname("`name'")
					rename v_`k' `name'		
				} 
			*


	
		* Narrow activity cost categories
			* Applying these directly to the broad categories to break out later
			******************************
			replace a_narrow = lower(a_narrow)
			
			* Now fix variable names to get rid of symbols
			replace a_narrow="circumcision_proced" if a_narrow=="for vmmc: circumcision procedure"
			replace a_narrow="pre_post_exam" if a_narrow=="for vmmc: pre- and post-examination"			
			replace a_narrow="unspecified" if a_narrow=="primary service delivery, unspecified"			
			replace a_narrow="arv_delivery" if a_narrow=="for art: arv delivery"
			replace a_narrow="lab_monitoring" if a_narrow=="for art: routine lab monitoring"
			replace a_narrow="hct" if a_narrow=="for vmmc: hct"			
			replace a_narrow="unspecified" if a_narrow=="secondary service delivery, unspecified"
			replace a_narrow="lab_services" if a_narrow=="laboratory services"
			replace a_narrow="adherence_retention" if a_narrow=="adherence/retention"
			replace a_narrow="unspecified" if a_narrow=="ancillary, unspecified"
			replace a_narrow="program_mgmt" if a_narrow=="programme management"
			replace a_narrow="hmis_recordkeeping" if a_narrow=="hmis and record-keeping"
			replace a_narrow="bldg_equip" if a_narrow=="building and equipment (maintenance and utlilities)"
			replace a_narrow="unspecified" if a_narrow=="operational, unspecified"
			
			tostring ancillary-unspecified, replace
	
			foreach i of varlist ancillary-unspecified {
					replace `i'="" if `i'=="0" | `i'=="."
					replace `i'=a_narrow if `i'=="1"
					replace `i'= lower(`i')
					encode `i', gen(`i'_1) label(`i')
					drop `i'
					rename `i'_1 `i' 
				}
				* Now destring and encode input_narrow_cost 
					encode a_narrow, gen(a_narrow1) label(a_narrow)
					move a_narrow1 a_narrow
					*drop input_narrow_cat
					rename a_narrow1 a_narrow2
					rename a_narrow a_narrow1
					rename a_narrow2 a_narrow

					
	* Now create binaries for the reshape command (need to finalize)
			*********************************************
				*create prefix
				
				split a_broad1, p(" " "_" "-")
				replace a_broad11=substr(a_broad11,1,3)
				gen _="_"
				gen prefix=a_broad11+a_broad12+_
						drop a_broad11-_
				*combine prefix with narrow cat var
				gen narrow_cat=prefix+a_narrow1
					drop prefix
				*encode categorical
				encode narrow_cat, gen(narrow_cat1) label(narrow_cat)
					drop narrow_cat
					rename narrow_cat1 narrow
				
				
				*Now generate binaries
				tab narrow, gen(v_)	
				labellist narrow, rc0
				return list
				local K: word count `r(labels)'
				display "`K'"
				forvalues k = 1/`K' {
					qui labellist narrow, rc0
					local name : word `k' of `r(labels)'
					local name = strtoname("`name'")
					rename v_`k' `name'
				} 
					drop narrow
					*drop _
	
				*clean up narrow cost binaries
				foreach i of varlist anc_adherence_retention-uns_unspecified {
					replace `i'=. if `i'==0
				}
			
			
			*Now replace all cat and subcat binaries with values of mean_cost
				foreach i of varlist ancillary-unspecified{
					egen unique`i'=group(`i')
					}
					drop ancillary-unspecified
					rename unique* *
				
					*STILL NEED TO REORDER VARS
				foreach i of varlist ancillary-unspecified {
					move `i' anc_adherence_retention
				}
				
			* Apply all mean_costs to these variables with missing obs for all 	
				foreach i of varlist ancillary-uns_unspecified{
					replace `i'=mean_cost if `i'!=.
				}
			*
			
				* Fix shitty variable name (VMMC only)
						* rename ope_building_and_equipment__main ope_bldg_equip_main
			*Finally add a prefix to these new variables si_
			foreach i of varlist ancillary-uns_unspecified {
				rename `i'	a_`i'		
			}
*	
	
** Encoding remaining variables
*******************************
			
		* Encode categorical variables for long version
			foreach i of varlist disease intervention cost_level trade_status fixed_variable cost_incurred_by period core_input output_unit_reported output_unit output_unit2 integrated_generic unit_obs empirical_modeled resource_id resource_valuation price_sources full_subsidized adjustment_method data_collection recall_period output_methods data_timing inflation inflation_method amortization currency_iso currency_name {
			*replace `i' = lower(`i')
			encode `i', gen(`i'_1) label(`i')
			move `i'_1 `i'
			drop `i'
			rename `i'_1 `i' 
			}
			
			
			
			* To add below??:
			   *obs_fd obs_fd_rs (but these are mixed between RS and categorical and numerical
			
			
		* Encode reporting standards variables for long version
			*set trace on
			label define rs 1 "explicit" 2 "inferred" 3 "n/a" 4 "nr"
			foreach i of varlist cost_source_rs cost_allocation_method_rs resource_id_rs resource_valuation_rs price_sources_rs inputq_source_rs full_subsidized_rs adjustment_method_rs data_collection_rs recall_period_rs output_methods_rs data_timing_rs inflation_rs inflation_method_rs amortization_rs currency_rs pot_distortions_rs{
			replace `i' = lower(`i')
			replace `i' = "1" if `i'== "explicit"
			replace `i' = "2" if `i'== "inferred"
			replace `i' = "3" if `i'== "n/a"
			replace `i' = "4" if `i'== "nr"
			destring `i', replace
				label values `i' rs
			*consider changing label for NR to . 	
			}

			
		* Numeric variables to recode NR to missing and destring to numeric
			foreach i of varlist lower_ci upper_ci std_dev median_cost lower_iqr upper_iqr input_price input_quantity program_level_cost output_quantity time_period_mo{
			replace `i' = lower(`i')
			replace `i'="." if `i'=="nr" | `i'=="n/a"
			destring `i', replace
			}
		*
		
		
* Add some new variables for analysis later (these applicable to VMMC, probably not ART, TB, other)
********************************************

				* Single scale variable
				gen output_pmonth=output_quantity/time_period_mo
				tab output_pmonth
				label variable output_pmonth "Site unit output per month"

				* Generate additional scale variable at the year level for more logic in reporting
				gen output_pyear=output_pmonth*12
				tab output_pyear
				label variable output_pyear "Site unit output per year"

				* Generate quadratic terms for both scale variables
				gen output_pyear2=output_pyear^2
				gen output_pmonth2=output_pmonth^2


				* Try scaling up the output variable so you can see the coeff.
				**************************************************************
				gen output1k_mo=output_pmonth/1000
				label variable output1k_mo "Site unit output per month / 1000"
				gen output1k_yr=output_pyear/1000
				label variable output1k_mo "Site unit output per year / 1000"

				* And do the same things for the 1000k versions so its interpretable
				gen output1k_yr2=output1k_yr^2
				label variable output1k_yr2 "Site unit output per year^2 / 1000"
				gen output1k_mo2=output1k_mo^2
				label variable output1k_mo2 "Site unit output per month^2 / 1000"

						
	
		* Finally rename id variable for merge
			drop id_old
		save temp_dta/costs.dta,replace	
		clear all


* Load in and clean study-level dataset
****************************************


		use temp_dta/study_attributes.dta


		* DROP NR for following Variables for encoding:
			foreach i of varlist   id_tech int_services costing_purpose_cat timing country_sampling geo_sampling_incountry site_sampling px_sampling sample_size_derived controls econ_costing omitted_costs asd_costs list_asd_costs research_costs unrelated_costs overhead_costs volunteer_time family_time currency_x ownership id_modality{
				replace `i'="" if `i'=="NR" | `i'=="nr"
			}

			* Generate a new country string variable so you can merge in other information later:
			gen country_alt=country
			
			foreach i of varlist extractor_initials article_dataset study_type econ_perspective_report econ_perspective_actual research_costs unrelated_costs overhead incremental_costing int_services econ_costing real_world country geo_sampling_incountry country_sampling site_sampling px_sampling sample_size_derived timing exclusions personnel_dt iso_code currency_x traded volunteer_time family_time px_time aggregation subgroup scale scale_up seasonality sensitivity_analysis limitations coi ownership pop_sex id_class id_type id_int id_modality id_modality_detail px_costs_measured cat_cost costing_purpose_cat asd_costs pop_density int_description time_unit consistency controls pop_couples cd4_med tb_rx_resistance id_phase id_tech{
			*replace `i' = lower(`i')
			replace `i'="." if `i'=="NR"
			encode `i', gen(`i'_1) label(`i')
			move `i'_1 `i'
			drop `i'
			rename `i'_1 `i' 
			}
			*

			
			
			
			* From above, there are a number that are best kept as free-text fields to be extracted as "phrases"
			* Then create new categorical or binary variables as appropriate. (specifically id_details, id_activities, id_tech, id_facility

			
			replace coverage="" if coverage=="NR"
				destring coverage, replace
			replace discount_rate="" if discount_rate=="NR" | discount_rate=="NA"
				destring discount_rate, replace
			replace location="" if location=="NR"
			
		* Reporting Standards Variables for Encoding (CAN CHANGE THIS TO *_rs for ease of coding)
			* should try grabbing all variables that have the "RS" ending somehow, instead of managing individual vars
			label define rs 1 "explicit" 2 "inferred" 3 "n/a"
			
			*set trace on
			foreach i of varlist costing_purpose_rs period_portrayed_rs research_costs_rs unrelated_costs_rs overhead_rs omitted_costs_rs incremental_costing_rs geo_incountry_rs econ_costing_rs geo_sampling_incountry_rs country_sampling_rs site_sampling_rs px_sampling_rs timing_rs discount_rate_rs currency_yr_rs currency_x_rs currency_period_rs volunteer_time_rs family_time_rs px_time_rs aggregationrs management_rs ownership_rs pop_sex_rs pop_ses_rs pop_education_rs pop_description_rs year_intro_rs coverage_rs qual_indicator_rs breakdown_input_rs breakdown_activity_rs breakdown_funder_rs px_costs_measured_rs cat_cost_rs asd_costs_rs real_world_rs personnel_dt_rs pop_age_rs {
			replace `i' = lower(`i')
			replace `i' = "1" if `i'== "explicit"
			replace `i' = "2" if `i'== "inferred"
			replace `i' = "3" if `i'== "n/a"
			replace `i' = "" if `i'== "nr"
			replace `i' = "" if `i'== "none"
			destring `i', replace
				label values `i' rs
			}
				
			*consider changing label for NR to . 	

* And destring remaining numeric variables:
** (For ART we need to treat these as categorical variables with labels for 99 and 88
			label define non_standard 88 "Open" 99 "Mixed"
			
			*Years
			foreach i of varlist start_year end_year year_intro {
				replace `i'=lower(`i')
				replace `i'="" if `i'=="n/a" | `i'=="nr" |  `i'=="na" | `i'=="no year"
					replace `i'="99" if `i'=="mixed"
					replace `i'="88" if `i'=="open"
				destring `i', replace
				}
			
			label values start_year non_standard
			label values end_year non_standard
			label values year_intro non_standard
			
			*Months
			foreach i of varlist start_month end_month{
				replace `i'=lower(`i')
				replace `i'="1" if `i'=="january"
				replace `i'="2" if `i'=="february"
				replace `i'="3" if `i'=="march"
				replace `i'="4" if `i'=="april"
				replace `i'="5" if `i'=="may"
				replace `i'="6" if `i'=="june"
				replace `i'="7" if `i'=="july"
				replace `i'="8" if `i'=="august"
				replace `i'="9" if `i'=="september"
				replace `i'="10" if `i'=="october"
				replace `i'="11" if `i'=="november"
				replace `i'="12" if `i'=="december"
				replace `i'="" if `i'=="n/a" | `i'=="nr" |  `i'=="na"
					replace `i'="99" if `i'=="mixed"
					replace `i'="88" if `i'=="open"
				destring `i', replace
				}
			label values start_month non_standard
			label values end_month non_standard
				
				
			*Period portrayed
			replace period_portrayed=lower(period_portrayed)
			replace period_portrayed="." if period_portrayed=="nr" | period_portrayed=="n/a"
			replace period_portrayed="99" if period_portrayed=="mixed"
			destring period_portrayed, replace
				label values period_portrayed non_standard
				
			
		* Exchange Rate
			replace current_x_rate=	lower(current_x_rate)
			replace current_x_rate="." if current_x_rate=="nr"
			replace current_x_rate="." if current_x_rate=="n/a"
			destring current_x_rate, replace
			
		* number of sites (Looks like we stopped collecting this for ART?)
			*replace no_sites="." if no_sites=="N/A" | no_sites=="NR"
			destring no_sites, replace
		
		
		* id_facility (coding structure, from codebook)
		
				*Create meta_category
				gen meta_facility=.
				replace meta_facility=1 if id_facility=="HC01" | id_facility=="HC02" | id_facility=="HC03" | id_facility=="HC04" | id_facility=="HC05" | id_facility=="HC06" | id_facility=="HC07" | id_facility=="HC08" | id_facility=="HC09" | id_facility=="HC10" | id_facility=="HC11"
				replace meta_facility=2 if id_facility=="OR01" | id_facility=="OR02" | id_facility=="OR03" | id_facility=="OR04" | id_facility=="OR05"
				replace meta_facility=3 if id_facility=="CB01" | id_facility=="CB02" | id_facility=="CB03" | id_facility=="CB04"
				replace meta_facility=4 if id_facility=="PW01"
				replace meta_facility=5 if id_facility=="OT01" | id_facility=="OT02"
				label define meta_facility 1 "Heath Care (service at fixed location)" 2 "Outreach (service in comm org/ elsewhere)" 3 "Community-based (org located in community)" 4 "Population wide" 5 "Other or not reported"
				label values meta_facility meta_facility
				label var meta_facility "Broad Facility Category"
				
			*Now create numeric for better encoding	
			gen facility_cat=.
				replace facility_cat=	101	if id_facility=="HC01"
				replace facility_cat=	102	if id_facility=="HC02"
				replace facility_cat=	103	if id_facility=="HC03"
				replace facility_cat=	104	if id_facility=="HC04"
				replace facility_cat=	105	if id_facility=="HC05"
				replace facility_cat=	107	if id_facility=="HC07"
				replace facility_cat=	108	if id_facility=="HC08"
				replace facility_cat=	109	if id_facility=="HC09"
				replace facility_cat=	110	if id_facility=="HC10"
				replace facility_cat=	111	if id_facility=="HC11"
				replace facility_cat=	201	if id_facility=="OR01"
				replace facility_cat=	202	if id_facility=="OR02"
				replace facility_cat=	203	if id_facility=="OR03"
				replace facility_cat=	204	if id_facility=="OR04"
				replace facility_cat=	205	if id_facility=="OR05"
				replace facility_cat=	301	if id_facility=="CB01"
				replace facility_cat=	302	if id_facility=="CB02"
				replace facility_cat=	303	if id_facility=="CB03"
				replace facility_cat=	304	if id_facility=="CB04"
				replace facility_cat=	401	if id_facility=="PW01"
				replace facility_cat=	501	if id_facility=="OT01"
				replace facility_cat=	502	if id_facility=="OT02"
				
					label define facility_cat 101 "Health Post (e.g. health outpost, etc.)" 102 "Health Center (e.g. community health clinic - sometimes w/ 1-2 beds)" 103 "Clinic at hospital (not intervention- or disease-specific)" 104 "Clinic at hospital (intervention- or disease-specific)" 105 "Hospital - Primary (district)" 107 "Hospital - Secondary (regional, specialist)" 108 "Hospital - Tertiary (teaching)" 109 "Hospital - Level Unspecified" 110 "Mix of health care facility types" 111 "Unspecified health care facility type" 201 "Mobile clinic (van, truck, etc.)" 202 "Temporary site in community building" 203 "Camp (e.g. tents for a week)" 204 "At client residences (targeted or door-to-door)" 205 "In at-risk setting (e.g. in brothel, bar, etc.)" 301 "Community center" 302 "School" 303 "Workplace" 304 "Other Community facility (e.g. religious center)" 401 "No facility (e.g. legislation, human rights advocacy, mass media)" 501 "Other facility type - specify in comments" 502 "Facility type is not reported"
					label values facility_cat facility_cat
					label variable facility_cat "Narrow Facility Category"
	
	
			*Finally, can we create mid-level variables for type of facility:
			gen fac_type=.
				replace fac_type=1 if facility_cat==101 | facility_cat==102
				replace fac_type=2 if facility_cat==103 | facility_cat==104
				replace fac_type=3 if facility_cat==105 | facility_cat==107 | facility_cat==108 | facility_cat==108 | facility_cat==109
				replace fac_type=4 if facility_cat==110 | facility_cat==111
				replace fac_type=5 if meta_facility==2
				replace fac_type=6 if meta_facility==3
				replace fac_type=7 if meta_facility==4
				replace fac_type=8 if meta_facility==5
				label define fac_type 1 "Clinics" 2 "Integrated clinics" 3 "Hospitals" 4 "HC unspecified/other" 5 "Mobile outreach" 6 "Community-based" 7 "Population level" 8 "Other/Unspecified" 
				label values fac_type fac_type
					label variable fac_type "Facility Type for Analysis"
				
				
			* And binaries for facility_type
			tab fac_type, gen(v_)
				rename v_1 ft_clinics
				rename v_2 ft_intclinics
				rename v_3 ft_hospitals
				rename v_4 ft_unspecified_hc
				rename v_5 ft_other
					// note, specific to ART, not appropriate for other intervention types
				
			* And binaries for faclity_category
			tab facility_cat, gen(v_)
				rename v_1 health_post
				rename v_2 health_center
				rename v_3 hosp_clinic
				rename v_4 hosp_clinic_disease
				rename v_5 primary_hosptial
				rename v_6 secondary_hospital
				rename v_7 tertiary_hospital
				rename v_8 unspec_hospital
				rename v_9 mixed_healthfac
				rename v_10 unspecified_healthfac
				rename v_11 other_facility
				
				** Try adding both to the models to see how it might differ.
	
	* Do I need to destring or recode: id_details; id_phase; 
	
	
	* Save progress
	save temp_dta/study_attributes.dta,replace	
	

*************************************************************************
* Part II
* Above, everything from cost_data sheet is encoded and ready for merging
* Below, we create two separate datasets for analysis
* 		1. Long DS with each row = cost input, combined with study level data
* 		2. Wide DS with each row as a study, collapsed and combined with study level data
*************************************************************************


	* II.1 - Create Long Dataset (simply load in clean study_attributes data)
	*************************************************************************
	
	clear
	use temp_dta/costs.dta
		drop ar_capital-a_uns_unspecified
	merge m:1 id using temp_dta/study_attributes.dta
		order extractor_initials-consistency_rmk
		order id
				drop if _merge!=3
				drop _merge
	
				save final_dta/long_file.dta, replace
				*This dataset may require some additional cleaning and culling for appropriate use
*!*					* HIV110c and 110d are both missing all "mean costs" - need to fix.
				
				
	* II.2 - Create Wide Dataset (collapse by unit_cost and add study_attributes data)
	**********************************************************************************
	clear
	use temp_dta/costs.dta

	
	* First set up the desired order of the collapsed cost variable with markers
			*Broad as reported costs
				gen broad_asreported=.
				move broad_asreported ar_capital
			*Narrow as reported costs
				gen narrow_asreported=.
				move narrow_asreported ar_cap_start_up
			
			*Broad Standardized Input costs
				gen broad_stdinput=.
				move broad_stdinput si_capital
			* Narrow Standardized Input costs
				gen narrow_stdinput=.
				move narrow_stdinput si_cap_other
			
				
			*Broad Activity Costs
				gen broad_activity=.
				move broad_activity a_ancillary
		
			* Narrow Activity costs
				gen narrow_activity=.
				move narrow_activity a_anc_adherence_retention
			
	
			save temp_dta/costs.dta, replace



		* Collapse for reshape wide 
		* (here, in two parts, 	1) collapse cost variables, and 
		*						2) remove non-total rows for all categorical variables).
		************************************************************************************

			*1. Collapse cost variables into new dataset
			*Need to collapse one var at a time and append to a new dataset
				collapse broad_asreported, by (unit_cost)
				save temp_dta/costs_temp.dta,replace
					clear
					use temp_dta/costs.dta
				*set trace on
				foreach i of varlist ar_capital-a_uns_unspecified {
						bysort unit_cost (`i') : gen miss = mi(`i'[1])
						collapse (sum) `i' (min) miss, by (unit_cost)
						replace `i'=. if miss==1
							drop miss
						merge 1:1 unit_cost using temp_dta/costs_temp.dta
							drop _merge
							save temp_dta/costs_temp.dta,replace
								clear
						use temp_dta/costs.dta
						}
						*
			*2. Now collapse all of the categorical variables just by total
				drop ar_capital-a_uns_unspecified
				keep if ar_narrow1=="full costing total" | ar_narrow1=="partial costing"
					save temp_dta/c_categoricals.dta,replace
					merge m:1 unit_cost using temp_dta/costs_temp.dta
							drop if _merge!=3
									* None dropped
							drop _merge
							
				
				*Create Global variables for ease of reordering
				global ar_broad ar_capital ar_facility ar_overhead ar_patient_costs ar_personnel ar_recurring_goods ar_recurring_services
				global ar_narrow ar_cap_start_up ar_cap_unspecified ar_cap_vehicles ar_fac_rental ar_fac_utilities ar_ove_unspecified ar_patcosts_accommodation ar_patcosts_carer_costs ar_patcosts_direct_medical ar_patcosts_food_service ar_patcosts_intangible ar_patcosts_patient_transport ar_patcosts_time_loss ar_per_admin_support ar_per_clinical_officer ar_per_counselors ar_per_lab_personnel ar_per_mgmt ar_per_nurses ar_per_pharmacy ar_per_physicians ar_per_service_delivery ar_per_unspecified ar_recgoods_clinical_consum ar_recgoods_consumables ar_recgoods_fuel ar_recgoods_key_drugs ar_recgoods_lab_consumables ar_recgoods_nonkey_drugs ar_recgoods_unspecified ar_recservices_equip_maint ar_recservices_food_support ar_recservices_hct ar_recservices_inpatient ar_recservices_lab_test ar_recservices_mconsult ar_recservices_medical_imaging ar_recservices_nonkey_drugs ar_recservices_storage ar_recservices_supply_chain ar_recservices_training ar_recservices_transport ar_recservices_unspecified ar_sub_subtotal ar_tot_full_costing_total ar_tot_partial_costing
				global si_broad si_capital si_combined si_mixed si_pdm si_pdn si_personnel si_pia si_pmx si_recurrent
				global si_narrow si_cap_other si_cap_vehicles si_com_combined si_com_unit_cost_total si_mix_building_space si_mix_mixed si_pdm_pat_fees si_pdn__patient__transport si_per_mixed_unspec si_per_service_delivery si_per_support si_pia_pat_productivity si_pmx_pat_mixed si_rec_building_space si_rec_key_drugs si_rec_med_int_supplies si_rec_nonmed_int_supplies si_rec_other
				global a_broad a_ancillary a_combo a_mixed a_operational a_primary_sd a_secondary_sd a_unspecified
				global a_narrow a_anc_adherence_retention a_anc_lab_services a_anc_unspecified a_com_combo a_mix_mixed a_ope_bldg_equip a_ope_logistics a_ope_program_mgmt a_ope_supervision a_ope_training a_ope_transportation a_ope_unspecified a_prisd_arv_delivery a_prisd_lab_monitoring a_prisd_lab_services a_prisd_unspecified a_secsd_unspecified a_uns_unspecified
				global output output_pmonth output_pyear output_pyear2 output_pmonth2 output1k_mo output1k_yr output1k_yr2 output1k_mo2	
				
				* reorder for ease of finding (Using Globals)
				order id unit_cost mean_cost broad_asreported $ar_broad narrow_asreported $ar_narrow broad_stdinput $si_broad narrow_stdinput $si_narrow broad_activity $a_broad narrow_activity $a_narrow $output
			
					
				* First label organizational variables after resort
				label variable broad_asreported "----------------------------------"
				label variable narrow_asreported "----------------------------------"
				label variable broad_stdinput "----------------------------------"	
				label variable narrow_stdinput "----------------------------------"
				label variable broad_activity "----------------------------------"
				label variable narrow_activity "----------------------------------"
				
				* Finally merge in study_attribute dataset
				merge m:1 id using temp_dta/study_attributes.dta
					drop if _merge!=3
						* In this case it drops the 6 sub-studies that we dont want
						drop _merge
			
		
			*Final cleaning and creation of organizational variables
			*********************************************************
			drop cost_record subset_of ar_narrow1 ar_broad1 si_narrow1 si_broad1 a_narrow1 a_broad1
			
			gen COVARIATES=.
			move COVARIATES output_pmonth
			label variable COVARIATES "----------------------------------"
			
			gen output_vars=.
			move output_vars output_pmonth
			label variable output_vars "----------------------------------"
			
			* Save version before importing GDPPC data:
			save final_dta/wide_file.dta, replace
			
			* Finally, import GDPPC data for each study.
			********************************************
				* Underlying dataset can be found at https://data.worldbank.org/indicator/NY.GDP.PCAP.CD
				* Simply download EXCEL file option for ALL countries (should be default). 
				* Download for this presentation was done on 25 October 2017
				* File name is: API_NY.GDP.PCAP.CD_DS2_en_excel_v2.xls
				* place file in path along with data extraction template
				* Presumably formatting for this file shouldnt change year-to-year, but possible 
				* ...so check that import and file manipulation commands below work. 
	STOP	
		
			clear

	*Change directory to pull in outside data
	cd "/Users/dcameron03/Documents/Berkeley/`GSI with Jim/Stata/GHCC/"
			
			import excel "external_data/API_NY.GDP.PCAP.CD_DS2_en_excel_v2.xls", firstrow sheet("Data") cellrange(A4) case(l)
						// Years wont translate to varnames, but will be retained as labels for cols e-bi
						// Need to manually rename the Years row (4) from #### to y####
						drop countrycode-y1999
						
			*global years y2000-y2016
			reshape long y, i(countryname) j(year_d)
			rename y gdppc
			rename year_d currency_yr
			rename countryname country_alt
			save ART/temp_dta/gdppc.dta, replace
			
			clear
			
			*Now merge in the GDPPC data you've created: 
			use ART/final_dta/wide_file.dta
			
			merge m:1 country_alt currency_yr using "ART/temp_dta/gdppc.dta"
				drop if _merge==2
*!*					* 13 did not merge, probably because of missing data in currency_yr
						//hiv110c and d; hiv104; hiv114 (all #s)
				drop _merge
				
				
			move gdppc country
			
			
			save ART/final_dta/wide_file.dta, replace

* And Binaries and amounts of global fund (GFAMTB) and PEPFAR funding
	** For dataset for this process visit: <http://ghdx.healthdata.org/record/development-assistance-health-database-1990-2015>.
	** To do this you will need to maintain a string variable with the country names in the same format as the WB country names.

			clear
			use external_data/IHME_DAH_DATABASE_1990_2015_Y2016M04D25.DTA

			* Get rid of unnecessary data
				drop if year<2000
				drop if channel!="BIL_USA" & channel!="GFATM"
				gen hiv_funding=hiv_dah_15+hiv_treat_dah_15+hiv_prev_dah_15+hiv_pmtct_dah_15+hiv_ovc_dah_15+hiv_care_dah_15+hiv_ct_dah_15+hiv_unid_dah_15+hiv_tb_dah_15+hiv_hss_dah_15
				
				gen pepfar=0
					replace pepfar=1 if channel=="BIL_USA" & year>2002 & hiv_funding!=0
					label var pepfar "Country recieved PEPFAR funding y/n"
				
				gen pepfar_amt=0
					replace pepfar_amt=hiv_dah_15 if channel=="BIL_USA" & year>2002 
					label var pepfar_amt "Amnt of PEPFAR funding 2016 USD"
				
				gen global_fund=0
					replace global_fund=1 if dah_15!=0 & channel=="GFATM"
					label var global_fund "Country recieved Global Fund funding y/n"
				
				gen global_fund_amt=0
					replace global_fund_amt=dah_15 if channel=="GFATM"
					label var global_fund_amt "Amnt of GF funding 2016 USD"
				
				keep year recipient_country pepfar pepfar_amt global_fund global_fund_amt
				rename year currency_yr
				rename recipient_country country_alt
				
		* Inflate to 2016 dollars using the CPI
			gen	cpi_current=110.0670089		
			gen	cpi_old	=.		
			replace	cpi_old=78.97072076	if currency_yr==	2000
			replace	cpi_old=81.20256846	if currency_yr==	2001
			replace	cpi_old=82.49046688	if currency_yr==	2002
			replace	cpi_old=84.36307882	if currency_yr==	2003
			replace	cpi_old=86.62167812	if currency_yr==	2004
			replace	cpi_old=89.56053237	if currency_yr==	2005
			replace	cpi_old=92.44970508	if currency_yr==	2006
			replace	cpi_old=95.08699238	if currency_yr==	2007
			replace	cpi_old=98.73747739	if currency_yr==	2008
			replace	cpi_old=98.38641997	if currency_yr==	2009
			replace	cpi_old=100	if currency_yr==	2010
			replace	cpi_old=103.1568416	if currency_yr==	2011
			replace	cpi_old=105.2915045	if currency_yr==	2012
			replace	cpi_old=106.8338489	if currency_yr==	2013
			replace	cpi_old=108.5669321	if currency_yr==	2014
			replace	cpi_old=108.695722	if currency_yr==	2015
				* replace all costs to reflect CPI adjustment
				replace	global_fund_amt=global_fund_amt*(cpi_current/cpi_old)
				replace pepfar_amt=pepfar_amt*(cpi_current/cpi_old)
				
				drop cpi_current cpi_old
				collapse (sum) pepfar_amt global_fund_amt (max) pepfar global_fund, by(country_alt currency_yr)
				
				save ART/temp_dta/pepfar_gf_data.dta, replace
				clear
				use ART/final_dta/wide_file.dta
				
				merge m:1 country_alt currency_yr using "ART/temp_dta/pepfar_gf_data.dta"
					drop if _merge==2
*!*					* There are problems here because two studies have multiple countries (hiv114 and hiv104); another hiv110 has several observations that are probably only partial drug costs

					* Will need to check for other missing values by looking at data that didnt merge from master. 
					STOP
					*Based on patterns, I assume:
						*FOR ALL 3 STUDIES NEED TO MAKE EDUCATED ASSESSMENT OF PEPFAR & GF STATUS
						
						
						drop _merge
						drop country_alt
						
			save ART/final_dta/wide_file.dta, replace						

			
				
				
				
** STOP HERE			
			
	
