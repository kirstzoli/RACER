libname rcr "C:\Users\cbford\Documents\RACER\SAS Datasets";

***** INHIBITION (BI) TASK *********;

*********************************************************************************************************
*									IMPORT EXCEL DATAFILES 												*
*********************************************************************************************************; 
** Subject output already combined into single excel file per wave **;

** MACRO to import xlsx files**;
%macro import (out=, datafile=);
proc import 
	out=&out
	datafile=&datafile
	dbms=xlsx replace;
run;
%mend import;

*ENTER: name you are giving sas file (out=) and full path to xlsx file (datafile = );
*Lebanon;%import(out= rcr.lb_bi_base_raw, datafile ="C:\Users\cbford\Documents\RACER\Lebanon data\Lebanon_baseline\Lebanon_compiled_baseline\LB_bi_baseline_raw.xlsx" )
%import(out= rcr.lb_bi_mid_raw, datafile ="C:\Users\cbford\Documents\RACER\Lebanon data\Lebanon_midline\Lebanon_compiled_midline\LB_bi_midline_raw.xlsx" )
%import(out= rcr.lb_bi_end_raw, datafile ="C:\Users\cbford\Documents\RACER\Lebanon data\Lebanon_endline\Lebanon_compiled_endline\LB_bi_endline_raw.xlsx" )

*Niger;
%import(out= rcr.ng_bi_base_raw, datafile ="C:\Users\cbford\Documents\RACER\Niger data\Niger_baseline\Niger_compiled_baseline\NG_bi_baseline_raw.xlsx" )
%import(out= rcr.ng_bi_mid_raw, datafile ="C:\Users\cbford\Documents\RACER\Niger data\Niger_midline\Niger_compiled_midline\NG_bi_midline_raw.xlsx" )
%import(out= rcr.ng_bi_end_raw, datafile ="C:\Users\cbford\Documents\RACER\Niger data\Niger_endline\Niger_compiled_endline\NG_bi_endline_raw.xlsx" )
;

*********************************************************************************************************
*									CLEAN RAW DATA 														*
*********************************************************************************************************

1) removing unnecessary variables 
2) including only trial data (not practice trials)
3) binary coding of accuracy - for averaging
4) binary coding for response or timed-out
;

%macro clean (data=, set= );
data &data;
*can rename variables in set statement;
set &set (rename=(sessionbatchname=ID ));
*creating a binary accuracy variable for easy averaging, correct=1 incorrect=0;
if correct_outcome = "Correct" then accuracy=1;
else if correct_outcome = "Incorrect" then accuracy=0;
else accuracy =.;
*creating a binary responded variable for summing # responded, responded=1 timedout=0;
if responded_outcome="Responded" then responded_binary=1;
else if responded_outcome=. then responded_binary=0;
******* CALCULATION FOR DISTANCE BETWEEN ACTUAL TOUCH AND WHERE SUBJ SHOULD HAVE TOUCHED;
******* This will replace the ctrldistt variable which used a strange y coordinate (358.9) in the activetargetpos_y variable;
******* We are instead using the active_dot_pos_y variable (384);
distt_calculated = sqrt(((first_touch_pos_x - activetargetpos_x)**2) + ((first_touch_pos_y - active_dot_pos_y)**2));
keep distt_calculated condition	correct_outcome	first_touch_pos_x  activetargetpos_x  first_touch_pos_y  active_dot_pos_y  first_touch_ctrdistl	first_touch_ctrdistr	first_touch_ctrdists	
first_touch_ctrdistt	first_touch_game_seq	first_touch_pos_x	first_touch_pos_y	
first_touch_resp_time	fullscreen	numberpractices	numbertutorials	record_type	remove	
responded_outcome	seq	 ID	sessiondate	sessiondatetime	side	
timedout_outcome accuracy responded_binary;
where record_type="trial event";*only keeping trial data, not practice runs;
run;
%mend clean;

%clean (data=rcr.lb_bi_base, set=rcr.lb_bi_base_raw)
%clean (data=rcr.lb_bi_mid, set=rcr.lb_bi_mid_raw)
%clean (data=rcr.lb_bi_end, set=rcr.lb_bi_end_raw)

%clean (data=rcr.ng_bi_base, set=rcr.ng_bi_base_raw)
%clean (data=rcr.ng_bi_mid, set=rcr.ng_bi_mid_raw)
%clean (data=rcr.ng_bi_end, set=rcr.ng_bi_end_raw)
;

*make all ID's all uppercase (e.g. ra4433 = RA4433);
%macro upper(data=, set=);
data &data;
set &set;
ID = upcase(id);
run;
%mend upper;

%upper(data=rcr.lb_bi_base, set=rcr.lb_bi_base)
%upper(data=rcr.lb_bi_mid, set=rcr.lb_bi_mid)
%upper(data=rcr.lb_bi_end, set=rcr.lb_bi_end)

