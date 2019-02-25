libname rcr "C:\Users\cbford\Documents\RACER\SAS Datasets";

************************************************************************************************************
* 					READ IN CLEANED TRIAL DATA 															   *
************************************************************************************************************;

%macro readin(data=, set=);
data &data; 
set &set; 
run;
%mend readin;

%readin(data=lb_base,  set=rcr.lb_bi_base_final_raw_cleaned)
%readin(data=lb_mid,  set=rcr.lb_bi_mid_final_raw_cleaned)
%readin(data=lb_end,  set=rcr.lb_bi_end_final_raw_cleaned)

%readin(data=ng_base,  set=rcr.ng_bi_base_final_raw_cleaned)
%readin(data=ng_mid,  set=rcr.ng_bi_mid_final_raw_cleaned)
%readin(data=ng_end,  set=rcr.ng_bi_end_final_raw_cleaned)

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

%exportRAW(data=rcr.lb_bi_base_final_raw_cleaned, outfile="C:\Users\cbford\Documents\RACER\Datafiles_means_raw_for_dropboxupload\lb_bi_base_trials.xlsx")
%exportRAW(data=rcr.lb_bi_mid_final_raw_cleaned, outfile="C:\Users\cbford\Documents\RACER\Datafiles_means_raw_for_dropboxupload\lb_bi_mid_trials.xlsx")
%exportRAW(data=rcr.lb_bi_end_final_raw_cleaned, outfile="C:\Users\cbford\Documents\RACER\Datafiles_means_raw_for_dropboxupload\lb_bi_end_trials.xlsx")

%exportRAW(data=rcr.ng_bi_base_final_raw_cleaned, outfile="C:\Users\cbford\Documents\RACER\Datafiles_means_raw_for_dropboxupload\ng_bi_base_trials.xlsx")
%exportRAW(data=rcr.ng_bi_mid_final_raw_cleaned, outfile="C:\Users\cbford\Documents\RACER\Datafiles_means_raw_for_dropboxupload\ng_bi_mid_trials.xlsx")
%exportRAW(data=rcr.ng_bi_end_final_raw_cleaned, outfile="C:\Users\cbford\Documents\RACER\Datafiles_means_raw_for_dropboxupload\ng_bi_end_trials.xlsx")
;

************************************************************************************************************
* 			     		CALCULATING OUTCOME MEANS by condition for each subject							   *
************************************************************************************************************;

**********************************************************;
******* By Inhibition conditions: sameside vs. oppside ***;
**********************************************************;

* sort by condition first;
%macro sortCOND(data=);
proc sort data=&data; 
by condition; 
run;
%mend sortCOND;

%sortCOND(data=lb_base)
%sortCOND(data=lb_mid)
%sortCOND(data=lb_end)

%sortCOND(data=ng_base)
%sortCOND(data=ng_mid)
%sortCOND(data=ng_end)
;

** Macro for distance outcomes -- by inhbition conditions;
** one distance variable at a time;
%macro meandistbi(data=, dist= ,out=) ;
proc means data=&data nway noprint;
class ID;
var &dist;
by condition ;
output out=&out(drop=_type_ _freq_)	 mean= /autoname;
run;
%mend meandistbi;

%meandistbi(data=lb_base, dist=first_touch_ctrdistl , out=lb_base_means_distl_bicond)
%meandistbi(data=lb_base, dist=first_touch_ctrdistr , out=lb_base_means_distr_bicond)
%meandistbi(data=lb_base, dist=distt_calculated , out=lb_base_means_distt_bicond)
%meandistbi(data=lb_base, dist=first_touch_ctrdists , out=lb_base_means_dists_bicond)

%meandistbi(data=lb_mid, dist=first_touch_ctrdistl , out=lb_mid_means_distl_bicond)
%meandistbi(data=lb_mid, dist=first_touch_ctrdistr , out=lb_mid_means_distr_bicond)
%meandistbi(data=lb_mid, dist=distt_calculated , out=lb_mid_means_distt_bicond)
%meandistbi(data=lb_mid, dist=first_touch_ctrdists , out=lb_mid_means_dists_bicond)

%meandistbi(data=lb_end, dist=first_touch_ctrdistl , out=lb_end_means_distl_bicond)
%meandistbi(data=lb_end, dist=first_touch_ctrdistr , out=lb_end_means_distr_bicond)
%meandistbi(data=lb_end, dist=distt_calculated , out=lb_end_means_distt_bicond)
%meandistbi(data=lb_end, dist=first_touch_ctrdists , out=lb_end_means_dists_bicond)

%meandistbi(data=ng_base, dist=first_touch_ctrdistl , out=ng_base_means_distl_bicond)
%meandistbi(data=ng_base, dist=first_touch_ctrdistr , out=ng_base_means_distr_bicond)
%meandistbi(data=ng_base, dist=distt_calculated , out=ng_base_means_distt_bicond)
%meandistbi(data=ng_base, dist=first_touch_ctrdists , out=ng_base_means_dists_bicond)

