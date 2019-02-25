libname rcr "C:\Users\cbford\Documents\RACER\SAS Datasets";

************************************ REMOVE DUPLICATES, TEST SUBJECTS, BAD IDs, ETC (based on notes and BI task code) ******************;
****************************************************************************************************************************************;

* first filter out any tests collected outside of testing date windows;
* then apply flags
* then filter based on flags

********** remove_flag KEY:

Flag 1 and 2 = based on notes from team and initial look at data by Cassie for subjects with multiple testing dates
Flag 3 = subjects with more than 30 trials per condition (took test multiple times)
Flag 4 = subjects with fewer than 15 trials per condition - too many missing responses to include

** NOTE: date variable = sessiondate and format is YYYYMMDD;

*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*
*								DATE FILTERS									 *					
*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*;

%macro dates (data=, out=);
proc freq data=&data noprint;
tables ID*sessiondate / list nofreq nocum nopercent out=&out;
run;
%mend dates;

%dates(data=rcr.lb_bi_base, out=lb_bi_base_dates)
%dates(data=rcr.lb_bi_mid, out=lb_bi_mid_dates)
%dates(data=rcr.lb_bi_end, out=lb_bi_end_dates)
;

* check dates before filter;
%macro checkpre (data=, cutoff=);
title "List of LB BI ID's with data before &cutoff";
proc freq data=&data;
tables ID*sessiondate/list;
where sessiondate<&cutoff;
run;
%mend checkpre;

%checkpre(data=lb_bi_base_dates, cutoff=20161114)
%checkpre(data=lb_bi_mid_dates, cutoff=20170327)
%checkpre(data=lb_bi_end_dates, cutoff=20170515)
;

%macro filter (data=, set=, start=, end=);
data &data;
 set &set; 
where &start<=sessiondate<=&end;
run;
%mend filter;

%filter(data=rcr.lb_bi_base_dates, set=rcr.lb_bi_base, start=20161114, end=20161230)
%filter(data=rcr.lb_bi_mid_dates, set=rcr.lb_bi_mid, start=20170227, end=20170327)
%filter(data=rcr.lb_bi_end_dates, set=rcr.lb_bi_end, start=20170515, end=20170601)
;

*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*
*								BASELINE  										 *					
*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*;

*********************************************************
						FLAG 1 & 2					
*********************************************************;
	
* flag subjects based on team notes ;
data rcr.lb_bi_base_flag_a;
set rcr.lb_bi_base_dates;
**rename IDs identified by team;
if ID="RB2728" then ID="RB2827";
if ID="R2434" then ID="RA2434";
if ID="RB2345" then ID="RB2473";
*** flag to remove based on team notes;
if ID in ("R3994", "RA1234", "RB3322", "RB2099", "RA2325",	"RA2325",	"RA2544",	"RA2929",	"RA3039",	"RA3049",	"RA3875",	"RA3875",	"RA4020",	"RA4024",	
"RA4038",	"RA4057",	"RB2099",	"RB2345",	"RB2528",	"RB2554",	"RB2936",	"RB3675",	"RB3874") then remove_flag=1;
else if ID="RA4436" and sessiondate=20161117 then remove_flag=1;
else if ID="RB2134" and sessiondate=20161110 then remove_flag=1;
*** flag to remove based on duplicates -- multiple dates and multiple sessions in a day;
else if ID="RB2650" and sessiondate=20161117 then remove_flag=1;
else if ID="RB2895" and sessiondate=20161202 then remove_flag=1;
else remove_flag=0;
run;

** Look at list of ID's that have remove_flag of 1 or 2;
proc freq data=rcr.lb_bi_base_flag_a; 
tables ID*remove_flag / list;
where remove_flag=1 or remove_flag=2;
run;

proc freq data=rcr.lb_bi_base_flag_a; 
tables remove_flag / list;
run;

*********************************************************
						FLAG 3 					
*********************************************************;
** find people with more than 1 test per day ;
proc freq data=rcr.lb_bi_base_flag_a noprint;
tables ID*sessiondate / list nofreq nocum nopercent out=lb_bi_base_trials_count;
where remove_flag=0;
run;

proc freq data=lb_bi_base_trials_count noprint;
tables ID/ list nofreq nocum nopercent out=lb_bi_base_dup_ids;
run;

*print IDs with tests on more than 1 date;
proc print data=lb_bi_base_dup_ids; 
where count>1;
run;

