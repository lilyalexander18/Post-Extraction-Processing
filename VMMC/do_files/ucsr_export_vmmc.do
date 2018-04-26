<<<<<<< HEAD:VMMC/do_files/ucsr_export_vmmc.do
**************************************************************************
**************************************************************************
**************************************************************************
** Do file for export of VMMC studies to the UCSR, using select variables
** Lily Alexander
** University of Washington
** February 2018 
** lilyalexander18@gmail.com
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
	*Drew's Path:
	//cd "/Users/dcameron03/Documents/GitHub/Post-Extraction-Processing/VMMC/"
	//use VMMC_wide_file.dta, replace	
	*Lily's Path:
	* cd "C:/Users/Lily Alexander/Dropbox/ALL LIFE THINGS/INSP/Work with Sergio/GHCC/Post-Extraction-Processing/VMMC"
	* 	use VMMC_wide_file_Feb2018.dta
	*Lily's temporary path: 
	cd "/Users/lilyalexander/Dropbox/ALL LIFE THINGS/INSP/Work with Sergio/GHCC/Post-Extraction-Processing/VMMC/wide_files"
	use VMMC_wide_file_Apr2018.dta, replace


**********************************		
** Cross-validation of costs **
**********************************
	
	* 1. Check that broad standard input categories sum to mean cost 
	****************************************************************
	egen check = rowtotal(si_recurrent si_personnel si_capital si_mixed)
	replace check = si_combined if check == 0
	gen diff = check - mean_cost
	gen flag = 1 if diff > 1
	
	count if flag == 1
	di in red `r(N)'
	
	drop diff check flag 

	
	* 2. Check that narrow standard input categories sum to broad categories
	************************************************************************
	
	local prefix "rec per mix cap" 
		
	preserve 
	
	foreach var of local prefix { 
		egen sum_`var' = rowtotal(si_`var'_*)
		drop si_`var'_*
		gen diff_`var' = sum_`var' - si_`var'
		gen flag_`var' = 1 if diff_`var' > 0.05 & diff_`var' !=. 
	
	}
	restore
	
	* 3. Check that broad activity categories sum to mean cost 
	**********************************************************
	
	egen check = rowtotal(a_primary_sd a_secondary_sd a_ancillary a_operational a_mixed)
	gen diff = check - mean_cost
	gen flag = 1 if diff > 0.1
	
	count if flag == 1 
	di in red `r(N)' 
	
	drop diff check flag 
	
	* 4. Check that narrow activity categories sum to broad categories
	******************************************************************
	
	local prefix "prisd secsd anc mix ope" 
	
	//preserve 
	
	foreach var of local prefix { 
		egen sum_`var' = rowtotal(a_`var'_*) 
		
	}
	
	gen diff_prisd = sum_prisd - a_primary_sd 
	gen flag_prisd = 1 if diff_prisd > 0.05 & diff_prisd != . 
	
	gen diff_secsd = sum_secsd - a_secondary_sd 
	gen flag_secsd = 1 if diff_secsd > 0.05 & diff_secsd != . 
	
	gen diff_anc = sum_anc - a_ancillary
	gen flag_anc = 1 if diff_anc > 0.05 & diff_anc != . 
	
	gen diff_ope = sum_ope - a_operational 
	gen flag_ope = 1 if diff_ope > 0.05 & diff_ope != . 
	
	gen diff_mix = sum_mix - a_mixed 
	gen flag_mix = 1 if diff_mix > 0.05 & diff_mix != . 
	

