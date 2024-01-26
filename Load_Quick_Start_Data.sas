/*******************************************************************************/
/*  Copyright © 2022, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved. */
/*  SPDX-License-Identifier: Apache-2.0                                        */
/*******************************************************************************/


/******************************************************************/
/* Run this program to load the HOME_EQUITY and CUSTOMER_COMMENTS */
/*     table used the SAS Viya Quick Start Videos.                */
/******************************************************************/

%macro loadQuickStart;
    /* Create copy of HOMEEQUITY in quick-start folder */

    %let fileName = %scan(&_sasprogramfile,-1,'/');
    %let path = %sysfunc(tranwrd(&_sasprogramfile, &fileName,));
    libname outlib "&path";

    %if %sysfunc(exist(sashelp.homeequity)) %then %do;
        %put NOTE: HOME_EQUITY in-memory table loaded from SASHELP.HOMEEQUITY;
        data outlib.home_equity;
		    set sashelp.homeequity;
		run;
    %end;

    %else %do;
        
		filename data TEMP;
        %put NOTE: HOME_EQUITY in-memory table loaded from home_equity.csv on support.sas.com;
		proc http 
		   method="GET" 
		   url="https://support.sas.com/documentation/onlinedoc/viya/exampledatasets/home_equity.csv" 
		   out=data;
		run;
		
		/*  Import home_equity.csv and create WORK.HOMEEQUITY */
		proc import file="data" dbms=csv out=outlib.home_equity replace;
		    guessingrows=5960;
		run;
		
		proc datasets lib=outlib memtype=data nolist;
		    modify home_equity;
		    label APPDATE="Loan Application Date"
		          BAD="Loan Status"
		          CITY="City"
		          CLAGE="Age of Oldest Credit Line (months)"
		          CLNO="Number of Credit Lines"
		          DEBTINC="Debt to Income Ratio"
		          DELINQ="Number of Delinquent Credit Lines"
		          DEROG="Number of Derogatory Reports"
		          DIVISION="Division"
		          JOB="Job Category"
		          LOAN="Amount of Loan Request"
		          MORTDUE="Amount Due on Existing Mortgage"
		          NINQ="Number of Recent Credit Inquiries"
		          REASON="Loan Purpose"
		          REGION="Region"
		          STATE="State"
		          VALUE="Value of Current Property"
		          YOJ="Years at Present Job";
		    format APPDATE date9.
		           CLAGE comma8.1
		           LOAN MORTDUE VALUE dollar12.
		           DEBTINC 8.1
		           BAD CITY CLNO DELINQ DEROG DIVISION JOB NINQ REASON REGION STATE YOJ;
		    attrib _all_ informat=;
		quit;
		
		filename data clear;	

    %end;

    /* Create copy of CUSTOMER_COMMENTS in quick-start folder */

	filename data TEMP;
	proc http 
	   method="GET" 
	   url="https://support.sas.com/documentation/onlinedoc/viya/exampledatasets/customer_comments.csv" 
	   out=data;
	run;
	
	/*  Import home_equity.csv and create WORK.HOMEEQUITY */
	proc import file="data" dbms=csv out=outlib.customer_comments replace;
	    guessingrows=10000;
	run;	
    filename data clear;

    /*  Load and promote HOME_EQUITY and CUSTOMER_COMMENTS into memory in the CASUSER caslib. */
    /*  Save HOME_EQUITY.sashdat in the CASUSER caslib so it is saved on disk.  */

    cas mysession;
    proc casutil;
        droptable casdata="home_equity" incaslib="casuser" quiet;
        droptable casdata="customer_comments" incaslib="casuser" quiet;

        load data=outlib.home_equity outcaslib="casuser" casout="home_equity" promote;
        load data=outlib.customer_comments outcaslib="casuser" casout="customer_comments" promote;

        save casdata="home_equity" incaslib="casuser" casout="home_equity" outcaslib="casuser" replace;
        list tables incaslib="casuser";
    quit;
    cas mysession terminate;

    libname outlib clear;

%mend loadQuickStart;

%loadQuickStart
