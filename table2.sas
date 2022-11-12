* #################################################################################
* TASK:     Computing metrics in REGARDS with recalibrated models = version 2
* INPUT:    stroke_risk_ads_v4, recalibrated survival
* OUTPUT:
* DATE:     03-JAN-2022
* UPDATES:  New version with Uno's c-index and correct interaction term in REGARDS model
* #########################################################################;
options nodate nonumber ls=120 mprint=no mautosource sasautos=("!SASROOT/sasautos","/dcri/shared_code/sas/macro") nocenter;

libname mydata "../manu/ads/data";
libname in "../manu/validating/data";
libname in3 "../manu/validating/data/recalibrations_v3";
libname template "../manu/validating/programs/templates";

%include "../manu/ads/programs/etc/formats.sas";
%include "../manu/validating/programs/etc/cidx_uno.sas";
%include "../manu/validating/programs/etc/brier13.sas";
%include "../manu/validating/programs/etc/obsexp.sas";

* REGARDS data;
data regards;
   set in.imputed_v3(where=(study="REGARDS"));

   if race_c="Black" then aa=1;
   else if race_c= "White" then aa=0;

run;

proc sort data=regards;
   by usubjid;
run;

proc sort data=mydata.stroke_risk_ads_v4(where=(study=("REGARDS"))) out=strk(keep=usubjid t2stroke);
   by usubjid;
run;

proc sort data=in.ml_results_regards_v2 out=ml_results_regards;
   by usubjid;
run;

data regards;
   merge regards
         ml_results_regards
         strk;
   by usubjid;

   coxnet10 = 1 - union_coxnet_10yr_cum_risk_pred;
   rsf10 = 1 - union_RSF_10yr_cum_risk_pred;

   drop union_coxnet_10yr_cum_risk_pred union_RSF_10yr_cum_risk_pred union_GBSA_10yr_cum_risk_pred;
run;

proc sort data=regards;
   by sex;
run;

data regards;
   merge regards
         in3.s0_fsrp;
   by sex;
run;

proc sort data=regards;
   by race_c sex;
run;

data regards;
   merge regards
         in3.s0_ascvd;
   by race_c sex;
run;

data regards;
   set regards;
   if _N_=1 then set in3.s0_regs;
run;

* Predicting;
data regards;
   set regards;

   * Predicting using recalibrated FSRP;
   if sex=1 then do;
      fsrp10_s_r = 1 - (fsrp_s0_s)**exp(F_men_s - fsrp_xbm_s);
      fsrp10_a_r = 1 - (fsrp_s0_a)**exp(F_men_a - fsrp_xbm_a);
      fsrp10_c_r = 1 - (fsrp_s0_c)**exp(F_men_c - fsrp_xbm_c);
      end;

   else if sex=2 then do;
      fsrp10_s_r = 1 - (fsrp_s0_s)**exp(F_wom_s - fsrp_xbm_s);
      fsrp10_a_r = 1 - (fsrp_s0_a)**exp(F_wom_a - fsrp_xbm_a);
      fsrp10_c_r = 1 - (fsrp_s0_c)**exp(F_wom_c - fsrp_xbm_c);
      end;

   * Predicting using recalibrated ASCVD;
   if sex=2 & aa=0 then do;
      ascvd10_s_r = 1 - (ascvd_s0_s)**exp(G_wwom_s - ascvd_xbm_s);
      ascvd10_a_r = 1 - (ascvd_s0_a)**exp(G_wwom_a - ascvd_xbm_a);
      ascvd10_c_r = 1 - (ascvd_s0_c)**exp(G_wwom_c - ascvd_xbm_c);
      end;

   else if sex=2 & aa=1 then do;
      ascvd10_s_r = 1 - (ascvd_s0_s)**exp(G_bwom_s - ascvd_xbm_s);
      ascvd10_a_r = 1 - (ascvd_s0_a)**exp(G_bwom_a - ascvd_xbm_a);
      ascvd10_c_r = 1 - (ascvd_s0_c)**exp(G_bwom_c - ascvd_xbm_c);
      end;

   else if sex=1 & aa=0  then do;
      ascvd10_s_r = 1 - (ascvd_s0_s)**exp(G_wmen_s - ascvd_xbm_s);
      ascvd10_a_r = 1 - (ascvd_s0_a)**exp(G_wmen_a - ascvd_xbm_a);
      ascvd10_c_r = 1 - (ascvd_s0_c)**exp(G_wmen_c - ascvd_xbm_c);
      end;

   else if sex=1 & aa=1  then do;
      ascvd10_s_r = 1 - (ascvd_s0_s)**exp(G_bmen_s - ascvd_xbm_s);
      ascvd10_a_r = 1 - (ascvd_s0_a)**exp(G_bmen_a - ascvd_xbm_a);
      ascvd10_c_r = 1 - (ascvd_s0_c)**exp(G_bmen_c - ascvd_xbm_c);
      end;

   * Predicting using recalibrated REGARDS;
   regs10_s_r = 1 - (regs_s0_s)**exp(Rs - regs_xbm_s);
   regs10_a_r = 1 - (regs_s0_a)**exp(Ra - regs_xbm_a);
   regs10_c_r = 1 - (regs_s0_c)**exp(Rc - regs_xbm_c);
