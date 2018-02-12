**************************************************************************
**************************************************************************
**************************************************************************
** Do file for export of ART studies to the UCSR, using select variables
** Lily Alexander
** Univ of Washington 
** January 2018 
** lilyalexander18@gmail.com; lalexan1@uw.edu
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
	cd "C:/Users/Lily Alexander/Dropbox/ALL LIFE THINGS/INSP/Work with Sergio/GHCC/post_extraction_processing/ART"

		use ART_wide_file.dta

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
		
	* Note: what are we doing about the technology variables? Thought they were being divided up into treatment/prevention/diagnosis but ART only has one column. 
	gen id_tech_diag = "." 
	gen id_tech_treat = "." 
	gen id_tech_prevention = "." 
	
		*Intervention variables
		***********************
		label var ownership "Ownership"
		label var id_facility "Facility Category" // Variable for Platform below
		label var id_class "Intervention Class"
		label var id_type "Intervention Type"
		label var id_tech "Technology"
		label var id_tech_diag "Technology for diagnosis"
		label var id_tech_treat "Technology for treatment" 
		label var id_tech_prevention "Technology for prevention"
		label var id_phase "Phase"
		//label var id_details "Intervention Details"
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
			
			*Capitalize ownership 
			
			label define ownership_new 1 "In-country NGO" 2 "International NGO" 3 "Mixed" 4 "Private" 5 "Public" 999 "."
			label values ownership ownership_new 
			
			label define integrated 1 "Integrated" 2 "Mixed" 3 "Partially integrated" 
			label values int_services integrated
			
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
			order ownership id_facility platform id_class id_type id_modality disease id_tech id_tech_diag id_tech_treat id_tech_prevention id_phase int_description_long start_month start_year end_month end_year period_portrayed coverage int_services 
					order id unit_cost lead_author ref_author ref_year title journal_etc url

		* Geography
		label var country "Country"
		label var pop_density "Urbanicity"
		label var location "Location"	
			* I dont know what variable you're talking about here. How do we want to deal with this? Its a free text field.
			
********************
* Temporary fix for region variable
gen region= . 

decode country, gen(country_new)

replace region = 1 if regexm(country_new, "Brazil|Haiti|Mexico")
replace region = 2 if regexm(country_new, "Burkina Faso|Burundi|Cameroon|Ethiopia|Kenya|Lesotho|Malawi|Namibia|Nigeria|Rwanda|South Africa|Uganda|Zambia")
replace region = 3 if regexm(country_new, "China|Indonesia|Vietnam")
replace region = 4 if country_new == "Multiple"

drop country_new

