proc format;
 value educf
  1 = 'Less than High School'
  2 = 'High School'
  3 = 'Some College'
  4 = 'College';

 value genhel
  1 = 'Excellent'
  2 = 'Good'
  3 = 'Fair'
  4 = 'Poor';

 value genhelb
  1 = 'Excellent'
  2 = 'Very good'
  3 = 'Good'
  4 = 'Fair'
  5 = 'Poor';

 value faminc
  1 = 'less than $5,000'
  2 = '$5,000 to $9,000'
  5 = '$10,000 to $14,000'
  7 = '$15,000 to $19,000'
  10 = '$20,000 to $24,000'
  11 = '$25,000 to $29,000'
  13 = '$30,000 to $34,000'
  14 = '$35,000 to $39,000'
  16 = '$40,000 to $44,000'
  17 = '$45,000 to $49,000'
  19 = 'more than $50,000';

 value faminc1a
  1 = 'less than $5,000'
  3 = '$5,000 to $7,000'
  4 = '$8,000 to $11,000'
  6 = '$12,000 to $15,000'
  9 = '$16,000 to $24,000'
  12 = '$25,000 to $34,000'
  15 = '$35,000 to $49,000'
  19 = 'more than $50,000'
  99 = 'Refused';

 value faminc4b
  1 = 'less than $5,000'
  3 = '$5,000 to $7,000'
  4 = '$8,000 to $11,000'
  6 = '$12,000 to $15,000'
  9 = '$16,000 to $24,000'
  12 = '$25,000 to $34,000'
  15 = '$35,000 to $49,000'
  20 = '$50,000 to $74,000'
  21 = '$75,000 to $99,000 '
  22 = 'more than $100,000'
  99 = 'Refused';

  value alc
   0 = "No Alcohol"
   1 = "Mild/Moderate"
   2 = "Heavy";

  value qui
   1 = "1st Quintile"
   2 = "2nd Quintile"
   3 = "3rd Quintile"
   4 = "4th Quintile"
   5 = "5th Quintile";

  value inc
   1 = "< 25K"
   2 = "25-50K"
   3 = "> 50K"
   9 = "Missing/Refused";

  value reg
   1 = "Northeast"
   2 = "Southeast"
   3 = "Midwest"
   4 = "Southwest"
   5 = "West";

   value coh
   1 = "Offspring 3"
   2 = "Offspring 6"
   3 = "Offspring 8"
   4 = "ARIC 1"
   5 = "ARIC 4"
   6 = "MESA 1"
   7 = "REGARDS";

   value sex
   1 = Male
   2 = Female;

   value active
   1 = 'Inactive'
   2 = 'Slightly active'
   3 = 'Active';

run;