%meandistbi(data=ng_mid, dist=first_touch_ctrdistl , out=ng_mid_means_distl_bicond)
%meandistbi(data=ng_mid, dist=first_touch_ctrdistr , out=ng_mid_means_distr_bicond)
%meandistbi(data=ng_mid, dist=distt_calculated , out=ng_mid_means_distt_bicond)
%meandistbi(data=ng_mid, dist=first_touch_ctrdists , out=ng_mid_means_dists_bicond)

%meandistbi(data=ng_end, dist=first_touch_ctrdistl , out=ng_end_means_distl_bicond)
%meandistbi(data=ng_end, dist=first_touch_ctrdistr , out=ng_end_means_distr_bicond)
%meandistbi(data=ng_end, dist=distt_calculated , out=ng_end_means_distt_bicond)
%meandistbi(data=ng_end, dist=first_touch_ctrdists , out=ng_end_means_dists_bicond)
;

** Macro for RT outcomes;
%macro meanRTbi(data=, out=) ;
proc means data=&data nway noprint;
class ID;
var first_touch_resp_time;
where correct_outcome="Correct";
by condition;
output out=&out(drop=_type_ _freq_) mean=rt_bicond;
run;
%mend meanRTbi;

%meanRTbi(data=lb_base, out=lb_base_means_RT_bicond)
%meanRTbi(data=lb_mid, out=lb_mid_means_RT_bicond)
%meanRTbi(data=lb_end, out=lb_end_means_RT_bicond)

%meanRTbi(data=ng_base, out=ng_base_means_RT_bicond)
%meanRTbi(data=ng_mid, out=ng_mid_means_RT_bicond)
%meanRTbi(data=ng_end, out=ng_end_means_RT_bicond)
;

** Macro for Accuracy outcome;
%macro meanACCbi(data=, out=) ;
proc means data=&data nway noprint;
class ID;
var accuracy;
by condition;
output out=&out(drop=_type_ _freq_) mean(accuracy)=acc_bicond;
run;
%mend meanACCbi;

%meanACCbi(data=lb_base, out=lb_base_means_acc_bicond)
%meanACCbi(data=lb_mid, out=lb_mid_means_acc_bicond)
%meanACCbi(data=lb_end, out=lb_end_means_acc_bicond)

%meanACCbi(data=ng_base, out=ng_base_means_acc_bicond)
%meanACCbi(data=ng_mid, out=ng_mid_means_acc_bicond)
%meanACCbi(data=ng_end, out=ng_end_means_acc_bicond)
;

****************** BY LAG CONDITIONS *********************;
**********************************************************;

* sort by lag_cond first;
%macro sortLAG(data=);
proc sort data=&data;
by lag_cond; 
run;
%mend sortLAG;

%sortLAG(data=lb_base)
%sortLAG(data=lb_mid)
%sortLAG(data=lb_end)

%sortLAG(data=ng_base)
%sortLAG(data=ng_mid)
%sortLAG(data=ng_end)
;

** Macro for distance outcomes -- by inhbition lag_conds;
%macro meandistlag(data=, dist= ,out=) ;
proc means data=&data nway noprint;
class ID;
var &dist ;
by lag_cond ;
output out=&out(drop=_type_ _freq_) mean= /autoname;
run;
%mend meandistlag;

%meandistlag(data=lb_base, dist=first_touch_ctrdistl , out=lb_base_means_distl_lagcond)
%meandistlag(data=lb_base, dist=first_touch_ctrdistr , out=lb_base_means_distr_lagcond)
%meandistlag(data=lb_base, dist=distt_calculated , out=lb_base_means_distt_lagcond)
%meandistlag(data=lb_base, dist=first_touch_ctrdists , out=lb_base_means_dists_lagcond)

%meandistlag(data=lb_mid, dist=first_touch_ctrdistl , out=lb_mid_means_distl_lagcond)
%meandistlag(data=lb_mid, dist=first_touch_ctrdistr , out=lb_mid_means_distr_lagcond)
%meandistlag(data=lb_mid, dist=distt_calculated , out=lb_mid_means_distt_lagcond)
%meandistlag(data=lb_mid, dist=first_touch_ctrdists , out=lb_mid_means_dists_lagcond)

%meandistlag(data=lb_end, dist=first_touch_ctrdistl , out=lb_end_means_distl_lagcond)
%meandistlag(data=lb_end, dist=first_touch_ctrdistr , out=lb_end_means_distr_lagcond)
%meandistlag(data=lb_end, dist=distt_calculated , out=lb_end_means_distt_lagcond)
%meandistlag(data=lb_end, dist=first_touch_ctrdists , out=lb_end_means_dists_lagcond)

