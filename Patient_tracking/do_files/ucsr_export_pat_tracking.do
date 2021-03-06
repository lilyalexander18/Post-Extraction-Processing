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
	cd "/Users/lilyalexander/Dropbox/ALL LIFE THINGS/INSP/Work with Sergio/GHCC/Post-Extraction-Processing/Patient_tracking/wide_files" 
	use pat_tracking_wide_file_Apr2018.dta, replace


**********************************		
** Cross-validation of costs **
**********************************
	
	* 1. Check that broad standard input categories sum to mean cost 
	****************************************************************
	egen check = rowtotal(si_recurrent si_personnel)
	replace check = si_combined if check == 0
	gen diff = check - mean_cost
	gen flag = 1 if diff > 1
	
	count if flag == 1
	di in red `r(N)'
	
	drop diff check flag 

	
	* 2. Check that narrow standard input categories sum to broad categories
	************************************************************************
	
	local prefix "rec per" 
		
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
	
	egen check = rowtotal(a_primary_sd a_operational)
	replace check = a_combo if check == 0
	gen diff = check - mean_cost
	gen flag = 1 if diff > 1
	
	count if flag == 1 
	di in red `r(N)' 
	
	drop diff check flag 
	
	* 4. Check that narrow activity categories sum to broad categories
	******************************************************************
	
	local prefix "prisd ope com" 
	
	//preserve 
	
	foreach var of local prefix { 
		egen sum_`var' = rowtotal(a_`var'_*) 
		
	}
	
	gen diff_prisd = sum_prisd - a_primary_sd 
	gen flag_prisd = 1 if diff_prisd > 0.05 & diff_prisd != . 

	gen diff_ope = sum_ope - a_operational 
	gen flag_ope = 1 if diff_ope > 0.05 & diff_ope != . 
	
	gen diff_com = sum_com - a_combo
	gen flag_com = 1 if diff_com > 0.05 & diff_com != . 



	

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
		label var id_tech_det "Technology detail"
		label var treatment_phase "Treatment phase"
		label var arv_regimen "ARV Regimen" 
		label var treatment "Treatment" 
		label var screening_diagnoses "Screening and diagnosis"
		label var community_awareness "Community awareness"
		label var health_system "Health system" 
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

		// Recurrent
		label var si_recurrent "Recurrent Goods (SI)"
		label var si_rec_other "Recurring: Other (SI)"
		label var si_rec_nonmed_int_supplies "Recurring: Non-medical Supplies (SI)"
	
		// Activities 
		label var a_primary_sd "Primary Service Delivery (A)"
		label var a_prisd_pt_tracking_services "Primary SD: Patient Tracking - Tracking Services (A)"

		label var a_operational "Operational (A)"
		label var a_ope_unspecified "Operational: Unspecified (A)"
		label var a_ope_transportation "Operational: Transportation (A)"
		

		* Create the missing columns 
		******************************
	
		gen si_rec_mixed = . 
		label var si_rec_mixed "Recurring: Mixed (SI)" 
		
		gen si_rec_med_int_supplies = . 
		label var si_rec_med_int_supplies "Recurring: Medical Supplies (excluding drugs) (SI)"
		
		gen si_rec_key_drugs = . 
		label var si_rec_key_drugs "Recurring: Supplies (key drugs) (SI)" 
		
		gen si_rec_building_space = . 
		label var si_rec_building_space "Recurring: Building Space (SI)"
		
		gen si_per_support = . 
		label var si_per_support "Personnel: Support (SI)" 
		
		gen si_per_mixed_unspec = . 
		label var si_per_mixed_unspec "Personnel: Mixed Unspecified (SI)"

		gen si_capital = . 
		label var si_capital "Capital (SI)"
		
		gen si_cap_other = . 
		label var si_cap_other "Capital: Other (SI)"
		
		gen si_cap_mixed = . 
		label var si_cap_mixed "Capital: Mixed (SI)"
		
		gen si_cap_med_equip = . 
		label var si_cap_med_equip "Capital: Equipment (medical) (SI)"
		
		gen si_cap_nonmed_equip = . 
		label var si_cap_nonmed_equip "Capital: Equipment (non-medical) (SI)"
		
		gen si_cap_building_space = . 
		label var si_cap_building_space "Capital: Building Space (SI)"
		
		gen si_cap_vehicles = . 
		label var si_cap_vehicles "Capital: Vehicles (SI)"
		
		gen si_mixed = . 
		label var si_mixed "Mixed (SI)"
		
		gen si_unspecified = . 
		label var si_unspecified "Unspecified (SI)"
		
		gen a_prisd_unspec_counseling = . 
		label var a_prisd_unspec_counseling "Primary SD: Counseling unspecified (A)"
		
		gen a_prisd_post_test_counseling = . 
		label var a_prisd_post_test_counseling "Primary SD: Post-test counseling (A)"
		
		gen a_prisd_lab_services = . 
		label var a_prisd_lab_services "Primary SD: Lab services (A)"
		
		gen a_prisd_htc_service_delivery = . 
		label var a_prisd_htc_service_delivery "Primary SD: HTC service delivery (A)"
		
		gen a_prisd_hiv_rapid_test = . 
		label var a_prisd_hiv_rapid_test "Primary SD: HIV rapid testing (A)"
		
		gen a_prisd_arv_delivery = . 
		label var a_prisd_arv_delivery "Primary SD: ARV delivery"
		
		gen a_anc_adhreten = . 
		label var a_anc_adhreten "Ancillary: Adherence/Retention (A)" 
		
		gen a_anc_lab_services = . 
		label var a_anc_lab_services "Ancillary: Lab Services (A)"
		
		gen a_ancillary = . 
		label var a_ancillary "Ancillary (A)"
		
		gen a_anc_unspecified = . 
		label var a_anc_unspecified "Ancillary: Unspecified (A)"
		
		gen a_anc_demand_generation = . 
		label var a_anc_demand_generation "Ancillary: Demand generation (A)"
		
		gen a_anc_bldg_equip = . 
		label var a_anc_bldg_equip "Ancillary: Building equipment (A)"
		
		gen a_ope_training = . 
		label var a_ope_training "Operational: Training (A)"
		
		gen a_ope_program_mgmt = . 
		label var a_ope_program_mgmt "Operational: Program Management (A)"
		
		gen a_ope_bldg_equip = . 
		label var a_ope_bldg_equip "Operational: Buildings and Equipment (A)"
		
		gen a_ope_logistics = . 
		label var a_ope_logistics "Operational: Logistics (A)"
		
		gen a_ope_supervision = . 
		label var a_ope_supervision "Operational: Supervision (A)"
		
		gen a_ope_massed = . 
		label var a_ope_massed "Operational: Mass Education (A)" 
		
		gen a_ope_hmis = . 
		label var a_ope_hmis "Operational: HMIS and Record-Keeping (A)"
		
		gen a_secondary_sd = . 
		label var a_secondary_sd "Secondary Service Delivery (A)"
			
		gen a_mixed = . 
		label var a_mixed "Mixed (A)"
		
		gen a_mix_bldg_equip = . 
		label var a_mix_bldg_equip "Mixed: Building Equipment (A)"
		
		gen a_unspecified = . 
		label var a_unspecified "Unspecified (A)" 


		
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

