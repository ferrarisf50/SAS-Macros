

/*options notes nomprint nomlogic symbolgen;*/
proc printto log = log; run;

******************************************************************************************************* ;
* 1  Detect if any truncation might exist in a table.             
     %detect_truncation( <table name> , <library name> )                                                                                   last modified: 08/11/2015;
******************************************************************************************************* ;




%macro max_length_of_variable(variable,num,table);
     
       proc sql noprint;
	          select max(length(&variable)) into: max_length_&num from &table;
       quit;
	   

%mend;
 
%macro detect_if_truncation_might_exist(variable,length,num);

        %if &&max_length_&num=&length %then 
             %put WARNING: Truncation might occur in variable &variable ;  
/*       %symdel max_length_&num;*/
%mend;

%macro detect_truncation(table,lib_nme);

	proc sql noprint;
		 create table t2 as select name,length from dictionary.columns where memname="&table" and libname="&lib_nme" and type="char";
	quit; 

	data _null_;
	      set t2; 
	      where name not in ('TRL','A_ORDER','DATASOURCE','FORMID');
	      call execute ('%max_length_of_variable('!!name!!','!!_n_!!','||'&lib_nme..&table)');

	run;
	 
	data _null_;
	      set t2; 
		  where name not in ('TRL','A_ORDER','DATASOURCE','FORMID');
	      call execute ('%detect_if_truncation_might_exist('!!name!!','!!length!!','!!_n_!!')');
		 
	run;

%mendl
