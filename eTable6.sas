* #################################################################################
* TASK:     Validating All Models Final Version - Tables 1 and 2: only c-indices
* INPUT:    stroke_risk_ads_v3
* OUTPUT:
* DATE:     20-OCT-2021
* UPDATES:
* #########################################################################;
options nodate nonumber ls=150 mprint=no mautosource sasautos=("!SASROOT/sasautos","/dcri/shared_code/sas/macro");

libname mydata "../manu/ads/data";
libname out "../manu/validating/data";
libname in3 "../manu/validating/data/recalibrations_v3";
libname template "../manu/validating/programs/templates";

%include "../manu/ads/programs/etc/formats.sas";
%include "../manu/validating/programs/etc/cidx_uno.sas";
%include "../manu/validating/programs/etc/brier13.sas";
%include "../manu/validating/programs/etc/obsexp.sas";

* Create Variables Needed in All 3 Models;
data all;
   set mydata.stroke_risk_ads_v4;

   * To Define Subpopulations;
   if 45 <= age < 60 then agegrp=1;
   else if age >= 60 then agegrp=2;

   * ###### FRAMINGHAM STROKE RISK PROFILE ######;
   * Variables Needed for FSRP;
   if age >= 65 then age65=1;
   else if .z < age < 65 then age65=0;

   if .z < age < 65 & diab=1 then age_l65_diab=1;
   else if age >= 65 | diab=0 then age_l65_diab=0;

   if age >= 65 & diab=1 then age_g65_diab=1;
   else if .z < age < 65 | diab=0 then age_g65_diab=0;

   * Women;
   if sex=2 then do;
      F_age_w = 0.87938*(age/10);
      F_smk_w = 0.51127*currsmk;
      F_cvd_w = -0.03035*hxcvd;
      F_afi_w = 1.20720*afib;
      F_a65_w = 0.39796*age65;
      F_ald_w = 1.07111*age_l65_diab;
      F_agd_w = 0.06565*age_g65_diab;
      F_hrx_w = 0.13085*hrx;
      F_sb1_w = 0.11303*(sysbp-120)/10*(1-hrx);
      F_sb2_w = 0.17234*(sysbp-120)/10*hrx;

      F_w = F_age_w + F_smk_w + F_cvd_w + F_afi_w + F_a65_w +
            F_ald_w + F_agd_w + F_hrx_w + F_sb1_w + F_sb2_w;
      end;

   * Men;
   else if sex=1 then do;
      F_age_m = 0.49716*(age/10);
      F_smk_m = 0.47254*currsmk;
      F_cvd_m = 0.45341*hxcvd;
      F_afi_m = 0.08064*afib;
      F_a65_m = 0.45426*age65;
      F_ald_m = 1.35304*age_l65_diab;
      F_agd_m = 0.34385*age_g65_diab;
      F_hrx_m = 0.82598*hrx;
      F_sb1_m = 0.27323*(sysbp-120)/10*(1-hrx);
      F_sb2_m = 0.09793*(sysbp-120)/10*hrx;

      F_m = F_age_m + F_smk_m + F_cvd_m + F_afi_m + F_a65_m +
            F_ald_m + F_agd_m + F_hrx_m + F_sb1_m + F_sb2_m;
      end;

   * ###### ASCVD MODEL ######;
   * Variables Needed for ASCVD;
   if race_c="Black" then aa=1;
   else if race_c= "White" then aa=0;

   * White / Women;
   if sex=2 & aa=0 then do;
      G_age_ww = -29.799*log(age);
      G_ag2_ww = 4.884*log(age)*log(age);
      G_chl_ww = 13.540*log(tc);
      G_ach_ww = -3.114*log(age)*log(tc);
      G_hdl_ww = -13.578*log(hdl);
      G_ahd_ww = 3.149*log(age)*log(hdl);
      G_sb1_ww = 2.019*hrx*log(sysbp);
      G_sb2_ww = 1.957*(1-hrx)*log(sysbp);
      G_smk_ww = 7.574*currsmk;
      G_asm_ww = -1.665*log(age)*currsmk;
      G_dbt_ww = 0.661*diab;
      end;

   * African-American / Women;
   else if sex=2 & aa=1 then do;
      G_age_bw = 17.114*log(age);
      G_chl_bw = 0.94*log(tc);
      G_hdl_bw = -18.92*log(hdl);
      G_ahd_bw = 4.475*log(age)*log(hdl);
      G_sb1_bw = 29.291*hrx*log(sysbp);
      G_sb2_bw = 27.82*(1-hrx)*log(sysbp);
      G_sh1_bw = -6.432*hrx*log(age)*log(sysbp);
      G_sh2_bw = -6.087*(1-hrx)*log(age)*log(sysbp);
      G_smk_bw =0.691*currsmk;
      G_dbt_bw =0.874*diab;
      end;

   * White / Men;
   else if sex=1 & aa=0 then do;
      G_age_wm = 12.344*log(age);
      G_chl_wm = 11.853*log(tc);
      G_ach_wm = -2.664*log(age)*log(tc);
      G_hdl_wm = -7.990*log(hdl);
      G_ahd_wm = 1.769*log(age)*log(hdl);
      G_sb1_wm = 1.797*hrx*log(sysbp);
      G_sb2_wm = 1.764*(1-hrx)*log(sysbp);
      G_smk_wm = 7.837*currsmk;
      G_asm_wm = -1.795*log(age)*currsmk;
      G_dbt_wm = 0.658*diab;
      end;

   * African-American / Men;
   else if sex=1 & aa=1 then do;
      G_age_bm = 2.469*log(age);
      G_chl_bm = 0.302*log(tc);
      G_hdl_bm = -0.307*log(hdl);
      G_sb1_bm = 1.916*hrx*log(sysbp);
      G_sb2_bm = 1.809*(1-hrx)*log(sysbp);
      G_smk_bm = 0.549*currsmk;
      G_dbt_bm = 0.645*diab;
      end;

   * ###### REGARDS MODEL ######;
   * All  missings in Offspring 3, using most common overall;
   if cohort=1 then health=3;

   * Variables Needed for REGARDS;
   age60 = age/10;
   female = sex - 1;
   educ3 = (educlev=3) + 0*educlev;
   educ2 = (educlev=2) + 0*educlev;
   educ1 = (educlev=1) + 0*educlev;
   health2 = (health=2) + 0*health;
   health3 = (health=3) + 0*health;
   health4 = (health=4) + 0*health;
   health5 = (health=5) + 0*health;

   if study ^= "REGARDS" then do;
      R_age = 0.78687*age60;
      R_rac = 2.13064*aa;
      R_agr = -0.29208*age60*aa;
      R_sex = -0.28036*female;
      R_afi = 0.33039*afib;
      R_dbt = 0.31412*diab;
      R_hrx = 0.24689*hrx;
      R_hmi = 0.40563*hxmi;
      R_smk = 0.51806*currsmk;
      R_ed3 = 0.12186*educ3;
      R_ed2 = 0.31384*educ2;
      R_ed1 = 0.13703*educ1;
      R_hh2 = -0.07226*health2;
      R_hh3 = 0.09785*health3;
      R_hh4 = 0.18702*health4;
      R_hh5 = 0.63835*health5;
      end;

   else if study="REGARDS" then do;
      R_age = 0.78687*age60;
      R_rac = 2.13064*aa;
      R_agr = -0.29208*age60*aa;
      R_sex = -0.28036*female;
      R_afi = 0.33039*afib_sr;
      R_dbt = 0.31412*diab_sr;
      R_hrx = 0.24689*hyper_sr;
      R_hmi = 0.40563*hxmi_sr;
      R_smk = 0.51806*currsmk;
      R_ed3 = 0.12186*educ3;
      R_ed2 = 0.31384*educ2;
      R_ed1 = 0.13703*educ1;
      R_hh2 = -0.07226*health2;
      R_hh3 = 0.09785*health3;
      R_hh4 = 0.18702*health4;
      R_hh5 = 0.63835*health5;
      end;

