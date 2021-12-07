# MBIE-min-wage-model
This project reviews the model used by MBIE in their [2020 minimum wage review](https://www.mbie.govt.nz/assets/minimum-wage-review-december-2020-redacted.pdf).

The OIA on which this review is based is available in the [OIA subfolder](OIA).

In my tweets, I made three claims. In this document I will substantiate each.

### 1) ``The model was trained on data from 1996 to 2017. If you instead train the model on data from 1996 to 2020, you find that higher minimum wages *create* jobs.''

In [code.txt](OIA/Code.txt), we see that the model MBIE use to predict the effect of minimum wage increases is


change in employment  =  
(  (proposed min wage ÷ forecast average hourly rate)
            - (current min wage ÷ current average hourly rate)
) ×  elasticity × population.

From code.txt, we have that:
- forecast average hourly rate = 1.009 × current average hourly rate
- current average hourly rate = 33.33
- current min wage = 18.90
- elasticity = -0.172
    
From page 59 of [the review](https://www.mbie.govt.nz/assets/minimum-wage-review-december-2020-redacted.pdf), we have that the population of all wage earners is 1914900.

Substituting these into the above equation, we calculate that the predicted change in employment from a $20 minimum wage is -9123 jobs. This matches page 7 of [the review](https://www.mbie.govt.nz/assets/minimum-wage-review-december-2020-redacted.pdf).

The elasticity of -0.172 comes from worksheet `M' of [this Excel document](https://github.com/wilburtownsend/MBIE-min-wage-model/blob/main/OIA/------'s%20work-13Feb2019.xlsx). It's not obvious from that document what the variable names mean, but from sleuthing around the rest of the OIA and comparing different data sources, I've concluded that the elasticity comes from a first-difference log regression of employment on the real minimum wage, GDP, lagged GDP and average earnings. That worksheet also specifies that only years 1996-2017 are used in the regression.

I replicate that regression in the Stata do file [replicate.do](replicate/replicate.do). When I use data from the years 1996-2017, I calculate an elasticity = -0.178, which is very similar to that calculated by MBIE. When I use data from the years 1996-2020, I calculate an elasticity = 0.017. This elasticity is greater than zero, implying that higher minimum wages increase employment.