label variable region "Region"
label define region 1 "LAC" 2 "SSA" 3 "Asia" 4 "Global"
label values region region
********************

		* Pop-density 
		
		label define density 1 "." 2 "Mixture" 3 "Peri-Urban" 4 "Rural" 5 "Urban"
		label values pop_density density 
			
			
			
			
			*Re-order starting here
			order country region pop_density location ss_unique_trait
					order ownership id_facility platform id_class id_type id_modality disease id_tech id_tech_diag id_tech_treat id_tech_prevention id_phase int_description_long start_month start_year end_month end_year period_portrayed coverage int_services 
					order id unit_cost lead_author ref_author ref_year title journal_etc url

		*Population
		rename id_pop id_pop_dem
		rename id_pop_std id_pop_dem_std
		label var id_pop_dem "Population"
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
		 
	
		foreach i of varlist id_pop_dem pop_age pop_ses pop_education hiv_prev cd4_range tb_prev {
			replace `i'="." if `i'=="NR"
			}
		
			* Re-order starting here
			order id_pop_dem_std pop_age pop_sex pop_ses pop_education pop_couples hiv_prev cd4_med cd4_range tb_prev tb_rx_resistance
					order country region pop_density location ss_unique_trait
					order ownership id_facility platform id_class id_type id_modality disease id_tech_diag id_tech_treat id_tech_prevention id_phase int_description_long start_month start_year end_month end_year period_portrayed coverage int_services 
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
		
	
	* Include population (to dummy out infants)
		gen neonates=.
		replace neonates=1 if id_pop_dem=="neonates" | id_pop_dem=="newborns" | id_pop_dem=="infant males at risk of HIV"
		replace neonates=0 if neonates==.
			* tab neonates
			* sum mean_cost if neonates==1,d
			* sum mean_cost if neonates==0,d
			label variable neonates "Target group (demographic)"
			label define neonates 0 "Adults and/or Adolescents" 1 "Neonates and/or Infants"
			label values neonates neonates
	
	foreach var in start_month end_month start_year end_year{ 
		_strip_labels `var' 
		tostring `var', replace
		replace `var' = "Open" if `var' == "88" 
		replace `var' = "Mixed" if `var' == "99"
	}
	
	*Need to replace all missing values in categoricals with 999 so we can label them "."
	foreach i of varlist ownership platform id_class id_type id_modality disease id_tech id_phase int_services country region pop_density pop_sex costing_purpose_cat timing country_sampling geo_sampling_incountry site_sampling px_sampling sample_size_derived controls econ_perspective_report econ_perspective_actual econ_costing real_world asd_costs research_costs unrelated_costs overhead volunteer_time family_time iso_code currency_x pop_couples cd4_med tb_rx sensitivity_analysis {
			
			decode `i', gen(`i'_new) 
			drop `i' 
			rename `i'_new `i'
		
			
			replace `i' = "." if `i' == "999" 
			replace `i' = "." if `i' == "N/A" 
			replace `i' = "." if `i' == "NR"
			replace `i' = "." if `i' == " "
			replace `i' = "." if `i' == ""
			}
	

	*Need to do same with string variables
	tostring ref_author, replace
	tostring url, replace
	tostring id_pop_dem_std, replace
	foreach i of varlist id unit_cost lead_author ref_author title journal_etc url ownership id_facility platform id_class id_modality int_description_long location ss_unique_trait id_pop_dem_std pop_age pop_ses pop_education hiv_prev cd4_range tb_prev list_asd_costs overhead_costs uncertainty_rmk tb_prev {
		replace `i'="." if `i'==""
		replace `i'="." if `i'=="N/A"
		}
		
		

			* re-order starting here
			order costing_purpose_cat timing country_sampling geo_sampling_incountry site_sampling px_sampling sample_size_derived controls
					order id_pop_dem_std pop_age pop_sex pop_ses pop_education pop_couples hiv_prev cd4_med cd4_range tb_prev tb_rx_resistance
					order country region pop_density location ss_unique_trait
					order ownership id_facility platform id_class id_type id_modality disease id_tech id_tech_diag id_tech_treat id_tech_prevention id_phase int_description_long start_month start_year end_month end_year period_portrayed coverage int_services 
					order id unit_cost lead_author ref_author ref_year title journal_etc url	
	
		
			label variable id_pop_dem_std "Population served"
			
	
		
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
		label var omitted_costs "Author-reported Omitted Costs"
		label var volunteer_time "Valuing Volunteer Time"
		label var family_time "Valuing Family Time"
		label var currency_yr "Reported Currency Year"
		label var iso_code "Reported Currency"
		label var currency_x "Currency Exchange Method"
		label var current_x_rate "Currency Exchange Rate"
		label var discount_rate "Discount Rate"
		label var sensitivity_analysis "Sensitivity Analysis"
		label var uncertainty_rmk "Uncertainty Remarks"
			
		* Discount rate 
		replace discount_rate = "0" if discount_rate == "none"
		replace discount_rate = "." if discount_rate == " " | discount_rate =="N/A"
		destring discount_rate, replace
		
		
		* not sure if the "costing Frame" variable you mention is omitted_costs
		* when you say you want "sensitivity remarks" do you mean uncertainty remarks?
				* If so, a free text field of this size wont translate with Stata
		
		* Omitted costs variable in the extraction spreadsheet includes both explicitly and inferred omitted so for UCSR include just "author-reported" omissions 
		replace omitted_costs = "" if omitted_costs_rs != 1 // "1" is when the authors state the omissions explicitly
	
		*Generate variables that are missing so that all columns are accounted for 
		gen a_anc_demand_generation = . 
		gen a_prisd_circumcision_proced = . 
		gen a_secsd_hct = . 
		
		gen si_cap_medical_equip = . 
		gen si_cap_nonmed_equip = . 
		
		
		* Order variables thusly:
		order mean_cost si_capital si_mixed si_personnel si_recurrent si_cap_medical_equip si_cap_nonmed_equip si_cap_other si_mix_mixed si_per_mixed_unspec si_per_service_delivery si_per_support si_rec_building_space si_rec_med_int_supplies si_rec_nonmed_int_supplies a_ancillary a_mixed a_operational a_primary_sd a_secondary_sd a_anc_demand_generation a_anc_lab_services a_anc_unspecified a_mix_mixed a_ope_bldg_equip a_ope_logistics a_ope_program_mgmt a_ope_supervision a_ope_training a_ope_transportation a_ope_unspecified a_prisd_circumcision_proced a_prisd_unspecified a_secsd_hct
		order econ_perspective_actual econ_costing real_world asd_costs list_asd_costs research_costs unrelated_costs overhead overhead_costs omitted_costs volunteer_time family_time currency_yr iso_code currency_x current_x_rate discount_rate sensitivity_analysis uncertainty_rmk
					order costing_purpose_cat timing country_sampling geo_sampling_incountry site_sampling px_sampling sample_size_derived controls
					order id_pop_dem_std pop_age pop_sex pop_ses pop_education pop_couples hiv_prev cd4_med cd4_range tb_prev tb_rx_resistance
					order country region pop_density neonates location ss_unique_trait
					order ownership id_facility platform id_class id_type id_modality disease id_tech id_tech_diag id_tech_treat id_tech_prevention id_phase int_description_long start_month start_year end_month end_year period_portrayed coverage int_services 
					order id unit_cost lead_author ref_author ref_year title journal_etc url

			
		* Finally, relabel the cost categories
		* (and dont forget to replace the order commands back down below)
			
		*Now, keep only these variables and costs
		keep id-a_secsd_hct

		
		
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
		gen collapsed= "No" 
		* Need to create an id without (a) for grouping collapse
		gen study=substr(id, 1, length(id)-1)
		
				label variable study "Study"
				label variable collapsed "Collapsed"
				
		
		*Create a Flags variable 
					gen Flags="."
		
		order study collapsed Flags id
		
			
save ART_clean_wide_file.dta, replace

* Finally, export to excel
**************************
export excel study-a_secsd_hct using ART_clean_wide_file.xlsx, first(varl) missing(".") replace       



