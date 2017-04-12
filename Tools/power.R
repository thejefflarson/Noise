# This fits a power function to the Quantcast statistics here:
# https://www.quantcast.com/top-sites/US?userView=Public

df <- read.csv("./rank-traffic.csv")

model <- lm(log(traffic) ~ log(rank), data=df)
summary(model)
model$coefficients