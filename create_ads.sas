* #################################################################################
* TASK:     Analysis dataset for stroke risk prediction project
* INPUT:
* OUTPUT:
* DATE:     09-DEC-2021
* UPDATES:  Added variables: diet in MESA, physical activity
* #########################################################################;
options nodate nonumber ls=120 mprint=no mautosource sasautos=("!SASROOT/sasautos","/dcri/shared_code/sas/macro");

libname aric "../data/aric/analdata" access=readonly;
libname aric_o "../data/aric/dbgap/import_pheno_text/outdata" access=readonly;
libname mesa "../data/mesa/analdata" access=readonly;
libname foff "../data/framingham/analdata" access=readonly;
libname mydata "../manu/ads/data";
%include "../manu/ads/programs/etc/formats.sas";

* FRAMINGHAM OFFSPRING: EXAMS 3, 6, and 8;
* Follow-Up time;
data off_followup;
	set foff.pheno_fram_offspring(where=(visit="EXAM1"));
	keep dbgap_subject_id censday;
run;

proc sort data=off_followup;
	by dbgap_subject_id;
run;

* Exam 3 Date;
data off_ex3_time;
	set foff.pheno_fram_offspring(where=(visit="EXAM3" & visday ^= .));
	rename visday=exam3day;
	keep dbgap_subject_id visday;
run;

proc sort data=off_ex3_time;
	by dbgap_subject_id;
run;

* Exam 6 Date;
data off_ex6_time;
	set foff.pheno_fram_offspring(where=(visit="EXAM6" & visday ^= .));
	rename visday=exam6day;
	keep dbgap_subject_id visday;
run;

proc sort data=off_ex6_time;
	by dbgap_subject_id;
run;

* Exam 8 Date;
data off_ex8_time;
	set foff.pheno_fram_offspring(where=(visit="EXAM8" & visday ^= .));
	rename visday=exam8day;
	keep dbgap_subject_id visday;
run;

proc sort data=off_ex8_time;
	by dbgap_subject_id;
run;

* CVD history at enrollment (Exam 1);
data off_base_cvd;
	set foff.pheno_fram_offspring;
	if base_cvd="YES";
	keep dbgap_subject_id;
run;

* Stroke history at enrollment (Exam 1);
data off_base_stroke;
	set foff.pheno_fram_offspring;
	if base_stroke in (1,2);
	keep dbgap_subject_id;
run;

* Stroke Events;
proc sort data=foff.cv_events(where=(event in (11,13,14,15,16,17,25) & event_val_c="YES")) out=off_stroke_events;
	by dbgap_subject_id days_since_exam1;
run;

* TIA Events;
proc sort data=foff.cv_events(where=(event=12 & event_val_c="YES")) out=off_tia_events;
	by dbgap_subject_id days_since_exam1;
run;

* CHD EVents;
proc sort data=foff.cv_events(where=(event=70 & event_val_c="YES")) out=off_chd_events;
	by dbgap_subject_id days_since_exam1;
run;

* Education: Only Collected in Exam 2, to be used in every visit;
data off_educ;
   set foff.pheno_fram_offspring(where=(visit="EXAM2" & visday ^= .));
   keep dbgap_subject_id educlev;
run;

proc sort data=off_educ;
   by dbgap_subject_id;
run;

* @@@@ EXAM 3 @@@@;
* Variables at Exam 3;
data off_ex3;
	set foff.pheno_fram_offspring(where=(visit="EXAM3" & visday ^= .));
	if n(sysbp1,sysbp2) > 0 then sysbp = mean(sysbp1,sysbp2);
	if n(diabp1,diabp2) > 0 then diabp = mean(diabp1,diabp2);

	label sysbp="Systolic Blood Pressure"
	      diabp="Diastolic Blood Pressure"
			hgt_cm="Height (cm)";

	keep dbgap_subject_id visday
	     age sex_n race_c wgt hgt_cm bmi sysbp diabp
	     diab hrx currsmk bg fasting_bg tc hdl trig creat
		  anycholmed statin nonstatin statnonstat insulin aspirin
        afib genhlth hxcvd hxhrtd hxmi lvh
		  valvdis carsten fam_income alcohol fruits vegetables
		  activity activity_alt
		  state;
run;

proc sort data=off_ex3;
	by dbgap_subject_id;
run;

* Exclude due to history of stroke between exam 1 and exam 3;
data off_hx_stroke_exam3(keep=dbgap_subject_id)
     off_post_exam3_stroke(keep=dbgap_subject_id days_since_exam1);
   merge off_stroke_events(in=s)
	      off_ex3_time;
   by dbgap_subject_id;

	if s=1 then do;
		if .z < days_since_exam1 <= exam3day then output off_hx_stroke_exam3;
		if days_since_exam1 >  exam3day then output off_post_exam3_stroke;
	   end;
run;

* Exclude due to history of TIA between exam 1 and exam 3;
data off_hx_tia_exam3(keep=dbgap_subject_id);
   merge off_tia_events(in=s)
	      off_ex3_time;
   by dbgap_subject_id;

	if s=1 & .z < days_since_exam1 <= exam3day then output;
run;

