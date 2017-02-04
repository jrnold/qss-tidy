
---
title: "QSS Tidyverse Code"
author: "Jeffrey B. Arnold"
date: "2017-02-03"
github-repo: jrnold/qss-tidy
site: "bookdown::bookdown_site"
documentclass: book
---

# Preface

This is tidyverse R code to supplement the book, [Quantitative Social Science: An Introduction](http://press.princeton.edu/titles/11025.html), by Kosuke Imai, to
be published by Princeton University Press in March 2017.

The R code included with the text of QSS and the supplementary materials relies mostly on base R functions. 
This translates the code examples provided with QSS to tidyverse R code. 
[Tidyverse](https://github.com/tidyverse/tidyverse) refers to a set of packages (**ggplot2**, **dplyr**, **tidyr**, **readr**, **purrr**, **tibble**,  and a few others) that share common data representations, especially the use of data frames for return values. The book [R for Data Science](http://r4ds.had.co.nz/) by Hadley Wickham and Garrett Grolemond is an introduction. 


I wrote this code while teaching course that employed both texts in order to make the excellent examples and statistical material in QSS more compatible with the modern data science R approach in R4DS.

## Colonphon

To install the R packages used in this work run the following code:

```r
# install.packages("devtools")
install_github("jrnold/qss-tidy")
```
It install's the **qsstidy** package which contains no code or data, but will install the needed dependencies.

Additionally, the [gganimate](https://cran.r-project.org/package=gganimate) package requires installing [ffmpeg](https://ffmpeg.org/) with libvpx support.



The source of the book is available [here](https://github.com/jrnold/qsstidy) and was built with versions of packages below:


```
#> Session info -------------------------------------------------------------
#>  setting  value                       
#>  version  R version 3.3.2 (2016-10-31)
#>  system   x86_64, darwin13.4.0        
#>  ui       X11                         
#>  language (EN)                        
#>  collate  en_US.UTF-8                 
#>  tz       America/Los_Angeles         
#>  date     2017-02-03
#> Packages -----------------------------------------------------------------
#>  package    * version     date       source                            
#>  animation  * 2.4         2015-08-16 cran (@2.4)                       
#>  assertthat   0.1         2013-12-06 CRAN (R 3.3.0)                    
#>  backports    1.0.5       2017-01-18 cran (@1.0.5)                     
#>  bookdown     0.3         2016-11-28 CRAN (R 3.3.2)                    
#>  broom        0.4.1       2016-06-24 CRAN (R 3.3.0)                    
#>  codetools    0.2-15      2016-10-05 CRAN (R 3.3.2)                    
#>  colorspace   1.3-2       2016-12-14 CRAN (R 3.3.2)                    
#>  DBI          0.5-1       2016-09-10 CRAN (R 3.3.0)                    
#>  devtools     1.12.0.9000 2017-01-24 Github (hadley/devtools@1ce84b0)  
#>  digest       0.6.12      2017-01-27 cran (@0.6.12)                    
#>  dplyr      * 0.5.0       2016-06-24 CRAN (R 3.3.0)                    
#>  evaluate     0.10        2016-10-11 CRAN (R 3.3.0)                    
#>  foreign      0.8-67      2016-09-13 CRAN (R 3.3.2)                    
#>  ggplot2    * 2.2.1.9000  2017-01-28 Github (hadley/ggplot2@96297bf)   
#>  gtable       0.2.0       2016-02-26 CRAN (R 3.3.0)                    
#>  haven        1.0.0       2016-09-23 CRAN (R 3.3.0)                    
#>  hms          0.3         2016-11-22 CRAN (R 3.3.2)                    
#>  htmltools    0.3.5       2016-03-21 CRAN (R 3.3.0)                    
#>  httr         1.2.1       2016-07-03 cran (@1.2.1)                     
#>  jsonlite     1.2         2016-12-31 CRAN (R 3.3.2)                    
#>  knitr        1.15.1      2016-11-22 CRAN (R 3.3.2)                    
#>  lattice      0.20-34     2016-09-06 CRAN (R 3.3.2)                    
#>  lazyeval     0.2.0       2016-06-12 CRAN (R 3.3.0)                    
#>  lubridate    1.6.0       2016-09-13 CRAN (R 3.3.0)                    
#>  magrittr     1.5         2014-11-22 CRAN (R 3.3.0)                    
#>  memoise      1.0.0       2016-01-29 CRAN (R 3.3.0)                    
#>  mnormt       1.5-5       2016-10-15 CRAN (R 3.3.0)                    
#>  modelr       0.1.0       2016-08-31 CRAN (R 3.3.0)                    
#>  munsell      0.4.3       2016-02-13 CRAN (R 3.3.0)                    
#>  nlme         3.1-128     2016-05-10 CRAN (R 3.3.2)                    
#>  pkgbuild     0.0.0.9000  2017-01-24 Github (r-pkgs/pkgbuild@65eace0)  
#>  pkgload      0.0.0.9000  2017-01-24 Github (r-pkgs/pkgload@def2b10)   
#>  plyr         1.8.4       2016-06-08 CRAN (R 3.3.0)                    
#>  psych        1.6.12      2017-01-08 CRAN (R 3.3.2)                    
#>  purrr      * 0.2.2       2016-06-18 CRAN (R 3.3.0)                    
#>  R6           2.2.0       2016-10-05 CRAN (R 3.3.0)                    
#>  Rcpp         0.12.9.1    2017-01-24 Github (RcppCore/Rcpp@5a99a86)    
#>  readr      * 1.0.0       2016-08-03 CRAN (R 3.3.0)                    
#>  readxl       0.1.1       2016-03-28 CRAN (R 3.3.0)                    
#>  reshape2     1.4.2       2016-10-22 CRAN (R 3.3.0)                    
#>  rmarkdown    1.3         2017-01-24 Github (rstudio/rmarkdown@5b74148)
#>  rprojroot    1.2         2017-01-16 cran (@1.2)                       
#>  rvest        0.3.2       2016-06-17 CRAN (R 3.3.0)                    
#>  scales       0.4.1       2016-11-09 CRAN (R 3.3.2)                    
#>  stringi      1.1.2       2016-10-01 CRAN (R 3.3.0)                    
#>  stringr    * 1.1.0       2016-08-19 CRAN (R 3.3.1)                    
#>  tibble     * 1.2         2016-08-26 CRAN (R 3.3.0)                    
#>  tidyr      * 0.6.1       2017-01-10 cran (@0.6.1)                     
#>  tidyverse  * 1.1.0       2017-01-20 CRAN (R 3.3.2)                    
#>  withr        1.0.2       2016-06-20 CRAN (R 3.3.0)                    
#>  xml2         1.1.1       2017-01-24 Github (hadley/xml2@a97f4a0)      
#>  yaml         2.1.14      2016-11-12 CRAN (R 3.3.2)
```
