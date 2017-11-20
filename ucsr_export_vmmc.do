**************************************************************************
**************************************************************************
**************************************************************************
** Do file for export of VMMC studies to the UCSR, using select variables
** Drew Cameron
** UC Berkeley
** September / October 2017
** drew.cameron@berkeley.edu
**************************************************************************
**************************************************************************
**************************************************************************

** Data requirements
**
**  Must use data already formatted into wide file for GHCC analysis
** 		- These are available upon request
**		- Procedure to be replicated for other intervention areas (ART, etc)
**		- As well as other diseases (TB)
**************************************************************************

set more off 
	clear
	cd "/Users/dcameron03/Documents/Berkeley/`GSI with Jim/Stata/GHCC/"
		use final_dta/wide_file.dta

**************************************************************************		
** First, export of whole raw data before compression / aggregation
**************************************************************************
** Begin by selecting key variables for export

		* Identifiers
		label var id "ID Variable"
		label var unit_cost "Unit Cost ID"
		
		*Bibliographic variables
		************************
		label var lead_author "Lead Author"
		label var ref_author "Reference Authors"
		label var ref_year "Reference Year"
		label var title "Title"
		label var journal_etc "Journal"
		label var url "URL"

		* Case issues - settled in excel, but could do something here too.
			*Sentence case
				* Clean up title to sentence case
				* foreach i of varlist  {
				*	replace `i'=substr(`i', 1, 1)+ lower(substr(`i', 2, .))
				*	}
					
				*Proper case
				*foreach i of varlist id_tech id_modality int_services {
				*	replace `i'=strproper(`i')
				*	}
				
				*Upper case
				*foreach i of varlist disease id_phase {
				*	replace `i'=upper(`i')
				*	}
					
					
	** Note for Willyanne, there is a character limit in Stata, so title and journal may need to be fixed manually
			*Reorder starting here
			order id unit_cost lead_author ref_author ref_year title journal_etc url
		
		*Intervention variables
		***********************
		label var ownership "Ownership"
		label var id_facility "Facility Category" // Variable for Platform below
		label var id_class "Intervention Class"
		label var id_type "Intervention Type"
		label var id_tech "Technology"
		label var id_phase "Phase"
		label var id_details "Intervention Details"
		label var id_modality "Delivery Modality"
		label var int_description_long "Intervention Description (Long)"
		label var start_month "Start Month"
		label var start_year "Start Year"
		label var end_month "End Month"
		label var end_year "End Year"
		label var period_portrayed "Total Months"
		*label var year_intro "Year Introduced at Study Site"
		label var coverage "Coverage"
		label var int_services "Integrated Services"
		label var disease "Disease"
		
			* Generate a higher-level platform variable
			gen platform=.
				replace platform=1 if id_facility=="HC01" | id_facility=="HC02" | id_facility=="HC03" | id_facility=="HC04" | id_facility=="HC05" |  id_facility=="HC06" |  id_facility=="HC07" | id_facility=="HC08" | id_facility=="HC09" | id_facility=="HC10" | id_facility=="HC11"
				replace platform=2 if id_facility=="OR01" | id_facility=="OR02" |  id_facility=="OR03" |  id_facility=="OR04" |  id_facility=="OR05"
				replace platform=3 if id_facility=="CB01" | id_facility=="CB02" | id_facility=="CB03" | id_facility=="CB04"
				replace platform=4 if id_facility=="PW01"
				replace platform=5 if id_facility=="OT01" |id_facility=="OT02"
			label variable platform "Platform"
			label define platform 1 "Fixed facility" 2 "Outreach" 3 "Community based" 4 "Population wide" 5 "Other"
			label values platform platform

	
			
			* Fix disease and capitalization
			label define disease1 1 "HIV"
			label values disease disease1
		
	** Note to willyanne: Intervention details needs to be standardized and broken into categories
			** Right now you'll lose all this info in the stata transfer.
	** We will also not be able to retain "intervention description long" in stata
	** Which field do you want in "health system level" comment? Long one wont copy over.
	** Also unclear whether you want integrated services variable or health system level remarks variable, or both.
		
			*Re-order starting here
			order ownership id_facility platform id_class id_type id_modality disease id_tech id_phase id_details int_description_long start_month start_year end_month end_year period_portrayed coverage int_services 
					order id unit_cost lead_author ref_author ref_year title journal_etc url

		* Geography
		label var country "Country"
		label var pop_density "Urbanicity"
		label var location "Location"	
			* I dont know what variable you're talking about here. How do we want to deal with this? Its a free text field.
			
