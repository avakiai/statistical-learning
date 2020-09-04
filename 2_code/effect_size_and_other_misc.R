# Power Analysis for N - SL Paper
# Ava Kiai

library(pwr)
# Source: https://www.statmethods.net/stats/power.html
# We use the population correlation coefficient as the effect size measure. 
# Cohen suggests that r values of 0.1, 0.3, and 0.5 represent small, medium, and large effect sizes respectively.

# Batterink 2015
# Exp 1: 24
# Exp 2: 25
# Batteirnk 2017
# Group 1: 24
# Group 2: 21 (online only, for EEG power)

# Correlation between word recognition and RT score based on B. 2017
pwr.r.test(n = 24, r = 0.51, sig.level = 0.05)
# >> Power = 0.74, thus quite a large effect size

# .... if we set power to the following... 
pwr.r.test(power = 0.8, r = 0.51, sig.level = 0.05)
pwr.r.test(power = 0.9, r = 0.51, sig.level = 0.05)
# >> Power of 0.8 should require 27 participants, 0.9 should require 36. 


# Based on B. 2015:
pwr.r.test(n = 24, r = .07, sig.level = 0.05)

powers <- c(0.1,0.3,0.5,0.7,0.9)

samplesizes <- array(numeric(length(powers)))
  
for (i in 1:length(powers)) {
  N <- pwr.r.test(power = powers[i], r = .07, sig.level = 0.05)
  samplesizes[i] <- N
}

lines(powers, samplesizes, col="pink")

# If indeed the effect size/correlation is 0.07, then it would not be 
# reasonable to attempt this, as the required N to get to 0.8 power 
# would be >1500. 

# ----------
# We can't do a power analysis for the RT effect because the effect size for those analyses is not reported. We
# can however, do one on our own Experiment 1. 

