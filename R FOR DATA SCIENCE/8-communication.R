library(tidyverse)
library(scales)
library(ggrepel)
library(patchwork)


# LABELS ------------------------------------------------------------------

ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point(aes(color = class)) +
  geom_smooth(se = FALSE)+
  labs(
    x = "Engine displacement (L)",
    y = "Highway fuel economy (mpg)",
    color = "Car type",
    title = "Fuel efficiency generally decreases with engine size",
    subtitle = "Two seaters (sports cars) are an exception because of their light weight",
    caption = "Data from fueleconomy.gov"
  )

#using math equations instead of  text strings

df <- tibble(
  x = 1:10,
  y = cumsum(x^2)
)

ggplot(df, aes(x, y)) +
  geom_point() +
  labs(
    x = quote(x[i]),
    y = quote(sum(x[i] ^ 2, i == 1, n))
  )

#Exercise
#plot
ggplot(
  data = mpg, aes(x = fct_reorder(class, hwy), y = hwy)) +
  geom_boxplot() +
  coord_flip() +
  labs(
    title = "Compact Cars have > 10 Hwy MPG than Pickup Trucks",
    subtitle = "Comparing the median highway mpg in each class",
    caption = "Data from fueleconomy.gov",
    x = "Car Class",
    y = "Highway Miles per Gallon"
  )

#plot
ggplot(mpg, aes(x = cty, y = hwy)) +
  geom_point(aes(shape = drv, color = drv)) +
  labs(
    x = "Highway MPG",
    y = "City MPG",
    color = "Type of drive train", shape =  "Type of drive train"
  )

# ANNOTATIONS -------------------------------------------------------------

#create label info tibble
label_info <- mpg |> 
  group_by(drv) |> 
  arrange(desc(displ)) |> 
  slice_head(n = 1) |> 
  mutate(
    drive_type = case_when(
      drv == "f" ~ "front-wheel drive",
      drv == "r" ~ "rear-wheel drive",
      drv == "4" ~ "4-wheel drive",
    )
  ) |> 
  select(displ, hwy, drv, drive_type)
  
#use laeble info in plots
ggplot(mpg, aes(x = displ, y = hwy, color = drv)) +
  geom_point(alpha = 0.3) +
  geom_smooth(se = FALSE)+
  geom_text(
    data = label_info,
    aes(x = displ, y = hwy, label = drive_type), 
    fontface = "bold", size = 4, hjust = "right", vjust = "bottom"
  ) +
  theme(legend.position = "none")

# Note the use of hjust (horizontal justification) and vjust (vertical justification) 
# to control the alignment of the label.  
  
#use geom_label_repel to avoid label and point overlapping
ggplot(mpg, aes(x = displ, y = hwy, color = drv)) +
  geom_point(alpha = 0.3) +
  geom_smooth(se = FALSE)+
  geom_label_repel(
    data = label_info,
    aes(x = displ, y = hwy, label = drive_type), 
    fontface = "bold", size = 5, nudge_y = 2
  ) +
  theme(legend.position = "none")
  

#adding second layer of large hollow points to highlight labelled points
potential_outliers <- mpg |> 
  filter(hwy > 40 | (hwy > 20 & displ > 5))

ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point() +
  geom_text_repel(data = potential_outliers, aes(label = model)) +
  geom_point(data = potential_outliers, color = "red") +
  geom_point(
    data = potential_outliers,
    color = "red", size = 3, shape = "circle open"
  )

#text to be included int plot  
trend_text <- "Larger engine sizes tend to have lower fuel economy." |>
  str_wrap(width = 30)
trend_text

ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point() +
  annotate(
    geom = "label", x = 3.5, y = 38,
    label = trend_text,
    hjust = "left", color = "red"
  ) +
  annotate(
    geom = "segment", 
    x = 3, y = 35, xend = 5, yend = 25, color = "red",
    arrow = arrow(type = "closed")
  )
  
#Exercise

#place text in all four corners of plot
label <- tribble(
  ~displ, ~hwy, ~label, ~vjust, ~hjust,
  Inf, Inf, "Top right", "top", "right",
  Inf, -Inf, "Bottom right", "bottom", "right",
  -Inf, Inf, "Top left", "top", "left",
  -Inf, -Inf, "Bottom left", "bottom", "left"
)

