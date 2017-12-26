
---
output: html_document
editor_options: 
  chunk_output_type: console
---

# Introduction

## Prerequisites {-}

In the prerequsites section of each chapter, we'll load any packages
needed for the chaper, and possibly define some funcitons or load data.


```r
library("tidyverse")
```
We also load the **readr** package to load `csv` files,

```r
library("readr")
```
the **haven** package to load Stata `dta` files,

```r
library("haven")
```
and the **rio** package to load multiple types of files.

```r
library("rio")
```



## Overview of the Book

<!-- define all sections so that numbering matches that of the book -->


## How to use the Book


## Introduction to R

These notes don't aim to completely teach R and the tidyverse. 
However, there are many other resources for that.

[R for Data Science](http://r4ds.had.co.nz/) is an comprehensive introduction to the 
using the Tidyverse.

[Data Camp](https://www.datacamp.com/home) has interactive courses. In particular,
I recommende starting with the following two courses.

- [Introduction to R](https://www.datacamp.com/courses/free-introduction-to-r)
- [Introduction to the Tidyverse](https://www.datacamp.com/courses/introduction-to-the-tidyverse)


### Arithmetic Operations

See *QSS* text


### Objects

See *QSS* text. Also see [R4DS: Workflow basics](http://r4ds.had.co.nz/workflow-basics.html).


### Vectors

See *QSS* text. Also see [R4DS: Vectors](http://r4ds.had.co.nz/vectors.html). In 
*R for Data Science* vectors are introduced much later, after data frames.


### Functions

See *QSS* text. Also see [R4DS: Functions](http://r4ds.had.co.nz/functions.html).


### Data Files


Rather than using `setwd()` in scripts, data analysis should be organized in
projects. Read the introduction on RStudio projects in  [R4DS](http://r4ds.had.co.nz/workflow-projects.html).[^setwd]


[^setwd]: For more on using projects read [Project-oriented worfklow](https://www.tidyverse.org/articles/2017/12/workflow-vs-script/).


Datasets used in R are accessed in two ways.

- Datasets can also be distributed with R packages. These are often smaller datasets used in examples and tutorials in packages. These are loaded with the `data()` function.
- Loaded from an external files including both stored R objects (`.RData`, `.rda`) and other formats (`.csv`, `.dta`, `.sav`).


The function `data` with called without any arguments will list all the datasets distributed with installed packages.

```r
data()
```
The **qss** library distributes the data sets used in the *QSS* textbook.

```r
data("UNpop", package = "qss")
```

To read a [csv](https://en.wikipedia.org/wiki/Comma-separated_values) file into R use the 

```r
UNpop_URL <- "https://raw.githubusercontent.com/kosukeimai/qss/master/INTRO/UNpop.csv"
UNpop <- read_csv(UNpop_URL)
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
#> # ... with 1 more row
```
When reading from csv files use `readr::read_csv` instead of the base R function `read.csv` used in the *QSS* text.
It is slightly faster, and returns a `tibble` instead of a data frame.
See [R for Data Science](http://r4ds.had.co.nz/) [Ch 11: Data Import](http://r4ds.had.co.nz/tibbles.html#introduction-4)
for more discussion.

Note that in the previous code we loaded the file directly from a URL, but it would also work with local files on your computer, e.g.

```r
read_csv("INTRO/UNpop.csv")
```

See [R for Data Science](http://r4ds.had.co.nz/) [Ch 10: Tibbles](http://r4ds.had.co.nz/tibbles.html) for a deeper discussion of data frames.

The single bracket, `[`, is useful to select rows and columns in simple cases,
but the **dplyr** functions  to select rows by number,  to select rows by certain criteria, or  to select columns.

Select rows 1--3:

```r
UNpop[c(1, 2, 3), ]
#> # A tibble: 3 x 2
#>    year world.pop
#>   <int>     <int>
#> 1  1950   2525779
#> 2  1960   3026003
#> 3  1970   3691173
slice(UNpop, 1:3)
#> # A tibble: 3 x 2
#>    year world.pop
#>   <int>     <int>
#> 1  1950   2525779
#> 2  1960   3026003
#> 3  1970   3691173
```

Select the `world.pop` column from the `UNpop` data frame:

```r
UNpop[, "world.pop"]
#> # A tibble: 7 x 1
#>   world.pop
#>       <int>
#> 1   2525779
#> 2   3026003
#> 3   3691173
#> 4   4449049
#> 5   5320817
#> 6   6127700
#> # ... with 1 more row
UNpop$world.pop
#> [1] 2525779 3026003 3691173 4449049 5320817 6127700 6916183
UNpop[["world.pop"]]
#> [1] 2525779 3026003 3691173 4449049 5320817 6127700 6916183
select(UNpop, world.pop)
#> # A tibble: 7 x 1
#>   world.pop
#>       <int>
#> 1   2525779
#> 2   3026003
#> 3   3691173
#> 4   4449049
#> 5   5320817
#> 6   6127700
#> # ... with 1 more row
```
However, note that, by default, `[` will return a vector rather than a data frame if only one column is selected. 
This may seem convenient, but it can result in many hard to find and surprising bugs in practice.
The `[[` and `$` operators can only select a single column and return a vector.
The function `select()` **always** returns a tibble (data frame), and never a vector, even if only one column is selected.
Also, note that since `world.pop` is a tibble, using `[` also returns tibbles
rather than a vector if it is only one column.


Select rows 1--3 and the `year` column:

```r
UNpop[1:3, "year"]
#> # A tibble: 3 x 1
#>    year
#>   <int>
#> 1  1950
#> 2  1960
#> 3  1970
```
or,

```r
select(slice(UNpop, 1:3), year)
#> # A tibble: 3 x 1
#>    year
#>   <int>
#> 1  1950
#> 2  1960
#> 3  1970
```
or,

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

Select every other row from `UNpop`:

```r
UNpop$world.pop[seq(from = 1, to = nrow(UNpop), by = 2)]
#> [1] 2525779 3691173 5320817 6916183
```
or

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
or

```r
UNpop %>%
  filter(row_number() %% 2 == 1)
#> # A tibble: 4 x 2
#>    year world.pop
#>   <int>     <int>
#> 1  1950   2525779
#> 2  1970   3691173
#> 3  1990   5320817
#> 4  2010   6916183
```

The function  when used in a **dplyr** function returns the number of rows
in the data frame (or the number of rows in the group if used with ).
The function  returns the row number of an observation. 
The `%%` operator returns the modulus, e.g. division remainder.


### Saving Objects

It is not recommended that you save the entire R workspace using using `save.image` due to the negative and unexpected impacts it can have on reproducibility.

See the [R for Data Science](http://r4ds.had.co.nz/) chapter [Workflow Projects](http://r4ds.had.co.nz/workflow-projects.html).
You should uncheck the options in RStudio to avoid saving and restoring from `.RData` files.
This will help ensure that your R code runs the way you think it does, instead of depending on some long forgotten code that is only saved in the workspace image.
Everything important should be in a script. Anything saved or loaded from file
should be done explicitly.

Your motto should be that the **source is real**, not the objects created by it.

> The source code is real. The objects are realizations of the source code. Source for EVERY user modified object is placed in a particular directory or directories, for later editing and retrieval. – from the [ESS manual](https://ess.r-project.org/Manual/ess.html#Philosophies-for-using-ESS_0028S_0029)

This means that while you should not save the entire workplace it is peferctly find practice to run a script and save or load R objects to files, using  or .

As with reading CSV files, use the [readr](http://readr.tidyverse.org/) package functions.
In this case,  writes a csv file

```r
write_csv(UNpop, "UNpop.csv")
```


### Programming and Learning Tips

Use the [haven](http://haven.tidyverse.org/) package to read and write Stata (`.dta`) and SPSS (`.sav`) files.
Stata and SPSS are two other statistical programs commonly used in social science.
Even if you don't ever use them, you'll almost certainly encounter data stored in their native formats.

```r
UNpop_dta_url <- "https://github.com/kosukeimai/qss/raw/master/INTRO/UNpop.dta"
UNpop <- read_dta(UNpop_dta_url)
UNpop
#> # A tibble: 7 x 2
#>    year world_pop
#>   <dbl>     <dbl>
#> 1  1950      2526
#> 2  1960      3026
#> 3  1970      3691
#> 4  1980      4449
#> 5  1990      5321
#> 6  2000      6128
#> # ... with 1 more row
```

There is also the equivalent `write_dta` function to create Stata datasets.

```r
write_dta(UNpop, "UNpop.dta")
```

One thing to note is that Stata and SPSS have different concept

Also see the [rio](https://cran.r-project.org/package=rio) package which makes loading data even easier with smart defaults.

You can use the `import` function to load many types of files:

```r
import("https://github.com/kosukeimai/qss/raw/master/INTRO/UNpop.csv")
#>   year world.pop
#> 1 1950   2525779
#> 2 1960   3026003
#> 3 1970   3691173
#> 4 1980   4449049
#> 5 1990   5320817
#> 6 2000   6127700
#> 7 2010   6916183
import("https://github.com/kosukeimai/qss/raw/master/INTRO/UNpop.RData")
#>   year world.pop
#> 1 1950   2525779
#> 2 1960   3026003
#> 3 1970   3691173
#> 4 1980   4449049
#> 5 1990   5320817
#> 6 2000   6127700
#> 7 2010   6916183
import("https://github.com/kosukeimai/qss/raw/master/INTRO/UNpop.dta")
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

Following a consistent coding style is important for your code to be readable by yourself and other.
The preferred style is the [tidyverse style guide](http://style.tidyverse.org/), which
differs slightly from [Google's R style guide](http://style.tidyverse.org/).

- The [lintr](https://cran.r-project.org/package=lintr) package will check files for style errors
- The [styler](https://cran.r-project.org/package=styler) package provides functions for automatically formatting
    R code according to style guides.
- In RStudio, go to the `Tools > Global Options > Code > Diagnostics` pane and check the
    box to activate style warnings. On this pane, there are other options that can be 
    set in order to provide more or less warnings while writing R code in Rstudio.