proc sort data=off_hx_stroke_exam3 nodupkey;
	by dbgap_subject_id;
run;

proc sort data=off_hx_tia_exam3 nodupkey;
	by dbgap_subject_id;
run;

* History of CHD;
data off_hx_chd_exam3;
   merge off_chd_events(in=s)
	      off_ex3_time;
   by dbgap_subject_id;

	if s=1 & .z < days_since_exam1 < exam3day;
   keep dbgap_subject_id;
run;

proc sort data=off_hx_chd_exam3 nodupkey;
	by dbgap_subject_id;
run;

* Strokes Post Exam 3;
proc sort data=off_post_exam3_stroke;
	by dbgap_subject_id days_since_exam1;
run;

data off_post_exam3_stroke;
	set off_post_exam3_stroke;
	by dbgap_subject_id;

	if first.dbgap_subject_id;

   rename days_since_exam1=t2stroke0;
	keep dbgap_subject_id days_since_exam1;
run;

* Family History of Stroke (Not Available in Exam 3, we use Exam 6);
data off_fhs_ex3;
	set foff.pheno_fram_offspring(where=(visit="EXAM6" & visday ^= .));

	keep dbgap_subject_id fh_stroke;
run;

proc sort data=off_fhs_ex3;
	by dbgap_subject_id;
run;

data offdata_exam3;
	attrib study length=$10. label="Study";
	attrib exam length=$6. label="Exam";

	merge off_ex3(in=e3)
         off_educ
	      off_base_cvd(in=bcvd)
			off_base_stroke(in=bstk)
			off_hx_stroke_exam3(in=hxs)
			off_hx_tia_exam3(in=hxt)
			off_hx_chd_exam3(in=hxc)
			off_ex6_time
			off_post_exam3_stroke(in=stk)
			off_fhs_ex3
			off_followup;
    by dbgap_subject_id;

	 study = "OFFSPRING";
	 exam = "EXAM3";

    * Select Observations included;
	 if e3=1 & bstk=0 & hxs=0 & hxt=0 & censday > visday;

	 * Time from Exam 3 to Exam 6;
	 if exam6day ^= . then time3_6 = exam6day - visday;

	 * The median time from Exam 3 to Exam 6 is 4095 days;
	 if time3_6 = . then time3_6 = 4096;

	 * Flag for Time to Exam 6 imputed;
	 time3_6_imputed = (exam6day = .);

	 * History of CHD;
	 if hxc=1 | bcvd=1 then hx_chd=1;
	 else hx_chd=0;

	 * Stroke Events;
	 if stk=1 & (t2stroke0 - visday) < time3_6 then do;
		 stroke = 1;
		 t2stroke = t2stroke0 - visday + 1;
	    end;

    else do;
		 stroke = 0;
		 t2stroke = min(time3_6,censday - visday + 1);
	    end;

   label time3_6 = "Time to next included exam"
	      time3_6_imputed = "Time to next included exam imputed? (1=Yes)"
			stroke = "Any stroke during follow-up"
			t2stroke = "Time to stroke during follow-up"
			hx_chd = "History of CHD";

   format bmi 5.1;
   rename time3_6=time_to_next time3_6_imputed=time_to_next_i visday=days_since_exam1;
   drop exam6day t2stroke0 censday;
run;

* @@@@ EXAM 6 @@@@;
* Variables at Exam 6;
data off_ex6;
	set foff.pheno_fram_offspring(where=(visit="EXAM6" & visday ^= .));
	if n(sysbp1,sysbp2) > 0 then sysbp = mean(sysbp1,sysbp2);
	if n(diabp1,diabp2) > 0 then diabp = mean(diabp1,diabp2);

	label sysbp="Systolic Blood Pressure"
	      diabp="Diastolic Blood Pressure"
			hgt_cm="Height (cm)";

	keep dbgap_subject_id visday
	     age sex_n race_c wgt hgt_cm bmi sysbp diabp
	     diab hrx currsmk bg fasting_bg tc hdl trig creat
		  anycholmed statin nonstatin statnonstat insulin aspirin
        afib genhlth hxcvd hxhrtd hxmi lvh
		  valvdis carsten alcohol fruits vegetables state fh_stroke sodium
 		  activity activity_alt;
run;

proc sort data=off_ex6;
	by dbgap_subject_id;
run;

* Exclude due to history of stroke between exam 1 and exam 6;
data off_hx_stroke_exam6(keep=dbgap_subject_id) off_post_exam6_stroke(keep=dbgap_subject_id days_since_exam1);
   merge off_stroke_events(in=s)
	      off_ex6_time;
   by dbgap_subject_id;

	if s=1 then do;
		if .z < days_since_exam1 <= exam6day then output off_hx_stroke_exam6;
		if days_since_exam1 >  exam6day then output off_post_exam6_stroke;
	   end;
run;

* Exclude due to history of TIA between exam 1 and exam 6;
data off_hx_tia_exam6(keep=dbgap_subject_id);
   merge off_tia_events(in=s)
	      off_ex6_time;
   by dbgap_subject_id;

	if s=1 & .z < days_since_exam1 <= exam6day then output;
run;

