
* GDP Inflation protocol for GHCC extracted cost data for all HIV interventions
*******************************************************************************
* Author: Drew Cameron, UC Berkeley School of Public Health
* Date Last Modified: 22 March 2018
* Location: Berkeley, California
* Email Address: drew.cameron@berkeley.edu
*
* This .do file to be used in conjunction with data transformation do files
* associated with the GHCC published data extraction tools
*******************************************************************************

* Required File Paths:
**********************
* All folders should exist in a common folder named GHCC/
* - Subfolder for each intervention (ie. "GHCC/VMMC/", "GHCC/ART/", "GHCC/TB/", etc.)
* - Subfolder for do files "GHCC/do_files" (in which this do file and the data 
*			import do files (ie. "GHCC/do_files/vmmc_data_import.do" and this file 
*			"GHCC/do_files/inflation_vmmc_gdp.do" should be housed)
* - Subfolder for external external data, which should include the excel file for 
*			containing inflation rates, slightly modified (by DC) from the original 
*			World Bank data - source information available below. 
*			(ie. "GHCC/external_data/GHCC WB Inflation Data.xls")
* - Subfolders within each intervention subfolders:
*	~ GHCC/VMMC/temp_dta (in which costs.dta and study_attributes.dta have been created
*				in the previous steps of the data_import do file.)
*	~ GHCC/VMMC/extracted_data (in which data extraction templates in xlsx form are 
*				stored)
**********************

** Protocol for inflating all costs to current USD using US GDP Price Deflator
****************************************************************************** 

************************************************************************************
* To create inflation file (should already be provided in the excel file: 
* external_data/GHCC WB Inflation Data.xls. To download the underlying data 
* manually, visit: <https://data.worldbank.org/indicator/NY.GDP.DEFL.ZS>
* Be sure that the data series displayed is "GDP deflator (base year varies by country)"
* Now export all country-level data by clicking on either CSV or EXCEL. 
* Importing data to Stata will require you to place an alphabetical letter before
* each year in the row of inflation data years (ie. 1990 becomes y1990). Italicizing
* these years also seems to help Stata to recognize a non-numeric on which it can
* reshape - otherwise it doesn't seem to work well. So do both before proceeding.
************************************************************************************
			
** Automated process for importing only GDP deflator info for the US 
***********************************************************************************
*Note, country names must be strings, and same format as WB conventions

*********
*********
*Step 1.1
*********
*********

	*Load in currency_yr data from the study_attributes tab for inflation
	*********************************************************************

	clear
	cd "/Users/lilyalexander/Dropbox/ALL LIFE THINGS/INSP/Work with Sergio/GHCC/Post-Extraction-Processing/ART"
			// Change path as applicable for different intervention categories.
			// larger folder GHCC/ subfolder "VMMC/" or other

	use temp_dta/costs.dta
		merge m:1 id using temp_dta/study_attributes.dta
		
			* If currency year is missing, replace with year of publication minus 1 
			replace currency_yr=ref_year - 1 if currency_yr==.
	
			drop _merge
			drop extractor_initials-geo_incountry_rs
			drop location-discount_rate_rs
			drop volunteer_time-consistency_rmk
			drop currency_x currency_x_rs currency_period_rs traded
			drop iso_name currency_yr_rs currency_rmk

			// Here check to see that the currency country and year are correct and not empty
			
	

		* Should have kept the following variables from the study_attributes tab
		tab country
		tab iso_code
		tab currency_yr
		tab current_x_rate
			replace current_x_rate="." if current_x_rate=="NR"
			destring current_x_rate, replace
			tab current_x_rate,m
		
	save temp_dta/costs.dta,replace			
		
*********	
*********		
*Step 1.2 
*********
*********
*(This procedure actually does NOTHING for VMMC, but might for other interventions)


	** Ensure currency are reported in USD... If not, use the following procedure
	*****************************************************************************
		tab iso_code, m
		
	
	* Use current_x_rate if available
		tab current_x_rate,m
		tab currency_yr,m
		
	* If not available, update to whatever the WB exchange rate is for the given year
	
	
		** Automated process for importing year-specific exchange rates for each country
		********************************************************************************
		*Note, as above, country names must be strings, and in same format as WB naming conventions
		
		clear
		cd "/Users/lilyalexander/Dropbox/ALL LIFE THINGS/INSP/Work with Sergio/GHCC/Post-Extraction-Processing/"
				// change for your file path to general GHCC/ folder
		import excel "external_data/GHCC WB Inflation Data.xls", firstrow sheet("Step1 Exchange Rates") cellrange(A5)
		reshape long y, i(CountryName) j(year_d)
		rename y wb_x_rate
		rename year_d currency_yr
		rename CountryName country
		save ART/temp_dta/exchange_rates.dta, replace
*!*			Need to replace VMMC with applicable folder name going forward		
					
		
		cd "/Users/lilyalexander/Dropbox/ALL LIFE THINGS/INSP/Work with Sergio/GHCC/Post-Extraction-Processing/ART"
				// change to intervention specific subfolder
		clear
		use temp_dta/costs.dta
		
		// Clean up some country names (capitalization, spelling, accent issues_
		replace country = "Cote d'Ivoire" if country == "Côte d'Ivoire"
		replace country = "Multiple" if country == "multiple" 
		
		// In some cases, the "country" variable is labeled as "Multiple", in which case we will create a temp_country variable so that these data points are not erroneously dropped
		//Check that are all in USD 
		count if country=="Multiple" & iso_code!="USD" 
		
		gen temp_country=.
		replace temp_country=1 if country=="Multiple" 
		replace country="United States" if country=="Multiple" 
		
		// Erase spaces
		replace country = strtrim(country)
		
		merge m:1 country currency_yr using "temp_dta/exchange_rates.dta"
		drop if _merge==2
		drop if _merge==1
		drop _merge
		
		replace country="Multiple" if temp_country==1
		drop temp_country 
		
		*replace missing current_x_rate data with WB data
		replace current_x_rate = "." if current_x_rate == "N/A"
		destring current_x_rate, replace
		replace current_x_rate=wb_x_rate if current_x_rate==. & iso_code!="USD"
			// proper number replaced
		drop wb_x_rate
		
			
		*Verify that current_x_rate data is not missing values
		*bro mean_cost alt_mean_cost current_x_rate
		tab current_x_rate, m
			
			
		* Make adjustments
		replace mean_cost=mean_cost*current_x_rate if iso_code!="USD"
			//data should now all be in USD for given currency_yr
		

		* Get rid of study attribute data so it loads in clean later
		drop country iso_code current_x_rate
		
		
			save temp_dta/costs.dta, replace	
			
		
*********
*********
*Step 1.3
*********
*********

	* Create year specific and current year inflation datasets
	**********************************************************

	clear
	cd "/Users/lilyalexander/Dropbox/ALL LIFE THINGS/INSP/Work with Sergio/GHCC/Post-Extraction-Processing/"
			// change to your desired file directory for /GHCC folder
	import excel "external_data/GHCC WB Inflation Data.xls", firstrow sheet("Step2 GDP Deflator") cellrange(A5)
		keep if CountryName=="United States"
	reshape long y, i(CountryName) j(year_d)
	rename y gdp_deflator
	
	rename year_d currency_yr
	drop CountryName
	
	* And generate a current gdp inflation number for each country to import
	sum gdp_deflator if currency_yr==2016
		gen gdp_current=r(mean)
	save ART/temp_dta/inflation_data.dta, replace
		// change to applicable intervention subfolder with /GHCC/

*********
*********
*Step 1.4
*********
*********

	* Import year specific and current year inflation datasets
	**********************************************************

	cd "/Users/lilyalexander/Dropbox/ALL LIFE THINGS/INSP/Work with Sergio/GHCC/Post-Extraction-Processing/ART/"
		// change to intervention specific subfolder within /GHCC/
	clear
	use temp_dta/costs.dta

	* Merge in the currency year deflation number
	merge m:1 currency_yr using "temp_dta/inflation_data.dta"

	drop if _merge==2
		drop if _merge==1
		drop _merge

	* Check to make sure data aren't missing
	* bro mean_cost country currency_yr gdp_deflator gdp_current
	tab gdp_deflator,m
	tab gdp_current,m

**********	
**********
* Step 1.5	
**********
**********

		*Make fake var to verify changes happening as planned
		*****************************************************
		gen mean_cost_unadjusted=mean_cost
		
		*Make adjustments to inflate to 2016 in local currency
		******************************************************
		replace	mean_cost = mean_cost*(gdp_current/gdp_deflator)

		*Check to be sure the procedure worked properly
		* bro mean_cost mean_cost_unadjusted if mean_cost==mean_cost_unadjusted
		count if mean_cost!=mean_cost_unadjusted
		count if mean_cost==mean_cost_unadjusted
				* Looks to all be zero costs that were not modified
			tab mean_cost,m
		
		*remove unnecessary variables
		drop gdp_current gdp_deflator mean_cost_unadjusted currency_yr

	* And save cost data:
	save temp_dta/costs.dta, replace				
			
			
			
			
			
