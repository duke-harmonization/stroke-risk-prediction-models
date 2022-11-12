* #################################################################################
* TASK:     Compare Predictions in REGARDS
* INPUT:    preds_regards_v3
* OUTPUT:
* DATE:     05-JAN-2022
* UPDATES:
* #########################################################################;
options nodate nonumber ls=150 mprint=no mautosource sasautos=("!SASROOT/sasautos","/dcri/shared_code/sas/macro");


libname in "../manu/validating/data" access=readonly;
libname out "../manu/validating/data/net_benefit_plot";
libname template "../manu/validating/programs/templates";

%include "../manu/ads/programs/etc/formats.sas";

data models;
   set in.preds_regards_v3;
run;

%macro cutpoint(cut);
   data _temp_;
      set models(where=(race_c="White" & agegrp=2));

      if fsrp10_c_r < &cut then pred_fsrp_o=0;
      else if fsrp10_c_r >= &cut then pred_fsrp_o=1;

      if ascvd10_c_r < &cut then pred_ascvd_o=0;
      else if ascvd10_c_r >= &cut then pred_ascvd_o=1;

      if regs10_c_r < &cut then pred_regs_o=0;
      else if regs10_c_r >= &cut then pred_regs_o=1;

      if coxnet10 < &cut then pred_ml_o=0;
      else if coxnet10 >= &cut then pred_ml_o=1;

      if rsf10 < &cut then pred_rsf_o=0;
      else if rsf10 >= &cut then pred_rsf_o=1;
   run;

   ods listing close;
   proc freq data=_temp_;
      tables stroke10*pred_fsrp_o;
      ods output CrossTabFreqs=fsrp_tp(where=(_type_="11" & pred_fsrp_o=1 & stroke10=1));
      ods output CrossTabFreqs=fsrp_fp(where=(_type_="11" & pred_fsrp_o=1 & stroke10=0));
   run;

   proc freq data=_temp_;
      tables stroke10*pred_ascvd_o;
      ods output CrossTabFreqs=ascvd_tp(where=(_type_="11" & pred_ascvd_o=1 & stroke10=1));
      ods output CrossTabFreqs=ascvd_fp(where=(_type_="11" & pred_ascvd_o=1 & stroke10=0));
   run;

   proc freq data=_temp_;
      tables stroke10*pred_regs_o;
      ods output CrossTabFreqs=regs_tp(where=(_type_="11" & pred_regs_o=1 & stroke10=1));
      ods output CrossTabFreqs=regs_fp(where=(_type_="11" & pred_regs_o=1 & stroke10=0));
   run;

   proc freq data=_temp_;
      tables stroke10*pred_ml_o;
      ods output CrossTabFreqs=ml_tp(where=(_type_="11" & pred_ml_o=1 & stroke10=1));
      ods output CrossTabFreqs=ml_fp(where=(_type_="11" & pred_ml_o=1 & stroke10=0));
   run;

   proc freq data=_temp_;
      tables stroke10*pred_rsf_o;
      ods output CrossTabFreqs=rsf_tp(where=(_type_="11" & pred_rsf_o=1 & stroke10=1));
      ods output CrossTabFreqs=rsf_fp(where=(_type_="11" & pred_rsf_o=1 & stroke10=0));
   run;
   ods listing;

   data comp;
      merge fsrp_tp(keep=percent rename=(percent=tp_fsrp))
            fsrp_fp(keep=percent rename=(percent=fp_fsrp))
            ascvd_tp(keep=percent rename=(percent=tp_ascvd))
            ascvd_fp(keep=percent rename=(percent=fp_ascvd))
            regs_tp(keep=percent rename=(percent=tp_regs))
            regs_fp(keep=percent rename=(percent=fp_regs))
            ml_tp(keep=percent rename=(percent=tp_ml))
            ml_fp(keep=percent rename=(percent=fp_ml))
            rsf_tp(keep=percent rename=(percent=tp_rsf))
            rsf_fp(keep=percent rename=(percent=fp_rsf));

      nb_fsrp = tp_fsrp/100 - (fp_fsrp/100*&cut/(1-&cut));
      nb_ascvd = tp_ascvd/100 - (fp_ascvd/100*&cut/(1-&cut));
      nb_regs = tp_regs/100 - (fp_regs/100*&cut/(1-&cut));
      nb_ml = tp_ml/100 - (fp_ml/100*&cut/(1-&cut));
      nb_rsf = tp_rsf/100 - (fp_rsf/100*&cut/(1-&cut));

      p = &cut;
   run;

   proc datasets library=work;
      append base=results data=comp;
   run;
   quit;
%mend cutpoint;

