libname rcr "C:\Users\cbford\Documents\RACER\SAS Datasets";

***** WORKING MEMORY (WM) TASK DATA IMPORT AND CLEAN *********;

******************** IMPORT EXCEL DATAFILES ********************************;
****************************************************************************; 
** Subject output already combined into single excel file per wave **;

%macro import (out=, datafile=);
proc import 
	out=&out
	datafile=&datafile
	dbms=xlsx replace;
run;
%mend import;

*ENTER: name you are giving sas file (out=) and full path to xlsx file (datafile = );
*Lebanon;
%import(out= lb_wm_base_raw, datafile ="C:\Users\cbford\Documents\RACER\Lebanon data\Lebanon_baseline\Lebanon_compiled_baseline\LB_WM_baseline_raw.xlsx" )
%import(out= lb_wm_mid_raw, datafile ="C:\Users\cbford\Documents\RACER\Lebanon data\Lebanon_midline\Lebanon_compiled_midline\LB_WM_midline_raw.xlsx" )
%import(out= lb_wm_end_raw, datafile ="C:\Users\cbford\Documents\RACER\Lebanon data\Lebanon_endline\Lebanon_compiled_endline\LB_WM_endline_raw.xlsx" )

*Niger;
%import(out= ng_wm_base_raw, datafile ="C:\Users\cbford\Documents\RACER\Niger data\Niger_baseline\Niger_compiled_baseline\NG_WM_baseline_raw.xlsx" )
%import(out= ng_wm_mid_raw, datafile ="C:\Users\cbford\Documents\RACER\Niger data\Niger_midline\Niger_compiled_midline\NG_WM_midline_raw.xlsx" )
%import(out= ng_wm_end_raw, datafile ="C:\Users\cbford\Documents\RACER\Niger data\Niger_endline\Niger_compiled_endline\NG_WM_endline_raw.xlsx" )
;

************************** CLEAN RAW DATA **********************************;
****************************************************************************;  
**
1) keep only relevant variables & trials (not practices)
2) create accurate touch distance variables -- current code uses smallest distance only, 
doesn't account for previous touches. E.g. 2 ball trial could be distance from B, distance from B, dist from A
should be touch to b, then distance from next nearest that isn't b, etc.
3)create variable with # of touches / misses per trial. e.g. if load=3, touch=2 then miss=1
Can code up as: load - probe_touch_count = missed_targets 
;

%macro clean (data=, set = );
data &data;
set &set ;
rename sessionbatchname=id; *rename ID variable;
if record_type="practice event" then delete; *keeping only trials;
keep sessionbatchname sessiondate	sessiondatetime numbertutorials	numberpractices	seq	load	encoding	delay	probe	
iti	dotloc1	dotloc2	dotloc3	record_type	timedout_outcome	first_touch_resp_time	second_touch_resp_time	
third_touch_resp_time	first_touch_pos_x	first_touch_pos_y	second_touch_pos_x	second_touch_pos_y	third_touch_pos_x	
third_touch_pos_y	first_touch_ctrdist_nearest	first_touch_ctrdist_dota	first_touch_ctrdist_dotb	
first_touch_ctrdist_dotc	second_touch_ctrdist_nearest	second_touch_ctrdist_dota	second_touch_ctrdist_dotb	
second_touch_ctrdist_dotc	third_touch_ctrdist_nearest	third_touch_ctrdist_dota	third_touch_ctrdist_dotb	
third_touch_ctrdist_dotc	first_touch_touched_stim	first_touch_touched_stimnum	second_touch_touched_stim	
second_touch_touched_stimnum	third_touch_touched_stim	third_touch_touched_stimnum	first_touch_nearest_stim	
first_touch_nearest_stimnum	second_touch_nearest_stim	second_touch_nearest_stimnum	third_touch_nearest_stim	
third_touch_nearest_stimnum	probe_touch_count	active_dota_number	active_dota_pos_x	active_dota_pos_y	
active_dotb_number	active_dotb_pos_x	active_dotb_pos_y	active_dotc_number	active_dotc_pos_x	active_dotc_pos_y; 
run;
%mend clean;