%meandistlag(data=ng_base, dist=first_touch_ctrdistl , out=ng_base_means_distl_lagcond)
%meandistlag(data=ng_base, dist=first_touch_ctrdistr , out=ng_base_means_distr_lagcond)
%meandistlag(data=ng_base, dist=distt_calculated , out=ng_base_means_distt_lagcond)
%meandistlag(data=ng_base, dist=first_touch_ctrdists , out=ng_base_means_dists_lagcond)

%meandistlag(data=ng_mid, dist=first_touch_ctrdistl , out=ng_mid_means_distl_lagcond)
%meandistlag(data=ng_mid, dist=first_touch_ctrdistr , out=ng_mid_means_distr_lagcond)
%meandistlag(data=ng_mid, dist=distt_calculated , out=ng_mid_means_distt_lagcond)
%meandistlag(data=ng_mid, dist=first_touch_ctrdists , out=ng_mid_means_dists_lagcond)

%meandistlag(data=ng_end, dist=first_touch_ctrdistl , out=ng_end_means_distl_lagcond)
%meandistlag(data=ng_end, dist=first_touch_ctrdistr , out=ng_end_means_distr_lagcond)
%meandistlag(data=ng_end, dist=distt_calculated , out=ng_end_means_distt_lagcond)
%meandistlag(data=ng_end, dist=first_touch_ctrdists , out=ng_end_means_dists_lagcond)
;

** Macro for RT outcomes;
%macro meanRTlag(data=, out=) ;
proc means data=&data nway noprint;
class ID;
var first_touch_resp_time;
where correct_outcome="Correct";
by lag_cond;
output out=&out(drop=_type_ _freq_) mean=rt_lagcond;
run;
%mend meanRTlag;

%meanRTlag(data=lb_base, out=lb_base_means_RT_lagcond)
%meanRTlag(data=lb_mid, out=lb_mid_means_RT_lagcond)
%meanRTlag(data=lb_end, out=lb_end_means_RT_lagcond)

%meanRTlag(data=ng_base, out=ng_base_means_RT_lagcond)
%meanRTlag(data=ng_mid, out=ng_mid_means_RT_lagcond)
%meanRTlag(data=ng_end, out=ng_end_means_RT_lagcond)
;

** Macro for Accuracy outcome;
%macro meanACClag(data=, out=) ;
proc means data=&data nway noprint;
class ID;
var accuracy;
by lag_cond;
output out=&out(drop=_type_ _freq_) mean(accuracy)=acc_lacgond;
run;
%mend meanACClag;

%meanACClag(data=lb_base, out=lb_base_means_acc_lagcond)
%meanACClag(data=lb_mid, out=lb_mid_means_acc_lagcond)
%meanACClag(data=lb_end, out=lb_end_means_acc_lagcond)

%meanACClag(data=ng_base, out=ng_base_means_acc_lagcond)
%meanACClag(data=ng_mid, out=ng_mid_means_acc_lagcond)
%meanACClag(data=ng_end, out=ng_end_means_acc_lagcond)
;

************************ sort, transpose and merge all *********************;

** sort to transpose;
%macro sort (data);
proc sort data=&data; by ID; run;
%mend sort;

%sort(lb_base_means_distl_bicond)
%sort(lb_base_means_distr_bicond)
%sort(lb_base_means_distt_bicond)
%sort(lb_base_means_dists_bicond)
%sort(lb_base_means_RT_bicond)
%sort(lb_base_means_ACC_bicond)
%sort(lb_base_means_distl_lagcond)
%sort(lb_base_means_distr_lagcond)
%sort(lb_base_means_distt_lagcond)
%sort(lb_base_means_dists_lagcond)
%sort(lb_base_means_RT_lagcond)
%sort(lb_base_means_ACC_lagcond)

%sort(lb_mid_means_distl_bicond)
%sort(lb_mid_means_distr_bicond)
%sort(lb_mid_means_distt_bicond)
%sort(lb_mid_means_dists_bicond)
%sort(lb_mid_means_RT_bicond)
%sort(lb_mid_means_ACC_bicond)
%sort(lb_mid_means_distl_lagcond)
%sort(lb_mid_means_distr_lagcond)
%sort(lb_mid_means_distt_lagcond)
%sort(lb_mid_means_dists_lagcond)
%sort(lb_mid_means_RT_lagcond)
%sort(lb_mid_means_ACC_lagcond)

%sort(lb_end_means_distl_bicond)
%sort(lb_end_means_distr_bicond)
%sort(lb_end_means_distt_bicond)
%sort(lb_end_means_dists_bicond)
%sort(lb_end_means_RT_bicond)
%sort(lb_end_means_ACC_bicond)
%sort(lb_end_means_distl_lagcond)
%sort(lb_end_means_distr_lagcond)
%sort(lb_end_means_distt_lagcond)
%sort(lb_end_means_dists_lagcond)
%sort(lb_end_means_RT_lagcond)
%sort(lb_end_means_ACC_lagcond)

