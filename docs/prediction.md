
---
output: html_document
editor_options:
  chunk_output_type: console
---
# Prediction

## Prerequisites


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

## Loops in R

For more on looping and iteration in R see the *R for Data Science* chapter [Iteration](http://r4ds.had.co.nz/data-visualisation.html).

RStudio provides many features to help debugging, which will be useful in
for loops and function: see  [this](https://support.rstudio.com/hc/en-us/articles/205612627-Debugging-with-RStudio) article for an example.

## General Conditional Statements in R

See the *R for Data Science* section [Conditional Execution](http://r4ds.had.co.nz/functions.html#conditional-execution) for a more complete discussion of conditional execution.

If you are using conditional statements to assign values for data frame,
see the **dplyr** functions [if_else](https://www.rdocumentation.org/packages/dplyr/topics/if_else), [recode](https://www.rdocumentation.org/packages/dplyr/topics/recode), and [case_when](https://www.rdocumentation.org/packages/dplyr/topics/case_when)


## Poll Predictions

Load the election polls and election results for 2008,

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
polls08 <-
  mutate(polls08, ELECTION_DAY - middate)
```

Although the code in the chapter uses a `for` loop, there is no reason to do so.
We can accomplish the same task by merging the election results data to the polling data by `state`.


```r
polls_w_results <-
  left_join(polls08,
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
#> # Groups:   state [51]
#>   state        Pollster Obama McCain    middate margin
#>   <chr>           <chr> <int>  <int>     <date>  <int>
#> 1    AK Research 2000-3    39     58 2008-10-29    -19
#> 2    AL     SurveyUSA-2    36     61 2008-10-27    -25
#> 3    AR           ARG-4    44     51 2008-10-29     -7
#> 4    AZ           ARG-3    46     50 2008-10-29     -4
#> 5    CA     SurveyUSA-3    60     36 2008-10-30     24
#> 6    CO           ARG-3    52     45 2008-10-29      7
#> # ... with 45 more rows, and 3 more variables: `ELECTION_DAY -
#> #   middate` <time>, elec_margin <int>, error <int>
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

<img src="prediction_files/figure-html/unnamed-chunk-14-1.png" width="70%" style="display: block; margin: auto;" />

The text uses bin widths of 5%:

```r
ggplot(last_polls, aes(x = error)) +
  geom_histogram(binwidth = 5, boundary = 0)
```

<img src="prediction_files/figure-html/unnamed-chunk-15-1.png" width="70%" style="display: block; margin: auto;" />

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

<img src="prediction_files/figure-html/unnamed-chunk-16-1.png" width="70%" style="display: block; margin: auto;" />

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
#> # Groups:   classification [4]
#>   classification     n
#>            <chr> <int>
#> 1 false negative     2
#> 2 false positive     1
#> 3  true negative    21
#> 4  true positive    27
```

Which states were incorrectly predicted by the polls?

```r
last_polls %>%
  filter(classification %in% c("false positive", "false negative")) %>%
  select(state, margin, elec_margin, classification) %>%
  arrange(desc(elec_margin))
#> # A tibble: 3 x 4
#>   state margin elec_margin classification
#>   <chr>  <int>       <int>          <chr>
#> 1    IN     -5           1 false negative
#> 2    NC     -1           1 false negative
#> 3    MO      1          -1 false positive
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

```r
all_dates <- seq(min(polls08$middate), ELECTION_DAY,
                 by = "days")

# Number of poll days to use
POLL_DAYS <- 7

pop_vote_avg <- vector(length(all_dates), mode = "list")
for (i in seq_along(all_dates)) {
  date <- all_dates[i]
  # summarise the seven day
  week_data <-
     pollsUS08 %>%
     filter(as.integer(middate - date) <= 0,
            as.integer(middate - date) > -POLL_DAYS) %>%
     summarise(Obama = mean(Obama, na.rm = TRUE),
               McCain = mean(McCain, na.rm = TRUE))
  # add date for the observation
  week_data$date <- date
  pop_vote_avg[[i]] <- week_data
}

pop_vote_avg <- bind_rows(pop_vote_avg)
```

It is easier to plot this if the data are tidy, with `Obama` and `McCain` as categories of a column `candidate`.

```r
pop_vote_avg_tidy <-
  pop_vote_avg %>%
  gather(candidate, share, -date, na.rm = TRUE)
pop_vote_avg_tidy
#>           date candidate share
#> 9   2008-01-09     Obama  49.0
#> 10  2008-01-10     Obama  46.0
#> 11  2008-01-11     Obama  45.0
#> 12  2008-01-12     Obama  45.0
#> 13  2008-01-13     Obama  45.0
#> 14  2008-01-14     Obama  45.0
#> 15  2008-01-15     Obama  45.0
#> 16  2008-01-16     Obama  44.6
#> 17  2008-01-17     Obama  45.4
#> 18  2008-01-18     Obama  46.0
#> 19  2008-01-19     Obama  47.0
#> 20  2008-01-20     Obama  45.0
#> 21  2008-01-21     Obama  44.2
#> 22  2008-01-22     Obama  44.2
#> 23  2008-01-23     Obama  43.3
#> 24  2008-01-24     Obama  41.5
#> 25  2008-01-25     Obama  41.5
#> 26  2008-01-26     Obama  41.5
#> 27  2008-01-27     Obama  42.0
#> 30  2008-01-30     Obama  46.0
#> 31  2008-01-31     Obama  46.0
#> 32  2008-02-01     Obama  45.8
#> 33  2008-02-02     Obama  47.0
#> 34  2008-02-03     Obama  47.2
#> 35  2008-02-04     Obama  46.7
#> 36  2008-02-05     Obama  46.6
#> 37  2008-02-06     Obama  47.0
#> 38  2008-02-07     Obama  47.0
#> 39  2008-02-08     Obama  47.5
#> 40  2008-02-09     Obama  46.1
#> 41  2008-02-10     Obama  45.8
#> 42  2008-02-11     Obama  46.7
#> 43  2008-02-12     Obama  46.8
#> 44  2008-02-13     Obama  46.7
#> 45  2008-02-14     Obama  46.7
#> 46  2008-02-15     Obama  46.6
#> 47  2008-02-16     Obama  47.2
#> 48  2008-02-17     Obama  47.0
#> 49  2008-02-18     Obama  46.6
#> 50  2008-02-19     Obama  46.4
#> 51  2008-02-20     Obama  47.0
#> 52  2008-02-21     Obama  46.5
#> 53  2008-02-22     Obama  47.4
#> 54  2008-02-23     Obama  47.1
#> 55  2008-02-24     Obama  47.2
#> 56  2008-02-25     Obama  46.6
#> 57  2008-02-26     Obama  46.7
#> 58  2008-02-27     Obama  46.3
#> 59  2008-02-28     Obama  46.8
#> 60  2008-02-29     Obama  45.3
#> 61  2008-03-01     Obama  44.8
#> 62  2008-03-02     Obama  44.8
#> 63  2008-03-03     Obama  45.0
#> 64  2008-03-04     Obama  45.0
#> 65  2008-03-05     Obama  45.2
#> 66  2008-03-06     Obama  45.2
#> 67  2008-03-07     Obama  45.8
#> 68  2008-03-08     Obama  44.6
#> 69  2008-03-09     Obama  45.1
#> 70  2008-03-10     Obama  45.1
#> 71  2008-03-11     Obama  45.2
#> 72  2008-03-12     Obama  44.8
#> 73  2008-03-13     Obama  44.0
#> 74  2008-03-14     Obama  44.0
#> 75  2008-03-15     Obama  45.3
#> 76  2008-03-16     Obama  44.3
#> 77  2008-03-17     Obama  44.9
#> 78  2008-03-18     Obama  44.6
#> 79  2008-03-19     Obama  44.0
#> 80  2008-03-20     Obama  44.1
#> 81  2008-03-21     Obama  44.8
#> 82  2008-03-22     Obama  44.0
#> 83  2008-03-23     Obama  43.9
#> 84  2008-03-24     Obama  43.2
#> 85  2008-03-25     Obama  43.1
#> 86  2008-03-26     Obama  43.6
#> 87  2008-03-27     Obama  43.5
#> 88  2008-03-28     Obama  42.7
#> 89  2008-03-29     Obama  42.7
#> 90  2008-03-30     Obama  43.5
#> 91  2008-03-31     Obama  43.6
#> 92  2008-04-01     Obama  43.5
#> 93  2008-04-02     Obama  43.3
#> 94  2008-04-03     Obama  44.0
#> 95  2008-04-04     Obama  44.2
#> 96  2008-04-05     Obama  44.3
#> 97  2008-04-06     Obama  43.5
#> 98  2008-04-07     Obama  43.6
#> 99  2008-04-08     Obama  42.7
#> 100 2008-04-09     Obama  43.2
#> 101 2008-04-10     Obama  43.2
#> 102 2008-04-11     Obama  43.0
#> 103 2008-04-12     Obama  42.8
#> 104 2008-04-13     Obama  42.8
#> 105 2008-04-14     Obama  43.0
#> 106 2008-04-15     Obama  43.9
#> 107 2008-04-16     Obama  44.7
#> 108 2008-04-17     Obama  44.2
#> 109 2008-04-18     Obama  44.6
#> 110 2008-04-19     Obama  45.1
#> 111 2008-04-20     Obama  45.2
#> 112 2008-04-21     Obama  44.7
#> 113 2008-04-22     Obama  45.0
#> 114 2008-04-23     Obama  44.2
#> 115 2008-04-24     Obama  45.0
#> 116 2008-04-25     Obama  45.7
#> 117 2008-04-26     Obama  45.2
#> 118 2008-04-27     Obama  45.4
#> 119 2008-04-28     Obama  45.7
#> 120 2008-04-29     Obama  45.4
#> 121 2008-04-30     Obama  45.4
#> 122 2008-05-01     Obama  45.1
#> 123 2008-05-02     Obama  45.3
#> 124 2008-05-03     Obama  45.3
#> 125 2008-05-04     Obama  45.4
#> 126 2008-05-05     Obama  45.1
#> 127 2008-05-06     Obama  45.2
#> 128 2008-05-07     Obama  45.4
#> 129 2008-05-08     Obama  45.7
#> 130 2008-05-09     Obama  45.1
#> 131 2008-05-10     Obama  46.4
#> 132 2008-05-11     Obama  46.5
#> 133 2008-05-12     Obama  47.8
#> 134 2008-05-13     Obama  47.9
#> 135 2008-05-14     Obama  46.0
#> 136 2008-05-15     Obama  46.0
#> 137 2008-05-16     Obama  45.7
#> 138 2008-05-17     Obama  45.3
#> 139 2008-05-18     Obama  45.1
#> 140 2008-05-19     Obama  45.2
#> 141 2008-05-20     Obama  44.0
#> 142 2008-05-21     Obama  45.7
#> 143 2008-05-22     Obama  45.6
#> 144 2008-05-23     Obama  45.8
#> 145 2008-05-24     Obama  45.4
#> 146 2008-05-25     Obama  45.4
#> 147 2008-05-26     Obama  45.3
#> 148 2008-05-27     Obama  44.1
#> 149 2008-05-28     Obama  43.9
#> 150 2008-05-29     Obama  43.9
#> 151 2008-05-30     Obama  43.2
#> 152 2008-05-31     Obama  44.0
#> 153 2008-06-01     Obama  44.5
#> 154 2008-06-02     Obama  44.5
#> 155 2008-06-03     Obama  46.5
#> 156 2008-06-04     Obama  46.8
#> 157 2008-06-05     Obama  46.3
#> 158 2008-06-06     Obama  47.1
#> 159 2008-06-07     Obama  46.9
#> 160 2008-06-08     Obama  47.2
#> 161 2008-06-09     Obama  46.9
#> 162 2008-06-10     Obama  46.1
#> 163 2008-06-11     Obama  45.8
#> 164 2008-06-12     Obama  46.4
#> 165 2008-06-13     Obama  46.2
#> 166 2008-06-14     Obama  46.0
#> 167 2008-06-15     Obama  45.3
#> 168 2008-06-16     Obama  44.4
#> 169 2008-06-17     Obama  45.4
#> 170 2008-06-18     Obama  45.4
#> 171 2008-06-19     Obama  44.5
#> 172 2008-06-20     Obama  44.2
#> 173 2008-06-21     Obama  44.9
#> 174 2008-06-22     Obama  44.9
#> 175 2008-06-23     Obama  45.6
#> 176 2008-06-24     Obama  45.4
#> 177 2008-06-25     Obama  45.4
#> 178 2008-06-26     Obama  46.3
#> 179 2008-06-27     Obama  46.6
#> 180 2008-06-28     Obama  46.5
#> 181 2008-06-29     Obama  46.4
#> 182 2008-06-30     Obama  46.7
#> 183 2008-07-01     Obama  46.4
#> 184 2008-07-02     Obama  46.4
#> 185 2008-07-03     Obama  46.4
#> 186 2008-07-04     Obama  46.4
#> 187 2008-07-05     Obama  45.8
#> 188 2008-07-06     Obama  45.8
#> 189 2008-07-07     Obama  45.0
#> 190 2008-07-08     Obama  45.2
#> 191 2008-07-09     Obama  44.6
#> 192 2008-07-10     Obama  45.2
#> 193 2008-07-11     Obama  45.1
#> 194 2008-07-12     Obama  45.1
#> 195 2008-07-13     Obama  45.1
#> 196 2008-07-14     Obama  45.3
#> 197 2008-07-15     Obama  45.9
#> 198 2008-07-16     Obama  46.1
#> 199 2008-07-17     Obama  45.5
#> 200 2008-07-18     Obama  45.5
#> 201 2008-07-19     Obama  45.2
#> 202 2008-07-20     Obama  45.4
#> 203 2008-07-21     Obama  45.4
#> 204 2008-07-22     Obama  44.6
#> 205 2008-07-23     Obama  45.3
#> 206 2008-07-24     Obama  45.8
#> 207 2008-07-25     Obama  45.8
#> 208 2008-07-26     Obama  46.3
#> 209 2008-07-27     Obama  46.5
#> 210 2008-07-28     Obama  46.6
#> 211 2008-07-29     Obama  47.0
#> 212 2008-07-30     Obama  47.4
#> 213 2008-07-31     Obama  46.6
#> 214 2008-08-01     Obama  46.4
#> 215 2008-08-02     Obama  45.2
#> 216 2008-08-03     Obama  45.0
#> 217 2008-08-04     Obama  44.8
#> 218 2008-08-05     Obama  44.8
#> 219 2008-08-06     Obama  44.5
#> 220 2008-08-07     Obama  45.0
#> 221 2008-08-08     Obama  45.2
#> 222 2008-08-09     Obama  45.8
#> 223 2008-08-10     Obama  45.9
#> 224 2008-08-11     Obama  46.0
#> 225 2008-08-12     Obama  45.7
#> 226 2008-08-13     Obama  45.6
#> 227 2008-08-14     Obama  45.7
#> 228 2008-08-15     Obama  44.9
#> 229 2008-08-16     Obama  45.0
#> 230 2008-08-17     Obama  45.0
#> 231 2008-08-18     Obama  44.8
#> 232 2008-08-19     Obama  44.3
#> 233 2008-08-20     Obama  44.6
#> 234 2008-08-21     Obama  44.2
#> 235 2008-08-22     Obama  44.5
#> 236 2008-08-23     Obama  45.0
#> 237 2008-08-24     Obama  44.8
#> 238 2008-08-25     Obama  44.5
#> 239 2008-08-26     Obama  45.6
#> 240 2008-08-27     Obama  45.4
#> 241 2008-08-28     Obama  46.0
#> 242 2008-08-29     Obama  46.3
#> 243 2008-08-30     Obama  46.8
#> 244 2008-08-31     Obama  46.8
#> 245 2008-09-01     Obama  47.5
#> 246 2008-09-02     Obama  46.9
#> 247 2008-09-03     Obama  46.9
#> 248 2008-09-04     Obama  46.7
#> 249 2008-09-05     Obama  46.5
#> 250 2008-09-06     Obama  46.1
#> 251 2008-09-07     Obama  45.7
#> 252 2008-09-08     Obama  45.2
#> 253 2008-09-09     Obama  45.4
#> 254 2008-09-10     Obama  45.0
#> 255 2008-09-11     Obama  45.0
#> 256 2008-09-12     Obama  45.2
#> 257 2008-09-13     Obama  45.3
#> 258 2008-09-14     Obama  45.5
#> 259 2008-09-15     Obama  46.0
#> 260 2008-09-16     Obama  45.9
#> 261 2008-09-17     Obama  46.4
#> 262 2008-09-18     Obama  46.8
#> 263 2008-09-19     Obama  46.8
#> 264 2008-09-20     Obama  46.9
#> 265 2008-09-21     Obama  47.5
#> 266 2008-09-22     Obama  47.6
#> 267 2008-09-23     Obama  47.5
#> 268 2008-09-24     Obama  47.5
#> 269 2008-09-25     Obama  47.5
#> 270 2008-09-26     Obama  47.6
#> 271 2008-09-27     Obama  47.9
#> 272 2008-09-28     Obama  47.8
#> 273 2008-09-29     Obama  48.0
#> 274 2008-09-30     Obama  48.6
#> 275 2008-10-01     Obama  48.8
#> 276 2008-10-02     Obama  48.8
#> 277 2008-10-03     Obama  49.1
#> 278 2008-10-04     Obama  49.1
#> 279 2008-10-05     Obama  49.0
#> 280 2008-10-06     Obama  49.4
#> 281 2008-10-07     Obama  49.2
#> 282 2008-10-08     Obama  48.9
#> 283 2008-10-09     Obama  49.2
#> 284 2008-10-10     Obama  49.3
#> 285 2008-10-11     Obama  49.3
#> 286 2008-10-12     Obama  49.9
#> 287 2008-10-13     Obama  49.8
#> 288 2008-10-14     Obama  49.7
#> 289 2008-10-15     Obama  50.3
#> 290 2008-10-16     Obama  49.9
#> 291 2008-10-17     Obama  49.7
#> 292 2008-10-18     Obama  49.8
#> 293 2008-10-19     Obama  49.4
#> 294 2008-10-20     Obama  49.6
#> 295 2008-10-21     Obama  50.0
#> 296 2008-10-22     Obama  49.9
#> 297 2008-10-23     Obama  50.0
#> 298 2008-10-24     Obama  50.2
#> 299 2008-10-25     Obama  50.3
#> 300 2008-10-26     Obama  50.4
#> 301 2008-10-27     Obama  50.4
#> 302 2008-10-28     Obama  50.2
#> 303 2008-10-29     Obama  50.1
#> 304 2008-10-30     Obama  50.1
#> 305 2008-10-31     Obama  50.4
#> 306 2008-11-01     Obama  50.6
#> 307 2008-11-02     Obama  51.0
#> 308 2008-11-03     Obama  51.1
#> 309 2008-11-04     Obama  51.3
#> 318 2008-01-09    McCain  48.0
#> 319 2008-01-10    McCain  46.5
#> 320 2008-01-11    McCain  45.0
#> 321 2008-01-12    McCain  45.4
#> 322 2008-01-13    McCain  45.4
#> 323 2008-01-14    McCain  45.4
#> 324 2008-01-15    McCain  45.4
#> 325 2008-01-16    McCain  43.4
#> 326 2008-01-17    McCain  41.8
#> 327 2008-01-18    McCain  41.8
#> 328 2008-01-19    McCain  37.5
#> 329 2008-01-20    McCain  39.0
#> 330 2008-01-21    McCain  39.8
#> 331 2008-01-22    McCain  39.8
#> 332 2008-01-23    McCain  40.3
#> 333 2008-01-24    McCain  42.0
#> 334 2008-01-25    McCain  42.0
#> 335 2008-01-26    McCain  42.0
#> 336 2008-01-27    McCain  42.0
#> 339 2008-01-30    McCain  46.3
#> 340 2008-01-31    McCain  46.3
#> 341 2008-02-01    McCain  45.5
#> 342 2008-02-02    McCain  45.2
#> 343 2008-02-03    McCain  44.5
#> 344 2008-02-04    McCain  43.6
#> 345 2008-02-05    McCain  43.5
#> 346 2008-02-06    McCain  41.8
#> 347 2008-02-07    McCain  41.8
#> 348 2008-02-08    McCain  41.5
#> 349 2008-02-09    McCain  41.3
#> 350 2008-02-10    McCain  41.3
#> 351 2008-02-11    McCain  41.5
#> 352 2008-02-12    McCain  41.2
#> 353 2008-02-13    McCain  41.5
#> 354 2008-02-14    McCain  41.5
#> 355 2008-02-15    McCain  41.1
#> 356 2008-02-16    McCain  40.4
#> 357 2008-02-17    McCain  40.8
#> 358 2008-02-18    McCain  41.2
#> 359 2008-02-19    McCain  41.9
#> 360 2008-02-20    McCain  42.0
#> 361 2008-02-21    McCain  42.5
#> 362 2008-02-22    McCain  42.6
#> 363 2008-02-23    McCain  43.4
#> 364 2008-02-24    McCain  43.4
#> 365 2008-02-25    McCain  44.0
#> 366 2008-02-26    McCain  44.1
#> 367 2008-02-27    McCain  44.1
#> 368 2008-02-28    McCain  43.9
#> 369 2008-02-29    McCain  45.4
#> 370 2008-03-01    McCain  44.6
#> 371 2008-03-02    McCain  44.6
#> 372 2008-03-03    McCain  43.0
#> 373 2008-03-04    McCain  44.5
#> 374 2008-03-05    McCain  44.6
#> 375 2008-03-06    McCain  44.6
#> 376 2008-03-07    McCain  43.8
#> 377 2008-03-08    McCain  45.4
#> 378 2008-03-09    McCain  45.0
#> 379 2008-03-10    McCain  45.0
#> 380 2008-03-11    McCain  44.6
#> 381 2008-03-12    McCain  44.6
#> 382 2008-03-13    McCain  44.8
#> 383 2008-03-14    McCain  45.0
#> 384 2008-03-15    McCain  45.4
#> 385 2008-03-16    McCain  46.3
#> 386 2008-03-17    McCain  45.9
#> 387 2008-03-18    McCain  45.6
#> 388 2008-03-19    McCain  44.3
#> 389 2008-03-20    McCain  44.7
#> 390 2008-03-21    McCain  44.0
#> 391 2008-03-22    McCain  43.4
#> 392 2008-03-23    McCain  43.0
#> 393 2008-03-24    McCain  44.0
#> 394 2008-03-25    McCain  44.0
#> 395 2008-03-26    McCain  45.8
#> 396 2008-03-27    McCain  44.7
#> 397 2008-03-28    McCain  45.6
#> 398 2008-03-29    McCain  45.6
#> 399 2008-03-30    McCain  45.4
#> 400 2008-03-31    McCain  45.0
#> 401 2008-04-01    McCain  45.5
#> 402 2008-04-02    McCain  44.5
#> 403 2008-04-03    McCain  45.8
#> 404 2008-04-04    McCain  45.4
#> 405 2008-04-05    McCain  45.5
#> 406 2008-04-06    McCain  45.8
#> 407 2008-04-07    McCain  45.4
#> 408 2008-04-08    McCain  43.2
#> 409 2008-04-09    McCain  43.6
#> 410 2008-04-10    McCain  43.6
#> 411 2008-04-11    McCain  42.7
#> 412 2008-04-12    McCain  42.2
#> 413 2008-04-13    McCain  42.6
#> 414 2008-04-14    McCain  42.6
#> 415 2008-04-15    McCain  43.7
#> 416 2008-04-16    McCain  43.9
#> 417 2008-04-17    McCain  44.4
#> 418 2008-04-18    McCain  45.7
#> 419 2008-04-19    McCain  45.3
#> 420 2008-04-20    McCain  44.2
#> 421 2008-04-21    McCain  44.5
#> 422 2008-04-22    McCain  44.5
#> 423 2008-04-23    McCain  44.2
#> 424 2008-04-24    McCain  43.9
#> 425 2008-04-25    McCain  44.0
#> 426 2008-04-26    McCain  43.8
#> 427 2008-04-27    McCain  44.6
#> 428 2008-04-28    McCain  44.4
#> 429 2008-04-29    McCain  44.9
#> 430 2008-04-30    McCain  44.9
#> 431 2008-05-01    McCain  44.6
#> 432 2008-05-02    McCain  44.0
#> 433 2008-05-03    McCain  44.3
#> 434 2008-05-04    McCain  44.5
#> 435 2008-05-05    McCain  44.1
#> 436 2008-05-06    McCain  43.3
#> 437 2008-05-07    McCain  43.4
#> 438 2008-05-08    McCain  43.7
#> 439 2008-05-09    McCain  44.0
#> 440 2008-05-10    McCain  43.1
#> 441 2008-05-11    McCain  43.2
#> 442 2008-05-12    McCain  43.3
#> 443 2008-05-13    McCain  44.1
#> 444 2008-05-14    McCain  43.4
#> 445 2008-05-15    McCain  43.0
#> 446 2008-05-16    McCain  43.0
#> 447 2008-05-17    McCain  42.9
#> 448 2008-05-18    McCain  42.6
#> 449 2008-05-19    McCain  42.9
#> 450 2008-05-20    McCain  41.8
#> 451 2008-05-21    McCain  42.6
#> 452 2008-05-22    McCain  43.2
#> 453 2008-05-23    McCain  44.1
#> 454 2008-05-24    McCain  44.9
#> 455 2008-05-25    McCain  44.9
#> 456 2008-05-26    McCain  45.0
#> 457 2008-05-27    McCain  45.5
#> 458 2008-05-28    McCain  45.4
#> 459 2008-05-29    McCain  45.4
#> 460 2008-05-30    McCain  45.0
#> 461 2008-05-31    McCain  44.7
#> 462 2008-06-01    McCain  44.4
#> 463 2008-06-02    McCain  44.4
#> 464 2008-06-03    McCain  44.2
#> 465 2008-06-04    McCain  44.5
#> 466 2008-06-05    McCain  44.0
#> 467 2008-06-06    McCain  43.8
#> 468 2008-06-07    McCain  43.9
#> 469 2008-06-08    McCain  43.4
#> 470 2008-06-09    McCain  42.5
#> 471 2008-06-10    McCain  41.5
#> 472 2008-06-11    McCain  40.9
#> 473 2008-06-12    McCain  41.2
#> 474 2008-06-13    McCain  41.2
#> 475 2008-06-14    McCain  40.6
#> 476 2008-06-15    McCain  41.0
#> 477 2008-06-16    McCain  40.9
#> 478 2008-06-17    McCain  41.7
#> 479 2008-06-18    McCain  41.1
#> 480 2008-06-19    McCain  40.8
#> 481 2008-06-20    McCain  40.5
#> 482 2008-06-21    McCain  40.6
#> 483 2008-06-22    McCain  40.2
#> 484 2008-06-23    McCain  40.7
#> 485 2008-06-24    McCain  40.9
#> 486 2008-06-25    McCain  41.3
#> 487 2008-06-26    McCain  41.6
#> 488 2008-06-27    McCain  41.7
#> 489 2008-06-28    McCain  41.9
#> 490 2008-06-29    McCain  41.8
#> 491 2008-06-30    McCain  42.0
#> 492 2008-07-01    McCain  41.3
#> 493 2008-07-02    McCain  41.3
#> 494 2008-07-03    McCain  41.3
#> 495 2008-07-04    McCain  41.3
#> 496 2008-07-05    McCain  41.4
#> 497 2008-07-06    McCain  41.4
#> 498 2008-07-07    McCain  40.8
#> 499 2008-07-08    McCain  41.8
#> 500 2008-07-09    McCain  41.4
#> 501 2008-07-10    McCain  41.4
#> 502 2008-07-11    McCain  41.0
#> 503 2008-07-12    McCain  41.3
#> 504 2008-07-13    McCain  41.3
#> 505 2008-07-14    McCain  41.5
#> 506 2008-07-15    McCain  42.2
#> 507 2008-07-16    McCain  41.9
#> 508 2008-07-17    McCain  42.1
#> 509 2008-07-18    McCain  43.3
#> 510 2008-07-19    McCain  42.8
#> 511 2008-07-20    McCain  42.4
#> 512 2008-07-21    McCain  42.6
#> 513 2008-07-22    McCain  41.3
#> 514 2008-07-23    McCain  41.7
#> 515 2008-07-24    McCain  41.7
#> 516 2008-07-25    McCain  41.3
#> 517 2008-07-26    McCain  41.7
#> 518 2008-07-27    McCain  42.1
#> 519 2008-07-28    McCain  41.6
#> 520 2008-07-29    McCain  42.2
#> 521 2008-07-30    McCain  43.0
#> 522 2008-07-31    McCain  42.9
#> 523 2008-08-01    McCain  43.1
#> 524 2008-08-02    McCain  41.5
#> 525 2008-08-03    McCain  41.1
#> 526 2008-08-04    McCain  41.2
#> 527 2008-08-05    McCain  41.3
#> 528 2008-08-06    McCain  40.7
#> 529 2008-08-07    McCain  40.7
#> 530 2008-08-08    McCain  40.8
#> 531 2008-08-09    McCain  42.0
#> 532 2008-08-10    McCain  42.0
#> 533 2008-08-11    McCain  42.8
#> 534 2008-08-12    McCain  43.0
#> 535 2008-08-13    McCain  43.6
#> 536 2008-08-14    McCain  43.8
#> 537 2008-08-15    McCain  43.8
#> 538 2008-08-16    McCain  43.7
#> 539 2008-08-17    McCain  43.6
#> 540 2008-08-18    McCain  43.4
#> 541 2008-08-19    McCain  42.7
#> 542 2008-08-20    McCain  42.9
#> 543 2008-08-21    McCain  42.5
#> 544 2008-08-22    McCain  42.5
#> 545 2008-08-23    McCain  43.1
#> 546 2008-08-24    McCain  43.1
#> 547 2008-08-25    McCain  42.5
#> 548 2008-08-26    McCain  43.8
#> 549 2008-08-27    McCain  43.5
#> 550 2008-08-28    McCain  43.6
#> 551 2008-08-29    McCain  44.1
#> 552 2008-08-30    McCain  43.1
#> 553 2008-08-31    McCain  42.7
#> 554 2008-09-01    McCain  43.2
#> 555 2008-09-02    McCain  42.5
#> 556 2008-09-03    McCain  42.5
#> 557 2008-09-04    McCain  42.5
#> 558 2008-09-05    McCain  42.8
#> 559 2008-09-06    McCain  44.3
#> 560 2008-09-07    McCain  45.5
#> 561 2008-09-08    McCain  45.3
#> 562 2008-09-09    McCain  46.2
#> 563 2008-09-10    McCain  46.3
#> 564 2008-09-11    McCain  46.5
#> 565 2008-09-12    McCain  46.3
#> 566 2008-09-13    McCain  45.7
#> 567 2008-09-14    McCain  45.5
#> 568 2008-09-15    McCain  45.7
#> 569 2008-09-16    McCain  45.5
#> 570 2008-09-17    McCain  45.6
#> 571 2008-09-18    McCain  45.5
#> 572 2008-09-19    McCain  45.2
#> 573 2008-09-20    McCain  45.0
#> 574 2008-09-21    McCain  45.0
#> 575 2008-09-22    McCain  44.5
#> 576 2008-09-23    McCain  44.4
#> 577 2008-09-24    McCain  44.4
#> 578 2008-09-25    McCain  44.3
#> 579 2008-09-26    McCain  44.1
#> 580 2008-09-27    McCain  44.2
#> 581 2008-09-28    McCain  43.6
#> 582 2008-09-29    McCain  43.8
#> 583 2008-09-30    McCain  43.5
#> 584 2008-10-01    McCain  43.4
#> 585 2008-10-02    McCain  43.2
#> 586 2008-10-03    McCain  43.2
#> 587 2008-10-04    McCain  43.0
#> 588 2008-10-05    McCain  43.0
#> 589 2008-10-06    McCain  43.0
#> 590 2008-10-07    McCain  43.1
#> 591 2008-10-08    McCain  42.5
#> 592 2008-10-09    McCain  42.5
#> 593 2008-10-10    McCain  42.3
#> 594 2008-10-11    McCain  42.2
#> 595 2008-10-12    McCain  42.0
#> 596 2008-10-13    McCain  41.9
#> 597 2008-10-14    McCain  42.0
#> 598 2008-10-15    McCain  42.5
#> 599 2008-10-16    McCain  42.7
#> 600 2008-10-17    McCain  42.8
#> 601 2008-10-18    McCain  43.0
#> 602 2008-10-19    McCain  43.1
#> 603 2008-10-20    McCain  42.9
#> 604 2008-10-21    McCain  42.9
#> 605 2008-10-22    McCain  42.5
#> 606 2008-10-23    McCain  42.5
#> 607 2008-10-24    McCain  42.6
#> 608 2008-10-25    McCain  42.4
#> 609 2008-10-26    McCain  42.6
#> 610 2008-10-27    McCain  42.8
#> 611 2008-10-28    McCain  43.0
#> 612 2008-10-29    McCain  43.3
#> 613 2008-10-30    McCain  43.4
#> 614 2008-10-31    McCain  43.7
#> 615 2008-11-01    McCain  44.0
#> 616 2008-11-02    McCain  44.2
#> 617 2008-11-03    McCain  44.2
#> 618 2008-11-04    McCain  44.2
```


```r
ggplot(pop_vote_avg_tidy, aes(x = date, y = share,
                              colour = fct_reorder2(candidate, date, share))) +
  geom_point() +
  geom_line() +
  scale_colour_manual("Candidate",
                      values = c(Obama = "blue", McCain = "red"))
```

<img src="prediction_files/figure-html/unnamed-chunk-25-1.png" width="70%" style="display: block; margin: auto;" />


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

<img src="prediction_files/figure-html/unnamed-chunk-26-1.png" width="70%" style="display: block; margin: auto;" />


### Correlation

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

In addition to these, the **broom** package provides three functions: `glance`, `tidy`, and `augment` that always return data frames.

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
  geom_abline(slope = coef(fit)["d.comp"],
              intercept = coef(fit)["(Intercept)"],
              colour = "red")
```

<img src="prediction_files/figure-html/unnamed-chunk-31-1.png" width="70%" style="display: block; margin: auto;" />

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
#> 4 0.1145 -0.237
#> 5 0.1148 -0.236
#> 6 0.1639 -0.204
```
Now we can plot the regression line and the original data just like any other plot.

```r
ggplot() +
  geom_point(data = face, mapping = aes(x = d.comp, y = diff.share)) +
  geom_line(data = grid, mapping = aes(x = d.comp, y = pred),
            colour = "red")
```

<img src="prediction_files/figure-html/unnamed-chunk-33-1.png" width="70%" style="display: block; margin: auto;" />
This method is more complicated than the `geom_abline` method for a bivariate regression, but will work for more complicated models, while the `geom_abline` method won't.


Note that [geom_smooth](http://docs.ggplot2.org/current/geom_smooth.html) can be used to add a regression line to a data-set.

```r
ggplot(data = face, mapping = aes(x = d.comp, y = diff.share)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE)
```

<img src="prediction_files/figure-html/unnamed-chunk-34-1.png" width="70%" style="display: block; margin: auto;" />
The argument `method = "lm"` specifies that the function `lm` is to be used to generate fitted values.
It is equivalent to running the regression `lm(y ~ x)` and plotting the regression line, where `y` and `x` are the aesthetics specified by the mappings.
The argument `se = FALSE` tells the function not to plot the confidence interval of the regression (discussed later).

### Regression towards the mean

### Merging Data Sets in R

See the [R for Data Science](http://r4ds.had.co.nz/) chapter [Relational data](http://r4ds.had.co.nz/relational-data.html).


```r
data("pres12", package = "qss")
```


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

*Note: this could be a question. How would you change the .x, .y suffixes to something more informative*
To avoid the duplicate names, or change them, you can rename before merging, or
use the `suffix` argument:

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


The **dplyr** equivalent functions for [cbind](https://www.rdocumentation.org/packages/base/topics/cbind) is [bind_cols](https://www.rdocumentation.org/packages/dplyr/topics/bind_cols).


```r
pres <- pres %>%
  mutate(Obama2008.z = as.numeric(scale(Obama_08)),
         Obama2012.z = as.numeric(scale(Obama_12)))
```

We need to use the `as.numeric` function because `scale()` always returns a matrix.
This will not produce an error in the code chunk above, since the columns of a data frame
can be matrices, but will produce errors in some of the following code if it were omitted.

Scatter plot of states with vote shares in 2008 and 2012

```r
ggplot(pres, aes(x = Obama2008.z, y = Obama2012.z, label = state)) +
  geom_abline(colour = "white", size = 2) +
  geom_text() +
  coord_fixed() +
  scale_x_continuous("Obama's standardized vote share in 2008",
                     limits = c(-4, 4)) +
  scale_y_continuous("Obama's standardized vote share in 2012",
                     limits = c(-4, 4))
```

<img src="prediction_files/figure-html/unnamed-chunk-38-1.png" width="70%" style="display: block; margin: auto;" />

To calculate the bottom and top quartiles


```r
pres %>%
  filter(Obama2008.z < quantile(Obama2008.z, 0.25)) %>%
  summarise(improve = mean(Obama2012.z > Obama2008.z))
#>   improve
#> 1   0.583

pres %>%
  filter(Obama2008.z < quantile(Obama2008.z, 0.75)) %>%
  summarise(improve = mean(Obama2012.z > Obama2008.z))
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

In addition to

```r
summary(fit2)$r.squared
#> [1] 0.513
```
we can get the R squared value from the data frame [glance](https://www.rdocumentation.org/packages/broom/topics/glance.lm) returns:

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

<img src="prediction_files/figure-html/unnamed-chunk-44-1.png" width="70%" style="display: block; margin: auto;" />
Note, we use the function [geom_refline](https://www.rdocumentation.org/packages/modelr/topics/geom_refline) to add a reference line at 0.

Let's add some labels to points, who is that outlier?

```r
fit2_resid_plot +
  geom_label(aes(label = county))
```

<img src="prediction_files/figure-html/unnamed-chunk-45-1.png" width="70%" style="display: block; margin: auto;" />

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

<img src="prediction_files/figure-html/unnamed-chunk-49-1.png" width="70%" style="display: block; margin: auto;" />

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

<img src="prediction_files/figure-html/unnamed-chunk-51-1.png" width="70%" style="display: block; margin: auto;" />
See [Graphics for communication](http://r4ds.had.co.nz/graphics-for-communication.html#label) in *R for Data Science* on labels and annotations in plots.



## Regression and Causation

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
#> 2        1      1.0000
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
#>     variable   `0`   `1`   diff
#>        <chr> <dbl> <dbl>  <dbl>
#> 1 irrigation  3.39  3.02 -0.369
#> 2      water 14.74 23.99  9.252
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

Create indicator variables

```r
social <-
  social %>%
  mutate(Control = as.integer(messages == "Control"),
         Hawthorne = as.integer(messages == "Hawthorne"),
         Neighbors = as.integer(messages == "Neighbors"))
```
alternatively, create these using a for loop.
This is easier to understand and less prone to typo.

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
#>     messages  pred
#>        <chr> <dbl>
#> 1 Civic Duty 0.315
#> 2    Control 0.297
#> 3  Hawthorne 0.322
#> 4  Neighbors 0.378
```

Compare to the sample averages

```r
social %>%
  group_by(messages) %>%
  summarise(mean(primary2006))
#> # A tibble: 4 x 2
#>     messages `mean(primary2006)`
#>        <chr>               <dbl>
#> 1 Civic Duty               0.315
#> 2    Control               0.297
#> 3  Hawthorne               0.322
#> 4  Neighbors               0.378
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
#>     messages primary2006 Control   diff
#>        <chr>       <dbl>   <dbl>  <dbl>
#> 1 Civic Duty       0.315   0.297 0.0179
#> 2    Control       0.297   0.297 0.0000
#> 3  Hawthorne       0.322   0.297 0.0257
#> 4  Neighbors       0.378   0.297 0.0813
```

Adjusted R-squared is included in the output of `broom::glance()`

```r
glance(fit)
#>   r.squared adj.r.squared sigma statistic   p.value df  logLik    AIC
#> 1   0.00328       0.00327 0.463       336 1.06e-217  4 -198247 396504
#>      BIC deviance df.residual
#> 1 396557    65468      305862
glance(fit)$adj.r.squared
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
#> # Groups:   primary2004 [2]
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
#> 1    25   0.189     0.254 0.0643
#> 2    45   0.269     0.346 0.0768
#> 3    65   0.349     0.439 0.0894
#> 4    85   0.429     0.531 0.1020
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
  labs(colour = "", y = "predicted turnout rates") +
  theme(legend.position = "bottom")
```

<img src="prediction_files/figure-html/unnamed-chunk-78-1.png" width="70%" style="display: block; margin: auto;" />


```r
y.hat %>%
  spread(messages, pred) %>%
  mutate(ate = Neighbors - Control) %>%
  filter(age > 20, age < 90) %>%
  ggplot(aes(x = age, y = ate)) +
  geom_line() +
  labs(y = "estimated average treatment effect") +
  ylim(0, 0.1)
```

<img src="prediction_files/figure-html/unnamed-chunk-79-1.png" width="70%" style="display: block; margin: auto;" />

## Regression Discontinuity Design


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

<img src="prediction_files/figure-html/unnamed-chunk-82-1.png" width="70%" style="display: block; margin: auto;" />

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

<img src="prediction_files/figure-html/unnamed-chunk-83-1.png" width="70%" style="display: block; margin: auto;" />

In the previous code, I didn't directly compute the the average net wealth at 0, so I'll need to do that here.
I'll use [gather_predictions](https://www.rdocumentation.org/packages/modelr/topics/gather_predictions) to add predictions for multiple models:

```r
spread_predictions(data_frame(margin = 0),
                   tory_fit1, tory_fit2) %>%
  mutate(rd_est = tory_fit2 - tory_fit1)
#> # A tibble: 1 x 4
#>   margin tory_fit1 tory_fit2 rd_est
#>    <dbl>     <dbl>     <dbl>  <dbl>
#> 1      0      12.5      13.2   0.65
```


**Tidyverse:**

```r
tory_fit3 <- lm(margin.pre ~ margin, data = filter(MPs_tory, margin < 0))
tory_fit4 <- lm(margin.pre ~ margin, data = filter(MPs_tory, margin > 0))

(filter(tidy(tory_fit3), term == "(Intercept)")[["estimate"]] -
 filter(tidy(tory_fit4), term == "(Intercept)")[["estimate"]])
#> [1] 0.0173
```
