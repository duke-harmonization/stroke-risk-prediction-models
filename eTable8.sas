* #################################################################################
* TASK:     Compare Predictions in REGARDS
* INPUT:    preds_regards_v3
* OUTPUT:
* DATE:     05-JAN-2022
* UPDATES:
* #########################################################################;
options nodate nonumber ls=150 mprint=no mautosource sasautos=("!SASROOT/sasautos","/dcri/shared_code/sas/macro");

libname out "../manu/validating/data";
libname template "../manu/validating/programs/templates";

%include "../manu/ads/programs/etc/formats.sas";

data models;
   set out.preds_regards_v3; /* dataset created in table2.sas */
run;

ods listing close;
proc lifetest data=models timelist=(10);
   time t2stroke10_yrs*stroke10(0);
   ods output ProductLimitEstimates=PLE_ove(keep=failure);
run;

proc lifetest data=models timelist=(10);
   strata race_c sex;
   time t2stroke10_yrs*stroke10(0);
   ods output ProductLimitEstimates=PLE_sex(keep=failure race_c sex);
run;

proc lifetest data=models timelist=(10);
   strata race_c agegrp;
   time t2stroke10_yrs*stroke10(0);
   ods output ProductLimitEstimates=PLE_age(keep=failure race_c agegrp);
run;
ods listing;

data models;
   set models;
   if _N_=1 then set PLE_ove(rename=(failure=rate_overall));
run;

proc sort data=models;
   by race_c sex;
run;

proc sort data=PLE_sex;
   by race_c sex;
run;

data models;
   merge models
         PLE_sex(rename=(failure=rate_bysex));
   by race_c sex;
run;

proc sort data=models;
   by race_c agegrp;
run;

proc sort data=PLE_age;
   by race_c agegrp;
run;

data models;
   merge models
         PLE_age(rename=(failure=rate_byage));
   by race_c agegrp;

   * FSRP;
   if 0 <= fsrp10_c_r <= rate_overall then pred_fsrp_o = 0;
   else if fsrp10_c_r >  rate_overall then pred_fsrp_o = 1;

   if 0 <= fsrp10_s_r <= rate_bysex then pred_fsrp_s = 0;
   else if fsrp10_s_r >  rate_bysex then pred_fsrp_s = 1;

   if 0 <= fsrp10_a_r <= rate_byage then pred_fsrp_a = 0;
   else if fsrp10_a_r >  rate_byage then pred_fsrp_a = 1;

   * ASCVD;
   if 0 <= ascvd10_c_r <= rate_overall then pred_ascvd_o = 0;
   else if ascvd10_c_r >  rate_overall then pred_ascvd_o = 1;

   if 0 <= ascvd10_s_r <= rate_bysex then pred_ascvd_s = 0;
   else if ascvd10_s_r >  rate_bysex then pred_ascvd_s = 1;

   if 0 <= ascvd10_a_r <= rate_byage then pred_ascvd_a = 0;
   else if ascvd10_a_r >  rate_byage then pred_ascvd_a = 1;

   * REGARDS;
   if 0 <= regs10_c_r <= rate_overall then pred_regs_o = 0;
   else if regs10_c_r >  rate_overall then pred_regs_o = 1;

   if 0 <= regs10_s_r <= rate_bysex then pred_regs_s = 0;
   else if regs10_s_r >  rate_bysex then pred_regs_s = 1;

   if 0 <= regs10_a_r <= rate_byage then pred_regs_a = 0;
   else if regs10_a_r >  rate_byage then pred_regs_a = 1;

   * ML;
   if 0 <= coxnet10 <= rate_overall then pred_ml_o = 0;
   else if coxnet10 >  rate_overall then pred_ml_o = 1;

   if 0 <= coxnet10 <= rate_bysex then pred_ml_s = 0;
   else if coxnet10 >  rate_bysex then pred_ml_s = 1;

   if 0 <= coxnet10 <= rate_byage then pred_ml_a = 0;
   else if coxnet10 >  rate_byage then pred_ml_a = 1;

   * RSF;
   if 0 <= rsf10 <= rate_overall then pred_rsf_o = 0;
   else if rsf10 >  rate_overall then pred_rsf_o = 1;

   if 0 <= rsf10 <= rate_bysex then pred_rsf_s = 0;
   else if rsf10 >  rate_bysex then pred_rsf_s = 1;

   if 0 <= rsf10 <= rate_byage then pred_rsf_a = 0;
   else if rsf10 >  rate_byage then pred_rsf_a = 1;
run;

* Overall;
ods listing close;
proc freq data=models;
   tables pred_fsrp_o*pred_ascvd_o / nocol norow nopercent agree;
   tables pred_fsrp_o*pred_regs_o / nocol norow nopercent agree;
   tables pred_fsrp_o*pred_ml_o / nocol norow nopercent agree;
   tables pred_fsrp_o*pred_rsf_o / nocol norow nopercent agree;
   tables pred_ascvd_o*pred_regs_o / nocol norow nopercent agree;
   tables pred_ascvd_o*pred_ml_o / nocol norow nopercent agree;
   tables pred_ascvd_o*pred_rsf_o / nocol norow nopercent agree;
   tables pred_regs_o*pred_ml_o / nocol norow nopercent agree;
   tables pred_regs_o*pred_rsf_o / nocol norow nopercent agree;
   tables pred_ml_o*pred_rsf_o / nocol norow nopercent agree;
   ods output KappaStatistics=KS_overall;
run;
ods listing;

