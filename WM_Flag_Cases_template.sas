libname rcr "C:\Users\cbford\Documents\RACER\SAS Datasets";

***** WORKING MEMORY (WM) TASK FLAG BAD CASES/ERROS & FIX IDs,  *********;

********** FILES FROM FIRST DATA CLEAN STEPS: 
rcr.lb_wm_base_newdist3
rcr.lb_wm_mid_newdist3
rcr.lb_wm_end_newdist3

************************************ REMOVE DUPLICATES, TEST SUBJECTS, BAD IDs, ETC (based on notes and BI task code) ******************;
****************************************************************************************************************************************;

* first filter out any tests collected outside of testing date windows;
* then apply flags
* then filter based on flags

********** remove_flag KEY:

Flag 1 and 2 = based on notes from team and initial look at data by Cassie for subjects with multiple testing dates
Flag 3 = subjects with more than 33 trials (indicating more than 1 test taken) (not already flagged)
Flag 4 = subjects with all trials (4 or 7) missing for any one of the 6 load/delay combos (not already flagged)
;

** NOTE: date variable = sessiondate and format is YYYYMMDD;

*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*
*								DATE FILTERS									 *					
*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*;

%macro dates (data=, out=);
proc freq data=&data noprint;
tables ID*sessiondate / list nofreq nocum nopercent out=&out;
run;
%mend dates;

%dates(data=rcr.lb_wm_base_newdist3, out=lb_wm_base_dates)
%dates(data=rcr.lb_wm_mid_newdist3, out=lb_wm_mid_dates)
%dates(data=rcr.lb_wm_end_newdist3, out=lb_wm_end_dates)
;

* check dates before filter;
%macro checkpre (data=, cutoff=);
title "List of &data ID's with data before &cutoff";
proc freq data=&data;
tables ID*sessiondate/list;
where sessiondate<&cutoff;
run;
%mend checkpre;

%checkpre(data=lb_wm_base_dates, cutoff=20161114)
%checkpre(data=lb_wm_mid_dates, cutoff=20170227)
%checkpre(data=lb_wm_end_dates, cutoff=20170515)
;

%macro filter (data=, set=, start=, end=);
data &data;
 set &set; 
where &start<=sessiondate<=&end;
run;
%mend filter;

%filter(data=rcr.lb_wm_base_dates, set=rcr.lb_wm_base_newdist3, start=20161114, end=20161230)
%filter(data=rcr.lb_wm_mid_dates, set=rcr.lb_wm_mid_newdist3, start=20170227, end=20170327)
%filter(data=rcr.lb_wm_end_dates, set=rcr.lb_wm_end_newdist3, start=20170515, end=20170601)
;

*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*
*								BASELINE  										 *					
*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*;

*********************************************************
*						FLAG 1 & 2						*					
*********************************************************;

*flag subjects based on team notes and pivot table info (multiple dates per subject);
proc freq data=rcr.lb_wm_base_dates;
tables id*sessiondate / list;
where ID in ("RA1234", 	"RA2013", 	"RA2153", 	"RA2325", 	"RA2544", 	"RA2648", 	"RA2929", 	"RA3039", 	"RA3049", 	"RA3875", 	"RA4020", 	
"RA4024", 	"RA4038", 	"RA4057", 	"RA4127", 	"RA4436", 	"RA4450", 	"RB2099", 	"RB2134", 	"RB2345", 	"RB2518", 	"RB2528", 	"RB2534", 	
"RB2553", 	"RB2554", 	"RB2650", 	"RB2895", 	"RB2936", 	"RB3322", 	"RB3627", 	"RB3675", 	"RB3874", 	"RB3883", 	"RB4021", 	"RB4039", 	"RB4415");
run;