run;

* c-index for Table 2a;
%cidx(regards,%str(race_c="Black" & sex=2),fsrp10_s_r,bw_m1);
%cidx(regards,%str(race_c="Black" & sex=2),ascvd10_s_r,bw_m2);
%cidx(regards,%str(race_c="Black" & sex=2),regs10_s_r,bw_m3);
%cidx(regards,%str(race_c="Black" & sex=2),coxnet10,bw_m4);
%cidx(regards,%str(race_c="Black" & sex=2),rsf10,bw_m5);

%cidx(regards,%str(race_c="Black" & sex=1),fsrp10_s_r,bm_m1);
%cidx(regards,%str(race_c="Black" & sex=1),ascvd10_s_r,bm_m2);
%cidx(regards,%str(race_c="Black" & sex=1),regs10_s_r,bm_m3);
%cidx(regards,%str(race_c="Black" & sex=1),coxnet10,bm_m4);
%cidx(regards,%str(race_c="Black" & sex=1),rsf10,bm_m5);

%cidx(regards,%str(race_c="White" & sex=2),fsrp10_s_r,ww_m1);
%cidx(regards,%str(race_c="White" & sex=2),ascvd10_s_r,ww_m2);
%cidx(regards,%str(race_c="White" & sex=2),regs10_s_r,ww_m3);
%cidx(regards,%str(race_c="White" & sex=2),coxnet10,ww_m4);
%cidx(regards,%str(race_c="White" & sex=2),rsf10,ww_m5);

%cidx(regards,%str(race_c="White" & sex=1),fsrp10_s_r,wm_m1);
%cidx(regards,%str(race_c="White" & sex=1),ascvd10_s_r,wm_m2);
%cidx(regards,%str(race_c="White" & sex=1),regs10_s_r,wm_m3);
%cidx(regards,%str(race_c="White" & sex=1),coxnet10,wm_m4);
%cidx(regards,%str(race_c="White" & sex=1),rsf10,wm_m5);

* Brier Scores for Table 2a;
%brier13(regards,%str(race_c="Black" & sex=2),fsrp10_s_r,bri_bw_m1);
%brier13(regards,%str(race_c="Black" & sex=2),ascvd10_s_r,bri_bw_m2);
%brier13(regards,%str(race_c="Black" & sex=2),regs10_s_r,bri_bw_m3);
%brier13(regards,%str(race_c="Black" & sex=2),coxnet10,bri_bw_m4);
%brier13(regards,%str(race_c="Black" & sex=2),rsf10,bri_bw_m5);

