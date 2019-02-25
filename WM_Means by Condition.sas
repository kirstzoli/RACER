libname rcr "C:\Users\cbford\Documents\RACER\SAS Datasets";

************************** WM Create Average Values per condition for each subject (Wide Dataset) ***********************************;
*************************************************************************************************************************************;

* open datasets, excluding flagged subjects;
%macro loadfile (data=, set=);
data &data; 
set &set;
where remove_flag=0;
run;
%mend loadfile;

*Lebanon*;
%loadfile(data=lb_wm_base, set=rcr.lb_wm_base_trials_final)
%loadfile(data=lb_wm_mid, set=rcr.lb_wm_mid_trials_final)
%loadfile(data=lb_wm_end, set=rcr.lb_wm_end_trials_final)

*Niger*;
%loadfile(data=ng_wm_base, set=rcr.ng_wm_base_trials_final)
%loadfile(data=ng_wm_mid, set=rcr.ng_wm_mid_trials_final)
%loadfile(data=ng_wm_end, set=rcr.ng_wm_end_trials_final)
;

************************************************************************************************************
* 			     		EXPORT FILTERED/CLEANED PRE-AVERAGED RAW DATA 							   		   *
************************************************************************************************************;

%macro exportRAW(data=, outfile=);
proc export data = &data
outfile = &outfile
dbms=xlsx replace;
run;
%mend exportRAW;

%exportRAW(data=rcr.lb_wm_base_trials_final, outfile="C:\Users\cbford\Documents\RACER\Datafiles_means_raw_for_dropboxupload\lb_wm_base_trials.xlsx")
%exportRAW(data=rcr.lb_wm_mid_trials_final, outfile="C:\Users\cbford\Documents\RACER\Datafiles_means_raw_for_dropboxupload\lb_wm_mid_trials.xlsx")
%exportRAW(data=rcr.lb_wm_end_trials_final, outfile="C:\Users\cbford\Documents\RACER\Datafiles_means_raw_for_dropboxupload\lb_wm_end_trials.xlsx")

%exportRAW(data=rcr.ng_wm_base_trials_final, outfile="C:\Users\cbford\Documents\RACER\Datafiles_means_raw_for_dropboxupload\ng_wm_base_trials.xlsx")
%exportRAW(data=rcr.ng_wm_mid_trials_final, outfile="C:\Users\cbford\Documents\RACER\Datafiles_means_raw_for_dropboxupload\ng_wm_mid_trials.xlsx")
%exportRAW(data=rcr.ng_wm_end_trials_final, outfile="C:\Users\cbford\Documents\RACER\Datafiles_means_raw_for_dropboxupload\ng_wm_end_trials.xlsx")
;

******************** Overall Averages, No Conditions ***********************;

%macro mean_overall(data=, var= ,out=) ;
proc means data=&data nway noprint;
class ID;
var &var;
output out=&out(drop=_type_ _freq_)	 mean= /autoname;
run;
%mend mean_overall;

** LB Baseline;
*average distance between touch & dot;
%mean_overall(data=lb_wm_base, var=ave_dist, out=lbbase_dist)
*average number of timed out trials;
%mean_overall(data=lb_wm_base, var=missed_targets, out=lbbase_miss)

** LB Midline;
*average distance between touch & dot;
%mean_overall(data=lb_wm_mid, var=ave_dist, out=lbmid_dist)
*average number of timed out trials;
%mean_overall(data=lb_wm_mid, var=missed_targets, out=lbmid_miss)

** LB Endline;
*average distance between touch & dot;
%mean_overall(data=lb_wm_end, var=ave_dist, out=lbend_dist)
*average number of timed out trials;
%mean_overall(data=lb_wm_end, var=missed_targets, out=lbend_miss)

** NG Baseline;
*average distance between touch & dot;
%mean_overall(data=ng_wm_base, var=ave_dist, out=ngbase_dist)
*average number of timed out trials;
%mean_overall(data=ng_wm_base, var=missed_targets, out=ngbase_miss)

** NG Midline;
*average distance between touch & dot;
%mean_overall(data=ng_wm_mid, var=ave_dist, out=ngmid_dist)
*average number of timed out trials;
%mean_overall(data=ng_wm_mid, var=missed_targets, out=ngmid_miss)

** NG Endline;
*average distance between touch & dot;
%mean_overall(data=ng_wm_end, var=ave_dist, out=ngend_dist)
*average number of timed out trials;
%mean_overall(data=ng_wm_end, var=missed_targets, out=ngend_miss)
;

%macro merge_overall (data=, v1=, v2=);
data &data;
merge &v1 &v2 ;
by ID;
run;
%mend merge_overall;

%merge_overall(data=lb_base_overall, v1=lbbase_dist, v2=lbbase_miss)
%merge_overall(data=lb_mid_overall, v1=lbmid_dist, v2=lbmid_miss)
%merge_overall(data=lb_end_overall, v1=lbend_dist, v2=lbend_miss)

%merge_overall(data=ng_base_overall, v1=ngbase_dist, v2=ngbase_miss)
%merge_overall(data=ng_mid_overall, v1=ngmid_dist, v2=ngmid_miss)
%merge_overall(data=ng_end_overall, v1=ngend_dist, v2=ngend_miss)
;