********************
* Temporary fix for region variable
gen region=1
label variable region "Region"
label define region 1 "Africa"
label values region region
********************
			
			
			
			
			*Re-order starting here
			order country region pop_density location
					order ownership id_facility platform id_class id_type id_modality disease id_tech id_phase id_details int_description_long start_month start_year end_month end_year period_portrayed coverage int_services 
					order id unit_cost lead_author ref_author ref_year title journal_etc url

		*Population
		label var id_pop "Population"
		label var pop_age "Average Age"
		label var pop_sex "Gender"
		label var pop_ses "SES"
		label var pop_education "Education"
		label var pop_couples "Couples"
		label var hiv_prev "HIV Prevalence"
		label var cd4_med "Median CD4 Count"
		label var cd4_range "CD4 Range"
		label var tb_prev "TB Prevalence"
		label var tb_rx_resistance "TB Drug Resistance"
		 
		foreach i of varlist id_pop pop_age pop_ses pop_education hiv_prev cd4_range tb_prev {
			replace `i'="." if `i'=="NR"
			}
		
			* Re-order starting here
			order id_pop_std pop_age pop_sex pop_ses pop_education pop_couples hiv_prev cd4_med cd4_range tb_prev tb_rx_resistance
					order country region pop_density location
					order ownership id_facility platform id_class id_type id_modality disease id_tech id_phase id_details int_description_long start_month start_year end_month end_year period_portrayed coverage int_services 
					order id unit_cost lead_author ref_author ref_year title journal_etc url
		
		* Study Design
		label var costing_purpose_cat "Costing Purpose"
		label var timing "Timing"
		*label var seasonality "Seasonality"
		label var country_sampling "Country Sampling"
		label var geo_sampling_incountry "Geographic Area In Country Sampling"
		label var site_sampling "Site Sampling"
		label var px_sampling "Patient Sampling"
		label var sample_size_derived "Sample size formally derived"
		label var controls "Controls"
		label var ss_unique_trait "Unique Trait"
	
	*Need to replace all missing values in categoricals with 999 so we can label them "."
	foreach i of varlist ownership platform id_class id_type id_modality disease id_tech id_phase int_services country region pop_density pop_sex costing_purpose_cat timing country_sampling geo_sampling_incountry site_sampling px_sampling sample_size_derived controls econ_perspective_report econ_perspective_actual econ_costing real_world asd_costs research_costs unrelated_costs overhead volunteer_time family_time iso_code currency_x {
			replace `i'=999 if `i'==.
			label define `i' 999 ".", add
			}
	
	*Need to do same with string variables
	foreach i of varlist id unit_cost lead_author ref_author title journal_etc url id_facility id_details int_description_long location ss_unique_trait id_pop_std pop_age pop_ses pop_education hiv_prev cd4_range tb_prev list_asd_costs overhead_costs uncertainty_rmk {
		replace `i'="." if `i'==""
		}
	
			* re-order starting here
			order costing_purpose_cat timing country_sampling geo_sampling_incountry site_sampling px_sampling sample_size_derived controls
					order id_pop_std pop_age pop_sex pop_ses pop_education pop_couples hiv_prev cd4_med cd4_range tb_prev tb_rx_resistance
					order country region pop_density location
					order ownership id_facility platform id_class id_type id_modality disease id_tech id_phase id_details int_description_long start_month start_year end_month end_year period_portrayed coverage int_services 
					order id unit_cost lead_author ref_author ref_year title journal_etc url	
		
		* Include population (to dummy out infants)
		gen neonates=.
		replace neonates=1 if id_pop=="neonates" | id_pop=="newborns" | id_pop=="infant males at risk of HIV"
		replace neonates=0 if neonates==.
			* tab neonates
			* sum mean_cost if neonates==1,d
			* sum mean_cost if neonates==0,d
			label variable neonates "Target group (demographic)"
			label define neonates 0 "Adults and/or Adolescents" 1 "Neonates and/or Infants"
			label values neonates neonates
		
			label variable id_pop_std "Population served"
			
	
		
		* Costing methods
		label var econ_perspective_actual "Perspective"
		label var econ_costing "Economic / Financial"
		label var real_world "Real World / Per Protocol"
		*label var omitted_costs "Costing Frame"
		label var asd_costs "Above Service Costs Included"
		label var list_asd_costs "Above Service Cost List"
		label var research_costs "Research Costs Included"
		label var unrelated_costs "Unrelated Costs Included"
		label var overhead "Overhead Costs Included"
		label var overhead_costs "Overhead Costs List"
		label var volunteer_time "Valuing Volunteer Time"
		label var family_time "Valuing Family Time"
		label var currency_yr "Reported Currency Year"
		label var iso_code "Reported Currency"
		label var currency_x "Currency Exchange Method"
		label var current_x_rate "Currency Exchange Rate"
		label var discount_rate "Discount Rate"
		label var sensitivity_analysis "Sensitivity Analysis"
		label var uncertainty_rmk "Uncertainty Remarks"
		
		* not sure if the "costing Frame" variable you mention is omitted_costs
		* when you say you want "sensitivity remarks" do you mean uncertainty remarks?
				* If so, a free text field of this size wont translate with Stata
				
		* Order variables thusly:
		order mean_cost si_capital si_mixed si_personnel si_recurrent si_cap_medical_equip si_cap_nonmed_equip si_cap_other si_mix_mixed si_per_mixed_unspec si_per_service_delivery si_per_support si_rec_building_space si_rec_med_int_supplies si_rec_nonmed_int_supplies a_ancillary a_mixed a_operational a_primary_sd a_secondary_sd a_anc_demand_generation a_anc_lab_services a_anc_unspecified a_mix_mixed a_ope_bldg_equip a_ope_logistics a_ope_program_mgmt a_ope_supervision a_ope_training a_ope_transportation a_ope_unspecified a_prisd_circumcision_proced a_prisd_unspecified a_secsd_hct
		order econ_perspective_actual econ_costing real_world asd_costs list_asd_costs research_costs unrelated_costs overhead overhead_costs volunteer_time family_time currency_yr iso_code currency_x current_x_rate discount_rate sensitivity_analysis uncertainty_rmk
					order costing_purpose_cat timing country_sampling geo_sampling_incountry site_sampling px_sampling sample_size_derived controls
					order id_pop_std pop_age pop_sex pop_ses pop_education pop_couples hiv_prev cd4_med cd4_range tb_prev tb_rx_resistance
					order country region pop_density neonates location ss_unique_trait
					order ownership id_facility platform id_class id_type id_modality disease id_tech id_phase id_details int_description_long start_month start_year end_month end_year period_portrayed coverage int_services 
					order id unit_cost lead_author ref_author ref_year title journal_etc url

			
		* Finally, relabel the cost categories
		* (and dont forget to replace the order commands back down below)
			
		*Now, keep only these variables and costs
		keep id-a_secsd_hct

		
		
		** AND remove some studies because they're modeled
				*modeled and mislabeled
				drop if id=="hiv028c"
				drop if id=="hiv035c"
				
				*modeled and labeled properly
				drop if unit_cost=="hiv034a_ii"
				drop if unit_cost=="hiv034b_ii"
				drop if unit_cost=="hiv034c_ii"
				drop if unit_cost=="hiv034d_ii"
				drop if unit_cost=="hiv034e_ii"
				drop if unit_cost=="hiv034f_ii"
				drop if unit_cost=="hiv034g_ii"
				drop if unit_cost=="hiv035a_ii"
				drop if unit_cost=="hiv035a_iii"
				drop if unit_cost=="hiv035b_ii"
				drop if unit_cost=="hiv035b_iii"
					*Need to figure out how to automate this, or remove before they arrive.
		
		* Label remaining confusing variables
		label var mean_cost	"Mean Unit Cost"
		label var si_capital "Capital (SI)"
		label var si_mixed "Mixed (SI)"
		label var si_personnel "Personnel (SI)"
		label var si_recurrent "Recurrent Goods (SI)"
		label var si_cap_medical_equip "Capital: Equipment (medical) (SI)"
		label var si_cap_nonmed_equip "Capital: Equipment (non-medical) (SI)"
		label var si_cap_other "Capital: Other capital (SI)"
		label var si_mix_mixed "Mixed: Mixed (SI)"
		label var si_per_mixed_unspec "Personnel: Direct Service Delivery (SI)"
		label var si_per_service_delivery "Personnel: Support (SI)"
		label var si_per_support "Personnel: Mixed Unspecified (SI)"
		label var si_rec_building_space "Recurring: Building Space (SI)"
		label var si_rec_med_int_supplies "Recurring: Medical Supplies (excluding drugs) (SI)"
		label var si_rec_nonmed_int_supplies "Recurring: Non-medical Supplies (SI)"
		label var a_ancillary "Ancillary (A)"
		label var a_mixed "Mixed (A)"
		label var a_operational "Operational (A)"
		label var a_primary_sd "Primary Service Delivery (A)"
		label var a_secondary_sd "Secondary Service Delivery (A)"
		label var a_anc_demand_generation "Ancillary: Demand Generation (A)"
		label var a_anc_lab_services "Anicllary: Lab Services (A)"
		label var a_anc_unspecified "Ancillary: Unspecified (A)"
		label var a_mix_mixed "Ancillary: Mixed (A)"
		label var a_ope_bldg_equip "Operational: Buildings and Equipment (A)"
		label var a_ope_logistics "Operational: Logistics (A)"
		label var a_ope_program_mgmt "Operational: Program Management (A)"
		label var a_ope_supervision "Operational: Supervision (A)"
		label var a_ope_training "Operational: Training (A)"
		label var a_ope_transportation "Operational: Transportation (A)"
		label var a_ope_unspecified "Operational: Unspecified (A)"
		label var a_prisd_circumcision_proced "Primary SD: Circumcision Procedure (A)"
		label var a_prisd_unspecified "Primary SD: Unspecified (A)"
		label var a_secsd_hct "Secondary SD: HIV Counseling and Testing (A)"
		
		
	* And for the collapse: 
		*Generate a variable to tell collapsed costs from full costs
		gen collapsed=0
		* Need to create an id without (a) for grouping collapse
		gen study=substr(id, 1, length(id)-1)
		
				label variable study "Study"
				label variable collapsed "Collapsed"
				
				label define collapsed 0 "No" 1 "Yes"
				label values collapsed collapsed
		
		*Create a caveats variable 
					gen caveats="."
		
		order study collapsed caveats ss_unique_trait id
		
			
		
