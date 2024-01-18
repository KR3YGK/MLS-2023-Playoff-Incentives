*(1) data prep.do <-- (this file)
*(2) histograms.do

*!!!CHANGE THESE FILE PATHS TO MATCH WHERE YOU PUT DATA FOLDER!!!
global dir_raw="/Users/.../data/raw"
global dir_output="/Users/.../data/output"

*****
*MLS*
*****

*data from https://fbref.com/en/comps/22/schedule/Major-League-Soccer-Scores-and-Fixtures

import excel "/$dir_raw/MLS Playoffs.xlsx", sheet("Sheet1") firstrow clear 

*regexs(0) is the stored returned part of the string matching what regexm was looking for (here, a number followed by a dash followed by a number). This code removes the PK scores in parenthesis when they exist.
replace score=regexs(0) if(regexm(score, "[0-9]-[0-9]"))

split score, p("-")
destring score?, replace
rename (score1 score2) (home_score away_score)

*************************************
*Generate indicator for playoff type*
*only refers to rules of first round*
*where all teams in playoffs play.  *
*************************************

*info on playoffs 1996-2015
*https://www.mlssoccer.com/news/audi-mls-cup-playoffs-tracing-evolution-postseason-format

gen year=year(date)


***********
*1996-1999*
***********

*3 game series for first round, no ties-->PKs 
*(PKs were diff 1996-1999 so may want to consider treating this as diff format)

gen scenario=(inrange(year,1996,1999) & substr(round,1,7)!="MLS Cup")

gen series="best of 3" if scenario
gen game_tie="PK" if scenario
gen series_tie="N/A" if scenario

replace scenario=(inrange(year,1996,1999) & substr(round,1,7)=="MLS Cup")

replace series="1 game" if scenario
replace game_tie="GG-PK" if scenario
replace series_tie="N/A" if scenario



************
*2000-20002*
************

*3 game series, first to 5 pts wins, tied games attempted to settle w/ OT, if series tied 4 pts each after game 3 --> golden goal OT. If neither team scores, not sure what would've happened. 

*https://web.archive.org/web/20011118141434/http://www.mlsnet.com/content/01/spot0927playoffs.html
replace scenario=inrange(year,2000,2002) & substr(round,1,7)!="MLS Cup"

replace series="First to 5 pts" if scenario
replace game_tie="GG-tie" if scenario
replace series_tie="GG-PK" if scenario

replace scenario=inrange(year,2000,2002) & substr(round,1,7)=="MLS Cup"

replace series="1 game" if scenario
replace game_tie="GG-PK" if scenario
replace series_tie="N/A" if scenario



******
*2003*
******

*useful clarifying info
*https://web.archive.org/web/20031003061715/http://www.mlsnet.com/special/mlscup/2003/mlscuppo_format.html

*home/away, if series tied --> agg goals --> golden goal ET
replace scenario=year==2003 & round=="Conference Semifinals"

replace series="home/away" if scenario
replace game_tie="tie" if scenario
replace series_tie="Agg-GG-PK" if scenario

replace scenario=year==2003 & inlist(round, "Conference Finals", "MLS Cup 2003")

replace series="1 game" if scenario
replace game_tie="GG-PK" if scenario
replace series_tie="N/A" if scenario



***********
*2004-2010*
***********

replace scenario=inrange(year,2004,2010) & round=="Conference Semifinals"

replace series="home/away" if scenario
replace game_tie="tie" if scenario
replace series_tie="OT-PK" if scenario

replace scenario=inrange(year,2004,2010) & round!="Conference Semifinals"

replace series="1 game" if scenario
replace game_tie="OT-PK" if scenario
replace series_tie="N/A" if scenario



******
*2011*
******

*useful clarifying info
*https://web.archive.org/web/20111008023028/http://www.mlssoccer.com/competition-rules-and-regulations

replace scenario=inrange(year,2011,2011) & round=="Conference Semifinals"

replace series="home/away" if scenario
replace game_tie="tie" if scenario
replace series_tie="Agg-OT-PK" if scenario

replace scenario=inrange(year,2011,2011) & round!="Conference Semifinals"

replace series="1 game" if scenario
replace game_tie="OT-PK" if scenario
replace series_tie="N/A" if scenario


***********
*2012-2013*
***********

replace scenario=inrange(year,2012,2013) & inlist(round,"Conference Semifinals", "Conference Finals")

replace series="home/away" if scenario
replace game_tie="tie" if scenario
replace series_tie="Agg-OT-PK" if scenario

replace scenario=inrange(year,2012,2013) & !inlist(round,"Conference Semifinals", "Conference Finals")

replace series="1 game" if scenario
replace game_tie="OT-PK" if scenario
replace series_tie="N/A" if scenario


***********
*2014-2018*
***********

replace scenario=inrange(year,2014,2018) & inlist(round,"Conference Semifinals", "Conference Finals")