*checking overall means dataset;
%macro checkoverall (data=);
proc print data=&data(obs=10);  run;
%mend checkoverall;

%checkoverall(data=lb_base_overall)
%checkoverall(data=lb_mid_overall)
%checkoverall(data=lb_end_overall)

%checkoverall(data=ng_base_overall)
%checkoverall(data=ng_mid_overall)
%checkoverall(data=ng_end_overall)
;

****************** By Condition: Load/Delay combinations *************************
	* load=1, delay=0 (4)
	* load=1, delay=3 (7)
	* load=2, delay=0 (4)
	* load=2, delay=3 (7)
	* load=3, delay=0 (4)
	* load=3, delay=3 (7)
***************************************************************************;

*sort;
%macro sortLOAD (data=);
proc sort data=&data; by load delay; run;
%mend sortLOAD;

%sortLOAD(data=lb_wm_base)
%sortLOAD(data=lb_wm_mid)
%sortLOAD(data=lb_wm_end)

%sortLOAD(data=ng_wm_base)
%sortLOAD(data=ng_wm_mid)
%sortLOAD(data=ng_wm_end)
;

*get means by CONDITION per person;
%macro mean_cond(data=, var= ,out=, load=, delay=, cond=) ;
proc means data=&data nway noprint;
class ID;
var &var;
where load=&load and delay=&delay;
output out=&out(drop=_type_ _freq_)	 mean= &cond;
run;
%mend mean_cond;

*** LB Baseline;
*average distance between touch & dot;
%mean_cond(data=lb_wm_base, var=ave_dist, out=lbbaseL1D0_dist, load=1, delay=0, cond=L1D0_avedist)
%mean_cond(data=lb_wm_base, var=ave_dist, out=lbbaseL1D3_dist, load=1, delay=3, cond=L1D3_avedist)
%mean_cond(data=lb_wm_base, var=ave_dist, out=lbbaseL2D0_dist, load=2, delay=0, cond=L2D0_avedist)
%mean_cond(data=lb_wm_base, var=ave_dist, out=lbbaseL2D3_dist, load=2, delay=3, cond=L2D3_avedist)
%mean_cond(data=lb_wm_base, var=ave_dist, out=lbbaseL3D0_dist, load=3, delay=0, cond=L3D0_avedist)
%mean_cond(data=lb_wm_base, var=ave_dist, out=lbbaseL3D3_dist, load=3, delay=3, cond=L3D3_avedist)
*average number of timed out trials;
%mean_cond(data=lb_wm_base, var=missed_targets, out=lbbaseL1D0_miss, load=1, delay=0, cond=L1D0_missed)
%mean_cond(data=lb_wm_base, var=missed_targets, out=lbbaseL1D3_miss, load=1, delay=3, cond=L1D3_missed)
%mean_cond(data=lb_wm_base, var=missed_targets, out=lbbaseL2D0_miss, load=2, delay=0, cond=L2D0_missed)
%mean_cond(data=lb_wm_base, var=missed_targets, out=lbbaseL2D3_miss, load=2, delay=3, cond=L2D3_missed)
%mean_cond(data=lb_wm_base, var=missed_targets, out=lbbaseL3D0_miss, load=3, delay=0, cond=L3D0_missed)
%mean_cond(data=lb_wm_base, var=missed_targets, out=lbbaseL3D3_miss, load=3, delay=3, cond=L3D3_missed)

*** LB Midline;
*average distance between touch & dot;
%mean_cond(data=lb_wm_mid, var=ave_dist, out=lbmidL1D0_dist, load=1, delay=0, cond=L1D0_avedist)
%mean_cond(data=lb_wm_mid, var=ave_dist, out=lbmidL1D3_dist, load=1, delay=3, cond=L1D3_avedist)
%mean_cond(data=lb_wm_mid, var=ave_dist, out=lbmidL2D0_dist, load=2, delay=0, cond=L2D0_avedist)
%mean_cond(data=lb_wm_mid, var=ave_dist, out=lbmidL2D3_dist, load=2, delay=3, cond=L2D3_avedist)
%mean_cond(data=lb_wm_mid, var=ave_dist, out=lbmidL3D0_dist, load=3, delay=0, cond=L3D0_avedist)
%mean_cond(data=lb_wm_mid, var=ave_dist, out=lbmidL3D3_dist, load=3, delay=3, cond=L3D3_avedist)
*average number of timed out trials;
%mean_cond(data=lb_wm_mid, var=missed_targets, out=lbmidL1D0_miss, load=1, delay=0, cond=L1D0_missed)
%mean_cond(data=lb_wm_mid, var=missed_targets, out=lbmidL1D3_miss, load=1, delay=3, cond=L1D3_missed)
%mean_cond(data=lb_wm_mid, var=missed_targets, out=lbmidL2D0_miss, load=2, delay=0, cond=L2D0_missed)
%mean_cond(data=lb_wm_mid, var=missed_targets, out=lbmidL2D3_miss, load=2, delay=3, cond=L2D3_missed)
%mean_cond(data=lb_wm_mid, var=missed_targets, out=lbmidL3D0_miss, load=3, delay=0, cond=L3D0_missed)
%mean_cond(data=lb_wm_mid, var=missed_targets, out=lbmidL3D3_miss, load=3, delay=3, cond=L3D3_missed)

