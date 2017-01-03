
# Probability

## Prerequisites


```r
library("tidyverse")
#> Loading tidyverse: ggplot2
#> Loading tidyverse: tibble
#> Loading tidyverse: tidyr
#> Loading tidyverse: readr
#> Loading tidyverse: purrr
#> Loading tidyverse: dplyr
#> Conflicts with tidy packages ----------------------------------------------
#> filter(): dplyr, stats
#> lag():    dplyr, stats
```

## Probability


```r
birthday <- function(k) {
  logdenom <- k * log(365) + lfactorial(365 - k)
  lognumer <- lfactorial(365)
  pr <- 1 -   exp(lognumer - logdenom)
  pr
}

bday <- tibble(k = 1:50,
               pr = birthday(k))
ggplot(bday, aes(x = k , y = pr)) +
  geom_hline(yintercept = 0.5, colour = "gray") +
  geom_point() +
  scale_y_continuous("Probability that at least two\n people have the same birthday", limits = c(0, 1)) +
  labs(x = "Number of people")
```

<img src="probability_files/figure-html/unnamed-chunk-3-1.png" width="70%" style="display: block; margin: auto;" />

**Note:** The logarithm is used for numerical stability. Basically,  "floating-point" numbers are approximations of numbers. If you perform arithmetic with numbers that are very large, very small, or vary differently in magnitudes, you could have problems. Logarithms help with some of those issues.
See "Falling Into the Floating Point Trap" in [The R Inforno](http://www.burns-stat.com/pages/Tutor/R_inferno.pdf) for a summary of floating point numbers.
See these John Fox posts [1](http://www.johndcook.com/blog/2008/09/26/comparing-three-methods-of-computing-standard-deviation/) [2](http://www.johndcook.com/blog/2008/09/28/theoretical-explanation-for-numerical-results/) for an example of numerical stability gone wrong.
Also see: http://andrewgelman.com/2016/06/11/log-sum-of-exponentials/.


Instead of using a for-loop, we could do the simulations using a functional
as described in R for Data Science.
Define the function `sim_bdays` to randomly sample k birthdays, and returns
`TRUE` if there are any duplicates.

```r
sim_bdays <- function(k) {
  days <- sample(1:365, k, replace = TRUE)
  length(unique(days)) < k
}
```
Set the parameters for 1,000 simulations, and 23 individuals.
We use `map_lgl` since `sim_bdays` returns a logical value (`TRUE`, `FALSE`):

```r
sims <- 1000
k <- 23
map_lgl(seq_len(sims), ~ sim_bdays(k)) %>%
  mean()
#> [1] 0.52
```


```r
FLVoters <- read_csv(qss_data_url("probability", "FLVoters.csv"))
#> Parsed with column specification:
#> cols(
#>   surname = col_character(),
#>   county = col_integer(),
#>   VTD = col_integer(),
#>   age = col_integer(),
#>   gender = col_character(),
#>   race = col_character()
#> )
dim(FLVoters)
#> [1] 10000     6
FLVoters <- FLVoters %>%
  na.omit()
```


```r
margin.race <-
  FLVoters %>%
  count(race) %>%
  mutate(prop = n / sum(n))
margin.race
#> # A tibble: 6 × 3
#>       race     n    prop
#>      <chr> <int>   <dbl>
#> 1    asian   175 0.01920
#> 2    black  1194 0.13102
#> 3 hispanic  1192 0.13080
#> 4   native    29 0.00318
#> 5    other   310 0.03402
#> 6    white  6213 0.68177
```


```r
margin.gender <- FLVoters %>%
  count(gender) %>%
  mutate(prop = n / sum(n))
margin.gender
#> # A tibble: 2 × 3
#>   gender     n  prop
#>    <chr> <int> <dbl>
#> 1      f  4883 0.536
#> 2      m  4230 0.464
```


```r
FLVoters %>% 
  filter(gender == "f") %>%
  count(race) %>%
  mutate(prop = n / sum(n))
#> # A tibble: 6 × 3
#>       race     n    prop
#>      <chr> <int>   <dbl>
#> 1    asian    83 0.01700
#> 2    black   678 0.13885
#> 3 hispanic   666 0.13639
#> 4   native    17 0.00348
#> 5    other   158 0.03236
#> 6    white  3281 0.67192
```


```r
joint.p <-
  FLVoters %>%
  count(gender, race) %>%
  # needed because it is still grouped by gender
  ungroup() %>%
  mutate(prop = n / sum(n))
joint.p
#> # A tibble: 12 × 4
#>   gender     race     n    prop
#>    <chr>    <chr> <int>   <dbl>
#> 1      f    asian    83 0.00911
#> 2      f    black   678 0.07440
#> 3      f hispanic   666 0.07308
#> 4      f   native    17 0.00187
#> 5      f    other   158 0.01734
#> 6      f    white  3281 0.36004
#> # ... with 6 more rows
```
or 

```r
joint.p %>%
  ungroup() %>%
  select(-n) %>%
  spread(gender, prop)
#> # A tibble: 6 × 3
#>       race       f       m
#> *    <chr>   <dbl>   <dbl>
#> 1    asian 0.00911 0.01010
#> 2    black 0.07440 0.05662
#> 3 hispanic 0.07308 0.05772
#> 4   native 0.00187 0.00132
#> 5    other 0.01734 0.01668
#> 6    white 0.36004 0.32174
```


```r
joint.p %>%
  group_by(race) %>%
  summarise(prop = sum(prop))
#> # A tibble: 6 × 2
#>       race    prop
#>      <chr>   <dbl>
#> 1    asian 0.01920
#> 2    black 0.13102
#> 3 hispanic 0.13080
#> 4   native 0.00318
#> 5    other 0.03402
#> 6    white 0.68177
```


```r
joint.p %>%
  group_by(gender) %>%
  summarise(prop = sum(prop))
#> # A tibble: 2 × 2
#>   gender  prop
#>    <chr> <dbl>
#> 1      f 0.536
#> 2      m 0.464
```



```r
FLVoters <-
  FLVoters %>%
  mutate(age_group = 
           case_when(
             .$age <= 20 ~ 1,
             .$age > 20 & .$age <= 40 ~ 2,
             .$age > 40 & .$age <= 60 ~ 3,
             .$age > 60 ~ 4
           ))
```


```r
joint3 <-
  FLVoters %>%
  count(race, age_group, gender) %>%
  ungroup() %>%
  mutate(prop = n / sum(n))
joint3
#> # A tibble: 47 × 5
#>    race age_group gender     n     prop
#>   <chr>     <dbl>  <chr> <int>    <dbl>
#> 1 asian         1      f     1 0.000110
#> 2 asian         1      m     2 0.000219
#> 3 asian         2      f    24 0.002634
#> 4 asian         2      m    26 0.002853
#> 5 asian         3      f    38 0.004170
#> 6 asian         3      m    47 0.005157
#> # ... with 41 more rows
```

Marginal probabilities by age groups

```r
margin_age <- 
  FLVoters %>%
  count(age_group) %>%
  mutate(prop = n / sum(n))
margin_age
#> # A tibble: 4 × 3
#>   age_group     n   prop
#>       <dbl> <int>  <dbl>
#> 1         1   161 0.0177
#> 2         2  2469 0.2709
#> 3         3  3285 0.3605
#> 4         4  3198 0.3509
```

Calculate the probabilities that each group is in a given age group.

```r
left_join(joint3, 
          select(margin_age, age_group, margin_age = prop),
          by = "age_group") %>%
  mutate(prob_age_group = prop / margin_age) %>%
  filter(race == "black", gender == "f", age_group == 4)
#> # A tibble: 1 × 7
#>    race age_group gender     n   prop margin_age prob_age_group
#>   <chr>     <dbl>  <chr> <int>  <dbl>      <dbl>          <dbl>
#> 1 black         4      f   172 0.0189      0.351         0.0538
```

Two-way joint probability table for age group and gender

```r
joint2 <- FLVoters %>%
  count(age_group, gender) %>%
  ungroup() %>%
  mutate(prob_age_gender = n / sum(n)) 
joint2
#> # A tibble: 8 × 4
#>   age_group gender     n prob_age_gender
#>       <dbl>  <chr> <int>           <dbl>
#> 1         1      f    88         0.00966
#> 2         1      m    73         0.00801
#> 3         2      f  1304         0.14309
#> 4         2      m  1165         0.12784
#> 5         3      f  1730         0.18984
#> 6         3      m  1555         0.17064
#> # ... with 2 more rows
```

Conditional probablities $P(race | gender, age)$,

```r
left_join(joint3, select(joint2, -n), by = c("age_group", "gender")) %>%
  mutate(prob_race = prop / prob_age_gender) %>% 
  arrange(age_group, gender) %>%
  select(age_group, gender, race, prob_race)
#> # A tibble: 47 × 4
#>   age_group gender     race prob_race
#>       <dbl>  <chr>    <chr>     <dbl>
#> 1         1      f    asian    0.0114
#> 2         1      f    black    0.1705
#> 3         1      f hispanic    0.1591
#> 4         1      f   native    0.0114
#> 5         1      f    other    0.0341
#> 6         1      f    white    0.6136
#> # ... with 41 more rows
```
Each row is the $P(race | age_group, gender)$.