%brier13(regards,%str(race_c="Black" & sex=1),fsrp10_s_r,bri_bm_m1);
%brier13(regards,%str(race_c="Black" & sex=1),ascvd10_s_r,bri_bm_m2);
%brier13(regards,%str(race_c="Black" & sex=1),regs10_s_r,bri_bm_m3);
%brier13(regards,%str(race_c="Black" & sex=1),coxnet10,bri_bm_m4);
%brier13(regards,%str(race_c="Black" & sex=1),rsf10,bri_bm_m5);

%brier13(regards,%str(race_c="White" & sex=2),fsrp10_s_r,bri_ww_m1);
%brier13(regards,%str(race_c="White" & sex=2),ascvd10_s_r,bri_ww_m2);
%brier13(regards,%str(race_c="White" & sex=2),regs10_s_r,bri_ww_m3);
%brier13(regards,%str(race_c="White" & sex=2),coxnet10,bri_ww_m4);
%brier13(regards,%str(race_c="White" & sex=2),rsf10,bri_ww_m5);

%brier13(regards,%str(race_c="White" & sex=1),fsrp10_s_r,bri_wm_m1);
%brier13(regards,%str(race_c="White" & sex=1),ascvd10_s_r,bri_wm_m2);
%brier13(regards,%str(race_c="White" & sex=1),regs10_s_r,bri_wm_m3);
%brier13(regards,%str(race_c="White" & sex=1),coxnet10,bri_wm_m4);
%brier13(regards,%str(race_c="White" & sex=1),rsf10,bri_wm_m5);

* Observed/Expected Table 3;
%obsexp(regards,%str(race_c="Black" & sex=2),fsrp10_s_r,oe_bw_m1);
%obsexp(regards,%str(race_c="Black" & sex=2),ascvd10_s_r,oe_bw_m2);
%obsexp(regards,%str(race_c="Black" & sex=2),regs10_s_r,oe_bw_m3);
%obsexp(regards,%str(race_c="Black" & sex=2),coxnet10,oe_bw_m4);
%obsexp(regards,%str(race_c="Black" & sex=2),rsf10,oe_bw_m5);

%obsexp(regards,%str(race_c="Black" & sex=1),fsrp10_s_r,oe_bm_m1);
%obsexp(regards,%str(race_c="Black" & sex=1),ascvd10_s_r,oe_bm_m2);
%obsexp(regards,%str(race_c="Black" & sex=1),regs10_s_r,oe_bm_m3);
%obsexp(regards,%str(race_c="Black" & sex=1),coxnet10,oe_bm_m4);
%obsexp(regards,%str(race_c="Black" & sex=1),rsf10,oe_bm_m5);

%obsexp(regards,%str(race_c="White" & sex=2),fsrp10_s_r,oe_ww_m1);
%obsexp(regards,%str(race_c="White" & sex=2),ascvd10_s_r,oe_ww_m2);
%obsexp(regards,%str(race_c="White" & sex=2),regs10_s_r,oe_ww_m3);
%obsexp(regards,%str(race_c="White" & sex=2),coxnet10,oe_ww_m4);
%obsexp(regards,%str(race_c="White" & sex=2),rsf10,oe_ww_m5);

%obsexp(regards,%str(race_c="White" & sex=1),fsrp10_s_r,oe_wm_m1);
%obsexp(regards,%str(race_c="White" & sex=1),ascvd10_s_r,oe_wm_m2);
%obsexp(regards,%str(race_c="White" & sex=1),regs10_s_r,oe_wm_m3);
%obsexp(regards,%str(race_c="White" & sex=1),coxnet10,oe_wm_m4);
%obsexp(regards,%str(race_c="White" & sex=1),rsf10,oe_wm_m5);

data blank;
   attrib result length=$30.;
   result="";
run;

* Table 2a;
data t3_cindex;
   set bw_m1-bw_m5
       blank
       bm_m1-bm_m5
       blank
       ww_m1-ww_m5
       blank
       wm_m1-wm_m5;
   retain row 0;
   row + 1;
run;

data t3_brier;
   set bri_bw_m1-bri_bw_m5
       blank
       bri_bm_m1-bri_bm_m5
       blank
       bri_ww_m1-bri_ww_m5
       blank
       bri_wm_m1-bri_wm_m5;

   retain row 0;
   row + 1;
