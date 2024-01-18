*(1) data prep 
*(2) histograms <-- (this file)

*!!!CHANGE THESE FILE PATHS TO MATCH WHERE YOU PUT DATA FOLDER!!!
global dir_raw="/Users/.../data/raw"
global dir_output="/Users/.../data/output"

use "$dir_output/playoff data.dta", replace

*histogram of all knockout games
hist total_goals if format<3, discrete by(format, c(1) note("") title("Knockout Game Goals by Tiebreaker")) percent ytitle("Percent of Games") w(1) xtick(0(1)8) xlabel(0(1)8) xsc(range(0 8)) 

graph export "$dir_output/knockout games.png", replace

*Mann-Whitney test of same distributions (fails to reject)
ranksum total if inlist(format,1,2), by(format)


*histogram of all 3 game series
hist total_goals if inrange(format,4,5), discrete by(format, c(1) note("Note: only goals scored in regulation are considered.") title("3 Game Series Goals per Game by Tiebreaker")) percent ytitle("Percent of Games") w(1) xtick(0(1)8) xlabel(0(1)8) xsc(range(0 8)) 

graph export "$dir_output/3 game series.png", replace

*Mann-Whitney test of same distributions (fails to reject)
ranksum total if inlist(series,"First to 5 pts","best of 3"), by(format)

*histogram of all home/away games
hist total_goals if inlist(format,6,8,9), discrete by(format, c(1) note("") title("Home/Away Series Goals per Game by Tiebreaker")) percent ytitle("Percent of Games") w(1) xtick(0(1)7) xlabel(0(1)7) xsc(range(0 7))  

graph export "$dir_output/home-away.png", replace

*Mann-Whitney test of same distributions (fails to reject)
ranksum total if inlist(format,6,8), by(format)
ranksum total if inlist(format,6,9), by(format)
ranksum total if inlist(format,8,9), by(format)


*test single elimination with OT/PKs against everything 
ranksum total if inlist(format,1,2), by(format)
ranksum total if inlist(format,3,2), by(format)
ranksum total if inlist(format,4,2), by(format)
ranksum total if inlist(format,5,2), by(format)
ranksum total if inlist(format,6,2), by(format)
ranksum total if inlist(format,7,2), by(format)
ranksum total if inlist(format,8,2), by(format)
ranksum total if inlist(format,9,2), by(format)

***********************
*Number of games Chart*
***********************
replace count=1
collapse (sum) count, by(year)

*generate min/max possible games for years with 3-game series
gen min=13 if year<2003
gen max=19 if year<2003
replace min=25 if year==2023
replace max=33 if year==2023

*found Stata's default scheme color to use for rcaps (stc1) by typing 
*"viewsource scheme-stcolor.scheme" and looking under histograms
twoway (bar count year) (rcap min max year, lcolor(stc1)), xsc(range(1996 2023)) xlab(1996(1)2023, angle(45) labsize(vsmall)) ysc(range(0 35)) ylab(5(5)35) legend(order(2 "Possible Range") position(6)) xtitle("Year") ytitle("Number of Playoff Games")

graph export "$dir_output/number of games.png", replace
