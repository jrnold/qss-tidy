
---
output: html_document
editor_options: 
  chunk_output_type: console
---
# Causality

## Prerequisites {-}


```r
library("tidyverse")
library("stringr")
```

## Racial Discrimination in the Labor Market

Load the data from the **qss** package.

```r
data("resume", package = "qss")
```

In addition to the functions shown in the text,

```r
dim(resume)
#> [1] 4870    4
summary(resume)
#>   firstname             sex                race                call     
#>  Length:4870        Length:4870        Length:4870        Min.   :0.00  
#>  Class :character   Class :character   Class :character   1st Qu.:0.00  
#>  Mode  :character   Mode  :character   Mode  :character   Median :0.00  
#>                                                           Mean   :0.08  
#>                                                           3rd Qu.:0.00  
#>                                                           Max.   :1.00
head(resume)
#>   firstname    sex  race call
#> 1   Allison female white    0
#> 2   Kristen female white    0
#> 3   Lakisha female black    0
#> 4   Latonya female black    0
#> 5    Carrie female white    0
#> 6       Jay   male white    0
```
we can also use `glimpse` to get a quick understanding of the variables in the data frame,

```r
glimpse(resume)
#> Observations: 4,870
#> Variables: 4
#> $ firstname <chr> "Allison", "Kristen", "Lakisha", "Latonya", "Carrie"...
#> $ sex       <chr> "female", "female", "female", "female", "female", "m...
#> $ race      <chr> "white", "white", "black", "black", "white", "white"...
#> $ call      <int> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0...
```

The code in *QSS* uses `table` and `addmargins` to construct the table.
However, this can be done easily with `dplyr` using grouping and summarizing.

For each combination of `race` and `call` let's count the observations:

```r
race_call_tab <- resume %>%
  group_by(race, call) %>%
  count()
race_call_tab
#> # A tibble: 4 x 3
#> # Groups:   race, call [4]
#>    race  call     n
#>   <chr> <int> <int>
#> 1 black     0  2278
#> 2 black     1   157
#> 3 white     0  2200
#> 4 white     1   235
```

If we want to calculate callback rates by race:

```r
race_call_rate <- race_call_tab %>%
  group_by(race) %>%
  mutate(call_rate =  n / sum(n)) %>%
  filter(call == 1) %>%
  select(race, call_rate)
race_call_rate
#> # A tibble: 2 x 2
#> # Groups:   race [2]
#>    race call_rate
#>   <chr>     <dbl>
#> 1 black    0.0645
#> 2 white    0.0965
```

If we want the overall callback rate, we can calculate it from the original
data,

```r
resume %>%
  summarise(call_back = mean(call))
#>   call_back
#> 1    0.0805
```

## Subsetting Data in R


### Subsetting

Select black individuals in the `resume` data:

```r
resumeB <- 
  resume %>%
  filter(race == "black")
```

```r
glimpse(resumeB)
#> Observations: 2,435
#> Variables: 4
#> $ firstname <chr> "Lakisha", "Latonya", "Kenya", "Latonya", "Tyrone", ...
#> $ sex       <chr> "female", "female", "female", "female", "male", "fem...
#> $ race      <chr> "black", "black", "black", "black", "black", "black"...
#> $ call      <int> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0...
```

Calculate the callback rate for black individuals:

```r
resumeB %>%
  summarise(call_rate = mean(call))
#>   call_rate
#> 1    0.0645
```

To keep call and first name variables and those with black-sounding first names:

```r
resumeBf <-
  resume %>%
  filter(race == "black", sex == "female") %>%
  select(call, firstname)
head(resumeBf)
#>   call firstname
#> 1    0   Lakisha
#> 2    0   Latonya
#> 3    0     Kenya
#> 4    0   Latonya
#> 5    0     Aisha
#> 6    0     Aisha
```

Now we can calculate the gender gap by group.


This seems to be a little more code, but we didn't duplicate as much as in QSS, and this would easily scale to more than two categories.

A way to do this using the [spread](https://www.rdocumentation.org/packages/tidyr/topics/spread) and [gather](https://www.rdocumentation.org/packages/tidyr/topics/gather) functions from [tidyr](https://cran.r-project.org/package=tidyr) package.
See the [R for Data Science](http://r4ds.had.co.nz/) chapgter ["Tidy Data"](http://r4ds.had.co.nz/tidy-data.html).

First, group by race and sex and calculate the callback rate for each group:

```r
resume_race_sex <-
  resume %>%
  group_by(race, sex) %>%
  summarise(call = mean(call))
head(resume_race_sex)
#> # A tibble: 4 x 3
#> # Groups:   race [2]
#>    race    sex   call
#>   <chr>  <chr>  <dbl>
#> 1 black female 0.0663
#> 2 black   male 0.0583
#> 3 white female 0.0989
#> 4 white   male 0.0887
```
Use `spread()` to make each value of `race` a new column:

```r

resume_sex <-
  resume_race_sex %>%
  ungroup() %>%
  spread(race, call)
resume_sex
#> # A tibble: 2 x 3
#>      sex  black  white
#> *  <chr>  <dbl>  <dbl>
#> 1 female 0.0663 0.0989
#> 2   male 0.0583 0.0887
```
Now we can calculate the race wage differences by sex as before,

```r
resume_sex %>%
  mutate(call_diff = white - black)
#> # A tibble: 2 x 4
#>      sex  black  white call_diff
#>    <chr>  <dbl>  <dbl>     <dbl>
#> 1 female 0.0663 0.0989    0.0326
#> 2   male 0.0583 0.0887    0.0304
```
This could be combined into a single chain with only six lines of code:

```r
resume %>%
  group_by(race, sex) %>%
  summarise(call = mean(call)) %>%
  ungroup() %>%
  spread(race, call) %>%
  mutate(call_diff = white - black)
#> # A tibble: 2 x 4
#>      sex  black  white call_diff
#>    <chr>  <dbl>  <dbl>     <dbl>
#> 1 female 0.0663 0.0989    0.0326
#> 2   male 0.0583 0.0887    0.0304
```

**WARNING** The function [ungroup](https://www.rdocumentation.org/packages/dplyr/topics/ungroup) removes the groupings 
in [group_by](https://www.rdocumentation.org/packages/dplyr/topics/group_by). The function `spread` will not allow a grouping
variable to be reshaped.  Since many dplyr functions work differently depending on 
whether the data frame is grouped or not, I find that I can encounter many errors due
to forgetting that data frame is grouped. As such, I tend to `ungroup` data frames
as soon as I no longer are using the groupings.

Alternatively, we could have used `summarise` and the `diff` function:

```r
resume %>%
  group_by(race, sex) %>%
  summarise(call = mean(call)) %>%
  group_by(sex) %>%
  arrange(race) %>%
  summarise(call_diff = diff(call))
#> # A tibble: 2 x 2
#>      sex call_diff
#>    <chr>     <dbl>
#> 1 female    0.0326
#> 2   male    0.0304
```
I find the `spread` code preferrrable since the individual race callback rates are
retained in the data, and since there is no natural ordering of the `race` variable
(unlike if it were a time-series), it is not obvious from reading the code  whether `call_diff` is `black - white` or `white - black`.
difference between "balck"


### Simple conditional statements

**dlpyr** has three conditional statement functions `if_else`, `recode` and `case_when`.

The function `if_else` is like `ifelse` but corrects for some weird behavior that `ifelse` has in certain cases.

```r
resume %>%
  mutate(BlackFemale = if_else(race == "black" & sex == "female", 1, 0)) %>%
  group_by(BlackFemale, race, sex) %>%
  count()
#> # A tibble: 4 x 4
#> # Groups:   BlackFemale, race, sex [4]
#>   BlackFemale  race    sex     n
#>         <dbl> <chr>  <chr> <int>
#> 1           0 black   male   549
#> 2           0 white female  1860
#> 3           0 white   male   575
#> 4           1 black female  1886
```

**Warning** The function `if_else` is more strict about the variable types than `ifelse`.
While most R functions are forgiving about variables types, and will automatically convert 
integers to numeric or vice-versa, they are distinct. For example, these examples
will produce errors:

```r
resume %>%
  mutate(BlackFemale = if_else(race == "black" & sex == "female", TRUE, 0)) %>%
#> Error: <text>:3:0: unexpected end of input
#> 1: resume %>%
#> 2:   mutate(BlackFemale = if_else(race == "black" & sex == "female", TRUE, 0)) %>%
#>   ^
```
because `TRUE` is logical and `0` is numeric.

```r
resume %>%
  mutate(BlackFemale = if_else(race == "black" & sex == "female", 1L, 0)) %>%
#> Error: <text>:3:0: unexpected end of input
#> 1: resume %>%
#> 2:   mutate(BlackFemale = if_else(race == "black" & sex == "female", 1L, 0)) %>%
#>   ^
```
because `1L` is an integer and `0` is numeric (a floating-point number)
The distinction between integers and numeric variables is often invisible because most functions coerce variables between 

```r
class(1)
#> [1] "numeric"
class(1L)
#> [1] "integer"
```
The `:` operator returns integers and `as.integer` coerces numeric vectors to integer vectors:

```r
class(1:5)
#> [1] "integer"
class(c(1, 2, 3))
#> [1] "numeric"
class(as.integer(c(1, 2, 3)))
#> [1] "integer"
```



### Factor Variables

For more on factors see the [R for Data Science](http://r4ds.had.co.nz/) chapter ["Factors"](http://r4ds.had.co.nz/factors.html) and the package [forcats](https://cran.r-project.org/package=forcats).
Also see the [R for Data Science](http://r4ds.had.co.nz/) chapter ["Strings"](http://r4ds.had.co.nz/strings.html) for working
with strings.

The function `case_when` is a generalization of the `if_then` to multiple conditions.
For example, to create categories for all combinations of race and sex,

```r
resume %>%
  mutate(
    race_sex = case_when(
      race == "black" & sex == "female" ~ "black, female",
      race == "white" & sex == "female" ~ "white female",
      race == "black" & sex == "male" ~ "black male",
      race == "white" & sex == "male" ~ "white male"
    )
  )
#>      firstname    sex  race call      race_sex
#> 1      Allison female white    0  white female
#> 2      Kristen female white    0  white female
#> 3      Lakisha female black    0 black, female
#> 4      Latonya female black    0 black, female
#> 5       Carrie female white    0  white female
#> 6          Jay   male white    0    white male
#> 7         Jill female white    0  white female
#> 8        Kenya female black    0 black, female
#> 9      Latonya female black    0 black, female
#> 10      Tyrone   male black    0    black male
#> 11       Aisha female black    0 black, female
#> 12     Allison female white    0  white female
#> 13       Aisha female black    0 black, female
#> 14      Carrie female white    0  white female
#> 15       Aisha female black    0 black, female
#> 16    Geoffrey   male white    0    white male
#> 17     Matthew   male white    0    white male
#> 18      Tamika female black    0 black, female
#> 19        Jill female white    0  white female
#> 20     Latonya female black    0 black, female
#> 21       Leroy   male black    0    black male
#> 22        Todd   male white    0    white male
#> 23     Allison female white    0  white female
#> 24      Carrie female white    0  white female
#> 25        Greg   male white    0    white male
#> 26      Keisha female black    0 black, female
#> 27      Keisha female black    0 black, female
#> 28     Kristen female white    0  white female
#> 29     Lakisha female black    0 black, female
#> 30      Tamika female black    0 black, female
#> 31     Allison female white    0  white female
#> 32      Keisha female black    0 black, female
#> 33     Kristen female white    0  white female
#> 34     Latonya female black    0 black, female
#> 35        Brad   male white    0    white male
#> 36        Jill female white    0  white female
#> 37      Keisha female black    0 black, female
#> 38      Keisha female black    0 black, female
#> 39     Lakisha female black    0 black, female
#> 40      Laurie female white    0  white female
#> 41    Meredith female white    0  white female
#> 42      Tyrone   male black    0    black male
#> 43        Anne female white    0  white female
#> 44       Emily female white    0  white female
#> 45      Latoya female black    0 black, female
#> 46      Tamika female black    0 black, female
#> 47        Brad   male white    0    white male
#> 48      Latoya female black    0 black, female
#> 49     Kristen female white    0  white female
#> 50     Latonya female black    0 black, female
#> 51      Latoya female black    0 black, female
#> 52      Laurie female white    0  white female
#> 53     Allison female white    0  white female
#> 54       Ebony female black    0 black, female
#> 55         Jay   male white    0    white male
#> 56      Keisha female black    0 black, female
#> 57      Laurie female white    0  white female
#> 58      Tyrone   male black    0    black male
#> 59        Anne female white    0  white female
#> 60     Lakisha female black    0 black, female
#> 61     Latonya female black    0 black, female
#> 62    Meredith female white    0  white female
#> 63     Allison female white    0  white female
#> 64      Carrie female white    0  white female
#> 65       Ebony female black    0 black, female
#> 66       Kenya female black    0 black, female
#> 67     Lakisha female black    0 black, female
#> 68      Laurie female white    0  white female
#> 69       Aisha female black    0 black, female
#> 70        Anne female white    0  white female
#> 71     Brendan   male white    0    white male
#> 72       Hakim   male black    0    black male
#> 73      Latoya female black    0 black, female
#> 74      Laurie female white    0  white female
#> 75      Laurie female white    0  white female
#> 76       Leroy   male black    0    black male
#> 77        Anne female white    0  white female
#> 78       Kenya female black    0 black, female
#> 79     Latonya female black    0 black, female
#> 80    Meredith female white    0  white female
#> 81       Jamal   male black    0    black male
#> 82     Matthew   male white    0    white male
#> 83        Neil   male white    0    white male
#> 84      Tyrone   male black    0    black male
#> 85       Leroy   male black    0    black male
#> 86        Todd   male white    1    white male
#> 87        Brad   male white    0    white male
#> 88       Ebony female black    0 black, female
#> 89        Jill female white    0  white female
#> 90     Kristen female white    0  white female
#> 91     Lakisha female black    0 black, female
#> 92     Matthew   male white    0    white male
#> 93      Tamika female black    0 black, female
#> 94    Tremayne   male black    0    black male
#> 95       Aisha female black    0 black, female
#> 96       Brett   male white    1    white male
#> 97     Darnell   male black    0    black male
#> 98       Emily female white    0  white female
#> 99     Latonya female black    0 black, female
#> 100      Sarah female white    0  white female
#> 101      Aisha female black    0 black, female
#> 102       Anne female white    0  white female
#> 103   Jermaine   male black    0    black male
#> 104       Neil   male white    0    white male
#> 105    Allison female white    0  white female
#> 106       Anne female white    1  white female
#> 107     Keisha female black    0 black, female
#> 108    Latonya female black    1 black, female
#> 109    Latonya female black    0 black, female
#> 110     Laurie female white    0  white female
#> 111        Jay   male white    0    white male
#> 112    Lakisha female black    0 black, female
#> 113       Anne female white    0  white female
#> 114     Keisha female black    0 black, female
#> 115    Kristen female white    0  white female
#> 116    Lakisha female black    0 black, female
#> 117    Allison female white    0  white female
#> 118      Ebony female black    0 black, female
#> 119     Keisha female black    0 black, female
#> 120    Kristen female white    0  white female
#> 121    Lakisha female black    0 black, female
#> 122   Meredith female white    0  white female
#> 123    Allison female white    0  white female
#> 124    Kristen female white    0  white female
#> 125    Lakisha female black    0 black, female
#> 126    Lakisha female black    0 black, female
#> 127    Tanisha female black    1 black, female
#> 128       Todd   male white    1    white male
#> 129      Aisha female black    0 black, female
#> 130       Anne female white    0  white female
#> 131       Jill female white    0  white female
#> 132     Latoya female black    0 black, female
#> 133       Neil   male white    0    white male
#> 134     Tamika female black    0 black, female
#> 135       Anne female white    0  white female
#> 136   Geoffrey   male white    0    white male
#> 137     Latoya female black    0 black, female
#> 138    Rasheed   male black    0    black male
#> 139      Aisha female black    0 black, female
#> 140    Allison female white    0  white female
#> 141     Carrie female white    0  white female
#> 142      Ebony female black    0 black, female
#> 143      Kenya female black    0 black, female
#> 144    Kristen female white    0  white female
#> 145   Jermaine   male black    0    black male
#> 146     Laurie female white    0  white female
#> 147    Allison female white    0  white female
#> 148    Kristen female white    0  white female
#> 149    Lakisha female black    0 black, female
#> 150    Latonya female black    0 black, female
#> 151       Brad   male white    0    white male
#> 152      Leroy   male black    0    black male
#> 153      Emily female white    0  white female
#> 154    Latonya female black    0 black, female
#> 155     Latoya female black    0 black, female
#> 156     Laurie female white    0  white female
#> 157      Aisha female black    0 black, female
#> 158    Allison female white    0  white female
#> 159      Ebony female black    0 black, female
#> 160   Jermaine   male black    0    black male
#> 161    Kristen female white    0  white female
#> 162    Latonya female black    0 black, female
#> 163     Laurie female white    0  white female
#> 164     Laurie female white    0  white female
#> 165       Anne female white    0  white female
#> 166    Brendan   male white    1    white male
#> 167     Kareem   male black    0    black male
#> 168     Keisha female black    0 black, female
#> 169    Matthew   male white    1    white male
#> 170   Meredith female white    0  white female
#> 171    Tanisha female black    0 black, female
#> 172    Tanisha female black    1 black, female
#> 173      Aisha female black    0 black, female
#> 174    Allison female white    0  white female
#> 175    Allison female white    0  white female
#> 176       Anne female white    0  white female
#> 177    Brendan   male white    0    white male
#> 178      Brett   male white    0    white male
#> 179      Brett   male white    0    white male
#> 180      Brett   male white    0    white male
#> 181      Ebony female black    0 black, female
#> 182   Geoffrey   male white    0    white male
#> 183        Jay   male white    0    white male
#> 184       Jill female white    0  white female
#> 185     Keisha female black    0 black, female
#> 186     Keisha female black    0 black, female
#> 187      Kenya female black    0 black, female
#> 188      Kenya female black    0 black, female
#> 189    Lakisha female black    0 black, female
#> 190     Latoya female black    0 black, female
#> 191     Latoya female black    0 black, female
#> 192     Laurie female white    0  white female
#> 193    Matthew   male white    0    white male
#> 194    Rasheed   male black    0    black male
#> 195      Sarah female white    0  white female
#> 196      Sarah female white    0  white female
#> 197     Tamika female black    0 black, female
#> 198    Tanisha female black    0 black, female
#> 199    Tanisha female black    0 black, female
#> 200   Tremayne   male black    0    black male
#> 201    Lakisha female black    1 black, female
#> 202   Meredith female white    1  white female
#> 203       Anne female white    0  white female
#> 204    Latonya female black    0 black, female
#> 205      Sarah female white    0  white female
#> 206     Tamika female black    0 black, female
#> 207       Jill female white    0  white female
#> 208     Keisha female black    0 black, female
#> 209    Lakisha female black    0 black, female
#> 210   Meredith female white    0  white female
#> 211       Jill female white    1  white female
#> 212     Keisha female black    0 black, female
#> 213    Lakisha female black    0 black, female
#> 214   Meredith female white    0  white female
#> 215     Carrie female white    0  white female
#> 216       Greg   male white    0    white male
#> 217      Kenya female black    0 black, female
#> 218   Tremayne   male black    0    black male
#> 219      Kenya female black    0 black, female
#> 220       Neil   male white    0    white male
#> 221      Emily female white    0  white female
#> 222       Jill female white    0  white female
#> 223    Latonya female black    0 black, female
#> 224    Tanisha female black    0 black, female
#> 225      Ebony female black    0 black, female
#> 226    Kristen female white    0  white female
#> 227    Latonya female black    0 black, female
#> 228     Laurie female white    0  white female
#> 229       Anne female white    0  white female
#> 230      Emily female white    0  white female
#> 231     Keisha female black    0 black, female
#> 232    Tanisha female black    0 black, female
#> 233    Allison female white    0  white female
#> 234    Kristen female white    0  white female
#> 235    Latonya female black    0 black, female
#> 236    Tanisha female black    0 black, female
#> 237      Aisha female black    0 black, female
#> 238    Allison female white    0  white female
#> 239       Anne female white    0  white female
#> 240    Latonya female black    0 black, female
#> 241     Latoya female black    0 black, female
#> 242      Sarah female white    0  white female
#> 243      Aisha female black    0 black, female
#> 244       Anne female white    0  white female
#> 245     Latoya female black    0 black, female
#> 246     Laurie female white    0  white female
#> 247       Anne female white    0  white female
#> 248     Carrie female white    1  white female
#> 249      Ebony female black    0 black, female
#> 250    Lakisha female black    0 black, female
#> 251    Allison female white    0  white female
#> 252     Keisha female black    0 black, female
#> 253    Kristen female white    0  white female
#> 254    Tanisha female black    0 black, female
#> 255      Aisha female black    0 black, female
#> 256      Emily female white    0  white female
#> 257    Latonya female black    0 black, female
#> 258      Sarah female white    0  white female
#> 259   Geoffrey   male white    0    white male
#> 260     Kareem   male black    1    black male
#> 261    Kristen female white    0  white female
#> 262    Rasheed   male black    0    black male
#> 263       Todd   male white    0    white male
#> 264     Tyrone   male black    0    black male
#> 265    Brendan   male white    0    white male
#> 266      Jamal   male black    0    black male
#> 267    Matthew   male white    0    white male
#> 268   Meredith female white    1  white female
#> 269    Rasheed   male black    0    black male
#> 270   Tremayne   male black    1    black male
#> 271       Anne female white    1  white female
#> 272      Ebony female black    1 black, female
#> 273    Kristen female white    1  white female
#> 274     Tamika female black    0 black, female
#> 275      Aisha female black    0 black, female
#> 276    Allison female white    0  white female
#> 277      Emily female white    0  white female
#> 278    Kristen female white    0  white female
#> 279     Latoya female black    0 black, female
#> 280     Tamika female black    0 black, female
#> 281      Aisha female black    0 black, female
#> 282       Anne female white    0  white female
#> 283      Emily female white    0  white female
#> 284       Jill female white    0  white female
#> 285     Keisha female black    0 black, female
#> 286    Lakisha female black    0 black, female
#> 287      Ebony female black    0 black, female
#> 288      Kenya female black    0 black, female
#> 289    Kristen female white    0  white female
#> 290   Meredith female white    0  white female
#> 291      Aisha female black    0 black, female
#> 292       Anne female white    0  white female
#> 293      Emily female white    0  white female
#> 294      Emily female white    0  white female
#> 295      Kenya female black    0 black, female
#> 296    Latonya female black    0 black, female
#> 297       Anne female white    0  white female
#> 298      Emily female white    0  white female
#> 299     Keisha female black    0 black, female
#> 300     Tamika female black    0 black, female
#> 301       Anne female white    0  white female
#> 302      Emily female white    0  white female
#> 303     Keisha female black    0 black, female
#> 304      Kenya female black    0 black, female
#> 305     Latoya female black    0 black, female
#> 306       Neil   male white    0    white male
#> 307      Aisha female black    0 black, female
#> 308       Anne female white    0  white female
#> 309      Emily female white    0  white female
#> 310     Tamika female black    0 black, female
#> 311     Carrie female white    0  white female
#> 312       Jill female white    0  white female
#> 313     Keisha female black    0 black, female
#> 314    Latonya female black    0 black, female
#> 315      Sarah female white    0  white female
#> 316     Tyrone   male black    0    black male
#> 317     Carrie female white    0  white female
#> 318      Emily female white    0  white female
#> 319     Latoya female black    0 black, female
#> 320    Tanisha female black    0 black, female
#> 321      Aisha female black    0 black, female
#> 322    Kristen female white    0  white female
#> 323    Lakisha female black    0 black, female
#> 324     Laurie female white    0  white female
#> 325    Allison female white    0  white female
#> 326       Jill female white    0  white female
#> 327     Keisha female black    0 black, female
#> 328    Kristen female white    0  white female
#> 329    Lakisha female black    0 black, female
#> 330      Leroy   male black    0    black male
#> 331       Brad   male white    0    white male
#> 332     Keisha female black    0 black, female
#> 333    Allison female white    0  white female
#> 334     Carrie female white    0  white female
#> 335    Latonya female black    0 black, female
#> 336     Latoya female black    0 black, female
#> 337     Carrie female white    0  white female
#> 338      Ebony female black    0 black, female
#> 339    Latonya female black    0 black, female
#> 340     Laurie female white    0  white female
#> 341   Meredith female white    0  white female
#> 342   Tremayne   male black    0    black male
#> 343    Allison female white    0  white female
#> 344     Carrie female white    0  white female
#> 345    Lakisha female black    0 black, female
#> 346     Tamika female black    0 black, female
#> 347       Anne female white    0  white female
#> 348    Darnell   male black    0    black male
#> 349       Greg   male white    1    white male
#> 350     Tamika female black    0 black, female
#> 351    Allison female white    0  white female
#> 352     Carrie female white    0  white female
#> 353      Kenya female black    0 black, female
#> 354   Tremayne   male black    0    black male
#> 355      Aisha female black    0 black, female
#> 356      Aisha female black    0 black, female
#> 357       Brad   male white    0    white male
#> 358       Brad   male white    0    white male
#> 359    Brendan   male white    0    white male
#> 360      Ebony female black    0 black, female
#> 361   Geoffrey   male white    0    white male
#> 362       Greg   male white    0    white male
#> 363       Greg   male white    0    white male
#> 364       Greg   male white    0    white male
#> 365      Hakim   male black    0    black male
#> 366        Jay   male white    0    white male
#> 367   Jermaine   male black    0    black male
#> 368     Kareem   male black    0    black male
#> 369     Kareem   male black    0    black male
#> 370    Latonya female black    0 black, female
#> 371      Leroy   male black    0    black male
#> 372   Meredith female white    0  white female
#> 373      Sarah female white    0  white female
#> 374      Sarah female white    0  white female
#> 375     Tamika female black    0 black, female
#> 376    Tanisha female black    0 black, female
#> 377       Todd   male white    0    white male
#> 378   Tremayne   male black    0    black male
#> 379      Emily female white    0  white female
#> 380      Kenya female black    0 black, female
#> 381     Latoya female black    0 black, female
#> 382      Sarah female white    0  white female
#> 383     Carrie female white    1  white female
#> 384   Jermaine   male black    1    black male
#> 385    Matthew   male white    0    white male
#> 386     Tyrone   male black    0    black male
#> 387    Allison female white    0  white female
#> 388      Ebony female black    0 black, female
#> 389        Jay   male white    1    white male
#> 390     Tamika female black    0 black, female
#> 391       Anne female white    0  white female
#> 392    Latonya female black    0 black, female
#> 393     Laurie female white    0  white female
#> 394    Tanisha female black    0 black, female
#> 395      Ebony female black    0 black, female
#> 396       Jill female white    0  white female
#> 397    Kristen female white    0  white female
#> 398    Lakisha female black    0 black, female
#> 399     Carrie female white    0  white female
#> 400       Jill female white    0  white female
#> 401     Keisha female black    0 black, female
#> 402    Rasheed   male black    0    black male
#> 403    Allison female white    0  white female
#> 404      Kenya female black    0 black, female
#> 405   Meredith female white    0  white female
#> 406     Tamika female black    0 black, female
#> 407    Matthew   male white    0    white male
#> 408   Tremayne   male black    0    black male
#> 409      Ebony female black    0 black, female
#> 410      Emily female white    0  white female
#> 411       Jill female white    0  white female
#> 412     Tamika female black    0 black, female
#> 413    Darnell   male black    0    black male
#> 414      Emily female white    1  white female
#> 415       Neil   male white    0    white male
#> 416     Tamika female black    0 black, female
#> 417    Latonya female black    0 black, female
#> 418     Laurie female white    0  white female
#> 419      Sarah female white    0  white female
#> 420    Tanisha female black    0 black, female
#> 421     Carrie female white    0  white female
#> 422     Kareem   male black    0    black male
#> 423       Todd   male white    0    white male
#> 424     Tyrone   male black    0    black male
#> 425       Anne female white    0  white female
#> 426       Jill female white    0  white female
#> 427      Kenya female black    1 black, female
#> 428     Latoya female black    1 black, female
#> 429       Anne female white    0  white female
#> 430      Ebony female black    0 black, female
#> 431      Emily female white    0  white female
#> 432     Keisha female black    0 black, female
#> 433    Allison female white    0  white female
#> 434    Kristen female white    0  white female
#> 435    Lakisha female black    0 black, female
#> 436    Tanisha female black    0 black, female
#> 437    Brendan   male white    0    white male
#> 438     Laurie female white    0  white female
#> 439    Rasheed   male black    0    black male
#> 440     Tyrone   male black    0    black male
#> 441       Jill female white    0  white female
#> 442    Lakisha female black    0 black, female
#> 443    Matthew   male white    1    white male
#> 444     Tamika female black    0 black, female
#> 445      Aisha female black    0 black, female
#> 446      Emily female white    0  white female
#> 447     Keisha female black    0 black, female
#> 448      Sarah female white    1  white female
#> 449       Anne female white    0  white female
#> 450      Emily female white    0  white female
#> 451     Latoya female black    0 black, female
#> 452     Tamika female black    0 black, female
#> 453      Kenya female black    0 black, female
#> 454    Kristen female white    0  white female
#> 455    Latonya female black    0 black, female
#> 456     Laurie female white    0  white female
#> 457     Carrie female white    0  white female
#> 458       Jill female white    0  white female
#> 459     Keisha female black    0 black, female
#> 460     Latoya female black    0 black, female
#> 461      Emily female white    0  white female
#> 462    Kristen female white    0  white female
#> 463     Latoya female black    0 black, female
#> 464     Tamika female black    0 black, female
#> 465     Keisha female black    0 black, female
#> 466    Kristen female white    0  white female
#> 467    Lakisha female black    0 black, female
#> 468   Meredith female white    0  white female
#> 469    Allison female white    0  white female
#> 470    Lakisha female black    0 black, female
#> 471   Meredith female white    0  white female
#> 472    Tanisha female black    0 black, female
#> 473      Emily female white    1  white female
#> 474     Keisha female black    0 black, female
#> 475    Latonya female black    1 black, female
#> 476      Sarah female white    1  white female
#> 477      Aisha female black    1 black, female
#> 478       Jill female white    1  white female
#> 479    Latonya female black    1 black, female
#> 480      Sarah female white    1  white female
#> 481       Anne female white    0  white female
#> 482      Kenya female black    0 black, female
#> 483     Latoya female black    0 black, female
#> 484      Sarah female white    0  white female
#> 485    Allison female white    0  white female
#> 486     Keisha female black    0 black, female
#> 487   Meredith female white    0  white female
#> 488    Tanisha female black    0 black, female
#> 489       Anne female white    0  white female
#> 490     Carrie female white    0  white female
#> 491    Latonya female black    0 black, female
#> 492    Tanisha female black    0 black, female
#> 493    Allison female white    0  white female
#> 494       Anne female white    0  white female
#> 495      Ebony female black    0 black, female
#> 496       Jill female white    0  white female
#> 497     Keisha female black    0 black, female
#> 498    Lakisha female black    0 black, female
#> 499    Latonya female black    0 black, female
#> 500       Todd   male white    0    white male
#> 501     Carrie female white    0  white female
#> 502   Meredith female white    0  white female
#> 503     Tamika female black    0 black, female
#> 504    Tanisha female black    0 black, female
#> 505      Aisha female black    0 black, female
#> 506       Anne female white    0  white female
#> 507      Emily female white    0  white female
#> 508    Latonya female black    0 black, female
#> 509      Aisha female black    0 black, female
#> 510    Allison female white    0  white female
#> 511       Jill female white    0  white female
#> 512     Tamika female black    0 black, female
#> 513       Anne female white    0  white female
#> 514      Ebony female black    0 black, female
#> 515       Jill female white    0  white female
#> 516     Tamika female black    0 black, female
#> 517     Carrie female white    0  white female
#> 518      Kenya female black    0 black, female
#> 519      Sarah female white    0  white female
#> 520    Tanisha female black    0 black, female
#> 521       Anne female white    0  white female
#> 522     Keisha female black    0 black, female
#> 523    Allison female white    0  white female
#> 524     Latoya female black    0 black, female
#> 525      Sarah female white    0  white female
#> 526     Tamika female black    0 black, female
#> 527       Anne female white    0  white female
#> 528       Jill female white    0  white female
#> 529      Kenya female black    0 black, female
#> 530    Lakisha female black    0 black, female
#> 531       Jill female white    0  white female
#> 532     Keisha female black    0 black, female
#> 533    Lakisha female black    0 black, female
#> 534   Meredith female white    0  white female
#> 535      Aisha female black    0 black, female
#> 536    Allison female white    0  white female
#> 537    Allison female white    0  white female
#> 538      Hakim   male black    0    black male
#> 539      Sarah female white    0  white female
#> 540     Tamika female black    0 black, female
#> 541      Aisha female black    0 black, female
#> 542     Latoya female black    0 black, female
#> 543     Laurie female white    0  white female
#> 544   Meredith female white    0  white female
#> 545      Aisha female black    0 black, female
#> 546    Allison female white    0  white female
#> 547    Allison female white    0  white female
#> 548    Allison female white    0  white female
#> 549       Anne female white    0  white female
#> 550       Brad   male white    0    white male
#> 551    Brendan   male white    0    white male
#> 552    Darnell   male black    0    black male
#> 553      Emily female white    0  white female
#> 554   Geoffrey   male white    0    white male
#> 555       Greg   male white    0    white male
#> 556      Hakim   male black    0    black male
#> 557      Hakim   male black    0    black male
#> 558        Jay   male white    0    white male
#> 559   Jermaine   male black    0    black male
#> 560     Kareem   male black    0    black male
#> 561      Kenya female black    0 black, female
#> 562      Kenya female black    0 black, female
#> 563    Lakisha female black    0 black, female
#> 564    Latonya female black    0 black, female
#> 565   Meredith female white    0  white female
#> 566       Neil   male white    0    white male
#> 567       Neil   male white    0    white male
#> 568    Rasheed   male black    0    black male
#> 569     Tamika female black    0 black, female
#> 570    Tanisha female black    0 black, female
#> 571       Todd   male white    0    white male
#> 572   Tremayne   male black    0    black male
#> 573       Brad   male white    0    white male
#> 574      Ebony female black    0 black, female
#> 575      Jamal   male black    0    black male
#> 576        Jay   male white    0    white male
#> 577      Ebony female black    1 black, female
#> 578      Emily female white    1  white female
#> 579    Latonya female black    0 black, female
#> 580   Meredith female white    0  white female
#> 581    Lakisha female black    0 black, female
#> 582    Latonya female black    0 black, female
#> 583     Laurie female white    1  white female
#> 584   Meredith female white    0  white female
#> 585    Darnell   male black    0    black male
#> 586   Geoffrey   male white    0    white male
#> 587    Kristen female white    0  white female
#> 588     Tyrone   male black    0    black male
#> 589       Jill female white    0  white female
#> 590    Latonya female black    0 black, female
#> 591      Sarah female white    0  white female
#> 592    Tanisha female black    0 black, female
#> 593    Allison female white    1  white female
#> 594      Ebony female black    0 black, female
#> 595    Lakisha female black    0 black, female
#> 596     Laurie female white    1  white female
#> 597    Allison female white    0  white female
#> 598      Emily female white    0  white female
#> 599     Tamika female black    0 black, female
#> 600    Tanisha female black    0 black, female
#> 601    Allison female white    1  white female
#> 602      Brett   male white    0    white male
#> 603   Jermaine   male black    0    black male
#> 604    Tanisha female black    0 black, female
#> 605      Aisha female black    0 black, female
#> 606    Allison female white    0  white female
#> 607       Jill female white    0  white female
#> 608    Latonya female black    0 black, female
#> 609     Carrie female white    0  white female
#> 610      Ebony female black    0 black, female
#> 611     Latoya female black    0 black, female
#> 612     Laurie female white    0  white female
#> 613     Carrie female white    0  white female
#> 614     Keisha female black    0 black, female
#> 615    Latonya female black    0 black, female
#> 616      Sarah female white    0  white female
#> 617    Allison female white    0  white female
#> 618      Ebony female black    0 black, female
#> 619      Kenya female black    0 black, female
#> 620      Sarah female white    0  white female
#> 621      Aisha female black    0 black, female
#> 622       Jill female white    0  white female
#> 623    Kristen female white    0  white female
#> 624    Latonya female black    0 black, female
#> 625       Anne female white    0  white female
#> 626      Ebony female black    0 black, female
#> 627    Kristen female white    0  white female
#> 628     Latoya female black    0 black, female
#> 629      Ebony female black    0 black, female
#> 630       Jill female white    0  white female
#> 631      Sarah female white    0  white female
#> 632     Tamika female black    0 black, female
#> 633      Emily female white    0  white female
#> 634     Keisha female black    0 black, female
#> 635      Kenya female black    0 black, female
#> 636      Sarah female white    0  white female
#> 637      Aisha female black    0 black, female
#> 638      Ebony female black    0 black, female
#> 639       Jill female white    0  white female
#> 640   Meredith female white    0  white female
#> 641       Anne female white    0  white female
#> 642      Emily female white    0  white female
#> 643     Latoya female black    0 black, female
#> 644     Tamika female black    0 black, female
#> 645    Allison female white    0  white female
#> 646      Emily female white    0  white female
#> 647      Kenya female black    0 black, female
#> 648     Tamika female black    0 black, female
#> 649    Allison female white    0  white female
#> 650     Carrie female white    0  white female
#> 651     Keisha female black    0 black, female
#> 652    Lakisha female black    0 black, female
#> 653     Laurie female white    0  white female
#> 654    Tanisha female black    0 black, female
#> 655       Anne female white    0  white female
#> 656     Carrie female white    0  white female
#> 657     Keisha female black    0 black, female
#> 658     Tamika female black    0 black, female
#> 659    Allison female white    0  white female
#> 660    Latonya female black    0 black, female
#> 661     Laurie female white    0  white female
#> 662     Tamika female black    0 black, female
#> 663    Allison female white    0  white female
#> 664     Keisha female black    0 black, female
#> 665   Meredith female white    0  white female
#> 666    Tanisha female black    0 black, female
#> 667       Jill female white    0  white female
#> 668    Lakisha female black    0 black, female
#> 669      Sarah female white    0  white female
#> 670     Tamika female black    0 black, female
#> 671       Anne female white    0  white female
#> 672      Ebony female black    0 black, female
#> 673      Sarah female white    0  white female
#> 674    Tanisha female black    0 black, female
#> 675     Carrie female white    0  white female
#> 676     Keisha female black    0 black, female
#> 677    Latonya female black    0 black, female
#> 678      Sarah female white    0  white female
#> 679     Carrie female white    0  white female
#> 680     Latoya female black    0 black, female
#> 681   Meredith female white    0  white female
#> 682    Tanisha female black    0 black, female
#> 683    Allison female white    0  white female
#> 684      Ebony female black    0 black, female
#> 685    Lakisha female black    0 black, female
#> 686     Laurie female white    0  white female
#> 687      Kenya female black    0 black, female
#> 688     Laurie female white    0  white female
#> 689        Jay   male white    0    white male
#> 690     Keisha female black    0 black, female
#> 691      Emily female white    0  white female
#> 692      Kenya female black    0 black, female
#> 693      Sarah female white    0  white female
#> 694    Tanisha female black    0 black, female
#> 695      Aisha female black    0 black, female
#> 696    Allison female white    0  white female
#> 697    Allison female white    0  white female
#> 698       Anne female white    0  white female
#> 699       Brad   male white    0    white male
#> 700       Brad   male white    0    white male
#> 701      Brett   male white    0    white male
#> 702     Carrie female white    0  white female
#> 703     Carrie female white    0  white female
#> 704      Emily female white    0  white female
#> 705      Jamal   male black    0    black male
#> 706        Jay   male white    0    white male
#> 707        Jay   male white    0    white male
#> 708   Jermaine   male black    0    black male
#> 709       Jill female white    0  white female
#> 710     Kareem   male black    0    black male
#> 711     Kareem   male black    0    black male
#> 712     Kareem   male black    0    black male
#> 713     Keisha female black    0 black, female
#> 714    Latonya female black    0 black, female
#> 715    Latonya female black    0 black, female
#> 716     Latoya female black    0 black, female
#> 717     Laurie female white    0  white female
#> 718      Leroy   male black    0    black male
#> 719       Neil   male white    0    white male
#> 720    Rasheed   male black    0    black male
#> 721      Sarah female white    0  white female
#> 722      Sarah female white    0  white female
#> 723    Tanisha female black    0 black, female
#> 724    Tanisha female black    0 black, female
#> 725   Tremayne   male black    0    black male
#> 726     Tyrone   male black    0    black male
#> 727    Kristen female white    0  white female
#> 728    Latonya female black    0 black, female
#> 729      Sarah female white    0  white female
#> 730    Tanisha female black    0 black, female
#> 731      Ebony female black    0 black, female
#> 732      Emily female white    0  white female
#> 733    Lakisha female black    0 black, female
#> 734      Sarah female white    0  white female
#> 735       Anne female white    1  white female
#> 736     Latoya female black    1 black, female
#> 737   Meredith female white    0  white female
#> 738    Tanisha female black    0 black, female
#> 739       Anne female white    0  white female
#> 740      Hakim   male black    0    black male
#> 741        Jay   male white    0    white male
#> 742     Latoya female black    0 black, female
#> 743      Aisha female black    0 black, female
#> 744      Emily female white    0  white female
#> 745       Jill female white    0  white female
#> 746     Keisha female black    0 black, female
#> 747     Laurie female white    0  white female
#> 748     Tamika female black    0 black, female
#> 749     Carrie female white    0  white female
#> 750    Lakisha female black    0 black, female
#> 751     Latoya female black    0 black, female
#> 752     Laurie female white    0  white female
#> 753    Allison female white    0  white female
#> 754    Kristen female white    0  white female
#> 755    Lakisha female black    0 black, female
#> 756    Latonya female black    0 black, female
#> 757    Allison female white    1  white female
#> 758     Keisha female black    0 black, female
#> 759     Laurie female white    1  white female
#> 760    Tanisha female black    0 black, female
#> 761       Jill female white    0  white female
#> 762    Kristen female white    0  white female
#> 763    Lakisha female black    0 black, female
#> 764     Tamika female black    0 black, female
#> 765     Latoya female black    1 black, female
#> 766     Laurie female white    1  white female
#> 767      Sarah female white    0  white female
#> 768     Tamika female black    0 black, female
#> 769      Ebony female black    0 black, female
#> 770    Lakisha female black    0 black, female
#> 771   Meredith female white    0  white female
#> 772      Sarah female white    0  white female
#> 773    Allison female white    0  white female
#> 774      Kenya female black    0 black, female
#> 775     Laurie female white    0  white female
#> 776     Tamika female black    0 black, female
#> 777    Allison female white    0  white female
#> 778     Keisha female black    0 black, female
#> 779    Lakisha female black    0 black, female
#> 780   Meredith female white    0  white female
#> 781    Latonya female black    0 black, female
#> 782     Laurie female white    0  white female
#> 783      Aisha female black    0 black, female
#> 784    Allison female white    0  white female
#> 785     Carrie female white    0  white female
#> 786    Tanisha female black    0 black, female
#> 787       Anne female white    0  white female
#> 788     Latoya female black    0 black, female
#> 789     Laurie female white    0  white female
#> 790     Tamika female black    0 black, female
#> 791     Carrie female white    0  white female
#> 792    Lakisha female black    0 black, female
#> 793    Latonya female black    0 black, female
#> 794      Sarah female white    0  white female
#> 795      Ebony female black    0 black, female
#> 796    Kristen female white    0  white female
#> 797       Anne female white    0  white female
#> 798      Emily female white    0  white female
#> 799      Kenya female black    0 black, female
#> 800     Latoya female black    0 black, female
#> 801    Allison female white    0  white female
#> 802      Emily female white    0  white female
#> 803     Tamika female black    0 black, female
#> 804    Tanisha female black    0 black, female
#> 805      Aisha female black    0 black, female
#> 806    Allison female white    0  white female
#> 807     Carrie female white    1  white female
#> 808     Latoya female black    0 black, female
#> 809      Ebony female black    0 black, female
#> 810       Jill female white    0  white female
#> 811    Kristen female white    0  white female
#> 812     Latoya female black    0 black, female
#> 813       Anne female white    0  white female
#> 814      Emily female white    0  white female
#> 815     Keisha female black    0 black, female
#> 816      Kenya female black    0 black, female
#> 817     Carrie female white    0  white female
#> 818      Ebony female black    0 black, female
#> 819   Meredith female white    0  white female
#> 820     Tamika female black    0 black, female
#> 821    Kristen female white    1  white female
#> 822     Laurie female white    0  white female
#> 823     Tamika female black    0 black, female
#> 824    Tanisha female black    0 black, female
#> 825     Carrie female white    0  white female
#> 826      Emily female white    0  white female
#> 827     Keisha female black    0 black, female
#> 828     Tamika female black    0 black, female
#> 829    Allison female white    0  white female
#> 830       Brad   male white    0    white male
#> 831       Brad   male white    0    white male
#> 832    Brendan   male white    0    white male
#> 833      Brett   male white    0    white male
#> 834      Brett   male white    0    white male
#> 835     Carrie female white    0  white female
#> 836      Emily female white    0  white female
#> 837       Greg   male white    0    white male
#> 838      Hakim   male black    0    black male
#> 839      Hakim   male black    0    black male
#> 840      Hakim   male black    0    black male
#> 841      Jamal   male black    0    black male
#> 842        Jay   male white    0    white male
#> 843     Keisha female black    0 black, female
#> 844     Keisha female black    0 black, female
#> 845     Keisha female black    0 black, female
#> 846     Keisha female black    0 black, female
#> 847     Keisha female black    0 black, female
#> 848     Keisha female black    0 black, female
#> 849      Kenya female black    0 black, female
#> 850    Kristen female white    0  white female
#> 851    Matthew   male white    0    white male
#> 852   Meredith female white    0  white female
#> 853      Sarah female white    0  white female
#> 854      Sarah female white    0  white female
#> 855       Todd   male white    0    white male
#> 856   Tremayne   male black    0    black male
#> 857     Tyrone   male black    0    black male
#> 858     Tyrone   male black    0    black male
#> 859     Tyrone   male black    0    black male
#> 860     Tyrone   male black    0    black male
#> 861    Allison female white    0  white female
#> 862       Anne female white    0  white female
#> 863    Latonya female black    0 black, female
#> 864     Tamika female black    0 black, female
#> 865       Jill female white    0  white female
#> 866      Kenya female black    0 black, female
#> 867   Meredith female white    0  white female
#> 868     Tamika female black    0 black, female
#> 869    Allison female white    0  white female
#> 870      Ebony female black    0 black, female
#> 871      Emily female white    0  white female
#> 872     Latoya female black    0 black, female
#> 873    Kristen female white    0  white female
#> 874    Latonya female black    0 black, female
#> 875     Laurie female white    0  white female
#> 876    Tanisha female black    0 black, female
#> 877       Anne female white    0  white female
#> 878      Kenya female black    0 black, female
#> 879    Lakisha female black    0 black, female
#> 880   Meredith female white    0  white female
#> 881      Emily female white    0  white female
#> 882   Meredith female white    0  white female
#> 883    Tanisha female black    0 black, female
#> 884     Tyrone   male black    0    black male
#> 885      Aisha female black    0 black, female
#> 886    Allison female white    1  white female
#> 887     Carrie female white    1  white female
#> 888     Latoya female black    0 black, female
#> 889       Anne female white    1  white female
#> 890     Tamika female black    0 black, female
#> 891      Aisha female black    0 black, female
#> 892     Carrie female white    0  white female
#> 893      Ebony female black    0 black, female
#> 894   Meredith female white    0  white female
#> 895       Anne female white    0  white female
#> 896    Lakisha female black    0 black, female
#> 897    Latonya female black    0 black, female
#> 898   Meredith female white    1  white female
#> 899      Aisha female black    0 black, female
#> 900      Emily female white    0  white female
#> 901       Jill female white    0  white female
#> 902     Keisha female black    0 black, female
#> 903    Allison female white    0  white female
#> 904     Latoya female black    0 black, female
#> 905   Meredith female white    0  white female
#> 906    Tanisha female black    0 black, female
#> 907     Carrie female white    0  white female
#> 908      Kenya female black    0 black, female
#> 909    Latonya female black    0 black, female
#> 910      Sarah female white    1  white female
#> 911    Allison female white    1  white female
#> 912      Ebony female black    0 black, female
#> 913      Sarah female white    0  white female
#> 914    Tanisha female black    0 black, female
#> 915       Anne female white    0  white female
#> 916      Ebony female black    0 black, female
#> 917     Keisha female black    0 black, female
#> 918    Kristen female white    0  white female
#> 919    Allison female white    0  white female
#> 920      Emily female white    0  white female
#> 921    Latonya female black    0 black, female
#> 922     Latoya female black    0 black, female
#> 923       Jill female white    0  white female
#> 924     Latoya female black    0 black, female
#> 925      Sarah female white    1  white female
#> 926     Tamika female black    1 black, female
#> 927       Anne female white    0  white female
#> 928       Jill female white    0  white female
#> 929     Keisha female black    0 black, female
#> 930      Kenya female black    0 black, female
#> 931     Latoya female black    0 black, female
#> 932     Laurie female white    0  white female
#> 933   Meredith female white    0  white female
#> 934     Tamika female black    0 black, female
#> 935      Aisha female black    0 black, female
#> 936       Anne female white    0  white female
#> 937     Keisha female black    0 black, female
#> 938     Laurie female white    0  white female
#> 939     Carrie female white    0  white female
#> 940      Kenya female black    0 black, female
#> 941    Lakisha female black    0 black, female
#> 942     Laurie female white    0  white female
#> 943      Emily female white    0  white female
#> 944       Greg   male white    0    white male
#> 945    Lakisha female black    0 black, female
#> 946     Latoya female black    0 black, female
#> 947       Jill female white    0  white female
#> 948    Kristen female white    0  white female
#> 949     Latoya female black    0 black, female
#> 950     Tamika female black    0 black, female
#> 951      Ebony female black    0 black, female
#> 952      Emily female white    0  white female
#> 953    Kristen female white    1  white female
#> 954     Latoya female black    0 black, female
#> 955    Allison female white    0  white female
#> 956     Latoya female black    0 black, female
#> 957     Carrie female white    0  white female
#> 958     Keisha female black    0 black, female
#> 959    Kristen female white    0  white female
#> 960     Latoya female black    0 black, female
#> 961    Allison female white    0  white female
#> 962       Anne female white    0  white female
#> 963    Lakisha female black    0 black, female
#> 964     Tamika female black    0 black, female
#> 965      Ebony female black    0 black, female
#> 966    Kristen female white    0  white female
#> 967   Meredith female white    0  white female
#> 968    Tanisha female black    0 black, female
#> 969    Allison female white    0  white female
#> 970      Emily female white    0  white female
#> 971     Tamika female black    0 black, female
#> 972    Tanisha female black    0 black, female
#> 973    Allison female white    0  white female
#> 974      Kenya female black    0 black, female
#> 975     Laurie female white    0  white female
#> 976     Tamika female black    0 black, female
#> 977    Allison female white    1  white female
#> 978      Ebony female black    0 black, female
#> 979       Jill female white    0  white female
#> 980     Keisha female black    0 black, female
#> 981    Allison female white    0  white female
#> 982     Carrie female white    0  white female
#> 983      Ebony female black    0 black, female
#> 984     Tamika female black    0 black, female
#> 985     Carrie female white    0  white female
#> 986     Keisha female black    0 black, female
#> 987      Kenya female black    0 black, female
#> 988      Sarah female white    1  white female
#> 989      Ebony female black    1 black, female
#> 990     Laurie female white    0  white female
#> 991    Allison female white    0  white female
#> 992     Keisha female black    0 black, female
#> 993    Kristen female white    0  white female
#> 994     Tamika female black    0 black, female
#> 995      Ebony female black    0 black, female
#> 996     Keisha female black    0 black, female
#> 997   Meredith female white    0  white female
#> 998      Sarah female white    0  white female
#> 999       Anne female white    0  white female
#> 1000      Brad   male white    0    white male
#> 1001     Brett   male white    0    white male
#> 1002     Brett   male white    0    white male
#> 1003   Darnell   male black    0    black male
#> 1004     Ebony female black    0 black, female
#> 1005     Emily female white    0  white female
#> 1006  Geoffrey   male white    0    white male
#> 1007     Jamal   male black    0    black male
#> 1008       Jay   male white    0    white male
#> 1009       Jay   male white    1    white male
#> 1010  Jermaine   male black    0    black male
#> 1011  Jermaine   male black    0    black male
#> 1012      Jill female white    0  white female
#> 1013      Jill female white    0  white female
#> 1014    Kareem   male black    0    black male
#> 1015    Keisha female black    0 black, female
#> 1016     Kenya female black    0 black, female
#> 1017   Kristen female white    0  white female
#> 1018   Latonya female black    0 black, female
#> 1019   Latonya female black    0 black, female
#> 1020   Latonya female black    0 black, female
#> 1021    Laurie female white    0  white female
#> 1022     Leroy   male black    0    black male
#> 1023     Leroy   male black    0    black male
#> 1024     Leroy   male black    0    black male
#> 1025     Leroy   male black    0    black male
#> 1026   Matthew   male white    0    white male
#> 1027  Meredith female white    0  white female
#> 1028      Neil   male white    0    white male
#> 1029      Neil   male white    0    white male
#> 1030      Neil   male white    0    white male
#> 1031      Neil   male white    0    white male
#> 1032   Rasheed   male black    0    black male
#> 1033   Rasheed   male black    0    black male
#> 1034   Tanisha female black    0 black, female
#> 1035      Todd   male white    0    white male
#> 1036      Todd   male white    0    white male
#> 1037    Tyrone   male black    0    black male
#> 1038    Tyrone   male black    0    black male
#> 1039   Allison female white    0  white female
#> 1040      Jill female white    0  white female
#> 1041   Latonya female black    0 black, female
#> 1042    Tamika female black    0 black, female
#> 1043      Jill female white    0  white female
#> 1044     Kenya female black    0 black, female
#> 1045   Kristen female white    0  white female
#> 1046    Tamika female black    0 black, female
#> 1047     Brett   male white    0    white male
#> 1048     Hakim   male black    0    black male
#> 1049    Laurie female white    1  white female
#> 1050   Rasheed   male black    0    black male
#> 1051    Carrie female white    0  white female
#> 1052     Ebony female black    0 black, female
#> 1053   Latonya female black    0 black, female
#> 1054  Meredith female white    0  white female
#> 1055   Allison female white    0  white female
#> 1056     Ebony female black    0 black, female
#> 1057    Latoya female black    0 black, female
#> 1058    Laurie female white    0  white female
#> 1059    Carrie female white    0  white female
#> 1060     Kenya female black    0 black, female
#> 1061   Lakisha female black    0 black, female
#> 1062  Meredith female white    0  white female
#> 1063     Aisha female black    0 black, female
#> 1064      Anne female white    0  white female
#> 1065   Kristen female white    0  white female
#> 1066   Tanisha female black    0 black, female
#> 1067      Anne female white    0  white female
#> 1068      Anne female white    0  white female
#> 1069     Ebony female black    0 black, female
#> 1070   Tanisha female black    0 black, female
#> 1071     Kenya female black    0 black, female
#> 1072   Kristen female white    0  white female
#> 1073  Meredith female white    0  white female
#> 1074   Tanisha female black    0 black, female
#> 1075     Aisha female black    0 black, female
#> 1076    Carrie female white    0  white female
#> 1077   Latonya female black    0 black, female
#> 1078    Laurie female white    0  white female
#> 1079     Ebony female black    0 black, female
#> 1080      Jill female white    1  white female
#> 1081    Keisha female black    0 black, female
#> 1082    Laurie female white    0  white female
#> 1083     Ebony female black    0 black, female
#> 1084     Emily female white    0  white female
#> 1085    Laurie female white    0  white female
#> 1086    Tamika female black    0 black, female
#> 1087      Jill female white    0  white female
#> 1088   Lakisha female black    0 black, female
#> 1089    Latoya female black    0 black, female
#> 1090    Laurie female white    0  white female
#> 1091      Anne female white    0  white female
#> 1092     Kenya female black    0 black, female
#> 1093    Latoya female black    0 black, female
#> 1094    Laurie female white    0  white female
#> 1095   Allison female white    0  white female
#> 1096      Jill female white    0  white female
#> 1097     Kenya female black    0 black, female
#> 1098   Lakisha female black    0 black, female
#> 1099   Kristen female white    0  white female
#> 1100    Latoya female black    0 black, female
#> 1101     Sarah female white    0  white female
#> 1102   Tanisha female black    0 black, female
#> 1103     Emily female white    0  white female
#> 1104      Jill female white    0  white female
#> 1105   Lakisha female black    0 black, female
#> 1106   Latonya female black    0 black, female
#> 1107      Neil   male white    0    white male
#> 1108    Tyrone   male black    0    black male
#> 1109   Allison female white    0  white female
#> 1110      Anne female white    0  white female
#> 1111     Kenya female black    0 black, female
#> 1112    Tamika female black    0 black, female
#> 1113   Kristen female white    1  white female
#> 1114    Tamika female black    0 black, female
#> 1115      Anne female white    0  white female
#> 1116     Ebony female black    0 black, female
#> 1117      Jill female white    0  white female
#> 1118   Tanisha female black    0 black, female
#> 1119     Aisha female black    0 black, female
#> 1120   Allison female white    0  white female
#> 1121    Latoya female black    0 black, female
#> 1122    Laurie female white    0  white female
#> 1123   Allison female white    0  white female
#> 1124      Anne female white    0  white female
#> 1125   Latonya female black    0 black, female
#> 1126    Latoya female black    0 black, female
#> 1127     Ebony female black    0 black, female
#> 1128      Jill female white    0  white female
#> 1129    Keisha female black    0 black, female
#> 1130    Laurie female white    0  white female
#> 1131     Aisha female black    0 black, female
#> 1132     Emily female white    0  white female
#> 1133      Jill female white    0  white female
#> 1134    Keisha female black    0 black, female
#> 1135     Aisha female black    0 black, female
#> 1136   Brendan   male white    0    white male
#> 1137   Brendan   male white    0    white male
#> 1138    Carrie female white    0  white female
#> 1139   Darnell   male black    0    black male
#> 1140     Ebony female black    0 black, female
#> 1141  Geoffrey   male white    0    white male
#> 1142     Jamal   male black    0    black male
#> 1143     Jamal   male black    0    black male
#> 1144       Jay   male white    0    white male
#> 1145       Jay   male white    0    white male
#> 1146  Jermaine   male black    0    black male
#> 1147      Jill female white    0  white female
#> 1148    Kareem   male black    0    black male
#> 1149   Kristen female white    0  white female
#> 1150    Latoya female black    0 black, female
#> 1151     Leroy   male black    0    black male
#> 1152     Leroy   male black    0    black male
#> 1153      Neil   male white    0    white male
#> 1154   Rasheed   male black    0    black male
#> 1155     Sarah female white    0  white female
#> 1156      Todd   male white    0    white male
#> 1157      Todd   male white    0    white male
#> 1158  Tremayne   male black    0    black male
#> 1159   Allison female white    0  white female
#> 1160      Anne female white    0  white female
#> 1161    Latoya female black    0 black, female
#> 1162    Tamika female black    0 black, female
#> 1163   Latonya female black    0 black, female
#> 1164    Laurie female white    1  white female
#> 1165  Meredith female white    1  white female
#> 1166    Tamika female black    1 black, female
#> 1167     Emily female white    0  white female
#> 1168     Kenya female black    0 black, female
#> 1169   Kristen female white    0  white female
#> 1170   Tanisha female black    0 black, female
#> 1171     Ebony female black    0 black, female
#> 1172     Emily female white    1  white female
#> 1173    Latoya female black    0 black, female
#> 1174     Sarah female white    0  white female
#> 1175     Ebony female black    0 black, female
#> 1176      Jill female white    0  white female
#> 1177   Kristen female white    0  white female
#> 1178   Tanisha female black    0 black, female
#> 1179     Emily female white    0  white female
#> 1180     Kenya female black    0 black, female
#> 1181     Sarah female white    0  white female
#> 1182    Tamika female black    0 black, female
#> 1183     Ebony female black    0 black, female
#> 1184   Kristen female white    0  white female
#> 1185    Laurie female white    0  white female
#> 1186   Tanisha female black    0 black, female
#> 1187   Allison female white    1  white female
#> 1188     Ebony female black    0 black, female
#> 1189    Kareem   male black    0    black male
#> 1190      Neil   male white    0    white male
#> 1191     Aisha female black    0 black, female
#> 1192      Anne female white    0  white female
#> 1193     Ebony female black    0 black, female
#> 1194      Jill female white    0  white female
#> 1195      Jill female white    0  white female
#> 1196    Keisha female black    0 black, female
#> 1197   Lakisha female black    0 black, female
#> 1198  Meredith female white    0  white female
#> 1199     Aisha female black    0 black, female
#> 1200      Anne female white    0  white female
#> 1201    Carrie female white    0  white female
#> 1202     Kenya female black    0 black, female
#> 1203     Aisha female black    0 black, female
#> 1204     Emily female white    0  white female
#> 1205  Meredith female white    0  white female
#> 1206   Tanisha female black    0 black, female
#> 1207     Aisha female black    0 black, female
#> 1208   Allison female white    0  white female
#> 1209     Emily female white    0  white female
#> 1210     Kenya female black    0 black, female
#> 1211   Allison female white    0  white female
#> 1212   Kristen female white    1  white female
#> 1213   Lakisha female black    1 black, female
#> 1214    Tamika female black    1 black, female
#> 1215     Aisha female black    0 black, female
#> 1216     Emily female white    0  white female
#> 1217   Kristen female white    0  white female
#> 1218   Tanisha female black    0 black, female
#> 1219     Aisha female black    0 black, female
#> 1220    Carrie female white    0  white female
#> 1221  Meredith female white    0  white female
#> 1222   Tanisha female black    0 black, female
#> 1223      Anne female white    0  white female
#> 1224      Jill female white    0  white female
#> 1225   Lakisha female black    0 black, female
#> 1226   Tanisha female black    0 black, female
#> 1227     Emily female white    0  white female
#> 1228    Latoya female black    0 black, female
#> 1229  Meredith female white    0  white female
#> 1230    Tamika female black    0 black, female
#> 1231   Allison female white    0  white female
#> 1232   Latonya female black    0 black, female
#> 1233  Meredith female white    0  white female
#> 1234    Tamika female black    0 black, female
#> 1235     Leroy   male black    0    black male
#> 1236   Matthew   male white    0    white male
#> 1237      Neil   male white    0    white male
#> 1238    Tyrone   male black    0    black male
#> 1239  Meredith female white    0  white female
#> 1240   Tanisha female black    0 black, female
#> 1241    Carrie female white    0  white female
#> 1242     Emily female white    0  white female
#> 1243    Keisha female black    0 black, female
#> 1244   Lakisha female black    0 black, female
#> 1245   Allison female white    0  white female
#> 1246     Ebony female black    0 black, female
#> 1247    Latoya female black    0 black, female
#> 1248    Laurie female white    0  white female
#> 1249   Allison female white    0  white female
#> 1250      Anne female white    0  white female
#> 1251      Brad   male white    0    white male
#> 1252     Brett   male white    0    white male
#> 1253   Darnell   male black    0    black male
#> 1254   Darnell   male black    1    black male
#> 1255   Darnell   male black    0    black male
#> 1256     Ebony female black    0 black, female
#> 1257     Emily female white    0  white female
#> 1258  Geoffrey   male white    0    white male
#> 1259  Geoffrey   male white    0    white male
#> 1260       Jay   male white    0    white male
#> 1261  Jermaine   male black    0    black male
#> 1262      Jill female white    0  white female
#> 1263    Keisha female black    1 black, female
#> 1264    Keisha female black    0 black, female
#> 1265   Lakisha female black    0 black, female
#> 1266   Latonya female black    0 black, female
#> 1267    Latoya female black    0 black, female
#> 1268  Meredith female white    0  white female
#> 1269  Meredith female white    0  white female
#> 1270      Neil   male white    0    white male
#> 1271   Rasheed   male black    0    black male
#> 1272      Todd   male white    0    white male
#> 1273      Todd   male white    0    white male
#> 1274  Tremayne   male black    0    black male
#> 1275    Tyrone   male black    0    black male
#> 1276    Tyrone   male black    0    black male
#> 1277     Emily female white    0  white female
#> 1278   Lakisha female black    0 black, female
#> 1279     Sarah female white    1  white female
#> 1280   Tanisha female black    0 black, female
#> 1281   Allison female white    0  white female
#> 1282     Kenya female black    0 black, female
#> 1283   Latonya female black    0 black, female
#> 1284  Meredith female white    1  white female
#> 1285      Anne female white    0  white female
#> 1286     Ebony female black    0 black, female
#> 1287     Emily female white    0  white female
#> 1288    Tamika female black    0 black, female
#> 1289      Anne female white    0  white female
#> 1290     Kenya female black    0 black, female
#> 1291   Latonya female black    0 black, female
#> 1292     Sarah female white    0  white female
#> 1293     Ebony female black    0 black, female
#> 1294   Kristen female white    0  white female
#> 1295    Laurie female white    0  white female
#> 1296    Tamika female black    0 black, female
#> 1297   Allison female white    0  white female
#> 1298      Jill female white    0  white female
#> 1299     Kenya female black    0 black, female
#> 1300   Lakisha female black    0 black, female
#> 1301      Anne female white    1  white female
#> 1302     Emily female white    0  white female
#> 1303     Kenya female black    0 black, female
#> 1304    Latoya female black    0 black, female
#> 1305     Ebony female black    0 black, female
#> 1306     Emily female white    0  white female
#> 1307      Jill female white    0  white female
#> 1308    Tamika female black    0 black, female
#> 1309   Allison female white    1  white female
#> 1310     Hakim   male black    1    black male
#> 1311     Jamal   male black    1    black male
#> 1312       Jay   male white    1    white male
#> 1313      Anne female white    0  white female
#> 1314     Emily female white    0  white female
#> 1315   Lakisha female black    0 black, female
#> 1316   Latonya female black    0 black, female
#> 1317      Anne female white    0  white female
#> 1318     Ebony female black    0 black, female
#> 1319     Sarah female white    0  white female
#> 1320   Tanisha female black    0 black, female
#> 1321    Laurie female white    0  white female
#> 1322    Tamika female black    0 black, female
#> 1323     Emily female white    0  white female
#> 1324    Keisha female black    0 black, female
#> 1325    Latoya female black    0 black, female
#> 1326  Meredith female white    0  white female
#> 1327   Kristen female white    0  white female
#> 1328    Latoya female black    0 black, female
#> 1329  Meredith female white    0  white female
#> 1330   Tanisha female black    0 black, female
#> 1331      Anne female white    1  white female
#> 1332     Kenya female black    1 black, female
#> 1333     Sarah female white    1  white female
#> 1334   Tanisha female black    1 black, female
#> 1335    Carrie female white    0  white female
#> 1336     Emily female white    0  white female
#> 1337    Keisha female black    0 black, female
#> 1338     Kenya female black    0 black, female
#> 1339      Anne female white    0  white female
#> 1340     Emily female white    0  white female
#> 1341    Keisha female black    0 black, female
#> 1342   Tanisha female black    0 black, female
#> 1343     Emily female white    0  white female
#> 1344     Kenya female black    0 black, female
#> 1345   Latonya female black    0 black, female
#> 1346     Sarah female white    0  white female
#> 1347     Emily female white    0  white female
#> 1348   Latonya female black    0 black, female
#> 1349    Latoya female black    0 black, female
#> 1350     Sarah female white    0  white female
#> 1351     Emily female white    0  white female
#> 1352      Jill female white    0  white female
#> 1353   Lakisha female black    0 black, female
#> 1354   Latonya female black    0 black, female
#> 1355      Anne female white    0  white female
#> 1356     Ebony female black    0 black, female
#> 1357    Latoya female black    0 black, female
#> 1358  Meredith female white    0  white female
#> 1359   Allison female white    0  white female
#> 1360     Ebony female black    0 black, female
#> 1361     Emily female white    0  white female
#> 1362    Latoya female black    0 black, female
#> 1363      Anne female white    0  white female
#> 1364     Emily female white    0  white female
#> 1365    Keisha female black    0 black, female
#> 1366    Tamika female black    0 black, female
#> 1367      Jill female white    0  white female
#> 1368   Lakisha female black    0 black, female
#> 1369     Sarah female white    0  white female
#> 1370    Tamika female black    0 black, female
#> 1371    Carrie female white    1  white female
#> 1372   Lakisha female black    0 black, female
#> 1373    Laurie female white    0  white female
#> 1374   Tanisha female black    0 black, female
#> 1375     Aisha female black    0 black, female
#> 1376     Aisha female black    0 black, female
#> 1377     Aisha female black    0 black, female
#> 1378      Anne female white    0  white female
#> 1379      Brad   male white    0    white male
#> 1380      Brad   male white    0    white male
#> 1381    Carrie female white    0  white female
#> 1382    Carrie female white    0  white female
#> 1383     Emily female white    0  white female
#> 1384  Geoffrey   male white    0    white male
#> 1385     Hakim   male black    0    black male
#> 1386       Jay   male white    0    white male
#> 1387  Jermaine   male black    0    black male
#> 1388    Keisha female black    0 black, female
#> 1389     Kenya female black    0 black, female
#> 1390   Kristen female white    0  white female
#> 1391   Kristen female white    0  white female
#> 1392   Kristen female white    0  white female
#> 1393   Lakisha female black    0 black, female
#> 1394   Lakisha female black    0 black, female
#> 1395   Latonya female black    0 black, female
#> 1396    Latoya female black    0 black, female
#> 1397     Leroy   male black    0    black male
#> 1398   Matthew   male white    0    white male
#> 1399   Matthew   male white    0    white male
#> 1400      Neil   male white    0    white male
#> 1401   Rasheed   male black    0    black male
#> 1402     Sarah female white    0  white female
#> 1403      Todd   male white    0    white male
#> 1404  Tremayne   male black    0    black male
#> 1405  Tremayne   male black    0    black male
#> 1406    Tyrone   male black    0    black male
#> 1407    Latoya female black    1 black, female
#> 1408  Meredith female white    1  white female
#> 1409     Sarah female white    1  white female
#> 1410   Tanisha female black    1 black, female
#> 1411      Jill female white    1  white female
#> 1412   Kristen female white    0  white female
#> 1413    Tamika female black    0 black, female
#> 1414   Tanisha female black    0 black, female
#> 1415      Anne female white    0  white female
#> 1416     Ebony female black    0 black, female
#> 1417   Lakisha female black    0 black, female
#> 1418    Laurie female white    0  white female
#> 1419   Allison female white    0  white female
#> 1420     Emily female white    0  white female
#> 1421     Kenya female black    0 black, female
#> 1422    Tamika female black    0 black, female
#> 1423   Latonya female black    0 black, female
#> 1424    Laurie female white    0  white female
#> 1425  Meredith female white    0  white female
#> 1426    Tamika female black    0 black, female
#> 1427   Kristen female white    0  white female
#> 1428   Latonya female black    0 black, female
#> 1429     Sarah female white    0  white female
#> 1430   Tanisha female black    0 black, female
#> 1431   Allison female white    1  white female
#> 1432      Anne female white    0  white female
#> 1433   Lakisha female black    0 black, female
#> 1434    Tamika female black    0 black, female
#> 1435      Anne female white    1  white female
#> 1436     Emily female white    1  white female
#> 1437   Lakisha female black    0 black, female
#> 1438    Latoya female black    0 black, female
#> 1439    Carrie female white    0  white female
#> 1440     Ebony female black    0 black, female
#> 1441    Laurie female white    0  white female
#> 1442   Tanisha female black    0 black, female
#> 1443    Carrie female white    1  white female
#> 1444     Ebony female black    0 black, female
#> 1445   Kristen female white    1  white female
#> 1446   Tanisha female black    0 black, female
#> 1447      Jill female white    1  white female
#> 1448   Lakisha female black    1 black, female
#> 1449     Aisha female black    0 black, female
#> 1450      Anne female white    0  white female
#> 1451      Jill female white    0  white female
#> 1452    Tamika female black    0 black, female
#> 1453     Aisha female black    0 black, female
#> 1454   Allison female white    0  white female
#> 1455    Carrie female white    0  white female
#> 1456    Latoya female black    0 black, female
#> 1457      Anne female white    0  white female
#> 1458     Emily female white    0  white female
#> 1459    Latoya female black    0 black, female
#> 1460    Tamika female black    0 black, female
#> 1461      Anne female white    0  white female
#> 1462     Emily female white    0  white female
#> 1463     Kenya female black    0 black, female
#> 1464    Latoya female black    0 black, female
#> 1465    Carrie female white    0  white female
#> 1466     Emily female white    0  white female
#> 1467    Keisha female black    0 black, female
#> 1468    Tamika female black    0 black, female
#> 1469      Anne female white    0  white female
#> 1470   Lakisha female black    0 black, female
#> 1471   Latonya female black    0 black, female
#> 1472  Meredith female white    0  white female
#> 1473      Anne female white    0  white female
#> 1474     Kenya female black    0 black, female
#> 1475   Kristen female white    0  white female
#> 1476    Latoya female black    0 black, female
#> 1477   Kristen female white    0  white female
#> 1478    Latoya female black    0 black, female
#> 1479     Aisha female black    0 black, female
#> 1480      Jill female white    0  white female
#> 1481   Kristen female white    0  white female
#> 1482   Lakisha female black    0 black, female
#> 1483      Anne female white    0  white female
#> 1484     Kenya female black    0 black, female
#> 1485   Kristen female white    0  white female
#> 1486    Tamika female black    0 black, female
#> 1487   Allison female white    0  white female
#> 1488    Keisha female black    0 black, female
#> 1489     Kenya female black    0 black, female
#> 1490     Sarah female white    0  white female
#> 1491   Brendan   male white    0    white male
#> 1492     Brett   male white    0    white male
#> 1493  Jermaine   male black    0    black male
#> 1494    Tyrone   male black    0    black male
#> 1495      Jill female white    1  white female
#> 1496     Kenya female black    0 black, female
#> 1497    Latoya female black    0 black, female
#> 1498    Laurie female white    1  white female
#> 1499    Keisha female black    0 black, female
#> 1500   Lakisha female black    0 black, female
#> 1501    Laurie female white    0  white female
#> 1502     Sarah female white    0  white female
#> 1503     Emily female white    0  white female
#> 1504     Kenya female black    0 black, female
#> 1505     Kenya female black    0 black, female
#> 1506   Lakisha female black    0 black, female
#> 1507    Laurie female white    0  white female
#> 1508     Sarah female white    0  white female
#> 1509      Anne female white    0  white female
#> 1510   Lakisha female black    0 black, female
#> 1511   Latonya female black    0 black, female
#> 1512  Meredith female white    0  white female
#> 1513     Ebony female black    0 black, female
#> 1514   Kristen female white    0  white female
#> 1515   Latonya female black    0 black, female
#> 1516  Meredith female white    0  white female
#> 1517     Aisha female black    0 black, female
#> 1518     Aisha female black    0 black, female
#> 1519     Aisha female black    0 black, female
#> 1520      Brad   male white    1    white male
#> 1521      Brad   male white    0    white male
#> 1522   Brendan   male white    0    white male
#> 1523   Brendan   male white    0    white male
#> 1524     Brett   male white    1    white male
#> 1525    Carrie female white    0  white female
#> 1526     Hakim   male black    0    black male
#> 1527       Jay   male white    0    white male
#> 1528    Kareem   male black    0    black male
#> 1529     Kenya female black    1 black, female
#> 1530   Kristen female white    0  white female
#> 1531   Lakisha female black    0 black, female
#> 1532   Lakisha female black    0 black, female
#> 1533   Latonya female black    1 black, female
#> 1534     Leroy   male black    0    black male
#> 1535     Leroy   male black    0    black male
#> 1536   Matthew   male white    0    white male
#> 1537   Matthew   male white    0    white male
#> 1538      Neil   male white    0    white male
#> 1539      Neil   male white    0    white male
#> 1540      Neil   male white    0    white male
#> 1541     Sarah female white    0  white female
#> 1542  Tremayne   male black    0    black male
#> 1543    Tyrone   male black    0    black male
#> 1544    Tyrone   male black    0    black male
#> 1545      Anne female white    0  white female
#> 1546   Lakisha female black    0 black, female
#> 1547    Latoya female black    0 black, female
#> 1548     Sarah female white    1  white female
#> 1549     Aisha female black    0 black, female
#> 1550      Anne female white    0  white female
#> 1551     Sarah female white    0  white female
#> 1552   Tanisha female black    0 black, female
#> 1553    Carrie female white    0  white female
#> 1554     Ebony female black    0 black, female
#> 1555     Kenya female black    0 black, female
#> 1556   Kristen female white    0  white female
#> 1557     Aisha female black    0 black, female
#> 1558   Allison female white    0  white female
#> 1559     Ebony female black    1 black, female
#> 1560      Jill female white    0  white female
#> 1561   Allison female white    0  white female
#> 1562     Emily female white    1  white female
#> 1563    Latoya female black    0 black, female
#> 1564    Tamika female black    1 black, female
#> 1565     Aisha female black    0 black, female
#> 1566    Carrie female white    1  white female
#> 1567      Jill female white    1  white female
#> 1568   Latonya female black    0 black, female
#> 1569     Kenya female black    0 black, female
#> 1570   Kristen female white    0  white female
#> 1571    Latoya female black    0 black, female
#> 1572     Sarah female white    0  white female
#> 1573     Emily female white    0  white female
#> 1574      Jill female white    1  white female
#> 1575     Kenya female black    0 black, female
#> 1576    Latoya female black    0 black, female
#> 1577     Emily female white    1  white female
#> 1578     Kenya female black    0 black, female
#> 1579   Lakisha female black    0 black, female
#> 1580     Sarah female white    0  white female
#> 1581      Brad   male white    1    white male
#> 1582     Hakim   male black    1    black male
#> 1583      Todd   male white    1    white male
#> 1584  Tremayne   male black    1    black male
#> 1585      Anne female white    0  white female
#> 1586     Kenya female black    0 black, female
#> 1587   Kristen female white    0  white female
#> 1588   Latonya female black    0 black, female
#> 1589   Allison female white    0  white female
#> 1590    Keisha female black    1 black, female
#> 1591   Kristen female white    0  white female
#> 1592    Tamika female black    0 black, female
#> 1593      Jill female white    0  white female
#> 1594   Kristen female white    0  white female
#> 1595    Latoya female black    0 black, female
#> 1596    Tamika female black    0 black, female
#> 1597   Allison female white    0  white female
#> 1598   Latonya female black    0 black, female
#> 1599  Meredith female white    0  white female
#> 1600    Tamika female black    0 black, female
#> 1601     Aisha female black    0 black, female
#> 1602     Emily female white    0  white female
#> 1603    Laurie female white    0  white female
#> 1604   Tanisha female black    0 black, female
#> 1605      Jill female white    0  white female
#> 1606     Kenya female black    0 black, female
#> 1607   Latonya female black    0 black, female
#> 1608  Meredith female white    0  white female
#> 1609    Carrie female white    0  white female
#> 1610     Ebony female black    0 black, female
#> 1611   Latonya female black    0 black, female
#> 1612     Sarah female white    0  white female
#> 1613   Kristen female white    0  white female
#> 1614    Latoya female black    0 black, female
#> 1615    Laurie female white    0  white female
#> 1616    Tamika female black    0 black, female
#> 1617     Kenya female black    0 black, female
#> 1618   Kristen female white    0  white female
#> 1619    Laurie female white    0  white female
#> 1620    Tamika female black    0 black, female
#> 1621      Anne female white    0  white female
#> 1622     Ebony female black    0 black, female
#> 1623      Jill female white    0  white female
#> 1624   Latonya female black    0 black, female
#> 1625      Anne female white    0  white female
#> 1626     Kenya female black    0 black, female
#> 1627   Latonya female black    0 black, female
#> 1628  Meredith female white    0  white female
#> 1629      Anne female white    0  white female
#> 1630    Keisha female black    0 black, female
#> 1631   Kristen female white    0  white female
#> 1632   Latonya female black    0 black, female
#> 1633    Carrie female white    0  white female
#> 1634     Ebony female black    0 black, female
#> 1635     Emily female white    0  white female
#> 1636    Tamika female black    0 black, female
#> 1637     Brett   male white    0    white male
#> 1638      Neil   male white    0    white male
#> 1639   Rasheed   male black    0    black male
#> 1640    Tyrone   male black    0    black male
#> 1641   Brendan   male white    0    white male
#> 1642     Jamal   male black    0    black male
#> 1643     Aisha female black    0 black, female
#> 1644   Allison female white    0  white female
#> 1645    Carrie female white    0  white female
#> 1646    Latoya female black    0 black, female
#> 1647     Aisha female black    0 black, female
#> 1648   Allison female white    0  white female
#> 1649      Jill female white    0  white female
#> 1650    Tamika female black    0 black, female
#> 1651      Jill female white    0  white female
#> 1652    Keisha female black    0 black, female
#> 1653   Kristen female white    0  white female
#> 1654    Tamika female black    0 black, female
#> 1655   Allison female white    0  white female
#> 1656      Anne female white    0  white female
#> 1657      Brad   male white    0    white male
#> 1658     Brett   male white    0    white male
#> 1659     Ebony female black    0 black, female
#> 1660     Emily female white    0  white female
#> 1661  Geoffrey   male white    0    white male
#> 1662  Geoffrey   male white    0    white male
#> 1663       Jay   male white    0    white male
#> 1664    Kareem   male black    0    black male
#> 1665    Kareem   male black    0    black male
#> 1666    Keisha female black    0 black, female
#> 1667    Keisha female black    0 black, female
#> 1668     Kenya female black    0 black, female
#> 1669     Kenya female black    0 black, female
#> 1670   Kristen female white    0  white female
#> 1671    Laurie female white    0  white female
#> 1672    Laurie female white    0  white female
#> 1673     Leroy   male black    0    black male
#> 1674     Leroy   male black    0    black male
#> 1675     Leroy   male black    0    black male
#> 1676   Matthew   male white    0    white male
#> 1677  Meredith female white    0  white female
#> 1678   Rasheed   male black    0    black male
#> 1679     Sarah female white    0  white female
#> 1680   Tanisha female black    0 black, female
#> 1681    Tyrone   male black    0    black male
#> 1682    Tyrone   male black    0    black male
#> 1683    Carrie female white    0  white female
#> 1684    Laurie female white    0  white female
#> 1685    Tamika female black    0 black, female
#> 1686   Tanisha female black    0 black, female
#> 1687   Allison female white    1  white female
#> 1688     Ebony female black    0 black, female
#> 1689     Emily female white    0  white female
#> 1690    Latoya female black    0 black, female
#> 1691   Allison female white    0  white female
#> 1692     Emily female white    0  white female
#> 1693     Kenya female black    0 black, female
#> 1694   Lakisha female black    0 black, female
#> 1695    Carrie female white    1  white female
#> 1696    Latoya female black    1 black, female
#> 1697     Sarah female white    1  white female
#> 1698    Tamika female black    0 black, female
#> 1699     Aisha female black    0 black, female
#> 1700      Anne female white    0  white female
#> 1701      Jill female white    0  white female
#> 1702    Latoya female black    1 black, female
#> 1703     Ebony female black    0 black, female
#> 1704     Emily female white    0  white female
#> 1705   Kristen female white    0  white female
#> 1706   Lakisha female black    0 black, female
#> 1707      Anne female white    0  white female
#> 1708   Lakisha female black    0 black, female
#> 1709     Sarah female white    0  white female
#> 1710   Tanisha female black    0 black, female
#> 1711     Ebony female black    0 black, female
#> 1712      Jill female white    1  white female
#> 1713   Kristen female white    1  white female
#> 1714   Tanisha female black    0 black, female
#> 1715    Carrie female white    0  white female
#> 1716      Jill female white    1  white female
#> 1717    Keisha female black    0 black, female
#> 1718   Lakisha female black    1 black, female
#> 1719  Geoffrey   male white    0    white male
#> 1720     Kenya female black    0 black, female
#> 1721    Laurie female white    0  white female
#> 1722    Tamika female black    0 black, female
#> 1723     Emily female white    0  white female
#> 1724   Latonya female black    0 black, female
#> 1725    Laurie female white    0  white female
#> 1726    Tamika female black    0 black, female
#> 1727   Allison female white    0  white female
#> 1728   Lakisha female black    0 black, female
#> 1729   Lakisha female black    0 black, female
#> 1730  Meredith female white    0  white female
#> 1731     Sarah female white    0  white female
#> 1732   Tanisha female black    0 black, female
#> 1733   Allison female white    0  white female
#> 1734      Anne female white    0  white female
#> 1735     Ebony female black    0 black, female
#> 1736    Latoya female black    0 black, female
#> 1737     Aisha female black    0 black, female
#> 1738      Anne female white    1  white female
#> 1739      Jill female white    0  white female
#> 1740   Tanisha female black    0 black, female
#> 1741   Brendan   male white    1    white male
#> 1742    Keisha female black    0 black, female
#> 1743     Kenya female black    0 black, female
#> 1744     Sarah female white    1  white female
#> 1745      Todd   male white    0    white male
#> 1746    Tyrone   male black    0    black male
#> 1747     Emily female white    0  white female
#> 1748   Latonya female black    0 black, female
#> 1749      Jill female white    0  white female
#> 1750     Kenya female black    0 black, female
#> 1751     Sarah female white    0  white female
#> 1752   Tanisha female black    0 black, female
#> 1753      Jill female white    0  white female
#> 1754   Lakisha female black    0 black, female
#> 1755    Latoya female black    0 black, female
#> 1756      Neil   male white    0    white male
#> 1757    Keisha female black    0 black, female
#> 1758    Laurie female white    0  white female
#> 1759   Allison female white    0  white female
#> 1760     Ebony female black    0 black, female
#> 1761     Emily female white    0  white female
#> 1762   Latonya female black    0 black, female
#> 1763   Allison female white    0  white female
#> 1764      Jill female white    0  white female
#> 1765    Keisha female black    0 black, female
#> 1766   Kristen female white    0  white female
#> 1767    Latoya female black    0 black, female
#> 1768   Rasheed   male black    0    black male
#> 1769     Aisha female black    0 black, female
#> 1770   Allison female white    0  white female
#> 1771    Latoya female black    0 black, female
#> 1772     Sarah female white    0  white female
#> 1773   Brendan   male white    0    white male
#> 1774     Emily female white    0  white female
#> 1775    Keisha female black    0 black, female
#> 1776     Kenya female black    0 black, female
#> 1777   Lakisha female black    0 black, female
#> 1778     Sarah female white    0  white female
#> 1779     Aisha female black    0 black, female
#> 1780     Aisha female black    0 black, female
#> 1781      Anne female white    0  white female
#> 1782    Carrie female white    0  white female
#> 1783     Emily female white    0  white female
#> 1784     Kenya female black    0 black, female
#> 1785     Kenya female black    0 black, female
#> 1786   Kristen female white    0  white female
#> 1787  Meredith female white    0  white female
#> 1788   Tanisha female black    0 black, female
#> 1789   Allison female white    0  white female
#> 1790     Emily female white    0  white female
#> 1791     Kenya female black    0 black, female
#> 1792    Tamika female black    0 black, female
#> 1793     Brett   male white    0    white male
#> 1794     Hakim   male black    0    black male
#> 1795      Jill female white    0  white female
#> 1796      Jill female white    0  white female
#> 1797   Matthew   male white    0    white male
#> 1798    Tamika female black    0 black, female
#> 1799   Tanisha female black    0 black, female
#> 1800    Tyrone   male black    0    black male
#> 1801      Jill female white    0  white female
#> 1802    Tamika female black    0 black, female
#> 1803      Anne female white    0  white female
#> 1804   Latonya female black    0 black, female
#> 1805    Latoya female black    0 black, female
#> 1806     Sarah female white    0  white female
#> 1807   Allison female white    0  white female
#> 1808     Ebony female black    0 black, female
#> 1809     Emily female white    0  white female
#> 1810      Jill female white    0  white female
#> 1811     Kenya female black    0 black, female
#> 1812    Laurie female white    0  white female
#> 1813    Tamika female black    0 black, female
#> 1814   Tanisha female black    0 black, female
#> 1815     Emily female white    1  white female
#> 1816     Kenya female black    1 black, female
#> 1817   Lakisha female black    0 black, female
#> 1818      Todd   male white    0    white male
#> 1819     Aisha female black    0 black, female
#> 1820      Jill female white    0  white female
#> 1821   Lakisha female black    0 black, female
#> 1822   Matthew   male white    0    white male
#> 1823   Lakisha female black    0 black, female
#> 1824   Matthew   male white    0    white male
#> 1825      Brad   male white    0    white male
#> 1826    Tamika female black    0 black, female
#> 1827      Anne female white    0  white female
#> 1828    Keisha female black    0 black, female
#> 1829   Kristen female white    0  white female
#> 1830   Lakisha female black    0 black, female
#> 1831   Allison female white    0  white female
#> 1832     Emily female white    0  white female
#> 1833     Sarah female white    0  white female
#> 1834    Tamika female black    0 black, female
#> 1835    Tamika female black    0 black, female
#> 1836   Tanisha female black    0 black, female
#> 1837  Geoffrey   male white    0    white male
#> 1838      Jill female white    0  white female
#> 1839    Keisha female black    0 black, female
#> 1840   Kristen female white    0  white female
#> 1841    Tamika female black    0 black, female
#> 1842   Tanisha female black    0 black, female
#> 1843   Allison female white    0  white female
#> 1844      Anne female white    0  white female
#> 1845    Keisha female black    0 black, female
#> 1846   Kristen female white    1  white female
#> 1847   Lakisha female black    0 black, female
#> 1848    Latoya female black    0 black, female
#> 1849    Carrie female white    0  white female
#> 1850    Keisha female black    0 black, female
#> 1851     Kenya female black    0 black, female
#> 1852     Leroy   male black    0    black male
#> 1853      Neil   male white    0    white male
#> 1854     Sarah female white    0  white female
#> 1855      Anne female white    0  white female
#> 1856     Emily female white    0  white female
#> 1857    Keisha female black    0 black, female
#> 1858   Latonya female black    0 black, female
#> 1859    Laurie female white    0  white female
#> 1860   Tanisha female black    0 black, female
#> 1861   Allison female white    0  white female
#> 1862     Kenya female black    0 black, female
#> 1863   Latonya female black    0 black, female
#> 1864     Leroy   male black    0    black male
#> 1865  Meredith female white    0  white female
#> 1866      Todd   male white    0    white male
#> 1867     Kenya female black    0 black, female
#> 1868      Todd   male white    0    white male
#> 1869     Emily female white    0  white female
#> 1870   Latonya female black    0 black, female
#> 1871    Laurie female white    0  white female
#> 1872    Tamika female black    0 black, female
#> 1873   Allison female white    0  white female
#> 1874    Carrie female white    0  white female
#> 1875   Kristen female white    0  white female
#> 1876   Lakisha female black    0 black, female
#> 1877   Latonya female black    0 black, female
#> 1878    Tyrone   male black    0    black male
#> 1879     Aisha female black    0 black, female
#> 1880     Aisha female black    0 black, female
#> 1881     Emily female white    0  white female
#> 1882     Emily female white    0  white female
#> 1883    Keisha female black    0 black, female
#> 1884    Keisha female black    0 black, female
#> 1885   Matthew   male white    0    white male
#> 1886     Sarah female white    0  white female
#> 1887      Anne female white    0  white female
#> 1888      Brad   male white    1    white male
#> 1889     Hakim   male black    0    black male
#> 1890     Kenya female black    0 black, female
#> 1891     Kenya female black    1 black, female
#> 1892    Latoya female black    0 black, female
#> 1893  Meredith female white    1  white female
#> 1894  Meredith female white    0  white female
#> 1895     Aisha female black    0 black, female
#> 1896      Brad   male white    0    white male
#> 1897      Brad   male white    0    white male
#> 1898    Carrie female white    0  white female
#> 1899   Darnell   male black    0    black male
#> 1900     Ebony female black    0 black, female
#> 1901     Emily female white    0  white female
#> 1902  Geoffrey   male white    0    white male
#> 1903      Greg   male white    0    white male
#> 1904     Hakim   male black    0    black male
#> 1905     Jamal   male black    0    black male
#> 1906      Jill female white    0  white female
#> 1907    Keisha female black    0 black, female
#> 1908     Kenya female black    0 black, female
#> 1909   Latonya female black    0 black, female
#> 1910    Latoya female black    0 black, female
#> 1911     Leroy   male black    0    black male
#> 1912   Matthew   male white    1    white male
#> 1913   Matthew   male white    0    white male
#> 1914   Matthew   male white    0    white male
#> 1915   Matthew   male white    0    white male
#> 1916   Rasheed   male black    1    black male
#> 1917      Todd   male white    0    white male
#> 1918  Tremayne   male black    0    black male
#> 1919      Anne female white    0  white female
#> 1920     Kenya female black    0 black, female
#> 1921  Meredith female white    0  white female
#> 1922    Tamika female black    0 black, female
#> 1923      Anne female white    0  white female
#> 1924     Kenya female black    0 black, female
#> 1925  Meredith female white    0  white female
#> 1926    Tamika female black    0 black, female
#> 1927     Ebony female black    0 black, female
#> 1928   Kristen female white    0  white female
#> 1929   Latonya female black    0 black, female
#> 1930    Laurie female white    0  white female
#> 1931     Emily female white    0  white female
#> 1932      Jill female white    0  white female
#> 1933    Latoya female black    0 black, female
#> 1934   Tanisha female black    0 black, female
#> 1935    Keisha female black    1 black, female
#> 1936   Kristen female white    1  white female
#> 1937     Sarah female white    0  white female
#> 1938    Tamika female black    1 black, female
#> 1939     Emily female white    0  white female
#> 1940    Latoya female black    0 black, female
#> 1941      Jill female white    0  white female
#> 1942   Lakisha female black    0 black, female
#> 1943  Meredith female white    0  white female
#> 1944   Tanisha female black    0 black, female
#> 1945      Anne female white    0  white female
#> 1946    Latoya female black    0 black, female
#> 1947     Sarah female white    0  white female
#> 1948   Tanisha female black    0 black, female
#> 1949      Jill female white    0  white female
#> 1950   Lakisha female black    0 black, female
#> 1951    Laurie female white    1  white female
#> 1952    Tamika female black    1 black, female
#> 1953   Allison female white    0  white female
#> 1954     Kenya female black    0 black, female
#> 1955   Lakisha female black    0 black, female
#> 1956    Laurie female white    0  white female
#> 1957   Allison female white    0  white female
#> 1958      Anne female white    0  white female
#> 1959     Ebony female black    0 black, female
#> 1960     Kenya female black    0 black, female
#> 1961     Ebony female black    1 black, female
#> 1962      Jill female white    0  white female
#> 1963    Laurie female white    0  white female
#> 1964    Tamika female black    0 black, female
#> 1965     Emily female white    0  white female
#> 1966    Keisha female black    0 black, female
#> 1967     Kenya female black    0 black, female
#> 1968     Sarah female white    0  white female
#> 1969     Hakim   male black    0    black male
#> 1970     Leroy   male black    1    black male
#> 1971      Neil   male white    0    white male
#> 1972      Todd   male white    0    white male
#> 1973      Jill female white    0  white female
#> 1974    Keisha female black    0 black, female
#> 1975  Meredith female white    0  white female
#> 1976    Tamika female black    0 black, female
#> 1977      Anne female white    0  white female
#> 1978     Ebony female black    1 black, female
#> 1979      Jill female white    0  white female
#> 1980    Tamika female black    0 black, female
#> 1981     Aisha female black    0 black, female
#> 1982      Anne female white    0  white female
#> 1983     Kenya female black    0 black, female
#> 1984   Kristen female white    0  white female
#> 1985     Aisha female black    0 black, female
#> 1986      Brad   male white    1    white male
#> 1987   Brendan   male white    0    white male
#> 1988   Brendan   male white    0    white male
#> 1989     Brett   male white    0    white male
#> 1990    Carrie female white    0  white female
#> 1991     Ebony female black    0 black, female
#> 1992  Geoffrey   male white    0    white male
#> 1993     Jamal   male black    0    black male
#> 1994       Jay   male white    0    white male
#> 1995    Kareem   male black    0    black male
#> 1996     Kenya female black    0 black, female
#> 1997     Kenya female black    0 black, female
#> 1998   Lakisha female black    0 black, female
#> 1999      Neil   male white    0    white male
#> 2000     Sarah female white    0  white female
#> 2001   Tanisha female black    0 black, female
#> 2002      Todd   male white    0    white male
#> 2003    Tyrone   male black    0    black male
#> 2004    Tyrone   male black    0    black male
#> 2005     Emily female white    0  white female
#> 2006   Lakisha female black    0 black, female
#> 2007     Sarah female white    0  white female
#> 2008   Tanisha female black    0 black, female
#> 2009      Jill female white    1  white female
#> 2010   Latonya female black    1 black, female
#> 2011    Latoya female black    1 black, female
#> 2012     Sarah female white    0  white female
#> 2013    Keisha female black    0 black, female
#> 2014   Kristen female white    1  white female
#> 2015    Latoya female black    0 black, female
#> 2016     Sarah female white    0  white female
#> 2017      Jill female white    0  white female
#> 2018     Leroy   male black    0    black male
#> 2019  Meredith female white    0  white female
#> 2020   Tanisha female black    0 black, female
#> 2021     Emily female white    0  white female
#> 2022   Latonya female black    0 black, female
#> 2023    Laurie female white    0  white female
#> 2024    Tamika female black    0 black, female
#> 2025     Ebony female black    0 black, female
#> 2026     Emily female white    0  white female
#> 2027     Sarah female white    1  white female
#> 2028    Tamika female black    0 black, female
#> 2029     Aisha female black    0 black, female
#> 2030     Emily female white    0  white female
#> 2031   Kristen female white    0  white female
#> 2032   Tanisha female black    0 black, female
#> 2033     Ebony female black    0 black, female
#> 2034   Latonya female black    0 black, female
#> 2035  Meredith female white    0  white female
#> 2036     Sarah female white    0  white female
#> 2037   Kristen female white    0  white female
#> 2038   Latonya female black    0 black, female
#> 2039  Meredith female white    0  white female
#> 2040    Tamika female black    0 black, female
#> 2041   Allison female white    0  white female
#> 2042      Anne female white    0  white female
#> 2043   Lakisha female black    0 black, female
#> 2044    Tamika female black    0 black, female
#> 2045   Allison female white    0  white female
#> 2046   Latonya female black    0 black, female
#> 2047    Laurie female white    0  white female
#> 2048    Tamika female black    0 black, female
#> 2049      Jill female white    0  white female
#> 2050     Kenya female black    0 black, female
#> 2051     Sarah female white    0  white female
#> 2052    Tamika female black    0 black, female
#> 2053      Anne female white    0  white female
#> 2054   Lakisha female black    0 black, female
#> 2055     Sarah female white    0  white female
#> 2056    Tamika female black    0 black, female
#> 2057     Emily female white    0  white female
#> 2058   Lakisha female black    0 black, female
#> 2059    Latoya female black    0 black, female
#> 2060  Meredith female white    0  white female
#> 2061     Aisha female black    0 black, female
#> 2062   Brendan   male white    0    white male
#> 2063     Brett   male white    0    white male
#> 2064   Darnell   male black    0    black male
#> 2065  Geoffrey   male white    0    white male
#> 2066      Greg   male white    0    white male
#> 2067       Jay   male white    0    white male
#> 2068  Jermaine   male black    0    black male
#> 2069      Jill female white    0  white female
#> 2070    Keisha female black    0 black, female
#> 2071   Kristen female white    0  white female
#> 2072   Kristen female white    0  white female
#> 2073   Lakisha female black    0 black, female
#> 2074    Laurie female white    0  white female
#> 2075     Leroy   male black    0    black male
#> 2076     Leroy   male black    0    black male
#> 2077     Leroy   male black    0    black male
#> 2078   Matthew   male white    0    white male
#> 2079      Neil   male white    0    white male
#> 2080      Neil   male white    0    white male
#> 2081    Tamika female black    0 black, female
#> 2082    Tyrone   male black    0    black male
#> 2083    Tyrone   male black    0    black male
#> 2084    Tyrone   male black    0    black male
#> 2085      Anne female white    0  white female
#> 2086    Carrie female white    0  white female
#> 2087    Keisha female black    0 black, female
#> 2088    Latoya female black    0 black, female
#> 2089      Anne female white    0  white female
#> 2090      Jill female white    0  white female
#> 2091   Latonya female black    0 black, female
#> 2092   Tanisha female black    0 black, female
#> 2093      Anne female white    1  white female
#> 2094   Lakisha female black    1 black, female
#> 2095     Sarah female white    0  white female
#> 2096   Tanisha female black    0 black, female
#> 2097   Allison female white    1  white female
#> 2098    Carrie female white    1  white female
#> 2099   Latonya female black    1 black, female
#> 2100    Tamika female black    1 black, female
#> 2101     Aisha female black    0 black, female
#> 2102     Emily female white    0  white female
#> 2103    Latoya female black    0 black, female
#> 2104  Meredith female white    0  white female
#> 2105     Aisha female black    0 black, female
#> 2106   Allison female white    0  white female
#> 2107    Carrie female white    1  white female
#> 2108    Latoya female black    0 black, female
#> 2109     Emily female white    1  white female
#> 2110   Latonya female black    0 black, female
#> 2111    Laurie female white    1  white female
#> 2112    Tyrone   male black    0    black male
#> 2113      Anne female white    0  white female
#> 2114    Latoya female black    0 black, female
#> 2115     Sarah female white    0  white female
#> 2116   Tanisha female black    0 black, female
#> 2117     Aisha female black    0 black, female
#> 2118    Laurie female white    0  white female
#> 2119     Sarah female white    0  white female
#> 2120    Tamika female black    0 black, female
#> 2121     Aisha female black    0 black, female
#> 2122     Emily female white    0  white female
#> 2123    Laurie female white    0  white female
#> 2124   Tanisha female black    0 black, female
#> 2125     Ebony female black    0 black, female
#> 2126    Laurie female white    0  white female
#> 2127  Meredith female white    0  white female
#> 2128    Tamika female black    0 black, female
#> 2129    Latoya female black    0 black, female
#> 2130  Meredith female white    0  white female
#> 2131     Sarah female white    0  white female
#> 2132    Tamika female black    0 black, female
#> 2133   Allison female white    0  white female
#> 2134      Jill female white    0  white female
#> 2135     Kenya female black    0 black, female
#> 2136    Latoya female black    0 black, female
#> 2137     Ebony female black    0 black, female
#> 2138     Emily female white    0  white female
#> 2139      Jill female white    0  white female
#> 2140   Lakisha female black    0 black, female
#> 2141   Allison female white    0  white female
#> 2142     Emily female white    0  white female
#> 2143     Kenya female black    0 black, female
#> 2144    Tamika female black    0 black, female
#> 2145      Anne female white    0  white female
#> 2146   Kristen female white    0  white female
#> 2147   Lakisha female black    0 black, female
#> 2148    Tamika female black    0 black, female
#> 2149      Anne female white    0  white female
#> 2150    Carrie female white    0  white female
#> 2151   Latonya female black    0 black, female
#> 2152    Latoya female black    0 black, female
#> 2153      Brad   male white    0    white male
#> 2154   Brendan   male white    0    white male
#> 2155     Brett   male white    0    white male
#> 2156    Carrie female white    0  white female
#> 2157     Ebony female black    0 black, female
#> 2158     Emily female white    0  white female
#> 2159  Geoffrey   male white    0    white male
#> 2160      Greg   male white    0    white male
#> 2161      Greg   male white    0    white male
#> 2162     Hakim   male black    0    black male
#> 2163     Jamal   male black    0    black male
#> 2164     Jamal   male black    0    black male
#> 2165  Jermaine   male black    1    black male
#> 2166    Kareem   male black    0    black male
#> 2167    Keisha female black    0 black, female
#> 2168   Kristen female white    0  white female
#> 2169   Lakisha female black    0 black, female
#> 2170   Lakisha female black    0 black, female
#> 2171   Latonya female black    0 black, female
#> 2172   Latonya female black    0 black, female
#> 2173    Latoya female black    0 black, female
#> 2174    Latoya female black    0 black, female
#> 2175    Latoya female black    0 black, female
#> 2176    Laurie female white    0  white female
#> 2177    Laurie female white    0  white female
#> 2178    Laurie female white    0  white female
#> 2179   Matthew   male white    0    white male
#> 2180   Matthew   male white    0    white male
#> 2181   Matthew   male white    0    white male
#> 2182      Neil   male white    0    white male
#> 2183      Neil   male white    0    white male
#> 2184   Rasheed   male black    0    black male
#> 2185   Rasheed   male black    0    black male
#> 2186    Tamika female black    0 black, female
#> 2187   Tanisha female black    0 black, female
#> 2188   Tanisha female black    0 black, female
#> 2189      Todd   male white    0    white male
#> 2190      Todd   male white    0    white male
#> 2191      Todd   male white    0    white male
#> 2192    Tyrone   male black    0    black male
#> 2193   Latonya female black    0 black, female
#> 2194  Meredith female white    1  white female
#> 2195     Sarah female white    1  white female
#> 2196   Tanisha female black    0 black, female
#> 2197   Allison female white    0  white female
#> 2198     Kenya female black    0 black, female
#> 2199   Kristen female white    0  white female
#> 2200   Lakisha female black    0 black, female
#> 2201    Carrie female white    0  white female
#> 2202    Keisha female black    1 black, female
#> 2203    Latoya female black    0 black, female
#> 2204    Laurie female white    1  white female
#> 2205   Allison female white    1  white female
#> 2206     Ebony female black    0 black, female
#> 2207    Latoya female black    0 black, female
#> 2208    Laurie female white    1  white female
#> 2209      Jill female white    0  white female
#> 2210    Keisha female black    0 black, female
#> 2211   Latonya female black    1 black, female
#> 2212     Sarah female white    0  white female
#> 2213     Emily female white    0  white female
#> 2214      Jill female white    0  white female
#> 2215    Latoya female black    0 black, female
#> 2216    Tamika female black    0 black, female
#> 2217     Emily female white    0  white female
#> 2218      Jill female white    0  white female
#> 2219     Kenya female black    0 black, female
#> 2220    Latoya female black    0 black, female
#> 2221     Aisha female black    0 black, female
#> 2222    Carrie female white    1  white female
#> 2223   Latonya female black    1 black, female
#> 2224     Sarah female white    0  white female
#> 2225     Kenya female black    0 black, female
#> 2226   Kristen female white    0  white female
#> 2227   Lakisha female black    0 black, female
#> 2228  Meredith female white    1  white female
#> 2229    Carrie female white    1  white female
#> 2230     Kenya female black    0 black, female
#> 2231   Latonya female black    0 black, female
#> 2232    Laurie female white    0  white female
#> 2233   Allison female white    0  white female
#> 2234   Brendan   male white    1    white male
#> 2235     Jamal   male black    0    black male
#> 2236    Tamika female black    0 black, female
#> 2237   Allison female white    0  white female
#> 2238     Emily female white    0  white female
#> 2239   Latonya female black    0 black, female
#> 2240    Latoya female black    0 black, female
#> 2241     Aisha female black    0 black, female
#> 2242   Allison female white    0  white female
#> 2243   Kristen female white    0  white female
#> 2244   Latonya female black    0 black, female
#> 2245     Ebony female black    0 black, female
#> 2246     Emily female white    0  white female
#> 2247   Latonya female black    0 black, female
#> 2248    Laurie female white    0  white female
#> 2249   Brendan   male white    0    white male
#> 2250   Brendan   male white    0    white male
#> 2251     Jamal   male black    0    black male
#> 2252  Jermaine   male black    0    black male
#> 2253   Allison female white    0  white female
#> 2254     Emily female white    0  white female
#> 2255    Tamika female black    0 black, female
#> 2256   Tanisha female black    1 black, female
#> 2257     Ebony female black    0 black, female
#> 2258     Emily female white    0  white female
#> 2259    Keisha female black    0 black, female
#> 2260  Meredith female white    0  white female
#> 2261     Ebony female black    0 black, female
#> 2262   Kristen female white    0  white female
#> 2263  Meredith female white    0  white female
#> 2264   Tanisha female black    0 black, female
#> 2265     Emily female white    0  white female
#> 2266    Keisha female black    0 black, female
#> 2267    Latoya female black    0 black, female
#> 2268    Laurie female white    0  white female
#> 2269     Aisha female black    0 black, female
#> 2270   Allison female white    0  white female
#> 2271   Brendan   male white    0    white male
#> 2272   Brendan   male white    0    white male
#> 2273    Carrie female white    0  white female
#> 2274    Carrie female white    0  white female
#> 2275   Darnell   male black    0    black male
#> 2276     Ebony female black    0 black, female
#> 2277     Emily female white    0  white female
#> 2278  Geoffrey   male white    0    white male
#> 2279  Geoffrey   male white    0    white male
#> 2280      Greg   male white    0    white male
#> 2281     Hakim   male black    0    black male
#> 2282       Jay   male white    0    white male
#> 2283    Kareem   male black    0    black male
#> 2284     Kenya female black    0 black, female
#> 2285     Kenya female black    0 black, female
#> 2286   Kristen female white    0  white female
#> 2287   Kristen female white    0  white female
#> 2288   Lakisha female black    0 black, female
#> 2289   Lakisha female black    0 black, female
#> 2290   Lakisha female black    0 black, female
#> 2291   Latonya female black    0 black, female
#> 2292    Latoya female black    0 black, female
#> 2293    Laurie female white    0  white female
#> 2294   Matthew   male white    0    white male
#> 2295  Meredith female white    0  white female
#> 2296      Neil   male white    0    white male
#> 2297   Rasheed   male black    0    black male
#> 2298    Tamika female black    0 black, female
#> 2299   Tanisha female black    0 black, female
#> 2300  Tremayne   male black    0    black male
#> 2301     Aisha female black    0 black, female
#> 2302      Anne female white    1  white female
#> 2303    Carrie female white    1  white female
#> 2304     Kenya female black    1 black, female
#> 2305    Keisha female black    0 black, female
#> 2306   Kristen female white    0  white female
#> 2307   Latonya female black    0 black, female
#> 2308  Meredith female white    0  white female
#> 2309    Carrie female white    0  white female
#> 2310      Jill female white    0  white female
#> 2311    Keisha female black    0 black, female
#> 2312   Lakisha female black    0 black, female
#> 2313     Aisha female black    0 black, female
#> 2314   Allison female white    0  white female
#> 2315     Emily female white    0  white female
#> 2316   Tanisha female black    0 black, female
#> 2317      Anne female white    1  white female
#> 2318     Ebony female black    1 black, female
#> 2319     Emily female white    1  white female
#> 2320    Tamika female black    1 black, female
#> 2321     Aisha female black    0 black, female
#> 2322   Allison female white    0  white female
#> 2323   Latonya female black    0 black, female
#> 2324    Laurie female white    0  white female
#> 2325      Anne female white    1  white female
#> 2326  Geoffrey   male white    1    white male
#> 2327  Jermaine   male black    1    black male
#> 2328    Latoya female black    0 black, female
#> 2329     Aisha female black    0 black, female
#> 2330   Kristen female white    0  white female
#> 2331   Latonya female black    0 black, female
#> 2332     Sarah female white    0  white female
#> 2333      Jill female white    0  white female
#> 2334    Keisha female black    0 black, female
#> 2335   Kristen female white    0  white female
#> 2336   Lakisha female black    0 black, female
#> 2337     Aisha female black    0 black, female
#> 2338     Emily female white    0  white female
#> 2339   Latonya female black    0 black, female
#> 2340    Laurie female white    0  white female
#> 2341      Anne female white    0  white female
#> 2342      Anne female white    0  white female
#> 2343      Anne female white    0  white female
#> 2344      Brad   male white    0    white male
#> 2345      Brad   male white    0    white male
#> 2346     Emily female white    0  white female
#> 2347      Greg   male white    0    white male
#> 2348     Hakim   male black    0    black male
#> 2349     Jamal   male black    0    black male
#> 2350  Jermaine   male black    0    black male
#> 2351      Jill female white    0  white female
#> 2352    Kareem   male black    0    black male
#> 2353    Kareem   male black    0    black male
#> 2354    Keisha female black    0 black, female
#> 2355    Keisha female black    0 black, female
#> 2356    Keisha female black    0 black, female
#> 2357   Lakisha female black    0 black, female
#> 2358   Lakisha female black    0 black, female
#> 2359    Laurie female white    0  white female
#> 2360    Laurie female white    0  white female
#> 2361     Leroy   male black    0    black male
#> 2362     Leroy   male black    0    black male
#> 2363  Meredith female white    0  white female
#> 2364  Meredith female white    0  white female
#> 2365      Neil   male white    0    white male
#> 2366   Rasheed   male black    0    black male
#> 2367    Tamika female black    0 black, female
#> 2368      Todd   male white    0    white male
#> 2369     Aisha female black    0 black, female
#> 2370      Anne female white    0  white female
#> 2371  Meredith female white    0  white female
#> 2372    Tamika female black    0 black, female
#> 2373     Aisha female black    0 black, female
#> 2374      Jill female white    0  white female
#> 2375  Meredith female white    0  white female
#> 2376   Tanisha female black    1 black, female
#> 2377   Allison female white    0  white female
#> 2378      Anne female white    0  white female
#> 2379    Keisha female black    1 black, female
#> 2380   Lakisha female black    1 black, female
#> 2381   Allison female white    1  white female
#> 2382   Latonya female black    1 black, female
#> 2383    Latoya female black    1 black, female
#> 2384  Meredith female white    1  white female
#> 2385     Aisha female black    0 black, female
#> 2386     Kenya female black    0 black, female
#> 2387    Laurie female white    0  white female
#> 2388  Meredith female white    0  white female
#> 2389   Allison female white    0  white female
#> 2390   Latonya female black    0 black, female
#> 2391     Sarah female white    0  white female
#> 2392    Tamika female black    0 black, female
#> 2393      Jill female white    1  white female
#> 2394   Latonya female black    0 black, female
#> 2395    Latoya female black    0 black, female
#> 2396  Meredith female white    1  white female
#> 2397   Allison female white    0  white female
#> 2398    Latoya female black    0 black, female
#> 2399  Meredith female white    0  white female
#> 2400    Tamika female black    0 black, female
#> 2401     Ebony female black    0 black, female
#> 2402     Kenya female black    0 black, female
#> 2403   Kristen female white    0  white female
#> 2404    Laurie female white    0  white female
#> 2405     Hakim   male black    0    black male
#> 2406       Jay   male white    0    white male
#> 2407     Leroy   male black    0    black male
#> 2408  Meredith female white    0  white female
#> 2409     Ebony female black    0 black, female
#> 2410   Kristen female white    0  white female
#> 2411   Latonya female black    0 black, female
#> 2412  Meredith female white    0  white female
#> 2413     Aisha female black    0 black, female
#> 2414    Carrie female white    0  white female
#> 2415     Ebony female black    0 black, female
#> 2416   Kristen female white    0  white female
#> 2417     Jamal   male black    0    black male
#> 2418      Todd   male white    0    white male
#> 2419      Anne female white    0  white female
#> 2420     Ebony female black    0 black, female
#> 2421     Kenya female black    0 black, female
#> 2422   Kristen female white    0  white female
#> 2423   Allison female white    0  white female
#> 2424      Anne female white    0  white female
#> 2425    Tamika female black    0 black, female
#> 2426   Tanisha female black    0 black, female
#> 2427   Allison female white    0  white female
#> 2428    Keisha female black    0 black, female
#> 2429  Meredith female white    0  white female
#> 2430   Tanisha female black    0 black, female
#> 2431     Aisha female black    0 black, female
#> 2432      Anne female white    0  white female
#> 2433      Anne female white    0  white female
#> 2434      Brad   male white    0    white male
#> 2435   Brendan   male white    0    white male
#> 2436     Brett   male white    0    white male
#> 2437     Brett   male white    0    white male
#> 2438     Brett   male white    0    white male
#> 2439     Ebony female black    0 black, female
#> 2440     Ebony female black    0 black, female
#> 2441  Geoffrey   male white    0    white male
#> 2442      Greg   male white    0    white male
#> 2443     Hakim   male black    0    black male
#> 2444     Hakim   male black    0    black male
#> 2445       Jay   male white    0    white male
#> 2446  Jermaine   male black    0    black male
#> 2447      Jill female white    0  white female
#> 2448    Kareem   male black    0    black male
#> 2449    Keisha female black    0 black, female
#> 2450     Kenya female black    0 black, female
#> 2451   Kristen female white    0  white female
#> 2452   Lakisha female black    0 black, female
#> 2453   Latonya female black    0 black, female
#> 2454   Latonya female black    0 black, female
#> 2455     Leroy   male black    0    black male
#> 2456     Leroy   male black    0    black male
#> 2457   Matthew   male white    0    white male
#> 2458      Neil   male white    0    white male
#> 2459     Sarah female white    0  white female
#> 2460      Todd   male white    0    white male
#> 2461  Tremayne   male black    0    black male
#> 2462    Tyrone   male black    0    black male
#> 2463     Ebony female black    0 black, female
#> 2464   Latonya female black    0 black, female
#> 2465  Meredith female white    0  white female
#> 2466     Sarah female white    0  white female
#> 2467     Ebony female black    0 black, female
#> 2468   Kristen female white    1  white female
#> 2469  Meredith female white    1  white female
#> 2470   Tanisha female black    1 black, female
#> 2471     Emily female white    0  white female
#> 2472    Keisha female black    0 black, female
#> 2473   Lakisha female black    0 black, female
#> 2474  Meredith female white    0  white female
#> 2475     Aisha female black    0 black, female
#> 2476      Anne female white    1  white female
#> 2477    Carrie female white    1  white female
#> 2478    Latoya female black    0 black, female
#> 2479      Jill female white    0  white female
#> 2480   Lakisha female black    0 black, female
#> 2481     Sarah female white    0  white female
#> 2482    Tamika female black    0 black, female
#> 2483   Allison female white    0  white female
#> 2484     Emily female white    0  white female
#> 2485     Kenya female black    0 black, female
#> 2486    Latoya female black    0 black, female
#> 2487   Allison female white    0  white female
#> 2488      Anne female white    0  white female
#> 2489   Lakisha female black    0 black, female
#> 2490    Tamika female black    0 black, female
#> 2491   Kristen female white    1  white female
#> 2492   Latonya female black    1 black, female
#> 2493      Neil   male white    0    white male
#> 2494    Tyrone   male black    0    black male
#> 2495     Aisha female black    0 black, female
#> 2496      Anne female white    0  white female
#> 2497    Latoya female black    0 black, female
#> 2498    Laurie female white    0  white female
#> 2499   Brendan   male white    0    white male
#> 2500     Brett   male white    0    white male
#> 2501     Leroy   male black    0    black male
#> 2502  Tremayne   male black    0    black male
#> 2503      Anne female white    0  white female
#> 2504     Emily female white    0  white female
#> 2505    Keisha female black    0 black, female
#> 2506    Latoya female black    0 black, female
#> 2507   Kristen female white    0  white female
#> 2508    Latoya female black    0 black, female
#> 2509     Sarah female white    0  white female
#> 2510    Tamika female black    0 black, female
#> 2511     Aisha female black    0 black, female
#> 2512     Aisha female black    0 black, female
#> 2513   Allison female white    0  white female
#> 2514   Allison female white    0  white female
#> 2515   Brendan   male white    0    white male
#> 2516     Brett   male white    1    white male
#> 2517     Brett   male white    0    white male
#> 2518     Brett   male white    0    white male
#> 2519     Emily female white    0  white female
#> 2520       Jay   male white    1    white male
#> 2521      Jill female white    0  white female
#> 2522      Jill female white    0  white female
#> 2523    Kareem   male black    0    black male
#> 2524    Keisha female black    0 black, female
#> 2525   Lakisha female black    0 black, female
#> 2526   Latonya female black    0 black, female
#> 2527   Latonya female black    0 black, female
#> 2528   Latonya female black    0 black, female
#> 2529   Matthew   male white    0    white male
#> 2530      Neil   male white    0    white male
#> 2531    Tamika female black    1 black, female
#> 2532    Tamika female black    0 black, female
#> 2533  Tremayne   male black    0    black male
#> 2534    Tyrone   male black    0    black male
#> 2535     Emily female white    0  white female
#> 2536   Latonya female black    0 black, female
#> 2537     Sarah female white    0  white female
#> 2538   Tanisha female black    0 black, female
#> 2539     Aisha female black    0 black, female
#> 2540   Allison female white    1  white female
#> 2541     Emily female white    1  white female
#> 2542   Lakisha female black    1 black, female
#> 2543      Jill female white    0  white female
#> 2544   Kristen female white    0  white female
#> 2545   Latonya female black    0 black, female
#> 2546    Tamika female black    0 black, female
#> 2547   Allison female white    0  white female
#> 2548    Keisha female black    0 black, female
#> 2549   Kristen female white    0  white female
#> 2550   Tanisha female black    1 black, female
#> 2551     Emily female white    0  white female
#> 2552   Lakisha female black    0 black, female
#> 2553   Matthew   male white    0    white male
#> 2554   Tanisha female black    0 black, female
#> 2555      Anne female white    0  white female
#> 2556    Latoya female black    0 black, female
#> 2557    Laurie female white    1  white female
#> 2558    Tamika female black    0 black, female
#> 2559   Brendan   male white    0    white male
#> 2560     Jamal   male black    0    black male
#> 2561     Ebony female black    0 black, female
#> 2562     Emily female white    0  white female
#> 2563   Latonya female black    1 black, female
#> 2564  Meredith female white    0  white female
#> 2565     Ebony female black    0 black, female
#> 2566     Emily female white    0  white female
#> 2567    Keisha female black    0 black, female
#> 2568    Laurie female white    0  white female
#> 2569      Anne female white    0  white female
#> 2570      Brad   male white    0    white male
#> 2571     Brett   male white    0    white male
#> 2572     Ebony female black    0 black, female
#> 2573     Emily female white    0  white female
#> 2574     Emily female white    0  white female
#> 2575     Jamal   male black    0    black male
#> 2576       Jay   male white    0    white male
#> 2577  Jermaine   male black    0    black male
#> 2578      Jill female white    0  white female
#> 2579    Kareem   male black    0    black male
#> 2580    Kareem   male black    0    black male
#> 2581    Kareem   male black    0    black male
#> 2582    Keisha female black    0 black, female
#> 2583   Kristen female white    0  white female
#> 2584   Lakisha female black    0 black, female
#> 2585     Leroy   male black    0    black male
#> 2586     Leroy   male black    0    black male
#> 2587   Matthew   male white    0    white male
#> 2588   Matthew   male white    0    white male
#> 2589      Neil   male white    0    white male
#> 2590     Sarah female white    0  white female
#> 2591     Sarah female white    0  white female
#> 2592    Tamika female black    0 black, female
#> 2593   Tanisha female black    0 black, female
#> 2594   Tanisha female black    0 black, female
#> 2595   Tanisha female black    0 black, female
#> 2596      Todd   male white    0    white male
#> 2597      Todd   male white    0    white male
#> 2598      Todd   male white    0    white male
#> 2599  Tremayne   male black    0    black male
#> 2600  Tremayne   male black    0    black male
#> 2601     Emily female white    0  white female
#> 2602      Jill female white    0  white female
#> 2603   Lakisha female black    0 black, female
#> 2604   Tanisha female black    0 black, female
#> 2605      Jill female white    0  white female
#> 2606     Kenya female black    0 black, female
#> 2607   Kristen female white    0  white female
#> 2608    Latoya female black    0 black, female
#> 2609    Carrie female white    0  white female
#> 2610     Emily female white    0  white female
#> 2611   Latonya female black    0 black, female
#> 2612    Latoya female black    0 black, female
#> 2613      Anne female white    1  white female
#> 2614    Keisha female black    1 black, female
#> 2615     Kenya female black    1 black, female
#> 2616  Meredith female white    1  white female
#> 2617      Anne female white    0  white female
#> 2618   Kristen female white    0  white female
#> 2619   Lakisha female black    0 black, female
#> 2620   Tanisha female black    0 black, female
#> 2621      Anne female white    1  white female
#> 2622     Ebony female black    1 black, female
#> 2623   Latonya female black    0 black, female
#> 2624     Sarah female white    0  white female
#> 2625   Allison female white    0  white female
#> 2626      Anne female white    0  white female
#> 2627     Ebony female black    1 black, female
#> 2628   Tanisha female black    1 black, female
#> 2629  Geoffrey   male white    0    white male
#> 2630   Rasheed   male black    0    black male
#> 2631   Allison female white    0  white female
#> 2632     Emily female white    0  white female
#> 2633     Kenya female black    0 black, female
#> 2634    Latoya female black    0 black, female
#> 2635      Anne female white    0  white female
#> 2636    Carrie female white    0  white female
#> 2637     Kenya female black    0 black, female
#> 2638    Latoya female black    0 black, female
#> 2639     Emily female white    0  white female
#> 2640    Keisha female black    0 black, female
#> 2641     Kenya female black    0 black, female
#> 2642     Sarah female white    0  white female
#> 2643     Aisha female black    0 black, female
#> 2644      Greg   male white    0    white male
#> 2645       Jay   male white    0    white male
#> 2646  Jermaine   male black    0    black male
#> 2647  Jermaine   male black    0    black male
#> 2648    Kareem   male black    0    black male
#> 2649    Kareem   male black    0    black male
#> 2650   Kristen female white    0  white female
#> 2651   Kristen female white    0  white female
#> 2652   Latonya female black    0 black, female
#> 2653    Latoya female black    0 black, female
#> 2654   Matthew   male white    0    white male
#> 2655  Meredith female white    0  white female
#> 2656  Meredith female white    0  white female
#> 2657      Todd   male white    0    white male
#> 2658  Tremayne   male black    0    black male
#> 2659     Ebony female black    0 black, female
#> 2660      Jill female white    0  white female
#> 2661     Kenya female black    0 black, female
#> 2662    Laurie female white    0  white female
#> 2663      Anne female white    0  white female
#> 2664   Lakisha female black    0 black, female
#> 2665   Latonya female black    1 black, female
#> 2666     Sarah female white    0  white female
#> 2667     Ebony female black    0 black, female
#> 2668      Jill female white    0  white female
#> 2669   Latonya female black    0 black, female
#> 2670    Laurie female white    1  white female
#> 2671      Anne female white    0  white female
#> 2672   Lakisha female black    0 black, female
#> 2673     Sarah female white    0  white female
#> 2674   Tanisha female black    0 black, female
#> 2675   Allison female white    0  white female
#> 2676     Kenya female black    0 black, female
#> 2677   Kristen female white    0  white female
#> 2678   Lakisha female black    0 black, female
#> 2679      Anne female white    0  white female
#> 2680     Ebony female black    0 black, female
#> 2681     Kenya female black    0 black, female
#> 2682   Kristen female white    1  white female
#> 2683     Aisha female black    0 black, female
#> 2684      Anne female white    0  white female
#> 2685   Latonya female black    0 black, female
#> 2686    Laurie female white    0  white female
#> 2687    Carrie female white    0  white female
#> 2688      Jill female white    0  white female
#> 2689    Keisha female black    0 black, female
#> 2690    Tamika female black    0 black, female
#> 2691     Aisha female black    0 black, female
#> 2692   Allison female white    0  white female
#> 2693    Carrie female white    1  white female
#> 2694    Tamika female black    1 black, female
#> 2695      Anne female white    1  white female
#> 2696     Jamal   male black    1    black male
#> 2697       Jay   male white    1    white male
#> 2698    Tyrone   male black    1    black male
#> 2699   Brendan   male white    0    white male
#> 2700     Jamal   male black    0    black male
#> 2701      Anne female white    0  white female
#> 2702     Ebony female black    0 black, female
#> 2703   Kristen female white    0  white female
#> 2704   Tanisha female black    0 black, female
#> 2705   Lakisha female black    0 black, female
#> 2706   Latonya female black    0 black, female
#> 2707    Laurie female white    0  white female
#> 2708  Meredith female white    0  white female
#> 2709     Aisha female black    0 black, female
#> 2710   Allison female white    0  white female
#> 2711   Allison female white    0  white female
#> 2712     Brett   male white    0    white male
#> 2713    Carrie female white    0  white female
#> 2714   Darnell   male black    0    black male
#> 2715     Ebony female black    0 black, female
#> 2716     Ebony female black    0 black, female
#> 2717     Ebony female black    0 black, female
#> 2718      Greg   male white    0    white male
#> 2719       Jay   male white    0    white male
#> 2720      Jill female white    0  white female
#> 2721    Kareem   male black    0    black male
#> 2722    Keisha female black    0 black, female
#> 2723   Kristen female white    0  white female
#> 2724   Lakisha female black    0 black, female
#> 2725   Latonya female black    0 black, female
#> 2726   Latonya female black    0 black, female
#> 2727    Laurie female white    0  white female
#> 2728  Meredith female white    0  white female
#> 2729     Sarah female white    0  white female
#> 2730    Tamika female black    0 black, female
#> 2731      Todd   male white    0    white male
#> 2732  Tremayne   male black    0    black male
#> 2733    Laurie female white    1  white female
#> 2734  Meredith female white    0  white female
#> 2735    Tamika female black    0 black, female
#> 2736   Tanisha female black    0 black, female
#> 2737      Anne female white    0  white female
#> 2738      Jill female white    1  white female
#> 2739   Latonya female black    1 black, female
#> 2740   Tanisha female black    0 black, female
#> 2741    Carrie female white    0  white female
#> 2742   Kristen female white    0  white female
#> 2743   Lakisha female black    0 black, female
#> 2744   Tanisha female black    0 black, female
#> 2745      Anne female white    1  white female
#> 2746     Ebony female black    0 black, female
#> 2747     Kenya female black    1 black, female
#> 2748     Sarah female white    0  white female
#> 2749      Anne female white    1  white female
#> 2750     Ebony female black    0 black, female
#> 2751   Latonya female black    1 black, female
#> 2752     Sarah female white    0  white female
#> 2753   Allison female white    0  white female
#> 2754    Keisha female black    0 black, female
#> 2755    Laurie female white    0  white female
#> 2756    Tamika female black    0 black, female
#> 2757  Meredith female white    0  white female
#> 2758    Tamika female black    0 black, female
#> 2759   Allison female white    0  white female
#> 2760     Brett   male white    0    white male
#> 2761   Lakisha female black    1 black, female
#> 2762    Tyrone   male black    0    black male
#> 2763      Anne female white    0  white female
#> 2764    Latoya female black    0 black, female
#> 2765  Meredith female white    0  white female
#> 2766    Tamika female black    0 black, female
#> 2767    Carrie female white    0  white female
#> 2768     Ebony female black    0 black, female
#> 2769       Jay   male white    0    white male
#> 2770    Latoya female black    0 black, female
#> 2771     Sarah female white    0  white female
#> 2772    Tamika female black    0 black, female
#> 2773     Aisha female black    0 black, female
#> 2774      Anne female white    0  white female
#> 2775      Jill female white    0  white female
#> 2776   Tanisha female black    0 black, female
#> 2777   Kristen female white    0  white female
#> 2778     Sarah female white    0  white female
#> 2779    Tamika female black    0 black, female
#> 2780   Tanisha female black    0 black, female
#> 2781      Anne female white    0  white female
#> 2782   Tanisha female black    0 black, female
#> 2783   Kristen female white    0  white female
#> 2784  Tremayne   male black    0    black male
#> 2785     Brett   male white    0    white male
#> 2786     Ebony female black    0 black, female
#> 2787     Emily female white    0  white female
#> 2788  Geoffrey   male white    0    white male
#> 2789     Jamal   male black    0    black male
#> 2790      Jill female white    0  white female
#> 2791   Lakisha female black    0 black, female
#> 2792    Tyrone   male black    0    black male
#> 2793   Allison female white    0  white female
#> 2794   Lakisha female black    0 black, female
#> 2795    Latoya female black    0 black, female
#> 2796  Meredith female white    0  white female
#> 2797   Allison female white    0  white female
#> 2798      Brad   male white    0    white male
#> 2799   Darnell   male black    0    black male
#> 2800     Kenya female black    0 black, female
#> 2801   Latonya female black    0 black, female
#> 2802  Meredith female white    0  white female
#> 2803    Laurie female white    0  white female
#> 2804    Tamika female black    0 black, female
#> 2805      Brad   male white    0    white male
#> 2806   Latonya female black    0 black, female
#> 2807    Laurie female white    0  white female
#> 2808   Tanisha female black    0 black, female
#> 2809     Aisha female black    0 black, female
#> 2810      Jill female white    0  white female
#> 2811   Latonya female black    0 black, female
#> 2812    Laurie female white    0  white female
#> 2813      Anne female white    0  white female
#> 2814      Jill female white    0  white female
#> 2815     Kenya female black    0 black, female
#> 2816   Lakisha female black    0 black, female
#> 2817       Jay   male white    0    white male
#> 2818      Jill female white    0  white female
#> 2819    Kareem   male black    0    black male
#> 2820    Latoya female black    0 black, female
#> 2821     Leroy   male black    0    black male
#> 2822     Sarah female white    0  white female
#> 2823     Aisha female black    0 black, female
#> 2824    Laurie female white    0  white female
#> 2825     Sarah female white    0  white female
#> 2826    Tamika female black    0 black, female
#> 2827      Jill female white    0  white female
#> 2828    Keisha female black    0 black, female
#> 2829     Kenya female black    0 black, female
#> 2830   Kristen female white    0  white female
#> 2831      Anne female white    0  white female
#> 2832      Anne female white    0  white female
#> 2833   Darnell   male black    0    black male
#> 2834     Emily female white    0  white female
#> 2835    Keisha female black    0 black, female
#> 2836   Tanisha female black    0 black, female
#> 2837     Emily female white    0  white female
#> 2838     Kenya female black    0 black, female
#> 2839   Kristen female white    0  white female
#> 2840   Latonya female black    0 black, female
#> 2841   Kristen female white    0  white female
#> 2842    Latoya female black    0 black, female
#> 2843    Tamika female black    0 black, female
#> 2844      Todd   male white    0    white male
#> 2845      Jill female white    1  white female
#> 2846   Kristen female white    1  white female
#> 2847    Latoya female black    1 black, female
#> 2848    Tamika female black    0 black, female
#> 2849   Kristen female white    1  white female
#> 2850    Tamika female black    0 black, female
#> 2851     Aisha female black    0 black, female
#> 2852     Ebony female black    0 black, female
#> 2853     Emily female white    0  white female
#> 2854      Jill female white    0  white female
#> 2855    Latoya female black    0 black, female
#> 2856    Laurie female white    0  white female
#> 2857   Darnell   male black    0    black male
#> 2858       Jay   male white    0    white male
#> 2859   Lakisha female black    0 black, female
#> 2860    Latoya female black    0 black, female
#> 2861   Matthew   male white    0    white male
#> 2862  Meredith female white    0  white female
#> 2863     Sarah female white    0  white female
#> 2864    Tamika female black    0 black, female
#> 2865   Allison female white    0  white female
#> 2866     Ebony female black    0 black, female
#> 2867      Jill female white    0  white female
#> 2868    Keisha female black    0 black, female
#> 2869     Jamal   male black    0    black male
#> 2870  Meredith female white    0  white female
#> 2871     Sarah female white    0  white female
#> 2872   Tanisha female black    0 black, female
#> 2873    Carrie female white    0  white female
#> 2874    Latoya female black    0 black, female
#> 2875   Allison female white    0  white female
#> 2876     Hakim   male black    0    black male
#> 2877      Jill female white    0  white female
#> 2878    Keisha female black    0 black, female
#> 2879   Kristen female white    0  white female
#> 2880   Tanisha female black    0 black, female
#> 2881      Anne female white    0  white female
#> 2882    Keisha female black    0 black, female
#> 2883     Kenya female black    1 black, female
#> 2884   Kristen female white    1  white female
#> 2885   Latonya female black    0 black, female
#> 2886     Sarah female white    0  white female
#> 2887     Aisha female black    0 black, female
#> 2888     Emily female white    0  white female
#> 2889       Jay   male white    0    white male
#> 2890   Kristen female white    0  white female
#> 2891    Latoya female black    0 black, female
#> 2892   Tanisha female black    0 black, female
#> 2893      Anne female white    0  white female
#> 2894    Carrie female white    1  white female
#> 2895   Darnell   male black    0    black male
#> 2896    Latoya female black    1 black, female
#> 2897    Laurie female white    1  white female
#> 2898   Tanisha female black    0 black, female
#> 2899      Anne female white    0  white female
#> 2900   Darnell   male black    0    black male
#> 2901       Jay   male white    0    white male
#> 2902   Tanisha female black    0 black, female
#> 2903    Carrie female white    0  white female
#> 2904     Emily female white    1  white female
#> 2905     Sarah female white    0  white female
#> 2906    Tamika female black    1 black, female
#> 2907   Tanisha female black    0 black, female
#> 2908  Tremayne   male black    0    black male
#> 2909      Anne female white    0  white female
#> 2910      Jill female white    0  white female
#> 2911     Kenya female black    0 black, female
#> 2912   Lakisha female black    0 black, female
#> 2913   Matthew   male white    0    white male
#> 2914    Tamika female black    0 black, female
#> 2915   Matthew   male white    0    white male
#> 2916   Tanisha female black    0 black, female
#> 2917      Anne female white    0  white female
#> 2918    Latoya female black    0 black, female
#> 2919  Meredith female white    0  white female
#> 2920    Tamika female black    0 black, female
#> 2921     Aisha female black    0 black, female
#> 2922     Emily female white    0  white female
#> 2923      Greg   male white    0    white male
#> 2924     Hakim   male black    0    black male
#> 2925      Jill female white    0  white female
#> 2926    Keisha female black    0 black, female
#> 2927     Kenya female black    0 black, female
#> 2928    Laurie female white    0  white female
#> 2929     Sarah female white    0  white female
#> 2930    Tamika female black    0 black, female
#> 2931    Carrie female white    0  white female
#> 2932     Ebony female black    0 black, female
#> 2933     Jamal   male black    0    black male
#> 2934      Jill female white    0  white female
#> 2935     Kenya female black    0 black, female
#> 2936    Latoya female black    0 black, female
#> 2937  Meredith female white    0  white female
#> 2938      Todd   male white    0    white male
#> 2939     Aisha female black    0 black, female
#> 2940   Allison female white    0  white female
#> 2941      Brad   male white    0    white male
#> 2942  Geoffrey   male white    0    white male
#> 2943     Hakim   male black    0    black male
#> 2944    Latoya female black    0 black, female
#> 2945     Sarah female white    0  white female
#> 2946   Tanisha female black    0 black, female
#> 2947   Allison female white    0  white female
#> 2948   Allison female white    0  white female
#> 2949      Anne female white    0  white female
#> 2950      Brad   male white    1    white male
#> 2951   Brendan   male white    1    white male
#> 2952   Brendan   male white    0    white male
#> 2953     Brett   male white    0    white male
#> 2954     Brett   male white    0    white male
#> 2955   Darnell   male black    0    black male
#> 2956     Ebony female black    0 black, female
#> 2957     Emily female white    0  white female
#> 2958      Greg   male white    0    white male
#> 2959     Hakim   male black    0    black male
#> 2960      Jill female white    0  white female
#> 2961   Kristen female white    0  white female
#> 2962   Latonya female black    0 black, female
#> 2963   Latonya female black    0 black, female
#> 2964   Latonya female black    0 black, female
#> 2965    Latoya female black    0 black, female
#> 2966    Laurie female white    0  white female
#> 2967  Meredith female white    0  white female
#> 2968      Neil   male white    0    white male
#> 2969   Rasheed   male black    0    black male
#> 2970   Rasheed   male black    0    black male
#> 2971     Sarah female white    0  white female
#> 2972    Tamika female black    1 black, female
#> 2973    Tamika female black    0 black, female
#> 2974    Tamika female black    0 black, female
#> 2975    Tamika female black    0 black, female
#> 2976    Tamika female black    0 black, female
#> 2977    Tamika female black    0 black, female
#> 2978      Todd   male white    0    white male
#> 2979      Todd   male white    0    white male
#> 2980  Tremayne   male black    0    black male
#> 2981    Tyrone   male black    0    black male
#> 2982    Tyrone   male black    0    black male
#> 2983     Ebony female black    0 black, female
#> 2984   Kristen female white    0  white female
#> 2985    Latoya female black    0 black, female
#> 2986     Sarah female white    0  white female
#> 2987      Anne female white    0  white female
#> 2988     Emily female white    0  white female
#> 2989     Kenya female black    0 black, female
#> 2990    Latoya female black    0 black, female
#> 2991   Allison female white    0  white female
#> 2992     Ebony female black    0 black, female
#> 2993    Keisha female black    0 black, female
#> 2994   Kristen female white    0  white female
#> 2995      Brad   male white    0    white male
#> 2996   Brendan   male white    0    white male
#> 2997     Brett   male white    0    white male
#> 2998    Carrie female white    0  white female
#> 2999   Darnell   male black    0    black male
#> 3000     Ebony female black    0 black, female
#> 3001      Greg   male white    0    white male
#> 3002      Greg   male white    0    white male
#> 3003     Jamal   male black    0    black male
#> 3004    Kareem   male black    0    black male
#> 3005    Keisha female black    0 black, female
#> 3006   Lakisha female black    0 black, female
#> 3007    Latoya female black    0 black, female
#> 3008    Latoya female black    0 black, female
#> 3009    Latoya female black    1 black, female
#> 3010    Laurie female white    0  white female
#> 3011      Neil   male white    0    white male
#> 3012      Neil   male white    0    white male
#> 3013      Neil   male white    0    white male
#> 3014   Rasheed   male black    0    black male
#> 3015     Sarah female white    0  white female
#> 3016     Sarah female white    0  white female
#> 3017   Tanisha female black    0 black, female
#> 3018  Tremayne   male black    0    black male
#> 3019    Carrie female white    0  white female
#> 3020     Emily female white    1  white female
#> 3021   Latonya female black    1 black, female
#> 3022   Tanisha female black    0 black, female
#> 3023   Allison female white    0  white female
#> 3024     Kenya female black    0 black, female
#> 3025   Kristen female white    0  white female
#> 3026   Latonya female black    0 black, female
#> 3027   Allison female white    0  white female
#> 3028    Carrie female white    0  white female
#> 3029    Keisha female black    0 black, female
#> 3030   Tanisha female black    0 black, female
#> 3031      Anne female white    0  white female
#> 3032    Carrie female white    0  white female
#> 3033   Lakisha female black    0 black, female
#> 3034   Tanisha female black    0 black, female
#> 3035      Anne female white    0  white female
#> 3036     Ebony female black    0 black, female
#> 3037     Kenya female black    0 black, female
#> 3038  Meredith female white    0  white female
#> 3039     Emily female white    0  white female
#> 3040  Geoffrey   male white    0    white male
#> 3041   Rasheed   male black    0    black male
#> 3042  Tremayne   male black    0    black male
#> 3043     Ebony female black    1 black, female
#> 3044      Jill female white    0  white female
#> 3045   Kristen female white    0  white female
#> 3046   Latonya female black    0 black, female
#> 3047      Anne female white    0  white female
#> 3048    Keisha female black    0 black, female
#> 3049     Sarah female white    0  white female
#> 3050   Tanisha female black    0 black, female
#> 3051     Aisha female black    0 black, female
#> 3052      Brad   male white    0    white male
#> 3053     Brett   male white    0    white male
#> 3054    Carrie female white    0  white female
#> 3055    Carrie female white    0  white female
#> 3056     Ebony female black    0 black, female
#> 3057  Geoffrey   male white    0    white male
#> 3058    Kareem   male black    0    black male
#> 3059    Kareem   male black    0    black male
#> 3060    Keisha female black    0 black, female
#> 3061      Neil   male white    0    white male
#> 3062  Tremayne   male black    0    black male
#> 3063      Jill female white    0  white female
#> 3064     Kenya female black    0 black, female
#> 3065   Latonya female black    0 black, female
#> 3066    Laurie female white    0  white female
#> 3067    Carrie female white    0  white female
#> 3068      Jill female white    0  white female
#> 3069    Keisha female black    0 black, female
#> 3070     Kenya female black    0 black, female
#> 3071   Allison female white    0  white female
#> 3072     Emily female white    0  white female
#> 3073    Latoya female black    0 black, female
#> 3074   Tanisha female black    0 black, female
#> 3075      Anne female white    0  white female
#> 3076    Carrie female white    0  white female
#> 3077   Lakisha female black    0 black, female
#> 3078   Latonya female black    0 black, female
#> 3079   Allison female white    0  white female
#> 3080     Ebony female black    0 black, female
#> 3081  Meredith female white    0  white female
#> 3082    Tamika female black    0 black, female
#> 3083      Jill female white    0  white female
#> 3084   Kristen female white    0  white female
#> 3085    Latoya female black    0 black, female
#> 3086    Tamika female black    0 black, female
#> 3087     Aisha female black    0 black, female
#> 3088   Lakisha female black    0 black, female
#> 3089    Laurie female white    0  white female
#> 3090  Meredith female white    0  white female
#> 3091     Emily female white    0  white female
#> 3092   Lakisha female black    0 black, female
#> 3093     Sarah female white    0  white female
#> 3094   Tanisha female black    0 black, female
#> 3095     Emily female white    0  white female
#> 3096     Hakim   male black    1    black male
#> 3097    Laurie female white    0  white female
#> 3098    Tyrone   male black    0    black male
#> 3099      Anne female white    0  white female
#> 3100     Emily female white    0  white female
#> 3101    Tamika female black    0 black, female
#> 3102    Tamika female black    0 black, female
#> 3103     Aisha female black    0 black, female
#> 3104   Allison female white    0  white female
#> 3105    Carrie female white    0  white female
#> 3106     Emily female white    0  white female
#> 3107     Emily female white    0  white female
#> 3108  Geoffrey   male white    0    white male
#> 3109      Greg   male white    0    white male
#> 3110     Hakim   male black    0    black male
#> 3111     Hakim   male black    0    black male
#> 3112       Jay   male white    0    white male
#> 3113    Keisha female black    0 black, female
#> 3114   Lakisha female black    0 black, female
#> 3115    Latoya female black    0 black, female
#> 3116    Laurie female white    0  white female
#> 3117   Matthew   male white    0    white male
#> 3118   Rasheed   male black    0    black male
#> 3119   Tanisha female black    0 black, female
#> 3120      Todd   male white    0    white male
#> 3121  Tremayne   male black    0    black male
#> 3122    Tyrone   male black    0    black male
#> 3123   Kristen female white    0  white female
#> 3124   Lakisha female black    0 black, female
#> 3125   Matthew   male white    0    white male
#> 3126  Tremayne   male black    0    black male
#> 3127   Allison female white    0  white female
#> 3128    Carrie female white    0  white female
#> 3129     Kenya female black    0 black, female
#> 3130    Latoya female black    0 black, female
#> 3131      Brad   male white    0    white male
#> 3132   Brendan   male white    0    white male
#> 3133     Brett   male white    0    white male
#> 3134    Carrie female white    0  white female
#> 3135   Darnell   male black    0    black male
#> 3136  Geoffrey   male white    0    white male
#> 3137      Greg   male white    0    white male
#> 3138     Jamal   male black    0    black male
#> 3139  Jermaine   male black    0    black male
#> 3140    Kareem   male black    0    black male
#> 3141    Keisha female black    0 black, female
#> 3142   Kristen female white    0  white female
#> 3143   Kristen female white    0  white female
#> 3144   Latonya female black    0 black, female
#> 3145   Latonya female black    0 black, female
#> 3146    Latoya female black    0 black, female
#> 3147    Laurie female white    0  white female
#> 3148     Leroy   male black    0    black male
#> 3149      Neil   male white    0    white male
#> 3150      Neil   male white    0    white male
#> 3151     Sarah female white    0  white female
#> 3152    Tamika female black    0 black, female
#> 3153  Tremayne   male black    0    black male
#> 3154    Tyrone   male black    0    black male
#> 3155     Aisha female black    0 black, female
#> 3156   Allison female white    0  white female
#> 3157      Jill female white    1  white female
#> 3158    Tamika female black    0 black, female
#> 3159     Aisha female black    0 black, female
#> 3160   Allison female white    0  white female
#> 3161     Ebony female black    0 black, female
#> 3162     Ebony female black    0 black, female
#> 3163     Emily female white    0  white female
#> 3164      Greg   male white    0    white male
#> 3165     Hakim   male black    0    black male
#> 3166      Jill female white    0  white female
#> 3167    Kareem   male black    0    black male
#> 3168    Keisha female black    0 black, female
#> 3169   Lakisha female black    1 black, female
#> 3170    Laurie female white    0  white female
#> 3171    Laurie female white    0  white female
#> 3172   Matthew   male white    1    white male
#> 3173  Meredith female white    1  white female
#> 3174      Neil   male white    0    white male
#> 3175   Rasheed   male black    0    black male
#> 3176     Sarah female white    0  white female
#> 3177   Tanisha female black    0 black, female
#> 3178    Tyrone   male black    0    black male
#> 3179     Ebony female black    1 black, female
#> 3180      Jill female white    0  white female
#> 3181   Matthew   male white    0    white male
#> 3182  Tremayne   male black    0    black male
#> 3183    Carrie female white    0  white female
#> 3184     Ebony female black    0 black, female
#> 3185      Jill female white    0  white female
#> 3186    Tamika female black    0 black, female
#> 3187      Brad   male white    0    white male
#> 3188      Brad   male white    0    white male
#> 3189  Geoffrey   male white    0    white male
#> 3190    Kareem   male black    0    black male
#> 3191    Keisha female black    0 black, female
#> 3192    Keisha female black    0 black, female
#> 3193     Kenya female black    0 black, female
#> 3194   Kristen female white    0  white female
#> 3195   Lakisha female black    0 black, female
#> 3196   Lakisha female black    0 black, female
#> 3197    Laurie female white    0  white female
#> 3198     Leroy   male black    1    black male
#> 3199  Meredith female white    0  white female
#> 3200      Neil   male white    0    white male
#> 3201      Neil   male white    0    white male
#> 3202   Rasheed   male black    0    black male
#> 3203   Rasheed   male black    0    black male
#> 3204   Rasheed   male black    0    black male
#> 3205     Sarah female white    0  white female
#> 3206      Todd   male white    0    white male
#> 3207     Aisha female black    0 black, female
#> 3208   Allison female white    0  white female
#> 3209      Anne female white    0  white female
#> 3210      Brad   male white    0    white male
#> 3211    Carrie female white    0  white female
#> 3212    Kareem   male black    0    black male
#> 3213    Keisha female black    0 black, female
#> 3214     Kenya female black    0 black, female
#> 3215   Kristen female white    0  white female
#> 3216   Lakisha female black    0 black, female
#> 3217    Latoya female black    0 black, female
#> 3218   Matthew   male white    0    white male
#> 3219  Meredith female white    0  white female
#> 3220      Neil   male white    0    white male
#> 3221  Tremayne   male black    0    black male
#> 3222    Tyrone   male black    0    black male
#> 3223   Brendan   male white    0    white male
#> 3224    Carrie female white    0  white female
#> 3225  Geoffrey   male white    0    white male
#> 3226     Jamal   male black    0    black male
#> 3227      Jill female white    0  white female
#> 3228    Kareem   male black    0    black male
#> 3229   Kristen female white    0  white female
#> 3230    Latoya female black    0 black, female
#> 3231    Latoya female black    0 black, female
#> 3232     Leroy   male black    0    black male
#> 3233   Matthew   male white    0    white male
#> 3234   Tanisha female black    0 black, female
#> 3235   Brendan   male white    0    white male
#> 3236      Greg   male white    0    white male
#> 3237    Kareem   male black    0    black male
#> 3238     Kenya female black    0 black, female
#> 3239   Latonya female black    0 black, female
#> 3240    Laurie female white    0  white female
#> 3241  Meredith female white    0  white female
#> 3242  Tremayne   male black    0    black male
#> 3243     Emily female white    0  white female
#> 3244     Hakim   male black    0    black male
#> 3245    Latoya female black    0 black, female
#> 3246      Todd   male white    0    white male
#> 3247     Aisha female black    0 black, female
#> 3248     Ebony female black    1 black, female
#> 3249  Geoffrey   male white    1    white male
#> 3250     Jamal   male black    0    black male
#> 3251  Jermaine   male black    0    black male
#> 3252   Lakisha female black    0 black, female
#> 3253  Meredith female white    0  white female
#> 3254  Meredith female white    0  white female
#> 3255      Neil   male white    0    white male
#> 3256     Sarah female white    0  white female
#> 3257     Sarah female white    1  white female
#> 3258    Tyrone   male black    1    black male
#> 3259  Jermaine   male black    0    black male
#> 3260      Jill female white    0  white female
#> 3261   Kristen female white    1  white female
#> 3262     Leroy   male black    0    black male
#> 3263   Allison female white    0  white female
#> 3264   Latonya female black    0 black, female
#> 3265     Aisha female black    0 black, female
#> 3266   Allison female white    0  white female
#> 3267     Brett   male white    0    white male
#> 3268    Carrie female white    0  white female
#> 3269     Kenya female black    0 black, female
#> 3270    Latoya female black    0 black, female
#> 3271     Aisha female black    0 black, female
#> 3272      Anne female white    0  white female
#> 3273      Jill female white    0  white female
#> 3274   Tanisha female black    0 black, female
#> 3275      Brad   male white    1    white male
#> 3276     Emily female white    1  white female
#> 3277  Jermaine   male black    1    black male
#> 3278   Lakisha female black    1 black, female
#> 3279   Allison female white    0  white female
#> 3280     Leroy   male black    1    black male
#> 3281   Allison female white    0  white female
#> 3282    Carrie female white    0  white female
#> 3283       Jay   male white    0    white male
#> 3284    Keisha female black    0 black, female
#> 3285   Lakisha female black    0 black, female
#> 3286   Latonya female black    0 black, female
#> 3287  Meredith female white    0  white female
#> 3288    Tyrone   male black    0    black male
#> 3289      Anne female white    0  white female
#> 3290    Keisha female black    0 black, female
#> 3291  Meredith female white    0  white female
#> 3292   Tanisha female black    0 black, female
#> 3293      Anne female white    0  white female
#> 3294   Darnell   male black    0    black male
#> 3295     Ebony female black    0 black, female
#> 3296     Emily female white    0  white female
#> 3297     Sarah female white    0  white female
#> 3298   Tanisha female black    0 black, female
#> 3299   Allison female white    0  white female
#> 3300     Emily female white    1  white female
#> 3301   Latonya female black    1 black, female
#> 3302    Latoya female black    0 black, female
#> 3303   Allison female white    0  white female
#> 3304      Anne female white    0  white female
#> 3305     Jamal   male black    0    black male
#> 3306  Jermaine   male black    0    black male
#> 3307     Emily female white    0  white female
#> 3308   Lakisha female black    0 black, female
#> 3309    Latoya female black    0 black, female
#> 3310  Meredith female white    0  white female
#> 3311   Allison female white    1  white female
#> 3312     Brett   male white    0    white male
#> 3313     Kenya female black    0 black, female
#> 3314    Latoya female black    0 black, female
#> 3315     Leroy   male black    0    black male
#> 3316      Todd   male white    0    white male
#> 3317      Anne female white    0  white female
#> 3318      Anne female white    0  white female
#> 3319     Ebony female black    0 black, female
#> 3320   Tanisha female black    0 black, female
#> 3321     Aisha female black    0 black, female
#> 3322   Brendan   male white    0    white male
#> 3323     Brett   male white    0    white male
#> 3324    Carrie female white    0  white female
#> 3325   Darnell   male black    0    black male
#> 3326     Ebony female black    0 black, female
#> 3327     Ebony female black    0 black, female
#> 3328   Kristen female white    0  white female
#> 3329     Aisha female black    0 black, female
#> 3330      Greg   male white    0    white male
#> 3331      Jill female white    0  white female
#> 3332     Kenya female black    0 black, female
#> 3333  Meredith female white    0  white female
#> 3334   Tanisha female black    0 black, female
#> 3335     Jamal   male black    0    black male
#> 3336      Neil   male white    0    white male
#> 3337   Brendan   male white    0    white male
#> 3338     Jamal   male black    0    black male
#> 3339      Todd   male white    0    white male
#> 3340    Tyrone   male black    0    black male
#> 3341      Todd   male white    1    white male
#> 3342    Tyrone   male black    1    black male
#> 3343     Emily female white    0  white female
#> 3344     Emily female white    0  white female
#> 3345  Jermaine   male black    0    black male
#> 3346     Kenya female black    0 black, female
#> 3347   Lakisha female black    0 black, female
#> 3348     Leroy   male black    0    black male
#> 3349  Meredith female white    1  white female
#> 3350     Sarah female white    0  white female
#> 3351     Ebony female black    0 black, female
#> 3352     Emily female white    0  white female
#> 3353      Jill female white    0  white female
#> 3354      Jill female white    0  white female
#> 3355    Keisha female black    0 black, female
#> 3356    Keisha female black    0 black, female
#> 3357    Latoya female black    0 black, female
#> 3358  Meredith female white    0  white female
#> 3359     Aisha female black    1 black, female
#> 3360   Darnell   male black    1    black male
#> 3361     Ebony female black    0 black, female
#> 3362       Jay   male white    0    white male
#> 3363      Jill female white    0  white female
#> 3364    Keisha female black    0 black, female
#> 3365  Meredith female white    1  white female
#> 3366  Meredith female white    0  white female
#> 3367     Aisha female black    0 black, female
#> 3368    Carrie female white    0  white female
#> 3369  Meredith female white    0  white female
#> 3370   Tanisha female black    0 black, female
#> 3371      Brad   male white    1    white male
#> 3372     Ebony female black    0 black, female
#> 3373     Emily female white    0  white female
#> 3374   Kristen female white    0  white female
#> 3375   Rasheed   male black    0    black male
#> 3376    Tamika female black    0 black, female
#> 3377      Jill female white    0  white female
#> 3378  Tremayne   male black    0    black male
#> 3379     Sarah female white    0  white female
#> 3380    Tamika female black    0 black, female
#> 3381   Allison female white    0  white female
#> 3382      Anne female white    1  white female
#> 3383    Carrie female white    0  white female
#> 3384     Ebony female black    1 black, female
#> 3385   Latonya female black    0 black, female
#> 3386     Leroy   male black    1    black male
#> 3387      Anne female white    0  white female
#> 3388     Jamal   male black    0    black male
#> 3389    Latoya female black    0 black, female
#> 3390    Laurie female white    0  white female
#> 3391     Sarah female white    0  white female
#> 3392   Tanisha female black    0 black, female
#> 3393   Allison female white    0  white female
#> 3394    Keisha female black    0 black, female
#> 3395   Lakisha female black    0 black, female
#> 3396    Latoya female black    1 black, female
#> 3397    Laurie female white    1  white female
#> 3398  Meredith female white    0  white female
#> 3399     Aisha female black    0 black, female
#> 3400   Allison female white    0  white female
#> 3401     Emily female white    0  white female
#> 3402    Latoya female black    0 black, female
#> 3403    Laurie female white    0  white female
#> 3404    Tamika female black    0 black, female
#> 3405      Anne female white    0  white female
#> 3406     Brett   male white    0    white male
#> 3407  Jermaine   male black    0    black male
#> 3408   Latonya female black    0 black, female
#> 3409   Allison female white    0  white female
#> 3410    Keisha female black    0 black, female
#> 3411    Laurie female white    0  white female
#> 3412     Leroy   male black    0    black male
#> 3413   Tanisha female black    0 black, female
#> 3414      Todd   male white    0    white male
#> 3415    Carrie female white    0  white female
#> 3416     Hakim   male black    0    black male
#> 3417     Aisha female black    0 black, female
#> 3418   Allison female white    0  white female
#> 3419      Jill female white    0  white female
#> 3420   Latonya female black    0 black, female
#> 3421   Darnell   male black    0    black male
#> 3422     Emily female white    0  white female
#> 3423   Kristen female white    0  white female
#> 3424   Latonya female black    0 black, female
#> 3425    Laurie female white    0  white female
#> 3426    Tamika female black    0 black, female
#> 3427     Aisha female black    0 black, female
#> 3428   Allison female white    0  white female
#> 3429    Carrie female white    0  white female
#> 3430    Tamika female black    0 black, female
#> 3431     Ebony female black    0 black, female
#> 3432  Meredith female white    0  white female
#> 3433      Neil   male white    0    white male
#> 3434  Tremayne   male black    0    black male
#> 3435     Aisha female black    0 black, female
#> 3436   Allison female white    0  white female
#> 3437     Ebony female black    0 black, female
#> 3438     Hakim   male black    0    black male
#> 3439       Jay   male white    1    white male
#> 3440      Jill female white    0  white female
#> 3441   Lakisha female black    0 black, female
#> 3442      Neil   male white    0    white male
#> 3443   Allison female white    0  white female
#> 3444   Brendan   male white    0    white male
#> 3445   Darnell   male black    0    black male
#> 3446     Ebony female black    0 black, female
#> 3447  Geoffrey   male white    0    white male
#> 3448  Geoffrey   male white    0    white male
#> 3449  Geoffrey   male white    0    white male
#> 3450      Greg   male white    0    white male
#> 3451       Jay   male white    0    white male
#> 3452  Jermaine   male black    0    black male
#> 3453   Lakisha female black    0 black, female
#> 3454   Latonya female black    0 black, female
#> 3455   Matthew   male white    0    white male
#> 3456      Neil   male white    0    white male
#> 3457   Rasheed   male black    0    black male
#> 3458   Rasheed   male black    0    black male
#> 3459   Rasheed   male black    0    black male
#> 3460     Sarah female white    0  white female
#> 3461     Sarah female white    0  white female
#> 3462     Sarah female white    0  white female
#> 3463    Tamika female black    0 black, female
#> 3464   Tanisha female black    0 black, female
#> 3465  Tremayne   male black    0    black male
#> 3466  Tremayne   male black    0    black male
#> 3467   Brendan   male white    0    white male
#> 3468   Brendan   male white    0    white male
#> 3469      Greg   male white    0    white male
#> 3470     Jamal   male black    0    black male
#> 3471  Jermaine   male black    0    black male
#> 3472    Kareem   male black    0    black male
#> 3473    Keisha female black    0 black, female
#> 3474    Laurie female white    0  white female
#> 3475    Laurie female white    0  white female
#> 3476     Leroy   male black    0    black male
#> 3477     Leroy   male black    0    black male
#> 3478      Neil   male white    0    white male
#> 3479     Sarah female white    0  white female
#> 3480    Tamika female black    0 black, female
#> 3481   Tanisha female black    0 black, female
#> 3482      Todd   male white    0    white male
#> 3483     Ebony female black    0 black, female
#> 3484      Greg   male white    0    white male
#> 3485      Greg   male white    1    white male
#> 3486     Hakim   male black    0    black male
#> 3487     Hakim   male black    0    black male
#> 3488    Kareem   male black    0    black male
#> 3489    Kareem   male black    0    black male
#> 3490     Kenya female black    0 black, female
#> 3491   Kristen female white    0  white female
#> 3492   Kristen female white    1  white female
#> 3493   Lakisha female black    0 black, female
#> 3494    Latoya female black    0 black, female
#> 3495    Laurie female white    0  white female
#> 3496  Meredith female white    0  white female
#> 3497      Neil   male white    0    white male
#> 3498      Neil   male white    0    white male
#> 3499    Tamika female black    0 black, female
#> 3500      Todd   male white    0    white male
#> 3501      Todd   male white    0    white male
#> 3502    Tyrone   male black    0    black male
#> 3503     Jamal   male black    0    black male
#> 3504    Kareem   male black    0    black male
#> 3505    Laurie female white    0  white female
#> 3506      Todd   male white    0    white male
#> 3507     Aisha female black    0 black, female
#> 3508      Anne female white    0  white female
#> 3509   Brendan   male white    0    white male
#> 3510     Brett   male white    0    white male
#> 3511     Emily female white    0  white female
#> 3512      Greg   male white    0    white male
#> 3513     Jamal   male black    0    black male
#> 3514  Jermaine   male black    0    black male
#> 3515   Latonya female black    0 black, female
#> 3516   Latonya female black    0 black, female
#> 3517     Leroy   male black    0    black male
#> 3518  Meredith female white    0  white female
#> 3519   Rasheed   male black    0    black male
#> 3520   Rasheed   male black    0    black male
#> 3521     Sarah female white    0  white female
#> 3522      Todd   male white    0    white male
#> 3523      Brad   male white    0    white male
#> 3524     Ebony female black    0 black, female
#> 3525      Greg   male white    0    white male
#> 3526     Hakim   male black    0    black male
#> 3527     Emily female white    0  white female
#> 3528     Kenya female black    0 black, female
#> 3529     Sarah female white    0  white female
#> 3530    Tamika female black    0 black, female
#> 3531      Brad   male white    0    white male
#> 3532    Carrie female white    0  white female
#> 3533     Ebony female black    0 black, female
#> 3534  Geoffrey   male white    0    white male
#> 3535  Geoffrey   male white    0    white male
#> 3536     Jamal   male black    0    black male
#> 3537    Kareem   male black    0    black male
#> 3538   Kristen female white    0  white female
#> 3539   Lakisha female black    0 black, female
#> 3540     Leroy   male black    0    black male
#> 3541      Neil   male white    0    white male
#> 3542    Tamika female black    0 black, female
#> 3543     Aisha female black    0 black, female
#> 3544   Allison female white    0  white female
#> 3545      Anne female white    0  white female
#> 3546      Anne female white    0  white female
#> 3547      Brad   male white    0    white male
#> 3548   Brendan   male white    0    white male
#> 3549     Brett   male white    0    white male
#> 3550  Jermaine   male black    0    black male
#> 3551   Lakisha female black    0 black, female
#> 3552   Latonya female black    0 black, female
#> 3553   Latonya female black    0 black, female
#> 3554    Laurie female white    0  white female
#> 3555     Leroy   male black    0    black male
#> 3556  Meredith female white    0  white female
#> 3557   Rasheed   male black    0    black male
#> 3558  Tremayne   male black    0    black male
#> 3559   Allison female white    0  white female
#> 3560      Anne female white    0  white female
#> 3561  Geoffrey   male white    0    white male
#> 3562     Jamal   male black    0    black male
#> 3563    Kareem   male black    0    black male
#> 3564   Kristen female white    0  white female
#> 3565    Tamika female black    0 black, female
#> 3566   Tanisha female black    0 black, female
#> 3567      Anne female white    0  white female
#> 3568     Emily female white    0  white female
#> 3569     Hakim   male black    0    black male
#> 3570      Jill female white    0  white female
#> 3571     Kenya female black    0 black, female
#> 3572   Kristen female white    0  white female
#> 3573   Latonya female black    0 black, female
#> 3574   Matthew   male white    0    white male
#> 3575  Meredith female white    0  white female
#> 3576   Rasheed   male black    0    black male
#> 3577  Tremayne   male black    0    black male
#> 3578  Tremayne   male black    0    black male
#> 3579  Jermaine   male black    0    black male
#> 3580    Laurie female white    1  white female
#> 3581   Matthew   male white    0    white male
#> 3582   Rasheed   male black    0    black male
#> 3583     Brett   male white    0    white male
#> 3584     Emily female white    0  white female
#> 3585  Geoffrey   male white    0    white male
#> 3586     Jamal   male black    0    black male
#> 3587     Jamal   male black    1    black male
#> 3588     Jamal   male black    0    black male
#> 3589    Kareem   male black    0    black male
#> 3590   Latonya female black    0 black, female
#> 3591    Laurie female white    0  white female
#> 3592      Neil   male white    1    white male
#> 3593     Sarah female white    0  white female
#> 3594    Tyrone   male black    0    black male
#> 3595     Ebony female black    0 black, female
#> 3596     Jamal   male black    0    black male
#> 3597     Sarah female white    0  white female
#> 3598      Todd   male white    0    white male
#> 3599     Ebony female black    1 black, female
#> 3600      Jill female white    1  white female
#> 3601   Kristen female white    1  white female
#> 3602   Tanisha female black    0 black, female
#> 3603    Carrie female white    0  white female
#> 3604   Darnell   male black    0    black male
#> 3605  Geoffrey   male white    0    white male
#> 3606  Geoffrey   male white    0    white male
#> 3607  Jermaine   male black    0    black male
#> 3608   Latonya female black    0 black, female
#> 3609   Matthew   male white    0    white male
#> 3610   Tanisha female black    0 black, female
#> 3611   Allison female white    0  white female
#> 3612   Darnell   male black    0    black male
#> 3613       Jay   male white    1    white male
#> 3614    Tyrone   male black    0    black male
#> 3615   Allison female white    0  white female
#> 3616      Anne female white    0  white female
#> 3617      Anne female white    0  white female
#> 3618     Ebony female black    0 black, female
#> 3619   Lakisha female black    0 black, female
#> 3620     Sarah female white    0  white female
#> 3621   Tanisha female black    0 black, female
#> 3622   Tanisha female black    0 black, female
#> 3623   Brendan   male white    0    white male
#> 3624     Ebony female black    0 black, female
#> 3625      Greg   male white    0    white male
#> 3626    Latoya female black    1 black, female
#> 3627      Brad   male white    1    white male
#> 3628     Ebony female black    0 black, female
#> 3629      Neil   male white    1    white male
#> 3630   Rasheed   male black    1    black male
#> 3631    Carrie female white    1  white female
#> 3632    Latoya female black    1 black, female
#> 3633      Anne female white    0  white female
#> 3634    Carrie female white    1  white female
#> 3635     Ebony female black    0 black, female
#> 3636     Hakim   male black    0    black male
#> 3637    Keisha female black    1 black, female
#> 3638     Kenya female black    0 black, female
#> 3639      Neil   male white    0    white male
#> 3640      Todd   male white    0    white male
#> 3641   Kristen female white    0  white female
#> 3642     Sarah female white    0  white female
#> 3643    Tamika female black    0 black, female
#> 3644   Tanisha female black    0 black, female
#> 3645   Allison female white    1  white female
#> 3646     Ebony female black    1 black, female
#> 3647    Latoya female black    1 black, female
#> 3648    Laurie female white    0  white female
#> 3649   Darnell   male black    0    black male
#> 3650       Jay   male white    0    white male
#> 3651   Brendan   male white    0    white male
#> 3652   Darnell   male black    0    black male
#> 3653  Geoffrey   male white    0    white male
#> 3654    Latoya female black    0 black, female
#> 3655     Aisha female black    0 black, female
#> 3656   Allison female white    0  white female
#> 3657       Jay   male white    0    white male
#> 3658     Kenya female black    0 black, female
#> 3659   Kristen female white    0  white female
#> 3660   Lakisha female black    0 black, female
#> 3661  Meredith female white    0  white female
#> 3662    Tyrone   male black    0    black male
#> 3663      Anne female white    0  white female
#> 3664    Carrie female white    0  white female
#> 3665     Kenya female black    0 black, female
#> 3666    Latoya female black    0 black, female
#> 3667    Carrie female white    0  white female
#> 3668      Greg   male white    0    white male
#> 3669       Jay   male white    0    white male
#> 3670     Kenya female black    0 black, female
#> 3671    Latoya female black    0 black, female
#> 3672  Meredith female white    0  white female
#> 3673   Rasheed   male black    0    black male
#> 3674   Tanisha female black    0 black, female
#> 3675      Anne female white    0  white female
#> 3676    Latoya female black    0 black, female
#> 3677     Sarah female white    0  white female
#> 3678   Tanisha female black    0 black, female
#> 3679    Carrie female white    0  white female
#> 3680     Hakim   male black    0    black male
#> 3681     Emily female white    0  white female
#> 3682   Lakisha female black    0 black, female
#> 3683    Latoya female black    0 black, female
#> 3684     Sarah female white    0  white female
#> 3685   Allison female white    0  white female
#> 3686     Ebony female black    0 black, female
#> 3687   Kristen female white    0  white female
#> 3688    Tamika female black    0 black, female
#> 3689   Brendan   male white    0    white male
#> 3690    Latoya female black    0 black, female
#> 3691   Brendan   male white    0    white male
#> 3692     Ebony female black    1 black, female
#> 3693     Emily female white    1  white female
#> 3694   Latonya female black    1 black, female
#> 3695    Latoya female black    0 black, female
#> 3696    Laurie female white    1  white female
#> 3697     Aisha female black    1 black, female
#> 3698    Carrie female white    0  white female
#> 3699  Geoffrey   male white    0    white male
#> 3700  Jermaine   male black    0    black male
#> 3701    Keisha female black    0 black, female
#> 3702   Kristen female white    1  white female
#> 3703   Latonya female black    0 black, female
#> 3704    Laurie female white    0  white female
#> 3705   Lakisha female black    0 black, female
#> 3706     Sarah female white    0  white female
#> 3707     Emily female white    0  white female
#> 3708     Jamal   male black    0    black male
#> 3709      Brad   male white    0    white male
#> 3710    Tamika female black    0 black, female
#> 3711   Allison female white    0  white female
#> 3712   Latonya female black    0 black, female
#> 3713  Meredith female white    0  white female
#> 3714    Tamika female black    0 black, female
#> 3715     Ebony female black    0 black, female
#> 3716  Geoffrey   male white    1    white male
#> 3717    Keisha female black    0 black, female
#> 3718    Laurie female white    0  white female
#> 3719  Meredith female white    0  white female
#> 3720   Tanisha female black    0 black, female
#> 3721     Aisha female black    0 black, female
#> 3722      Brad   male white    0    white male
#> 3723     Leroy   male black    0    black male
#> 3724      Neil   male white    0    white male
#> 3725   Lakisha female black    0 black, female
#> 3726    Latoya female black    0 black, female
#> 3727  Meredith female white    0  white female
#> 3728     Sarah female white    0  white female
#> 3729   Kristen female white    0  white female
#> 3730   Latonya female black    0 black, female
#> 3731    Laurie female white    0  white female
#> 3732     Sarah female white    0  white female
#> 3733    Tamika female black    0 black, female
#> 3734   Tanisha female black    0 black, female
#> 3735   Allison female white    0  white female
#> 3736     Kenya female black    0 black, female
#> 3737  Meredith female white    0  white female
#> 3738    Tamika female black    0 black, female
#> 3739      Anne female white    0  white female
#> 3740    Keisha female black    0 black, female
#> 3741   Kristen female white    0  white female
#> 3742   Lakisha female black    0 black, female
#> 3743     Aisha female black    0 black, female
#> 3744   Allison female white    0  white female
#> 3745    Carrie female white    0  white female
#> 3746   Darnell   male black    0    black male
#> 3747      Jill female white    0  white female
#> 3748    Keisha female black    0 black, female
#> 3749   Allison female white    0  white female
#> 3750     Brett   male white    0    white male
#> 3751     Emily female white    0  white female
#> 3752   Latonya female black    0 black, female
#> 3753    Latoya female black    0 black, female
#> 3754    Tyrone   male black    0    black male
#> 3755  Geoffrey   male white    0    white male
#> 3756      Jill female white    0  white female
#> 3757     Kenya female black    1 black, female
#> 3758   Latonya female black    0 black, female
#> 3759    Laurie female white    0  white female
#> 3760   Rasheed   male black    0    black male
#> 3761      Anne female white    0  white female
#> 3762     Ebony female black    0 black, female
#> 3763     Emily female white    0  white female
#> 3764   Tanisha female black    0 black, female
#> 3765   Allison female white    0  white female
#> 3766      Anne female white    0  white female
#> 3767     Ebony female black    0 black, female
#> 3768     Emily female white    0  white female
#> 3769     Kenya female black    0 black, female
#> 3770   Tanisha female black    0 black, female
#> 3771   Allison female white    0  white female
#> 3772     Jamal   male black    0    black male
#> 3773       Jay   male white    1    white male
#> 3774    Keisha female black    0 black, female
#> 3775      Brad   male white    0    white male
#> 3776    Kareem   male black    0    black male
#> 3777    Carrie female white    0  white female
#> 3778     Ebony female black    0 black, female
#> 3779   Latonya female black    0 black, female
#> 3780  Meredith female white    0  white female
#> 3781      Anne female white    0  white female
#> 3782    Latoya female black    0 black, female
#> 3783  Meredith female white    0  white female
#> 3784  Meredith female white    0  white female
#> 3785    Tamika female black    0 black, female
#> 3786   Tanisha female black    0 black, female
#> 3787      Anne female white    0  white female
#> 3788     Ebony female black    0 black, female
#> 3789   Kristen female white    0  white female
#> 3790   Tanisha female black    0 black, female
#> 3791   Allison female white    1  white female
#> 3792     Brett   male white    0    white male
#> 3793     Ebony female black    0 black, female
#> 3794       Jay   male white    0    white male
#> 3795      Jill female white    0  white female
#> 3796    Kareem   male black    0    black male
#> 3797     Kenya female black    0 black, female
#> 3798   Latonya female black    0 black, female
#> 3799   Allison female white    1  white female
#> 3800     Ebony female black    0 black, female
#> 3801     Emily female white    0  white female
#> 3802  Geoffrey   male white    0    white male
#> 3803   Latonya female black    0 black, female
#> 3804     Leroy   male black    0    black male
#> 3805      Todd   male white    0    white male
#> 3806  Tremayne   male black    0    black male
#> 3807     Aisha female black    0 black, female
#> 3808     Aisha female black    1 black, female
#> 3809      Anne female white    0  white female
#> 3810      Brad   male white    0    white male
#> 3811      Brad   male white    1    white male
#> 3812   Brendan   male white    0    white male
#> 3813    Carrie female white    0  white female
#> 3814    Carrie female white    0  white female
#> 3815   Darnell   male black    0    black male
#> 3816     Ebony female black    0 black, female
#> 3817     Ebony female black    0 black, female
#> 3818     Hakim   male black    0    black male
#> 3819     Hakim   male black    0    black male
#> 3820       Jay   male white    0    white male
#> 3821      Jill female white    0  white female
#> 3822    Kareem   male black    0    black male
#> 3823    Keisha female black    0 black, female
#> 3824     Kenya female black    0 black, female
#> 3825   Kristen female white    0  white female
#> 3826   Lakisha female black    0 black, female
#> 3827    Laurie female white    0  white female
#> 3828   Matthew   male white    0    white male
#> 3829  Meredith female white    0  white female
#> 3830   Rasheed   male black    0    black male
#> 3831   Tanisha female black    0 black, female
#> 3832      Todd   male white    0    white male
#> 3833      Todd   male white    0    white male
#> 3834    Tyrone   male black    0    black male
#> 3835      Anne female white    0  white female
#> 3836      Anne female white    0  white female
#> 3837     Ebony female black    0 black, female
#> 3838      Jill female white    0  white female
#> 3839     Kenya female black    0 black, female
#> 3840  Meredith female white    0  white female
#> 3841  Meredith female white    0  white female
#> 3842   Rasheed   male black    0    black male
#> 3843   Rasheed   male black    0    black male
#> 3844    Tamika female black    0 black, female
#> 3845      Todd   male white    0    white male
#> 3846  Tremayne   male black    0    black male
#> 3847     Aisha female black    0 black, female
#> 3848      Anne female white    0  white female
#> 3849   Brendan   male white    0    white male
#> 3850     Leroy   male black    0    black male
#> 3851   Allison female white    0  white female
#> 3852  Geoffrey   male white    0    white male
#> 3853     Hakim   male black    0    black male
#> 3854   Rasheed   male black    0    black male
#> 3855      Anne female white    0  white female
#> 3856     Ebony female black    0 black, female
#> 3857    Laurie female white    0  white female
#> 3858   Tanisha female black    0 black, female
#> 3859     Aisha female black    0 black, female
#> 3860   Brendan   male white    0    white male
#> 3861      Neil   male white    0    white male
#> 3862    Tamika female black    0 black, female
#> 3863   Brendan   male white    0    white male
#> 3864     Kenya female black    0 black, female
#> 3865      Neil   male white    0    white male
#> 3866    Tyrone   male black    0    black male
#> 3867      Anne female white    0  white female
#> 3868   Brendan   male white    0    white male
#> 3869     Brett   male white    0    white male
#> 3870      Greg   male white    0    white male
#> 3871     Hakim   male black    0    black male
#> 3872     Jamal   male black    0    black male
#> 3873  Jermaine   male black    0    black male
#> 3874    Kareem   male black    0    black male
#> 3875   Brendan   male white    0    white male
#> 3876     Jamal   male black    0    black male
#> 3877   Latonya female black    0 black, female
#> 3878   Matthew   male white    0    white male
#> 3879    Carrie female white    0  white female
#> 3880     Ebony female black    0 black, female
#> 3881     Emily female white    0  white female
#> 3882      Jill female white    0  white female
#> 3883    Tamika female black    0 black, female
#> 3884   Tanisha female black    0 black, female
#> 3885      Todd   male white    0    white male
#> 3886    Tyrone   male black    0    black male
#> 3887     Aisha female black    0 black, female
#> 3888   Brendan   male white    0    white male
#> 3889       Jay   male white    0    white male
#> 3890   Lakisha female black    0 black, female
#> 3891     Brett   male white    0    white male
#> 3892    Keisha female black    0 black, female
#> 3893    Laurie female white    0  white female
#> 3894   Rasheed   male black    0    black male
#> 3895     Brett   male white    0    white male
#> 3896     Hakim   male black    0    black male
#> 3897     Leroy   male black    0    black male
#> 3898      Todd   male white    0    white male
#> 3899     Aisha female black    0 black, female
#> 3900     Brett   male white    0    white male
#> 3901   Lakisha female black    0 black, female
#> 3902   Matthew   male white    0    white male
#> 3903      Anne female white    0  white female
#> 3904     Kenya female black    0 black, female
#> 3905   Lakisha female black    0 black, female
#> 3906     Sarah female white    0  white female
#> 3907     Emily female white    0  white female
#> 3908     Jamal   male black    0    black male
#> 3909  Jermaine   male black    0    black male
#> 3910     Sarah female white    0  white female
#> 3911      Greg   male white    0    white male
#> 3912     Jamal   male black    0    black male
#> 3913   Lakisha female black    0 black, female
#> 3914      Todd   male white    0    white male
#> 3915    Carrie female white    0  white female
#> 3916   Lakisha female black    0 black, female
#> 3917   Latonya female black    0 black, female
#> 3918  Meredith female white    1  white female
#> 3919      Anne female white    0  white female
#> 3920    Carrie female white    0  white female
#> 3921  Jermaine   male black    0    black male
#> 3922    Keisha female black    0 black, female
#> 3923    Latoya female black    0 black, female
#> 3924  Meredith female white    0  white female
#> 3925     Aisha female black    0 black, female
#> 3926    Carrie female white    0  white female
#> 3927      Anne female white    0  white female
#> 3928     Emily female white    0  white female
#> 3929    Latoya female black    0 black, female
#> 3930    Tamika female black    0 black, female
#> 3931      Anne female white    0  white female
#> 3932    Kareem   male black    0    black male
#> 3933  Meredith female white    0  white female
#> 3934   Rasheed   male black    0    black male
#> 3935     Aisha female black    0 black, female
#> 3936     Aisha female black    0 black, female
#> 3937     Emily female white    0  white female
#> 3938   Latonya female black    0 black, female
#> 3939    Laurie female white    0  white female
#> 3940  Meredith female white    0  white female
#> 3941     Aisha female black    0 black, female
#> 3942    Keisha female black    0 black, female
#> 3943    Laurie female white    0  white female
#> 3944  Meredith female white    0  white female
#> 3945     Aisha female black    0 black, female
#> 3946     Emily female white    0  white female
#> 3947   Kristen female white    0  white female
#> 3948   Tanisha female black    0 black, female
#> 3949   Allison female white    0  white female
#> 3950     Ebony female black    0 black, female
#> 3951      Greg   male white    0    white male
#> 3952   Lakisha female black    0 black, female
#> 3953    Carrie female white    0  white female
#> 3954     Ebony female black    1 black, female
#> 3955    Latoya female black    0 black, female
#> 3956     Sarah female white    0  white female
#> 3957   Kristen female white    0  white female
#> 3958    Laurie female white    0  white female
#> 3959    Tamika female black    0 black, female
#> 3960   Tanisha female black    0 black, female
#> 3961     Aisha female black    0 black, female
#> 3962   Allison female white    0  white female
#> 3963    Carrie female white    0  white female
#> 3964   Darnell   male black    0    black male
#> 3965     Emily female white    0  white female
#> 3966    Keisha female black    0 black, female
#> 3967    Laurie female white    0  white female
#> 3968    Tamika female black    0 black, female
#> 3969       Jay   male white    0    white male
#> 3970   Latonya female black    0 black, female
#> 3971     Aisha female black    0 black, female
#> 3972   Allison female white    0  white female
#> 3973      Jill female white    0  white female
#> 3974   Lakisha female black    0 black, female
#> 3975   Latonya female black    0 black, female
#> 3976    Laurie female white    0  white female
#> 3977     Sarah female white    0  white female
#> 3978   Tanisha female black    0 black, female
#> 3979      Anne female white    0  white female
#> 3980   Latonya female black    0 black, female
#> 3981  Meredith female white    0  white female
#> 3982    Tamika female black    0 black, female
#> 3983   Brendan   male white    0    white male
#> 3984     Jamal   male black    0    black male
#> 3985   Matthew   male white    0    white male
#> 3986  Tremayne   male black    0    black male
#> 3987   Allison female white    0  white female
#> 3988    Latoya female black    0 black, female
#> 3989      Neil   male white    0    white male
#> 3990    Tyrone   male black    0    black male
#> 3991   Brendan   male white    0    white male
#> 3992     Ebony female black    0 black, female
#> 3993     Sarah female white    0  white female
#> 3994   Tanisha female black    0 black, female
#> 3995      Anne female white    0  white female
#> 3996   Brendan   male white    0    white male
#> 3997     Ebony female black    0 black, female
#> 3998     Hakim   male black    0    black male
#> 3999   Kristen female white    0  white female
#> 4000    Tamika female black    0 black, female
#> 4001    Carrie female white    0  white female
#> 4002  Jermaine   male black    0    black male
#> 4003      Jill female white    0  white female
#> 4004    Keisha female black    0 black, female
#> 4005    Latoya female black    0 black, female
#> 4006   Matthew   male white    0    white male
#> 4007    Carrie female white    1  white female
#> 4008     Kenya female black    1 black, female
#> 4009     Aisha female black    0 black, female
#> 4010    Laurie female white    0  white female
#> 4011     Sarah female white    0  white female
#> 4012     Sarah female white    0  white female
#> 4013    Tamika female black    0 black, female
#> 4014   Tanisha female black    0 black, female
#> 4015    Carrie female white    0  white female
#> 4016   Latonya female black    0 black, female
#> 4017    Laurie female white    0  white female
#> 4018   Tanisha female black    0 black, female
#> 4019      Anne female white    1  white female
#> 4020   Rasheed   male black    0    black male
#> 4021      Jill female white    0  white female
#> 4022    Keisha female black    0 black, female
#> 4023   Kristen female white    0  white female
#> 4024   Tanisha female black    0 black, female
#> 4025   Allison female white    0  white female
#> 4026     Emily female white    0  white female
#> 4027   Lakisha female black    0 black, female
#> 4028   Latonya female black    0 black, female
#> 4029   Matthew   male white    0    white male
#> 4030    Tyrone   male black    0    black male
#> 4031   Kristen female white    0  white female
#> 4032    Latoya female black    0 black, female
#> 4033    Laurie female white    0  white female
#> 4034    Tamika female black    0 black, female
#> 4035     Emily female white    0  white female
#> 4036    Keisha female black    0 black, female
#> 4037    Laurie female white    0  white female
#> 4038     Sarah female white    0  white female
#> 4039    Tamika female black    0 black, female
#> 4040   Tanisha female black    0 black, female
#> 4041     Aisha female black    0 black, female
#> 4042   Kristen female white    0  white female
#> 4043   Lakisha female black    0 black, female
#> 4044    Laurie female white    0  white female
#> 4045     Aisha female black    0 black, female
#> 4046   Allison female white    1  white female
#> 4047    Latoya female black    0 black, female
#> 4048    Laurie female white    0  white female
#> 4049   Allison female white    0  white female
#> 4050      Anne female white    0  white female
#> 4051      Anne female white    0  white female
#> 4052   Darnell   male black    0    black male
#> 4053    Keisha female black    0 black, female
#> 4054    Latoya female black    0 black, female
#> 4055   Tanisha female black    0 black, female
#> 4056      Todd   male white    0    white male
#> 4057     Ebony female black    0 black, female
#> 4058     Emily female white    0  white female
#> 4059   Latonya female black    0 black, female
#> 4060    Laurie female white    0  white female
#> 4061     Aisha female black    0 black, female
#> 4062   Allison female white    0  white female
#> 4063     Jamal   male black    0    black male
#> 4064       Jay   male white    0    white male
#> 4065      Jill female white    0  white female
#> 4066   Latonya female black    0 black, female
#> 4067   Allison female white    1  white female
#> 4068      Anne female white    0  white female
#> 4069     Ebony female black    0 black, female
#> 4070     Kenya female black    0 black, female
#> 4071     Emily female white    1  white female
#> 4072  Geoffrey   male white    1    white male
#> 4073    Kareem   male black    1    black male
#> 4074     Kenya female black    1 black, female
#> 4075   Kristen female white    0  white female
#> 4076   Latonya female black    0 black, female
#> 4077  Meredith female white    0  white female
#> 4078   Tanisha female black    0 black, female
#> 4079     Aisha female black    0 black, female
#> 4080      Anne female white    0  white female
#> 4081   Brendan   male white    0    white male
#> 4082     Emily female white    0  white female
#> 4083       Jay   male white    0    white male
#> 4084    Keisha female black    0 black, female
#> 4085   Latonya female black    1 black, female
#> 4086    Tamika female black    1 black, female
#> 4087     Aisha female black    0 black, female
#> 4088      Anne female white    0  white female
#> 4089      Brad   male white    0    white male
#> 4090    Carrie female white    0  white female
#> 4091     Ebony female black    0 black, female
#> 4092     Emily female white    0  white female
#> 4093  Geoffrey   male white    0    white male
#> 4094      Greg   male white    0    white male
#> 4095      Greg   male white    0    white male
#> 4096     Hakim   male black    0    black male
#> 4097     Hakim   male black    0    black male
#> 4098  Jermaine   male black    0    black male
#> 4099      Jill female white    0  white female
#> 4100      Jill female white    0  white female
#> 4101    Kareem   male black    0    black male
#> 4102    Keisha female black    0 black, female
#> 4103     Kenya female black    0 black, female
#> 4104    Latoya female black    0 black, female
#> 4105    Latoya female black    0 black, female
#> 4106    Laurie female white    0  white female
#> 4107   Matthew   male white    0    white male
#> 4108  Meredith female white    0  white female
#> 4109     Sarah female white    0  white female
#> 4110    Tamika female black    0 black, female
#> 4111      Todd   male white    0    white male
#> 4112  Tremayne   male black    0    black male
#> 4113  Tremayne   male black    0    black male
#> 4114    Tyrone   male black    0    black male
#> 4115     Ebony female black    0 black, female
#> 4116     Emily female white    0  white female
#> 4117      Jill female white    0  white female
#> 4118   Lakisha female black    0 black, female
#> 4119      Greg   male white    0    white male
#> 4120       Jay   male white    0    white male
#> 4121     Leroy   male black    0    black male
#> 4122   Rasheed   male black    0    black male
#> 4123     Aisha female black    0 black, female
#> 4124    Kareem   male black    0    black male
#> 4125   Matthew   male white    0    white male
#> 4126  Meredith female white    0  white female
#> 4127      Greg   male white    1    white male
#> 4128       Jay   male white    1    white male
#> 4129    Kareem   male black    1    black male
#> 4130    Tamika female black    1 black, female
#> 4131      Anne female white    0  white female
#> 4132    Latoya female black    0 black, female
#> 4133  Meredith female white    0  white female
#> 4134   Tanisha female black    0 black, female
#> 4135      Greg   male white    0    white male
#> 4136     Jamal   male black    0    black male
#> 4137    Latoya female black    0 black, female
#> 4138      Neil   male white    0    white male
#> 4139   Allison female white    0  white female
#> 4140     Ebony female black    0 black, female
#> 4141   Lakisha female black    0 black, female
#> 4142  Meredith female white    0  white female
#> 4143     Brett   male white    1    white male
#> 4144     Ebony female black    1 black, female
#> 4145      Neil   male white    0    white male
#> 4146  Tremayne   male black    1    black male
#> 4147      Anne female white    0  white female
#> 4148    Kareem   male black    0    black male
#> 4149     Kenya female black    0 black, female
#> 4150   Matthew   male white    0    white male
#> 4151      Jill female white    0  white female
#> 4152     Kenya female black    0 black, female
#> 4153     Sarah female white    0  white female
#> 4154    Tamika female black    0 black, female
#> 4155      Brad   male white    0    white male
#> 4156  Jermaine   male black    0    black male
#> 4157      Neil   male white    0    white male
#> 4158    Tamika female black    0 black, female
#> 4159   Lakisha female black    0 black, female
#> 4160   Matthew   male white    0    white male
#> 4161  Meredith female white    0  white female
#> 4162   Rasheed   male black    0    black male
#> 4163      Anne female white    0  white female
#> 4164   Rasheed   male black    0    black male
#> 4165     Sarah female white    0  white female
#> 4166  Tremayne   male black    0    black male
#> 4167      Greg   male white    0    white male
#> 4168   Rasheed   male black    0    black male
#> 4169   Tanisha female black    1 black, female
#> 4170      Todd   male white    0    white male
#> 4171     Brett   male white    0    white male
#> 4172     Leroy   male black    0    black male
#> 4173   Matthew   male white    0    white male
#> 4174    Tamika female black    0 black, female
#> 4175     Aisha female black    0 black, female
#> 4176   Allison female white    0  white female
#> 4177     Sarah female white    0  white female
#> 4178    Tamika female black    0 black, female
#> 4179   Allison female white    0  white female
#> 4180   Allison female white    0  white female
#> 4181      Anne female white    0  white female
#> 4182     Ebony female black    0 black, female
#> 4183   Lakisha female black    0 black, female
#> 4184   Latonya female black    0 black, female
#> 4185   Kristen female white    0  white female
#> 4186     Sarah female white    0  white female
#> 4187    Tamika female black    0 black, female
#> 4188   Tanisha female black    0 black, female
#> 4189      Jill female white    0  white female
#> 4190    Latoya female black    0 black, female
#> 4191   Kristen female white    1  white female
#> 4192   Lakisha female black    0 black, female
#> 4193   Latonya female black    0 black, female
#> 4194  Meredith female white    1  white female
#> 4195      Anne female white    0  white female
#> 4196    Carrie female white    0  white female
#> 4197     Ebony female black    0 black, female
#> 4198     Emily female white    0  white female
#> 4199      Jill female white    0  white female
#> 4200     Kenya female black    0 black, female
#> 4201   Tanisha female black    0 black, female
#> 4202  Tremayne   male black    0    black male
#> 4203    Carrie female white    0  white female
#> 4204      Jill female white    0  white female
#> 4205    Latoya female black    0 black, female
#> 4206   Tanisha female black    0 black, female
#> 4207    Laurie female white    0  white female
#> 4208    Tamika female black    0 black, female
#> 4209     Sarah female white    0  white female
#> 4210    Tamika female black    0 black, female
#> 4211     Emily female white    0  white female
#> 4212     Kenya female black    0 black, female
#> 4213   Kristen female white    0  white female
#> 4214   Latonya female black    0 black, female
#> 4215      Anne female white    0  white female
#> 4216    Carrie female white    0  white female
#> 4217   Darnell   male black    0    black male
#> 4218     Hakim   male black    0    black male
#> 4219       Jay   male white    0    white male
#> 4220      Jill female white    0  white female
#> 4221   Lakisha female black    0 black, female
#> 4222    Tamika female black    0 black, female
#> 4223     Kenya female black    0 black, female
#> 4224   Kristen female white    0  white female
#> 4225    Laurie female white    0  white female
#> 4226    Tamika female black    0 black, female
#> 4227   Allison female white    0  white female
#> 4228    Keisha female black    0 black, female
#> 4229   Kristen female white    0  white female
#> 4230     Sarah female white    0  white female
#> 4231    Tamika female black    0 black, female
#> 4232  Tremayne   male black    0    black male
#> 4233      Anne female white    0  white female
#> 4234     Ebony female black    0 black, female
#> 4235     Kenya female black    0 black, female
#> 4236   Kristen female white    0  white female
#> 4237     Aisha female black    0 black, female
#> 4238   Allison female white    0  white female
#> 4239    Carrie female white    0  white female
#> 4240    Keisha female black    0 black, female
#> 4241   Allison female white    0  white female
#> 4242  Jermaine   male black    1    black male
#> 4243     Leroy   male black    0    black male
#> 4244      Neil   male white    1    white male
#> 4245       Jay   male white    0    white male
#> 4246      Jill female white    1  white female
#> 4247     Kenya female black    1 black, female
#> 4248   Kristen female white    0  white female
#> 4249    Latoya female black    1 black, female
#> 4250   Rasheed   male black    0    black male
#> 4251     Ebony female black    0 black, female
#> 4252  Geoffrey   male white    0    white male
#> 4253       Jay   male white    0    white male
#> 4254      Jill female white    0  white female
#> 4255     Kenya female black    0 black, female
#> 4256   Latonya female black    0 black, female
#> 4257     Sarah female white    0  white female
#> 4258   Tanisha female black    0 black, female
#> 4259   Brendan   male white    0    white male
#> 4260     Emily female white    0  white female
#> 4261   Kristen female white    0  white female
#> 4262    Latoya female black    0 black, female
#> 4263   Rasheed   male black    0    black male
#> 4264    Tamika female black    0 black, female
#> 4265      Jill female white    0  white female
#> 4266    Latoya female black    0 black, female
#> 4267    Laurie female white    0  white female
#> 4268    Tamika female black    0 black, female
#> 4269    Carrie female white    0  white female
#> 4270     Ebony female black    0 black, female
#> 4271     Ebony female black    0 black, female
#> 4272     Kenya female black    0 black, female
#> 4273   Kristen female white    0  white female
#> 4274      Todd   male white    0    white male
#> 4275     Aisha female black    0 black, female
#> 4276   Allison female white    0  white female
#> 4277    Carrie female white    0  white female
#> 4278    Latoya female black    0 black, female
#> 4279    Laurie female white    0  white female
#> 4280     Sarah female white    0  white female
#> 4281    Tamika female black    0 black, female
#> 4282   Tanisha female black    0 black, female
#> 4283    Carrie female white    0  white female
#> 4284    Keisha female black    0 black, female
#> 4285   Latonya female black    0 black, female
#> 4286     Leroy   male black    1    black male
#> 4287      Neil   male white    1    white male
#> 4288     Sarah female white    0  white female
#> 4289     Aisha female black    0 black, female
#> 4290      Anne female white    0  white female
#> 4291    Latoya female black    0 black, female
#> 4292  Meredith female white    0  white female
#> 4293    Carrie female white    0  white female
#> 4294     Kenya female black    0 black, female
#> 4295   Kristen female white    1  white female
#> 4296   Lakisha female black    0 black, female
#> 4297  Meredith female white    1  white female
#> 4298  Tremayne   male black    0    black male
#> 4299      Jill female white    0  white female
#> 4300   Kristen female white    0  white female
#> 4301    Latoya female black    0 black, female
#> 4302    Tamika female black    0 black, female
#> 4303    Carrie female white    0  white female
#> 4304     Emily female white    0  white female
#> 4305    Latoya female black    0 black, female
#> 4306   Tanisha female black    0 black, female
#> 4307     Ebony female black    0 black, female
#> 4308     Emily female white    0  white female
#> 4309    Laurie female white    0  white female
#> 4310  Tremayne   male black    0    black male
#> 4311    Laurie female white    0  white female
#> 4312    Tamika female black    0 black, female
#> 4313    Carrie female white    0  white female
#> 4314   Lakisha female black    0 black, female
#> 4315   Latonya female black    0 black, female
#> 4316  Meredith female white    0  white female
#> 4317   Allison female white    0  white female
#> 4318    Carrie female white    0  white female
#> 4319      Jill female white    0  white female
#> 4320    Kareem   male black    0    black male
#> 4321   Latonya female black    0 black, female
#> 4322    Latoya female black    0 black, female
#> 4323      Anne female white    0  white female
#> 4324     Emily female white    0  white female
#> 4325     Kenya female black    0 black, female
#> 4326   Tanisha female black    0 black, female
#> 4327  Jermaine   male black    0    black male
#> 4328   Latonya female black    0 black, female
#> 4329    Laurie female white    0  white female
#> 4330     Sarah female white    0  white female
#> 4331  Jermaine   male black    0    black male
#> 4332     Kenya female black    0 black, female
#> 4333   Kristen female white    1  white female
#> 4334  Meredith female white    0  white female
#> 4335     Sarah female white    1  white female
#> 4336   Tanisha female black    1 black, female
#> 4337      Anne female white    0  white female
#> 4338      Brad   male white    0    white male
#> 4339     Emily female white    0  white female
#> 4340     Hakim   male black    0    black male
#> 4341  Jermaine   male black    0    black male
#> 4342  Jermaine   male black    0    black male
#> 4343      Jill female white    0  white female
#> 4344      Jill female white    0  white female
#> 4345    Keisha female black    0 black, female
#> 4346   Lakisha female black    0 black, female
#> 4347   Lakisha female black    0 black, female
#> 4348   Latonya female black    0 black, female
#> 4349    Latoya female black    0 black, female
#> 4350    Latoya female black    0 black, female
#> 4351    Latoya female black    0 black, female
#> 4352    Laurie female white    0  white female
#> 4353    Laurie female white    0  white female
#> 4354    Laurie female white    0  white female
#> 4355   Matthew   male white    0    white male
#> 4356  Meredith female white    0  white female
#> 4357   Rasheed   male black    0    black male
#> 4358     Sarah female white    0  white female
#> 4359      Todd   male white    0    white male
#> 4360  Tremayne   male black    0    black male
#> 4361      Anne female white    0  white female
#> 4362      Jill female white    0  white female
#> 4363    Latoya female black    1 black, female
#> 4364    Tamika female black    0 black, female
#> 4365      Greg   male white    0    white male
#> 4366       Jay   male white    0    white male
#> 4367   Latonya female black    0 black, female
#> 4368    Tyrone   male black    0    black male
#> 4369      Brad   male white    0    white male
#> 4370   Kristen female white    1  white female
#> 4371    Latoya female black    0 black, female
#> 4372   Tanisha female black    0 black, female
#> 4373   Kristen female white    0  white female
#> 4374   Latonya female black    0 black, female
#> 4375     Sarah female white    0  white female
#> 4376   Tanisha female black    0 black, female
#> 4377   Darnell   male black    0    black male
#> 4378    Keisha female black    0 black, female
#> 4379  Meredith female white    0  white female
#> 4380      Neil   male white    0    white male
#> 4381  Geoffrey   male white    0    white male
#> 4382    Keisha female black    0 black, female
#> 4383   Latonya female black    0 black, female
#> 4384   Matthew   male white    0    white male
#> 4385      Brad   male white    0    white male
#> 4386      Greg   male white    0    white male
#> 4387    Latoya female black    0 black, female
#> 4388  Tremayne   male black    0    black male
#> 4389  Geoffrey   male white    0    white male
#> 4390    Latoya female black    0 black, female
#> 4391      Neil   male white    0    white male
#> 4392    Tyrone   male black    0    black male
#> 4393      Anne female white    0  white female
#> 4394     Emily female white    0  white female
#> 4395     Hakim   male black    0    black male
#> 4396   Latonya female black    0 black, female
#> 4397     Ebony female black    0 black, female
#> 4398    Laurie female white    0  white female
#> 4399  Meredith female white    0  white female
#> 4400    Tamika female black    0 black, female
#> 4401      Greg   male white    1    white male
#> 4402    Latoya female black    1 black, female
#> 4403      Neil   male white    0    white male
#> 4404   Tanisha female black    1 black, female
#> 4405   Allison female white    0  white female
#> 4406     Ebony female black    0 black, female
#> 4407      Jill female white    0  white female
#> 4408     Kenya female black    0 black, female
#> 4409     Ebony female black    1 black, female
#> 4410     Emily female white    1  white female
#> 4411     Aisha female black    0 black, female
#> 4412    Carrie female white    1  white female
#> 4413     Ebony female black    0 black, female
#> 4414     Emily female white    0  white female
#> 4415     Emily female white    0  white female
#> 4416    Kareem   male black    0    black male
#> 4417   Matthew   male white    0    white male
#> 4418  Tremayne   male black    0    black male
#> 4419   Kristen female white    0  white female
#> 4420     Sarah female white    0  white female
#> 4421    Tamika female black    0 black, female
#> 4422   Tanisha female black    0 black, female
#> 4423   Allison female white    0  white female
#> 4424    Keisha female black    0 black, female
#> 4425   Kristen female white    0  white female
#> 4426    Tamika female black    0 black, female
#> 4427     Brett   male white    0    white male
#> 4428     Jamal   male black    1    black male
#> 4429      Anne female white    0  white female
#> 4430     Ebony female black    0 black, female
#> 4431     Emily female white    0  white female
#> 4432   Rasheed   male black    0    black male
#> 4433      Anne female white    0  white female
#> 4434      Jill female white    0  white female
#> 4435     Kenya female black    0 black, female
#> 4436    Latoya female black    0 black, female
#> 4437     Aisha female black    0 black, female
#> 4438      Anne female white    0  white female
#> 4439    Latoya female black    0 black, female
#> 4440  Meredith female white    0  white female
#> 4441     Kenya female black    0 black, female
#> 4442   Kristen female white    0  white female
#> 4443    Laurie female white    0  white female
#> 4444    Tamika female black    0 black, female
#> 4445      Anne female white    0  white female
#> 4446     Ebony female black    0 black, female
#> 4447    Keisha female black    0 black, female
#> 4448    Laurie female white    0  white female
#> 4449     Aisha female black    0 black, female
#> 4450      Anne female white    0  white female
#> 4451      Jill female white    0  white female
#> 4452   Kristen female white    0  white female
#> 4453   Lakisha female black    0 black, female
#> 4454   Rasheed   male black    0    black male
#> 4455     Aisha female black    0 black, female
#> 4456      Anne female white    0  white female
#> 4457     Emily female white    0  white female
#> 4458    Tamika female black    0 black, female
#> 4459      Anne female white    0  white female
#> 4460     Emily female white    0  white female
#> 4461  Jermaine   male black    0    black male
#> 4462   Latonya female black    0 black, female
#> 4463   Latonya female black    0 black, female
#> 4464    Laurie female white    0  white female
#> 4465     Aisha female black    0 black, female
#> 4466  Meredith female white    0  white female
#> 4467     Sarah female white    0  white female
#> 4468   Tanisha female black    0 black, female
#> 4469     Brett   male white    0    white male
#> 4470     Leroy   male black    0    black male
#> 4471   Brendan   male white    0    white male
#> 4472  Geoffrey   male white    0    white male
#> 4473     Jamal   male black    0    black male
#> 4474    Kareem   male black    0    black male
#> 4475   Matthew   male white    1    white male
#> 4476  Tremayne   male black    0    black male
#> 4477      Anne female white    0  white female
#> 4478     Kenya female black    0 black, female
#> 4479    Laurie female white    0  white female
#> 4480   Tanisha female black    0 black, female
#> 4481      Anne female white    0  white female
#> 4482      Jill female white    0  white female
#> 4483    Keisha female black    0 black, female
#> 4484   Kristen female white    0  white female
#> 4485   Lakisha female black    0 black, female
#> 4486   Latonya female black    0 black, female
#> 4487     Aisha female black    0 black, female
#> 4488      Anne female white    0  white female
#> 4489   Kristen female white    0  white female
#> 4490   Matthew   male white    0    white male
#> 4491    Tamika female black    0 black, female
#> 4492   Tanisha female black    0 black, female
#> 4493     Aisha female black    0 black, female
#> 4494   Allison female white    0  white female
#> 4495   Lakisha female black    0 black, female
#> 4496     Sarah female white    0  white female
#> 4497     Aisha female black    0 black, female
#> 4498     Emily female white    0  white female
#> 4499    Keisha female black    0 black, female
#> 4500     Kenya female black    0 black, female
#> 4501    Laurie female white    0  white female
#> 4502     Sarah female white    0  white female
#> 4503   Allison female white    0  white female
#> 4504     Emily female white    0  white female
#> 4505    Tamika female black    0 black, female
#> 4506   Tanisha female black    0 black, female
#> 4507    Carrie female white    0  white female
#> 4508     Kenya female black    0 black, female
#> 4509     Sarah female white    0  white female
#> 4510   Tanisha female black    0 black, female
#> 4511   Allison female white    0  white female
#> 4512   Darnell   male black    0    black male
#> 4513     Ebony female black    0 black, female
#> 4514       Jay   male white    0    white male
#> 4515      Jill female white    0  white female
#> 4516    Keisha female black    0 black, female
#> 4517    Laurie female white    0  white female
#> 4518     Sarah female white    0  white female
#> 4519    Tamika female black    0 black, female
#> 4520   Tanisha female black    0 black, female
#> 4521     Aisha female black    0 black, female
#> 4522   Allison female white    0  white female
#> 4523     Brett   male white    0    white male
#> 4524  Jermaine   male black    0    black male
#> 4525      Jill female white    0  white female
#> 4526    Keisha female black    0 black, female
#> 4527      Anne female white    0  white female
#> 4528   Latonya female black    0 black, female
#> 4529    Laurie female white    0  white female
#> 4530   Tanisha female black    0 black, female
#> 4531     Aisha female black    0 black, female
#> 4532    Carrie female white    0  white female
#> 4533   Kristen female white    0  white female
#> 4534    Tamika female black    0 black, female
#> 4535   Brendan   male white    0    white male
#> 4536    Carrie female white    0  white female
#> 4537   Lakisha female black    0 black, female
#> 4538   Latonya female black    0 black, female
#> 4539    Latoya female black    0 black, female
#> 4540  Meredith female white    0  white female
#> 4541     Brett   male white    0    white male
#> 4542   Latonya female black    0 black, female
#> 4543      Anne female white    0  white female
#> 4544     Emily female white    0  white female
#> 4545    Latoya female black    0 black, female
#> 4546    Tamika female black    0 black, female
#> 4547    Carrie female white    0  white female
#> 4548   Latonya female black    0 black, female
#> 4549    Laurie female white    0  white female
#> 4550  Tremayne   male black    0    black male
#> 4551     Aisha female black    0 black, female
#> 4552    Carrie female white    0  white female
#> 4553    Carrie female white    0  white female
#> 4554     Emily female white    0  white female
#> 4555      Jill female white    0  white female
#> 4556     Kenya female black    0 black, female
#> 4557   Latonya female black    0 black, female
#> 4558   Tanisha female black    0 black, female
#> 4559   Allison female white    1  white female
#> 4560    Carrie female white    0  white female
#> 4561     Ebony female black    0 black, female
#> 4562     Leroy   male black    1    black male
#> 4563      Anne female white    0  white female
#> 4564      Anne female white    0  white female
#> 4565      Brad   male white    0    white male
#> 4566     Brett   male white    0    white male
#> 4567     Brett   male white    0    white male
#> 4568    Carrie female white    0  white female
#> 4569   Darnell   male black    0    black male
#> 4570     Ebony female black    0 black, female
#> 4571     Emily female white    0  white female
#> 4572     Hakim   male black    0    black male
#> 4573     Jamal   male black    0    black male
#> 4574     Jamal   male black    0    black male
#> 4575       Jay   male white    0    white male
#> 4576       Jay   male white    0    white male
#> 4577  Jermaine   male black    0    black male
#> 4578   Kristen female white    0  white female
#> 4579   Kristen female white    0  white female
#> 4580   Lakisha female black    0 black, female
#> 4581    Latoya female black    0 black, female
#> 4582  Meredith female white    0  white female
#> 4583  Meredith female white    0  white female
#> 4584      Neil   male white    0    white male
#> 4585   Rasheed   male black    0    black male
#> 4586   Rasheed   male black    0    black male
#> 4587     Sarah female white    0  white female
#> 4588     Sarah female white    0  white female
#> 4589    Tamika female black    0 black, female
#> 4590    Tamika female black    0 black, female
#> 4591   Tanisha female black    0 black, female
#> 4592  Tremayne   male black    0    black male
#> 4593  Tremayne   male black    0    black male
#> 4594    Tyrone   male black    0    black male
#> 4595   Allison female white    0  white female
#> 4596      Jill female white    0  white female
#> 4597    Tamika female black    0 black, female
#> 4598  Tremayne   male black    0    black male
#> 4599     Aisha female black    0 black, female
#> 4600   Brendan   male white    0    white male
#> 4601  Jermaine   male black    0    black male
#> 4602      Jill female white    0  white female
#> 4603      Jill female white    0  white female
#> 4604     Kenya female black    1 black, female
#> 4605     Sarah female white    0  white female
#> 4606    Tamika female black    0 black, female
#> 4607   Kristen female white    0  white female
#> 4608    Latoya female black    0 black, female
#> 4609     Leroy   male black    0    black male
#> 4610  Meredith female white    0  white female
#> 4611      Jill female white    0  white female
#> 4612   Kristen female white    1  white female
#> 4613    Latoya female black    0 black, female
#> 4614    Tamika female black    0 black, female
#> 4615      Anne female white    0  white female
#> 4616   Latonya female black    0 black, female
#> 4617      Neil   male white    0    white male
#> 4618   Rasheed   male black    0    black male
#> 4619   Allison female white    0  white female
#> 4620     Emily female white    0  white female
#> 4621   Lakisha female black    0 black, female
#> 4622   Tanisha female black    0 black, female
#> 4623      Greg   male white    0    white male
#> 4624     Kenya female black    0 black, female
#> 4625   Kristen female white    0  white female
#> 4626    Tamika female black    0 black, female
#> 4627     Brett   male white    0    white male
#> 4628   Darnell   male black    0    black male
#> 4629     Ebony female black    0 black, female
#> 4630  Meredith female white    0  white female
#> 4631     Ebony female black    0 black, female
#> 4632   Kristen female white    0  white female
#> 4633    Latoya female black    0 black, female
#> 4634     Sarah female white    0  white female
#> 4635      Brad   male white    0    white male
#> 4636   Latonya female black    0 black, female
#> 4637   Rasheed   male black    0    black male
#> 4638     Sarah female white    0  white female
#> 4639     Aisha female black    0 black, female
#> 4640    Latoya female black    0 black, female
#> 4641    Laurie female white    0  white female
#> 4642  Meredith female white    0  white female
#> 4643   Brendan   male white    0    white male
#> 4644     Emily female white    0  white female
#> 4645     Kenya female black    0 black, female
#> 4646     Kenya female black    0 black, female
#> 4647   Kristen female white    0  white female
#> 4648   Latonya female black    0 black, female
#> 4649   Rasheed   male black    0    black male
#> 4650     Sarah female white    0  white female
#> 4651   Allison female white    0  white female
#> 4652    Keisha female black    0 black, female
#> 4653   Kristen female white    0  white female
#> 4654    Tamika female black    0 black, female
#> 4655   Allison female white    0  white female
#> 4656    Keisha female black    0 black, female
#> 4657   Kristen female white    0  white female
#> 4658    Tamika female black    0 black, female
#> 4659     Jamal   male black    0    black male
#> 4660    Kareem   male black    0    black male
#> 4661   Kristen female white    0  white female
#> 4662    Laurie female white    0  white female
#> 4663     Emily female white    0  white female
#> 4664   Kristen female white    0  white female
#> 4665   Kristen female white    0  white female
#> 4666   Rasheed   male black    0    black male
#> 4667    Tamika female black    0 black, female
#> 4668    Tamika female black    0 black, female
#> 4669     Aisha female black    0 black, female
#> 4670     Emily female white    0  white female
#> 4671     Kenya female black    0 black, female
#> 4672     Sarah female white    0  white female
#> 4673     Aisha female black    0 black, female
#> 4674      Anne female white    0  white female
#> 4675     Emily female white    0  white female
#> 4676    Tamika female black    0 black, female
#> 4677      Jill female white    0  white female
#> 4678   Lakisha female black    1 black, female
#> 4679    Latoya female black    1 black, female
#> 4680    Laurie female white    0  white female
#> 4681    Carrie female white    0  white female
#> 4682   Kristen female white    0  white female
#> 4683   Latonya female black    0 black, female
#> 4684    Tamika female black    0 black, female
#> 4685     Aisha female black    0 black, female
#> 4686  Geoffrey   male white    0    white male
#> 4687      Jill female white    0  white female
#> 4688   Kristen female white    0  white female
#> 4689   Tanisha female black    0 black, female
#> 4690  Tremayne   male black    0    black male
#> 4691     Aisha female black    0 black, female
#> 4692   Allison female white    0  white female
#> 4693    Latoya female black    0 black, female
#> 4694     Sarah female white    0  white female
#> 4695    Carrie female white    0  white female
#> 4696     Ebony female black    0 black, female
#> 4697     Emily female white    0  white female
#> 4698    Tamika female black    0 black, female
#> 4699     Aisha female black    0 black, female
#> 4700    Carrie female white    1  white female
#> 4701   Lakisha female black    0 black, female
#> 4702     Sarah female white    1  white female
#> 4703     Jamal   male black    0    black male
#> 4704      Neil   male white    1    white male
#> 4705      Todd   male white    0    white male
#> 4706    Tyrone   male black    1    black male
#> 4707       Jay   male white    0    white male
#> 4708      Neil   male white    0    white male
#> 4709  Tremayne   male black    0    black male
#> 4710    Tyrone   male black    0    black male
#> 4711     Hakim   male black    0    black male
#> 4712       Jay   male white    0    white male
#> 4713     Kenya female black    0 black, female
#> 4714    Laurie female white    0  white female
#> 4715   Allison female white    0  white female
#> 4716   Kristen female white    0  white female
#> 4717   Latonya female black    0 black, female
#> 4718    Tamika female black    0 black, female
#> 4719     Aisha female black    0 black, female
#> 4720   Allison female white    0  white female
#> 4721    Carrie female white    0  white female
#> 4722      Jill female white    0  white female
#> 4723   Lakisha female black    0 black, female
#> 4724    Tamika female black    0 black, female
#> 4725     Aisha female black    0 black, female
#> 4726   Allison female white    1  white female
#> 4727     Emily female white    0  white female
#> 4728     Emily female white    0  white female
#> 4729     Kenya female black    1 black, female
#> 4730     Leroy   male black    0    black male
#> 4731     Aisha female black    0 black, female
#> 4732      Anne female white    0  white female
#> 4733    Carrie female white    0  white female
#> 4734   Lakisha female black    0 black, female
#> 4735      Jill female white    0  white female
#> 4736     Kenya female black    1 black, female
#> 4737   Kristen female white    1  white female
#> 4738   Latonya female black    1 black, female
#> 4739   Latonya female black    0 black, female
#> 4740     Sarah female white    1  white female
#> 4741     Ebony female black    0 black, female
#> 4742      Jill female white    0  white female
#> 4743   Kristen female white    0  white female
#> 4744    Latoya female black    0 black, female
#> 4745      Anne female white    0  white female
#> 4746     Emily female white    0  white female
#> 4747   Lakisha female black    0 black, female
#> 4748     Sarah female white    0  white female
#> 4749    Tamika female black    0 black, female
#> 4750    Tamika female black    0 black, female
#> 4751    Carrie female white    0  white female
#> 4752     Kenya female black    0 black, female
#> 4753  Meredith female white    0  white female
#> 4754   Tanisha female black    0 black, female
#> 4755   Allison female white    0  white female
#> 4756   Allison female white    0  white female
#> 4757     Emily female white    0  white female
#> 4758     Kenya female black    1 black, female
#> 4759   Lakisha female black    0 black, female
#> 4760   Latonya female black    0 black, female
#> 4761     Aisha female black    0 black, female
#> 4762    Carrie female white    0  white female
#> 4763   Kristen female white    0  white female
#> 4764    Tamika female black    0 black, female
#> 4765      Jill female white    0  white female
#> 4766    Tamika female black    0 black, female
#> 4767      Anne female white    0  white female
#> 4768       Jay   male white    0    white male
#> 4769   Latonya female black    0 black, female
#> 4770    Latoya female black    0 black, female
#> 4771  Meredith female white    0  white female
#> 4772   Tanisha female black    0 black, female
#> 4773    Laurie female white    0  white female
#> 4774    Tyrone   male black    0    black male
#> 4775     Aisha female black    0 black, female
#> 4776   Allison female white    0  white female
#> 4777     Sarah female white    0  white female
#> 4778    Tamika female black    0 black, female
#> 4779      Brad   male white    0    white male
#> 4780    Carrie female white    0  white female
#> 4781   Latonya female black    0 black, female
#> 4782   Latonya female black    0 black, female
#> 4783   Brendan   male white    1    white male
#> 4784     Ebony female black    1 black, female
#> 4785     Emily female white    0  white female
#> 4786      Jill female white    0  white female
#> 4787     Kenya female black    0 black, female
#> 4788    Latoya female black    0 black, female
#> 4789    Laurie female white    1  white female
#> 4790    Tamika female black    0 black, female
#> 4791  Geoffrey   male white    0    white male
#> 4792      Greg   male white    0    white male
#> 4793    Kareem   male black    0    black male
#> 4794  Tremayne   male black    0    black male
#> 4795      Brad   male white    0    white male
#> 4796   Darnell   male black    0    black male
#> 4797     Ebony female black    0 black, female
#> 4798     Emily female white    0  white female
#> 4799  Geoffrey   male white    0    white male
#> 4800      Greg   male white    0    white male
#> 4801     Hakim   male black    0    black male
#> 4802     Jamal   male black    0    black male
#> 4803       Jay   male white    0    white male
#> 4804      Jill female white    0  white female
#> 4805    Kareem   male black    0    black male
#> 4806    Kareem   male black    0    black male
#> 4807     Kenya female black    0 black, female
#> 4808     Kenya female black    0 black, female
#> 4809   Lakisha female black    0 black, female
#> 4810    Laurie female white    0  white female
#> 4811    Laurie female white    0  white female
#> 4812    Laurie female white    0  white female
#> 4813     Leroy   male black    0    black male
#> 4814  Meredith female white    0  white female
#> 4815  Meredith female white    0  white female
#> 4816   Rasheed   male black    0    black male
#> 4817     Sarah female white    0  white female
#> 4818     Sarah female white    0  white female
#> 4819   Tanisha female black    0 black, female
#> 4820      Todd   male white    0    white male
#> 4821  Tremayne   male black    0    black male
#> 4822    Tyrone   male black    0    black male
#> 4823   Allison female white    0  white female
#> 4824   Latonya female black    0 black, female
#> 4825  Meredith female white    0  white female
#> 4826    Tamika female black    0 black, female
#> 4827      Brad   male white    1    white male
#> 4828    Kareem   male black    0    black male
#> 4829    Keisha female black    0 black, female
#> 4830   Matthew   male white    1    white male
#> 4831      Anne female white    0  white female
#> 4832     Emily female white    0  white female
#> 4833   Lakisha female black    0 black, female
#> 4834    Tamika female black    0 black, female
#> 4835      Brad   male white    0    white male
#> 4836   Darnell   male black    0    black male
#> 4837      Todd   male white    0    white male
#> 4838  Tremayne   male black    0    black male
#> 4839   Brendan   male white    0    white male
#> 4840     Brett   male white    0    white male
#> 4841     Jamal   male black    0    black male
#> 4842    Kareem   male black    0    black male
#> 4843     Kenya female black    0 black, female
#> 4844   Kristen female white    1  white female
#> 4845    Latoya female black    0 black, female
#> 4846    Laurie female white    0  white female
#> 4847    Carrie female white    1  white female
#> 4848   Kristen female white    1  white female
#> 4849   Latonya female black    1 black, female
#> 4850    Tyrone   male black    0    black male
#> 4851     Ebony female black    0 black, female
#> 4852      Jill female white    0  white female
#> 4853  Meredith female white    0  white female
#> 4854   Tanisha female black    0 black, female
#> 4855  Geoffrey   male white    0    white male
#> 4856      Greg   male white    0    white male
#> 4857     Jamal   male black    0    black male
#> 4858    Tamika female black    0 black, female
#> 4859     Jamal   male black    0    black male
#> 4860   Latonya female black    1 black, female
#> 4861   Matthew   male white    0    white male
#> 4862     Sarah female white    1  white female
#> 4863   Allison female white    0  white female
#> 4864      Jill female white    0  white female
#> 4865   Lakisha female black    0 black, female
#> 4866    Tamika female black    0 black, female
#> 4867     Ebony female black    0 black, female
#> 4868       Jay   male white    0    white male
#> 4869   Latonya female black    0 black, female
#> 4870    Laurie female white    0  white female
```
Each condition is a formula (an R object created with the "tilde" `~`).
You will see formulas used extensively in the modeling section.
The condition is on the left-hand side of the formula. The value to assign
to observations meeting that condition is on the right-hand side.
Observations are given the value of the first matching condition, so the order
of these can matter.


The `case_when` function also supports a default value by using a condition `TRUE`
as the last condition. This will match anything not already matched. E.g.
if you wanted three categories ("black male", "black female", "white"),

```r
resume %>%
  mutate(
    race_sex = case_when(
      race == "black" & sex == "female" ~ "black, female",
      race == "black" & sex == "male" ~ "black male",
      TRUE ~ "white"
    )
  )
#>      firstname    sex  race call      race_sex
#> 1      Allison female white    0         white
#> 2      Kristen female white    0         white
#> 3      Lakisha female black    0 black, female
#> 4      Latonya female black    0 black, female
#> 5       Carrie female white    0         white
#> 6          Jay   male white    0         white
#> 7         Jill female white    0         white
#> 8        Kenya female black    0 black, female
#> 9      Latonya female black    0 black, female
#> 10      Tyrone   male black    0    black male
#> 11       Aisha female black    0 black, female
#> 12     Allison female white    0         white
#> 13       Aisha female black    0 black, female
#> 14      Carrie female white    0         white
#> 15       Aisha female black    0 black, female
#> 16    Geoffrey   male white    0         white
#> 17     Matthew   male white    0         white
#> 18      Tamika female black    0 black, female
#> 19        Jill female white    0         white
#> 20     Latonya female black    0 black, female
#> 21       Leroy   male black    0    black male
#> 22        Todd   male white    0         white
#> 23     Allison female white    0         white
#> 24      Carrie female white    0         white
#> 25        Greg   male white    0         white
#> 26      Keisha female black    0 black, female
#> 27      Keisha female black    0 black, female
#> 28     Kristen female white    0         white
#> 29     Lakisha female black    0 black, female
#> 30      Tamika female black    0 black, female
#> 31     Allison female white    0         white
#> 32      Keisha female black    0 black, female
#> 33     Kristen female white    0         white
#> 34     Latonya female black    0 black, female
#> 35        Brad   male white    0         white
#> 36        Jill female white    0         white
#> 37      Keisha female black    0 black, female
#> 38      Keisha female black    0 black, female
#> 39     Lakisha female black    0 black, female
#> 40      Laurie female white    0         white
#> 41    Meredith female white    0         white
#> 42      Tyrone   male black    0    black male
#> 43        Anne female white    0         white
#> 44       Emily female white    0         white
#> 45      Latoya female black    0 black, female
#> 46      Tamika female black    0 black, female
#> 47        Brad   male white    0         white
#> 48      Latoya female black    0 black, female
#> 49     Kristen female white    0         white
#> 50     Latonya female black    0 black, female
#> 51      Latoya female black    0 black, female
#> 52      Laurie female white    0         white
#> 53     Allison female white    0         white
#> 54       Ebony female black    0 black, female
#> 55         Jay   male white    0         white
#> 56      Keisha female black    0 black, female
#> 57      Laurie female white    0         white
#> 58      Tyrone   male black    0    black male
#> 59        Anne female white    0         white
#> 60     Lakisha female black    0 black, female
#> 61     Latonya female black    0 black, female
#> 62    Meredith female white    0         white
#> 63     Allison female white    0         white
#> 64      Carrie female white    0         white
#> 65       Ebony female black    0 black, female
#> 66       Kenya female black    0 black, female
#> 67     Lakisha female black    0 black, female
#> 68      Laurie female white    0         white
#> 69       Aisha female black    0 black, female
#> 70        Anne female white    0         white
#> 71     Brendan   male white    0         white
#> 72       Hakim   male black    0    black male
#> 73      Latoya female black    0 black, female
#> 74      Laurie female white    0         white
#> 75      Laurie female white    0         white
#> 76       Leroy   male black    0    black male
#> 77        Anne female white    0         white
#> 78       Kenya female black    0 black, female
#> 79     Latonya female black    0 black, female
#> 80    Meredith female white    0         white
#> 81       Jamal   male black    0    black male
#> 82     Matthew   male white    0         white
#> 83        Neil   male white    0         white
#> 84      Tyrone   male black    0    black male
#> 85       Leroy   male black    0    black male
#> 86        Todd   male white    1         white
#> 87        Brad   male white    0         white
#> 88       Ebony female black    0 black, female
#> 89        Jill female white    0         white
#> 90     Kristen female white    0         white
#> 91     Lakisha female black    0 black, female
#> 92     Matthew   male white    0         white
#> 93      Tamika female black    0 black, female
#> 94    Tremayne   male black    0    black male
#> 95       Aisha female black    0 black, female
#> 96       Brett   male white    1         white
#> 97     Darnell   male black    0    black male
#> 98       Emily female white    0         white
#> 99     Latonya female black    0 black, female
#> 100      Sarah female white    0         white
#> 101      Aisha female black    0 black, female
#> 102       Anne female white    0         white
#> 103   Jermaine   male black    0    black male
#> 104       Neil   male white    0         white
#> 105    Allison female white    0         white
#> 106       Anne female white    1         white
#> 107     Keisha female black    0 black, female
#> 108    Latonya female black    1 black, female
#> 109    Latonya female black    0 black, female
#> 110     Laurie female white    0         white
#> 111        Jay   male white    0         white
#> 112    Lakisha female black    0 black, female
#> 113       Anne female white    0         white
#> 114     Keisha female black    0 black, female
#> 115    Kristen female white    0         white
#> 116    Lakisha female black    0 black, female
#> 117    Allison female white    0         white
#> 118      Ebony female black    0 black, female
#> 119     Keisha female black    0 black, female
#> 120    Kristen female white    0         white
#> 121    Lakisha female black    0 black, female
#> 122   Meredith female white    0         white
#> 123    Allison female white    0         white
#> 124    Kristen female white    0         white
#> 125    Lakisha female black    0 black, female
#> 126    Lakisha female black    0 black, female
#> 127    Tanisha female black    1 black, female
#> 128       Todd   male white    1         white
#> 129      Aisha female black    0 black, female
#> 130       Anne female white    0         white
#> 131       Jill female white    0         white
#> 132     Latoya female black    0 black, female
#> 133       Neil   male white    0         white
#> 134     Tamika female black    0 black, female
#> 135       Anne female white    0         white
#> 136   Geoffrey   male white    0         white
#> 137     Latoya female black    0 black, female
#> 138    Rasheed   male black    0    black male
#> 139      Aisha female black    0 black, female
#> 140    Allison female white    0         white
#> 141     Carrie female white    0         white
#> 142      Ebony female black    0 black, female
#> 143      Kenya female black    0 black, female
#> 144    Kristen female white    0         white
#> 145   Jermaine   male black    0    black male
#> 146     Laurie female white    0         white
#> 147    Allison female white    0         white
#> 148    Kristen female white    0         white
#> 149    Lakisha female black    0 black, female
#> 150    Latonya female black    0 black, female
#> 151       Brad   male white    0         white
#> 152      Leroy   male black    0    black male
#> 153      Emily female white    0         white
#> 154    Latonya female black    0 black, female
#> 155     Latoya female black    0 black, female
#> 156     Laurie female white    0         white
#> 157      Aisha female black    0 black, female
#> 158    Allison female white    0         white
#> 159      Ebony female black    0 black, female
#> 160   Jermaine   male black    0    black male
#> 161    Kristen female white    0         white
#> 162    Latonya female black    0 black, female
#> 163     Laurie female white    0         white
#> 164     Laurie female white    0         white
#> 165       Anne female white    0         white
#> 166    Brendan   male white    1         white
#> 167     Kareem   male black    0    black male
#> 168     Keisha female black    0 black, female
#> 169    Matthew   male white    1         white
#> 170   Meredith female white    0         white
#> 171    Tanisha female black    0 black, female
#> 172    Tanisha female black    1 black, female
#> 173      Aisha female black    0 black, female
#> 174    Allison female white    0         white
#> 175    Allison female white    0         white
#> 176       Anne female white    0         white
#> 177    Brendan   male white    0         white
#> 178      Brett   male white    0         white
#> 179      Brett   male white    0         white
#> 180      Brett   male white    0         white
#> 181      Ebony female black    0 black, female
#> 182   Geoffrey   male white    0         white
#> 183        Jay   male white    0         white
#> 184       Jill female white    0         white
#> 185     Keisha female black    0 black, female
#> 186     Keisha female black    0 black, female
#> 187      Kenya female black    0 black, female
#> 188      Kenya female black    0 black, female
#> 189    Lakisha female black    0 black, female
#> 190     Latoya female black    0 black, female
#> 191     Latoya female black    0 black, female
#> 192     Laurie female white    0         white
#> 193    Matthew   male white    0         white
#> 194    Rasheed   male black    0    black male
#> 195      Sarah female white    0         white
#> 196      Sarah female white    0         white
#> 197     Tamika female black    0 black, female
#> 198    Tanisha female black    0 black, female
#> 199    Tanisha female black    0 black, female
#> 200   Tremayne   male black    0    black male
#> 201    Lakisha female black    1 black, female
#> 202   Meredith female white    1         white
#> 203       Anne female white    0         white
#> 204    Latonya female black    0 black, female
#> 205      Sarah female white    0         white
#> 206     Tamika female black    0 black, female
#> 207       Jill female white    0         white
#> 208     Keisha female black    0 black, female
#> 209    Lakisha female black    0 black, female
#> 210   Meredith female white    0         white
#> 211       Jill female white    1         white
#> 212     Keisha female black    0 black, female
#> 213    Lakisha female black    0 black, female
#> 214   Meredith female white    0         white
#> 215     Carrie female white    0         white
#> 216       Greg   male white    0         white
#> 217      Kenya female black    0 black, female
#> 218   Tremayne   male black    0    black male
#> 219      Kenya female black    0 black, female
#> 220       Neil   male white    0         white
#> 221      Emily female white    0         white
#> 222       Jill female white    0         white
#> 223    Latonya female black    0 black, female
#> 224    Tanisha female black    0 black, female
#> 225      Ebony female black    0 black, female
#> 226    Kristen female white    0         white
#> 227    Latonya female black    0 black, female
#> 228     Laurie female white    0         white
#> 229       Anne female white    0         white
#> 230      Emily female white    0         white
#> 231     Keisha female black    0 black, female
#> 232    Tanisha female black    0 black, female
#> 233    Allison female white    0         white
#> 234    Kristen female white    0         white
#> 235    Latonya female black    0 black, female
#> 236    Tanisha female black    0 black, female
#> 237      Aisha female black    0 black, female
#> 238    Allison female white    0         white
#> 239       Anne female white    0         white
#> 240    Latonya female black    0 black, female
#> 241     Latoya female black    0 black, female
#> 242      Sarah female white    0         white
#> 243      Aisha female black    0 black, female
#> 244       Anne female white    0         white
#> 245     Latoya female black    0 black, female
#> 246     Laurie female white    0         white
#> 247       Anne female white    0         white
#> 248     Carrie female white    1         white
#> 249      Ebony female black    0 black, female
#> 250    Lakisha female black    0 black, female
#> 251    Allison female white    0         white
#> 252     Keisha female black    0 black, female
#> 253    Kristen female white    0         white
#> 254    Tanisha female black    0 black, female
#> 255      Aisha female black    0 black, female
#> 256      Emily female white    0         white
#> 257    Latonya female black    0 black, female
#> 258      Sarah female white    0         white
#> 259   Geoffrey   male white    0         white
#> 260     Kareem   male black    1    black male
#> 261    Kristen female white    0         white
#> 262    Rasheed   male black    0    black male
#> 263       Todd   male white    0         white
#> 264     Tyrone   male black    0    black male
#> 265    Brendan   male white    0         white
#> 266      Jamal   male black    0    black male
#> 267    Matthew   male white    0         white
#> 268   Meredith female white    1         white
#> 269    Rasheed   male black    0    black male
#> 270   Tremayne   male black    1    black male
#> 271       Anne female white    1         white
#> 272      Ebony female black    1 black, female
#> 273    Kristen female white    1         white
#> 274     Tamika female black    0 black, female
#> 275      Aisha female black    0 black, female
#> 276    Allison female white    0         white
#> 277      Emily female white    0         white
#> 278    Kristen female white    0         white
#> 279     Latoya female black    0 black, female
#> 280     Tamika female black    0 black, female
#> 281      Aisha female black    0 black, female
#> 282       Anne female white    0         white
#> 283      Emily female white    0         white
#> 284       Jill female white    0         white
#> 285     Keisha female black    0 black, female
#> 286    Lakisha female black    0 black, female
#> 287      Ebony female black    0 black, female
#> 288      Kenya female black    0 black, female
#> 289    Kristen female white    0         white
#> 290   Meredith female white    0         white
#> 291      Aisha female black    0 black, female
#> 292       Anne female white    0         white
#> 293      Emily female white    0         white
#> 294      Emily female white    0         white
#> 295      Kenya female black    0 black, female
#> 296    Latonya female black    0 black, female
#> 297       Anne female white    0         white
#> 298      Emily female white    0         white
#> 299     Keisha female black    0 black, female
#> 300     Tamika female black    0 black, female
#> 301       Anne female white    0         white
#> 302      Emily female white    0         white
#> 303     Keisha female black    0 black, female
#> 304      Kenya female black    0 black, female
#> 305     Latoya female black    0 black, female
#> 306       Neil   male white    0         white
#> 307      Aisha female black    0 black, female
#> 308       Anne female white    0         white
#> 309      Emily female white    0         white
#> 310     Tamika female black    0 black, female
#> 311     Carrie female white    0         white
#> 312       Jill female white    0         white
#> 313     Keisha female black    0 black, female
#> 314    Latonya female black    0 black, female
#> 315      Sarah female white    0         white
#> 316     Tyrone   male black    0    black male
#> 317     Carrie female white    0         white
#> 318      Emily female white    0         white
#> 319     Latoya female black    0 black, female
#> 320    Tanisha female black    0 black, female
#> 321      Aisha female black    0 black, female
#> 322    Kristen female white    0         white
#> 323    Lakisha female black    0 black, female
#> 324     Laurie female white    0         white
#> 325    Allison female white    0         white
#> 326       Jill female white    0         white
#> 327     Keisha female black    0 black, female
#> 328    Kristen female white    0         white
#> 329    Lakisha female black    0 black, female
#> 330      Leroy   male black    0    black male
#> 331       Brad   male white    0         white
#> 332     Keisha female black    0 black, female
#> 333    Allison female white    0         white
#> 334     Carrie female white    0         white
#> 335    Latonya female black    0 black, female
#> 336     Latoya female black    0 black, female
#> 337     Carrie female white    0         white
#> 338      Ebony female black    0 black, female
#> 339    Latonya female black    0 black, female
#> 340     Laurie female white    0         white
#> 341   Meredith female white    0         white
#> 342   Tremayne   male black    0    black male
#> 343    Allison female white    0         white
#> 344     Carrie female white    0         white
#> 345    Lakisha female black    0 black, female
#> 346     Tamika female black    0 black, female
#> 347       Anne female white    0         white
#> 348    Darnell   male black    0    black male
#> 349       Greg   male white    1         white
#> 350     Tamika female black    0 black, female
#> 351    Allison female white    0         white
#> 352     Carrie female white    0         white
#> 353      Kenya female black    0 black, female
#> 354   Tremayne   male black    0    black male
#> 355      Aisha female black    0 black, female
#> 356      Aisha female black    0 black, female
#> 357       Brad   male white    0         white
#> 358       Brad   male white    0         white
#> 359    Brendan   male white    0         white
#> 360      Ebony female black    0 black, female
#> 361   Geoffrey   male white    0         white
#> 362       Greg   male white    0         white
#> 363       Greg   male white    0         white
#> 364       Greg   male white    0         white
#> 365      Hakim   male black    0    black male
#> 366        Jay   male white    0         white
#> 367   Jermaine   male black    0    black male
#> 368     Kareem   male black    0    black male
#> 369     Kareem   male black    0    black male
#> 370    Latonya female black    0 black, female
#> 371      Leroy   male black    0    black male
#> 372   Meredith female white    0         white
#> 373      Sarah female white    0         white
#> 374      Sarah female white    0         white
#> 375     Tamika female black    0 black, female
#> 376    Tanisha female black    0 black, female
#> 377       Todd   male white    0         white
#> 378   Tremayne   male black    0    black male
#> 379      Emily female white    0         white
#> 380      Kenya female black    0 black, female
#> 381     Latoya female black    0 black, female
#> 382      Sarah female white    0         white
#> 383     Carrie female white    1         white
#> 384   Jermaine   male black    1    black male
#> 385    Matthew   male white    0         white
#> 386     Tyrone   male black    0    black male
#> 387    Allison female white    0         white
#> 388      Ebony female black    0 black, female
#> 389        Jay   male white    1         white
#> 390     Tamika female black    0 black, female
#> 391       Anne female white    0         white
#> 392    Latonya female black    0 black, female
#> 393     Laurie female white    0         white
#> 394    Tanisha female black    0 black, female
#> 395      Ebony female black    0 black, female
#> 396       Jill female white    0         white
#> 397    Kristen female white    0         white
#> 398    Lakisha female black    0 black, female
#> 399     Carrie female white    0         white
#> 400       Jill female white    0         white
#> 401     Keisha female black    0 black, female
#> 402    Rasheed   male black    0    black male
#> 403    Allison female white    0         white
#> 404      Kenya female black    0 black, female
#> 405   Meredith female white    0         white
#> 406     Tamika female black    0 black, female
#> 407    Matthew   male white    0         white
#> 408   Tremayne   male black    0    black male
#> 409      Ebony female black    0 black, female
#> 410      Emily female white    0         white
#> 411       Jill female white    0         white
#> 412     Tamika female black    0 black, female
#> 413    Darnell   male black    0    black male
#> 414      Emily female white    1         white
#> 415       Neil   male white    0         white
#> 416     Tamika female black    0 black, female
#> 417    Latonya female black    0 black, female
#> 418     Laurie female white    0         white
#> 419      Sarah female white    0         white
#> 420    Tanisha female black    0 black, female
#> 421     Carrie female white    0         white
#> 422     Kareem   male black    0    black male
#> 423       Todd   male white    0         white
#> 424     Tyrone   male black    0    black male
#> 425       Anne female white    0         white
#> 426       Jill female white    0         white
#> 427      Kenya female black    1 black, female
#> 428     Latoya female black    1 black, female
#> 429       Anne female white    0         white
#> 430      Ebony female black    0 black, female
#> 431      Emily female white    0         white
#> 432     Keisha female black    0 black, female
#> 433    Allison female white    0         white
#> 434    Kristen female white    0         white
#> 435    Lakisha female black    0 black, female
#> 436    Tanisha female black    0 black, female
#> 437    Brendan   male white    0         white
#> 438     Laurie female white    0         white
#> 439    Rasheed   male black    0    black male
#> 440     Tyrone   male black    0    black male
#> 441       Jill female white    0         white
#> 442    Lakisha female black    0 black, female
#> 443    Matthew   male white    1         white
#> 444     Tamika female black    0 black, female
#> 445      Aisha female black    0 black, female
#> 446      Emily female white    0         white
#> 447     Keisha female black    0 black, female
#> 448      Sarah female white    1         white
#> 449       Anne female white    0         white
#> 450      Emily female white    0         white
#> 451     Latoya female black    0 black, female
#> 452     Tamika female black    0 black, female
#> 453      Kenya female black    0 black, female
#> 454    Kristen female white    0         white
#> 455    Latonya female black    0 black, female
#> 456     Laurie female white    0         white
#> 457     Carrie female white    0         white
#> 458       Jill female white    0         white
#> 459     Keisha female black    0 black, female
#> 460     Latoya female black    0 black, female
#> 461      Emily female white    0         white
#> 462    Kristen female white    0         white
#> 463     Latoya female black    0 black, female
#> 464     Tamika female black    0 black, female
#> 465     Keisha female black    0 black, female
#> 466    Kristen female white    0         white
#> 467    Lakisha female black    0 black, female
#> 468   Meredith female white    0         white
#> 469    Allison female white    0         white
#> 470    Lakisha female black    0 black, female
#> 471   Meredith female white    0         white
#> 472    Tanisha female black    0 black, female
#> 473      Emily female white    1         white
#> 474     Keisha female black    0 black, female
#> 475    Latonya female black    1 black, female
#> 476      Sarah female white    1         white
#> 477      Aisha female black    1 black, female
#> 478       Jill female white    1         white
#> 479    Latonya female black    1 black, female
#> 480      Sarah female white    1         white
#> 481       Anne female white    0         white
#> 482      Kenya female black    0 black, female
#> 483     Latoya female black    0 black, female
#> 484      Sarah female white    0         white
#> 485    Allison female white    0         white
#> 486     Keisha female black    0 black, female
#> 487   Meredith female white    0         white
#> 488    Tanisha female black    0 black, female
#> 489       Anne female white    0         white
#> 490     Carrie female white    0         white
#> 491    Latonya female black    0 black, female
#> 492    Tanisha female black    0 black, female
#> 493    Allison female white    0         white
#> 494       Anne female white    0         white
#> 495      Ebony female black    0 black, female
#> 496       Jill female white    0         white
#> 497     Keisha female black    0 black, female
#> 498    Lakisha female black    0 black, female
#> 499    Latonya female black    0 black, female
#> 500       Todd   male white    0         white
#> 501     Carrie female white    0         white
#> 502   Meredith female white    0         white
#> 503     Tamika female black    0 black, female
#> 504    Tanisha female black    0 black, female
#> 505      Aisha female black    0 black, female
#> 506       Anne female white    0         white
#> 507      Emily female white    0         white
#> 508    Latonya female black    0 black, female
#> 509      Aisha female black    0 black, female
#> 510    Allison female white    0         white
#> 511       Jill female white    0         white
#> 512     Tamika female black    0 black, female
#> 513       Anne female white    0         white
#> 514      Ebony female black    0 black, female
#> 515       Jill female white    0         white
#> 516     Tamika female black    0 black, female
#> 517     Carrie female white    0         white
#> 518      Kenya female black    0 black, female
#> 519      Sarah female white    0         white
#> 520    Tanisha female black    0 black, female
#> 521       Anne female white    0         white
#> 522     Keisha female black    0 black, female
#> 523    Allison female white    0         white
#> 524     Latoya female black    0 black, female
#> 525      Sarah female white    0         white
#> 526     Tamika female black    0 black, female
#> 527       Anne female white    0         white
#> 528       Jill female white    0         white
#> 529      Kenya female black    0 black, female
#> 530    Lakisha female black    0 black, female
#> 531       Jill female white    0         white
#> 532     Keisha female black    0 black, female
#> 533    Lakisha female black    0 black, female
#> 534   Meredith female white    0         white
#> 535      Aisha female black    0 black, female
#> 536    Allison female white    0         white
#> 537    Allison female white    0         white
#> 538      Hakim   male black    0    black male
#> 539      Sarah female white    0         white
#> 540     Tamika female black    0 black, female
#> 541      Aisha female black    0 black, female
#> 542     Latoya female black    0 black, female
#> 543     Laurie female white    0         white
#> 544   Meredith female white    0         white
#> 545      Aisha female black    0 black, female
#> 546    Allison female white    0         white
#> 547    Allison female white    0         white
#> 548    Allison female white    0         white
#> 549       Anne female white    0         white
#> 550       Brad   male white    0         white
#> 551    Brendan   male white    0         white
#> 552    Darnell   male black    0    black male
#> 553      Emily female white    0         white
#> 554   Geoffrey   male white    0         white
#> 555       Greg   male white    0         white
#> 556      Hakim   male black    0    black male
#> 557      Hakim   male black    0    black male
#> 558        Jay   male white    0         white
#> 559   Jermaine   male black    0    black male
#> 560     Kareem   male black    0    black male
#> 561      Kenya female black    0 black, female
#> 562      Kenya female black    0 black, female
#> 563    Lakisha female black    0 black, female
#> 564    Latonya female black    0 black, female
#> 565   Meredith female white    0         white
#> 566       Neil   male white    0         white
#> 567       Neil   male white    0         white
#> 568    Rasheed   male black    0    black male
#> 569     Tamika female black    0 black, female
#> 570    Tanisha female black    0 black, female
#> 571       Todd   male white    0         white
#> 572   Tremayne   male black    0    black male
#> 573       Brad   male white    0         white
#> 574      Ebony female black    0 black, female
#> 575      Jamal   male black    0    black male
#> 576        Jay   male white    0         white
#> 577      Ebony female black    1 black, female
#> 578      Emily female white    1         white
#> 579    Latonya female black    0 black, female
#> 580   Meredith female white    0         white
#> 581    Lakisha female black    0 black, female
#> 582    Latonya female black    0 black, female
#> 583     Laurie female white    1         white
#> 584   Meredith female white    0         white
#> 585    Darnell   male black    0    black male
#> 586   Geoffrey   male white    0         white
#> 587    Kristen female white    0         white
#> 588     Tyrone   male black    0    black male
#> 589       Jill female white    0         white
#> 590    Latonya female black    0 black, female
#> 591      Sarah female white    0         white
#> 592    Tanisha female black    0 black, female
#> 593    Allison female white    1         white
#> 594      Ebony female black    0 black, female
#> 595    Lakisha female black    0 black, female
#> 596     Laurie female white    1         white
#> 597    Allison female white    0         white
#> 598      Emily female white    0         white
#> 599     Tamika female black    0 black, female
#> 600    Tanisha female black    0 black, female
#> 601    Allison female white    1         white
#> 602      Brett   male white    0         white
#> 603   Jermaine   male black    0    black male
#> 604    Tanisha female black    0 black, female
#> 605      Aisha female black    0 black, female
#> 606    Allison female white    0         white
#> 607       Jill female white    0         white
#> 608    Latonya female black    0 black, female
#> 609     Carrie female white    0         white
#> 610      Ebony female black    0 black, female
#> 611     Latoya female black    0 black, female
#> 612     Laurie female white    0         white
#> 613     Carrie female white    0         white
#> 614     Keisha female black    0 black, female
#> 615    Latonya female black    0 black, female
#> 616      Sarah female white    0         white
#> 617    Allison female white    0         white
#> 618      Ebony female black    0 black, female
#> 619      Kenya female black    0 black, female
#> 620      Sarah female white    0         white
#> 621      Aisha female black    0 black, female
#> 622       Jill female white    0         white
#> 623    Kristen female white    0         white
#> 624    Latonya female black    0 black, female
#> 625       Anne female white    0         white
#> 626      Ebony female black    0 black, female
#> 627    Kristen female white    0         white
#> 628     Latoya female black    0 black, female
#> 629      Ebony female black    0 black, female
#> 630       Jill female white    0         white
#> 631      Sarah female white    0         white
#> 632     Tamika female black    0 black, female
#> 633      Emily female white    0         white
#> 634     Keisha female black    0 black, female
#> 635      Kenya female black    0 black, female
#> 636      Sarah female white    0         white
#> 637      Aisha female black    0 black, female
#> 638      Ebony female black    0 black, female
#> 639       Jill female white    0         white
#> 640   Meredith female white    0         white
#> 641       Anne female white    0         white
#> 642      Emily female white    0         white
#> 643     Latoya female black    0 black, female
#> 644     Tamika female black    0 black, female
#> 645    Allison female white    0         white
#> 646      Emily female white    0         white
#> 647      Kenya female black    0 black, female
#> 648     Tamika female black    0 black, female
#> 649    Allison female white    0         white
#> 650     Carrie female white    0         white
#> 651     Keisha female black    0 black, female
#> 652    Lakisha female black    0 black, female
#> 653     Laurie female white    0         white
#> 654    Tanisha female black    0 black, female
#> 655       Anne female white    0         white
#> 656     Carrie female white    0         white
#> 657     Keisha female black    0 black, female
#> 658     Tamika female black    0 black, female
#> 659    Allison female white    0         white
#> 660    Latonya female black    0 black, female
#> 661     Laurie female white    0         white
#> 662     Tamika female black    0 black, female
#> 663    Allison female white    0         white
#> 664     Keisha female black    0 black, female
#> 665   Meredith female white    0         white
#> 666    Tanisha female black    0 black, female
#> 667       Jill female white    0         white
#> 668    Lakisha female black    0 black, female
#> 669      Sarah female white    0         white
#> 670     Tamika female black    0 black, female
#> 671       Anne female white    0         white
#> 672      Ebony female black    0 black, female
#> 673      Sarah female white    0         white
#> 674    Tanisha female black    0 black, female
#> 675     Carrie female white    0         white
#> 676     Keisha female black    0 black, female
#> 677    Latonya female black    0 black, female
#> 678      Sarah female white    0         white
#> 679     Carrie female white    0         white
#> 680     Latoya female black    0 black, female
#> 681   Meredith female white    0         white
#> 682    Tanisha female black    0 black, female
#> 683    Allison female white    0         white
#> 684      Ebony female black    0 black, female
#> 685    Lakisha female black    0 black, female
#> 686     Laurie female white    0         white
#> 687      Kenya female black    0 black, female
#> 688     Laurie female white    0         white
#> 689        Jay   male white    0         white
#> 690     Keisha female black    0 black, female
#> 691      Emily female white    0         white
#> 692      Kenya female black    0 black, female
#> 693      Sarah female white    0         white
#> 694    Tanisha female black    0 black, female
#> 695      Aisha female black    0 black, female
#> 696    Allison female white    0         white
#> 697    Allison female white    0         white
#> 698       Anne female white    0         white
#> 699       Brad   male white    0         white
#> 700       Brad   male white    0         white
#> 701      Brett   male white    0         white
#> 702     Carrie female white    0         white
#> 703     Carrie female white    0         white
#> 704      Emily female white    0         white
#> 705      Jamal   male black    0    black male
#> 706        Jay   male white    0         white
#> 707        Jay   male white    0         white
#> 708   Jermaine   male black    0    black male
#> 709       Jill female white    0         white
#> 710     Kareem   male black    0    black male
#> 711     Kareem   male black    0    black male
#> 712     Kareem   male black    0    black male
#> 713     Keisha female black    0 black, female
#> 714    Latonya female black    0 black, female
#> 715    Latonya female black    0 black, female
#> 716     Latoya female black    0 black, female
#> 717     Laurie female white    0         white
#> 718      Leroy   male black    0    black male
#> 719       Neil   male white    0         white
#> 720    Rasheed   male black    0    black male
#> 721      Sarah female white    0         white
#> 722      Sarah female white    0         white
#> 723    Tanisha female black    0 black, female
#> 724    Tanisha female black    0 black, female
#> 725   Tremayne   male black    0    black male
#> 726     Tyrone   male black    0    black male
#> 727    Kristen female white    0         white
#> 728    Latonya female black    0 black, female
#> 729      Sarah female white    0         white
#> 730    Tanisha female black    0 black, female
#> 731      Ebony female black    0 black, female
#> 732      Emily female white    0         white
#> 733    Lakisha female black    0 black, female
#> 734      Sarah female white    0         white
#> 735       Anne female white    1         white
#> 736     Latoya female black    1 black, female
#> 737   Meredith female white    0         white
#> 738    Tanisha female black    0 black, female
#> 739       Anne female white    0         white
#> 740      Hakim   male black    0    black male
#> 741        Jay   male white    0         white
#> 742     Latoya female black    0 black, female
#> 743      Aisha female black    0 black, female
#> 744      Emily female white    0         white
#> 745       Jill female white    0         white
#> 746     Keisha female black    0 black, female
#> 747     Laurie female white    0         white
#> 748     Tamika female black    0 black, female
#> 749     Carrie female white    0         white
#> 750    Lakisha female black    0 black, female
#> 751     Latoya female black    0 black, female
#> 752     Laurie female white    0         white
#> 753    Allison female white    0         white
#> 754    Kristen female white    0         white
#> 755    Lakisha female black    0 black, female
#> 756    Latonya female black    0 black, female
#> 757    Allison female white    1         white
#> 758     Keisha female black    0 black, female
#> 759     Laurie female white    1         white
#> 760    Tanisha female black    0 black, female
#> 761       Jill female white    0         white
#> 762    Kristen female white    0         white
#> 763    Lakisha female black    0 black, female
#> 764     Tamika female black    0 black, female
#> 765     Latoya female black    1 black, female
#> 766     Laurie female white    1         white
#> 767      Sarah female white    0         white
#> 768     Tamika female black    0 black, female
#> 769      Ebony female black    0 black, female
#> 770    Lakisha female black    0 black, female
#> 771   Meredith female white    0         white
#> 772      Sarah female white    0         white
#> 773    Allison female white    0         white
#> 774      Kenya female black    0 black, female
#> 775     Laurie female white    0         white
#> 776     Tamika female black    0 black, female
#> 777    Allison female white    0         white
#> 778     Keisha female black    0 black, female
#> 779    Lakisha female black    0 black, female
#> 780   Meredith female white    0         white
#> 781    Latonya female black    0 black, female
#> 782     Laurie female white    0         white
#> 783      Aisha female black    0 black, female
#> 784    Allison female white    0         white
#> 785     Carrie female white    0         white
#> 786    Tanisha female black    0 black, female
#> 787       Anne female white    0         white
#> 788     Latoya female black    0 black, female
#> 789     Laurie female white    0         white
#> 790     Tamika female black    0 black, female
#> 791     Carrie female white    0         white
#> 792    Lakisha female black    0 black, female
#> 793    Latonya female black    0 black, female
#> 794      Sarah female white    0         white
#> 795      Ebony female black    0 black, female
#> 796    Kristen female white    0         white
#> 797       Anne female white    0         white
#> 798      Emily female white    0         white
#> 799      Kenya female black    0 black, female
#> 800     Latoya female black    0 black, female
#> 801    Allison female white    0         white
#> 802      Emily female white    0         white
#> 803     Tamika female black    0 black, female
#> 804    Tanisha female black    0 black, female
#> 805      Aisha female black    0 black, female
#> 806    Allison female white    0         white
#> 807     Carrie female white    1         white
#> 808     Latoya female black    0 black, female
#> 809      Ebony female black    0 black, female
#> 810       Jill female white    0         white
#> 811    Kristen female white    0         white
#> 812     Latoya female black    0 black, female
#> 813       Anne female white    0         white
#> 814      Emily female white    0         white
#> 815     Keisha female black    0 black, female
#> 816      Kenya female black    0 black, female
#> 817     Carrie female white    0         white
#> 818      Ebony female black    0 black, female
#> 819   Meredith female white    0         white
#> 820     Tamika female black    0 black, female
#> 821    Kristen female white    1         white
#> 822     Laurie female white    0         white
#> 823     Tamika female black    0 black, female
#> 824    Tanisha female black    0 black, female
#> 825     Carrie female white    0         white
#> 826      Emily female white    0         white
#> 827     Keisha female black    0 black, female
#> 828     Tamika female black    0 black, female
#> 829    Allison female white    0         white
#> 830       Brad   male white    0         white
#> 831       Brad   male white    0         white
#> 832    Brendan   male white    0         white
#> 833      Brett   male white    0         white
#> 834      Brett   male white    0         white
#> 835     Carrie female white    0         white
#> 836      Emily female white    0         white
#> 837       Greg   male white    0         white
#> 838      Hakim   male black    0    black male
#> 839      Hakim   male black    0    black male
#> 840      Hakim   male black    0    black male
#> 841      Jamal   male black    0    black male
#> 842        Jay   male white    0         white
#> 843     Keisha female black    0 black, female
#> 844     Keisha female black    0 black, female
#> 845     Keisha female black    0 black, female
#> 846     Keisha female black    0 black, female
#> 847     Keisha female black    0 black, female
#> 848     Keisha female black    0 black, female
#> 849      Kenya female black    0 black, female
#> 850    Kristen female white    0         white
#> 851    Matthew   male white    0         white
#> 852   Meredith female white    0         white
#> 853      Sarah female white    0         white
#> 854      Sarah female white    0         white
#> 855       Todd   male white    0         white
#> 856   Tremayne   male black    0    black male
#> 857     Tyrone   male black    0    black male
#> 858     Tyrone   male black    0    black male
#> 859     Tyrone   male black    0    black male
#> 860     Tyrone   male black    0    black male
#> 861    Allison female white    0         white
#> 862       Anne female white    0         white
#> 863    Latonya female black    0 black, female
#> 864     Tamika female black    0 black, female
#> 865       Jill female white    0         white
#> 866      Kenya female black    0 black, female
#> 867   Meredith female white    0         white
#> 868     Tamika female black    0 black, female
#> 869    Allison female white    0         white
#> 870      Ebony female black    0 black, female
#> 871      Emily female white    0         white
#> 872     Latoya female black    0 black, female
#> 873    Kristen female white    0         white
#> 874    Latonya female black    0 black, female
#> 875     Laurie female white    0         white
#> 876    Tanisha female black    0 black, female
#> 877       Anne female white    0         white
#> 878      Kenya female black    0 black, female
#> 879    Lakisha female black    0 black, female
#> 880   Meredith female white    0         white
#> 881      Emily female white    0         white
#> 882   Meredith female white    0         white
#> 883    Tanisha female black    0 black, female
#> 884     Tyrone   male black    0    black male
#> 885      Aisha female black    0 black, female
#> 886    Allison female white    1         white
#> 887     Carrie female white    1         white
#> 888     Latoya female black    0 black, female
#> 889       Anne female white    1         white
#> 890     Tamika female black    0 black, female
#> 891      Aisha female black    0 black, female
#> 892     Carrie female white    0         white
#> 893      Ebony female black    0 black, female
#> 894   Meredith female white    0         white
#> 895       Anne female white    0         white
#> 896    Lakisha female black    0 black, female
#> 897    Latonya female black    0 black, female
#> 898   Meredith female white    1         white
#> 899      Aisha female black    0 black, female
#> 900      Emily female white    0         white
#> 901       Jill female white    0         white
#> 902     Keisha female black    0 black, female
#> 903    Allison female white    0         white
#> 904     Latoya female black    0 black, female
#> 905   Meredith female white    0         white
#> 906    Tanisha female black    0 black, female
#> 907     Carrie female white    0         white
#> 908      Kenya female black    0 black, female
#> 909    Latonya female black    0 black, female
#> 910      Sarah female white    1         white
#> 911    Allison female white    1         white
#> 912      Ebony female black    0 black, female
#> 913      Sarah female white    0         white
#> 914    Tanisha female black    0 black, female
#> 915       Anne female white    0         white
#> 916      Ebony female black    0 black, female
#> 917     Keisha female black    0 black, female
#> 918    Kristen female white    0         white
#> 919    Allison female white    0         white
#> 920      Emily female white    0         white
#> 921    Latonya female black    0 black, female
#> 922     Latoya female black    0 black, female
#> 923       Jill female white    0         white
#> 924     Latoya female black    0 black, female
#> 925      Sarah female white    1         white
#> 926     Tamika female black    1 black, female
#> 927       Anne female white    0         white
#> 928       Jill female white    0         white
#> 929     Keisha female black    0 black, female
#> 930      Kenya female black    0 black, female
#> 931     Latoya female black    0 black, female
#> 932     Laurie female white    0         white
#> 933   Meredith female white    0         white
#> 934     Tamika female black    0 black, female
#> 935      Aisha female black    0 black, female
#> 936       Anne female white    0         white
#> 937     Keisha female black    0 black, female
#> 938     Laurie female white    0         white
#> 939     Carrie female white    0         white
#> 940      Kenya female black    0 black, female
#> 941    Lakisha female black    0 black, female
#> 942     Laurie female white    0         white
#> 943      Emily female white    0         white
#> 944       Greg   male white    0         white
#> 945    Lakisha female black    0 black, female
#> 946     Latoya female black    0 black, female
#> 947       Jill female white    0         white
#> 948    Kristen female white    0         white
#> 949     Latoya female black    0 black, female
#> 950     Tamika female black    0 black, female
#> 951      Ebony female black    0 black, female
#> 952      Emily female white    0         white
#> 953    Kristen female white    1         white
#> 954     Latoya female black    0 black, female
#> 955    Allison female white    0         white
#> 956     Latoya female black    0 black, female
#> 957     Carrie female white    0         white
#> 958     Keisha female black    0 black, female
#> 959    Kristen female white    0         white
#> 960     Latoya female black    0 black, female
#> 961    Allison female white    0         white
#> 962       Anne female white    0         white
#> 963    Lakisha female black    0 black, female
#> 964     Tamika female black    0 black, female
#> 965      Ebony female black    0 black, female
#> 966    Kristen female white    0         white
#> 967   Meredith female white    0         white
#> 968    Tanisha female black    0 black, female
#> 969    Allison female white    0         white
#> 970      Emily female white    0         white
#> 971     Tamika female black    0 black, female
#> 972    Tanisha female black    0 black, female
#> 973    Allison female white    0         white
#> 974      Kenya female black    0 black, female
#> 975     Laurie female white    0         white
#> 976     Tamika female black    0 black, female
#> 977    Allison female white    1         white
#> 978      Ebony female black    0 black, female
#> 979       Jill female white    0         white
#> 980     Keisha female black    0 black, female
#> 981    Allison female white    0         white
#> 982     Carrie female white    0         white
#> 983      Ebony female black    0 black, female
#> 984     Tamika female black    0 black, female
#> 985     Carrie female white    0         white
#> 986     Keisha female black    0 black, female
#> 987      Kenya female black    0 black, female
#> 988      Sarah female white    1         white
#> 989      Ebony female black    1 black, female
#> 990     Laurie female white    0         white
#> 991    Allison female white    0         white
#> 992     Keisha female black    0 black, female
#> 993    Kristen female white    0         white
#> 994     Tamika female black    0 black, female
#> 995      Ebony female black    0 black, female
#> 996     Keisha female black    0 black, female
#> 997   Meredith female white    0         white
#> 998      Sarah female white    0         white
#> 999       Anne female white    0         white
#> 1000      Brad   male white    0         white
#> 1001     Brett   male white    0         white
#> 1002     Brett   male white    0         white
#> 1003   Darnell   male black    0    black male
#> 1004     Ebony female black    0 black, female
#> 1005     Emily female white    0         white
#> 1006  Geoffrey   male white    0         white
#> 1007     Jamal   male black    0    black male
#> 1008       Jay   male white    0         white
#> 1009       Jay   male white    1         white
#> 1010  Jermaine   male black    0    black male
#> 1011  Jermaine   male black    0    black male
#> 1012      Jill female white    0         white
#> 1013      Jill female white    0         white
#> 1014    Kareem   male black    0    black male
#> 1015    Keisha female black    0 black, female
#> 1016     Kenya female black    0 black, female
#> 1017   Kristen female white    0         white
#> 1018   Latonya female black    0 black, female
#> 1019   Latonya female black    0 black, female
#> 1020   Latonya female black    0 black, female
#> 1021    Laurie female white    0         white
#> 1022     Leroy   male black    0    black male
#> 1023     Leroy   male black    0    black male
#> 1024     Leroy   male black    0    black male
#> 1025     Leroy   male black    0    black male
#> 1026   Matthew   male white    0         white
#> 1027  Meredith female white    0         white
#> 1028      Neil   male white    0         white
#> 1029      Neil   male white    0         white
#> 1030      Neil   male white    0         white
#> 1031      Neil   male white    0         white
#> 1032   Rasheed   male black    0    black male
#> 1033   Rasheed   male black    0    black male
#> 1034   Tanisha female black    0 black, female
#> 1035      Todd   male white    0         white
#> 1036      Todd   male white    0         white
#> 1037    Tyrone   male black    0    black male
#> 1038    Tyrone   male black    0    black male
#> 1039   Allison female white    0         white
#> 1040      Jill female white    0         white
#> 1041   Latonya female black    0 black, female
#> 1042    Tamika female black    0 black, female
#> 1043      Jill female white    0         white
#> 1044     Kenya female black    0 black, female
#> 1045   Kristen female white    0         white
#> 1046    Tamika female black    0 black, female
#> 1047     Brett   male white    0         white
#> 1048     Hakim   male black    0    black male
#> 1049    Laurie female white    1         white
#> 1050   Rasheed   male black    0    black male
#> 1051    Carrie female white    0         white
#> 1052     Ebony female black    0 black, female
#> 1053   Latonya female black    0 black, female
#> 1054  Meredith female white    0         white
#> 1055   Allison female white    0         white
#> 1056     Ebony female black    0 black, female
#> 1057    Latoya female black    0 black, female
#> 1058    Laurie female white    0         white
#> 1059    Carrie female white    0         white
#> 1060     Kenya female black    0 black, female
#> 1061   Lakisha female black    0 black, female
#> 1062  Meredith female white    0         white
#> 1063     Aisha female black    0 black, female
#> 1064      Anne female white    0         white
#> 1065   Kristen female white    0         white
#> 1066   Tanisha female black    0 black, female
#> 1067      Anne female white    0         white
#> 1068      Anne female white    0         white
#> 1069     Ebony female black    0 black, female
#> 1070   Tanisha female black    0 black, female
#> 1071     Kenya female black    0 black, female
#> 1072   Kristen female white    0         white
#> 1073  Meredith female white    0         white
#> 1074   Tanisha female black    0 black, female
#> 1075     Aisha female black    0 black, female
#> 1076    Carrie female white    0         white
#> 1077   Latonya female black    0 black, female
#> 1078    Laurie female white    0         white
#> 1079     Ebony female black    0 black, female
#> 1080      Jill female white    1         white
#> 1081    Keisha female black    0 black, female
#> 1082    Laurie female white    0         white
#> 1083     Ebony female black    0 black, female
#> 1084     Emily female white    0         white
#> 1085    Laurie female white    0         white
#> 1086    Tamika female black    0 black, female
#> 1087      Jill female white    0         white
#> 1088   Lakisha female black    0 black, female
#> 1089    Latoya female black    0 black, female
#> 1090    Laurie female white    0         white
#> 1091      Anne female white    0         white
#> 1092     Kenya female black    0 black, female
#> 1093    Latoya female black    0 black, female
#> 1094    Laurie female white    0         white
#> 1095   Allison female white    0         white
#> 1096      Jill female white    0         white
#> 1097     Kenya female black    0 black, female
#> 1098   Lakisha female black    0 black, female
#> 1099   Kristen female white    0         white
#> 1100    Latoya female black    0 black, female
#> 1101     Sarah female white    0         white
#> 1102   Tanisha female black    0 black, female
#> 1103     Emily female white    0         white
#> 1104      Jill female white    0         white
#> 1105   Lakisha female black    0 black, female
#> 1106   Latonya female black    0 black, female
#> 1107      Neil   male white    0         white
#> 1108    Tyrone   male black    0    black male
#> 1109   Allison female white    0         white
#> 1110      Anne female white    0         white
#> 1111     Kenya female black    0 black, female
#> 1112    Tamika female black    0 black, female
#> 1113   Kristen female white    1         white
#> 1114    Tamika female black    0 black, female
#> 1115      Anne female white    0         white
#> 1116     Ebony female black    0 black, female
#> 1117      Jill female white    0         white
#> 1118   Tanisha female black    0 black, female
#> 1119     Aisha female black    0 black, female
#> 1120   Allison female white    0         white
#> 1121    Latoya female black    0 black, female
#> 1122    Laurie female white    0         white
#> 1123   Allison female white    0         white
#> 1124      Anne female white    0         white
#> 1125   Latonya female black    0 black, female
#> 1126    Latoya female black    0 black, female
#> 1127     Ebony female black    0 black, female
#> 1128      Jill female white    0         white
#> 1129    Keisha female black    0 black, female
#> 1130    Laurie female white    0         white
#> 1131     Aisha female black    0 black, female
#> 1132     Emily female white    0         white
#> 1133      Jill female white    0         white
#> 1134    Keisha female black    0 black, female
#> 1135     Aisha female black    0 black, female
#> 1136   Brendan   male white    0         white
#> 1137   Brendan   male white    0         white
#> 1138    Carrie female white    0         white
#> 1139   Darnell   male black    0    black male
#> 1140     Ebony female black    0 black, female
#> 1141  Geoffrey   male white    0         white
#> 1142     Jamal   male black    0    black male
#> 1143     Jamal   male black    0    black male
#> 1144       Jay   male white    0         white
#> 1145       Jay   male white    0         white
#> 1146  Jermaine   male black    0    black male
#> 1147      Jill female white    0         white
#> 1148    Kareem   male black    0    black male
#> 1149   Kristen female white    0         white
#> 1150    Latoya female black    0 black, female
#> 1151     Leroy   male black    0    black male
#> 1152     Leroy   male black    0    black male
#> 1153      Neil   male white    0         white
#> 1154   Rasheed   male black    0    black male
#> 1155     Sarah female white    0         white
#> 1156      Todd   male white    0         white
#> 1157      Todd   male white    0         white
#> 1158  Tremayne   male black    0    black male
#> 1159   Allison female white    0         white
#> 1160      Anne female white    0         white
#> 1161    Latoya female black    0 black, female
#> 1162    Tamika female black    0 black, female
#> 1163   Latonya female black    0 black, female
#> 1164    Laurie female white    1         white
#> 1165  Meredith female white    1         white
#> 1166    Tamika female black    1 black, female
#> 1167     Emily female white    0         white
#> 1168     Kenya female black    0 black, female
#> 1169   Kristen female white    0         white
#> 1170   Tanisha female black    0 black, female
#> 1171     Ebony female black    0 black, female
#> 1172     Emily female white    1         white
#> 1173    Latoya female black    0 black, female
#> 1174     Sarah female white    0         white
#> 1175     Ebony female black    0 black, female
#> 1176      Jill female white    0         white
#> 1177   Kristen female white    0         white
#> 1178   Tanisha female black    0 black, female
#> 1179     Emily female white    0         white
#> 1180     Kenya female black    0 black, female
#> 1181     Sarah female white    0         white
#> 1182    Tamika female black    0 black, female
#> 1183     Ebony female black    0 black, female
#> 1184   Kristen female white    0         white
#> 1185    Laurie female white    0         white
#> 1186   Tanisha female black    0 black, female
#> 1187   Allison female white    1         white
#> 1188     Ebony female black    0 black, female
#> 1189    Kareem   male black    0    black male
#> 1190      Neil   male white    0         white
#> 1191     Aisha female black    0 black, female
#> 1192      Anne female white    0         white
#> 1193     Ebony female black    0 black, female
#> 1194      Jill female white    0         white
#> 1195      Jill female white    0         white
#> 1196    Keisha female black    0 black, female
#> 1197   Lakisha female black    0 black, female
#> 1198  Meredith female white    0         white
#> 1199     Aisha female black    0 black, female
#> 1200      Anne female white    0         white
#> 1201    Carrie female white    0         white
#> 1202     Kenya female black    0 black, female
#> 1203     Aisha female black    0 black, female
#> 1204     Emily female white    0         white
#> 1205  Meredith female white    0         white
#> 1206   Tanisha female black    0 black, female
#> 1207     Aisha female black    0 black, female
#> 1208   Allison female white    0         white
#> 1209     Emily female white    0         white
#> 1210     Kenya female black    0 black, female
#> 1211   Allison female white    0         white
#> 1212   Kristen female white    1         white
#> 1213   Lakisha female black    1 black, female
#> 1214    Tamika female black    1 black, female
#> 1215     Aisha female black    0 black, female
#> 1216     Emily female white    0         white
#> 1217   Kristen female white    0         white
#> 1218   Tanisha female black    0 black, female
#> 1219     Aisha female black    0 black, female
#> 1220    Carrie female white    0         white
#> 1221  Meredith female white    0         white
#> 1222   Tanisha female black    0 black, female
#> 1223      Anne female white    0         white
#> 1224      Jill female white    0         white
#> 1225   Lakisha female black    0 black, female
#> 1226   Tanisha female black    0 black, female
#> 1227     Emily female white    0         white
#> 1228    Latoya female black    0 black, female
#> 1229  Meredith female white    0         white
#> 1230    Tamika female black    0 black, female
#> 1231   Allison female white    0         white
#> 1232   Latonya female black    0 black, female
#> 1233  Meredith female white    0         white
#> 1234    Tamika female black    0 black, female
#> 1235     Leroy   male black    0    black male
#> 1236   Matthew   male white    0         white
#> 1237      Neil   male white    0         white
#> 1238    Tyrone   male black    0    black male
#> 1239  Meredith female white    0         white
#> 1240   Tanisha female black    0 black, female
#> 1241    Carrie female white    0         white
#> 1242     Emily female white    0         white
#> 1243    Keisha female black    0 black, female
#> 1244   Lakisha female black    0 black, female
#> 1245   Allison female white    0         white
#> 1246     Ebony female black    0 black, female
#> 1247    Latoya female black    0 black, female
#> 1248    Laurie female white    0         white
#> 1249   Allison female white    0         white
#> 1250      Anne female white    0         white
#> 1251      Brad   male white    0         white
#> 1252     Brett   male white    0         white
#> 1253   Darnell   male black    0    black male
#> 1254   Darnell   male black    1    black male
#> 1255   Darnell   male black    0    black male
#> 1256     Ebony female black    0 black, female
#> 1257     Emily female white    0         white
#> 1258  Geoffrey   male white    0         white
#> 1259  Geoffrey   male white    0         white
#> 1260       Jay   male white    0         white
#> 1261  Jermaine   male black    0    black male
#> 1262      Jill female white    0         white
#> 1263    Keisha female black    1 black, female
#> 1264    Keisha female black    0 black, female
#> 1265   Lakisha female black    0 black, female
#> 1266   Latonya female black    0 black, female
#> 1267    Latoya female black    0 black, female
#> 1268  Meredith female white    0         white
#> 1269  Meredith female white    0         white
#> 1270      Neil   male white    0         white
#> 1271   Rasheed   male black    0    black male
#> 1272      Todd   male white    0         white
#> 1273      Todd   male white    0         white
#> 1274  Tremayne   male black    0    black male
#> 1275    Tyrone   male black    0    black male
#> 1276    Tyrone   male black    0    black male
#> 1277     Emily female white    0         white
#> 1278   Lakisha female black    0 black, female
#> 1279     Sarah female white    1         white
#> 1280   Tanisha female black    0 black, female
#> 1281   Allison female white    0         white
#> 1282     Kenya female black    0 black, female
#> 1283   Latonya female black    0 black, female
#> 1284  Meredith female white    1         white
#> 1285      Anne female white    0         white
#> 1286     Ebony female black    0 black, female
#> 1287     Emily female white    0         white
#> 1288    Tamika female black    0 black, female
#> 1289      Anne female white    0         white
#> 1290     Kenya female black    0 black, female
#> 1291   Latonya female black    0 black, female
#> 1292     Sarah female white    0         white
#> 1293     Ebony female black    0 black, female
#> 1294   Kristen female white    0         white
#> 1295    Laurie female white    0         white
#> 1296    Tamika female black    0 black, female
#> 1297   Allison female white    0         white
#> 1298      Jill female white    0         white
#> 1299     Kenya female black    0 black, female
#> 1300   Lakisha female black    0 black, female
#> 1301      Anne female white    1         white
#> 1302     Emily female white    0         white
#> 1303     Kenya female black    0 black, female
#> 1304    Latoya female black    0 black, female
#> 1305     Ebony female black    0 black, female
#> 1306     Emily female white    0         white
#> 1307      Jill female white    0         white
#> 1308    Tamika female black    0 black, female
#> 1309   Allison female white    1         white
#> 1310     Hakim   male black    1    black male
#> 1311     Jamal   male black    1    black male
#> 1312       Jay   male white    1         white
#> 1313      Anne female white    0         white
#> 1314     Emily female white    0         white
#> 1315   Lakisha female black    0 black, female
#> 1316   Latonya female black    0 black, female
#> 1317      Anne female white    0         white
#> 1318     Ebony female black    0 black, female
#> 1319     Sarah female white    0         white
#> 1320   Tanisha female black    0 black, female
#> 1321    Laurie female white    0         white
#> 1322    Tamika female black    0 black, female
#> 1323     Emily female white    0         white
#> 1324    Keisha female black    0 black, female
#> 1325    Latoya female black    0 black, female
#> 1326  Meredith female white    0         white
#> 1327   Kristen female white    0         white
#> 1328    Latoya female black    0 black, female
#> 1329  Meredith female white    0         white
#> 1330   Tanisha female black    0 black, female
#> 1331      Anne female white    1         white
#> 1332     Kenya female black    1 black, female
#> 1333     Sarah female white    1         white
#> 1334   Tanisha female black    1 black, female
#> 1335    Carrie female white    0         white
#> 1336     Emily female white    0         white
#> 1337    Keisha female black    0 black, female
#> 1338     Kenya female black    0 black, female
#> 1339      Anne female white    0         white
#> 1340     Emily female white    0         white
#> 1341    Keisha female black    0 black, female
#> 1342   Tanisha female black    0 black, female
#> 1343     Emily female white    0         white
#> 1344     Kenya female black    0 black, female
#> 1345   Latonya female black    0 black, female
#> 1346     Sarah female white    0         white
#> 1347     Emily female white    0         white
#> 1348   Latonya female black    0 black, female
#> 1349    Latoya female black    0 black, female
#> 1350     Sarah female white    0         white
#> 1351     Emily female white    0         white
#> 1352      Jill female white    0         white
#> 1353   Lakisha female black    0 black, female
#> 1354   Latonya female black    0 black, female
#> 1355      Anne female white    0         white
#> 1356     Ebony female black    0 black, female
#> 1357    Latoya female black    0 black, female
#> 1358  Meredith female white    0         white
#> 1359   Allison female white    0         white
#> 1360     Ebony female black    0 black, female
#> 1361     Emily female white    0         white
#> 1362    Latoya female black    0 black, female
#> 1363      Anne female white    0         white
#> 1364     Emily female white    0         white
#> 1365    Keisha female black    0 black, female
#> 1366    Tamika female black    0 black, female
#> 1367      Jill female white    0         white
#> 1368   Lakisha female black    0 black, female
#> 1369     Sarah female white    0         white
#> 1370    Tamika female black    0 black, female
#> 1371    Carrie female white    1         white
#> 1372   Lakisha female black    0 black, female
#> 1373    Laurie female white    0         white
#> 1374   Tanisha female black    0 black, female
#> 1375     Aisha female black    0 black, female
#> 1376     Aisha female black    0 black, female
#> 1377     Aisha female black    0 black, female
#> 1378      Anne female white    0         white
#> 1379      Brad   male white    0         white
#> 1380      Brad   male white    0         white
#> 1381    Carrie female white    0         white
#> 1382    Carrie female white    0         white
#> 1383     Emily female white    0         white
#> 1384  Geoffrey   male white    0         white
#> 1385     Hakim   male black    0    black male
#> 1386       Jay   male white    0         white
#> 1387  Jermaine   male black    0    black male
#> 1388    Keisha female black    0 black, female
#> 1389     Kenya female black    0 black, female
#> 1390   Kristen female white    0         white
#> 1391   Kristen female white    0         white
#> 1392   Kristen female white    0         white
#> 1393   Lakisha female black    0 black, female
#> 1394   Lakisha female black    0 black, female
#> 1395   Latonya female black    0 black, female
#> 1396    Latoya female black    0 black, female
#> 1397     Leroy   male black    0    black male
#> 1398   Matthew   male white    0         white
#> 1399   Matthew   male white    0         white
#> 1400      Neil   male white    0         white
#> 1401   Rasheed   male black    0    black male
#> 1402     Sarah female white    0         white
#> 1403      Todd   male white    0         white
#> 1404  Tremayne   male black    0    black male
#> 1405  Tremayne   male black    0    black male
#> 1406    Tyrone   male black    0    black male
#> 1407    Latoya female black    1 black, female
#> 1408  Meredith female white    1         white
#> 1409     Sarah female white    1         white
#> 1410   Tanisha female black    1 black, female
#> 1411      Jill female white    1         white
#> 1412   Kristen female white    0         white
#> 1413    Tamika female black    0 black, female
#> 1414   Tanisha female black    0 black, female
#> 1415      Anne female white    0         white
#> 1416     Ebony female black    0 black, female
#> 1417   Lakisha female black    0 black, female
#> 1418    Laurie female white    0         white
#> 1419   Allison female white    0         white
#> 1420     Emily female white    0         white
#> 1421     Kenya female black    0 black, female
#> 1422    Tamika female black    0 black, female
#> 1423   Latonya female black    0 black, female
#> 1424    Laurie female white    0         white
#> 1425  Meredith female white    0         white
#> 1426    Tamika female black    0 black, female
#> 1427   Kristen female white    0         white
#> 1428   Latonya female black    0 black, female
#> 1429     Sarah female white    0         white
#> 1430   Tanisha female black    0 black, female
#> 1431   Allison female white    1         white
#> 1432      Anne female white    0         white
#> 1433   Lakisha female black    0 black, female
#> 1434    Tamika female black    0 black, female
#> 1435      Anne female white    1         white
#> 1436     Emily female white    1         white
#> 1437   Lakisha female black    0 black, female
#> 1438    Latoya female black    0 black, female
#> 1439    Carrie female white    0         white
#> 1440     Ebony female black    0 black, female
#> 1441    Laurie female white    0         white
#> 1442   Tanisha female black    0 black, female
#> 1443    Carrie female white    1         white
#> 1444     Ebony female black    0 black, female
#> 1445   Kristen female white    1         white
#> 1446   Tanisha female black    0 black, female
#> 1447      Jill female white    1         white
#> 1448   Lakisha female black    1 black, female
#> 1449     Aisha female black    0 black, female
#> 1450      Anne female white    0         white
#> 1451      Jill female white    0         white
#> 1452    Tamika female black    0 black, female
#> 1453     Aisha female black    0 black, female
#> 1454   Allison female white    0         white
#> 1455    Carrie female white    0         white
#> 1456    Latoya female black    0 black, female
#> 1457      Anne female white    0         white
#> 1458     Emily female white    0         white
#> 1459    Latoya female black    0 black, female
#> 1460    Tamika female black    0 black, female
#> 1461      Anne female white    0         white
#> 1462     Emily female white    0         white
#> 1463     Kenya female black    0 black, female
#> 1464    Latoya female black    0 black, female
#> 1465    Carrie female white    0         white
#> 1466     Emily female white    0         white
#> 1467    Keisha female black    0 black, female
#> 1468    Tamika female black    0 black, female
#> 1469      Anne female white    0         white
#> 1470   Lakisha female black    0 black, female
#> 1471   Latonya female black    0 black, female
#> 1472  Meredith female white    0         white
#> 1473      Anne female white    0         white
#> 1474     Kenya female black    0 black, female
#> 1475   Kristen female white    0         white
#> 1476    Latoya female black    0 black, female
#> 1477   Kristen female white    0         white
#> 1478    Latoya female black    0 black, female
#> 1479     Aisha female black    0 black, female
#> 1480      Jill female white    0         white
#> 1481   Kristen female white    0         white
#> 1482   Lakisha female black    0 black, female
#> 1483      Anne female white    0         white
#> 1484     Kenya female black    0 black, female
#> 1485   Kristen female white    0         white
#> 1486    Tamika female black    0 black, female
#> 1487   Allison female white    0         white
#> 1488    Keisha female black    0 black, female
#> 1489     Kenya female black    0 black, female
#> 1490     Sarah female white    0         white
#> 1491   Brendan   male white    0         white
#> 1492     Brett   male white    0         white
#> 1493  Jermaine   male black    0    black male
#> 1494    Tyrone   male black    0    black male
#> 1495      Jill female white    1         white
#> 1496     Kenya female black    0 black, female
#> 1497    Latoya female black    0 black, female
#> 1498    Laurie female white    1         white
#> 1499    Keisha female black    0 black, female
#> 1500   Lakisha female black    0 black, female
#> 1501    Laurie female white    0         white
#> 1502     Sarah female white    0         white
#> 1503     Emily female white    0         white
#> 1504     Kenya female black    0 black, female
#> 1505     Kenya female black    0 black, female
#> 1506   Lakisha female black    0 black, female
#> 1507    Laurie female white    0         white
#> 1508     Sarah female white    0         white
#> 1509      Anne female white    0         white
#> 1510   Lakisha female black    0 black, female
#> 1511   Latonya female black    0 black, female
#> 1512  Meredith female white    0         white
#> 1513     Ebony female black    0 black, female
#> 1514   Kristen female white    0         white
#> 1515   Latonya female black    0 black, female
#> 1516  Meredith female white    0         white
#> 1517     Aisha female black    0 black, female
#> 1518     Aisha female black    0 black, female
#> 1519     Aisha female black    0 black, female
#> 1520      Brad   male white    1         white
#> 1521      Brad   male white    0         white
#> 1522   Brendan   male white    0         white
#> 1523   Brendan   male white    0         white
#> 1524     Brett   male white    1         white
#> 1525    Carrie female white    0         white
#> 1526     Hakim   male black    0    black male
#> 1527       Jay   male white    0         white
#> 1528    Kareem   male black    0    black male
#> 1529     Kenya female black    1 black, female
#> 1530   Kristen female white    0         white
#> 1531   Lakisha female black    0 black, female
#> 1532   Lakisha female black    0 black, female
#> 1533   Latonya female black    1 black, female
#> 1534     Leroy   male black    0    black male
#> 1535     Leroy   male black    0    black male
#> 1536   Matthew   male white    0         white
#> 1537   Matthew   male white    0         white
#> 1538      Neil   male white    0         white
#> 1539      Neil   male white    0         white
#> 1540      Neil   male white    0         white
#> 1541     Sarah female white    0         white
#> 1542  Tremayne   male black    0    black male
#> 1543    Tyrone   male black    0    black male
#> 1544    Tyrone   male black    0    black male
#> 1545      Anne female white    0         white
#> 1546   Lakisha female black    0 black, female
#> 1547    Latoya female black    0 black, female
#> 1548     Sarah female white    1         white
#> 1549     Aisha female black    0 black, female
#> 1550      Anne female white    0         white
#> 1551     Sarah female white    0         white
#> 1552   Tanisha female black    0 black, female
#> 1553    Carrie female white    0         white
#> 1554     Ebony female black    0 black, female
#> 1555     Kenya female black    0 black, female
#> 1556   Kristen female white    0         white
#> 1557     Aisha female black    0 black, female
#> 1558   Allison female white    0         white
#> 1559     Ebony female black    1 black, female
#> 1560      Jill female white    0         white
#> 1561   Allison female white    0         white
#> 1562     Emily female white    1         white
#> 1563    Latoya female black    0 black, female
#> 1564    Tamika female black    1 black, female
#> 1565     Aisha female black    0 black, female
#> 1566    Carrie female white    1         white
#> 1567      Jill female white    1         white
#> 1568   Latonya female black    0 black, female
#> 1569     Kenya female black    0 black, female
#> 1570   Kristen female white    0         white
#> 1571    Latoya female black    0 black, female
#> 1572     Sarah female white    0         white
#> 1573     Emily female white    0         white
#> 1574      Jill female white    1         white
#> 1575     Kenya female black    0 black, female
#> 1576    Latoya female black    0 black, female
#> 1577     Emily female white    1         white
#> 1578     Kenya female black    0 black, female
#> 1579   Lakisha female black    0 black, female
#> 1580     Sarah female white    0         white
#> 1581      Brad   male white    1         white
#> 1582     Hakim   male black    1    black male
#> 1583      Todd   male white    1         white
#> 1584  Tremayne   male black    1    black male
#> 1585      Anne female white    0         white
#> 1586     Kenya female black    0 black, female
#> 1587   Kristen female white    0         white
#> 1588   Latonya female black    0 black, female
#> 1589   Allison female white    0         white
#> 1590    Keisha female black    1 black, female
#> 1591   Kristen female white    0         white
#> 1592    Tamika female black    0 black, female
#> 1593      Jill female white    0         white
#> 1594   Kristen female white    0         white
#> 1595    Latoya female black    0 black, female
#> 1596    Tamika female black    0 black, female
#> 1597   Allison female white    0         white
#> 1598   Latonya female black    0 black, female
#> 1599  Meredith female white    0         white
#> 1600    Tamika female black    0 black, female
#> 1601     Aisha female black    0 black, female
#> 1602     Emily female white    0         white
#> 1603    Laurie female white    0         white
#> 1604   Tanisha female black    0 black, female
#> 1605      Jill female white    0         white
#> 1606     Kenya female black    0 black, female
#> 1607   Latonya female black    0 black, female
#> 1608  Meredith female white    0         white
#> 1609    Carrie female white    0         white
#> 1610     Ebony female black    0 black, female
#> 1611   Latonya female black    0 black, female
#> 1612     Sarah female white    0         white
#> 1613   Kristen female white    0         white
#> 1614    Latoya female black    0 black, female
#> 1615    Laurie female white    0         white
#> 1616    Tamika female black    0 black, female
#> 1617     Kenya female black    0 black, female
#> 1618   Kristen female white    0         white
#> 1619    Laurie female white    0         white
#> 1620    Tamika female black    0 black, female
#> 1621      Anne female white    0         white
#> 1622     Ebony female black    0 black, female
#> 1623      Jill female white    0         white
#> 1624   Latonya female black    0 black, female
#> 1625      Anne female white    0         white
#> 1626     Kenya female black    0 black, female
#> 1627   Latonya female black    0 black, female
#> 1628  Meredith female white    0         white
#> 1629      Anne female white    0         white
#> 1630    Keisha female black    0 black, female
#> 1631   Kristen female white    0         white
#> 1632   Latonya female black    0 black, female
#> 1633    Carrie female white    0         white
#> 1634     Ebony female black    0 black, female
#> 1635     Emily female white    0         white
#> 1636    Tamika female black    0 black, female
#> 1637     Brett   male white    0         white
#> 1638      Neil   male white    0         white
#> 1639   Rasheed   male black    0    black male
#> 1640    Tyrone   male black    0    black male
#> 1641   Brendan   male white    0         white
#> 1642     Jamal   male black    0    black male
#> 1643     Aisha female black    0 black, female
#> 1644   Allison female white    0         white
#> 1645    Carrie female white    0         white
#> 1646    Latoya female black    0 black, female
#> 1647     Aisha female black    0 black, female
#> 1648   Allison female white    0         white
#> 1649      Jill female white    0         white
#> 1650    Tamika female black    0 black, female
#> 1651      Jill female white    0         white
#> 1652    Keisha female black    0 black, female
#> 1653   Kristen female white    0         white
#> 1654    Tamika female black    0 black, female
#> 1655   Allison female white    0         white
#> 1656      Anne female white    0         white
#> 1657      Brad   male white    0         white
#> 1658     Brett   male white    0         white
#> 1659     Ebony female black    0 black, female
#> 1660     Emily female white    0         white
#> 1661  Geoffrey   male white    0         white
#> 1662  Geoffrey   male white    0         white
#> 1663       Jay   male white    0         white
#> 1664    Kareem   male black    0    black male
#> 1665    Kareem   male black    0    black male
#> 1666    Keisha female black    0 black, female
#> 1667    Keisha female black    0 black, female
#> 1668     Kenya female black    0 black, female
#> 1669     Kenya female black    0 black, female
#> 1670   Kristen female white    0         white
#> 1671    Laurie female white    0         white
#> 1672    Laurie female white    0         white
#> 1673     Leroy   male black    0    black male
#> 1674     Leroy   male black    0    black male
#> 1675     Leroy   male black    0    black male
#> 1676   Matthew   male white    0         white
#> 1677  Meredith female white    0         white
#> 1678   Rasheed   male black    0    black male
#> 1679     Sarah female white    0         white
#> 1680   Tanisha female black    0 black, female
#> 1681    Tyrone   male black    0    black male
#> 1682    Tyrone   male black    0    black male
#> 1683    Carrie female white    0         white
#> 1684    Laurie female white    0         white
#> 1685    Tamika female black    0 black, female
#> 1686   Tanisha female black    0 black, female
#> 1687   Allison female white    1         white
#> 1688     Ebony female black    0 black, female
#> 1689     Emily female white    0         white
#> 1690    Latoya female black    0 black, female
#> 1691   Allison female white    0         white
#> 1692     Emily female white    0         white
#> 1693     Kenya female black    0 black, female
#> 1694   Lakisha female black    0 black, female
#> 1695    Carrie female white    1         white
#> 1696    Latoya female black    1 black, female
#> 1697     Sarah female white    1         white
#> 1698    Tamika female black    0 black, female
#> 1699     Aisha female black    0 black, female
#> 1700      Anne female white    0         white
#> 1701      Jill female white    0         white
#> 1702    Latoya female black    1 black, female
#> 1703     Ebony female black    0 black, female
#> 1704     Emily female white    0         white
#> 1705   Kristen female white    0         white
#> 1706   Lakisha female black    0 black, female
#> 1707      Anne female white    0         white
#> 1708   Lakisha female black    0 black, female
#> 1709     Sarah female white    0         white
#> 1710   Tanisha female black    0 black, female
#> 1711     Ebony female black    0 black, female
#> 1712      Jill female white    1         white
#> 1713   Kristen female white    1         white
#> 1714   Tanisha female black    0 black, female
#> 1715    Carrie female white    0         white
#> 1716      Jill female white    1         white
#> 1717    Keisha female black    0 black, female
#> 1718   Lakisha female black    1 black, female
#> 1719  Geoffrey   male white    0         white
#> 1720     Kenya female black    0 black, female
#> 1721    Laurie female white    0         white
#> 1722    Tamika female black    0 black, female
#> 1723     Emily female white    0         white
#> 1724   Latonya female black    0 black, female
#> 1725    Laurie female white    0         white
#> 1726    Tamika female black    0 black, female
#> 1727   Allison female white    0         white
#> 1728   Lakisha female black    0 black, female
#> 1729   Lakisha female black    0 black, female
#> 1730  Meredith female white    0         white
#> 1731     Sarah female white    0         white
#> 1732   Tanisha female black    0 black, female
#> 1733   Allison female white    0         white
#> 1734      Anne female white    0         white
#> 1735     Ebony female black    0 black, female
#> 1736    Latoya female black    0 black, female
#> 1737     Aisha female black    0 black, female
#> 1738      Anne female white    1         white
#> 1739      Jill female white    0         white
#> 1740   Tanisha female black    0 black, female
#> 1741   Brendan   male white    1         white
#> 1742    Keisha female black    0 black, female
#> 1743     Kenya female black    0 black, female
#> 1744     Sarah female white    1         white
#> 1745      Todd   male white    0         white
#> 1746    Tyrone   male black    0    black male
#> 1747     Emily female white    0         white
#> 1748   Latonya female black    0 black, female
#> 1749      Jill female white    0         white
#> 1750     Kenya female black    0 black, female
#> 1751     Sarah female white    0         white
#> 1752   Tanisha female black    0 black, female
#> 1753      Jill female white    0         white
#> 1754   Lakisha female black    0 black, female
#> 1755    Latoya female black    0 black, female
#> 1756      Neil   male white    0         white
#> 1757    Keisha female black    0 black, female
#> 1758    Laurie female white    0         white
#> 1759   Allison female white    0         white
#> 1760     Ebony female black    0 black, female
#> 1761     Emily female white    0         white
#> 1762   Latonya female black    0 black, female
#> 1763   Allison female white    0         white
#> 1764      Jill female white    0         white
#> 1765    Keisha female black    0 black, female
#> 1766   Kristen female white    0         white
#> 1767    Latoya female black    0 black, female
#> 1768   Rasheed   male black    0    black male
#> 1769     Aisha female black    0 black, female
#> 1770   Allison female white    0         white
#> 1771    Latoya female black    0 black, female
#> 1772     Sarah female white    0         white
#> 1773   Brendan   male white    0         white
#> 1774     Emily female white    0         white
#> 1775    Keisha female black    0 black, female
#> 1776     Kenya female black    0 black, female
#> 1777   Lakisha female black    0 black, female
#> 1778     Sarah female white    0         white
#> 1779     Aisha female black    0 black, female
#> 1780     Aisha female black    0 black, female
#> 1781      Anne female white    0         white
#> 1782    Carrie female white    0         white
#> 1783     Emily female white    0         white
#> 1784     Kenya female black    0 black, female
#> 1785     Kenya female black    0 black, female
#> 1786   Kristen female white    0         white
#> 1787  Meredith female white    0         white
#> 1788   Tanisha female black    0 black, female
#> 1789   Allison female white    0         white
#> 1790     Emily female white    0         white
#> 1791     Kenya female black    0 black, female
#> 1792    Tamika female black    0 black, female
#> 1793     Brett   male white    0         white
#> 1794     Hakim   male black    0    black male
#> 1795      Jill female white    0         white
#> 1796      Jill female white    0         white
#> 1797   Matthew   male white    0         white
#> 1798    Tamika female black    0 black, female
#> 1799   Tanisha female black    0 black, female
#> 1800    Tyrone   male black    0    black male
#> 1801      Jill female white    0         white
#> 1802    Tamika female black    0 black, female
#> 1803      Anne female white    0         white
#> 1804   Latonya female black    0 black, female
#> 1805    Latoya female black    0 black, female
#> 1806     Sarah female white    0         white
#> 1807   Allison female white    0         white
#> 1808     Ebony female black    0 black, female
#> 1809     Emily female white    0         white
#> 1810      Jill female white    0         white
#> 1811     Kenya female black    0 black, female
#> 1812    Laurie female white    0         white
#> 1813    Tamika female black    0 black, female
#> 1814   Tanisha female black    0 black, female
#> 1815     Emily female white    1         white
#> 1816     Kenya female black    1 black, female
#> 1817   Lakisha female black    0 black, female
#> 1818      Todd   male white    0         white
#> 1819     Aisha female black    0 black, female
#> 1820      Jill female white    0         white
#> 1821   Lakisha female black    0 black, female
#> 1822   Matthew   male white    0         white
#> 1823   Lakisha female black    0 black, female
#> 1824   Matthew   male white    0         white
#> 1825      Brad   male white    0         white
#> 1826    Tamika female black    0 black, female
#> 1827      Anne female white    0         white
#> 1828    Keisha female black    0 black, female
#> 1829   Kristen female white    0         white
#> 1830   Lakisha female black    0 black, female
#> 1831   Allison female white    0         white
#> 1832     Emily female white    0         white
#> 1833     Sarah female white    0         white
#> 1834    Tamika female black    0 black, female
#> 1835    Tamika female black    0 black, female
#> 1836   Tanisha female black    0 black, female
#> 1837  Geoffrey   male white    0         white
#> 1838      Jill female white    0         white
#> 1839    Keisha female black    0 black, female
#> 1840   Kristen female white    0         white
#> 1841    Tamika female black    0 black, female
#> 1842   Tanisha female black    0 black, female
#> 1843   Allison female white    0         white
#> 1844      Anne female white    0         white
#> 1845    Keisha female black    0 black, female
#> 1846   Kristen female white    1         white
#> 1847   Lakisha female black    0 black, female
#> 1848    Latoya female black    0 black, female
#> 1849    Carrie female white    0         white
#> 1850    Keisha female black    0 black, female
#> 1851     Kenya female black    0 black, female
#> 1852     Leroy   male black    0    black male
#> 1853      Neil   male white    0         white
#> 1854     Sarah female white    0         white
#> 1855      Anne female white    0         white
#> 1856     Emily female white    0         white
#> 1857    Keisha female black    0 black, female
#> 1858   Latonya female black    0 black, female
#> 1859    Laurie female white    0         white
#> 1860   Tanisha female black    0 black, female
#> 1861   Allison female white    0         white
#> 1862     Kenya female black    0 black, female
#> 1863   Latonya female black    0 black, female
#> 1864     Leroy   male black    0    black male
#> 1865  Meredith female white    0         white
#> 1866      Todd   male white    0         white
#> 1867     Kenya female black    0 black, female
#> 1868      Todd   male white    0         white
#> 1869     Emily female white    0         white
#> 1870   Latonya female black    0 black, female
#> 1871    Laurie female white    0         white
#> 1872    Tamika female black    0 black, female
#> 1873   Allison female white    0         white
#> 1874    Carrie female white    0         white
#> 1875   Kristen female white    0         white
#> 1876   Lakisha female black    0 black, female
#> 1877   Latonya female black    0 black, female
#> 1878    Tyrone   male black    0    black male
#> 1879     Aisha female black    0 black, female
#> 1880     Aisha female black    0 black, female
#> 1881     Emily female white    0         white
#> 1882     Emily female white    0         white
#> 1883    Keisha female black    0 black, female
#> 1884    Keisha female black    0 black, female
#> 1885   Matthew   male white    0         white
#> 1886     Sarah female white    0         white
#> 1887      Anne female white    0         white
#> 1888      Brad   male white    1         white
#> 1889     Hakim   male black    0    black male
#> 1890     Kenya female black    0 black, female
#> 1891     Kenya female black    1 black, female
#> 1892    Latoya female black    0 black, female
#> 1893  Meredith female white    1         white
#> 1894  Meredith female white    0         white
#> 1895     Aisha female black    0 black, female
#> 1896      Brad   male white    0         white
#> 1897      Brad   male white    0         white
#> 1898    Carrie female white    0         white
#> 1899   Darnell   male black    0    black male
#> 1900     Ebony female black    0 black, female
#> 1901     Emily female white    0         white
#> 1902  Geoffrey   male white    0         white
#> 1903      Greg   male white    0         white
#> 1904     Hakim   male black    0    black male
#> 1905     Jamal   male black    0    black male
#> 1906      Jill female white    0         white
#> 1907    Keisha female black    0 black, female
#> 1908     Kenya female black    0 black, female
#> 1909   Latonya female black    0 black, female
#> 1910    Latoya female black    0 black, female
#> 1911     Leroy   male black    0    black male
#> 1912   Matthew   male white    1         white
#> 1913   Matthew   male white    0         white
#> 1914   Matthew   male white    0         white
#> 1915   Matthew   male white    0         white
#> 1916   Rasheed   male black    1    black male
#> 1917      Todd   male white    0         white
#> 1918  Tremayne   male black    0    black male
#> 1919      Anne female white    0         white
#> 1920     Kenya female black    0 black, female
#> 1921  Meredith female white    0         white
#> 1922    Tamika female black    0 black, female
#> 1923      Anne female white    0         white
#> 1924     Kenya female black    0 black, female
#> 1925  Meredith female white    0         white
#> 1926    Tamika female black    0 black, female
#> 1927     Ebony female black    0 black, female
#> 1928   Kristen female white    0         white
#> 1929   Latonya female black    0 black, female
#> 1930    Laurie female white    0         white
#> 1931     Emily female white    0         white
#> 1932      Jill female white    0         white
#> 1933    Latoya female black    0 black, female
#> 1934   Tanisha female black    0 black, female
#> 1935    Keisha female black    1 black, female
#> 1936   Kristen female white    1         white
#> 1937     Sarah female white    0         white
#> 1938    Tamika female black    1 black, female
#> 1939     Emily female white    0         white
#> 1940    Latoya female black    0 black, female
#> 1941      Jill female white    0         white
#> 1942   Lakisha female black    0 black, female
#> 1943  Meredith female white    0         white
#> 1944   Tanisha female black    0 black, female
#> 1945      Anne female white    0         white
#> 1946    Latoya female black    0 black, female
#> 1947     Sarah female white    0         white
#> 1948   Tanisha female black    0 black, female
#> 1949      Jill female white    0         white
#> 1950   Lakisha female black    0 black, female
#> 1951    Laurie female white    1         white
#> 1952    Tamika female black    1 black, female
#> 1953   Allison female white    0         white
#> 1954     Kenya female black    0 black, female
#> 1955   Lakisha female black    0 black, female
#> 1956    Laurie female white    0         white
#> 1957   Allison female white    0         white
#> 1958      Anne female white    0         white
#> 1959     Ebony female black    0 black, female
#> 1960     Kenya female black    0 black, female
#> 1961     Ebony female black    1 black, female
#> 1962      Jill female white    0         white
#> 1963    Laurie female white    0         white
#> 1964    Tamika female black    0 black, female
#> 1965     Emily female white    0         white
#> 1966    Keisha female black    0 black, female
#> 1967     Kenya female black    0 black, female
#> 1968     Sarah female white    0         white
#> 1969     Hakim   male black    0    black male
#> 1970     Leroy   male black    1    black male
#> 1971      Neil   male white    0         white
#> 1972      Todd   male white    0         white
#> 1973      Jill female white    0         white
#> 1974    Keisha female black    0 black, female
#> 1975  Meredith female white    0         white
#> 1976    Tamika female black    0 black, female
#> 1977      Anne female white    0         white
#> 1978     Ebony female black    1 black, female
#> 1979      Jill female white    0         white
#> 1980    Tamika female black    0 black, female
#> 1981     Aisha female black    0 black, female
#> 1982      Anne female white    0         white
#> 1983     Kenya female black    0 black, female
#> 1984   Kristen female white    0         white
#> 1985     Aisha female black    0 black, female
#> 1986      Brad   male white    1         white
#> 1987   Brendan   male white    0         white
#> 1988   Brendan   male white    0         white
#> 1989     Brett   male white    0         white
#> 1990    Carrie female white    0         white
#> 1991     Ebony female black    0 black, female
#> 1992  Geoffrey   male white    0         white
#> 1993     Jamal   male black    0    black male
#> 1994       Jay   male white    0         white
#> 1995    Kareem   male black    0    black male
#> 1996     Kenya female black    0 black, female
#> 1997     Kenya female black    0 black, female
#> 1998   Lakisha female black    0 black, female
#> 1999      Neil   male white    0         white
#> 2000     Sarah female white    0         white
#> 2001   Tanisha female black    0 black, female
#> 2002      Todd   male white    0         white
#> 2003    Tyrone   male black    0    black male
#> 2004    Tyrone   male black    0    black male
#> 2005     Emily female white    0         white
#> 2006   Lakisha female black    0 black, female
#> 2007     Sarah female white    0         white
#> 2008   Tanisha female black    0 black, female
#> 2009      Jill female white    1         white
#> 2010   Latonya female black    1 black, female
#> 2011    Latoya female black    1 black, female
#> 2012     Sarah female white    0         white
#> 2013    Keisha female black    0 black, female
#> 2014   Kristen female white    1         white
#> 2015    Latoya female black    0 black, female
#> 2016     Sarah female white    0         white
#> 2017      Jill female white    0         white
#> 2018     Leroy   male black    0    black male
#> 2019  Meredith female white    0         white
#> 2020   Tanisha female black    0 black, female
#> 2021     Emily female white    0         white
#> 2022   Latonya female black    0 black, female
#> 2023    Laurie female white    0         white
#> 2024    Tamika female black    0 black, female
#> 2025     Ebony female black    0 black, female
#> 2026     Emily female white    0         white
#> 2027     Sarah female white    1         white
#> 2028    Tamika female black    0 black, female
#> 2029     Aisha female black    0 black, female
#> 2030     Emily female white    0         white
#> 2031   Kristen female white    0         white
#> 2032   Tanisha female black    0 black, female
#> 2033     Ebony female black    0 black, female
#> 2034   Latonya female black    0 black, female
#> 2035  Meredith female white    0         white
#> 2036     Sarah female white    0         white
#> 2037   Kristen female white    0         white
#> 2038   Latonya female black    0 black, female
#> 2039  Meredith female white    0         white
#> 2040    Tamika female black    0 black, female
#> 2041   Allison female white    0         white
#> 2042      Anne female white    0         white
#> 2043   Lakisha female black    0 black, female
#> 2044    Tamika female black    0 black, female
#> 2045   Allison female white    0         white
#> 2046   Latonya female black    0 black, female
#> 2047    Laurie female white    0         white
#> 2048    Tamika female black    0 black, female
#> 2049      Jill female white    0         white
#> 2050     Kenya female black    0 black, female
#> 2051     Sarah female white    0         white
#> 2052    Tamika female black    0 black, female
#> 2053      Anne female white    0         white
#> 2054   Lakisha female black    0 black, female
#> 2055     Sarah female white    0         white
#> 2056    Tamika female black    0 black, female
#> 2057     Emily female white    0         white
#> 2058   Lakisha female black    0 black, female
#> 2059    Latoya female black    0 black, female
#> 2060  Meredith female white    0         white
#> 2061     Aisha female black    0 black, female
#> 2062   Brendan   male white    0         white
#> 2063     Brett   male white    0         white
#> 2064   Darnell   male black    0    black male
#> 2065  Geoffrey   male white    0         white
#> 2066      Greg   male white    0         white
#> 2067       Jay   male white    0         white
#> 2068  Jermaine   male black    0    black male
#> 2069      Jill female white    0         white
#> 2070    Keisha female black    0 black, female
#> 2071   Kristen female white    0         white
#> 2072   Kristen female white    0         white
#> 2073   Lakisha female black    0 black, female
#> 2074    Laurie female white    0         white
#> 2075     Leroy   male black    0    black male
#> 2076     Leroy   male black    0    black male
#> 2077     Leroy   male black    0    black male
#> 2078   Matthew   male white    0         white
#> 2079      Neil   male white    0         white
#> 2080      Neil   male white    0         white
#> 2081    Tamika female black    0 black, female
#> 2082    Tyrone   male black    0    black male
#> 2083    Tyrone   male black    0    black male
#> 2084    Tyrone   male black    0    black male
#> 2085      Anne female white    0         white
#> 2086    Carrie female white    0         white
#> 2087    Keisha female black    0 black, female
#> 2088    Latoya female black    0 black, female
#> 2089      Anne female white    0         white
#> 2090      Jill female white    0         white
#> 2091   Latonya female black    0 black, female
#> 2092   Tanisha female black    0 black, female
#> 2093      Anne female white    1         white
#> 2094   Lakisha female black    1 black, female
#> 2095     Sarah female white    0         white
#> 2096   Tanisha female black    0 black, female
#> 2097   Allison female white    1         white
#> 2098    Carrie female white    1         white
#> 2099   Latonya female black    1 black, female
#> 2100    Tamika female black    1 black, female
#> 2101     Aisha female black    0 black, female
#> 2102     Emily female white    0         white
#> 2103    Latoya female black    0 black, female
#> 2104  Meredith female white    0         white
#> 2105     Aisha female black    0 black, female
#> 2106   Allison female white    0         white
#> 2107    Carrie female white    1         white
#> 2108    Latoya female black    0 black, female
#> 2109     Emily female white    1         white
#> 2110   Latonya female black    0 black, female
#> 2111    Laurie female white    1         white
#> 2112    Tyrone   male black    0    black male
#> 2113      Anne female white    0         white
#> 2114    Latoya female black    0 black, female
#> 2115     Sarah female white    0         white
#> 2116   Tanisha female black    0 black, female
#> 2117     Aisha female black    0 black, female
#> 2118    Laurie female white    0         white
#> 2119     Sarah female white    0         white
#> 2120    Tamika female black    0 black, female
#> 2121     Aisha female black    0 black, female
#> 2122     Emily female white    0         white
#> 2123    Laurie female white    0         white
#> 2124   Tanisha female black    0 black, female
#> 2125     Ebony female black    0 black, female
#> 2126    Laurie female white    0         white
#> 2127  Meredith female white    0         white
#> 2128    Tamika female black    0 black, female
#> 2129    Latoya female black    0 black, female
#> 2130  Meredith female white    0         white
#> 2131     Sarah female white    0         white
#> 2132    Tamika female black    0 black, female
#> 2133   Allison female white    0         white
#> 2134      Jill female white    0         white
#> 2135     Kenya female black    0 black, female
#> 2136    Latoya female black    0 black, female
#> 2137     Ebony female black    0 black, female
#> 2138     Emily female white    0         white
#> 2139      Jill female white    0         white
#> 2140   Lakisha female black    0 black, female
#> 2141   Allison female white    0         white
#> 2142     Emily female white    0         white
#> 2143     Kenya female black    0 black, female
#> 2144    Tamika female black    0 black, female
#> 2145      Anne female white    0         white
#> 2146   Kristen female white    0         white
#> 2147   Lakisha female black    0 black, female
#> 2148    Tamika female black    0 black, female
#> 2149      Anne female white    0         white
#> 2150    Carrie female white    0         white
#> 2151   Latonya female black    0 black, female
#> 2152    Latoya female black    0 black, female
#> 2153      Brad   male white    0         white
#> 2154   Brendan   male white    0         white
#> 2155     Brett   male white    0         white
#> 2156    Carrie female white    0         white
#> 2157     Ebony female black    0 black, female
#> 2158     Emily female white    0         white
#> 2159  Geoffrey   male white    0         white
#> 2160      Greg   male white    0         white
#> 2161      Greg   male white    0         white
#> 2162     Hakim   male black    0    black male
#> 2163     Jamal   male black    0    black male
#> 2164     Jamal   male black    0    black male
#> 2165  Jermaine   male black    1    black male
#> 2166    Kareem   male black    0    black male
#> 2167    Keisha female black    0 black, female
#> 2168   Kristen female white    0         white
#> 2169   Lakisha female black    0 black, female
#> 2170   Lakisha female black    0 black, female
#> 2171   Latonya female black    0 black, female
#> 2172   Latonya female black    0 black, female
#> 2173    Latoya female black    0 black, female
#> 2174    Latoya female black    0 black, female
#> 2175    Latoya female black    0 black, female
#> 2176    Laurie female white    0         white
#> 2177    Laurie female white    0         white
#> 2178    Laurie female white    0         white
#> 2179   Matthew   male white    0         white
#> 2180   Matthew   male white    0         white
#> 2181   Matthew   male white    0         white
#> 2182      Neil   male white    0         white
#> 2183      Neil   male white    0         white
#> 2184   Rasheed   male black    0    black male
#> 2185   Rasheed   male black    0    black male
#> 2186    Tamika female black    0 black, female
#> 2187   Tanisha female black    0 black, female
#> 2188   Tanisha female black    0 black, female
#> 2189      Todd   male white    0         white
#> 2190      Todd   male white    0         white
#> 2191      Todd   male white    0         white
#> 2192    Tyrone   male black    0    black male
#> 2193   Latonya female black    0 black, female
#> 2194  Meredith female white    1         white
#> 2195     Sarah female white    1         white
#> 2196   Tanisha female black    0 black, female
#> 2197   Allison female white    0         white
#> 2198     Kenya female black    0 black, female
#> 2199   Kristen female white    0         white
#> 2200   Lakisha female black    0 black, female
#> 2201    Carrie female white    0         white
#> 2202    Keisha female black    1 black, female
#> 2203    Latoya female black    0 black, female
#> 2204    Laurie female white    1         white
#> 2205   Allison female white    1         white
#> 2206     Ebony female black    0 black, female
#> 2207    Latoya female black    0 black, female
#> 2208    Laurie female white    1         white
#> 2209      Jill female white    0         white
#> 2210    Keisha female black    0 black, female
#> 2211   Latonya female black    1 black, female
#> 2212     Sarah female white    0         white
#> 2213     Emily female white    0         white
#> 2214      Jill female white    0         white
#> 2215    Latoya female black    0 black, female
#> 2216    Tamika female black    0 black, female
#> 2217     Emily female white    0         white
#> 2218      Jill female white    0         white
#> 2219     Kenya female black    0 black, female
#> 2220    Latoya female black    0 black, female
#> 2221     Aisha female black    0 black, female
#> 2222    Carrie female white    1         white
#> 2223   Latonya female black    1 black, female
#> 2224     Sarah female white    0         white
#> 2225     Kenya female black    0 black, female
#> 2226   Kristen female white    0         white
#> 2227   Lakisha female black    0 black, female
#> 2228  Meredith female white    1         white
#> 2229    Carrie female white    1         white
#> 2230     Kenya female black    0 black, female
#> 2231   Latonya female black    0 black, female
#> 2232    Laurie female white    0         white
#> 2233   Allison female white    0         white
#> 2234   Brendan   male white    1         white
#> 2235     Jamal   male black    0    black male
#> 2236    Tamika female black    0 black, female
#> 2237   Allison female white    0         white
#> 2238     Emily female white    0         white
#> 2239   Latonya female black    0 black, female
#> 2240    Latoya female black    0 black, female
#> 2241     Aisha female black    0 black, female
#> 2242   Allison female white    0         white
#> 2243   Kristen female white    0         white
#> 2244   Latonya female black    0 black, female
#> 2245     Ebony female black    0 black, female
#> 2246     Emily female white    0         white
#> 2247   Latonya female black    0 black, female
#> 2248    Laurie female white    0         white
#> 2249   Brendan   male white    0         white
#> 2250   Brendan   male white    0         white
#> 2251     Jamal   male black    0    black male
#> 2252  Jermaine   male black    0    black male
#> 2253   Allison female white    0         white
#> 2254     Emily female white    0         white
#> 2255    Tamika female black    0 black, female
#> 2256   Tanisha female black    1 black, female
#> 2257     Ebony female black    0 black, female
#> 2258     Emily female white    0         white
#> 2259    Keisha female black    0 black, female
#> 2260  Meredith female white    0         white
#> 2261     Ebony female black    0 black, female
#> 2262   Kristen female white    0         white
#> 2263  Meredith female white    0         white
#> 2264   Tanisha female black    0 black, female
#> 2265     Emily female white    0         white
#> 2266    Keisha female black    0 black, female
#> 2267    Latoya female black    0 black, female
#> 2268    Laurie female white    0         white
#> 2269     Aisha female black    0 black, female
#> 2270   Allison female white    0         white
#> 2271   Brendan   male white    0         white
#> 2272   Brendan   male white    0         white
#> 2273    Carrie female white    0         white
#> 2274    Carrie female white    0         white
#> 2275   Darnell   male black    0    black male
#> 2276     Ebony female black    0 black, female
#> 2277     Emily female white    0         white
#> 2278  Geoffrey   male white    0         white
#> 2279  Geoffrey   male white    0         white
#> 2280      Greg   male white    0         white
#> 2281     Hakim   male black    0    black male
#> 2282       Jay   male white    0         white
#> 2283    Kareem   male black    0    black male
#> 2284     Kenya female black    0 black, female
#> 2285     Kenya female black    0 black, female
#> 2286   Kristen female white    0         white
#> 2287   Kristen female white    0         white
#> 2288   Lakisha female black    0 black, female
#> 2289   Lakisha female black    0 black, female
#> 2290   Lakisha female black    0 black, female
#> 2291   Latonya female black    0 black, female
#> 2292    Latoya female black    0 black, female
#> 2293    Laurie female white    0         white
#> 2294   Matthew   male white    0         white
#> 2295  Meredith female white    0         white
#> 2296      Neil   male white    0         white
#> 2297   Rasheed   male black    0    black male
#> 2298    Tamika female black    0 black, female
#> 2299   Tanisha female black    0 black, female
#> 2300  Tremayne   male black    0    black male
#> 2301     Aisha female black    0 black, female
#> 2302      Anne female white    1         white
#> 2303    Carrie female white    1         white
#> 2304     Kenya female black    1 black, female
#> 2305    Keisha female black    0 black, female
#> 2306   Kristen female white    0         white
#> 2307   Latonya female black    0 black, female
#> 2308  Meredith female white    0         white
#> 2309    Carrie female white    0         white
#> 2310      Jill female white    0         white
#> 2311    Keisha female black    0 black, female
#> 2312   Lakisha female black    0 black, female
#> 2313     Aisha female black    0 black, female
#> 2314   Allison female white    0         white
#> 2315     Emily female white    0         white
#> 2316   Tanisha female black    0 black, female
#> 2317      Anne female white    1         white
#> 2318     Ebony female black    1 black, female
#> 2319     Emily female white    1         white
#> 2320    Tamika female black    1 black, female
#> 2321     Aisha female black    0 black, female
#> 2322   Allison female white    0         white
#> 2323   Latonya female black    0 black, female
#> 2324    Laurie female white    0         white
#> 2325      Anne female white    1         white
#> 2326  Geoffrey   male white    1         white
#> 2327  Jermaine   male black    1    black male
#> 2328    Latoya female black    0 black, female
#> 2329     Aisha female black    0 black, female
#> 2330   Kristen female white    0         white
#> 2331   Latonya female black    0 black, female
#> 2332     Sarah female white    0         white
#> 2333      Jill female white    0         white
#> 2334    Keisha female black    0 black, female
#> 2335   Kristen female white    0         white
#> 2336   Lakisha female black    0 black, female
#> 2337     Aisha female black    0 black, female
#> 2338     Emily female white    0         white
#> 2339   Latonya female black    0 black, female
#> 2340    Laurie female white    0         white
#> 2341      Anne female white    0         white
#> 2342      Anne female white    0         white
#> 2343      Anne female white    0         white
#> 2344      Brad   male white    0         white
#> 2345      Brad   male white    0         white
#> 2346     Emily female white    0         white
#> 2347      Greg   male white    0         white
#> 2348     Hakim   male black    0    black male
#> 2349     Jamal   male black    0    black male
#> 2350  Jermaine   male black    0    black male
#> 2351      Jill female white    0         white
#> 2352    Kareem   male black    0    black male
#> 2353    Kareem   male black    0    black male
#> 2354    Keisha female black    0 black, female
#> 2355    Keisha female black    0 black, female
#> 2356    Keisha female black    0 black, female
#> 2357   Lakisha female black    0 black, female
#> 2358   Lakisha female black    0 black, female
#> 2359    Laurie female white    0         white
#> 2360    Laurie female white    0         white
#> 2361     Leroy   male black    0    black male
#> 2362     Leroy   male black    0    black male
#> 2363  Meredith female white    0         white
#> 2364  Meredith female white    0         white
#> 2365      Neil   male white    0         white
#> 2366   Rasheed   male black    0    black male
#> 2367    Tamika female black    0 black, female
#> 2368      Todd   male white    0         white
#> 2369     Aisha female black    0 black, female
#> 2370      Anne female white    0         white
#> 2371  Meredith female white    0         white
#> 2372    Tamika female black    0 black, female
#> 2373     Aisha female black    0 black, female
#> 2374      Jill female white    0         white
#> 2375  Meredith female white    0         white
#> 2376   Tanisha female black    1 black, female
#> 2377   Allison female white    0         white
#> 2378      Anne female white    0         white
#> 2379    Keisha female black    1 black, female
#> 2380   Lakisha female black    1 black, female
#> 2381   Allison female white    1         white
#> 2382   Latonya female black    1 black, female
#> 2383    Latoya female black    1 black, female
#> 2384  Meredith female white    1         white
#> 2385     Aisha female black    0 black, female
#> 2386     Kenya female black    0 black, female
#> 2387    Laurie female white    0         white
#> 2388  Meredith female white    0         white
#> 2389   Allison female white    0         white
#> 2390   Latonya female black    0 black, female
#> 2391     Sarah female white    0         white
#> 2392    Tamika female black    0 black, female
#> 2393      Jill female white    1         white
#> 2394   Latonya female black    0 black, female
#> 2395    Latoya female black    0 black, female
#> 2396  Meredith female white    1         white
#> 2397   Allison female white    0         white
#> 2398    Latoya female black    0 black, female
#> 2399  Meredith female white    0         white
#> 2400    Tamika female black    0 black, female
#> 2401     Ebony female black    0 black, female
#> 2402     Kenya female black    0 black, female
#> 2403   Kristen female white    0         white
#> 2404    Laurie female white    0         white
#> 2405     Hakim   male black    0    black male
#> 2406       Jay   male white    0         white
#> 2407     Leroy   male black    0    black male
#> 2408  Meredith female white    0         white
#> 2409     Ebony female black    0 black, female
#> 2410   Kristen female white    0         white
#> 2411   Latonya female black    0 black, female
#> 2412  Meredith female white    0         white
#> 2413     Aisha female black    0 black, female
#> 2414    Carrie female white    0         white
#> 2415     Ebony female black    0 black, female
#> 2416   Kristen female white    0         white
#> 2417     Jamal   male black    0    black male
#> 2418      Todd   male white    0         white
#> 2419      Anne female white    0         white
#> 2420     Ebony female black    0 black, female
#> 2421     Kenya female black    0 black, female
#> 2422   Kristen female white    0         white
#> 2423   Allison female white    0         white
#> 2424      Anne female white    0         white
#> 2425    Tamika female black    0 black, female
#> 2426   Tanisha female black    0 black, female
#> 2427   Allison female white    0         white
#> 2428    Keisha female black    0 black, female
#> 2429  Meredith female white    0         white
#> 2430   Tanisha female black    0 black, female
#> 2431     Aisha female black    0 black, female
#> 2432      Anne female white    0         white
#> 2433      Anne female white    0         white
#> 2434      Brad   male white    0         white
#> 2435   Brendan   male white    0         white
#> 2436     Brett   male white    0         white
#> 2437     Brett   male white    0         white
#> 2438     Brett   male white    0         white
#> 2439     Ebony female black    0 black, female
#> 2440     Ebony female black    0 black, female
#> 2441  Geoffrey   male white    0         white
#> 2442      Greg   male white    0         white
#> 2443     Hakim   male black    0    black male
#> 2444     Hakim   male black    0    black male
#> 2445       Jay   male white    0         white
#> 2446  Jermaine   male black    0    black male
#> 2447      Jill female white    0         white
#> 2448    Kareem   male black    0    black male
#> 2449    Keisha female black    0 black, female
#> 2450     Kenya female black    0 black, female
#> 2451   Kristen female white    0         white
#> 2452   Lakisha female black    0 black, female
#> 2453   Latonya female black    0 black, female
#> 2454   Latonya female black    0 black, female
#> 2455     Leroy   male black    0    black male
#> 2456     Leroy   male black    0    black male
#> 2457   Matthew   male white    0         white
#> 2458      Neil   male white    0         white
#> 2459     Sarah female white    0         white
#> 2460      Todd   male white    0         white
#> 2461  Tremayne   male black    0    black male
#> 2462    Tyrone   male black    0    black male
#> 2463     Ebony female black    0 black, female
#> 2464   Latonya female black    0 black, female
#> 2465  Meredith female white    0         white
#> 2466     Sarah female white    0         white
#> 2467     Ebony female black    0 black, female
#> 2468   Kristen female white    1         white
#> 2469  Meredith female white    1         white
#> 2470   Tanisha female black    1 black, female
#> 2471     Emily female white    0         white
#> 2472    Keisha female black    0 black, female
#> 2473   Lakisha female black    0 black, female
#> 2474  Meredith female white    0         white
#> 2475     Aisha female black    0 black, female
#> 2476      Anne female white    1         white
#> 2477    Carrie female white    1         white
#> 2478    Latoya female black    0 black, female
#> 2479      Jill female white    0         white
#> 2480   Lakisha female black    0 black, female
#> 2481     Sarah female white    0         white
#> 2482    Tamika female black    0 black, female
#> 2483   Allison female white    0         white
#> 2484     Emily female white    0         white
#> 2485     Kenya female black    0 black, female
#> 2486    Latoya female black    0 black, female
#> 2487   Allison female white    0         white
#> 2488      Anne female white    0         white
#> 2489   Lakisha female black    0 black, female
#> 2490    Tamika female black    0 black, female
#> 2491   Kristen female white    1         white
#> 2492   Latonya female black    1 black, female
#> 2493      Neil   male white    0         white
#> 2494    Tyrone   male black    0    black male
#> 2495     Aisha female black    0 black, female
#> 2496      Anne female white    0         white
#> 2497    Latoya female black    0 black, female
#> 2498    Laurie female white    0         white
#> 2499   Brendan   male white    0         white
#> 2500     Brett   male white    0         white
#> 2501     Leroy   male black    0    black male
#> 2502  Tremayne   male black    0    black male
#> 2503      Anne female white    0         white
#> 2504     Emily female white    0         white
#> 2505    Keisha female black    0 black, female
#> 2506    Latoya female black    0 black, female
#> 2507   Kristen female white    0         white
#> 2508    Latoya female black    0 black, female
#> 2509     Sarah female white    0         white
#> 2510    Tamika female black    0 black, female
#> 2511     Aisha female black    0 black, female
#> 2512     Aisha female black    0 black, female
#> 2513   Allison female white    0         white
#> 2514   Allison female white    0         white
#> 2515   Brendan   male white    0         white
#> 2516     Brett   male white    1         white
#> 2517     Brett   male white    0         white
#> 2518     Brett   male white    0         white
#> 2519     Emily female white    0         white
#> 2520       Jay   male white    1         white
#> 2521      Jill female white    0         white
#> 2522      Jill female white    0         white
#> 2523    Kareem   male black    0    black male
#> 2524    Keisha female black    0 black, female
#> 2525   Lakisha female black    0 black, female
#> 2526   Latonya female black    0 black, female
#> 2527   Latonya female black    0 black, female
#> 2528   Latonya female black    0 black, female
#> 2529   Matthew   male white    0         white
#> 2530      Neil   male white    0         white
#> 2531    Tamika female black    1 black, female
#> 2532    Tamika female black    0 black, female
#> 2533  Tremayne   male black    0    black male
#> 2534    Tyrone   male black    0    black male
#> 2535     Emily female white    0         white
#> 2536   Latonya female black    0 black, female
#> 2537     Sarah female white    0         white
#> 2538   Tanisha female black    0 black, female
#> 2539     Aisha female black    0 black, female
#> 2540   Allison female white    1         white
#> 2541     Emily female white    1         white
#> 2542   Lakisha female black    1 black, female
#> 2543      Jill female white    0         white
#> 2544   Kristen female white    0         white
#> 2545   Latonya female black    0 black, female
#> 2546    Tamika female black    0 black, female
#> 2547   Allison female white    0         white
#> 2548    Keisha female black    0 black, female
#> 2549   Kristen female white    0         white
#> 2550   Tanisha female black    1 black, female
#> 2551     Emily female white    0         white
#> 2552   Lakisha female black    0 black, female
#> 2553   Matthew   male white    0         white
#> 2554   Tanisha female black    0 black, female
#> 2555      Anne female white    0         white
#> 2556    Latoya female black    0 black, female
#> 2557    Laurie female white    1         white
#> 2558    Tamika female black    0 black, female
#> 2559   Brendan   male white    0         white
#> 2560     Jamal   male black    0    black male
#> 2561     Ebony female black    0 black, female
#> 2562     Emily female white    0         white
#> 2563   Latonya female black    1 black, female
#> 2564  Meredith female white    0         white
#> 2565     Ebony female black    0 black, female
#> 2566     Emily female white    0         white
#> 2567    Keisha female black    0 black, female
#> 2568    Laurie female white    0         white
#> 2569      Anne female white    0         white
#> 2570      Brad   male white    0         white
#> 2571     Brett   male white    0         white
#> 2572     Ebony female black    0 black, female
#> 2573     Emily female white    0         white
#> 2574     Emily female white    0         white
#> 2575     Jamal   male black    0    black male
#> 2576       Jay   male white    0         white
#> 2577  Jermaine   male black    0    black male
#> 2578      Jill female white    0         white
#> 2579    Kareem   male black    0    black male
#> 2580    Kareem   male black    0    black male
#> 2581    Kareem   male black    0    black male
#> 2582    Keisha female black    0 black, female
#> 2583   Kristen female white    0         white
#> 2584   Lakisha female black    0 black, female
#> 2585     Leroy   male black    0    black male
#> 2586     Leroy   male black    0    black male
#> 2587   Matthew   male white    0         white
#> 2588   Matthew   male white    0         white
#> 2589      Neil   male white    0         white
#> 2590     Sarah female white    0         white
#> 2591     Sarah female white    0         white
#> 2592    Tamika female black    0 black, female
#> 2593   Tanisha female black    0 black, female
#> 2594   Tanisha female black    0 black, female
#> 2595   Tanisha female black    0 black, female
#> 2596      Todd   male white    0         white
#> 2597      Todd   male white    0         white
#> 2598      Todd   male white    0         white
#> 2599  Tremayne   male black    0    black male
#> 2600  Tremayne   male black    0    black male
#> 2601     Emily female white    0         white
#> 2602      Jill female white    0         white
#> 2603   Lakisha female black    0 black, female
#> 2604   Tanisha female black    0 black, female
#> 2605      Jill female white    0         white
#> 2606     Kenya female black    0 black, female
#> 2607   Kristen female white    0         white
#> 2608    Latoya female black    0 black, female
#> 2609    Carrie female white    0         white
#> 2610     Emily female white    0         white
#> 2611   Latonya female black    0 black, female
#> 2612    Latoya female black    0 black, female
#> 2613      Anne female white    1         white
#> 2614    Keisha female black    1 black, female
#> 2615     Kenya female black    1 black, female
#> 2616  Meredith female white    1         white
#> 2617      Anne female white    0         white
#> 2618   Kristen female white    0         white
#> 2619   Lakisha female black    0 black, female
#> 2620   Tanisha female black    0 black, female
#> 2621      Anne female white    1         white
#> 2622     Ebony female black    1 black, female
#> 2623   Latonya female black    0 black, female
#> 2624     Sarah female white    0         white
#> 2625   Allison female white    0         white
#> 2626      Anne female white    0         white
#> 2627     Ebony female black    1 black, female
#> 2628   Tanisha female black    1 black, female
#> 2629  Geoffrey   male white    0         white
#> 2630   Rasheed   male black    0    black male
#> 2631   Allison female white    0         white
#> 2632     Emily female white    0         white
#> 2633     Kenya female black    0 black, female
#> 2634    Latoya female black    0 black, female
#> 2635      Anne female white    0         white
#> 2636    Carrie female white    0         white
#> 2637     Kenya female black    0 black, female
#> 2638    Latoya female black    0 black, female
#> 2639     Emily female white    0         white
#> 2640    Keisha female black    0 black, female
#> 2641     Kenya female black    0 black, female
#> 2642     Sarah female white    0         white
#> 2643     Aisha female black    0 black, female
#> 2644      Greg   male white    0         white
#> 2645       Jay   male white    0         white
#> 2646  Jermaine   male black    0    black male
#> 2647  Jermaine   male black    0    black male
#> 2648    Kareem   male black    0    black male
#> 2649    Kareem   male black    0    black male
#> 2650   Kristen female white    0         white
#> 2651   Kristen female white    0         white
#> 2652   Latonya female black    0 black, female
#> 2653    Latoya female black    0 black, female
#> 2654   Matthew   male white    0         white
#> 2655  Meredith female white    0         white
#> 2656  Meredith female white    0         white
#> 2657      Todd   male white    0         white
#> 2658  Tremayne   male black    0    black male
#> 2659     Ebony female black    0 black, female
#> 2660      Jill female white    0         white
#> 2661     Kenya female black    0 black, female
#> 2662    Laurie female white    0         white
#> 2663      Anne female white    0         white
#> 2664   Lakisha female black    0 black, female
#> 2665   Latonya female black    1 black, female
#> 2666     Sarah female white    0         white
#> 2667     Ebony female black    0 black, female
#> 2668      Jill female white    0         white
#> 2669   Latonya female black    0 black, female
#> 2670    Laurie female white    1         white
#> 2671      Anne female white    0         white
#> 2672   Lakisha female black    0 black, female
#> 2673     Sarah female white    0         white
#> 2674   Tanisha female black    0 black, female
#> 2675   Allison female white    0         white
#> 2676     Kenya female black    0 black, female
#> 2677   Kristen female white    0         white
#> 2678   Lakisha female black    0 black, female
#> 2679      Anne female white    0         white
#> 2680     Ebony female black    0 black, female
#> 2681     Kenya female black    0 black, female
#> 2682   Kristen female white    1         white
#> 2683     Aisha female black    0 black, female
#> 2684      Anne female white    0         white
#> 2685   Latonya female black    0 black, female
#> 2686    Laurie female white    0         white
#> 2687    Carrie female white    0         white
#> 2688      Jill female white    0         white
#> 2689    Keisha female black    0 black, female
#> 2690    Tamika female black    0 black, female
#> 2691     Aisha female black    0 black, female
#> 2692   Allison female white    0         white
#> 2693    Carrie female white    1         white
#> 2694    Tamika female black    1 black, female
#> 2695      Anne female white    1         white
#> 2696     Jamal   male black    1    black male
#> 2697       Jay   male white    1         white
#> 2698    Tyrone   male black    1    black male
#> 2699   Brendan   male white    0         white
#> 2700     Jamal   male black    0    black male
#> 2701      Anne female white    0         white
#> 2702     Ebony female black    0 black, female
#> 2703   Kristen female white    0         white
#> 2704   Tanisha female black    0 black, female
#> 2705   Lakisha female black    0 black, female
#> 2706   Latonya female black    0 black, female
#> 2707    Laurie female white    0         white
#> 2708  Meredith female white    0         white
#> 2709     Aisha female black    0 black, female
#> 2710   Allison female white    0         white
#> 2711   Allison female white    0         white
#> 2712     Brett   male white    0         white
#> 2713    Carrie female white    0         white
#> 2714   Darnell   male black    0    black male
#> 2715     Ebony female black    0 black, female
#> 2716     Ebony female black    0 black, female
#> 2717     Ebony female black    0 black, female
#> 2718      Greg   male white    0         white
#> 2719       Jay   male white    0         white
#> 2720      Jill female white    0         white
#> 2721    Kareem   male black    0    black male
#> 2722    Keisha female black    0 black, female
#> 2723   Kristen female white    0         white
#> 2724   Lakisha female black    0 black, female
#> 2725   Latonya female black    0 black, female
#> 2726   Latonya female black    0 black, female
#> 2727    Laurie female white    0         white
#> 2728  Meredith female white    0         white
#> 2729     Sarah female white    0         white
#> 2730    Tamika female black    0 black, female
#> 2731      Todd   male white    0         white
#> 2732  Tremayne   male black    0    black male
#> 2733    Laurie female white    1         white
#> 2734  Meredith female white    0         white
#> 2735    Tamika female black    0 black, female
#> 2736   Tanisha female black    0 black, female
#> 2737      Anne female white    0         white
#> 2738      Jill female white    1         white
#> 2739   Latonya female black    1 black, female
#> 2740   Tanisha female black    0 black, female
#> 2741    Carrie female white    0         white
#> 2742   Kristen female white    0         white
#> 2743   Lakisha female black    0 black, female
#> 2744   Tanisha female black    0 black, female
#> 2745      Anne female white    1         white
#> 2746     Ebony female black    0 black, female
#> 2747     Kenya female black    1 black, female
#> 2748     Sarah female white    0         white
#> 2749      Anne female white    1         white
#> 2750     Ebony female black    0 black, female
#> 2751   Latonya female black    1 black, female
#> 2752     Sarah female white    0         white
#> 2753   Allison female white    0         white
#> 2754    Keisha female black    0 black, female
#> 2755    Laurie female white    0         white
#> 2756    Tamika female black    0 black, female
#> 2757  Meredith female white    0         white
#> 2758    Tamika female black    0 black, female
#> 2759   Allison female white    0         white
#> 2760     Brett   male white    0         white
#> 2761   Lakisha female black    1 black, female
#> 2762    Tyrone   male black    0    black male
#> 2763      Anne female white    0         white
#> 2764    Latoya female black    0 black, female
#> 2765  Meredith female white    0         white
#> 2766    Tamika female black    0 black, female
#> 2767    Carrie female white    0         white
#> 2768     Ebony female black    0 black, female
#> 2769       Jay   male white    0         white
#> 2770    Latoya female black    0 black, female
#> 2771     Sarah female white    0         white
#> 2772    Tamika female black    0 black, female
#> 2773     Aisha female black    0 black, female
#> 2774      Anne female white    0         white
#> 2775      Jill female white    0         white
#> 2776   Tanisha female black    0 black, female
#> 2777   Kristen female white    0         white
#> 2778     Sarah female white    0         white
#> 2779    Tamika female black    0 black, female
#> 2780   Tanisha female black    0 black, female
#> 2781      Anne female white    0         white
#> 2782   Tanisha female black    0 black, female
#> 2783   Kristen female white    0         white
#> 2784  Tremayne   male black    0    black male
#> 2785     Brett   male white    0         white
#> 2786     Ebony female black    0 black, female
#> 2787     Emily female white    0         white
#> 2788  Geoffrey   male white    0         white
#> 2789     Jamal   male black    0    black male
#> 2790      Jill female white    0         white
#> 2791   Lakisha female black    0 black, female
#> 2792    Tyrone   male black    0    black male
#> 2793   Allison female white    0         white
#> 2794   Lakisha female black    0 black, female
#> 2795    Latoya female black    0 black, female
#> 2796  Meredith female white    0         white
#> 2797   Allison female white    0         white
#> 2798      Brad   male white    0         white
#> 2799   Darnell   male black    0    black male
#> 2800     Kenya female black    0 black, female
#> 2801   Latonya female black    0 black, female
#> 2802  Meredith female white    0         white
#> 2803    Laurie female white    0         white
#> 2804    Tamika female black    0 black, female
#> 2805      Brad   male white    0         white
#> 2806   Latonya female black    0 black, female
#> 2807    Laurie female white    0         white
#> 2808   Tanisha female black    0 black, female
#> 2809     Aisha female black    0 black, female
#> 2810      Jill female white    0         white
#> 2811   Latonya female black    0 black, female
#> 2812    Laurie female white    0         white
#> 2813      Anne female white    0         white
#> 2814      Jill female white    0         white
#> 2815     Kenya female black    0 black, female
#> 2816   Lakisha female black    0 black, female
#> 2817       Jay   male white    0         white
#> 2818      Jill female white    0         white
#> 2819    Kareem   male black    0    black male
#> 2820    Latoya female black    0 black, female
#> 2821     Leroy   male black    0    black male
#> 2822     Sarah female white    0         white
#> 2823     Aisha female black    0 black, female
#> 2824    Laurie female white    0         white
#> 2825     Sarah female white    0         white
#> 2826    Tamika female black    0 black, female
#> 2827      Jill female white    0         white
#> 2828    Keisha female black    0 black, female
#> 2829     Kenya female black    0 black, female
#> 2830   Kristen female white    0         white
#> 2831      Anne female white    0         white
#> 2832      Anne female white    0         white
#> 2833   Darnell   male black    0    black male
#> 2834     Emily female white    0         white
#> 2835    Keisha female black    0 black, female
#> 2836   Tanisha female black    0 black, female
#> 2837     Emily female white    0         white
#> 2838     Kenya female black    0 black, female
#> 2839   Kristen female white    0         white
#> 2840   Latonya female black    0 black, female
#> 2841   Kristen female white    0         white
#> 2842    Latoya female black    0 black, female
#> 2843    Tamika female black    0 black, female
#> 2844      Todd   male white    0         white
#> 2845      Jill female white    1         white
#> 2846   Kristen female white    1         white
#> 2847    Latoya female black    1 black, female
#> 2848    Tamika female black    0 black, female
#> 2849   Kristen female white    1         white
#> 2850    Tamika female black    0 black, female
#> 2851     Aisha female black    0 black, female
#> 2852     Ebony female black    0 black, female
#> 2853     Emily female white    0         white
#> 2854      Jill female white    0         white
#> 2855    Latoya female black    0 black, female
#> 2856    Laurie female white    0         white
#> 2857   Darnell   male black    0    black male
#> 2858       Jay   male white    0         white
#> 2859   Lakisha female black    0 black, female
#> 2860    Latoya female black    0 black, female
#> 2861   Matthew   male white    0         white
#> 2862  Meredith female white    0         white
#> 2863     Sarah female white    0         white
#> 2864    Tamika female black    0 black, female
#> 2865   Allison female white    0         white
#> 2866     Ebony female black    0 black, female
#> 2867      Jill female white    0         white
#> 2868    Keisha female black    0 black, female
#> 2869     Jamal   male black    0    black male
#> 2870  Meredith female white    0         white
#> 2871     Sarah female white    0         white
#> 2872   Tanisha female black    0 black, female
#> 2873    Carrie female white    0         white
#> 2874    Latoya female black    0 black, female
#> 2875   Allison female white    0         white
#> 2876     Hakim   male black    0    black male
#> 2877      Jill female white    0         white
#> 2878    Keisha female black    0 black, female
#> 2879   Kristen female white    0         white
#> 2880   Tanisha female black    0 black, female
#> 2881      Anne female white    0         white
#> 2882    Keisha female black    0 black, female
#> 2883     Kenya female black    1 black, female
#> 2884   Kristen female white    1         white
#> 2885   Latonya female black    0 black, female
#> 2886     Sarah female white    0         white
#> 2887     Aisha female black    0 black, female
#> 2888     Emily female white    0         white
#> 2889       Jay   male white    0         white
#> 2890   Kristen female white    0         white
#> 2891    Latoya female black    0 black, female
#> 2892   Tanisha female black    0 black, female
#> 2893      Anne female white    0         white
#> 2894    Carrie female white    1         white
#> 2895   Darnell   male black    0    black male
#> 2896    Latoya female black    1 black, female
#> 2897    Laurie female white    1         white
#> 2898   Tanisha female black    0 black, female
#> 2899      Anne female white    0         white
#> 2900   Darnell   male black    0    black male
#> 2901       Jay   male white    0         white
#> 2902   Tanisha female black    0 black, female
#> 2903    Carrie female white    0         white
#> 2904     Emily female white    1         white
#> 2905     Sarah female white    0         white
#> 2906    Tamika female black    1 black, female
#> 2907   Tanisha female black    0 black, female
#> 2908  Tremayne   male black    0    black male
#> 2909      Anne female white    0         white
#> 2910      Jill female white    0         white
#> 2911     Kenya female black    0 black, female
#> 2912   Lakisha female black    0 black, female
#> 2913   Matthew   male white    0         white
#> 2914    Tamika female black    0 black, female
#> 2915   Matthew   male white    0         white
#> 2916   Tanisha female black    0 black, female
#> 2917      Anne female white    0         white
#> 2918    Latoya female black    0 black, female
#> 2919  Meredith female white    0         white
#> 2920    Tamika female black    0 black, female
#> 2921     Aisha female black    0 black, female
#> 2922     Emily female white    0         white
#> 2923      Greg   male white    0         white
#> 2924     Hakim   male black    0    black male
#> 2925      Jill female white    0         white
#> 2926    Keisha female black    0 black, female
#> 2927     Kenya female black    0 black, female
#> 2928    Laurie female white    0         white
#> 2929     Sarah female white    0         white
#> 2930    Tamika female black    0 black, female
#> 2931    Carrie female white    0         white
#> 2932     Ebony female black    0 black, female
#> 2933     Jamal   male black    0    black male
#> 2934      Jill female white    0         white
#> 2935     Kenya female black    0 black, female
#> 2936    Latoya female black    0 black, female
#> 2937  Meredith female white    0         white
#> 2938      Todd   male white    0         white
#> 2939     Aisha female black    0 black, female
#> 2940   Allison female white    0         white
#> 2941      Brad   male white    0         white
#> 2942  Geoffrey   male white    0         white
#> 2943     Hakim   male black    0    black male
#> 2944    Latoya female black    0 black, female
#> 2945     Sarah female white    0         white
#> 2946   Tanisha female black    0 black, female
#> 2947   Allison female white    0         white
#> 2948   Allison female white    0         white
#> 2949      Anne female white    0         white
#> 2950      Brad   male white    1         white
#> 2951   Brendan   male white    1         white
#> 2952   Brendan   male white    0         white
#> 2953     Brett   male white    0         white
#> 2954     Brett   male white    0         white
#> 2955   Darnell   male black    0    black male
#> 2956     Ebony female black    0 black, female
#> 2957     Emily female white    0         white
#> 2958      Greg   male white    0         white
#> 2959     Hakim   male black    0    black male
#> 2960      Jill female white    0         white
#> 2961   Kristen female white    0         white
#> 2962   Latonya female black    0 black, female
#> 2963   Latonya female black    0 black, female
#> 2964   Latonya female black    0 black, female
#> 2965    Latoya female black    0 black, female
#> 2966    Laurie female white    0         white
#> 2967  Meredith female white    0         white
#> 2968      Neil   male white    0         white
#> 2969   Rasheed   male black    0    black male
#> 2970   Rasheed   male black    0    black male
#> 2971     Sarah female white    0         white
#> 2972    Tamika female black    1 black, female
#> 2973    Tamika female black    0 black, female
#> 2974    Tamika female black    0 black, female
#> 2975    Tamika female black    0 black, female
#> 2976    Tamika female black    0 black, female
#> 2977    Tamika female black    0 black, female
#> 2978      Todd   male white    0         white
#> 2979      Todd   male white    0         white
#> 2980  Tremayne   male black    0    black male
#> 2981    Tyrone   male black    0    black male
#> 2982    Tyrone   male black    0    black male
#> 2983     Ebony female black    0 black, female
#> 2984   Kristen female white    0         white
#> 2985    Latoya female black    0 black, female
#> 2986     Sarah female white    0         white
#> 2987      Anne female white    0         white
#> 2988     Emily female white    0         white
#> 2989     Kenya female black    0 black, female
#> 2990    Latoya female black    0 black, female
#> 2991   Allison female white    0         white
#> 2992     Ebony female black    0 black, female
#> 2993    Keisha female black    0 black, female
#> 2994   Kristen female white    0         white
#> 2995      Brad   male white    0         white
#> 2996   Brendan   male white    0         white
#> 2997     Brett   male white    0         white
#> 2998    Carrie female white    0         white
#> 2999   Darnell   male black    0    black male
#> 3000     Ebony female black    0 black, female
#> 3001      Greg   male white    0         white
#> 3002      Greg   male white    0         white
#> 3003     Jamal   male black    0    black male
#> 3004    Kareem   male black    0    black male
#> 3005    Keisha female black    0 black, female
#> 3006   Lakisha female black    0 black, female
#> 3007    Latoya female black    0 black, female
#> 3008    Latoya female black    0 black, female
#> 3009    Latoya female black    1 black, female
#> 3010    Laurie female white    0         white
#> 3011      Neil   male white    0         white
#> 3012      Neil   male white    0         white
#> 3013      Neil   male white    0         white
#> 3014   Rasheed   male black    0    black male
#> 3015     Sarah female white    0         white
#> 3016     Sarah female white    0         white
#> 3017   Tanisha female black    0 black, female
#> 3018  Tremayne   male black    0    black male
#> 3019    Carrie female white    0         white
#> 3020     Emily female white    1         white
#> 3021   Latonya female black    1 black, female
#> 3022   Tanisha female black    0 black, female
#> 3023   Allison female white    0         white
#> 3024     Kenya female black    0 black, female
#> 3025   Kristen female white    0         white
#> 3026   Latonya female black    0 black, female
#> 3027   Allison female white    0         white
#> 3028    Carrie female white    0         white
#> 3029    Keisha female black    0 black, female
#> 3030   Tanisha female black    0 black, female
#> 3031      Anne female white    0         white
#> 3032    Carrie female white    0         white
#> 3033   Lakisha female black    0 black, female
#> 3034   Tanisha female black    0 black, female
#> 3035      Anne female white    0         white
#> 3036     Ebony female black    0 black, female
#> 3037     Kenya female black    0 black, female
#> 3038  Meredith female white    0         white
#> 3039     Emily female white    0         white
#> 3040  Geoffrey   male white    0         white
#> 3041   Rasheed   male black    0    black male
#> 3042  Tremayne   male black    0    black male
#> 3043     Ebony female black    1 black, female
#> 3044      Jill female white    0         white
#> 3045   Kristen female white    0         white
#> 3046   Latonya female black    0 black, female
#> 3047      Anne female white    0         white
#> 3048    Keisha female black    0 black, female
#> 3049     Sarah female white    0         white
#> 3050   Tanisha female black    0 black, female
#> 3051     Aisha female black    0 black, female
#> 3052      Brad   male white    0         white
#> 3053     Brett   male white    0         white
#> 3054    Carrie female white    0         white
#> 3055    Carrie female white    0         white
#> 3056     Ebony female black    0 black, female
#> 3057  Geoffrey   male white    0         white
#> 3058    Kareem   male black    0    black male
#> 3059    Kareem   male black    0    black male
#> 3060    Keisha female black    0 black, female
#> 3061      Neil   male white    0         white
#> 3062  Tremayne   male black    0    black male
#> 3063      Jill female white    0         white
#> 3064     Kenya female black    0 black, female
#> 3065   Latonya female black    0 black, female
#> 3066    Laurie female white    0         white
#> 3067    Carrie female white    0         white
#> 3068      Jill female white    0         white
#> 3069    Keisha female black    0 black, female
#> 3070     Kenya female black    0 black, female
#> 3071   Allison female white    0         white
#> 3072     Emily female white    0         white
#> 3073    Latoya female black    0 black, female
#> 3074   Tanisha female black    0 black, female
#> 3075      Anne female white    0         white
#> 3076    Carrie female white    0         white
#> 3077   Lakisha female black    0 black, female
#> 3078   Latonya female black    0 black, female
#> 3079   Allison female white    0         white
#> 3080     Ebony female black    0 black, female
#> 3081  Meredith female white    0         white
#> 3082    Tamika female black    0 black, female
#> 3083      Jill female white    0         white
#> 3084   Kristen female white    0         white
#> 3085    Latoya female black    0 black, female
#> 3086    Tamika female black    0 black, female
#> 3087     Aisha female black    0 black, female
#> 3088   Lakisha female black    0 black, female
#> 3089    Laurie female white    0         white
#> 3090  Meredith female white    0         white
#> 3091     Emily female white    0         white
#> 3092   Lakisha female black    0 black, female
#> 3093     Sarah female white    0         white
#> 3094   Tanisha female black    0 black, female
#> 3095     Emily female white    0         white
#> 3096     Hakim   male black    1    black male
#> 3097    Laurie female white    0         white
#> 3098    Tyrone   male black    0    black male
#> 3099      Anne female white    0         white
#> 3100     Emily female white    0         white
#> 3101    Tamika female black    0 black, female
#> 3102    Tamika female black    0 black, female
#> 3103     Aisha female black    0 black, female
#> 3104   Allison female white    0         white
#> 3105    Carrie female white    0         white
#> 3106     Emily female white    0         white
#> 3107     Emily female white    0         white
#> 3108  Geoffrey   male white    0         white
#> 3109      Greg   male white    0         white
#> 3110     Hakim   male black    0    black male
#> 3111     Hakim   male black    0    black male
#> 3112       Jay   male white    0         white
#> 3113    Keisha female black    0 black, female
#> 3114   Lakisha female black    0 black, female
#> 3115    Latoya female black    0 black, female
#> 3116    Laurie female white    0         white
#> 3117   Matthew   male white    0         white
#> 3118   Rasheed   male black    0    black male
#> 3119   Tanisha female black    0 black, female
#> 3120      Todd   male white    0         white
#> 3121  Tremayne   male black    0    black male
#> 3122    Tyrone   male black    0    black male
#> 3123   Kristen female white    0         white
#> 3124   Lakisha female black    0 black, female
#> 3125   Matthew   male white    0         white
#> 3126  Tremayne   male black    0    black male
#> 3127   Allison female white    0         white
#> 3128    Carrie female white    0         white
#> 3129     Kenya female black    0 black, female
#> 3130    Latoya female black    0 black, female
#> 3131      Brad   male white    0         white
#> 3132   Brendan   male white    0         white
#> 3133     Brett   male white    0         white
#> 3134    Carrie female white    0         white
#> 3135   Darnell   male black    0    black male
#> 3136  Geoffrey   male white    0         white
#> 3137      Greg   male white    0         white
#> 3138     Jamal   male black    0    black male
#> 3139  Jermaine   male black    0    black male
#> 3140    Kareem   male black    0    black male
#> 3141    Keisha female black    0 black, female
#> 3142   Kristen female white    0         white
#> 3143   Kristen female white    0         white
#> 3144   Latonya female black    0 black, female
#> 3145   Latonya female black    0 black, female
#> 3146    Latoya female black    0 black, female
#> 3147    Laurie female white    0         white
#> 3148     Leroy   male black    0    black male
#> 3149      Neil   male white    0         white
#> 3150      Neil   male white    0         white
#> 3151     Sarah female white    0         white
#> 3152    Tamika female black    0 black, female
#> 3153  Tremayne   male black    0    black male
#> 3154    Tyrone   male black    0    black male
#> 3155     Aisha female black    0 black, female
#> 3156   Allison female white    0         white
#> 3157      Jill female white    1         white
#> 3158    Tamika female black    0 black, female
#> 3159     Aisha female black    0 black, female
#> 3160   Allison female white    0         white
#> 3161     Ebony female black    0 black, female
#> 3162     Ebony female black    0 black, female
#> 3163     Emily female white    0         white
#> 3164      Greg   male white    0         white
#> 3165     Hakim   male black    0    black male
#> 3166      Jill female white    0         white
#> 3167    Kareem   male black    0    black male
#> 3168    Keisha female black    0 black, female
#> 3169   Lakisha female black    1 black, female
#> 3170    Laurie female white    0         white
#> 3171    Laurie female white    0         white
#> 3172   Matthew   male white    1         white
#> 3173  Meredith female white    1         white
#> 3174      Neil   male white    0         white
#> 3175   Rasheed   male black    0    black male
#> 3176     Sarah female white    0         white
#> 3177   Tanisha female black    0 black, female
#> 3178    Tyrone   male black    0    black male
#> 3179     Ebony female black    1 black, female
#> 3180      Jill female white    0         white
#> 3181   Matthew   male white    0         white
#> 3182  Tremayne   male black    0    black male
#> 3183    Carrie female white    0         white
#> 3184     Ebony female black    0 black, female
#> 3185      Jill female white    0         white
#> 3186    Tamika female black    0 black, female
#> 3187      Brad   male white    0         white
#> 3188      Brad   male white    0         white
#> 3189  Geoffrey   male white    0         white
#> 3190    Kareem   male black    0    black male
#> 3191    Keisha female black    0 black, female
#> 3192    Keisha female black    0 black, female
#> 3193     Kenya female black    0 black, female
#> 3194   Kristen female white    0         white
#> 3195   Lakisha female black    0 black, female
#> 3196   Lakisha female black    0 black, female
#> 3197    Laurie female white    0         white
#> 3198     Leroy   male black    1    black male
#> 3199  Meredith female white    0         white
#> 3200      Neil   male white    0         white
#> 3201      Neil   male white    0         white
#> 3202   Rasheed   male black    0    black male
#> 3203   Rasheed   male black    0    black male
#> 3204   Rasheed   male black    0    black male
#> 3205     Sarah female white    0         white
#> 3206      Todd   male white    0         white
#> 3207     Aisha female black    0 black, female
#> 3208   Allison female white    0         white
#> 3209      Anne female white    0         white
#> 3210      Brad   male white    0         white
#> 3211    Carrie female white    0         white
#> 3212    Kareem   male black    0    black male
#> 3213    Keisha female black    0 black, female
#> 3214     Kenya female black    0 black, female
#> 3215   Kristen female white    0         white
#> 3216   Lakisha female black    0 black, female
#> 3217    Latoya female black    0 black, female
#> 3218   Matthew   male white    0         white
#> 3219  Meredith female white    0         white
#> 3220      Neil   male white    0         white
#> 3221  Tremayne   male black    0    black male
#> 3222    Tyrone   male black    0    black male
#> 3223   Brendan   male white    0         white
#> 3224    Carrie female white    0         white
#> 3225  Geoffrey   male white    0         white
#> 3226     Jamal   male black    0    black male
#> 3227      Jill female white    0         white
#> 3228    Kareem   male black    0    black male
#> 3229   Kristen female white    0         white
#> 3230    Latoya female black    0 black, female
#> 3231    Latoya female black    0 black, female
#> 3232     Leroy   male black    0    black male
#> 3233   Matthew   male white    0         white
#> 3234   Tanisha female black    0 black, female
#> 3235   Brendan   male white    0         white
#> 3236      Greg   male white    0         white
#> 3237    Kareem   male black    0    black male
#> 3238     Kenya female black    0 black, female
#> 3239   Latonya female black    0 black, female
#> 3240    Laurie female white    0         white
#> 3241  Meredith female white    0         white
#> 3242  Tremayne   male black    0    black male
#> 3243     Emily female white    0         white
#> 3244     Hakim   male black    0    black male
#> 3245    Latoya female black    0 black, female
#> 3246      Todd   male white    0         white
#> 3247     Aisha female black    0 black, female
#> 3248     Ebony female black    1 black, female
#> 3249  Geoffrey   male white    1         white
#> 3250     Jamal   male black    0    black male
#> 3251  Jermaine   male black    0    black male
#> 3252   Lakisha female black    0 black, female
#> 3253  Meredith female white    0         white
#> 3254  Meredith female white    0         white
#> 3255      Neil   male white    0         white
#> 3256     Sarah female white    0         white
#> 3257     Sarah female white    1         white
#> 3258    Tyrone   male black    1    black male
#> 3259  Jermaine   male black    0    black male
#> 3260      Jill female white    0         white
#> 3261   Kristen female white    1         white
#> 3262     Leroy   male black    0    black male
#> 3263   Allison female white    0         white
#> 3264   Latonya female black    0 black, female
#> 3265     Aisha female black    0 black, female
#> 3266   Allison female white    0         white
#> 3267     Brett   male white    0         white
#> 3268    Carrie female white    0         white
#> 3269     Kenya female black    0 black, female
#> 3270    Latoya female black    0 black, female
#> 3271     Aisha female black    0 black, female
#> 3272      Anne female white    0         white
#> 3273      Jill female white    0         white
#> 3274   Tanisha female black    0 black, female
#> 3275      Brad   male white    1         white
#> 3276     Emily female white    1         white
#> 3277  Jermaine   male black    1    black male
#> 3278   Lakisha female black    1 black, female
#> 3279   Allison female white    0         white
#> 3280     Leroy   male black    1    black male
#> 3281   Allison female white    0         white
#> 3282    Carrie female white    0         white
#> 3283       Jay   male white    0         white
#> 3284    Keisha female black    0 black, female
#> 3285   Lakisha female black    0 black, female
#> 3286   Latonya female black    0 black, female
#> 3287  Meredith female white    0         white
#> 3288    Tyrone   male black    0    black male
#> 3289      Anne female white    0         white
#> 3290    Keisha female black    0 black, female
#> 3291  Meredith female white    0         white
#> 3292   Tanisha female black    0 black, female
#> 3293      Anne female white    0         white
#> 3294   Darnell   male black    0    black male
#> 3295     Ebony female black    0 black, female
#> 3296     Emily female white    0         white
#> 3297     Sarah female white    0         white
#> 3298   Tanisha female black    0 black, female
#> 3299   Allison female white    0         white
#> 3300     Emily female white    1         white
#> 3301   Latonya female black    1 black, female
#> 3302    Latoya female black    0 black, female
#> 3303   Allison female white    0         white
#> 3304      Anne female white    0         white
#> 3305     Jamal   male black    0    black male
#> 3306  Jermaine   male black    0    black male
#> 3307     Emily female white    0         white
#> 3308   Lakisha female black    0 black, female
#> 3309    Latoya female black    0 black, female
#> 3310  Meredith female white    0         white
#> 3311   Allison female white    1         white
#> 3312     Brett   male white    0         white
#> 3313     Kenya female black    0 black, female
#> 3314    Latoya female black    0 black, female
#> 3315     Leroy   male black    0    black male
#> 3316      Todd   male white    0         white
#> 3317      Anne female white    0         white
#> 3318      Anne female white    0         white
#> 3319     Ebony female black    0 black, female
#> 3320   Tanisha female black    0 black, female
#> 3321     Aisha female black    0 black, female
#> 3322   Brendan   male white    0         white
#> 3323     Brett   male white    0         white
#> 3324    Carrie female white    0         white
#> 3325   Darnell   male black    0    black male
#> 3326     Ebony female black    0 black, female
#> 3327     Ebony female black    0 black, female
#> 3328   Kristen female white    0         white
#> 3329     Aisha female black    0 black, female
#> 3330      Greg   male white    0         white
#> 3331      Jill female white    0         white
#> 3332     Kenya female black    0 black, female
#> 3333  Meredith female white    0         white
#> 3334   Tanisha female black    0 black, female
#> 3335     Jamal   male black    0    black male
#> 3336      Neil   male white    0         white
#> 3337   Brendan   male white    0         white
#> 3338     Jamal   male black    0    black male
#> 3339      Todd   male white    0         white
#> 3340    Tyrone   male black    0    black male
#> 3341      Todd   male white    1         white
#> 3342    Tyrone   male black    1    black male
#> 3343     Emily female white    0         white
#> 3344     Emily female white    0         white
#> 3345  Jermaine   male black    0    black male
#> 3346     Kenya female black    0 black, female
#> 3347   Lakisha female black    0 black, female
#> 3348     Leroy   male black    0    black male
#> 3349  Meredith female white    1         white
#> 3350     Sarah female white    0         white
#> 3351     Ebony female black    0 black, female
#> 3352     Emily female white    0         white
#> 3353      Jill female white    0         white
#> 3354      Jill female white    0         white
#> 3355    Keisha female black    0 black, female
#> 3356    Keisha female black    0 black, female
#> 3357    Latoya female black    0 black, female
#> 3358  Meredith female white    0         white
#> 3359     Aisha female black    1 black, female
#> 3360   Darnell   male black    1    black male
#> 3361     Ebony female black    0 black, female
#> 3362       Jay   male white    0         white
#> 3363      Jill female white    0         white
#> 3364    Keisha female black    0 black, female
#> 3365  Meredith female white    1         white
#> 3366  Meredith female white    0         white
#> 3367     Aisha female black    0 black, female
#> 3368    Carrie female white    0         white
#> 3369  Meredith female white    0         white
#> 3370   Tanisha female black    0 black, female
#> 3371      Brad   male white    1         white
#> 3372     Ebony female black    0 black, female
#> 3373     Emily female white    0         white
#> 3374   Kristen female white    0         white
#> 3375   Rasheed   male black    0    black male
#> 3376    Tamika female black    0 black, female
#> 3377      Jill female white    0         white
#> 3378  Tremayne   male black    0    black male
#> 3379     Sarah female white    0         white
#> 3380    Tamika female black    0 black, female
#> 3381   Allison female white    0         white
#> 3382      Anne female white    1         white
#> 3383    Carrie female white    0         white
#> 3384     Ebony female black    1 black, female
#> 3385   Latonya female black    0 black, female
#> 3386     Leroy   male black    1    black male
#> 3387      Anne female white    0         white
#> 3388     Jamal   male black    0    black male
#> 3389    Latoya female black    0 black, female
#> 3390    Laurie female white    0         white
#> 3391     Sarah female white    0         white
#> 3392   Tanisha female black    0 black, female
#> 3393   Allison female white    0         white
#> 3394    Keisha female black    0 black, female
#> 3395   Lakisha female black    0 black, female
#> 3396    Latoya female black    1 black, female
#> 3397    Laurie female white    1         white
#> 3398  Meredith female white    0         white
#> 3399     Aisha female black    0 black, female
#> 3400   Allison female white    0         white
#> 3401     Emily female white    0         white
#> 3402    Latoya female black    0 black, female
#> 3403    Laurie female white    0         white
#> 3404    Tamika female black    0 black, female
#> 3405      Anne female white    0         white
#> 3406     Brett   male white    0         white
#> 3407  Jermaine   male black    0    black male
#> 3408   Latonya female black    0 black, female
#> 3409   Allison female white    0         white
#> 3410    Keisha female black    0 black, female
#> 3411    Laurie female white    0         white
#> 3412     Leroy   male black    0    black male
#> 3413   Tanisha female black    0 black, female
#> 3414      Todd   male white    0         white
#> 3415    Carrie female white    0         white
#> 3416     Hakim   male black    0    black male
#> 3417     Aisha female black    0 black, female
#> 3418   Allison female white    0         white
#> 3419      Jill female white    0         white
#> 3420   Latonya female black    0 black, female
#> 3421   Darnell   male black    0    black male
#> 3422     Emily female white    0         white
#> 3423   Kristen female white    0         white
#> 3424   Latonya female black    0 black, female
#> 3425    Laurie female white    0         white
#> 3426    Tamika female black    0 black, female
#> 3427     Aisha female black    0 black, female
#> 3428   Allison female white    0         white
#> 3429    Carrie female white    0         white
#> 3430    Tamika female black    0 black, female
#> 3431     Ebony female black    0 black, female
#> 3432  Meredith female white    0         white
#> 3433      Neil   male white    0         white
#> 3434  Tremayne   male black    0    black male
#> 3435     Aisha female black    0 black, female
#> 3436   Allison female white    0         white
#> 3437     Ebony female black    0 black, female
#> 3438     Hakim   male black    0    black male
#> 3439       Jay   male white    1         white
#> 3440      Jill female white    0         white
#> 3441   Lakisha female black    0 black, female
#> 3442      Neil   male white    0         white
#> 3443   Allison female white    0         white
#> 3444   Brendan   male white    0         white
#> 3445   Darnell   male black    0    black male
#> 3446     Ebony female black    0 black, female
#> 3447  Geoffrey   male white    0         white
#> 3448  Geoffrey   male white    0         white
#> 3449  Geoffrey   male white    0         white
#> 3450      Greg   male white    0         white
#> 3451       Jay   male white    0         white
#> 3452  Jermaine   male black    0    black male
#> 3453   Lakisha female black    0 black, female
#> 3454   Latonya female black    0 black, female
#> 3455   Matthew   male white    0         white
#> 3456      Neil   male white    0         white
#> 3457   Rasheed   male black    0    black male
#> 3458   Rasheed   male black    0    black male
#> 3459   Rasheed   male black    0    black male
#> 3460     Sarah female white    0         white
#> 3461     Sarah female white    0         white
#> 3462     Sarah female white    0         white
#> 3463    Tamika female black    0 black, female
#> 3464   Tanisha female black    0 black, female
#> 3465  Tremayne   male black    0    black male
#> 3466  Tremayne   male black    0    black male
#> 3467   Brendan   male white    0         white
#> 3468   Brendan   male white    0         white
#> 3469      Greg   male white    0         white
#> 3470     Jamal   male black    0    black male
#> 3471  Jermaine   male black    0    black male
#> 3472    Kareem   male black    0    black male
#> 3473    Keisha female black    0 black, female
#> 3474    Laurie female white    0         white
#> 3475    Laurie female white    0         white
#> 3476     Leroy   male black    0    black male
#> 3477     Leroy   male black    0    black male
#> 3478      Neil   male white    0         white
#> 3479     Sarah female white    0         white
#> 3480    Tamika female black    0 black, female
#> 3481   Tanisha female black    0 black, female
#> 3482      Todd   male white    0         white
#> 3483     Ebony female black    0 black, female
#> 3484      Greg   male white    0         white
#> 3485      Greg   male white    1         white
#> 3486     Hakim   male black    0    black male
#> 3487     Hakim   male black    0    black male
#> 3488    Kareem   male black    0    black male
#> 3489    Kareem   male black    0    black male
#> 3490     Kenya female black    0 black, female
#> 3491   Kristen female white    0         white
#> 3492   Kristen female white    1         white
#> 3493   Lakisha female black    0 black, female
#> 3494    Latoya female black    0 black, female
#> 3495    Laurie female white    0         white
#> 3496  Meredith female white    0         white
#> 3497      Neil   male white    0         white
#> 3498      Neil   male white    0         white
#> 3499    Tamika female black    0 black, female
#> 3500      Todd   male white    0         white
#> 3501      Todd   male white    0         white
#> 3502    Tyrone   male black    0    black male
#> 3503     Jamal   male black    0    black male
#> 3504    Kareem   male black    0    black male
#> 3505    Laurie female white    0         white
#> 3506      Todd   male white    0         white
#> 3507     Aisha female black    0 black, female
#> 3508      Anne female white    0         white
#> 3509   Brendan   male white    0         white
#> 3510     Brett   male white    0         white
#> 3511     Emily female white    0         white
#> 3512      Greg   male white    0         white
#> 3513     Jamal   male black    0    black male
#> 3514  Jermaine   male black    0    black male
#> 3515   Latonya female black    0 black, female
#> 3516   Latonya female black    0 black, female
#> 3517     Leroy   male black    0    black male
#> 3518  Meredith female white    0         white
#> 3519   Rasheed   male black    0    black male
#> 3520   Rasheed   male black    0    black male
#> 3521     Sarah female white    0         white
#> 3522      Todd   male white    0         white
#> 3523      Brad   male white    0         white
#> 3524     Ebony female black    0 black, female
#> 3525      Greg   male white    0         white
#> 3526     Hakim   male black    0    black male
#> 3527     Emily female white    0         white
#> 3528     Kenya female black    0 black, female
#> 3529     Sarah female white    0         white
#> 3530    Tamika female black    0 black, female
#> 3531      Brad   male white    0         white
#> 3532    Carrie female white    0         white
#> 3533     Ebony female black    0 black, female
#> 3534  Geoffrey   male white    0         white
#> 3535  Geoffrey   male white    0         white
#> 3536     Jamal   male black    0    black male
#> 3537    Kareem   male black    0    black male
#> 3538   Kristen female white    0         white
#> 3539   Lakisha female black    0 black, female
#> 3540     Leroy   male black    0    black male
#> 3541      Neil   male white    0         white
#> 3542    Tamika female black    0 black, female
#> 3543     Aisha female black    0 black, female
#> 3544   Allison female white    0         white
#> 3545      Anne female white    0         white
#> 3546      Anne female white    0         white
#> 3547      Brad   male white    0         white
#> 3548   Brendan   male white    0         white
#> 3549     Brett   male white    0         white
#> 3550  Jermaine   male black    0    black male
#> 3551   Lakisha female black    0 black, female
#> 3552   Latonya female black    0 black, female
#> 3553   Latonya female black    0 black, female
#> 3554    Laurie female white    0         white
#> 3555     Leroy   male black    0    black male
#> 3556  Meredith female white    0         white
#> 3557   Rasheed   male black    0    black male
#> 3558  Tremayne   male black    0    black male
#> 3559   Allison female white    0         white
#> 3560      Anne female white    0         white
#> 3561  Geoffrey   male white    0         white
#> 3562     Jamal   male black    0    black male
#> 3563    Kareem   male black    0    black male
#> 3564   Kristen female white    0         white
#> 3565    Tamika female black    0 black, female
#> 3566   Tanisha female black    0 black, female
#> 3567      Anne female white    0         white
#> 3568     Emily female white    0         white
#> 3569     Hakim   male black    0    black male
#> 3570      Jill female white    0         white
#> 3571     Kenya female black    0 black, female
#> 3572   Kristen female white    0         white
#> 3573   Latonya female black    0 black, female
#> 3574   Matthew   male white    0         white
#> 3575  Meredith female white    0         white
#> 3576   Rasheed   male black    0    black male
#> 3577  Tremayne   male black    0    black male
#> 3578  Tremayne   male black    0    black male
#> 3579  Jermaine   male black    0    black male
#> 3580    Laurie female white    1         white
#> 3581   Matthew   male white    0         white
#> 3582   Rasheed   male black    0    black male
#> 3583     Brett   male white    0         white
#> 3584     Emily female white    0         white
#> 3585  Geoffrey   male white    0         white
#> 3586     Jamal   male black    0    black male
#> 3587     Jamal   male black    1    black male
#> 3588     Jamal   male black    0    black male
#> 3589    Kareem   male black    0    black male
#> 3590   Latonya female black    0 black, female
#> 3591    Laurie female white    0         white
#> 3592      Neil   male white    1         white
#> 3593     Sarah female white    0         white
#> 3594    Tyrone   male black    0    black male
#> 3595     Ebony female black    0 black, female
#> 3596     Jamal   male black    0    black male
#> 3597     Sarah female white    0         white
#> 3598      Todd   male white    0         white
#> 3599     Ebony female black    1 black, female
#> 3600      Jill female white    1         white
#> 3601   Kristen female white    1         white
#> 3602   Tanisha female black    0 black, female
#> 3603    Carrie female white    0         white
#> 3604   Darnell   male black    0    black male
#> 3605  Geoffrey   male white    0         white
#> 3606  Geoffrey   male white    0         white
#> 3607  Jermaine   male black    0    black male
#> 3608   Latonya female black    0 black, female
#> 3609   Matthew   male white    0         white
#> 3610   Tanisha female black    0 black, female
#> 3611   Allison female white    0         white
#> 3612   Darnell   male black    0    black male
#> 3613       Jay   male white    1         white
#> 3614    Tyrone   male black    0    black male
#> 3615   Allison female white    0         white
#> 3616      Anne female white    0         white
#> 3617      Anne female white    0         white
#> 3618     Ebony female black    0 black, female
#> 3619   Lakisha female black    0 black, female
#> 3620     Sarah female white    0         white
#> 3621   Tanisha female black    0 black, female
#> 3622   Tanisha female black    0 black, female
#> 3623   Brendan   male white    0         white
#> 3624     Ebony female black    0 black, female
#> 3625      Greg   male white    0         white
#> 3626    Latoya female black    1 black, female
#> 3627      Brad   male white    1         white
#> 3628     Ebony female black    0 black, female
#> 3629      Neil   male white    1         white
#> 3630   Rasheed   male black    1    black male
#> 3631    Carrie female white    1         white
#> 3632    Latoya female black    1 black, female
#> 3633      Anne female white    0         white
#> 3634    Carrie female white    1         white
#> 3635     Ebony female black    0 black, female
#> 3636     Hakim   male black    0    black male
#> 3637    Keisha female black    1 black, female
#> 3638     Kenya female black    0 black, female
#> 3639      Neil   male white    0         white
#> 3640      Todd   male white    0         white
#> 3641   Kristen female white    0         white
#> 3642     Sarah female white    0         white
#> 3643    Tamika female black    0 black, female
#> 3644   Tanisha female black    0 black, female
#> 3645   Allison female white    1         white
#> 3646     Ebony female black    1 black, female
#> 3647    Latoya female black    1 black, female
#> 3648    Laurie female white    0         white
#> 3649   Darnell   male black    0    black male
#> 3650       Jay   male white    0         white
#> 3651   Brendan   male white    0         white
#> 3652   Darnell   male black    0    black male
#> 3653  Geoffrey   male white    0         white
#> 3654    Latoya female black    0 black, female
#> 3655     Aisha female black    0 black, female
#> 3656   Allison female white    0         white
#> 3657       Jay   male white    0         white
#> 3658     Kenya female black    0 black, female
#> 3659   Kristen female white    0         white
#> 3660   Lakisha female black    0 black, female
#> 3661  Meredith female white    0         white
#> 3662    Tyrone   male black    0    black male
#> 3663      Anne female white    0         white
#> 3664    Carrie female white    0         white
#> 3665     Kenya female black    0 black, female
#> 3666    Latoya female black    0 black, female
#> 3667    Carrie female white    0         white
#> 3668      Greg   male white    0         white
#> 3669       Jay   male white    0         white
#> 3670     Kenya female black    0 black, female
#> 3671    Latoya female black    0 black, female
#> 3672  Meredith female white    0         white
#> 3673   Rasheed   male black    0    black male
#> 3674   Tanisha female black    0 black, female
#> 3675      Anne female white    0         white
#> 3676    Latoya female black    0 black, female
#> 3677     Sarah female white    0         white
#> 3678   Tanisha female black    0 black, female
#> 3679    Carrie female white    0         white
#> 3680     Hakim   male black    0    black male
#> 3681     Emily female white    0         white
#> 3682   Lakisha female black    0 black, female
#> 3683    Latoya female black    0 black, female
#> 3684     Sarah female white    0         white
#> 3685   Allison female white    0         white
#> 3686     Ebony female black    0 black, female
#> 3687   Kristen female white    0         white
#> 3688    Tamika female black    0 black, female
#> 3689   Brendan   male white    0         white
#> 3690    Latoya female black    0 black, female
#> 3691   Brendan   male white    0         white
#> 3692     Ebony female black    1 black, female
#> 3693     Emily female white    1         white
#> 3694   Latonya female black    1 black, female
#> 3695    Latoya female black    0 black, female
#> 3696    Laurie female white    1         white
#> 3697     Aisha female black    1 black, female
#> 3698    Carrie female white    0         white
#> 3699  Geoffrey   male white    0         white
#> 3700  Jermaine   male black    0    black male
#> 3701    Keisha female black    0 black, female
#> 3702   Kristen female white    1         white
#> 3703   Latonya female black    0 black, female
#> 3704    Laurie female white    0         white
#> 3705   Lakisha female black    0 black, female
#> 3706     Sarah female white    0         white
#> 3707     Emily female white    0         white
#> 3708     Jamal   male black    0    black male
#> 3709      Brad   male white    0         white
#> 3710    Tamika female black    0 black, female
#> 3711   Allison female white    0         white
#> 3712   Latonya female black    0 black, female
#> 3713  Meredith female white    0         white
#> 3714    Tamika female black    0 black, female
#> 3715     Ebony female black    0 black, female
#> 3716  Geoffrey   male white    1         white
#> 3717    Keisha female black    0 black, female
#> 3718    Laurie female white    0         white
#> 3719  Meredith female white    0         white
#> 3720   Tanisha female black    0 black, female
#> 3721     Aisha female black    0 black, female
#> 3722      Brad   male white    0         white
#> 3723     Leroy   male black    0    black male
#> 3724      Neil   male white    0         white
#> 3725   Lakisha female black    0 black, female
#> 3726    Latoya female black    0 black, female
#> 3727  Meredith female white    0         white
#> 3728     Sarah female white    0         white
#> 3729   Kristen female white    0         white
#> 3730   Latonya female black    0 black, female
#> 3731    Laurie female white    0         white
#> 3732     Sarah female white    0         white
#> 3733    Tamika female black    0 black, female
#> 3734   Tanisha female black    0 black, female
#> 3735   Allison female white    0         white
#> 3736     Kenya female black    0 black, female
#> 3737  Meredith female white    0         white
#> 3738    Tamika female black    0 black, female
#> 3739      Anne female white    0         white
#> 3740    Keisha female black    0 black, female
#> 3741   Kristen female white    0         white
#> 3742   Lakisha female black    0 black, female
#> 3743     Aisha female black    0 black, female
#> 3744   Allison female white    0         white
#> 3745    Carrie female white    0         white
#> 3746   Darnell   male black    0    black male
#> 3747      Jill female white    0         white
#> 3748    Keisha female black    0 black, female
#> 3749   Allison female white    0         white
#> 3750     Brett   male white    0         white
#> 3751     Emily female white    0         white
#> 3752   Latonya female black    0 black, female
#> 3753    Latoya female black    0 black, female
#> 3754    Tyrone   male black    0    black male
#> 3755  Geoffrey   male white    0         white
#> 3756      Jill female white    0         white
#> 3757     Kenya female black    1 black, female
#> 3758   Latonya female black    0 black, female
#> 3759    Laurie female white    0         white
#> 3760   Rasheed   male black    0    black male
#> 3761      Anne female white    0         white
#> 3762     Ebony female black    0 black, female
#> 3763     Emily female white    0         white
#> 3764   Tanisha female black    0 black, female
#> 3765   Allison female white    0         white
#> 3766      Anne female white    0         white
#> 3767     Ebony female black    0 black, female
#> 3768     Emily female white    0         white
#> 3769     Kenya female black    0 black, female
#> 3770   Tanisha female black    0 black, female
#> 3771   Allison female white    0         white
#> 3772     Jamal   male black    0    black male
#> 3773       Jay   male white    1         white
#> 3774    Keisha female black    0 black, female
#> 3775      Brad   male white    0         white
#> 3776    Kareem   male black    0    black male
#> 3777    Carrie female white    0         white
#> 3778     Ebony female black    0 black, female
#> 3779   Latonya female black    0 black, female
#> 3780  Meredith female white    0         white
#> 3781      Anne female white    0         white
#> 3782    Latoya female black    0 black, female
#> 3783  Meredith female white    0         white
#> 3784  Meredith female white    0         white
#> 3785    Tamika female black    0 black, female
#> 3786   Tanisha female black    0 black, female
#> 3787      Anne female white    0         white
#> 3788     Ebony female black    0 black, female
#> 3789   Kristen female white    0         white
#> 3790   Tanisha female black    0 black, female
#> 3791   Allison female white    1         white
#> 3792     Brett   male white    0         white
#> 3793     Ebony female black    0 black, female
#> 3794       Jay   male white    0         white
#> 3795      Jill female white    0         white
#> 3796    Kareem   male black    0    black male
#> 3797     Kenya female black    0 black, female
#> 3798   Latonya female black    0 black, female
#> 3799   Allison female white    1         white
#> 3800     Ebony female black    0 black, female
#> 3801     Emily female white    0         white
#> 3802  Geoffrey   male white    0         white
#> 3803   Latonya female black    0 black, female
#> 3804     Leroy   male black    0    black male
#> 3805      Todd   male white    0         white
#> 3806  Tremayne   male black    0    black male
#> 3807     Aisha female black    0 black, female
#> 3808     Aisha female black    1 black, female
#> 3809      Anne female white    0         white
#> 3810      Brad   male white    0         white
#> 3811      Brad   male white    1         white
#> 3812   Brendan   male white    0         white
#> 3813    Carrie female white    0         white
#> 3814    Carrie female white    0         white
#> 3815   Darnell   male black    0    black male
#> 3816     Ebony female black    0 black, female
#> 3817     Ebony female black    0 black, female
#> 3818     Hakim   male black    0    black male
#> 3819     Hakim   male black    0    black male
#> 3820       Jay   male white    0         white
#> 3821      Jill female white    0         white
#> 3822    Kareem   male black    0    black male
#> 3823    Keisha female black    0 black, female
#> 3824     Kenya female black    0 black, female
#> 3825   Kristen female white    0         white
#> 3826   Lakisha female black    0 black, female
#> 3827    Laurie female white    0         white
#> 3828   Matthew   male white    0         white
#> 3829  Meredith female white    0         white
#> 3830   Rasheed   male black    0    black male
#> 3831   Tanisha female black    0 black, female
#> 3832      Todd   male white    0         white
#> 3833      Todd   male white    0         white
#> 3834    Tyrone   male black    0    black male
#> 3835      Anne female white    0         white
#> 3836      Anne female white    0         white
#> 3837     Ebony female black    0 black, female
#> 3838      Jill female white    0         white
#> 3839     Kenya female black    0 black, female
#> 3840  Meredith female white    0         white
#> 3841  Meredith female white    0         white
#> 3842   Rasheed   male black    0    black male
#> 3843   Rasheed   male black    0    black male
#> 3844    Tamika female black    0 black, female
#> 3845      Todd   male white    0         white
#> 3846  Tremayne   male black    0    black male
#> 3847     Aisha female black    0 black, female
#> 3848      Anne female white    0         white
#> 3849   Brendan   male white    0         white
#> 3850     Leroy   male black    0    black male
#> 3851   Allison female white    0         white
#> 3852  Geoffrey   male white    0         white
#> 3853     Hakim   male black    0    black male
#> 3854   Rasheed   male black    0    black male
#> 3855      Anne female white    0         white
#> 3856     Ebony female black    0 black, female
#> 3857    Laurie female white    0         white
#> 3858   Tanisha female black    0 black, female
#> 3859     Aisha female black    0 black, female
#> 3860   Brendan   male white    0         white
#> 3861      Neil   male white    0         white
#> 3862    Tamika female black    0 black, female
#> 3863   Brendan   male white    0         white
#> 3864     Kenya female black    0 black, female
#> 3865      Neil   male white    0         white
#> 3866    Tyrone   male black    0    black male
#> 3867      Anne female white    0         white
#> 3868   Brendan   male white    0         white
#> 3869     Brett   male white    0         white
#> 3870      Greg   male white    0         white
#> 3871     Hakim   male black    0    black male
#> 3872     Jamal   male black    0    black male
#> 3873  Jermaine   male black    0    black male
#> 3874    Kareem   male black    0    black male
#> 3875   Brendan   male white    0         white
#> 3876     Jamal   male black    0    black male
#> 3877   Latonya female black    0 black, female
#> 3878   Matthew   male white    0         white
#> 3879    Carrie female white    0         white
#> 3880     Ebony female black    0 black, female
#> 3881     Emily female white    0         white
#> 3882      Jill female white    0         white
#> 3883    Tamika female black    0 black, female
#> 3884   Tanisha female black    0 black, female
#> 3885      Todd   male white    0         white
#> 3886    Tyrone   male black    0    black male
#> 3887     Aisha female black    0 black, female
#> 3888   Brendan   male white    0         white
#> 3889       Jay   male white    0         white
#> 3890   Lakisha female black    0 black, female
#> 3891     Brett   male white    0         white
#> 3892    Keisha female black    0 black, female
#> 3893    Laurie female white    0         white
#> 3894   Rasheed   male black    0    black male
#> 3895     Brett   male white    0         white
#> 3896     Hakim   male black    0    black male
#> 3897     Leroy   male black    0    black male
#> 3898      Todd   male white    0         white
#> 3899     Aisha female black    0 black, female
#> 3900     Brett   male white    0         white
#> 3901   Lakisha female black    0 black, female
#> 3902   Matthew   male white    0         white
#> 3903      Anne female white    0         white
#> 3904     Kenya female black    0 black, female
#> 3905   Lakisha female black    0 black, female
#> 3906     Sarah female white    0         white
#> 3907     Emily female white    0         white
#> 3908     Jamal   male black    0    black male
#> 3909  Jermaine   male black    0    black male
#> 3910     Sarah female white    0         white
#> 3911      Greg   male white    0         white
#> 3912     Jamal   male black    0    black male
#> 3913   Lakisha female black    0 black, female
#> 3914      Todd   male white    0         white
#> 3915    Carrie female white    0         white
#> 3916   Lakisha female black    0 black, female
#> 3917   Latonya female black    0 black, female
#> 3918  Meredith female white    1         white
#> 3919      Anne female white    0         white
#> 3920    Carrie female white    0         white
#> 3921  Jermaine   male black    0    black male
#> 3922    Keisha female black    0 black, female
#> 3923    Latoya female black    0 black, female
#> 3924  Meredith female white    0         white
#> 3925     Aisha female black    0 black, female
#> 3926    Carrie female white    0         white
#> 3927      Anne female white    0         white
#> 3928     Emily female white    0         white
#> 3929    Latoya female black    0 black, female
#> 3930    Tamika female black    0 black, female
#> 3931      Anne female white    0         white
#> 3932    Kareem   male black    0    black male
#> 3933  Meredith female white    0         white
#> 3934   Rasheed   male black    0    black male
#> 3935     Aisha female black    0 black, female
#> 3936     Aisha female black    0 black, female
#> 3937     Emily female white    0         white
#> 3938   Latonya female black    0 black, female
#> 3939    Laurie female white    0         white
#> 3940  Meredith female white    0         white
#> 3941     Aisha female black    0 black, female
#> 3942    Keisha female black    0 black, female
#> 3943    Laurie female white    0         white
#> 3944  Meredith female white    0         white
#> 3945     Aisha female black    0 black, female
#> 3946     Emily female white    0         white
#> 3947   Kristen female white    0         white
#> 3948   Tanisha female black    0 black, female
#> 3949   Allison female white    0         white
#> 3950     Ebony female black    0 black, female
#> 3951      Greg   male white    0         white
#> 3952   Lakisha female black    0 black, female
#> 3953    Carrie female white    0         white
#> 3954     Ebony female black    1 black, female
#> 3955    Latoya female black    0 black, female
#> 3956     Sarah female white    0         white
#> 3957   Kristen female white    0         white
#> 3958    Laurie female white    0         white
#> 3959    Tamika female black    0 black, female
#> 3960   Tanisha female black    0 black, female
#> 3961     Aisha female black    0 black, female
#> 3962   Allison female white    0         white
#> 3963    Carrie female white    0         white
#> 3964   Darnell   male black    0    black male
#> 3965     Emily female white    0         white
#> 3966    Keisha female black    0 black, female
#> 3967    Laurie female white    0         white
#> 3968    Tamika female black    0 black, female
#> 3969       Jay   male white    0         white
#> 3970   Latonya female black    0 black, female
#> 3971     Aisha female black    0 black, female
#> 3972   Allison female white    0         white
#> 3973      Jill female white    0         white
#> 3974   Lakisha female black    0 black, female
#> 3975   Latonya female black    0 black, female
#> 3976    Laurie female white    0         white
#> 3977     Sarah female white    0         white
#> 3978   Tanisha female black    0 black, female
#> 3979      Anne female white    0         white
#> 3980   Latonya female black    0 black, female
#> 3981  Meredith female white    0         white
#> 3982    Tamika female black    0 black, female
#> 3983   Brendan   male white    0         white
#> 3984     Jamal   male black    0    black male
#> 3985   Matthew   male white    0         white
#> 3986  Tremayne   male black    0    black male
#> 3987   Allison female white    0         white
#> 3988    Latoya female black    0 black, female
#> 3989      Neil   male white    0         white
#> 3990    Tyrone   male black    0    black male
#> 3991   Brendan   male white    0         white
#> 3992     Ebony female black    0 black, female
#> 3993     Sarah female white    0         white
#> 3994   Tanisha female black    0 black, female
#> 3995      Anne female white    0         white
#> 3996   Brendan   male white    0         white
#> 3997     Ebony female black    0 black, female
#> 3998     Hakim   male black    0    black male
#> 3999   Kristen female white    0         white
#> 4000    Tamika female black    0 black, female
#> 4001    Carrie female white    0         white
#> 4002  Jermaine   male black    0    black male
#> 4003      Jill female white    0         white
#> 4004    Keisha female black    0 black, female
#> 4005    Latoya female black    0 black, female
#> 4006   Matthew   male white    0         white
#> 4007    Carrie female white    1         white
#> 4008     Kenya female black    1 black, female
#> 4009     Aisha female black    0 black, female
#> 4010    Laurie female white    0         white
#> 4011     Sarah female white    0         white
#> 4012     Sarah female white    0         white
#> 4013    Tamika female black    0 black, female
#> 4014   Tanisha female black    0 black, female
#> 4015    Carrie female white    0         white
#> 4016   Latonya female black    0 black, female
#> 4017    Laurie female white    0         white
#> 4018   Tanisha female black    0 black, female
#> 4019      Anne female white    1         white
#> 4020   Rasheed   male black    0    black male
#> 4021      Jill female white    0         white
#> 4022    Keisha female black    0 black, female
#> 4023   Kristen female white    0         white
#> 4024   Tanisha female black    0 black, female
#> 4025   Allison female white    0         white
#> 4026     Emily female white    0         white
#> 4027   Lakisha female black    0 black, female
#> 4028   Latonya female black    0 black, female
#> 4029   Matthew   male white    0         white
#> 4030    Tyrone   male black    0    black male
#> 4031   Kristen female white    0         white
#> 4032    Latoya female black    0 black, female
#> 4033    Laurie female white    0         white
#> 4034    Tamika female black    0 black, female
#> 4035     Emily female white    0         white
#> 4036    Keisha female black    0 black, female
#> 4037    Laurie female white    0         white
#> 4038     Sarah female white    0         white
#> 4039    Tamika female black    0 black, female
#> 4040   Tanisha female black    0 black, female
#> 4041     Aisha female black    0 black, female
#> 4042   Kristen female white    0         white
#> 4043   Lakisha female black    0 black, female
#> 4044    Laurie female white    0         white
#> 4045     Aisha female black    0 black, female
#> 4046   Allison female white    1         white
#> 4047    Latoya female black    0 black, female
#> 4048    Laurie female white    0         white
#> 4049   Allison female white    0         white
#> 4050      Anne female white    0         white
#> 4051      Anne female white    0         white
#> 4052   Darnell   male black    0    black male
#> 4053    Keisha female black    0 black, female
#> 4054    Latoya female black    0 black, female
#> 4055   Tanisha female black    0 black, female
#> 4056      Todd   male white    0         white
#> 4057     Ebony female black    0 black, female
#> 4058     Emily female white    0         white
#> 4059   Latonya female black    0 black, female
#> 4060    Laurie female white    0         white
#> 4061     Aisha female black    0 black, female
#> 4062   Allison female white    0         white
#> 4063     Jamal   male black    0    black male
#> 4064       Jay   male white    0         white
#> 4065      Jill female white    0         white
#> 4066   Latonya female black    0 black, female
#> 4067   Allison female white    1         white
#> 4068      Anne female white    0         white
#> 4069     Ebony female black    0 black, female
#> 4070     Kenya female black    0 black, female
#> 4071     Emily female white    1         white
#> 4072  Geoffrey   male white    1         white
#> 4073    Kareem   male black    1    black male
#> 4074     Kenya female black    1 black, female
#> 4075   Kristen female white    0         white
#> 4076   Latonya female black    0 black, female
#> 4077  Meredith female white    0         white
#> 4078   Tanisha female black    0 black, female
#> 4079     Aisha female black    0 black, female
#> 4080      Anne female white    0         white
#> 4081   Brendan   male white    0         white
#> 4082     Emily female white    0         white
#> 4083       Jay   male white    0         white
#> 4084    Keisha female black    0 black, female
#> 4085   Latonya female black    1 black, female
#> 4086    Tamika female black    1 black, female
#> 4087     Aisha female black    0 black, female
#> 4088      Anne female white    0         white
#> 4089      Brad   male white    0         white
#> 4090    Carrie female white    0         white
#> 4091     Ebony female black    0 black, female
#> 4092     Emily female white    0         white
#> 4093  Geoffrey   male white    0         white
#> 4094      Greg   male white    0         white
#> 4095      Greg   male white    0         white
#> 4096     Hakim   male black    0    black male
#> 4097     Hakim   male black    0    black male
#> 4098  Jermaine   male black    0    black male
#> 4099      Jill female white    0         white
#> 4100      Jill female white    0         white
#> 4101    Kareem   male black    0    black male
#> 4102    Keisha female black    0 black, female
#> 4103     Kenya female black    0 black, female
#> 4104    Latoya female black    0 black, female
#> 4105    Latoya female black    0 black, female
#> 4106    Laurie female white    0         white
#> 4107   Matthew   male white    0         white
#> 4108  Meredith female white    0         white
#> 4109     Sarah female white    0         white
#> 4110    Tamika female black    0 black, female
#> 4111      Todd   male white    0         white
#> 4112  Tremayne   male black    0    black male
#> 4113  Tremayne   male black    0    black male
#> 4114    Tyrone   male black    0    black male
#> 4115     Ebony female black    0 black, female
#> 4116     Emily female white    0         white
#> 4117      Jill female white    0         white
#> 4118   Lakisha female black    0 black, female
#> 4119      Greg   male white    0         white
#> 4120       Jay   male white    0         white
#> 4121     Leroy   male black    0    black male
#> 4122   Rasheed   male black    0    black male
#> 4123     Aisha female black    0 black, female
#> 4124    Kareem   male black    0    black male
#> 4125   Matthew   male white    0         white
#> 4126  Meredith female white    0         white
#> 4127      Greg   male white    1         white
#> 4128       Jay   male white    1         white
#> 4129    Kareem   male black    1    black male
#> 4130    Tamika female black    1 black, female
#> 4131      Anne female white    0         white
#> 4132    Latoya female black    0 black, female
#> 4133  Meredith female white    0         white
#> 4134   Tanisha female black    0 black, female
#> 4135      Greg   male white    0         white
#> 4136     Jamal   male black    0    black male
#> 4137    Latoya female black    0 black, female
#> 4138      Neil   male white    0         white
#> 4139   Allison female white    0         white
#> 4140     Ebony female black    0 black, female
#> 4141   Lakisha female black    0 black, female
#> 4142  Meredith female white    0         white
#> 4143     Brett   male white    1         white
#> 4144     Ebony female black    1 black, female
#> 4145      Neil   male white    0         white
#> 4146  Tremayne   male black    1    black male
#> 4147      Anne female white    0         white
#> 4148    Kareem   male black    0    black male
#> 4149     Kenya female black    0 black, female
#> 4150   Matthew   male white    0         white
#> 4151      Jill female white    0         white
#> 4152     Kenya female black    0 black, female
#> 4153     Sarah female white    0         white
#> 4154    Tamika female black    0 black, female
#> 4155      Brad   male white    0         white
#> 4156  Jermaine   male black    0    black male
#> 4157      Neil   male white    0         white
#> 4158    Tamika female black    0 black, female
#> 4159   Lakisha female black    0 black, female
#> 4160   Matthew   male white    0         white
#> 4161  Meredith female white    0         white
#> 4162   Rasheed   male black    0    black male
#> 4163      Anne female white    0         white
#> 4164   Rasheed   male black    0    black male
#> 4165     Sarah female white    0         white
#> 4166  Tremayne   male black    0    black male
#> 4167      Greg   male white    0         white
#> 4168   Rasheed   male black    0    black male
#> 4169   Tanisha female black    1 black, female
#> 4170      Todd   male white    0         white
#> 4171     Brett   male white    0         white
#> 4172     Leroy   male black    0    black male
#> 4173   Matthew   male white    0         white
#> 4174    Tamika female black    0 black, female
#> 4175     Aisha female black    0 black, female
#> 4176   Allison female white    0         white
#> 4177     Sarah female white    0         white
#> 4178    Tamika female black    0 black, female
#> 4179   Allison female white    0         white
#> 4180   Allison female white    0         white
#> 4181      Anne female white    0         white
#> 4182     Ebony female black    0 black, female
#> 4183   Lakisha female black    0 black, female
#> 4184   Latonya female black    0 black, female
#> 4185   Kristen female white    0         white
#> 4186     Sarah female white    0         white
#> 4187    Tamika female black    0 black, female
#> 4188   Tanisha female black    0 black, female
#> 4189      Jill female white    0         white
#> 4190    Latoya female black    0 black, female
#> 4191   Kristen female white    1         white
#> 4192   Lakisha female black    0 black, female
#> 4193   Latonya female black    0 black, female
#> 4194  Meredith female white    1         white
#> 4195      Anne female white    0         white
#> 4196    Carrie female white    0         white
#> 4197     Ebony female black    0 black, female
#> 4198     Emily female white    0         white
#> 4199      Jill female white    0         white
#> 4200     Kenya female black    0 black, female
#> 4201   Tanisha female black    0 black, female
#> 4202  Tremayne   male black    0    black male
#> 4203    Carrie female white    0         white
#> 4204      Jill female white    0         white
#> 4205    Latoya female black    0 black, female
#> 4206   Tanisha female black    0 black, female
#> 4207    Laurie female white    0         white
#> 4208    Tamika female black    0 black, female
#> 4209     Sarah female white    0         white
#> 4210    Tamika female black    0 black, female
#> 4211     Emily female white    0         white
#> 4212     Kenya female black    0 black, female
#> 4213   Kristen female white    0         white
#> 4214   Latonya female black    0 black, female
#> 4215      Anne female white    0         white
#> 4216    Carrie female white    0         white
#> 4217   Darnell   male black    0    black male
#> 4218     Hakim   male black    0    black male
#> 4219       Jay   male white    0         white
#> 4220      Jill female white    0         white
#> 4221   Lakisha female black    0 black, female
#> 4222    Tamika female black    0 black, female
#> 4223     Kenya female black    0 black, female
#> 4224   Kristen female white    0         white
#> 4225    Laurie female white    0         white
#> 4226    Tamika female black    0 black, female
#> 4227   Allison female white    0         white
#> 4228    Keisha female black    0 black, female
#> 4229   Kristen female white    0         white
#> 4230     Sarah female white    0         white
#> 4231    Tamika female black    0 black, female
#> 4232  Tremayne   male black    0    black male
#> 4233      Anne female white    0         white
#> 4234     Ebony female black    0 black, female
#> 4235     Kenya female black    0 black, female
#> 4236   Kristen female white    0         white
#> 4237     Aisha female black    0 black, female
#> 4238   Allison female white    0         white
#> 4239    Carrie female white    0         white
#> 4240    Keisha female black    0 black, female
#> 4241   Allison female white    0         white
#> 4242  Jermaine   male black    1    black male
#> 4243     Leroy   male black    0    black male
#> 4244      Neil   male white    1         white
#> 4245       Jay   male white    0         white
#> 4246      Jill female white    1         white
#> 4247     Kenya female black    1 black, female
#> 4248   Kristen female white    0         white
#> 4249    Latoya female black    1 black, female
#> 4250   Rasheed   male black    0    black male
#> 4251     Ebony female black    0 black, female
#> 4252  Geoffrey   male white    0         white
#> 4253       Jay   male white    0         white
#> 4254      Jill female white    0         white
#> 4255     Kenya female black    0 black, female
#> 4256   Latonya female black    0 black, female
#> 4257     Sarah female white    0         white
#> 4258   Tanisha female black    0 black, female
#> 4259   Brendan   male white    0         white
#> 4260     Emily female white    0         white
#> 4261   Kristen female white    0         white
#> 4262    Latoya female black    0 black, female
#> 4263   Rasheed   male black    0    black male
#> 4264    Tamika female black    0 black, female
#> 4265      Jill female white    0         white
#> 4266    Latoya female black    0 black, female
#> 4267    Laurie female white    0         white
#> 4268    Tamika female black    0 black, female
#> 4269    Carrie female white    0         white
#> 4270     Ebony female black    0 black, female
#> 4271     Ebony female black    0 black, female
#> 4272     Kenya female black    0 black, female
#> 4273   Kristen female white    0         white
#> 4274      Todd   male white    0         white
#> 4275     Aisha female black    0 black, female
#> 4276   Allison female white    0         white
#> 4277    Carrie female white    0         white
#> 4278    Latoya female black    0 black, female
#> 4279    Laurie female white    0         white
#> 4280     Sarah female white    0         white
#> 4281    Tamika female black    0 black, female
#> 4282   Tanisha female black    0 black, female
#> 4283    Carrie female white    0         white
#> 4284    Keisha female black    0 black, female
#> 4285   Latonya female black    0 black, female
#> 4286     Leroy   male black    1    black male
#> 4287      Neil   male white    1         white
#> 4288     Sarah female white    0         white
#> 4289     Aisha female black    0 black, female
#> 4290      Anne female white    0         white
#> 4291    Latoya female black    0 black, female
#> 4292  Meredith female white    0         white
#> 4293    Carrie female white    0         white
#> 4294     Kenya female black    0 black, female
#> 4295   Kristen female white    1         white
#> 4296   Lakisha female black    0 black, female
#> 4297  Meredith female white    1         white
#> 4298  Tremayne   male black    0    black male
#> 4299      Jill female white    0         white
#> 4300   Kristen female white    0         white
#> 4301    Latoya female black    0 black, female
#> 4302    Tamika female black    0 black, female
#> 4303    Carrie female white    0         white
#> 4304     Emily female white    0         white
#> 4305    Latoya female black    0 black, female
#> 4306   Tanisha female black    0 black, female
#> 4307     Ebony female black    0 black, female
#> 4308     Emily female white    0         white
#> 4309    Laurie female white    0         white
#> 4310  Tremayne   male black    0    black male
#> 4311    Laurie female white    0         white
#> 4312    Tamika female black    0 black, female
#> 4313    Carrie female white    0         white
#> 4314   Lakisha female black    0 black, female
#> 4315   Latonya female black    0 black, female
#> 4316  Meredith female white    0         white
#> 4317   Allison female white    0         white
#> 4318    Carrie female white    0         white
#> 4319      Jill female white    0         white
#> 4320    Kareem   male black    0    black male
#> 4321   Latonya female black    0 black, female
#> 4322    Latoya female black    0 black, female
#> 4323      Anne female white    0         white
#> 4324     Emily female white    0         white
#> 4325     Kenya female black    0 black, female
#> 4326   Tanisha female black    0 black, female
#> 4327  Jermaine   male black    0    black male
#> 4328   Latonya female black    0 black, female
#> 4329    Laurie female white    0         white
#> 4330     Sarah female white    0         white
#> 4331  Jermaine   male black    0    black male
#> 4332     Kenya female black    0 black, female
#> 4333   Kristen female white    1         white
#> 4334  Meredith female white    0         white
#> 4335     Sarah female white    1         white
#> 4336   Tanisha female black    1 black, female
#> 4337      Anne female white    0         white
#> 4338      Brad   male white    0         white
#> 4339     Emily female white    0         white
#> 4340     Hakim   male black    0    black male
#> 4341  Jermaine   male black    0    black male
#> 4342  Jermaine   male black    0    black male
#> 4343      Jill female white    0         white
#> 4344      Jill female white    0         white
#> 4345    Keisha female black    0 black, female
#> 4346   Lakisha female black    0 black, female
#> 4347   Lakisha female black    0 black, female
#> 4348   Latonya female black    0 black, female
#> 4349    Latoya female black    0 black, female
#> 4350    Latoya female black    0 black, female
#> 4351    Latoya female black    0 black, female
#> 4352    Laurie female white    0         white
#> 4353    Laurie female white    0         white
#> 4354    Laurie female white    0         white
#> 4355   Matthew   male white    0         white
#> 4356  Meredith female white    0         white
#> 4357   Rasheed   male black    0    black male
#> 4358     Sarah female white    0         white
#> 4359      Todd   male white    0         white
#> 4360  Tremayne   male black    0    black male
#> 4361      Anne female white    0         white
#> 4362      Jill female white    0         white
#> 4363    Latoya female black    1 black, female
#> 4364    Tamika female black    0 black, female
#> 4365      Greg   male white    0         white
#> 4366       Jay   male white    0         white
#> 4367   Latonya female black    0 black, female
#> 4368    Tyrone   male black    0    black male
#> 4369      Brad   male white    0         white
#> 4370   Kristen female white    1         white
#> 4371    Latoya female black    0 black, female
#> 4372   Tanisha female black    0 black, female
#> 4373   Kristen female white    0         white
#> 4374   Latonya female black    0 black, female
#> 4375     Sarah female white    0         white
#> 4376   Tanisha female black    0 black, female
#> 4377   Darnell   male black    0    black male
#> 4378    Keisha female black    0 black, female
#> 4379  Meredith female white    0         white
#> 4380      Neil   male white    0         white
#> 4381  Geoffrey   male white    0         white
#> 4382    Keisha female black    0 black, female
#> 4383   Latonya female black    0 black, female
#> 4384   Matthew   male white    0         white
#> 4385      Brad   male white    0         white
#> 4386      Greg   male white    0         white
#> 4387    Latoya female black    0 black, female
#> 4388  Tremayne   male black    0    black male
#> 4389  Geoffrey   male white    0         white
#> 4390    Latoya female black    0 black, female
#> 4391      Neil   male white    0         white
#> 4392    Tyrone   male black    0    black male
#> 4393      Anne female white    0         white
#> 4394     Emily female white    0         white
#> 4395     Hakim   male black    0    black male
#> 4396   Latonya female black    0 black, female
#> 4397     Ebony female black    0 black, female
#> 4398    Laurie female white    0         white
#> 4399  Meredith female white    0         white
#> 4400    Tamika female black    0 black, female
#> 4401      Greg   male white    1         white
#> 4402    Latoya female black    1 black, female
#> 4403      Neil   male white    0         white
#> 4404   Tanisha female black    1 black, female
#> 4405   Allison female white    0         white
#> 4406     Ebony female black    0 black, female
#> 4407      Jill female white    0         white
#> 4408     Kenya female black    0 black, female
#> 4409     Ebony female black    1 black, female
#> 4410     Emily female white    1         white
#> 4411     Aisha female black    0 black, female
#> 4412    Carrie female white    1         white
#> 4413     Ebony female black    0 black, female
#> 4414     Emily female white    0         white
#> 4415     Emily female white    0         white
#> 4416    Kareem   male black    0    black male
#> 4417   Matthew   male white    0         white
#> 4418  Tremayne   male black    0    black male
#> 4419   Kristen female white    0         white
#> 4420     Sarah female white    0         white
#> 4421    Tamika female black    0 black, female
#> 4422   Tanisha female black    0 black, female
#> 4423   Allison female white    0         white
#> 4424    Keisha female black    0 black, female
#> 4425   Kristen female white    0         white
#> 4426    Tamika female black    0 black, female
#> 4427     Brett   male white    0         white
#> 4428     Jamal   male black    1    black male
#> 4429      Anne female white    0         white
#> 4430     Ebony female black    0 black, female
#> 4431     Emily female white    0         white
#> 4432   Rasheed   male black    0    black male
#> 4433      Anne female white    0         white
#> 4434      Jill female white    0         white
#> 4435     Kenya female black    0 black, female
#> 4436    Latoya female black    0 black, female
#> 4437     Aisha female black    0 black, female
#> 4438      Anne female white    0         white
#> 4439    Latoya female black    0 black, female
#> 4440  Meredith female white    0         white
#> 4441     Kenya female black    0 black, female
#> 4442   Kristen female white    0         white
#> 4443    Laurie female white    0         white
#> 4444    Tamika female black    0 black, female
#> 4445      Anne female white    0         white
#> 4446     Ebony female black    0 black, female
#> 4447    Keisha female black    0 black, female
#> 4448    Laurie female white    0         white
#> 4449     Aisha female black    0 black, female
#> 4450      Anne female white    0         white
#> 4451      Jill female white    0         white
#> 4452   Kristen female white    0         white
#> 4453   Lakisha female black    0 black, female
#> 4454   Rasheed   male black    0    black male
#> 4455     Aisha female black    0 black, female
#> 4456      Anne female white    0         white
#> 4457     Emily female white    0         white
#> 4458    Tamika female black    0 black, female
#> 4459      Anne female white    0         white
#> 4460     Emily female white    0         white
#> 4461  Jermaine   male black    0    black male
#> 4462   Latonya female black    0 black, female
#> 4463   Latonya female black    0 black, female
#> 4464    Laurie female white    0         white
#> 4465     Aisha female black    0 black, female
#> 4466  Meredith female white    0         white
#> 4467     Sarah female white    0         white
#> 4468   Tanisha female black    0 black, female
#> 4469     Brett   male white    0         white
#> 4470     Leroy   male black    0    black male
#> 4471   Brendan   male white    0         white
#> 4472  Geoffrey   male white    0         white
#> 4473     Jamal   male black    0    black male
#> 4474    Kareem   male black    0    black male
#> 4475   Matthew   male white    1         white
#> 4476  Tremayne   male black    0    black male
#> 4477      Anne female white    0         white
#> 4478     Kenya female black    0 black, female
#> 4479    Laurie female white    0         white
#> 4480   Tanisha female black    0 black, female
#> 4481      Anne female white    0         white
#> 4482      Jill female white    0         white
#> 4483    Keisha female black    0 black, female
#> 4484   Kristen female white    0         white
#> 4485   Lakisha female black    0 black, female
#> 4486   Latonya female black    0 black, female
#> 4487     Aisha female black    0 black, female
#> 4488      Anne female white    0         white
#> 4489   Kristen female white    0         white
#> 4490   Matthew   male white    0         white
#> 4491    Tamika female black    0 black, female
#> 4492   Tanisha female black    0 black, female
#> 4493     Aisha female black    0 black, female
#> 4494   Allison female white    0         white
#> 4495   Lakisha female black    0 black, female
#> 4496     Sarah female white    0         white
#> 4497     Aisha female black    0 black, female
#> 4498     Emily female white    0         white
#> 4499    Keisha female black    0 black, female
#> 4500     Kenya female black    0 black, female
#> 4501    Laurie female white    0         white
#> 4502     Sarah female white    0         white
#> 4503   Allison female white    0         white
#> 4504     Emily female white    0         white
#> 4505    Tamika female black    0 black, female
#> 4506   Tanisha female black    0 black, female
#> 4507    Carrie female white    0         white
#> 4508     Kenya female black    0 black, female
#> 4509     Sarah female white    0         white
#> 4510   Tanisha female black    0 black, female
#> 4511   Allison female white    0         white
#> 4512   Darnell   male black    0    black male
#> 4513     Ebony female black    0 black, female
#> 4514       Jay   male white    0         white
#> 4515      Jill female white    0         white
#> 4516    Keisha female black    0 black, female
#> 4517    Laurie female white    0         white
#> 4518     Sarah female white    0         white
#> 4519    Tamika female black    0 black, female
#> 4520   Tanisha female black    0 black, female
#> 4521     Aisha female black    0 black, female
#> 4522   Allison female white    0         white
#> 4523     Brett   male white    0         white
#> 4524  Jermaine   male black    0    black male
#> 4525      Jill female white    0         white
#> 4526    Keisha female black    0 black, female
#> 4527      Anne female white    0         white
#> 4528   Latonya female black    0 black, female
#> 4529    Laurie female white    0         white
#> 4530   Tanisha female black    0 black, female
#> 4531     Aisha female black    0 black, female
#> 4532    Carrie female white    0         white
#> 4533   Kristen female white    0         white
#> 4534    Tamika female black    0 black, female
#> 4535   Brendan   male white    0         white
#> 4536    Carrie female white    0         white
#> 4537   Lakisha female black    0 black, female
#> 4538   Latonya female black    0 black, female
#> 4539    Latoya female black    0 black, female
#> 4540  Meredith female white    0         white
#> 4541     Brett   male white    0         white
#> 4542   Latonya female black    0 black, female
#> 4543      Anne female white    0         white
#> 4544     Emily female white    0         white
#> 4545    Latoya female black    0 black, female
#> 4546    Tamika female black    0 black, female
#> 4547    Carrie female white    0         white
#> 4548   Latonya female black    0 black, female
#> 4549    Laurie female white    0         white
#> 4550  Tremayne   male black    0    black male
#> 4551     Aisha female black    0 black, female
#> 4552    Carrie female white    0         white
#> 4553    Carrie female white    0         white
#> 4554     Emily female white    0         white
#> 4555      Jill female white    0         white
#> 4556     Kenya female black    0 black, female
#> 4557   Latonya female black    0 black, female
#> 4558   Tanisha female black    0 black, female
#> 4559   Allison female white    1         white
#> 4560    Carrie female white    0         white
#> 4561     Ebony female black    0 black, female
#> 4562     Leroy   male black    1    black male
#> 4563      Anne female white    0         white
#> 4564      Anne female white    0         white
#> 4565      Brad   male white    0         white
#> 4566     Brett   male white    0         white
#> 4567     Brett   male white    0         white
#> 4568    Carrie female white    0         white
#> 4569   Darnell   male black    0    black male
#> 4570     Ebony female black    0 black, female
#> 4571     Emily female white    0         white
#> 4572     Hakim   male black    0    black male
#> 4573     Jamal   male black    0    black male
#> 4574     Jamal   male black    0    black male
#> 4575       Jay   male white    0         white
#> 4576       Jay   male white    0         white
#> 4577  Jermaine   male black    0    black male
#> 4578   Kristen female white    0         white
#> 4579   Kristen female white    0         white
#> 4580   Lakisha female black    0 black, female
#> 4581    Latoya female black    0 black, female
#> 4582  Meredith female white    0         white
#> 4583  Meredith female white    0         white
#> 4584      Neil   male white    0         white
#> 4585   Rasheed   male black    0    black male
#> 4586   Rasheed   male black    0    black male
#> 4587     Sarah female white    0         white
#> 4588     Sarah female white    0         white
#> 4589    Tamika female black    0 black, female
#> 4590    Tamika female black    0 black, female
#> 4591   Tanisha female black    0 black, female
#> 4592  Tremayne   male black    0    black male
#> 4593  Tremayne   male black    0    black male
#> 4594    Tyrone   male black    0    black male
#> 4595   Allison female white    0         white
#> 4596      Jill female white    0         white
#> 4597    Tamika female black    0 black, female
#> 4598  Tremayne   male black    0    black male
#> 4599     Aisha female black    0 black, female
#> 4600   Brendan   male white    0         white
#> 4601  Jermaine   male black    0    black male
#> 4602      Jill female white    0         white
#> 4603      Jill female white    0         white
#> 4604     Kenya female black    1 black, female
#> 4605     Sarah female white    0         white
#> 4606    Tamika female black    0 black, female
#> 4607   Kristen female white    0         white
#> 4608    Latoya female black    0 black, female
#> 4609     Leroy   male black    0    black male
#> 4610  Meredith female white    0         white
#> 4611      Jill female white    0         white
#> 4612   Kristen female white    1         white
#> 4613    Latoya female black    0 black, female
#> 4614    Tamika female black    0 black, female
#> 4615      Anne female white    0         white
#> 4616   Latonya female black    0 black, female
#> 4617      Neil   male white    0         white
#> 4618   Rasheed   male black    0    black male
#> 4619   Allison female white    0         white
#> 4620     Emily female white    0         white
#> 4621   Lakisha female black    0 black, female
#> 4622   Tanisha female black    0 black, female
#> 4623      Greg   male white    0         white
#> 4624     Kenya female black    0 black, female
#> 4625   Kristen female white    0         white
#> 4626    Tamika female black    0 black, female
#> 4627     Brett   male white    0         white
#> 4628   Darnell   male black    0    black male
#> 4629     Ebony female black    0 black, female
#> 4630  Meredith female white    0         white
#> 4631     Ebony female black    0 black, female
#> 4632   Kristen female white    0         white
#> 4633    Latoya female black    0 black, female
#> 4634     Sarah female white    0         white
#> 4635      Brad   male white    0         white
#> 4636   Latonya female black    0 black, female
#> 4637   Rasheed   male black    0    black male
#> 4638     Sarah female white    0         white
#> 4639     Aisha female black    0 black, female
#> 4640    Latoya female black    0 black, female
#> 4641    Laurie female white    0         white
#> 4642  Meredith female white    0         white
#> 4643   Brendan   male white    0         white
#> 4644     Emily female white    0         white
#> 4645     Kenya female black    0 black, female
#> 4646     Kenya female black    0 black, female
#> 4647   Kristen female white    0         white
#> 4648   Latonya female black    0 black, female
#> 4649   Rasheed   male black    0    black male
#> 4650     Sarah female white    0         white
#> 4651   Allison female white    0         white
#> 4652    Keisha female black    0 black, female
#> 4653   Kristen female white    0         white
#> 4654    Tamika female black    0 black, female
#> 4655   Allison female white    0         white
#> 4656    Keisha female black    0 black, female
#> 4657   Kristen female white    0         white
#> 4658    Tamika female black    0 black, female
#> 4659     Jamal   male black    0    black male
#> 4660    Kareem   male black    0    black male
#> 4661   Kristen female white    0         white
#> 4662    Laurie female white    0         white
#> 4663     Emily female white    0         white
#> 4664   Kristen female white    0         white
#> 4665   Kristen female white    0         white
#> 4666   Rasheed   male black    0    black male
#> 4667    Tamika female black    0 black, female
#> 4668    Tamika female black    0 black, female
#> 4669     Aisha female black    0 black, female
#> 4670     Emily female white    0         white
#> 4671     Kenya female black    0 black, female
#> 4672     Sarah female white    0         white
#> 4673     Aisha female black    0 black, female
#> 4674      Anne female white    0         white
#> 4675     Emily female white    0         white
#> 4676    Tamika female black    0 black, female
#> 4677      Jill female white    0         white
#> 4678   Lakisha female black    1 black, female
#> 4679    Latoya female black    1 black, female
#> 4680    Laurie female white    0         white
#> 4681    Carrie female white    0         white
#> 4682   Kristen female white    0         white
#> 4683   Latonya female black    0 black, female
#> 4684    Tamika female black    0 black, female
#> 4685     Aisha female black    0 black, female
#> 4686  Geoffrey   male white    0         white
#> 4687      Jill female white    0         white
#> 4688   Kristen female white    0         white
#> 4689   Tanisha female black    0 black, female
#> 4690  Tremayne   male black    0    black male
#> 4691     Aisha female black    0 black, female
#> 4692   Allison female white    0         white
#> 4693    Latoya female black    0 black, female
#> 4694     Sarah female white    0         white
#> 4695    Carrie female white    0         white
#> 4696     Ebony female black    0 black, female
#> 4697     Emily female white    0         white
#> 4698    Tamika female black    0 black, female
#> 4699     Aisha female black    0 black, female
#> 4700    Carrie female white    1         white
#> 4701   Lakisha female black    0 black, female
#> 4702     Sarah female white    1         white
#> 4703     Jamal   male black    0    black male
#> 4704      Neil   male white    1         white
#> 4705      Todd   male white    0         white
#> 4706    Tyrone   male black    1    black male
#> 4707       Jay   male white    0         white
#> 4708      Neil   male white    0         white
#> 4709  Tremayne   male black    0    black male
#> 4710    Tyrone   male black    0    black male
#> 4711     Hakim   male black    0    black male
#> 4712       Jay   male white    0         white
#> 4713     Kenya female black    0 black, female
#> 4714    Laurie female white    0         white
#> 4715   Allison female white    0         white
#> 4716   Kristen female white    0         white
#> 4717   Latonya female black    0 black, female
#> 4718    Tamika female black    0 black, female
#> 4719     Aisha female black    0 black, female
#> 4720   Allison female white    0         white
#> 4721    Carrie female white    0         white
#> 4722      Jill female white    0         white
#> 4723   Lakisha female black    0 black, female
#> 4724    Tamika female black    0 black, female
#> 4725     Aisha female black    0 black, female
#> 4726   Allison female white    1         white
#> 4727     Emily female white    0         white
#> 4728     Emily female white    0         white
#> 4729     Kenya female black    1 black, female
#> 4730     Leroy   male black    0    black male
#> 4731     Aisha female black    0 black, female
#> 4732      Anne female white    0         white
#> 4733    Carrie female white    0         white
#> 4734   Lakisha female black    0 black, female
#> 4735      Jill female white    0         white
#> 4736     Kenya female black    1 black, female
#> 4737   Kristen female white    1         white
#> 4738   Latonya female black    1 black, female
#> 4739   Latonya female black    0 black, female
#> 4740     Sarah female white    1         white
#> 4741     Ebony female black    0 black, female
#> 4742      Jill female white    0         white
#> 4743   Kristen female white    0         white
#> 4744    Latoya female black    0 black, female
#> 4745      Anne female white    0         white
#> 4746     Emily female white    0         white
#> 4747   Lakisha female black    0 black, female
#> 4748     Sarah female white    0         white
#> 4749    Tamika female black    0 black, female
#> 4750    Tamika female black    0 black, female
#> 4751    Carrie female white    0         white
#> 4752     Kenya female black    0 black, female
#> 4753  Meredith female white    0         white
#> 4754   Tanisha female black    0 black, female
#> 4755   Allison female white    0         white
#> 4756   Allison female white    0         white
#> 4757     Emily female white    0         white
#> 4758     Kenya female black    1 black, female
#> 4759   Lakisha female black    0 black, female
#> 4760   Latonya female black    0 black, female
#> 4761     Aisha female black    0 black, female
#> 4762    Carrie female white    0         white
#> 4763   Kristen female white    0         white
#> 4764    Tamika female black    0 black, female
#> 4765      Jill female white    0         white
#> 4766    Tamika female black    0 black, female
#> 4767      Anne female white    0         white
#> 4768       Jay   male white    0         white
#> 4769   Latonya female black    0 black, female
#> 4770    Latoya female black    0 black, female
#> 4771  Meredith female white    0         white
#> 4772   Tanisha female black    0 black, female
#> 4773    Laurie female white    0         white
#> 4774    Tyrone   male black    0    black male
#> 4775     Aisha female black    0 black, female
#> 4776   Allison female white    0         white
#> 4777     Sarah female white    0         white
#> 4778    Tamika female black    0 black, female
#> 4779      Brad   male white    0         white
#> 4780    Carrie female white    0         white
#> 4781   Latonya female black    0 black, female
#> 4782   Latonya female black    0 black, female
#> 4783   Brendan   male white    1         white
#> 4784     Ebony female black    1 black, female
#> 4785     Emily female white    0         white
#> 4786      Jill female white    0         white
#> 4787     Kenya female black    0 black, female
#> 4788    Latoya female black    0 black, female
#> 4789    Laurie female white    1         white
#> 4790    Tamika female black    0 black, female
#> 4791  Geoffrey   male white    0         white
#> 4792      Greg   male white    0         white
#> 4793    Kareem   male black    0    black male
#> 4794  Tremayne   male black    0    black male
#> 4795      Brad   male white    0         white
#> 4796   Darnell   male black    0    black male
#> 4797     Ebony female black    0 black, female
#> 4798     Emily female white    0         white
#> 4799  Geoffrey   male white    0         white
#> 4800      Greg   male white    0         white
#> 4801     Hakim   male black    0    black male
#> 4802     Jamal   male black    0    black male
#> 4803       Jay   male white    0         white
#> 4804      Jill female white    0         white
#> 4805    Kareem   male black    0    black male
#> 4806    Kareem   male black    0    black male
#> 4807     Kenya female black    0 black, female
#> 4808     Kenya female black    0 black, female
#> 4809   Lakisha female black    0 black, female
#> 4810    Laurie female white    0         white
#> 4811    Laurie female white    0         white
#> 4812    Laurie female white    0         white
#> 4813     Leroy   male black    0    black male
#> 4814  Meredith female white    0         white
#> 4815  Meredith female white    0         white
#> 4816   Rasheed   male black    0    black male
#> 4817     Sarah female white    0         white
#> 4818     Sarah female white    0         white
#> 4819   Tanisha female black    0 black, female
#> 4820      Todd   male white    0         white
#> 4821  Tremayne   male black    0    black male
#> 4822    Tyrone   male black    0    black male
#> 4823   Allison female white    0         white
#> 4824   Latonya female black    0 black, female
#> 4825  Meredith female white    0         white
#> 4826    Tamika female black    0 black, female
#> 4827      Brad   male white    1         white
#> 4828    Kareem   male black    0    black male
#> 4829    Keisha female black    0 black, female
#> 4830   Matthew   male white    1         white
#> 4831      Anne female white    0         white
#> 4832     Emily female white    0         white
#> 4833   Lakisha female black    0 black, female
#> 4834    Tamika female black    0 black, female
#> 4835      Brad   male white    0         white
#> 4836   Darnell   male black    0    black male
#> 4837      Todd   male white    0         white
#> 4838  Tremayne   male black    0    black male
#> 4839   Brendan   male white    0         white
#> 4840     Brett   male white    0         white
#> 4841     Jamal   male black    0    black male
#> 4842    Kareem   male black    0    black male
#> 4843     Kenya female black    0 black, female
#> 4844   Kristen female white    1         white
#> 4845    Latoya female black    0 black, female
#> 4846    Laurie female white    0         white
#> 4847    Carrie female white    1         white
#> 4848   Kristen female white    1         white
#> 4849   Latonya female black    1 black, female
#> 4850    Tyrone   male black    0    black male
#> 4851     Ebony female black    0 black, female
#> 4852      Jill female white    0         white
#> 4853  Meredith female white    0         white
#> 4854   Tanisha female black    0 black, female
#> 4855  Geoffrey   male white    0         white
#> 4856      Greg   male white    0         white
#> 4857     Jamal   male black    0    black male
#> 4858    Tamika female black    0 black, female
#> 4859     Jamal   male black    0    black male
#> 4860   Latonya female black    1 black, female
#> 4861   Matthew   male white    0         white
#> 4862     Sarah female white    1         white
#> 4863   Allison female white    0         white
#> 4864      Jill female white    0         white
#> 4865   Lakisha female black    0 black, female
#> 4866    Tamika female black    0 black, female
#> 4867     Ebony female black    0 black, female
#> 4868       Jay   male white    0         white
#> 4869   Latonya female black    0 black, female
#> 4870    Laurie female white    0         white
```

Alternatively, we could have created this variable using string manipulation functions.
Use  [str_to_title](https://www.rdocumentation.org/packages/stringr/topics/str_to_title) to capitalize `sex` and `race`,and [str_c](https://www.rdocumentation.org/packages/stringr/topics/str_c) to concatenate these vectors.

```r
resume <-
  resume %>%
  mutate(type = str_c(str_to_title(race), str_to_title(sex)))
```

Some of the reasons given in *QSS* for using factors in this chapter are less important due to the functionality od modern **tidyverse** packages.
For example, there is no reason to use `tapply`, as that can use `group_by` and `summarise`,

```r
resume %>%
  group_by(type) %>%
  summarise(call = mean(call))
#> # A tibble: 4 x 2
#>          type   call
#>         <chr>  <dbl>
#> 1 BlackFemale 0.0663
#> 2   BlackMale 0.0583
#> 3 WhiteFemale 0.0989
#> 4   WhiteMale 0.0887
```

What's nice about this approach is that we wouldn't have needed to create the factor variable first,

```r
resume %>%
  group_by(race, sex) %>%
  summarise(call = mean(call))
#> # A tibble: 4 x 3
#> # Groups:   race [?]
#>    race    sex   call
#>   <chr>  <chr>  <dbl>
#> 1 black female 0.0663
#> 2 black   male 0.0583
#> 3 white female 0.0989
#> 4 white   male 0.0887
```

We can use that same approach to calculate the mean of first names, and use
`arrange` to sort in ascending order.

```r
resume %>%
  group_by(firstname) %>%
  summarise(call = mean(call)) %>%
  arrange(call)
#> # A tibble: 36 x 2
#>   firstname   call
#>       <chr>  <dbl>
#> 1     Aisha 0.0222
#> 2   Rasheed 0.0299
#> 3    Keisha 0.0383
#> 4  Tremayne 0.0435
#> 5    Kareem 0.0469
#> 6   Darnell 0.0476
#> # ... with 30 more rows
```



**Tip:** General advice for working (or not) with factors:

- Use character vectors instead of factors. They are easier to manipulate with string functions.
- Use factor vectors only when you need a specific ordering of string values in a variable, e.g. in a model or a plot.




## Causal Affects and the Counterfactual

Load the `social` dataset included in the **qss** package.

```r
data("social", package = "qss")
summary(social)
#>      sex             yearofbirth    primary2004      messages        
#>  Length:305866      Min.   :1900   Min.   :0.000   Length:305866     
#>  Class :character   1st Qu.:1947   1st Qu.:0.000   Class :character  
#>  Mode  :character   Median :1956   Median :0.000   Mode  :character  
#>                     Mean   :1956   Mean   :0.401                     
#>                     3rd Qu.:1965   3rd Qu.:1.000                     
#>                     Max.   :1986   Max.   :1.000                     
#>   primary2006        hhsize    
#>  Min.   :0.000   Min.   :1.00  
#>  1st Qu.:0.000   1st Qu.:2.00  
#>  Median :0.000   Median :2.00  
#>  Mean   :0.312   Mean   :2.18  
#>  3rd Qu.:1.000   3rd Qu.:2.00  
#>  Max.   :1.000   Max.   :8.00
```

Calculate the mean turnout by `message`:

```r
gotv_by_group <-
  social %>%
  group_by(messages) %>%
  summarize(turnout = mean(primary2006))
gotv_by_group
#> # A tibble: 4 x 2
#>     messages turnout
#>        <chr>   <dbl>
#> 1 Civic Duty   0.315
#> 2    Control   0.297
#> 3  Hawthorne   0.322
#> 4  Neighbors   0.378
```

Since we want to calculate the difference by group, spread the data set so each 
group is a column:

```r
gotv_by_group %>%
  spread(messages, turnout) %>%
  mutate(diff_civic_duty = `Civic Duty` - Control,
         diff_Hawthorne = Hawthorne - Control,
         diff_Neighbors = Neighbors - Control) %>%
  select(matches("diff_"))
#> # A tibble: 1 x 3
#>   diff_civic_duty diff_Hawthorne diff_Neighbors
#>             <dbl>          <dbl>          <dbl>
#> 1          0.0179         0.0257         0.0813
```

Find the mean values of age, 2004 turnout, and household size for each group:

```r
social %>%
  mutate(age = 2006 - yearofbirth) %>%
  group_by(messages) %>%
  summarise(primary2004 = mean(primary2004),
            age = mean(age),
            hhsize = mean(hhsize))
#> # A tibble: 4 x 4
#>     messages primary2004   age hhsize
#>        <chr>       <dbl> <dbl>  <dbl>
#> 1 Civic Duty       0.399  49.7   2.19
#> 2    Control       0.400  49.8   2.18
#> 3  Hawthorne       0.403  49.7   2.18
#> 4  Neighbors       0.407  49.9   2.19
```
The function [summarise_at](https://www.rdocumentation.org/packages/dplyr/topics/summarise_at) allows you to summarize multiple variables,
using multiple functions, or both.

```r
social %>%
  mutate(age = 2006 - yearofbirth) %>%
  group_by(messages) %>%
  summarise_at(vars(primary2004, age, hhsize), funs(mean))
#> # A tibble: 4 x 4
#>     messages primary2004   age hhsize
#>        <chr>       <dbl> <dbl>  <dbl>
#> 1 Civic Duty       0.399  49.7   2.19
#> 2    Control       0.400  49.8   2.18
#> 3  Hawthorne       0.403  49.7   2.18
#> 4  Neighbors       0.407  49.9   2.19
```



## Observational Studies


```r
data("minwage", package = "qss")
glimpse(minwage)
#> Observations: 358
#> Variables: 8
#> $ chain      <chr> "wendys", "wendys", "burgerking", "burgerking", "kf...
#> $ location   <chr> "PA", "PA", "PA", "PA", "PA", "PA", "PA", "PA", "PA...
#> $ wageBefore <dbl> 5.00, 5.50, 5.00, 5.00, 5.25, 5.00, 5.00, 5.00, 5.0...
#> $ wageAfter  <dbl> 5.25, 4.75, 4.75, 5.00, 5.00, 5.00, 4.75, 5.00, 4.5...
#> $ fullBefore <dbl> 20.0, 6.0, 50.0, 10.0, 2.0, 2.0, 2.5, 40.0, 8.0, 10...
#> $ fullAfter  <dbl> 0.0, 28.0, 15.0, 26.0, 3.0, 2.0, 1.0, 9.0, 7.0, 18....
#> $ partBefore <dbl> 20.0, 26.0, 35.0, 17.0, 8.0, 10.0, 20.0, 30.0, 27.0...
#> $ partAfter  <dbl> 36, 3, 18, 9, 12, 9, 25, 32, 39, 10, 20, 4, 13, 20,...
summary(minwage)
#>     chain             location           wageBefore     wageAfter   
#>  Length:358         Length:358         Min.   :4.25   Min.   :4.25  
#>  Class :character   Class :character   1st Qu.:4.25   1st Qu.:5.05  
#>  Mode  :character   Mode  :character   Median :4.50   Median :5.05  
#>                                        Mean   :4.62   Mean   :4.99  
#>                                        3rd Qu.:4.99   3rd Qu.:5.05  
#>                                        Max.   :5.75   Max.   :6.25  
#>    fullBefore     fullAfter      partBefore     partAfter   
#>  Min.   : 0.0   Min.   : 0.0   Min.   : 0.0   Min.   : 0.0  
#>  1st Qu.: 2.1   1st Qu.: 2.0   1st Qu.:11.0   1st Qu.:11.0  
#>  Median : 6.0   Median : 6.0   Median :16.2   Median :17.0  
#>  Mean   : 8.5   Mean   : 8.4   Mean   :18.8   Mean   :18.7  
#>  3rd Qu.:12.0   3rd Qu.:12.0   3rd Qu.:25.0   3rd Qu.:25.0  
#>  Max.   :60.0   Max.   :40.0   Max.   :60.0   Max.   :60.0
```

First, calculate the proportion of restaurants by state whose hourly wages were less than the minimum wage in NJ, \$5.05, for `wageBefore` and `wageAfter`:

Since the NJ minimum wage was \$5.05, we'll define a variable with that value.
Even if you use them only once or twice, it is a good idea to put values like this in variables.
It makes your code closer to self-documenting.n

```r
NJ_MINWAGE <- 5.05
```
Later, it will be easier to understand `wageAfter < NJ_MINWAGE` without any comments than it would be to understand `wageAfter < 5.05`.
In the latter case you'd have to remember that the new NJ minimum wage was 5.05 and that's why you were using that value.
This is an example of a [magic number](https://en.wikipedia.org/wiki/Magic_number_(programming)#Unnamed_numerical_constants): try to avoid them.

Note that location has multiple values: PA and four regions of NJ.
So we'll add a state variable to the data.

```r
minwage %>%
  count(location)
#> # A tibble: 5 x 2
#>    location     n
#>       <chr> <int>
#> 1 centralNJ    45
#> 2   northNJ   146
#> 3        PA    67
#> 4   shoreNJ    33
#> 5   southNJ    67
```

We can extract the state from the final two characters of the location variable using the[stringr](https://cran.r-project.org/package=stringr) function [str_sub](https://www.rdocumentation.org/packages/stringr/topics/str_sub):

```r
minwage <-
  mutate(minwage, state = str_sub(location, -2L))
```
Alternatively, since `"NJ"` and `"PA"` are the only two values that `location` takes,

```r
minwage <-
  mutate(minwage, state = if_else(location == "PA", "PA", "NJ"))
```

Let's confirm that the restaurants followed the law:

```r
minwage %>%
  group_by(state) %>%
  summarise(prop_after = mean(wageAfter < NJ_MINWAGE),
            prop_Before = mean(wageBefore < NJ_MINWAGE))
#> # A tibble: 2 x 3
#>   state prop_after prop_Before
#>   <chr>      <dbl>       <dbl>
#> 1    NJ    0.00344       0.911
#> 2    PA    0.95522       0.940
```

Create a variable for the proportion of full-time employees in NJ and PA

```r
minwage <- minwage %>%
  mutate(totalAfter = fullAfter + partAfter,
        fullPropAfter = fullAfter / totalAfter)
```

Now calculate the average for each state:

```r
full_prop_by_state <- minwage %>%
  group_by(state) %>%
  summarise(fullPropAfter = mean(fullPropAfter))
full_prop_by_state
#> # A tibble: 2 x 2
#>   state fullPropAfter
#>   <chr>         <dbl>
#> 1    NJ         0.320
#> 2    PA         0.272
```

We could compute the difference in means between NJ and PA by

```r
(filter(full_prop_by_state, state == "NJ")[["fullPropAfter"]] -
  filter(full_prop_by_state, state == "PA")[["fullPropAfter"]])
#> [1] 0.0481
```
or

```r
spread(full_prop_by_state, state, fullPropAfter) %>%
  mutate(diff = NJ - PA)
#> # A tibble: 1 x 3
#>      NJ    PA   diff
#>   <dbl> <dbl>  <dbl>
#> 1  0.32 0.272 0.0481
```



### Confounding Bias

We can calculate the proportion of fast-food restaurants in each chain in each state:

```r
chains_by_state <-
  minwage %>%
  group_by(state) %>%
  count(chain) %>%
  mutate(prop = n / sum(n))
```

We can easily compare these using a dot-plot:

```r
ggplot(chains_by_state, aes(x = chain, y = prop, colour = state)) +
  geom_point() +
  coord_flip()
```

<img src="causality_files/figure-html/unnamed-chunk-42-1.png" width="70%" style="display: block; margin: auto;" />

In the QSS text, only Burger King restaurants are compared.
However, **dplyr** makes this easy.
All we have to do is change the `group_by` statement we used last time,

```r
full_prop_by_state_chain <-
  minwage %>%
  group_by(state, chain) %>%
  summarise(fullPropAfter = mean(fullPropAfter))
full_prop_by_state_chain
#> # A tibble: 8 x 3
#> # Groups:   state [?]
#>   state      chain fullPropAfter
#>   <chr>      <chr>         <dbl>
#> 1    NJ burgerking         0.358
#> 2    NJ        kfc         0.328
#> 3    NJ       roys         0.283
#> 4    NJ     wendys         0.260
#> 5    PA burgerking         0.321
#> 6    PA        kfc         0.236
#> # ... with 2 more rows
```

We can plot and compare the proportions easily in this format.
In general, ordering categorical variables alphabetically is useless, so we'll order the chains by the average of the NJ and PA `fullPropAfter`, using `forcats::fct_reorder`:

```r
ggplot(full_prop_by_state_chain,
       aes(x = forcats::fct_reorder(chain, fullPropAfter),
           y = fullPropAfter,
           colour = state)) +
  geom_point() +
  coord_flip() +
  labs(x = "chains")
```

<img src="causality_files/figure-html/unnamed-chunk-44-1.png" width="70%" style="display: block; margin: auto;" />

To calculate the before and after difference,

```r
full_prop_by_state_chain %>%
  spread(state, fullPropAfter) %>%
  mutate(diff = NJ - PA)
#> # A tibble: 4 x 4
#>        chain    NJ    PA   diff
#>        <chr> <dbl> <dbl>  <dbl>
#> 1 burgerking 0.358 0.321 0.0364
#> 2        kfc 0.328 0.236 0.0918
#> 3       roys 0.283 0.213 0.0697
#> 4     wendys 0.260 0.248 0.0117
```



### Before and After and Difference-in-Difference Designs

To compute the estimates in the before and after design first create a variable for the difference before and after the law passed.

```r
minwage <-
  minwage %>%
  mutate(totalBefore = fullBefore + partBefore,
         fullPropBefore = fullBefore / totalBefore)
```

The before-and-after analysis is the difference between the full-time employment before and after the minimum wage law passed looking only at NJ:

```r
filter(minwage, state == "NJ") %>%
  summarise(diff = mean(fullPropAfter) - mean(fullPropBefore))
#>     diff
#> 1 0.0239
```

The difference-in-differences design uses the difference in the before-and-after differences for each state.

```r
minwage %>%
  group_by(state) %>%
  summarise(diff = mean(fullPropAfter) - mean(fullPropBefore)) %>%
  spread(state, diff) %>%
  mutate(diff_in_diff = NJ - PA)
#> # A tibble: 1 x 3
#>       NJ      PA diff_in_diff
#>    <dbl>   <dbl>        <dbl>
#> 1 0.0239 -0.0377       0.0616
```

Let's create a single dataset with the mean values of each state before and after to visually look at each of these designs:

```r
full_prop_by_state <-
  minwage %>%
  group_by(state) %>%
  summarise_at(vars(fullPropAfter, fullPropBefore), mean) %>%
  gather(period, fullProp, -state) %>%
  mutate(period = recode(period, fullPropAfter = 1, fullPropBefore = 0))
full_prop_by_state
#> # A tibble: 4 x 3
#>   state period fullProp
#>   <chr>  <dbl>    <dbl>
#> 1    NJ      1    0.320
#> 2    PA      1    0.272
#> 3    NJ      0    0.297
#> 4    PA      0    0.310
```


```r
ggplot(full_prop_by_state, aes(x = period, y = fullProp, colour = state)) +
  geom_point() +
  geom_line() +
  scale_x_continuous(breaks = c(0, 1), labels = c("Before", "After"))
```

<img src="causality_files/figure-html/unnamed-chunk-50-1.png" width="70%" style="display: block; margin: auto;" />




## Descriptive Statistics for a Single Variable

To calculate the summary for the variables `wageBefore` and `wageAfter`:

```r
minwage %>%
  filter(state == "NJ") %>%
  select(wageBefore, wageAfter) %>%
  summary()
#>    wageBefore     wageAfter   
#>  Min.   :4.25   Min.   :5.00  
#>  1st Qu.:4.25   1st Qu.:5.05  
#>  Median :4.50   Median :5.05  
#>  Mean   :4.61   Mean   :5.08  
#>  3rd Qu.:4.87   3rd Qu.:5.05  
#>  Max.   :5.75   Max.   :5.75
```

We calculate the interquartile range for each state's wages after the passage of the law using the same grouped summarize as we used before:

```r
minwage %>%
  group_by(state) %>%
  summarise(wageAfter = IQR(wageAfter),
            wageBefore = IQR(wageBefore))
#> # A tibble: 2 x 3
#>   state wageAfter wageBefore
#>   <chr>     <dbl>      <dbl>
#> 1    NJ     0.000       0.62
#> 2    PA     0.575       0.75
```

Calculate the variance and standard deviation of `wageAfter` and `wageBefore` for each state:

```r
minwage %>%
  group_by(state) %>%
  summarise(wageAfter_sd = sd(wageAfter),
               wageAfter_var = var(wageAfter),
               wageBefore_sd = sd(wageBefore),
               wageBefore_var = var(wageBefore))
#> # A tibble: 2 x 5
#>   state wageAfter_sd wageAfter_var wageBefore_sd wageBefore_var
#>   <chr>        <dbl>         <dbl>         <dbl>          <dbl>
#> 1    NJ        0.106        0.0112         0.343          0.118
#> 2    PA        0.359        0.1291         0.358          0.128
```

`summarise_at` and `summarise_if` are two functions that allow you 
r, more compactly, using `summarise_at`:

```r
minwage %>%
  group_by(state) %>%
  summarise_at(vars(wageAfter, wageBefore), funs(sd, var))
#> # A tibble: 2 x 5
#>   state wageAfter_sd wageBefore_sd wageAfter_var wageBefore_var
#>   <chr>        <dbl>         <dbl>         <dbl>          <dbl>
#> 1    NJ        0.106         0.343        0.0112          0.118
#> 2    PA        0.359         0.358        0.1291          0.128
```
