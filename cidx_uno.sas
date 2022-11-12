* Macro for c-index;
%macro cidx(inds,cond,model,outds);
data _temp_;
   set &inds;

   if &cond;
run;

ods listing close;
proc phreg data=_temp_ concordance=uno(se);
   model t2stroke10_yrs*stroke10(0) = &model;
   ods output Concordance=cidx;
run;

data &outds;
   attrib result length=$30.;
   set cidx;

   c_ll = estimate + quantile('NORMAL', .025)*StdErr;
   c_ul = estimate + quantile('NORMAL', .975)*StdErr;

   result = put(estimate,5.3) || " (" || put(c_ll,5.3) || " - " || put(c_ul,5.3) || ")";
   keep result estimate c_ll c_ul;
run;

proc datasets library=work;
   delete _temp_ cidx;
quit;
ods listing;
%mend cidx;