*** LB Endline;
*average distance between touch & dot;
%mean_cond(data=lb_wm_end, var=ave_dist, out=lbendL1D0_dist, load=1, delay=0, cond=L1D0_avedist)
%mean_cond(data=lb_wm_end, var=ave_dist, out=lbendL1D3_dist, load=1, delay=3, cond=L1D3_avedist)
%mean_cond(data=lb_wm_end, var=ave_dist, out=lbendL2D0_dist, load=2, delay=0, cond=L2D0_avedist)
%mean_cond(data=lb_wm_end, var=ave_dist, out=lbendL2D3_dist, load=2, delay=3, cond=L2D3_avedist)
%mean_cond(data=lb_wm_end, var=ave_dist, out=lbendL3D0_dist, load=3, delay=0, cond=L3D0_avedist)
%mean_cond(data=lb_wm_end, var=ave_dist, out=lbendL3D3_dist, load=3, delay=3, cond=L3D3_avedist)
*average number of timed out trials;
%mean_cond(data=lb_wm_end, var=missed_targets, out=lbendL1D0_miss, load=1, delay=0, cond=L1D0_missed)
%mean_cond(data=lb_wm_end, var=missed_targets, out=lbendL1D3_miss, load=1, delay=3, cond=L1D3_missed)
%mean_cond(data=lb_wm_end, var=missed_targets, out=lbendL2D0_miss, load=2, delay=0, cond=L2D0_missed)
%mean_cond(data=lb_wm_end, var=missed_targets, out=lbendL2D3_miss, load=2, delay=3, cond=L2D3_missed)
%mean_cond(data=lb_wm_end, var=missed_targets, out=lbendL3D0_miss, load=3, delay=0, cond=L3D0_missed)
%mean_cond(data=lb_wm_end, var=missed_targets, out=lbendL3D3_miss, load=3, delay=3, cond=L3D3_missed)

*** NG Baseline;
*average distance between touch & dot;
%mean_cond(data=ng_wm_base, var=ave_dist, out=ngbaseL1D0_dist, load=1, delay=0, cond=L1D0_avedist)
%mean_cond(data=ng_wm_base, var=ave_dist, out=ngbaseL1D3_dist, load=1, delay=3, cond=L1D3_avedist)
%mean_cond(data=ng_wm_base, var=ave_dist, out=ngbaseL2D0_dist, load=2, delay=0, cond=L2D0_avedist)
%mean_cond(data=ng_wm_base, var=ave_dist, out=ngbaseL2D3_dist, load=2, delay=3, cond=L2D3_avedist)
%mean_cond(data=ng_wm_base, var=ave_dist, out=ngbaseL3D0_dist, load=3, delay=0, cond=L3D0_avedist)
%mean_cond(data=ng_wm_base, var=ave_dist, out=ngbaseL3D3_dist, load=3, delay=3, cond=L3D3_avedist)
*average number of timed out trials;
%mean_cond(data=ng_wm_base, var=missed_targets, out=ngbaseL1D0_miss, load=1, delay=0, cond=L1D0_missed)
%mean_cond(data=ng_wm_base, var=missed_targets, out=ngbaseL1D3_miss, load=1, delay=3, cond=L1D3_missed)
%mean_cond(data=ng_wm_base, var=missed_targets, out=ngbaseL2D0_miss, load=2, delay=0, cond=L2D0_missed)
%mean_cond(data=ng_wm_base, var=missed_targets, out=ngbaseL2D3_miss, load=2, delay=3, cond=L2D3_missed)
%mean_cond(data=ng_wm_base, var=missed_targets, out=ngbaseL3D0_miss, load=3, delay=0, cond=L3D0_missed)
%mean_cond(data=ng_wm_base, var=missed_targets, out=ngbaseL3D3_miss, load=3, delay=3, cond=L3D3_missed)

*** NG Midline;
*average distance between touch & dot;
%mean_cond(data=ng_wm_mid, var=ave_dist, out=ngmidL1D0_dist, load=1, delay=0, cond=L1D0_avedist)
%mean_cond(data=ng_wm_mid, var=ave_dist, out=ngmidL1D3_dist, load=1, delay=3, cond=L1D3_avedist)
%mean_cond(data=ng_wm_mid, var=ave_dist, out=ngmidL2D0_dist, load=2, delay=0, cond=L2D0_avedist)
%mean_cond(data=ng_wm_mid, var=ave_dist, out=ngmidL2D3_dist, load=2, delay=3, cond=L2D3_avedist)
%mean_cond(data=ng_wm_mid, var=ave_dist, out=ngmidL3D0_dist, load=3, delay=0, cond=L3D0_avedist)
%mean_cond(data=ng_wm_mid, var=ave_dist, out=ngmidL3D3_dist, load=3, delay=3, cond=L3D3_avedist)
*average number of timed out trials;
%mean_cond(data=ng_wm_mid, var=missed_targets, out=ngmidL1D0_miss, load=1, delay=0, cond=L1D0_missed)
%mean_cond(data=ng_wm_mid, var=missed_targets, out=ngmidL1D3_miss, load=1, delay=3, cond=L1D3_missed)
%mean_cond(data=ng_wm_mid, var=missed_targets, out=ngmidL2D0_miss, load=2, delay=0, cond=L2D0_missed)
%mean_cond(data=ng_wm_mid, var=missed_targets, out=ngmidL2D3_miss, load=2, delay=3, cond=L2D3_missed)
%mean_cond(data=ng_wm_mid, var=missed_targets, out=ngmidL3D0_miss, load=3, delay=0, cond=L3D0_missed)
%mean_cond(data=ng_wm_mid, var=missed_targets, out=ngmidL3D3_miss, load=3, delay=3, cond=L3D3_missed)