%sort(ng_base_means_distl_bicond)
%sort(ng_base_means_distr_bicond)
%sort(ng_base_means_distt_bicond)
%sort(ng_base_means_dists_bicond)
%sort(ng_base_means_RT_bicond)
%sort(ng_base_means_ACC_bicond)
%sort(ng_base_means_distl_lagcond)
%sort(ng_base_means_distr_lagcond)
%sort(ng_base_means_distt_lagcond)
%sort(ng_base_means_dists_lagcond)
%sort(ng_base_means_RT_lagcond)
%sort(ng_base_means_ACC_lagcond)

%sort(ng_mid_means_distl_bicond)
%sort(ng_mid_means_distr_bicond)
%sort(ng_mid_means_distt_bicond)
%sort(ng_mid_means_dists_bicond)
%sort(ng_mid_means_RT_bicond)
%sort(ng_mid_means_ACC_bicond)
%sort(ng_mid_means_distl_lagcond)
%sort(ng_mid_means_distr_lagcond)
%sort(ng_mid_means_distt_lagcond)
%sort(ng_mid_means_dists_lagcond)
%sort(ng_mid_means_RT_lagcond)
%sort(ng_mid_means_ACC_lagcond)

%sort(ng_end_means_distl_bicond)
%sort(ng_end_means_distr_bicond)
%sort(ng_end_means_distt_bicond)
%sort(ng_end_means_dists_bicond)
%sort(ng_end_means_RT_bicond)
%sort(ng_end_means_ACC_bicond)
%sort(ng_end_means_distl_lagcond)
%sort(ng_end_means_distr_lagcond)
%sort(ng_end_means_distt_lagcond)
%sort(ng_end_means_dists_lagcond)
%sort(ng_end_means_RT_lagcond)
%sort(ng_end_means_ACC_lagcond)
;

** long to wide;
%macro transp_bi (data=, out=, prefix=, id=);
proc transpose data=&data out=&out prefix=&prefix;
	by ID;
	id &id;	
run;
%mend transp_bi;

%transp_bi(data=lb_base_means_distl_bicond, out=lb_base_bicond_dist1, prefix=distl_bicond_, id=condition)
%transp_bi(data=lb_base_means_distr_bicond, out=lb_base_bicond_dist2, prefix=distr_bicond_, id=condition)
%transp_bi(data=lb_base_means_distt_bicond, out=lb_base_bicond_dist3, prefix=distt_bicond_, id=condition)
%transp_bi(data=lb_base_means_dists_bicond, out=lb_base_bicond_dist4, prefix=dists_bicond_, id=condition)
%transp_bi(data=lb_base_means_RT_bicond , out=lb_base_bicond_rt, prefix=rt_bicond_, id=condition)
%transp_bi(data=lb_base_means_ACC_bicond , out=lb_base_bicond_acc, prefix=acc_bicond_, id=condition)
%transp_bi(data=lb_base_means_distl_lagcond , out=lb_base_lagcond_dist1, prefix=distl_lagcond_, id=lag_cond)
%transp_bi(data=lb_base_means_distr_lagcond , out=lb_base_lagcond_dist2, prefix=distr_lagcond_, id=lag_cond)
%transp_bi(data=lb_base_means_distt_lagcond , out=lb_base_lagcond_dist3, prefix=distt_lagcond_, id=lag_cond)
%transp_bi(data=lb_base_means_dists_lagcond , out=lb_base_lagcond_dist4, prefix=dists_lagcond_, id=lag_cond)
%transp_bi(data=lb_base_means_RT_lagcond , out=lb_base_lagcond_rt, prefix=rt_lagcond_, id=lag_cond)
%transp_bi(data=lb_base_means_ACC_lagcond , out=lb_base_lagcond_acc, prefix=acc_lagcond_, id=lag_cond)

%transp_bi(data=lb_mid_means_distl_bicond, out=lb_mid_bicond_dist1, prefix=distl_bicond_, id=condition)
%transp_bi(data=lb_mid_means_distr_bicond, out=lb_mid_bicond_dist2, prefix=distr_bicond_, id=condition)
%transp_bi(data=lb_mid_means_distt_bicond, out=lb_mid_bicond_dist3, prefix=distt_bicond_, id=condition)
%transp_bi(data=lb_mid_means_dists_bicond, out=lb_mid_bicond_dist4, prefix=dists_bicond_, id=condition)
%transp_bi(data=lb_mid_means_RT_bicond , out=lb_mid_bicond_rt, prefix=rt_bicond_, id=condition)
%transp_bi(data=lb_mid_means_ACC_bicond , out=lb_mid_bicond_acc, prefix=acc_bicond_, id=condition)
%transp_bi(data=lb_mid_means_distl_lagcond , out=lb_mid_lagcond_dist1, prefix=distl_lagcond_, id=lag_cond)
%transp_bi(data=lb_mid_means_distr_lagcond , out=lb_mid_lagcond_dist2, prefix=distr_lagcond_, id=lag_cond)
%transp_bi(data=lb_mid_means_distt_lagcond , out=lb_mid_lagcond_dist3, prefix=distt_lagcond_, id=lag_cond)
%transp_bi(data=lb_mid_means_dists_lagcond , out=lb_mid_lagcond_dist4, prefix=dists_lagcond_, id=lag_cond)
%transp_bi(data=lb_mid_means_RT_lagcond , out=lb_mid_lagcond_rt, prefix=rt_lagcond_, id=lag_cond)
%transp_bi(data=lb_mid_means_ACC_lagcond , out=lb_mid_lagcond_acc, prefix=acc_lagcond_, id=lag_cond)

