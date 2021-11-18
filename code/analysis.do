	
	
	// assign values input by user for globals analysis and corr to separate variables
	foreach input in analysis corr {
		clear
		set obs 1
		gen `input' = "${`input'}"
		split `input', p (",")
		drop `input'
		sxpose, clear 
		replace _var1 = subinstr(_var1," ","",.)
		rename _var1 `input'
		levelsof `input', local(lev_`input')
		global n_`input' = `r(N)'
		forv i = 1/`r(N)' {
			global `input'_`i' = `=`input'[`i']'
		} 
	}
	
		// meta-analysis to be run at study level
		if(strpos("${analysis}", "1") > 0) {
			  use "${directory}/output/data/${filename}.dta", clear
			  drop if StdErrES == .
			  gen group = studyid
  
			  bys group: gen n_outcomes = _N
			  bys group: egen effect_size = mean(Effect_size)
			  
			  // assign a number (like 1,2,3) to each studyid
			  preserve
				tempfile id
				duplicates drop group, force
				sort group
				gen id = _n
				keep group id
				save `id'
			  restore
			  
			  merge m:1 group using `id'
			  
			  gen covariance = 0 
			  gen variance_sum = 0
			  
			  // calculate covariance for each studyid
			  forv n_id = 1/`=id[_N]' {
					preserve 
						tempfile id`n_id'
						keep if id == `n_id'
						local n = n_outcomes
						
						if (`n' > 2) {
						local k = `n' - 1 
						local sum = 0
						forv i = 1/`k' {
							local z = `i' + 1 
							forv j = `z'/`n' {
								local covariance = `=StdErrES[`i']' * `=StdErrES[`j']'
								local sum = `sum' + `covariance'			
							}
							
						}
						}
						else if (`n' == 2) {
							local sum = `=StdErrES[1]' * `=StdErrES[2]'	
						}
						else if (`n' == 1 ) {
							local sum = 0
						}	
						replace covariance = `sum'
						
						// calculate sum of variances for each studyid
						local variance_sum = `=StdErrES[1]' * `=StdErrES[1]'
						if (`n'>= 2) {
							forv q = 2/`n' {
								local variance_sum = `variance_sum' + (`=StdErrES[`q']' * `=StdErrES[`q']')
							}	
						}
						replace variance_sum = `variance_sum'
					
					
						duplicates drop group, force 
						save `id`n_id''
					restore 
					
			  }
			  
			  // append datasets for all studyids
			  local number = `=id[_N]'
			  use `id1', clear 
			  
			  forv i = 2/`number' {
				append using `id`i''
			  }
				
			  tempfile analysis_1
			  save `analysis_1'
			  
			  // calculate std. error of synthetic effect size for each correlation value
			  forv v = 1/$n_corr {
			  	use `analysis_1', clear 
				gen variance = ((variance_sum) + ${corr_`v'} * covariance)/(n_outcomes*n_outcomes)
				gen std_err = sqrt(variance)
					 
				lab var std_err "Synthetic Std. Error"
			    lab var effect_size "Synthetic Effect_Size"
					  
			    drop variance _merge
				
				save "${directory}/output/data/${filename}_meta_1_corr_${corr_`v'}.dta", replace 
				}
		}
		
		if("`: word 1 of `lev_analysis''" == "2" | "`: word 2 of `lev_analysis''" == "2") {
			use "${directory}/output/data/${filename}", clear
			drop if StdErrES == .
			save "${directory}/output/data/${filename}_meta_2.dta", replace 
		}
	
	// the end! 	

  