proc sort data=off_hx_stroke_exam6 nodupkey;
	by dbgap_subject_id;
run;

proc sort data=off_hx_tia_exam6 nodupkey;
	by dbgap_subject_id;
run;

* History of CHD;
data off_hx_chd_exam6;
   merge off_chd_events(in=s)
	      off_ex6_time;
   by dbgap_subject_id;

	if s=1 & .z < days_since_exam1 < exam6day;
   keep dbgap_subject_id;
run;

proc sort data=off_hx_chd_exam6 nodupkey;
	by dbgap_subject_id;
run;

* Strokes Post Exam 6;
proc sort data=off_post_exam6_stroke;
	by dbgap_subject_id days_since_exam1;
run;

data off_post_exam6_stroke;
	set off_post_exam6_stroke;
	by dbgap_subject_id;

	if first.dbgap_subject_id;

   rename days_since_exam1=t2stroke0;
	keep dbgap_subject_id days_since_exam1;
run;

* Family Income (Not Available in Exam 6, we use Exam 3);
data off_inc_ex6;
	set foff.pheno_fram_offspring(where=(visit="EXAM3" & visday ^= .));

	keep dbgap_subject_id fam_income;
run;

proc sort data=off_inc_ex6;
	by dbgap_subject_id;
run;

data offdata_exam6;
	attrib study length=$10. label="Study";
	attrib exam length=$6. label="Exam";

	merge off_ex6(in=e6)
         off_educ
	      off_base_cvd(in=bcvd)
			off_base_stroke(in=bstk)
			off_hx_stroke_exam6(in=hxs)
			off_hx_tia_exam6(in=hxt)
			off_hx_chd_exam6(in=hxc)
			off_ex8_time
			off_post_exam6_stroke(in=stk)
			off_inc_ex6
			off_followup;
    by dbgap_subject_id;

	 study = "OFFSPRING";
	 exam = "EXAM6";

    * Select Observations included;
	 if e6=1 & bstk=0 & hxs=0 & hxt=0 & censday > visday;

	 * Time from Exam 6 to Exam 8;
	 if exam8day ^= . then time6_8 = exam8day - visday;

    * Since Participants with Missing Exam 8 won't be included at Exam 8 we can assign 10 years of potential follow-up;
	 * 3653 days = 365.25 x 10;
	 if time6_8 = . then time6_8 = censday - visday;

	 * Flag for Time to Exam 8 imputed;
	 time6_8_imputed = (exam8day = .);

	 * History of CHD;
	 if hxc=1 | bcvd=1 then hx_chd=1;
	 else hx_chd=0;

	 * Stroke Events;
	 if stk=1 & (t2stroke0 - visday) < time6_8 then do;
		 stroke = 1;
		 t2stroke = t2stroke0 - visday + 1;
	    end;

    else do;
		 stroke = 0;
		 t2stroke = min(time6_8,censday - visday + 1);
	    end;

   label time6_8 = "Time to next included exam"
	      time6_8_imputed = "Time to next included exam imputed? (1=Yes)"
			stroke = "Any stroke during follow-up"
			t2stroke = "Time to stroke during follow-up"
			hx_chd = "History of CHD";

   format bmi 5.1;
   rename time6_8=time_to_next time6_8_imputed=time_to_next_i visday=days_since_exam1;
   drop exam8day t2stroke0 censday;
run;

* @@@@ EXAM 8 @@@@;
* Variables at Exam 8;
data off_ex8;
	set foff.pheno_fram_offspring(where=(visit="EXAM8" & visday ^= .));
	if n(sysbp1,sysbp2) > 0 then sysbp = mean(sysbp1,sysbp2);
	if n(diabp1,diabp2) > 0 then diabp = mean(diabp1,diabp2);

	label sysbp="Systolic Blood Pressure"
	      diabp="Diastolic Blood Pressure"
			hgt_cm="Height (cm)";

	keep dbgap_subject_id visday
	     age sex_n race_c wgt hgt_cm bmi sysbp diabp
	     diab hrx currsmk bg fasting_bg tc hdl trig creat
		  anycholmed statin nonstatin statnonstat insulin aspirin
        afib genhlth2 hxcvd hxhrtd hxmi lvh
		  valvdis carsten alcohol fruits vegetables state sodium
  		  activity activity_alt;
run;

proc sort data=off_ex8;
	by dbgap_subject_id;
run;

* Exclude due to history of stroke between exam 1 and exam 8;
data off_hx_stroke_exam8(keep=dbgap_subject_id) off_post_exam8_stroke(keep=dbgap_subject_id days_since_exam1);
   merge off_stroke_events(in=s)
	      off_ex8_time;
   by dbgap_subject_id;

	if s=1 then do;
		if .z < days_since_exam1 <= exam8day then output off_hx_stroke_exam8;
		if days_since_exam1 >  exam8day then output off_post_exam8_stroke;
	   end;
run;

* Exclude due to history of TIA between exam 1 and exam 8;
data off_hx_tia_exam8(keep=dbgap_subject_id);
   merge off_tia_events(in=s)
	      off_ex8_time;
   by dbgap_subject_id;

	if s=1 & .z < days_since_exam1 <= exam8day then output;