%transp_bi(data=lb_end_means_distl_bicond, out=lb_end_bicond_dist1, prefix=distl_bicond_, id=condition)
%transp_bi(data=lb_end_means_distr_bicond, out=lb_end_bicond_dist2, prefix=distr_bicond_, id=condition)
%transp_bi(data=lb_end_means_distt_bicond, out=lb_end_bicond_dist3, prefix=distt_bicond_, id=condition)
%transp_bi(data=lb_end_means_dists_bicond, out=lb_end_bicond_dist4, prefix=dists_bicond_, id=condition)
%transp_bi(data=lb_end_means_RT_bicond , out=lb_end_bicond_rt, prefix=rt_bicond_, id=condition)
%transp_bi(data=lb_end_means_ACC_bicond , out=lb_end_bicond_acc, prefix=acc_bicond_, id=condition)
%transp_bi(data=lb_end_means_distl_lagcond , out=lb_end_lagcond_dist1, prefix=distl_lagcond_, id=lag_cond)
%transp_bi(data=lb_end_means_distr_lagcond , out=lb_end_lagcond_dist2, prefix=distr_lagcond_, id=lag_cond)
%transp_bi(data=lb_end_means_distt_lagcond , out=lb_end_lagcond_dist3, prefix=distt_lagcond_, id=lag_cond)
%transp_bi(data=lb_end_means_dists_lagcond , out=lb_end_lagcond_dist4, prefix=dists_lagcond_, id=lag_cond)
%transp_bi(data=lb_end_means_RT_lagcond , out=lb_end_lagcond_rt, prefix=rt_lagcond_, id=lag_cond)
%transp_bi(data=lb_end_means_ACC_lagcond , out=lb_end_lagcond_acc, prefix=acc_lagcond_, id=lag_cond)

%transp_bi(data=ng_base_means_distl_bicond, out=ng_base_bicond_dist1, prefix=distl_bicond_, id=condition)
%transp_bi(data=ng_base_means_distr_bicond, out=ng_base_bicond_dist2, prefix=distr_bicond_, id=condition)
%transp_bi(data=ng_base_means_distt_bicond, out=ng_base_bicond_dist3, prefix=distt_bicond_, id=condition)
%transp_bi(data=ng_base_means_dists_bicond, out=ng_base_bicond_dist4, prefix=dists_bicond_, id=condition)
%transp_bi(data=ng_base_means_RT_bicond , out=ng_base_bicond_rt, prefix=rt_bicond_, id=condition)
%transp_bi(data=ng_base_means_ACC_bicond , out=ng_base_bicond_acc, prefix=acc_bicond_, id=condition)
%transp_bi(data=ng_base_means_distl_lagcond , out=ng_base_lagcond_dist1, prefix=distl_lagcond_, id=lag_cond)
%transp_bi(data=ng_base_means_distr_lagcond , out=ng_base_lagcond_dist2, prefix=distr_lagcond_, id=lag_cond)
%transp_bi(data=ng_base_means_distt_lagcond , out=ng_base_lagcond_dist3, prefix=distt_lagcond_, id=lag_cond)
%transp_bi(data=ng_base_means_dists_lagcond , out=ng_base_lagcond_dist4, prefix=dists_lagcond_, id=lag_cond)
%transp_bi(data=ng_base_means_RT_lagcond , out=ng_base_lagcond_rt, prefix=rt_lagcond_, id=lag_cond)
%transp_bi(data=ng_base_means_ACC_lagcond , out=ng_base_lagcond_acc, prefix=acc_lagcond_, id=lag_cond)