ggplot(mpg, aes(displ, hwy)) +
  geom_point() +
  geom_text(aes(label = label, vjust = vjust, hjust = hjust), data = label)


#add text label to plot without creating tibble

ggplot(mpg, aes(displ, hwy)) +
  geom_point() +
  annotate(
    "text",
    x = Inf, y = Inf,
    label = "Increasing engine size is \nrelated to decreasing fuel economy.", vjust = "top", hjust = "right"
  )

# If the facet variable is not specified, the text is drawn in all facets.

label <- tibble(
  displ = Inf,
  hwy = Inf,
  label = "Increasing engine size is \nrelated to decreasing fuel economy."
)

ggplot(mpg, aes(displ, hwy)) +
  geom_point() +
  geom_text(aes(label = label),
            data = label, vjust = "top", hjust = "right",
            size = 2
  ) +
  facet_wrap(~class)
  
# To draw the label in only one facet, add a column to the label data frame with the value of 
# the faceting variable(s) in which to draw it.

label <- tibble(
  displ = Inf,
  hwy = Inf,
  class = "2seater",
  label = "Increasing engine size is \nrelated to decreasing fuel economy."
)

ggplot(mpg, aes(displ, hwy)) +
  geom_point() +
  geom_text(aes(label = label),
            data = label, vjust = "top", hjust = "right",
            size = 2
  ) +
  facet_wrap(~class)

# To draw labels in different plots, simply have the faceting variable(s):

label <- tibble(
  displ = Inf,
  hwy = Inf,
  class = unique(mpg$class),
  label = str_c("Label for", class)
)

ggplot(mpg, aes(displ, hwy)) +
  geom_point() +
  geom_text(aes(label = label),
            data = label, vjust = "top", hjust = "right",
            size = 3
            ) +
  facet_wrap(~class)


# SCALES ------------------------------------------------------------------

#Scales control how aesthetic mapping manifest visually

#1. Axis ticks and legend keys
#There are two primary arguments that affect the appearance of the ticks on the axes and the keys on the legend: breaks and labels.
# Breaks controls the position of the ticks, or the values associated with the keys. Labels controls the text label associated with each tick/key.Breaks controls the position of the ticks, or the values associated with the keys. 
# Labels controls the text label associated with each tick/key.

ggplot(mpg, aes(x = displ, y = hwy, color = drv)) +
  geom_point() +
  scale_y_continuous(breaks = seq(15, 40, by = 5))


ggplot(mpg, aes(x = displ, y = hwy, color = drv)) +
  geom_point() +
  scale_x_continuous(labels = NULL) + # no x labels
  scale_y_continuous(labels = NULL) + #no y labels
  scale_color_discrete(labels = c("4" = "4-wheel", "f" = "front", "r" = "rear")) #change legend labels


ggplot(diamonds, aes(x = price, y = cut)) +
  geom_boxplot(alpha = 0.05) +
  scale_x_continuous(labels = label_dollar()) #add $ labels and format prices

ggplot(diamonds, aes(x = price, y = cut)) +
  geom_boxplot(alpha = 0.05) +
  scale_x_continuous(
    labels = label_dollar(scale = 1/1000, suffix = "K"), #remove zeros and add k
    breaks = seq(1000, 19000, by = 6000)
  )
  
ggplot(diamonds, aes(x = cut, fill = clarity)) +
  geom_bar(position = "fill") +
  scale_y_continuous(name = "Percentage", labels = label_percent()) #add percentage at values

#using breaks when you have very few data points
presidential |> 
  mutate(id = 33 + row_number()) |> 
  ggplot(aes(x = start, y = id)) +
  geom_point() +
  geom_segment(aes(xend = end, yend = id)) +
  scale_x_date(name = NULL, breaks = presidential$start, date_labels = "%y")


#2. Legend Layout
#to control position of the legend, we use theme

base <- ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point(aes(color = class))

base + theme(legend.position = "right") #the default
base + theme(legend.position = "left")
base + 
  theme(legend.position = "top") +
  guides(color = guide_legend(nrow = 3))
