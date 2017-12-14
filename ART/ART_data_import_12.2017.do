******************************************************
* Data Cleaning and Transformation Do File
* Global Health Costing Consortium (GHCC)
* 
* Date created: December 4, 2017
*
* Lily Alexander, MPH Student, University of Washington
* lalexan1@uw.edu
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

	cd "C:/Users/Lily Alexander/Dropbox/ALL LIFE THINGS/INSP/Work with Sergio/GHCC/post_extraction_processing/"

* 1: Load in both data files (change title of excel file as appropriate)
***********************
//using GHCC_Data_Extraction_ART_v23_23-Oct-2017_DBC
* Costs data sheet
	import excel ART_12.2017.xlsx, firstrow sh("Cost data") clear
	
		*Save for working later
		save temp_dta/costs.dta,replace	
		clear
		
* Study Attributes data sheet	
	import excel ART_12.2017.xlsx, firstrow sh("Study attributes") clear
	
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
		
		drop extractor_initials-discount_rate_RS
		drop currency_yr_RS-_merge
			* No need to destring numerics

		replace mean_cost = "." if mean_cost == "NR"
		destring mean_cost, replace

			* START WITH: Inflation to 2016 dollars using the CPI
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
				replace	mean_cost=mean_cost*(cpi_current/cpi_old)		
				* This will have to be modified for any pre 2000 studies. 
			
			* NEXT: Inflation to 2016 dollars using GDP Deflator Index
				* data here: https://www.imf.org/external/pubs/ft/weo/2016/01/weodata/download.aspx
			
			
			* All can easily be updated for 2017 dollars later.
			
			
		*Save for working later
		save temp_dta/costs.dta,replace	

		