run;

proc sort data=off_hx_stroke_exam8 nodupkey;
	by dbgap_subject_id;
run;

proc sort data=off_hx_tia_exam8 nodupkey;
	by dbgap_subject_id;
run;

* History of CHD;
data off_hx_chd_exam8;
   merge off_chd_events(in=s)
	      off_ex8_time;
   by dbgap_subject_id;

	if s=1 & .z < days_since_exam1 < exam8day;
   keep dbgap_subject_id;
run;

proc sort data=off_hx_chd_exam8 nodupkey;
	by dbgap_subject_id;
run;

* Strokes Post Exam 8;
proc sort data=off_post_exam8_stroke;
	by dbgap_subject_id days_since_exam1;
run;

data off_post_exam8_stroke;
	set off_post_exam8_stroke;
	by dbgap_subject_id;

	if first.dbgap_subject_id;

   rename days_since_exam1=t2stroke0;
	keep dbgap_subject_id days_since_exam1;
run;

* Family History of Stroke (Not Available in Exam 8, we use Exam 6);
data off_fhs_ex8;
	set foff.pheno_fram_offspring(where=(visit="EXAM6" & visday ^= .));

	keep dbgap_subject_id fh_stroke;
run;

proc sort data=off_fhs_ex8;
	by dbgap_subject_id;
run;

* Family Income (Not Available in Exam 8, we use Exam 3);
data off_inc_ex8;
	set foff.pheno_fram_offspring(where=(visit="EXAM3" & visday ^= .));

	keep dbgap_subject_id fam_income;
run;

proc sort data=off_inc_ex8;
	by dbgap_subject_id;
run;

data offdata_exam8;
	attrib study length=$10. label="Study";
	attrib exam length=$6. label="Exam";

	merge off_ex8(in=e8)
         off_educ
	      off_base_cvd(in=bcvd)
			off_base_stroke(in=bstk)
			off_hx_stroke_exam8(in=hxs)
			off_hx_tia_exam8(in=hxt)
			off_hx_chd_exam8(in=hxc)
			off_post_exam8_stroke(in=stk)
			off_fhs_ex8
			off_inc_ex8
			off_followup;
    by dbgap_subject_id;

	 study = "OFFSPRING";
	 exam = "EXAM8";

    * Select Observations included;
	 if e8=1 & bstk=0 & hxs=0 & hxt=0 & censday > visday;

	 * History of CHD;
	 if hxc=1 | bcvd=1 then hx_chd=1;
	 else hx_chd=0;

	 * Stroke Events;
	 if stk=1 then do;
		 stroke = 1;
		 t2stroke = t2stroke0 - visday + 1;
	    end;

    else do;
		 stroke = 0;
		 t2stroke = censday - visday + 1;
	    end;

   label stroke = "Any stroke during follow-up"
			t2stroke = "Time to stroke during follow-up"
			hx_chd = "History of CHD";

   format bmi 5.1;
   rename visday=days_since_exam1;
   drop t2stroke0 censday;

run;

* ARIC: EXAMS 1 and 4;
* Follow-Up time;
data aric_followup;
	set aric.pheno_aric(where=(visit="EXAM1"));
	keep dbgap_subject_id censday;
run;

proc sort data=aric_followup;
	by dbgap_subject_id;
run;

* Exam 4 Date;
data aric_ex4_time;
	set aric.pheno_aric(where=(visit="EXAM4" & visday ^= .));
	rename visday=exam4day;
	keep dbgap_subject_id visday;
run;

proc sort data=aric_ex4_time;
	by dbgap_subject_id;
run;

* CVD history at enrollment (Exam 1);
data aric_base_cvd;
	set aric.pheno_aric;
	if base_cvd="YES";
	keep dbgap_subject_id;
run;

proc sort data=aric_base_cvd;
	by dbgap_subject_id;
run;

* Stroke/TIA history at enrollment (Exam 1);
data aric_base_stroke;
	set aric.pheno_aric;
	if base_stroke in (1,2);
	keep dbgap_subject_id;
run;

proc sort data=aric_base_stroke;
	by dbgap_subject_id;
run;

* Strokes;
data aric_stroke_events;
   set aric.cv_events(where=(event_desc in ("DEFINITE/PROBABLE BRAIN HEMORRHAGIC INCIDENT STROKE BY 2016",
                                            "DEFINITE/PROBABLE BRAIN/SAH HEMORRHAGIC INCIDENT STROKE BY 2016",
                                            "DEFINITE/PROBABLE INCIDENT STROKE BY 2011",
                                            "DEFINITE/PROBABLE ISCHEMIC INCIDENT STROKE BY 2016",
                                            "DEFINITE/PROBABLE/POSSIBLE INCIDENT STROKE BY 2016")));
   if event_val_c="YES";
   keep dbgap_subject_id event_desc days_since_exam1;
run;

proc sort data=aric_stroke_events;
	by dbgap_subject_id days_since_exam1;
run;

* CHD;
data aric_chd_events;
   set aric.cv_events(where=(event_desc in ("MI OR FATAL CHD BY 2016",
	                                         "MYOCARDIAL INFARCTION (DEFINITE + PROBABLE) BY 2016")));
   if event_val_c="YES";
   keep dbgap_subject_id event_desc days_since_exam1;
