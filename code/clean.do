
  
  
  import excel "$directory/data/HCPPR_Data_ES_StdErrES_26Jan2021 (1).xlsx", ///
  sheet("effect size data Jan.26.2021")firstrow clear

  // label QQ_URBAN_RURAL
  split QQ_URBAN_RURAL, p(".")
  drop QQ_URBAN_RURAL QQ_URBAN_RURAL2
  rename QQ_URBAN_RURAL1 QQ_URBAN_RURAL
  destring QQ_URBAN_RURAL, replace
  
  label define urban_rural 1 "Urban +/- periurban" 2 "Periurban only" ///
  3 "Urban-rural mix" 4 "Town +/- rural" 5 "Rural only" ///
  6 "Unclear or not stated" 7 "Periurban-town mix"
  label val QQ_URBAN_RURAL urban_rural
  
  // label STUDY_DESIGN_FIN
  
  local design `""Pre-post study with randomized controls" "Pre-post study with non-randomized controls" "Post-only study with randomized controls" "Interrupted time series with randomized controls" "Interrupted time series with no controls" "Interrupted time series with non-randomized controls""'
  forv i = 1/6 {
    replace STUDY_DESIGN_FIN = "`i'" if STUDY_DESIGN_FIN == "`: word `i' of `design''"
  }
  destring STUDY_DESIGN_FIN, replace 
  
  local lbl_design = ""
  forv i = 1/6 {
    local thisLabel `i' "`: word `i' of `design''"
    local lbl_design `lbl_design' `thisLabel'
  }
  
  label define design `lbl_design'
  label val STUDY_DESIGN_FIN design 
  
  // create strategy var to capture numeric values of strategy_label var
  replace strategy_label = subinstr(strategy_label,"only", "", .)

  local strategy `" "Community support" "Patient support" "Strengthening infrastructure" "Health system financing and other incentives" "HCP-directed financial incentives" "Regulation and governance" "Other management techniques" "Group problem solving" "Supervision" "Training" "Information and communication technology or mHealth for HCPs" "Printed information or job aids for HCPs" "'
  
  gen strategy = strategy_label
  
  forv i = 1/12 {  
    replace strategy = subinstr(strategy,"`: word `i' of `strategy''","`i'",.) 
  }
  
  replace strategy = " " + strategy + " "

  // destring vars
  local var "ILL_Dental ILL_Infect_prev ILL_Drug_abuse ILL_Gen_med_use GNI QQ_overcome ESNewHCP ESNewSTG EStime ESbaseline setting_public_only ESNewHCPresp"
  
  foreach var in `var' {
    destring `var', replace 
  }
  
  // name each report for meta-analysis
  gen work = subinstr(Report1, ",", "", .)

  // extract year from Report1 var 
  moss work, match("([0-9]+)")  regex
  forv i = 1/8 {
    destring _match`i', replace 
  }
  forv i = 2/8 {
    replace _match1 = _match`i' if _match1 < 1900
  }
  
  split work, limit(1) // get first author's name
  tostring _match1, replace
  
  preserve
    tempfile merge1
    keep studyid ComparisonID
    duplicates drop studyid ComparisonID, force 
    bys studyid : gen comp = _n // create a simpler comparison id
    save `merge1'
  restore 
  
  merge m:1 studyid ComparisonID using `merge1'
    
  tostring comp, replace 
  
  // create name for each study  
  gen name = work1 + "(" + _match1 + ")"
  
  //gen name = work1 + "(" + _match1 + ")" + ":" +  Outcome_definition + " " + "(" + "Comparison-" + comp + ")"
  
  //gen name_comp = work1 + "(" + _match1 + ")" + ":" + "Comparison-" + comp 
  
  drop work _match* _pos* _merge
  
  // number of strategies 
  gen n_strategy = length(strategy) - length(subinstr(strategy, "+", "", .)) + 1 
  //bys studyid: egen n_strategy_study = max(n_strategy)
  
   	local varlist "OUTCOME_case_mgmt OUTCOME_counseling OUTCOME_diagnosis OUTCOME_document OUTCOME_other_practice OUTCOME_pt_assess OUTCOME_treatment OUTCOME_univers_precaution OUTCOME_vaccination OUTCOME_referral"
  
  local i = 1 
  gen outcome_group = ""
  foreach var in `varlist' {
  	replace outcome_group = "`: word `i' of `varlist''" if `var' == 1 
	local i = `i' + 1	
  }
  
  
  replace outcome_group = proper(outcome_group)
  replace outcome_group = subinstr(outcome_group,"_",": ",1)
  replace outcome_group = "Outcome: Case Mgmt" if outcome_group == "Outcome: Case_Mgmt"
  replace outcome_group = "Outcome: Other Practice" if outcome_group == "Outcome: Other_Practice"
  replace outcome_group = "Outcome: Patient Assessment" if outcome_group == "Outcome: Pt_Assess"
  replace outcome_group = "Outcome: Universal Precaution" if outcome_group == "Outcome: Univers_Precaution"
   
  destring StdErrES, replace 
  drop if StdErrES == . 
  
  format studyid %12.0f
    
  save "${directory}/constructed/effect_sizes.dta", replace 