*
*!******* THIS TO BE REMOVED AFTER BEN FIXES EVERYTHING
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
				foreach i of varlist cap_medical_equipment-uns_unspecified {
					replace `i'=. if `i'==0
				}
			
			
			*Now replace all cat and subcat binaries with values of mean_cost
				foreach i of varlist capital-unspecified{
					egen unique`i'=group(`i')
					}
					drop capital-unspecified
					rename unique* *
					
					*STILL NEED TO REORDER VARS
				foreach i of varlist capital-unspecified {
					move `i' cap_medical_equipment
				}
				
			* Apply all mean_costs to these variables with missing obs for all 	
				foreach i of varlist capital-uns_unspecified{
					replace `i'=mean_cost if `i'!=.
				}
			*
			
					* Fix variable names that are too long: 
					rename recservices_equipment_maintenanc recserv_equip_maint
				
			
			*Finally add a prefix to these new variables ar_
			foreach i of varlist capital-uns_unspecified {
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
				***** Should do the same here for TB coding including:
						* Patient direct, medical
						* Patient direct, non medical
						* Patient indirect
						* Patient direct
						* Patient mixed
						* Patient coping strategies
			
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
				foreach i of varlist cap_medical_equip-rec_nonmed_int_supplies {
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
					move `i' cap_medical_equip
				}
				
			* Apply all mean_costs to these variables with missing obs for all 	
				foreach i of varlist capital-rec_nonmed_int_supplies{
					replace `i'=mean_cost if `i'!=.
				}
			*
					
			*Finally add a prefix to these new variables si_
			foreach i of varlist capital-rec_nonmed_int_supplies {
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
			
			tostring ancillary-secondary_sd, replace
	
			foreach i of varlist ancillary-secondary_sd {
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
	
				*clean up
				foreach i of varlist anc_demand_generation-secsd_hct {
					replace `i'=. if `i'==0
				}
			
			
			*Now replace all cat and subcat binaries with values of mean_cost
				foreach i of varlist ancillary-secondary_sd{
					egen unique`i'=group(`i')
					}
					drop ancillary-secondary_sd
					rename unique* *
					
					*STILL NEED TO REORDER VARS
				foreach i of varlist ancillary-secondary_sd {
					move `i' anc_demand_generation
				}
				
			* Apply all mean_costs to these variables with missing obs for all 	
				foreach i of varlist ancillary-secsd_hct{
					replace `i'=mean_cost if `i'!=.
				}
			*
				* Fix shitty variable name
						rename ope_building_and_equipment__main ope_bldg_equip_main
			*Finally add a prefix to these new variables si_
			foreach i of varlist ancillary-secsd_hct {
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
		* rename substudyid id
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
			*Years
			foreach i of varlist start_year end_year year_intro ref_year{
				replace `i'=lower(`i')
				replace `i'="" if `i'=="n/a" | `i'=="nr" |  `i'=="na" | `i'=="no year"
				destring `i', replace
				}
			
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
				destring `i', replace
				}
				
			*Period portrayed
			replace period_portrayed=lower(period_portrayed)
			replace period_portrayed="." if period_portrayed=="nr" | period_portrayed=="n/a"
			destring period_portrayed, replace
			
		* Exchange Rate
			replace current_x_rate=	lower(current_x_rate)
			replace current_x_rate="." if current_x_rate=="nr"
			destring current_x_rate, replace
			
		* number of sites
			replace no_sites="." if no_sites=="N/A" | no_sites=="NR"
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
				rename v_5 ft_mobile_outreach
				rename v_6 ft_poplevel
				rename v_7 ft_other
					// note not appropriate for other intervention types
				
			* And binaries for faclity_category
			tab facility_cat, gen(v_)
				rename v_1 health_post
				rename v_2 health_center
				rename v_3 hospital_clinic
				rename v_4 primary_hosptial
				rename v_5 tertiary_hospital
				rename v_6 unspec_hospital
				rename v_7 mixed_healthfac
				rename v_8 unspecified_healthfac
				rename v_9 mobile_clinic
				rename v_10 temp_site
				rename v_11 camp
				rename v_12 pop_level
				rename v_13 other_facility
				rename v_14 type_nr
				
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
		drop ar_capital-a_secsd_hct
	merge m:1 id using temp_dta/study_attributes.dta
		order extractor_initials-consistency_rmk
		order id
				drop if _merge!=3
				drop _merge
	
				save final_dta/long_file.dta, replace
				*This dataset may require some additional cleaning and culling for appropriate use
				
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
				move narrow_asreported ar_cap_medical_equipment
			
			*Broad Standardized Input costs
				gen broad_stdinput=.
				move broad_stdinput si_capital
			* Narrow Standardized Input costs
				gen narrow_stdinput=.
				move narrow_stdinput si_cap_medical_equip
			
				
			*Broad Activity Costs
				gen broad_activity=.
				move broad_activity a_ancillary
		
			* Narrow Activity costs
				gen narrow_activity=.
				move narrow_activity a_anc_demand_generation
			
	
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
				foreach i of varlist ar_capital-a_secsd_hct {
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
				drop ar_capital-a_secsd_hct
				keep if ar_narrow1=="full costing total" | ar_narrow1=="partial costing"
					save temp_dta/c_categoricals.dta,replace
					merge m:1 unit_cost using temp_dta/costs_temp.dta
							drop if _merge!=3
									* In this case, drops 6 that we dont want anyway
							drop _merge
							
				* reorder for ease of finding 
				* (This could be done in a better way, problem is the above procedure reverses the order)	
				order id unit_cost broad_asreported ar_broad ar_capital ar_facility ar_overhead ar_personnel ar_recurring_goods ar_recurring_services ar_subtotal ar_total ar_unspecified ar_narrow narrow_asreported ar_cap_medical_equipment ar_cap_non_consumable_supplies ar_cap_non_medical_equipment ar_cap_unspecified ar_fac_building ar_fac_maint_and_util ar_fac_rental ar_fac_waste_management ar_ove_unspecified ar_per_admin_support ar_per_nurses ar_per_physicians ar_per_service_delivery ar_per_unspecified ar_recgoods_clinical_consumables ar_recgoods_consumables ar_recgoods_nclinical_consum ar_recservices_hct ar_recservices_adverse_events ar_recservices_consultancy ar_recservices_demand_generation ar_recservices_inpatient ar_recservices_lab_test ar_recservices_mgmt ar_recservices_sterilization ar_recservices_supply_chain ar_recservices_training ar_recservices_transport ar_sub_subtotal ar_tot_full_costing_total ar_tot_partial_costing ar_uns_unspecified broad_stdinput si_broad si_capital si_mixed si_personnel si_recurrent narrow_stdinput si_narrow si_cap_medical_equip si_cap_nonmed_equip si_cap_other si_mix_mixed si_per_mixed_unspec si_per_service_delivery si_per_support si_rec_building_space si_rec_med_int_supplies si_rec_nonmed_int_supplies broad_activity a_broad a_ancillary a_mixed a_operational a_primary_sd a_secondary_sd narrow_activity a_narrow a_anc_demand_generation a_anc_lab_services a_anc_unspecified a_mix_mixed a_ope_bldg_equip a_ope_logistics a_ope_program_mgmt a_ope_supervision a_ope_training a_ope_transportation a_ope_unspecified a_prisd_circumcision_proced a_prisd_unspecified a_secsd_hct output_pmonth output_pyear output_pyear2 output_pmonth2 output1k_mo output1k_yr output1k_yr2 output1k_mo2	
							
				* First label organizational variables after resort
				label variable broad_asreported "----------------------------------"
				label variable narrow_asreported "----------------------------------"
				label variable broad_stdinput "----------------------------------"	
				label variable narrow_stdinput "----------------------------------"
				label variable broad_activity "----------------------------------"
				label variable narrow_activity "----------------------------------"
			
				* Generate a Unit Cost Total "uc_total"
				move mean_cost ar_broad
				
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
		
			
			clear

			import excel "API_NY.GDP.PCAP.CD_DS2_en_excel_v2.xls", firstrow sheet("Data") cellrange(A4) case(l)
						// Years wont translate to varnames, but will be retained as labels for cols e-bi
						// Need to manually rename the Years row (4) from #### to y####
						drop countrycode-y1999
						
			*global years y2000-y2016
			reshape long y, i(countryname) j(year_d)
			rename y gdppc
			rename year_d currency_yr
			rename countryname country_alt
			save temp_dta/gdppc.dta, replace
			
			clear
			
			*Now merge in the GDPPC data you've created: 
			use final_dta/wide_file.dta
			
			merge m:1 country_alt currency_yr using "temp_dta/gdppc.dta"
				drop if _merge==2
				drop _merge
				
				
			move gdppc country
			
			
			save final_dta/wide_file.dta, replace

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
				
				save temp_dta/pepfar_gf_data.dta, replace
				clear
				use final_dta/wide_file.dta
				
				merge m:1 country_alt currency_yr using "temp_dta/pepfar_gf_data.dta"
					drop if _merge==2
					* There are problems here because missing data for South Africa (2014) and Zimbabwe (2014, 2015)
					* Will need to check for other missing values by looking at data that didnt merge from master. 
						*Based on patterns, I assume:
						replace pepfar=1 if country_alt=="Zimbabwe" & currency_yr>2013
						replace global_fund=1 if country_alt=="Zimbabwe" & currency_yr>2013
						replace pepfar=1 if country_alt=="South Africa" & currency_yr>2013
						replace global_fund=1 if country_alt=="South Africa" & currency_yr>2013
						drop _merge
						drop country_alt
						
			save final_dta/wide_file.dta, replace						

			
				
				
				
** STOP HERE			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
********************************************************************************************************
********************************************************************************************************			
**** THE CLEANING PROCEDURE STOPS HERE> EVERYTHING BELOW IS FROM OLDER DO FILES OR FOR MY OWN REFERENCE
********************************************************************************************************			
********************************************************************************************************			
	
	/*
			* Use this procedure to see that the new categories add up to 
			* at least ABOUT the same amount as the mean_cost (as there will be
			* minor discrepancies in reporting based on rounding and extrapolation)

			
			* AR Broad
				move ar_unspecified ar_total
				egen ar_b_totes=rowtotal(ar_capital-ar_unspecified)
				move ar_b_totes mean_cost
			* AR NARROW
				move ar_uns_unspecified ar_sub_subtotal
				egen ar_n_totes=rowtotal(ar_cap_medical_equipment-ar_uns_unspecified)
				
			
			*SI BROAD
				egen si_b_totes=rowtotal(si_capital-si_recurrent)
				move si_b_totes mean_cost
				
		
			* SI NARROW
				egen si_n_totes=rowtotal(si_cap_medical_equip-si_rec_nonmed_int_supplies)
				move si_n_totes mean_cost
			
			
			*A_BROAD
				egen a_b_totes=rowtotal(a_ancillary-a_secondary_sd)
				move a_b_totes mean_cost
			
			*A_Narrow
				egen a_n_totes=rowtotal(a_anc_demand_generation-a_secsd_hct)
				move a_n_totes mean_cost
		
		*First round (Rounding dollar values to nearest cent)
		
		gen blah = round(ar_b_totes,.01)
		
		foreach i of varlist ar_b_totes si_b_totes si_n_totes a_b_totes a_n_totes {
			gen `i'_1 = round(`i',0.01)
			move `i'_1 `i'
			drop `i'
			rename `i'_1 `i'
			replace `i'=. if `i'==0
		}
		

		
			** NEED TP:
				
				*2. fix up the additional cost stuff
					* Looks like these variables apply to specific inputs, but are not possible to aggregate in wide file
					
					
					
					
* Drop those unnecessary variables (unless there's need to keep this)
* drop ar_narrow1 ar_broad1 si_narrow1 si_broad1 a_narrow1 a_broad1		
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
** Stuff thats probably not necessary
*************************************	
					
*And reorder variables appropriately (need to add in reorder of cost variables)
order broad_categories capital_costs environment facility overhead patient_costs personnel recurring_goods recurring_goods_non_traded recurring_goods_traded recurring_services subtotal total training sub_categories capital_costs_sub capc_furnishings capc_medical_equipment capc_na capc_non_consumable_supplies capc_non_medical_equipment capc_start_up capc_unspecified capc_unspecified_equipment capc_vehicles environment_sub env_na facility_sub fac_building fac_facility_maintenance fac_facility_rental fac_management fac_unspecified fac_utilities overhead_sub ove_na ove_off_site ove_on__or_off_site_unspecified ove_on_site ove_recurring_services pat_costs_sub patc_indirect_costs personnel_sub per_administration per_direct_service_delivery per_management per_na per_unspecified recurring_goods_sub recg_clinical_consumables recg_fuel recg_na recg_non_clinical_consumables recg_pharmaceuticals recg_unspecified r_goods_ntraded_sub recgnt_medical_consultation recgnt_recurring_services r_goods_traded_sub recgt_clinical_consumables recurring_services_sub recs_commodity_distribution recs_demand_generation recs_equipment_maintenance recs_hiv_counseling_and_testing recs_inpatient_service recs_laboratory_test recs_medical_consultation recs_na recs_transportation recs_unspecified training_sub tra_na subtotal_sub sub_na total_sub tot_full_costing_total tot_na tot_partial_costing_total

*Stick these in front (there's gotta be a better way to do this)
order substudyid unit_cost cost_record disease intervention cap_recurring activity_cat input_broad_cat input_broad_cat1 input_narrow_cat input_narrow_cat1 subset_of cost_details core_input output_unit_reported output_unit output_unit2 integrated_generic mean_cost lower_ci upper_ci std_dev median_cost lower_iqr upper_iqr direct_obs unit_obs input_price input_quantity input_type timeframe program_level_cost output_quantity time_period_mo source cost_remarks pot_distortions pot_distortions_rs adjustments timeframe_rmrk empirical_modeled cost_source cost_source_rs cost_allocation_method cost_allocation_method_rs resource_id resource_id_rs resource_valuation resource_valuation_rs price_sources price_sources_rs inputq_source inputq_source_rs full_subsidized full_subsidized_rs adjustment_method adjustment_method_rs data_collection data_collection_rs recall_period recall_period_rs output_methods output_methods_rs data_timing data_timing_rs inflation inflation_rs inflation_method inflation_method_rs amortization amortization_rs methods_rmrk currency_iso currency_name currency_rs
	
	*And rename organizational variables
		label var sub_categories "-------------------------------------------------"
		label var broad_categories "-------------------------------------------------"
		label var capital_costs_sub "-------------------------------------------------"
		label var facility_sub "-------------------------------------------------"
		label var overhead_sub "-------------------------------------------------"
		label var pat_costs_sub "-------------------------------------------------"
		label var personnel_sub "-------------------------------------------------"
		label var recurring_goods_sub "-------------------------------------------------"
		label var r_goods_traded_sub "-------------------------------------------------"
		label var r_goods_ntraded_sub "-------------------------------------------------"
		label var recurring_services_sub "-------------------------------------------------"
		label var training_sub "-------------------------------------------------"
		label var environment_sub "-------------------------------------------------"
		label var subtotal_sub "-------------------------------------------------"
		label var total_sub "-------------------------------------------------"

		save temp_dta/costlevel_wide.dta,replace
		
		clear
		
		
		



*Labels and globals for organization
************************************
	* Global for new cost items
		global costs capital_costs-tra_na
		
	*Broad cats
	gen broad_categories=. 
	label var broad_categories "-------------------------------------------------"
	move broad_categories capital_costs

	*Sub cats
	gen sub_categories=.
	label var sub_categories "-------------------------------------------------"
	move sub_categories capc_furnishings

	*Individual subs
		* Capital costs
		gen capital_costs_sub=.
		label var capital_costs_sub "-------------------------------------------------"

		* Facility
		gen facility_sub=.
		label var facility_sub "-------------------------------------------------"

		* Overhead
		gen overhead_sub=.
		label var overhead_sub "-------------------------------------------------"

		* Patient Costs
		gen pat_costs_sub=.
		label var pat_costs_sub "-------------------------------------------------"

		* Personnel
		gen personnel_sub=.
		label var personnel_sub "-------------------------------------------------"

		* Recurring Goods
		gen recurring_goods_sub=.
		label var recurring_goods_sub "-------------------------------------------------"

		* Recurring Goods Traded
		gen r_goods_traded_sub=.
		label var r_goods_traded_sub "-------------------------------------------------"

		* Recurring Goods Non Traded
		gen r_goods_ntraded_sub=.
		label var r_goods_ntraded_sub "-------------------------------------------------"

		* Recurring Services
		gen recurring_services_sub=.
		label var recurring_services_sub "-------------------------------------------------"

		* Training
		gen training_sub=.
		label var training_sub "-------------------------------------------------"

		* Environment
		gen environment_sub=.
		label var environment_sub "-------------------------------------------------"
			
		* Subtotal
		gen subtotal_sub=.
		label var subtotal_sub "-------------------------------------------------"
			
		* Total
		gen total_sub=.
		label var total_sub "-------------------------------------------------"

		global org capital_costs_sub-total_sub
		
* Apply sub-area organizational labels based on first three letters of?
	*Not sure how to do this, will have to revisit later.

	move capital_costs_sub capc_furnishings
	move environment_sub env_na
	move facility_sub fac_building
	move overhead_sub ove_na
	move pat_costs_sub patc_indirect_costs
	move personnel_sub per_administration
	move recurring_goods_sub recg_clinical_consumables
	move r_goods_ntraded_sub recgnt_medical_consultation
	move r_goods_traded_sub recgt_clinical_consumables
	move recurring_services_sub recs_commodity_distribution
	move training_sub tra_na
	move subtotal_sub sub_na
	move total_sub tot_full_costing_total
	move training_sub subtotal_sub
	move tra_na subtotal_sub
  
	
*And reorder variables appropriately
order substudyid unit_cost cost_record disease intervention cap_recurring activity_cat input_broad_cat input_broad_cat1 input_narrow_cat input_narrow_cat1 subset_of cost_details core_input output_unit_reported output_unit output_unit2 integrated_generic mean_cost lower_ci upper_ci std_dev median_cost lower_iqr upper_iqr direct_obs unit_obs input_price input_quantity input_type timeframe program_level_cost output_quantity time_period_mo source cost_remarks pot_distortions pot_distortions_rs adjustments timeframe_rmrk empirical_modeled cost_source cost_source_rs cost_allocation_method cost_allocation_method_rs resource_id resource_id_rs resource_valuation resource_valuation_rs price_sources price_sources_rs inputq_source inputq_source_rs full_subsidized full_subsidized_rs adjustment_method adjustment_method_rs data_collection data_collection_rs recall_period recall_period_rs output_methods output_methods_rs data_timing data_timing_rs inflation inflation_rs inflation_method inflation_method_rs amortization amortization_rs methods_rmrk currency_iso currency_name currency_rs
	
	
	save temp_dta/costs.dta,replace	

	
	
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		


*****************************************************************************	



* save temp_dta/study_attributes.dta,replace

********************************************
* Merge together with cost-level subdataset:
********************************************

	*Create studyid for analysis
		gen studyid=substr(substudyid,1,6)
		move studyid extractor_initials

 *merge together three data files
		merge 1:m substudyid using temp_dta/costlevel_wide.dta
				* Three lines that were not totals get dropped from the analysis
			drop if _merge!=3
			drop _merge

			


STOP HERE
 
 * Stuff to deal with above:
 * Counterfacutals no longer exists, need to replace
 * Also should do all load in of data from extraction sheet in the first few lines so I dont forget
 *   which sheets I'm importing from later on in the do file. Quick fix, needs standardized
 * Keep cleaning this up and try getting rid of crap that doesn't help
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 

********************************************************************************
*PRIOR CLEANING (use this only as useful).




*Finish with





	
		
		
		

stop


/*
	

* Drop unnecessary variables for export to Will (fix later when actual variables desired have been determined)
************************************************
drop disease-activity_cat
drop input_broad_cat
drop inputnarrowcat-integrated_generic
drop lower_ci-_
*/

			
/*


* Capital costs
gen capital_costs_sub=.
label var capital_costs_sub "-------------------------------------------------"

gen cc_admin_equipment=.
	replace cc_admin_equipment=capital_costs if capital_costs==1
gen cc_furnishings=.
	replace cc_furnishings=capital_costs if capital_costs==2
gen cc_lab_equipment=. 
	replace cc_lab_equipment=capital_costs if capital_costs==3
gen cc_med_equipment=.  
	replace cc_med_equipment=capital_costs if capital_costs==4
gen cc_non_consumables=.
	replace cc_non_consumables=capital_costs if capital_costs==5
gen cc_non_med_equipment=. 
	replace cc_non_med_equipment=capital_costs if capital_costs==6
gen cc_start_up=.
	replace cc_start_up=capital_costs if capital_costs==7
gen cc_vehicles=. 
	replace cc_vehicles=capital_costs if capital_costs==8
gen cc_unspecified=. 
	replace cc_unspecified=capital_costs if capital_costs==9
gen cc_unspecified_equip=.
	replace cc_unspecified_equip=capital_costs if capital_costs==10
gen cc_na=.
	replace cc_na=capital_costs if capital_costs==11

foreach i of varlist cc_admin_equipment-cc_na {
replace `i'=mean_cost if `i'!=.

}



* Facility
	gen facility_sub=.
	label var facility_sub "-------------------------------------------------"
	gen fac_building=.
		replace fac_building=facility if facility==1
	gen fac_maintenance=.
		replace fac_maintenance=facility if facility==2
	gen fac_rental=.
		replace fac_rental=facility if facility==3
	gen fac_management=.
		replace fac_management=facility if facility==4
	gen fac_unspecified=.
		replace fac_unspecified=facility if facility==5
	gen fac_utilities=.
		replace fac_utilities=facility if facility==6

	foreach i of varlist fac_building-fac_utilities {
	replace `i'=mean_cost if `i'!=.
	}


* Overhead
	gen overhead_sub=.
	label var overhead_sub "-------------------------------------------------"
	gen oh_off_site=.
		replace oh_off_site=overhead if overhead==1
	gen oh_onandoff_site=.
		replace oh_onandoff_site=overhead if overhead==2
	gen oh_onoroff_site=.
		replace oh_onoroff_site=overhead if overhead==3
	gen oh_unspecified=.
		replace oh_unspecified=overhead if overhead==4
	gen oh_on_site=.
		replace oh_on_site=overhead if overhead==5
	gen oh_recurring_services=.
		replace oh_recurring_services=overhead if overhead==6
	gen oh_na=.
		replace oh_na=overhead if overhead==7
	foreach i of varlist oh_off_site-oh_na {
	replace `i'=mean_cost if `i'!=.
	}
		
* Patient Costs
	gen pat_costs_sub=.
	label var pat_costs_sub "-------------------------------------------------"
	gen pc_indirect_costs=.
		replace pc_indirect_costs=patient_costs if patient_costs==1
	gen pc_lost_income=.
		replace pc_lost_income=patient_costs if patient_costs==2
	gen pc_service_fee=.
		replace pc_service_fee=patient_costs if patient_costs==3
	gen pc_travel_expenses=.
		replace pc_travel_expenses=patient_costs if patient_costs==4
	gen pc_na=.
		replace pc_na=patient_costs if patient_costs==5
	foreach i of varlist pc_indirect_costs-pc_na {
	replace `i'=mean_cost if `i'!=.
	}
		
* Personnel
	gen personnel_sub=.
	label var personnel_sub "-------------------------------------------------"
	gen p_administration=.
		replace p_administration=personnel if personnel==1
	gen p_counselors=.
		replace p_counselors=personnel if personnel==2
	gen p_dir_serv_deliv=.
		replace p_dir_serv_deliv=personnel if personnel==3
	gen p_management=.
		replace p_management=personnel if personnel==4
	gen p_unspecified=.
		replace p_unspecified=personnel if personnel==5
	gen p_na=.
		replace p_na=personnel if personnel==6

	foreach i of varlist p_administration-p_na {
	replace `i'=mean_cost if `i'!=.
	}

* Recurring Goods
	gen recurring_goods_sub=.
	label var recurring_goods_sub "-------------------------------------------------"
	gen rg_c_consumables=.
		replace rg_c_consumables=recurring_goods if recurring_goods==1
	gen rg_fuel=.
		replace rg_fuel=recurring_goods if recurring_goods==2
	gen rg_water=.
		replace rg_water=recurring_goods if recurring_goods==3
	gen rg_nc_consumables=.
		replace rg_nc_consumables=recurring_goods if recurring_goods==4
	gen rg_pharmaceuticals=.
		replace rg_pharmaceuticals=recurring_goods if recurring_goods==5
	gen rg_unspecified=.
		replace rg_unspecified=recurring_goods if recurring_goods==6
	gen rg_na=.
		replace rg_na=recurring_goods if recurring_goods==7

	foreach i of varlist rg_c_consumables-rg_na {
	replace `i'=mean_cost if `i'!=.
	}
		
* Recurring Goods Traded
	gen r_goods_traded_sub=.
	label var r_goods_traded_sub "-------------------------------------------------"
	gen rgt_c_consumables=.
		replace rgt_c_consumables=recurring_goods_traded if recurring_goods_traded==1
	gen rgt_nc_consumables=.
		replace rgt_nc_consumables=recurring_goods_traded if recurring_goods_traded==2
	gen rgt_pharmaceuticals=.
		replace rgt_pharmaceuticals=recurring_goods_traded if recurring_goods_traded==3
	gen rgt_u_consumables=.
		replace rgt_u_consumables=recurring_goods_traded if recurring_goods_traded==4

	foreach i of varlist rgt_c_consumables-rgt_u_consumables {
	replace `i'=mean_cost if `i'!=.
	}
		
* Recurring Goods Non Traded
	gen r_goods_ntraded_sub=.
	label var r_goods_ntraded_sub "-------------------------------------------------"

	gen rgnt_advertising=.
		replace rgnt_advertising=recurring_goods_non_traded if recurring_goods_non_traded==1
	gen rgnt_med_consultation=.
		replace rgnt_med_consultation=recurring_goods_non_traded if recurring_goods_non_traded==2
	gen rgnt_recurring_services=.
		replace rgnt_recurring_services=recurring_goods_non_traded if recurring_goods_non_traded==3
	gen rgnt_research_tools=.
		replace rgnt_research_tools=recurring_goods_non_traded if recurring_goods_non_traded==4
	gen rgnt_na=.
		replace rgnt_na=recurring_goods_non_traded if recurring_goods_non_traded==5
		
	foreach i of varlist rgnt_advertising-rgnt_na {
	replace `i'=mean_cost if `i'!=.
	}

* Recurring Services
	gen recurring_services_sub=.
	label var recurring_services_sub "-------------------------------------------------"
	gen rs_commodity_distrib=.
		replace rs_commodity_distrib=recurring_services if recurring_services==1
	gen rs_consultancy=.
		replace rs_consultancy=recurring_services if recurring_services==2
	gen rs_demand_generation=.
		replace rs_demand_generation=recurring_services if recurring_services==3
	gen rs_equipment_maintenance=.
		replace rs_equipment_maintenance=recurring_services if recurring_services==4
	gen rs_food_service=.
		replace rs_food_service=recurring_services if recurring_services==5
	gen rs_inpatient_service=.
		replace rs_inpatient_service=recurring_services if recurring_services==6
	gen rs_lab_test=.
		replace rs_lab_test=recurring_services if recurring_services==7
	gen rs_med_consult=.
		replace rs_med_consult=recurring_services if recurring_services==8
	gen rs_med_imaging=.
		replace rs_med_imaging=recurring_services if recurring_services==9
	gen rs_transport=.
		replace rs_transport=recurring_services if recurring_services==10
	gen rs_unspecified=.
		replace rs_unspecified=recurring_services if recurring_services==11
	gen rs_na=.
		replace rs_na=recurring_services if recurring_services==12
		
	foreach i of varlist rs_commodity_distrib-rs_na {
	replace `i'=mean_cost if `i'!=.
	}

* Training
	gen training_sub=.
	label var training_sub "-------------------------------------------------"
	gen tr_na=.
		replace tr_na=training if training==1
	replace tr_na=mean_cost if tr_na!=.

* Environment
	gen environment_sub=.
	label var environment_sub "-------------------------------------------------"
	gen env_na=.
		replace env_na=environment if environment==1
	replace env_na=mean_cost if env_na!=.

* Subtotal
	gen subtotal_sub=.
	label var subtotal_sub "-------------------------------------------------"
	gen st_na=.
		replace st_na=subtotal if subtotal==1
	replace st_na=mean_cost if st_na!=.

* Total
	gen total_sub=.
	label var total_sub "-------------------------------------------------"

	gen t_full_costing=.
		replace t_full_costing=total if total==1
	gen t_partial_costing=.
		replace t_partial_costing=total if total==2
	gen t_na=.
		replace t_na=total if total==3
		
	foreach i of varlist t_full_costing-t_na {
	replace `i'=mean_cost if `i'!=.
	}
*/






*****START AGAIN AROUND ABOUT HERE













	** Now reshape dataset
**********************

*and reshape wide by cost within each subcategory 
drop if mean_cost==.

*reshape wide capital_costs-meancost2015, i(studyid) j(costrecord) s
*cant do this, intead have to collapse by siteid, and for broad categories need to collapse by sum, narrow categories should only have one observation per category for each siteid, so those will be fine, and the broad categories will be combined for each siteid as a sum. Also subtotals will equal totals (which could be confusing, so should drop subtotals as a broad category, and only have as subcategories)



/*
*First create globals
		*`broad'
		global broad capital_costs_1 facility_1 overhead_1 patient_costs_1 personnel_1 recurring_goods_1 recurring_goods_traded_1 recurring_goods_non_traded_1 recurring_services_1 training_1 environment_1 subtotal_1 total_1
		*'capital_costs'
		global capital_costs cc_admin_equipment cc_furnishings cc_lab_equipment cc_med_equipment cc_non_consumables cc_non_med_equipment cc_start_up cc_vehicles cc_unspecified cc_unspecified_equip cc_na

		*`facility'
		global facility fac_building-fac_utilities

		*`overhead'
		global overhead oh_off_site oh_onandoff_site oh_onoroff_site oh_unspecified oh_on_site oh_recurring_services oh_na

		*`patient_costs'
		global patient_costs pc_indirect_costs pc_lost_income pc_service_fee pc_travel_expenses pc_na

		*`personnel'
		global personnel p_administration p_counselors p_dir_serv_deliv p_management p_unspecified p_na

		*`recurring_goods'
		global recurring_goods rg_c_consumables rg_fuel rg_water rg_nc_consumables rg_pharmaceuticals rg_unspecified rg_na

		*`r_goods_traded'
		global r_goods_traded rgt_c_consumables rgt_nc_consumables rgt_pharmaceuticals rgt_u_consumables

		*`r_goods_ntraded'
		global r_goods_ntraded rgnt_advertising rgnt_med_consultation rgnt_recurring_services rgnt_research_tools rgnt_na

		*`recurring_services'
		global recurring_services rs_commodity_distrib rs_consultancy rs_demand_generation rs_equipment_maintenance rs_food_service rs_inpatient_service rs_lab_test rs_med_consult rs_med_imaging rs_transport rs_unspecified rs_na

		*`training'
		global training tr_na

		*`environment'
		global environment env_na

		*`subtotal'
		global subtotal st_na

		*`total'
		global total t_full_costing t_partial_costing t_na

		*`data_organization'
		global data_organization broad_categories sub_categories capital_costs_sub facility_sub overhead_sub pat_costs_sub personnel_sub recurring_goods_sub r_goods_traded_sub r_goods_ntraded_sub recurring_services_sub training_sub environment_sub subtotal_sub total_sub

		*Might want to do this for collapse depending on shape of data
		*sort substudyid

		
* Collapse and reshape wide manually
************************************
	drop cost_record-mean_cost
	collapse (sum) broad_categories-t_na, by(unit_cost) // this is WRONG!
			rename *_1 * 

			
			
*fix labels again :(
		label var broad_categories "  "
			replace broad_categories=.
		label var sub_categories "  "
			replace sub_categories=.
		label var capital_costs_sub "-------------------------------------------------"
			replace capital_costs_sub=.
		label var facility_sub "-------------------------------------------------"
			replace facility_sub=.
		label var overhead_sub "-------------------------------------------------"
			replace overhead_sub=.
		label var pat_costs_sub "-------------------------------------------------"
			replace pat_costs_sub=.
		label var personnel_sub "-------------------------------------------------"
			replace recurring_goods_sub=.
		label var recurring_goods_sub "-------------------------------------------------"
			replace personnel_sub=.
		label var r_goods_traded_sub "-------------------------------------------------"
			replace r_goods_traded_sub=.
		label var r_goods_ntraded_sub "-------------------------------------------------"
			replace r_goods_ntraded_sub=.
		label var recurring_services_sub "-------------------------------------------------"
			replace recurring_services_sub=.
		label var training_sub "-------------------------------------------------"
			replace training_sub=.
		label var environment_sub "-------------------------------------------------"
			replace environment_sub=.
		label var subtotal_sub "-------------------------------------------------"
			replace subtotal_sub=.
		label var total_sub "-------------------------------------------------"
			replace total_sub=.

		*Fix broad category names
*				(DO THIS LATER)
		*Re-apply the substudy level ID
		gen substudyid=substr(unit_cost,1,7)
		move substudyid unit_cost

* Now save as prep for indiv-level merge
	save temp_dta/cost_level_temp.dta,replace

	*/
	
			
* And load in study-level data
	clear
	import excel vmmc, firstrow sh("study_level")

	
	
	
* And make repairs and drop unneeded data

	drop extractor_initials-ref_author
	drop journal_etc-study_type

	*Fix years
	replace ref_year="." if ref_year=="No Year"
	destring ref_year, replace

*Fix countries (at study level)

*make a loop for all the variables
replace country = lower(country)

* Recode country variable
encode country, generate(country1) label(country)
move country1 country 
drop country
rename country1 country


stop


		* COMMAND 'STRPOS() > 0' MAY BE USEFUL FOR OTHER STRING VARIABLES:
/*		replace c_kenya=1 if strpos(country, "Kenya") > 0
		replace c_lesotho=1 if strpos(country, "Lesotho") > 0
		replace c_mozambique=1 if strpos(country, "Mozambique") > 0
		replace c_namibia=1 if strpos(country, "Namibia") > 0
		replace c_rwanda=1 if strpos(country, "Rwanda") > 0
		replace c_south_africa=1 if strpos(country, "South Africa") > 0
		replace c_swaziland=1 if strpos(country, "Swaziland") > 0
		replace c_tanzania=1 if strpos(country, "Tanzania") > 0
		replace c_uganda=1 if strpos(country, "Uganda") > 0
		replace c_zambia=1 if strpos(country, "Zambia") > 0
		replace c_zimbabwe=1 if strpos(country, "Zimbabwe") > 0

		*One location with multiple countries is an average of all the cost estimates from the countries later listed as individual sub-site areas, so we can drop this observation because its double counting

		*drop if c_multiple==1
*/
		

		
	

		
		* NEED TO FIX THIS 
/*		* Facility Category
		gen fac_cat=.
		replace fac_cat=1 if facility_cat=="CL01"
		replace fac_cat=2 if facility_cat=="CL02"
		replace fac_cat=3 if facility_cat=="CL03"
		replace fac_cat=4 if facility_cat=="CL04"
		replace fac_cat=5 if facility_cat=="UC01"
		replace fac_cat=6 if facility_cat=="HL01"
		replace fac_cat=7 if facility_cat=="HL02"
		replace fac_cat=8 if facility_cat=="HL03"
		replace fac_cat=9 if facility_cat=="HL04"
		replace fac_cat=10 if facility_cat=="MF01"
		replace fac_cat=11 if facility_cat=="NC01"
		replace fac_cat=99 if facility_cat=="NR"

		label define fac_cat 1 "Clinic - stand Alone (not part of larger fac)" 2 "Clinic -  integrated (part of parent facility like hosp)" 3 "Clinic - Mobile" 4 "Clinic - Intervention specific (ex. MMC only)" 5 "Unspecified clinical facility" 6 "Hospital - Primary" 7 "Hospital - Secondary" 8 "Hospital Tertiary" 9 "Hospital - unspecified level" 10 "Mixed Facility" 11 "Non-clinical facility" 99 "Facility type not reported"

		label values fac_cat fac_cat
		move fac_cat title
		drop facility_cat
		rename fac_cat facility_cat

*/


* Scale definition (number of clients served
		*Number of clients #1 served (and otherwise)
		replace scale1_num="." if scale1_num=="" // need to find this value
		replace scale1_num="." if scale1_num=="N/A" | scale1_num=="NR"
		destring scale1_num, replace

		*Number of clients #2 served (and otherwise)
		replace scale2_num="." if scale2_num=="" // need to find this value
		replace scale2_num="." if scale2_num=="N/A" | scale2_num=="NR"
		destring scale2_num, replace

		*Keep these at the end of the study level data file.
		move scale1_def title 
		move scale1_num title
		move scale2_def title
		move scale2_num title


* Scale timeframe unit of measurement
		gen scale_timeframe_unit1=.
		replace scale_timeframe_unit1=1 if scale_timeframe_unit=="weeks"
		replace  scale_timeframe_unit1=2 if scale_timeframe_unit=="month" |  scale_timeframe_unit== "months"
		replace scale_timeframe_unit1=3 if scale_timeframe_unit=="year" | scale_timeframe_unit=="year (per facility)"
		replace  scale_timeframe_unit1=99 if  scale_timeframe_unit=="N/A"

		label define time_frame 1 "weeks" 2 "months" 3 "years" 99 "N/A"
		label values scale_timeframe_unit1 time_frame
	
* Scale timeframe
		tab  scale_timeframe
		replace scale_timeframe="." if scale_timeframe=="N/A" | scale_timeframe=="NR"
		destring scale_timeframe,replace

* Create binaries for time frames
	tab scale_timeframe_unit1, gen(tf_)
	rename tf_1 weeks
	rename tf_2 months
	rename tf_3 years
	drop tf_4

	*Weeks
	replace weeks=scale_timeframe if weeks==1
	replace weeks=(scale_timeframe*4) if months==1
	replace weeks=(scale_timeframe*52) if years==1
	replace weeks=. if weeks==0
	
	*Months
	replace months=scale_timeframe if months==1
	replace months=(scale_timeframe*12) if years==1
	replace months=(scale_timeframe/4) if scale_timeframe_unit1==1
	replace months=. if months==0
	
	*Years
	replace years=scale_timeframe if years==1
	replace years=(scale_timeframe/12) if scale_timeframe_unit1==2
	replace years=(scale_timeframe/52) if scale_timeframe_unit1==1
	replace years=. if years==0
		
	*Move up front 
	move scale_timeframe title
	move scale_timeframe_unit1 title
	move weeks title
	move months title
	move years title




*Period Portrayed
	replace period_portrayed="." if period_portrayed=="N/A" | period_portrayed=="NR" | period_portrayed=="inferred"
	destring period_portrayed, replace
	move period_portrayed ownership


*Sample size and sample size units
* Again these are a mess and not standardized, perhaps this needs to be discussed.
		move sample_size title
		move sample_size_units title
	
STOP
*/

