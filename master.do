
  // Globals
  
   
  global directory "/Users/RuchikaBhatia/Box/Ruchika Mumbai Hospital/Database CDC SR/user_input"
  
  global filter = "2"
  /*
  Select 1 for just filtering the studies without running meta-analysis
  Select 2 for running meta-analysis on the filtered studies
  */
	
  global filename = "check"
 /*
 Enter the name via which you would like all the outputs i.e. forestplots, datatsets and the word document to be saved. 
 If you don't have a preference, let the default of "filename" remain
 */
 
 global analysis = "1"
	  /* 
	  Select 1 for creating a synthetic effect size at the study level for meta-analysis
	  Select 2 for using the outcome level effect for meta-analysis
	  Select 1,2 if you want results from both of the above methodologies 
	  If you don't have a preference or just want to filter studies without running meta-analysis, let the default of "1" remain  
	  */
	  
 global corr = "0.4,0.8"
	  /*
	  If you included "1" in the global analysis, then select the correlation to be assumed between outcomes in all studies for calculating the std. error of the sythetic effect size 
	  If you want results from separate correlations, then separate them by a ",". For eg: select corr = "0.4,0.5,0.6" if you want 3 sets of results with correlation assumed to be 0.4, 0.5, 0.6 respectively
	  If you haven't included "1" in the global analysis or just want to filter studies without running meta-analysis , let the default option of "0.5" remain
	  */
  
  if (strpos("${filter}", "1") > 0) {
	  ssc install moss, replace 
	  ssc install sxpose, replace 
	  
	  
	  run "${directory}/code/clean.do"
	  run "${directory}/code/construct.do"
	
  }
  
  
  if (strpos("${filter}", "2") > 0) {
	 
	 
	  // Install packages
	  
	  ssc install moss, replace 
	  ssc install sxpose, replace 
	  
	  // Run clean.do file
	  
	  run "${directory}/code/clean.do"
	  run "${directory}/code/construct.do"
	 
	  drop if StdErrES == .
	 
	 **************************************************************************** 
	 ******** Make Additional Changes To The Filtered Studies Here  *************
	 ******** save "${directory}/output/data/${filename}.dta", replace ***********  
	 ****************************************************************************
	 
	 run "${directory}/code/analysis.do"
	 
	 import excel "${directory}/data/user_input.xlsx", sheet("Characteristics")  cellrange(A1:E90) firstrow allstring clear
	  replace user_input = stritrim(user_input)
	  keep if user_input != ""
	  keep variable user_input
	  
	  putdocx begin
	  putdocx paragraph, style(Title)
	  putdocx text ("Meta Analysis")
	  putdocx paragraph, style(Heading1)
	  putdocx text ("User Input Filter")
	  putdocx paragraph

	  forv i = 1/`c(N)' {
		putdocx text ( "`=variable[`i']'- ")
		putdocx text ("`=user_input[`i']'"), linebreak(1)
	  }
	  
	  putdocx paragraph, style(Heading1)
	  putdocx text ("Forest Plots")

		  
	  if (strpos("${analysis}", "1") > 0) {
		forv i = 1/$n_corr {
			use "${directory}/output/data/${filename}_meta_1_corr_${corr_`i'}.dta", clear
			putdocx paragraph, style(Heading2)
			putdocx text ("Meta Category = Effect size at study level and Correlation = ${corr_`i'}")
			
			meta set effect_size std_err, studylabel(name)
			
	 ******************************************************************************
			meta forestplot _id studyid _plot _esci n_outcomes, columnopts(studyid, title("StudyID")) columnopts(n_outcomes, title("No. of Outcomes"))
	 *** Make additional changes to the above command to customize your analysis if your global analysis includes "1"
	 *******************************************************************************
			
			graph export "${directory}/output/graphs/${filename}_meta_1_corr`i'.png", replace 
			putdocx paragraph
			putdocx image "${directory}/output/graphs/${filename}_meta_1_corr`i'.png"
			save "${directory}/output/data/${filename}_meta_1_corr_${corr_`i'}.dta", replace            
		  }
		}
		if (strpos("${analysis}", "2") > 0) {
		  use "${directory}/output/data/${filename}_meta_2.dta", clear
		  putdocx pagebreak
		  putdocx paragraph, style(Heading2)
		  putdocx text ("Meta Category = Effect size at outcome level")
		  
		  meta set Effect_size StdErrES, studylabel(name)
	 ******************************************************************************
		  meta forestplot _id studyid _plot _esci , columnopts(studyid, title("StudyID")) 
	  *** Make additional changes to the above command to custom your analysis if your global analysis includes "2"
	 *******************************************************************************
				
		  graph export "${directory}/output/graphs/${filename}_meta_2.png", replace 
		  putdocx paragraph
		  putdocx image  "${directory}/output/graphs/${filename}_meta_2.png"
		  save "${directory}/output/data/${filename}_meta_2.dta", replace    
		}
		
	  putdocx save "${directory}/output/documents/${filename}.docx", replace 
  }  
  // the end! 
  

  
 
  

  
  
 
  
  
  
