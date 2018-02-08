
## Spatial Data

Some resources on plotting spatial data in R:

- [ggplot2](https://cran.r-project.org/package=ggplot2) has several map-related functions

  - [borders](http://docs.ggplot2.org/current/borders.html)
  - [fortify.map](http://docs.ggplot2.org/current/fortify.map.html)
  - [map_data](http://docs.ggplot2.org/current/map_data.html)

- [ggmap](https://cran.r-project.org/package=ggmap) allows ggplot to us a map from Google Maps, OpenStreet Maps or similar as a background for the plot.

  - David Kahle and Hadley Wickham. 2013. [ggmap: Spatial Visualization with ggplot2](https://journal.r-project.org/archive/2013-1/kahle-wickham.pdf). *Journal of Statistical Software*
  - Github [dkahle/ggmamp](https://github.com/dkahle/ggmap)

- [tmap](https://cran.r-project.org/package=tmap) is not built on ggplot2 but uses a ggplot2-like API for network data.
- [leaflet](https://cran.r-project.org/package=leaflet) is an R interface to a popular javascript mapping library.

Here are few tutorials on plotting spatial data in ggplot2:

- [Making Maps with R](http://eriqande.github.io/rep-res-web/lectures/making-maps-with-R.html)
- [Plotting Data on a World Map](https://www.r-bloggers.com/r-beginners-plotting-locations-on-to-a-world-map/)
- [Introduction to Spatial Data and ggplot2](https://rpubs.com/m_dev/Intro-to-Spatial-Data-and-ggplot2)


### Prerequisites {-}


```r
library("tidyverse")
library("lubridate")
library("stringr")
library("forcats")
library("modelr")
library("ggrepel")
```


### Spatial Data in R


```r
data("us.cities", package = "maps")
glimpse(us.cities)
#> Observations: 1,005
#> Variables: 6
#> $ name        <chr> "Abilene TX", "Akron OH", "Alameda CA", "Albany GA...
#> $ country.etc <chr> "TX", "OH", "CA", "GA", "NY", "OR", "NM", "LA", "V...
#> $ pop         <int> 113888, 206634, 70069, 75510, 93576, 45535, 494962...
#> $ lat         <dbl> 32.5, 41.1, 37.8, 31.6, 42.7, 44.6, 35.1, 31.3, 38...
#> $ long        <dbl> -99.7, -81.5, -122.3, -84.2, -73.8, -123.1, -106.6...
#> $ capital     <int> 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,...
```


```r
usa_map <- map_data("usa")
#> 
#> Attaching package: 'maps'
#> The following object is masked from 'package:purrr':
#> 
#>     map
capitals <- filter(us.cities,
                   capital == 2,
                   !country.etc %in% c("HI", "AK"))
ggplot() +
  geom_map(map = usa_map) +
  borders(database = "usa") +
  geom_point(aes(x = long, y = lat, size = pop),
             data = capitals) +
  # scale size area ensures: 0 = no area
  scale_size_area() +
  coord_quickmap() +
  theme_void() +
  labs(x = "", y = "", title = "US State Capitals",
       size = "Population")
```

<img src="discovery-spatial_files/figure-html/unnamed-chunk-4-1.png" width="70%" style="display: block; margin: auto;" />


```r
cal_cities <- filter(us.cities, country.etc == "CA") %>%
  top_n(7, pop)

ggplot() +
  borders(database = "state", regions = "California") +
  geom_point(aes(x = long, y = lat), data = cal_cities) +
  geom_text_repel(aes(x = long, y = lat, label = name), data = cal_cities) +
  coord_quickmap() +
  theme_minimal() +
  labs(x = "", y = "")
```

<img src="discovery-spatial_files/figure-html/unnamed-chunk-5-1.png" width="70%" style="display: block; margin: auto;" />



### Colors in R

For more resources on using colors in R

- `R4DS` chapter [Graphics for Communication](http://r4ds.had.co.nz/graphics-for-communication.html#replacing-a-scale)
- ggplot2 book Chapter "Scales"
- Jenny Bryan [Using colors in R](https://www.stat.ubc.ca/~jenny/STAT545A/block14_colors.html)
- Achim Zeileis, Kurt Hornik, Paul Murrell (2009). Escaping RGBland: Selecting Colors for Statistical Graphics. Computational Statistics & Data Analysis [DOI](http://dx.doi.org/10.1016/j.csda.2008.11.033)
- [colorspace vignette](https://cran.r-project.org/web/packages/colorspace/vignettes/hcl-colors.pdf)
- Maureen Stone [Choosing Colors for Data Visualization](https://www.perceptualedge.com/articles/b-eye/choosing_colors.pdf)
- [ColorBrewer](http://colorbrewer2.org) A website with a variety of palettes, primarily designed for maps, but also useful in data viz.
- Stephen Few [Practical Rules for Using Color in Charts](http://www.perceptualedge.com/articles/visual_business_intelligence/rules_for_using_color.pdf)
- [Why Should Engineers and Scientists by Worried About Color?](http://www.research.ibm.com/people/l/lloydt/color/color.HTM)
- [A Better Default Colormap for Matplotlib](https://www.youtube.com/watch?v=xAoljeRJ3lU) A SciPy 2015 talk that describes how the [viridis](https://cran.r-project.org/package=viridis) was created.
- [Evaluation of Artery Visualizations for Heart Disease Diagnosis](http://www.eecs.harvard.edu/~kgajos/papers/2011/borkin11-infoviz.pdf) Using the wrong color scale can be deadly ... literally.
- The python package matplotlib has a good discussion of [colormaps](http://matplotlib.org/users/colormaps.html).
- Peter Kovesi [Good Color Maps: How to Design Them](https://arxiv.org/pdf/1509.03700v1.pdf).
- See the [viridis](https://cran.r-project.org/package=viridis), [ggthemes](https://cran.r-project.org/package=ggthemes), [dichromat](https://cran.r-project.org/package=dichromat), and [pals](https://cran.r-project.org/package=pals) packages for color palettes.


Use [scale_identity](http://docs.ggplot2.org/current/scale_identity.html) for the color and alpha scales since the values
of the variables are the values of the scale itself (the color names, and the
alpha values).

```r
ggplot(tibble(x = rep(1:4, each = 2),
              y = x + rep(c(0, 0.2), times = 2),
              colour = rep(c("black", "red"), each = 4),
              alpha = c(1, 1, 0.5, 0.5, 1, 1, 0.5, 0.5)),
  aes(x = x, y = y, colour = colour, alpha = alpha)) +
  geom_point(size = 15) +
  scale_color_identity() +
  scale_alpha_identity() +
  theme_bw() +
  theme(panel.grid = element_blank())
```

<img src="discovery-spatial_files/figure-html/unnamed-chunk-6-1.png" width="70%" style="display: block; margin: auto;" />


### United States Presidential Elections


```r
data("pres08", package = "qss")

pres08 <- pres08 %>%
  mutate(Dem = Obama / (Obama + McCain),
         Rep = McCain / (Obama + McCain))
```


```r
ggplot() +
  borders(database = "state", regions = "California", fill = "blue") +
  coord_quickmap() +
  theme_void()
```

<img src="discovery-spatial_files/figure-html/unnamed-chunk-8-1.png" width="70%" style="display: block; margin: auto;" />


```r
cal_color <- filter(pres08, state == "CA") %>% {
    rgb(red = .$Rep, green = 0, blue = .$Dem)
  }

ggplot() +
  borders(database = "state", regions = "California", fill = cal_color) +
  coord_quickmap() +
  theme_void()
```

<img src="discovery-spatial_files/figure-html/unnamed-chunk-9-1.png" width="70%" style="display: block; margin: auto;" />


```r
# America as red and blue states
map(database = "state") # create a map
for (i  in 1:nrow(pres08)) {
    if ( (pres08$state[i] != "HI") & (pres08$state[i] != "AK") &
        (pres08$state[i] != "DC")) {
        map(database = "state", regions = pres08$state.name[i],
            col = ifelse(pres08$Rep[i] > pres08$Dem[i], "red", "blue"),
            fill = TRUE, add = TRUE)
    }
}

## America as purple states
map(database = "state") # create a map
for (i in 1:nrow(pres08)) {
    if ( (pres08$state[i] != "HI") & (pres08$state[i] != "AK") &
        (pres08$state[i] != "DC")) {
        map(database = "state", regions = pres08$state.name[i],
            col = rgb(red = pres08$Rep[i], blue = pres08$Dem[i],
               green = 0), fill = TRUE, add = TRUE)
    }
}
```


```r
states <- map_data("state") %>%
  left_join(mutate(pres08, state.name = str_to_lower(state.name)),
            by = c("region" = "state.name")) %>%
  # drops DC
  filter(!is.na(EV)) %>%
  mutate(party = if_else(Dem > Rep, "Dem", "Rep"),
         color = map2_chr(Dem, Rep, ~ rgb(blue = .x, red = .y, green = 0)))

ggplot(states) +
  geom_polygon(aes(group = group, x = long, y = lat,
                   fill = party)) +
  coord_quickmap() +
  scale_fill_manual(values = c("Rep" = "red", "Dem" = "blue")) +
  theme_void() +
  labs(x = "", y = "")
```

<img src="discovery-spatial_files/figure-html/unnamed-chunk-11-1.png" width="70%" style="display: block; margin: auto;" />

For plotting the purple states, I use  since the `color` column contains the RGB values to use in the plot:

```r
ggplot(states) +
  geom_polygon(aes(group = group, x = long, y = lat,
                   fill = color)) +
  coord_quickmap() +
  scale_fill_identity() +
  theme_void() +
  labs(x = "", y = "")
```

<img src="discovery-spatial_files/figure-html/unnamed-chunk-12-1.png" width="70%" style="display: block; margin: auto;" />

However, plotting purple states is not a good data visualization.
Even though the colors are a proportional mixture of red and blue, human visual perception doesn't work that way.

The proportion of the democratic vote is best thought of a diverging scale with 0.5 is midpoint.
And since the Democratic Party is associated with the color blue and the Republican Party is associated with the color red.
The Color Brewer palette [RdBu](http://colorbrewer2.org/#type=diverging&scheme=RdBu&n=11) is an example:

```r
ggplot(states) +
  geom_polygon(aes(group = group, x = long, y = lat, fill = Dem)) +
  scale_fill_distiller("% Obama", direction = 1, limits = c(0, 1), type = "div",
                       palette = "RdBu") +
  coord_quickmap() +
  theme_void() +
  labs(x = "", y = "")
```

<img src="discovery-spatial_files/figure-html/unnamed-chunk-13-1.png" width="70%" style="display: block; margin: auto;" />


### Expansion of Walmart

We don't need to do the direct mapping since

```r
data("walmart", package = "qss")

ggplot() +
  borders(database = "state") +
  geom_point(aes(x = long, y = lat, colour = type, size = size),
             data = mutate(walmart,
                           size = if_else(type == "DistributionCenter", 2, 1)),
             alpha = 1 / 3) +
  coord_quickmap() +
  scale_size_identity() +
  guides(color = guide_legend(override.aes = list(alpha = 1))) +
  theme_void()
```

<img src="discovery-spatial_files/figure-html/unnamed-chunk-14-1.png" width="70%" style="display: block; margin: auto;" />
We don't need to worry about colors since `ggplot` handles that.
I use [guides](http://docs.ggplot2.org/current/guides.html) to so that the colors or not transparent
in the legend (see *R for Data Science* chapter[Graphics for communication](http://r4ds.had.co.nz/graphics-for-communication.html)).


To make a plot showing all Walmart stores opened up through that year, I write a function, that takes the year and dataset as parameters.

Since I am calling the function for its side effect (printing the plot) rather than the value it returns, I use the [walk](https://www.rdocumentation.org/packages/purrr/topics/walk) function rather than [map](https://www.rdocumentation.org/packages/purrr/topics/map). See [R for Data Science](http://r4ds.had.co.nz/), [Chapter 21.8: Walk](http://r4ds.had.co.nz/iteration.html#walk) for more information.

```r
map_walmart <- function(year, .data) {
  .data <- filter(.data, opendate < make_date(year, 1, 1)) %>%
    mutate(size = if_else(type == "DistributionCenter", 2, 1))
  ggplot() +
    borders(database = "state") +
    geom_point(aes(x = long, y = lat, colour = type, size = size),
               data = .data, alpha = 1 / 3) +
    coord_quickmap() +
    scale_size_identity() +
    guides(color = guide_legend(override.aes = list(alpha = 1))) +
    theme_void() +
    ggtitle(year)
}

years <- c(1975, 1985, 1995, 2005)
walk(years, ~ print(map_walmart(.x, walmart)))
```

<img src="discovery-spatial_files/figure-html/unnamed-chunk-15-1.png" width="70%" style="display: block; margin: auto;" /><img src="discovery-spatial_files/figure-html/unnamed-chunk-15-2.png" width="70%" style="display: block; margin: auto;" /><img src="discovery-spatial_files/figure-html/unnamed-chunk-15-3.png" width="70%" style="display: block; margin: auto;" /><img src="discovery-spatial_files/figure-html/unnamed-chunk-15-4.png" width="70%" style="display: block; margin: auto;" />


### Animation in R

For easy animation with [ggplot2](https://cran.r-project.org/package=ggplot2), use the [gganimate](https://github.com/dgrtwo/gganimate) package.
Note that the **gganimate** package is not on CRAN, so you have to install it with the [devtools](https://cran.r-project.org/package=devtools) package:

```r
install.packages("cowplot")
devtools::install_github("dgrtwo/animate")
```

```r
library("gganimate")
```

An animation is a series of frames.
The [gganimate](https://cran.r-project.org/package=gganimate) package works by adding a `frame` aesthetic to ggplots, and function  will animate the plot.

I use `frame = year(opendate)` to have the animation use each year as a frame, and `cumulative = TRUE` so that the previous years are shown.

```r
walmart_animated <-
  ggplot() +
    borders(database = "state") +
    geom_point(aes(x = long, y = lat,
                   colour = type,
                   fill = type,
                   frame = year(opendate),
                   cumulative = TRUE),
               data = walmart) +
    coord_quickmap() +
    theme_void()
gganimate(walmart_animated)
```
