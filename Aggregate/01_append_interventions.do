* Appending interventions for export to UCSR
* Global Health Costing Consortium (GHCC)
* January 2018
* 
* Latest update date: 15 January 2018
*
* Lily Alexander, MPH Student, Univ of Washington
* lilyalexander18@gmail.com; lalexan1@uw.edu
******************************************************

// Set Stata preferences 
	clear all
	set more off
	set mem 2g

	
// Set local paths 
	local folder "/Users/lilyalexander/Dropbox/ALL LIFE THINGS/INSP/Work with Sergio/GHCC/Post-Extraction-Processing"
	
*************************************************************************
* Part I: Pull datasets in front intervention-specific folders and append
*************************************************************************

	local interventions "ART PMTCT Post_violence_care Patient_tracking Retention_and_adherence STI VMMC HCT PrEP" 
	
	

	foreach int of local interventions { 
	
		di in red "`int'"
		
		use "`folder'/`int'/wide_files/`int'_clean_wide_file_Apr2018.dta", clear
		
		if "`int'" == "ART" | "`int'" == "PMTCT" | "`int'" == "Post_violence_care" | "`int'" == "Patient_tracking" | "`int'" == "Retention_and_adherence" | "`int'" == "VMMC" { 
			tostring year_intro, replace
			tostring coverage, replace
			tostring hiv_prev, replace
			tostring discount_rate, replace
		}
	
		if "`int'" == "STI" { 
			destring no_sites, replace
			destring period_portrayed, replace
			tostring year_intro, replace 
			
			replace hiv_prev = ".23" if hiv_prev == "16–30% " 
			
			destring current_x_rate, replace
			tostring coverage, replace
			tostring discount_rate, replace

		}
		
		if "`int'" == "HCT" { 
			destring no_sites, replace
			replace period_portrayed = "9" if period_portrayed == "6-12" 
			destring period_portrayed, replace
			tostring year_intro, replace
			destring current_x_rate, replace

		}
		
		if "`int'" == "PrEP" { 
			destring start_year, replace
			destring end_year, replace
			destring period_portrayed, replace
			tostring year_intro, replace
			tostring coverage, replace
			tostring pop_age, replace
			tostring hiv_prev, replace
			destring current_x_rate, replace
			tostring discount_rate, replace
		}

		
		tempfile `int'_file
		save ``int'_file', replace 
			
	}
	
		
	use `ART_file', clear 
	
	replace no_sites = "." if no_sites == "NR"
	destring no_sites, replace 
	replace year_intro = "." if year_intro == "99"
	
	foreach int of local interventions {

		if "`int'" != "ART" {		
			
			di in red "`int'"
			append using ``int'_file'
		}
	}

*************************************************************************
* Part II: Run GDP deflator code 
*************************************************************************

* Finally, export to excel
**************************
export excel using "`folder'/Aggregate/wide_file_4_22_2018.xlsx", first(varl) missing(".") replace    
	
	