**************************************************************************		
** First, export of whole raw data before compression / aggregation
**************************************************************************
** Begin by selecting key variables for export
		
		label var disease "Disease" 
		label var output_unit2 "Output unit"
		
		* Identifiers
		**************
		label var id "ID Variable"
		label var unit_cost "Unit Cost ID"
		
		*Bibliographic variables
		************************
		label var lead_author "Lead Author"
		label var ref_year "Reference Year"
		label var title "Title"
		label var journal_etc "Journal"
		label var url "URL"

		* Geography
		************
		label var iso_name "Country"
		label var pop_density "Urbanicity"
		label var location "Location"	
		label var no_sites "Sites"
		
		*Intervention variables
		***********************
		label var ownership "Ownership"
		
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
			
		label var facility_cat "Platform specificity" 
		label var id_class "Intervention Category"
		label var id_type "Intervention Type"
		label var id_int "Intervention"		
		label var int_description_long "Intervention Description (Long)"
		label var id_modality "Modality"
		label var id_phase "Phase"
		label var clinical_monitoring "Clinical monitoring" 
		label var demand_generation "Demand generation" 
		label var counseling_content "Counseling content"
		label var staff_type "Staff type & number"
		label var supportive_care "Supportive care"
		label var visits "Visit type & number"
		label var referrals "Referrals"
		label var method "Method"
		label var id_tech "Technology"
		label var treatment_phase "Treatment phase"
		label var arv_regimen "ARV Regimen" 
		label var treatment "Treatment" 
		label var screening_diagnoses "Screening and diagnosis"
		label var community_awareness "Community awareness"
		label var software_electronics "Software and electronics system"
		label var id_activities "Costed activities"
		
		label var start_month "Start Month"
		label var start_year "Start Year"
		label var end_month "End Month"
		label var end_year "End Year"
		label var period_portrayed "Total Months"
		label var year_intro "Year introduced at study site"
		label var coverage "Coverage"
		

		*Population
		************
		label var id_pop_dem_std "Target group (demographic)"
		label var id_pop_clin_std "Target group (clinical)"
		label var pop_age "Average Age"
		label var pop_sex "Gender"
		label var pop_ses "SES"
		label var pop_education "Education"
		label var hiv_prev "HIV Prevalence"
		label var tb_prev "TB Prevalence"
		label var tb_rx_resistance "TB Drug Resistance"
		 
		replace pop_age = subinstr(pop_age, "years", "", .)
		
		* Study Design
		***************
		label var costing_purpose "Costing Purpose"
		label var timing "Timing"
		label var country_sampling "Country Sampling"
		label var geo_sampling_incountry "Geographic Area In Country Sampling"
		label var site_sampling "Site Sampling"
		label var px_sampling "Patient Sampling"
		label var sample_size_derived "Sample size formally derived"
		label var controls "Controls"
	
	/*
	*Need to replace all missing values in categoricals with 999 so we can label them "."
	foreach i of varlist ownership platform id_class id_type id_modality disease id_tech id_phase int_services country region pop_density pop_sex costing_purpose_cat timing country_sampling geo_sampling_incountry site_sampling px_sampling sample_size_derived controls econ_perspective_report econ_perspective_actual econ_costing real_world asd_costs research_costs unrelated_costs overhead volunteer_time family_time iso_code currency_x {
			replace `i'=999 if `i'==.
			label define `i' 999 ".", add
			}
	
	*Need to do same with string variables
	foreach i of varlist id unit_cost lead_author ref_author title journal_etc url id_facility id_details int_description_long location ss_unique_trait id_pop_std pop_age pop_ses pop_education hiv_prev cd4_range tb_prev list_asd_costs overhead_costs uncertainty_rmk {
		replace `i'="." if `i'==""
		}
	*/
	
		* Costing methods
		*******************
		label var econ_perspective_actual "Perspective"
		label var econ_costing "Economic / Financial"
		label var real_world "Real World / Per Protocol"
		label var asd_costs "Above Service Costs Included"
		label var list_asd_costs "Above Service Cost List"
		label var omitted_costs "Omitted Costs"
		label var sensitivity_analysis "Sensitivity Analysis"
		label var scale "Economies of scale"
		
		label var research_costs "Research Costs Included"
		label var unrelated_costs "Unrelated Costs Included"
		label var overhead "Overhead Costs Included"
		label var overhead_costs "Overhead Costs List"
		label var pot_distortions "Potential distortions"
		
		label var volunteer_time "Valuing Volunteer Time"
		label var family_time "Valuing Family Time"
		label var px_costs_measured "Patient-Incurred Costs Measured"
		label var cat_cost "Catastrophic Cost Calculated"
		
		label var currency_yr "Reported Currency Year"
		label var iso_code "Reported Currency"
		label var currency_iso "Currency of Data Collection"
		label var currency_x "Currency Exchange Method"
		label var current_x_rate "Currency Exchange Rate"
		label var discount_rate "Discount Rate"
		label var inflation "Inflation rate"
		
			
		* Finally, relabel the cost categories
		***************************************
		
		* Label remaining confusing variables
		label var mean_cost	"Mean Unit Cost"
		
		// Personnel
		label var si_personnel "Personnel (SI)"
		label var si_per_service_delivery "Personnel: Direct Service Delivery (SI)"
		label var si_per_support "Personnel: Support (SI)" 
		label var si_per_mixed_unspec "Personnel: Mixed Unspecified (SI)"

		// Recurrent
		label var si_recurrent "Recurrent Goods (SI)"
		label var si_rec_med_int_supplies "Recurring: Medical Supplies (excluding drugs) (SI)"
		label var si_rec_nonmed_int_supplies "Recurring: Non-medical Supplies (SI)"
		label var si_rec_building_space "Recurring: Building Space (SI)"
		label var si_rec_key_drugs "Recurring: Supplies (key drugs) (SI)" 
		label var si_rec_other "Recurring: Other (SI)"
		
		// Capital 
		label var si_capital "Capital (SI)"
		label var si_cap_medical_equip "Capital: Equipment (medical) (SI)"
		label var si_cap_nonmed_equip "Capital: Equipment (non-medical) (SI)"
		label var si_cap_other "Capital: Other (SI)"
		
		// Mixed 
		label var si_mixed "Mixed (SI)"
		//label var si_mix_mixed "Mixed: Mixed (SI)"

		// Activities 
		label var a_primary_sd "Primary Service Delivery (A)"
		label var a_prisd_circumcision_proced "Primary SD: Circumcision Procedure (A)"
		label var a_prisd_unspecified "Primary SD: Unspecified (A)"
		
		label var a_secondary_sd "Secondary Service Delivery (A)"
		label var a_secsd_hct "Secondary SD: HIV Counseling and Testing (A)"

		label var a_ancillary "Ancillary (A)"
		label var a_anc_demand_generation "Ancillary: Demand Generation (A)"
		label var a_anc_lab_services "Ancillary: Lab Services (A)"
		label var a_anc_unspecified "Ancillary: Unspecified (A)"
		label var a_mix_mixed "Ancillary: Mixed (A)"

		label var a_operational "Operational (A)"
		label var a_ope_bldg_equip "Operational: Buildings and Equipment (A)"
		label var a_ope_logistics "Operational: Logistics (A)"
		label var a_ope_program_mgmt "Operational: Program Management (A)"
		label var a_ope_supervision "Operational: Supervision (A)"
		label var a_ope_training "Operational: Training (A)"
		label var a_ope_transportation "Operational: Transportation (A)"
		label var a_ope_unspecified "Operational: Unspecified (A)"
	
		label var a_mixed "Mixed (A)"
		
					
		* Create the missing columns 
		******************************
				
		gen si_cap_build = . 
		label var si_cap_build "Capital: Building/space (SI)"
		
		gen si_cap_vehic = . 
		label var si_cap_vehic "Capital: Vehicles (SI)"
		
		gen a_anc_adhreten = . 
		label var a_anc_adhreten "Ancillary: Adherence/Retention (A)" 
		
		gen a_ope_massed = . 
		label var a_ope_massed "Operational: Mass Education (A)" 
		
		gen a_ope_hmis = . 
		label var a_ope_hmis "Operational: HMIS and Record-Keeping (A)"
		
	* And for the collapse: 
	/*
		*Generate a variable to tell collapsed costs from full costs
		gen collapsed=0
		* Need to create an id without (a) for grouping collapse
		gen study=substr(id, 1, length(id)-1)
		
				label variable study "Study"
				label variable collapsed "Collapsed"
				
				label define collapsed 0 "No" 1 "Yes"
				label values collapsed collapsed
		
		*Create a caveats variable 
					//gen flags="."	
					
	*/