run;

data t3_obsexp;
   set oe_bw_m1-oe_bw_m5
       blank
       oe_bm_m1-oe_bm_m5
       blank
       oe_ww_m1-oe_ww_m5
       blank
       oe_wm_m1-oe_wm_m5;

   retain row 0;
   row + 1;
run;

data table3;
   attrib model length=$10.;
   attrib subgroup length=$40.;
   merge t3_cindex(rename=(result=cindex))
         t3_brier(rename=(result=brier))
         t3_obsexp;
   by row;

   if row in (1,7,13,19) then model="FSRP";
   else if row in (2,8,14,20) then model="ASCVD";
   else if row in (3,9,15,21) then model="REGARDS";
   else if row in (4,10,16,22) then model="ML";
   else if row in (5,11,17,23) then model="RSF";

   if row in (1,2,3,4,5) then subgroup="Black Women";
   else if row in (7,8,9,10,11) then subgroup="Black Men";
   else if row in (13,14,15,16,17) then subgroup="White Women";
   else if row in (19,20,21,22,23) then subgroup="White Men";
run;

options orientation=portrait nodate nonumber;
ods path sashelp.tmplmst(read) template.tables(read);
ods rtf file = "../manu/validating/output/27_table3x.rtf" bodytitle style=grayborders;
ods listing close;
title "Table 2a. Validation metrics for previously developed models: by race + sex in REGARDS == Uno c-index version";
proc report data=table3 nowd split = '|' missing
   style(report)={just=center}
   style(lines)=header{background=white font_size=10pt
   font_face="Arial" font_weight=bold just=left}
   style(header)=header{background=white font_size=9pt
   font_face="Arial" font_weight=bold }
   style(column)=header{background=white font_size=9pt
   font_face="Arial" font_weight=medium protectspecialchars = off } ;

   columns subgroup model cindex brier exp_risk obs_risk;

   define subgroup / display "Subgroup" style(header)={just=left cellwidth=14%} ;
   define model / display "Model" style(header)={just=left cellwidth=12%};

   define cindex /display "c-index" style(column)=[just=center cellwidth=20%];
   define brier /display "Brier (%)" style(column)=[just=center cellwidth=20%];
   define exp_risk /display "Expected Risk" style(column)=[just=center cellwidth=16%];
   define obs_risk /display "Observed Risk" style(column)=[just=center cellwidth=16%];
run;
ods rtf close;

* c-index for Table 2b;
%cidx(regards,%str(race_c="Black" & agegrp=1),fsrp10_a_r,by_m1);
%cidx(regards,%str(race_c="Black" & agegrp=1),ascvd10_a_r,by_m2);
%cidx(regards,%str(race_c="Black" & agegrp=1),regs10_a_r,by_m3);
%cidx(regards,%str(race_c="Black" & agegrp=1),coxnet10,by_m4);
%cidx(regards,%str(race_c="Black" & agegrp=1),rsf10,by_m5);

%cidx(regards,%str(race_c="Black" & agegrp=2),fsrp10_a_r,bo_m1);
%cidx(regards,%str(race_c="Black" & agegrp=2),ascvd10_a_r,bo_m2);
%cidx(regards,%str(race_c="Black" & agegrp=2),regs10_a_r,bo_m3);
%cidx(regards,%str(race_c="Black" & agegrp=2),coxnet10,bo_m4);
%cidx(regards,%str(race_c="Black" & agegrp=2),rsf10,bo_m5);

%cidx(regards,%str(race_c="White" & agegrp=1),fsrp10_a_r,wy_m1);
%cidx(regards,%str(race_c="White" & agegrp=1),ascvd10_a_r,wy_m2);
%cidx(regards,%str(race_c="White" & agegrp=1),regs10_a_r,wy_m3);
%cidx(regards,%str(race_c="White" & agegrp=1),coxnet10,wy_m4);
%cidx(regards,%str(race_c="White" & agegrp=1),rsf10,wy_m5);