run;

* Race/Sex Specific Imputation == All Models Together == ;
* Impute with Race/Sex/Cohort Specific Mean;
proc means data=all nway noprint;
   class race_c sex cohort;
   var F_age_w F_smk_w F_cvd_w F_afi_w F_a65_w
       F_ald_w F_agd_w F_hrx_w F_sb1_w F_sb2_w
       F_age_m F_smk_m F_cvd_m F_afi_m F_a65_m
       F_ald_m F_agd_m F_hrx_m F_sb1_m F_sb2_m
       G_age_ww G_ag2_ww G_chl_ww G_ach_ww G_hdl_ww
       G_ahd_ww G_sb1_ww G_sb2_ww G_smk_ww G_asm_ww
       G_dbt_ww G_age_bw G_chl_bw G_hdl_bw G_ahd_bw
       G_sb1_bw G_sb2_bw G_sh1_bw G_sh2_bw G_smk_bw
       G_dbt_bw G_age_wm G_chl_wm G_ach_wm G_hdl_wm
       G_ahd_wm G_sb1_wm G_sb2_wm G_smk_wm G_asm_wm
       G_dbt_wm G_age_bm G_chl_bm G_hdl_bm G_sb1_bm
       G_sb2_bm G_smk_bm G_dbt_bm
       R_age R_rac R_agr R_sex R_afi
       R_dbt R_hrx R_hmi R_smk R_ed3
       R_ed2 R_ed1 R_hh2 R_hh3 R_hh4
       R_hh5;
   output out=means_race_sex mean= / autoname;
run;

proc sort data=all;
   by race_c sex cohort;
run;

proc sort data=means_race_sex;
   by race_c sex cohort;
run;

data imputed_sex;
   merge all
         means_race_sex(drop=_type_ _freq_);
   by race_c sex cohort;

   * Imputing FSRP;
   array F_wom[10] F_age_w F_smk_w F_cvd_w F_afi_w F_a65_w
                   F_ald_w F_agd_w F_hrx_w F_sb1_w F_sb2_w;

   array F_wom_avg[10] F_age_w_Mean F_smk_w_Mean F_cvd_w_Mean F_afi_w_Mean F_a65_w_Mean
                       F_ald_w_Mean F_agd_w_Mean F_hrx_w_Mean F_sb1_w_Mean F_sb2_w_Mean;

   array F_men[10] F_age_m F_smk_m F_cvd_m F_afi_m F_a65_m
                   F_ald_m F_agd_m F_hrx_m F_sb1_m F_sb2_m;

   array F_men_avg[10] F_age_m_Mean F_smk_m_Mean F_cvd_m_Mean F_afi_m_Mean F_a65_m_Mean
                       F_ald_m_Mean F_agd_m_Mean F_hrx_m_Mean F_sb1_m_Mean F_sb2_m_Mean;

   do i = 1 to 10;
      if sex=1 & F_men[i] = . then F_men[i]=F_men_avg[i];
      else if sex=2 & F_wom[i] = . then F_wom[i]=F_wom_avg[i];
      end;

   if sex=1 then F_men_s = F_age_m + F_smk_m + F_cvd_m + F_afi_m + F_a65_m +
                           F_ald_m + F_agd_m + F_hrx_m + F_sb1_m + F_sb2_m;

   else if sex=2 then F_wom_s = F_age_w + F_smk_w + F_cvd_w + F_afi_w + F_a65_w +
                                F_ald_w + F_agd_w + F_hrx_w + F_sb1_w + F_sb2_w;

   if sex=1 then fsrp10_s = 1 - (0.94451)**exp(F_men_s - 4.4227101);
   else if sex=2 then fsrp10_s = 1 - (0.95911)**exp(F_wom_s - 6.6170719);

   * Imputing ASCVD;
   array G_wwom[11] G_age_ww G_ag2_ww G_chl_ww G_ach_ww G_hdl_ww
                    G_ahd_ww G_sb1_ww G_sb2_ww G_smk_ww G_asm_ww
                    G_dbt_ww;

   array G_wwom_avg[11] G_age_ww_Mean G_ag2_ww_Mean G_chl_ww_Mean G_ach_ww_Mean G_hdl_ww_Mean
                        G_ahd_ww_Mean G_sb1_ww_Mean G_sb2_ww_Mean G_smk_ww_Mean G_asm_ww_Mean
                        G_dbt_ww_Mean;

   array G_bwom[10] G_age_bw G_chl_bw G_hdl_bw G_ahd_bw G_sb1_bw
                    G_sb2_bw G_sh1_bw G_sh2_bw G_smk_bw G_dbt_bw;

   array G_bwom_avg[10] G_age_bw_Mean G_chl_bw_Mean G_hdl_bw_Mean G_ahd_bw_Mean G_sb1_bw_Mean
                        G_sb2_bw_Mean G_sh1_bw_Mean G_sh2_bw_Mean G_smk_bw_Mean G_dbt_bw_Mean;

   array G_wmen[10] G_age_wm G_chl_wm G_ach_wm G_hdl_wm G_ahd_wm
                    G_sb1_wm G_sb2_wm G_smk_wm G_asm_wm G_dbt_wm;

   array G_wmen_avg[10] G_age_wm_Mean G_chl_wm_Mean G_ach_wm_Mean G_hdl_wm_Mean G_ahd_wm_Mean
                        G_sb1_wm_Mean G_sb2_wm_Mean G_smk_wm_Mean G_asm_wm_Mean G_dbt_wm_Mean;

   array G_bmen[7] G_age_bm G_chl_bm G_hdl_bm G_sb1_bm G_sb2_bm
                   G_smk_bm G_dbt_bm;

   array G_bmen_avg[7] G_age_bm_Mean G_chl_bm_Mean G_hdl_bm_Mean G_sb1_bm_Mean G_sb2_bm_Mean
                       G_smk_bm_Mean G_dbt_bm_Mean;

   if sex=2 & aa=0 then do;
      do i = 1 to 11;
         if G_wwom[i] = . then G_wwom[i] = G_wwom_avg[i];
         end;

      G_wwom_s = G_age_ww + G_ag2_ww + G_chl_ww + G_ach_ww + G_hdl_ww +
                 G_ahd_ww + G_sb1_ww + G_sb2_ww + G_smk_ww + G_asm_ww +
                 G_dbt_ww;
      ascvd10_s = (1 - (0.9665**exp(G_wwom_s + 29.18)));
      end;

   else if sex=2 & aa=1 then do;
      do i = 1 to 10;
         if G_bwom[i] = . then G_bwom[i] = G_bwom_avg[i];
         end;
      G_bwom_s = G_age_bw + G_chl_bw + G_hdl_bw + G_ahd_bw + G_sb1_bw +
                 G_sb2_bw + G_sh1_bw + G_sh2_bw + G_smk_bw + G_dbt_bw;
      ascvd10_s = (1 - (0.9533**exp(G_bwom_s - 86.61)));
      end;

   else if sex=1 & aa=0 then do;
      do i = 1 to 10;
         if G_wmen[i] = . then G_wmen[i] = G_wmen_avg[i];
         end;
      G_wmen_s = G_age_wm + G_chl_wm + G_ach_wm + G_hdl_wm + G_ahd_wm +
                 G_sb1_wm + G_sb2_wm + G_smk_wm + G_asm_wm + G_dbt_wm;
      ascvd10_s = (1 - (0.9144**exp(G_wmen_s - 61.18)));
      end;

   else if sex=1 & aa=1 then do;
      do i = 1 to 7;
         if G_bmen[i] = . then G_bmen[i] = G_bmen_avg[i];
         end;
      G_bmen_s = G_age_bm + G_chl_bm + G_hdl_bm + G_sb1_bm + G_sb2_bm +
                 G_smk_bm + G_dbt_bm;
      ascvd10_s = (1 - (0.8954**exp(G_bmen_s - 19.54)));
      end;

   * Imputing REGARDS;
   array Reg[16] R_age R_rac R_agr R_sex R_afi R_dbt R_hrx R_hmi R_smk R_ed3
                 R_ed2 R_ed1 R_hh2 R_hh3 R_hh4 R_hh5;

   array Reg_avg[16] R_age_Mean R_rac_Mean R_agr_Mean R_sex_Mean R_afi_Mean R_dbt_Mean R_hrx_Mean R_hmi_Mean
                     R_smk_Mean R_ed3_Mean R_ed2_Mean R_ed1_Mean R_hh2_Mean R_hh3_Mean R_hh4_Mean R_hh5_Mean;

   do i = 1 to 16;
      if Reg[i] = . then Reg[i]=Reg_avg[i];
      end;

   Re = R_age + R_rac + R_agr + R_sex + R_afi + R_dbt + R_hrx + R_hmi +
        R_smk + R_ed3 + R_ed2 + R_ed1 + R_hh2 + R_hh3 + R_hh4 + R_hh5;

   regs10_s = 1 - (0.99985)**exp(Re);

   keep usubjid study cohort sex race_c fsrp10_s ascvd10_s regs10_s stroke10 t2stroke t2stroke10_yrs;