**************************************************************************		
** Replace N/A, NR and none with missing
**************************************************************************	

local to_decode "disease output_unit2 pop_density ownership platform facility_cat id_type id_class id_phase id_int id_modality method id_tech pop_sex tb_rx_resistance timing country_sampling geo_sampling_incountry site_sampling px_sampling sample_size_derived controls econ_perspective_actual econ_costing real_world asd_costs sensitivity_analysis scale research_costs unrelated_costs overhead volunteer_time family_time px_costs_measured cat_cost iso_code currency_iso currency_x inflation" 

foreach var of local to_decode { 
	decode `var', gen(`var'_new) 
	drop `var'
	rename `var'_new `var' 
	
	replace `var' = "." if `var' == "N/A" | `var' == "NR" | `var' == "NA" | `var' == "" | `var' == " "
	
	replace `var' = strproper(`var')
	replace `var' = subinstr(`var', "Arv", "ARV", .)
	replace `var' = subinstr(`var', "Art", "ART", .)
	replace `var' = subinstr(`var', "Ngo", "NGO", .)
	replace `var' = subinstr(`var', "Cd4", "CD4", .)
	replace `var' = subinstr(`var', "Pmtct", "PMTCT", .)
	replace `var' = subinstr(`var', "Pmtc", "PMTC", .)
	replace `var' = subinstr(`var', "Nr", "NR", .)
	replace `var' = subinstr(`var', "Mc", "MC", .)
	


}

