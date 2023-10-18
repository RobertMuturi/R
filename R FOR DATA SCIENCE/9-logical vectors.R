library(tidyverse)
library(nycflights13)


# COMPARISONS -------------------------------------------------------------

#common way to create a logical vector is via a numeric comparison with <, <=, >, >=, !=, and ==

#All daytime depatures that arrive on time
flights |> 
  filter(dep_time > 600 & dep_time < 2000 & abs(arr_delay <20))

# this is a shortcut and you can explicitly create the underlying logical variables with mutate()
flights |> 
  mutate(
    daytime = dep_time > 600 & dep_time < 2000,
    appro_ontime = abs(arr_delay) < 20,
    .keep = "used"
  )

# initial filter is equivalent to:
flights |> 
  mutate(
    daytime = dep_time > 600 & dep_time < 2000,
    approx_ontime = abs(arr_delay) < 20,
  ) |> 
  filter(daytime & approx_ontime)


#1 floating point comparisons

# Beware of using == with numbers. e.g, it looks like this vector contains the numbers 1 and 2:
x <- c(1 / 49 * 49, sqrt(2) ^ 2)
x

# But if you test them for equality, you get FALSE:
x == c(1, 2)

# One option is to use dplyr::near() which ignores small differences:
near(x, c(1, 2))

#3 is.na()
# is.na(x) works with any type of vector and returns TRUE for missing values and FALSE for everything else:
#We can use is.na() to find all the rows with a missing dep_time:

flights |> 
  filter(is.na(dep_time))

# is.na() can also be useful in arrange(). arrange() usually puts all the missing values at the end but 
# you can override this default by first sorting by is.na():


flights |> 
  filter(month == 1, day == 1) |> 
  arrange(dep_time) #default

flights |> 
  filter(month == 1, day == 1) |> 
  arrange(desc(is.na(dep_time)), dep_time) #na values at the top

#Exercise
#how are dep_time, sched_dep_time & dep_deplay connected
flights %>%
  mutate(
    dep_time_na = is.na(dep_time),
    sched_dep_time_na = is.na(sched_dep_time),
    dep_delay_na = is.na(dep_delay)
  ) %>%
  count(dep_time_na, sched_dep_time_na, dep_delay_na)

# BOOLEAN ALGEBRA ---------------------------------------------------------

# n R, & is “and”, | is “or”, ! is “not”, and xor() is exclusive or

flights |> 
  filter(month == 11 | month == 12)

#%in%
#x %in% y returns a logical vector the same length as x that is TRUE whenever a value in x is anywhere in y .

1:12 %in% c(1, 5, 12)

letters[1:10] %in% c("a", "e", "i", "o", "u")


# flights in November and December we could write
flights |> 
  filter(month %in% c(11, 12))

flights |> 
  filter(dep_time %in% c(NA, 0800))

#exercise
#all flights where arr delay is missing but dep delay is not

flights |> 
  filter(is.na(arr_delay) & !is.na(dep_delay) )

# Find all flights where neither arr_time nor sched_arr_time are missing, but arr_delay is.
flights |> 
  filter(!is.na(arr_time | sched_arr_time) & is.na(arr_delay))

flights %>%
  filter(!is.na(arr_time) & !is.na(sched_arr_time) & is.na(arr_delay))

# How many flights have a missing dep_time? What other variables are missing in these rows? 
# What might these rows represent?

flights |> 
  filter(is.na(dep_time)) |> 
  count()
  
# dep_time implies that a flight is cancelled, look at the number of cancelled flights per day
flights %>%
  mutate(
    dep_time_na = is.na(dep_time),
    sched_dep_time_na = is.na(sched_dep_time),
    dep_delay_na = is.na(dep_delay)
  ) %>%
  filter(dep_time_na == TRUE) %>%
  group_by(year, month, day) %>%
  summarize(n_cancelled = n())

# average delay of non-cancelled flights
flights %>%
  filter(!is.na(dep_delay)) %>%
  summarize(avg_delay = mean(dep_delay))


# SUMMARIES ---------------------------------------------------------------

#1  Logical summaries
# There are two main logical summaries: any() and all()

# we could use all() and any() to find out if every flight was delayed on departure 
# by at most an hour or if any flights were delayed on arrival by five hours or more. 
# And using group_by() allows us to do that by day:


flights |> 
  group_by(year, month, day) |> 
  summarise(
    all_delayed = all(dep_delay <= 60, na.rm = TRUE), #make the missing values go away with na.rm = TRUE.
    any_long_delay = any(arr_delay >= 300, na.rm = TRUE),
    .groups = "drop"
  )

#2 Numeric summaries of logical vectors


# When you use a logical vector in a numeric context, TRUE becomes 1 and FALSE becomes 0. 
# This makes sum() and mean() very useful with logical vectors because sum(x) gives the number 
# of TRUEs and mean(x) gives the proportion of TRUEs (because mean() is just sum() divided by length().


# lets see the proportion of flights that were delayed on departure by at most an hour 
# and the number of flights that were delayed on arrival by five hours or more:

flights |> 
  group_by(year, month, day) |> 
  summarise(
    all_delayed = mean(dep_delay <= 60, na.rm = TRUE),
    any_long_delay = sum(arr_delay >= 300, na.rm = TRUE),
    .groups = "drop"
  )

#3 Logical subsetting
# you can use a logical vector to filter a single variable to a subset of interest.

# Imagine we wanted to look at the average delay just for flights that were actually delayed. 
# One way to do so would be to first filter the flights and then calculate the average delay:


flights |> 
  filter(arr_delay > 0) |> 
  group_by(year, month, day) |> 
  summarise(
    behind = mean(arr_delay),
    n = n(),
    .groups = "drop"
  )