* Get ID's with more than 60 trials (i.e. more than one test) ;
proc print data=lb_bi_base_trials_count; 
where count > 60; * print people with more than 60 trials;
run;

* from the output, get IDs and paste into next step;

* Print date and time for each ID with duplicates;
proc freq data=rcr.lb_bi_base_flag_a ;
tables ID*sessiondate*sessiondatetime/ list nofreq nocum nopercent ; 
where ID in ("RA2013",	"RA2037",	"RA2391",	"RA2399",	"RA2633",	"RA2648",	"RA2656",	"RA2811",	"RA2867",	
"RA2982",	"RA2991",	"RA3058",	"RA3204",	"RA3778",	"RA3890",	"RA4072",	"RA4127",	"RA4222",	"RA4450",	
"RB2439",	"RB2682",	"RB2892",	"RB2902",	"RB2962",	"RB2989",	"RB3307",	"RB3502",	"RB3521",	"RB3776",	
"RB3836",	"RB4195",	"RB4227");
run;

** removing those with too many trials, flag=3;
* flagging IDs with tests over multiple days or more than 2 tests on single day;
* flagging second of 2 tests on single day;
data rcr.lb_bi_base_flag_b;
set rcr.lb_bi_base_flag_a;
if ID in ("RB21", "RA2013", "RA2037", "RA2982", "RA2648", "RA2811", "RA2991", "RA3204","RA4127", "RA4450", "RB3307" )
	then remove_flag=3;
*** flag code 3 for 2nd of 2 tests for IDs with 2 tests on one day (keeping first test);
else if 
	(ID="RA2391" and sessiondatetime="11:35:49.2030 30 November, 2016") or
	(ID="RA2399" and sessiondatetime="11:24:03.3101 30 November, 2016") or
	(ID="RA2633" and sessiondatetime="09:32:04.0872 02 December, 2016") or
	(ID="RA2656" and sessiondatetime="11:21:59.3866 25 November, 2016") or
	(ID="RA3058" and sessiondatetime="11:37:13.2985 14 November, 2016") or
	(ID="RA3058" and sessiondatetime="12:43:52.5508 14 November, 2016") or
	(ID="RA3778" and sessiondatetime="11:31:58.1120 15 November, 2016") or
	(ID="RA3890" and sessiondatetime="13:00:29.9423 21 November, 2016") or
	(ID="RA4072" and sessiondatetime="10:24:46.8712 21 November, 2016") or
	(ID="RA4222" and sessiondatetime="12:42:54.9984 23 November, 2016") or
	(ID="RB2439" and sessiondatetime="05:05:21.7507 18 November, 2016") or
	(ID="RB2682" and sessiondatetime="13:58:29.2585 18 November, 2016") or
	(ID="RB2892" and sessiondatetime="12:19:29.8839 30 November, 2016") or
	(ID="RB2902" and sessiondatetime="11:07:50.1364 01 December, 2016") or
	(ID="RB2962" and sessiondatetime="10:41:00.8291 15 November, 2016") or
	(ID="RB2989" and sessiondatetime="12:01:23.8565 15 November, 2016") or
	(ID="RB3502" and sessiondatetime="10:08:54.3058 17 November, 2016") or
	(ID="RB3521" and sessiondatetime="10:57:42.8833 18 November, 2016") or
	(ID="RB3776" and sessiondatetime="11:22:09.8892 29 November, 2016") or
	(ID="RB3836" and sessiondatetime="05:42:34.2200 25 November, 2016") or
	(ID="RB4195" and sessiondatetime="05:34:30.8977 02 December, 2016") or
	(ID="RB4227" and sessiondatetime="04:44:02.0504 25 November, 2016") or
	(ID="RA2867" and sessiondatetime="11:44:00.5387 30 November, 2016")
then remove_flag=3;
run;

proc freq data=rcr.lb_bi_base_flag_b; 
tables remove_flag/list;
run;

*********************************************************
						FLAG 4					
*********************************************************
* People with fewer than 15 trials with a response, per condition;
proc sort data=rcr.lb_bi_base_flag_b; by condition; run;

proc freq data=rcr.lb_bi_base_flag_b noprint;
tables ID*sessiondate / list nofreq nocum nopercent out=lb_bi_base_trials_noresponse;
by condition;
where responded_binary=0 and remove_flag=0;
run;
* People with fewer than 15 trials per condition ;
proc print data=lb_bi_base_trials_noresponse; 
where count >= 15; * print people with fewer than 15 responses in a condition;
run;

