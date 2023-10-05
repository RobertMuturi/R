library(tidyverse)
library(ggplot2)

# Tidy data ---------------------------------------------------------------

table1
table2
table3

#table one is what you would describe as tidy data and is easier to work with
#rate per 10000
table1 |> 
  mutate(rate = cases / population * 10000)

#total cases per year
table1 |> 
  group_by(year) |> 
  summarise(total_cases = sum(cases))

#visualise over time 
ggplot(table1, aes(x = year, y = cases)) +
  geom_line(aes(group = country), color = "grey50") +
  geom_point(aes(color = country, shape = country)) +
  scale_x_continuous(breaks = c(1999, 2000))


# LENGTHENING DATA --------------------------------------------------------
# This is tidying data function called pivot and its in two fncts
#pivot_longer and pivot_wider

# DATA IN THE COLUMN NAMES 
billboard

#here the column names are one variable(the week) and cells are another(the rank)
#to tidy we use pivot_longer

billboard |> 
  pivot_longer(
    cols = starts_with("wk"),
    names_to = "week",
    values_to = "rank"
  )

#songs that were not in the top had na values so we need to get rid of them
billboard |> 
  pivot_longer(
    cols = starts_with("wk"),
    names_to = "week",
    values_to = "rank",
    values_drop_na = TRUE
  )

# we could make future computation a bit easier by converting values of week from 
# character strings to numbers using mutate() and readr::parse_number(). 
# parse_number() is a handy function that will extract the first number from a string, 
# ignoring all other text.

billboard_longer <- billboard |> 
  pivot_longer(
    cols = starts_with("wk"), 
    names_to = "week", 
    values_to = "rank",
    values_drop_na = TRUE
  ) |> 
  mutate(
    week = parse_number(week)
  )
billboard_longer

#plot the data
billboard_longer |> 
  ggplot(aes(x = week, y = rank, group = track)) +
  geom_line(alpha = 0.25) +
  scale_y_reverse()



#MANY VARIBLES IN THE COLUMN NAMES

who2

# To organize these six pieces of information in six separate columns, 
# we use pivot_longer() with a vector of column names for names_to and 
# instructors for splitting the original variable names into pieces for names_sep as well 
# as a column name for values_to:

who2 |> 
  pivot_longer(
    cols = !(country:year),
    names_to = c("diagnosis", "gender", "age"),
    names_sep = "_",
    values_to = "count"
  )



#DATA AND VARIABLE NAMES IN THE COLUMN HEADER
household


# we again need to supply a vector to names_to but this time we use the 
# special ".value" sentinel; this isn’t the name of a variable but a unique 
# value that tells pivot_longer() to do something different. This overrides 
# the usual values_to argument to use the first component of the pivoted 
# column name as a variable name in the output.

household |> 
  pivot_longer(
    cols = !family,
    names_to = c(".value", "child"),
    names_sep = "_",
    values_drop_na = TRUE
  )




# WIDENING DATA -----------------------------------------------------------

#Makes datasets wider by increasing columns and reducing rows
cms_patient_experience

# We can see the complete set of values for measure_cd and measure_title by using distinct():
cms_patient_experience |> 
  distinct(measure_cd, measure_title)

# pivot_wider() has the opposite interface to pivot_longer(): 
# instead of choosing new column names, we need to provide the existing 
# columns that define the values (values_from) and the column name (names_from):

cms_patient_experience |> 
  pivot_wider(
    names_from = measure_cd,
    values_from = prf_rate
  )

# we also need to tell pivot_wider() which column or columns have values 
# that uniquely identify each row; in this case those are the variables starting with "org":

cms_patient_experience |> 
  pivot_wider(
    id_cols = starts_with("org"),
    names_from = measure_cd,
    values_from = prf_rate
  )