run;

proc sort data=aric_chd_events;
	by dbgap_subject_id days_since_exam1;
run;


* @@@@ EXAM 1 @@@@;
* Variables at Exam 1;
data aric_ex1;
	set aric.pheno_aric(where=(visit="EXAM1" & visday ^= .));

   if fasting_8hr=1 then fasting_bg=glucose;

	keep dbgap_subject_id visday
	     age sex_n race_c wgt hgt_cm bmi sysbp diabp
	     diab hrx currsmk fasting_bg tc hdl trig ldl creat
		  anycholmed statin insulin aspirin
        afib educlev genhlth hxcvd hxhrtd hxmi lvh
		  carsten alcohol fruits vegetables state sodium fh_stroke fam_income
		  activity;
run;

proc sort data=aric_ex1;
   by dbgap_subject_id;
run;

* Strokes Post Exam 1;
data aric_post_exam1_stroke;
	set aric_stroke_events;
	by dbgap_subject_id;

	if first.dbgap_subject_id;

   rename days_since_exam1=t2stroke;
	keep dbgap_subject_id days_since_exam1;
run;

data aricdata_exam1;
	attrib study length=$10. label="Study";
	attrib exam length=$6. label="Exam";

	merge aric_ex1(in=a1)
	      aric_base_cvd(in=bcvd)
         aric_base_stroke(in=bstk)
			aric_ex4_time
			aric_post_exam1_stroke(in=stk)
			aric_followup;
    by dbgap_subject_id;

	 study = "ARIC";
	 exam = "EXAM1";

    * Select Observations included;
	 if a1=1 & bstk=0 & censday > visday;

	 * Time from Exam 1 to Exam 4;
	 if exam4day ^= . then time1_4 = exam4day;

	 * If missed Exam 4 then impute with full follow-up;
	 if time1_4 = . then time1_4 = censday;

	 * Flag for Time to Exam 4 imputed;
	 time1_4_imputed = (exam4day = .);

	 * History of CHD;
	 if bcvd=1 then hx_chd=1;
	 else hx_chd=0;

	 * Stroke Events;
	 if stk=1 & t2stroke < time1_4 then stroke = 1;

    else do;
		 stroke = 0;
		 t2stroke = min(time1_4,censday + 1);
	    end;

   label time1_4 = "Time to next included exam"
	      time1_4_imputed = "Time to next included exam imputed? (1=Yes)"
			stroke = "Any stroke during follow-up"
			t2stroke = "Time to stroke during follow-up";

   format bmi 5.1;
   rename time1_4=time_to_next time1_4_imputed=time_to_next_i visday=days_since_exam1;
   drop exam4day;
run;

* Exam 4: History of TIA at Exam 4;
data aric_tia_ex4;
	set aric_o.pht004200_v2_stroke41;
	if tia41="Y";
	keep dbGaP_Subject_ID;
run;

proc sort data=aric_tia_ex4;
	by dbGaP_Subject_ID;
run;

* @@@@ EXAM 4 @@@@;
* Variables at Exam 4;
data aric_ex4;
	set aric.pheno_aric(where=(visit="EXAM4" & visday ^= .));

   * In ARIC exam 4, all glucoses are fasting;
   rename glucose=fasting_bg cholmed=anycholmed diabetes=diab;

	keep dbgap_subject_id visday
	     age sex_n race_c wgt hgt_cm bmi sysbp diabp
	     diab hrx currsmk glucose tc hdl trig ldl creat
		  anycholmed statin insulin aspirin
        afib genhlth2 hxcvd hxhrtd hxmi lvh
		  carsten alcohol fruits vegetables state sodium fam_income
		  activity;
run;

proc sort data=aric_ex4;
	by dbgap_subject_id;
run;

* Exclude due to history of stroke between exam 1 and exam 4;
data aric_hx_stroke_exam4(keep=dbgap_subject_id) aric_post_exam4_stroke(keep=dbgap_subject_id days_since_exam1);
   merge aric_stroke_events(in=s)
	      aric_ex4_time;
   by dbgap_subject_id;

	if s=1 then do;
		if .z < days_since_exam1 <= exam4day then output aric_hx_stroke_exam4;
		if days_since_exam1 > exam4day then output aric_post_exam4_stroke;
	   end;
run;

proc sort data=aric_hx_stroke_exam4 nodupkey;
	by dbgap_subject_id;
run;

* History of CHD;
data aric_hx_chd_exam4;
   merge aric_chd_events(in=s)
	      aric_ex4_time;
   by dbgap_subject_id;

	if s=1 & .z < days_since_exam1 < exam4day;
   keep dbgap_subject_id;
run;

proc sort data=aric_hx_chd_exam4 nodupkey;
	by dbgap_subject_id;
run;

* Strokes Post Exam 4;
proc sort data=aric_post_exam4_stroke;
	by dbgap_subject_id days_since_exam1;
run;

