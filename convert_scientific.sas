*.   Last modified 08/01/2016;

options notes nomprint nomlogic symbolgen;
proc printto log = log; run;



******************************************************************************************************* ;
* 1  Convert scientific column to numeric if scientific found              
     %convert_scientific(<sas library name>, <sas table name>,<variable name> )                                                                                     last modified: 08/11/2015;
******************************************************************************************************* ;



%macro convert_scientific(lib_nme,table,variable);
	data &lib_nme..&table;
		set &lib_nme..&table;
		if prxmatch('/^-?[0-9]+(\.[0-9]+)?(e|E)(\+|-)[0-9]+/',&variable)>0 then do;
		   temp_num=input(&variable,best32.);
		   &variable=left(temp_num);
		   drop temp_num;
		   put  "WARNING: Obs " _n_ " of Variable &variable, scientific has been converted to numeric."; 
		end;

		if prxmatch('/^-?(\d)?(\d)?(\d)?(\,\d{3})+(\.[0-9])?/',&variable)>0 then do;           /* Also convert any comma style to numeric*/
		   temp_num2=input(&variable,comma12.);
		   &variable=left(temp_num2);
		   drop temp_num2;
		   put  "WARNING: Obs " _n_ " of Variable &variable, comma style has been converted to numeric."; 
		end;
	run; 


%mend;


%macro auto_convert_scientific(tbl_nme,lib_nme);
	proc sql noprint;
		 create table temp as select name from dictionary.columns where memname="&tbl_nme" and libname="&lib_nme";
	quit;

	data _null_;
	set temp;
	where name in('TEST_RESULT','RESULT','RESULT_N') ;     /*Add column names that needs to be converted*/ 
	call execute('%convert_scientific('||'&lib_nme,&tbl_nme,'||name||')');
	run;
%mend;