** removing those with too few trials with response, code = 4;
data rcr.lb_bi_base_flag_c;
set rcr.lb_bi_base_flag_b;
if ID in ("RA2111",	"RA2225",	"RA2383",	"RA2395",	"RA3742",	"RA3832",	"RA3842",	"RA3844",	"RB2669",	"RB2780",	"RB3064",	"RB3194",	"RB3336",	
"RB3383",	"RB3477",	"RB3551",	"RB3664",	"RB3751",	"RB3828",	"RB3876",	"RB4346",	"RA2129",	"RA3854",	"RA4320",	"RA4418",	"RB2724",
"RB2842",	"RB2985",	"RB3523")
then remove_flag=4;
run;

proc freq data=rcr.lb_bi_base_flag_c; 
tables ID / list;
where remove_flag=4;
run;

* check % of data removed by each flag;
proc freq data=rcr.lb_bi_base_flag_c; 
tables remove_flag/ list;
run;

*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*
*								  MIDLINE  										 *					
*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*

*********************************************************
						FLAG 1 & 2					
*********************************************************;

* flag subjects from on team notes ;
data rcr.lb_bi_mid_flag_a;
set rcr.lb_bi_mid_dates;
**rename IDs identified by team;
if ID="RB4688" then ID="RB4687";
else if ID="R2434" then ID="RA2434";
else if ID="R4086" then ID="RA4086";
*** flag to remove from on team notes;
else if ID = "RA000" then remove_flag=1;
else if ID = "RA0000" then remove_flag=1;
*** flag to remove IDs for specific dates from team notes;
if ID="RA2253" and sessiondate=20170303 then remove_flag=1;
else if ID="RA2760" and sessiondate=20170314 then remove_flag=1;
else if ID="RA3805" and sessiondate=20170315 then remove_flag=1;
else if ID="RB2266" and sessiondate=20170317 then remove_flag=1;
else if ID="RB2296" and sessiondate=20170317 then remove_flag=1;
else if ID="RB2708" and sessiondate=20170307 then remove_flag=1;
else if ID="RB3074" and sessiondate=20170315 then remove_flag=1;
else if ID="RB4659" and sessiondate=20170307 then remove_flag=1;
else if ID="RA4178" and sessiondate=20170306 then remove_flag=1;
else if ID="RA4228" and sessiondate=20170315 then remove_flag=1;
else remove_flag=0;
run;

** Look at list of ID's that have remove_flag of 1 or 2;
proc freq data=rcr.lb_bi_mid_flag_a; 
tables ID*remove_flag / list;
where remove_flag=1 or remove_flag=2;
run;

proc freq data=rcr.lb_bi_mid_flag_a; 
tables remove_flag / list;
run;
*********************************************************
						FLAG 3					
*********************************************************;
*people with more than 1 test per day ;
proc freq data=rcr.lb_bi_mid_flag_a noprint;
tables ID*sessiondate / list nofreq nocum nopercent out=lb_bi_mid_trials_count;
where remove_flag=0;
run;

proc freq data=lb_bi_mid_trials_count noprint;
tables ID/ list nofreq nocum nopercent out=lb_bi_mid_dup_ids;
run;

*print IDs with tests on more than 1 date;
proc print data=lb_bi_mid_dup_ids; 
where count>1;
run;

* Get ID's with more than 60 trials (i.e. more than one test) ;
proc print data=lb_bi_mid_trials_count; 
where count > 60; * print people with more than 60 trials;
run;

* Print date and time for each ID with duplicates;
proc freq data=rcr.lb_bi_mid_flag_a ;
tables ID*sessiondate*sessiondatetime/ list nofreq nocum nopercent ; 
where ID in ("RA3155",	"RA3268",	"RA3949",	"RB3357",	"RB3911");
run;

** removing those with too many trials, flag=3;
* flagging IDs with tests over multiple days or more than 2 tests on single day;
* flagging second of 2 tests on single day;
data rcr.lb_bi_mid_flag_b;
set rcr.lb_bi_mid_flag_a;
if ID in ("RA0000", "RA000")
	then remove_flag=3;
*** flag code 3 for 2nd of 2 tests for IDs with 2 tests on one day (keeping first test);
else if 
	(ID="RA3155" and sessiondatetime="11:53:56.0936 02 March, 2017") or
	(ID="RA3268" and sessiondatetime="12:59:39.4280 28 February, 2017") or
	(ID="RA3949" and sessiondatetime="14:02:46.6751 28 February, 2017") or
	(ID="RB3357" and sessiondatetime="12:29:02.0187 27 February, 2017") or
	(ID="RB3911" and sessiondatetime="10:50:13.6703 14 March, 2017") 