** STEP 2: flag subjects based on team notes and pivot table info (multiple dates per subject);
data rcr.lb_wm_base_dates_flag_a;
set rcr.lb_wm_base_dates;
**rename IDs identified by team;
if ID="RB2728" then ID="RB2827";
if ID="R2434" then ID="RA2434";
if ID="RB2345" then ID="RB2473";
*** flag to remove based on team notes;
if ID in ("R3994", "RA1234", "RB3322", "RB2099", "RA2325",	"RA2325",	"RA2544",	"RA2929",	"RA3039",	"RA3049",	"RA3875",	"RA3875",	"RA4020",	"RA4024",	
"RA4038",	"RA4057",	"RB2099",	"RB2345",	"RB2528",	"RB2554",	"RB2936",	"RB3675",	"RB3874", "RA2153", "RB3627", "RB4415") then remove_flag=1;
else if ID="RA4436" and sessiondate=20161117 then remove_flag=1;
else if ID="RB2134" and sessiondate=20161110 then remove_flag=1;
*** flag to remove based on duplicates -- multiple dates and multiple sessions in a day;
else if ID="RB2650" and sessiondate=20161117 then remove_flag=2;
else if ID="RB2895" and sessiondate=20161202 then remove_flag=2;
else if ID="RB4007" then remove_flag=2; *bad screen resolution;
else remove_flag=0;
run;

** Look at list of ID's that have remove_flag of 1 or 2;
proc freq data=rcr.lb_wm_base_dates_flag_a; 
tables ID / list;
where remove_flag=1 or remove_flag=2;
run;

proc freq data=rcr.lb_wm_base_dates_flag_a; 
tables remove_flag/ list;
run;

*********************************************************
*						FLAG 3 							*					
*********************************************************;

*Look at number of trial responses per subject for those not flagged above;
*if more than 33, then took test multiple times;
*if timed_out=33 then didn't respond to any;

proc freq data=rcr.lb_wm_base_dates_flag_a noprint;
tables ID*sessiondate / list nofreq nocum nopercent out=lb_wm_trial_count;
where remove_flag=0;
run;

proc freq data=lb_wm_trial_count noprint;
tables ID/ list nofreq nocum nopercent out=lb_wm_base_dup_ids;
run;

*print IDs with tests on more than 1 date;
proc print data=lb_wm_base_dup_ids; 
where count>1;
run;

* Get ID's with more than 33 trials (i.e. more than one test) ;
proc print data=lb_wm_trial_count; 
where count >33; * print people with more than 30 responses in a condition;
run;

* Print date and time for each ID with duplicates ;
proc freq data=rcr.lb_wm_base_dates_flag_a ;
tables ID*sessiondate*sessiondatetime/ list nofreq nocum nopercent ; 
where ID in ("RA3785", "RA2013", 	"RA2037", 	"RA2391", 	"RA2399", 	"RA2633", 	"RA2648", 	"RA2656", 	"RA2811", 	"RA2867", 	"RA2982", 	"RA2991", 	"RA3058", 
"RA3204", 	"RA3778", 	"RA3890", 	"RA4072", 	"RA4127", 	"RA4222", 	"RA4450", 	"RB2439", 	"RB2682", 	"RB2892", 	"RB2902", 	"RB2962", 	"RB2989",
"RB3307", 	"RB3502", 	"RB3521", 	"RB3776", 	"RB3836", 	"RB4195", 	"RB4227");
run;

proc freq data=rcr.lb_wm_base_dates_flag_a ;
tables ID*sessiondate*sessiondatetime/ list nofreq nocum nopercent ; 
where ID ="RA3785";
run;

*** TIP: copy and paste output of above into excel and then run pivot table to evaluate for next step ****;

** removing those with too many trials, flag=3;
* flagging IDs with tests over multiple days or more than 2 tests on single day;
* flagging second of 2 tests on single day;
data rcr.lb_wm_base_dates_flag_b;
set rcr.lb_wm_base_dates_flag_a;
if ID in ("RA4450",	"RA2013",	"RA4127",	"RA2648",	"RA2811",	"RA3204",	"RA2037",	"RA2982",	"RA2991",	"RB3307")
	then remove_flag=3;
