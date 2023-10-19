library(tidyverse)
library(nycflights13)


# MAKING NUMBERS ----------------------------------------------------------

# In most cases, you’ll get numbers already recorded in one of R’s numeric types: integer or double. In some cases, 
# however, you’ll encounter them as strings,
# readr provides two useful functions for parsing strings into numbers: parse_double() and parse_number(). 
# Use parse_double() when you have numbers that have been written as strings:

x <- c("1.2", "5.6", "1e3")
parse_double(x)

# Use parse_number() when the string contains non-numeric text that you want to ignore
x <- c("$1,234", "USD 3,513", "59%")
parse_number(x)


# COUNTS ------------------------------------------------------------------
#his function is great for quick exploration and checks during analysis:

flights |> count(dest)

# If you want to see the most common values, add sort = TRUE:

flights |> count(dest, sort = TRUE)

# if you want to see all the values, you can use |> View() or |> print(n = Inf).

# You can perform the same computation “by hand” with group_by(), summarize() and n(). 
# This is useful because it allows you to compute other summaries


flights |> 
  group_by(dest) |> 
  summarize(
    n = n(),
    delay = mean(arr_delay, na.rm = TRUE)
  )

# n() is a special summary function that doesn’t take any arguments and instead accesses 
# information about the “current” group. This means that it only works inside dplyr verbs:

# There are a couple of variants of n() and count()
# n_distinct(x) counts the number of distinct (unique) values of one or more variables. 
# E.g we could figure out which destinations are served by the most carriers:

flights |> 
  group_by(dest) |> 
  summarise(carriers = n_distinct(carrier)) |> 
  arrange(desc(carriers))

# A weighted count is a sum. For example you could “count” the number of miles each plane flew:

flights |> 
  group_by(tailnum) |> 
  summarise(miles = sum(distance))

# count() has a wt argument that does the same thing:
flights |> count(tailnum, wt = distance)

# You can count missing values by combining sum() and is.na(). In the flights dataset this represents flights that are cancelled:
flights |> 
  group_by(dest) |> 
  summarise(n_cancelled = sum(is.na(dep_time)))

#exercise
# use count() to count the number rows with a missing value for a given variable
flights |> 
  count(is.na(arr_time))

flights |> 
  group_by(dest) |> 
  summarise(n = n()) |> 
  arrange(desc(n))

flights |> count(dest, sort = TRUE)


# NUMERICAL TRANSFORMATION ------------------------------------------------

#Arithmetic and recycling rule

# recycling rules which determine what happens when the left and right hand sides have different lengths.

 x<- c(1, 2, 10, 20)

x / 5
#is shorthand for 
x / c(5, 5, 5, 5)


# Minimum and maximum
#pmin() and pmax(), which when given two or more variables will return the smallest or largest value in each row:


df <- tribble(
  ~x, ~y,
  1,  3,
  5,  2,
  7, NA,
)

df |> 
  mutate(
    min = pmin(x, y, na.rm = TRUE),
    max = pmax(x, y, na.rm = TRUE)
  )

# Modular arithmetic
# n R, %/% does integer division and %% computes the remainder:

1:10 %/% 3
1:10 %% 3

# Modular arithmetic is handy for the flights dataset, because we can use it to 
# unpack the sched_dep_time variable into hour and minute:

flights |> 
  mutate(
    hour = sched_dep_time %/% 100,
    minute = sched_dep_time %% 100,
    .keep = "used"
  )

# We can combine that with the mean(is.na(x)) to see how the proportion of cancelled flights varies over the course of the day
flights |> 
  group_by(hour = sched_dep_time %/% 100) |> 
  summarise(prop_cancelled = mean(is.na(dep_time)), n = n()) |> 
  filter(hour > 1) |> 
  ggplot(aes(hour, prop_cancelled)) +
  geom_line(color = "grey50") +
  geom_point(aes(size = n))



# Rounding

round(123.456)

round(123.456, 2)  # two digits
round(123.456, 1)  # one digit
round(123.456, -1) # round to nearest ten
round(123.456, -2) # round to nearest hundred


# round() is paired with floor() which always rounds down and ceiling() which always rounds up:
x <- 123.456

floor(x)
ceiling(x)


# These functions don’t have a digits argument, so you can instead scale down, round, and then scale back up:
# Round down to nearest two digits
floor(x / 0.01) * 0.01

# Round up to nearest two digits
ceiling(x / 0.01) * 0.01

# Round to nearest multiple of 4
round(x / 4) * 4

# Round to nearest 0.25
round(x / 0.25) * 0.25


# Cutting numbers into ranges
# Use cut()1 to break up (aka bin) a numeric vector into discrete buckets:
x <- c(1, 2, 5, 10, 15, 20)

cut(x, breaks = c(0, 5, 10, 15, 20))

# The breaks don’t need to be evenly spaced:
cut(x, breaks = c(0, 5, 10, 100))

# The breaks don’t need to be evenly spaced:
cut(x, 
    breaks = c(0, 5, 10, 15, 20), 
    labels = c("sm", "md", "lg", "xl")
)

# Any values outside of the range of the breaks will become NA:
y <- c(NA, -10, 5, 10, 30)
cut(y, breaks = c(0, 5, 10, 15, 20))