*** NG Endline;
*average distance between touch & dot;
%mean_cond(data=ng_wm_end, var=ave_dist, out=ngendL1D0_dist, load=1, delay=0, cond=L1D0_avedist)
%mean_cond(data=ng_wm_end, var=ave_dist, out=ngendL1D3_dist, load=1, delay=3, cond=L1D3_avedist)
%mean_cond(data=ng_wm_end, var=ave_dist, out=ngendL2D0_dist, load=2, delay=0, cond=L2D0_avedist)
%mean_cond(data=ng_wm_end, var=ave_dist, out=ngendL2D3_dist, load=2, delay=3, cond=L2D3_avedist)
%mean_cond(data=ng_wm_end, var=ave_dist, out=ngendL3D0_dist, load=3, delay=0, cond=L3D0_avedist)
%mean_cond(data=ng_wm_end, var=ave_dist, out=ngendL3D3_dist, load=3, delay=3, cond=L3D3_avedist)
*average number of timed out trials;
%mean_cond(data=ng_wm_end, var=missed_targets, out=ngendL1D0_miss, load=1, delay=0, cond=L1D0_missed)
%mean_cond(data=ng_wm_end, var=missed_targets, out=ngendL1D3_miss, load=1, delay=3, cond=L1D3_missed)
%mean_cond(data=ng_wm_end, var=missed_targets, out=ngendL2D0_miss, load=2, delay=0, cond=L2D0_missed)
%mean_cond(data=ng_wm_end, var=missed_targets, out=ngendL2D3_miss, load=2, delay=3, cond=L2D3_missed)
%mean_cond(data=ng_wm_end, var=missed_targets, out=ngendL3D0_miss, load=3, delay=0, cond=L3D0_missed)
%mean_cond(data=ng_wm_end, var=missed_targets, out=ngendL3D3_miss, load=3, delay=3, cond=L3D3_missed)
;

*merge into single file;
%macro merge_cond (data=, v1=, v2=, v3=, v4=, v5=, v6=, v7=, v8=, v9=, v10=, v11=, v12=);
data &data;
merge &v1 &v2 &v3 &v4 &v5 &v6 &v7 &v8 &v9 &v10 &v11 &v12;
by ID;
run;
%mend merge_cond;

*LB;
%merge_cond(data=lb_base_cond, v1=lbbaseL1D0_dist, v2=lbbaseL1D3_dist, v3=lbbaseL2D0_dist, v4=lbbaseL2D3_dist, v5=lbbaseL3D0_dist, v6=lbbaseL3D3_dist,
			v7=lbbaseL1D0_miss, v8=lbbaseL1D3_miss, v9=lbbaseL2D0_miss, v10=lbbaseL2D3_miss, v11=lbbaseL3D0_miss, v12=lbbaseL3D3_miss)

%merge_cond(data=lb_mid_cond, v1=lbmidL1D0_dist, v2=lbmidL1D3_dist, v3=lbmidL2D0_dist, v4=lbmidL2D3_dist, v5=lbmidL3D0_dist, v6=lbmidL3D3_dist,
			v7=lbmidL1D0_miss, v8=lbmidL1D3_miss, v9=lbmidL2D0_miss, v10=lbmidL2D3_miss, v11=lbmidL3D0_miss, v12=lbmidL3D3_miss)

%merge_cond(data=lb_end_cond, v1=lbendL1D0_dist, v2=lbendL1D3_dist, v3=lbendL2D0_dist, v4=lbendL2D3_dist, v5=lbendL3D0_dist, v6=lbendL3D3_dist,
			v7=lbendL1D0_miss, v8=lbendL1D3_miss, v9=lbendL2D0_miss, v10=lbendL2D3_miss, v11=lbendL3D0_miss, v12=lbendL3D3_miss)

*NG;
%merge_cond(data=ng_base_cond, v1=ngbaseL1D0_dist, v2=ngbaseL1D3_dist, v3=ngbaseL2D0_dist, v4=ngbaseL2D3_dist, v5=ngbaseL3D0_dist, v6=ngbaseL3D3_dist,
			v7=ngbaseL1D0_miss, v8=ngbaseL1D3_miss, v9=ngbaseL2D0_miss, v10=ngbaseL2D3_miss, v11=ngbaseL3D0_miss, v12=ngbaseL3D3_miss)

