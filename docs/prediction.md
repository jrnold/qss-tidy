
---
output: html_document
editor_options:
  chunk_output_type: console
---
# Prediction


## Prerequisites {-}


```r
library("tidyverse")
library("lubridate")
library("stringr")
library("forcats")
```
The packages [modelr](https://cran.r-project.org/package=modelr) and [broom](https://cran.r-project.org/package=broom) are used to wrangle the results of linear regressions,

```r
library("broom")
library("modelr")
```

## Predicting Election Outcomes

### Loops in R


RStudio provides many features to help debugging, which will be useful in
for loops and function: see  [this](https://support.rstudio.com/hc/en-us/articles/205612627-Debugging-with-RStudio) article for an example.



```r
values <- c(2, 3, 6)
n <- length(values)
results <- rep(NA, n)
for (i in 1:n) {
  results[i] <- values[i] * 2
  cat(values[i], "times 2 is equal to", results[i], "\n")
}
#> 2 times 2 is equal to 4 
#> 3 times 2 is equal to 6 
#> 6 times 2 is equal to 12
```

Note that the above code uses the for loop for pedagogical purposes only, this could have simply been written

```r
results <- values * 2
```
In general, avoid using for loops when there is a *vectorized* function.

But sticking with the for loop, there are several things that could be improved.

Avoid using the idiom `1:n` in for loops. 
To see why, look what happens when values is empty:

```r
values <- c()
n <- length(values)
results <- rep(NA, n)
for (i in 1:n) {
  cat("i = ", i, "\n")
  results[i] <- values[i] * 2
  cat(values[i], "times 2 is equal to", results[i], "\n")
}
#> i =  1 
#>  times 2 is equal to NA 
#> i =  0 
#>  times 2 is equal to
```
Instead of not running a loop, as you would expect, it runs two loops, where `i = 1`, then `i = 0`.
This edge case occurs more than you may think, especially if you are writing functions
where you don't know the length of the vector is *ex ante*.

The way to avoid this is to use either `rdoc("base", "seq_len")` or `rdoc("base", "seq_along")`, which will handle 0-length vectors correctly.

```r
values <- c()
n <- length(values)
results <- rep(NA, n)
for (i in seq_along(values)) {
  results[i] <- values[i] * 2
}
print(results)
#> logical(0)
```
or 

```r
values <- c()
n <- length(values)
results <- rep(NA, n)
for (i in seq_len(n)) {
  results[i] <- values[i] * 2
}
print(results)
#> logical(0)
```

Also, note that the the result is `logical(0)`.
That's because the `NA` missing value has class [logical](http://r4ds.had.co.nz/vectors.html#missing-values-4), and thus `rep(NA, ...)` returns a logical vector.
It is better style to initialize the vector with the same data type that you will be using,

```r
results <- rep(NA_real_, length(values))
results
#> numeric(0)
class(results)
#> [1] "numeric"
```


Often loops can be rewritten to use a map function. 
Read the [R for Data Science](http://r4ds.had.co.nz/) chapter [Iteration](http://r4ds.had.co.nz/data-visualisation.html) before proceeding.

For a functional, we first write a function that will be applied to each element of the vector.
When converting from a `for` loop to a function, this is usually simply the body of the `for` loop, though you 
may need to add arguments for any variables defined outside the body of the for loop.
In this case,

```r
mult_by_two <- function(x) {
  x * 2
}
```
We can now test that this function works on different values:

```r
mult_by_two(0)
#> [1] 0
mult_by_two(2.5)
#> [1] 5
mult_by_two(-3)
#> [1] -6
```

At this point, we could replace the body of the `for` loop with this function

```r
values <- c(2, 4, 6)
n <- length(values)
results <- rep(NA, n)
for (i in seq_len(n)) {
  results[i] <- mult_by_two(values[i])
}
print(results)
#> [1]  4  8 12
```
This can be useful if the body of a for loop is many lines long.

However, this loop is still unwieldy code. We have to remember to define an empty vector `results` that is the same size as `values` to hold the results, and then correctly loop over all the values. 
We already saw how these steps have possibilities for errors. 
Functionals like `map`, apply a function to each element of a vector. 

```r
results <- map(values, mult_by_two)
results
#> [[1]]
#> [1] 4
#> 
#> [[2]]
#> [1] 8
#> 
#> [[3]]
#> [1] 12
```

The values of each element are correct, but `map` returns a list vector, not a numeric vector like we may have been expecting.
If we want a numeric vector, use `map_dbl`,

```r
results <- map_dbl(values, mult_by_two)
results
#> [1]  4  8 12
```

Also, instead of explicitly defining a function, like `mult_by_two`, we could have instead used an *anonymous function* with the functional.
An anonymous function is a function that is not assigned to a name.

```r
results <- map_dbl(values, function(x) x * 2)
results
#> [1]  4  8 12
```
The various [purrr](https://cran.r-project.org/package=purrr) functions also will interpret formulas as functions where `.x` and `.y` are interpreted as (up to) two arguments.

```r
results <- map_dbl(values, ~ .x * 2)
results
#> [1]  4  8 12
```
This is for parsimony and convenience; in the background, these functions are creating anonymous functions from the given formula.

*QSS* discusses several debugging strategies. The functional approach lends itself to easier debugging because the function can be tested with input values independently of the loop.


### General Conditional Statements in R

See the *R for Data Science* section [Conditional Execution](http://r4ds.had.co.nz/functions.html#conditional-execution) for a more complete discussion of conditional execution.

If you are using conditional statements to assign values for data frame,
see the **dplyr** functions [if_else](https://www.rdocumentation.org/packages/dplyr/topics/if_else), [recode](https://www.rdocumentation.org/packages/dplyr/topics/recode), and [case_when](https://www.rdocumentation.org/packages/dplyr/topics/case_when)

The following code which uses a for loop, 

```r
values <- 1:5
n <- length(values)
results <- rep(NA_real_, n)
for (i in seq_len(n)) {
  x <- values[i]
  r <- x %% 2
  if (r == 0) {
    cat(x, "is even and I will perform addition", x, " + ", x, "\n")
    results[i] <- x + x
  } else {
    cat(x, "is even and I will perform multiplication", x, " * ", x, "\n")
    results[i] <- x * x
  }
}
#> 1 is even and I will perform multiplication 1  *  1 
#> 2 is even and I will perform addition 2  +  2 
#> 3 is even and I will perform multiplication 3  *  3 
#> 4 is even and I will perform addition 4  +  4 
#> 5 is even and I will perform multiplication 5  *  5
results
#> [1]  1  4  9  8 25
```
could be rewritten to use `if_else`,

```r
if_else(values %% 2 == 0, values + values, values * values)
#> [1]  1  4  9  8 25
```
or using the `map_dbl` functional with a named function,

```r
myfunc <- function(x) {
  if (x %% 2 == 0) {
    x + x
  } else {
    x * x
  }
}
map_dbl(values, myfunc)
#> [1]  1  4  9  8 25
```
or `map_dbl` with an anonymous function,

```r
map_dbl(values, function(x) {
  if (x %% 2 == 0) {
    x + x
  } else {
    x * x
  }
})
#> [1]  1  4  9  8 25
```



### Poll Predictions

Load the election polls by state for the 2008 US Presidential election,

```r
data("polls08", package = "qss")
glimpse(polls08)
#> Observations: 1,332
#> Variables: 5
#> $ state    <chr> "AL", "AL", "AL", "AL", "AL", "AL", "AL", "AL", "AL",...
#> $ Pollster <chr> "SurveyUSA-2", "Capital Survey-2", "SurveyUSA-2", "Ca...
#> $ Obama    <int> 36, 34, 35, 35, 39, 34, 36, 25, 35, 34, 37, 36, 36, 3...
#> $ McCain   <int> 61, 54, 62, 55, 60, 64, 58, 52, 55, 47, 55, 51, 49, 5...
#> $ middate  <date> 2008-10-27, 2008-10-15, 2008-10-08, 2008-10-06, 2008...
```
and the election results,

```r
data("pres08", package = "qss")
glimpse(pres08)
#> Observations: 51
#> Variables: 5
#> $ state.name <chr> "Alabama", "Alaska", "Arizona", "Arkansas", "Califo...
#> $ state      <chr> "AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DC", "DE...
#> $ Obama      <int> 39, 38, 45, 39, 61, 54, 61, 92, 62, 51, 47, 72, 36,...
#> $ McCain     <int> 60, 59, 54, 59, 37, 45, 38, 7, 37, 48, 52, 27, 62, ...
#> $ EV         <int> 9, 3, 10, 6, 55, 9, 7, 3, 3, 27, 15, 4, 4, 21, 11, ...
```

Compute Obama's margin in polls and final election

```r
polls08 <-
  polls08 %>% mutate(margin = Obama - McCain)
pres08 <-
  pres08 %>% mutate(margin = Obama - McCain)
```

To work with dates, the R package [lubridate](https://cran.r-project.org/package=lubridate) makes wrangling them
much easier.
See the [R for Data Science](http://r4ds.had.co.nz/) chapter [Dates and Times](http://r4ds.had.co.nz/dates-and-times.html).

The function [ymd](https://www.rdocumentation.org/packages/lubridate/topics/ymd) will convert character strings like `year-month-day` and more
into dates, as long as the order is (year, month, day). See [dmy](https://www.rdocumentation.org/packages/lubridate/topics/dmy), [ymd](https://www.rdocumentation.org/packages/lubridate/topics/ymd), and others for other ways to convert strings to dates.

```r
x <- ymd("2008-11-04")
y <- ymd("2008/9/1")
x - y
#> Time difference of 64 days
```

However, note that in `polls08`, the date `middate` is *already* a `date` object,

```r
class(polls08$middate)
#> [1] "Date"
```
The function [read_csv](https://www.rdocumentation.org/packages/readr/topics/read_csv) by default will check character vectors to see if they have patterns that appear to be dates, and if so, will
parse those columns as dates.

We'll create a variable for election day

```r
ELECTION_DAY <- ymd("2008-11-04")
```
and add a new column to `poll08` with the days to the election

```r
polls08 <- mutate(polls08, ELECTION_DAY - middate)
```

Although the code in the chapter uses a `for` loop, there is no reason to do so.
We can accomplish the same task by merging the election results data to the polling data by `state`.


```r
polls_w_results <- left_join(polls08,
                            select(pres08, state, elec_margin = margin),
                            by = "state") %>%
  mutate(error = elec_margin - margin)
glimpse(polls_w_results)
#> Observations: 1,332
#> Variables: 9
#> $ state                    <chr> "AL", "AL", "AL", "AL", "AL", "AL", "...
#> $ Pollster                 <chr> "SurveyUSA-2", "Capital Survey-2", "S...
#> $ Obama                    <int> 36, 34, 35, 35, 39, 34, 36, 25, 35, 3...
#> $ McCain                   <int> 61, 54, 62, 55, 60, 64, 58, 52, 55, 4...
#> $ middate                  <date> 2008-10-27, 2008-10-15, 2008-10-08, ...
#> $ margin                   <int> -25, -20, -27, -20, -21, -30, -22, -2...
#> $ `ELECTION_DAY - middate` <time> 8 days, 20 days, 27 days, 29 days, 4...
#> $ elec_margin              <int> -21, -21, -21, -21, -21, -21, -21, -2...
#> $ error                    <int> 4, -1, 6, -1, 0, 9, 1, 6, -1, -8, -3,...
```

To get the last poll in each state, arrange and filter on `middate`

```r
last_polls <-
  polls_w_results %>%
  arrange(state, desc(middate)) %>%
  group_by(state) %>%
  slice(1)
last_polls
#> # A tibble: 51 x 9
#> # Groups: state [51]
#>   state Pollster        Obama McCain middate    margin `ELECT… elec… error
#>   <chr> <chr>           <int>  <int> <date>      <int> <time>  <int> <int>
#> 1 AK    Research 2000-3    39     58 2008-10-29    -19 6         -21   - 2
#> 2 AL    SurveyUSA-2        36     61 2008-10-27    -25 8         -21     4
#> 3 AR    ARG-4              44     51 2008-10-29    - 7 6         -20   -13
#> 4 AZ    ARG-3              46     50 2008-10-29    - 4 6         - 9   - 5
#> 5 CA    SurveyUSA-3        60     36 2008-10-30     24 5          24     0
#> 6 CO    ARG-3              52     45 2008-10-29      7 6           9     2
#> # ... with 45 more rows
```


**Challenge:** Instead of using the last poll, use the average of polls in the last week? Last month? How do the margins on the polls change over the election period?

To simplify things for later, let's define a function `rmse` which calculates the root mean squared error, as defined in the book.
See the [R for Data Science](http://r4ds.had.co.nz/) chapter [Functions](http://r4ds.had.co.nz/functions.html) for more on writing functions.


```r
rmse <- function(actual, pred) {
  sqrt(mean( (actual - pred) ^ 2))
}
```
Now we can use `rmse()` to calculate the RMSE for all the final polls:

```r
rmse(last_polls$margin, last_polls$elec_margin)
#> [1] 5.88
```
Or since we already have a variable `error`,

```r
sqrt(mean(last_polls$error ^ 2))
#> [1] 5.88
```
The mean prediction error is

```r
mean(last_polls$error)
#> [1] 1.08
```


This is slightly different than what is in the book due to the difference in the poll used as the final poll; many states have many polls on the last day.

I'll choose bin widths of 1%, since that is fairly interpretable:

```r
ggplot(last_polls, aes(x = error)) +
  geom_histogram(binwidth = 1, boundary = 0)
```

<img src="prediction_files/figure-html/unnamed-chunk-31-1.png" width="70%" style="display: block; margin: auto;" />

The text uses bin widths of 5%:

```r
ggplot(last_polls, aes(x = error)) +
  geom_histogram(binwidth = 5, boundary = 0)
```

<img src="prediction_files/figure-html/unnamed-chunk-32-1.png" width="70%" style="display: block; margin: auto;" />

**Challenge:** What other ways could you visualize the results? How would you show all states? What about plotting the absolute or squared errors instead of the errors?

**Challenge:** What happens to prediction error if you average polls?
Consider averaging back over time?
What happens if you take the averages of the state poll average and average of **all** polls - does that improve prediction?

To create a scatter plots using the state abbreviations instead of points use
[geom_text](http://docs.ggplot2.org/current/geom_text.html) instead of [geom_point](http://docs.ggplot2.org/current/geom_point.html).

```r
ggplot(last_polls, aes(x = margin, y = elec_margin, label = state)) +
  geom_abline(color = "white", size = 2) +
  geom_hline(yintercept = 0, color = "gray", size = 2) +
  geom_vline(xintercept = 0, color = "gray", size = 2) +
  geom_text() +
  coord_fixed() +
  labs(x = "Poll Results", y = "Actual Election Results")
```

<img src="prediction_files/figure-html/unnamed-chunk-33-1.png" width="70%" style="display: block; margin: auto;" />

We can create a confusion matrix as follows.
Create a new column `classification` which shows whether how the poll's classification was related to the actual election outcome ("true positive", "false positive", "false negative", "false positive").
If there were two outcomes, then we would use the  function.
But with more than two outcomes, it is easier to use the [dplyr](https://cran.r-project.org/package=dplyr) function .

```r
last_polls <-
  last_polls %>%
  ungroup() %>%
  mutate(classification =
           case_when(
             (.$margin > 0 & .$elec_margin > 0) ~ "true positive",
             (.$margin > 0 & .$elec_margin < 0) ~ "false positive",
             (.$margin < 0 & .$elec_margin < 0) ~ "true negative",
             (.$margin < 0 & .$elec_margin > 0) ~ "false negative"
           ))
```
You need to use `.` to refer to the data frame when using `case_when` within `mutate()`.
Also, we needed to first use  in order to remove the grouping variable so `mutate` will work.

Now simply count the number of polls in each category of `classification`:

```r
last_polls %>%
  group_by(classification) %>%
  count()
#> # A tibble: 4 x 2
#> # Groups: classification [4]
#>   classification     n
#>   <chr>          <int>
#> 1 false negative     2
#> 2 false positive     1
#> 3 true negative     21
#> 4 true positive     27
```

Which states were incorrectly predicted by the polls, and what was their margins?

```r
last_polls %>%
  filter(classification %in% c("false positive", "false negative")) %>%
  select(state, margin, elec_margin, classification) %>%
  arrange(desc(elec_margin))
#> # A tibble: 3 x 4
#>   state margin elec_margin classification
#>   <chr>  <int>       <int> <chr>         
#> 1 IN        -5           1 false negative
#> 2 NC        -1           1 false negative
#> 3 MO         1          -1 false positive
```

What was the difference in the poll prediction of electoral votes and actual electoral votes.
We hadn't included the variable `EV` when we first merged, but that's no problem, we'll just merge again in order to grab that variable:

```r
last_polls %>%
  left_join(select(pres08, state, EV), by = "state") %>%
  summarise(EV_pred = sum( (margin > 0) * EV),
            EV_actual = sum( (elec_margin > 0) * EV))
#> # A tibble: 1 x 2
#>   EV_pred EV_actual
#>     <int>     <int>
#> 1     349       364
```



```r
data("pollsUS08", package = "qss")
```

```r
pollsUS08 <- mutate(pollsUS08, DaysToElection = ELECTION_DAY - middate)
```

We'll produce the seven-day averages slightly differently than the method used in the text.
For all dates in the data, we'll calculate the moving average.
The code presented in *QSS* uses a for loop similar to the following:

```r
all_dates <- seq(min(polls08$middate), ELECTION_DAY, by = "days")

# Number of poll days to use
POLL_DAYS <- 7

pop_vote_avg <- vector(length(all_dates), mode = "list")
for (i in seq_along(all_dates)) {
  date <- all_dates[i]
  # summarise the seven day
  week_data <-
     filter(polls08,
            as.integer(middate - date) <= 0,
            as.integer(middate - date) > - POLL_DAYS) %>%
     summarise(Obama = mean(Obama, na.rm = TRUE),
               McCain = mean(McCain, na.rm = TRUE))
  # add date for the observation
  week_data$date <- date
  pop_vote_avg[[i]] <- week_data
}

pop_vote_avg <- bind_rows(pop_vote_avg)
```

Write a function which takes a `date`, and calculates the `days` (the default is 7 days)
moving average using the dataset `.data`:

```r
poll_ma <- function(date, .data, days = 7) {
  filter(.data,
        as.integer(middate - date) <= 0,
        as.integer(middate - date) > - !!days) %>%
  summarise(Obama = mean(Obama, na.rm = TRUE),
           McCain = mean(McCain, na.rm = TRUE)) %>%
  mutate(date = !!date)
}
```
The code above uses `!!`. 
This tells `filter` that `days` refers to a variable `days` in the calling environment,
and not a column named `days` in the data frame. 
In this case, there wouldn't be any ambiguities since there is not a column named `days`, but in general
there can be ambiguities in the dplyr functions as to whether the names refer to columns in the data frame
or variables in the environment calling the function.
Read [Programming with dplyr](http://dplyr.tidyverse.org/articles/programming.html) for an in-depth 
discussion of this.

This returns a one row data frame with the moving average for McCain and Obama on  Nov 1, 2008.

```r
poll_ma(as.Date("2008-11-01"), polls08)
#>   Obama McCain       date
#> 1  49.1   45.4 2008-11-01
```
Since we made `days` an argument to the function we could easily change the code to calculate
other moving averages,

```r
poll_ma(as.Date("2008-11-01"), polls08, days = 3)
#>   Obama McCain       date
#> 1  50.6   45.4 2008-11-01
```
Now use a functional to execute that function with all dates for which we want moving averages.
The function `poll_ma` returns a data frame, and our ideal output is a data frame that 
stacks those data frames row-wise. 
So we will use the `map_df` function,

```r
map_df(all_dates, poll_ma, polls08)
#>     Obama McCain       date
#> 1    46.5   52.5 2008-01-01
#> 2    46.5   52.5 2008-01-02
#> 3    46.5   52.5 2008-01-03
#> 4    46.5   52.5 2008-01-04
#> 5    46.5   52.4 2008-01-05
#> 6    46.5   52.4 2008-01-06
#> 7    46.5   52.4 2008-01-07
#> 8    40.5   48.0 2008-01-08
#> 9    40.5   48.0 2008-01-09
#> 10   40.5   48.0 2008-01-10
#> 11   40.5   48.0 2008-01-11
#> 12   45.7   45.3 2008-01-12
#> 13   45.7   45.3 2008-01-13
#> 14   45.7   45.3 2008-01-14
#> 15   47.7   44.0 2008-01-15
#> 16   42.4   49.4 2008-01-16
#> 17   42.4   49.4 2008-01-17
#> 18   42.4   49.4 2008-01-18
#> 19   37.7   52.3 2008-01-19
#> 20   40.6   50.0 2008-01-20
#> 21   40.6   50.0 2008-01-21
#> 22   39.8   52.0 2008-01-22
#> 23   45.0   46.5 2008-01-23
#> 24   45.0   46.5 2008-01-24
#> 25   45.0   46.5 2008-01-25
#> 26   45.0   46.5 2008-01-26
#> 27    NaN    NaN 2008-01-27
#> 28    NaN    NaN 2008-01-28
#> 29    NaN    NaN 2008-01-29
#> 30    NaN    NaN 2008-01-30
#> 31    NaN    NaN 2008-01-31
#> 32    NaN    NaN 2008-02-01
#> 33    NaN    NaN 2008-02-02
#> 34   42.3   49.7 2008-02-03
#> 35   42.3   49.7 2008-02-04
#> 36   42.3   49.7 2008-02-05
#> 37   42.3   49.7 2008-02-06
#> 38   42.3   49.7 2008-02-07
#> 39   42.3   49.7 2008-02-08
#> 40   41.8   46.4 2008-02-09
#> 41   41.0   41.5 2008-02-10
#> 42   43.7   39.7 2008-02-11
#> 43   44.9   39.6 2008-02-12
#> 44   44.7   39.9 2008-02-13
#> 45   45.1   39.8 2008-02-14
#> 46   44.9   41.0 2008-02-15
#> 47   48.4   42.0 2008-02-16
#> 48   47.5   42.3 2008-02-17
#> 49   47.4   42.5 2008-02-18
#> 50   47.5   43.2 2008-02-19
#> 51   48.2   43.1 2008-02-20
#> 52   47.8   43.1 2008-02-21
#> 53   47.8   43.2 2008-02-22
#> 54   43.9   43.9 2008-02-23
#> 55   44.9   44.0 2008-02-24
#> 56   45.0   44.4 2008-02-25
#> 57   46.0   42.7 2008-02-26
#> 58   45.3   45.0 2008-02-27
#> 59   45.4   45.1 2008-02-28
#> 60   45.4   45.0 2008-02-29
#> 61   45.4   45.0 2008-03-01
#> 62   45.5   45.0 2008-03-02
#> 63   45.5   45.0 2008-03-03
#> 64   45.3   45.2 2008-03-04
#> 65   41.0   46.5 2008-03-05
#> 66   38.0   48.0 2008-03-06
#> 67   39.5   46.5 2008-03-07
#> 68   35.3   45.3 2008-03-08
#> 69   35.3   45.3 2008-03-09
#> 70   38.0   44.8 2008-03-10
#> 71   42.2   42.0 2008-03-11
#> 72   43.6   42.1 2008-03-12
#> 73   43.2   42.6 2008-03-13
#> 74   44.1   42.0 2008-03-14
#> 75   45.7   45.9 2008-03-15
#> 76   45.6   45.9 2008-03-16
#> 77   46.1   45.7 2008-03-17
#> 78   45.2   46.8 2008-03-18
#> 79   45.0   46.4 2008-03-19
#> 80   44.9   46.8 2008-03-20
#> 81   45.0   46.7 2008-03-21
#> 82   44.4   44.8 2008-03-22
#> 83   44.5   44.7 2008-03-23
#> 84   43.1   46.2 2008-03-24
#> 85   42.3   46.1 2008-03-25
#> 86   42.2   47.8 2008-03-26
#> 87   43.1   45.2 2008-03-27
#> 88   42.3   46.1 2008-03-28
#> 89   41.4   46.3 2008-03-29
#> 90   41.7   46.0 2008-03-30
#> 91   42.3   45.3 2008-03-31
#> 92   43.6   44.1 2008-04-01
#> 93   42.4   44.9 2008-04-02
#> 94   39.6   47.7 2008-04-03
#> 95   39.6   47.7 2008-04-04
#> 96   41.3   47.1 2008-04-05
#> 97   41.0   47.7 2008-04-06
#> 98   41.6   47.9 2008-04-07
#> 99   41.2   48.1 2008-04-08
#> 100  41.8   47.5 2008-04-09
#> 101  43.6   46.4 2008-04-10
#> 102  43.6   46.4 2008-04-11
#> 103  44.0   48.0 2008-04-12
#> 104  44.0   48.0 2008-04-13
#> 105  43.9   47.4 2008-04-14
#> 106  44.1   47.9 2008-04-15
#> 107  44.7   47.7 2008-04-16
#> 108  44.9   47.4 2008-04-17
#> 109  44.9   47.4 2008-04-18
#> 110  46.1   44.5 2008-04-19
#> 111  45.0   45.7 2008-04-20
#> 112  45.0   46.8 2008-04-21
#> 113  46.1   44.8 2008-04-22
#> 114  46.2   44.5 2008-04-23
#> 115  45.9   44.4 2008-04-24
#> 116  45.1   44.7 2008-04-25
#> 117  45.5   43.2 2008-04-26
#> 118  46.2   42.5 2008-04-27
#> 119  46.2   42.2 2008-04-28
#> 120  45.2   42.6 2008-04-29
#> 121  43.7   43.6 2008-04-30
#> 122  44.4   43.2 2008-05-01
#> 123  45.0   42.9 2008-05-02
#> 124  44.1   44.2 2008-05-03
#> 125  43.7   44.2 2008-05-04
#> 126  43.6   44.6 2008-05-05
#> 127  42.6   46.0 2008-05-06
#> 128  44.3   44.9 2008-05-07
#> 129  42.7   47.2 2008-05-08
#> 130  42.7   47.2 2008-05-09
#> 131  42.4   48.0 2008-05-10
#> 132  42.4   48.0 2008-05-11
#> 133  43.2   47.7 2008-05-12
#> 134  44.3   45.9 2008-05-13
#> 135  44.4   45.8 2008-05-14
#> 136  44.2   44.9 2008-05-15
#> 137  43.0   45.4 2008-05-16
#> 138  43.8   44.6 2008-05-17
#> 139  43.8   44.8 2008-05-18
#> 140  43.6   44.7 2008-05-19
#> 141  43.0   45.3 2008-05-20
#> 142  43.2   44.9 2008-05-21
#> 143  43.7   44.6 2008-05-22
#> 144  44.4   44.1 2008-05-23
#> 145  43.9   44.5 2008-05-24
#> 146  43.9   44.1 2008-05-25
#> 147  43.9   43.9 2008-05-26
#> 148  44.7   42.9 2008-05-27
#> 149  43.3   44.3 2008-05-28
#> 150  42.9   44.6 2008-05-29
#> 151  42.8   45.4 2008-05-30
#> 152  41.7   46.7 2008-05-31
#> 153  41.7   46.7 2008-06-01
#> 154  41.0   47.0 2008-06-02
#> 155  42.1   45.9 2008-06-03
#> 156  41.7   46.6 2008-06-04
#> 157  41.5   46.4 2008-06-05
#> 158  41.8   45.7 2008-06-06
#> 159  42.7   44.6 2008-06-07
#> 160  44.5   43.1 2008-06-08
#> 161  47.1   40.3 2008-06-09
#> 162  46.8   40.2 2008-06-10
#> 163  46.7   39.8 2008-06-11
#> 164  46.9   40.4 2008-06-12
#> 165  47.0   40.4 2008-06-13
#> 166  46.8   40.5 2008-06-14
#> 167  46.5   41.0 2008-06-15
#> 168  45.5   41.8 2008-06-16
#> 169  44.9   42.4 2008-06-17
#> 170  45.7   42.7 2008-06-18
#> 171  45.0   42.9 2008-06-19
#> 172  45.4   42.1 2008-06-20
#> 173  45.3   43.0 2008-06-21
#> 174  45.3   42.5 2008-06-22
#> 175  45.7   42.5 2008-06-23
#> 176  46.1   42.6 2008-06-24
#> 177  44.0   43.7 2008-06-25
#> 178  44.8   43.8 2008-06-26
#> 179  44.4   45.1 2008-06-27
#> 180  44.1   44.7 2008-06-28
#> 181  43.1   46.4 2008-06-29
#> 182  45.4   43.6 2008-06-30
#> 183  46.9   42.3 2008-07-01
#> 184  49.4   40.6 2008-07-02
#> 185  51.2   37.7 2008-07-03
#> 186  52.7   36.0 2008-07-04
#> 187  52.7   36.0 2008-07-05
#> 188  52.7   36.0 2008-07-06
#> 189  47.8   42.8 2008-07-07
#> 190  46.7   41.7 2008-07-08
#> 191  46.0   43.6 2008-07-09
#> 192  47.2   42.4 2008-07-10
#> 193  47.8   41.5 2008-07-11
#> 194  47.8   41.5 2008-07-12
#> 195  47.6   42.1 2008-07-13
#> 196  46.5   42.4 2008-07-14
#> 197  45.6   43.5 2008-07-15
#> 198  45.6   41.9 2008-07-16
#> 199  43.9   42.7 2008-07-17
#> 200  43.9   43.4 2008-07-18
#> 201  44.2   43.0 2008-07-19
#> 202  44.3   43.0 2008-07-20
#> 203  43.9   43.4 2008-07-21
#> 204  43.7   44.0 2008-07-22
#> 205  44.0   43.4 2008-07-23
#> 206  43.9   43.4 2008-07-24
#> 207  43.3   43.5 2008-07-25
#> 208  43.7   43.4 2008-07-26
#> 209  43.5   43.2 2008-07-27
#> 210  43.7   43.2 2008-07-28
#> 211  42.5   44.1 2008-07-29
#> 212  41.3   46.4 2008-07-30
#> 213  41.5   47.2 2008-07-31
#> 214  41.3   46.4 2008-08-01
#> 215  41.1   47.2 2008-08-02
#> 216  41.6   46.6 2008-08-03
#> 217  43.0   45.0 2008-08-04
#> 218  44.7   43.0 2008-08-05
#> 219  46.6   41.1 2008-08-06
#> 220  46.8   40.7 2008-08-07
#> 221  48.2   40.7 2008-08-08
#> 222  47.8   40.9 2008-08-09
#> 223  47.1   42.3 2008-08-10
#> 224  45.9   44.2 2008-08-11
#> 225  45.9   43.3 2008-08-12
#> 226  45.5   43.7 2008-08-13
#> 227  43.1   46.0 2008-08-14
#> 228  42.6   45.7 2008-08-15
#> 229  42.4   45.5 2008-08-16
#> 230  42.4   45.5 2008-08-17
#> 231  42.8   44.9 2008-08-18
#> 232  42.1   45.7 2008-08-19
#> 233  41.8   45.7 2008-08-20
#> 234  42.9   44.9 2008-08-21
#> 235  43.2   45.1 2008-08-22
#> 236  43.3   45.2 2008-08-23
#> 237  43.5   44.6 2008-08-24
#> 238  44.0   44.5 2008-08-25
#> 239  43.9   45.0 2008-08-26
#> 240  45.6   44.6 2008-08-27
#> 241  46.9   42.4 2008-08-28
#> 242  46.7   43.3 2008-08-29
#> 243  46.7   43.3 2008-08-30
#> 244  45.2   44.6 2008-08-31
#> 245  47.5   43.8 2008-09-01
#> 246  47.5   43.8 2008-09-02
#> 247  47.5   43.8 2008-09-03
#> 248  47.5   43.8 2008-09-04
#> 249  48.2   43.2 2008-09-05
#> 250  44.9   46.8 2008-09-06
#> 251  45.7   46.9 2008-09-07
#> 252  44.4   49.1 2008-09-08
#> 253  43.7   49.2 2008-09-09
#> 254  43.2   50.0 2008-09-10
#> 255  42.7   50.2 2008-09-11
#> 256  43.8   49.0 2008-09-12
#> 257  44.7   48.1 2008-09-13
#> 258  44.4   48.5 2008-09-14
#> 259  45.1   47.5 2008-09-15
#> 260  45.2   47.6 2008-09-16
#> 261  46.0   46.8 2008-09-17
#> 262  46.7   46.4 2008-09-18
#> 263  46.4   46.9 2008-09-19
#> 264  46.5   46.7 2008-09-20
#> 265  46.8   46.3 2008-09-21
#> 266  47.0   46.5 2008-09-22
#> 267  47.7   45.7 2008-09-23
#> 268  47.7   45.7 2008-09-24
#> 269  47.7   45.7 2008-09-25
#> 270  47.5   45.6 2008-09-26
#> 271  47.1   46.1 2008-09-27
#> 272  47.6   46.0 2008-09-28
#> 273  47.6   46.2 2008-09-29
#> 274  47.2   46.3 2008-09-30
#> 275  47.3   46.2 2008-10-01
#> 276  47.6   45.9 2008-10-02
#> 277  47.8   45.9 2008-10-03
#> 278  48.0   46.0 2008-10-04
#> 279  48.5   45.7 2008-10-05
#> 280  48.1   45.8 2008-10-06
#> 281  48.8   45.5 2008-10-07
#> 282  48.4   45.8 2008-10-08
#> 283  48.6   45.8 2008-10-09
#> 284  49.0   45.3 2008-10-10
#> 285  48.9   45.0 2008-10-11
#> 286  49.0   45.2 2008-10-12
#> 287  49.5   44.6 2008-10-13
#> 288  49.4   44.4 2008-10-14
#> 289  49.3   44.2 2008-10-15
#> 290  49.1   44.3 2008-10-16
#> 291  49.2   44.1 2008-10-17
#> 292  48.4   44.3 2008-10-18
#> 293  48.1   44.2 2008-10-19
#> 294  48.8   43.8 2008-10-20
#> 295  48.7   44.1 2008-10-21
#> 296  49.0   43.9 2008-10-22
#> 297  49.0   43.9 2008-10-23
#> 298  48.6   44.3 2008-10-24
#> 299  49.4   44.1 2008-10-25
#> 300  49.7   43.9 2008-10-26
#> 301  49.2   44.3 2008-10-27
#> 302  49.1   44.5 2008-10-28
#> 303  49.0   44.9 2008-10-29
#> 304  49.1   45.0 2008-10-30
#> 305  49.2   45.3 2008-10-31
#> 306  49.1   45.4 2008-11-01
#> 307  48.8   45.8 2008-11-02
#> 308  48.8   45.9 2008-11-03
#> 309  49.4   45.7 2008-11-04
```
Note that the other arguments for `poll_ma` are placed after the name of the function as additional arguments to `map_df`.

It is easier to plot this if the data are tidy, with `Obama` and `McCain` as categories of a column `candidate`.

```r
pop_vote_avg_tidy <-
  pop_vote_avg %>%
  gather(candidate, share, -date, na.rm = TRUE)
pop_vote_avg_tidy
#>           date candidate share
#> 1   2008-01-01     Obama  46.5
#> 2   2008-01-02     Obama  46.5
#> 3   2008-01-03     Obama  46.5
#> 4   2008-01-04     Obama  46.5
#> 5   2008-01-05     Obama  46.5
#> 6   2008-01-06     Obama  46.5
#> 7   2008-01-07     Obama  46.5
#> 8   2008-01-08     Obama  40.5
#> 9   2008-01-09     Obama  40.5
#> 10  2008-01-10     Obama  40.5
#> 11  2008-01-11     Obama  40.5
#> 12  2008-01-12     Obama  45.7
#> 13  2008-01-13     Obama  45.7
#> 14  2008-01-14     Obama  45.7
#> 15  2008-01-15     Obama  47.7
#> 16  2008-01-16     Obama  42.4
#> 17  2008-01-17     Obama  42.4
#> 18  2008-01-18     Obama  42.4
#> 19  2008-01-19     Obama  37.7
#> 20  2008-01-20     Obama  40.6
#> 21  2008-01-21     Obama  40.6
#> 22  2008-01-22     Obama  39.8
#> 23  2008-01-23     Obama  45.0
#> 24  2008-01-24     Obama  45.0
#> 25  2008-01-25     Obama  45.0
#> 26  2008-01-26     Obama  45.0
#> 34  2008-02-03     Obama  42.3
#> 35  2008-02-04     Obama  42.3
#> 36  2008-02-05     Obama  42.3
#> 37  2008-02-06     Obama  42.3
#> 38  2008-02-07     Obama  42.3
#> 39  2008-02-08     Obama  42.3
#> 40  2008-02-09     Obama  41.8
#> 41  2008-02-10     Obama  41.0
#> 42  2008-02-11     Obama  43.7
#> 43  2008-02-12     Obama  44.9
#> 44  2008-02-13     Obama  44.7
#> 45  2008-02-14     Obama  45.1
#> 46  2008-02-15     Obama  44.9
#> 47  2008-02-16     Obama  48.4
#> 48  2008-02-17     Obama  47.5
#> 49  2008-02-18     Obama  47.4
#> 50  2008-02-19     Obama  47.5
#> 51  2008-02-20     Obama  48.2
#> 52  2008-02-21     Obama  47.8
#> 53  2008-02-22     Obama  47.8
#> 54  2008-02-23     Obama  43.9
#> 55  2008-02-24     Obama  44.9
#> 56  2008-02-25     Obama  45.0
#> 57  2008-02-26     Obama  46.0
#> 58  2008-02-27     Obama  45.3
#> 59  2008-02-28     Obama  45.4
#> 60  2008-02-29     Obama  45.4
#> 61  2008-03-01     Obama  45.4
#> 62  2008-03-02     Obama  45.5
#> 63  2008-03-03     Obama  45.5
#> 64  2008-03-04     Obama  45.3
#> 65  2008-03-05     Obama  41.0
#> 66  2008-03-06     Obama  38.0
#> 67  2008-03-07     Obama  39.5
#> 68  2008-03-08     Obama  35.3
#> 69  2008-03-09     Obama  35.3
#> 70  2008-03-10     Obama  38.0
#> 71  2008-03-11     Obama  42.2
#> 72  2008-03-12     Obama  43.6
#> 73  2008-03-13     Obama  43.2
#> 74  2008-03-14     Obama  44.1
#> 75  2008-03-15     Obama  45.7
#> 76  2008-03-16     Obama  45.6
#> 77  2008-03-17     Obama  46.1
#> 78  2008-03-18     Obama  45.2
#> 79  2008-03-19     Obama  45.0
#> 80  2008-03-20     Obama  44.9
#> 81  2008-03-21     Obama  45.0
#> 82  2008-03-22     Obama  44.4
#> 83  2008-03-23     Obama  44.5
#> 84  2008-03-24     Obama  43.1
#> 85  2008-03-25     Obama  42.3
#> 86  2008-03-26     Obama  42.2
#> 87  2008-03-27     Obama  43.1
#> 88  2008-03-28     Obama  42.3
#> 89  2008-03-29     Obama  41.4
#> 90  2008-03-30     Obama  41.7
#> 91  2008-03-31     Obama  42.3
#> 92  2008-04-01     Obama  43.6
#> 93  2008-04-02     Obama  42.4
#> 94  2008-04-03     Obama  39.6
#> 95  2008-04-04     Obama  39.6
#> 96  2008-04-05     Obama  41.3
#> 97  2008-04-06     Obama  41.0
#> 98  2008-04-07     Obama  41.6
#> 99  2008-04-08     Obama  41.2
#> 100 2008-04-09     Obama  41.8
#> 101 2008-04-10     Obama  43.6
#> 102 2008-04-11     Obama  43.6
#> 103 2008-04-12     Obama  44.0
#> 104 2008-04-13     Obama  44.0
#> 105 2008-04-14     Obama  43.9
#> 106 2008-04-15     Obama  44.1
#> 107 2008-04-16     Obama  44.7
#> 108 2008-04-17     Obama  44.9
#> 109 2008-04-18     Obama  44.9
#> 110 2008-04-19     Obama  46.1
#> 111 2008-04-20     Obama  45.0
#> 112 2008-04-21     Obama  45.0
#> 113 2008-04-22     Obama  46.1
#> 114 2008-04-23     Obama  46.2
#> 115 2008-04-24     Obama  45.9
#> 116 2008-04-25     Obama  45.1
#> 117 2008-04-26     Obama  45.5
#> 118 2008-04-27     Obama  46.2
#> 119 2008-04-28     Obama  46.2
#> 120 2008-04-29     Obama  45.2
#> 121 2008-04-30     Obama  43.7
#> 122 2008-05-01     Obama  44.4
#> 123 2008-05-02     Obama  45.0
#> 124 2008-05-03     Obama  44.1
#> 125 2008-05-04     Obama  43.7
#> 126 2008-05-05     Obama  43.6
#> 127 2008-05-06     Obama  42.6
#> 128 2008-05-07     Obama  44.3
#> 129 2008-05-08     Obama  42.7
#> 130 2008-05-09     Obama  42.7
#> 131 2008-05-10     Obama  42.4
#> 132 2008-05-11     Obama  42.4
#> 133 2008-05-12     Obama  43.2
#> 134 2008-05-13     Obama  44.3
#> 135 2008-05-14     Obama  44.4
#> 136 2008-05-15     Obama  44.2
#> 137 2008-05-16     Obama  43.0
#> 138 2008-05-17     Obama  43.8
#> 139 2008-05-18     Obama  43.8
#> 140 2008-05-19     Obama  43.6
#> 141 2008-05-20     Obama  43.0
#> 142 2008-05-21     Obama  43.2
#> 143 2008-05-22     Obama  43.7
#> 144 2008-05-23     Obama  44.4
#> 145 2008-05-24     Obama  43.9
#> 146 2008-05-25     Obama  43.9
#> 147 2008-05-26     Obama  43.9
#> 148 2008-05-27     Obama  44.7
#> 149 2008-05-28     Obama  43.3
#> 150 2008-05-29     Obama  42.9
#> 151 2008-05-30     Obama  42.8
#> 152 2008-05-31     Obama  41.7
#> 153 2008-06-01     Obama  41.7
#> 154 2008-06-02     Obama  41.0
#> 155 2008-06-03     Obama  42.1
#> 156 2008-06-04     Obama  41.7
#> 157 2008-06-05     Obama  41.5
#> 158 2008-06-06     Obama  41.8
#> 159 2008-06-07     Obama  42.7
#> 160 2008-06-08     Obama  44.5
#> 161 2008-06-09     Obama  47.1
#> 162 2008-06-10     Obama  46.8
#> 163 2008-06-11     Obama  46.7
#> 164 2008-06-12     Obama  46.9
#> 165 2008-06-13     Obama  47.0
#> 166 2008-06-14     Obama  46.8
#> 167 2008-06-15     Obama  46.5
#> 168 2008-06-16     Obama  45.5
#> 169 2008-06-17     Obama  44.9
#> 170 2008-06-18     Obama  45.7
#> 171 2008-06-19     Obama  45.0
#> 172 2008-06-20     Obama  45.4
#> 173 2008-06-21     Obama  45.3
#> 174 2008-06-22     Obama  45.3
#> 175 2008-06-23     Obama  45.7
#> 176 2008-06-24     Obama  46.1
#> 177 2008-06-25     Obama  44.0
#> 178 2008-06-26     Obama  44.8
#> 179 2008-06-27     Obama  44.4
#> 180 2008-06-28     Obama  44.1
#> 181 2008-06-29     Obama  43.1
#> 182 2008-06-30     Obama  45.4
#> 183 2008-07-01     Obama  46.9
#> 184 2008-07-02     Obama  49.4
#> 185 2008-07-03     Obama  51.2
#> 186 2008-07-04     Obama  52.7
#> 187 2008-07-05     Obama  52.7
#> 188 2008-07-06     Obama  52.7
#> 189 2008-07-07     Obama  47.8
#> 190 2008-07-08     Obama  46.7
#> 191 2008-07-09     Obama  46.0
#> 192 2008-07-10     Obama  47.2
#> 193 2008-07-11     Obama  47.8
#> 194 2008-07-12     Obama  47.8
#> 195 2008-07-13     Obama  47.6
#> 196 2008-07-14     Obama  46.5
#> 197 2008-07-15     Obama  45.6
#> 198 2008-07-16     Obama  45.6
#> 199 2008-07-17     Obama  43.9
#> 200 2008-07-18     Obama  43.9
#> 201 2008-07-19     Obama  44.2
#> 202 2008-07-20     Obama  44.3
#> 203 2008-07-21     Obama  43.9
#> 204 2008-07-22     Obama  43.7
#> 205 2008-07-23     Obama  44.0
#> 206 2008-07-24     Obama  43.9
#> 207 2008-07-25     Obama  43.3
#> 208 2008-07-26     Obama  43.7
#> 209 2008-07-27     Obama  43.5
#> 210 2008-07-28     Obama  43.7
#> 211 2008-07-29     Obama  42.5
#> 212 2008-07-30     Obama  41.3
#> 213 2008-07-31     Obama  41.5
#> 214 2008-08-01     Obama  41.3
#> 215 2008-08-02     Obama  41.1
#> 216 2008-08-03     Obama  41.6
#> 217 2008-08-04     Obama  43.0
#> 218 2008-08-05     Obama  44.7
#> 219 2008-08-06     Obama  46.6
#> 220 2008-08-07     Obama  46.8
#> 221 2008-08-08     Obama  48.2
#> 222 2008-08-09     Obama  47.8
#> 223 2008-08-10     Obama  47.1
#> 224 2008-08-11     Obama  45.9
#> 225 2008-08-12     Obama  45.9
#> 226 2008-08-13     Obama  45.5
#> 227 2008-08-14     Obama  43.1
#> 228 2008-08-15     Obama  42.6
#> 229 2008-08-16     Obama  42.4
#> 230 2008-08-17     Obama  42.4
#> 231 2008-08-18     Obama  42.8
#> 232 2008-08-19     Obama  42.1
#> 233 2008-08-20     Obama  41.8
#> 234 2008-08-21     Obama  42.9
#> 235 2008-08-22     Obama  43.2
#> 236 2008-08-23     Obama  43.3
#> 237 2008-08-24     Obama  43.5
#> 238 2008-08-25     Obama  44.0
#> 239 2008-08-26     Obama  43.9
#> 240 2008-08-27     Obama  45.6
#> 241 2008-08-28     Obama  46.9
#> 242 2008-08-29     Obama  46.7
#> 243 2008-08-30     Obama  46.7
#> 244 2008-08-31     Obama  45.2
#> 245 2008-09-01     Obama  47.5
#> 246 2008-09-02     Obama  47.5
#> 247 2008-09-03     Obama  47.5
#> 248 2008-09-04     Obama  47.5
#> 249 2008-09-05     Obama  48.2
#> 250 2008-09-06     Obama  44.9
#> 251 2008-09-07     Obama  45.7
#> 252 2008-09-08     Obama  44.4
#> 253 2008-09-09     Obama  43.7
#> 254 2008-09-10     Obama  43.2
#> 255 2008-09-11     Obama  42.7
#> 256 2008-09-12     Obama  43.8
#> 257 2008-09-13     Obama  44.7
#> 258 2008-09-14     Obama  44.4
#> 259 2008-09-15     Obama  45.1
#> 260 2008-09-16     Obama  45.2
#> 261 2008-09-17     Obama  46.0
#> 262 2008-09-18     Obama  46.7
#> 263 2008-09-19     Obama  46.4
#> 264 2008-09-20     Obama  46.5
#> 265 2008-09-21     Obama  46.8
#> 266 2008-09-22     Obama  47.0
#> 267 2008-09-23     Obama  47.7
#> 268 2008-09-24     Obama  47.7
#> 269 2008-09-25     Obama  47.7
#> 270 2008-09-26     Obama  47.5
#> 271 2008-09-27     Obama  47.1
#> 272 2008-09-28     Obama  47.6
#> 273 2008-09-29     Obama  47.6
#> 274 2008-09-30     Obama  47.2
#> 275 2008-10-01     Obama  47.3
#> 276 2008-10-02     Obama  47.6
#> 277 2008-10-03     Obama  47.8
#> 278 2008-10-04     Obama  48.0
#> 279 2008-10-05     Obama  48.5
#> 280 2008-10-06     Obama  48.1
#> 281 2008-10-07     Obama  48.8
#> 282 2008-10-08     Obama  48.4
#> 283 2008-10-09     Obama  48.6
#> 284 2008-10-10     Obama  49.0
#> 285 2008-10-11     Obama  48.9
#> 286 2008-10-12     Obama  49.0
#> 287 2008-10-13     Obama  49.5
#> 288 2008-10-14     Obama  49.4
#> 289 2008-10-15     Obama  49.3
#> 290 2008-10-16     Obama  49.1
#> 291 2008-10-17     Obama  49.2
#> 292 2008-10-18     Obama  48.4
#> 293 2008-10-19     Obama  48.1
#> 294 2008-10-20     Obama  48.8
#> 295 2008-10-21     Obama  48.7
#> 296 2008-10-22     Obama  49.0
#> 297 2008-10-23     Obama  49.0
#> 298 2008-10-24     Obama  48.6
#> 299 2008-10-25     Obama  49.4
#> 300 2008-10-26     Obama  49.7
#> 301 2008-10-27     Obama  49.2
#> 302 2008-10-28     Obama  49.1
#> 303 2008-10-29     Obama  49.0
#> 304 2008-10-30     Obama  49.1
#> 305 2008-10-31     Obama  49.2
#> 306 2008-11-01     Obama  49.1
#> 307 2008-11-02     Obama  48.8
#> 308 2008-11-03     Obama  48.8
#> 309 2008-11-04     Obama  49.4
#> 310 2008-01-01    McCain  52.5
#> 311 2008-01-02    McCain  52.5
#> 312 2008-01-03    McCain  52.5
#> 313 2008-01-04    McCain  52.5
#> 314 2008-01-05    McCain  52.4
#> 315 2008-01-06    McCain  52.4
#> 316 2008-01-07    McCain  52.4
#> 317 2008-01-08    McCain  48.0
#> 318 2008-01-09    McCain  48.0
#> 319 2008-01-10    McCain  48.0
#> 320 2008-01-11    McCain  48.0
#> 321 2008-01-12    McCain  45.3
#> 322 2008-01-13    McCain  45.3
#> 323 2008-01-14    McCain  45.3
#> 324 2008-01-15    McCain  44.0
#> 325 2008-01-16    McCain  49.4
#> 326 2008-01-17    McCain  49.4
#> 327 2008-01-18    McCain  49.4
#> 328 2008-01-19    McCain  52.3
#> 329 2008-01-20    McCain  50.0
#> 330 2008-01-21    McCain  50.0
#> 331 2008-01-22    McCain  52.0
#> 332 2008-01-23    McCain  46.5
#> 333 2008-01-24    McCain  46.5
#> 334 2008-01-25    McCain  46.5
#> 335 2008-01-26    McCain  46.5
#> 343 2008-02-03    McCain  49.7
#> 344 2008-02-04    McCain  49.7
#> 345 2008-02-05    McCain  49.7
#> 346 2008-02-06    McCain  49.7
#> 347 2008-02-07    McCain  49.7
#> 348 2008-02-08    McCain  49.7
#> 349 2008-02-09    McCain  46.4
#> 350 2008-02-10    McCain  41.5
#> 351 2008-02-11    McCain  39.7
#> 352 2008-02-12    McCain  39.6
#> 353 2008-02-13    McCain  39.9
#> 354 2008-02-14    McCain  39.8
#> 355 2008-02-15    McCain  41.0
#> 356 2008-02-16    McCain  42.0
#> 357 2008-02-17    McCain  42.3
#> 358 2008-02-18    McCain  42.5
#> 359 2008-02-19    McCain  43.2
#> 360 2008-02-20    McCain  43.1
#> 361 2008-02-21    McCain  43.1
#> 362 2008-02-22    McCain  43.2
#> 363 2008-02-23    McCain  43.9
#> 364 2008-02-24    McCain  44.0
#> 365 2008-02-25    McCain  44.4
#> 366 2008-02-26    McCain  42.7
#> 367 2008-02-27    McCain  45.0
#> 368 2008-02-28    McCain  45.1
#> 369 2008-02-29    McCain  45.0
#> 370 2008-03-01    McCain  45.0
#> 371 2008-03-02    McCain  45.0
#> 372 2008-03-03    McCain  45.0
#> 373 2008-03-04    McCain  45.2
#> 374 2008-03-05    McCain  46.5
#> 375 2008-03-06    McCain  48.0
#> 376 2008-03-07    McCain  46.5
#> 377 2008-03-08    McCain  45.3
#> 378 2008-03-09    McCain  45.3
#> 379 2008-03-10    McCain  44.8
#> 380 2008-03-11    McCain  42.0
#> 381 2008-03-12    McCain  42.1
#> 382 2008-03-13    McCain  42.6
#> 383 2008-03-14    McCain  42.0
#> 384 2008-03-15    McCain  45.9
#> 385 2008-03-16    McCain  45.9
#> 386 2008-03-17    McCain  45.7
#> 387 2008-03-18    McCain  46.8
#> 388 2008-03-19    McCain  46.4
#> 389 2008-03-20    McCain  46.8
#> 390 2008-03-21    McCain  46.7
#> 391 2008-03-22    McCain  44.8
#> 392 2008-03-23    McCain  44.7
#> 393 2008-03-24    McCain  46.2
#> 394 2008-03-25    McCain  46.1
#> 395 2008-03-26    McCain  47.8
#> 396 2008-03-27    McCain  45.2
#> 397 2008-03-28    McCain  46.1
#> 398 2008-03-29    McCain  46.3
#> 399 2008-03-30    McCain  46.0
#> 400 2008-03-31    McCain  45.3
#> 401 2008-04-01    McCain  44.1
#> 402 2008-04-02    McCain  44.9
#> 403 2008-04-03    McCain  47.7
#> 404 2008-04-04    McCain  47.7
#> 405 2008-04-05    McCain  47.1
#> 406 2008-04-06    McCain  47.7
#> 407 2008-04-07    McCain  47.9
#> 408 2008-04-08    McCain  48.1
#> 409 2008-04-09    McCain  47.5
#> 410 2008-04-10    McCain  46.4
#> 411 2008-04-11    McCain  46.4
#> 412 2008-04-12    McCain  48.0
#> 413 2008-04-13    McCain  48.0
#> 414 2008-04-14    McCain  47.4
#> 415 2008-04-15    McCain  47.9
#> 416 2008-04-16    McCain  47.7
#> 417 2008-04-17    McCain  47.4
#> 418 2008-04-18    McCain  47.4
#> 419 2008-04-19    McCain  44.5
#> 420 2008-04-20    McCain  45.7
#> 421 2008-04-21    McCain  46.8
#> 422 2008-04-22    McCain  44.8
#> 423 2008-04-23    McCain  44.5
#> 424 2008-04-24    McCain  44.4
#> 425 2008-04-25    McCain  44.7
#> 426 2008-04-26    McCain  43.2
#> 427 2008-04-27    McCain  42.5
#> 428 2008-04-28    McCain  42.2
#> 429 2008-04-29    McCain  42.6
#> 430 2008-04-30    McCain  43.6
#> 431 2008-05-01    McCain  43.2
#> 432 2008-05-02    McCain  42.9
#> 433 2008-05-03    McCain  44.2
#> 434 2008-05-04    McCain  44.2
#> 435 2008-05-05    McCain  44.6
#> 436 2008-05-06    McCain  46.0
#> 437 2008-05-07    McCain  44.9
#> 438 2008-05-08    McCain  47.2
#> 439 2008-05-09    McCain  47.2
#> 440 2008-05-10    McCain  48.0
#> 441 2008-05-11    McCain  48.0
#> 442 2008-05-12    McCain  47.7
#> 443 2008-05-13    McCain  45.9
#> 444 2008-05-14    McCain  45.8
#> 445 2008-05-15    McCain  44.9
#> 446 2008-05-16    McCain  45.4
#> 447 2008-05-17    McCain  44.6
#> 448 2008-05-18    McCain  44.8
#> 449 2008-05-19    McCain  44.7
#> 450 2008-05-20    McCain  45.3
#> 451 2008-05-21    McCain  44.9
#> 452 2008-05-22    McCain  44.6
#> 453 2008-05-23    McCain  44.1
#> 454 2008-05-24    McCain  44.5
#> 455 2008-05-25    McCain  44.1
#> 456 2008-05-26    McCain  43.9
#> 457 2008-05-27    McCain  42.9
#> 458 2008-05-28    McCain  44.3
#> 459 2008-05-29    McCain  44.6
#> 460 2008-05-30    McCain  45.4
#> 461 2008-05-31    McCain  46.7
#> 462 2008-06-01    McCain  46.7
#> 463 2008-06-02    McCain  47.0
#> 464 2008-06-03    McCain  45.9
#> 465 2008-06-04    McCain  46.6
#> 466 2008-06-05    McCain  46.4
#> 467 2008-06-06    McCain  45.7
#> 468 2008-06-07    McCain  44.6
#> 469 2008-06-08    McCain  43.1
#> 470 2008-06-09    McCain  40.3
#> 471 2008-06-10    McCain  40.2
#> 472 2008-06-11    McCain  39.8
#> 473 2008-06-12    McCain  40.4
#> 474 2008-06-13    McCain  40.4
#> 475 2008-06-14    McCain  40.5
#> 476 2008-06-15    McCain  41.0
#> 477 2008-06-16    McCain  41.8
#> 478 2008-06-17    McCain  42.4
#> 479 2008-06-18    McCain  42.7
#> 480 2008-06-19    McCain  42.9
#> 481 2008-06-20    McCain  42.1
#> 482 2008-06-21    McCain  43.0
#> 483 2008-06-22    McCain  42.5
#> 484 2008-06-23    McCain  42.5
#> 485 2008-06-24    McCain  42.6
#> 486 2008-06-25    McCain  43.7
#> 487 2008-06-26    McCain  43.8
#> 488 2008-06-27    McCain  45.1
#> 489 2008-06-28    McCain  44.7
#> 490 2008-06-29    McCain  46.4
#> 491 2008-06-30    McCain  43.6
#> 492 2008-07-01    McCain  42.3
#> 493 2008-07-02    McCain  40.6
#> 494 2008-07-03    McCain  37.7
#> 495 2008-07-04    McCain  36.0
#> 496 2008-07-05    McCain  36.0
#> 497 2008-07-06    McCain  36.0
#> 498 2008-07-07    McCain  42.8
#> 499 2008-07-08    McCain  41.7
#> 500 2008-07-09    McCain  43.6
#> 501 2008-07-10    McCain  42.4
#> 502 2008-07-11    McCain  41.5
#> 503 2008-07-12    McCain  41.5
#> 504 2008-07-13    McCain  42.1
#> 505 2008-07-14    McCain  42.4
#> 506 2008-07-15    McCain  43.5
#> 507 2008-07-16    McCain  41.9
#> 508 2008-07-17    McCain  42.7
#> 509 2008-07-18    McCain  43.4
#> 510 2008-07-19    McCain  43.0
#> 511 2008-07-20    McCain  43.0
#> 512 2008-07-21    McCain  43.4
#> 513 2008-07-22    McCain  44.0
#> 514 2008-07-23    McCain  43.4
#> 515 2008-07-24    McCain  43.4
#> 516 2008-07-25    McCain  43.5
#> 517 2008-07-26    McCain  43.4
#> 518 2008-07-27    McCain  43.2
#> 519 2008-07-28    McCain  43.2
#> 520 2008-07-29    McCain  44.1
#> 521 2008-07-30    McCain  46.4
#> 522 2008-07-31    McCain  47.2
#> 523 2008-08-01    McCain  46.4
#> 524 2008-08-02    McCain  47.2
#> 525 2008-08-03    McCain  46.6
#> 526 2008-08-04    McCain  45.0
#> 527 2008-08-05    McCain  43.0
#> 528 2008-08-06    McCain  41.1
#> 529 2008-08-07    McCain  40.7
#> 530 2008-08-08    McCain  40.7
#> 531 2008-08-09    McCain  40.9
#> 532 2008-08-10    McCain  42.3
#> 533 2008-08-11    McCain  44.2
#> 534 2008-08-12    McCain  43.3
#> 535 2008-08-13    McCain  43.7
#> 536 2008-08-14    McCain  46.0
#> 537 2008-08-15    McCain  45.7
#> 538 2008-08-16    McCain  45.5
#> 539 2008-08-17    McCain  45.5
#> 540 2008-08-18    McCain  44.9
#> 541 2008-08-19    McCain  45.7
#> 542 2008-08-20    McCain  45.7
#> 543 2008-08-21    McCain  44.9
#> 544 2008-08-22    McCain  45.1
#> 545 2008-08-23    McCain  45.2
#> 546 2008-08-24    McCain  44.6
#> 547 2008-08-25    McCain  44.5
#> 548 2008-08-26    McCain  45.0
#> 549 2008-08-27    McCain  44.6
#> 550 2008-08-28    McCain  42.4
#> 551 2008-08-29    McCain  43.3
#> 552 2008-08-30    McCain  43.3
#> 553 2008-08-31    McCain  44.6
#> 554 2008-09-01    McCain  43.8
#> 555 2008-09-02    McCain  43.8
#> 556 2008-09-03    McCain  43.8
#> 557 2008-09-04    McCain  43.8
#> 558 2008-09-05    McCain  43.2
#> 559 2008-09-06    McCain  46.8
#> 560 2008-09-07    McCain  46.9
#> 561 2008-09-08    McCain  49.1
#> 562 2008-09-09    McCain  49.2
#> 563 2008-09-10    McCain  50.0
#> 564 2008-09-11    McCain  50.2
#> 565 2008-09-12    McCain  49.0
#> 566 2008-09-13    McCain  48.1
#> 567 2008-09-14    McCain  48.5
#> 568 2008-09-15    McCain  47.5
#> 569 2008-09-16    McCain  47.6
#> 570 2008-09-17    McCain  46.8
#> 571 2008-09-18    McCain  46.4
#> 572 2008-09-19    McCain  46.9
#> 573 2008-09-20    McCain  46.7
#> 574 2008-09-21    McCain  46.3
#> 575 2008-09-22    McCain  46.5
#> 576 2008-09-23    McCain  45.7
#> 577 2008-09-24    McCain  45.7
#> 578 2008-09-25    McCain  45.7
#> 579 2008-09-26    McCain  45.6
#> 580 2008-09-27    McCain  46.1
#> 581 2008-09-28    McCain  46.0
#> 582 2008-09-29    McCain  46.2
#> 583 2008-09-30    McCain  46.3
#> 584 2008-10-01    McCain  46.2
#> 585 2008-10-02    McCain  45.9
#> 586 2008-10-03    McCain  45.9
#> 587 2008-10-04    McCain  46.0
#> 588 2008-10-05    McCain  45.7
#> 589 2008-10-06    McCain  45.8
#> 590 2008-10-07    McCain  45.5
#> 591 2008-10-08    McCain  45.8
#> 592 2008-10-09    McCain  45.8
#> 593 2008-10-10    McCain  45.3
#> 594 2008-10-11    McCain  45.0
#> 595 2008-10-12    McCain  45.2
#> 596 2008-10-13    McCain  44.6
#> 597 2008-10-14    McCain  44.4
#> 598 2008-10-15    McCain  44.2
#> 599 2008-10-16    McCain  44.3
#> 600 2008-10-17    McCain  44.1
#> 601 2008-10-18    McCain  44.3
#> 602 2008-10-19    McCain  44.2
#> 603 2008-10-20    McCain  43.8
#> 604 2008-10-21    McCain  44.1
#> 605 2008-10-22    McCain  43.9
#> 606 2008-10-23    McCain  43.9
#> 607 2008-10-24    McCain  44.3
#> 608 2008-10-25    McCain  44.1
#> 609 2008-10-26    McCain  43.9
#> 610 2008-10-27    McCain  44.3
#> 611 2008-10-28    McCain  44.5
#> 612 2008-10-29    McCain  44.9
#> 613 2008-10-30    McCain  45.0
#> 614 2008-10-31    McCain  45.3
#> 615 2008-11-01    McCain  45.4
#> 616 2008-11-02    McCain  45.8
#> 617 2008-11-03    McCain  45.9
#> 618 2008-11-04    McCain  45.7
```


```r
ggplot(pop_vote_avg_tidy, aes(x = date, y = share,
                              colour = fct_reorder2(candidate, date, share))) +
  geom_point() +
  geom_line() +
  scale_colour_manual("Candidate",
                      values = c(Obama = "blue", McCain = "red"))
```

<img src="prediction_files/figure-html/unnamed-chunk-46-1.png" width="70%" style="display: block; margin: auto;" />


**Challenge** read [R for Data Science](http://r4ds.had.co.nz/) chapter [Iteration](http://r4ds.had.co.nz/iteration.html#the-map-functions) and use the function [map_df](https://www.rdocumentation.org/packages/purrr/topics/map_df) instead of a for loop.

The 7-day average is similar to the simple method used by [Real Clear Politics](http://www.realclearpolitics.com/epolls/2016/president/us/general_election_trump_vs_clinton-5491.html).
The RCP average is simply the average of all polls in their data for the last seven days.
Sites like [538](https://fivethirtyeight.com) and the [Huffpost Pollster](http://elections.huffingtonpost.com/pollster), on the other hand, also use what amounts to averaging polls, but using more sophisticated statistical methods to assign different weights to different polls.

**Challenge** Why do we need to use different polls for the popular vote data? Why not simply average all the state polls?
What would you have to do?
Would the overall popular vote be useful in predicting state-level polling, or vice-versa? How would you use them?


## Linear Regression

### Facial Appearance and Election Outcomes

Load the `face` dataset:

```r
data("face", package = "qss")
```
Add Democrat and Republican vote shares, and the difference in shares:

```r
face <- mutate(face,
                d.share = d.votes / (d.votes + r.votes),
                r.share = r.votes / (d.votes + r.votes),
                diff.share = d.share - r.share)
```

Plot facial competence vs. vote share:

```r
ggplot(face, aes(x = d.comp, y = diff.share, colour = w.party)) +
  geom_ref_line(h = 0) +
  geom_point() +
  scale_colour_manual("Winning\nParty",
                      values = c(D = "blue", R = "red")) +
  labs(x = "Competence scores for Democrats",
       y = "Democratic margin in vote share")
```

<img src="prediction_files/figure-html/unnamed-chunk-47-1.png" width="70%" style="display: block; margin: auto;" />

### Correlation and Scatter Plots


```r
cor(face$d.comp, face$diff.share)
#> [1] 0.433
```


### Least Squares

Run the linear regression

```r
fit <- lm(diff.share ~ d.comp, data = face)
fit
#> 
#> Call:
#> lm(formula = diff.share ~ d.comp, data = face)
#> 
#> Coefficients:
#> (Intercept)       d.comp  
#>      -0.312        0.660
```

There are many functions to get data out of the `lm` model.

In addition to these, the [broom](https://cran.r-project.org/package=broom) package provides three functions: `glance`, `tidy`, and `augment` that always return data frames.

The function [glance](https://www.rdocumentation.org/packages/broom/topics/glance.lm) returns a one-row data-frame summary of the model,

```r
glance(fit)
#>   r.squared adj.r.squared sigma statistic  p.value df logLik AIC  BIC
#> 1     0.187          0.18 0.266        27 8.85e-07  2  -10.5  27 35.3
#>   deviance df.residual
#> 1     8.31         117
```
The function [tidy](https://www.rdocumentation.org/packages/broom/topics/tidy.lm) returns a data frame in which each row is a coefficient,

```r
tidy(fit)
#>          term estimate std.error statistic  p.value
#> 1 (Intercept)   -0.312     0.066     -4.73 6.24e-06
#> 2      d.comp    0.660     0.127      5.19 8.85e-07
```
The function [augment](https://www.rdocumentation.org/packages/broom/topics/augment.lm) returns the original data with fitted values, residuals, and other observation level stats from the model appended to it.

```r
augment(fit) %>% head()
#>   diff.share d.comp .fitted .se.fit  .resid    .hat .sigma  .cooksd
#> 1     0.2101  0.565  0.0606  0.0266  0.1495 0.00996  0.267 0.001600
#> 2     0.1194  0.342 -0.0864  0.0302  0.2059 0.01286  0.267 0.003938
#> 3     0.0499  0.612  0.0922  0.0295 -0.0423 0.01229  0.268 0.000158
#> 4     0.1965  0.542  0.0454  0.0256  0.1511 0.00922  0.267 0.001510
#> 5     0.4958  0.680  0.1370  0.0351  0.3588 0.01737  0.266 0.016307
#> 6    -0.3495  0.321 -0.1006  0.0319 -0.2490 0.01433  0.267 0.006436
#>   .std.resid
#> 1      0.564
#> 2      0.778
#> 3     -0.160
#> 4      0.570
#> 5      1.358
#> 6     -0.941
```


We can plot the results of the bivariate linear regression as follows:

```r
ggplot() +
  geom_point(data = face, mapping = aes(x = d.comp, y = diff.share)) +
  geom_ref_line(v = mean(face$d.comp)) +
  geom_ref_line(h = mean(face$diff.share)) +
  geom_abline(slope = coef(fit)["d.comp"],
              intercept = coef(fit)["(Intercept)"],
              colour = "red") +
  annotate("text", x = 0.9, y = mean(face$diff.share) + 0.05,
           label = "Mean of Y", color = "blue", vjust = 0) +
  annotate("text", y = -0.9, x = mean(face$d.comp), label = "Mean of X",
           color = "blue", hjust = 0) +
  scale_y_continuous("Democratic margin in vote shares",
                     breaks = seq(-1, 1, by = 0.5), limits = c(-1, 1)) +
  scale_x_continuous("Democratic margin in vote shares",
                     breaks = seq(0, 1, by = 0.2), limits = c(0, 1)) +
  ggtitle("Facial compotence and vote share")
```

<img src="prediction_files/figure-html/unnamed-chunk-53-1.png" width="70%" style="display: block; margin: auto;" />

A more general way to plot the predictions of the model against the data
is to use the methods described in [Ch 23.3.3](http://r4ds.had.co.nz/model-basics.html#visualising-models) of R4DS.
Create an evenly spaced grid of values of `d.comp`, and add predictions
of the model to it.

```r
grid <- face %>%
  data_grid(d.comp) %>%
  add_predictions(fit)
head(grid)
#> # A tibble: 6 x 2
#>   d.comp   pred
#>    <dbl>  <dbl>
#> 1 0.0640 -0.270
#> 2 0.0847 -0.256
#> 3 0.0893 -0.253
#> 4 0.115  -0.237
#> 5 0.115  -0.236
#> 6 0.164  -0.204
```
Now we can plot the regression line and the original data just like any other plot.

```r
ggplot() +
  geom_point(data = face, mapping = aes(x = d.comp, y = diff.share)) +
  geom_line(data = grid, mapping = aes(x = d.comp, y = pred),
            colour = "red")
```

<img src="prediction_files/figure-html/unnamed-chunk-55-1.png" width="70%" style="display: block; margin: auto;" />
This method is more complicated than the `geom_abline` method for a bivariate regression, but will work for more complicated models, while the `geom_abline` method won't.


Note that [geom_smooth](http://docs.ggplot2.org/current/geom_smooth.html) can be used to add a regression line to a data-set.

```r
ggplot(data = face, mapping = aes(x = d.comp, y = diff.share)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE)
```

<img src="prediction_files/figure-html/unnamed-chunk-56-1.png" width="70%" style="display: block; margin: auto;" />
The argument `method = "lm"` specifies that the function `lm` is to be used to generate fitted values.
It is equivalent to running the regression `lm(y ~ x)` and plotting the regression line, where `y` and `x` are the aesthetics specified by the mappings.
The argument `se = FALSE` tells the function not to plot the confidence interval of the regression (discussed later).

### Regression towards the mean

### Merging Data Sets in R

See the [R for Data Science](http://r4ds.had.co.nz/) chapter [Relational data](http://r4ds.had.co.nz/relational-data.html).


```r
data("pres12", package = "qss")
```

To join both data frames

```r
full_join(pres08, pres12, by = "state")
#>        state.name state Obama.x McCain EV.x margin Obama.y Romney EV.y
#> 1         Alabama    AL      39     60    9    -21      38     61    9
#> 2          Alaska    AK      38     59    3    -21      41     55    3
#> 3         Arizona    AZ      45     54   10     -9      45     54   11
#> 4        Arkansas    AR      39     59    6    -20      37     61    6
#> 5      California    CA      61     37   55     24      60     37   55
#> 6        Colorado    CO      54     45    9      9      51     46    9
#> 7     Connecticut    CT      61     38    7     23      58     41    7
#> 8            D.C.    DC      92      7    3     85      91      7    3
#> 9        Delaware    DE      62     37    3     25      59     40    3
#> 10        Florida    FL      51     48   27      3      50     49   29
#> 11        Georgia    GA      47     52   15     -5      45     53   16
#> 12         Hawaii    HI      72     27    4     45      71     28    4
#> 13          Idaho    ID      36     62    4    -26      33     65    4
#> 14       Illinois    IL      62     37   21     25      58     41   20
#> 15        Indiana    IN      50     49   11      1      44     54   11
#> 16           Iowa    IA      54     44    7     10      52     46    6
#> 17         Kansas    KS      42     57    6    -15      38     60    6
#> 18       Kentucky    KY      41     57    8    -16      38     60    8
#> 19      Louisiana    LA      40     59    9    -19      41     58    8
#> 20          Maine    ME      58     40    4     18      56     41    4
#> 21       Maryland    MD      62     36   10     26      62     36   10
#> 22  Massachusetts    MA      62     36   12     26      61     38   11
#> 23       Michigan    MI      57     41   17     16      54     45   16
#> 24      Minnesota    MN      54     44   10     10      53     45   10
#> 25    Mississippi    MS      43     56    6    -13      44     55    6
#> 26       Missouri    MO      48     49   11     -1      44     54   10
#> 27        Montana    MT      47     50    3     -3      42     55    3
#> 28       Nebraska    NE      42     57    5    -15      38     60    5
#> 29         Nevada    NV      55     43    5     12      52     46    6
#> 30  New Hampshire    NH      54     45    4      9      52     46    4
#> 31     New Jersey    NJ      57     42   15     15      58     41   14
#> 32     New Mexico    NM      57     42    5     15      53     43    5
#> 33       New York    NY      63     36   31     27      63     35   29
#> 34 North Carolina    NC      50     49   15      1      48     50   15
#> 35   North Dakota    ND      45     53    3     -8      39     58    3
#> 36           Ohio    OH      51     47   20      4      51     48   18
#> 37       Oklahoma    OK      34     66    7    -32      33     67    7
#> 38         Oregon    OR      57     40    7     17      54     42    7
#> 39   Pennsylvania    PA      55     44   21     11      52     47   20
#> 40   Rhode Island    RI      63     35    4     28      63     35    4
#> 41 South Carolina    SC      45     54    8     -9      44     55    9
#> 42   South Dakota    SD      45     53    3     -8      40     58    3
#> 43      Tennessee    TN      42     57   11    -15      39     59   11
#> 44          Texas    TX      44     55   34    -11      41     57   38
#> 45           Utah    UT      34     63    5    -29      25     73    6
#> 46        Vermont    VT      67     30    3     37      67     31    3
#> 47       Virginia    VA      53     46   13      7      51     47   13
#> 48     Washington    WA      58     40   11     18      56     41   12
#> 49  West Virginia    WV      43     56    5    -13      36     62    5
#> 50      Wisconsin    WI      56     42   10     14      53     46   10
#> 51        Wyoming    WY      33     65    3    -32      28     69    3
```
However, since there are duplicate names, `.x` and `.y` are appended.

**Challenge** What would happen if `by = "state"` was dropped? 

To avoid the duplicate names, or change them, you can rename before merging, 

```r
full_join(select(pres08, state, Obama_08 = Obama, McCain_08 = McCain,
                 EV_08 = EV),
          select(pres12, state, Obama_12 = Obama, Romney_12 = Romney,
                 EV_12 = EV),
          by = "state")
#>    state Obama_08 McCain_08 EV_08 Obama_12 Romney_12 EV_12
#> 1     AL       39        60     9       38        61     9
#> 2     AK       38        59     3       41        55     3
#> 3     AZ       45        54    10       45        54    11
#> 4     AR       39        59     6       37        61     6
#> 5     CA       61        37    55       60        37    55
#> 6     CO       54        45     9       51        46     9
#> 7     CT       61        38     7       58        41     7
#> 8     DC       92         7     3       91         7     3
#> 9     DE       62        37     3       59        40     3
#> 10    FL       51        48    27       50        49    29
#> 11    GA       47        52    15       45        53    16
#> 12    HI       72        27     4       71        28     4
#> 13    ID       36        62     4       33        65     4
#> 14    IL       62        37    21       58        41    20
#> 15    IN       50        49    11       44        54    11
#> 16    IA       54        44     7       52        46     6
#> 17    KS       42        57     6       38        60     6
#> 18    KY       41        57     8       38        60     8
#> 19    LA       40        59     9       41        58     8
#> 20    ME       58        40     4       56        41     4
#> 21    MD       62        36    10       62        36    10
#> 22    MA       62        36    12       61        38    11
#> 23    MI       57        41    17       54        45    16
#> 24    MN       54        44    10       53        45    10
#> 25    MS       43        56     6       44        55     6
#> 26    MO       48        49    11       44        54    10
#> 27    MT       47        50     3       42        55     3
#> 28    NE       42        57     5       38        60     5
#> 29    NV       55        43     5       52        46     6
#> 30    NH       54        45     4       52        46     4
#> 31    NJ       57        42    15       58        41    14
#> 32    NM       57        42     5       53        43     5
#> 33    NY       63        36    31       63        35    29
#> 34    NC       50        49    15       48        50    15
#> 35    ND       45        53     3       39        58     3
#> 36    OH       51        47    20       51        48    18
#> 37    OK       34        66     7       33        67     7
#> 38    OR       57        40     7       54        42     7
#> 39    PA       55        44    21       52        47    20
#> 40    RI       63        35     4       63        35     4
#> 41    SC       45        54     8       44        55     9
#> 42    SD       45        53     3       40        58     3
#> 43    TN       42        57    11       39        59    11
#> 44    TX       44        55    34       41        57    38
#> 45    UT       34        63     5       25        73     6
#> 46    VT       67        30     3       67        31     3
#> 47    VA       53        46    13       51        47    13
#> 48    WA       58        40    11       56        41    12
#> 49    WV       43        56     5       36        62     5
#> 50    WI       56        42    10       53        46    10
#> 51    WY       33        65     3       28        69     3
```
or use the `suffix` argument to `full_join`

```r
pres <- full_join(pres08, pres12, by = "state", suffix = c("_08", "_12"))
pres
#>        state.name state Obama_08 McCain EV_08 margin Obama_12 Romney EV_12
#> 1         Alabama    AL       39     60     9    -21       38     61     9
#> 2          Alaska    AK       38     59     3    -21       41     55     3
#> 3         Arizona    AZ       45     54    10     -9       45     54    11
#> 4        Arkansas    AR       39     59     6    -20       37     61     6
#> 5      California    CA       61     37    55     24       60     37    55
#> 6        Colorado    CO       54     45     9      9       51     46     9
#> 7     Connecticut    CT       61     38     7     23       58     41     7
#> 8            D.C.    DC       92      7     3     85       91      7     3
#> 9        Delaware    DE       62     37     3     25       59     40     3
#> 10        Florida    FL       51     48    27      3       50     49    29
#> 11        Georgia    GA       47     52    15     -5       45     53    16
#> 12         Hawaii    HI       72     27     4     45       71     28     4
#> 13          Idaho    ID       36     62     4    -26       33     65     4
#> 14       Illinois    IL       62     37    21     25       58     41    20
#> 15        Indiana    IN       50     49    11      1       44     54    11
#> 16           Iowa    IA       54     44     7     10       52     46     6
#> 17         Kansas    KS       42     57     6    -15       38     60     6
#> 18       Kentucky    KY       41     57     8    -16       38     60     8
#> 19      Louisiana    LA       40     59     9    -19       41     58     8
#> 20          Maine    ME       58     40     4     18       56     41     4
#> 21       Maryland    MD       62     36    10     26       62     36    10
#> 22  Massachusetts    MA       62     36    12     26       61     38    11
#> 23       Michigan    MI       57     41    17     16       54     45    16
#> 24      Minnesota    MN       54     44    10     10       53     45    10
#> 25    Mississippi    MS       43     56     6    -13       44     55     6
#> 26       Missouri    MO       48     49    11     -1       44     54    10
#> 27        Montana    MT       47     50     3     -3       42     55     3
#> 28       Nebraska    NE       42     57     5    -15       38     60     5
#> 29         Nevada    NV       55     43     5     12       52     46     6
#> 30  New Hampshire    NH       54     45     4      9       52     46     4
#> 31     New Jersey    NJ       57     42    15     15       58     41    14
#> 32     New Mexico    NM       57     42     5     15       53     43     5
#> 33       New York    NY       63     36    31     27       63     35    29
#> 34 North Carolina    NC       50     49    15      1       48     50    15
#> 35   North Dakota    ND       45     53     3     -8       39     58     3
#> 36           Ohio    OH       51     47    20      4       51     48    18
#> 37       Oklahoma    OK       34     66     7    -32       33     67     7
#> 38         Oregon    OR       57     40     7     17       54     42     7
#> 39   Pennsylvania    PA       55     44    21     11       52     47    20
#> 40   Rhode Island    RI       63     35     4     28       63     35     4
#> 41 South Carolina    SC       45     54     8     -9       44     55     9
#> 42   South Dakota    SD       45     53     3     -8       40     58     3
#> 43      Tennessee    TN       42     57    11    -15       39     59    11
#> 44          Texas    TX       44     55    34    -11       41     57    38
#> 45           Utah    UT       34     63     5    -29       25     73     6
#> 46        Vermont    VT       67     30     3     37       67     31     3
#> 47       Virginia    VA       53     46    13      7       51     47    13
#> 48     Washington    WA       58     40    11     18       56     41    12
#> 49  West Virginia    WV       43     56     5    -13       36     62     5
#> 50      Wisconsin    WI       56     42    10     14       53     46    10
#> 51        Wyoming    WY       33     65     3    -32       28     69     3
```

**Challenge** Would you consider this data tidy? How would you make it tidy?

The **dplyr** equivalent functions for [cbind](https://www.rdocumentation.org/packages/base/topics/cbind) is [bind_cols](https://www.rdocumentation.org/packages/dplyr/topics/bind_cols).

```r
pres <- pres %>%
  mutate(Obama2008_z = as.numeric(scale(Obama_08)),
         Obama2012_z = as.numeric(scale(Obama_12)))
```
Likewise, [bind_cols](https://www.rdocumentation.org/packages/dplyr/topics/bind_cols) concatenates data frames by row.

We need to use the `as.numeric` function because `scale()` always returns a matrix.
This will not produce an error in the code chunk above, since the columns of a data frame
can be matrices, but will produce errors in some of the following code if it were omitted.

Scatter plot of states with vote shares in 2008 and 2012

```r
ggplot(pres, aes(x = Obama2008_z, y = Obama2012_z, label = state)) +
  geom_abline(colour = "white", size = 2) +
  geom_text() +
  coord_fixed() +
  scale_x_continuous("Obama's standardized vote share in 2008",
                     limits = c(-4, 4)) +
  scale_y_continuous("Obama's standardized vote share in 2012",
                     limits = c(-4, 4))
```

<img src="prediction_files/figure-html/unnamed-chunk-61-1.png" width="70%" style="display: block; margin: auto;" />

To calculate the bottom and top quartiles

```r
pres %>%
  filter(Obama2008_z < quantile(Obama2008_z, 0.25)) %>%
  summarise(improve = mean(Obama2012_z > Obama2008_z))
#>   improve
#> 1   0.583

pres %>%
  filter(Obama2008_z < quantile(Obama2008_z, 0.75)) %>%
  summarise(improve = mean(Obama2012_z > Obama2008_z))
#>   improve
#> 1     0.5
```

**Challenge:** Why is it important to standardize the vote shares?

### Model Fit


```r
data("florida", package = "qss")
fit2 <- lm(Buchanan00 ~ Perot96, data = florida)
fit2
#> 
#> Call:
#> lm(formula = Buchanan00 ~ Perot96, data = florida)
#> 
#> Coefficients:
#> (Intercept)      Perot96  
#>      1.3458       0.0359
```

Calculate $R ^ 2$ from the results of `summary`,

```r
summary(fit2)$r.squared
#> [1] 0.513
```
Alternatively, can get the R squared value from the data frame [glance](https://www.rdocumentation.org/packages/broom/topics/glance.lm) returns:

```r
glance(fit2)
#>   r.squared adj.r.squared sigma statistic  p.value df logLik AIC BIC
#> 1     0.513         0.506   316      68.5 9.47e-12  2   -480 966 972
#>   deviance df.residual
#> 1  6506118          65
```

We can add predictions and residuals to the original data frame using the [modelr](https://cran.r-project.org/package=modelr) functions [add_residuals](https://www.rdocumentation.org/packages/modelr/topics/add_residuals) and [add_predictions](https://www.rdocumentation.org/packages/modelr/topics/add_predictions)

```r
florida <-
  florida %>%
  add_predictions(fit2) %>%
  add_residuals(fit2)
glimpse(florida)
#> Observations: 67
#> Variables: 9
#> $ county     <chr> "Alachua", "Baker", "Bay", "Bradford", "Brevard", "...
#> $ Clinton96  <int> 40144, 2273, 17020, 3356, 80416, 320736, 1794, 2712...
#> $ Dole96     <int> 25303, 3684, 28290, 4038, 87980, 142834, 1717, 2783...
#> $ Perot96    <int> 8072, 667, 5922, 819, 25249, 38964, 630, 7783, 7244...
#> $ Bush00     <int> 34124, 5610, 38637, 5414, 115185, 177323, 2873, 354...
#> $ Gore00     <int> 47365, 2392, 18850, 3075, 97318, 386561, 2155, 2964...
#> $ Buchanan00 <int> 263, 73, 248, 65, 570, 788, 90, 182, 270, 186, 122,...
#> $ pred       <dbl> 291.3, 25.3, 214.0, 30.8, 908.2, 1400.7, 24.0, 280....
#> $ resid      <dbl> -2.83e+01, 4.77e+01, 3.40e+01, 3.42e+01, -3.38e+02,...
```
There are now two new columns in `florida`, `pred` with the fitted values (predictions), and `resid` with the residuals.

Use `fit2_augment` to create a residual plot:

```r
fit2_resid_plot <-
  ggplot(florida, aes(x = pred, y = resid)) +
  geom_ref_line(h = 0) +
  geom_point() +
  labs(x = "Fitted values", y = "residuals")
fit2_resid_plot
```

<img src="prediction_files/figure-html/unnamed-chunk-67-1.png" width="70%" style="display: block; margin: auto;" />
Note, we use the function [geom_refline](https://www.rdocumentation.org/packages/modelr/topics/geom_refline) to add a reference line at 0.

Let's add some labels to points, who is that outlier?

```r
fit2_resid_plot +
  geom_label(aes(label = county))
```

<img src="prediction_files/figure-html/unnamed-chunk-68-1.png" width="70%" style="display: block; margin: auto;" />

The outlier county is "Palm Beach"

```r
arrange(florida) %>%
  arrange(desc(abs(resid))) %>%
  select(county, resid) %>%
  head()
#>       county resid
#> 1  PalmBeach  2302
#> 2    Broward  -613
#> 3        Lee  -357
#> 4    Brevard  -338
#> 5 Miami-Dade  -329
#> 6   Pinellas  -317
```

Data without Palm Beach

```r
florida_pb <- filter(florida, county != "PalmBeach")
fit3 <- lm(Buchanan00 ~ Perot96, data = florida_pb)
fit3
#> 
#> Call:
#> lm(formula = Buchanan00 ~ Perot96, data = florida_pb)
#> 
#> Coefficients:
#> (Intercept)      Perot96  
#>     45.8419       0.0244
```

$R^2$ or coefficient of determination

```r
glance(fit3)
#>   r.squared adj.r.squared sigma statistic  p.value df logLik AIC BIC
#> 1     0.851         0.849  87.7       366 3.61e-28  2   -388 782 788
#>   deviance df.residual
#> 1   492803          64
```


```r
florida_pb %>%
  add_residuals(fit3) %>%
  add_predictions(fit3) %>%
  ggplot(aes(x = pred, y = resid)) +
  geom_ref_line(h = 0) +
  geom_point() +
  ylim(-750, 2500) +
  xlim(0, 1500) +
  labs(x = "Fitted values", y = "residuals")
```

<img src="prediction_files/figure-html/unnamed-chunk-72-1.png" width="70%" style="display: block; margin: auto;" />

Create predictions for both models using [data_grid](https://www.rdocumentation.org/packages/modelr/topics/data_grid) and [gather_predictions](https://www.rdocumentation.org/packages/modelr/topics/gather_predictions):

```r
florida_grid <-
  florida %>%
  data_grid(Perot96) %>%
  gather_predictions(fit2, fit3) %>%
  mutate(model =
           fct_recode(model,
                      "Regression\n with Palm Beach" = "fit2",
                      "Regression\n without Palm Beach" = "fit3"))
```
Note this is an example of using non-syntactic column names in a tibble, as discussed in Chapter 10 of [R for data science](http://r4ds.had.co.nz/tibbles.html).


```r
ggplot() +
  geom_point(data = florida, mapping = aes(x = Perot96, y = Buchanan00)) +
  geom_line(data = florida_grid,
             mapping = aes(x = Perot96, y = pred,
                           colour = model)) +
  geom_label(data = filter(florida, county == "PalmBeach"),
             mapping = aes(x = Perot96, y = Buchanan00, label = county),
                           vjust = "top", hjust = "right") +
  geom_text(data = tibble(label = unique(florida_grid$model),
                           x = c(20000, 31000),
                           y = c(1000, 300)),
             mapping = aes(x = x, y = y, label = label, colour = label)) +
  labs(x = "Perot's Vote in 1996", y = "Buchanan's Votes in 1996") +
  theme(legend.position = "none")
```

<img src="prediction_files/figure-html/unnamed-chunk-74-1.png" width="70%" style="display: block; margin: auto;" />
See [Graphics for communication](http://r4ds.had.co.nz/graphics-for-communication.html#label) in *R for Data Science* on labels and annotations in plots.



## Regression and Causation


### Randomized Experiments

Load data

```r
data("women", package = "qss")
```

proportion of female politicians in reserved GP vs. unreserved GP

```r
women %>%
  group_by(reserved) %>%
  summarise(prop_female = mean(female))
#> # A tibble: 2 x 2
#>   reserved prop_female
#>      <int>       <dbl>
#> 1        0      0.0748
#> 2        1      1.00
```

The diff in diff estimator

```r
# drinking water facilities

# irrigation facilities
mean(women$irrigation[women$reserved == 1]) -
    mean(women$irrigation[women$reserved == 0])
#> [1] -0.369
```

Mean values of `irrigation` and `water` in reserved and non-reserved districts.

```r
women %>%
  group_by(reserved) %>%
  summarise(irrigation = mean(irrigation),
            water = mean(water))
#> # A tibble: 2 x 3
#>   reserved irrigation water
#>      <int>      <dbl> <dbl>
#> 1        0       3.39  14.7
#> 2        1       3.02  24.0
```

The difference between the two groups can be calculated with the function [diff](https://www.rdocumentation.org/packages/base/topics/diff), which calculates the difference between subsequent observations.
This works as long as we are careful about which group is first or second.

```r
women %>%
  group_by(reserved) %>%
  summarise(irrigation = mean(irrigation),
            water = mean(water)) %>%
  summarise(diff_irrigation = diff(irrigation),
            diff_water = diff(water))
#> # A tibble: 1 x 2
#>   diff_irrigation diff_water
#>             <dbl>      <dbl>
#> 1          -0.369       9.25
```

The other way uses **tidyr** [spread](https://www.rdocumentation.org/packages/tidyr/topics/spread.lm) and [gather](https://www.rdocumentation.org/packages/tidyr/topics/gather.lm),

```r
women %>%
  group_by(reserved) %>%
  summarise(irrigation = mean(irrigation),
            water = mean(water)) %>%
  gather(variable, value, -reserved) %>%
  spread(reserved, value) %>%
  mutate(diff = `1` - `0`)
#> # A tibble: 2 x 4
#>   variable     `0`   `1`   diff
#>   <chr>      <dbl> <dbl>  <dbl>
#> 1 irrigation  3.39  3.02 -0.369
#> 2 water      14.7  24.0   9.25
```
Now each row is an outcome variable of interest, and there are columns for the treatment (`1`) and control (`0`) groups, and the difference (`diff`).


```r
lm(water ~ reserved, data = women)
#> 
#> Call:
#> lm(formula = water ~ reserved, data = women)
#> 
#> Coefficients:
#> (Intercept)     reserved  
#>       14.74         9.25
```

```r
lm(irrigation ~ reserved, data = women)
#> 
#> Call:
#> lm(formula = irrigation ~ reserved, data = women)
#> 
#> Coefficients:
#> (Intercept)     reserved  
#>       3.388       -0.369
```

### Regression with multiple predictors


```r
data("social", package = "qss")
glimpse(social)
#> Observations: 305,866
#> Variables: 6
#> $ sex         <chr> "male", "female", "male", "female", "female", "mal...
#> $ yearofbirth <int> 1941, 1947, 1951, 1950, 1982, 1981, 1959, 1956, 19...
#> $ primary2004 <int> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 1, 0,...
#> $ messages    <chr> "Civic Duty", "Civic Duty", "Hawthorne", "Hawthorn...
#> $ primary2006 <int> 0, 0, 1, 1, 1, 0, 1, 1, 0, 0, 1, 0, 1, 0, 1, 1, 1,...
#> $ hhsize      <int> 2, 2, 3, 3, 3, 3, 3, 3, 2, 2, 1, 2, 2, 1, 2, 2, 1,...
levels(social$messages)
#> NULL
fit <- lm(primary2006 ~ messages, data = social)
fit
#> 
#> Call:
#> lm(formula = primary2006 ~ messages, data = social)
#> 
#> Coefficients:
#>       (Intercept)    messagesControl  messagesHawthorne  
#>           0.31454           -0.01790            0.00784  
#> messagesNeighbors  
#>           0.06341
```

Create indicator variables for each message:

```r
social <-
  social %>%
  mutate(Control = as.integer(messages == "Control"),
         Hawthorne = as.integer(messages == "Hawthorne"),
         Neighbors = as.integer(messages == "Neighbors"))
```
alternatively, create these using a for loop.
This is easier to understand and less prone to typos:

```r
for (i in unique(social$messages)) {
  social[[i]] <- as.integer(social[["messages"]] == i)
}
```
We created a variable for each level of `messages` even though we will exclude one of them.

```r
lm(primary2006 ~ Control + Hawthorne + Neighbors, data = social)
#> 
#> Call:
#> lm(formula = primary2006 ~ Control + Hawthorne + Neighbors, data = social)
#> 
#> Coefficients:
#> (Intercept)      Control    Hawthorne    Neighbors  
#>     0.31454     -0.01790      0.00784      0.06341
```

Create predictions for each unique value of `messages`

```r
unique_messages <-
  data_grid(social, messages) %>%
  add_predictions(fit)
unique_messages
#> # A tibble: 4 x 2
#>   messages    pred
#>   <chr>      <dbl>
#> 1 Civic Duty 0.315
#> 2 Control    0.297
#> 3 Hawthorne  0.322
#> 4 Neighbors  0.378
```

Compare to the sample averages

```r
social %>%
  group_by(messages) %>%
  summarise(mean(primary2006))
#> # A tibble: 4 x 2
#>   messages   `mean(primary2006)`
#>   <chr>                    <dbl>
#> 1 Civic Duty               0.315
#> 2 Control                  0.297
#> 3 Hawthorne                0.322
#> 4 Neighbors                0.378
```

Linear regression without intercept.

```r
fit.noint <- lm(primary2006 ~ -1 + messages, data = social)
fit.noint
#> 
#> Call:
#> lm(formula = primary2006 ~ -1 + messages, data = social)
#> 
#> Coefficients:
#> messagesCivic Duty     messagesControl   messagesHawthorne  
#>              0.315               0.297               0.322  
#>  messagesNeighbors  
#>              0.378
```

Calculating the regression average effect is also easier if we make the control group the first level so all regression coefficients are comparisons to it.
Use [fct_relevel](https://www.rdocumentation.org/packages/forcats/topics/fct_relevel) to make "Control"

```r
fit.control <-
 mutate(social, messages = fct_relevel(messages, "Control")) %>%
 lm(primary2006 ~ messages, data = .)
fit.control
#> 
#> Call:
#> lm(formula = primary2006 ~ messages, data = .)
#> 
#> Coefficients:
#>        (Intercept)  messagesCivic Duty   messagesHawthorne  
#>             0.2966              0.0179              0.0257  
#>  messagesNeighbors  
#>             0.0813
```

Difference in means

```r
social %>%
  group_by(messages) %>%
  summarise(primary2006 = mean(primary2006)) %>%
  mutate(Control = primary2006[messages == "Control"],
         diff = primary2006 - Control)
#> # A tibble: 4 x 4
#>   messages   primary2006 Control   diff
#>   <chr>            <dbl>   <dbl>  <dbl>
#> 1 Civic Duty       0.315   0.297 0.0179
#> 2 Control          0.297   0.297 0     
#> 3 Hawthorne        0.322   0.297 0.0257
#> 4 Neighbors        0.378   0.297 0.0813
```

Adjusted R-squared is included in the output of `broom::glance()`

```r
glance(fit)
#>   r.squared adj.r.squared sigma statistic   p.value df  logLik    AIC
#> 1   0.00328       0.00327 0.463       336 1.06e-217  4 -198247 396504
#>      BIC deviance df.residual
#> 1 396557    65468      305862
glance(fit)[["adj.r.squared"]]
#> [1] 0.00327
```


### Heterogeneous Treatment Effects

Average treatment effect (ate) among those who voted in 2004 primary

```r
ate <-
  social %>%
  group_by(primary2004, messages) %>%
  summarise(primary2006 = mean(primary2006)) %>%
  spread(messages, primary2006) %>%
  mutate(ate_Neighbors = Neighbors - Control) %>%
  select(primary2004, Neighbors, Control, ate_Neighbors)
ate
#> # A tibble: 2 x 4
#> # Groups: primary2004 [2]
#>   primary2004 Neighbors Control ate_Neighbors
#>         <int>     <dbl>   <dbl>         <dbl>
#> 1           0     0.306   0.237        0.0693
#> 2           1     0.482   0.386        0.0965
```
Difference in ATE in 2004 voters and non-voters

```r
diff(ate$ate_Neighbors)
#> [1] 0.0272
```



```r
social.neighbor <- social %>%
  filter( (messages == "Control") | (messages == "Neighbors"))

fit.int <- lm(primary2006 ~ primary2004 + messages + primary2004:messages,
              data = social.neighbor)
fit.int
#> 
#> Call:
#> lm(formula = primary2006 ~ primary2004 + messages + primary2004:messages, 
#>     data = social.neighbor)
#> 
#> Coefficients:
#>                   (Intercept)                    primary2004  
#>                        0.2371                         0.1487  
#>             messagesNeighbors  primary2004:messagesNeighbors  
#>                        0.0693                         0.0272
```


```r
lm(primary2006 ~ primary2004 * messages, data = social.neighbor)
#> 
#> Call:
#> lm(formula = primary2006 ~ primary2004 * messages, data = social.neighbor)
#> 
#> Coefficients:
#>                   (Intercept)                    primary2004  
#>                        0.2371                         0.1487  
#>             messagesNeighbors  primary2004:messagesNeighbors  
#>                        0.0693                         0.0272
```


```r
social.neighbor <-
  social.neighbor %>%
  mutate(age = 2008 - yearofbirth)

summary(social.neighbor$age)
#>    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
#>    22.0    43.0    52.0    51.8    61.0   108.0

fit.age <- lm(primary2006 ~ age * messages, data = social.neighbor)
fit.age
#> 
#> Call:
#> lm(formula = primary2006 ~ age * messages, data = social.neighbor)
#> 
#> Coefficients:
#>           (Intercept)                    age      messagesNeighbors  
#>              0.089477               0.003998               0.048573  
#> age:messagesNeighbors  
#>              0.000628
```

Calculate average treatment effects

```r
ate.age <-
  crossing(age = seq(from = 25, to = 85, by = 20),
         messages = c("Neighbors", "Control")) %>%
  add_predictions(fit.age) %>%
  spread(messages, pred) %>%
  mutate(diff = Neighbors - Control)
ate.age
#> # A tibble: 4 x 4
#>     age Control Neighbors   diff
#>   <dbl>   <dbl>     <dbl>  <dbl>
#> 1  25.0   0.189     0.254 0.0643
#> 2  45.0   0.269     0.346 0.0768
#> 3  65.0   0.349     0.439 0.0894
#> 4  85.0   0.429     0.531 0.102
```

You can use [poly](https://www.rdocumentation.org/packages/base/topics/poly) function to calculate polynomials instead of adding each term, `age + I(age ^ 2)`.
Though note that the coefficients will be be different since by default `poly` calculates orthogonal polynomials instead of the natural (raw) polynomials.
However, you really shouldn't interpret the coefficients directly anyways, so this should matter.

```r
fit.age2 <- lm(primary2006 ~ poly(age, 2) * messages,
               data = social.neighbor)
fit.age2
#> 
#> Call:
#> lm(formula = primary2006 ~ poly(age, 2) * messages, data = social.neighbor)
#> 
#> Coefficients:
#>                     (Intercept)                    poly(age, 2)1  
#>                          0.2966                          27.6665  
#>                   poly(age, 2)2                messagesNeighbors  
#>                        -10.2832                           0.0816  
#> poly(age, 2)1:messagesNeighbors  poly(age, 2)2:messagesNeighbors  
#>                          4.5820                          -5.5124
```

Create a data frame of combinations of ages and messages using [data_grid](https://www.rdocumentation.org/packages/modelr/topics/data_grid), which means that we only need to specify the variables, and not the specific values,

```r
y.hat <-
  data_grid(social.neighbor, age, messages) %>%
  add_predictions(fit.age2)
```


```r
ggplot(y.hat, aes(x = age, y = pred,
                  colour = str_c(messages, " condition"))) +
  geom_line() +
  labs(colour = "", y = "Predicted turnout rates") +
  theme(legend.position = "bottom")
```

<img src="prediction_files/figure-html/unnamed-chunk-101-1.png" width="70%" style="display: block; margin: auto;" />


```r
y.hat %>%
  spread(messages, pred) %>%
  mutate(ate = Neighbors - Control) %>%
  filter(age > 20, age < 90) %>%
  ggplot(aes(x = age, y = ate)) +
  geom_line() +
  labs(y = "Estimated average treatment effect",
       x = "Age") +
  ylim(0, 0.1)
```

<img src="prediction_files/figure-html/unnamed-chunk-102-1.png" width="70%" style="display: block; margin: auto;" />


### Regression Discontinuity Design


```r
data("MPs", package = "qss")

MPs_labour <- filter(MPs, party == "labour")
MPs_tory <- filter(MPs, party == "tory")

labour_fit1 <- lm(ln.net ~ margin,
                 data = filter(MPs_labour, margin < 0))
labour_fit2 <- lm(ln.net ~ margin, MPs_labour, margin > 0)

tory_fit1 <- lm(ln.net ~ margin,
                data = filter(MPs_tory, margin < 0))
tory_fit2 <- lm(ln.net ~ margin, data = filter(MPs_tory, margin > 0))
```

Use  to generate a grid for predictions.

```r
y1_labour <-
  filter(MPs_labour, margin < 0) %>%
  data_grid(margin) %>%
  add_predictions(labour_fit1)
y2_labour <-
  filter(MPs_labour, margin > 0) %>%
  data_grid(margin) %>%
  add_predictions(labour_fit2)

y1_tory <-
  filter(MPs_tory, margin < 0) %>%
  data_grid(margin) %>%
  add_predictions(tory_fit1)

y2_tory <-
  filter(MPs_tory, margin > 0) %>%
  data_grid(margin) %>%
  add_predictions(tory_fit2)
```

Tory politicians

```r
ggplot() +
  geom_ref_line(v = 0) +
  geom_point(data = MPs_tory,
             mapping = aes(x = margin, y = ln.net)) +
  geom_line(data = y1_tory,
            mapping = aes(x = margin, y = pred), colour = "red", size = 1.5) +
  geom_line(data = y2_tory,
            mapping = aes(x = margin, y = pred), colour = "red", size = 1.5) +
  labs(x = "margin of victory", y = "log net wealth at death",
       title = "labour")
```

<img src="prediction_files/figure-html/unnamed-chunk-105-1.png" width="70%" style="display: block; margin: auto;" />

We can actually produce this plot easily without running the regressions, by using `geom_smooth`:


```r
ggplot(mutate(MPs, winner = (margin > 0)),
       aes(x = margin, y = ln.net)) +
  geom_ref_line(v = 0) +
  geom_point() +
  geom_smooth(method = lm, se = FALSE, mapping = aes(group = winner)) +
  facet_grid(party ~ .) +
  labs(x = "margin of victory", y = "log net wealth at death")
```

<img src="prediction_files/figure-html/unnamed-chunk-106-1.png" width="70%" style="display: block; margin: auto;" />

In the previous code, I didn't directly compute the the average net wealth at 0, so I'll need to do that here.
I'll use [gather_predictions](https://www.rdocumentation.org/packages/modelr/topics/gather_predictions) to add predictions for multiple models:

```r
spread_predictions(data_frame(margin = 0),
                   tory_fit1, tory_fit2) %>%
  mutate(rd_est = tory_fit2 - tory_fit1)
#> # A tibble: 1 x 4
#>   margin tory_fit1 tory_fit2 rd_est
#>    <dbl>     <dbl>     <dbl>  <dbl>
#> 1      0      12.5      13.2  0.650
```



```r
tory_fit3 <- lm(margin.pre ~ margin, data = filter(MPs_tory, margin < 0))
tory_fit4 <- lm(margin.pre ~ margin, data = filter(MPs_tory, margin > 0))

(filter(tidy(tory_fit3), term == "(Intercept)")[["estimate"]] -
 filter(tidy(tory_fit4), term == "(Intercept)")[["estimate"]])
#> [1] 0.0173
```
