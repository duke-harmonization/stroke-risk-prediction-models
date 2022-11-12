* #################################################################################
* TASK:     Compare Predictions in REGARDS
* INPUT:    preds_regards_v3
* OUTPUT:
* DATE:     05-JAN-2022
* UPDATES:
* #########################################################################;
options nodate nonumber ls=150 mprint=no mautosource sasautos=("!SASROOT/sasautos","/dcri/shared_code/sas/macro");


libname out "/dcri/sigmadata/stroke_prediction/manu/validating/data";
libname template "/dcri/sigmadata/stroke_prediction/manu/validating/programs/templates";

%include "../manu/ads/programs/etc/formats.sas";

data models;
   set out.preds_regards_v3; /* dataset created in table2.sas */
run;

ods listing close;
proc corr data=models spearman noprob;
   var fsrp10_c_r ascvd10_c_r regs10_c_r coxnet10 rsf10;
   ods output SpearmanCorr=corr_overall;
run;

proc sort data=models;
   by race_c sex;
run;

proc corr data=models spearman noprob;
   by race_c sex;
   var fsrp10_c_r ascvd10_c_r regs10_c_r coxnet10 rsf10;
   ods output SpearmanCorr=corr_bysex;
run;

proc sort data=models;
   by race_c agegrp;
run;

proc corr data=models spearman noprob;
   by race_c agegrp;
   var fsrp10_c_r ascvd10_c_r regs10_c_r coxnet10 rsf10;
   ods output SpearmanCorr=corr_byage;
run;
ods listing;

data blank;
   attrib Variable length=$30.;
   Variable="";
run;

data table;
   set corr_overall
       corr_bysex
       corr_byage;

   if sex=. & agegrp=. & Variable ^= "" then grp=1;
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

   value $mods "fsrp10_c_r"="FSRP"
               "ascvd10_c_r"="ASCVD"
               "regs10_c_r"="REGARDS"
               "coxnet10"="ML"
               "rsf10"="RSF";
run;

options orientation=landscape nodate nonumber;
ods path sashelp.tmplmst(read) template.tables(read);
ods rtf file = "../manu/validating/output/30_corrs.rtf" bodytitle style=grayborders;
ods listing close;
title "eTable 7. Spearman correlation ";
proc report data=table nowd split = '|' missing
   style(report)={just=center}
   style(lines)=header{background=white font_size=10pt font_face="Arial" font_weight=bold just=left}
   style(header)=header{background=white font_size=9pt font_face="Arial" font_weight=bold }
   style(column)=header{background=white font_size=9pt font_face="Arial" font_weight=medium protectspecialchars = off } ;

   columns grp Variable fsrp10_c_r ascvd10_c_r regs10_c_r coxnet10 rsf10;

   define grp / display "Subgroup" style(column)={just=left cellwidth=13%} group order=data;
   define variable / display "Model" style(column)={just=left cellwidth=13%};
   define fsrp10_c_r /display "FSRP" style(column)=[just=center cellwidth=13%];
   define ascvd10_c_r /display "ASCVD" style(column)=[just=center cellwidth=13%];
   define regs10_c_r /display "REGARDS" style(column)=[just=center cellwidth=13%];
   define coxnet10 /display "ML" style(column)=[just=center cellwidth=13%];
   define rsf10 /display "RSF" style(column)=[just=center cellwidth=13%];
   format fsrp10_c_r ascvd10_c_r regs10_c_r coxnet10 rsf10 6.3 grp grpf. Variable $mods.;
run;
ods rtf close;
