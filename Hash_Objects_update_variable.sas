
******************************************************************************************************* ;
* 1  Use Hash Objects to update a code_clinical_sign by looking for a key.                                                                                  last modified: 08/11/2015;
******************************************************************************************************* ;

proc printto;
run;
data add_code;
   if 0 then set tempdata;
   infile datalines dlm='|';
   input animal date clinical_sign term_diag code_clinical_sign  ; 
   ;
   keep animal date clinical_sign term_diag code_clinical_sign  ; 

datalines4;
10001|21-Dec-16|vomiting|GI upset probably due to change in food|1234
10002|22-Oct-16|vomiting bile at night once|vomiting bile|5678
;;;;
run;

data new_tempdata;
   if _n_ = 1 then do;
      declare hash lookup();
      _rc = lookup.definekey('animal', 'date', 'term_clinical_sign');
      _rc = lookup.definedata('code_clinical_sign');
      _rc = lookup.definedone();
   end;

   do until(eoflookup);
      set add_code end=eoflookup;
      _rc = lookup.add();
   end;

   do until(eofdosing);
      set tempdata end=eofdosing;
      _rc = lookup.find();
      output;
   end;

   drop _rc;
RUN;