%transp_bi(data=ng_mid_means_distl_bicond, out=ng_mid_bicond_dist1, prefix=distl_bicond_, id=condition)
%transp_bi(data=ng_mid_means_distr_bicond, out=ng_mid_bicond_dist2, prefix=distr_bicond_, id=condition)
%transp_bi(data=ng_mid_means_distt_bicond, out=ng_mid_bicond_dist3, prefix=distt_bicond_, id=condition)
%transp_bi(data=ng_mid_means_dists_bicond, out=ng_mid_bicond_dist4, prefix=dists_bicond_, id=condition)
%transp_bi(data=ng_mid_means_RT_bicond , out=ng_mid_bicond_rt, prefix=rt_bicond_, id=condition)
%transp_bi(data=ng_mid_means_ACC_bicond , out=ng_mid_bicond_acc, prefix=acc_bicond_, id=condition)
%transp_bi(data=ng_mid_means_distl_lagcond , out=ng_mid_lagcond_dist1, prefix=distl_lagcond_, id=lag_cond)
%transp_bi(data=ng_mid_means_distr_lagcond , out=ng_mid_lagcond_dist2, prefix=distr_lagcond_, id=lag_cond)
%transp_bi(data=ng_mid_means_distt_lagcond , out=ng_mid_lagcond_dist3, prefix=distt_lagcond_, id=lag_cond)
%transp_bi(data=ng_mid_means_dists_lagcond , out=ng_mid_lagcond_dist4, prefix=dists_lagcond_, id=lag_cond)
%transp_bi(data=ng_mid_means_RT_lagcond , out=ng_mid_lagcond_rt, prefix=rt_lagcond_, id=lag_cond)
%transp_bi(data=ng_mid_means_ACC_lagcond , out=ng_mid_lagcond_acc, prefix=acc_lagcond_, id=lag_cond)

%transp_bi(data=ng_end_means_distl_bicond, out=ng_end_bicond_dist1, prefix=distl_bicond_, id=condition)
%transp_bi(data=ng_end_means_distr_bicond, out=ng_end_bicond_dist2, prefix=distr_bicond_, id=condition)
%transp_bi(data=ng_end_means_distt_bicond, out=ng_end_bicond_dist3, prefix=distt_bicond_, id=condition)
%transp_bi(data=ng_end_means_dists_bicond, out=ng_end_bicond_dist4, prefix=dists_bicond_, id=condition)
%transp_bi(data=ng_end_means_RT_bicond , out=ng_end_bicond_rt, prefix=rt_bicond_, id=condition)
%transp_bi(data=ng_end_means_ACC_bicond , out=ng_end_bicond_acc, prefix=acc_bicond_, id=condition)
%transp_bi(data=ng_end_means_distl_lagcond , out=ng_end_lagcond_dist1, prefix=distl_lagcond_, id=lag_cond)
%transp_bi(data=ng_end_means_distr_lagcond , out=ng_end_lagcond_dist2, prefix=distr_lagcond_, id=lag_cond)
%transp_bi(data=ng_end_means_distt_lagcond , out=ng_end_lagcond_dist3, prefix=distt_lagcond_, id=lag_cond)
%transp_bi(data=ng_end_means_dists_lagcond , out=ng_end_lagcond_dist4, prefix=dists_lagcond_, id=lag_cond)
%transp_bi(data=ng_end_means_RT_lagcond , out=ng_end_lagcond_rt, prefix=rt_lagcond_, id=lag_cond)
%transp_bi(data=ng_end_means_ACC_lagcond , out=ng_end_lagcond_acc, prefix=acc_lagcond_, id=lag_cond)
;

** sort again by ID **;

%macro sort2 (data);
proc sort data=&data; by ID; run;
%mend sort2;

*lb base;
%sort2(lb_base_bicond_dist1)
%sort2(lb_base_bicond_dist2)
%sort2(lb_base_bicond_dist3)
%sort2(lb_base_bicond_dist4)
%sort2(lb_base_bicond_rt)
%sort2(lb_base_bicond_acc)
%sort2(lb_base_lagcond_dist1)
%sort2(lb_base_lagcond_dist2)
%sort2(lb_base_lagcond_dist3)
%sort2(lb_base_lagcond_dist4)
%sort2(lb_base_lagcond_rt)
%sort2(lb_base_lagcond_acc)

*lb mid;
%sort2(lb_mid_bicond_dist1)
%sort2(lb_mid_bicond_dist2)
%sort2(lb_mid_bicond_dist3)
%sort2(lb_mid_bicond_dist4)
%sort2(lb_mid_bicond_rt)
%sort2(lb_mid_bicond_acc)
%sort2(lb_mid_lagcond_dist1)
%sort2(lb_mid_lagcond_dist2)
%sort2(lb_mid_lagcond_dist3)
%sort2(lb_mid_lagcond_dist4)
%sort2(lb_mid_lagcond_rt)
%sort2(lb_mid_lagcond_acc)

*lb end;
%sort2(lb_end_bicond_dist1)
%sort2(lb_end_bicond_dist2)
%sort2(lb_end_bicond_dist3)
%sort2(lb_end_bicond_dist4)
%sort2(lb_end_bicond_rt)
%sort2(lb_end_bicond_acc)
%sort2(lb_end_lagcond_dist1)
%sort2(lb_end_lagcond_dist2)
%sort2(lb_end_lagcond_dist3)
%sort2(lb_end_lagcond_dist4)
%sort2(lb_end_lagcond_rt)
%sort2(lb_end_lagcond_acc)

