* #################################################################################
* TASK:     Differences in c-indices
* INPUT:    stroke_risk_ads_v4
* OUTPUT:
* DATE:     04-JAN-2022
* UPDATES:  Using Uno definitin for the c-index
* #########################################################################;
options nodate nonumber ls=150 mprint=no mautosource sasautos=("!SASROOT/sasautos","/dcri/shared_code/sas/macro");

libname mydata "../manu/ads/data";
libname out "../manu/validating/data";
libname template "../manu/validating/programs/templates";

%include "../manu/ads/programs/etc/formats.sas";

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
   age10 = age/10;
   female = sex - 1;
   educ3 = (educlev=3) + 0*educlev;
   educ2 = (educlev=2) + 0*educlev;
   educ1 = (educlev=1) + 0*educlev;
   health2 = (health=2) + 0*health;
   health3 = (health=3) + 0*health;
   health4 = (health=4) + 0*health;
   health5 = (health=5) + 0*health;

   if study ^= "REGARDS" then do;
      R_age = 0.78687*age10;
      R_rac = 2.13064*aa;
      R_agr = -0.29208*(age10*aa - 6.44);
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
      R_age = 0.78687*age10;
      R_rac = 2.13064*aa;
      R_agr = -0.29208*(age10*aa - 6.44);
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
        R_smk + R_ed3 + R_ed2 + R_ed1 + R_hh2 + R_hh3 + R_hh4 + R_hh5 - 6.44;

   regs10_s = 1 - (0.97612109)**exp(Re);

   keep usubjid study cohort sex race_c fsrp10_s ascvd10_s regs10_s stroke10 t2stroke10_yrs;
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
        R_smk + R_ed3 + R_ed2 + R_ed1 + R_hh2 + R_hh3 + R_hh4 + R_hh5 - 6.44;

   regs10_a = 1 - (0.97612109)**exp(Re);

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
        R_smk + R_ed3 + R_ed2 + R_ed1 + R_hh2 + R_hh3 + R_hh4 + R_hh5 - 6.44;

   regs10_c = 1 - (0.97612109)**exp(Re);

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

data everything;
   merge imputed_sex
         imputed_age
         imputed_cohort;
   by usubjid;
run;

%macro c_diff(cond,seed,outds,lab);
data _temp_;
   set everything;

   if &cond;
run;

ods listing close;
proc phreg data=_temp_ concordance=uno;
   model t2stroke10_yrs*stroke10(0) = ascvd10_s;
	store out=ascvd;
run;

proc phreg data=_temp_ concordance=uno;
   model t2stroke10_yrs*stroke10(0) = regs10_s;
	store out=regs;
run;

proc phreg data=_temp_ concordance=uno(se diff iter=100 seed=&seed. alpha=0.05);;
   model t2stroke10_yrs*stroke10(0) = fsrp10_s / roclabel="FSRP";
   roc "ASCVD" source=ascvd;
	roc "REGARDS" source=regs;
   ods output ConcordanceDiff=c_diff;
run;
ods listing;

data result;
	attrib c_diff length=$25.;
	set c_diff;

   c_ll = estimate + quantile('NORMAL', .025)*StdErr;
   c_ul = estimate + quantile('NORMAL', .975)*StdErr;
   c_diff = compress(put(estimate,7.3)) || " (" || compress(put(c_ll,7.3)) || " - " || compress(put(c_ul,7.3)) || ")";
run;

data &outds;
	attrib res1-res3 length=$25.;
	attrib pva1-pva3 length=$10.;
	attrib subgrp length=$25.;
	set result end=eof;
	retain res1-res3 pva1-pva3;

	if Source2="FSRP" & Source="ASCVD" then do;
		res1 = c_diff;
		pva1 = put(ProbChiSq,pvalue7.4);
	   end;

   else if Source2="FSRP" & Source="REGARDS" then do;
		res2 = c_diff;
		pva2 = put(ProbChiSq,pvalue7.4);
	   end;

   else if Source2="REGARDS" & Source="ASCVD" then do;
		res3 = c_diff;
		pva3 = put(ProbChiSq,pvalue7.4);
	   end;

   if eof then do;
		subgrp = "&lab";
		keep subgrp res1 pva1 res2 pva2 res3 pva3;
		output;
    	end;
run;
%mend c_diff;

%c_diff(%str(race_c="Black" & sex=2),1356,bw_ove,%str(Black Women));
%c_diff(%str(race_c="Black" & sex=1),4536,bm_ove,%str(Black Men));
%c_diff(%str(race_c="White" & sex=2),4687,ww_ove,%str(White Women));
%c_diff(%str(race_c="White" & sex=1),9843,wm_ove,%str(White Men));

data table1_diff;
	set bw_ove
	    bm_ove
		 ww_ove
		 wm_ove;
run;