%cidx(regards,%str(race_c="White" & agegrp=2),fsrp10_a_r,wo_m1);
%cidx(regards,%str(race_c="White" & agegrp=2),ascvd10_a_r,wo_m2);
%cidx(regards,%str(race_c="White" & agegrp=2),regs10_a_r,wo_m3);
%cidx(regards,%str(race_c="White" & agegrp=2),coxnet10,wo_m4);
%cidx(regards,%str(race_c="White" & agegrp=2),rsf10,wo_m5);

* Brier Scores for Table 2b;
%brier13(regards,%str(race_c="Black" & agegrp=1),fsrp10_a_r,bri_by_m1);
%brier13(regards,%str(race_c="Black" & agegrp=1),ascvd10_a_r,bri_by_m2);
%brier13(regards,%str(race_c="Black" & agegrp=1),regs10_a_r,bri_by_m3);
%brier13(regards,%str(race_c="Black" & agegrp=1),coxnet10,bri_by_m4);
%brier13(regards,%str(race_c="Black" & agegrp=1),rsf10,bri_by_m5);

%brier13(regards,%str(race_c="Black" & agegrp=2),fsrp10_a_r,bri_bo_m1);
%brier13(regards,%str(race_c="Black" & agegrp=2),ascvd10_a_r,bri_bo_m2);
%brier13(regards,%str(race_c="Black" & agegrp=2),regs10_a_r,bri_bo_m3);
%brier13(regards,%str(race_c="Black" & agegrp=2),coxnet10,bri_bo_m4);
%brier13(regards,%str(race_c="Black" & agegrp=2),rsf10,bri_bo_m5);

%brier13(regards,%str(race_c="White" & agegrp=1),fsrp10_a_r,bri_wy_m1);
%brier13(regards,%str(race_c="White" & agegrp=1),ascvd10_a_r,bri_wy_m2);
%brier13(regards,%str(race_c="White" & agegrp=1),regs10_a_r,bri_wy_m3);
%brier13(regards,%str(race_c="White" & agegrp=1),coxnet10,bri_wy_m4);
%brier13(regards,%str(race_c="White" & agegrp=1),rsf10,bri_wy_m5);

%brier13(regards,%str(race_c="White" & agegrp=2),fsrp10_a_r,bri_wo_m1);
%brier13(regards,%str(race_c="White" & agegrp=2),ascvd10_a_r,bri_wo_m2);
%brier13(regards,%str(race_c="White" & agegrp=2),regs10_a_r,bri_wo_m3);
%brier13(regards,%str(race_c="White" & agegrp=2),coxnet10,bri_wo_m4);
%brier13(regards,%str(race_c="White" & agegrp=2),rsf10,bri_wo_m5);

* Observed/Expected Table 2b;
%obsexp(regards,%str(race_c="Black" & agegrp=1),fsrp10_a_r,oe_by_m1);
%obsexp(regards,%str(race_c="Black" & agegrp=1),ascvd10_a_r,oe_by_m2);
%obsexp(regards,%str(race_c="Black" & agegrp=1),regs10_a_r,oe_by_m3);
%obsexp(regards,%str(race_c="Black" & agegrp=1),coxnet10,oe_by_m4);
%obsexp(regards,%str(race_c="Black" & agegrp=1),rsf10,oe_by_m5);

%obsexp(regards,%str(race_c="Black" & agegrp=2),fsrp10_a_r,oe_bo_m1);
%obsexp(regards,%str(race_c="Black" & agegrp=2),ascvd10_a_r,oe_bo_m2);
%obsexp(regards,%str(race_c="Black" & agegrp=2),regs10_a_r,oe_bo_m3);
%obsexp(regards,%str(race_c="Black" & agegrp=2),coxnet10,oe_bo_m4);
%obsexp(regards,%str(race_c="Black" & agegrp=2),rsf10,oe_bo_m5);

