* class7.sas
  written by Steve Simon
  October 28, 2018;

** preliminaries **;

%let path=/folders/myfolders;
%let xpath=c:/Users/simons/Documents/SASUniversityEdition/myfolders;

ods pdf file="&path/survival-lecture7/sas/class7.pdf";

libname survival
  "&path/data";
  
data survival.crack1;
  infile "&path/data/crack1.txt";
  input t0 t1 n;
run;

proc print
    data=survival.crack1(obs=5);
  title1 "Partial listing of crack1 data";
run;


proc lifereg
    data=survival.crack1;
  model (t0, t1)= / distribution=exponential;
  output
    out=prob0
    cdf=exp_prob;
  weight n;
  title "Exponential fit to crack1 data";
run;

proc print
    data=exp_mod1;
  title1 "Parameter estimates for exponential model";
run;

data prob0;
  set prob0;
  if t0 = . then delete;
  keep t0 exp_prob;
run;

data prob1;
  set survival.crack1;
  if t1 = . then delete;
  t0=t1;
  np=n;
  keep t0 np;
run;

data prob2;
  set survival.crack1;
  if t0 = . then delete;
  nq=n;
  keep t0 nq;
run;

data prob3;
  merge prob0 prob1 prob2;
  by t0;
  observed_p = np / (np + nq);
run;

proc print data=prob3;
  title1 "Comparison of observed and predicted probabilities";
run;

proc sgplot
    data=prob3;
  scatter x=t0 y=observed_p;
  series x=t0 y=exp_prob;
run;

data survival.crack2;
  infile "&path/data/crack2.txt";
  input t0 t1 n c;
run;

proc print
    data=survival.crack2(obs=5);
  title1 "Partial listing of crack2 data";
run;

proc lifereg
    data=survival.crack2;
  model (t0, t1)= / distribution=exponential;
  output
    out=prob4
    cdf=exp_prob;
  weight n;
  title "Exponential fit to crack2 data";
run;

data prob4;
  set prob4;
  if t0 ^= .;
  t=t0;
  keep t exp_prob;
run;

data prob5;
  set survival.crack2;
  if t1 = . then delete;
  t=t1;
  observed_p = c / 167;
  keep t n observed_p;
run;

proc print
    data=prob4;
run;

proc print
    data=prob5;
run;

data prob6;
  merge prob4 prob5;
  by t;
run;

proc print
    data=prob6;
  title "Comparison of observed and predicted probabilities";
run;

proc sgplot
    data=prob6;
  scatter x=t y=observed_p;
  series x=t y=exp_prob;
run;

ods pdf close;