data aric_post_exam4_stroke;
	set aric_post_exam4_stroke;
	by dbgap_subject_id;

	if first.dbgap_subject_id;

   rename days_since_exam1=t2stroke0;
	keep dbgap_subject_id days_since_exam1;
run;

* Education: Only Collected in Exam 1, to be used in Exam 4;
data aric_educ;
   set aric.pheno_aric(where=(visit="EXAM1" & visday ^= .));
   keep dbgap_subject_id educlev;
run;

proc sort data=aric_educ;
   by dbgap_subject_id;
run;

* General Health (Exam 5);
data aric_genhlth5;
   set aric.pheno_aric(where=(visit="EXAM5"));
   keep dbgap_subject_id genhlth2;
run;

proc sort data=aric_genhlth5;
   by dbgap_subject_id;
run;

* Family History of Stroke (Not Available in Exam 4, we use Exam 1);
data aric_fhs_ex4;
	set aric.pheno_aric(where=(visit="EXAM1" & visday ^= .));

	keep dbgap_subject_id fh_stroke;
run;

proc sort data=aric_fhs_ex4;
	by dbgap_subject_id;
run;

data aricdata_exam4;
	attrib study length=$10. label="Study";
	attrib exam length=$6. label="Exam";

	merge aric_ex4(in=a4)
         aric_educ
         aric_genhlth5
	      aric_base_cvd(in=bcvd)
         aric_base_stroke(in=bstk)
			aric_hx_stroke_exam4(in=hxs)
			aric_tia_ex4(in=hxt)
			aric_hx_chd_exam4(in=hxc)
			aric_post_exam4_stroke(in=stk)
			aric_fhs_ex4
			aric_followup;
    by dbgap_subject_id;

	 study = "ARIC";
	 exam = "EXAM4";

    * Select Observations included;
	 if a4=1 & bstk=0 & hxs=0 & hxt=0 & censday > visday;

	 * History of CHD;
	 if hxc=1 | bcvd=1 then hx_chd=1;
	 else hx_chd=0;

	 * Stroke Events;
	 if stk=1 then do;
		 stroke = 1;
		 t2stroke = t2stroke0 - visday + 1;
	    end;

    else do;
		 stroke = 0;
		 t2stroke = censday - visday + 1;
	    end;

   label stroke = "Any stroke during follow-up"
			t2stroke = "Time to stroke during follow-up"
			hx_chd = "History of CHD";

   format bmi 5.1;
   rename visday=days_since_exam1;
   drop t2stroke0 censday;
run;

* MESA: EXAM 1;
* Follow-Up time;
data mesa_followup;
	set mesa.pheno_mesa(where=(visit="EXAM1"));
	keep dbgap_subject_id censday;
run;

proc sort data=mesa_followup;
	by dbgap_subject_id;
run;

* CVD history at enrollment (Exam 1);
data mesa_base_cvd;
	set mesa.pheno_mesa;
	if base_cvd="YES";
	keep dbgap_subject_id;
run;

proc sort data=mesa_base_cvd;
	by dbgap_subject_id;
run;

* Strokes;
data mesa_stroke_events;
   set mesa.cv_events(where=(event_desc in ("DEATH - STROKE","STROKE - ALL CAUSE","STROKE - HEMORRHAGIC",
                                            "STROKE - ISCHEMIC","STROKE - NEC")));
   if event_val_c="YES";
   keep dbgap_subject_id event_desc days_since_exam1;
run;

proc sort data=mesa_stroke_events;
	by dbgap_subject_id days_since_exam1;
run;

* CHD;
data mesa_chd_events;
   set mesa.cv_events(where=(event_desc="CORONARY HEART DISEASE (CHD), HARD"));
   if event_val_c="YES";
   keep dbgap_subject_id event_desc days_since_exam1;
run;

proc sort data=mesa_chd_events;
	by dbgap_subject_id days_since_exam1;
run;

* Genral Health (Exam 2);
data mesa_genhlth;
   set mesa.pheno_mesa(where=(visit="EXAM2" & visday ^= .));
   keep dbgap_subject_id genhlth2;
run;

proc sort data=mesa_genhlth;
   by dbgap_subject_id;
run;

* @@@@ EXAM 1 @@@@;
* Variables at Exam 1;
data mesa_ex1;
	set mesa.pheno_mesa(where=(visit="EXAM1" & visday ^= .));

	keep dbgap_subject_id visday
	     age sex_n race_c wgt hgt_cm bmi sysbp diabp
	     diab hrx currsmk fasting_bg tc hdl trig ldl creat
		  anycholmed statin nonstatin insulin aspirin
        afib educlev hxcvd hxhrtd hxmi lvh
		  valvdis carsten fam_income alcohol state fh_stroke
		  vegetables fruits sodium activity;
run;

proc sort data=mesa_ex1;
	by dbgap_subject_id;
run;

* Strokes Post Exam 1;
data mesa_post_exam1_stroke;
	set mesa_stroke_events;
	by dbgap_subject_id;

	if first.dbgap_subject_id;

   rename days_since_exam1=t2stroke;
	keep dbgap_subject_id days_since_exam1;
run;

