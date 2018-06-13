
---
knit: "bookdown::render_book"
title: "Quantatitive Social Science: The R Tidyverse Code"
description: >
  This supplement for Kosuke Imai's "Quantitative Social Science: An Introduction"
  contains Tidyverse R code versions of the code in the original text.
author: "Jeffrey B. Arnold"
twitter: jrnld
github-repo: "jrnold/qss-tidy"
url: 'http\://jrnold.github.io/qss-tidy'
date: "2018-06-12"
site: "bookdown::bookdown_site"
documentclass: book
---

# Preface {-}

This is tidyverse R code to supplement the book, [Quantitative Social Science: An Introduction](http://press.princeton.edu/titles/11025.html), by Kosuke Imai.

The R code included with the text of *QSS* and the supplementary materials relies mostly on base R functions.
This translates the code examples provided with *QSS* to tidyverse R code.
[Tidyverse](https://github.com/tidyverse/tidyverse) refers to a set of packages (**ggplot2**, **dplyr**, **tidyr**, **readr**, **purrr**, **tibble**,  and a few others) that share common data representations, especially the use of data frames for return values.

This is not a complete introduction to R and the tidyverse.
I suggest pairing it with [R for Data Science](http://r4ds.had.co.nz/) by Hadley Wickham and Garrett Grolemond.

These materials are supplement to replace the existing *QSS* code with the tidvyerse dialect of R.
Thus it does not replicate the substantive material, and not meant to be used independently of the *QSS* text.
However, the provided code is not merely a translation of the *QSS* code.
It often uses the topics in *QSS* to delve deeper into data science, data visualization, and computational topics.

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
#>  version  R version 3.5.0 (2018-04-23)
#>  system   x86_64, darwin15.6.0        
#>  ui       X11                         
#>  language (EN)                        
#>  collate  en_US.UTF-8                 
#>  tz       America/Los_Angeles         
#>  date     2018-06-12
#> Packages -----------------------------------------------------------------
#>  package    * version    date       source                            
#>  animation  * 2.5        2017-03-30 cran (@2.5)                       
#>  assertthat   0.2.0      2017-04-11 CRAN (R 3.5.0)                    
#>  backports    1.1.2      2017-12-13 CRAN (R 3.5.0)                    
#>  base       * 3.5.0      2018-04-24 local                             
#>  bindr        0.1.1      2018-03-13 CRAN (R 3.5.0)                    
#>  bindrcpp     0.2.2      2018-03-29 CRAN (R 3.5.0)                    
#>  bookdown     0.7        2018-02-18 CRAN (R 3.5.0)                    
#>  broom        0.4.4      2018-03-29 CRAN (R 3.5.0)                    
#>  cellranger   1.1.0      2016-07-27 CRAN (R 3.5.0)                    
#>  cli          1.0.0      2017-11-05 CRAN (R 3.5.0)                    
#>  colorspace   1.3-2      2016-12-14 CRAN (R 3.5.0)                    
#>  compiler     3.5.0      2018-04-24 local                             
#>  crayon       1.3.4      2017-09-16 CRAN (R 3.5.0)                    
#>  datasets   * 3.5.0      2018-04-24 local                             
#>  devtools     1.13.5     2018-02-18 CRAN (R 3.5.0)                    
#>  digest       0.6.15     2018-01-28 CRAN (R 3.5.0)                    
#>  dplyr      * 0.7.5      2018-05-19 cran (@0.7.5)                     
#>  evaluate     0.10.1     2017-06-24 CRAN (R 3.5.0)                    
#>  forcats    * 0.3.0      2018-02-19 CRAN (R 3.5.0)                    
#>  foreign      0.8-70     2017-11-28 CRAN (R 3.5.0)                    
#>  ggplot2    * 2.2.1.9000 2018-06-13 Github (tidyverse/ggplot2@4db5122)
#>  glue         1.2.0      2017-10-29 CRAN (R 3.5.0)                    
#>  graphics   * 3.5.0      2018-04-24 local                             
#>  grDevices  * 3.5.0      2018-04-24 local                             
#>  grid         3.5.0      2018-04-24 local                             
#>  gtable       0.2.0      2016-02-26 CRAN (R 3.5.0)                    
#>  haven        1.1.1      2018-01-18 CRAN (R 3.5.0)                    
#>  hms          0.4.2      2018-03-10 CRAN (R 3.5.0)                    
#>  htmltools    0.3.6      2017-04-28 CRAN (R 3.5.0)                    
#>  httr         1.3.1      2017-08-20 CRAN (R 3.5.0)                    
#>  jsonlite     1.5        2017-06-01 CRAN (R 3.5.0)                    
#>  knitr        1.20       2018-02-20 CRAN (R 3.5.0)                    
#>  lattice      0.20-35    2017-03-25 CRAN (R 3.5.0)                    
#>  lazyeval     0.2.1      2017-10-29 CRAN (R 3.5.0)                    
#>  lubridate    1.7.4      2018-04-11 CRAN (R 3.5.0)                    
#>  magrittr     1.5        2014-11-22 CRAN (R 3.5.0)                    
#>  memoise      1.1.0      2017-04-21 CRAN (R 3.5.0)                    
#>  methods    * 3.5.0      2018-04-24 local                             
#>  mnormt       1.5-5      2016-10-15 CRAN (R 3.5.0)                    
#>  modelr       0.1.2      2018-05-11 cran (@0.1.2)                     
#>  munsell      0.4.3      2016-02-13 CRAN (R 3.5.0)                    
#>  nlme         3.1-137    2018-04-07 CRAN (R 3.5.0)                    
#>  parallel     3.5.0      2018-04-24 local                             
#>  pillar       1.2.2      2018-04-26 CRAN (R 3.5.0)                    
#>  pkgconfig    2.0.1      2017-03-21 CRAN (R 3.5.0)                    
#>  plyr         1.8.4      2016-06-08 CRAN (R 3.5.0)                    
#>  psych        1.8.3.3    2018-03-30 CRAN (R 3.5.0)                    
#>  purrr      * 0.2.5      2018-05-29 cran (@0.2.5)                     
#>  R6           2.2.2      2017-06-17 CRAN (R 3.5.0)                    
#>  Rcpp         0.12.17    2018-05-18 cran (@0.12.17)                   
#>  readr      * 1.1.1      2017-05-16 CRAN (R 3.5.0)                    
#>  readxl       1.1.0      2018-04-20 CRAN (R 3.5.0)                    
#>  reshape2     1.4.3      2017-12-11 CRAN (R 3.5.0)                    
#>  rlang        0.2.1      2018-05-30 cran (@0.2.1)                     
#>  rmarkdown    1.10       2018-06-13 Github (rstudio/rmarkdown@297ff13)
#>  rprojroot    1.3-2      2018-01-03 CRAN (R 3.5.0)                    
#>  rstudioapi   0.7        2017-09-07 CRAN (R 3.5.0)                    
#>  rvest        0.3.2      2016-06-17 CRAN (R 3.5.0)                    
#>  scales       0.5.0      2017-08-24 CRAN (R 3.5.0)                    
#>  stats      * 3.5.0      2018-04-24 local                             
#>  stringi      1.2.2      2018-05-02 cran (@1.2.2)                     
#>  stringr    * 1.3.1      2018-05-10 cran (@1.3.1)                     
#>  tibble     * 1.4.2      2018-01-22 CRAN (R 3.5.0)                    
#>  tidyr      * 0.8.1      2018-05-18 cran (@0.8.1)                     
#>  tidyselect   0.2.4      2018-02-26 CRAN (R 3.5.0)                    
#>  tidyverse  * 1.2.1      2017-11-14 CRAN (R 3.5.0)                    
#>  tools        3.5.0      2018-04-24 local                             
#>  utils      * 3.5.0      2018-04-24 local                             
#>  withr        2.1.2      2018-03-15 CRAN (R 3.5.0)                    
#>  xfun         0.1        2018-01-22 CRAN (R 3.5.0)                    
#>  xml2         1.2.0      2018-01-24 CRAN (R 3.5.0)                    
#>  yaml         2.1.19     2018-05-01 cran (@2.1.19)
```