run;

* Race/Age Group Specific Imputation == All Models Together == ;
* Impute with Race/Age Group/Cohort Specific Mean;
proc means data=all nway noprint;
   class race_c agegrp cohort;
   var F_age_w F_smk_w F_cvd_w F_afi_w F_a65_w
       F_ald_w F_agd_w F_hrx_w F_sb1_w F_sb2_w
       F_age_m F_smk_m F_cvd_m F_afi_m F_a65_m
       F_ald_m F_agd_m F_hrx_m F_sb1_m F_sb2_m
       G_age_ww G_ag2_ww G_chl_ww G_ach_ww G_hdl_ww
       G_ahd_ww G_sb1_ww G_sb2_ww G_smk_ww G_asm_ww
       G_dbt_ww G_age_bw G_chl_bw G_hdl_bw G_ahd_bw
       G_sb1_bw G_sb2_bw G_sh1_bw G_sh2_bw G_smk_bw
       G_dbt_bw G_age_wm G_chl_wm G_ach_wm G_hdl_wm
       G_ahd_wm G_sb1_wm G_sb2_wm G_smk_wm G_asm_wm
       G_dbt_wm G_age_bm G_chl_bm G_hdl_bm G_sb1_bm
       G_sb2_bm G_smk_bm G_dbt_bm
       R_age R_rac R_agr R_sex R_afi
       R_dbt R_hrx R_hmi R_smk R_ed3
       R_ed2 R_ed1 R_hh2 R_hh3 R_hh4
       R_hh5;
   output out=means_race_age mean= / autoname;
run;

proc sort data=all;
   by race_c agegrp cohort;
run;

proc sort data=means_race_age;
   by race_c agegrp cohort;
run;

data imputed_age;
   merge all
         means_race_age(drop=_type_ _freq_);
   by race_c agegrp cohort;

   * Imputing FSRP;
   array F_wom[10] F_age_w F_smk_w F_cvd_w F_afi_w F_a65_w
                   F_ald_w F_agd_w F_hrx_w F_sb1_w F_sb2_w;

   array F_wom_avg[10] F_age_w_Mean F_smk_w_Mean F_cvd_w_Mean F_afi_w_Mean F_a65_w_Mean
                       F_ald_w_Mean F_agd_w_Mean F_hrx_w_Mean F_sb1_w_Mean F_sb2_w_Mean;

   array F_men[10] F_age_m F_smk_m F_cvd_m F_afi_m F_a65_m
                   F_ald_m F_agd_m F_hrx_m F_sb1_m F_sb2_m;

   array F_men_avg[10] F_age_m_Mean F_smk_m_Mean F_cvd_m_Mean F_afi_m_Mean F_a65_m_Mean
                       F_ald_m_Mean F_agd_m_Mean F_hrx_m_Mean F_sb1_m_Mean F_sb2_m_Mean;

   do i = 1 to 10;
      if sex=1 & F_men[i] = . then F_men[i]=F_men_avg[i];
      else if sex=2 & F_wom[i] = . then F_wom[i]=F_wom_avg[i];
      end;

   if sex=1 then F_men_a = F_age_m + F_smk_m + F_cvd_m + F_afi_m + F_a65_m +
                           F_ald_m + F_agd_m + F_hrx_m + F_sb1_m + F_sb2_m;

   else if sex=2 then F_wom_a = F_age_w + F_smk_w + F_cvd_w + F_afi_w + F_a65_w +
                                F_ald_w + F_agd_w + F_hrx_w + F_sb1_w + F_sb2_w;

   if sex=1 then fsrp10_a = 1 - (0.94451)**exp(F_men_a - 4.4227101);
   else if sex=2 then fsrp10_a = 1 - (0.95911)**exp(F_wom_a - 6.6170719);

   * Imputing ASCVD;
   array G_wwom[11] G_age_ww G_ag2_ww G_chl_ww G_ach_ww G_hdl_ww
                    G_ahd_ww G_sb1_ww G_sb2_ww G_smk_ww G_asm_ww
                    G_dbt_ww;

   array G_wwom_avg[11] G_age_ww_Mean G_ag2_ww_Mean G_chl_ww_Mean G_ach_ww_Mean G_hdl_ww_Mean
                        G_ahd_ww_Mean G_sb1_ww_Mean G_sb2_ww_Mean G_smk_ww_Mean G_asm_ww_Mean
                        G_dbt_ww_Mean;

   array G_bwom[10] G_age_bw G_chl_bw G_hdl_bw G_ahd_bw G_sb1_bw
                    G_sb2_bw G_sh1_bw G_sh2_bw G_smk_bw G_dbt_bw;

   array G_bwom_avg[10] G_age_bw_Mean G_chl_bw_Mean G_hdl_bw_Mean G_ahd_bw_Mean G_sb1_bw_Mean
                        G_sb2_bw_Mean G_sh1_bw_Mean G_sh2_bw_Mean G_smk_bw_Mean G_dbt_bw_Mean;

   array G_wmen[10] G_age_wm G_chl_wm G_ach_wm G_hdl_wm G_ahd_wm
                    G_sb1_wm G_sb2_wm G_smk_wm G_asm_wm G_dbt_wm;

   array G_wmen_avg[10] G_age_wm_Mean G_chl_wm_Mean G_ach_wm_Mean G_hdl_wm_Mean G_ahd_wm_Mean
                        G_sb1_wm_Mean G_sb2_wm_Mean G_smk_wm_Mean G_asm_wm_Mean G_dbt_wm_Mean;

   array G_bmen[7] G_age_bm G_chl_bm G_hdl_bm G_sb1_bm G_sb2_bm
                   G_smk_bm G_dbt_bm;

   array G_bmen_avg[7] G_age_bm_Mean G_chl_bm_Mean G_hdl_bm_Mean G_sb1_bm_Mean G_sb2_bm_Mean
                       G_smk_bm_Mean G_dbt_bm_Mean;

   if sex=2 & aa=0 then do;
      do i = 1 to 11;
         if G_wwom[i] = . then G_wwom[i] = G_wwom_avg[i];
         end;

      G_wwom_a = G_age_ww + G_ag2_ww + G_chl_ww + G_ach_ww + G_hdl_ww +
                 G_ahd_ww + G_sb1_ww + G_sb2_ww + G_smk_ww + G_asm_ww +
                 G_dbt_ww;
      ascvd10_a = (1 - (0.9665**exp(G_wwom_a + 29.18)));
      end;

   else if sex=2 & aa=1 then do;
      do i = 1 to 10;
         if G_bwom[i] = . then G_bwom[i] = G_bwom_avg[i];
         end;
      G_bwom_a = G_age_bw + G_chl_bw + G_hdl_bw + G_ahd_bw + G_sb1_bw +
                 G_sb2_bw + G_sh1_bw + G_sh2_bw + G_smk_bw + G_dbt_bw;
      ascvd10_a = (1 - (0.9533**exp(G_bwom_a - 86.61)));
      end;

   else if sex=1 & aa=0 then do;
      do i = 1 to 10;
         if G_wmen[i] = . then G_wmen[i] = G_wmen_avg[i];
         end;
      G_wmen_a = G_age_wm + G_chl_wm + G_ach_wm + G_hdl_wm + G_ahd_wm +
                 G_sb1_wm + G_sb2_wm + G_smk_wm + G_asm_wm + G_dbt_wm;
      ascvd10_a = (1 - (0.9144**exp(G_wmen_a - 61.18)));
      end;

   else if sex=1 & aa=1 then do;
      do i = 1 to 7;
         if G_bmen[i] = . then G_bmen[i] = G_bmen_avg[i];
         end;
      G_bmen_a = G_age_bm + G_chl_bm + G_hdl_bm + G_sb1_bm + G_sb2_bm +
                 G_smk_bm + G_dbt_bm;
      ascvd10_a = (1 - (0.8954**exp(G_bmen_a - 19.54)));
      end;

   * Imputing REGARDS;
   array Reg[16] R_age R_rac R_agr R_sex R_afi R_dbt R_hrx R_hmi R_smk R_ed3
                 R_ed2 R_ed1 R_hh2 R_hh3 R_hh4 R_hh5;

   array Reg_avg[16] R_age_Mean R_rac_Mean R_agr_Mean R_sex_Mean R_afi_Mean R_dbt_Mean R_hrx_Mean R_hmi_Mean
                     R_smk_Mean R_ed3_Mean R_ed2_Mean R_ed1_Mean R_hh2_Mean R_hh3_Mean R_hh4_Mean R_hh5_Mean;

   do i = 1 to 16;
      if Reg[i] = . then Reg[i]=Reg_avg[i];
      end;

   Re = R_age + R_rac + R_agr + R_sex + R_afi + R_dbt + R_hrx + R_hmi +
        R_smk + R_ed3 + R_ed2 + R_ed1 + R_hh2 + R_hh3 + R_hh4 + R_hh5;

   regs10_a = 1 - (0.99985)**exp(Re);

   keep usubjid race_c agegrp fsrp10_a ascvd10_a regs10_a;
