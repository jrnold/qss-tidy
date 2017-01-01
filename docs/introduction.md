
# Introduction

## Prerequisites


```r
library("tidyverse")
#> Loading tidyverse: ggplot2
#> Loading tidyverse: tibble
#> Loading tidyverse: tidyr
#> Loading tidyverse: readr
#> Loading tidyverse: purrr
#> Loading tidyverse: dplyr
#> Conflicts with tidy packages ----------------------------------------------
#> filter(): dplyr, stats
#> lag():    dplyr, stats
```
We also load the **haven** package to load Stata `dta` files,

```r
library("haven")
```
and the **rio** package to load multiple types of files,

```r
library("rio")
```


## Introduction to R

### Data Files

Don't use `setwd()` within scripts.
It is much better to organize your code in projects.

When reading from csv files use `readr::read_csv` instead of the base R function `read.csv`. 
It is slightly faster, and returns a `tibble` instead of a data frame.
See r4ds [Ch 11: Data Import](http://r4ds.had.co.nz/tibbles.html#introduction-4)
for more dicussion.

We also can load it directly from a URL.

```r
UNpop <- read_csv("https://raw.githubusercontent.com/jrnold/qss/master/INTRO/UNpop.csv")
#> Parsed with column specification:
#> cols(
#>   year = col_integer(),
#>   world.pop = col_integer()
#> )
class(UNpop)
#> [1] "tbl_df"     "tbl"        "data.frame"
UNpop
#> # A tibble: 7 × 2
#>    year world.pop
#>   <int>     <int>
#> 1  1950   2525779
#> 2  1960   3026003
#> 3  1970   3691173
#> 4  1980   4449049
#> 5  1990   5320817
#> 6  2000   6127700
#> # ... with 1 more rows
```

The single bracket, `[`, is useful to select rows and columns in simple cases,
but the **dplyr** functions `slice()` to select rows by number, `filter` to select by certain criteria, or `select()` to select columns.


```r
UNpop[c(1, 2, 3), ]
#> # A tibble: 3 × 2
#>    year world.pop
#>   <int>     <int>
#> 1  1950   2525779
#> 2  1960   3026003
#> 3  1970   3691173
```
is equivalent to 

```r
UNpop %>% slice(1:3)
#> # A tibble: 3 × 2
#>    year world.pop
#>   <int>     <int>
#> 1  1950   2525779
#> 2  1960   3026003
#> 3  1970   3691173
```


```r
UNpop[, "world.pop"]
#> # A tibble: 7 × 1
#>   world.pop
#>       <int>
#> 1   2525779
#> 2   3026003
#> 3   3691173
#> 4   4449049
#> 5   5320817
#> 6   6127700
#> # ... with 1 more rows
```
is almost equivalent to 

```r
select(UNpop, world.pop)
#> # A tibble: 7 × 1
#>   world.pop
#>       <int>
#> 1   2525779
#> 2   3026003
#> 3   3691173
#> 4   4449049
#> 5   5320817
#> 6   6127700
#> # ... with 1 more rows
```
However, note that `select()` **always** returns a tibble, and never a vector, 
even if only one column is selected.
Also, note that since `world.pop` is a tibble, using `[` also returns tibbles 
rather than a vector if it is only one column.


```r
UNpop[1:3, "year"]
#> # A tibble: 3 × 1
#>    year
#>   <int>
#> 1  1950
#> 2  1960
#> 3  1970
```
is almost equivalent to 

```r
UNpop %>%
  slice(1:3) %>%
  select(year)
#> # A tibble: 3 × 1
#>    year
#>   <int>
#> 1  1950
#> 2  1960
#> 3  1970
```
For this example using these functions and `%>%` to chain them together may 
seem a little excessive, but later we will see how chaining simple functions 
togther like that becomes a very powerful way to build up complicated logic.



```r
UNpop$world.pop[seq(from = 1, to = nrow(UNpop), by = 2)]
#> [1] 2525779 3691173 5320817 6916183
```
can be rewritten as

```r
UNpop %>%
  slice(seq(1, n(), by = 2)) %>%
  select(world.pop) 
#> # A tibble: 4 × 1
#>   world.pop
#>       <int>
#> 1   2525779
#> 2   3691173
#> 3   5320817
#> 4   6916183
```

The function `n()` when used in a dplyr functions returns the number of rows
in the data frame (or the number of rows in the group if used with `group_by`).

### Saving Objects

**Do not save** the workspace using `save.image`.
This is an extremely bad idea for reproducibility.
See r4ds [Ch 8](http://r4ds.had.co.nz/workflow-projects.html). 
You should uncheck the options in RStudio to avoid saving and rstoring from `.RData` files. 
This will help ensure that your R code runs the way you think it does, instead of depending on some long forgotten code that is only saved in the workspace image. 

Everything important should be in a script. Anything saved or loaded from file
should be done explicitly.

As with reading CSVs, use the **readr** package functions. 
In this case, `write_csv` writes a csv file


```r
write_csv(UNpop, "UNpop.csv")
```

### Packages

Instead of **foreign** for reading and writing Stata and SPSS files, use **haven**. 
One reason to do so is that it is better maintained. 
The R function `read.dta` does not read files created by the most recent versions of Stata (13+).


```r
read_dta("https://raw.githubusercontent.com/kosukeimai/qss/master/INTRO/UNpop.dta")
#> # A tibble: 7 × 2
#>    year world_pop
#>   <dbl>     <dbl>
#> 1  1950      2526
#> 2  1960      3026
#> 3  1970      3691
#> 4  1980      4449
#> 5  1990      5321
#> 6  2000      6128
#> # ... with 1 more rows
```

There is also the equivalent `write_dta` function to create Stata datasets.

```r
write_dta(UNpop, "UNpop.dta")
```

Also see the [rio](https://cran.r-project.org/package=rio) package which makes loading data even easier with smart defaults.

You can use the `import` function to load many types of files:

```r
import("https://raw.githubusercontent.com/kosukeimai/qss/master/INTRO/UNpop.csv")
#>   year world.pop
#> 1 1950   2525779
#> 2 1960   3026003
#> 3 1970   3691173
#> 4 1980   4449049
#> 5 1990   5320817
#> 6 2000   6127700
#> 7 2010   6916183
import("https://raw.githubusercontent.com/kosukeimai/qss/master/INTRO/UNpop.RData")
#>   year world.pop
#> 1 1950   2525779
#> 2 1960   3026003
#> 3 1970   3691173
#> 4 1980   4449049
#> 5 1990   5320817
#> 6 2000   6127700
#> 7 2010   6916183
import("https://raw.githubusercontent.com/kosukeimai/qss/master/INTRO/UNpop.dta")
#>   year world_pop
#> 1 1950      2526
#> 2 1960      3026
#> 3 1970      3691
#> 4 1980      4449
#> 5 1990      5321
#> 6 2000      6128
#> 7 2010      6916
```

### Style Guide

Follow [Hadley Wickham's Style Guide](http://adv-r.had.co.nz/Style.html) not the Google R style guide.

In addition to **lintr**, the R package [formatR](https://cran.r-project.org/package=formatR) has methods to clean up your code.
