# Tidyverse R code for Imai's "Quantitative Social Science: An Introduction"

This repository contains the code and text for the [QSS Tidy](https://jrnold.github.io/qss-tidy) which supplements the text 

> Kosuke Imai. 2017. "Quantitative Social Science: An Introduction"
> [URL](https://press.princeton.edu/titles/11025.html), [Amazon](https://www.amazon.com/Quantitative-Social-Science-Kosuke-Imai/dp/0691175462/).

with R [tidyverse](https://www.tidyverse.org/) code.



## Install

You can install the R packages this book depends on with
```r
devtools::install("jrnold/r4ds-exercise-solutions")
```

## Build 

The site is built with the R package [bookdown](https://bookdown.org/yihui/bookdown/).

Render the book by running
```r
bookdown::render_book("index.Rmd")
```

Serve the book and render on change to files by running:
```r
bookdown::serve_book()
```
