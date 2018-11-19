* class7.sas
  written by Steve Simon
  October 28, 2018;

** preliminaries **;

%let path=/folders/myfolders;
%let xpath=c:/Users/simons/Documents/SASUniversityEdition/myfolders;

ods pdf file="&path/survival-lecture7/sas/class7.pdf";

libname survival
  "&path/data";

* 1. Open the file, diabetes.csv.

```{r load}
library(timereg)
data(diabetes)
head(diabetes)
diabetes_surv <- Surv(diabetes$time, diabetes$status)
```

I cheated here and took the file directly from the timereg library.

a. Calculate and graph a Kaplan-Meier curve comparing treated to untreated eyes, ignoring for now the correlations inherent in this data set. Does it appear as if these survival curves differ? If so, do they appear to violate the assumption of proportional hazards?

```{r km, fig.width=4.5, fig.height=2.5}
survfit(diabetes_surv~treat, data=diabetes) %>%
  tidy                                      %>%
  ggplot(aes(time, estimate, color=strata))  +
  expand_limits(y=0)                         +
  geom_step()
```

The curves doe seem to differ, but do not appear to violate the assumption of proportional hazards.

b. Calculate and interpret a Cox regression model using treat as an independent variable and id as a cluster effect.

```{r cluster}
coxph(
  diabetes_surv~treat+agedx+cluster(id),
  data=diabetes)
```

There is a statistically significant treatment effect, even after allowing for the correlation within subjects. The robust standard error appears to be slightly smaller, which means that accounting for the pairing has improved your precision.

c. Calculate and interpret a Cox regression model using treat as an independent variable and id as a frailty effect.

```{r frailty}
coxph(
  diabetes_surv~treat+agedx+frailty(id),
  data=diabetes)
```

Normally, you don't fit both a cluster and a frailty model. It is better to pick one prior to data collection and stick with it. Nevertheless, the conclusions remain largely the same.

;
  
ods pdf close;