base + 
  theme(legend.position = "bottom") +
  guides(color = guide_legend(nrow = 3))

#You can also use legend.position = "none" to suppress the display of the legend

#controlling display of individual legends
ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point(aes(color = class)) +
  geom_smooth(se = FALSE) +
  theme(legend.position = "bottom") +
  guides(color = guide_legend(nrow = 2, override.aes = list(size = 4))) #control number of rows(nrow), override aes to make points bigger

#3. Replacing the scale

#rather than use default scale which can be hard to interpret, we log transform and axes are labelled on original data scale
ggplot(diamonds, aes(x = carat, y = price)) +
  geom_bin2d() +
  scale_x_log10() +
  scale_y_log10()

#customised color scale
ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point(aes(color = drv)) +
  scale_color_brewer(palette = "Set1") #tuned for color blindness

ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point(aes(color = drv, shape = drv)) + #shape mapping 
  scale_color_brewer(palette = "Set1") 

#predefined mapping
presidential |>
  mutate(id = 33 + row_number()) |>
  ggplot(aes(x = start, y = id, color = party)) +
  geom_point() +
  geom_segment(aes(xend = end, yend = id)) +
  scale_color_manual(values = c(Republican = "#E81B23", Democratic = "#00AEF3")) #add party colors

#custom 
presidential |>
  mutate(id = 33 + row_number()) |>
  ggplot(aes(x = start, y = id, color = party)) +
  geom_point() +
  geom_segment(aes(xend = end, yend = id)) +
  geom_label_repel(
    data = presidential |> mutate(id = 33 + row_number()),
    aes(x = start, y = id, label = name, color = party),
    size = 4, nudge_x = 1, nudge_y = 0.1
  ) +
  scale_x_date(name = "Term Served", breaks = presidential$start, date_labels = "%y") +
  scale_color_manual(values = c(Republican = "#E81B23", Democratic = "#00AEF3")) #add party colors


# For continuous color, you can use the built-in scale_color_gradient() or scale_fill_gradient(). 
# If you have a diverging scale, you can use scale_color_gradient2(). 

df <- tibble(
  x = rnorm(10000),
  y = rnorm(10000)
)

ggplot(df, aes(x, y)) +
  geom_hex() +
  coord_fixed() +
  labs(title = "Default, continuous", x = NULL, y = NULL)

ggplot(df, aes(x, y)) +
  geom_hex() +
  coord_fixed() +
  scale_fill_viridis_c() +
  labs(title = "Viridis, continuous", x = NULL, y = NULL)

ggplot(df, aes(x, y)) +
  geom_hex() +
  coord_fixed() +
  scale_fill_viridis_b() +
  labs(title = "Viridis, binned", x = NULL, y = NULL)

#4. Zooming

# There are three ways to control the plot limits:
# Adjusting what data are plotted.
# Setting the limits in each scale.
# Setting xlim and ylim in coord_cartesian().

# relationship between engine size and fuel efficiency
ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point(aes(color = drv)) +
  geom_smooth()

#subsetting the data
mpg |> 
  filter(displ >= 5 & displ <= 6 & hwy >= 10 & hwy <= 25) |> 
  ggplot(aes(x = displ, y = hwy)) +
  geom_point(aes(color = drv)) +
  geom_smooth()

#when zooming in to a region, best to use coord_cartesian()
ggplot(mpg, aes(displ, hwy)) +
  geom_point(aes(color = drv)) +
  geom_smooth() +
  coord_cartesian(xlim = c(5, 6), ylim = c(10, 25))

#we can create scales which can be used accross multiple plots and make them easy to compare
suv <- mpg |> filter(class == "suv")
compact <- mpg |> filter(class == "compact")

x_scale <- scale_x_continuous(limits = range(mpg$displ))
y_scale <- scale_y_continuous(limits = range(mpg$hwy))
col_scale <- scale_color_discrete(limits = unique(mpg$drv))

ggplot(suv, aes(displ, hwy, color = drv)) +
  geom_point() +
  x_scale +
  y_scale +
  col_scale