then remove_flag=3;
run;

proc freq data=rcr.lb_bi_mid_flag_b; 
tables remove_flag / list;
run;

*********************************************************
						FLAG 4					
*********************************************************;

* People with fewer than 15 trials with a response, per condition;
proc sort data=rcr.lb_bi_mid_flag_b; by condition; run;
proc freq data=rcr.lb_bi_mid_flag_b noprint;
tables ID*sessiondate / list nofreq nocum nopercent out=lb_bi_mid_trials_noresponse;
by condition;
where responded_binary=0 and remove_flag=0;
run;
* People with fewer than 15 trials per condition ;
proc print data=lb_bi_mid_trials_noresponse; 
where count >= 15; * print people with fewer than 15 responses in a condition;
run;

** removing those with too few trials with response, code = 4;
data rcr.lb_bi_mid_flag_c;
set rcr.lb_bi_mid_flag_b;
if ID in ("RA3850",	"RA3920",	"RA4093",	"RA4228",	"RB2278",	"RB2447",	"RB2623",	"RB2846",
"RB2996",	"RB3383",	"RB3403",	"RB4369",	"RB4642",	"RB4672",	"RB4752",	"RB4757",	"RA3133")
then remove_flag=4;
run;

proc freq data=rcr.lb_bi_mid_flag_c; 
tables ID / list;
where remove_flag=4;
run;

* check % of data removed by each flag;
proc freq data=rcr.lb_bi_mid_flag_c; 
tables remove_flag/ list;
run;

*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*
*								  ENDLINE  										 *					
*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*

*********************************************************
						FLAG 1 & 2					
*********************************************************;

proc print data=rcr.lb_bi_end_dates; 
var ID;
where id in ("R2205", "RA000", "RA0000");
run;

* flag subjects from on team notes ;
data rcr.lb_bi_end_flag_a;
set rcr.lb_bi_end_dates;
**rename IDs identified by team;
if ID="R2205" then ID="RB2205";
*** flag to remove from on team notes;
if ID ="RA000" then remove_flag=1;
else if ID ="RA0000" then remove_flag=1;
*** flag to remove IDs for specific dates from team notes;
*if ID="" and sessiondate= then remove_flag=1;
*else if ID="" and sessiondate= then remove_flag=1;
else remove_flag=0;
run;

** Look at list of ID's that have remove_flag of 1 or 2;
proc freq data=rcr.lb_bi_end_flag_a; 
tables ID*remove_flag / list;
where remove_flag=1 or remove_flag=2;
run;

proc freq data=rcr.lb_bi_end_flag_a; 
tables remove_flag / list;
run;
*********************************************************
						FLAG 3					
*********************************************************;

*people with too many trials;
*people with more than 1 test per day ;
proc freq data=rcr.lb_bi_end_flag_a noprint;
tables ID*sessiondate / list nofreq nocum nopercent out=lb_bi_end_trials_count;
where remove_flag=0;
run;

proc freq data=lb_bi_end_trials_count noprint;
tables ID/ list nofreq nocum nopercent out=lb_bi_end_dup_ids;
run;

*print IDs with tests on more than 1 date;
proc print data=lb_bi_end_dup_ids; 
where count>1;
run;

* Get ID's with more than 60 trials (i.e. more than one test) ;
proc print data=lb_bi_end_trials_count; 
where count > 60; * print people with more than 60 trials;
run;

* Print date and time for each ID with duplicates;
proc freq data=rcr.lb_bi_end_flag_a ;
tables ID*sessiondate*sessiondatetime/ list nofreq nocum nopercent ; 
where ID in ("RA2460",	"RA4203",	"RA4774",	"RA4803",	"RB2090",	"RB2592",	"RB4458",	"RA3483",	
"RA3696",	"RA4086",	"RB2007",	"RB2179",	"RB3529",	"RB3904",	"RB4220");
run;

