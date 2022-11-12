%macro brier13(inds,cond,preds,outds);
data _ads;
	set &inds;
	if &cond;

	rename &preds=prob_10yrs;
	keep t2stroke stroke10 &preds;
run;

proc iml;
   call ExportDataSetToR("work._ads", "ads");
   %include "/dcri/sigmadata/stroke_prediction/manu/validating/programs/etc/brier.sas";
   call ImportDataSetFromR("&outds", "to_export");
quit;

data &outds;
   attrib result length=$30.;
	set &outds;
	if Model="Result";

   result = compress(put(100*Brier,5.2)) || " (" || compress(put(100*lower,5.2)) || " - " || compress(put(100*upper,5.2)) || ")";
	keep result;
run;
%mend brier13;
