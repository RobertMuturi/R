#LAYERS
library(tidyverse)
library(gridExtra)

# AESTHETIC MAPPING -------------------------------------------------------
mpg

#Left
ggplot(mpg, aes(x = displ, y = hwy, color = class)) +
  geom_point()

#Right
ggplot(mpg, aes(x = displ, y = hwy, shape = class))+
  geom_point()

#Since ggplot2 will only use six shapes at a time, by default, 
#additional groups will go unplotted when you use the shape aesthetic.

# Mapping an unordered discrete (categorical) variable (class) to an ordered
# aesthetic (size or alpha) is generally not a good idea because it implies a
# ranking that does not in fact exist.

# You can also set the visual properties of your geom manually as an argument 
# of your geom function (outside of aes())

ggplot(mpg, aes(x = displ, y = hwy))+
  geom_point(color = "blue") #make all points blue


# EXERCISE ----------------------------------------------------------------

ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point(
    color = "pink",
    shape = "triangle"
  )

ggplot(mpg) + 
  geom_point(aes(x = displ, y = hwy, color = "blue"))

library(ggplot2)

# Create a scatter plot with shape 21 (filled circle) and stroke aesthetic
ggplot(mtcars, aes(wt, mpg)) +
  geom_point(shape = 21, colour = "black", fill = "white", size = 5, stroke = 5)

ggplot(mpg) +
  geom_point(aes(x = displ, y = hwy, color = displ < 5))



# GEOMETRIC OBJECTS -------------------------------------------------------

#plotting the same variables on different plots
ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point()

ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_smooth()


# you can change linetype for specific variables, this wont work with shape
ggplot(mpg, aes(x = displ, y = hwy, linetype = drv)) + #changing linetype to shape will be ignored
  geom_smooth()

#overlaying lines on data and using color
ggplot(mpg, aes(x = displ, y = hwy, color = drv)) +
  geom_point() +
  geom_smooth(aes(linetype = drv))

#you can set the group aesthetic to a categorical variable to draw multiple objects.
ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_smooth(aes(group = drv))

ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_smooth(aes(color = drv), show.legend = FALSE)

# placing mappings in a geom function, ggplot2 will treat them as local mappings for the layer only
ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point(aes(color = class)) +
  geom_smooth()


# You can use the same idea to specify different data for each layer.
ggplot(mpg, aes(x= displ, y = hwy)) +
  geom_point()+
  geom_point(
    data = mpg |> filter(class == "2seater"),
    color = "red"
  ) +
  geom_point(
    data = mpg |> filter(class == "2seater"),
    shape = "circle open", size = 3, color = "red"
  )

# Geoms are the fundamental building blocks of ggplot2. You can completely transform 
# the look of your plot by changing its geom, and different geoms can reveal different 
# features of your data. For example, the histogram and density plot below reveal that
# the distribution of highway mileage is bimodal and right skewed while the boxplot 
# reveals two potential outliers.

# Left
ggplot(mpg, aes(x = hwy)) +
  geom_histogram(binwidth = 2)

# Middle
ggplot(mpg, aes(x = hwy)) +
  geom_density()

# Right
ggplot(mpg, aes(x = hwy)) +
  geom_boxplot()



# EXERCISE 2 --------------------------------------------------------------

ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point() +
  geom_smooth(se = FALSE)

ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point() +
  geom_smooth(aes(group = drv), se = FALSE)

ggplot(mpg, aes(x = displ, y = hwy, color = drv)) +
  geom_point() +
  geom_smooth(se = FALSE)

ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point(aes(color = drv)) +
  geom_smooth(se = FALSE)

ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point(aes(color = drv)) +
  geom_smooth(aes(linetype = drv),se = FALSE)

ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point(size = 3, color = "white") +
  geom_point(aes(color = drv))



# FACETS ------------------------------------------------------------------

 #facet_wrap splits plot into subplots that each display 
# one subset of the data based on a categorical variable.

ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point() +
  facet_wrap(~cyl)