** removing those with too many trials, flag=3;
* flagging IDs with tests over multiple days or more than 2 tests on single day;
* flagging second of 2 tests on single day;
data rcr.lb_bi_end_flag_b;
set rcr.lb_bi_end_flag_a;
*** flag code 3 for 2nd of 2 tests for IDs with 2 tests on one day (keeping first test);
if 
	(ID="RA2460" and sessiondatetime="10:52:47.4967 30 May, 2017") or
	(ID="RA3483" and sessiondatetime="13:39:31.5566 22 May, 2017") or
	(ID="RA3696" and sessiondatetime="11:07:23.8558 26 May, 2017") or
	(ID="RA4086" and sessiondatetime="11:16:26.2063 29 May, 2017") or
	(ID="RA4203" and sessiondatetime="10:28:46.4534 23 May, 2017") or
	(ID="RA4774" and sessiondatetime="13:17:21.2657 31 May, 2017") or
	(ID="RA4803" and sessiondatetime="13:01:45.5225 25 May, 2017") or
	(ID="RB2007" and sessiondatetime="05:30:14.6004 22 May, 2017") or
	(ID="RB2090" and sessiondatetime="13:51:23.2424 22 May, 2017") or
	(ID="RB2179" and sessiondatetime="13:42:33.6536 23 May, 2017") or
	(ID="RB2592" and sessiondatetime="12:18:13.7926 22 May, 2017") or
	(ID="RB3529" and sessiondatetime="05:05:57.7431 17 May, 2017") or
	(ID="RB3904" and sessiondatetime="09:48:44.8940 30 May, 2017") or
	(ID="RB4220" and sessiondatetime="10:14:43.2162 25 May, 2017") or
	(ID="RB4458" and sessiondatetime="14:46:19.8214 24 May, 2017") 
then remove_flag=3;
run;

proc freq data=rcr.lb_bi_end_flag_b; 
tables ID / list;
where remove_flag=3;
run;

proc freq data=rcr.lb_bi_end_flag_b; 
tables remove_flag / list;
run;

*********************************************************
						FLAG 4					
*********************************************************;

* People with fewer than 15 trials with a response, per condition;
proc sort data=rcr.lb_bi_end_flag_b; by condition; run;
proc freq data=rcr.lb_bi_end_flag_b noprint;
tables ID*sessiondate / list nofreq nocum nopercent out=lb_bi_end_trials_noresponse;
by condition;
where responded_binary=0 and remove_flag=0;
run;
* People with fewer than 15 trials per condition ;
proc print data=lb_bi_end_trials_noresponse; 
where count >= 15; * print people with fewer than 15 responses in a condition;
run;

** removing those with too few trials with response, code = 4;
data rcr.lb_bi_end_flag_c;
set rcr.lb_bi_end_flag_b;
if ID in ("RA2237",	"RA2335",	"RA2618",	"RA2643",	"RA3369",	"RA3698",	"RA3906",	"RA4863",	"RB2669",	
"RB2764",	"RB3529",	"RB3699",	"RB3736",	"RB4463",	"RB4502",	"RB4705",	"RA2330",	"RA3133",	"RA3449")
then remove_flag=4;
run;

proc freq data=rcr.lb_bi_end_flag_c; 
tables ID / list;
where remove_flag=4;
run;

proc freq data=rcr.lb_bi_end_flag_c; 
tables remove_flag;
run;

*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*
*								CHECK & CREATE NEW DATASETS 										*				
*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*;

*** Sort datasets by flag number;
%macro sortflagged (data=);
proc sort data=&data; 
by remove_flag; 
run;
%mend sortflagged;

%sortflagged(data=rcr.lb_bi_base_flag_c)
%sortflagged(data=rcr.lb_bi_mid_flag_c)
%sortflagged(data=rcr.lb_bi_end_flag_c)
;

*** Examine how many subjects will be removed with each flag;
%macro freqflags (data=);
proc freq data=&data;
tables remove_flag/ list;
run;
%mend freqflags;

%freqflags(data=rcr.lb_bi_base_flag_c)
%freqflags(data=rcr.lb_bi_mid_flag_c)
%freqflags(data=rcr.lb_bi_end_flag_c)
;

*** Create "clean" dataset without flagged subjects;
%macro removeflags (data=, set=);
data &data ;
set &set ;
where remove_flag=0;
run;
%mend removeflags;

%removeflags (data=rcr.lb_bi_base_cleaned, set=rcr.lb_bi_base_flag_c) 
%removeflags (data=rcr.lb_bi_mid_cleaned, set=rcr.lb_bi_mid_flag_c) 
%removeflags (data=rcr.lb_bi_end_cleaned, set=rcr.lb_bi_end_flag_c)
;