%obsexp(regards,%str(race_c="White" & agegrp=1),fsrp10_a_r,oe_wy_m1);
%obsexp(regards,%str(race_c="White" & agegrp=1),ascvd10_a_r,oe_wy_m2);
%obsexp(regards,%str(race_c="White" & agegrp=1),regs10_a_r,oe_wy_m3);
%obsexp(regards,%str(race_c="White" & agegrp=1),coxnet10,oe_wy_m4);
%obsexp(regards,%str(race_c="White" & agegrp=1),rsf10,oe_wy_m5);

%obsexp(regards,%str(race_c="White" & agegrp=2),fsrp10_a_r,oe_wo_m1);
%obsexp(regards,%str(race_c="White" & agegrp=2),ascvd10_a_r,oe_wo_m2);
%obsexp(regards,%str(race_c="White" & agegrp=2),regs10_a_r,oe_wo_m3);
%obsexp(regards,%str(race_c="White" & agegrp=2),coxnet10,oe_wo_m4);
%obsexp(regards,%str(race_c="White" & agegrp=2),rsf10,oe_wo_m5);

data blank;
   attrib result length=$30.;
   result="";
run;

* Table 2b;
data t4_cindex;
   set by_m1-by_m5
       blank
       bo_m1-bo_m5
       blank
       wy_m1-wy_m5
       blank
       wo_m1-wo_m5;
   retain row 0;
   row + 1;
run;

data t4_brier;
   set bri_by_m1-bri_by_m5
       blank
       bri_bo_m1-bri_bo_m5
       blank
       bri_wy_m1-bri_wy_m5
       blank
       bri_wo_m1-bri_wo_m5;

   retain row 0;
   row + 1;
run;

data t4_obsexp;
   set oe_by_m1-oe_by_m5
       blank
       oe_bo_m1-oe_bo_m5
       blank
       oe_wy_m1-oe_wy_m5
       blank
       oe_wo_m1-oe_wo_m5;

   retain row 0;
   row + 1;
run;

data table4;
   attrib model length=$10.;
   attrib subgroup length=$40.;
   merge t4_cindex(rename=(result=cindex))
         t4_brier(rename=(result=brier))
         t4_obsexp;
   by row;

   if row in (1,7,13,19) then model="FSRP";
   else if row in (2,8,14,20) then model="ASCVD";
   else if row in (3,9,15,21) then model="REGARDS";
   else if row in (4,10,16,22) then model="ML";
   else if row in (5,11,17,23) then model="RSF";

   if row in (1,2,3,4,5) then subgroup="Black Women";
   else if row in (7,8,9,10,11) then subgroup="Black Men";
   else if row in (13,14,15,16,17) then subgroup="White Women";
   else if row in (19,20,21,22,23) then subgroup="White Men";
run;

options orientation=portrait nodate nonumber;
ods path sashelp.tmplmst(read) template.tables(read);
ods rtf file = "../manu/validating/output/27_table4x.rtf" bodytitle style=grayborders;
ods listing close;
title "Table 2b. Validation metrics for previously developed models: by race + age in REGARDS == Uno c-index version";
proc report data=table4 nowd split = '|' missing
   style(report)={just=center}
   style(lines)=header{background=white font_size=10pt
   font_face="Arial" font_weight=bold just=left}
   style(header)=header{background=white font_size=9pt
   font_face="Arial" font_weight=bold }
   style(column)=header{background=white font_size=9pt
   font_face="Arial" font_weight=medium protectspecialchars = off } ;

   columns subgroup model cindex brier exp_risk obs_risk;

   define subgroup / display "Subgroup" style(header)={just=left cellwidth=14%} ;
   define model / display "Model" style(header)={just=left cellwidth=12%};

   define cindex /display "c-index" style(column)=[just=center cellwidth=20%];
   define brier /display "Brier (%)" style(column)=[just=center cellwidth=20%];
   define exp_risk /display "Expected Risk" style(column)=[just=center cellwidth=16%];
   define obs_risk /display "Observed Risk" style(column)=[just=center cellwidth=16%];
run;
ods rtf close;

data in.preds_regards_v3;
   set regards;
run;