*** flag code 3 for 2nd of 2 tests for IDs with 2 tests on one day (keeping first test);
else if 
	(ID="RA2391" and sessiondatetime="11:35:49.2030 30 November, 2016") or 
	(ID="RA2399" and sessiondatetime="11:24:03.3101 30 November, 2016") or 
	(ID="RA2633" and sessiondatetime="09:32:04.0872 02 December, 2016") or 
	(ID="RA2656" and sessiondatetime="11:21:59.3866 25 November, 2016") or 
	(ID="RA2867" and sessiondatetime="11:44:00.5387 30 November, 2016") or 
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
	(ID="RA3785" and sessiondatetime="09:52:06.7960 16 November, 2016") 
then remove_flag=3;
run;

proc freq data=rcr.lb_wm_base_dates_flag_b; 
tables ID / list;
where remove_flag=3;
run;

proc freq data=rcr.lb_wm_base_dates_flag_b; 
tables remove_flag/ list;
run;

proc print data=rcr.lb_wm_base_dates_flag_a;
where ID="RA3785";
run;

*********************************************************
*						FLAG 4 							*					
*********************************************************;

*People with too many Timed Out responses *;
*all trials missing from one of the following 6 conditions (FLAG 4)
	* load=1 or 2 or 3 (11 each)
	* delay=0 (12)
	* delay=3 (21)
;

%macro getmissingLOAD (out=, load=);
proc freq data=rcr.lb_wm_base_dates_flag_b noprint;
tables ID*sessiondate / list nofreq nocum nopercent out=&out;
where timedout_outcome="Timed Out" and remove_flag=0 and load=&load;
run;
%mend getmissingLOAD;

%getmissingLOAD(out=lb_L1, load=1)
%getmissingLOAD(out=lb_L2, load=2)
%getmissingLOAD(out=lb_L3, load=3)
;

%macro getmissingDELAY (out=, delay=);
proc freq data=rcr.lb_wm_base_dates_flag_b noprint;
tables ID*sessiondate / list nofreq nocum nopercent out=&out;
where timedout_outcome="Timed Out" and remove_flag=0 and delay=&delay;
run;
%mend getmissingDELAY;

%getmissingDELAY(out=lb_D0, delay=0)
%getmissingDELAY(out=lb_D3, delay=3)
;

%macro getID(data=, set=, count=);
data &data;
set &set;
where count = &count; 
run;
%mend getID;

%getID(data=lb_L1_count, set=lb_L1,  count=11 )
%getID(data=lb_L2_count, set=lb_L2,  count=11 )
%getID(data=lb_L3_count, set=lb_L3,  count=11 )
%getID(data=lb_D0_count, set=lb_D0,  count=12 )
%getID(data=lb_D3_count, set=lb_D3,  count=21 )
;

%macro sort(data);
proc sort data=&data;
by id;
run;
%mend sort ;

%sort(data=lb_L1_count)
%sort(data=lb_L2_count)
%sort(data=lb_L3_count)
%sort(data=lb_D0_count)
%sort(data=lb_D3_count)
;

* Merge all missing datasets;
data lb_missing;
merge lb_L1_count	lb_L2_count	lb_L3_count	lb_D0_count	lb_D3_count;
by id;
run;

*print IDs to flag in next step;
proc print data=lb_missing;
run;

data rcr.lb_wm_base_dates_flag_c;
set rcr.lb_wm_base_dates_flag_b;
if ID in (
"RA2163", 	"RA2327", 	"RA2331", 	"RA2383", 	"RA2681", 	"RA2814", 	"RA2956", 	"RA3548", 	"RA3638", 	"RA3719", 
"RA3723", 	"RA3742", 	"RA3832", 	"RA3842", 	"RA3844", 	"RA3890", 	"RA4101", 	"RA4113", 	"RA4199", 	"RA4269", 
"RA4324", 	"RA4340", 	"RA4346", 	"RB2000", 	"RB2052", 	"RB2140", 	"RB2192", 	"RB2383", 	"RB2404", 	"RB2406", 
"RB2518", 	"RB2534", 	"RB2535", 	"RB2553", 	"RB2568", 	"RB2669", 	"RB2724", 	"RB2830", 	"RB2833", 	"RB2886", 
"RB2932", 	"RB3456", 	"RB3477", 	"RB3527", 	"RB3551", 	"RB3594", 	"RB3596", 	"RB3611", 	"RB3647", 	"RB3664", 
"RB3702", 	"RB3741", 	"RB3772", 	"RB3785", 	"RB3828", 	"RB3840", 	"RB3876", 	"RB3904", 	"RB3924", 	"RB3926", 
"RB3930", 	"RB3957", 	"RB3967", 	"RB4021", 	"RB4022", 	"RB4039", 	"RB4056", 	"RB4111", 	"RB4168", 	"RB4234", 	
"RB4270", 	"RB4280", 	"RB4327", 	"RB4458", 	"RB4464", 	"RB4465", 	"RB4470", 	"RB4485", 	"RB4487") 
then remove_flag=4;
run;