%clean (data=lb_wm_base , set=lb_wm_base_raw)
%clean (data=lb_wm_mid , set=lb_wm_mid_raw)
%clean (data=lb_wm_end , set=lb_wm_end_raw)

%clean (data=ng_wm_base , set=ng_wm_base_raw)
%clean (data=ng_wm_mid , set=ng_wm_mid_raw)
%clean (data=ng_wm_end , set=ng_wm_end_raw)
;

*make all ID's all uppercase (e.g. ra4433 = RA4433);
%macro upper(data=, set=);
data &data;
set &set;
ID = upcase(id);
run;
%mend upper;

%upper(data=lb_wm_base, set=lb_wm_base)
%upper(data=lb_wm_mid, set=lb_wm_mid)
%upper(data=lb_wm_end, set=lb_wm_end)

%upper(data=ng_wm_base, set=ng_wm_base)
%upper(data=ng_wm_mid, set=ng_wm_mid)
%upper(data=ng_wm_end, set=ng_wm_end)
;

**** Create error flag for trials with distance label error (e.g AAB or ACA etc);
%macro errorflag(data=, set=);
data &data;
set &set;
	if load=2 and (first_touch_nearest_stim = second_touch_nearest_stim) 	
		and (first_touch_nearest_stim NE '' and second_touch_nearest_stim NE '') 
	then error_flag=1;
	else if load=3 and ((first_touch_nearest_stim = second_touch_nearest_stim)
			or (third_touch_nearest_stim = second_touch_nearest_stim)
			or (first_touch_nearest_stim = third_touch_nearest_stim))
			and (first_touch_nearest_stim NE '' and second_touch_nearest_stim NE '' and third_touch_nearest_stim NE '' )
	then error_flag=1;
	else if load=3 and ((first_touch_nearest_stim = second_touch_nearest_stim)
			and (first_touch_nearest_stim NE '' and second_touch_nearest_stim NE '' ))
	then error_flag=1;
	else error_flag=0;
run;
%mend errorflag;

%errorflag(data=lb_wm_base_error_flag, set=lb_wm_base)
%errorflag(data=lb_wm_mid_error_flag, set=lb_wm_mid)
%errorflag(data=lb_wm_end_error_flag, set=lb_wm_end)

%errorflag(data=ng_wm_base_error_flag, set=ng_wm_base)
%errorflag(data=ng_wm_mid_error_flag, set=ng_wm_mid)
%errorflag(data=ng_wm_end_error_flag, set=ng_wm_end)
;

*** looking at how many trials have distance error;
%macro checkerror(data=);
proc freq data=&data;
tables error_flag ; 
run;
%mend checkerror;

%checkerror(data=lb_wm_base_error_flag)
%checkerror(data=lb_wm_mid_error_flag)
%checkerror(data=lb_wm_end_error_flag)

%checkerror(data=ng_wm_base_error_flag)
%checkerror(data=ng_wm_mid_error_flag)
%checkerror(data=ng_wm_end_error_flag)
;

********************************* CREATE NEW OUTCOMES **************************************;
********************************************************************************************;

********* Create new distance variables that don't repeat stim ************;
%macro newdist(data=, set=);
data &data;
set &set;
** First put values into new variables as is for trials w/o error flag;
first_touch_dist_new = first_touch_ctrdist_nearest; *All first touch distances are ok;
if load = 1 then first_stim_new = first_touch_nearest_stim;
	else if load = 2 and error_flag=0
		then do;
			second_touch_dist_new = second_touch_ctrdist_nearest ;
			first_stim_new = first_touch_nearest_stim;
			second_stim_new = second_touch_nearest_stim;
		end;
	else if error_flag=0 and load=3 
			then do;
				second_touch_dist_new = second_touch_ctrdist_nearest ;
				third_touch_dist_new = third_touch_ctrdist_nearest;
				first_stim_new = first_touch_nearest_stim;
				second_stim_new = second_touch_nearest_stim;
				third_stim_new = third_touch_nearest_stim;
		end;
** Creating new nearest touch distances -- LOAD=2;
** for load=2 and error = true;
* for error A A;
	else if load=2 and error_flag=1 and first_touch_ctrdist_nearest=first_touch_ctrdist_dota
		then do;
			second_touch_dist_new = second_touch_ctrdist_dotb; 
			first_stim_new = 'A';
			second_stim_new = 'B';
		end;
