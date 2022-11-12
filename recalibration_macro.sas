%macro recalibration(ds,tevent,event,xbeta,outds,rcvble);
ods listing close;
options nonotes;
data _temp_;
   set &ds;
run;

proc lifetest data=_temp_ timelist=(10);
   time &tevent*&event(0);
   ods output ProductLimitEstimates=PLE;
run;

data _null_;
   set PLE;
   call symput("rate",Failure);
run;

proc means data=_temp_ noprint;
   var &xbeta;
   output out=xbeta_mean mean(&xbeta)=xbeta_mean n(&xbeta)=nobs;
run;

data _null_;
   set xbeta_mean;
   call symput("nobs",nobs);
run;

data _temp_;
   set _temp_;
   if _N_=1 then set xbeta_mean;
   xbc = &xbeta - xbeta_mean;
   keep usubjid &xbeta xbeta_mean xbc;
run;

proc optmodel;
   set obs;
   num xbc{obs};
   var s10;
   read data _temp_ into obs=[_n_] xbc;
   impvar form{i in obs} = (1 - s10^exp(xbc[i]));
   min f = abs(((1/&nobs)*(sum{i in obs} form[i])) - &rate);
   con c: 0 <= s10 <= 1;
   solve with nlp;
   print s10;
   create data solu from s10;
quit;

data &outds;
   set _temp_;
   if _N_=1 then set solu;
   &rcvble = 1 - s10**exp(xbc);
run;
ods listing;
options notes;
%mend recalibration;
