# Tidyverse R code for Imai's "Quantitative Social Science: An Introduction"

This repo contains R [tidyverse](https://www.tidyverse.org/) code associated for the text,

> Kosuke Imai. 2017. "Quantitative Social Science: An Introduction"
> [URL](https://press.princeton.edu/titles/11025.html), [Amazon](https://www.amazon.com/Quantitative-Social-Science-Kosuke-Imai/dp/0691175462/).

To view the rendered pages visit <https://jrnold.github.io/qss-tidy>.


## Build and Install

Clone the repository:
```console
$ git clone --recurse-submodules https://github.com/jrnold/qss-tidy.git
```
The `--recurse-submodules` option is necessary since the `qss` directory is a git submodule of [kosukeimai/qss](https://github.com/kosukeimai/qss).

The site is built with the R package [bookdown](https://bookdown.org/yihui/bookdown/).

Install the necessary R dependencies with
```r
devtools::install()
```

Render the book by running:
```r
bookdown::render_book("index.Rmd")`
```

Serve the book and render on change to files by running:
```r
bookdown::serve_book()
```

Rendering the book requires an initialization of the qss folder, which depends on an external repository. To do so, run the following in the shell:
```r
git submodule update --init
```