proc freq data=rcr.lb_wm_base_dates_flag_c; 
tables remove_flag/list;
run;

*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*
*								MIDLINE  										 *					
*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*;

*********************************************************
*						FLAG 1 & 2						*					
*********************************************************;

* flag subjects from on team notes ;
data rcr.lb_wm_mid_dates_flag_a;
set rcr.lb_wm_mid_dates;
**rename IDs identified by team;
if ID="RB4688" then ID="RB4687";
else if ID="R2434" then ID="RA2434";
else if ID="R4086" then ID="RA4086";
*** flag to remove from on team notes;
else if ID="RA000" then remove_flag=1;
else if ID="RA0000" then remove_flag=1;
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
* remove all records collected before 2/1/2017, not midline;
else if sessiondate<=20170201 then remove_flag=1;
else remove_flag=0;
run;

proc freq data=rcr.lb_wm_mid_dates_flag_a; 
tables remove_flag/ list;
run;

proc freq data=rcr.lb_wm_mid_dates_flag_a; 
tables ID / list;
where remove_flag=1;
run;

*********************************************************
*						FLAG 3 							*					
*********************************************************;

*Look at number of trial responses per subject for those not flagged above;
*if more than 33, then took test multiple times;
*if timed_out=33 then didn't respond to any;

proc freq data=rcr.lb_wm_mid_dates_flag_a noprint;
tables ID*sessiondate / list nofreq nocum nopercent out=lb_wm_mid_trial_count;
where remove_flag=0;
run;

proc freq data=lb_wm_mid_trial_count noprint;
tables ID/ list nofreq nocum nopercent out=lb_wm_mid_dup_ids;
run;

*print IDs with tests on more than 1 date;
proc print data=lb_wm_mid_dup_ids; 
where count>1;
run;

* Get ID's with more than 33 trials (i.e. more than one test) ;
proc print data=lb_wm_mid_trial_count; 
where count >33; * print people with more than 30 responses in a condition;
run;

* Print date and time for each ID with duplicates ;
proc freq data=rcr.lb_wm_mid_dates_flag_a ;
tables ID*sessiondate*sessiondatetime/ list nofreq nocum nopercent ; 
where ID in ("RA3155",	"RA3268",	"RA3949",	"RB2278",	"RB3111",	"RB3337",	
"RB3357",	"RB3911",	"RB4125");
run;

*** TIP: copy and paste output of above into excel and then run pivot table to evaluate for next step ****;

** removing those with too many trials, flag=3;
* flagging IDs with tests over multiple days or more than 2 tests on single day;
* flagging second of 2 tests on single day;
data rcr.lb_wm_mid_dates_flag_b;
set rcr.lb_wm_mid_dates_flag_a;
*** flag code 3 for 2nd of 2 tests for IDs with 2 tests on one day (keeping first test);
if 
	(ID="RA3155" and sessiondatetime="11:53:56.0936 02 March, 2017") or
	(ID="RA3268" and sessiondatetime="12:46:40.8824 28 February, 2017") or
	(ID="RA3949" and sessiondatetime="11:56:46.2435 28 February, 2017") or
	(ID="RB2278" and sessiondatetime="11:24:14.8505 10 March, 2017") or
	(ID="RB3111" and sessiondatetime="08:29:25.2002 07 March, 2017") or
	(ID="RB3337" and sessiondatetime="11:05:47.6703 27 February, 2017") or
	(ID="RB3357" and sessiondatetime="11:40:52.9782 27 February, 2017") or
	(ID="RB3911" and sessiondatetime="10:26:12.7575 14 March, 2017") or
	(ID="RB4125" and sessiondatetime="11:45:56.8900 08 March, 2017") 