*ng base;
%sort2(ng_base_bicond_dist1)
%sort2(ng_base_bicond_dist2)
%sort2(ng_base_bicond_dist3)
%sort2(ng_base_bicond_dist4)
%sort2(ng_base_bicond_rt)
%sort2(ng_base_bicond_acc)
%sort2(ng_base_lagcond_dist1)
%sort2(ng_base_lagcond_dist2)
%sort2(ng_base_lagcond_dist3)
%sort2(ng_base_lagcond_dist4)
%sort2(ng_base_lagcond_rt)
%sort2(ng_base_lagcond_acc)

*ng mid;
%sort2(ng_mid_bicond_dist1)
%sort2(ng_mid_bicond_dist2)
%sort2(ng_mid_bicond_dist3)
%sort2(ng_mid_bicond_dist4)
%sort2(ng_mid_bicond_rt)
%sort2(ng_mid_bicond_acc)
%sort2(ng_mid_lagcond_dist1)
%sort2(ng_mid_lagcond_dist2)
%sort2(ng_mid_lagcond_dist3)
%sort2(ng_mid_lagcond_dist4)
%sort2(ng_mid_lagcond_rt)
%sort2(ng_mid_lagcond_acc)

*ng end;
%sort2(ng_end_bicond_dist1)
%sort2(ng_end_bicond_dist2)
%sort2(ng_end_bicond_dist3)
%sort2(ng_end_bicond_dist4)
%sort2(ng_end_bicond_rt)
%sort2(ng_end_bicond_acc)
%sort2(ng_end_lagcond_dist1)
%sort2(ng_end_lagcond_dist2)
%sort2(ng_end_lagcond_dist3)
%sort2(ng_end_lagcond_dist4)
%sort2(ng_end_lagcond_rt)
%sort2(ng_end_lagcond_acc)
;

******** MERGE ****************;

%macro merge (outfile=, f1=, f2=, f3=, f4=, f5=, f6=,f7=, f8=, f9=, f10=, f11=, f12= );
data &outfile;
merge &f1  &f2  &f3  &f4  &f5  &f6 &f7  &f8  &f9  &f10  &f11  &f12 ;
by ID;
drop _NAME_ _LABEL_ acc_lagcond__ RT_lagcond__ distl_lagcond__ distr_lagcond__ distt_lagcond__ dists_lagcond__;
run;
%mend merge;

%merge(outfile=rcr.lb_bi_base_means,f1=lb_base_bicond_dist1, f2=lb_base_bicond_dist2, f3=lb_base_bicond_dist3,
f4=lb_base_bicond_dist4, f5=lb_base_bicond_rt, f6=lb_base_bicond_acc, f7=lb_base_lagcond_dist1, f8=lb_base_lagcond_dist2,
f9=lb_base_lagcond_dist3, f10=lb_base_lagcond_dist4, f11=lb_base_lagcond_rt, f12=lb_base_lagcond_acc)

%merge(outfile=rcr.lb_bi_mid_means,f1=lb_mid_bicond_dist1, f2=lb_mid_bicond_dist2, f3=lb_mid_bicond_dist3,
f4=lb_mid_bicond_dist4, f5=lb_mid_bicond_rt, f6=lb_mid_bicond_acc, f7=lb_mid_lagcond_dist1, f8=lb_mid_lagcond_dist2,
f9=lb_mid_lagcond_dist3, f10=lb_mid_lagcond_dist4, f11=lb_mid_lagcond_rt, f12=lb_mid_lagcond_acc)

%merge(outfile=rcr.lb_bi_end_means,f1=lb_end_bicond_dist1, f2=lb_end_bicond_dist2, f3=lb_end_bicond_dist3,
f4=lb_end_bicond_dist4, f5=lb_end_bicond_rt, f6=lb_end_bicond_acc, f7=lb_end_lagcond_dist1, f8=lb_end_lagcond_dist2,
f9=lb_end_lagcond_dist3, f10=lb_end_lagcond_dist4, f11=lb_end_lagcond_rt, f12=lb_end_lagcond_acc)

%merge(outfile=rcr.ng_bi_base_means,f1=ng_base_bicond_dist1, f2=ng_base_bicond_dist2, f3=ng_base_bicond_dist3,
f4=ng_base_bicond_dist4, f5=ng_base_bicond_rt, f6=ng_base_bicond_acc, f7=ng_base_lagcond_dist1, f8=ng_base_lagcond_dist2,
f9=ng_base_lagcond_dist3, f10=ng_base_lagcond_dist4, f11=ng_base_lagcond_rt, f12=ng_base_lagcond_acc)

%merge(outfile=rcr.ng_bi_mid_means,f1=ng_mid_bicond_dist1, f2=ng_mid_bicond_dist2, f3=ng_mid_bicond_dist3,
f4=ng_mid_bicond_dist4, f5=ng_mid_bicond_rt, f6=ng_mid_bicond_acc, f7=ng_mid_lagcond_dist1, f8=ng_mid_lagcond_dist2,
f9=ng_mid_lagcond_dist3, f10=ng_mid_lagcond_dist4, f11=ng_mid_lagcond_rt, f12=ng_mid_lagcond_acc)