%merge_cond(data=ng_mid_cond, v1=ngmidL1D0_dist, v2=ngmidL1D3_dist, v3=ngmidL2D0_dist, v4=ngmidL2D3_dist, v5=ngmidL3D0_dist, v6=ngmidL3D3_dist,
			v7=ngmidL1D0_miss, v8=ngmidL1D3_miss, v9=ngmidL2D0_miss, v10=ngmidL2D3_miss, v11=ngmidL3D0_miss, v12=ngmidL3D3_miss)

%merge_cond(data=ng_end_cond, v1=ngendL1D0_dist, v2=ngendL1D3_dist, v3=ngendL2D0_dist, v4=ngendL2D3_dist, v5=ngendL3D0_dist, v6=ngendL3D3_dist,
			v7=ngendL1D0_miss, v8=ngendL1D3_miss, v9=ngendL2D0_miss, v10=ngendL2D3_miss, v11=ngendL3D0_miss, v12=ngendL3D3_miss)
;

*checking condition means dataset;
%macro checkCOND (data=);
proc print data=&data(obs=10);  run;
%mend checkCOND;

%checkcond(data=lb_base_cond)
%checkcond(data=lb_mid_cond)
%checkcond(data=lb_end_cond)

%checkcond(data=ng_base_cond)
%checkcond(data=ng_mid_cond)
%checkcond(data=ng_end_cond)
;

************ By Load Condition: Load=1, Load=2, Load=3 *******************;
*sort;
%macro sortLOAD (data=);
proc sort data=&data; by load; run;
%mend sortLOAD;

%sortLOAD(data=lb_wm_base)
%sortLOAD(data=lb_wm_mid)
%sortLOAD(data=lb_wm_end)

%sortLOAD(data=ng_wm_base)
%sortLOAD(data=ng_wm_mid)
%sortLOAD(data=ng_wm_end)
;

*get means by LOAD per person;
%macro mean_load(data=, var= ,out=, load=, cond=) ;
proc means data=&data nway noprint;
class ID;
var &var;
where load=&load;
output out=&out(drop=_type_ _freq_)	 mean= &cond;
run;
%mend mean_load;

*LB Baseline;
*average distance between touch & dot;
%mean_load(data=lb_wm_base, var=ave_dist, out=lbbaseload1_dist, load=1, cond=load1_avedist)
%mean_load(data=lb_wm_base, var=ave_dist, out=lbbaseload2_dist, load=2, cond=load2_avedist)
%mean_load(data=lb_wm_base, var=ave_dist, out=lbbaseload3_dist, load=3, cond=load3_avedist)
*average timed out trials;
%mean_load(data=lb_wm_base, var=missed_targets, out=lbbaseload1_miss, load=1, cond=load1_missed)
%mean_load(data=lb_wm_base, var=missed_targets, out=lbbaseload2_miss, load=2, cond=load2_missed)
%mean_load(data=lb_wm_base, var=missed_targets, out=lbbaseload3_miss, load=3, cond=load3_missed)

*LB Midline;
*average distance between touch & dot;
%mean_load(data=lb_wm_mid, var=ave_dist, out=lbmidload1_dist, load=1, cond=load1_avedist)
%mean_load(data=lb_wm_mid, var=ave_dist, out=lbmidload2_dist, load=2, cond=load2_avedist)
%mean_load(data=lb_wm_mid, var=ave_dist, out=lbmidload3_dist, load=3, cond=load3_avedist)
*average timed out trials;
%mean_load(data=lb_wm_mid, var=missed_targets, out=lbmidload1_miss, load=1, cond=load1_missed)
%mean_load(data=lb_wm_mid, var=missed_targets, out=lbmidload2_miss, load=2, cond=load2_missed)
%mean_load(data=lb_wm_mid, var=missed_targets, out=lbmidload3_miss, load=3, cond=load3_missed)

*LB Endline;
*average distance between touch & dot;
%mean_load(data=lb_wm_end, var=ave_dist, out=lbendload1_dist, load=1, cond=load1_avedist)
%mean_load(data=lb_wm_end, var=ave_dist, out=lbendload2_dist, load=2, cond=load2_avedist)
%mean_load(data=lb_wm_end, var=ave_dist, out=lbendload3_dist, load=3, cond=load3_avedist)
*average timed out trials;
%mean_load(data=lb_wm_end, var=missed_targets, out=lbendload1_miss, load=1, cond=load1_missed)
%mean_load(data=lb_wm_end, var=missed_targets, out=lbendload2_miss, load=2, cond=load2_missed)
%mean_load(data=lb_wm_end, var=missed_targets, out=lbendload3_miss, load=3, cond=load3_missed)

*NG Baseline;
*average distance between touch & dot;
%mean_load(data=ng_wm_base, var=ave_dist, out=ngbaseload1_dist, load=1, cond=load1_avedist)
%mean_load(data=ng_wm_base, var=ave_dist, out=ngbaseload2_dist, load=2, cond=load2_avedist)
%mean_load(data=ng_wm_base, var=ave_dist, out=ngbaseload3_dist, load=3, cond=load3_avedist)
*average timed out trials;
%mean_load(data=ng_wm_base, var=missed_targets, out=ngbaseload1_miss, load=1, cond=load1_missed)
%mean_load(data=ng_wm_base, var=missed_targets, out=ngbaseload2_miss, load=2, cond=load2_missed)
%mean_load(data=ng_wm_base, var=missed_targets, out=ngbaseload3_miss, load=3, cond=load3_missed)