run;

* Cohort Specific Imputation == All Models Together == ;
* Impute with Cohort Specific Mean;
proc means data=all nway noprint;
   class cohort;
   var F_age_w F_smk_w F_cvd_w F_afi_w F_a65_w
       F_ald_w F_agd_w F_hrx_w F_sb1_w F_sb2_w
       F_age_m F_smk_m F_cvd_m F_afi_m F_a65_m
       F_ald_m F_agd_m F_hrx_m F_sb1_m F_sb2_m
       G_age_ww G_ag2_ww G_chl_ww G_ach_ww G_hdl_ww
       G_ahd_ww G_sb1_ww G_sb2_ww G_smk_ww G_asm_ww
       G_dbt_ww G_age_bw G_chl_bw G_hdl_bw G_ahd_bw
       G_sb1_bw G_sb2_bw G_sh1_bw G_sh2_bw G_smk_bw
       G_dbt_bw G_age_wm G_chl_wm G_ach_wm G_hdl_wm
       G_ahd_wm G_sb1_wm G_sb2_wm G_smk_wm G_asm_wm
       G_dbt_wm G_age_bm G_chl_bm G_hdl_bm G_sb1_bm
       G_sb2_bm G_smk_bm G_dbt_bm
       R_age R_rac R_agr R_sex R_afi
       R_dbt R_hrx R_hmi R_smk R_ed3
       R_ed2 R_ed1 R_hh2 R_hh3 R_hh4
       R_hh5;
   output out=means_cohort mean= / autoname;
run;

proc sort data=all;
   by cohort;
run;

proc sort data=means_cohort;
   by cohort;
run;

data imputed_cohort;
   merge all
         means_cohort(drop=_type_ _freq_);
   by cohort;

   * Imputing FSRP;
   array F_wom[10] F_age_w F_smk_w F_cvd_w F_afi_w F_a65_w
                   F_ald_w F_agd_w F_hrx_w F_sb1_w F_sb2_w;

   array F_wom_avg[10] F_age_w_Mean F_smk_w_Mean F_cvd_w_Mean F_afi_w_Mean F_a65_w_Mean
                       F_ald_w_Mean F_agd_w_Mean F_hrx_w_Mean F_sb1_w_Mean F_sb2_w_Mean;

   array F_men[10] F_age_m F_smk_m F_cvd_m F_afi_m F_a65_m
                   F_ald_m F_agd_m F_hrx_m F_sb1_m F_sb2_m;

   array F_men_avg[10] F_age_m_Mean F_smk_m_Mean F_cvd_m_Mean F_afi_m_Mean F_a65_m_Mean
                       F_ald_m_Mean F_agd_m_Mean F_hrx_m_Mean F_sb1_m_Mean F_sb2_m_Mean;

   do i = 1 to 10;
      if sex=1 & F_men[i] = . then F_men[i]=F_men_avg[i];
      else if sex=2 & F_wom[i] = . then F_wom[i]=F_wom_avg[i];
      end;

   if sex=1 then F_men_c = F_age_m + F_smk_m + F_cvd_m + F_afi_m + F_a65_m +
                           F_ald_m + F_agd_m + F_hrx_m + F_sb1_m + F_sb2_m;

   else if sex=2 then F_wom_c = F_age_w + F_smk_w + F_cvd_w + F_afi_w + F_a65_w +
                                F_ald_w + F_agd_w + F_hrx_w + F_sb1_w + F_sb2_w;

   if sex=1 then fsrp10_c = 1 - (0.94451)**exp(F_men_c - 4.4227101);
   else if sex=2 then fsrp10_c = 1 - (0.95911)**exp(F_wom_c - 6.6170719);

   * Imputing ASCVD;
   array G_wwom[11] G_age_ww G_ag2_ww G_chl_ww G_ach_ww G_hdl_ww
                    G_ahd_ww G_sb1_ww G_sb2_ww G_smk_ww G_asm_ww
                    G_dbt_ww;

   array G_wwom_avg[11] G_age_ww_Mean G_ag2_ww_Mean G_chl_ww_Mean G_ach_ww_Mean G_hdl_ww_Mean
                        G_ahd_ww_Mean G_sb1_ww_Mean G_sb2_ww_Mean G_smk_ww_Mean G_asm_ww_Mean
                        G_dbt_ww_Mean;

   array G_bwom[10] G_age_bw G_chl_bw G_hdl_bw G_ahd_bw G_sb1_bw
                    G_sb2_bw G_sh1_bw G_sh2_bw G_smk_bw G_dbt_bw;

   array G_bwom_avg[10] G_age_bw_Mean G_chl_bw_Mean G_hdl_bw_Mean G_ahd_bw_Mean G_sb1_bw_Mean
                        G_sb2_bw_Mean G_sh1_bw_Mean G_sh2_bw_Mean G_smk_bw_Mean G_dbt_bw_Mean;

   array G_wmen[10] G_age_wm G_chl_wm G_ach_wm G_hdl_wm G_ahd_wm
                    G_sb1_wm G_sb2_wm G_smk_wm G_asm_wm G_dbt_wm;

   array G_wmen_avg[10] G_age_wm_Mean G_chl_wm_Mean G_ach_wm_Mean G_hdl_wm_Mean G_ahd_wm_Mean
                        G_sb1_wm_Mean G_sb2_wm_Mean G_smk_wm_Mean G_asm_wm_Mean G_dbt_wm_Mean;

   array G_bmen[7] G_age_bm G_chl_bm G_hdl_bm G_sb1_bm G_sb2_bm
                   G_smk_bm G_dbt_bm;

   array G_bmen_avg[7] G_age_bm_Mean G_chl_bm_Mean G_hdl_bm_Mean G_sb1_bm_Mean G_sb2_bm_Mean
                       G_smk_bm_Mean G_dbt_bm_Mean;

   if sex=2 & aa=0 then do;
      do i = 1 to 11;
         if G_wwom[i] = . then G_wwom[i] = G_wwom_avg[i];
         end;

      G_wwom_c = G_age_ww + G_ag2_ww + G_chl_ww + G_ach_ww + G_hdl_ww +
                 G_ahd_ww + G_sb1_ww + G_sb2_ww + G_smk_ww + G_asm_ww +
                 G_dbt_ww;
      ascvd10_c = (1 - (0.9665**exp(G_wwom_c + 29.18)));
      end;

   else if sex=2 & aa=1 then do;
      do i = 1 to 10;
         if G_bwom[i] = . then G_bwom[i] = G_bwom_avg[i];
         end;
      G_bwom_c = G_age_bw + G_chl_bw + G_hdl_bw + G_ahd_bw + G_sb1_bw +
                 G_sb2_bw + G_sh1_bw + G_sh2_bw + G_smk_bw + G_dbt_bw;
      ascvd10_c = (1 - (0.9533**exp(G_bwom_c - 86.61)));
      end;

   else if sex=1 & aa=0 then do;
      do i = 1 to 10;
         if G_wmen[i] = . then G_wmen[i] = G_wmen_avg[i];
         end;
      G_wmen_c = G_age_wm + G_chl_wm + G_ach_wm + G_hdl_wm + G_ahd_wm +
                 G_sb1_wm + G_sb2_wm + G_smk_wm + G_asm_wm + G_dbt_wm;
      ascvd10_c = (1 - (0.9144**exp(G_wmen_c - 61.18)));
      end;

   else if sex=1 & aa=1 then do;
      do i = 1 to 7;
         if G_bmen[i] = . then G_bmen[i] = G_bmen_avg[i];
         end;
      G_bmen_c = G_age_bm + G_chl_bm + G_hdl_bm + G_sb1_bm + G_sb2_bm +
                 G_smk_bm + G_dbt_bm;
      ascvd10_c = (1 - (0.8954**exp(G_bmen_c - 19.54)));
      end;

   * Imputing REGARDS;
   array Reg[16] R_age R_rac R_agr R_sex R_afi R_dbt R_hrx R_hmi R_smk R_ed3
                 R_ed2 R_ed1 R_hh2 R_hh3 R_hh4 R_hh5;

   array Reg_avg[16] R_age_Mean R_rac_Mean R_agr_Mean R_sex_Mean R_afi_Mean R_dbt_Mean R_hrx_Mean R_hmi_Mean
                     R_smk_Mean R_ed3_Mean R_ed2_Mean R_ed1_Mean R_hh2_Mean R_hh3_Mean R_hh4_Mean R_hh5_Mean;

   do i = 1 to 16;
      if Reg[i] = . then Reg[i]=Reg_avg[i];
      end;

   Re = R_age + R_rac + R_agr + R_sex + R_afi + R_dbt + R_hrx + R_hmi +
        R_smk + R_ed3 + R_ed2 + R_ed1 + R_hh2 + R_hh3 + R_hh4 + R_hh5;

   regs10_c = 1 - (0.99985)**exp(Re);

   keep usubjid fsrp10_c ascvd10_c regs10_c;
