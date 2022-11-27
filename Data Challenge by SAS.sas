/* Pre-requisite */

/* Create 2 libraries, named "data_sas" and "practice" that reference to the folders "Datasets - SAS" and "Datasets - Practice" in your own personal folder */
/* Import all the files in xlsx format that are in the folder "Datasets - Practice" that you will need to use: airbnb_mod; melbourne_weather */

libname data_sas "/home/u49540231/awinnie/DP using SAS/datasets/Datasets - SAS";
libname practice "/home/u49540231/awinnie/DP using SAS/datasets/Datasets - Practice"; 

%web_drop_table(PRACTICE.Airbnb_mod);


FILENAME REFFILE '/home/u49540231/awinnie/DP using SAS/datasets/Datasets - Practice/Airbnb_mod.xlsx';

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=PRACTICE.Airbnb_mod;
	GETNAMES=YES;
RUN;

PROC CONTENTS DATA=PRACTICE.Airbnb_mod; RUN;


%web_open_table(PRACTICE.Airbnb_mod);


%web_drop_table(PRACTICE.melbourne_weather);


FILENAME REFFILE '/home/u49540231/awinnie/DP using SAS/datasets/Datasets - Practice/melbourne_weather.xlsx';

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=PRACTICE.melbourne_weather;
	GETNAMES=YES;
RUN;

PROC CONTENTS DATA=PRACTICE.melbourne_weather; RUN;


%web_open_table(PRACTICE.melbourne_weather);


***********************************************************;

/* Exercise 1 */

/* Write a new program that creates a temporary table named Mammal from the np_species table (data_sas). */
/* The table mammal should only include rows for which Category is equal to "Mammal"   */ 
/* Do not include Abundance, Seasonality, or Conservation_Status in the output table. */ 
/* Use the appropriate procedure to determine how many mammal species there are for each unique value of Record_Status. Submit the program. */
/* Confirm that the percentage of mammal species that have a Record_Status value of Approved is 90.22% */ 

data work.Mammal;
    set data_sas.np_species;
    where Category="Mammal";
    drop Abundance Seasonality Conservation_Status;
run;

proc freq data=work.Mammal;
	tables Record_Status;
run;

/* Modify the program to use a macro variable, named "Type" in place of the value Mammal so you can analyze other values of Category.
		Use the macro variable also to rename the table:
			In the DATA step, you can use the expression 
			******	data &Macro_name (no need of quotation marks here) *****/
/* Change the macro variable value to "Amphibian" and run the program.  */
/* Confirm that the overall frequency of Amphibian species is 743 and that 619 are approved */

%let Type = Amphibian;

data &Type;
    set data_sas.np_species;
    where Category="&Type";
    drop Abundance Seasonality Conservation_Status;
run;

proc freq data = &Type;
	tables Record_Status;
run;



***********************************************************;

/* Exercise 2 */

/* Write a DATA step to create a temporary table named eu_occ_total that is based on eu_occ table (data_sas). */
/* Create the following new columns: */
/* 		Year: the four-digit year extracted from YearMon (Notice that YearMon is a character variable, so you should use functions for character variables (use SUBSTR())) */
/*			The syntax of SUBSTR is: SUBSTR(variable, position, length), where length defines the length of the substring to extract*/
/* 		Month: the two-digit month extracted from YearMon */
/* 		ReportDate: the first day of the reporting month. Note: Use the function MDY() and the new Year and Month columns. For day, simply use the number 1. */
/* 		Total: the total nights spent at any establishment */
/* Format Hotel, ShortStay, Camp, and Total with commas. Format ReportDate to display the values in the form 01JAN2018. */
/* Keep Country, Hotel, ShortStay, Camp, ReportDate, and Total in the new table. */
/* Submit the program and view the output data. */
/* Confirm that the value of ReportDate in row one is 01SEP2017 */

data work.eu_occ_total;
    set data_sas.eu_occ;
    Year=substr(YearMon,1,4);
    Month=substr(YearMon,6,2);
    ReportDate=mdy(Month,1,Year);
    Total=Hotel + ShortStay + Camp;
    format Hotel ShortStay Camp Total COMMA10.;
    format ReportDate Date9.;
    Keep Country Hotel ShortStay Camp ReportDate Total;
run;



***********************************************************;

/* Exercise 3 */

/* Create a new temporary table named np_summary2 that is based on np_summary (data_sas). */
/* Use the SCAN function to create a new column named ParkType that is the last word in the ParkName column.  */
/*		SCAN syntax: SCAN(column, count), where count is the number of the word in the character string that you want SCAN to select.
		Use a negative number for the second argument to count words from right to left in the character string.
/* Keep Reg, Type, ParkName, and ParkType in the output table. */
/* Submit the program and view the output data. */
/* Confirm that the value of ParkType in row four is Preserve; */

