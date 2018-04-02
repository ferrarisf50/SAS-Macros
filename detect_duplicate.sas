
PROC PRINTTO;
RUN;

options source source2 notes mprint mlogic symbolgen;


******************************************************************************************************* ;
* 1 * Detect duplicate value in allotment or sample collection           last modified: 07/25/2017; * ;
    *  Default is to detect duplicate (date,sampleid,test) for the current table;
    *  %detect_duplication( <duplicated key> , <table> )                                                                                     last modified: 08/11/2015;
    *  Require external scripts: Export_export.sas
******************************************************************************************************* ;
%MACRO detect_duplication(d_vars=date sampleid test,d_dataset);   
	%LOCAL key_var tmp_string; 

	PROC SORT DATA=&d_dataset OUT=dup_temp1 DUPOUT=dup_temp2 nodupkey;
	by &d_vars ;
	RUN;

	proc sort data=dup_temp2 out=dup_temp4 nodupkey;
	by &d_vars ;
	RUN;

	******************************************************************************************************* ;
	* Create a macro variable key_var  
	* In default, key_var is "a.date=b.date and a.sampleid=b.sampleid and a.test=b.test" ;
	******************************************************************************************************* ;
	DATA _NULL_;
		LENGTH key_var $1000;

		nvars=COUNTW("&d_vars",' ');
		%let tmp_string=TRIM(LEFT(SCAN("&d_vars",count,' ')));



		DO count=1 TO nvars; 
		IF count=1 THEN key_var="a."!!&tmp_string!!"=b."!!&tmp_string;
		ELSE key_var=TRIM(LEFT(key_var))!!" and a."!!&tmp_string!!"=b."!!&tmp_string;
		IF count=nvars THEN CALL SYMPUT('key_var',key_var); 
		OUTPUT;
		END;

	RUN;

	PROC SQL;
	create table dup_temp3 as select a.* from &d_dataset as a inner join dup_temp4 as b on &key_var ;
	QUIT;

	%include "Excel_export.sas";

	proc sql noprint;
		  select count(*) into: obs_count_dup_temp3 from dup_temp3;
	quit;



	%if &obs_count_dup_temp3>0 %then %do;  
	    proc sort data=dup_temp3;
		by &d_vars;
	    run;

		data dup_temp3;
			set dup_temp3;
		    drop trl a_order datasource;
		run;

	    %xcel_export(dup_temp3,&d_dataset._duplicates);
		%put WARNING: &obs_count_dup_temp3 row(s) found duplicate by &d_vars !;
	%end;


	proc sql;
		 drop table dup_temp1;
		 drop table dup_temp2;
		 drop table dup_temp3;
		 drop table dup_temp4;
	quit;


%MEND;

******************************************************************************************************* ;
* 2 * autorun_detect_duplication          last modified: 07/25/2017; * ;
    *    autorun_detect_duplication(<table>);                                                                                     last modified: 08/11/2015;

******************************************************************************************************* ;

%macro autorun_detect_duplication(table);
	%local auto_d_var;


	data _null_;
		auto_d_var="&used_cols";    /*&used_cols is defined in get_var_properties.sas"*/
		auto_d_var=prxchange('s/\b\w*result\w*\b//i', -1, auto_d_var);    /* Remove any variable associated with result */
		*auto_d_var=prxchange('s/\bx[0-9]*\b//i', -1, auto_d_var);     /* Remove any dummy variable name like x1 x2 x3 */
		auto_d_var=tranwrd(auto_d_var,"VALUE_DCF","");
		auto_d_var=tranwrd(auto_d_var,"TIME_UNIT","");
		auto_d_var=tranwrd(auto_d_var,"REF_RANGE_LOWER_N","");
		auto_d_var=tranwrd(auto_d_var,"REF_RANGE_UPPER_N","");
		auto_d_var=tranwrd(auto_d_var,"WEIGHT_N","");
		auto_d_var=tranwrd(auto_d_var,"WEIGHT_UNIT","");
		auto_d_var=prxchange('s/\b\w*dose\w*\b//i', -1, auto_d_var);


		call symput('auto_d_var',auto_d_var); 
	run;
	/*%put &auto_d_var;*/
	%detect_duplication(d_vars=&auto_d_var,d_dataset=&table);



%mend;