data KS_o;
   set KS_overall end=eof;

   retain k1-k10 k 0;
   array ks[10] k1-k10;
   k + 1;

   ks[k] = Value;

   if eof then do;
      keep k1-k10;
      output;
      end;
run;

proc sort data=models;
   by race_c sex;
run;

ods listing close;
proc freq data=models;
   by race_c sex;
   tables pred_fsrp_s*pred_ascvd_s / nocol norow nopercent agree;
   tables pred_fsrp_s*pred_regs_s / nocol norow nopercent agree;
   tables pred_fsrp_s*pred_ml_s / nocol norow nopercent agree;
   tables pred_fsrp_s*pred_rsf_s / nocol norow nopercent agree;
   tables pred_ascvd_s*pred_regs_s / nocol norow nopercent agree;
   tables pred_ascvd_s*pred_ml_s / nocol norow nopercent agree;
   tables pred_ascvd_s*pred_rsf_s / nocol norow nopercent agree;
   tables pred_regs_s*pred_ml_s / nocol norow nopercent agree;
   tables pred_regs_s*pred_rsf_s / nocol norow nopercent agree;
   tables pred_ml_s*pred_rsf_s / nocol norow nopercent agree;
   ods output KappaStatistics=KS_sex;
run;
ods listing;

data KS_s;
   set KS_sex;
   by race_c sex;

   retain k1-k10 k 0;
   array ks[10] k1-k10;

   if first.sex then do;
      call missing(of ks{*});
      k=0;
      end;

   k + 1;
   ks[k] = Value;

   if last.sex then do;
      keep race_c sex k1-k10;
      output;
      end;
run;

proc sort data=models;
   by race_c agegrp;
run;

ods listing close;
proc freq data=models;
   by race_c agegrp;
   tables pred_fsrp_s*pred_ascvd_s / nocol norow nopercent agree;
   tables pred_fsrp_s*pred_regs_s / nocol norow nopercent agree;
   tables pred_fsrp_s*pred_ml_s / nocol norow nopercent agree;
   tables pred_fsrp_s*pred_rsf_s / nocol norow nopercent agree;
   tables pred_ascvd_s*pred_regs_s / nocol norow nopercent agree;
   tables pred_ascvd_s*pred_ml_s / nocol norow nopercent agree;
   tables pred_ascvd_s*pred_rsf_s / nocol norow nopercent agree;
   tables pred_regs_s*pred_ml_s / nocol norow nopercent agree;
   tables pred_regs_s*pred_rsf_s / nocol norow nopercent agree;
   tables pred_ml_s*pred_rsf_s / nocol norow nopercent agree;
   ods output KappaStatistics=KS_age;
run;
ods listing;

data KS_a;
   set KS_age;
   by race_c agegrp;

   retain k1-k10 k 0;
   array ks[10] k1-k10;

   if first.agegrp then do;
      call missing(of ks{*});
      k=0;
      end;

   k + 1;
   ks[k] = Value;

   if last.agegrp then do;
      keep race_c agegrp k1-k10;
      output;
      end;
run;

data table;
   set KS_o
       KS_s
       KS_a;

   if sex=. & agegrp=. then grp=1;
   else if race_c="Black" & sex=2 then grp=2;
   else if race_c="Black" & sex=1 then grp=3;
   else if race_c="White" & sex=2 then grp=4;
   else if race_c="White" & sex=1 then grp=5;

   else if race_c="Black" & agegrp=1 then grp=6;
   else if race_c="Black" & agegrp=2 then grp=7;
   else if race_c="White" & agegrp=1 then grp=8;
   else if race_c="White" & agegrp=2 then grp=9;
run;

proc sort data=table;
   by grp;
run;

proc format;
   value grpf 1="Overall"
              2="Black - Female"
              3="Black - Male"
              4="White - Female"
              5="White - Male"
              6="Black - < 60 "
              7="Black - >= 60"
              8="White - < 60"
              9="White - >= 60";
run;

options orientation=landscape nodate nonumber;
ods path sashelp.tmplmst(read) template.tables(read);
ods rtf file = "../manu/validating/output/30_kappas.rtf" bodytitle style=grayborders;
ods listing close;
title "eTable 8. Kappa's";
proc report data=table nowd split = '|' missing
   style(report)={just=center}
   style(lines)=header{background=white font_size=10pt font_face="Arial" font_weight=bold just=left}
   style(header)=header{background=white font_size=9pt font_face="Arial" font_weight=bold }
   style(column)=header{background=white font_size=9pt font_face="Arial" font_weight=medium protectspecialchars = off } ;

   columns grp ("FSRP vs." k1 k2 k3 k4) ("ASCVD vs." k5 k6 k7) ("REGARDS vs." k8 k9) ("ML vs." k10);

   define grp / display "Subgroup" style(column)={just=left cellwidth=10%};

   define k1 / display "ASCVD" style(column)={just=center cellwidth=8%};
   define k2 / display "REGARDS" style(column)={just=center cellwidth=8%};
   define k3 / display "ML" style(column)={just=center cellwidth=8%};
   define k4 / display "RSF" style(column)={just=center cellwidth=8%};
   define k5 / display "REGARDS" style(column)={just=center cellwidth=8%};
   define k6 / display "ML" style(column)={just=center cellwidth=8%};
   define k7 / display "RSF" style(column)={just=center cellwidth=8%};
   define k8 / display "ML" style(column)={just=center cellwidth=8%};
   define k9 / display "RSF" style(column)={just=center cellwidth=8%};
   define k10 / display "RSF" style(column)={just=center cellwidth=8%};
   format k1-k10 6.3 grp grpf.;
run;
ods rtf close;
