* birds.sas
  written by Steve Simon
  October 30, 2018;

** preliminaries **;

%let path=/folders/myfolders;
%let xpath=c:/Users/simons/Documents/SASUniversityEdition/myfolders;

ods pdf file="&path/survival-lecture7/sas/birds.pdf";

libname survival
  "&path/data";
  
* This data set uses the start/stop coding to 
  allow the use of two time varying covariates,
  lowtemp and snowdep. These vary from day to
  day, but since the birds are observed on
  the same time scale, the two time varying
  covariates are constant across birds. This
  causes problems with a Cox model, but you 
  can get reasonable estimates from a 
  parametric model.
;
  
data survival.birds;
  infile "&path/data/birds.csv" firstobs=2 dlm=",";
  input 
    birdno
    months
    dead
    age
    weight
    t1
    t2
    season $
    status
    lowtemp
    snowdep
    nestsucc
    broodsucc;
run;

proc print
    data=survival.birds(obs=5);
  title1 "Partial listing of birds data";
run;

* There are 60 bird-days of time at risk from day 0 
  through day 5, when two deaths are recorded. Then
  there are 16 bird-days of exposure until day 7, 
  when two more birds die. Then there are 24
  bird-days of exposure until day 11, when one
  more bird dies.
  
  Across the entire day range, you have 100 bird-days
  and 5 deaths.
;

proc freq
    data=survival.birds;
  table t1*status /
      norow nocol nopercent;
  title1 "Event count by day";
run;

* The semi-parametric Cox model cannot provide an
  estimate for either of the two time-varying
  covariates, because all the degrees of freedom
  are soaked up by the estimation of the baseline
  hazard.
;

proc phreg
    data=survival.birds;
  model (t1, t2)*status(0)=snowdep;
  title1 "Model with a time varying covariate";
run;

* This plot shows that the time varying covariate
  is constant across the individual birds.
;

proc sgplot
    data=survival.birds;
  series x=t1 y=snowdep / group=birdno;
  title1 "Plot of snow depth over time for each bird";
run;

* A parametric model will help you here. First,
  fit a simple exponential model with no
  covariates.
;

proc lifereg
    data=survival.birds;
  model dt*status(0)= / 
    distribution=exponential;
  title1 "Baseline exponential model";
run;

* The intercept parameter here is consistent with
  5 recorded deaths across 100 bird-days. Note that
  exp(-2.944) = 0.05;


data indicators;
  set survival.birds;
   dt=1;
  i1 = ifn(t1 > 5, 1, 0);
  i2 = ifn(t1 > 7, 1, 0);
run;

* The indicator variables split up the time scale
  into 0-5 days, 6-7 days,and 8-11 days. The 
  hazard will differ across these three regions.
;

proc lifereg
    data=indicators;
  model dt*status(0)= i1 i2 / 
    distribution=exponential;
  title1 "Baseline exponential model";
run;

* The intercept term represents the hazard from 
  0-5 days, where there were 60 bird days and
  2 deaths. Note that exp(-3.4012) = 0.033.
  
  The intercept term plus the coefficient for
  i1 represents the hazard from 6 to 7 days,
  where there were 2 deaths across 16 patient
  days of risk. Note that
  
  exp(-(3.4012-1.3218))=0.125.
  
  The intercept term plus the two additional
  coefficients represents the hazard from
  8 to 11 days, when there were 24 bird days 
  of exposure with one death. Note that
  
  exp(-(3.4012-1.3218+1.0986))=0.0417.
;

proc lifereg
    data=survival.birds;
  model dt*status(0)= snowdep / 
    distribution=exponential;
  title1 "Baseline exponential model";
run;

* Rather than letting the hazrds vary freely
  across the three time intervals, you can 
  see if the changes in hazard are related
  to one of the time varying covariates. The
  data is too sparse to allow examination
  of both time varying covariates at the
  same time.
;

ods pdf close;