options orientation=landscape nodate nonumber;
ods path sashelp.tmplmst(read) template.tables(read);
ods rtf file = "../manu/validating/output/28_cdiff_table1.rtf" bodytitle style=grayborders;
ods listing close;
title "eTable 5a. Difference in c-index statistics for previously developed models: by race + sex for each cohort. 10 years == Uno Version";
proc report data=table1_diff nowd split = '|' missing
   style(report)={just=center}
   style(lines)=header{background=white font_size=10pt
   font_face="Arial" font_weight=bold just=left}
   style(header)=header{background=white font_size=9pt
   font_face="Arial" font_weight=bold }
   style(column)=header{background=white font_size=9pt
   font_face="Arial" font_weight=medium protectspecialchars = off } ;

   columns subgrp ("ASCVD vs. FSRP" res1 pva1) ("REGARDS vs. FSRP" res2 pva2) ("ASCVD vs. REGARDS" res3 pva3);

   define subgrp / display "Subgroup" style(header)={just=left cellwidth=15%} ;
   define res1 /display "Difference (95% CI)" style(column)=[just=center cellwidth=18%];
   define pva1 /display "p-value" style(column)=[just=center cellwidth=10%];
   define res2 /display "Difference (95% CI)" style(column)=[just=center cellwidth=18%];
   define pva2 /display "p-value" style(column)=[just=center cellwidth=10%];
   define res3 /display "Difference (95% CI)" style(column)=[just=center cellwidth=18%];
   define pva3 /display "p-value" style(column)=[just=center cellwidth=10%];
run;
ods rtf close;

* Age Version;
%macro c_diff(cond,seed,outds,lab);
data _temp_;
   set everything;

   if &cond;
run;

ods listing close;
proc phreg data=_temp_ concordance=uno;
   model t2stroke10_yrs*stroke10(0) = ascvd10_a;
	store out=ascvd;
run;

proc phreg data=_temp_ concordance=uno;
   model t2stroke10_yrs*stroke10(0) = regs10_a;
	store out=regs;
run;

proc phreg data=_temp_ concordance=uno(se diff iter=100 seed=&seed. alpha=0.05);;
   model t2stroke10_yrs*stroke10(0) = fsrp10_a / roclabel="FSRP";
   roc "ASCVD" source=ascvd;
	roc "REGARDS" source=regs;
   ods output ConcordanceDiff=c_diff;
run;
ods listing;

data result;
	attrib c_diff length=$25.;
	set c_diff;

   c_ll = estimate + quantile('NORMAL', .025)*StdErr;
   c_ul = estimate + quantile('NORMAL', .975)*StdErr;
   c_diff = compress(put(estimate,7.3)) || " (" || compress(put(c_ll,7.3)) || " - " || compress(put(c_ul,7.3)) || ")";
run;

data &outds;
	attrib res1-res3 length=$25.;
	attrib pva1-pva3 length=$10.;
	attrib subgrp length=$25.;
	set result end=eof;
	retain res1-res3 pva1-pva3;

	if Source2="FSRP" & Source="ASCVD" then do;
		res1 = c_diff;
		pva1 = put(ProbChiSq,pvalue7.4);
	   end;

   else if Source2="FSRP" & Source="REGARDS" then do;
		res2 = c_diff;
		pva2 = put(ProbChiSq,pvalue7.4);
	   end;

   else if Source2="REGARDS" & Source="ASCVD" then do;
		res3 = c_diff;
		pva3 = put(ProbChiSq,pvalue7.4);
	   end;

   if eof then do;
		subgrp = "&lab";
		keep subgrp res1 pva1 res2 pva2 res3 pva3;
		output;
    	end;
run;
%mend c_diff;

%c_diff(%str(race_c="Black" & agegrp=1),2467,by_ove,%str(Black < 60));
%c_diff(%str(race_c="Black" & agegrp=2),5647,bo_ove,%str(Black >= 60));
%c_diff(%str(race_c="White" & agegrp=1),5798,wy_ove,%str(White < 60));
%c_diff(%str(race_c="White" & agegrp=2),0954,wo_ove,%str(White >= 60));

data table2_diff;
	set by_ove
	    bo_ove
		 wy_ove
		 wo_ove;
run;

options orientation=landscape nodate nonumber;
ods path sashelp.tmplmst(read) template.tables(read);
ods rtf file = "../manu/validating/output/28_cdiff_table2.rtf" bodytitle style=grayborders;
ods listing close;
title "eTable 5b. Difference in c-index statistics for previously developed models: by race + age for each cohort. 10 years == Uno Version";
proc report data=table2_diff nowd split = '|' missing
   style(report)={just=center}
   style(lines)=header{background=white font_size=10pt
   font_face="Arial" font_weight=bold just=left}
   style(header)=header{background=white font_size=9pt
   font_face="Arial" font_weight=bold }
   style(column)=header{background=white font_size=9pt
   font_face="Arial" font_weight=medium protectspecialchars = off } ;

   columns subgrp ("ASCVD vs. FSRP" res1 pva1) ("REGARDS vs. FSRP" res2 pva2) ("ASCVD vs. REGARDS" res3 pva3);

   define subgrp / display "Subgroup" style(header)={just=left cellwidth=15%} ;
   define res1 /display "Difference (95% CI)" style(column)=[just=center cellwidth=18%];
   define pva1 /display "p-value" style(column)=[just=center cellwidth=10%];
   define res2 /display "Difference (95% CI)" style(column)=[just=center cellwidth=18%];
   define pva2 /display "p-value" style(column)=[just=center cellwidth=10%];
   define res3 /display "Difference (95% CI)" style(column)=[just=center cellwidth=18%];
   define pva3 /display "p-value" style(column)=[just=center cellwidth=10%];
run;
ods rtf close;