run;

proc sort data=imputed_sex;
   by usubjid;
run;

proc sort data=imputed_age;
   by usubjid;
run;

proc sort data=imputed_cohort;
   by usubjid;
run;

data everything2;
   merge imputed_sex
         imputed_age
         imputed_cohort;
   by usubjid;

   * Applying correction factors;
	if sex=2 then do;
		if race_c="Black" then do;
			ascvd10_s = 0.57116*ascvd10_s;
			ascvd10_a = 0.57116*ascvd10_a;
			ascvd10_c = 0.57116*ascvd10_c;
		   end;
      else if race_c="White" then do;
			ascvd10_s = 0.47437*ascvd10_s;
			ascvd10_a = 0.47437*ascvd10_a;
			ascvd10_c = 0.47437*ascvd10_c;
		   end;
		end;

	if sex=1 then do;
		if race_c="Black" then do;
			ascvd10_s = 0.43108*ascvd10_s;
			ascvd10_a = 0.43108*ascvd10_a;
			ascvd10_c = 0.43108*ascvd10_c;
		   end;
      else if race_c="White" then do;
			ascvd10_s = 0.29985*ascvd10_s;
			ascvd10_a = 0.29985*ascvd10_a;
			ascvd10_c = 0.29985*ascvd10_c;
		   end;
		end;

run;

* Observed/Expected for Supplementary Table 1 == ARIC;
%obsexp(everything2,%str(race_c="Black" & sex=2 & study="ARIC"),fsrp10_s,oe_bwa_m1);
%obsexp(everything2,%str(race_c="Black" & sex=2 & study="ARIC"),ascvd10_s,oe_bwa_m2);
%obsexp(everything2,%str(race_c="Black" & sex=2 & study="ARIC"),regs10_s,oe_bwa_m3);

%obsexp(everything2,%str(race_c="Black" & sex=1 & study="ARIC"),fsrp10_s,oe_bma_m1);
%obsexp(everything2,%str(race_c="Black" & sex=1 & study="ARIC"),ascvd10_s,oe_bma_m2);
%obsexp(everything2,%str(race_c="Black" & sex=1 & study="ARIC"),regs10_s,oe_bma_m3);

%obsexp(everything2,%str(race_c="White" & sex=2 & study="ARIC"),fsrp10_s,oe_wwa_m1);
%obsexp(everything2,%str(race_c="White" & sex=2 & study="ARIC"),ascvd10_s,oe_wwa_m2);
%obsexp(everything2,%str(race_c="White" & sex=2 & study="ARIC"),regs10_s,oe_wwa_m3);

%obsexp(everything2,%str(race_c="White" & sex=1 & study="ARIC"),fsrp10_s,oe_wma_m1);
%obsexp(everything2,%str(race_c="White" & sex=1 & study="ARIC"),ascvd10_s,oe_wma_m2);
%obsexp(everything2,%str(race_c="White" & sex=1 & study="ARIC"),regs10_s,oe_wma_m3);

%obsexp(everything2,%str(study="ARIC"),fsrp10_c,oe_oa_m1);
%obsexp(everything2,%str(study="ARIC"),ascvd10_c,oe_oa_m2);
%obsexp(everything2,%str(study="ARIC"),regs10_c,oe_oa_m3);

* Observed/Expected for Supplementary Table 1 == MESA;
%obsexp(everything2,%str(race_c="Black" & sex=2 & study="MESA"),fsrp10_s,oe_bwm_m1);
%obsexp(everything2,%str(race_c="Black" & sex=2 & study="MESA"),ascvd10_s,oe_bwm_m2);
%obsexp(everything2,%str(race_c="Black" & sex=2 & study="MESA"),regs10_s,oe_bwm_m3);

%obsexp(everything2,%str(race_c="Black" & sex=1 & study="MESA"),fsrp10_s,oe_bmm_m1);
%obsexp(everything2,%str(race_c="Black" & sex=1 & study="MESA"),ascvd10_s,oe_bmm_m2);
%obsexp(everything2,%str(race_c="Black" & sex=1 & study="MESA"),regs10_s,oe_bmm_m3);

%obsexp(everything2,%str(race_c="White" & sex=2 & study="MESA"),fsrp10_s,oe_wwm_m1);
%obsexp(everything2,%str(race_c="White" & sex=2 & study="MESA"),ascvd10_s,oe_wwm_m2);
%obsexp(everything2,%str(race_c="White" & sex=2 & study="MESA"),regs10_s,oe_wwm_m3);

%obsexp(everything2,%str(race_c="White" & sex=1 & study="MESA"),fsrp10_s,oe_wmm_m1);
%obsexp(everything2,%str(race_c="White" & sex=1 & study="MESA"),ascvd10_s,oe_wmm_m2);
%obsexp(everything2,%str(race_c="White" & sex=1 & study="MESA"),regs10_s,oe_wmm_m3);

