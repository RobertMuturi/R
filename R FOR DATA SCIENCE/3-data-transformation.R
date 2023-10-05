library(nycflights13)
library(tidyverse)
library(ggplot2)

# flights is a tibble, a special type of data frame used by the tidyverse to avoid some common gotchas. 
# The most important difference between tibbles and data frames is the way tibbles print; 
# they are designed for large datasets.

# We are using the dplyr package to transform the dataframe 
# Because each verb does one thing well, solving complex problems will 
# usually require combining multiple verbs, and we’ll do so with the pipe, |>.
# The pipe takes the thing on its left and passes it along to the function on its right 

flights %>% 
  filter(dest == "IAH") %>% 
  group_by(year, month, day) %>% 
  summarise(
    arr_delay = mean(arr_delay, na.rm = TRUE)
  )


#ROWS
#FILTER

# filter() This keeps rows based on the value of columns. 
# flights that departed more than 120 minutes late 
flights %>% 
  filter(dep_delay >120)

#combine with other operator
#flights that departed jan 1
flights %>% 
  filter(month == 1 & day == 1)

#flights that departed jan and feb
flights %>% 
  filter(month == 1 | month == 2)

#shortcut
flights %>% 
  filter(month %in% c(1, 2))

#using assignment operator in filtering
jan1 <- flights %>% 
  filter(month == 1 & day == 1)


#ARRANGE
#changes order of rows based on column

flights %>% 
  arrange(year, month, day, dep_time)

#you can use desc() to arrange in descending order 
flights %>% 
  arrange(desc(dep_time))

# DISTINCT
#finds unique rows in the dataset, one can optionally supply column names
flights %>% 
  distinct()

flights %>% 
  distinct(origin, dest)

#if to keep all columns
flights %>% 
  distinct(origin, dest, .keep_all = TRUE)


#Exercise
#pipeline with several conditions
filtered <- flights %>% 
  filter(arr_delay >= 2, 
         dest == "HOU" | dest == "IAH",
         carrier == "UA" | carrier == "DL",
         month >= 7 & month <= 9,
         arr_delay >= 2 & dep_delay <=0)

#sort flights with longest departure delays and left earliest
sorted_delay <- flights %>% 
  arrange(dep_time & dep_delay)

#fastest flight
fast_flight <- flights %>% 
  arrange(arr_time - dep_time)

#was there a flight everyday of 2013
flights %>% 
  distinct(day, month)

#traveled least distance
least_dist <- flights %>% 
  arrange(distance)

#traveled farthest distance
far_dist <- flights %>% 
  arrange(desc(distance))



#COLUMNS
# mutate() creates new columns that are derived from the existing columns, 
# select() changes which columns are present, 
# rename() changes the names of the columns, and 
# relocate() changes the positions of the columns.


#MUTATE
# compute the gain, how much time a delayed flight made up in the air, 
# and the speed in miles per hour:

flights %>% 
  mutate(
    gain = dep_delay - arr_delay,
    speed = distance / air_time * 60
  )

#put .before to see the columns on left hand side
flights %>% 
  mutate(
    gain = dep_delay - arr_delay,
    speed = distance / air_time * 60,
    .before = 1
  )

#we can also do .after
flights %>% 
  mutate(
    gain = dep_delay - arr_delay,
    speed = distance / air_time * 60,
    .after = day
  )

# you can control which variables are kept with the .keep argument. 
# A particularly useful argument is "used" which specifies that we only 
# keep the columns that were involved or created in the mutate()

flights %>% 
  mutate(
    gain = dep_delay - arr_delay,
    hours = air_time / 60,
    gain_per_hour = gain / hours,
    .keep = "used"
  )
#data not stored unless assigned

#SELECT
#zoom in on useful subset

#select by name
flights %>% 
  select(year, month, day)

#select columns between year and day
flights %>% 
  select(year:day)

#select columns except those of year to day
flights %>% 
  select(!year:day)

#select columns that are characters
flights %>% 
  select(where(is.character))

# There are a number of helper functions you can use within select():
# starts_with("abc"): matches names that begin with “abc”.
# ends_with("xyz"): matches names that end with “xyz”.
# contains("ijk"): matches names that contain “ijk”.
# num_range("x", 1:3): matches x1, x2 and x3.


#you can rename as you select
flights %>% 
  select(tail_num = tailnum)


#RENAME
#renaming variables
flights %>% 
  rename(tail_num = tailnum)

# If you have a bunch of inconsistently named columns and it would be painful to fix them all by hand, 
# check out janitor::clean_names() which provides some useful automated cleaning.

#RELOCATE
#You can move related variables together
flights %>% 
  relocate(time_hour, air_time)

#you can specify by .before or .after
flights %>% 
  relocate(year:dep_time, .after = time_hour)
