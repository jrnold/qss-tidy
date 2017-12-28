
# Discovery

The idea of tidy data and the common feature of tidyverse packages is that data should be stored in data frames with certain conventions.
This works well with naturally tabular data, the type which has been common in social science applications.
But there are other domains in which other data structures are more appropriate because they more naturally model the data or processes, or for computational reasons.
The three applications in this chapter: text, networks, and spatial data are examples where the tidy data structure is less of an advantage.
I will still rely on **ggplot2** for plotting, and use tidy verse compatible packages where appropriate.

- Textual data: [tidytext](https://cran.r-project.org/package=tidytext)
- Network data: [igraph](https://cran.r-project.org/package=igraph) for network computation, as in the chapter. But several **ggplot2**2 extension packages for plotting the networks.
- Spatial data: [ggplot2](https://cran.r-project.org/package=ggplot2) has some built-in support for maps. The [map](https://cran.r-project.org/package=map) package provides map data.

See the [R for Data Science](http://r4ds.had.co.nz/) section [12.7 Non-tidy data](http://r4ds.had.co.nz/tidy-data.html#non-tidy-data) and this post on [Non-tidy data](http://simplystatistics.org/2016/02/17/non-tidy-data/) by Jeff Leek for more on non-tidy data.