local to_decode "disease output_unit2 pop_density ownership platform facility_cat id_class id_type id_phase id_int method id_tech pop_sex tb_rx_resistance timing country_sampling geo_sampling_incountry site_sampling px_sampling sample_size_derived controls econ_perspective_actual econ_costing real_world asd_costs sensitivity_analysis scale research_costs unrelated_costs overhead volunteer_time family_time px_costs_measured cat_cost iso_code currency_iso currency_x inflation" 

foreach var of local to_decode { 
	decode `var', gen(`var'_new) 
	drop `var'
	rename `var'_new `var' 
	
	replace `var' = "." if `var' == "N/A" | `var' == "NR" | `var' == "NA" | `var' == "" | `var' == " "
	
	replace `var' = strproper(`var')
}

foreach var of varlist clinical_monitoring demand_generation counseling_content staff_type supportive_care software_electronics visits referrals id_activities list_asd_cost overhead_costs treatment_phase { 
	
	replace `var' = "." if `var' == "N/A" | `var' == "NR" | `var' == "NA" | `var' == "" | `var' == " "
	
	replace `var' = strproper(`var')

}

  
replace disease = strupper(disease) 
replace id_int = strproper(id_int) 
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

	gen flag = 1 if regexm(id_activities, "HTC") & counseling_content == "."
	
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
	replace screen_diag_flag = 1 if screening_diagnoses != "." & screening_diagnoses !="NR" & (!(strmatch(id_activities, "*iagnoses*")))
	
	gen treatment_flag = 1 if regexm(id_activities, "reatment") & (treatment == "." | treatment == "N/A" | treatment == "NR") 
	replace treatment_flag = 1 if treatment != "." & treatment != "N/A" & treatment != "NR" & !(strmatch(id_activities, "*reatment*"))
	
	gen comm_awareness_flag = 1 if regexm(id_activities, "wareness") & (community_awareness == "." | community_awareness == "N/A" | community_awareness == "NR") 
	replace comm_awareness_flag = 1 if community_awareness != "." & community_awareness != "N/A" & community_awareness != "NR" & community_awareness != "None" & !(strmatch(id_activities, "*wareness*"))
	
	gen health_system_flag = 1 if regexm(id_activities, "system") & (health_system == "." | health_system == "N/A" | health_system == "NR") 
	replace health_system_flag = 1 if health_system != "." & health_system != "N/A" & health_system != "NR" & !(strmatch(id_activities, "*system*"))
	
	gen software_electronics_flag = 1 if regexm(id_activities, "electronics") & (software_electronics == "." | software_electronics == "N/A" | software_electronics == "NR") 
	replace software_electronics_flag = 1 if software_electronics != "." & !(strmatch(id_activities, "*lectronics*"))


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
si_recurrent si_rec_key_drugs si_rec_med_int_supplies si_rec_nonmed_int_supplies si_rec_building_space si_rec_mixed si_rec_other /// 
si_capital si_cap_med_equip si_cap_nonmed_equip si_cap_build si_cap_vehic si_cap_mixed si_cap_other si_mixed si_unspecified /// 
a_primary_sd  a_prisd_pt_tracking_services a_prisd_unspec_counseling a_prisd_post_test_counseling a_prisd_lab_services a_prisd_htc_service_delivery a_prisd_hiv_rapid_test a_prisd_arv_delivery /// 
a_secondary_sd a_ancillary /// 
a_anc_demand_generation a_anc_lab_services a_anc_adhreten a_anc_bldg_equip a_anc_unspecified /// 
a_operational a_ope_bldg_equip a_ope_logistics a_ope_program_mgmt a_ope_supervision a_ope_training a_ope_transportation a_ope_massed a_ope_hmis a_ope_unspecified a_mixed a_mix_bldg_equip a_unspecified


// only keep relevant variables 
keep disease-a_unspecified



* Finally, export!
**************************
save Patient_tracking_clean_wide_file_Apr2018.dta, replace

* Drew's Path
//export excel using wide_files/UCSR_export_full.xlsx, first(varl) missing(".") replace

* Lily's Path
* export excel using UCSR_exports/UCSR_export_full.xlsx, first(varl) missing(".") replace       