%obsexp(everything2,%str(study="MESA"),fsrp10_c,oe_om_m1);
%obsexp(everything2,%str(study="MESA"),ascvd10_c,oe_om_m2);
%obsexp(everything2,%str(study="MESA"),regs10_c,oe_om_m3);

* Observed/Expected for Supplementary Table 1 == REGARDS;
%obsexp(everything2,%str(race_c="Black" & sex=2 & study="REGARDS"),fsrp10_s,oe_bwr_m1);
%obsexp(everything2,%str(race_c="Black" & sex=2 & study="REGARDS"),ascvd10_s,oe_bwr_m2);
%obsexp(everything2,%str(race_c="Black" & sex=2 & study="REGARDS"),regs10_s,oe_bwr_m3);

%obsexp(everything2,%str(race_c="Black" & sex=1 & study="REGARDS"),fsrp10_s,oe_bmr_m1);
%obsexp(everything2,%str(race_c="Black" & sex=1 & study="REGARDS"),ascvd10_s,oe_bmr_m2);
%obsexp(everything2,%str(race_c="Black" & sex=1 & study="REGARDS"),regs10_s,oe_bmr_m3);

%obsexp(everything2,%str(race_c="White" & sex=2 & study="REGARDS"),fsrp10_s,oe_wwr_m1);
%obsexp(everything2,%str(race_c="White" & sex=2 & study="REGARDS"),ascvd10_s,oe_wwr_m2);
%obsexp(everything2,%str(race_c="White" & sex=2 & study="REGARDS"),regs10_s,oe_wwr_m3);

%obsexp(everything2,%str(race_c="White" & sex=1 & study="REGARDS"),fsrp10_s,oe_wmr_m1);
%obsexp(everything2,%str(race_c="White" & sex=1 & study="REGARDS"),ascvd10_s,oe_wmr_m2);
%obsexp(everything2,%str(race_c="White" & sex=1 & study="REGARDS"),regs10_s,oe_wmr_m3);

%obsexp(everything2,%str(study="REGARDS"),fsrp10_c,oe_or_m1);
%obsexp(everything2,%str(study="REGARDS"),ascvd10_c,oe_or_m2);
%obsexp(everything2,%str(study="REGARDS"),regs10_c,oe_or_m3);

* Observed/Expected for Supplementary Table 1 == OFFSPRING;
%obsexp(everything2,%str(race_c="White" & sex=2 & study="OFFSPRING"),fsrp10_s,oe_wwo_m1);
%obsexp(everything2,%str(race_c="White" & sex=2 & study="OFFSPRING"),ascvd10_s,oe_wwo_m2);
%obsexp(everything2,%str(race_c="White" & sex=2 & study="OFFSPRING"),regs10_s,oe_wwo_m3);

%obsexp(everything2,%str(race_c="White" & sex=1 & study="OFFSPRING"),fsrp10_s,oe_wmo_m1);
%obsexp(everything2,%str(race_c="White" & sex=1 & study="OFFSPRING"),ascvd10_s,oe_wmo_m2);
%obsexp(everything2,%str(race_c="White" & sex=1 & study="OFFSPRING"),regs10_s,oe_wmo_m3);

%obsexp(everything2,%str(study="OFFSPRING"),fsrp10_c,oe_oo_m1);
%obsexp(everything2,%str(study="OFFSPRING"),ascvd10_c,oe_oo_m2);
%obsexp(everything2,%str(study="OFFSPRING"),regs10_c,oe_oo_m3);

* Observed/Expected for Supplementary Table 1 == Overall;
%obsexp(everything2,%str(race_c="Black" & sex=2),fsrp10_s,oe_bw_m1);
%obsexp(everything2,%str(race_c="Black" & sex=2),ascvd10_s,oe_bw_m2);
%obsexp(everything2,%str(race_c="Black" & sex=2),regs10_s,oe_bw_m3);

%obsexp(everything2,%str(race_c="Black" & sex=1),fsrp10_s,oe_bm_m1);
%obsexp(everything2,%str(race_c="Black" & sex=1),ascvd10_s,oe_bm_m2);
%obsexp(everything2,%str(race_c="Black" & sex=1),regs10_s,oe_bm_m3);

%obsexp(everything2,%str(race_c="White" & sex=2),fsrp10_s,oe_ww_m1);
%obsexp(everything2,%str(race_c="White" & sex=2),ascvd10_s,oe_ww_m2);
%obsexp(everything2,%str(race_c="White" & sex=2),regs10_s,oe_ww_m3);

%obsexp(everything2,%str(race_c="White" & sex=1),fsrp10_s,oe_wm_m1);
%obsexp(everything2,%str(race_c="White" & sex=1),ascvd10_s,oe_wm_m2);
%obsexp(everything2,%str(race_c="White" & sex=1),regs10_s,oe_wm_m3);

%obsexp(everything2,%str(study ^= ""),fsrp10_c,oe_o_m1);
%obsexp(everything2,%str(study ^= ""),ascvd10_c,oe_o_m2);
%obsexp(everything2,%str(study ^= ""),regs10_c,oe_o_m3);

data blank;
   attrib result length=$30.;
   result="";
run;

data t1_aric_obsexp;
   set oe_bwa_m1-oe_bwa_m3
       blank
       oe_bma_m1-oe_bma_m3
       blank
       oe_wwa_m1-oe_wwa_m3
       blank
       oe_wma_m1-oe_wma_m3
       blank
       oe_oa_m1-oe_oa_m3;

   retain row 0;
   row + 1;

   rename obs_risk=obs_risk_aric exp_risk=exp_risk_aric;
run;

data t1_mesa_obsexp;
   set oe_bwm_m1-oe_bwm_m3
       blank
       oe_bmm_m1-oe_bmm_m3
       blank
       oe_wwm_m1-oe_wwm_m3
       blank
       oe_wmm_m1-oe_wmm_m3
       blank
       oe_om_m1-oe_om_m3;

   retain row 0;
   row + 1;

   rename obs_risk=obs_risk_mesa exp_risk=exp_risk_mesa;
run;

data t1_regs_obsexp;
   set oe_bwr_m1-oe_bwr_m3
       blank
       oe_bmr_m1-oe_bmr_m3
       blank
       oe_wwr_m1-oe_wwr_m3
       blank
       oe_wmr_m1-oe_wmr_m3
       blank
       oe_or_m1-oe_or_m3;

   retain row 0;
   row + 1;

   rename obs_risk=obs_risk_regs exp_risk=exp_risk_regs;
run;

data t1_off_obsexp;
   set oe_wwo_m1-oe_wwo_m3
       blank
       oe_wmo_m1-oe_wmo_m3
       blank
       oe_oo_m1-oe_oo_m3;

   retain row 8;
   row + 1;
   rename obs_risk=obs_risk_offs exp_risk=exp_risk_offs;
run;

data t1_overall_obsexp;
   set oe_bw_m1-oe_bw_m3
       blank
       oe_bm_m1-oe_bm_m3
       blank
       oe_ww_m1-oe_ww_m3
       blank
       oe_wm_m1-oe_wm_m3
       blank
       oe_o_m1-oe_o_m3;

   retain row 0;
   row + 1;

   rename obs_risk=obs_risk_overall exp_risk=exp_risk_overall;
run;

data t1;
   merge t1_aric_obsexp
         t1_mesa_obsexp
         t1_regs_obsexp
         t1_off_obsexp
         t1_overall_obsexp;
   by row;
run;

data table;
   attrib model length=$10.;
   attrib subgroup length=$40.;
   set t1;

   if row in (1,5,9,13,17) then model="FSRP";
   else if row in (2,6,10,14,18) then model="ASCVD";
   else if row in (3,7,11,15,19) then model="REGARDS";

   if row in (1,2,3) then subgroup="Black Women";
   else if row in (5,6,7) then subgroup="Black Men";
   else if row in (9,10,11) then subgroup="White Women";
   else if row in (13,14,15) then subgroup="White Men";
   else if row in (17,18,19) then subgroup="Overall";
run;