foreach var of varlist clinical_monitoring demand_generation counseling_content staff_type supportive_care visits referrals software_electronics id_activities id_tech_det list_asd_cost overhead_costs { 
	
	replace `var' = "." if `var' == "N/A" | `var' == "NR" | `var' == "NA" | `var' == "" | `var' == " "
	
	replace `var' = strproper(`var')
	replace `var' = subinstr(`var', "Oi", "OI", .)
	replace `var' = subinstr(`var', "Nr", "NR", .)
	replace `var' = subinstr(`var', "Art", "ART", .)
	replace `var' = subinstr(`var', "Arv", "ARV", .)
	replace `var' = subinstr(`var', "Cd4", "CD4", .)
	replace `var' = subinstr(`var', "Ae", "AE", .)
	replace `var' = subinstr(`var', "Cssd", "CSSD", .)

}

  
replace disease = strupper(disease) 
replace id_int = strupper(id_int) 
replace id_type = strupper(id_type)
replace iso_code = strupper(iso_code)
replace currency_iso = strupper(currency_iso)
replace pot_distortions = strupper(pot_distortions)

// identify string variables in the dataset and make sure that missings are all formatted homogenously

ds, has(type string) 
local strvars "`r(varlist)'"

foreach var of local strvars { 
	replace `var' = "." if `var' == "NA" | `var' == "N/A" | `var' == "NR" | `var' == " " | `var' == "" | `var' == "None"
}


****************************************************************************		
** Cross-validation of costed activities and intervention details columns **
****************************************************************************

	gen supportive_care_flag = 1 if regexm(id_activities, "Supportive") & (supportive_care == "." | supportive_care == "N/A" | supportive_care == "NR")
	replace supportive_care_flag = 1 if regexm(id_activities, "support") & (supportive_care == "." | supportive_care == "N/A" | supportive_care == "NR")
	replace supportive_care_flag = 1 if supportive_care != "." & !(strmatch(id_activities, "*upport*"))
	
	gen clinical_mo_flag = 1 if regexm(id_activities, "CD4|iagnosis") & (clinical_monitoring == "." | clinical_monitoring == "N/A" | clinical_monitoring == "NR")
	replace clinical_mo_flag = 1 if clinical_monitoring != "." & !(strmatch(id_activities, "*onitoring*")) 
	
	gen counsel_flag = 1 if regexm(id_activities, "ounsel|VCT") & (counseling_content == "." | counseling_content == "N/A" | counseling_content == "NR")
	replace counsel_flag = 1 if counseling_content != "." & !(strmatch(id_activities, "*ounsel*"))
	
	gen demand_gen_flag = 1 if regexm(id_activities, "emand|generation") & (demand_generation == "." | demand_generation == "N/A" | demand_generation == "NR")
	replace demand_gen_flag = 1 if demand_generation != "." & demand_generation != "None" & !(strmatch(id_activities, "*eneration*"))
	
	gen referrals_flag = 1 if regexm(id_activities, "eferrals") & (referrals == "." | referrals == "N/A" | referrals == "NR")
	replace referrals_flag = 1 if referrals != "." & !(strmatch(id_activities, "*eferrals*"))
	
	gen arv_regimen_flag = 1 if regexm(id_activities, "ARV") & (arv_regimen == "." | arv_regimen == "N/A" | arv_regimen == "NR")
	replace arv_regimen_flag = 1 if arv_regimen != "." & arv_regimen != "N/A" & arv_regimen != "NR" & arv_regimen != "none" & arv_regimen != "None" & (!(strmatch(id_activities, "*ARV*")) & !(strmatch(id_activities, "*Arv*")))
	
	gen screen_diag_flag = 1 if regexm(id_activities, "iagnosis") & (screening_diagnoses == "." | screening_diagnoses == "N/A" | screening_diagnoses == "NR")
	replace screen_diag_flag = 1 if screening_diagnoses != "." & screening_diagnoses != "none" & (!(strmatch(id_activities, "*iagnoses*")))
	
	gen treatment_flag = 1 if regexm(id_activities, "reatment") & (treatment == "." | treatment == "N/A" | treatment == "NR") 
	replace treatment_flag = 1 if treatment != "." & treatment != "N/A" & treatment != "NR" & !(strmatch(id_activities, "*reatment*"))
	
	gen comm_awareness_flag = 1 if regexm(id_activities, "wareness") & (community_awareness == "." | community_awareness == "N/A" | community_awareness == "NR") 
	replace comm_awareness_flag = 1 if community_awareness != "." & community_awareness != "N/A" & community_awareness != "NR" & community_awareness != "None" & !(strmatch(id_activities, "*wareness*"))
	
	gen health_system_flag = 1 if regexm(id_activities, "system") & (health_system == "." | health_system == "N/A" | health_system == "NR") 
	replace health_system_flag = 1 if health_system != "." & health_system != "N/A" & health_system != "NR" & !(strmatch(id_activities, "*system*"))
	
	gen software_electronics_flag = 1 if regexm(id_activities, "electronics") & (software_electronics == "." | software_electronics == "N/A" | software_electronics == "NR") 
	replace software_electronics_flag = 1 if software_electronics != "." & !(strmatch(id_activities, "*electronics*"))


	

**************************************************************************		
** Order variables 
**************************************************************************		

order disease lead_author ref_year output_unit2 ref_year title journal_etc url /// 
iso_name location no_sites pop_density ownership platform facility_cat id_class id_type id_int int_description_long id_phase /// 
clinical_monitoring demand_generation counseling_content staff_type supportive_care visits referrals method id_tech id_tech_det /// 
treatment_phase arv_regimen treatment screening_diagnoses community_awareness health_system software_electronics id_activities /// 
start_month start_year end_month end_year period_portrayed year_intro coverage /// 
id_pop_dem_std id_pop_clin_std pop_age pop_sex pop_ses pop_education hiv_prev tb_prev tb_rx_resistance /// 
costing_purpose timing country_sampling geo_sampling_incountry site_sampling px_sampling sample_size_derived controls /// 
econ_perspective_actual econ_costing real_world asd_costs list_asd_costs omitted_costs sensitivity_analysis scale /// 
research_costs unrelated_costs overhead overhead_costs /// 
volunteer_time family_time px_costs_measured cat_cost currency_yr iso_code currency_iso currency_x current_x_rate discount_rate inflation /// 
mean_cost si_personnel si_per_service_delivery si_per_support si_per_mixed_unspec /// 
si_recurrent si_rec_key_drugs si_rec_med_int_supplies si_rec_nonmed_int_supplies si_rec_building_space si_rec_other /// 
si_capital si_cap_medical_equip si_cap_nonmed_equip si_cap_build si_cap_vehic si_cap_other si_mixed /// 
a_primary_sd a_prisd_circumcision_proced a_prisd_unspecified a_secondary_sd a_secsd_hct a_ancillary /// 
a_anc_demand_generation a_anc_lab_services a_anc_adhreten a_anc_unspecified a_mix_mixed /// 
a_operational a_ope_bldg_equip a_ope_logistics a_ope_program_mgmt a_ope_supervision a_ope_training a_ope_transportation a_ope_massed a_ope_hmis a_ope_unspecified a_mixed


// only keep relevant variables 
keep disease-a_mixed




* Finally, export!
**************************
save VMMC_clean_wide_file_Apr2018.dta, replace

* Drew's Path
//export excel using UCSR_export_full.xlsx, first(varl) missing(".") replace
* Lily's Path
* export excel using UCSR_exports/UCSR_export_full.xlsx, first(varl) missing(".") replace       

/*





=======
**************************************************************************
**************************************************************************
**************************************************************************
** Do file for export of VMMC studies to the UCSR, using select variables
** Lily Alexander
** University of Washington
** February 2018 
** lilyalexander18@gmail.com
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
	*Drew's Path:
	cd "/Users/dcameron03/Documents/GitHub/Post-Extraction-Processing/VMMC/"
	use VMMC_wide_file.dta, replace	
	*Lily's Path:
	* cd "C:/Users/Lily Alexander/Dropbox/ALL LIFE THINGS/INSP/Work with Sergio/GHCC/Post-Extraction-Processing/VMMC"
	* 	use VMMC_wide_file_Feb2018.dta


**********************************		
** Cross-validation of costs **
**********************************
	
	* 1. Check that broad standard input categories sum to mean cost 
	****************************************************************
	egen check = rowtotal(si_recurrent si_personnel si_capital si_mixed)
	replace check = si_combined if check == 0
	gen diff = check - mean_cost
	gen flag = 1 if diff > 0.1
	
	count if flag == 1
	di in red `r(N)'
	
	drop diff check flag 

	
	* 2. Check that narrow standard input categories sum to broad categories
	************************************************************************
	
	local prefix "rec per mix cap" 
		
	preserve 
	
	foreach var of local prefix { 
		egen sum_`var' = rowtotal(si_`var'_*)
		drop si_`var'_*
		gen diff_`var' = sum_`var' - si_`var'
		gen flag_`var' = 1 if diff_`var' > 0.05 & diff_`var' !=. 
	
	}
	restore
	
	* 3. Check that broad activity categories sum to mean cost 
	**********************************************************
	
	egen check = rowtotal(a_primary_sd a_secondary_sd a_ancillary a_operational a_mixed)
	gen diff = check - mean_cost
	gen flag = 1 if diff > 0.1
	
	count if flag == 1 
	di in red `r(N)' 
	
	drop diff check flag 
	
	* 4. Check that narrow activity categories sum to broad categories
	******************************************************************
	
	local prefix "prisd secsd anc mix ope" 
	
	//preserve 
	
	foreach var of local prefix { 
		egen sum_`var' = rowtotal(a_`var'_*) 
		
	}
	
	gen diff_prisd = sum_prisd - a_primary_sd 
	gen flag_prisd = 1 if diff_prisd > 0.05 & diff_prisd != . 
	
	gen diff_secsd = sum_secsd - a_secondary_sd 
	gen flag_secsd = 1 if diff_secsd > 0.05 & diff_secsd != . 
	
	gen diff_anc = sum_anc - a_ancillary
	gen flag_anc = 1 if diff_anc > 0.05 & diff_anc != . 
	
	gen diff_ope = sum_ope - a_operational 
	gen flag_ope = 1 if diff_ope > 0.05 & diff_ope != . 
	
	gen diff_mix = sum_mix - a_mixed 
	gen flag_mix = 1 if diff_mix > 0.05 & diff_mix != . 
	

**************************************************************************		
** First, export of whole raw data before compression / aggregation
**************************************************************************
** Begin by selecting key variables for export
		
		label var disease "Disease" 
		label var output_unit2 "Output unit"
		* Identifiers
		**************
		label var id "ID Variable"
		label var unit_cost "Unit Cost ID"
		
		*Bibliographic variables
		************************
		label var lead_author "Lead Author"
		*label var ref_author "Reference Authors"
		label var ref_year "Reference Year"
		label var title "Title"
		label var journal_etc "Journal"
		label var url "URL"

		* Geography
		************
		label var iso_name "Country"
		label var pop_density "Urbanicity"
		label var location "Location"	
		label var no_sites "Sites"
		
		*Intervention variables
		***********************
		label var ownership "Ownership"
		
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
			
		label var facility_cat "Platform_specificity" 
		label var id_class "Intervention Category"
		label var id_int "Intervention"		
		label var int_description_long "Intervention Description (Long)"
		label var clinical_monitoring "Clinical monitoring" 
		label var demand_generation "Demand generation" 
		label var counseling_content "Counseling content"
		label var staff_type "Staff type & number"
		label var supportive_care "Supportive care"
		label var visits "Visit type & number"
		label var referrals "Referrals"
		label var method "Method"
		label var id_tech "Technology"
		label var treatment_phase "Treatment phase"
		label var arv_regimen "ARV Regimen" 
		label var treatment "Treatment" 
		label var screening_diagnoses "Screening and diagnosis"
		label var community_awareness "Community awareness"
		label var id_activities "Costed activities"
		
		label var start_month "Start Month"
		label var start_year "Start Year"
		label var end_month "End Month"
		label var end_year "End Year"
		label var period_portrayed "Total Months"
		label var year_intro "Year introduced at study site"
		label var coverage "Coverage"
		

		*Population
		************
		label var id_pop_dem_std "Target group (demographic)"
		label var id_pop_clin_std "Target group (clinical)"
		label var pop_age "Average Age"
		label var pop_sex "Gender"
		label var pop_ses "SES"
		label var pop_education "Education"
		label var hiv_prev "HIV Prevalence"
		label var tb_prev "TB Prevalence"
		label var tb_rx_resistance "TB Drug Resistance"
		 
		/*
		foreach i of varlist id_pop pop_age pop_ses pop_education hiv_prev cd4_range tb_prev {
			replace `i'="." if `i'=="NR"
			}
		*/
		
		* Study Design
		***************
		label var costing_purpose "Costing Purpose"
		label var timing "Timing"
		label var country_sampling "Country Sampling"
		label var geo_sampling_incountry "Geographic Area In Country Sampling"
		label var site_sampling "Site Sampling"
		label var px_sampling "Patient Sampling"
		label var sample_size_derived "Sample size formally derived"
		label var controls "Controls"
	
	/*
	*Need to replace all missing values in categoricals with 999 so we can label them "."
	foreach i of varlist ownership platform id_class id_type id_modality disease id_tech id_phase int_services country region pop_density pop_sex costing_purpose_cat timing country_sampling geo_sampling_incountry site_sampling px_sampling sample_size_derived controls econ_perspective_report econ_perspective_actual econ_costing real_world asd_costs research_costs unrelated_costs overhead volunteer_time family_time iso_code currency_x {
			replace `i'=999 if `i'==.
			label define `i' 999 ".", add
			}
	
	*Need to do same with string variables
	foreach i of varlist id unit_cost lead_author ref_author title journal_etc url id_facility id_details int_description_long location ss_unique_trait id_pop_std pop_age pop_ses pop_education hiv_prev cd4_range tb_prev list_asd_costs overhead_costs uncertainty_rmk {
		replace `i'="." if `i'==""
		}
	*/
	
		* Costing methods
		*******************
		label var econ_perspective_actual "Perspective"
		label var econ_costing "Economic / Financial"
		label var real_world "Real World / Per Protocol"
		label var asd_costs "Above Service Costs Included"
		label var list_asd_costs "Above Service Cost List"
		label var omitted_costs "Omitted Costs"
		label var sensitivity_analysis "Sensitivity Analysis"
		label var scale "Economies of scale"
		
		label var research_costs "Research Costs Included"
		label var unrelated_costs "Unrelated Costs Included"
		label var overhead "Overhead Costs Included"
		label var overhead_costs "Overhead Costs List"
		label var pot_distortions "Potential distortions"
		
		label var volunteer_time "Valuing Volunteer Time"
		label var family_time "Valuing Family Time"
		label var px_costs_measured "Patient-Incurred Costs Measured"
		label var cat_cost "Catastrophic Cost Calculated"
		
		label var currency_yr "Reported Currency Year"
		label var iso_code "Reported Currency"
		label var currency_iso "Currency of Data Collection"
		label var currency_x "Currency Exchange Method"
		label var current_x_rate "Currency Exchange Rate"
		label var discount_rate "Discount Rate"
		label var inflation "Inflation rate"
		
			
		* Finally, relabel the cost categories
		***************************************
		
		* Label remaining confusing variables
		label var mean_cost	"Mean Unit Cost"
		
		// Personnel
		label var si_personnel "Personnel (SI)"
		label var si_per_service_delivery "Personnel: Direct Service Delivery (SI)"
		label var si_per_support "Personnel: Support (SI)" 
		label var si_per_mixed_unspec "Personnel: Mixed Unspecified (SI)"

		// Recurrent
		label var si_recurrent "Recurrent Goods (SI)"
		label var si_rec_med_int_supplies "Recurring: Medical Supplies (excluding drugs) (SI)"
		label var si_rec_nonmed_int_supplies "Recurring: Non-medical Supplies (SI)"
		label var si_rec_building_space "Recurring: Building Space (SI)"
		* rename rec_other si_rec_other 
		label var si_rec_other "Recurring: Other (SI)"
		
		// Capital 
		label var si_capital "Capital (SI)"
		label var si_cap_medical_equip "Capital: Equipment (medical) (SI)"
		label var si_cap_nonmed_equip "Capital: Equipment (non-medical) (SI)"
		label var si_cap_other "Capital: Other (SI)"
		
		// Mixed 
		label var si_mixed "Mixed (SI)"
		//label var si_mix_mixed "Mixed: Mixed (SI)"

		// Activities 
		label var a_primary_sd "Primary Service Delivery (A)"
		label var a_prisd_circumcision_proced "Primary SD: Circumcision Procedure (A)"
		label var a_prisd_unspecified "Primary SD: Unspecified (A)"
		
		label var a_secondary_sd "Secondary Service Delivery (A)"
		label var a_secsd_hct "Secondary SD: HIV Counseling and Testing (A)"

		label var a_ancillary "Ancillary (A)"
		label var a_anc_demand_generation "Ancillary: Demand Generation (A)"
		label var a_anc_lab_services "Ancillary: Lab Services (A)"
		label var a_anc_unspecified "Ancillary: Unspecified (A)"
		label var a_mix_mixed "Ancillary: Mixed (A)"

		label var a_operational "Operational (A)"
		label var a_ope_bldg_equip "Operational: Buildings and Equipment (A)"
		label var a_ope_logistics "Operational: Logistics (A)"
		label var a_ope_program_mgmt "Operational: Program Management (A)"
		label var a_ope_supervision "Operational: Supervision (A)"
		label var a_ope_training "Operational: Training (A)"
		label var a_ope_transportation "Operational: Transportation (A)"
		label var a_ope_unspecified "Operational: Unspecified (A)"
	
		label var a_mixed "Mixed (A)"
		
					
		* Create the missing columns 
		******************************
		
		*gen si_rec_key_drugs = . 
		label var si_rec_key_drugs "Recurring: Supplies (key drugs) (SI)" 
		
		gen si_cap_build = . 
		label var si_cap_build "Capital: Building/space (SI)"
		
		gen si_cap_vehic = . 
		label var si_cap_vehic "Capital: Vehicles (SI)"
		
		gen a_anc_adhreten = . 
		label var a_anc_adhreten "Ancillary: Adherence/Retention (A)" 
		
		gen a_ope_massed = . 
		label var a_ope_massed "Operational: Mass Education (A)" 
		
		gen a_ope_hmis = . 
		label var a_ope_hmis "Operational: HMIS and Record-Keeping (A)"
		
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
					gen flags="."	
					

**************************************************************************		
** Replace N/A, NR and none with missing
**************************************************************************	

local to_decode "disease collapsed output_unit2 pop_density ownership platform facility_cat id_class id_int method id_tech pop_sex tb_rx_resistance timing country_sampling geo_sampling_incountry site_sampling px_sampling sample_size_derived controls econ_perspective_actual econ_costing real_world asd_costs sensitivity_analysis scale research_costs unrelated_costs overhead volunteer_time family_time px_costs_measured cat_cost iso_code currency_iso currency_x inflation" 

foreach var of local to_decode { 
	decode `var', gen(`var'_new) 
	drop `var'
	rename `var'_new `var' 
	
	replace `var' = "." if `var' == "N/A" | `var' == "NR" | `var' == "NA" | `var' == "" | `var' == " "
	
	replace `var' = strproper(`var')
}

foreach var of varlist clinical_monitoring demand_generation counseling_content staff_type supportive_care visits referrals id_activities list_asd_cost overhead_costs { 
	
	replace `var' = "." if `var' == "N/A" | `var' == "NR" | `var' == "NA" | `var' == "" | `var' == " "
	
	replace `var' = strproper(`var')

}

  
replace disease = strupper(disease) 
replace id_int = strupper(id_int) 
replace iso_code = strupper(iso_code)
replace currency_iso = strupper(currency_iso)


**************************************************************************		
** Order variables 
**************************************************************************		

order disease collapsed lead_author ref_year output_unit2 flags ref_year title journal_etc url /// 
iso_name location no_sites pop_density ownership platform facility_cat id_class id_int int_description_long /// 
clinical_monitoring demand_generation counseling_content staff_type supportive_care visits referrals method id_tech /// 
treatment_phase arv_regimen treatment screening_diagnoses community_awareness id_activities /// 
start_month start_year end_month end_year period_portrayed year_intro coverage /// 
id_pop_dem_std id_pop_clin_std pop_age pop_sex pop_ses pop_education hiv_prev tb_prev tb_rx_resistance /// 
costing_purpose timing country_sampling geo_sampling_incountry site_sampling px_sampling sample_size_derived controls /// 
econ_perspective_actual econ_costing real_world asd_costs list_asd_costs omitted_costs sensitivity_analysis scale /// 
research_costs unrelated_costs overhead overhead_costs pot_distortions /// 
volunteer_time family_time px_costs_measured cat_cost currency_yr iso_code currency_iso currency_x current_x_rate discount_rate inflation /// 
mean_cost si_personnel si_per_service_delivery si_per_support si_per_mixed_unspec /// 
si_recurrent si_rec_key_drugs si_rec_med_int_supplies si_rec_nonmed_int_supplies si_rec_building_space si_rec_other /// 
si_capital si_cap_medical_equip si_cap_nonmed_equip si_cap_build si_cap_vehic si_cap_other si_mixed /// 
a_primary_sd a_prisd_circumcision_proced a_prisd_unspecified a_secondary_sd a_secsd_hct a_ancillary /// 
a_anc_demand_generation a_anc_lab_services a_anc_adhreten a_anc_unspecified a_mix_mixed /// 
a_operational a_ope_bldg_equip a_ope_logistics a_ope_program_mgmt a_ope_supervision a_ope_training a_ope_transportation a_ope_massed a_ope_hmis a_ope_unspecified a_mixed

// only keep relevant variables 
keep disease-a_mixed


// identify string variables in the dataset and make sure that missings are all formatted homogenously

ds, has(type string) 
local strvars "`r(varlist)'"

foreach var of local strvars { 
	replace `var' = "." if `var' == "NA" | `var' == "N/A" | `var' == "NR" | `var' == " " | `var' == ""
}



* Finally, export!
**************************
save VMMC_clean_wide_file_Feb2018.dta, replace

* Drew's Path
export excel using UCSR_export_full.xlsx, first(varl) missing(".") replace
* Lily's Path
* export excel using UCSR_exports/UCSR_export_full.xlsx, first(varl) missing(".") replace       

/*








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
	

>>>>>>> 8030aef4b643f408d5290824eb015b37f1e78186:VMMC/ucsr_export_vmmc.do
