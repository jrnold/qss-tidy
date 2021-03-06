
---
output: html_document
editor_options:
  chunk_output_type: console
---

# Introduction

## Prerequisites {-}

In this and other chapters we will make use of data from the `qss` package, which is available on github. Install it using the `install_github()` function from the library `devtools`.


```r
devtools::install_github("kosukeimai/qss-package")
```

```r
library("qss")
```

In the prerequisites section of each chapter, we'll load any packages needed for the chapter, possibly define some functions, and possibly load data.
It is good practice to load necessary libraries at the start of an R markdown file or script.


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
and the **rio** package to load multiple types of files


```r
library("rio")
```

## Overview of the Book

<!-- define all sections so that numbering matches that of the book -->

This sections contains no code to translate -- see *QSS* text.

## How to use the Book

This sections contains no code to translate -- see *QSS* text.

## Introduction to R

These notes do not aim to completely teach R and the tidyverse.
However, there are many other resources for that.

[R for Data Science](http://r4ds.had.co.nz/) is a comprehensive introduction to R
using the tidyverse.

[Data Camp](https://www.datacamp.com/home) has interactive courses. In particular,
I recommend starting with the following two courses.

-   [Introduction to R](https://www.datacamp.com/courses/free-introduction-to-r)
-   [Introduction to the Tidyverse](https://www.datacamp.com/courses/introduction-to-the-tidyverse)

### Arithmetic Operations

This sections contains no code to translate---see *QSS* text.

### Objects

This sections contains no code to translate---see *QSS* text.

Also see [R4DS: Workflow basics](http://r4ds.had.co.nz/workflow-basics.html).

### Vectors

This sections contains no code to translate---see *QSS* text.

Also see [R4DS: Vectors](http://r4ds.had.co.nz/vectors.html). In
*R for Data Science* vectors are introduced much later, after data frames.

### Functions

This sections contains no code to translate---see *QSS* text.

Also see [R4DS: Functions](http://r4ds.had.co.nz/functions.html).

### Data Files

Rather than using `setwd()` in scripts, data analysis should be organized in
projects. Read the introduction on RStudio projects in  [R4DS](http://r4ds.had.co.nz/workflow-projects.html).[^setwd]

Datasets used in R are accessed in two ways.

First, datasets can be distributed with R packages. These are often smaller
datasets used in examples and tutorials in packages. These are loaded with the
`data()` function. For example you can load UN data on demographic statistics
from the **qss** library, which distributes the data sets used in the *QSS*
textbook. (The function `data()` called without any arguments will list all the
datasets distributed with installed packages.)


```r
data("UNpop", package = "qss")
```

Second, datasets can be loaded from external files including both stored R
objects (`.RData`, `.rda`) and other formats (`.csv`, `.dta`, `.sav`). To read
a [csv](https://en.wikipedia.org/wiki/Comma-separated_values) file into R use
the `read_csv` function from the **readr** library, part of the tidyverse.


```r
UNpop_URL <- "https://raw.githubusercontent.com/kosukeimai/qss/master/INTRO/UNpop.csv"
UNpop <- read_csv(UNpop_URL)
#> Parsed with column specification:
#> cols(
#>   year = col_integer(),
#>   world.pop = col_integer()
#> )
```

We use the readr function`read_csv()` instead of the base R function `read.csv()` used in the *QSS* text. It is slightly faster, and returns a `tibble` instead of a data frame. Check this by calling `class()` on the new object.


```r
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
See [R for Data Science](http://r4ds.had.co.nz/) [Ch 11: Data Import](http://r4ds.had.co.nz/tibbles.html#introduction-4)
for more discussion.

Note that in the previous code we loaded the file directly from a URL, but we could also work with local files on your computer, e.g.

```r
UNpop <- read_csv("INTRO/UNpop.csv")
```

See [R for Data Science](http://r4ds.had.co.nz/) [Ch 10: Tibbles](http://r4ds.had.co.nz/tibbles.html) for a deeper discussion of data frames.

The single bracket, `[`, is useful to select rows and columns in simple cases.


```r
UNpop[c(1, 2, 3), ]
#> # A tibble: 3 x 2
#>    year world.pop
#>   <int>     <int>
#> 1  1950   2525779
#> 2  1960   3026003
#> 3  1970   3691173
```

There are **dplyr** functions to select rows by number, to select rows by certain criteria, or to select columns.

To select rows 1--3, use `slice()`.


```r
slice(UNpop, 1:3)
#> # A tibble: 3 x 2
#>    year world.pop
#>   <int>     <int>
#> 1  1950   2525779
#> 2  1960   3026003
#> 3  1970   3691173
```

Base R allows you to choose the column `world.pop` column from the `UNpop` data frame:


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
Unlike `[`, the `[[` and `$` operators can only select a single column and return a vector.[^extract1]
The `dplyr` function `select()` **always** returns a tibble (data frame), and never a vector, even if only one column is selected.

Select rows 1--3 of the `year` column:

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

The same series of functions can be performed using the pipe operator, `%>%`.


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
This example may seem verbose, but later we can produce more complicated transformations of the data by chaining together simple functions.

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

The function `n()` when used in a **dplyr** function returns the number of rows in the data frame (or the number of rows in the group if used with `group_by()`).
The function  `row_number()` returns the row number of an observation.
The `%%` operator returns the modulus, i.e. division remainder.

### Saving Objects

It is not recommended that you save the entire R workspace using `save.image` due to the negative and unexpected impacts it can have on reproducibility.See the [R for Data Science](http://r4ds.had.co.nz/) chapter [Workflow Projects](http://r4ds.had.co.nz/workflow-projects.html).

You should uncheck the options in RStudio to avoid saving and restoring from `.RData` files (go to `Tools > Global Options > General`).
This will help ensure that your R code runs the way you think it does, instead of depending on some long forgotten code that is only saved in the workspace image.
Everything important should be in a script. Anything saved or loaded from file
should be done explicitly.

Your motto should be that the **source is real**, not the objects created by it.

> The source code is real. The objects are realizations of the source code. Source for EVERY user modified object is placed in a particular directory or directories, for later editing and retrieval. – from the [ESS manual](https://ess.r-project.org/Manual/ess.html#Philosophies-for-using-ESS_0028S_0029)

This means that while you should not save the entire workplace it is perfectly fine practice to run a script and save or load R objects to files, using  or .

As with reading CSV files, use the [readr](http://readr.tidyverse.org/) package functions.
In this case, `write_csv()` writes a csv file and takes at least two objects: the data that you want to write to a csv and the name that you want to give the file.


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
#> 1  1950     2526.
#> 2  1960     3026.
#> 3  1970     3691.
#> 4  1980     4449.
#> 5  1990     5321.
#> 6  2000     6128.
#> # ... with 1 more row
```

There is also the equivalent `write_dta()` function to create Stata datasets.


```r
write_dta(UNpop, "UNpop.dta")
```

While Stata and SPSS data sets are quite similar to data frames, they differ slightly in definitions of acceptable data types of columns and what metadata they store with the data.
Be careful when reading and writing from these formats to ensure that information is not lost.

Also see the [rio](https://cran.r-project.org/package=rio) package which makes loading data even easier with smart defaults.

You can use the `import()` function to load many types of files:


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

R also includes the **foreign** package, which contains functions for reading and writing files using **haven**.
One reason to use these packages is that they are better maintained.
For example, the R function `read.dta()` does not read files created by the most recent versions of Stata (13+), whereas **haven** does.

### Style Guide

Following a consistent coding style is important for your code to be readable by you and others.
The preferred style is the [tidyverse style guide](http://style.tidyverse.org/), which
differs slightly from [Google's R style guide](http://style.tidyverse.org/).

-   The [lintr](https://cran.r-project.org/package=lintr) package will check files for style errors.

-   The [styler](https://cran.r-project.org/package=styler) package provides functions for automatically formatting
    R code according to style guides.

-   In RStudio, go to the `Tools > Global Options > Code > Diagnostics` pane and check the
    box to activate style warnings. On this pane, there are other options that can be
    set in order to increase or decrease the amount of warnings while writing R code in RStudio.

[^setwd]: For more on using projects read [Project-oriented workflow](https://www.tidyverse.org/articles/2017/12/workflow-vs-script/).

[^extract1]: See the discussion in
    [R for DataScience](http://r4ds.had.co.nz/tibbles.html#tibbles-vs.data.frame)
    on how `tibble` objects differ from base `data.frame` objects in how the single bracket `[` is handled.