*NG Midline;
*average distance between touch & dot;
%mean_load(data=ng_wm_mid, var=ave_dist, out=ngmidload1_dist, load=1, cond=load1_avedist)
%mean_load(data=ng_wm_mid, var=ave_dist, out=ngmidload2_dist, load=2, cond=load2_avedist)
%mean_load(data=ng_wm_mid, var=ave_dist, out=ngmidload3_dist, load=3, cond=load3_avedist)
*average timed out trials;
%mean_load(data=ng_wm_mid, var=missed_targets, out=ngmidload1_miss, load=1, cond=load1_missed)
%mean_load(data=ng_wm_mid, var=missed_targets, out=ngmidload2_miss, load=2, cond=load2_missed)
%mean_load(data=ng_wm_mid, var=missed_targets, out=ngmidload3_miss, load=3, cond=load3_missed)

*NG Endline;
*average distance between touch & dot;
%mean_load(data=ng_wm_end, var=ave_dist, out=ngendload1_dist, load=1, cond=load1_avedist)
%mean_load(data=ng_wm_end, var=ave_dist, out=ngendload2_dist, load=2, cond=load2_avedist)
%mean_load(data=ng_wm_end, var=ave_dist, out=ngendload3_dist, load=3, cond=load3_avedist)
*average timed out trials;
%mean_load(data=ng_wm_end, var=missed_targets, out=ngendload1_miss, load=1, cond=load1_missed)
%mean_load(data=ng_wm_end, var=missed_targets, out=ngendload2_miss, load=2, cond=load2_missed)
%mean_load(data=ng_wm_end, var=missed_targets, out=ngendload3_miss, load=3, cond=load3_missed)
;

*merge into single file;
%macro merge_load (data=, v1=, v2=, v3=, v4=, v5=, v6=);
data &data;
merge &v1 &v2 &v3 &v4 &v5 &v6 ;
by ID;
run;
%mend merge_load;

%merge_load(data=lb_base_load, v1=lbbaseload1_dist, v2=lbbaseload2_dist, v3=lbbaseload3_dist, 
			v4=lbbaseload1_miss, v5=lbbaseload2_miss, v6=lbbaseload3_miss)

%merge_load(data=lb_mid_load, v1=lbmidload1_dist, v2=lbmidload2_dist, v3=lbmidload3_dist, 
			v4=lbmidload1_miss, v5=lbmidload2_miss, v6=lbmidload3_miss)

%merge_load(data=lb_end_load, v1=lbendload1_dist, v2=lbendload2_dist, v3=lbendload3_dist, 
			v4=lbendload1_miss, v5=lbendload2_miss, v6=lbendload3_miss)

%merge_load(data=ng_base_load, v1=ngbaseload1_dist, v2=ngbaseload2_dist, v3=ngbaseload3_dist, 
			v4=ngbaseload1_miss, v5=ngbaseload2_miss, v6=ngbaseload3_miss)

%merge_load(data=ng_mid_load, v1=ngmidload1_dist, v2=ngmidload2_dist, v3=ngmidload3_dist, 
			v4=ngmidload1_miss, v5=ngmidload2_miss, v6=ngmidload3_miss)

%merge_load(data=ng_end_load, v1=ngendload1_dist, v2=ngendload2_dist, v3=ngendload3_dist, 
			v4=ngendload1_miss, v5=ngendload2_miss, v6=ngendload3_miss)
;

*checking load means dataset;
%macro checkLOAD(data=);
proc print data=&data(obs=10);  run;
%mend checkLOAD;

%checkLOAD(data=lb_base_load)
%checkLOAD(data=lb_mid_load)
%checkLOAD(data=lb_end_load)

%checkLOAD(data=ng_base_load)
%checkLOAD(data=ng_mid_load)
%checkLOAD(data=ng_end_load)
;

************ By Delay: Delay=0 and Delay=3 *******************;
*sort;
%macro sortDELAY (data=);
proc sort data=&data; by delay; run;
%mend sortDELAY;

%sortDELAY(data=lb_wm_base)
%sortDELAY(data=lb_wm_mid)
%sortDELAY(data=lb_wm_end)

%sortDELAY(data=ng_wm_base)
%sortDELAY(data=ng_wm_mid)
%sortDELAY(data=ng_wm_end)
;

*get means by LOAD per person;
%macro mean_delay(data=, var= ,out=, delay=, cond=) ;
proc means data=&data nway noprint;
class ID;
var &var;
where delay=&delay;
output out=&out(drop=_type_ _freq_)	 mean= &cond;
run;
%mend mean_delay;

*LB Baseline
*average distance between touch & dot;
%mean_delay(data=lb_wm_base, var=ave_dist, out=lbbasedelay0_dist, delay=0, cond=delay0_avedist)
%mean_delay(data=lb_wm_base, var=ave_dist, out=lbbasedelay3_dist, delay=3, cond=delay3_avedist)
*average timed out trials;
%mean_delay(data=lb_wm_base, var=missed_targets, out=lbbasedelay0_miss, delay=0, cond=delay0_missed)
%mean_delay(data=lb_wm_base, var=missed_targets, out=lbbasedelay3_miss, delay=3, cond=delay3_missed)