*for error B B;
	else if load=2 and error_flag=1 and first_touch_ctrdist_nearest=first_touch_ctrdist_dotb
		then do;
			second_touch_dist_new = second_touch_ctrdist_dota;
			first_stim_new = 'B';
			second_stim_new = 'A';
		end;
** Creating new nearest touch distances -- LOAD=3;
* True nearest touch = A B C;
	else if load=3 and error_flag=1 and (first_touch_ctrdist_nearest=first_touch_ctrdist_dota) and (second_touch_ctrdist_dotb < second_touch_ctrdist_dotc)
			and third_touch_ctrdist_dotc NE .
		then do;
			second_touch_dist_new=second_touch_ctrdist_dotb;
			third_touch_dist_new=third_touch_ctrdist_dotc;
			first_stim_new = 'A';
			second_stim_new = 'B';
			third_stim_new = 'C';
		end;
* True nearest touch = A B C -- BUT third response missing;	
	else if load=3 and error_flag=1 and (first_touch_ctrdist_nearest=first_touch_ctrdist_dota) and (second_touch_ctrdist_dotb < second_touch_ctrdist_dotc)
			and third_touch_ctrdist_nearest = .
		then do;
			second_touch_dist_new=second_touch_ctrdist_dotb;
			third_touch_dist_new=third_touch_ctrdist_dotc;
			first_stim_new = 'A';
			second_stim_new = 'B';
		end;
* True nearest touch = A C B;
	else if load=3 and error_flag=1 and (first_touch_ctrdist_nearest=first_touch_ctrdist_dota) and (second_touch_ctrdist_dotb > second_touch_ctrdist_dotc)
			and third_touch_ctrdist_dotc NE .
		then do;
			second_touch_dist_new=second_touch_ctrdist_dotc;
			third_touch_dist_new=third_touch_ctrdist_dotb;
			first_stim_new = 'A';
			second_stim_new = 'C';
			third_stim_new = 'B';
		end;
* True nearest touch = A C B -- BUT third response missing;
	else if load=3 and error_flag=1 and (first_touch_ctrdist_nearest=first_touch_ctrdist_dota) and (second_touch_ctrdist_dotb > second_touch_ctrdist_dotc)
			and third_touch_ctrdist_dotc = .
		then do;
			second_touch_dist_new=second_touch_ctrdist_dotc;
			third_touch_dist_new=third_touch_ctrdist_dotb;
			first_stim_new = 'A';
			second_stim_new = 'C';
		end;
* True nearest touch = B A C;
	else if load=3 and error_flag=1 and (first_touch_ctrdist_nearest=first_touch_ctrdist_dotb) and (second_touch_ctrdist_dota < second_touch_ctrdist_dotc)
			and third_touch_ctrdist_dotc NE .
		then do;
			second_touch_dist_new=second_touch_ctrdist_dota;
			third_touch_dist_new=third_touch_ctrdist_dotc;
			first_stim_new = 'B';
			second_stim_new = 'A';
			third_stim_new = 'C';
		end;
* True nearest touch = B A C-- BUT third response missing;
	else if load=3 and error_flag=1 and (first_touch_ctrdist_nearest=first_touch_ctrdist_dotb) and (second_touch_ctrdist_dota < second_touch_ctrdist_dotc)
			and third_touch_ctrdist_dotc = .
		then do;
			second_touch_dist_new=second_touch_ctrdist_dota;
			third_touch_dist_new=third_touch_ctrdist_dotc;
			first_stim_new = 'B';
			second_stim_new = 'A';
		end;
* True nearest touch = B C A;
	else if load=3 and error_flag=1 and (first_touch_ctrdist_nearest=first_touch_ctrdist_dotb) and (second_touch_ctrdist_dota > second_touch_ctrdist_dotc)
			and third_touch_ctrdist_dotc NE .
		then do;
			second_touch_dist_new=second_touch_ctrdist_dotc;
			third_touch_dist_new=third_touch_ctrdist_dota;
			first_stim_new = 'B';
			second_stim_new = 'C';
			third_stim_new = 'A';
		end;