data work.np_summary2;
    set data_sas.np_summary;
    ParkType=scan(ParkName, -1);
    keep Reg Type ParkName ParkType;
run;



***********************************************************;

/* Exercise 4 */

/* Create a temporary table named airbnb_city based on airbnb_mod (practice), such that it contains only rows for which zipcode is between 2000 and 2100 (included). */
/* Create a new variable Review_scores2 equal to 
		(review_scores_accuracy + 
		review_scores_cleanliness + 
		review_scores_checkin + 
		review_scores_communication + 
		review_scores_location + 
		review_scores_value)/60*100 */
/* Create a new variable Review_diff equal to the absolute value of Review_scores2 - review_scores_rating. Use the function abs() */
/* Format review_diff and review_scores2 in order to include a comma and 2 decimals; */

data work.airbnb_city;
    set practice.airbnb_mod;
    where zipcode >= 2000 and zipcode <= 2100;
    Review_scores2 = (review_scores_accuracy + review_scores_cleanliness + review_scores_checkin + review_scores_communication + review_scores_location + review_scores_value)/60*100;
    Review_diff = abs(Review_scores2 - review_scores_rating);
    format Review_diff Review_scores2 COMMA8.2;
run;


/* Produce detailed statistics of the variable weekly_diff. */ 
/* Confirm that there are 3 missing values */ 

proc univariate data=work.airbnb_city;
	var Review_diff;
run;


/* Remove rows having missing values for the variable review_diff*/
/* Re-produce detailed statistics of the same variable and confirm that the highest value is now 16.6667 */

data work.Review_diff;
	set work.airbnb_city;
	where Review_diff is not null;
run;

proc univariate data=work.airbnb_city;
	var Review_diff;
run;



***********************************************************;

/* Exercise 5 */

/* Create a new temporary table named Melbourne_weather2 from the table Melbourne_weather (practice) */
/* The new table should not contain any duplicate. Create a table named Melbourne_weather2_dup to store the duplicate rows. */
/* Also only keep the variables Date, City, MinTemp, MaxTemp, Rainfall. */
/* Create a new variable RangeTemp equal to MaxTemp - MinTemp */
/* Format the Date variable as 01MAY2020 */
/* Confirm that there are no duplicates in the dataset */

data work.Melbourne_weather2_notsorted;
    set practice.Melbourne_weather;
run;

proc sort data=work.Melbourne_weather2_notsorted out=work.Melbourne_weather2;
	by _all_;
run;


proc sort data=work.Melbourne_weather2 out=work.Melbourne_weather2_nodup
	dupout=Melbourne_weather2_dup
	noduprecs;
	by _all_;
run;

/* No duplicated found */

data work.Melbourne_weather2;
	set practice.Melbourne_weather;
    keep Date City MinTemp MaxTemp Rainfall RangeTemp;
	RangeTemp = MaxTemp - MinTemp;
	format Date DATE9.;
run;



***********************************************************;

/* Exercise 6 */

/* Explore the dataset shoes in the library sashelp */
/* Use the appropriate procedure to verify that: */
/*  15.70% of the products are from the Region Western Europe  */
/*  3.54% of the products are from the Region Asia */
/*  13.16% of the products are Boots and the same amount are Slippers */
/*  11.39% of the products are Men's Casual */

data work.sashelp_shoes;
	set sashelp.shoes;
run;

proc freq data=work.sashelp_shoes;
	table Region;
run;

proc freq data=work.sashelp_shoes;
	table product;
run;

/* Create a temporary table named shoes_sales from the table shoes in the library sashelp */
/* Do not copy the variable Subsidiary */
/* Only keep rows that have more than 1 store */
/* Create a performance index named Perf_sales equal to (Sales - Returns) and divide it by the number of stores */
/* Format the new variable using a dollar format with 2 decimal points */
/* Confirm that for the first row the values of Perf_sales is $2,416.00 */

data work.shoes_sales;
	set sashelp.shoes;
	drop Subsidiary;
	where Stores > 1;
	Perf_sales = (Sales - Returns)/Stores;
	format Perf_sales DOLLAR10.2;
run;


/* Sort the new table by Perf_sales to see which product and in which region has the highest index. */
/* Confirm that  it is Men's Casual and the region is Middle East */

proc sort data=work.shoes_sales; 
	by descending Perf_sales;
run;



/* Use the appropriate procedure to find out which region has the highest mean score.  */
/* Simply add the statement BY within the appropriate procedure to calculate the statistics by Region; */
/* Note you have to Sort the table by Region before running the other procedure */
/* Verify that Middle East has the largest mean index and it is equal to 13862.06 */

proc sort data=work.shoes_sales;
	by Region;
run;

proc means data=work.shoes_sales;
	var Perf_sales;
	by Region;
run;




***********************************************************;