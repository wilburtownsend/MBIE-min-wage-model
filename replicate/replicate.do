/*******************************************************************************
replicate.do

This do-file replicates the regression with which MBIE calculate the elasticity
used in their model. This do-file also assesses how the elasticity would change,
were different years used to train the model.

The Stata path should be set to the "/MBIE-min-wage-model/replicate/" subfolder.
*******************************************************************************/


/*******************************************************************************
1: Combine data.***************************************************************/

tempfile data

import delimited "data/GDP.csv", varnames(nonames) rowrange(3:139) clear 
rename * (year_quarter GDP)
keep if strpos(year_quarter, "Q2")
generate year = real(subinstr(year_quarter, "Q2", "", .))
keep year GDP
save "`data'", replace

import delimited "data/PPI.csv", varnames(nonames) rowrange(3:177) clear 
rename * (year_quarter PPI)
keep if strpos(year_quarter, "Q2")
generate year = real(subinstr(year_quarter, "Q2", "", .))
keep year PPI
merge 1:1 year using "`data'", nogen
save "`data'", replace

import delimited "data/average earnings.csv", varnames(nonames) rowrange(5:134) clear 
rename * (year_quarter earnings)
keep if strpos(year_quarter, "Q2")
generate year = real(subinstr(year_quarter, "Q2", "", .))
keep year earnings
merge 1:1 year using "`data'", nogen
save "`data'", replace

import delimited "data/employment.csv", varnames(nonames) rowrange(4:145) clear 
rename * (year_quarter employment)
keep if strpos(year_quarter, "Q2")
generate year = real(subinstr(year_quarter, "Q2", "", .))
keep year employment
merge 1:1 year using "`data'", nogen
save "`data'", replace

* Generate min wages using age-specific EMP from MBIE data -- can just use
* national min wage more recently.
import excel "../OIA/AnnualupdatedAllInputData15Feb2019.xls", ///
									sheet("Updated data") firstrow clear
generate year = year(date) 
generate nmwall = EMP1617/EMPAll*NMW1617+EMP1819/EMPAll*NMW1819+ ///
                (1-EMP1617/EMPAll-EMP1819/EMPAll)*NMWADL
keep year nmwall
set obs `=_N+1'
replace year = 2021 if _n == _N
replace nmwall = 16.50 if year == 2018
replace nmwall = 17.70 if year == 2019
replace nmwall = 18.90 if year == 2020
replace nmwall = 20.00 if year == 2021
merge 1:1 year using "`data'", nogen
save "`data'", replace


/*******************************************************************************
2: Run regressions.************************************************************/

tsset year
generate dlempall  = log(employment) - log(L.employment)
generate dlGDP     = log(GDP) - log(L.GDP)
generate ldlGDP    = L.dlGDP
generate lldlGDP   = L.ldlGDP
generate dlraheot = log(earnings*(1000/PPI))-log(L.earnings*(1000/L.PPI))

generate rmwall=nmwall*(1000/PPI)
generate lrmwall=log(rmwall)
generate dlrmwall=lrmwall-L.lrmwall

regress dlempall dlrmwall dlGDP ldlGDP dlraheot if inrange(year, 1996, 2017)
regress dlempall dlrmwall dlGDP ldlGDP dlraheot if inrange(year, 1996, 2020)