save final_dta/UCSR_export_full.dta, replace

* Finally, export to excel
**************************
export excel study-a_secsd_hct using UCSR_exports/UCSR_export_full.xlsx, first(varl) missing(".") replace       


**************************************************************************
** Aggregation tests for Jim and Willyanne
**************************************************************************

					*First get rid of regional costs that belong in a country-wide average
					drop if id=="hiv053b"
					drop if id=="hiv053c"
					drop if id=="hiv053d"
					drop if id=="hiv053e"
					drop if id=="hiv053f"
					drop if id=="hiv053g"
					drop if id=="hiv053h"
					drop if id=="hiv053i"
	
					* And same but backwards (facility costs but NOT country average) for the hiv032 study
					drop if id=="hiv032a"
	
					* and remove modeled costs: 
					drop if id=="hiv021c"

					*And drop regional cost estimates in favor of the two country-wide estimates in hiv025
					drop if id=="hiv025a"
					drop if id=="hiv025b"
					drop if id=="hiv025c"
					drop if id=="hiv025e"
					drop if id=="hiv025f"
					drop if id=="hiv025h"
					

		
*******************************		
		*** THIS IS FOR TESTING
				** NEED TO ADD A MOBILE, FIXED, OUTREACH variable
				* By pop_density, ownership, id_modality (PREFERRED AGGREGATION CODE)
					* order study pop_density ownership id_modality platform neonates country id_facility mean_cost id ss_unique_trait 
						//so you can see whats going on
					* collapse mean_cost, by (study pop_density ownership id_modality platform neonates country)
