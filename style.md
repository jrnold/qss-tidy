---
title: "R Style"
editor_options: 
  chunk_output_type: inline
---

In terms of the functions to use, attempt to use the functions and idioms from the tidyverse where at all possible

- **ggplot2** for graphics
- **tibbles** instead of data frames
- **dplyr** and **tidyr** for data frame wrangling
- **purrr** for apply-type functionals
- **forcats** for factors
- **lubridate** for dates and times
- **stringr** for strings
- **readr**, **haven**, **readxl** or **rio** for reading from data formats

Use **ggplot2**, not **base** or **lattice**. The only exception is to use the
`plot()` method of an object when convenient. But do not create new graphics
using non-ggplot2 formats.

Some rules:

- do not use `setwd()` in scripts EVER.
- do not use `install.packages` in scripts.
- Do not use `subset` or `transform`, use `filter` and `mutate`
- Do not use `aggregate` or `by`, use `summarise`
- Do not use `merge`, use the various dplyr `*_join` functions
- Do not use `order` or `sort` (when sorting data frames, it's okay for vectors),
  use `arrange`.
- Do not use `unique` or `duplicated` with data frames. Use `distinct()`
- Do not use `sapply`, `vapply`, `tapply`, use `purrr` map functions.
- It is okay to use `apply` as the current purrr functions are annoying. However,
  they should only be used for matrices. Never on data frames.
- use `haven::read_dta`  instead of `foreign::read.dta`
- use `readr::read.csv` instead of `read.csv`
- use `haven::read_spss` intead of `foreign::read.spss`

It is okay to create new columns usine `$<-` or `[[<-`.
But do not filter for  using logicals within `[`. Use `filter()`.

In writing code, follow the tidyverse Style Guide.