%upper(data=rcr.ng_bi_base, set=rcr.ng_bi_base)
%upper(data=rcr.ng_bi_mid, set=rcr.ng_bi_mid)
%upper(data=rcr.ng_bi_end, set=rcr.ng_bi_end)
;

/*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*/
/*					 RUN CLEAN UP SCRIPT THAT FLAGS SUBJECTS BASED ON VARIOUS CRITERIA *****************************/
/*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*/

* This code runs the flag subjects scripts resulting in cleaned datafiles with those subjects removed;
* Code for those files created before running this step;
* Can run these include statements if these scripts are fully edited and ready to run;
* Alternately, stop here and run throug the flag cases scripts, then return to run create conditions;

%include C:\Users\cbford\Documents\RACER\SAS scripts\BI_Flag_Cases_Niger.sas;
%include C:\Users\cbford\Documents\RACER\SAS scripts\BI_Flag_Cases_Lebanon.sas;

**** OPEN AND RUN FLAGGING SCRIPTS ****
C:\Users\cbford\Documents\RACER\SAS scripts\BI_Flag_Cases_Niger.sas
C:\Users\cbford\Documents\RACER\SAS scripts\BI_Flag_Cases_Lebanon.sas;

*********************************************************************************************************
*									CREATE CONDITIONS													*
*********************************************************************************************************;

* create new newcond for same/diff rule & same/diff motor; 
%macro newcond(data=, set=);
data &data;
set &set; 
if condition="sameside" and side="r" then newcond="same_right";
if condition="sameside" and side="l" then newcond="same_left";
if condition="opp_side" and side="r" then newcond="opp_right";
if condition="opp_side" and side="l" then newcond="opp_left";
run;
%mend newcond;

%newcond (data=lb_bi_base_newcond, set=rcr.lb_bi_base_cleaned)
%newcond (data=lb_bi_mid_newcond, set=rcr.lb_bi_mid_cleaned)
%newcond (data=lb_bi_end_newcond, set=rcr.lb_bi_end_cleaned)

%newcond (data=ng_bi_base_newcond, set=rcr.ng_bi_base_cleaned)
%newcond (data=ng_bi_mid_newcond, set=rcr.ng_bi_mid_cleaned)
%newcond (data=ng_bi_end_newcond, set=rcr.ng_bi_end_cleaned)
;

*** Create Lag Conditions based on previous row; 
*n-1				n				lagcondition
same-right			same-right		smsr
same-left			same-left		smsr
opposite-right		opposite-right	smsr
opposite-left		opposite-left	smsr
same-right			opposite-left	smdr
same-left			opposite-right	smdr
opposite-right		same-left		smdr
opposite-left		same-right		smdr
same-right			same-left		dmsr
same-left			same-right		dmsr
opposite-right		opposite-left	dmsr
opposite-left		opposite-right	dmsr
same-right			opposite-right	dmdr
same-left			opposite-left	dmdr
opposite-right		same-right		dmdr
opposite-left		same-left		dmdr
; 

* first sort by ID and sequence so each subject's trials are in order;
%macro sortSEQ(data=);
proc sort data=&data;
by ID seq;
run;
%mend sortSEQ;

%sortSEQ(data=lb_bi_base_newcond)
%sortSEQ(data=lb_bi_mid_newcond)
%sortSEQ(data=lb_bi_end_newcond)

%sortSEQ(data=ng_bi_base_newcond)
%sortSEQ(data=ng_bi_mid_newcond)
%sortSEQ(data=ng_bi_end_newcond)
;

%macro lagconds(data=, set=);
data &data;
obs1 = 1; 
  do while( obs1 <= nobs);
    set &set nobs=nobs;
    obs_min_1 = obs1 - 1; 
    set &set(
        rename=(
        ID = ID2
		newcond = prevcond 
        )
      ) point=obs_min_1;
  If ID2 = ID and
  	  newcond=prevcond
	then lag_cond = "smsr";
	else if ID2=ID and
	      ((prevcond = "same_right" and newcond= "opp_left" )
		or(prevcond = "same_left" and newcond= "opp_right")
		or(prevcond = "opp_right" and newcond= "same_left")
		or(prevcond = "opp_left" and newcond= "same_right"))
		then lag_cond = "smdr";
	else if ID2=ID and
	      ((prevcond = "same_right" and newcond= "same_left" )
		or(prevcond = "same_left" and newcond= "same_right")
		or(prevcond = "opp_right" and newcond= "opp_left")
		or(prevcond = "opp_left" and newcond= "opp_right"))
		then lag_cond = "dmsr";
	else if ID2=ID and
	      ((prevcond = "same_right" and newcond= "opp_right" )
		or(prevcond = "same_left" and newcond= "opp_left")
		or(prevcond = "opp_right" and newcond= "same_right")
		or(prevcond = "opp_left" and newcond= "same_left"))
		then lag_cond = "dmdr";
 else lag_cond=.;
    output; 
    obs1 + 1; 
  end; 
run;
%mend lagconds; 

