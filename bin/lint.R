suppressPackageStartupMessages({
  library("lintr")
  library("glue")
})

linters <- with_defaults(
  camel_case_linter = NULL,
  multiple_dots_linter = NULL
)

files <- list.files(".", pattern = "\\.(Rnw|Rmd)$", full.names = TRUE)
for (f in files) {
  cat(glue(""))
  print(lint(f, linters = linters))
}
