* class7.sas
  written by Steve Simon
  October 28, 2018;

** preliminaries **;

%let path=/folders/myfolders;
%let xpath=c:/Users/simons/Documents/SASUniversityEdition/myfolders;

ods pdf file="&path/survival-lecture7/sas/hw7.pdf";

libname survival
  "&path/data";

* 1. Open the file, diabetes.csv.;

proc import
    datafile="&path/data/diabetes.csv"
    dbms=dlm
    out=survival.diabetes;
  delimiter=",";  
  getnames=yes;
run;

* a. Calculate and graph a Kaplan-Meier curve 
     comparing treated to untreated eyes, 
     ignoring for now the correlations 
     inherent in this data set. Does it appear
     as if these survival curves differ? If so,
     do they appear to violate the assumption 
     of proportional hazards?
;

proc lifetest
    notable
    plots=survival
    data=survival.diabetes;
  time time*status(0);
  strata treat / nodetail test=logrank;
  title2 "Comparison of treatment ignoring cluster effect";
run;
  
* The curves doe seem to differ, but do not 
  appear to violate the assumption of 
  proportional hazards.
;

* b. Calculate and interpret a Cox regression
     model using treat as an independent 
     variable and id as a cluster effect.
;

proc phreg
    data=survival.diabetes;
  model time*status(0)=treat;
  id id;
  title2 "Cluster (marginal) model";
run;

* There is a statistically significant treatment 
  effect, even after allowing for the correlation
  within subjects.
;

* c. Calculate and interpret a Cox regression 
     model using treat as an independent 
     variable and id as a frailty effect.
;

proc phreg
    data=survival.diabetes;
  class id;
  model time*status(0)=treat;
  random id;
  title2 "Frailty (random) model";
run;

* This model has a similar interpretation. Normally,
  you don't fit both a cluster and a frailty model.
  It is better to pick one prior to data collection
  and stick with it.
;
  
ods pdf close;
