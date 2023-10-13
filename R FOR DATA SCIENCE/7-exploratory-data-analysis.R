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

unusual


# Exercise
# Explore the distribution of each of the x, y, and z variables in diamonds. What do you learn?
summary(select(diamonds, x, y, z))

ggplot(diamonds, aes(x = x)) +
  geom_histogram(binwidth = 0.01)

ggplot(diamonds, aes(x = y)) +
  geom_histogram(binwidth = 0.01)

filter(diamonds, x == 0 | y == 0 | z == 0)

ggplot(diamonds, aes(x = z)) +
  geom_histogram(binwidth = 0.01)

filter(diamonds, x == 0 | y == 0 | z == 0)

diamonds %>%
  arrange(desc(y)) %>%
  head()


#Explore the distribution of price. Do you discover anything unusual or surprising?

ggplot(filter(diamonds, price < 2500), aes(x = price)) +
  geom_histogram(binwidth = 10, center = 0)

ggplot(filter(diamonds), aes(x = price)) +
  geom_histogram(binwidth = 100, center = 0)

diamonds %>%
  mutate(ending = price %% 1000) %>%
  filter(ending >= 500, ending <= 800) %>%
  ggplot(aes(x = ending)) +
  geom_histogram(binwidth = 1)

# How many diamonds are 0.99 carat? How many are 1 carat? What do you think is the cause of the difference?
diamonds |> 
  filter(carat >= 0.99, carat <= 1) |> 
  count(carat)

# Compare and contrast coord_cartesian() vs xlim() or ylim() when zooming in 
# on a histogram. What happens if you leave binwidth unset? What happens if you 
# try and zoom so only half a bar shows?

ggplot(diamonds, aes(x = price)) +
  geom_histogram() +
  coord_cartesian(xlim = c(100, 5000), ylim = c(0, 3000))

ggplot(diamonds, aes(x = price)) +
  geom_histogram() +
  xlim(100, 5000) +
  ylim(0, 3000)


# UNUSUAL VALUES ----------------------------------------------------------

#If there are unusual values, there are two options

# drop the entire row (not recommended, unless data quality is low)
diamonds2 <- diamonds |> 
  filter(between(y, 3, 20))

#replace unusual values with missing values

diamonds2 <- diamonds |> 
  mutate(y = if_else(y < 3 | y > 20, NA, y))

ggplot(diamonds2, aes(x =x, y = y)) +
  geom_point()
# To suppress that warning, set na.rm = TRUE:

# Other times you want to understand what makes observations with missing values 
# different to observations with recorded values. For example, in nycflights13::flights1, 
# missing values in the dep_time variable indicate that the flight was cancelled. 
# So you might want to compare the scheduled departure times for cancelled and 
# non-cancelled times. You can do this by making a new variable, using is.na() to 
# check if dep_time is missing.


nycflights13::flights |> 
  mutate(
    cancelled = is.na(dep_time),
    sched_hour = sched_dep_time %/% 100,
    sched_min = sched_dep_time %% 100,
    sched_dep_time = sched_hour + (sched_min / 60)
  ) |> 
  ggplot(aes(x = sched_dep_time)) + 
  geom_freqpoly(aes(color = cancelled), binwidth = 1/4)


# COVARIATION -------------------------------------------------------------

# If variation describes the behavior within a variable, covariation describes 
# the behavior between variables. Covariation is the tendency for the values of 
# two or more variables to vary together in a related way. The best way to spot
# covariation is to visualize the relationship between two or more variables.

# A CATEGORICAL AND NUMERICAL VARIABLE
ggplot(diamonds, aes(x = price)) +
  geom_freqpoly(aes(color = cut), binwidth = 500, linewidth = 0.75)

ggplot(diamonds, aes(x = price, y = after_stat(density))) +
  geom_freqpoly(aes(color = cut), binwidth = 500, linewidth = 0.75)

ggplot(diamonds, aes(x = cut, y = price)) +
  geom_boxplot()


ggplot(mpg, aes(x = class, y = hwy)) +
  geom_boxplot()

#reorder based on median value
ggplot(mpg, aes(x = fct_reorder(class, hwy, median), y = hwy)) +
  geom_boxplot()

#flipping the plot
ggplot(mpg, aes(x = hwy, y = fct_reorder(class, hwy, median))) +
  geom_boxplot()


#Exercise
#boxplot of cancelled flights
nycflights13::flights %>%
  mutate(
    cancelled = is.na(dep_time),
    sched_hour = sched_dep_time %/% 100,
    sched_min = sched_dep_time %% 100,
    sched_dep_time = sched_hour + sched_min / 60
  ) %>%
  ggplot() +
  geom_boxplot(mapping = aes(y = sched_dep_time, x = cancelled))



# TWO CATEGORICAL VARIABLES -----------------------------------------------

# To visualize the covariation between categorical variables, you’ll need to 
# count the number of observations for each combination of levels of these 
# categorical variables. One way to do that is to rely on the built-in geom_count():