flights %>% 
  relocate(starts_with("arr"), .before = dep_time)


#EXERCICES
# Compare dep_time, sched_dep_time, and dep_delay
flights %>% 
  select(dep_time:dep_delay)

flights %>% 
  select(any_of(variables <- c("year", "month", "day", "dep_delay", "arr_delay")))

flights |> select(contains("time"))

flights %>% 
  rename(air_time_min = air_time) %>% 
  relocate(air_time_min)

## THE PIPE
#can be used to combine multiple functions
flights %>% 
  filter(dest == "IAH") %>% 
  mutate(speed = distance / air_time *60) %>% 
  select(year:day, dep_time, carrier, flight, speed) %>% 
  arrange(desc(speed))

##GROUPS
#GROUP_BY
flights |> 
  group_by(month)

#SUMMARIZE
#this calculates a single statistic into a single row for each group
flights |> 
  group_by(month) |> 
  summarise(
    avg_delay = mean(dep_delay)
  )
# the avg_delay is Na due to missing values to ignore them:
flights |> 
  group_by(month) |> 
  summarise(
    avg_delay = mean(dep_delay, na.rm = TRUE)
  )

#you can create a number of summaries, a useful one to return the number of rows in each group
flights |> 
  group_by(month) |> 
  summarise(
    avg_delay = mean(dep_delay, na.rm = TRUE),
    n = n()
  )

#SLICE_ FUNCTIONS

# There are five handy functions that allow you extract specific rows within each group:
#   
# df |> slice_head(n = 1) takes the first row from each group.
# df |> slice_tail(n = 1) takes the last row in each group.
# df |> slice_min(x, n = 1) takes the row with the smallest value of column x.
# df |> slice_max(x, n = 1) takes the row with the largest value of column x.
# df |> slice_sample(n = 1) takes one random row.

# You can vary n to select more than one row, or instead of n =, 
# you can use prop = 0.1 to select (e.g.) 10% of the rows in each group. 
# For example, the following code finds the flights that are most delayed upon arrival at each destination:

flights |> 
  group_by(dest) |> 
  slice_max(arr_delay, n=1) |> 
  relocate(dest)

# Note that there are 105 destinations but we get 108 rows here. What’s up? 
#   slice_min() and slice_max() keep tied values so n = 1 means give us all rows with 
# the highest value. If you want exactly one row per group you can set with_ties = FALSE.
# This is similar to computing the max delay with summarize(), but you get the whole 
# corresponding row (or rows if there’s a tie) instead of the single summary statistic.

#GROUPING WITH MULTIPLE VARIABLES
daily <- flights |> 
  group_by(year, month, day)
daily

#to show the grouping
daily_flights = daily |> 
  summarise(n = n())

#request it in order to suppress the message
daily_flights = daily |> 
  summarise(
    n = n(),
    .groups = "drop_last"
    )
daily_flights

# Alternatively, change the default behavior by setting a different value, 
# e.g., "drop" to drop all grouping or "keep" to preserve the same groups.

#UNGROUP
daily |> 
  ungroup()

#when you summarise
daily |> 
  ungroup() |> 
  summarise(
    avg_delay = mean(dep_delay, na.rm = TRUE),
    flights = n()
  )

#You get a single row back because dplyr treats 
#all the rows in an ungrouped data frame as belonging to one group.

#.BY
#The package has a  new and experimental operation called .by to 
#group within a single operation

flights |> 
  summarise(
    delay = mean(dep_delay, na.rm = TRUE),
    n = n(),
    .by = month
  )

#for multiple variables
flights |> 
  summarise(
    delay = mean(dep_delay, na.rm = TRUE),
    n = n(),
    .by = c(origin, dest)
  )


# Exercices ---------------------------------------------------------------
#Which carrier has the worst delays
flights |> 
  group_by(carrier) |> 
  summarise(
    ar_delay_m = mean(arr_delay, na.rm = TRUE),
    dep_delay_me = mean(dep_delay, na.rm = TRUE),
    n = n()
  ) |> 
  arrange(n, ar_delay_m)

#flights most delayed upon departure
flights |> 
  group_by(dest) |> 
  summarise(
    avg_delay = mean(dep_delay, na.rm = TRUE),
    n = n()
  ) |> 
  arrange(desc(avg_delay))

#plot how delays vary over the course of the day
delay_day <-  flights |> 
  group_by(time_hour) |> 
  summarise(
    avg_delay = mean(dep_delay, na.rm = TRUE)
  )

ggplot(
  data = delay_day,
  mapping = aes(y = avg_delay, x = time_hour)
)+
  geom_smooth()

#what does n=-1
flights |> 
  group_by(dest) |> 
  slice_min(arr_delay, n=-1) |> 
  relocate(dest)