then remove_flag=3;
run;

proc freq data=rcr.lb_wm_mid_dates_flag_b; 
tables ID / list;
where remove_flag=3;
run;

proc freq data=rcr.lb_wm_mid_dates_flag_b; 
tables remove_flag/ list;
run;

*********************************************************
*						FLAG 4 							*					
*********************************************************;

*People with too many Timed Out responses *;
*all trials missing from one of the following 6 conditions (FLAG 4)
	* load=1 or 2 or 3 (11 each)
	* delay=0 (12)
	* delay=3 (21)
;

%macro getmissingLOAD (out=, load=);
proc freq data=rcr.lb_wm_mid_dates_flag_b noprint;
tables ID*sessiondate / list nofreq nocum nopercent out=&out;
where timedout_outcome="Timed Out" and remove_flag=0 and load=&load;
run;
%mend getmissingLOAD;

%getmissingLOAD(out=lb_L1, load=1)
%getmissingLOAD(out=lb_L2, load=2)
%getmissingLOAD(out=lb_L3, load=3)
;

%macro getmissingDELAY (out=, delay=);
proc freq data=rcr.lb_wm_mid_dates_flag_b noprint;
tables ID*sessiondate / list nofreq nocum nopercent out=&out;
where timedout_outcome="Timed Out" and remove_flag=0 and delay=&delay;
run;
%mend getmissingDELAY;

%getmissingDELAY(out=lb_D0, delay=0)
%getmissingDELAY(out=lb_D3, delay=3)
;

%macro getID(data=, set=, count=);
data &data;
set &set;
where count = &count; 
run;
%mend getID;

%getID(data=lb_L1_count, set=lb_L1,  count=11 )
%getID(data=lb_L2_count, set=lb_L2,  count=11 )
%getID(data=lb_L3_count, set=lb_L3,  count=11 )
%getID(data=lb_D0_count, set=lb_D0,  count=12 )
%getID(data=lb_D3_count, set=lb_D3,  count=21 )
;

%macro sort(data);
proc sort data=&data;
by id;
run;
%mend sort ;

%sort(data=lb_L1_count)
%sort(data=lb_L2_count)
%sort(data=lb_L3_count)
%sort(data=lb_D0_count)
%sort(data=lb_D3_count)
;

* Merge all missing datasets;
data lb_missing;
merge lb_L1_count	lb_L2_count	lb_L3_count	lb_D0_count	lb_D3_count;
by id;
run;

*print IDs to flag in next step;
proc print data=lb_missing;
run;

data rcr.lb_wm_mid_dates_flag_c;
set rcr.lb_wm_mid_dates_flag_b;
if ID in ("RA3601",	"RA3797",	"RA4026",	"RA4141",	"RA4215",	"RA4221",	"RA4511",	"RA4570",	"RA4732",	
"RB2052",	"RB2278",	"RB2932",	"RB3383",	"RB3654",	"RB3694",	"RB3720",	"RB3726",	"RB3831",	"RB3926",	
"RB4039",	"RB4210",	"RB4369",	"RB4470",	"RB4642",	"RB4672",	"RB4712",	"RB4736",	"RB4757",	"RB4770",	
"RB4794",	"RB4804") 
then remove_flag=4;
run;

proc freq data=rcr.lb_wm_mid_dates_flag_c; 
tables remove_flag/list;
run;

*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*
*								ENDLINE  										 *					
*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*;

*********************************************************
*						FLAG 1 & 2						*					
*********************************************************;

* flag subjects from on team notes ;
data rcr.lb_wm_end_dates_flag_a;
set rcr.lb_wm_end_dates;
**rename IDs identified by team;
if ID="R2205" then ID="RB2205";
*** flag to remove from on team notes;
else if ID ="RA000" then remove_flag=1;
else if ID ="RA0000" then remove_flag=1;
*if ID="" and sessiondate= then remove_flag=1;
*else if ID="" and sessiondate= then remove_flag=1;
else remove_flag=0;
run;