replace series="home/away" if scenario
replace game_tie="tie" if scenario
replace series_tie="AG-OT-PK" if scenario

replace scenario=inrange(year,2014,2018) & !inlist(round,"Conference Semifinals", "Conference Finals")

replace series="1 game" if scenario
replace game_tie="OT-PK" if scenario
replace series_tie="N/A" if scenario

***********
*2019-2022*
***********

replace scenario=inrange(year,2019,2022)

replace series="1 game" if scenario
replace game_tie="OT-PK" if scenario
replace series_tie="N/A" if scenario


******
*2023*
******

replace scenario=year==2023 & round=="Wild Card Round"

replace series="1 game" if scenario
replace game_tie="PK" if scenario
replace series_tie="N/A" if scenario

replace scenario=year==2023 & round=="Round One"

replace series="best of 3" if scenario
replace game_tie="PK" if scenario
replace series_tie="N/A" if scenario

replace scenario=year==2023 & round=="Round One"

replace series="best of 3" if scenario
replace game_tie="PK" if scenario
replace series_tie="N/A" if scenario

replace scenario=year==2023 & !inlist(round,"Wild Card Round","Round One")

replace series="1 game" if scenario
replace game_tie="OT-PK" if scenario
replace series_tie="N/A" if scenario

sort date
br year round series game_tie series_tie 

gen total_goals=home_score+away_score
label var total_goals "Total Goals in a Game"

	*remove goals scored in overtime for first-to-5-pts matches since I use that graph
	*note: other years may have goals scored in OT but those years not used here
	replace total_goals=total_goals-1 if home=="MetroStars" & date==date("9/15/2000","MD20Y")
	replace total_goals=total_goals-1 if home=="LA Galaxy" & inlist(date,date("10/3/2000","MD20Y"), date("9/29/2001","MD20Y"), date("10/13/2001","MD20Y"),date("9/25/2002","MD20Y"))
	replace total_goals=total_goals-1 if home=="Chicago Fire" & date==date("10/17/2001","MD20Y")
	replace total_goals=total_goals-1 if home=="Miami Fusion" & date==date("10/10/2001","MD20Y")
	replace total_goals=total_goals-1 if home=="Dallas Burn" & date==date("10/2/2002","MD20Y")



*format variable for format of game/series
egen format=group(series game_tie series_tie)
sum format
*F is total number of formats
local F=r(max)

*count observations by format
gen count=.
forval f=1/`F'{
	count if format==`f'
	replace count=r(N) if format==`f'
}

*label formats
label define format_lbl 1 "Golden Goal > PK (10 games)" 2 "OT > PK (111 games)" 3 "PK (2 games)" 4 "First to 5pts - Golden Goal > tie (49 games)" 5 "PK (75 games)" 6 "Away Goals > OT > PK (60 games)" 7 "Aggretate Goals > Golden Goal > PK" 8 "Aggregate Goals > OT > PK (32 games)" 9 "OT > PK (56 games)"
label values format format_lbl

*data used to create histograms
save "$dir_output/playoff data.dta", replace


***************************
*Regular Season Attendance*
***************************

*data from https://fbref.com/en/comps/22/schedule/Major-League-Soccer-Scores-and-Fixtures
import excel "$dir_raw/MLS Regular Season 2023.xlsx", sheet("Sheet1") firstrow case(lower) clear

gen count=1

collapse ave_attendance=attendance (sum) count, by(home)

	sum count
	assert r(min)==r(max)
	drop count

merge 1:m home using "$dir_output/playoff data.dta", keep(3)

keep if year==2023

gen att_diff=attendance-ave_attendance
sort att_diff

*stadium capacity
gen capacity=.
replace capacity=73019 if home=="Atlanta Utd"
replace capacity=20371 if home=="Columbus Crew"
replace capacity=74867 if home=="Charlotte"
replace capacity=22039 if home=="Dynamo FC" 
replace capacity=25513 if home=="FC Cincinnati" 
replace capacity=19096 if home=="FC Dallas" 
replace capacity=22000 if home=="Los Angeles FC" 
replace capacity=25000 if home=="NY Red Bulls" 
replace capacity=30000 if home=="Nashville" 
replace capacity=65878 if home=="New England" 
replace capacity=25500 if home=="Orlando City" 
replace capacity=18500 if home=="Philadelphia" 
replace capacity=20213 if home=="Real Salt Lake"
replace capacity=18000 if home=="San Jose" 
replace capacity=68740  if home=="Seattle" 
replace capacity=18467 if home=="Sporting KC" 
replace capacity=22423 if home=="St. Louis" 
replace capacity=54500 if home=="Vancouver" 


gen games=1
collapse (min) ave_attendance capacity (sum) attendance games, by(home)

gen pct_capacity=100*attendance/(games*capacity)
gen ave_capacity=100*ave_attendance/capacity


gsort -pct_capacity

*data used in Tableau graph
export delimited using "$dir_output/attendance data.csv", replace