* True nearest touch = B C A -- BUT third response missing;
	else if load=3 and error_flag=1 and (first_touch_ctrdist_nearest=first_touch_ctrdist_dotb) and (second_touch_ctrdist_dota > second_touch_ctrdist_dotc)
			and third_touch_ctrdist_dotc = .
		then do;
			second_touch_dist_new=second_touch_ctrdist_dotc;
			third_touch_dist_new=third_touch_ctrdist_dota;
			first_stim_new = 'B';
			second_stim_new = 'C';
		end;
* True nearest touch = C A B;
	else if load=3 and error_flag=1 and (first_touch_ctrdist_nearest=first_touch_ctrdist_dotc) and (second_touch_ctrdist_dota < second_touch_ctrdist_dotb)
			and third_touch_ctrdist_dotc NE .
		then do;
			second_touch_dist_new=second_touch_ctrdist_dota;
			third_touch_dist_new=third_touch_ctrdist_dotb;
			first_stim_new = 'C';
			second_stim_new = 'A';
			third_stim_new = 'B';
		end;
* True nearest touch = C A B -- BUT third response missing;
	else if load=3 and error_flag=1 and (first_touch_ctrdist_nearest=first_touch_ctrdist_dotc) and (second_touch_ctrdist_dota < second_touch_ctrdist_dotb)
			and third_touch_ctrdist_dotc = .
		then do;
			second_touch_dist_new=second_touch_ctrdist_dota;
			third_touch_dist_new=third_touch_ctrdist_dotb;
			first_stim_new = 'C';
			second_stim_new = 'A';
		end;
* True nearest touch = C B A;
	else if load=3 and error_flag=1 and (first_touch_ctrdist_nearest=first_touch_ctrdist_dotc) and (second_touch_ctrdist_dota > second_touch_ctrdist_dotb)
			and third_touch_ctrdist_dotc NE .
		then do;
			second_touch_dist_new=second_touch_ctrdist_dotb;
			third_touch_dist_new=third_touch_ctrdist_dota;
			first_stim_new = 'C';
			second_stim_new = 'B';
			third_stim_new = 'A';
		end;
* True nearest touch = C B A -- BUT third response missing;
	else if load=3 and error_flag=1 and (first_touch_ctrdist_nearest=first_touch_ctrdist_dotc) and (second_touch_ctrdist_dota > second_touch_ctrdist_dotb)
			and third_touch_ctrdist_dotc = .
		then do;
			second_touch_dist_new=second_touch_ctrdist_dotb;
			third_touch_dist_new=third_touch_ctrdist_dota;
			first_stim_new = 'C';
			second_stim_new = 'B';
		end;
run;
%mend newdist;

%newdist(data=lb_wm_base_newdist, set=lb_wm_base_error_flag)
%newdist(data=lb_wm_mid_newdist, set=lb_wm_mid_error_flag)
%newdist(data=lb_wm_end_newdist, set=lb_wm_end_error_flag)

%newdist(data=ng_wm_base_newdist, set=ng_wm_base_error_flag)
%newdist(data=ng_wm_mid_newdist, set=ng_wm_mid_error_flag)
%newdist(data=ng_wm_end_newdist, set=ng_wm_end_error_flag)
;

*************** Calculate average distance across trials ***********;

%macro avedist(data=, set=);
data &data;
set &set;
*load=1;
if load=1 then ave_dist = first_touch_dist_new;
*load = 2 and no missing values;
else if load = 2 and first_touch_dist_new NE . and second_touch_dist_new NE . then ave_dist = (first_touch_dist_new + second_touch_dist_new) / 2;
*load = 2 but second touch is missing;
else if load = 2 and first_touch_dist_new NE . and second_touch_dist_new =. then ave_dist = first_touch_dist_new ;
*load = 2 but all are missing;
else if load = 2 and first_touch_dist_new =. and second_touch_dist_new =. then ave_dist = .;
*load = 3 and no missing values;
else if load = 3 and first_touch_dist_new NE . and second_touch_dist_new NE . and third_touch_dist_new NE . then ave_dist = (first_touch_dist_new + second_touch_dist_new + third_touch_dist_new) / 3;
*load = 3 and second & third touches missing;
else if load = 3 and first_touch_dist_new NE . and second_touch_dist_new =. and third_touch_dist_new =. then ave_dist = first_touch_dist_new ;
*load = 3 and only third touch missing;
else if load = 3 and first_touch_dist_new NE . and second_touch_dist_new NE . and third_touch_dist_new =. then ave_dist = (first_touch_dist_new + second_touch_dist_new ) /2;
*load = 3 and all are missing;
else if load = 3 and first_touch_dist_new =. and second_touch_dist_new =. and third_touch_dist_new =. then ave_dist = .;
run;
%mend avedist;