*******************************				
				
				
				
		*** THIS IS WHAT THE ACTUAL COLLAPSE CODE WILL BE: 

				* First order all the numeric and cost vars that will be collapsed: 
				*order mean_cost si_capital si_mixed si_personnel si_recurrent si_cap_medical_equip si_cap_nonmed_equip si_cap_other si_mix_mixed si_per_mixed_unspec si_per_service_delivery si_per_support si_rec_building_space si_rec_med_int_supplies si_rec_nonmed_int_supplies a_ancillary a_mixed a_operational a_primary_sd a_secondary_sd a_anc_demand_generation a_anc_lab_services a_anc_unspecified a_mix_mixed a_ope_bldg_equip a_ope_logistics a_ope_program_mgmt a_ope_supervision a_ope_training a_ope_transportation a_ope_unspecified a_prisd_circumcision_proced a_prisd_unspecified a_secsd_hct
				
codebook id_class id_type disease id_phase region timing country_sampling geo_sampling_incountry site_sampling px_sampling sample_size_derived controls econ_perspective_actual econ_costing real_world asd_costs research_costs unrelated_costs overhead volunteer_time family_time currency_x current_x_rate discount_rate sensitivity_analysis

				* Then run the collapse, 
				collapse mean_cost-a_secsd_hct ref_year int_services start_month-coverage currency_yr id_class id_type disease id_phase region timing country_sampling geo_sampling_incountry site_sampling px_sampling sample_size_derived controls econ_perspective_actual econ_costing real_world asd_costs research_costs unrelated_costs overhead volunteer_time family_time currency_x current_x_rate discount_rate sensitivity_analysis, by (study pop_density ownership id_modality platform neonates country)
					gen collapsed=1
	
	
				* Then save the file 
				save final_dta/UCSR_export_temp.dta, replace
	
				* Close and append collapse file to full dataset
				clear
				use final_dta/UCSR_export_full.dta
		STOOP		
				append using final_dta/UCSR_export_temp.dta
				sort collapsed study id
					label variable study "Study"
					label variable collapsed "Collapsed"
					
					*And eliminate duplicate studies that didn't collapse
					gen original=.
					replace original=1 if collapsed==0
					replace original=0 if collapsed==1
					
					egen orig=total(original), by(study)
					egen coll=total(collapsed), by(study)
					
					*get rid of studies that didn't collapse
					drop if collapsed==1 & orig==coll
						drop original orig coll
						
						
						label values collapsed collapsed
					
					* edit caveats variable
					replace caveats="Unit cost is an aggregate of..." if collapsed==1
					
					*Apparently have to re-order yet again...
					order study collapsed id
					sort study id collapsed
					
			*Get rid of the neonates variable here: 
					drop neonates
					
			*Have to re-drop the values that needed to be dropped to do the aggregation to avoid confusion:
				*First get rid of regional costs that belong in a country-wide average
					drop if id=="hiv053b"
					drop if id=="hiv053c"
					drop if id=="hiv053d"
					drop if id=="hiv053e"
					drop if id=="hiv053f"
					drop if id=="hiv053g"
					drop if id=="hiv053h"
					drop if id=="hiv053i"
	
				* And same but backwards (facility costs but NOT country average) for the hiv032 study
					drop if id=="hiv032a"
	
				* and remove modeled costs: 
					drop if id=="hiv021c"

				*And drop regional cost estimates in favor of the two country-wide estimates in hiv025
					drop if id=="hiv025a"
					drop if id=="hiv025b"
					drop if id=="hiv025c"
					drop if id=="hiv025e"
					drop if id=="hiv025f"
					drop if id=="hiv025h"
					
				
					
					
				*And save this for editing into final collapsed dataset
				save final_dta/UCSR_export_collapsed.dta, replace
				export excel study-a_secsd_hct using UCSR_exports/UCSR_export_collapsed.xlsx, first(varl) missing(".") replace   
				
				STOP
				
				*Now the only way to proceed is to manually remove duplicates (procedure best run manually in excel)
				
				
				
				
				
	
				* And remove duplcate studies
	
	
*1. Collapse cost variables into new dataset
			* First need to create a dataset of non-numerics for each study to merge with the collapsed data
		
			
			* First, we should select 1 line from the study characteristics to stay constant
		* Then save this as an extra dataset to plug into. 
				/*
		
			keep id study ref_author-uncertainty_rmk
				bysort study: gen counter=_n
				move counter ref_author
				
				foreach i of varlist ref_year-uncertainty_rmk {
					bysort study: tab(`i'), gen(v_)
					}
					bysort study: replace `i'="mixed" if v_1!=v_*
	
	
				save temp_dta/costs_temp.dta,replace
					clear
					use temp_dta/costs.dta
				
				STOP
	
	
	}
		*/
	

