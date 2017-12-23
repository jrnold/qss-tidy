
# Introduction

## Prerequisites


```r
library("tidyverse")
```
We also load the **haven** package to load Stata `dta` files,

```r
library("haven")
```
and the **rio** package to load multiple types of files.

```r
library("rio")
```
We also create a helper function for loading in the data.
We will also, use the function `qss_data_url`:



This function returns the URL to a data set.

```r
qss_data_url("intro", "Kenya.csv")
#> [1] "https://raw.githubusercontent.com/kosukeimai/qss/master/INTRO/Kenya.csv"
```
Since URLs can be used for paths to files, this can be used to easily load data directly from the site:

```r
read_csv(qss_data_url("intro", "Kenya.csv"))
#> # A tibble: 30 x 8
#>   country    period   age births deaths py.men py.women    l_x
#>     <chr>     <chr> <chr>  <dbl>  <dbl>  <dbl>    <dbl>  <dbl>
#> 1     KEN 1950-1955   0-4      0  398.3   2983     2978 100000
#> 2     KEN 1950-1955   5-9      0   36.8   1978     1970  75157
#> 3     KEN 1950-1955 10-14      0   19.5   1635     1634  71365
#> 4     KEN 1950-1955 15-19    264   18.5   1589     1565  69469
#> 5     KEN 1950-1955 20-24    486   21.4   1428     1364  67421
#> 6     KEN 1950-1955 25-29    383   20.4   1205     1106  64855
#> # ... with 24 more rows
```



## Introduction to R

### Data Files

Don't use `setwd()` within scripts.
It is much better to organize your code in projects.

When reading from csv files use `readr::read_csv` instead of the base R function `read.csv`. 
It is slightly faster, and returns a `tibble` instead of a data frame.
See [R for Data Science](http://r4ds.had.co.nz/) [Ch 11: Data Import](http://r4ds.had.co.nz/tibbles.html#introduction-4)
for more discussion.

We also can load it directly from a URL.

```r
UNpop <- read_csv(qss_data_url("INTRO", "UNpop.csv"))
#> Parsed with column specification:
#> cols(
#>   year = col_integer(),
#>   world.pop = col_integer()
#> )
class(UNpop)
#> [1] "tbl_df"     "tbl"        "data.frame"
UNpop
#> # A tibble: 7 x 2
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


Datasets can also be distributed with R packages. 
These are often smaller datasets used in examples and package tutorials.

The function `data` with called without any arguments will list all the datasets distributed with installed packages.

```r
data()
```
The **qss** library distributes the data sets used in the *QSS* textbook.

```r
data("UNpop", package = "qss")
```

The single bracket, `[`, is useful to select rows and columns in simple cases,
but the **dplyr** functions `slice()` to select rows by number, `filter` to select by certain criteria, or `select()` to select columns.


```r
UNpop[c(1, 2, 3), ]
#>   year world.pop
#> 1 1950   2525779
#> 2 1960   3026003
#> 3 1970   3691173
```
is equivalent to 

```r
UNpop %>% slice(1:3)
#> # A tibble: 3 x 2
#>    year world.pop
#>   <int>     <int>
#> 1  1950   2525779
#> 2  1960   3026003
#> 3  1970   3691173
```


```r
UNpop[, "world.pop"]
#> [1] 2525779 3026003 3691173 4449049 5320817 6127700 6916183
```
is almost equivalent to 

```r
select(UNpop, world.pop)
#>   world.pop
#> 1   2525779
#> 2   3026003
#> 3   3691173
#> 4   4449049
#> 5   5320817
#> 6   6127700
#> 7   6916183
```
However, note that `select()` **always** returns a tibble, and never a vector, 
even if only one column is selected.
Also, note that since `world.pop` is a tibble, using `[` also returns tibbles 
rather than a vector if it is only one column.


```r
UNpop[1:3, "year"]
#> [1] 1950 1960 1970
```
is equivalent to 

```r
UNpop %>%
  slice(1:3) %>%
  select(year)
#> # A tibble: 3 x 1
#>    year
#>   <int>
#> 1  1950
#> 2  1960
#> 3  1970
```
For this example using these functions and `%>%` to chain them together may seem verbose, but later we can produce more complicated transformations of the data by chaining together simple functions.


```r
UNpop$world.pop[seq(from = 1, to = nrow(UNpop), by = 2)]
#> [1] 2525779 3691173 5320817 6916183
```
can be rewritten as

```r
UNpop %>%
  slice(seq(1, n(), by = 2)) %>%
  select(world.pop) 
#> # A tibble: 4 x 1
#>   world.pop
#>       <int>
#> 1   2525779
#> 2   3691173
#> 3   5320817
#> 4   6916183
```

The function `n()` when used in a **dplyr** function returns the number of rows
in the data frame (or the number of rows in the group if used with `group_by`).



### Saving Objects

**Do not save** the work space using `save.image`.
This is an extremely bad idea for reproducibility.

See the [R for Data Science](http://r4ds.had.co.nz/) chapter [Workflow Projects](http://r4ds.had.co.nz/workflow-projects.html). 
You should uncheck the options in RStudio to avoid saving and restoring from `.RData` files. 
This will help ensure that your R code runs the way you think it does, instead of depending on some long forgotten code that is only saved in the workspace image. 

Everything important should be in a script. Anything saved or loaded from file
should be done explicitly.

As with reading CSV files, use the **readr** package functions. 
In this case, `write_csv` writes a csv file

```r
write_csv(UNpop, "UNpop.csv")
```


### Packages

To read and write Stata and SPSS 


```r
read_dta(qss_data_url("INTRO", "UNpop.dta"))
#> # A tibble: 7 x 2
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
import(qss_data_url("INTRO", "UNpop.csv"))
#>   year world.pop
#> 1 1950   2525779
#> 2 1960   3026003
#> 3 1970   3691173
#> 4 1980   4449049
#> 5 1990   5320817
#> 6 2000   6127700
#> 7 2010   6916183
import(qss_data_url("INTRO", "UNpop.RData"))
#>   year world.pop
#> 1 1950   2525779
#> 2 1960   3026003
#> 3 1970   3691173
#> 4 1980   4449049
#> 5 1990   5320817
#> 6 2000   6127700
#> 7 2010   6916183
import(qss_data_url("INTRO", "UNpop.dta"))
#>   year world_pop
#> 1 1950      2526
#> 2 1960      3026
#> 3 1970      3691
#> 4 1980      4449
#> 5 1990      5321
#> 6 2000      6128
#> 7 2010      6916
```

R also includes the **foreign** package, which contains functions for reading and writing  **haven**. 
One reason to do so is that it is better maintained. 
For  R function `read.dta` does not read files created by the most recent versions of Stata (13+).


### Style Guide


In addition to [lintr](https://cran.r-project.org/package=lintr) the R package [formatR](https://cran.r-project.org/package=formatR) has methods to clean up your code.

