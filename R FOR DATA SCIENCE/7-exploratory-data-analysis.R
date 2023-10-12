library(tidyverse)

#The goal here in EDA is to develop an understanding of your data


# VARIATION ---------------------------------------------------------------

# Variation is the tendency of the values of a variable to change from measurement to measurement.
# Every variable has its own pattern of variation, which can reveal interesting information about 
# how that it varies between measurements on the same observation as well as across observations. 
# The best way to understand that pattern is to visualize the distribution of the variable’s values,

ggplot(diamonds, aes(x = carat)) +
  geom_histogram(binwidth = 0.5)


#TYPICAL VALUES

# To turn this information into useful questions, look for anything unexpected:
# Which values are the most common? Why?
# Which values are rare? Why? Does that match your expectations?
# Can you see any unusual patterns? What might explain them?

#   Let’s take a look at the distribution of carat for smaller diamonds.

smaller <- diamonds |> 
  filter(carat < 3)

ggplot(smaller, aes(x = carat)) +
  geom_histogram(binwidth = 0.01)


# UNUSUAL VALUES
# Outliers are observations that are unusual; data points that don’t seem to fit the pattern.

ggplot(diamonds, aes(x = y)) +
  geom_histogram(binwidth = 0.5)

# There are so many observations in the common bins that the rare bins are very short, 
# making it very difficult to see them

# To make it easy to see the unusual values, we need to zoom to small values of 
# the y-axis with coord_cartesian():

ggplot(diamonds, aes(x= y)) +
  geom_histogram(binwidth = 0.5) +
  coord_cartesian(ylim = c(0, 50))

# Coord_cartesian() also has an xlim() argument for when you need to zoom into the x-axis. 
# ggplot2 also has xlim() and ylim() functions that work slightly differently: they throw 
# away the data outside the limits.

#filter the unusual vaules

unusual <- diamonds |> 
  filter(y < 3 | y > 20) |> 
  select(price, x, y, z) |> 
  arrange(y)