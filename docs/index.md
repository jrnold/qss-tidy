
---
title: "QSS Tidyverse Code"
author: "Jeffrey B. Arnold"
date: "2018-01-13"
github-repo: jrnold/qss-tidy
site: "bookdown::bookdown_site"
documentclass: book
---

# Preface {-}

This is tidyverse R code to supplement the book, [Quantitative Social Science: An Introduction](http://press.princeton.edu/titles/11025.html), by Kosuke Imai, to
be published by Princeton University Press in March 2017.

The R code included with the text of *QSS* and the supplementary materials relies mostly on base R functions. 
This translates the code examples provided with *QSS* to tidyverse R code. 
[Tidyverse](https://github.com/tidyverse/tidyverse) refers to a set of packages (**ggplot2**, **dplyr**, **tidyr**, **readr**, **purrr**, **tibble**,  and a few others) that share common data representations, especially the use of data frames for return values. 

These notes do not aim to teach tidyverse, The book [R for Data Science](http://r4ds.had.co.nz/) by Hadley Wickham and Garrett Grolemond is an introduction. 

I wrote this code while teaching course that employed both texts in order to make the excellent examples and statistical material in *QSS* more compatible with the modern data science using R approach in *R4DS*.


## Colophon {-}

To install the R packages used in this work run the following code, installs the **qsstidy** package which contains no code or data, but will install the needed dependencies.

```r
install.packages("devtools")
install_github("jrnold/qss-tidy")
```

Additionally, the [gganimate](https://cran.r-project.org/package=gganimate) package requires installing [ffmpeg](https://ffmpeg.org/) with libvpx support.

The source of the book is available [here](https://github.com/jrnold/qsstidy) and was built with versions of packages below:


```
#> Session info -------------------------------------------------------------
#>  setting  value                       
#>  version  R version 3.4.3 (2017-11-30)
#>  system   x86_64, darwin15.6.0        
#>  ui       X11                         
#>  language (EN)                        
#>  collate  en_US.UTF-8                 
#>  tz       America/Los_Angeles         
#>  date     2018-01-10
#> Packages -----------------------------------------------------------------
#>  package    * version date       source        
#>  animation  * 2.5     2017-03-30 cran (@2.5)   
#>  assertthat   0.2.0   2017-04-11 CRAN (R 3.4.0)
#>  backports    1.1.2   2017-12-13 CRAN (R 3.4.3)
#>  base       * 3.4.3   2017-12-07 local         
#>  bindr        0.1     2016-11-13 CRAN (R 3.4.0)
#>  bindrcpp     0.2     2017-06-17 CRAN (R 3.4.0)
#>  bookdown     0.5     2017-08-20 CRAN (R 3.4.1)
#>  broom        0.4.3   2017-11-20 CRAN (R 3.4.3)
#>  cellranger   1.1.0   2016-07-27 CRAN (R 3.4.0)
#>  cli          1.0.0   2017-11-05 CRAN (R 3.4.2)
#>  colorspace   1.3-2   2016-12-14 CRAN (R 3.4.0)
#>  compiler     3.4.3   2017-12-07 local         
#>  crayon       1.3.4   2017-09-16 CRAN (R 3.4.1)
#>  datasets   * 3.4.3   2017-12-07 local         
#>  devtools     1.13.4  2017-11-09 CRAN (R 3.4.2)
#>  digest       0.6.13  2017-12-14 CRAN (R 3.4.3)
#>  dplyr      * 0.7.4   2017-09-28 CRAN (R 3.4.2)
#>  evaluate     0.10.1  2017-06-24 CRAN (R 3.4.1)
#>  forcats    * 0.2.0   2017-01-23 CRAN (R 3.4.0)
#>  foreign      0.8-69  2017-06-22 CRAN (R 3.4.3)
#>  ggplot2    * 2.2.1   2016-12-30 CRAN (R 3.4.0)
#>  glue         1.2.0   2017-10-29 CRAN (R 3.4.2)
#>  graphics   * 3.4.3   2017-12-07 local         
#>  grDevices  * 3.4.3   2017-12-07 local         
#>  grid         3.4.3   2017-12-07 local         
#>  gtable       0.2.0   2016-02-26 CRAN (R 3.4.0)
#>  haven        1.1.0   2017-07-09 CRAN (R 3.4.1)
#>  hms          0.4.0   2017-11-23 CRAN (R 3.4.3)
#>  htmltools    0.3.6   2017-04-28 CRAN (R 3.4.0)
#>  httr         1.3.1   2017-08-20 CRAN (R 3.4.1)
#>  jsonlite     1.5     2017-06-01 CRAN (R 3.4.0)
#>  knitr        1.18    2017-12-27 CRAN (R 3.4.3)
#>  lattice      0.20-35 2017-03-25 CRAN (R 3.4.3)
#>  lazyeval     0.2.1   2017-10-29 CRAN (R 3.4.2)
#>  lubridate    1.7.1   2017-11-03 CRAN (R 3.4.2)
#>  magrittr     1.5     2014-11-22 CRAN (R 3.4.0)
#>  memoise      1.1.0   2017-04-21 CRAN (R 3.4.0)
#>  methods      3.4.3   2017-12-07 local         
#>  mnormt       1.5-5   2016-10-15 CRAN (R 3.4.0)
#>  modelr       0.1.1   2017-07-24 CRAN (R 3.4.1)
#>  munsell      0.4.3   2016-02-13 CRAN (R 3.4.0)
#>  nlme         3.1-131 2017-02-06 CRAN (R 3.4.3)
#>  parallel     3.4.3   2017-12-07 local         
#>  pillar       1.0.1   2017-11-27 CRAN (R 3.4.3)
#>  pkgconfig    2.0.1   2017-03-21 CRAN (R 3.4.0)
#>  plyr         1.8.4   2016-06-08 CRAN (R 3.4.0)
#>  psych        1.7.8   2017-09-09 CRAN (R 3.4.3)
#>  purrr      * 0.2.4   2017-10-18 CRAN (R 3.4.2)
#>  R6           2.2.2   2017-06-17 CRAN (R 3.4.0)
#>  Rcpp         0.12.14 2017-11-23 CRAN (R 3.4.3)
#>  readr      * 1.1.1   2017-05-16 CRAN (R 3.4.0)
#>  readxl       1.0.0   2017-04-18 CRAN (R 3.4.0)
#>  reshape2     1.4.3   2017-12-11 CRAN (R 3.4.3)
#>  rlang        0.1.6   2017-12-21 CRAN (R 3.4.3)
#>  rmarkdown    1.8     2017-11-17 CRAN (R 3.4.2)
#>  rprojroot    1.3-2   2018-01-03 CRAN (R 3.4.3)
#>  rstudioapi   0.7     2017-09-07 CRAN (R 3.4.1)
#>  rvest        0.3.2   2016-06-17 CRAN (R 3.4.0)
#>  scales       0.5.0   2017-08-24 CRAN (R 3.4.1)
#>  stats      * 3.4.3   2017-12-07 local         
#>  stringi      1.1.6   2017-11-17 CRAN (R 3.4.2)
#>  stringr    * 1.2.0   2017-02-18 CRAN (R 3.4.0)
#>  tibble     * 1.4.1   2017-12-25 CRAN (R 3.4.3)
#>  tidyr      * 0.7.2   2017-10-16 CRAN (R 3.4.2)
#>  tidyverse  * 1.2.1   2017-11-14 CRAN (R 3.4.2)
#>  tools        3.4.3   2017-12-07 local         
#>  utils      * 3.4.3   2017-12-07 local         
#>  withr        2.1.1   2017-12-19 CRAN (R 3.4.3)
#>  xml2         1.1.1   2017-01-24 CRAN (R 3.4.0)
#>  yaml         2.1.16  2017-12-12 CRAN (R 3.4.3)
```
