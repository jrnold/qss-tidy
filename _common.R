# same options as r4ds
# https://github.com/hadley/r4ds/blob/master/_common.R
set.seed(12531235)
options(digits = 3)

suppressPackageStartupMessages({
  library("tidyverse")
  library("stringr")
})


knitr::opts_chunk$set(
  comment = "#>",
  collapse = TRUE,
  cache = TRUE,
  out.width = "70%",
  fig.align = 'center',
  fig.width = 6,
  fig.asp = 0.618,  # 1 / phi
  fig.show = "hold"
)

options(dplyr.print_min = 6, dplyr.print_max = 6)

#' Create an Rmarkdown link to an Rdocumentation.org help page
#'
#' This is commonly used inline to generate links to functions.
#'
#' @param name function or topic name
#' @param package Package name
#' @param text Text to use for the link, defaults to \code{name}.
#' @return character string
rdoc <- function(package, name, text = NULL) {
  text <- text %||% name
  stringr::str_c("[", text, "](https://www.rdocumentation.org/packages/",
                 package, "/topics/", name, ")")
}

RDoc <- function(name, package = NULL, text = NULL, full = FALSE) {
  if (is.null(package)) {
    pkg_name <- str_split(name, "::", n = 2)[[1]]
    name = pkg_name[1]
    package = pkg_name[2]
  }
  if (is.null(text)) {
    if (full) {
      text <- str_c(package, name, sep = "::")
    } else {
      text <- name
    }
  }
  url <- str_c("https://www.rdocumentation.org/packages/",
               package, "/topics/", name)
  str_c()
}

#' Get link to a QSS Data File
#'
#' @param chapter Chapter name
#' @param file File name
#' @return string with the URL to download the file
qss_data_url <- function(chapter, file) {
  stringr::str_c("https://raw.githubusercontent.com/kosukeimai/qss/master/",
        stringr::str_to_upper(chapter), "/", file)
}

#' CRAN URL for a package
cran_pkg_url <- function(pkgname) {
  stringr::str_c("https://cran.r-project.org/package=", pkgname)
}

#' Markdown link for a package
pkg_link <- function(pkgname) {
  stringr::str_c("[", pkgname, "](", cran_pkg_url(pkgname), ")")
}
pkg <- pkg_link

#' Constant to insert title and link to R for data science
R4DS <- "[R for Data Science](http://r4ds.had.co.nz/)"

ggdoc <- function(name) {
  stringr::str_c("[", name, "](http://docs.ggplot2.org/current/",
                 name, ".html)")
}
