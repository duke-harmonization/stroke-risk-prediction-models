%macro obsexp(inds,cond,preds,outds);
data _ads;
   set &inds;
   if &cond;
run;

ods listing close;
ods select ProductLimitEstimates;
proc lifetest data=_ads timelist=(10);
   time t2stroke10_yrs*stroke10(0);
   ods output ProductLimitEstimates=PLE(keep=Failure);
run;

proc means data=_ads mean maxdec=4 nway;
   var &preds;
   output out=pred mean(&preds)=pred_risk;
run;
ods listing;

options mergenoby=nowarn;
data &outds;
   attrib obs_risk exp_risk length=$10.;
   merge PLE
         pred;
   obs_risk=compress(put(100*Failure,5.2));
   exp_risk=compress(put(100*pred_risk,5.2));
   keep obs_risk exp_risk;
run;
%mend obsexp;
