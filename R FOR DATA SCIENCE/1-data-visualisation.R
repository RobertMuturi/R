library(palmerpenguins)
library(ggthemes)
library(tidyverse)

#mapping for each individual species
#lm is linear model for drawing line of best fit
ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g, color = species)
) +
  geom_point() +
  geom_smooth(method = "lm")

#mapping curve for all species
ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g)
) +
  geom_point(mapping = aes(color = species)) +
  geom_smooth(method = "lm")

#adding shape aesthetic for each species
ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g)
)+
  geom_point(mapping = aes(color = species, shape = species)) +
  geom_smooth(method = "lm")

#using labs function to add title and subtitles as well as making colorblind safe
ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g)
) +
  geom_point(aes(color = species, shape = species)) +
  geom_smooth(method = "lm") +
  labs(
    title = "Body mass and flipper length",
    subtitle = "Dimensions for Adelie, Chinstrap, and Gentoo Penguins",
    x = "Flipper length (mm)", y = "Body mass (g)",
    color = "Species", shape = "Species"
  ) +
  scale_color_colorblind()

#scatter plot of bill length vs bill depth
ggplot(
  data = penguins,
  mapping = aes(bill_length_mm, bill_depth_mm)
)+
  geom_point(aes(color = species, shape = species))+
  labs(
    x = "Bill Length(mm)", y = "Bill Depth(mm)"
  )

#scatter plot of species vs bill depth
ggplot(
  penguins,
  aes(species, bill_length_mm)
)+
  geom_point(aes(color = species))+
  labs(
    title = "Data Came from palmerpenguins package"
  )

#plot of body vs flipper length with bill depth as color aesthetic
ggplot(
  penguins,
  mapping = aes(flipper_length_mm, body_mass_g)
)+
  geom_point(aes(color = bill_depth_mm))+
  geom_smooth()

#body mass vs flipper length with island as color,
#se = false removes the grey shading along the line
ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g, color = island)
) +
  geom_point() +
  geom_smooth(se = FALSE)

#check difference btwn the following two lines of code
ggplot(
  data = penguins,
  mapping = aes(x = flipper_length_mm, y = body_mass_g)
) +
  geom_point() +
  geom_smooth()

ggplot() +
  geom_point(
    data = penguins,
    mapping = aes(x = flipper_length_mm, y = body_mass_g)
  ) +
  geom_smooth(
    data = penguins,
    mapping = aes(x = flipper_length_mm, y = body_mass_g)
  )
#the two are the same

# Rewriting the code much more better
ggplot(penguins, aes(x = flipper_length_mm, y = body_mass_g)) +
  geom_point()


# VISUALISING DISTRIBUTIONS
#categorical variable
ggplot(penguins, aes(x = species)) + geom_bar()

#ordering based on frequencies
ggplot(penguins, aes(x=fct_infreq(species))) + 
  geom_bar()

#numerical variable
ggplot(penguins, aes(x=body_mass_g))+
  geom_histogram(binwidth = 200)

#using a density plot
ggplot(penguins, aes(x = body_mass_g)) +
  geom_density()

#bar plot with species on y
ggplot(penguins, aes(y=species)) + geom_bar()

ggplot(penguins, aes(x = species)) +
  geom_bar(fill = "red")

ggplot(diamonds, aes(x=carat))+
  geom_histogram(binwidth = 0.1)


# Visualising relationships
#categorical and numerical variables can be visualized using boxplots
ggplot(penguins, aes(x=species, y=body_mass_g))+
  geom_boxplot()

#density plots can also be used
ggplot(penguins, aes(x = body_mass_g, color = species)) +
  geom_density(linewidth = 0.75)

#using fill colors
ggplot(penguins, aes(x=body_mass_g, color = species, fill = species)) + 
  geom_density(alpha = 0.5)

#Plotting two categorical variables
ggplot(penguins, aes(x=island, fill=species))+
  geom_bar()

#relative frequency plot, showing distribution across islands using "position=fill"
ggplot(penguins, aes(x=island, fill=species))+
  geom_bar(position = "fill")


#Numerical variables
#scatterplot most common for comparing two numerical variables
ggplot(penguins, aes(x = flipper_length_mm, y = body_mass_g)) +
  geom_point()

#three or more variables using different shapes and colors 
ggplot(penguins, aes(x= flipper_length_mm, y= body_mass_g)) +
  geom_point(aes(color=species, shape=island))

#creating subplots using facets
# To facet your plot by a single variable, use facet_wrap(). 
# The first argument of facet_wrap() is a formula3, which you create with ~ 
# followed by a variable name. The variable that you pass to facet_wrap() should be categorical.

ggplot(penguins, aes(x= flipper_length_mm, y= body_mass_g))+
  geom_point(aes(color=species, shape= species))+
  facet_wrap(~island)

#plot numerical variables using mpg dataset
ggplot(mpg, aes(x=hwy, y= displ))+
  geom_point(aes(color=year, size=cyl, shape=drv))

#plot of colored species
ggplot(penguins, aes(x= bill_depth_mm, bill_length_mm))+
  geom_point(aes(color=species))

#same plot with facets
ggplot(penguins, aes(x= bill_depth_mm, bill_length_mm))+
  geom_point(aes(color = species))+
  facet_wrap(~species)

#compare the two plots
ggplot(penguins, aes(x = island, fill = species)) +
  geom_bar(position = "fill")
ggplot(penguins, aes(x = species, fill = island)) +
  geom_bar(position = "fill")

#saving plots
# ggplot(penguins, aes(x = flipper_length_mm, y = body_mass_g))+
#   geom_point()
# ggsave(filename = "penguin-plot.png")

ggplot(mpg, aes(x = class)) +
  geom_bar()
ggplot(mpg, aes(x = cty, y = hwy)) +
  geom_point()
#ggsave("mpg-plot.png")

