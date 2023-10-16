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

# To draw labels in different plots, simply have the facetting variable(s):










  