data mesadata_exam1;
	attrib study length=$10. label="Study";
	attrib exam length=$6. label="Exam";

	merge mesa_ex1(in=m1)
         mesa_genhlth
	      mesa_base_cvd(in=bcvd)
			mesa_post_exam1_stroke(in=stk)
			mesa_followup;
    by dbgap_subject_id;

	 study = "MESA";
	 exam = "EXAM1";

    * Select Observations included;
	 if m1=1 & censday > visday;

    * History of CVD;
    hx_chd=bcvd;

	 * Stroke Events;
	 if stk=1 then stroke = 1;

    else do;
		 stroke = 0;
		 t2stroke = censday + 1;
	    end;

   label stroke = "Any stroke during follow-up"
			t2stroke = "Time to stroke during follow-up";

   format bmi 5.1;
   rename visday=days_since_exam1;
run;

data merged;
	retain dbgap_subject_id study exam days_since_exam1
	       age sex_n race_c wgt hgt_cm bmi sysbp diabp
			 diab hrx hx_chd currsmk tc hdl trig ldl bg fasting_bg creat
	       anycholmed statin nonstatin statnonstat
			 aspirin insulin
          afib educlev hxcvd hxhrtd hxmi lvh genhlth genhlth2
          valvdis carsten fam_income alcohol fruits vegetables activity activity_alt
			 state
			 stroke t2stroke
			 ;

	set offdata_exam3
	    offdata_exam6
		 offdata_exam8
		 aricdata_exam1
		 aricdata_exam4
		 mesadata_exam1;

	if age >= 45;

	if study="OFFSPRING" then do;
		if exam="EXAM3" then cohort=1;
		else if exam="EXAM6" then cohort=2;
		else if exam="EXAM8" then cohort=3;
	   end;
	else if study="ARIC" then do;
		if exam="EXAM1" then cohort=4;
		else if exam="EXAM4" then cohort=5;
	   end;
	else if study="MESA" then cohort=6;

   ldl_calc = tc - hdl - (trig/5);
   if ldl_calc <= 0 then ldl_calc=.;
   if ldl <= 0 then ldl=.;
	if trig > 400 then ldl_calc=.;
	ldl_calc = round(ldl_calc,1);

   t2stroke_yrs = t2stroke / 365.25;

   * Stroke Censored at 10 Years;
   if stroke=1 & t2stroke_yrs <= 10 then do;
      stroke10=1;
      t2stroke10=t2stroke;
      t2stroke10_yrs=t2stroke_yrs;
   end;

   else do;
      stroke10=0;
      t2stroke10=min(t2stroke,3653);
      t2stroke10_yrs=min(t2stroke_yrs,10);
      end;

   * Stroke Censored at 12 Years;
   if stroke=1 & t2stroke_yrs <= 12 then do;
      stroke12=1;
      t2stroke12=t2stroke;
      t2stroke12_yrs=t2stroke_yrs;
   end;

   else do;
      stroke12=0;
      t2stroke12=min(t2stroke,4383);
      t2stroke12_yrs=min(t2stroke_yrs,12);
      end;

   * Framingham Offspring Exam 3: None on Statins;
   if cohort=1 then statin=0;

   label ldl_calc="LDL-C (calculated)"
         t2stroke_yrs="Time (in years) to Stroke/Censoring"
         stroke10="Any stroke in first 10 years of follow-up"
         t2stroke10="Time to Stroke/Censoring in first 10 years"
         t2stroke10_yrs="Time (in years) to Stroke/Censoring in first 10 years"
         stroke12="Any stroke in first 12 years of follow-up"
         t2stroke12="Time to Stroke/Censoring in first 12 years"
         t2stroke12_yrs="Time (in years) to Stroke/Censoring in first 12 years"
         cohort="Cohort: 1=Off3 2=Off6 3=Off8 4=ARIC1 5=ARIC4 6=MESA1"
         genhlth="General Health (4 Levels)"
         genhlth2="General Health (5 Levels)";

   drop censday time_to_next time_to_next_i;
run;

data merged;
   attrib usubjid length=$15.;
   set merged(rename=(hxcvd=hxcvd1 hxhrtd=hxhrtd1 hxmi=hxmi1));

   if hxcvd1="YES" then hxcvd=1;
   else if hxcvd1="NO" then hxcvd=0;

   if hxhrtd1="YES" then hxhrtd=1;
   else if hxhrtd1="NO" then hxhrtd=0;

   if hxmi1="YES" then hxmi=1;
   else if hxmi1="NO" then hxmi=0;

	* Set DBP=0 to missing;
	if diabp=0 then diabp=.;

	* Alcohol Categorical Variable;
	if alcohol=0 then alcohol_cat=0;
	else if alcohol > 0 then do;
		if sex_n=1 then do;
			if alcohol > 14 then alcohol_cat=2;
			else if 0 < alcohol <= 14 then alcohol_cat=1;
		   end;
      else if sex_n=0 then do;
			if alcohol > 7 then alcohol_cat=2;
			else if 0 < alcohol <= 7 then alcohol_cat=1;
		   end;
		end;

   * Unique Subject ID;
   if study="OFFSPRING" then do;
      if exam="EXAM3" then usubjid="O-3-" || put(dbgap_subject_id,z7.0);
      else if exam="EXAM6" then usubjid="O-6-" || put(dbgap_subject_id,z7.0);
      else if exam="EXAM8" then usubjid="O-8-" || put(dbgap_subject_id,z7.0);
      end;

   else if study="ARIC" then do;
      if exam="EXAM1" then usubjid="A-1-" || put(dbgap_subject_id,z7.0);
      else if exam="EXAM4" then usubjid="A-4-" || put(dbgap_subject_id,z7.0);
      end;

   else if study="MESA" then usubjid="M-1-" || put(dbgap_subject_id,z7.0);

   rename dbgap_subject_id=original_id;

   label hxcvd="History of Cardiovascular Disease (0=No 1=Yes)"
         hxhrtd="History of Heart Disease (0=No 1=Yes)"
         hxmi="History of Myocardial Infarction"
			alcohol_cat="Alcohol (Categorical), 0=No Alcohol, 1=Mild/Moderate, 2=Heavy";

   drop hxcvd1 hxhrtd1 hxmi1 bg;