# To facet your plot with the combination of two variables, 
# switch from facet_wrap() to facet_grid(). The first argument of facet_grid() 
# is also a formula, but now it’s a double sided formula: rows ~ cols.

ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point() +
  facet_grid(drv ~ cyl)

# By default each of the facets share the same scale and range for x and y axes. 
# This is useful when you want to compare data across facets but it can be 
# limiting when you want to visualize the relationship within each facet better. 
# Setting the scales argument in a faceting function to "free" will allow for 
# different axis scales across both rows and columns, "free_x" will allow for 
# different scales across rows, and "free_y" will allow for different scales 
# across columns.

ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point() +
  facet_grid(drv ~ cyl, scales = "free_y")


# EXERCISE 3 --------------------------------------------------------------


ggplot(mpg) + 
  geom_point(aes(x = displ, y = hwy)) +
  facet_grid(drv ~ .)

ggplot(mpg) + 
  geom_point(aes(x = displ, y = hwy)) +
  facet_grid(. ~ cyl)

ggplot(mpg) + 
  geom_point(aes(x = displ, y = hwy)) + 
  facet_wrap(~ class, nrow = 2)

#Which of the following makes it easier to compare engine sizes
ggplot(mpg, aes(x = displ)) + 
  geom_histogram() + 
  facet_grid(drv ~ .)

ggplot(mpg, aes(x = displ)) + 
  geom_histogram() +
  facet_grid(. ~ drv)

#recreat using facet wrap
ggplot(mpg) + 
  geom_point(aes(x = displ, y = hwy)) +
  facet_grid(drv ~ .)

ggplot(mpg) + 
  geom_point(aes(x = displ, y = hwy)) +
  facet_wrap(~ drv)


# STATISTICAL TRANSFORMATIONS ---------------------------------------------

#Chart shows more diamonds available with high quality cut than with low

ggplot(diamonds, aes(x = cut)) +
  geom_bar()

# On the x-axis, the chart displays cut, a variable from diamonds. On the y-axis, 
# it displays count, but count is not a variable in diamonds! Where does count 
# come from? Many graphs, like scatterplots, plot the raw values of your dataset. 
# Other graphs, like bar charts, calculate new values to plot:
  
# Bar charts, histograms, and frequency polygons bin your data and then plot bin 
# counts, the number of points that fall in each bin.
# 
# Smoothers fit a model to your data and then plot predictions from the model.
# 
# Boxplots compute the five-number summary of the distribution and then display 
# that summary as a specially formatted box.
# 
# The algorithm used to calculate new values for a graph is called a stat, short 
# for statistical transformation

#Every geom has a default stat as every stat has a geom. there are 3 reasons to
#use a stat explicitily

#1 overide default stat. i.e here we change stat from count to identity to map height
# of bars to raw values

diamonds |> 
  count(cut) |> 
  ggplot(aes(x = cut, y = n)) +
  geom_bar(stat = "identity")

#2. To override the default mapping from transformed variables to aesthetics i.e display
# bar chart of proportions rather than counts

ggplot(diamonds, aes(x = cut, y = after_stat(prop), group = 1)) + 
  geom_bar()

#3 draw greater attention to statistical transformation in code i.e use stat_summary
# to summarise y values for each unique x value

ggplot(diamonds) +
  stat_summary(
    aes(x = cut, y = depth),
    fun.min = min,
    fun.max = max,
    fun = median
  )


# POSITION ADJUSTEMENTS ---------------------------------------------------

#You can color bar charts using color aesthetics or fill aestehtics
ggplot(mpg, aes(x = drv, color = drv)) +
  geom_bar()

ggplot(mpg, aes(x = drv, fill = drv)) +
  geom_bar()

#fill with another variable i.e class
ggplot(mpg, aes(x = drv, fill = class)) +
  geom_bar()

#the stacking is auto. however there alt options
#identity, dodge, fill

#position = identity will place each object where it falls in context to the graph
# its not very useful for bars cause it overlaps them and have to use transparency or 
# completly transparent. More useful with 2d geoms like points
ggplot(mpg, aes(x = drv, fill = class)) +
  geom_bar(alpha = 1/5, position = "identity")