proc freq data=rcr.lb_wm_end_dates_flag_a; 
tables ID / list;
where remove_flag=1 or remove_flag=2;
run;

proc freq data=rcr.lb_wm_end_dates_flag_a; 
tables remove_flag/ list;
run;

*********************************************************
*						FLAG 3 							*					
*********************************************************;

*Look at number of trial responses per subject for those not flagged above;
*if more than 33, then took test multiple times;
*if timed_out=33 then didn't respond to any;

proc freq data=rcr.lb_wm_end_dates_flag_a noprint;
tables ID*sessiondate / list nofreq nocum nopercent out=lb_wm_end_trial_count;
where remove_flag=0;
run;

proc freq data=lb_wm_end_trial_count noprint;
tables ID/ list nofreq nocum nopercent out=lb_wm_end_dup_ids;
run;

*print IDs with tests on more than 1 date;
proc print data=lb_wm_end_dup_ids; 
where count>1;
run;

* Get ID's with more than 33 trials (i.e. more than one test) ;
proc print data=lb_wm_end_trial_count; 
where count >33; * print people with more than 30 responses in a condition;
run;

* Print date and time for each ID with duplicates ;
proc freq data=rcr.lb_wm_end_dates_flag_a ;
tables ID*sessiondate*sessiondatetime/ list nofreq nocum nopercent ; 
where ID in ("RA2460",	"RA4203",	"RA4774",	"RA4803",	"RB2090",	"RB2592",	"RB4458",	"RA3181",	
"RA3483",	"RA3696",	"RA3953",	"RA4086",	"RB2007",	"RB2179",	"RB2886",	"RB3529",	"RB3684",	
"RB3904",	"RB4104",	"RB4220");
run;

*** TIP: copy and paste output of above into excel and then run pivot table to evaluate for next step ****;

** removing those with too many trials, flag=3;
* flagging IDs with tests over multiple days or more than 2 tests on single day;
* flagging second of 2 tests on single day;
data rcr.lb_wm_end_dates_flag_b;
set rcr.lb_wm_end_dates_flag_a;
if ID in ("RA3483", "RA3696")
	then remove_flag=3;
*** flag code 3 for 2nd of 2 tests for IDs with 2 tests on one day (keeping first test);
	else if 
	(ID="RA2460" and sessiondatetime="10:52:47.4967 30 May, 2017") or
	(ID="RA3181" and sessiondatetime="12:17:33.9075 31 May, 2017") or
	(ID="RA3483" and sessiondatetime="13:39:31.5566 22 May, 2017") or
	(ID="RA3696" and sessiondatetime="11:07:23.8558 26 May, 2017") or
	(ID="RA3953" and sessiondatetime="13:52:27.3413 29 May, 2017") or
	(ID="RA4086" and sessiondatetime="11:16:26.2063 29 May, 2017") or
	(ID="RA4203" and sessiondatetime="10:28:46.4534 23 May, 2017") or
	(ID="RA4774" and sessiondatetime="13:17:21.2657 31 May, 2017") or
	(ID="RA4803" and sessiondatetime="13:01:45.5225 25 May, 2017") or
	(ID="RB2007" and sessiondatetime="05:30:14.6004 22 May, 2017") or
	(ID="RB2090" and sessiondatetime="13:51:23.2424 22 May, 2017") or
	(ID="RB2179" and sessiondatetime="13:42:33.6536 23 May, 2017") or
	(ID="RB2592" and sessiondatetime="12:18:13.7926 22 May, 2017") or
	(ID="RB2886" and sessiondatetime="06:07:07.1465 30 May, 2017") or
	(ID="RB3529" and sessiondatetime="05:05:57.7431 17 May, 2017") or
	(ID="RB3684" and sessiondatetime="11:13:56.8349 22 May, 2017") or
	(ID="RB3904" and sessiondatetime="09:48:44.8940 30 May, 2017") or
	(ID="RB4104" and sessiondatetime="11:10:50.2908 31 May, 2017") or
	(ID="RB4220" and sessiondatetime="10:14:43.2162 25 May, 2017") or
	(ID="RB4458" and sessiondatetime="14:46:19.8214 24 May, 2017") 