%avedist(data=lb_wm_base_newdist2, set=lb_wm_base_newdist)
%avedist(data=lb_wm_mid_newdist2, set=lb_wm_mid_newdist)
%avedist(data=lb_wm_end_newdist2, set=lb_wm_end_newdist)

%avedist(data=ng_wm_base_newdist2, set=ng_wm_base_newdist)
%avedist(data=ng_wm_mid_newdist2, set=ng_wm_mid_newdist)
%avedist(data=ng_wm_end_newdist2, set=ng_wm_end_newdist)
;

*look at new dataset;
*macro checkave (data=);
*proc print data=&data(obs=20); 
*run;
*%mend checkave;

*%checkave(data=rcr.lb_wm_base_new_dist2)
%checkave(data=rcr.ng_wm_base_new_dist2)
;
options NOQUOTELENMAX;

*** Calculate number of missed targets (ie. Timed Out) ****;
*** Also creating binary if missed 0-yes 1-no ****;
*** Average of missed_binary var will give percent missed ***;
%macro numbmiss(data=, set=);
data &data;
set &set;
*load = 1;
if load=1 and first_touch_resp_time=. then missed_targets=1;
else if load=1 and first_touch_resp_time NE . then missed_targets=0;
*load=2;
else if load=2 and first_touch_resp_time=. and second_touch_resp_time=. then missed_targets=2;
else if load=2 and first_touch_resp_time NE . and second_touch_resp_time=. then missed_targets=1;
else if load=2 and first_touch_resp_time NE . and second_touch_resp_time NE . then missed_targets=0;
*load=3;
else if load=3 and first_touch_resp_time =. and second_touch_resp_time =. and third_touch_resp_time=. then missed_targets=3;
else if load=3 and first_touch_resp_time NE . and second_touch_resp_time =. and third_touch_resp_time=. then missed_targets=2;
else if load=3 and first_touch_resp_time NE . and second_touch_resp_time NE . and third_touch_resp_time=. then missed_targets=1;
else if load=3 and first_touch_resp_time NE . and second_touch_resp_time NE . and third_touch_resp_time NE . then missed_targets=0;
if missed_targets>0 then missed_binary=0;
else if missed_targets=0 then missed_binary=1;
run;
%mend numbmiss;

%numbmiss(data=rcr.lb_wm_base_newdist3, set=lb_wm_base_newdist2)
%numbmiss(data=rcr.lb_wm_mid_newdist3, set=lb_wm_mid_newdist2)
%numbmiss(data=rcr.lb_wm_end_newdist3, set=lb_wm_end_newdist2)

%numbmiss(data=rcr.ng_wm_base_newdist3, set=ng_wm_base_newdist2)
%numbmiss(data=rcr.ng_wm_mid_newdist3, set=ng_wm_mid_newdist2)
%numbmiss(data=rcr.ng_wm_end_newdist3, set=ng_wm_end_newdist2)
;

*CHECK FINAL DATASET;
%macro checkvars(data=);
title "final &data";
proc print data=&data(obs=20);
run;
%mend checkvars;

%checkvars(data=rcr.lb_wm_base_newdist3)
%checkvars(data=rcr.lb_wm_mid_newdist3)
%checkvars(data=rcr.lb_wm_end_newdist3)

%checkvars(data=rcr.ng_wm_base_newdist3)
%checkvars(data=rcr.ng_wm_mid_newdist3)
%checkvars(data=rcr.ng_wm_end_newdist3)
;