ggplot(mpg, aes(x = drv, color = class)) +
  geom_bar(fill = NA, position = "identity")


#position = fill makes set of stacks the same height hence easy to compare
#position = dodge places objects beside each other

ggplot(mpg, aes(x = drv, fill = class)) +
  geom_bar(position = "fill")

ggplot(mpg, aes(x = drv, fill = class)) + 
  geom_bar(position = "dodge")

#other arguments applied to points as overlaping points are grouped
ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point(position = "jitter")



# EXERCISE 4 --------------------------------------------------------------


ggplot(mpg, aes(x = cty, y = hwy)) + 
  geom_jitter()

#diffrence
ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point()
ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point(position = "identity")

# Compare and contrast geom_jitter() with geom_count().
ggplot(data = mpg, mapping = aes(x = cty, y = hwy)) +
  geom_jitter()

ggplot(data = mpg, mapping = aes(x = cty, y = hwy)) +
  geom_count()

ggplot(data = mpg, mapping = aes(x = cty, y = hwy, color = class)) +
  geom_jitter()

ggplot(data = mpg, mapping = aes(x = cty, y = hwy, color = class)) +
  geom_count()

ggplot(data = mpg, mapping = aes(x = cty, y = hwy, color = class)) +
  geom_count(position = "jitter")

ggplot(data = mpg, aes(x = drv, y = hwy, colour = class)) +
  geom_boxplot()

ggplot(data = mpg, aes(x = drv, y = hwy, colour = class)) +
  geom_boxplot(position = "identity")

#plot side by side
p1 <- ggplot(data = mpg, aes(x = drv, y = hwy, colour = class)) +
  geom_boxplot()
p2 <- ggplot(data = mpg, aes(x = drv, y = hwy, colour = class)) +
  geom_boxplot(position = "identity")

grid.arrange(p1, p2, ncol = 2)


# COORDINATE SYSTEMS ------------------------------------------------------

# the default coordinate system is the Cartesian coordinate system
# There are two other coordinate systems that are occasionally helpful.
# 
# coord_quickmap() sets the aspect ratio correctly for geographic maps. 
# This is very important if you’re plotting spatial data with ggplot2

nz <- map_data("nz")

ggplot(nz, aes(x = long, y = lat, group = group)) +
  geom_polygon(fill = "white", color = "black")

ggplot(nz, aes(x = long, y = lat, group = group)) +
  geom_polygon(fill = "white", color = "black") +
  coord_quickmap()

# coord_polar() uses polar coordinates. Polar coordinates reveal an interesting 
# connection between a bar chart and a Coxcomb chart.

bar <- ggplot(data = diamonds) +
  geom_bar(
    mapping = aes(x = clarity, fill = clarity),
    show.legend = FALSE,
    width = 1
  ) +
  theme(aspect.ratio = 1)

bar + coord_flip()
bar + coord_polar()


# EXERCISE 5 --------------------------------------------------------------

# Turn a stacked bar chart into a pie chart using coord_polar().
ggplot(mpg, aes(x = factor(1), fill = drv)) +
  geom_bar()

ggplot(mpg, aes(x = factor(1), fill = drv)) +
  geom_bar(width = 1) +
  coord_polar(theta = "y")

# The argument theta = "y" maps y to the angle of each section. If coord_polar() 
# is specified without theta = "y", then the resulting plot is called a bulls-eye chart.

ggplot(mpg, aes(x = factor(1), fill = drv)) +
  geom_bar(width = 1) +
  coord_polar()

#what does this explain
ggplot(data = mpg, mapping = aes(x = cty, y = hwy)) +
  geom_point() + 
  geom_abline() +
  coord_fixed()

# The function coord_fixed() ensures that the line produced by geom_abline() is 
# at a 45-degree angle. A 45-degree line makes it easy to compare the highway 
# and city mileage to the case in which city and highway MPG were equal
# If we didn’t include coord_fixed(), then the line would no longer have an angle of 45 degrees.