options orientation=landscape nodate nonumber;
ods path sashelp.tmplmst(read) template.tables(read);
ods rtf file = "../manu/validating/output/34_calibration_by_sex_corrected.rtf" bodytitle style=grayborders;
ods listing close;
title "eTable 6a. Calibration metrics for previously developed models: by race + sex (with stroke factor corrections)";
proc report data=table nowd split = '|' missing
   style(report)={just=center}
   style(lines)=header{background=white font_size=10pt
   font_face="Arial" font_weight=bold just=left}
   style(header)=header{background=white font_size=9pt
   font_face="Arial" font_weight=bold }
   style(column)=header{background=white font_size=9pt
   font_face="Arial" font_weight=medium protectspecialchars = off } ;

   columns subgroup model ("Offspring" exp_risk_offs obs_risk_offs) ("ARIC" exp_risk_aric obs_risk_aric)
                          ("MESA" exp_risk_mesa obs_risk_mesa) ("REGARDS" exp_risk_regs obs_risk_regs)
                          ("Overall" exp_risk_overall obs_risk_overall);

   define subgroup / display "Subgroup" style(header)={just=left cellwidth=15%} ;
   define model / display "Model" style(header)={just=left cellwidth=10%};

   define exp_risk_offs /display "Expected" style(column)=[just=center cellwidth=7%];
   define obs_risk_offs /display "Observed" style(column)=[just=center cellwidth=7%];
   define exp_risk_aric /display "Expected" style(column)=[just=center cellwidth=7%];
   define obs_risk_aric /display "Observed" style(column)=[just=center cellwidth=7%];
   define exp_risk_mesa /display "Expected" style(column)=[just=center cellwidth=7%];
   define obs_risk_mesa /display "Observed" style(column)=[just=center cellwidth=7%];
   define exp_risk_regs /display "Expected" style(column)=[just=center cellwidth=7%];
   define obs_risk_regs /display "Observed" style(column)=[just=center cellwidth=7%];
   define exp_risk_overall /display "Expected" style(column)=[just=center cellwidth=7%];
   define obs_risk_overall /display "Observed" style(column)=[just=center cellwidth=7%];

run;
ods rtf close;

* By Age;
* Observed/Expected for Supplementary Table 2 == ARIC;
%obsexp(everything2,%str(race_c="Black" & agegrp=1 & study="ARIC"),fsrp10_a,oe_bya_m1);
%obsexp(everything2,%str(race_c="Black" & agegrp=1 & study="ARIC"),ascvd10_a,oe_bya_m2);
%obsexp(everything2,%str(race_c="Black" & agegrp=1 & study="ARIC"),regs10_a,oe_bya_m3);

%obsexp(everything2,%str(race_c="Black" & agegrp=2 & study="ARIC"),fsrp10_a,oe_boa_m1);
%obsexp(everything2,%str(race_c="Black" & agegrp=2 & study="ARIC"),ascvd10_a,oe_boa_m2);
%obsexp(everything2,%str(race_c="Black" & agegrp=2 & study="ARIC"),regs10_a,oe_boa_m3);

%obsexp(everything2,%str(race_c="White" & agegrp=1 & study="ARIC"),fsrp10_a,oe_wya_m1);
%obsexp(everything2,%str(race_c="White" & agegrp=1 & study="ARIC"),ascvd10_a,oe_wya_m2);
%obsexp(everything2,%str(race_c="White" & agegrp=1 & study="ARIC"),regs10_a,oe_wya_m3);

%obsexp(everything2,%str(race_c="White" & agegrp=2 & study="ARIC"),fsrp10_a,oe_woa_m1);
%obsexp(everything2,%str(race_c="White" & agegrp=2 & study="ARIC"),ascvd10_a,oe_woa_m2);
%obsexp(everything2,%str(race_c="White" & agegrp=2 & study="ARIC"),regs10_a,oe_woa_m3);

%obsexp(everything2,%str(study="ARIC"),fsrp10_c,oe_oa_m1);
%obsexp(everything2,%str(study="ARIC"),ascvd10_c,oe_oa_m2);
%obsexp(everything2,%str(study="ARIC"),regs10_c,oe_oa_m3);

* Observed/Expected for Supplementary Table 1 == MESA;
%obsexp(everything2,%str(race_c="Black" & agegrp=1 & study="MESA"),fsrp10_a,oe_bym_m1);
%obsexp(everything2,%str(race_c="Black" & agegrp=1 & study="MESA"),ascvd10_a,oe_bym_m2);
%obsexp(everything2,%str(race_c="Black" & agegrp=1 & study="MESA"),regs10_a,oe_bym_m3);

%obsexp(everything2,%str(race_c="Black" & agegrp=2 & study="MESA"),fsrp10_a,oe_bom_m1);
%obsexp(everything2,%str(race_c="Black" & agegrp=2 & study="MESA"),ascvd10_a,oe_bom_m2);
%obsexp(everything2,%str(race_c="Black" & agegrp=2 & study="MESA"),regs10_a,oe_bom_m3);

%obsexp(everything2,%str(race_c="White" & agegrp=1 & study="MESA"),fsrp10_a,oe_wym_m1);
%obsexp(everything2,%str(race_c="White" & agegrp=1 & study="MESA"),ascvd10_a,oe_wym_m2);
%obsexp(everything2,%str(race_c="White" & agegrp=1 & study="MESA"),regs10_a,oe_wym_m3);

%obsexp(everything2,%str(race_c="White" & agegrp=2 & study="MESA"),fsrp10_a,oe_wom_m1);
%obsexp(everything2,%str(race_c="White" & agegrp=2 & study="MESA"),ascvd10_a,oe_wom_m2);
%obsexp(everything2,%str(race_c="White" & agegrp=2 & study="MESA"),regs10_a,oe_wom_m3);

%obsexp(everything2,%str(study="MESA"),fsrp10_c,oe_om_m1);
%obsexp(everything2,%str(study="MESA"),ascvd10_c,oe_om_m2);
%obsexp(everything2,%str(study="MESA"),regs10_c,oe_om_m3);

* Observed/Expected for Supplementary Table 1 == REGARDS;
%obsexp(everything2,%str(race_c="Black" & agegrp=1 & study="REGARDS"),fsrp10_a,oe_byr_m1);
%obsexp(everything2,%str(race_c="Black" & agegrp=1 & study="REGARDS"),ascvd10_a,oe_byr_m2);
%obsexp(everything2,%str(race_c="Black" & agegrp=1 & study="REGARDS"),regs10_a,oe_byr_m3);

%obsexp(everything2,%str(race_c="Black" & agegrp=2 & study="REGARDS"),fsrp10_a,oe_bor_m1);
%obsexp(everything2,%str(race_c="Black" & agegrp=2 & study="REGARDS"),ascvd10_a,oe_bor_m2);
%obsexp(everything2,%str(race_c="Black" & agegrp=2 & study="REGARDS"),regs10_a,oe_bor_m3);

%obsexp(everything2,%str(race_c="White" & agegrp=1 & study="REGARDS"),fsrp10_a,oe_wyr_m1);
%obsexp(everything2,%str(race_c="White" & agegrp=1 & study="REGARDS"),ascvd10_a,oe_wyr_m2);
%obsexp(everything2,%str(race_c="White" & agegrp=1 & study="REGARDS"),regs10_a,oe_wyr_m3);

%obsexp(everything2,%str(race_c="White" & agegrp=2 & study="REGARDS"),fsrp10_a,oe_wor_m1);
%obsexp(everything2,%str(race_c="White" & agegrp=2 & study="REGARDS"),ascvd10_a,oe_wor_m2);
%obsexp(everything2,%str(race_c="White" & agegrp=2 & study="REGARDS"),regs10_a,oe_wor_m3);

%obsexp(everything2,%str(study="REGARDS"),fsrp10_c,oe_or_m1);
%obsexp(everything2,%str(study="REGARDS"),ascvd10_c,oe_or_m2);
%obsexp(everything2,%str(study="REGARDS"),regs10_c,oe_or_m3);