%merge(outfile=rcr.ng_bi_end_means,f1=ng_end_bicond_dist1, f2=ng_end_bicond_dist2, f3=ng_end_bicond_dist3,
f4=ng_end_bicond_dist4, f5=ng_end_bicond_rt, f6=ng_end_bicond_acc, f7=ng_end_lagcond_dist1, f8=ng_end_lagcond_dist2,
f9=ng_end_lagcond_dist3, f10=ng_end_lagcond_dist4, f11=ng_end_lagcond_rt, f12=ng_end_lagcond_acc)
;

**** check / view new files ***;
%macro printfinal(data=);
proc print data=&data(obs=20);
run;
%mend printfinal;

%printfinal(data=rcr.lb_bi_base_means)
%printfinal(data=rcr.lb_bi_mid_means)
%printfinal(data=rcr.lb_bi_end_means)

%printfinal(data=rcr.ng_bi_base_means)
%printfinal(data=rcr.ng_bi_mid_means)
%printfinal(data=rcr.ng_bi_end_means)
;


****************************************************************************;
******************* FLAG LOW ACCURACY PARITICPANTS *************************;
**************** OK if sameside >= 0.5 and oppside >=0.25 ******************;

* STEP 1: flag based on criteria;
* < 25% accuracy opposite side;
* < 50% accuracy same side;

%macro flag (data=, set=);
data &data;
set &set;
if acc_bicond_opp_side < .25 or acc_bicond_sameside < 0.5 then low_accuracy_flag=1;
else low_accuracy_flag=0;
run;
%mend flag;

%flag(data=rcr.lb_bi_base_means, set=rcr.lb_bi_base_means)
%flag(data=rcr.lb_bi_mid_means, set=rcr.lb_bi_mid_means)
%flag(data=rcr.lb_bi_end_means, set=rcr.lb_bi_end_means)

%flag(data=rcr.ng_bi_base_means, set=rcr.ng_bi_base_means)
%flag(data=rcr.ng_bi_mid_means, set=rcr.ng_bi_mid_means)
%flag(data=rcr.ng_bi_end_means, set=rcr.ng_bi_end_means)
;

* STEP 2: count how many removed by this cut-off;
%macro countflag(data=);
proc freq data=&data;
tables low_accuracy_flag/list ;
run;
%mend countflag;

%countflag(data=rcr.lb_bi_base_means)
%countflag(data=rcr.lb_bi_mid_means)
%countflag(data=rcr.lb_bi_end_means)

%countflag(data=rcr.ng_bi_base_means)
%countflag(data=rcr.ng_bi_mid_means)
%countflag(data=rcr.ng_bi_end_means)
;

*********************************************************************************
*							EXPORT MEANS TO EXCEL 								*
*********************************************************************************;

%macro export(data=, outfile=);
proc export data = &data
outfile = &outfile
dbms=xlsx replace;
run;
%mend export;

%export(data=rcr.lb_bi_base_means, outfile="C:\Users\cbford\Documents\RACER\Datafiles_means_raw_for_dropboxupload\lb_bi_base_means.xlsx")
%export(data=rcr.lb_bi_mid_means, outfile="C:\Users\cbford\Documents\RACER\Datafiles_means_raw_for_dropboxupload\lb_bi_mid_means.xlsx")
%export(data=rcr.lb_bi_end_means, outfile="C:\Users\cbford\Documents\RACER\Datafiles_means_raw_for_dropboxupload\lb_bi_end_means.xlsx")

%export(data=rcr.ng_bi_base_means, outfile="C:\Users\cbford\Documents\RACER\Datafiles_means_raw_for_dropboxupload\ng_bi_base_means.xlsx")
%export(data=rcr.ng_bi_mid_means, outfile="C:\Users\cbford\Documents\RACER\Datafiles_means_raw_for_dropboxupload\ng_bi_mid_means.xlsx")
%export(data=rcr.ng_bi_end_means, outfile="C:\Users\cbford\Documents\RACER\Datafiles_means_raw_for_dropboxupload\ng_bi_end_means.xlsx")
;


*************************************************************************************************************;
*									COUNT IDS IN FINAL DATASETS			 									*;
*************************************************************************************************************;

%macro idcountBI_AVES (data=);
proc iml;
 use &data;
 read all var{id} into x;
 close;

 title "ID count in &data";
 print nobs;
 print (nrow(x));
quit;
%mend idcountBI_AVES;

%idcountBI_AVES(data=rcr.lb_bi_base_means)
%idcountBI_AVES(data=rcr.lb_bi_mid_means)
%idcountBI_AVES(data=rcr.lb_bi_end_means)

%idcountBI_AVES(data=rcr.ng_bi_base_means)
%idcountBI_AVES(data=rcr.ng_bi_mid_means)
%idcountBI_AVES(data=rcr.ng_bi_end_means)
;


