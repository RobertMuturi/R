library(tidyverse)


# READING DATA FROM FILE --------------------------------------------------

students <- read.csv("data/students.csv", na = c("N/A", ""))

#read as list, convert to tibble
students <- as_tibble(students)

students

#rename columns because of they non-syntactic
students |> 
  rename(
    student_id = 'Student.ID',
    full_name = 'Full.Name'
  )

#alternative approach is
students |> janitor::clean_names()

# Another common task after reading in data is to consider variable types. 
# For example, meal_plan is a categorical variable with a known set of 
# possible values, which in R should be represented as a factor:

students |> 
  janitor::clean_names() |> 
  mutate(meal_plan = factor(meal_plan))

#age is defined as character variable, we need to change 
students <- students |> 
  janitor::clean_names() |> 
  mutate(
    meal_plan = factor(meal_plan),
    age = parse_number(if_else(age == "five", "5", age))
  )


#Other handy tricks

#skipping a row
read_csv(
  "The first line of metadata
  The second line of metadata
  x,y,z
  1,2,3",
  skip = 2
)

#skipping a comment
read_csv(
  "# A comment I want to skip
  x,y,z
  1,2,3",
  comment = "#"
)

#data might not have column names but you can label sequentially
read_csv(
  "1,2,3
  4,5,6",
  col_names = FALSE
)

#passing col_names to be used as column names
read_csv(
  "1,2,3
  4,5,6",
  col_names = c("x", "y", "z")
)


# EXERCISE ----------------------------------------------------------------

#What does the following do?
read_csv("a,b\n1,2,3\n4,5,6")
read_csv("a,b,c\n1,2\n1,2,3,4")
read_csv("a,b\n\"1")
read_csv("a,b\n1,2\na,b")
read_csv("a;b\n1;3")

# how to read in "x,y\n1,'a,b'"
text <- "x,y\n1,'a,b'"
df <- read.csv(text = text, quote = "'")
print(df)

annoying <- tibble(
  `1` = 1:10,
  `2` = `1` * 2 + rnorm(length(`1`))
)

#extract variable 1
annoying$'1'

#scatterplot of 1 v 2
plot(annoying$'1', annoying$'2')

#create column 3 which is 2/1
annoying$'3' <- annoying$'1' / annoying$'2'

#rename the columns
colnames(annoying) <- c('one', "two", "three")



# CONTROLLING COLUMN TYPES ------------------------------------------------

#basic types
read_csv("
  logical,numeric,date,string
  TRUE,1,2021-01-15,abc
  false,4.5,2021-02-15,def
  T,Inf,2021-02-16,ghi
")

#missing values
simple_csv <- "
  x
  10
  .
  20
  30"

read_csv(simple_csv)

#tell readr this is a numeric column
df <- read_csv(
  simple_csv,
  col_types = list(x = col_double())
)

#here we're told there's a problem and where to find it with problems()
problems(df)

#This tells us that there was a problem in row 3, col 1 where readr expected a double
#This suggents its a missing value

read_csv(simple_csv, na = ".")


# t’s also possible to override the default column by switching from 
# list() to cols() and specifying .default:

another_csv <- "
x,y,z
1,2,3"

read_csv(
  another_csv,
  col_types = cols(.default = col_character())
)

#Another useful helper is cols_only() which will read in only the columns you specify:
read_csv(
  another_csv,
  col_types = cols_only(x = col_character())
)



# READING MULTIPLE FILES --------------------------------------------------

sales_files <- c("data/01-sales.csv", "data/02-sales.csv", "data/03-sales.csv")
read_csv(sales_files, id = "file")


# The id argument adds a new column called file to the resulting data frame 
# that identifies the file the data come from

# If you have many files you want to read in, you can use the base list.files() 
# function to find the files for you by matching a pattern in the file names.

sales_files <-  list.files("data", pattern = "sales\\.csv$", full.names = TRUE)
sales_files



# WRITING TO FILE ---------------------------------------------------------

#writing to csv can be unreliable, but there are two alternatives
#write_rds and read_rds are uniform wrappers around the base functions 
# readRDS() and saveRDS(). These store data in R’s custom binary format called RDS. 
# This means that when you reload the object, you are loading the exact same R object 
# that you stored.

write_rds(students, "students.rds")
read_rds("students.rds")


#The arrow package allows you to read and write parquet files, a fast binary 
#file format that can be shared across programming languages. 

library(arrow)
write_parquet(students, "students.parquet")
read_parquet("students.parquet")

#Parquet tends to be much faster than RDS and is usable outside of R, but does require the arrow package.


# DATA ENTRY --------------------------------------------------------------

# Sometimes you’ll need to assemble a tibble “by hand” doing a little data entry 
# in your R script. There are two useful functions to help you do this which differ 
# in whether you layout the tibble by columns or by rows. tibble() works by column:

tibble(
  x = c(1, 2, 5), 
  y = c("h", "m", "g"),
  z = c(0.08, 0.83, 0.60)
)

# Laying out the data by column can make it hard to see how the rows are related, 
# so an alternative is tribble(), short for transposed tibble,

tribble(
  ~x, ~y, ~z,
  1, "h", 0.08,
  2, "m", 0.83,
  5, "g", 0.60
)