%lagconds(data=lb_bi_base_lag_conditions, set=lb_bi_base_newcond)
%lagconds(data=lb_bi_mid_lag_conditions, set=lb_bi_mid_newcond)
%lagconds(data=lb_bi_end_lag_conditions, set=lb_bi_end_newcond)

%lagconds(data=ng_bi_base_lag_conditions, set=ng_bi_base_newcond)
%lagconds(data=ng_bi_mid_lag_conditions, set=ng_bi_mid_newcond)
%lagconds(data=ng_bi_end_lag_conditions, set=ng_bi_end_newcond)
;

* check to make sure all lag conditions were created;
%macro checklag (data=);
proc freq data= &data;
tables lag_cond / nocum nopercent;
run;
%mend checklag;

%checklag(data=lb_bi_base_lag_conditions)
%checklag(data=lb_bi_mid_lag_conditions)
%checklag(data=lb_bi_end_lag_conditions)

%checklag(data=ng_bi_base_lag_conditions)
%checklag(data=ng_bi_mid_lag_conditions)
%checklag(data=ng_bi_end_lag_conditions)
;

**** Remove non-response lines now that they have been used for lag condition creation;
%macro cleanlag (data=, set=);
data &data;
set &set;
where responded_binary=1;
run;
%mend cleanlag;

%cleanlag(data=rcr.lb_bi_base_final_raw_cleaned, set=lb_bi_base_lag_conditions)
%cleanlag(data=rcr.lb_bi_mid_final_raw_cleaned, set=lb_bi_mid_lag_conditions)
%cleanlag(data=rcr.lb_bi_end_final_raw_cleaned, set=lb_bi_end_lag_conditions)

%cleanlag(data=rcr.ng_bi_base_final_raw_cleaned, set=ng_bi_base_lag_conditions)
%cleanlag(data=rcr.ng_bi_mid_final_raw_cleaned, set=ng_bi_mid_lag_conditions)
%cleanlag(data=rcr.ng_bi_end_final_raw_cleaned, set=ng_bi_end_lag_conditions)
;


%macro lagfreq(data=);
proc freq data=&data;
tables lag_cond / nocum nopercent;
run;
%mend lagfreq;

%lagfreq(data=rcr.lb_bi_base_final_raw_cleaned)
%lagfreq(data=rcr.lb_bi_mid_final_raw_cleaned)
%lagfreq(data=rcr.lb_bi_end_final_raw_cleaned)

%lagfreq(data=rcr.ng_bi_base_final_raw_cleaned)
%lagfreq(data=rcr.ng_bi_mid_final_raw_cleaned)
%lagfreq(data=rcr.ng_bi_end_final_raw_cleaned)
;

****************************************************************;
* 					EXPORT TO TEST FOR DUPES 					;
****************************************************************;
** This step shouldn't be necessary, but is here for QC;

%macro export(data=, outfile=);
proc export data =&data
outfile = &outfile
dbms=xlsx replace;
run;
%mend export;

%export(data= rcr.lb_bi_base_final_raw_cleaned, outfile="C:\Users\cbford\Documents\RACER\lb_bi_base_cleaned_TEST.xlsx")
%export(data= rcr.lb_bi_mid_final_raw_cleaned, outfile="C:\Users\cbford\Documents\RACER\lb_bi_mid_cleaned_TEST.xlsx")
%export(data= rcr.lb_bi_end_final_raw_cleaned, outfile="C:\Users\cbford\Documents\RACER\lb_bi_end_cleaned_TEST.xlsx")

%export(data= rcr.ng_bi_base_final_raw_cleaned, outfile="C:\Users\cbford\Documents\RACER\ng_bi_base_cleaned_TEST.xlsx")
%export(data= rcr.ng_bi_mid_final_raw_cleaned, outfile="C:\Users\cbford\Documents\RACER\ng_bi_mid_cleaned_TEST.xlsx")
%export(data= rcr.ng_bi_end_final_raw_cleaned, outfile="C:\Users\cbford\Documents\RACER\ng_bi_end_cleaned_TEST.xlsx")
;

*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*
*			Checking subj numbers BEFORE & AFTER flagging & filtering				   *					
*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*;

%macro getIDs (data=, out=);
proc freq data=&data noprint; 
tables id / list out=&out;
run;
%mend getIDs;

%getIDs(data= rcr.ng_bi_base_final_raw_cleaned, out=ng_bi_base_final)
%getIDs(data= rcr.ng_bi_mid_final_raw_cleaned, out=ng_bi_mid_final)
%getIDs(data= rcr.ng_bi_end_final_raw_cleaned, out=ng_bi_end_final)
;

%macro idcountBI (data=);
proc iml;
 use &data;
 read all var{id} into x;
 close;

 title "ID count in &data";
 print nobs;
 print (nrow(x));
quit;
%mend idcountBI;

%idcountBI(data=ng_bi_base_final)
%idcountBI(data=ng_bi_mid_final)
%idcountBI(data=ng_bi_end_final)
;
