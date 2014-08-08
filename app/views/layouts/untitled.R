#This is the basic copper graph
plot(dat.fert$copper_ug_per_l, dat.fert$mean_value_prop, xlab="Copper (microM)", ylab="Proportion of fertilisation", ylim=c(0, 1))
ss <- seq(1, max(dat.fert$copper_ug_per_l), 1)

# You forgot to tell predict to return SE -- i.e., "se.fit=TRUE"
p1 <- predict(mod_fert_final, list(sediment_mg_per_l=rep(0, length(ss)), phosphorous_microM=rep(0, length(ss)), copper_ug_per_l=ss,  salinity_psu_sq=rep(35, length(ss))^2, salinity_psu=rep(35, length(ss))), type="response", se.fit=TRUE)

# Just the mean fit
lines(ss, p1$fit)

# Now calculate your se
lowerp1  <-  p1$fit - p1$se.fit
upperp1  <-  p1$fit + p1$se.fit

# Plot the upper (lines doesn't take type or ylim arguments, becase these are set in plot)
lines(ss, lowerp1, lty=2)
lines(ss, upperp1, lty=2)

# If you want to get fancy with polygon:

polygon(c(ss, rev(ss)), c(lowerp1, rev(upperp1)), border=NA, col=make.transparent('grey40', 0.2))


#This is my attempt at adding the CI to the copper graph
p1 <- predict(mod_fert_final, list(sediment_mg_per_l=rep(0, length(ss)), phosphorous_microM=rep(0, length(ss)), copper_ug_per_l=ss,  salinity_psu_sq=rep(35, length(ss))^2, salinity_psu=rep(35, length(ss))), type="response")

lowerp1  <-  p1$fit - p1$se.fit
upperp1  <-  p1$fit + p1$se.fit

polygon (c(ss, ss[length(ss)], ss[length(ss):1]), c(lowerp1, upperp1[length(upperp1)], upperp1[length(upperp1):1]), border=NA, col=make.transparent('grey40', 0.2))
lines(ss, p1$fit, type="l", ylim=c(0,1), col = "black")
