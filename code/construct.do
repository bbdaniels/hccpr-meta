  
  tempfile effect_sizes
  use "${directory}/constructed/effect_sizes.dta", clear
  save `effect_sizes', replace
  
   *** Characteristics sheet from "user_input" excel file ***

  tempfile characteristics
  import excel "${directory}/data/user_input.xlsx", sheet("Characteristics")  cellrange(A1:E90) firstrow allstring clear
  replace user_input = stritrim(user_input)
  keep if user_input != ""
  keep variable user_input
  save `characteristics', replace
 
  drop if variable == "strategy" 
  local n2 `c(N)'

  //create separate datasets for each non-empty variable entered by the user in the excel sheet
 if (`n2' > 0) {
  forv i = 1/`c(N)' {
	preserve
		keep in `i'/`i'
		split user_input, p(",")
		drop user_input
		sxpose, clear firstnames force
		qui ds
		local name "`: word 1 of `r(varlist)''"
		
		if (("`name'" != "CountryName") & ("`name'" != "WHO_Region2") & ///
			("`name'" != "EStime") & ("`name'" != "QQ_year") & ///
			("`name'" != "GNI") & ("`name'" != "ESncomponent") & ("`name'" != "strategy")) {
				destring `name', replace
				tempfile `name'
				sort `name'
				save ``name''
				
				use `effect_sizes' //merge the user input with the main dataset
				sort `name'
				merge m:1 `name' using ``name''
				keep if _merge == 3
				
				sort EffectID
				drop _merge
				
				if (`c(N)' == 0) {
					display as error "Error in `name' input."
					----
				}
				else {
					save ``name'', replace // save each merged file separately
				}
				
			}
			
		else if (("`name'" == "CountryName") | ("`name'" == "WHO_Region2")) {
			
				replace `name' = strtrim(`name')
				levelsof `name', local(levs)
				local n3 `r(N)'
				
				forv j = 1/`n3' {
					tempfile `name'_`j'
					use `effect_sizes' ,clear
					keep if strpos(`name', "`: word `j' of `levs''") > 0 //keep rows that contain the country name/ WHO region name entered by the user
					
					if (`c(N)' == 0) {
						display as error "`name' = `: word `j' of `levs'' not found"
						----
					}
					else {
						save ``name'_`j'', replace //save the dataset of each unique name entered by the user separately
					}
			
				}
				
				tempfile `name'
				use ``name'_1', clear
				if (`n3' > 1) {
					forv j = 2/`n3' {
						append using ``name'_`j'' // append all datasets created above
					}
				}
				
				if (`c(N)' == 0) {
					save ``name'', emptyok
				}

				else {
					duplicates drop EffectID, force
					sort EffectID
					save ``name'', replace
				}			
				
		}
		
		 else if (("`name'" == "EStime") | ("`name'" == "QQ_year") | ///
         ("`name'" == "GNI") | ("`name'" == "ESncomponent")) {
				local num = `c(N)'
				if (`num' > 1) {

					local low = `name'[1] 
					local high = `name'[2] 
	
					tempfile `name'
					use `effect_sizes', clear
        
					keep if `name' `low' & `name' `high' //keep rows that fall in the range entered by the user

			
					if (`c(N)' == 0) {
						display as error "`name' `low' `high' not found"
						----
					}
				save ``name'', replace
				}
				
				else if (`num' == 1) {
					local low = `name'[1]
					tempfile `name'
					use `effect_sizes', clear
        
					keep if `name' `low'
			
					if (`c(N)' == 0) {
						display as error "`name' `low' not found"
						---- 
					}
					save ``name'', replace
				}	
			
		 }					 
	restore
  }
  } 
  
  use `characteristics', clear
  keep if variable == "strategy"
  replace user_input = subinstr(user_input," ","",.)
  
    if (`c(N)' > 0 & user_input != "") {
  	
		keep variable user_input
		split user_input, p(",") 
		drop user_input
		sxpose, clear firstnames force

		local obs = `c(N)'
		di `obs'
		
		//run loop to check the startegy input kind and save the relevant rows 
		forv i = 1/`obs' {
			preserve
				keep in `i'/`i'
				if (strpos(strategy, "+") == 0) {
					if(strpos(strategy, "==") == 0) {
						levelsof strategy, local(levs)
						tempfile strategy_`i'
						use `effect_sizes', clear
						keep if strpos(strategy, " `: word 1 of `levs'' ") > 0
						save `strategy_`i''
					}
					else if (strpos(strategy, "==") > 0) {
						replace strategy = substr(strategy,3,.) 
						levelsof strategy, local(levs)
						tempfile strategy_`i'
						use `effect_sizes', clear
						keep if strategy == " `: word 1 of `levs''  "
						save `strategy_`i''			
					}				
				}
				else if (strpos(strategy, "+") > 0){
					if(strpos(strategy, "==") == 0) {
						split strategy, p("+")
						drop strategy
						sxpose, clear
						destring, gen(var`i')
						levelsof var`i', local(levs)
						local num = `r(N)'
						forv j = 1/`num' {
							tempfile strategy_`i'_`j'
							use `effect_sizes', clear
							keep if strpos(strategy, " `: word `j' of `levs'' ") > 0
							sort EffectID
							save `strategy_`i'_`j''
						}
						use `strategy_`i'_1',clear
						forv k = 2/`num'{
							merge 1:1 EffectID using `strategy_`i'_`k''
							keep if _merge == 3
							drop _merge
							sort EffectID			
						}
						if(`c(N)' == 0){
							clear
							tempfile strategy_`i'
							save `strategy_`i'', emptyok
						}
						else {
							tempfile strategy_`i'
							save `strategy_`i''
						}
					}
					else if(strpos(strategy, "==") > 0) {
						replace strategy = substr(strategy,3,.) 
						split strategy, p("+")
						drop strategy
						sxpose, clear
						destring, gen(var`i')
						levelsof var`i', local(levs)
						local num = `r(N)'
						forv j = 1/`num' {
							tempfile strategy_`i'_`j'
							use `effect_sizes', clear
							keep if strpos(strategy, " `: word `j' of `levs'' ") > 0
							sort EffectID
							save `strategy_`i'_`j''
						}
						use `strategy_`i'_1',clear
						forv k = 2/`num'{
							merge 1:1 EffectID using `strategy_`i'_`k''
							keep if _merge == 3 & n_strategy == `num'
							drop _merge
							sort EffectID			
						}
						if(`c(N)' == 0){
							clear
							tempfile strategy_`i'
							save `strategy_`i'', emptyok
						}
						else {
							tempfile strategy_`i'
							save `strategy_`i''
						}				
					}
				}
			restore	
		}
		
		tempfile strategy
		use `strategy_1', clear 
		if (`obs' > 1) {
			forv i = 2/`obs'{
				append using `strategy_`i''
				duplicates drop EffectID, force
				sort EffectID 
			}
		}
		if(`c(N)' == 0) {
			display as error "No articles found from strategy input"
			----
		}
		save `strategy'
	  }
	  
	use `characteristics', clear
	local num = `c(N)'

	if (`num' > 0) {
		keep variable
		sxpose, clear firstnames force
		ds
		local name "`r(varlist)'"

		// merge all separate tempfiles created above

		use ``: word 1 of `name''', clear

		if (`num' > 1) {
			forv i = 2/`num' {
				merge 1:1 EffectID using ``: word `i' of `name'''
				keep if _merge == 3
				drop _merge
				sort EffectID
				// Check for a null dataset
				if (`c(N)' == 0) {
				  forv j = 1/`i' {
					local variable `:word `j' of `name''
					local no_merge `variable' `no_merge'
				  }
				  display as error "No merge from `no_merge'"
				  --
				}
			  }
			}
			save "${directory}/output/data/${filename}.dta", replace
		  }

		
		  else {
			use `effect_sizes', clear
			save "${directory}/output/data/${filename}.dta", replace
		  }
		  
		  
// the end! 
			  
			  

			  
				