ggplot(diamonds, aes(x = cut, y = color)) +
  geom_count()

# Another approach for exploring the relationship between these variables is computing the counts with dplyr:
diamonds |> 
  count(color, cut)

#visualise with geom_tile
diamonds |> 
  count(color, cut) |> 
  ggplot(aes(x = color, y = cut)) +
  geom_tile(aes(fill = n))


#Exercise
#rescale to make the above plot more clear
diamonds %>%
  count(color, cut) %>%
  group_by(color) %>%
  mutate(prop = n / sum(n)) %>%
  ggplot(mapping = aes(x = color, y = cut)) +
  geom_tile(mapping = aes(fill = prop))

diamonds %>%
  count(color, cut) %>%
  group_by(cut) %>%
  mutate(prop = n / sum(n)) %>%
  ggplot(mapping = aes(x = color, y = cut)) +
  geom_tile(mapping = aes(fill = prop))


# Use geom_tile() together with dplyr to explore how average flight delays 
# vary by destination and month of year

nycflights13::flights %>%
  group_by(month, dest) %>%
  summarise(dep_delay = mean(dep_delay, na.rm = TRUE)) %>%
  ggplot(aes(x = factor(month), y = dest, fill = dep_delay)) +
  geom_tile() +
  labs(x = "Month", y = "Destination", fill = "Departure Delay")

nycflights13::flights %>%
  group_by(month, dest) %>%                                 # This gives us (month, dest) pairs
  summarise(dep_delay = mean(dep_delay, na.rm = TRUE)) %>%
  group_by(dest) %>%                                        # group all (month, dest) pairs by dest ..
  filter(n() == 12) %>%                                     # and only select those that have one entry per month 
  ungroup() %>%
  mutate(dest = reorder(dest, dep_delay)) %>%
  ggplot(aes(x = factor(month), y = dest, fill = dep_delay)) +
  geom_tile() +
  labs(x = "Month", y = "Destination", fill = "Departure Delay")


# TWO NUMRICAL VARIABLES --------------------------------------------------

ggplot(smaller, aes(x = carat, y = price)) +
  geom_point()

ggplot(smaller, aes(x = carat, y = price)) + 
  geom_point(alpha = 1 / 100)

# geom_bin2d() and geom_hex() divide the coordinate plane into 2d bins and 
# then use a fill color to display how many points fall into each bin. 
# geom_bin2d() creates rectangular bins. geom_hex() creates hexagonal bins.

ggplot(smaller, aes(x = carat, y = price)) +
  geom_bin2d()

ggplot(smaller, aes(x = carat, y = price)) +
  geom_hex()

ggplot(smaller, aes(x = carat, y = price)) + 
  geom_boxplot(aes(group = cut_width(carat, 0.1)))

#EXERCISE
# Instead of summarizing the conditional distribution with a box plot, 
# you could use a frequency polygon. What do you need to consider when 
# using cut_width() vs cut_number()? How does that impact a visualization
# of the 2d distribution of carat and price?

ggplot(
  data = diamonds,
  mapping = aes(color = cut_number(carat, 5), x = price)
) +
  geom_freqpoly() +
  labs(x = "Price", y = "Count", color = "Carat")

ggplot(
  data = diamonds,
  mapping = aes(color = cut_width(carat, 1, boundary = 0), x = price)
) +
  geom_freqpoly() +
  labs(x = "Price", y = "Count", color = "Carat")


# Visualize the distribution of carat, partitioned by price.

ggplot(diamonds, aes(x = cut_number(price, 10), y = carat)) +
  geom_boxplot() +
  coord_flip() +
  xlab("Price")

ggplot(diamonds, aes(x = cut_width(price, 2000, boundary = 0), y = carat)) +
  geom_boxplot(varwidth = TRUE) +
  coord_flip() +
  xlab("Price")

#Combine two of the techniques you’ve learned to visualize the combined 
#distribution of cut, carat, and price.

ggplot(diamonds, aes(x = cut_number(carat, 5), y = price, color = cut)) +
  geom_boxplot()


ggplot(diamonds, aes(colour = cut_number(carat, 5), y = price, x = cut)) +
  geom_boxplot()



# PATTERNS AND MODELS -----------------------------------------------------

# Patterns in your data provide clues about relationships, i.e., they reveal covariation
# Models are a tool for extracting patterns out of data

library(tidymodels)

diamonds <- diamonds |> 
  mutate(
    log_price = log(price),
    log_carat = log(carat)
  )

diamonds_fit <- linear_reg() |> 
  fit(log_price ~ log_carat, data = diamonds)

diamonds_aug <- augment(diamonds_fit, new_data = diamonds) |> 
  mutate(.reside = exp(.resid))

ggplot(diamonds_aug, aes(x = carat, y = .resid)) +
  geom_point()

ggplot(diamonds_aug, aes(x = cut, y = .resid)) + 
  geom_boxplot()