ggplot(compact, aes(x = displ, y = hwy, color = drv)) +
  geom_point() +
  x_scale +
  y_scale +
  col_scale

#Exercise
# modify the code using override.aes to make the legend easier to see.
ggplot(diamonds, aes(x = carat, y = price)) +
  geom_point(aes(color = cut), alpha = 1/20) +
  guides(color = guide_legend(override.aes = list(size = 5)))



# THEMES ------------------------------------------------------------------

# you can customize the non-data elements of your plot with a theme:
ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point(aes(color = class)) +
  geom_smooth(se = FALSE) +
  theme_bw()

ggplot(mpg, aes(x = displ, y = hwy, color = drv)) +
  geom_point() +
  labs(
    title = "Larger engine sizes tend to have lower fuel economy",
    caption = "Source: https://fueleconomy.gov."
  ) +
  theme(
    legend.position = c(0.6, 0.7),
    legend.direction = "horizontal",
    legend.box.background = element_rect(color = "black"),
    plot.title = element_text(face = "bold"),
    plot.title.position = "plot",
    plot.caption.position = "plot",
    plot.caption = element_text(hjust = 0),
    axis.title.x = element_text(face = "bold", color = "blue"),
    axis.title.y = element_text(face = "bold", color = "blue"),
  ) +
  theme_dark()

# plot these are set to "plot" to indicate these elements are aligned to the entire plot area, instead of the plot panel (the default)


# LAYOUT ------------------------------------------------------------------

#Combine separate plots in one graphic


p1 <- ggplot(mpg, aes(x = displ, y = hwy)) + 
  geom_point() + 
  labs(title = "Plot 1")
p2 <- ggplot(mpg, aes(x = drv, y = hwy)) + 
  geom_boxplot() + 
  labs(title = "Plot 2")
p1 + p2

# You can also create complex plot layouts with patchwork. | places the p1 and p3 next to each other and / moves p2 to the next line.
p3 <- ggplot(mpg, aes(x = cty, y = hwy)) + 
  geom_point() + 
  labs(title = "Plot 3")
(p1 | p3) / p2

#collect legend from multiple plots into common one and add common title
p1 <- ggplot(mpg, aes(x = drv, y = cty, color = drv)) + 
  geom_boxplot(show.legend = FALSE) + #turned off the legends on the box plots
  labs(title = "Plot 1")

p2 <- ggplot(mpg, aes(x = drv, y = hwy, color = drv)) + 
  geom_boxplot(show.legend = FALSE) + #turned off the legends on the box plots
  labs(title = "Plot 2")

p3 <- ggplot(mpg, aes(x = cty, color = drv, fill = drv)) + 
  geom_density(alpha = 0.5) +  #collected the legends for the density plots
  labs(title = "Plot 3")

p4 <- ggplot(mpg, aes(x = hwy, color = drv, fill = drv)) + 
  geom_density(alpha = 0.5) + #collected the legends for the density plots
  labs(title = "Plot 4")

p5 <- ggplot(mpg, aes(x = cty, y = hwy, color = drv)) + 
  geom_point(show.legend = FALSE) + #turned off the legends on the box plots
  facet_wrap(~drv) +
  labs(title = "Plot 5")

(guide_area() / (p1 + p2) / (p3 + p4) / p5) +
  plot_annotation(
    title = "City and highway mileage for cars with different drive trains",
    caption = "Source: https://fueleconomy.gov."
  ) +
  plot_layout(
    guides = "collect",
    heights = c(1, 3, 2, 4) #the guide has a height of 1, the box plots 3, density plots 2, nd the faceted scatterplot 4
  ) &
  theme(legend.position = "top") #The legend is placed on top,

#Exercise
p1 <- ggplot(mpg, aes(x = displ, y = hwy)) + 
  geom_point() + 
  labs(title = "Plot 1")
p2 <- ggplot(mpg, aes(x = drv, y = hwy)) + 
  geom_boxplot() + 
  labs(title = "Plot 2")
p3 <- ggplot(mpg, aes(x = cty, y = hwy)) + 
  geom_point() + 
  labs(title = "Plot 3")

p1 / (p2 | p3)