run;

* Compute Quintiles of Distributions by Cohort;
proc univariate data=merged noprint;
	by cohort;
	var fruits;
	output out=fru_q pctlpts=(20 40 60 80) pctlpre=f_;
run;

proc univariate data=merged noprint;
	by cohort;
	var vegetables;
	output out=veg_q pctlpts=(20 40 60 80) pctlpre=v_;
run;

proc univariate data=merged noprint;
	by cohort;
	var sodium;
	output out=sod_q pctlpts=(20 40 60 80) pctlpre=s_;
run;

data merged;
	merge merged
	      fru_q
			veg_q
			sod_q;
   by cohort;

	* Quintiles;
	if 1 <= cohort <= 6 then do;
		if 0 <= fruits <= f_20 then fruits_q = 1;
		else if f_20 < fruits <= f_40 then fruits_q = 2;
		else if f_40 < fruits <= f_60 then fruits_q = 3;
		else if f_60 < fruits <= f_80 then fruits_q = 4;
		else if f_80 < fruits         then fruits_q = 5;

		if 0 <= vegetables <= v_20 then vegetables_q = 1;
		else if v_20 < vegetables <= v_40 then vegetables_q = 2;
		else if v_40 < vegetables <= v_60 then vegetables_q = 3;
		else if v_60 < vegetables <= v_80 then vegetables_q = 4;
		else if v_80 < vegetables         then vegetables_q = 5;
	   end;

	if cohort ^= 1 then do;
		if 0 <= sodium <= s_20 then sodium_q = 1;
		else if s_20 < sodium <= s_40 then sodium_q = 2;
		else if s_40 < sodium <= s_60 then sodium_q = 3;
		else if s_60 < sodium <= s_80 then sodium_q = 4;
		else if s_80 < sodium         then sodium_q = 5;
	   end;

   * Income Category;
	if 1 <= fam_income <= 10 then income_cat=1;
	else if 11 <= fam_income <= 18 then income_cat=2;
	else if 19 <= fam_income <= 22 then income_cat=3;
	else income_cat=9;

   sex = 2 - sex_n;

	format alcohol_cat alc. fruits_q vegetables_q sodium_q qui. income_cat inc.;
	drop sex_n f_: v_: s_:;
run;

* Add REGARDS data;
data merged;
	set merged
	    mydata.regards_v3;

   * Weight Impossible Values;
	if wgt < 60 then wgt=.;

	if hdl < 10 or hdl > 140 then hdl=.;
	if ldl_calc < 20 then ldl_calc=.;

	* Make Health One Variable;
	if cohort in (2,4) then do;
		if genhlth = 1 then health=genhlth;
		if genhlth > 1 then health=genhlth+1;
	   end;
   else if cohort in (3,5,6,7) then health=genhlth2;

	* Removing Other Races;
	if race_c not in ("Black","White") then delete;

	* History of TIA already excluded from pheno_regards;

   * Stroke Censored at 12 Years;
   if stroke=1 & t2stroke_yrs <= 12 then do;
      stroke12=1;
      t2stroke12=t2stroke;
      t2stroke12_yrs=t2stroke_yrs;
   end;

   else do;
      stroke12=0;
      t2stroke12=min(t2stroke,4383);
      t2stroke12_yrs=min(t2stroke_yrs,12);
      end;

   * Region;
	if state in ("ME","MA","RI","CT","NH","VT","NY","PA","NJ","DE","MD") then region=1;
	else if state in ("WV","VA","KY","TN","NC","SC","GA","AL","MS","AR","LA","FL","DC") then region=2;
	else if state in ("OH","IN","IL","MI","WI","MO","MN","IA","KS","NE","SD","ND") then region=3;
	else if state in ("TX","OK","NM","AZ") then region=4;
	else if state in ("CO","WY","MT","ID","WA","OR","UT","NV","CA","HI") then region=5;

	* Activity Alternative for Non-Offspring cohorts, copies;
	if cohort > 3 then activity_alt=activity;

   drop genhlth genhlth2;
   format region reg. health genhelb.;
run;

data mydata.stroke_risk_ads_v4;
   set merged;
run;
