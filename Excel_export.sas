PROC PRINTTO;
RUN;
OPTIONS NOTES MPRINT MLOGIC SYMBOLGEN;


******************************************************************************************************* ;
* 1  Export an EXCEL file on desktop if it is not empty              
     %xcel_export( <sas table name>,<export filename> )                                                                                     last modified: 08/11/2015;
******************************************************************************************************* ;

%MACRO xcel_export(ex_file,ex_rename);

%IF %SYSFUNC(EXIST(&ex_file)) %THEN %DO;
    %LOCAL nrow;
      PROC SQL NOPRINT;
        SELECT count(*) INTO : nrow
        FROM &ex_file;
      QUIT;

    %IF &nrow>0 %THEN %DO;
    PROC EXPORT DATA=&ex_file DBMS=xlsx REPLACE OUTFILE="C:\Users\&sysuserid\Desktop\&ex_rename";
    RUN;
    %END;
%END;
%ELSE %PUT '############  The table &ex_file does not exist!!!    #############';
%MEND xcel_export;