* Observed/Expected for Supplementary Table 1 == OFFSPRING;
%obsexp(everything2,%str(race_c="White" & agegrp=1 & study="OFFSPRING"),fsrp10_a,oe_wyo_m1);
%obsexp(everything2,%str(race_c="White" & agegrp=1 & study="OFFSPRING"),ascvd10_a,oe_wyo_m2);
%obsexp(everything2,%str(race_c="White" & agegrp=1 & study="OFFSPRING"),regs10_a,oe_wyo_m3);

%obsexp(everything2,%str(race_c="White" & agegrp=2 & study="OFFSPRING"),fsrp10_a,oe_woo_m1);
%obsexp(everything2,%str(race_c="White" & agegrp=2 & study="OFFSPRING"),ascvd10_a,oe_woo_m2);
%obsexp(everything2,%str(race_c="White" & agegrp=2 & study="OFFSPRING"),regs10_a,oe_woo_m3);

%obsexp(everything2,%str(study="OFFSPRING"),fsrp10_c,oe_oo_m1);
%obsexp(everything2,%str(study="OFFSPRING"),ascvd10_c,oe_oo_m2);
%obsexp(everything2,%str(study="OFFSPRING"),regs10_c,oe_oo_m3);

* Observed/Expected for Supplementary Table 1 == Overall;
%obsexp(everything2,%str(race_c="Black" & agegrp=1),fsrp10_a,oe_by_m1);
%obsexp(everything2,%str(race_c="Black" & agegrp=1),ascvd10_a,oe_by_m2);
%obsexp(everything2,%str(race_c="Black" & agegrp=1),regs10_a,oe_by_m3);

%obsexp(everything2,%str(race_c="Black" & agegrp=2),fsrp10_a,oe_bo_m1);
%obsexp(everything2,%str(race_c="Black" & agegrp=2),ascvd10_a,oe_bo_m2);
%obsexp(everything2,%str(race_c="Black" & agegrp=2),regs10_a,oe_bo_m3);

%obsexp(everything2,%str(race_c="White" & agegrp=1),fsrp10_a,oe_wy_m1);
%obsexp(everything2,%str(race_c="White" & agegrp=1),ascvd10_a,oe_wy_m2);
%obsexp(everything2,%str(race_c="White" & agegrp=1),regs10_a,oe_wy_m3);

%obsexp(everything2,%str(race_c="White" & agegrp=2),fsrp10_a,oe_wo_m1);
%obsexp(everything2,%str(race_c="White" & agegrp=2),ascvd10_a,oe_wo_m2);
%obsexp(everything2,%str(race_c="White" & agegrp=2),regs10_a,oe_wo_m3);

%obsexp(everything2,%str(study ^= ""),fsrp10_c,oe_o_m1);
%obsexp(everything2,%str(study ^= ""),ascvd10_c,oe_o_m2);
%obsexp(everything2,%str(study ^= ""),regs10_c,oe_o_m3);

data blank;
   attrib result length=$30.;
   result="";
run;

data t2_aric_obsexp;
   set oe_bya_m1-oe_bya_m3
       blank
       oe_boa_m1-oe_boa_m3
       blank
       oe_wya_m1-oe_wya_m3
       blank
       oe_woa_m1-oe_woa_m3
       blank
       oe_oa_m1-oe_oa_m3;

   retain row 0;
   row + 1;

   rename obs_risk=obs_risk_aric exp_risk=exp_risk_aric;
run;

data t2_mesa_obsexp;
   set oe_bym_m1-oe_bym_m3
       blank
       oe_bom_m1-oe_bom_m3
       blank
       oe_wym_m1-oe_wym_m3
       blank
       oe_wom_m1-oe_wom_m3
       blank
       oe_om_m1-oe_om_m3;

   retain row 0;
   row + 1;

   rename obs_risk=obs_risk_mesa exp_risk=exp_risk_mesa;
run;

data t2_regs_obsexp;
   set oe_byr_m1-oe_byr_m3
       blank
       oe_bor_m1-oe_bor_m3
       blank
       oe_wyr_m1-oe_wyr_m3
       blank
       oe_wor_m1-oe_wor_m3
       blank
       oe_or_m1-oe_or_m3;

   retain row 0;
   row + 1;

   rename obs_risk=obs_risk_regs exp_risk=exp_risk_regs;
run;

data t2_off_obsexp;
   set oe_wyo_m1-oe_wyo_m3
       blank
       oe_woo_m1-oe_woo_m3
       blank
       oe_oo_m1-oe_oo_m3;

   retain row 8;
   row + 1;
   rename obs_risk=obs_risk_offs exp_risk=exp_risk_offs;
run;

data t2_overall_obsexp;
   set oe_by_m1-oe_by_m3
       blank
       oe_bo_m1-oe_bo_m3
       blank
       oe_wy_m1-oe_wy_m3
       blank
       oe_wo_m1-oe_wo_m3
       blank
       oe_o_m1-oe_o_m3;

   retain row 0;
   row + 1;

   rename obs_risk=obs_risk_overall exp_risk=exp_risk_overall;
run;

data t2;
   merge t2_aric_obsexp
         t2_mesa_obsexp
         t2_regs_obsexp
         t2_off_obsexp
         t2_overall_obsexp;
   by row;
run;

data table2;
   attrib model length=$10.;
   attrib subgroup length=$40.;
   set t2;

   if row in (1,5,9,13,17) then model="FSRP";
   else if row in (2,6,10,14,18) then model="ASCVD";
   else if row in (3,7,11,15,19) then model="REGARDS";

   if row in (1,2,3) then subgroup="Black < 60";
   else if row in (5,6,7) then subgroup="Black >= 60";
   else if row in (9,10,11) then subgroup="White < 60";
   else if row in (13,14,15) then subgroup="White >= 60";
   else if row in (17,18,19) then subgroup="Overall";
run;

options orientation=landscape nodate nonumber;
ods path sashelp.tmplmst(read) template.tables(read);
ods rtf file = "../manu/validating/output/34_calibration_by_age_corrected.rtf" bodytitle style=grayborders;
ods listing close;
title "eTable 6b. Calibration metrics for previously developed models: by race + age (with stroke factor corrections)";
proc report data=table2 nowd split = '|' missing
   style(report)={just=center}
   style(lines)=header{background=white font_size=10pt
   font_face="Arial" font_weight=bold just=left}
   style(header)=header{background=white font_size=9pt
   font_face="Arial" font_weight=bold }
   style(column)=header{background=white font_size=9pt
   font_face="Arial" font_weight=medium protectspecialchars = off } ;

   columns subgroup model ("Offspring" exp_risk_offs obs_risk_offs) ("ARIC" exp_risk_aric obs_risk_aric)
                          ("MESA" exp_risk_mesa obs_risk_mesa) ("REGARDS" exp_risk_regs obs_risk_regs)
                          ("Overall" exp_risk_overall obs_risk_overall);

   define subgroup / display "Subgroup" style(header)={just=left cellwidth=15%} ;
   define model / display "Model" style(header)={just=left cellwidth=10%};

   define exp_risk_offs /display "Expected" style(column)=[just=center cellwidth=7%];
   define obs_risk_offs /display "Observed" style(column)=[just=center cellwidth=7%];
   define exp_risk_aric /display "Expected" style(column)=[just=center cellwidth=7%];
   define obs_risk_aric /display "Observed" style(column)=[just=center cellwidth=7%];
   define exp_risk_mesa /display "Expected" style(column)=[just=center cellwidth=7%];
   define obs_risk_mesa /display "Observed" style(column)=[just=center cellwidth=7%];
   define exp_risk_regs /display "Expected" style(column)=[just=center cellwidth=7%];
   define obs_risk_regs /display "Observed" style(column)=[just=center cellwidth=7%];
   define exp_risk_overall /display "Expected" style(column)=[just=center cellwidth=7%];
   define obs_risk_overall /display "Observed" style(column)=[just=center cellwidth=7%];

run;
ods rtf close;
