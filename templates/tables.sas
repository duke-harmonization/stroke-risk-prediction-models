libname template "/sigma/db0028_aristotle/CV185030/manu/arist103_heart_rate/programs/templates";

proc template;  
    define style grayborders / store=template.tables;   
    parent = styles.analysis;

   style Table /
      cellpadding = 3
      borderspacing = 0
      frame = box
      rules = all
      bordertopwidth = 1px
      borderleftwidth = 1px
      borderbottomwidth = 0px
      borderrightwidth = 0px
      bordercolor = lightgray
      bordercollapse = separate
      borderstyle = solid;
      end;
run;
