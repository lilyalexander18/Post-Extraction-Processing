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
	local folder "C:/Users/Lily Alexander/Dropbox/ALL LIFE THINGS/INSP/Work with Sergio/GHCC/post_extraction_processing"
	
*************************************************************************
* Part I: Pull datasets in front intervention-specific folders and append
*************************************************************************

	local interventions "ART Inpatient_care" 
	
	use "`folder'/STI/STI_clean_wide_file.dta", clear 


	foreach int of local interventions { 
		di in red "`int'"
		append using "`folder'/`int'/`int'_clean_wide_file.dta"
			
	}
	

sort study id unit_cost 

* Finally, export to excel
**************************
export excel using "`folder'/wide_file_1_17_2018.xlsx", first(varl) missing(".") replace    
	
	

