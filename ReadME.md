## Note

The raw dataset required to replicate this code is not on open access.


## Overview

The code in this replication package runs 3 do files in Stata to achieve the following:

* Select a subset of studies based on a user's input

* Create synthetic effect sizes for each study depending on how the user wants to run meta-analysis

* Visualize the effect sizes of selected studies in a forestplot using random-effects meta-analysis

## Description of Code Files

* ```master.do``` runs the entire code for the project to generate all the outputs

* ```code/clean.do``` prepares the dataset from the raw HCPPR dataset. This involves modifying existing variables and also creating new variables

* ```code/construct.do``` creates the dataset of the studies selected using the user's input

* ```code/analysis.do``` creates the data for meta-analysis using the user's input of the globals- analaysis and corr in the ```master.do```

## Instructions to Replicators
* Stata version used- 16.1. Update version 16 if not done already

* Open the ```data/user_input.xlsx```, make necessary changes and then save it. Read the intructions for user_input column and the comments in the excel file carefully before making any changes

* Open the ```master.do```, change the directory to your local file path. Change the values of other globals or let the default options remain. Run the entire do-file

* Outputs i.e. datasets, graphs and the word document are saved in the ```output``` folder in their respective folders. They are either saved by their default names or by the name given by the user

* In the ```master.do``` file, create additional changes, if required, in the marked spaces

* Change your input in the excel file or the global values and run the entire ```master.do``` to get results from a different subset of studies or from a different methodology

* To get the default setting of the excel file, remove all enteries from the ```user_input``` column or delete ```data/user_input.xlsx``` , re-download the excel-file from [here](https://github.com/ruchikabhatia96/CDC_SR) , and save it in the ```data``` folder

* Don't make edits to any column other than the ```user_input``` column. If accidental edits made, delete the file, download it from [here](https://github.com/ruchikabhatia96/CDC_SR) and save it in the ```data``` folder.