*LB Midline
*average distance between touch & dot;
%mean_delay(data=lb_wm_mid, var=ave_dist, out=lbmiddelay0_dist, delay=0, cond=delay0_avedist)
%mean_delay(data=lb_wm_mid, var=ave_dist, out=lbmiddelay3_dist, delay=3, cond=delay3_avedist)
*average timed out trials;
%mean_delay(data=lb_wm_mid, var=missed_targets, out=lbmiddelay0_miss, delay=0, cond=delay0_missed)
%mean_delay(data=lb_wm_mid, var=missed_targets, out=lbmiddelay3_miss, delay=3, cond=delay3_missed)

*LB Endline
*average distance between touch & dot;
%mean_delay(data=lb_wm_end, var=ave_dist, out=lbenddelay0_dist, delay=0, cond=delay0_avedist)
%mean_delay(data=lb_wm_end, var=ave_dist, out=lbenddelay3_dist, delay=3, cond=delay3_avedist)
*average timed out trials;
%mean_delay(data=lb_wm_end, var=missed_targets, out=lbenddelay0_miss, delay=0, cond=delay0_missed)
%mean_delay(data=lb_wm_end, var=missed_targets, out=lbenddelay3_miss, delay=3, cond=delay3_missed)

*NG Baseline
*average distance between touch & dot;
%mean_delay(data=ng_wm_base, var=ave_dist, out=ngbasedelay0_dist, delay=0, cond=delay0_avedist)
%mean_delay(data=ng_wm_base, var=ave_dist, out=ngbasedelay3_dist, delay=3, cond=delay3_avedist)
*average timed out trials;
%mean_delay(data=ng_wm_base, var=missed_targets, out=ngbasedelay0_miss, delay=0, cond=delay0_missed)
%mean_delay(data=ng_wm_base, var=missed_targets, out=ngbasedelay3_miss, delay=3, cond=delay3_missed)

*NG Midline
*average distance between touch & dot;
%mean_delay(data=ng_wm_mid, var=ave_dist, out=ngmiddelay0_dist, delay=0, cond=delay0_avedist)
%mean_delay(data=ng_wm_mid, var=ave_dist, out=ngmiddelay3_dist, delay=3, cond=delay3_avedist)
*average timed out trials;
%mean_delay(data=ng_wm_mid, var=missed_targets, out=ngmiddelay0_miss, delay=0, cond=delay0_missed)
%mean_delay(data=ng_wm_mid, var=missed_targets, out=ngmiddelay3_miss, delay=3, cond=delay3_missed)

*NG Endline
*average distance between touch & dot;
%mean_delay(data=ng_wm_end, var=ave_dist, out=ngenddelay0_dist, delay=0, cond=delay0_avedist)
%mean_delay(data=ng_wm_end, var=ave_dist, out=ngenddelay3_dist, delay=3, cond=delay3_avedist)
*average timed out trials;
%mean_delay(data=ng_wm_end, var=missed_targets, out=ngenddelay0_miss, delay=0, cond=delay0_missed)
%mean_delay(data=ng_wm_end, var=missed_targets, out=ngenddelay3_miss, delay=3, cond=delay3_missed)
;

*merge into single file;
%macro merge_delay (data=, v1=, v2=, v3=, v4=);
data &data;
merge &v1 &v2 &v3 &v4;
by ID;
run;
%mend merge_delay;

%merge_delay(data=lb_base_delay, v1=lbbasedelay0_dist, v2=lbbasedelay3_dist, v3=lbbasedelay0_miss, v4=lbbasedelay3_miss)
%merge_delay(data=lb_mid_delay, v1=lbmiddelay0_dist, v2=lbmiddelay3_dist, v3=lbmiddelay0_miss, v4=lbmiddelay3_miss)
%merge_delay(data=lb_end_delay, v1=lbenddelay0_dist, v2=lbenddelay3_dist, v3=lbenddelay0_miss, v4=lbenddelay3_miss)

%merge_delay(data=ng_base_delay, v1=ngbasedelay0_dist, v2=ngbasedelay3_dist, v3=ngbasedelay0_miss, v4=ngbasedelay3_miss)
%merge_delay(data=ng_mid_delay, v1=ngmiddelay0_dist, v2=ngmiddelay3_dist, v3=ngmiddelay0_miss, v4=ngmiddelay3_miss)
%merge_delay(data=ng_end_delay, v1=ngenddelay0_dist, v2=ngenddelay3_dist, v3=ngenddelay0_miss, v4=ngenddelay3_miss)
;

*checking delay means dataset;
%macro checkDELAY(data=);
proc print data=&data(obs=10);  run;
%mend checkDELAY;

%checkDELAY(data=lb_base_delay)
%checkDELAY(data=lb_mid_delay)
%checkDELAY(data=lb_end_delay)