then remove_flag=3;
run;

proc freq data=rcr.lb_wm_end_dates_flag_b; 
tables ID / list;
where remove_flag=3;
run;

proc freq data=rcr.lb_wm_end_dates_flag_b; 
tables remove_flag/ list;
run;

*********************************************************
*						FLAG 4 							*					
*********************************************************;

*People with too many Timed Out responses *;
*all trials missing from one of the following 6 conditions (FLAG 4)
	* load=1 or 2 or 3 (11 each)
	* delay=0 (12)
	* delay=3 (21)
;

%macro getmissingLOAD (out=, load=);
proc freq data=rcr.lb_wm_end_dates_flag_b noprint;
tables ID*sessiondate / list nofreq nocum nopercent out=&out;
where timedout_outcome="Timed Out" and remove_flag=0 and load=&load;
run;
%mend getmissingLOAD;

%getmissingLOAD(out=lb_L1, load=1)
%getmissingLOAD(out=lb_L2, load=2)
%getmissingLOAD(out=lb_L3, load=3)
;

%macro getmissingDELAY (out=, delay=);
proc freq data=rcr.lb_wm_end_dates_flag_b noprint;
tables ID*sessiondate / list nofreq nocum nopercent out=&out;
where timedout_outcome="Timed Out" and remove_flag=0 and delay=&delay;
run;
%mend getmissingDELAY;

%getmissingDELAY(out=lb_D0, delay=0)
%getmissingDELAY(out=lb_D3, delay=3)
;

%macro getID(data=, set=, count=);
data &data;
set &set;
where count = &count; 
run;
%mend getID;

%getID(data=lb_L1_count, set=lb_L1,  count=11 )
%getID(data=lb_L2_count, set=lb_L2,  count=11 )
%getID(data=lb_L3_count, set=lb_L3,  count=11 )
%getID(data=lb_D0_count, set=lb_D0,  count=12 )
%getID(data=lb_D3_count, set=lb_D3,  count=21 )
;

%macro sort(data);
proc sort data=&data;
by id;
run;
%mend sort ;

%sort(data=lb_L1_count)
%sort(data=lb_L2_count)
%sort(data=lb_L3_count)
%sort(data=lb_D0_count)
%sort(data=lb_D3_count)
;

* Merge all missing datasets;
data lb_missing;
merge lb_L1_count	lb_L2_count	lb_L3_count	lb_D0_count	lb_D3_count;
by id;
run;

*print IDs to flag in next step;
proc print data=lb_missing;
run;

data rcr.lb_wm_end_dates_flag_c;
set rcr.lb_wm_end_dates_flag_b;
if ID in ("RA2643", 	"RA3282", 	"RA3369", 	"RA3449", 	"RA3601", 	"RA3797", 	"RA3920", 	"RA3974", 	
"RA4220", 	"RA4511", 	"RA4863", 	"RA4874", 	"RA4943", 	"RA5010", 	"RB2400", 	"RB2441", 	"RB2684", 
"RB2895", 	"RB2927", 	"RB3529", 	"RB3569", 	"RB3577", 	"RB3694", 	"RB3699", 	"RB4705", 	"RB4794",
"RB4804", 	"RB4979", 	"RB5025", 	"RB5056") 
then remove_flag=4;
run;

proc freq data=rcr.lb_wm_end_dates_flag_c; 
tables remove_flag/list;
run;

********************************************* OUTPUT FINAL CLEANED DATASETS **********************************;
**************************************************************************************************************;

* removing all flagged cases ;
%macro finalnoflags (data=, set=);
data &data;
set &set;
where remove_flag=0;
run;
%mend finalnoflags;

%finalnoflags(data=rcr.lb_wm_base_trials_final, set=rcr.lb_wm_base_dates_flag_c)
%finalnoflags(data=rcr.lb_wm_mid_trials_final, set=rcr.lb_wm_mid_dates_flag_c)
%finalnoflags(data=rcr.lb_wm_end_trials_final, set=rcr.lb_wm_end_dates_flag_c)
;