%macro loop;
   data _null_;
      do cut = 0.0010 to 0.1000 by 0.0001;
         call execute('%cutpoint('||cut||')');
         end;
   run;

   data out.nb_wo;
      attrib model length=$25;
      set results(keep=p nb_fsrp rename=(nb_fsrp=nb) in=a)
          results(keep=p nb_ascvd rename=(nb_ascvd=nb) in=b)
          results(keep=p nb_regs rename=(nb_regs=nb) in=c)
          results(keep=p nb_ml rename=(nb_ml=nb) in=d)
          results(keep=p nb_rsf rename=(nb_rsf=nb) in=e);

      if a=1 then model="FSRP";
      else if b=1 then model="ASCVD";
      else if c=1 then model="REGARDS";
      else if d=1 then model="CoxNET";
      else if e=1 then model="RSF";
   run;

%mend loop;

%loop;

* By Race/Sex;
data to_plot;
   attrib rate_c length=$15.;
   set out.nb_bw(in=a)
       out.nb_bm(in=b)
       out.nb_ww(in=c)
       out.nb_wm(in=d);

   if a=1 then subgrp_n=1;
   else if b=1 then subgrp_n=2;
   else if c=1 then subgrp_n=3;
   else if d=1 then subgrp_n=4;

   if a=1 then rate=0.0543;
   else if b=1 then rate=0.0601;
   else if c=1 then rate=0.0408;
   else if d=1 then rate=0.0558;

   rate_c = "Event Rate";
   if model="ML" then model="CoxNET";
   if model="REGARDS" then model="REGARDS self-report";
run;

proc format;
   value subgrp 1="Black Women" 2="Black Men" 3="White Women" 4="White Men";
run;

ods graphics / reset=all;
ods listing image_dpi=600 gpath="../manu/validating/output/plots";

ods graphics on / noborder imagefmt=jpeg height=10in width=10in imagename="net_benefit_racesex_v4";
proc sgpanel data=to_plot;
   styleattrs datalinepatterns=(solid) datacontrastcolors=(blue orange green red gray);
	panelby subgrp_n / onepanel layout=panel columns=2 novarname headerattrs=(size=14 weight=bold);
   series x=p y=nb / group=model;
   colaxis values=(0 to 0.10 by 0.02) label="Threshold" labelattrs=(size=12 weight=bold) valueattrs=(size=12);
   rowaxis values=(-0.01 to 0.04 by 0.01) label="Net Benefit" labelattrs=(size=12 weight=bold) valueattrs=(size=12);
   refline 0 / axis=y;
   refline rate / label=rate_c axis=x labelpos=min labelattrs=(size=12) lineattrs=(pattern=4);
   keylegend / noborder title=" " valueattrs=(size=12);
   format subgrp_n subgrp.;
run;

* By Race/Age;
data to_plot;
   attrib rate_c length=$15.;
   set out.nb_by(in=a)
       out.nb_bo(in=b)
       out.nb_wy(in=c)
       out.nb_wo(in=d);

   if a=1 then subgrp_n=1;
   else if b=1 then subgrp_n=2;
   else if c=1 then subgrp_n=3;
   else if d=1 then subgrp_n=4;

   if a=1 then rate=0.0323;
   else if b=1 then rate=0.0697;
   else if c=1 then rate=0.0161;
   else if d=1 then rate=0.0625;

   rate_c = "Event Rate";
   if model="ML" then model="CoxNET";
   if model="REGARDS" then model="REGARDS self-report";

run;

proc format;
   value subgrp 1="Black < 60 years-old" 2="Black (*ESC*){unicode '2265'x} 60 years-old"
                3="White < 60 years-old" 4="White (*ESC*){unicode '2265'x} 60 years-old";
run;

ods graphics / reset=all;
ods listing image_dpi=600 gpath="../manu/validating/output/plots";

ods graphics on / noborder imagefmt=jpeg height=10in width=10in imagename="net_benefit_raceage_v4";
proc sgpanel data=to_plot;
   styleattrs datalinepatterns=(solid) datacontrastcolors=(blue orange green red gray);
	panelby subgrp_n / onepanel layout=panel columns=2 novarname headerattrs=(size=14 weight=bold);
   series x=p y=nb / group=model;
   colaxis values=(0 to 0.10 by 0.02) label="Threshold" labelattrs=(size=12 weight=bold) valueattrs=(size=12);
   rowaxis values=(-0.01 to 0.04 by 0.01) label="Net Benefit" labelattrs=(size=12 weight=bold) valueattrs=(size=12);
   refline 0 / axis=y;
   refline rate / label=rate_c axis=x labelpos=min labelattrs=(size=12) lineattrs=(pattern=4);
   keylegend / noborder title=" " valueattrs=(size=12);
   format subgrp_n subgrp.;
run;