%checkDELAY(data=ng_base_delay)
%checkDELAY(data=ng_mid_delay)
%checkDELAY(data=ng_end_delay)
;

**************** Merge all means into single file with all outcomes ****************;
%macro sort_all (data); 
proc sort data=&data; by id; run;
%mend sort_all; 

*LB Baseline;
%sort_all(lb_base_overall)
%sort_all(lb_base_cond)
%sort_all(lb_base_load)
%sort_all(lb_base_delay)

*LB Midline;
%sort_all(lb_mid_overall)
%sort_all(lb_mid_cond)
%sort_all(lb_mid_load)
%sort_all(lb_mid_delay)

*LB Endline;
%sort_all(lb_end_overall)
%sort_all(lb_end_cond)
%sort_all(lb_end_load)
%sort_all(lb_end_delay)

*NG Baseline;
%sort_all(ng_base_overall)
%sort_all(ng_base_cond)
%sort_all(ng_base_load)
%sort_all(ng_base_delay)

*NG Midline;
%sort_all(ng_mid_overall)
%sort_all(ng_mid_cond)
%sort_all(ng_mid_load)
%sort_all(ng_mid_delay)

*NG Endline;
%sort_all(ng_end_overall)
%sort_all(ng_end_cond)
%sort_all(ng_end_load)
%sort_all(ng_end_delay)
;

%macro merge_all (data=, f1=, f2=, f3=, f4=);
data &data;
merge &f1 &f2 &f3 &f4;
by ID;
run;
%mend merge_all;

%merge_all(data=rcr.lb_wm_base_means, f1=lb_base_overall, f2=lb_base_cond, f3=lb_base_load, f4=lb_base_delay)
%merge_all(data=rcr.lb_wm_mid_means, f1=lb_mid_overall, f2=lb_mid_cond, f3=lb_mid_load, f4=lb_mid_delay)
%merge_all(data=rcr.lb_wm_end_means, f1=lb_end_overall, f2=lb_end_cond, f3=lb_end_load, f4=lb_end_delay)

%merge_all(data=rcr.ng_wm_base_means, f1=ng_base_overall, f2=ng_base_cond, f3=ng_base_load, f4=ng_base_delay)
%merge_all(data=rcr.ng_wm_mid_means, f1=ng_mid_overall, f2=ng_mid_cond, f3=ng_mid_load, f4=ng_mid_delay)
%merge_all(data=rcr.ng_wm_end_means, f1=ng_end_overall, f2=ng_end_cond, f3=ng_end_load, f4=ng_end_delay)
;

%macro checkfinal(data=);
title "final &data";
proc print data=&data(obs=10); 
run;
%mend checkfinal;

%checkfinal(data=rcr.lb_wm_base_means)
%checkfinal(data=rcr.lb_wm_mid_means)
%checkfinal(data=rcr.lb_wm_end_means)

%checkfinal(data=rcr.ng_wm_base_means)
%checkfinal(data=rcr.ng_wm_mid_means)
%checkfinal(data=rcr.ng_wm_end_means)
;

**************************************************************************************************;
*								 EXPORT MEANS TO EXCEL 											  ;
**************************************************************************************************;

%macro export(data=, outfile=);
proc export data =&data
outfile = &outfile
dbms=xlsx replace;
run;
%mend export;

%export(data= rcr.lb_wm_base_means, outfile="C:\Users\cbford\Documents\RACER\Datafiles_means_raw_for_dropboxupload\lb_wm_base_means.xlsx")
%export(data= rcr.lb_wm_mid_means, outfile="C:\Users\cbford\Documents\RACER\Datafiles_means_raw_for_dropboxupload\lb_wm_mid_means.xlsx")
%export(data= rcr.lb_wm_end_means, outfile="C:\Users\cbford\Documents\RACER\Datafiles_means_raw_for_dropboxupload\lb_wm_end_means.xlsx")

%export(data= rcr.ng_wm_base_means, outfile="C:\Users\cbford\Documents\RACER\Datafiles_means_raw_for_dropboxupload\ng_wm_base_means.xlsx")
%export(data= rcr.ng_wm_mid_means, outfile="C:\Users\cbford\Documents\RACER\Datafiles_means_raw_for_dropboxupload\ng_wm_mid_means.xlsx")
%export(data= rcr.ng_wm_end_means, outfile="C:\Users\cbford\Documents\RACER\Datafiles_means_raw_for_dropboxupload\ng_wm_end_means.xlsx")

;

*************************************************************************************************************;
*									COUNT IDS IN FINAL DATASETS			 									*;
*************************************************************************************************************;

%macro idcountWM_AVES (data=);
proc iml;
 use &data;
 read all var{id} into x;
 close;

 title "ID count in &data";
 print nobs;
 print (nrow(x));
quit;
%mend idcountWM_AVES;

%idcountWM_AVES(data= rcr.lb_wm_base_means)
%idcountWM_AVES(data= rcr.lb_wm_mid_means )
%idcountWM_AVES(data= rcr.lb_wm_end_means )
%idcountWM_AVES(data= rcr.ng_wm_base_means)
%idcountWM_AVES(data= rcr.ng_wm_mid_means )
%idcountWM_AVES(data= rcr.ng_wm_end_means )
;
