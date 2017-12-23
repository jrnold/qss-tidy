
# Causality

## Prerequistes

This chapter only uses the tidyverse package

```r
library("tidyverse")
```

## Racial Discrimination in the Labor Market

The code in the book uses `table` and `addmargins` to construct the table.
However, this can be done easily with `dplyr` using grouping and summarizing.


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

For each combination of `race` and `call` let's count the observations:

```r
race_call_tab <-
  resume %>%
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
race_call_rate <-
  race_call_tab %>%
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

The **dplyr** function `filter` is a much improved version of `subset`.

To select black individuals in the data:

```r
resumeB <-
  resume %>%
  filter(race == "black")
dim(resumeB)
#> [1] 2435    4
head(resumeB)
#>   firstname    sex  race call
#> 1   Lakisha female black    0
#> 2   Latonya female black    0
#> 3     Kenya female black    0
#> 4   Latonya female black    0
#> 5    Tyrone   male black    0
#> 6     Aisha female black    0
```

And to calculate the callback rate

```r
resumeB %>%
  summarise(call_rate = mean(call))
#>   call_rate
#> 1    0.0645
```

To keep call and first name variables and those with black-sounding first names.

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

One way to do this is to calculate the call back rates for both sexes of 
black sounding names,

```r
resumeB <- resume %>%
  filter(race == "black") %>%
  group_by(sex) %>%
  summarise(black_rate = mean(call))
```
and white-sounding names

```r
resumeW <- resume %>%
  filter(race == "white") %>%
  group_by(sex) %>%
  summarise(white_rate = mean(call))
resumeW
#> # A tibble: 2 x 2
#>      sex white_rate
#>    <chr>      <dbl>
#> 1 female     0.0989
#> 2   male     0.0887
```
Then, merge `resumeB` and `resumeW` on `sex` and calculate the difference for both sexes.

```r
inner_join(resumeB, resumeW, by = "sex") %>%
  mutate(race_gap = white_rate - black_rate)
#> # A tibble: 2 x 4
#>      sex black_rate white_rate race_gap
#>    <chr>      <dbl>      <dbl>    <dbl>
#> 1 female     0.0663     0.0989   0.0326
#> 2   male     0.0583     0.0887   0.0304
```

This seems to be a little more code, but we didn't duplicate as much as in QSS, and this would easily scale to more than two categories.

A way to do this using the `spread` and gather functions from **tidy** are,
First, calculate the 

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
Now, use `spread()` to make each value of `race` a new column:

```r
library("tidyr")
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



### Simple conditional statements

See the **dlpyr** functions `if_else`, `recode` and `case_when`.
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


### Factor Variables

See R4DS Chapter 15 "Factors" and the package **forcats**

The code in this section works, but can be simplified by using the function
`case_when` which works in exactly these cases.

```r
resume %>%
  mutate(type = as.factor(case_when(
    .$race == "black" & .$sex == "female" ~ "BlackFemale",
    .$race == "black" & .$sex == "male" ~ "BlackMale",
    .$race == "white" & .$sex == "female" ~ "WhiteFemale",
    .$race == "white" & .$sex == "male" ~ "WhiteMale",
    TRUE ~ as.character(NA)
  )))
#>      firstname    sex  race call        type
#> 1      Allison female white    0 WhiteFemale
#> 2      Kristen female white    0 WhiteFemale
#> 3      Lakisha female black    0 BlackFemale
#> 4      Latonya female black    0 BlackFemale
#> 5       Carrie female white    0 WhiteFemale
#> 6          Jay   male white    0   WhiteMale
#> 7         Jill female white    0 WhiteFemale
#> 8        Kenya female black    0 BlackFemale
#> 9      Latonya female black    0 BlackFemale
#> 10      Tyrone   male black    0   BlackMale
#> 11       Aisha female black    0 BlackFemale
#> 12     Allison female white    0 WhiteFemale
#> 13       Aisha female black    0 BlackFemale
#> 14      Carrie female white    0 WhiteFemale
#> 15       Aisha female black    0 BlackFemale
#> 16    Geoffrey   male white    0   WhiteMale
#> 17     Matthew   male white    0   WhiteMale
#> 18      Tamika female black    0 BlackFemale
#> 19        Jill female white    0 WhiteFemale
#> 20     Latonya female black    0 BlackFemale
#> 21       Leroy   male black    0   BlackMale
#> 22        Todd   male white    0   WhiteMale
#> 23     Allison female white    0 WhiteFemale
#> 24      Carrie female white    0 WhiteFemale
#> 25        Greg   male white    0   WhiteMale
#> 26      Keisha female black    0 BlackFemale
#> 27      Keisha female black    0 BlackFemale
#> 28     Kristen female white    0 WhiteFemale
#> 29     Lakisha female black    0 BlackFemale
#> 30      Tamika female black    0 BlackFemale
#> 31     Allison female white    0 WhiteFemale
#> 32      Keisha female black    0 BlackFemale
#> 33     Kristen female white    0 WhiteFemale
#> 34     Latonya female black    0 BlackFemale
#> 35        Brad   male white    0   WhiteMale
#> 36        Jill female white    0 WhiteFemale
#> 37      Keisha female black    0 BlackFemale
#> 38      Keisha female black    0 BlackFemale
#> 39     Lakisha female black    0 BlackFemale
#> 40      Laurie female white    0 WhiteFemale
#> 41    Meredith female white    0 WhiteFemale
#> 42      Tyrone   male black    0   BlackMale
#> 43        Anne female white    0 WhiteFemale
#> 44       Emily female white    0 WhiteFemale
#> 45      Latoya female black    0 BlackFemale
#> 46      Tamika female black    0 BlackFemale
#> 47        Brad   male white    0   WhiteMale
#> 48      Latoya female black    0 BlackFemale
#> 49     Kristen female white    0 WhiteFemale
#> 50     Latonya female black    0 BlackFemale
#> 51      Latoya female black    0 BlackFemale
#> 52      Laurie female white    0 WhiteFemale
#> 53     Allison female white    0 WhiteFemale
#> 54       Ebony female black    0 BlackFemale
#> 55         Jay   male white    0   WhiteMale
#> 56      Keisha female black    0 BlackFemale
#> 57      Laurie female white    0 WhiteFemale
#> 58      Tyrone   male black    0   BlackMale
#> 59        Anne female white    0 WhiteFemale
#> 60     Lakisha female black    0 BlackFemale
#> 61     Latonya female black    0 BlackFemale
#> 62    Meredith female white    0 WhiteFemale
#> 63     Allison female white    0 WhiteFemale
#> 64      Carrie female white    0 WhiteFemale
#> 65       Ebony female black    0 BlackFemale
#> 66       Kenya female black    0 BlackFemale
#> 67     Lakisha female black    0 BlackFemale
#> 68      Laurie female white    0 WhiteFemale
#> 69       Aisha female black    0 BlackFemale
#> 70        Anne female white    0 WhiteFemale
#> 71     Brendan   male white    0   WhiteMale
#> 72       Hakim   male black    0   BlackMale
#> 73      Latoya female black    0 BlackFemale
#> 74      Laurie female white    0 WhiteFemale
#> 75      Laurie female white    0 WhiteFemale
#> 76       Leroy   male black    0   BlackMale
#> 77        Anne female white    0 WhiteFemale
#> 78       Kenya female black    0 BlackFemale
#> 79     Latonya female black    0 BlackFemale
#> 80    Meredith female white    0 WhiteFemale
#> 81       Jamal   male black    0   BlackMale
#> 82     Matthew   male white    0   WhiteMale
#> 83        Neil   male white    0   WhiteMale
#> 84      Tyrone   male black    0   BlackMale
#> 85       Leroy   male black    0   BlackMale
#> 86        Todd   male white    1   WhiteMale
#> 87        Brad   male white    0   WhiteMale
#> 88       Ebony female black    0 BlackFemale
#> 89        Jill female white    0 WhiteFemale
#> 90     Kristen female white    0 WhiteFemale
#> 91     Lakisha female black    0 BlackFemale
#> 92     Matthew   male white    0   WhiteMale
#> 93      Tamika female black    0 BlackFemale
#> 94    Tremayne   male black    0   BlackMale
#> 95       Aisha female black    0 BlackFemale
#> 96       Brett   male white    1   WhiteMale
#> 97     Darnell   male black    0   BlackMale
#> 98       Emily female white    0 WhiteFemale
#> 99     Latonya female black    0 BlackFemale
#> 100      Sarah female white    0 WhiteFemale
#> 101      Aisha female black    0 BlackFemale
#> 102       Anne female white    0 WhiteFemale
#> 103   Jermaine   male black    0   BlackMale
#> 104       Neil   male white    0   WhiteMale
#> 105    Allison female white    0 WhiteFemale
#> 106       Anne female white    1 WhiteFemale
#> 107     Keisha female black    0 BlackFemale
#> 108    Latonya female black    1 BlackFemale
#> 109    Latonya female black    0 BlackFemale
#> 110     Laurie female white    0 WhiteFemale
#> 111        Jay   male white    0   WhiteMale
#> 112    Lakisha female black    0 BlackFemale
#> 113       Anne female white    0 WhiteFemale
#> 114     Keisha female black    0 BlackFemale
#> 115    Kristen female white    0 WhiteFemale
#> 116    Lakisha female black    0 BlackFemale
#> 117    Allison female white    0 WhiteFemale
#> 118      Ebony female black    0 BlackFemale
#> 119     Keisha female black    0 BlackFemale
#> 120    Kristen female white    0 WhiteFemale
#> 121    Lakisha female black    0 BlackFemale
#> 122   Meredith female white    0 WhiteFemale
#> 123    Allison female white    0 WhiteFemale
#> 124    Kristen female white    0 WhiteFemale
#> 125    Lakisha female black    0 BlackFemale
#> 126    Lakisha female black    0 BlackFemale
#> 127    Tanisha female black    1 BlackFemale
#> 128       Todd   male white    1   WhiteMale
#> 129      Aisha female black    0 BlackFemale
#> 130       Anne female white    0 WhiteFemale
#> 131       Jill female white    0 WhiteFemale
#> 132     Latoya female black    0 BlackFemale
#> 133       Neil   male white    0   WhiteMale
#> 134     Tamika female black    0 BlackFemale
#> 135       Anne female white    0 WhiteFemale
#> 136   Geoffrey   male white    0   WhiteMale
#> 137     Latoya female black    0 BlackFemale
#> 138    Rasheed   male black    0   BlackMale
#> 139      Aisha female black    0 BlackFemale
#> 140    Allison female white    0 WhiteFemale
#> 141     Carrie female white    0 WhiteFemale
#> 142      Ebony female black    0 BlackFemale
#> 143      Kenya female black    0 BlackFemale
#> 144    Kristen female white    0 WhiteFemale
#> 145   Jermaine   male black    0   BlackMale
#> 146     Laurie female white    0 WhiteFemale
#> 147    Allison female white    0 WhiteFemale
#> 148    Kristen female white    0 WhiteFemale
#> 149    Lakisha female black    0 BlackFemale
#> 150    Latonya female black    0 BlackFemale
#> 151       Brad   male white    0   WhiteMale
#> 152      Leroy   male black    0   BlackMale
#> 153      Emily female white    0 WhiteFemale
#> 154    Latonya female black    0 BlackFemale
#> 155     Latoya female black    0 BlackFemale
#> 156     Laurie female white    0 WhiteFemale
#> 157      Aisha female black    0 BlackFemale
#> 158    Allison female white    0 WhiteFemale
#> 159      Ebony female black    0 BlackFemale
#> 160   Jermaine   male black    0   BlackMale
#> 161    Kristen female white    0 WhiteFemale
#> 162    Latonya female black    0 BlackFemale
#> 163     Laurie female white    0 WhiteFemale
#> 164     Laurie female white    0 WhiteFemale
#> 165       Anne female white    0 WhiteFemale
#> 166    Brendan   male white    1   WhiteMale
#> 167     Kareem   male black    0   BlackMale
#> 168     Keisha female black    0 BlackFemale
#> 169    Matthew   male white    1   WhiteMale
#> 170   Meredith female white    0 WhiteFemale
#> 171    Tanisha female black    0 BlackFemale
#> 172    Tanisha female black    1 BlackFemale
#> 173      Aisha female black    0 BlackFemale
#> 174    Allison female white    0 WhiteFemale
#> 175    Allison female white    0 WhiteFemale
#> 176       Anne female white    0 WhiteFemale
#> 177    Brendan   male white    0   WhiteMale
#> 178      Brett   male white    0   WhiteMale
#> 179      Brett   male white    0   WhiteMale
#> 180      Brett   male white    0   WhiteMale
#> 181      Ebony female black    0 BlackFemale
#> 182   Geoffrey   male white    0   WhiteMale
#> 183        Jay   male white    0   WhiteMale
#> 184       Jill female white    0 WhiteFemale
#> 185     Keisha female black    0 BlackFemale
#> 186     Keisha female black    0 BlackFemale
#> 187      Kenya female black    0 BlackFemale
#> 188      Kenya female black    0 BlackFemale
#> 189    Lakisha female black    0 BlackFemale
#> 190     Latoya female black    0 BlackFemale
#> 191     Latoya female black    0 BlackFemale
#> 192     Laurie female white    0 WhiteFemale
#> 193    Matthew   male white    0   WhiteMale
#> 194    Rasheed   male black    0   BlackMale
#> 195      Sarah female white    0 WhiteFemale
#> 196      Sarah female white    0 WhiteFemale
#> 197     Tamika female black    0 BlackFemale
#> 198    Tanisha female black    0 BlackFemale
#> 199    Tanisha female black    0 BlackFemale
#> 200   Tremayne   male black    0   BlackMale
#> 201    Lakisha female black    1 BlackFemale
#> 202   Meredith female white    1 WhiteFemale
#> 203       Anne female white    0 WhiteFemale
#> 204    Latonya female black    0 BlackFemale
#> 205      Sarah female white    0 WhiteFemale
#> 206     Tamika female black    0 BlackFemale
#> 207       Jill female white    0 WhiteFemale
#> 208     Keisha female black    0 BlackFemale
#> 209    Lakisha female black    0 BlackFemale
#> 210   Meredith female white    0 WhiteFemale
#> 211       Jill female white    1 WhiteFemale
#> 212     Keisha female black    0 BlackFemale
#> 213    Lakisha female black    0 BlackFemale
#> 214   Meredith female white    0 WhiteFemale
#> 215     Carrie female white    0 WhiteFemale
#> 216       Greg   male white    0   WhiteMale
#> 217      Kenya female black    0 BlackFemale
#> 218   Tremayne   male black    0   BlackMale
#> 219      Kenya female black    0 BlackFemale
#> 220       Neil   male white    0   WhiteMale
#> 221      Emily female white    0 WhiteFemale
#> 222       Jill female white    0 WhiteFemale
#> 223    Latonya female black    0 BlackFemale
#> 224    Tanisha female black    0 BlackFemale
#> 225      Ebony female black    0 BlackFemale
#> 226    Kristen female white    0 WhiteFemale
#> 227    Latonya female black    0 BlackFemale
#> 228     Laurie female white    0 WhiteFemale
#> 229       Anne female white    0 WhiteFemale
#> 230      Emily female white    0 WhiteFemale
#> 231     Keisha female black    0 BlackFemale
#> 232    Tanisha female black    0 BlackFemale
#> 233    Allison female white    0 WhiteFemale
#> 234    Kristen female white    0 WhiteFemale
#> 235    Latonya female black    0 BlackFemale
#> 236    Tanisha female black    0 BlackFemale
#> 237      Aisha female black    0 BlackFemale
#> 238    Allison female white    0 WhiteFemale
#> 239       Anne female white    0 WhiteFemale
#> 240    Latonya female black    0 BlackFemale
#> 241     Latoya female black    0 BlackFemale
#> 242      Sarah female white    0 WhiteFemale
#> 243      Aisha female black    0 BlackFemale
#> 244       Anne female white    0 WhiteFemale
#> 245     Latoya female black    0 BlackFemale
#> 246     Laurie female white    0 WhiteFemale
#> 247       Anne female white    0 WhiteFemale
#> 248     Carrie female white    1 WhiteFemale
#> 249      Ebony female black    0 BlackFemale
#> 250    Lakisha female black    0 BlackFemale
#> 251    Allison female white    0 WhiteFemale
#> 252     Keisha female black    0 BlackFemale
#> 253    Kristen female white    0 WhiteFemale
#> 254    Tanisha female black    0 BlackFemale
#> 255      Aisha female black    0 BlackFemale
#> 256      Emily female white    0 WhiteFemale
#> 257    Latonya female black    0 BlackFemale
#> 258      Sarah female white    0 WhiteFemale
#> 259   Geoffrey   male white    0   WhiteMale
#> 260     Kareem   male black    1   BlackMale
#> 261    Kristen female white    0 WhiteFemale
#> 262    Rasheed   male black    0   BlackMale
#> 263       Todd   male white    0   WhiteMale
#> 264     Tyrone   male black    0   BlackMale
#> 265    Brendan   male white    0   WhiteMale
#> 266      Jamal   male black    0   BlackMale
#> 267    Matthew   male white    0   WhiteMale
#> 268   Meredith female white    1 WhiteFemale
#> 269    Rasheed   male black    0   BlackMale
#> 270   Tremayne   male black    1   BlackMale
#> 271       Anne female white    1 WhiteFemale
#> 272      Ebony female black    1 BlackFemale
#> 273    Kristen female white    1 WhiteFemale
#> 274     Tamika female black    0 BlackFemale
#> 275      Aisha female black    0 BlackFemale
#> 276    Allison female white    0 WhiteFemale
#> 277      Emily female white    0 WhiteFemale
#> 278    Kristen female white    0 WhiteFemale
#> 279     Latoya female black    0 BlackFemale
#> 280     Tamika female black    0 BlackFemale
#> 281      Aisha female black    0 BlackFemale
#> 282       Anne female white    0 WhiteFemale
#> 283      Emily female white    0 WhiteFemale
#> 284       Jill female white    0 WhiteFemale
#> 285     Keisha female black    0 BlackFemale
#> 286    Lakisha female black    0 BlackFemale
#> 287      Ebony female black    0 BlackFemale
#> 288      Kenya female black    0 BlackFemale
#> 289    Kristen female white    0 WhiteFemale
#> 290   Meredith female white    0 WhiteFemale
#> 291      Aisha female black    0 BlackFemale
#> 292       Anne female white    0 WhiteFemale
#> 293      Emily female white    0 WhiteFemale
#> 294      Emily female white    0 WhiteFemale
#> 295      Kenya female black    0 BlackFemale
#> 296    Latonya female black    0 BlackFemale
#> 297       Anne female white    0 WhiteFemale
#> 298      Emily female white    0 WhiteFemale
#> 299     Keisha female black    0 BlackFemale
#> 300     Tamika female black    0 BlackFemale
#> 301       Anne female white    0 WhiteFemale
#> 302      Emily female white    0 WhiteFemale
#> 303     Keisha female black    0 BlackFemale
#> 304      Kenya female black    0 BlackFemale
#> 305     Latoya female black    0 BlackFemale
#> 306       Neil   male white    0   WhiteMale
#> 307      Aisha female black    0 BlackFemale
#> 308       Anne female white    0 WhiteFemale
#> 309      Emily female white    0 WhiteFemale
#> 310     Tamika female black    0 BlackFemale
#> 311     Carrie female white    0 WhiteFemale
#> 312       Jill female white    0 WhiteFemale
#> 313     Keisha female black    0 BlackFemale
#> 314    Latonya female black    0 BlackFemale
#> 315      Sarah female white    0 WhiteFemale
#> 316     Tyrone   male black    0   BlackMale
#> 317     Carrie female white    0 WhiteFemale
#> 318      Emily female white    0 WhiteFemale
#> 319     Latoya female black    0 BlackFemale
#> 320    Tanisha female black    0 BlackFemale
#> 321      Aisha female black    0 BlackFemale
#> 322    Kristen female white    0 WhiteFemale
#> 323    Lakisha female black    0 BlackFemale
#> 324     Laurie female white    0 WhiteFemale
#> 325    Allison female white    0 WhiteFemale
#> 326       Jill female white    0 WhiteFemale
#> 327     Keisha female black    0 BlackFemale
#> 328    Kristen female white    0 WhiteFemale
#> 329    Lakisha female black    0 BlackFemale
#> 330      Leroy   male black    0   BlackMale
#> 331       Brad   male white    0   WhiteMale
#> 332     Keisha female black    0 BlackFemale
#> 333    Allison female white    0 WhiteFemale
#> 334     Carrie female white    0 WhiteFemale
#> 335    Latonya female black    0 BlackFemale
#> 336     Latoya female black    0 BlackFemale
#> 337     Carrie female white    0 WhiteFemale
#> 338      Ebony female black    0 BlackFemale
#> 339    Latonya female black    0 BlackFemale
#> 340     Laurie female white    0 WhiteFemale
#> 341   Meredith female white    0 WhiteFemale
#> 342   Tremayne   male black    0   BlackMale
#> 343    Allison female white    0 WhiteFemale
#> 344     Carrie female white    0 WhiteFemale
#> 345    Lakisha female black    0 BlackFemale
#> 346     Tamika female black    0 BlackFemale
#> 347       Anne female white    0 WhiteFemale
#> 348    Darnell   male black    0   BlackMale
#> 349       Greg   male white    1   WhiteMale
#> 350     Tamika female black    0 BlackFemale
#> 351    Allison female white    0 WhiteFemale
#> 352     Carrie female white    0 WhiteFemale
#> 353      Kenya female black    0 BlackFemale
#> 354   Tremayne   male black    0   BlackMale
#> 355      Aisha female black    0 BlackFemale
#> 356      Aisha female black    0 BlackFemale
#> 357       Brad   male white    0   WhiteMale
#> 358       Brad   male white    0   WhiteMale
#> 359    Brendan   male white    0   WhiteMale
#> 360      Ebony female black    0 BlackFemale
#> 361   Geoffrey   male white    0   WhiteMale
#> 362       Greg   male white    0   WhiteMale
#> 363       Greg   male white    0   WhiteMale
#> 364       Greg   male white    0   WhiteMale
#> 365      Hakim   male black    0   BlackMale
#> 366        Jay   male white    0   WhiteMale
#> 367   Jermaine   male black    0   BlackMale
#> 368     Kareem   male black    0   BlackMale
#> 369     Kareem   male black    0   BlackMale
#> 370    Latonya female black    0 BlackFemale
#> 371      Leroy   male black    0   BlackMale
#> 372   Meredith female white    0 WhiteFemale
#> 373      Sarah female white    0 WhiteFemale
#> 374      Sarah female white    0 WhiteFemale
#> 375     Tamika female black    0 BlackFemale
#> 376    Tanisha female black    0 BlackFemale
#> 377       Todd   male white    0   WhiteMale
#> 378   Tremayne   male black    0   BlackMale
#> 379      Emily female white    0 WhiteFemale
#> 380      Kenya female black    0 BlackFemale
#> 381     Latoya female black    0 BlackFemale
#> 382      Sarah female white    0 WhiteFemale
#> 383     Carrie female white    1 WhiteFemale
#> 384   Jermaine   male black    1   BlackMale
#> 385    Matthew   male white    0   WhiteMale
#> 386     Tyrone   male black    0   BlackMale
#> 387    Allison female white    0 WhiteFemale
#> 388      Ebony female black    0 BlackFemale
#> 389        Jay   male white    1   WhiteMale
#> 390     Tamika female black    0 BlackFemale
#> 391       Anne female white    0 WhiteFemale
#> 392    Latonya female black    0 BlackFemale
#> 393     Laurie female white    0 WhiteFemale
#> 394    Tanisha female black    0 BlackFemale
#> 395      Ebony female black    0 BlackFemale
#> 396       Jill female white    0 WhiteFemale
#> 397    Kristen female white    0 WhiteFemale
#> 398    Lakisha female black    0 BlackFemale
#> 399     Carrie female white    0 WhiteFemale
#> 400       Jill female white    0 WhiteFemale
#> 401     Keisha female black    0 BlackFemale
#> 402    Rasheed   male black    0   BlackMale
#> 403    Allison female white    0 WhiteFemale
#> 404      Kenya female black    0 BlackFemale
#> 405   Meredith female white    0 WhiteFemale
#> 406     Tamika female black    0 BlackFemale
#> 407    Matthew   male white    0   WhiteMale
#> 408   Tremayne   male black    0   BlackMale
#> 409      Ebony female black    0 BlackFemale
#> 410      Emily female white    0 WhiteFemale
#> 411       Jill female white    0 WhiteFemale
#> 412     Tamika female black    0 BlackFemale
#> 413    Darnell   male black    0   BlackMale
#> 414      Emily female white    1 WhiteFemale
#> 415       Neil   male white    0   WhiteMale
#> 416     Tamika female black    0 BlackFemale
#> 417    Latonya female black    0 BlackFemale
#> 418     Laurie female white    0 WhiteFemale
#> 419      Sarah female white    0 WhiteFemale
#> 420    Tanisha female black    0 BlackFemale
#> 421     Carrie female white    0 WhiteFemale
#> 422     Kareem   male black    0   BlackMale
#> 423       Todd   male white    0   WhiteMale
#> 424     Tyrone   male black    0   BlackMale
#> 425       Anne female white    0 WhiteFemale
#> 426       Jill female white    0 WhiteFemale
#> 427      Kenya female black    1 BlackFemale
#> 428     Latoya female black    1 BlackFemale
#> 429       Anne female white    0 WhiteFemale
#> 430      Ebony female black    0 BlackFemale
#> 431      Emily female white    0 WhiteFemale
#> 432     Keisha female black    0 BlackFemale
#> 433    Allison female white    0 WhiteFemale
#> 434    Kristen female white    0 WhiteFemale
#> 435    Lakisha female black    0 BlackFemale
#> 436    Tanisha female black    0 BlackFemale
#> 437    Brendan   male white    0   WhiteMale
#> 438     Laurie female white    0 WhiteFemale
#> 439    Rasheed   male black    0   BlackMale
#> 440     Tyrone   male black    0   BlackMale
#> 441       Jill female white    0 WhiteFemale
#> 442    Lakisha female black    0 BlackFemale
#> 443    Matthew   male white    1   WhiteMale
#> 444     Tamika female black    0 BlackFemale
#> 445      Aisha female black    0 BlackFemale
#> 446      Emily female white    0 WhiteFemale
#> 447     Keisha female black    0 BlackFemale
#> 448      Sarah female white    1 WhiteFemale
#> 449       Anne female white    0 WhiteFemale
#> 450      Emily female white    0 WhiteFemale
#> 451     Latoya female black    0 BlackFemale
#> 452     Tamika female black    0 BlackFemale
#> 453      Kenya female black    0 BlackFemale
#> 454    Kristen female white    0 WhiteFemale
#> 455    Latonya female black    0 BlackFemale
#> 456     Laurie female white    0 WhiteFemale
#> 457     Carrie female white    0 WhiteFemale
#> 458       Jill female white    0 WhiteFemale
#> 459     Keisha female black    0 BlackFemale
#> 460     Latoya female black    0 BlackFemale
#> 461      Emily female white    0 WhiteFemale
#> 462    Kristen female white    0 WhiteFemale
#> 463     Latoya female black    0 BlackFemale
#> 464     Tamika female black    0 BlackFemale
#> 465     Keisha female black    0 BlackFemale
#> 466    Kristen female white    0 WhiteFemale
#> 467    Lakisha female black    0 BlackFemale
#> 468   Meredith female white    0 WhiteFemale
#> 469    Allison female white    0 WhiteFemale
#> 470    Lakisha female black    0 BlackFemale
#> 471   Meredith female white    0 WhiteFemale
#> 472    Tanisha female black    0 BlackFemale
#> 473      Emily female white    1 WhiteFemale
#> 474     Keisha female black    0 BlackFemale
#> 475    Latonya female black    1 BlackFemale
#> 476      Sarah female white    1 WhiteFemale
#> 477      Aisha female black    1 BlackFemale
#> 478       Jill female white    1 WhiteFemale
#> 479    Latonya female black    1 BlackFemale
#> 480      Sarah female white    1 WhiteFemale
#> 481       Anne female white    0 WhiteFemale
#> 482      Kenya female black    0 BlackFemale
#> 483     Latoya female black    0 BlackFemale
#> 484      Sarah female white    0 WhiteFemale
#> 485    Allison female white    0 WhiteFemale
#> 486     Keisha female black    0 BlackFemale
#> 487   Meredith female white    0 WhiteFemale
#> 488    Tanisha female black    0 BlackFemale
#> 489       Anne female white    0 WhiteFemale
#> 490     Carrie female white    0 WhiteFemale
#> 491    Latonya female black    0 BlackFemale
#> 492    Tanisha female black    0 BlackFemale
#> 493    Allison female white    0 WhiteFemale
#> 494       Anne female white    0 WhiteFemale
#> 495      Ebony female black    0 BlackFemale
#> 496       Jill female white    0 WhiteFemale
#> 497     Keisha female black    0 BlackFemale
#> 498    Lakisha female black    0 BlackFemale
#> 499    Latonya female black    0 BlackFemale
#> 500       Todd   male white    0   WhiteMale
#> 501     Carrie female white    0 WhiteFemale
#> 502   Meredith female white    0 WhiteFemale
#> 503     Tamika female black    0 BlackFemale
#> 504    Tanisha female black    0 BlackFemale
#> 505      Aisha female black    0 BlackFemale
#> 506       Anne female white    0 WhiteFemale
#> 507      Emily female white    0 WhiteFemale
#> 508    Latonya female black    0 BlackFemale
#> 509      Aisha female black    0 BlackFemale
#> 510    Allison female white    0 WhiteFemale
#> 511       Jill female white    0 WhiteFemale
#> 512     Tamika female black    0 BlackFemale
#> 513       Anne female white    0 WhiteFemale
#> 514      Ebony female black    0 BlackFemale
#> 515       Jill female white    0 WhiteFemale
#> 516     Tamika female black    0 BlackFemale
#> 517     Carrie female white    0 WhiteFemale
#> 518      Kenya female black    0 BlackFemale
#> 519      Sarah female white    0 WhiteFemale
#> 520    Tanisha female black    0 BlackFemale
#> 521       Anne female white    0 WhiteFemale
#> 522     Keisha female black    0 BlackFemale
#> 523    Allison female white    0 WhiteFemale
#> 524     Latoya female black    0 BlackFemale
#> 525      Sarah female white    0 WhiteFemale
#> 526     Tamika female black    0 BlackFemale
#> 527       Anne female white    0 WhiteFemale
#> 528       Jill female white    0 WhiteFemale
#> 529      Kenya female black    0 BlackFemale
#> 530    Lakisha female black    0 BlackFemale
#> 531       Jill female white    0 WhiteFemale
#> 532     Keisha female black    0 BlackFemale
#> 533    Lakisha female black    0 BlackFemale
#> 534   Meredith female white    0 WhiteFemale
#> 535      Aisha female black    0 BlackFemale
#> 536    Allison female white    0 WhiteFemale
#> 537    Allison female white    0 WhiteFemale
#> 538      Hakim   male black    0   BlackMale
#> 539      Sarah female white    0 WhiteFemale
#> 540     Tamika female black    0 BlackFemale
#> 541      Aisha female black    0 BlackFemale
#> 542     Latoya female black    0 BlackFemale
#> 543     Laurie female white    0 WhiteFemale
#> 544   Meredith female white    0 WhiteFemale
#> 545      Aisha female black    0 BlackFemale
#> 546    Allison female white    0 WhiteFemale
#> 547    Allison female white    0 WhiteFemale
#> 548    Allison female white    0 WhiteFemale
#> 549       Anne female white    0 WhiteFemale
#> 550       Brad   male white    0   WhiteMale
#> 551    Brendan   male white    0   WhiteMale
#> 552    Darnell   male black    0   BlackMale
#> 553      Emily female white    0 WhiteFemale
#> 554   Geoffrey   male white    0   WhiteMale
#> 555       Greg   male white    0   WhiteMale
#> 556      Hakim   male black    0   BlackMale
#> 557      Hakim   male black    0   BlackMale
#> 558        Jay   male white    0   WhiteMale
#> 559   Jermaine   male black    0   BlackMale
#> 560     Kareem   male black    0   BlackMale
#> 561      Kenya female black    0 BlackFemale
#> 562      Kenya female black    0 BlackFemale
#> 563    Lakisha female black    0 BlackFemale
#> 564    Latonya female black    0 BlackFemale
#> 565   Meredith female white    0 WhiteFemale
#> 566       Neil   male white    0   WhiteMale
#> 567       Neil   male white    0   WhiteMale
#> 568    Rasheed   male black    0   BlackMale
#> 569     Tamika female black    0 BlackFemale
#> 570    Tanisha female black    0 BlackFemale
#> 571       Todd   male white    0   WhiteMale
#> 572   Tremayne   male black    0   BlackMale
#> 573       Brad   male white    0   WhiteMale
#> 574      Ebony female black    0 BlackFemale
#> 575      Jamal   male black    0   BlackMale
#> 576        Jay   male white    0   WhiteMale
#> 577      Ebony female black    1 BlackFemale
#> 578      Emily female white    1 WhiteFemale
#> 579    Latonya female black    0 BlackFemale
#> 580   Meredith female white    0 WhiteFemale
#> 581    Lakisha female black    0 BlackFemale
#> 582    Latonya female black    0 BlackFemale
#> 583     Laurie female white    1 WhiteFemale
#> 584   Meredith female white    0 WhiteFemale
#> 585    Darnell   male black    0   BlackMale
#> 586   Geoffrey   male white    0   WhiteMale
#> 587    Kristen female white    0 WhiteFemale
#> 588     Tyrone   male black    0   BlackMale
#> 589       Jill female white    0 WhiteFemale
#> 590    Latonya female black    0 BlackFemale
#> 591      Sarah female white    0 WhiteFemale
#> 592    Tanisha female black    0 BlackFemale
#> 593    Allison female white    1 WhiteFemale
#> 594      Ebony female black    0 BlackFemale
#> 595    Lakisha female black    0 BlackFemale
#> 596     Laurie female white    1 WhiteFemale
#> 597    Allison female white    0 WhiteFemale
#> 598      Emily female white    0 WhiteFemale
#> 599     Tamika female black    0 BlackFemale
#> 600    Tanisha female black    0 BlackFemale
#> 601    Allison female white    1 WhiteFemale
#> 602      Brett   male white    0   WhiteMale
#> 603   Jermaine   male black    0   BlackMale
#> 604    Tanisha female black    0 BlackFemale
#> 605      Aisha female black    0 BlackFemale
#> 606    Allison female white    0 WhiteFemale
#> 607       Jill female white    0 WhiteFemale
#> 608    Latonya female black    0 BlackFemale
#> 609     Carrie female white    0 WhiteFemale
#> 610      Ebony female black    0 BlackFemale
#> 611     Latoya female black    0 BlackFemale
#> 612     Laurie female white    0 WhiteFemale
#> 613     Carrie female white    0 WhiteFemale
#> 614     Keisha female black    0 BlackFemale
#> 615    Latonya female black    0 BlackFemale
#> 616      Sarah female white    0 WhiteFemale
#> 617    Allison female white    0 WhiteFemale
#> 618      Ebony female black    0 BlackFemale
#> 619      Kenya female black    0 BlackFemale
#> 620      Sarah female white    0 WhiteFemale
#> 621      Aisha female black    0 BlackFemale
#> 622       Jill female white    0 WhiteFemale
#> 623    Kristen female white    0 WhiteFemale
#> 624    Latonya female black    0 BlackFemale
#> 625       Anne female white    0 WhiteFemale
#> 626      Ebony female black    0 BlackFemale
#> 627    Kristen female white    0 WhiteFemale
#> 628     Latoya female black    0 BlackFemale
#> 629      Ebony female black    0 BlackFemale
#> 630       Jill female white    0 WhiteFemale
#> 631      Sarah female white    0 WhiteFemale
#> 632     Tamika female black    0 BlackFemale
#> 633      Emily female white    0 WhiteFemale
#> 634     Keisha female black    0 BlackFemale
#> 635      Kenya female black    0 BlackFemale
#> 636      Sarah female white    0 WhiteFemale
#> 637      Aisha female black    0 BlackFemale
#> 638      Ebony female black    0 BlackFemale
#> 639       Jill female white    0 WhiteFemale
#> 640   Meredith female white    0 WhiteFemale
#> 641       Anne female white    0 WhiteFemale
#> 642      Emily female white    0 WhiteFemale
#> 643     Latoya female black    0 BlackFemale
#> 644     Tamika female black    0 BlackFemale
#> 645    Allison female white    0 WhiteFemale
#> 646      Emily female white    0 WhiteFemale
#> 647      Kenya female black    0 BlackFemale
#> 648     Tamika female black    0 BlackFemale
#> 649    Allison female white    0 WhiteFemale
#> 650     Carrie female white    0 WhiteFemale
#> 651     Keisha female black    0 BlackFemale
#> 652    Lakisha female black    0 BlackFemale
#> 653     Laurie female white    0 WhiteFemale
#> 654    Tanisha female black    0 BlackFemale
#> 655       Anne female white    0 WhiteFemale
#> 656     Carrie female white    0 WhiteFemale
#> 657     Keisha female black    0 BlackFemale
#> 658     Tamika female black    0 BlackFemale
#> 659    Allison female white    0 WhiteFemale
#> 660    Latonya female black    0 BlackFemale
#> 661     Laurie female white    0 WhiteFemale
#> 662     Tamika female black    0 BlackFemale
#> 663    Allison female white    0 WhiteFemale
#> 664     Keisha female black    0 BlackFemale
#> 665   Meredith female white    0 WhiteFemale
#> 666    Tanisha female black    0 BlackFemale
#> 667       Jill female white    0 WhiteFemale
#> 668    Lakisha female black    0 BlackFemale
#> 669      Sarah female white    0 WhiteFemale
#> 670     Tamika female black    0 BlackFemale
#> 671       Anne female white    0 WhiteFemale
#> 672      Ebony female black    0 BlackFemale
#> 673      Sarah female white    0 WhiteFemale
#> 674    Tanisha female black    0 BlackFemale
#> 675     Carrie female white    0 WhiteFemale
#> 676     Keisha female black    0 BlackFemale
#> 677    Latonya female black    0 BlackFemale
#> 678      Sarah female white    0 WhiteFemale
#> 679     Carrie female white    0 WhiteFemale
#> 680     Latoya female black    0 BlackFemale
#> 681   Meredith female white    0 WhiteFemale
#> 682    Tanisha female black    0 BlackFemale
#> 683    Allison female white    0 WhiteFemale
#> 684      Ebony female black    0 BlackFemale
#> 685    Lakisha female black    0 BlackFemale
#> 686     Laurie female white    0 WhiteFemale
#> 687      Kenya female black    0 BlackFemale
#> 688     Laurie female white    0 WhiteFemale
#> 689        Jay   male white    0   WhiteMale
#> 690     Keisha female black    0 BlackFemale
#> 691      Emily female white    0 WhiteFemale
#> 692      Kenya female black    0 BlackFemale
#> 693      Sarah female white    0 WhiteFemale
#> 694    Tanisha female black    0 BlackFemale
#> 695      Aisha female black    0 BlackFemale
#> 696    Allison female white    0 WhiteFemale
#> 697    Allison female white    0 WhiteFemale
#> 698       Anne female white    0 WhiteFemale
#> 699       Brad   male white    0   WhiteMale
#> 700       Brad   male white    0   WhiteMale
#> 701      Brett   male white    0   WhiteMale
#> 702     Carrie female white    0 WhiteFemale
#> 703     Carrie female white    0 WhiteFemale
#> 704      Emily female white    0 WhiteFemale
#> 705      Jamal   male black    0   BlackMale
#> 706        Jay   male white    0   WhiteMale
#> 707        Jay   male white    0   WhiteMale
#> 708   Jermaine   male black    0   BlackMale
#> 709       Jill female white    0 WhiteFemale
#> 710     Kareem   male black    0   BlackMale
#> 711     Kareem   male black    0   BlackMale
#> 712     Kareem   male black    0   BlackMale
#> 713     Keisha female black    0 BlackFemale
#> 714    Latonya female black    0 BlackFemale
#> 715    Latonya female black    0 BlackFemale
#> 716     Latoya female black    0 BlackFemale
#> 717     Laurie female white    0 WhiteFemale
#> 718      Leroy   male black    0   BlackMale
#> 719       Neil   male white    0   WhiteMale
#> 720    Rasheed   male black    0   BlackMale
#> 721      Sarah female white    0 WhiteFemale
#> 722      Sarah female white    0 WhiteFemale
#> 723    Tanisha female black    0 BlackFemale
#> 724    Tanisha female black    0 BlackFemale
#> 725   Tremayne   male black    0   BlackMale
#> 726     Tyrone   male black    0   BlackMale
#> 727    Kristen female white    0 WhiteFemale
#> 728    Latonya female black    0 BlackFemale
#> 729      Sarah female white    0 WhiteFemale
#> 730    Tanisha female black    0 BlackFemale
#> 731      Ebony female black    0 BlackFemale
#> 732      Emily female white    0 WhiteFemale
#> 733    Lakisha female black    0 BlackFemale
#> 734      Sarah female white    0 WhiteFemale
#> 735       Anne female white    1 WhiteFemale
#> 736     Latoya female black    1 BlackFemale
#> 737   Meredith female white    0 WhiteFemale
#> 738    Tanisha female black    0 BlackFemale
#> 739       Anne female white    0 WhiteFemale
#> 740      Hakim   male black    0   BlackMale
#> 741        Jay   male white    0   WhiteMale
#> 742     Latoya female black    0 BlackFemale
#> 743      Aisha female black    0 BlackFemale
#> 744      Emily female white    0 WhiteFemale
#> 745       Jill female white    0 WhiteFemale
#> 746     Keisha female black    0 BlackFemale
#> 747     Laurie female white    0 WhiteFemale
#> 748     Tamika female black    0 BlackFemale
#> 749     Carrie female white    0 WhiteFemale
#> 750    Lakisha female black    0 BlackFemale
#> 751     Latoya female black    0 BlackFemale
#> 752     Laurie female white    0 WhiteFemale
#> 753    Allison female white    0 WhiteFemale
#> 754    Kristen female white    0 WhiteFemale
#> 755    Lakisha female black    0 BlackFemale
#> 756    Latonya female black    0 BlackFemale
#> 757    Allison female white    1 WhiteFemale
#> 758     Keisha female black    0 BlackFemale
#> 759     Laurie female white    1 WhiteFemale
#> 760    Tanisha female black    0 BlackFemale
#> 761       Jill female white    0 WhiteFemale
#> 762    Kristen female white    0 WhiteFemale
#> 763    Lakisha female black    0 BlackFemale
#> 764     Tamika female black    0 BlackFemale
#> 765     Latoya female black    1 BlackFemale
#> 766     Laurie female white    1 WhiteFemale
#> 767      Sarah female white    0 WhiteFemale
#> 768     Tamika female black    0 BlackFemale
#> 769      Ebony female black    0 BlackFemale
#> 770    Lakisha female black    0 BlackFemale
#> 771   Meredith female white    0 WhiteFemale
#> 772      Sarah female white    0 WhiteFemale
#> 773    Allison female white    0 WhiteFemale
#> 774      Kenya female black    0 BlackFemale
#> 775     Laurie female white    0 WhiteFemale
#> 776     Tamika female black    0 BlackFemale
#> 777    Allison female white    0 WhiteFemale
#> 778     Keisha female black    0 BlackFemale
#> 779    Lakisha female black    0 BlackFemale
#> 780   Meredith female white    0 WhiteFemale
#> 781    Latonya female black    0 BlackFemale
#> 782     Laurie female white    0 WhiteFemale
#> 783      Aisha female black    0 BlackFemale
#> 784    Allison female white    0 WhiteFemale
#> 785     Carrie female white    0 WhiteFemale
#> 786    Tanisha female black    0 BlackFemale
#> 787       Anne female white    0 WhiteFemale
#> 788     Latoya female black    0 BlackFemale
#> 789     Laurie female white    0 WhiteFemale
#> 790     Tamika female black    0 BlackFemale
#> 791     Carrie female white    0 WhiteFemale
#> 792    Lakisha female black    0 BlackFemale
#> 793    Latonya female black    0 BlackFemale
#> 794      Sarah female white    0 WhiteFemale
#> 795      Ebony female black    0 BlackFemale
#> 796    Kristen female white    0 WhiteFemale
#> 797       Anne female white    0 WhiteFemale
#> 798      Emily female white    0 WhiteFemale
#> 799      Kenya female black    0 BlackFemale
#> 800     Latoya female black    0 BlackFemale
#> 801    Allison female white    0 WhiteFemale
#> 802      Emily female white    0 WhiteFemale
#> 803     Tamika female black    0 BlackFemale
#> 804    Tanisha female black    0 BlackFemale
#> 805      Aisha female black    0 BlackFemale
#> 806    Allison female white    0 WhiteFemale
#> 807     Carrie female white    1 WhiteFemale
#> 808     Latoya female black    0 BlackFemale
#> 809      Ebony female black    0 BlackFemale
#> 810       Jill female white    0 WhiteFemale
#> 811    Kristen female white    0 WhiteFemale
#> 812     Latoya female black    0 BlackFemale
#> 813       Anne female white    0 WhiteFemale
#> 814      Emily female white    0 WhiteFemale
#> 815     Keisha female black    0 BlackFemale
#> 816      Kenya female black    0 BlackFemale
#> 817     Carrie female white    0 WhiteFemale
#> 818      Ebony female black    0 BlackFemale
#> 819   Meredith female white    0 WhiteFemale
#> 820     Tamika female black    0 BlackFemale
#> 821    Kristen female white    1 WhiteFemale
#> 822     Laurie female white    0 WhiteFemale
#> 823     Tamika female black    0 BlackFemale
#> 824    Tanisha female black    0 BlackFemale
#> 825     Carrie female white    0 WhiteFemale
#> 826      Emily female white    0 WhiteFemale
#> 827     Keisha female black    0 BlackFemale
#> 828     Tamika female black    0 BlackFemale
#> 829    Allison female white    0 WhiteFemale
#> 830       Brad   male white    0   WhiteMale
#> 831       Brad   male white    0   WhiteMale
#> 832    Brendan   male white    0   WhiteMale
#> 833      Brett   male white    0   WhiteMale
#> 834      Brett   male white    0   WhiteMale
#> 835     Carrie female white    0 WhiteFemale
#> 836      Emily female white    0 WhiteFemale
#> 837       Greg   male white    0   WhiteMale
#> 838      Hakim   male black    0   BlackMale
#> 839      Hakim   male black    0   BlackMale
#> 840      Hakim   male black    0   BlackMale
#> 841      Jamal   male black    0   BlackMale
#> 842        Jay   male white    0   WhiteMale
#> 843     Keisha female black    0 BlackFemale
#> 844     Keisha female black    0 BlackFemale
#> 845     Keisha female black    0 BlackFemale
#> 846     Keisha female black    0 BlackFemale
#> 847     Keisha female black    0 BlackFemale
#> 848     Keisha female black    0 BlackFemale
#> 849      Kenya female black    0 BlackFemale
#> 850    Kristen female white    0 WhiteFemale
#> 851    Matthew   male white    0   WhiteMale
#> 852   Meredith female white    0 WhiteFemale
#> 853      Sarah female white    0 WhiteFemale
#> 854      Sarah female white    0 WhiteFemale
#> 855       Todd   male white    0   WhiteMale
#> 856   Tremayne   male black    0   BlackMale
#> 857     Tyrone   male black    0   BlackMale
#> 858     Tyrone   male black    0   BlackMale
#> 859     Tyrone   male black    0   BlackMale
#> 860     Tyrone   male black    0   BlackMale
#> 861    Allison female white    0 WhiteFemale
#> 862       Anne female white    0 WhiteFemale
#> 863    Latonya female black    0 BlackFemale
#> 864     Tamika female black    0 BlackFemale
#> 865       Jill female white    0 WhiteFemale
#> 866      Kenya female black    0 BlackFemale
#> 867   Meredith female white    0 WhiteFemale
#> 868     Tamika female black    0 BlackFemale
#> 869    Allison female white    0 WhiteFemale
#> 870      Ebony female black    0 BlackFemale
#> 871      Emily female white    0 WhiteFemale
#> 872     Latoya female black    0 BlackFemale
#> 873    Kristen female white    0 WhiteFemale
#> 874    Latonya female black    0 BlackFemale
#> 875     Laurie female white    0 WhiteFemale
#> 876    Tanisha female black    0 BlackFemale
#> 877       Anne female white    0 WhiteFemale
#> 878      Kenya female black    0 BlackFemale
#> 879    Lakisha female black    0 BlackFemale
#> 880   Meredith female white    0 WhiteFemale
#> 881      Emily female white    0 WhiteFemale
#> 882   Meredith female white    0 WhiteFemale
#> 883    Tanisha female black    0 BlackFemale
#> 884     Tyrone   male black    0   BlackMale
#> 885      Aisha female black    0 BlackFemale
#> 886    Allison female white    1 WhiteFemale
#> 887     Carrie female white    1 WhiteFemale
#> 888     Latoya female black    0 BlackFemale
#> 889       Anne female white    1 WhiteFemale
#> 890     Tamika female black    0 BlackFemale
#> 891      Aisha female black    0 BlackFemale
#> 892     Carrie female white    0 WhiteFemale
#> 893      Ebony female black    0 BlackFemale
#> 894   Meredith female white    0 WhiteFemale
#> 895       Anne female white    0 WhiteFemale
#> 896    Lakisha female black    0 BlackFemale
#> 897    Latonya female black    0 BlackFemale
#> 898   Meredith female white    1 WhiteFemale
#> 899      Aisha female black    0 BlackFemale
#> 900      Emily female white    0 WhiteFemale
#> 901       Jill female white    0 WhiteFemale
#> 902     Keisha female black    0 BlackFemale
#> 903    Allison female white    0 WhiteFemale
#> 904     Latoya female black    0 BlackFemale
#> 905   Meredith female white    0 WhiteFemale
#> 906    Tanisha female black    0 BlackFemale
#> 907     Carrie female white    0 WhiteFemale
#> 908      Kenya female black    0 BlackFemale
#> 909    Latonya female black    0 BlackFemale
#> 910      Sarah female white    1 WhiteFemale
#> 911    Allison female white    1 WhiteFemale
#> 912      Ebony female black    0 BlackFemale
#> 913      Sarah female white    0 WhiteFemale
#> 914    Tanisha female black    0 BlackFemale
#> 915       Anne female white    0 WhiteFemale
#> 916      Ebony female black    0 BlackFemale
#> 917     Keisha female black    0 BlackFemale
#> 918    Kristen female white    0 WhiteFemale
#> 919    Allison female white    0 WhiteFemale
#> 920      Emily female white    0 WhiteFemale
#> 921    Latonya female black    0 BlackFemale
#> 922     Latoya female black    0 BlackFemale
#> 923       Jill female white    0 WhiteFemale
#> 924     Latoya female black    0 BlackFemale
#> 925      Sarah female white    1 WhiteFemale
#> 926     Tamika female black    1 BlackFemale
#> 927       Anne female white    0 WhiteFemale
#> 928       Jill female white    0 WhiteFemale
#> 929     Keisha female black    0 BlackFemale
#> 930      Kenya female black    0 BlackFemale
#> 931     Latoya female black    0 BlackFemale
#> 932     Laurie female white    0 WhiteFemale
#> 933   Meredith female white    0 WhiteFemale
#> 934     Tamika female black    0 BlackFemale
#> 935      Aisha female black    0 BlackFemale
#> 936       Anne female white    0 WhiteFemale
#> 937     Keisha female black    0 BlackFemale
#> 938     Laurie female white    0 WhiteFemale
#> 939     Carrie female white    0 WhiteFemale
#> 940      Kenya female black    0 BlackFemale
#> 941    Lakisha female black    0 BlackFemale
#> 942     Laurie female white    0 WhiteFemale
#> 943      Emily female white    0 WhiteFemale
#> 944       Greg   male white    0   WhiteMale
#> 945    Lakisha female black    0 BlackFemale
#> 946     Latoya female black    0 BlackFemale
#> 947       Jill female white    0 WhiteFemale
#> 948    Kristen female white    0 WhiteFemale
#> 949     Latoya female black    0 BlackFemale
#> 950     Tamika female black    0 BlackFemale
#> 951      Ebony female black    0 BlackFemale
#> 952      Emily female white    0 WhiteFemale
#> 953    Kristen female white    1 WhiteFemale
#> 954     Latoya female black    0 BlackFemale
#> 955    Allison female white    0 WhiteFemale
#> 956     Latoya female black    0 BlackFemale
#> 957     Carrie female white    0 WhiteFemale
#> 958     Keisha female black    0 BlackFemale
#> 959    Kristen female white    0 WhiteFemale
#> 960     Latoya female black    0 BlackFemale
#> 961    Allison female white    0 WhiteFemale
#> 962       Anne female white    0 WhiteFemale
#> 963    Lakisha female black    0 BlackFemale
#> 964     Tamika female black    0 BlackFemale
#> 965      Ebony female black    0 BlackFemale
#> 966    Kristen female white    0 WhiteFemale
#> 967   Meredith female white    0 WhiteFemale
#> 968    Tanisha female black    0 BlackFemale
#> 969    Allison female white    0 WhiteFemale
#> 970      Emily female white    0 WhiteFemale
#> 971     Tamika female black    0 BlackFemale
#> 972    Tanisha female black    0 BlackFemale
#> 973    Allison female white    0 WhiteFemale
#> 974      Kenya female black    0 BlackFemale
#> 975     Laurie female white    0 WhiteFemale
#> 976     Tamika female black    0 BlackFemale
#> 977    Allison female white    1 WhiteFemale
#> 978      Ebony female black    0 BlackFemale
#> 979       Jill female white    0 WhiteFemale
#> 980     Keisha female black    0 BlackFemale
#> 981    Allison female white    0 WhiteFemale
#> 982     Carrie female white    0 WhiteFemale
#> 983      Ebony female black    0 BlackFemale
#> 984     Tamika female black    0 BlackFemale
#> 985     Carrie female white    0 WhiteFemale
#> 986     Keisha female black    0 BlackFemale
#> 987      Kenya female black    0 BlackFemale
#> 988      Sarah female white    1 WhiteFemale
#> 989      Ebony female black    1 BlackFemale
#> 990     Laurie female white    0 WhiteFemale
#> 991    Allison female white    0 WhiteFemale
#> 992     Keisha female black    0 BlackFemale
#> 993    Kristen female white    0 WhiteFemale
#> 994     Tamika female black    0 BlackFemale
#> 995      Ebony female black    0 BlackFemale
#> 996     Keisha female black    0 BlackFemale
#> 997   Meredith female white    0 WhiteFemale
#> 998      Sarah female white    0 WhiteFemale
#> 999       Anne female white    0 WhiteFemale
#> 1000      Brad   male white    0   WhiteMale
#> 1001     Brett   male white    0   WhiteMale
#> 1002     Brett   male white    0   WhiteMale
#> 1003   Darnell   male black    0   BlackMale
#> 1004     Ebony female black    0 BlackFemale
#> 1005     Emily female white    0 WhiteFemale
#> 1006  Geoffrey   male white    0   WhiteMale
#> 1007     Jamal   male black    0   BlackMale
#> 1008       Jay   male white    0   WhiteMale
#> 1009       Jay   male white    1   WhiteMale
#> 1010  Jermaine   male black    0   BlackMale
#> 1011  Jermaine   male black    0   BlackMale
#> 1012      Jill female white    0 WhiteFemale
#> 1013      Jill female white    0 WhiteFemale
#> 1014    Kareem   male black    0   BlackMale
#> 1015    Keisha female black    0 BlackFemale
#> 1016     Kenya female black    0 BlackFemale
#> 1017   Kristen female white    0 WhiteFemale
#> 1018   Latonya female black    0 BlackFemale
#> 1019   Latonya female black    0 BlackFemale
#> 1020   Latonya female black    0 BlackFemale
#> 1021    Laurie female white    0 WhiteFemale
#> 1022     Leroy   male black    0   BlackMale
#> 1023     Leroy   male black    0   BlackMale
#> 1024     Leroy   male black    0   BlackMale
#> 1025     Leroy   male black    0   BlackMale
#> 1026   Matthew   male white    0   WhiteMale
#> 1027  Meredith female white    0 WhiteFemale
#> 1028      Neil   male white    0   WhiteMale
#> 1029      Neil   male white    0   WhiteMale
#> 1030      Neil   male white    0   WhiteMale
#> 1031      Neil   male white    0   WhiteMale
#> 1032   Rasheed   male black    0   BlackMale
#> 1033   Rasheed   male black    0   BlackMale
#> 1034   Tanisha female black    0 BlackFemale
#> 1035      Todd   male white    0   WhiteMale
#> 1036      Todd   male white    0   WhiteMale
#> 1037    Tyrone   male black    0   BlackMale
#> 1038    Tyrone   male black    0   BlackMale
#> 1039   Allison female white    0 WhiteFemale
#> 1040      Jill female white    0 WhiteFemale
#> 1041   Latonya female black    0 BlackFemale
#> 1042    Tamika female black    0 BlackFemale
#> 1043      Jill female white    0 WhiteFemale
#> 1044     Kenya female black    0 BlackFemale
#> 1045   Kristen female white    0 WhiteFemale
#> 1046    Tamika female black    0 BlackFemale
#> 1047     Brett   male white    0   WhiteMale
#> 1048     Hakim   male black    0   BlackMale
#> 1049    Laurie female white    1 WhiteFemale
#> 1050   Rasheed   male black    0   BlackMale
#> 1051    Carrie female white    0 WhiteFemale
#> 1052     Ebony female black    0 BlackFemale
#> 1053   Latonya female black    0 BlackFemale
#> 1054  Meredith female white    0 WhiteFemale
#> 1055   Allison female white    0 WhiteFemale
#> 1056     Ebony female black    0 BlackFemale
#> 1057    Latoya female black    0 BlackFemale
#> 1058    Laurie female white    0 WhiteFemale
#> 1059    Carrie female white    0 WhiteFemale
#> 1060     Kenya female black    0 BlackFemale
#> 1061   Lakisha female black    0 BlackFemale
#> 1062  Meredith female white    0 WhiteFemale
#> 1063     Aisha female black    0 BlackFemale
#> 1064      Anne female white    0 WhiteFemale
#> 1065   Kristen female white    0 WhiteFemale
#> 1066   Tanisha female black    0 BlackFemale
#> 1067      Anne female white    0 WhiteFemale
#> 1068      Anne female white    0 WhiteFemale
#> 1069     Ebony female black    0 BlackFemale
#> 1070   Tanisha female black    0 BlackFemale
#> 1071     Kenya female black    0 BlackFemale
#> 1072   Kristen female white    0 WhiteFemale
#> 1073  Meredith female white    0 WhiteFemale
#> 1074   Tanisha female black    0 BlackFemale
#> 1075     Aisha female black    0 BlackFemale
#> 1076    Carrie female white    0 WhiteFemale
#> 1077   Latonya female black    0 BlackFemale
#> 1078    Laurie female white    0 WhiteFemale
#> 1079     Ebony female black    0 BlackFemale
#> 1080      Jill female white    1 WhiteFemale
#> 1081    Keisha female black    0 BlackFemale
#> 1082    Laurie female white    0 WhiteFemale
#> 1083     Ebony female black    0 BlackFemale
#> 1084     Emily female white    0 WhiteFemale
#> 1085    Laurie female white    0 WhiteFemale
#> 1086    Tamika female black    0 BlackFemale
#> 1087      Jill female white    0 WhiteFemale
#> 1088   Lakisha female black    0 BlackFemale
#> 1089    Latoya female black    0 BlackFemale
#> 1090    Laurie female white    0 WhiteFemale
#> 1091      Anne female white    0 WhiteFemale
#> 1092     Kenya female black    0 BlackFemale
#> 1093    Latoya female black    0 BlackFemale
#> 1094    Laurie female white    0 WhiteFemale
#> 1095   Allison female white    0 WhiteFemale
#> 1096      Jill female white    0 WhiteFemale
#> 1097     Kenya female black    0 BlackFemale
#> 1098   Lakisha female black    0 BlackFemale
#> 1099   Kristen female white    0 WhiteFemale
#> 1100    Latoya female black    0 BlackFemale
#> 1101     Sarah female white    0 WhiteFemale
#> 1102   Tanisha female black    0 BlackFemale
#> 1103     Emily female white    0 WhiteFemale
#> 1104      Jill female white    0 WhiteFemale
#> 1105   Lakisha female black    0 BlackFemale
#> 1106   Latonya female black    0 BlackFemale
#> 1107      Neil   male white    0   WhiteMale
#> 1108    Tyrone   male black    0   BlackMale
#> 1109   Allison female white    0 WhiteFemale
#> 1110      Anne female white    0 WhiteFemale
#> 1111     Kenya female black    0 BlackFemale
#> 1112    Tamika female black    0 BlackFemale
#> 1113   Kristen female white    1 WhiteFemale
#> 1114    Tamika female black    0 BlackFemale
#> 1115      Anne female white    0 WhiteFemale
#> 1116     Ebony female black    0 BlackFemale
#> 1117      Jill female white    0 WhiteFemale
#> 1118   Tanisha female black    0 BlackFemale
#> 1119     Aisha female black    0 BlackFemale
#> 1120   Allison female white    0 WhiteFemale
#> 1121    Latoya female black    0 BlackFemale
#> 1122    Laurie female white    0 WhiteFemale
#> 1123   Allison female white    0 WhiteFemale
#> 1124      Anne female white    0 WhiteFemale
#> 1125   Latonya female black    0 BlackFemale
#> 1126    Latoya female black    0 BlackFemale
#> 1127     Ebony female black    0 BlackFemale
#> 1128      Jill female white    0 WhiteFemale
#> 1129    Keisha female black    0 BlackFemale
#> 1130    Laurie female white    0 WhiteFemale
#> 1131     Aisha female black    0 BlackFemale
#> 1132     Emily female white    0 WhiteFemale
#> 1133      Jill female white    0 WhiteFemale
#> 1134    Keisha female black    0 BlackFemale
#> 1135     Aisha female black    0 BlackFemale
#> 1136   Brendan   male white    0   WhiteMale
#> 1137   Brendan   male white    0   WhiteMale
#> 1138    Carrie female white    0 WhiteFemale
#> 1139   Darnell   male black    0   BlackMale
#> 1140     Ebony female black    0 BlackFemale
#> 1141  Geoffrey   male white    0   WhiteMale
#> 1142     Jamal   male black    0   BlackMale
#> 1143     Jamal   male black    0   BlackMale
#> 1144       Jay   male white    0   WhiteMale
#> 1145       Jay   male white    0   WhiteMale
#> 1146  Jermaine   male black    0   BlackMale
#> 1147      Jill female white    0 WhiteFemale
#> 1148    Kareem   male black    0   BlackMale
#> 1149   Kristen female white    0 WhiteFemale
#> 1150    Latoya female black    0 BlackFemale
#> 1151     Leroy   male black    0   BlackMale
#> 1152     Leroy   male black    0   BlackMale
#> 1153      Neil   male white    0   WhiteMale
#> 1154   Rasheed   male black    0   BlackMale
#> 1155     Sarah female white    0 WhiteFemale
#> 1156      Todd   male white    0   WhiteMale
#> 1157      Todd   male white    0   WhiteMale
#> 1158  Tremayne   male black    0   BlackMale
#> 1159   Allison female white    0 WhiteFemale
#> 1160      Anne female white    0 WhiteFemale
#> 1161    Latoya female black    0 BlackFemale
#> 1162    Tamika female black    0 BlackFemale
#> 1163   Latonya female black    0 BlackFemale
#> 1164    Laurie female white    1 WhiteFemale
#> 1165  Meredith female white    1 WhiteFemale
#> 1166    Tamika female black    1 BlackFemale
#> 1167     Emily female white    0 WhiteFemale
#> 1168     Kenya female black    0 BlackFemale
#> 1169   Kristen female white    0 WhiteFemale
#> 1170   Tanisha female black    0 BlackFemale
#> 1171     Ebony female black    0 BlackFemale
#> 1172     Emily female white    1 WhiteFemale
#> 1173    Latoya female black    0 BlackFemale
#> 1174     Sarah female white    0 WhiteFemale
#> 1175     Ebony female black    0 BlackFemale
#> 1176      Jill female white    0 WhiteFemale
#> 1177   Kristen female white    0 WhiteFemale
#> 1178   Tanisha female black    0 BlackFemale
#> 1179     Emily female white    0 WhiteFemale
#> 1180     Kenya female black    0 BlackFemale
#> 1181     Sarah female white    0 WhiteFemale
#> 1182    Tamika female black    0 BlackFemale
#> 1183     Ebony female black    0 BlackFemale
#> 1184   Kristen female white    0 WhiteFemale
#> 1185    Laurie female white    0 WhiteFemale
#> 1186   Tanisha female black    0 BlackFemale
#> 1187   Allison female white    1 WhiteFemale
#> 1188     Ebony female black    0 BlackFemale
#> 1189    Kareem   male black    0   BlackMale
#> 1190      Neil   male white    0   WhiteMale
#> 1191     Aisha female black    0 BlackFemale
#> 1192      Anne female white    0 WhiteFemale
#> 1193     Ebony female black    0 BlackFemale
#> 1194      Jill female white    0 WhiteFemale
#> 1195      Jill female white    0 WhiteFemale
#> 1196    Keisha female black    0 BlackFemale
#> 1197   Lakisha female black    0 BlackFemale
#> 1198  Meredith female white    0 WhiteFemale
#> 1199     Aisha female black    0 BlackFemale
#> 1200      Anne female white    0 WhiteFemale
#> 1201    Carrie female white    0 WhiteFemale
#> 1202     Kenya female black    0 BlackFemale
#> 1203     Aisha female black    0 BlackFemale
#> 1204     Emily female white    0 WhiteFemale
#> 1205  Meredith female white    0 WhiteFemale
#> 1206   Tanisha female black    0 BlackFemale
#> 1207     Aisha female black    0 BlackFemale
#> 1208   Allison female white    0 WhiteFemale
#> 1209     Emily female white    0 WhiteFemale
#> 1210     Kenya female black    0 BlackFemale
#> 1211   Allison female white    0 WhiteFemale
#> 1212   Kristen female white    1 WhiteFemale
#> 1213   Lakisha female black    1 BlackFemale
#> 1214    Tamika female black    1 BlackFemale
#> 1215     Aisha female black    0 BlackFemale
#> 1216     Emily female white    0 WhiteFemale
#> 1217   Kristen female white    0 WhiteFemale
#> 1218   Tanisha female black    0 BlackFemale
#> 1219     Aisha female black    0 BlackFemale
#> 1220    Carrie female white    0 WhiteFemale
#> 1221  Meredith female white    0 WhiteFemale
#> 1222   Tanisha female black    0 BlackFemale
#> 1223      Anne female white    0 WhiteFemale
#> 1224      Jill female white    0 WhiteFemale
#> 1225   Lakisha female black    0 BlackFemale
#> 1226   Tanisha female black    0 BlackFemale
#> 1227     Emily female white    0 WhiteFemale
#> 1228    Latoya female black    0 BlackFemale
#> 1229  Meredith female white    0 WhiteFemale
#> 1230    Tamika female black    0 BlackFemale
#> 1231   Allison female white    0 WhiteFemale
#> 1232   Latonya female black    0 BlackFemale
#> 1233  Meredith female white    0 WhiteFemale
#> 1234    Tamika female black    0 BlackFemale
#> 1235     Leroy   male black    0   BlackMale
#> 1236   Matthew   male white    0   WhiteMale
#> 1237      Neil   male white    0   WhiteMale
#> 1238    Tyrone   male black    0   BlackMale
#> 1239  Meredith female white    0 WhiteFemale
#> 1240   Tanisha female black    0 BlackFemale
#> 1241    Carrie female white    0 WhiteFemale
#> 1242     Emily female white    0 WhiteFemale
#> 1243    Keisha female black    0 BlackFemale
#> 1244   Lakisha female black    0 BlackFemale
#> 1245   Allison female white    0 WhiteFemale
#> 1246     Ebony female black    0 BlackFemale
#> 1247    Latoya female black    0 BlackFemale
#> 1248    Laurie female white    0 WhiteFemale
#> 1249   Allison female white    0 WhiteFemale
#> 1250      Anne female white    0 WhiteFemale
#> 1251      Brad   male white    0   WhiteMale
#> 1252     Brett   male white    0   WhiteMale
#> 1253   Darnell   male black    0   BlackMale
#> 1254   Darnell   male black    1   BlackMale
#> 1255   Darnell   male black    0   BlackMale
#> 1256     Ebony female black    0 BlackFemale
#> 1257     Emily female white    0 WhiteFemale
#> 1258  Geoffrey   male white    0   WhiteMale
#> 1259  Geoffrey   male white    0   WhiteMale
#> 1260       Jay   male white    0   WhiteMale
#> 1261  Jermaine   male black    0   BlackMale
#> 1262      Jill female white    0 WhiteFemale
#> 1263    Keisha female black    1 BlackFemale
#> 1264    Keisha female black    0 BlackFemale
#> 1265   Lakisha female black    0 BlackFemale
#> 1266   Latonya female black    0 BlackFemale
#> 1267    Latoya female black    0 BlackFemale
#> 1268  Meredith female white    0 WhiteFemale
#> 1269  Meredith female white    0 WhiteFemale
#> 1270      Neil   male white    0   WhiteMale
#> 1271   Rasheed   male black    0   BlackMale
#> 1272      Todd   male white    0   WhiteMale
#> 1273      Todd   male white    0   WhiteMale
#> 1274  Tremayne   male black    0   BlackMale
#> 1275    Tyrone   male black    0   BlackMale
#> 1276    Tyrone   male black    0   BlackMale
#> 1277     Emily female white    0 WhiteFemale
#> 1278   Lakisha female black    0 BlackFemale
#> 1279     Sarah female white    1 WhiteFemale
#> 1280   Tanisha female black    0 BlackFemale
#> 1281   Allison female white    0 WhiteFemale
#> 1282     Kenya female black    0 BlackFemale
#> 1283   Latonya female black    0 BlackFemale
#> 1284  Meredith female white    1 WhiteFemale
#> 1285      Anne female white    0 WhiteFemale
#> 1286     Ebony female black    0 BlackFemale
#> 1287     Emily female white    0 WhiteFemale
#> 1288    Tamika female black    0 BlackFemale
#> 1289      Anne female white    0 WhiteFemale
#> 1290     Kenya female black    0 BlackFemale
#> 1291   Latonya female black    0 BlackFemale
#> 1292     Sarah female white    0 WhiteFemale
#> 1293     Ebony female black    0 BlackFemale
#> 1294   Kristen female white    0 WhiteFemale
#> 1295    Laurie female white    0 WhiteFemale
#> 1296    Tamika female black    0 BlackFemale
#> 1297   Allison female white    0 WhiteFemale
#> 1298      Jill female white    0 WhiteFemale
#> 1299     Kenya female black    0 BlackFemale
#> 1300   Lakisha female black    0 BlackFemale
#> 1301      Anne female white    1 WhiteFemale
#> 1302     Emily female white    0 WhiteFemale
#> 1303     Kenya female black    0 BlackFemale
#> 1304    Latoya female black    0 BlackFemale
#> 1305     Ebony female black    0 BlackFemale
#> 1306     Emily female white    0 WhiteFemale
#> 1307      Jill female white    0 WhiteFemale
#> 1308    Tamika female black    0 BlackFemale
#> 1309   Allison female white    1 WhiteFemale
#> 1310     Hakim   male black    1   BlackMale
#> 1311     Jamal   male black    1   BlackMale
#> 1312       Jay   male white    1   WhiteMale
#> 1313      Anne female white    0 WhiteFemale
#> 1314     Emily female white    0 WhiteFemale
#> 1315   Lakisha female black    0 BlackFemale
#> 1316   Latonya female black    0 BlackFemale
#> 1317      Anne female white    0 WhiteFemale
#> 1318     Ebony female black    0 BlackFemale
#> 1319     Sarah female white    0 WhiteFemale
#> 1320   Tanisha female black    0 BlackFemale
#> 1321    Laurie female white    0 WhiteFemale
#> 1322    Tamika female black    0 BlackFemale
#> 1323     Emily female white    0 WhiteFemale
#> 1324    Keisha female black    0 BlackFemale
#> 1325    Latoya female black    0 BlackFemale
#> 1326  Meredith female white    0 WhiteFemale
#> 1327   Kristen female white    0 WhiteFemale
#> 1328    Latoya female black    0 BlackFemale
#> 1329  Meredith female white    0 WhiteFemale
#> 1330   Tanisha female black    0 BlackFemale
#> 1331      Anne female white    1 WhiteFemale
#> 1332     Kenya female black    1 BlackFemale
#> 1333     Sarah female white    1 WhiteFemale
#> 1334   Tanisha female black    1 BlackFemale
#> 1335    Carrie female white    0 WhiteFemale
#> 1336     Emily female white    0 WhiteFemale
#> 1337    Keisha female black    0 BlackFemale
#> 1338     Kenya female black    0 BlackFemale
#> 1339      Anne female white    0 WhiteFemale
#> 1340     Emily female white    0 WhiteFemale
#> 1341    Keisha female black    0 BlackFemale
#> 1342   Tanisha female black    0 BlackFemale
#> 1343     Emily female white    0 WhiteFemale
#> 1344     Kenya female black    0 BlackFemale
#> 1345   Latonya female black    0 BlackFemale
#> 1346     Sarah female white    0 WhiteFemale
#> 1347     Emily female white    0 WhiteFemale
#> 1348   Latonya female black    0 BlackFemale
#> 1349    Latoya female black    0 BlackFemale
#> 1350     Sarah female white    0 WhiteFemale
#> 1351     Emily female white    0 WhiteFemale
#> 1352      Jill female white    0 WhiteFemale
#> 1353   Lakisha female black    0 BlackFemale
#> 1354   Latonya female black    0 BlackFemale
#> 1355      Anne female white    0 WhiteFemale
#> 1356     Ebony female black    0 BlackFemale
#> 1357    Latoya female black    0 BlackFemale
#> 1358  Meredith female white    0 WhiteFemale
#> 1359   Allison female white    0 WhiteFemale
#> 1360     Ebony female black    0 BlackFemale
#> 1361     Emily female white    0 WhiteFemale
#> 1362    Latoya female black    0 BlackFemale
#> 1363      Anne female white    0 WhiteFemale
#> 1364     Emily female white    0 WhiteFemale
#> 1365    Keisha female black    0 BlackFemale
#> 1366    Tamika female black    0 BlackFemale
#> 1367      Jill female white    0 WhiteFemale
#> 1368   Lakisha female black    0 BlackFemale
#> 1369     Sarah female white    0 WhiteFemale
#> 1370    Tamika female black    0 BlackFemale
#> 1371    Carrie female white    1 WhiteFemale
#> 1372   Lakisha female black    0 BlackFemale
#> 1373    Laurie female white    0 WhiteFemale
#> 1374   Tanisha female black    0 BlackFemale
#> 1375     Aisha female black    0 BlackFemale
#> 1376     Aisha female black    0 BlackFemale
#> 1377     Aisha female black    0 BlackFemale
#> 1378      Anne female white    0 WhiteFemale
#> 1379      Brad   male white    0   WhiteMale
#> 1380      Brad   male white    0   WhiteMale
#> 1381    Carrie female white    0 WhiteFemale
#> 1382    Carrie female white    0 WhiteFemale
#> 1383     Emily female white    0 WhiteFemale
#> 1384  Geoffrey   male white    0   WhiteMale
#> 1385     Hakim   male black    0   BlackMale
#> 1386       Jay   male white    0   WhiteMale
#> 1387  Jermaine   male black    0   BlackMale
#> 1388    Keisha female black    0 BlackFemale
#> 1389     Kenya female black    0 BlackFemale
#> 1390   Kristen female white    0 WhiteFemale
#> 1391   Kristen female white    0 WhiteFemale
#> 1392   Kristen female white    0 WhiteFemale
#> 1393   Lakisha female black    0 BlackFemale
#> 1394   Lakisha female black    0 BlackFemale
#> 1395   Latonya female black    0 BlackFemale
#> 1396    Latoya female black    0 BlackFemale
#> 1397     Leroy   male black    0   BlackMale
#> 1398   Matthew   male white    0   WhiteMale
#> 1399   Matthew   male white    0   WhiteMale
#> 1400      Neil   male white    0   WhiteMale
#> 1401   Rasheed   male black    0   BlackMale
#> 1402     Sarah female white    0 WhiteFemale
#> 1403      Todd   male white    0   WhiteMale
#> 1404  Tremayne   male black    0   BlackMale
#> 1405  Tremayne   male black    0   BlackMale
#> 1406    Tyrone   male black    0   BlackMale
#> 1407    Latoya female black    1 BlackFemale
#> 1408  Meredith female white    1 WhiteFemale
#> 1409     Sarah female white    1 WhiteFemale
#> 1410   Tanisha female black    1 BlackFemale
#> 1411      Jill female white    1 WhiteFemale
#> 1412   Kristen female white    0 WhiteFemale
#> 1413    Tamika female black    0 BlackFemale
#> 1414   Tanisha female black    0 BlackFemale
#> 1415      Anne female white    0 WhiteFemale
#> 1416     Ebony female black    0 BlackFemale
#> 1417   Lakisha female black    0 BlackFemale
#> 1418    Laurie female white    0 WhiteFemale
#> 1419   Allison female white    0 WhiteFemale
#> 1420     Emily female white    0 WhiteFemale
#> 1421     Kenya female black    0 BlackFemale
#> 1422    Tamika female black    0 BlackFemale
#> 1423   Latonya female black    0 BlackFemale
#> 1424    Laurie female white    0 WhiteFemale
#> 1425  Meredith female white    0 WhiteFemale
#> 1426    Tamika female black    0 BlackFemale
#> 1427   Kristen female white    0 WhiteFemale
#> 1428   Latonya female black    0 BlackFemale
#> 1429     Sarah female white    0 WhiteFemale
#> 1430   Tanisha female black    0 BlackFemale
#> 1431   Allison female white    1 WhiteFemale
#> 1432      Anne female white    0 WhiteFemale
#> 1433   Lakisha female black    0 BlackFemale
#> 1434    Tamika female black    0 BlackFemale
#> 1435      Anne female white    1 WhiteFemale
#> 1436     Emily female white    1 WhiteFemale
#> 1437   Lakisha female black    0 BlackFemale
#> 1438    Latoya female black    0 BlackFemale
#> 1439    Carrie female white    0 WhiteFemale
#> 1440     Ebony female black    0 BlackFemale
#> 1441    Laurie female white    0 WhiteFemale
#> 1442   Tanisha female black    0 BlackFemale
#> 1443    Carrie female white    1 WhiteFemale
#> 1444     Ebony female black    0 BlackFemale
#> 1445   Kristen female white    1 WhiteFemale
#> 1446   Tanisha female black    0 BlackFemale
#> 1447      Jill female white    1 WhiteFemale
#> 1448   Lakisha female black    1 BlackFemale
#> 1449     Aisha female black    0 BlackFemale
#> 1450      Anne female white    0 WhiteFemale
#> 1451      Jill female white    0 WhiteFemale
#> 1452    Tamika female black    0 BlackFemale
#> 1453     Aisha female black    0 BlackFemale
#> 1454   Allison female white    0 WhiteFemale
#> 1455    Carrie female white    0 WhiteFemale
#> 1456    Latoya female black    0 BlackFemale
#> 1457      Anne female white    0 WhiteFemale
#> 1458     Emily female white    0 WhiteFemale
#> 1459    Latoya female black    0 BlackFemale
#> 1460    Tamika female black    0 BlackFemale
#> 1461      Anne female white    0 WhiteFemale
#> 1462     Emily female white    0 WhiteFemale
#> 1463     Kenya female black    0 BlackFemale
#> 1464    Latoya female black    0 BlackFemale
#> 1465    Carrie female white    0 WhiteFemale
#> 1466     Emily female white    0 WhiteFemale
#> 1467    Keisha female black    0 BlackFemale
#> 1468    Tamika female black    0 BlackFemale
#> 1469      Anne female white    0 WhiteFemale
#> 1470   Lakisha female black    0 BlackFemale
#> 1471   Latonya female black    0 BlackFemale
#> 1472  Meredith female white    0 WhiteFemale
#> 1473      Anne female white    0 WhiteFemale
#> 1474     Kenya female black    0 BlackFemale
#> 1475   Kristen female white    0 WhiteFemale
#> 1476    Latoya female black    0 BlackFemale
#> 1477   Kristen female white    0 WhiteFemale
#> 1478    Latoya female black    0 BlackFemale
#> 1479     Aisha female black    0 BlackFemale
#> 1480      Jill female white    0 WhiteFemale
#> 1481   Kristen female white    0 WhiteFemale
#> 1482   Lakisha female black    0 BlackFemale
#> 1483      Anne female white    0 WhiteFemale
#> 1484     Kenya female black    0 BlackFemale
#> 1485   Kristen female white    0 WhiteFemale
#> 1486    Tamika female black    0 BlackFemale
#> 1487   Allison female white    0 WhiteFemale
#> 1488    Keisha female black    0 BlackFemale
#> 1489     Kenya female black    0 BlackFemale
#> 1490     Sarah female white    0 WhiteFemale
#> 1491   Brendan   male white    0   WhiteMale
#> 1492     Brett   male white    0   WhiteMale
#> 1493  Jermaine   male black    0   BlackMale
#> 1494    Tyrone   male black    0   BlackMale
#> 1495      Jill female white    1 WhiteFemale
#> 1496     Kenya female black    0 BlackFemale
#> 1497    Latoya female black    0 BlackFemale
#> 1498    Laurie female white    1 WhiteFemale
#> 1499    Keisha female black    0 BlackFemale
#> 1500   Lakisha female black    0 BlackFemale
#> 1501    Laurie female white    0 WhiteFemale
#> 1502     Sarah female white    0 WhiteFemale
#> 1503     Emily female white    0 WhiteFemale
#> 1504     Kenya female black    0 BlackFemale
#> 1505     Kenya female black    0 BlackFemale
#> 1506   Lakisha female black    0 BlackFemale
#> 1507    Laurie female white    0 WhiteFemale
#> 1508     Sarah female white    0 WhiteFemale
#> 1509      Anne female white    0 WhiteFemale
#> 1510   Lakisha female black    0 BlackFemale
#> 1511   Latonya female black    0 BlackFemale
#> 1512  Meredith female white    0 WhiteFemale
#> 1513     Ebony female black    0 BlackFemale
#> 1514   Kristen female white    0 WhiteFemale
#> 1515   Latonya female black    0 BlackFemale
#> 1516  Meredith female white    0 WhiteFemale
#> 1517     Aisha female black    0 BlackFemale
#> 1518     Aisha female black    0 BlackFemale
#> 1519     Aisha female black    0 BlackFemale
#> 1520      Brad   male white    1   WhiteMale
#> 1521      Brad   male white    0   WhiteMale
#> 1522   Brendan   male white    0   WhiteMale
#> 1523   Brendan   male white    0   WhiteMale
#> 1524     Brett   male white    1   WhiteMale
#> 1525    Carrie female white    0 WhiteFemale
#> 1526     Hakim   male black    0   BlackMale
#> 1527       Jay   male white    0   WhiteMale
#> 1528    Kareem   male black    0   BlackMale
#> 1529     Kenya female black    1 BlackFemale
#> 1530   Kristen female white    0 WhiteFemale
#> 1531   Lakisha female black    0 BlackFemale
#> 1532   Lakisha female black    0 BlackFemale
#> 1533   Latonya female black    1 BlackFemale
#> 1534     Leroy   male black    0   BlackMale
#> 1535     Leroy   male black    0   BlackMale
#> 1536   Matthew   male white    0   WhiteMale
#> 1537   Matthew   male white    0   WhiteMale
#> 1538      Neil   male white    0   WhiteMale
#> 1539      Neil   male white    0   WhiteMale
#> 1540      Neil   male white    0   WhiteMale
#> 1541     Sarah female white    0 WhiteFemale
#> 1542  Tremayne   male black    0   BlackMale
#> 1543    Tyrone   male black    0   BlackMale
#> 1544    Tyrone   male black    0   BlackMale
#> 1545      Anne female white    0 WhiteFemale
#> 1546   Lakisha female black    0 BlackFemale
#> 1547    Latoya female black    0 BlackFemale
#> 1548     Sarah female white    1 WhiteFemale
#> 1549     Aisha female black    0 BlackFemale
#> 1550      Anne female white    0 WhiteFemale
#> 1551     Sarah female white    0 WhiteFemale
#> 1552   Tanisha female black    0 BlackFemale
#> 1553    Carrie female white    0 WhiteFemale
#> 1554     Ebony female black    0 BlackFemale
#> 1555     Kenya female black    0 BlackFemale
#> 1556   Kristen female white    0 WhiteFemale
#> 1557     Aisha female black    0 BlackFemale
#> 1558   Allison female white    0 WhiteFemale
#> 1559     Ebony female black    1 BlackFemale
#> 1560      Jill female white    0 WhiteFemale
#> 1561   Allison female white    0 WhiteFemale
#> 1562     Emily female white    1 WhiteFemale
#> 1563    Latoya female black    0 BlackFemale
#> 1564    Tamika female black    1 BlackFemale
#> 1565     Aisha female black    0 BlackFemale
#> 1566    Carrie female white    1 WhiteFemale
#> 1567      Jill female white    1 WhiteFemale
#> 1568   Latonya female black    0 BlackFemale
#> 1569     Kenya female black    0 BlackFemale
#> 1570   Kristen female white    0 WhiteFemale
#> 1571    Latoya female black    0 BlackFemale
#> 1572     Sarah female white    0 WhiteFemale
#> 1573     Emily female white    0 WhiteFemale
#> 1574      Jill female white    1 WhiteFemale
#> 1575     Kenya female black    0 BlackFemale
#> 1576    Latoya female black    0 BlackFemale
#> 1577     Emily female white    1 WhiteFemale
#> 1578     Kenya female black    0 BlackFemale
#> 1579   Lakisha female black    0 BlackFemale
#> 1580     Sarah female white    0 WhiteFemale
#> 1581      Brad   male white    1   WhiteMale
#> 1582     Hakim   male black    1   BlackMale
#> 1583      Todd   male white    1   WhiteMale
#> 1584  Tremayne   male black    1   BlackMale
#> 1585      Anne female white    0 WhiteFemale
#> 1586     Kenya female black    0 BlackFemale
#> 1587   Kristen female white    0 WhiteFemale
#> 1588   Latonya female black    0 BlackFemale
#> 1589   Allison female white    0 WhiteFemale
#> 1590    Keisha female black    1 BlackFemale
#> 1591   Kristen female white    0 WhiteFemale
#> 1592    Tamika female black    0 BlackFemale
#> 1593      Jill female white    0 WhiteFemale
#> 1594   Kristen female white    0 WhiteFemale
#> 1595    Latoya female black    0 BlackFemale
#> 1596    Tamika female black    0 BlackFemale
#> 1597   Allison female white    0 WhiteFemale
#> 1598   Latonya female black    0 BlackFemale
#> 1599  Meredith female white    0 WhiteFemale
#> 1600    Tamika female black    0 BlackFemale
#> 1601     Aisha female black    0 BlackFemale
#> 1602     Emily female white    0 WhiteFemale
#> 1603    Laurie female white    0 WhiteFemale
#> 1604   Tanisha female black    0 BlackFemale
#> 1605      Jill female white    0 WhiteFemale
#> 1606     Kenya female black    0 BlackFemale
#> 1607   Latonya female black    0 BlackFemale
#> 1608  Meredith female white    0 WhiteFemale
#> 1609    Carrie female white    0 WhiteFemale
#> 1610     Ebony female black    0 BlackFemale
#> 1611   Latonya female black    0 BlackFemale
#> 1612     Sarah female white    0 WhiteFemale
#> 1613   Kristen female white    0 WhiteFemale
#> 1614    Latoya female black    0 BlackFemale
#> 1615    Laurie female white    0 WhiteFemale
#> 1616    Tamika female black    0 BlackFemale
#> 1617     Kenya female black    0 BlackFemale
#> 1618   Kristen female white    0 WhiteFemale
#> 1619    Laurie female white    0 WhiteFemale
#> 1620    Tamika female black    0 BlackFemale
#> 1621      Anne female white    0 WhiteFemale
#> 1622     Ebony female black    0 BlackFemale
#> 1623      Jill female white    0 WhiteFemale
#> 1624   Latonya female black    0 BlackFemale
#> 1625      Anne female white    0 WhiteFemale
#> 1626     Kenya female black    0 BlackFemale
#> 1627   Latonya female black    0 BlackFemale
#> 1628  Meredith female white    0 WhiteFemale
#> 1629      Anne female white    0 WhiteFemale
#> 1630    Keisha female black    0 BlackFemale
#> 1631   Kristen female white    0 WhiteFemale
#> 1632   Latonya female black    0 BlackFemale
#> 1633    Carrie female white    0 WhiteFemale
#> 1634     Ebony female black    0 BlackFemale
#> 1635     Emily female white    0 WhiteFemale
#> 1636    Tamika female black    0 BlackFemale
#> 1637     Brett   male white    0   WhiteMale
#> 1638      Neil   male white    0   WhiteMale
#> 1639   Rasheed   male black    0   BlackMale
#> 1640    Tyrone   male black    0   BlackMale
#> 1641   Brendan   male white    0   WhiteMale
#> 1642     Jamal   male black    0   BlackMale
#> 1643     Aisha female black    0 BlackFemale
#> 1644   Allison female white    0 WhiteFemale
#> 1645    Carrie female white    0 WhiteFemale
#> 1646    Latoya female black    0 BlackFemale
#> 1647     Aisha female black    0 BlackFemale
#> 1648   Allison female white    0 WhiteFemale
#> 1649      Jill female white    0 WhiteFemale
#> 1650    Tamika female black    0 BlackFemale
#> 1651      Jill female white    0 WhiteFemale
#> 1652    Keisha female black    0 BlackFemale
#> 1653   Kristen female white    0 WhiteFemale
#> 1654    Tamika female black    0 BlackFemale
#> 1655   Allison female white    0 WhiteFemale
#> 1656      Anne female white    0 WhiteFemale
#> 1657      Brad   male white    0   WhiteMale
#> 1658     Brett   male white    0   WhiteMale
#> 1659     Ebony female black    0 BlackFemale
#> 1660     Emily female white    0 WhiteFemale
#> 1661  Geoffrey   male white    0   WhiteMale
#> 1662  Geoffrey   male white    0   WhiteMale
#> 1663       Jay   male white    0   WhiteMale
#> 1664    Kareem   male black    0   BlackMale
#> 1665    Kareem   male black    0   BlackMale
#> 1666    Keisha female black    0 BlackFemale
#> 1667    Keisha female black    0 BlackFemale
#> 1668     Kenya female black    0 BlackFemale
#> 1669     Kenya female black    0 BlackFemale
#> 1670   Kristen female white    0 WhiteFemale
#> 1671    Laurie female white    0 WhiteFemale
#> 1672    Laurie female white    0 WhiteFemale
#> 1673     Leroy   male black    0   BlackMale
#> 1674     Leroy   male black    0   BlackMale
#> 1675     Leroy   male black    0   BlackMale
#> 1676   Matthew   male white    0   WhiteMale
#> 1677  Meredith female white    0 WhiteFemale
#> 1678   Rasheed   male black    0   BlackMale
#> 1679     Sarah female white    0 WhiteFemale
#> 1680   Tanisha female black    0 BlackFemale
#> 1681    Tyrone   male black    0   BlackMale
#> 1682    Tyrone   male black    0   BlackMale
#> 1683    Carrie female white    0 WhiteFemale
#> 1684    Laurie female white    0 WhiteFemale
#> 1685    Tamika female black    0 BlackFemale
#> 1686   Tanisha female black    0 BlackFemale
#> 1687   Allison female white    1 WhiteFemale
#> 1688     Ebony female black    0 BlackFemale
#> 1689     Emily female white    0 WhiteFemale
#> 1690    Latoya female black    0 BlackFemale
#> 1691   Allison female white    0 WhiteFemale
#> 1692     Emily female white    0 WhiteFemale
#> 1693     Kenya female black    0 BlackFemale
#> 1694   Lakisha female black    0 BlackFemale
#> 1695    Carrie female white    1 WhiteFemale
#> 1696    Latoya female black    1 BlackFemale
#> 1697     Sarah female white    1 WhiteFemale
#> 1698    Tamika female black    0 BlackFemale
#> 1699     Aisha female black    0 BlackFemale
#> 1700      Anne female white    0 WhiteFemale
#> 1701      Jill female white    0 WhiteFemale
#> 1702    Latoya female black    1 BlackFemale
#> 1703     Ebony female black    0 BlackFemale
#> 1704     Emily female white    0 WhiteFemale
#> 1705   Kristen female white    0 WhiteFemale
#> 1706   Lakisha female black    0 BlackFemale
#> 1707      Anne female white    0 WhiteFemale
#> 1708   Lakisha female black    0 BlackFemale
#> 1709     Sarah female white    0 WhiteFemale
#> 1710   Tanisha female black    0 BlackFemale
#> 1711     Ebony female black    0 BlackFemale
#> 1712      Jill female white    1 WhiteFemale
#> 1713   Kristen female white    1 WhiteFemale
#> 1714   Tanisha female black    0 BlackFemale
#> 1715    Carrie female white    0 WhiteFemale
#> 1716      Jill female white    1 WhiteFemale
#> 1717    Keisha female black    0 BlackFemale
#> 1718   Lakisha female black    1 BlackFemale
#> 1719  Geoffrey   male white    0   WhiteMale
#> 1720     Kenya female black    0 BlackFemale
#> 1721    Laurie female white    0 WhiteFemale
#> 1722    Tamika female black    0 BlackFemale
#> 1723     Emily female white    0 WhiteFemale
#> 1724   Latonya female black    0 BlackFemale
#> 1725    Laurie female white    0 WhiteFemale
#> 1726    Tamika female black    0 BlackFemale
#> 1727   Allison female white    0 WhiteFemale
#> 1728   Lakisha female black    0 BlackFemale
#> 1729   Lakisha female black    0 BlackFemale
#> 1730  Meredith female white    0 WhiteFemale
#> 1731     Sarah female white    0 WhiteFemale
#> 1732   Tanisha female black    0 BlackFemale
#> 1733   Allison female white    0 WhiteFemale
#> 1734      Anne female white    0 WhiteFemale
#> 1735     Ebony female black    0 BlackFemale
#> 1736    Latoya female black    0 BlackFemale
#> 1737     Aisha female black    0 BlackFemale
#> 1738      Anne female white    1 WhiteFemale
#> 1739      Jill female white    0 WhiteFemale
#> 1740   Tanisha female black    0 BlackFemale
#> 1741   Brendan   male white    1   WhiteMale
#> 1742    Keisha female black    0 BlackFemale
#> 1743     Kenya female black    0 BlackFemale
#> 1744     Sarah female white    1 WhiteFemale
#> 1745      Todd   male white    0   WhiteMale
#> 1746    Tyrone   male black    0   BlackMale
#> 1747     Emily female white    0 WhiteFemale
#> 1748   Latonya female black    0 BlackFemale
#> 1749      Jill female white    0 WhiteFemale
#> 1750     Kenya female black    0 BlackFemale
#> 1751     Sarah female white    0 WhiteFemale
#> 1752   Tanisha female black    0 BlackFemale
#> 1753      Jill female white    0 WhiteFemale
#> 1754   Lakisha female black    0 BlackFemale
#> 1755    Latoya female black    0 BlackFemale
#> 1756      Neil   male white    0   WhiteMale
#> 1757    Keisha female black    0 BlackFemale
#> 1758    Laurie female white    0 WhiteFemale
#> 1759   Allison female white    0 WhiteFemale
#> 1760     Ebony female black    0 BlackFemale
#> 1761     Emily female white    0 WhiteFemale
#> 1762   Latonya female black    0 BlackFemale
#> 1763   Allison female white    0 WhiteFemale
#> 1764      Jill female white    0 WhiteFemale
#> 1765    Keisha female black    0 BlackFemale
#> 1766   Kristen female white    0 WhiteFemale
#> 1767    Latoya female black    0 BlackFemale
#> 1768   Rasheed   male black    0   BlackMale
#> 1769     Aisha female black    0 BlackFemale
#> 1770   Allison female white    0 WhiteFemale
#> 1771    Latoya female black    0 BlackFemale
#> 1772     Sarah female white    0 WhiteFemale
#> 1773   Brendan   male white    0   WhiteMale
#> 1774     Emily female white    0 WhiteFemale
#> 1775    Keisha female black    0 BlackFemale
#> 1776     Kenya female black    0 BlackFemale
#> 1777   Lakisha female black    0 BlackFemale
#> 1778     Sarah female white    0 WhiteFemale
#> 1779     Aisha female black    0 BlackFemale
#> 1780     Aisha female black    0 BlackFemale
#> 1781      Anne female white    0 WhiteFemale
#> 1782    Carrie female white    0 WhiteFemale
#> 1783     Emily female white    0 WhiteFemale
#> 1784     Kenya female black    0 BlackFemale
#> 1785     Kenya female black    0 BlackFemale
#> 1786   Kristen female white    0 WhiteFemale
#> 1787  Meredith female white    0 WhiteFemale
#> 1788   Tanisha female black    0 BlackFemale
#> 1789   Allison female white    0 WhiteFemale
#> 1790     Emily female white    0 WhiteFemale
#> 1791     Kenya female black    0 BlackFemale
#> 1792    Tamika female black    0 BlackFemale
#> 1793     Brett   male white    0   WhiteMale
#> 1794     Hakim   male black    0   BlackMale
#> 1795      Jill female white    0 WhiteFemale
#> 1796      Jill female white    0 WhiteFemale
#> 1797   Matthew   male white    0   WhiteMale
#> 1798    Tamika female black    0 BlackFemale
#> 1799   Tanisha female black    0 BlackFemale
#> 1800    Tyrone   male black    0   BlackMale
#> 1801      Jill female white    0 WhiteFemale
#> 1802    Tamika female black    0 BlackFemale
#> 1803      Anne female white    0 WhiteFemale
#> 1804   Latonya female black    0 BlackFemale
#> 1805    Latoya female black    0 BlackFemale
#> 1806     Sarah female white    0 WhiteFemale
#> 1807   Allison female white    0 WhiteFemale
#> 1808     Ebony female black    0 BlackFemale
#> 1809     Emily female white    0 WhiteFemale
#> 1810      Jill female white    0 WhiteFemale
#> 1811     Kenya female black    0 BlackFemale
#> 1812    Laurie female white    0 WhiteFemale
#> 1813    Tamika female black    0 BlackFemale
#> 1814   Tanisha female black    0 BlackFemale
#> 1815     Emily female white    1 WhiteFemale
#> 1816     Kenya female black    1 BlackFemale
#> 1817   Lakisha female black    0 BlackFemale
#> 1818      Todd   male white    0   WhiteMale
#> 1819     Aisha female black    0 BlackFemale
#> 1820      Jill female white    0 WhiteFemale
#> 1821   Lakisha female black    0 BlackFemale
#> 1822   Matthew   male white    0   WhiteMale
#> 1823   Lakisha female black    0 BlackFemale
#> 1824   Matthew   male white    0   WhiteMale
#> 1825      Brad   male white    0   WhiteMale
#> 1826    Tamika female black    0 BlackFemale
#> 1827      Anne female white    0 WhiteFemale
#> 1828    Keisha female black    0 BlackFemale
#> 1829   Kristen female white    0 WhiteFemale
#> 1830   Lakisha female black    0 BlackFemale
#> 1831   Allison female white    0 WhiteFemale
#> 1832     Emily female white    0 WhiteFemale
#> 1833     Sarah female white    0 WhiteFemale
#> 1834    Tamika female black    0 BlackFemale
#> 1835    Tamika female black    0 BlackFemale
#> 1836   Tanisha female black    0 BlackFemale
#> 1837  Geoffrey   male white    0   WhiteMale
#> 1838      Jill female white    0 WhiteFemale
#> 1839    Keisha female black    0 BlackFemale
#> 1840   Kristen female white    0 WhiteFemale
#> 1841    Tamika female black    0 BlackFemale
#> 1842   Tanisha female black    0 BlackFemale
#> 1843   Allison female white    0 WhiteFemale
#> 1844      Anne female white    0 WhiteFemale
#> 1845    Keisha female black    0 BlackFemale
#> 1846   Kristen female white    1 WhiteFemale
#> 1847   Lakisha female black    0 BlackFemale
#> 1848    Latoya female black    0 BlackFemale
#> 1849    Carrie female white    0 WhiteFemale
#> 1850    Keisha female black    0 BlackFemale
#> 1851     Kenya female black    0 BlackFemale
#> 1852     Leroy   male black    0   BlackMale
#> 1853      Neil   male white    0   WhiteMale
#> 1854     Sarah female white    0 WhiteFemale
#> 1855      Anne female white    0 WhiteFemale
#> 1856     Emily female white    0 WhiteFemale
#> 1857    Keisha female black    0 BlackFemale
#> 1858   Latonya female black    0 BlackFemale
#> 1859    Laurie female white    0 WhiteFemale
#> 1860   Tanisha female black    0 BlackFemale
#> 1861   Allison female white    0 WhiteFemale
#> 1862     Kenya female black    0 BlackFemale
#> 1863   Latonya female black    0 BlackFemale
#> 1864     Leroy   male black    0   BlackMale
#> 1865  Meredith female white    0 WhiteFemale
#> 1866      Todd   male white    0   WhiteMale
#> 1867     Kenya female black    0 BlackFemale
#> 1868      Todd   male white    0   WhiteMale
#> 1869     Emily female white    0 WhiteFemale
#> 1870   Latonya female black    0 BlackFemale
#> 1871    Laurie female white    0 WhiteFemale
#> 1872    Tamika female black    0 BlackFemale
#> 1873   Allison female white    0 WhiteFemale
#> 1874    Carrie female white    0 WhiteFemale
#> 1875   Kristen female white    0 WhiteFemale
#> 1876   Lakisha female black    0 BlackFemale
#> 1877   Latonya female black    0 BlackFemale
#> 1878    Tyrone   male black    0   BlackMale
#> 1879     Aisha female black    0 BlackFemale
#> 1880     Aisha female black    0 BlackFemale
#> 1881     Emily female white    0 WhiteFemale
#> 1882     Emily female white    0 WhiteFemale
#> 1883    Keisha female black    0 BlackFemale
#> 1884    Keisha female black    0 BlackFemale
#> 1885   Matthew   male white    0   WhiteMale
#> 1886     Sarah female white    0 WhiteFemale
#> 1887      Anne female white    0 WhiteFemale
#> 1888      Brad   male white    1   WhiteMale
#> 1889     Hakim   male black    0   BlackMale
#> 1890     Kenya female black    0 BlackFemale
#> 1891     Kenya female black    1 BlackFemale
#> 1892    Latoya female black    0 BlackFemale
#> 1893  Meredith female white    1 WhiteFemale
#> 1894  Meredith female white    0 WhiteFemale
#> 1895     Aisha female black    0 BlackFemale
#> 1896      Brad   male white    0   WhiteMale
#> 1897      Brad   male white    0   WhiteMale
#> 1898    Carrie female white    0 WhiteFemale
#> 1899   Darnell   male black    0   BlackMale
#> 1900     Ebony female black    0 BlackFemale
#> 1901     Emily female white    0 WhiteFemale
#> 1902  Geoffrey   male white    0   WhiteMale
#> 1903      Greg   male white    0   WhiteMale
#> 1904     Hakim   male black    0   BlackMale
#> 1905     Jamal   male black    0   BlackMale
#> 1906      Jill female white    0 WhiteFemale
#> 1907    Keisha female black    0 BlackFemale
#> 1908     Kenya female black    0 BlackFemale
#> 1909   Latonya female black    0 BlackFemale
#> 1910    Latoya female black    0 BlackFemale
#> 1911     Leroy   male black    0   BlackMale
#> 1912   Matthew   male white    1   WhiteMale
#> 1913   Matthew   male white    0   WhiteMale
#> 1914   Matthew   male white    0   WhiteMale
#> 1915   Matthew   male white    0   WhiteMale
#> 1916   Rasheed   male black    1   BlackMale
#> 1917      Todd   male white    0   WhiteMale
#> 1918  Tremayne   male black    0   BlackMale
#> 1919      Anne female white    0 WhiteFemale
#> 1920     Kenya female black    0 BlackFemale
#> 1921  Meredith female white    0 WhiteFemale
#> 1922    Tamika female black    0 BlackFemale
#> 1923      Anne female white    0 WhiteFemale
#> 1924     Kenya female black    0 BlackFemale
#> 1925  Meredith female white    0 WhiteFemale
#> 1926    Tamika female black    0 BlackFemale
#> 1927     Ebony female black    0 BlackFemale
#> 1928   Kristen female white    0 WhiteFemale
#> 1929   Latonya female black    0 BlackFemale
#> 1930    Laurie female white    0 WhiteFemale
#> 1931     Emily female white    0 WhiteFemale
#> 1932      Jill female white    0 WhiteFemale
#> 1933    Latoya female black    0 BlackFemale
#> 1934   Tanisha female black    0 BlackFemale
#> 1935    Keisha female black    1 BlackFemale
#> 1936   Kristen female white    1 WhiteFemale
#> 1937     Sarah female white    0 WhiteFemale
#> 1938    Tamika female black    1 BlackFemale
#> 1939     Emily female white    0 WhiteFemale
#> 1940    Latoya female black    0 BlackFemale
#> 1941      Jill female white    0 WhiteFemale
#> 1942   Lakisha female black    0 BlackFemale
#> 1943  Meredith female white    0 WhiteFemale
#> 1944   Tanisha female black    0 BlackFemale
#> 1945      Anne female white    0 WhiteFemale
#> 1946    Latoya female black    0 BlackFemale
#> 1947     Sarah female white    0 WhiteFemale
#> 1948   Tanisha female black    0 BlackFemale
#> 1949      Jill female white    0 WhiteFemale
#> 1950   Lakisha female black    0 BlackFemale
#> 1951    Laurie female white    1 WhiteFemale
#> 1952    Tamika female black    1 BlackFemale
#> 1953   Allison female white    0 WhiteFemale
#> 1954     Kenya female black    0 BlackFemale
#> 1955   Lakisha female black    0 BlackFemale
#> 1956    Laurie female white    0 WhiteFemale
#> 1957   Allison female white    0 WhiteFemale
#> 1958      Anne female white    0 WhiteFemale
#> 1959     Ebony female black    0 BlackFemale
#> 1960     Kenya female black    0 BlackFemale
#> 1961     Ebony female black    1 BlackFemale
#> 1962      Jill female white    0 WhiteFemale
#> 1963    Laurie female white    0 WhiteFemale
#> 1964    Tamika female black    0 BlackFemale
#> 1965     Emily female white    0 WhiteFemale
#> 1966    Keisha female black    0 BlackFemale
#> 1967     Kenya female black    0 BlackFemale
#> 1968     Sarah female white    0 WhiteFemale
#> 1969     Hakim   male black    0   BlackMale
#> 1970     Leroy   male black    1   BlackMale
#> 1971      Neil   male white    0   WhiteMale
#> 1972      Todd   male white    0   WhiteMale
#> 1973      Jill female white    0 WhiteFemale
#> 1974    Keisha female black    0 BlackFemale
#> 1975  Meredith female white    0 WhiteFemale
#> 1976    Tamika female black    0 BlackFemale
#> 1977      Anne female white    0 WhiteFemale
#> 1978     Ebony female black    1 BlackFemale
#> 1979      Jill female white    0 WhiteFemale
#> 1980    Tamika female black    0 BlackFemale
#> 1981     Aisha female black    0 BlackFemale
#> 1982      Anne female white    0 WhiteFemale
#> 1983     Kenya female black    0 BlackFemale
#> 1984   Kristen female white    0 WhiteFemale
#> 1985     Aisha female black    0 BlackFemale
#> 1986      Brad   male white    1   WhiteMale
#> 1987   Brendan   male white    0   WhiteMale
#> 1988   Brendan   male white    0   WhiteMale
#> 1989     Brett   male white    0   WhiteMale
#> 1990    Carrie female white    0 WhiteFemale
#> 1991     Ebony female black    0 BlackFemale
#> 1992  Geoffrey   male white    0   WhiteMale
#> 1993     Jamal   male black    0   BlackMale
#> 1994       Jay   male white    0   WhiteMale
#> 1995    Kareem   male black    0   BlackMale
#> 1996     Kenya female black    0 BlackFemale
#> 1997     Kenya female black    0 BlackFemale
#> 1998   Lakisha female black    0 BlackFemale
#> 1999      Neil   male white    0   WhiteMale
#> 2000     Sarah female white    0 WhiteFemale
#> 2001   Tanisha female black    0 BlackFemale
#> 2002      Todd   male white    0   WhiteMale
#> 2003    Tyrone   male black    0   BlackMale
#> 2004    Tyrone   male black    0   BlackMale
#> 2005     Emily female white    0 WhiteFemale
#> 2006   Lakisha female black    0 BlackFemale
#> 2007     Sarah female white    0 WhiteFemale
#> 2008   Tanisha female black    0 BlackFemale
#> 2009      Jill female white    1 WhiteFemale
#> 2010   Latonya female black    1 BlackFemale
#> 2011    Latoya female black    1 BlackFemale
#> 2012     Sarah female white    0 WhiteFemale
#> 2013    Keisha female black    0 BlackFemale
#> 2014   Kristen female white    1 WhiteFemale
#> 2015    Latoya female black    0 BlackFemale
#> 2016     Sarah female white    0 WhiteFemale
#> 2017      Jill female white    0 WhiteFemale
#> 2018     Leroy   male black    0   BlackMale
#> 2019  Meredith female white    0 WhiteFemale
#> 2020   Tanisha female black    0 BlackFemale
#> 2021     Emily female white    0 WhiteFemale
#> 2022   Latonya female black    0 BlackFemale
#> 2023    Laurie female white    0 WhiteFemale
#> 2024    Tamika female black    0 BlackFemale
#> 2025     Ebony female black    0 BlackFemale
#> 2026     Emily female white    0 WhiteFemale
#> 2027     Sarah female white    1 WhiteFemale
#> 2028    Tamika female black    0 BlackFemale
#> 2029     Aisha female black    0 BlackFemale
#> 2030     Emily female white    0 WhiteFemale
#> 2031   Kristen female white    0 WhiteFemale
#> 2032   Tanisha female black    0 BlackFemale
#> 2033     Ebony female black    0 BlackFemale
#> 2034   Latonya female black    0 BlackFemale
#> 2035  Meredith female white    0 WhiteFemale
#> 2036     Sarah female white    0 WhiteFemale
#> 2037   Kristen female white    0 WhiteFemale
#> 2038   Latonya female black    0 BlackFemale
#> 2039  Meredith female white    0 WhiteFemale
#> 2040    Tamika female black    0 BlackFemale
#> 2041   Allison female white    0 WhiteFemale
#> 2042      Anne female white    0 WhiteFemale
#> 2043   Lakisha female black    0 BlackFemale
#> 2044    Tamika female black    0 BlackFemale
#> 2045   Allison female white    0 WhiteFemale
#> 2046   Latonya female black    0 BlackFemale
#> 2047    Laurie female white    0 WhiteFemale
#> 2048    Tamika female black    0 BlackFemale
#> 2049      Jill female white    0 WhiteFemale
#> 2050     Kenya female black    0 BlackFemale
#> 2051     Sarah female white    0 WhiteFemale
#> 2052    Tamika female black    0 BlackFemale
#> 2053      Anne female white    0 WhiteFemale
#> 2054   Lakisha female black    0 BlackFemale
#> 2055     Sarah female white    0 WhiteFemale
#> 2056    Tamika female black    0 BlackFemale
#> 2057     Emily female white    0 WhiteFemale
#> 2058   Lakisha female black    0 BlackFemale
#> 2059    Latoya female black    0 BlackFemale
#> 2060  Meredith female white    0 WhiteFemale
#> 2061     Aisha female black    0 BlackFemale
#> 2062   Brendan   male white    0   WhiteMale
#> 2063     Brett   male white    0   WhiteMale
#> 2064   Darnell   male black    0   BlackMale
#> 2065  Geoffrey   male white    0   WhiteMale
#> 2066      Greg   male white    0   WhiteMale
#> 2067       Jay   male white    0   WhiteMale
#> 2068  Jermaine   male black    0   BlackMale
#> 2069      Jill female white    0 WhiteFemale
#> 2070    Keisha female black    0 BlackFemale
#> 2071   Kristen female white    0 WhiteFemale
#> 2072   Kristen female white    0 WhiteFemale
#> 2073   Lakisha female black    0 BlackFemale
#> 2074    Laurie female white    0 WhiteFemale
#> 2075     Leroy   male black    0   BlackMale
#> 2076     Leroy   male black    0   BlackMale
#> 2077     Leroy   male black    0   BlackMale
#> 2078   Matthew   male white    0   WhiteMale
#> 2079      Neil   male white    0   WhiteMale
#> 2080      Neil   male white    0   WhiteMale
#> 2081    Tamika female black    0 BlackFemale
#> 2082    Tyrone   male black    0   BlackMale
#> 2083    Tyrone   male black    0   BlackMale
#> 2084    Tyrone   male black    0   BlackMale
#> 2085      Anne female white    0 WhiteFemale
#> 2086    Carrie female white    0 WhiteFemale
#> 2087    Keisha female black    0 BlackFemale
#> 2088    Latoya female black    0 BlackFemale
#> 2089      Anne female white    0 WhiteFemale
#> 2090      Jill female white    0 WhiteFemale
#> 2091   Latonya female black    0 BlackFemale
#> 2092   Tanisha female black    0 BlackFemale
#> 2093      Anne female white    1 WhiteFemale
#> 2094   Lakisha female black    1 BlackFemale
#> 2095     Sarah female white    0 WhiteFemale
#> 2096   Tanisha female black    0 BlackFemale
#> 2097   Allison female white    1 WhiteFemale
#> 2098    Carrie female white    1 WhiteFemale
#> 2099   Latonya female black    1 BlackFemale
#> 2100    Tamika female black    1 BlackFemale
#> 2101     Aisha female black    0 BlackFemale
#> 2102     Emily female white    0 WhiteFemale
#> 2103    Latoya female black    0 BlackFemale
#> 2104  Meredith female white    0 WhiteFemale
#> 2105     Aisha female black    0 BlackFemale
#> 2106   Allison female white    0 WhiteFemale
#> 2107    Carrie female white    1 WhiteFemale
#> 2108    Latoya female black    0 BlackFemale
#> 2109     Emily female white    1 WhiteFemale
#> 2110   Latonya female black    0 BlackFemale
#> 2111    Laurie female white    1 WhiteFemale
#> 2112    Tyrone   male black    0   BlackMale
#> 2113      Anne female white    0 WhiteFemale
#> 2114    Latoya female black    0 BlackFemale
#> 2115     Sarah female white    0 WhiteFemale
#> 2116   Tanisha female black    0 BlackFemale
#> 2117     Aisha female black    0 BlackFemale
#> 2118    Laurie female white    0 WhiteFemale
#> 2119     Sarah female white    0 WhiteFemale
#> 2120    Tamika female black    0 BlackFemale
#> 2121     Aisha female black    0 BlackFemale
#> 2122     Emily female white    0 WhiteFemale
#> 2123    Laurie female white    0 WhiteFemale
#> 2124   Tanisha female black    0 BlackFemale
#> 2125     Ebony female black    0 BlackFemale
#> 2126    Laurie female white    0 WhiteFemale
#> 2127  Meredith female white    0 WhiteFemale
#> 2128    Tamika female black    0 BlackFemale
#> 2129    Latoya female black    0 BlackFemale
#> 2130  Meredith female white    0 WhiteFemale
#> 2131     Sarah female white    0 WhiteFemale
#> 2132    Tamika female black    0 BlackFemale
#> 2133   Allison female white    0 WhiteFemale
#> 2134      Jill female white    0 WhiteFemale
#> 2135     Kenya female black    0 BlackFemale
#> 2136    Latoya female black    0 BlackFemale
#> 2137     Ebony female black    0 BlackFemale
#> 2138     Emily female white    0 WhiteFemale
#> 2139      Jill female white    0 WhiteFemale
#> 2140   Lakisha female black    0 BlackFemale
#> 2141   Allison female white    0 WhiteFemale
#> 2142     Emily female white    0 WhiteFemale
#> 2143     Kenya female black    0 BlackFemale
#> 2144    Tamika female black    0 BlackFemale
#> 2145      Anne female white    0 WhiteFemale
#> 2146   Kristen female white    0 WhiteFemale
#> 2147   Lakisha female black    0 BlackFemale
#> 2148    Tamika female black    0 BlackFemale
#> 2149      Anne female white    0 WhiteFemale
#> 2150    Carrie female white    0 WhiteFemale
#> 2151   Latonya female black    0 BlackFemale
#> 2152    Latoya female black    0 BlackFemale
#> 2153      Brad   male white    0   WhiteMale
#> 2154   Brendan   male white    0   WhiteMale
#> 2155     Brett   male white    0   WhiteMale
#> 2156    Carrie female white    0 WhiteFemale
#> 2157     Ebony female black    0 BlackFemale
#> 2158     Emily female white    0 WhiteFemale
#> 2159  Geoffrey   male white    0   WhiteMale
#> 2160      Greg   male white    0   WhiteMale
#> 2161      Greg   male white    0   WhiteMale
#> 2162     Hakim   male black    0   BlackMale
#> 2163     Jamal   male black    0   BlackMale
#> 2164     Jamal   male black    0   BlackMale
#> 2165  Jermaine   male black    1   BlackMale
#> 2166    Kareem   male black    0   BlackMale
#> 2167    Keisha female black    0 BlackFemale
#> 2168   Kristen female white    0 WhiteFemale
#> 2169   Lakisha female black    0 BlackFemale
#> 2170   Lakisha female black    0 BlackFemale
#> 2171   Latonya female black    0 BlackFemale
#> 2172   Latonya female black    0 BlackFemale
#> 2173    Latoya female black    0 BlackFemale
#> 2174    Latoya female black    0 BlackFemale
#> 2175    Latoya female black    0 BlackFemale
#> 2176    Laurie female white    0 WhiteFemale
#> 2177    Laurie female white    0 WhiteFemale
#> 2178    Laurie female white    0 WhiteFemale
#> 2179   Matthew   male white    0   WhiteMale
#> 2180   Matthew   male white    0   WhiteMale
#> 2181   Matthew   male white    0   WhiteMale
#> 2182      Neil   male white    0   WhiteMale
#> 2183      Neil   male white    0   WhiteMale
#> 2184   Rasheed   male black    0   BlackMale
#> 2185   Rasheed   male black    0   BlackMale
#> 2186    Tamika female black    0 BlackFemale
#> 2187   Tanisha female black    0 BlackFemale
#> 2188   Tanisha female black    0 BlackFemale
#> 2189      Todd   male white    0   WhiteMale
#> 2190      Todd   male white    0   WhiteMale
#> 2191      Todd   male white    0   WhiteMale
#> 2192    Tyrone   male black    0   BlackMale
#> 2193   Latonya female black    0 BlackFemale
#> 2194  Meredith female white    1 WhiteFemale
#> 2195     Sarah female white    1 WhiteFemale
#> 2196   Tanisha female black    0 BlackFemale
#> 2197   Allison female white    0 WhiteFemale
#> 2198     Kenya female black    0 BlackFemale
#> 2199   Kristen female white    0 WhiteFemale
#> 2200   Lakisha female black    0 BlackFemale
#> 2201    Carrie female white    0 WhiteFemale
#> 2202    Keisha female black    1 BlackFemale
#> 2203    Latoya female black    0 BlackFemale
#> 2204    Laurie female white    1 WhiteFemale
#> 2205   Allison female white    1 WhiteFemale
#> 2206     Ebony female black    0 BlackFemale
#> 2207    Latoya female black    0 BlackFemale
#> 2208    Laurie female white    1 WhiteFemale
#> 2209      Jill female white    0 WhiteFemale
#> 2210    Keisha female black    0 BlackFemale
#> 2211   Latonya female black    1 BlackFemale
#> 2212     Sarah female white    0 WhiteFemale
#> 2213     Emily female white    0 WhiteFemale
#> 2214      Jill female white    0 WhiteFemale
#> 2215    Latoya female black    0 BlackFemale
#> 2216    Tamika female black    0 BlackFemale
#> 2217     Emily female white    0 WhiteFemale
#> 2218      Jill female white    0 WhiteFemale
#> 2219     Kenya female black    0 BlackFemale
#> 2220    Latoya female black    0 BlackFemale
#> 2221     Aisha female black    0 BlackFemale
#> 2222    Carrie female white    1 WhiteFemale
#> 2223   Latonya female black    1 BlackFemale
#> 2224     Sarah female white    0 WhiteFemale
#> 2225     Kenya female black    0 BlackFemale
#> 2226   Kristen female white    0 WhiteFemale
#> 2227   Lakisha female black    0 BlackFemale
#> 2228  Meredith female white    1 WhiteFemale
#> 2229    Carrie female white    1 WhiteFemale
#> 2230     Kenya female black    0 BlackFemale
#> 2231   Latonya female black    0 BlackFemale
#> 2232    Laurie female white    0 WhiteFemale
#> 2233   Allison female white    0 WhiteFemale
#> 2234   Brendan   male white    1   WhiteMale
#> 2235     Jamal   male black    0   BlackMale
#> 2236    Tamika female black    0 BlackFemale
#> 2237   Allison female white    0 WhiteFemale
#> 2238     Emily female white    0 WhiteFemale
#> 2239   Latonya female black    0 BlackFemale
#> 2240    Latoya female black    0 BlackFemale
#> 2241     Aisha female black    0 BlackFemale
#> 2242   Allison female white    0 WhiteFemale
#> 2243   Kristen female white    0 WhiteFemale
#> 2244   Latonya female black    0 BlackFemale
#> 2245     Ebony female black    0 BlackFemale
#> 2246     Emily female white    0 WhiteFemale
#> 2247   Latonya female black    0 BlackFemale
#> 2248    Laurie female white    0 WhiteFemale
#> 2249   Brendan   male white    0   WhiteMale
#> 2250   Brendan   male white    0   WhiteMale
#> 2251     Jamal   male black    0   BlackMale
#> 2252  Jermaine   male black    0   BlackMale
#> 2253   Allison female white    0 WhiteFemale
#> 2254     Emily female white    0 WhiteFemale
#> 2255    Tamika female black    0 BlackFemale
#> 2256   Tanisha female black    1 BlackFemale
#> 2257     Ebony female black    0 BlackFemale
#> 2258     Emily female white    0 WhiteFemale
#> 2259    Keisha female black    0 BlackFemale
#> 2260  Meredith female white    0 WhiteFemale
#> 2261     Ebony female black    0 BlackFemale
#> 2262   Kristen female white    0 WhiteFemale
#> 2263  Meredith female white    0 WhiteFemale
#> 2264   Tanisha female black    0 BlackFemale
#> 2265     Emily female white    0 WhiteFemale
#> 2266    Keisha female black    0 BlackFemale
#> 2267    Latoya female black    0 BlackFemale
#> 2268    Laurie female white    0 WhiteFemale
#> 2269     Aisha female black    0 BlackFemale
#> 2270   Allison female white    0 WhiteFemale
#> 2271   Brendan   male white    0   WhiteMale
#> 2272   Brendan   male white    0   WhiteMale
#> 2273    Carrie female white    0 WhiteFemale
#> 2274    Carrie female white    0 WhiteFemale
#> 2275   Darnell   male black    0   BlackMale
#> 2276     Ebony female black    0 BlackFemale
#> 2277     Emily female white    0 WhiteFemale
#> 2278  Geoffrey   male white    0   WhiteMale
#> 2279  Geoffrey   male white    0   WhiteMale
#> 2280      Greg   male white    0   WhiteMale
#> 2281     Hakim   male black    0   BlackMale
#> 2282       Jay   male white    0   WhiteMale
#> 2283    Kareem   male black    0   BlackMale
#> 2284     Kenya female black    0 BlackFemale
#> 2285     Kenya female black    0 BlackFemale
#> 2286   Kristen female white    0 WhiteFemale
#> 2287   Kristen female white    0 WhiteFemale
#> 2288   Lakisha female black    0 BlackFemale
#> 2289   Lakisha female black    0 BlackFemale
#> 2290   Lakisha female black    0 BlackFemale
#> 2291   Latonya female black    0 BlackFemale
#> 2292    Latoya female black    0 BlackFemale
#> 2293    Laurie female white    0 WhiteFemale
#> 2294   Matthew   male white    0   WhiteMale
#> 2295  Meredith female white    0 WhiteFemale
#> 2296      Neil   male white    0   WhiteMale
#> 2297   Rasheed   male black    0   BlackMale
#> 2298    Tamika female black    0 BlackFemale
#> 2299   Tanisha female black    0 BlackFemale
#> 2300  Tremayne   male black    0   BlackMale
#> 2301     Aisha female black    0 BlackFemale
#> 2302      Anne female white    1 WhiteFemale
#> 2303    Carrie female white    1 WhiteFemale
#> 2304     Kenya female black    1 BlackFemale
#> 2305    Keisha female black    0 BlackFemale
#> 2306   Kristen female white    0 WhiteFemale
#> 2307   Latonya female black    0 BlackFemale
#> 2308  Meredith female white    0 WhiteFemale
#> 2309    Carrie female white    0 WhiteFemale
#> 2310      Jill female white    0 WhiteFemale
#> 2311    Keisha female black    0 BlackFemale
#> 2312   Lakisha female black    0 BlackFemale
#> 2313     Aisha female black    0 BlackFemale
#> 2314   Allison female white    0 WhiteFemale
#> 2315     Emily female white    0 WhiteFemale
#> 2316   Tanisha female black    0 BlackFemale
#> 2317      Anne female white    1 WhiteFemale
#> 2318     Ebony female black    1 BlackFemale
#> 2319     Emily female white    1 WhiteFemale
#> 2320    Tamika female black    1 BlackFemale
#> 2321     Aisha female black    0 BlackFemale
#> 2322   Allison female white    0 WhiteFemale
#> 2323   Latonya female black    0 BlackFemale
#> 2324    Laurie female white    0 WhiteFemale
#> 2325      Anne female white    1 WhiteFemale
#> 2326  Geoffrey   male white    1   WhiteMale
#> 2327  Jermaine   male black    1   BlackMale
#> 2328    Latoya female black    0 BlackFemale
#> 2329     Aisha female black    0 BlackFemale
#> 2330   Kristen female white    0 WhiteFemale
#> 2331   Latonya female black    0 BlackFemale
#> 2332     Sarah female white    0 WhiteFemale
#> 2333      Jill female white    0 WhiteFemale
#> 2334    Keisha female black    0 BlackFemale
#> 2335   Kristen female white    0 WhiteFemale
#> 2336   Lakisha female black    0 BlackFemale
#> 2337     Aisha female black    0 BlackFemale
#> 2338     Emily female white    0 WhiteFemale
#> 2339   Latonya female black    0 BlackFemale
#> 2340    Laurie female white    0 WhiteFemale
#> 2341      Anne female white    0 WhiteFemale
#> 2342      Anne female white    0 WhiteFemale
#> 2343      Anne female white    0 WhiteFemale
#> 2344      Brad   male white    0   WhiteMale
#> 2345      Brad   male white    0   WhiteMale
#> 2346     Emily female white    0 WhiteFemale
#> 2347      Greg   male white    0   WhiteMale
#> 2348     Hakim   male black    0   BlackMale
#> 2349     Jamal   male black    0   BlackMale
#> 2350  Jermaine   male black    0   BlackMale
#> 2351      Jill female white    0 WhiteFemale
#> 2352    Kareem   male black    0   BlackMale
#> 2353    Kareem   male black    0   BlackMale
#> 2354    Keisha female black    0 BlackFemale
#> 2355    Keisha female black    0 BlackFemale
#> 2356    Keisha female black    0 BlackFemale
#> 2357   Lakisha female black    0 BlackFemale
#> 2358   Lakisha female black    0 BlackFemale
#> 2359    Laurie female white    0 WhiteFemale
#> 2360    Laurie female white    0 WhiteFemale
#> 2361     Leroy   male black    0   BlackMale
#> 2362     Leroy   male black    0   BlackMale
#> 2363  Meredith female white    0 WhiteFemale
#> 2364  Meredith female white    0 WhiteFemale
#> 2365      Neil   male white    0   WhiteMale
#> 2366   Rasheed   male black    0   BlackMale
#> 2367    Tamika female black    0 BlackFemale
#> 2368      Todd   male white    0   WhiteMale
#> 2369     Aisha female black    0 BlackFemale
#> 2370      Anne female white    0 WhiteFemale
#> 2371  Meredith female white    0 WhiteFemale
#> 2372    Tamika female black    0 BlackFemale
#> 2373     Aisha female black    0 BlackFemale
#> 2374      Jill female white    0 WhiteFemale
#> 2375  Meredith female white    0 WhiteFemale
#> 2376   Tanisha female black    1 BlackFemale
#> 2377   Allison female white    0 WhiteFemale
#> 2378      Anne female white    0 WhiteFemale
#> 2379    Keisha female black    1 BlackFemale
#> 2380   Lakisha female black    1 BlackFemale
#> 2381   Allison female white    1 WhiteFemale
#> 2382   Latonya female black    1 BlackFemale
#> 2383    Latoya female black    1 BlackFemale
#> 2384  Meredith female white    1 WhiteFemale
#> 2385     Aisha female black    0 BlackFemale
#> 2386     Kenya female black    0 BlackFemale
#> 2387    Laurie female white    0 WhiteFemale
#> 2388  Meredith female white    0 WhiteFemale
#> 2389   Allison female white    0 WhiteFemale
#> 2390   Latonya female black    0 BlackFemale
#> 2391     Sarah female white    0 WhiteFemale
#> 2392    Tamika female black    0 BlackFemale
#> 2393      Jill female white    1 WhiteFemale
#> 2394   Latonya female black    0 BlackFemale
#> 2395    Latoya female black    0 BlackFemale
#> 2396  Meredith female white    1 WhiteFemale
#> 2397   Allison female white    0 WhiteFemale
#> 2398    Latoya female black    0 BlackFemale
#> 2399  Meredith female white    0 WhiteFemale
#> 2400    Tamika female black    0 BlackFemale
#> 2401     Ebony female black    0 BlackFemale
#> 2402     Kenya female black    0 BlackFemale
#> 2403   Kristen female white    0 WhiteFemale
#> 2404    Laurie female white    0 WhiteFemale
#> 2405     Hakim   male black    0   BlackMale
#> 2406       Jay   male white    0   WhiteMale
#> 2407     Leroy   male black    0   BlackMale
#> 2408  Meredith female white    0 WhiteFemale
#> 2409     Ebony female black    0 BlackFemale
#> 2410   Kristen female white    0 WhiteFemale
#> 2411   Latonya female black    0 BlackFemale
#> 2412  Meredith female white    0 WhiteFemale
#> 2413     Aisha female black    0 BlackFemale
#> 2414    Carrie female white    0 WhiteFemale
#> 2415     Ebony female black    0 BlackFemale
#> 2416   Kristen female white    0 WhiteFemale
#> 2417     Jamal   male black    0   BlackMale
#> 2418      Todd   male white    0   WhiteMale
#> 2419      Anne female white    0 WhiteFemale
#> 2420     Ebony female black    0 BlackFemale
#> 2421     Kenya female black    0 BlackFemale
#> 2422   Kristen female white    0 WhiteFemale
#> 2423   Allison female white    0 WhiteFemale
#> 2424      Anne female white    0 WhiteFemale
#> 2425    Tamika female black    0 BlackFemale
#> 2426   Tanisha female black    0 BlackFemale
#> 2427   Allison female white    0 WhiteFemale
#> 2428    Keisha female black    0 BlackFemale
#> 2429  Meredith female white    0 WhiteFemale
#> 2430   Tanisha female black    0 BlackFemale
#> 2431     Aisha female black    0 BlackFemale
#> 2432      Anne female white    0 WhiteFemale
#> 2433      Anne female white    0 WhiteFemale
#> 2434      Brad   male white    0   WhiteMale
#> 2435   Brendan   male white    0   WhiteMale
#> 2436     Brett   male white    0   WhiteMale
#> 2437     Brett   male white    0   WhiteMale
#> 2438     Brett   male white    0   WhiteMale
#> 2439     Ebony female black    0 BlackFemale
#> 2440     Ebony female black    0 BlackFemale
#> 2441  Geoffrey   male white    0   WhiteMale
#> 2442      Greg   male white    0   WhiteMale
#> 2443     Hakim   male black    0   BlackMale
#> 2444     Hakim   male black    0   BlackMale
#> 2445       Jay   male white    0   WhiteMale
#> 2446  Jermaine   male black    0   BlackMale
#> 2447      Jill female white    0 WhiteFemale
#> 2448    Kareem   male black    0   BlackMale
#> 2449    Keisha female black    0 BlackFemale
#> 2450     Kenya female black    0 BlackFemale
#> 2451   Kristen female white    0 WhiteFemale
#> 2452   Lakisha female black    0 BlackFemale
#> 2453   Latonya female black    0 BlackFemale
#> 2454   Latonya female black    0 BlackFemale
#> 2455     Leroy   male black    0   BlackMale
#> 2456     Leroy   male black    0   BlackMale
#> 2457   Matthew   male white    0   WhiteMale
#> 2458      Neil   male white    0   WhiteMale
#> 2459     Sarah female white    0 WhiteFemale
#> 2460      Todd   male white    0   WhiteMale
#> 2461  Tremayne   male black    0   BlackMale
#> 2462    Tyrone   male black    0   BlackMale
#> 2463     Ebony female black    0 BlackFemale
#> 2464   Latonya female black    0 BlackFemale
#> 2465  Meredith female white    0 WhiteFemale
#> 2466     Sarah female white    0 WhiteFemale
#> 2467     Ebony female black    0 BlackFemale
#> 2468   Kristen female white    1 WhiteFemale
#> 2469  Meredith female white    1 WhiteFemale
#> 2470   Tanisha female black    1 BlackFemale
#> 2471     Emily female white    0 WhiteFemale
#> 2472    Keisha female black    0 BlackFemale
#> 2473   Lakisha female black    0 BlackFemale
#> 2474  Meredith female white    0 WhiteFemale
#> 2475     Aisha female black    0 BlackFemale
#> 2476      Anne female white    1 WhiteFemale
#> 2477    Carrie female white    1 WhiteFemale
#> 2478    Latoya female black    0 BlackFemale
#> 2479      Jill female white    0 WhiteFemale
#> 2480   Lakisha female black    0 BlackFemale
#> 2481     Sarah female white    0 WhiteFemale
#> 2482    Tamika female black    0 BlackFemale
#> 2483   Allison female white    0 WhiteFemale
#> 2484     Emily female white    0 WhiteFemale
#> 2485     Kenya female black    0 BlackFemale
#> 2486    Latoya female black    0 BlackFemale
#> 2487   Allison female white    0 WhiteFemale
#> 2488      Anne female white    0 WhiteFemale
#> 2489   Lakisha female black    0 BlackFemale
#> 2490    Tamika female black    0 BlackFemale
#> 2491   Kristen female white    1 WhiteFemale
#> 2492   Latonya female black    1 BlackFemale
#> 2493      Neil   male white    0   WhiteMale
#> 2494    Tyrone   male black    0   BlackMale
#> 2495     Aisha female black    0 BlackFemale
#> 2496      Anne female white    0 WhiteFemale
#> 2497    Latoya female black    0 BlackFemale
#> 2498    Laurie female white    0 WhiteFemale
#> 2499   Brendan   male white    0   WhiteMale
#> 2500     Brett   male white    0   WhiteMale
#> 2501     Leroy   male black    0   BlackMale
#> 2502  Tremayne   male black    0   BlackMale
#> 2503      Anne female white    0 WhiteFemale
#> 2504     Emily female white    0 WhiteFemale
#> 2505    Keisha female black    0 BlackFemale
#> 2506    Latoya female black    0 BlackFemale
#> 2507   Kristen female white    0 WhiteFemale
#> 2508    Latoya female black    0 BlackFemale
#> 2509     Sarah female white    0 WhiteFemale
#> 2510    Tamika female black    0 BlackFemale
#> 2511     Aisha female black    0 BlackFemale
#> 2512     Aisha female black    0 BlackFemale
#> 2513   Allison female white    0 WhiteFemale
#> 2514   Allison female white    0 WhiteFemale
#> 2515   Brendan   male white    0   WhiteMale
#> 2516     Brett   male white    1   WhiteMale
#> 2517     Brett   male white    0   WhiteMale
#> 2518     Brett   male white    0   WhiteMale
#> 2519     Emily female white    0 WhiteFemale
#> 2520       Jay   male white    1   WhiteMale
#> 2521      Jill female white    0 WhiteFemale
#> 2522      Jill female white    0 WhiteFemale
#> 2523    Kareem   male black    0   BlackMale
#> 2524    Keisha female black    0 BlackFemale
#> 2525   Lakisha female black    0 BlackFemale
#> 2526   Latonya female black    0 BlackFemale
#> 2527   Latonya female black    0 BlackFemale
#> 2528   Latonya female black    0 BlackFemale
#> 2529   Matthew   male white    0   WhiteMale
#> 2530      Neil   male white    0   WhiteMale
#> 2531    Tamika female black    1 BlackFemale
#> 2532    Tamika female black    0 BlackFemale
#> 2533  Tremayne   male black    0   BlackMale
#> 2534    Tyrone   male black    0   BlackMale
#> 2535     Emily female white    0 WhiteFemale
#> 2536   Latonya female black    0 BlackFemale
#> 2537     Sarah female white    0 WhiteFemale
#> 2538   Tanisha female black    0 BlackFemale
#> 2539     Aisha female black    0 BlackFemale
#> 2540   Allison female white    1 WhiteFemale
#> 2541     Emily female white    1 WhiteFemale
#> 2542   Lakisha female black    1 BlackFemale
#> 2543      Jill female white    0 WhiteFemale
#> 2544   Kristen female white    0 WhiteFemale
#> 2545   Latonya female black    0 BlackFemale
#> 2546    Tamika female black    0 BlackFemale
#> 2547   Allison female white    0 WhiteFemale
#> 2548    Keisha female black    0 BlackFemale
#> 2549   Kristen female white    0 WhiteFemale
#> 2550   Tanisha female black    1 BlackFemale
#> 2551     Emily female white    0 WhiteFemale
#> 2552   Lakisha female black    0 BlackFemale
#> 2553   Matthew   male white    0   WhiteMale
#> 2554   Tanisha female black    0 BlackFemale
#> 2555      Anne female white    0 WhiteFemale
#> 2556    Latoya female black    0 BlackFemale
#> 2557    Laurie female white    1 WhiteFemale
#> 2558    Tamika female black    0 BlackFemale
#> 2559   Brendan   male white    0   WhiteMale
#> 2560     Jamal   male black    0   BlackMale
#> 2561     Ebony female black    0 BlackFemale
#> 2562     Emily female white    0 WhiteFemale
#> 2563   Latonya female black    1 BlackFemale
#> 2564  Meredith female white    0 WhiteFemale
#> 2565     Ebony female black    0 BlackFemale
#> 2566     Emily female white    0 WhiteFemale
#> 2567    Keisha female black    0 BlackFemale
#> 2568    Laurie female white    0 WhiteFemale
#> 2569      Anne female white    0 WhiteFemale
#> 2570      Brad   male white    0   WhiteMale
#> 2571     Brett   male white    0   WhiteMale
#> 2572     Ebony female black    0 BlackFemale
#> 2573     Emily female white    0 WhiteFemale
#> 2574     Emily female white    0 WhiteFemale
#> 2575     Jamal   male black    0   BlackMale
#> 2576       Jay   male white    0   WhiteMale
#> 2577  Jermaine   male black    0   BlackMale
#> 2578      Jill female white    0 WhiteFemale
#> 2579    Kareem   male black    0   BlackMale
#> 2580    Kareem   male black    0   BlackMale
#> 2581    Kareem   male black    0   BlackMale
#> 2582    Keisha female black    0 BlackFemale
#> 2583   Kristen female white    0 WhiteFemale
#> 2584   Lakisha female black    0 BlackFemale
#> 2585     Leroy   male black    0   BlackMale
#> 2586     Leroy   male black    0   BlackMale
#> 2587   Matthew   male white    0   WhiteMale
#> 2588   Matthew   male white    0   WhiteMale
#> 2589      Neil   male white    0   WhiteMale
#> 2590     Sarah female white    0 WhiteFemale
#> 2591     Sarah female white    0 WhiteFemale
#> 2592    Tamika female black    0 BlackFemale
#> 2593   Tanisha female black    0 BlackFemale
#> 2594   Tanisha female black    0 BlackFemale
#> 2595   Tanisha female black    0 BlackFemale
#> 2596      Todd   male white    0   WhiteMale
#> 2597      Todd   male white    0   WhiteMale
#> 2598      Todd   male white    0   WhiteMale
#> 2599  Tremayne   male black    0   BlackMale
#> 2600  Tremayne   male black    0   BlackMale
#> 2601     Emily female white    0 WhiteFemale
#> 2602      Jill female white    0 WhiteFemale
#> 2603   Lakisha female black    0 BlackFemale
#> 2604   Tanisha female black    0 BlackFemale
#> 2605      Jill female white    0 WhiteFemale
#> 2606     Kenya female black    0 BlackFemale
#> 2607   Kristen female white    0 WhiteFemale
#> 2608    Latoya female black    0 BlackFemale
#> 2609    Carrie female white    0 WhiteFemale
#> 2610     Emily female white    0 WhiteFemale
#> 2611   Latonya female black    0 BlackFemale
#> 2612    Latoya female black    0 BlackFemale
#> 2613      Anne female white    1 WhiteFemale
#> 2614    Keisha female black    1 BlackFemale
#> 2615     Kenya female black    1 BlackFemale
#> 2616  Meredith female white    1 WhiteFemale
#> 2617      Anne female white    0 WhiteFemale
#> 2618   Kristen female white    0 WhiteFemale
#> 2619   Lakisha female black    0 BlackFemale
#> 2620   Tanisha female black    0 BlackFemale
#> 2621      Anne female white    1 WhiteFemale
#> 2622     Ebony female black    1 BlackFemale
#> 2623   Latonya female black    0 BlackFemale
#> 2624     Sarah female white    0 WhiteFemale
#> 2625   Allison female white    0 WhiteFemale
#> 2626      Anne female white    0 WhiteFemale
#> 2627     Ebony female black    1 BlackFemale
#> 2628   Tanisha female black    1 BlackFemale
#> 2629  Geoffrey   male white    0   WhiteMale
#> 2630   Rasheed   male black    0   BlackMale
#> 2631   Allison female white    0 WhiteFemale
#> 2632     Emily female white    0 WhiteFemale
#> 2633     Kenya female black    0 BlackFemale
#> 2634    Latoya female black    0 BlackFemale
#> 2635      Anne female white    0 WhiteFemale
#> 2636    Carrie female white    0 WhiteFemale
#> 2637     Kenya female black    0 BlackFemale
#> 2638    Latoya female black    0 BlackFemale
#> 2639     Emily female white    0 WhiteFemale
#> 2640    Keisha female black    0 BlackFemale
#> 2641     Kenya female black    0 BlackFemale
#> 2642     Sarah female white    0 WhiteFemale
#> 2643     Aisha female black    0 BlackFemale
#> 2644      Greg   male white    0   WhiteMale
#> 2645       Jay   male white    0   WhiteMale
#> 2646  Jermaine   male black    0   BlackMale
#> 2647  Jermaine   male black    0   BlackMale
#> 2648    Kareem   male black    0   BlackMale
#> 2649    Kareem   male black    0   BlackMale
#> 2650   Kristen female white    0 WhiteFemale
#> 2651   Kristen female white    0 WhiteFemale
#> 2652   Latonya female black    0 BlackFemale
#> 2653    Latoya female black    0 BlackFemale
#> 2654   Matthew   male white    0   WhiteMale
#> 2655  Meredith female white    0 WhiteFemale
#> 2656  Meredith female white    0 WhiteFemale
#> 2657      Todd   male white    0   WhiteMale
#> 2658  Tremayne   male black    0   BlackMale
#> 2659     Ebony female black    0 BlackFemale
#> 2660      Jill female white    0 WhiteFemale
#> 2661     Kenya female black    0 BlackFemale
#> 2662    Laurie female white    0 WhiteFemale
#> 2663      Anne female white    0 WhiteFemale
#> 2664   Lakisha female black    0 BlackFemale
#> 2665   Latonya female black    1 BlackFemale
#> 2666     Sarah female white    0 WhiteFemale
#> 2667     Ebony female black    0 BlackFemale
#> 2668      Jill female white    0 WhiteFemale
#> 2669   Latonya female black    0 BlackFemale
#> 2670    Laurie female white    1 WhiteFemale
#> 2671      Anne female white    0 WhiteFemale
#> 2672   Lakisha female black    0 BlackFemale
#> 2673     Sarah female white    0 WhiteFemale
#> 2674   Tanisha female black    0 BlackFemale
#> 2675   Allison female white    0 WhiteFemale
#> 2676     Kenya female black    0 BlackFemale
#> 2677   Kristen female white    0 WhiteFemale
#> 2678   Lakisha female black    0 BlackFemale
#> 2679      Anne female white    0 WhiteFemale
#> 2680     Ebony female black    0 BlackFemale
#> 2681     Kenya female black    0 BlackFemale
#> 2682   Kristen female white    1 WhiteFemale
#> 2683     Aisha female black    0 BlackFemale
#> 2684      Anne female white    0 WhiteFemale
#> 2685   Latonya female black    0 BlackFemale
#> 2686    Laurie female white    0 WhiteFemale
#> 2687    Carrie female white    0 WhiteFemale
#> 2688      Jill female white    0 WhiteFemale
#> 2689    Keisha female black    0 BlackFemale
#> 2690    Tamika female black    0 BlackFemale
#> 2691     Aisha female black    0 BlackFemale
#> 2692   Allison female white    0 WhiteFemale
#> 2693    Carrie female white    1 WhiteFemale
#> 2694    Tamika female black    1 BlackFemale
#> 2695      Anne female white    1 WhiteFemale
#> 2696     Jamal   male black    1   BlackMale
#> 2697       Jay   male white    1   WhiteMale
#> 2698    Tyrone   male black    1   BlackMale
#> 2699   Brendan   male white    0   WhiteMale
#> 2700     Jamal   male black    0   BlackMale
#> 2701      Anne female white    0 WhiteFemale
#> 2702     Ebony female black    0 BlackFemale
#> 2703   Kristen female white    0 WhiteFemale
#> 2704   Tanisha female black    0 BlackFemale
#> 2705   Lakisha female black    0 BlackFemale
#> 2706   Latonya female black    0 BlackFemale
#> 2707    Laurie female white    0 WhiteFemale
#> 2708  Meredith female white    0 WhiteFemale
#> 2709     Aisha female black    0 BlackFemale
#> 2710   Allison female white    0 WhiteFemale
#> 2711   Allison female white    0 WhiteFemale
#> 2712     Brett   male white    0   WhiteMale
#> 2713    Carrie female white    0 WhiteFemale
#> 2714   Darnell   male black    0   BlackMale
#> 2715     Ebony female black    0 BlackFemale
#> 2716     Ebony female black    0 BlackFemale
#> 2717     Ebony female black    0 BlackFemale
#> 2718      Greg   male white    0   WhiteMale
#> 2719       Jay   male white    0   WhiteMale
#> 2720      Jill female white    0 WhiteFemale
#> 2721    Kareem   male black    0   BlackMale
#> 2722    Keisha female black    0 BlackFemale
#> 2723   Kristen female white    0 WhiteFemale
#> 2724   Lakisha female black    0 BlackFemale
#> 2725   Latonya female black    0 BlackFemale
#> 2726   Latonya female black    0 BlackFemale
#> 2727    Laurie female white    0 WhiteFemale
#> 2728  Meredith female white    0 WhiteFemale
#> 2729     Sarah female white    0 WhiteFemale
#> 2730    Tamika female black    0 BlackFemale
#> 2731      Todd   male white    0   WhiteMale
#> 2732  Tremayne   male black    0   BlackMale
#> 2733    Laurie female white    1 WhiteFemale
#> 2734  Meredith female white    0 WhiteFemale
#> 2735    Tamika female black    0 BlackFemale
#> 2736   Tanisha female black    0 BlackFemale
#> 2737      Anne female white    0 WhiteFemale
#> 2738      Jill female white    1 WhiteFemale
#> 2739   Latonya female black    1 BlackFemale
#> 2740   Tanisha female black    0 BlackFemale
#> 2741    Carrie female white    0 WhiteFemale
#> 2742   Kristen female white    0 WhiteFemale
#> 2743   Lakisha female black    0 BlackFemale
#> 2744   Tanisha female black    0 BlackFemale
#> 2745      Anne female white    1 WhiteFemale
#> 2746     Ebony female black    0 BlackFemale
#> 2747     Kenya female black    1 BlackFemale
#> 2748     Sarah female white    0 WhiteFemale
#> 2749      Anne female white    1 WhiteFemale
#> 2750     Ebony female black    0 BlackFemale
#> 2751   Latonya female black    1 BlackFemale
#> 2752     Sarah female white    0 WhiteFemale
#> 2753   Allison female white    0 WhiteFemale
#> 2754    Keisha female black    0 BlackFemale
#> 2755    Laurie female white    0 WhiteFemale
#> 2756    Tamika female black    0 BlackFemale
#> 2757  Meredith female white    0 WhiteFemale
#> 2758    Tamika female black    0 BlackFemale
#> 2759   Allison female white    0 WhiteFemale
#> 2760     Brett   male white    0   WhiteMale
#> 2761   Lakisha female black    1 BlackFemale
#> 2762    Tyrone   male black    0   BlackMale
#> 2763      Anne female white    0 WhiteFemale
#> 2764    Latoya female black    0 BlackFemale
#> 2765  Meredith female white    0 WhiteFemale
#> 2766    Tamika female black    0 BlackFemale
#> 2767    Carrie female white    0 WhiteFemale
#> 2768     Ebony female black    0 BlackFemale
#> 2769       Jay   male white    0   WhiteMale
#> 2770    Latoya female black    0 BlackFemale
#> 2771     Sarah female white    0 WhiteFemale
#> 2772    Tamika female black    0 BlackFemale
#> 2773     Aisha female black    0 BlackFemale
#> 2774      Anne female white    0 WhiteFemale
#> 2775      Jill female white    0 WhiteFemale
#> 2776   Tanisha female black    0 BlackFemale
#> 2777   Kristen female white    0 WhiteFemale
#> 2778     Sarah female white    0 WhiteFemale
#> 2779    Tamika female black    0 BlackFemale
#> 2780   Tanisha female black    0 BlackFemale
#> 2781      Anne female white    0 WhiteFemale
#> 2782   Tanisha female black    0 BlackFemale
#> 2783   Kristen female white    0 WhiteFemale
#> 2784  Tremayne   male black    0   BlackMale
#> 2785     Brett   male white    0   WhiteMale
#> 2786     Ebony female black    0 BlackFemale
#> 2787     Emily female white    0 WhiteFemale
#> 2788  Geoffrey   male white    0   WhiteMale
#> 2789     Jamal   male black    0   BlackMale
#> 2790      Jill female white    0 WhiteFemale
#> 2791   Lakisha female black    0 BlackFemale
#> 2792    Tyrone   male black    0   BlackMale
#> 2793   Allison female white    0 WhiteFemale
#> 2794   Lakisha female black    0 BlackFemale
#> 2795    Latoya female black    0 BlackFemale
#> 2796  Meredith female white    0 WhiteFemale
#> 2797   Allison female white    0 WhiteFemale
#> 2798      Brad   male white    0   WhiteMale
#> 2799   Darnell   male black    0   BlackMale
#> 2800     Kenya female black    0 BlackFemale
#> 2801   Latonya female black    0 BlackFemale
#> 2802  Meredith female white    0 WhiteFemale
#> 2803    Laurie female white    0 WhiteFemale
#> 2804    Tamika female black    0 BlackFemale
#> 2805      Brad   male white    0   WhiteMale
#> 2806   Latonya female black    0 BlackFemale
#> 2807    Laurie female white    0 WhiteFemale
#> 2808   Tanisha female black    0 BlackFemale
#> 2809     Aisha female black    0 BlackFemale
#> 2810      Jill female white    0 WhiteFemale
#> 2811   Latonya female black    0 BlackFemale
#> 2812    Laurie female white    0 WhiteFemale
#> 2813      Anne female white    0 WhiteFemale
#> 2814      Jill female white    0 WhiteFemale
#> 2815     Kenya female black    0 BlackFemale
#> 2816   Lakisha female black    0 BlackFemale
#> 2817       Jay   male white    0   WhiteMale
#> 2818      Jill female white    0 WhiteFemale
#> 2819    Kareem   male black    0   BlackMale
#> 2820    Latoya female black    0 BlackFemale
#> 2821     Leroy   male black    0   BlackMale
#> 2822     Sarah female white    0 WhiteFemale
#> 2823     Aisha female black    0 BlackFemale
#> 2824    Laurie female white    0 WhiteFemale
#> 2825     Sarah female white    0 WhiteFemale
#> 2826    Tamika female black    0 BlackFemale
#> 2827      Jill female white    0 WhiteFemale
#> 2828    Keisha female black    0 BlackFemale
#> 2829     Kenya female black    0 BlackFemale
#> 2830   Kristen female white    0 WhiteFemale
#> 2831      Anne female white    0 WhiteFemale
#> 2832      Anne female white    0 WhiteFemale
#> 2833   Darnell   male black    0   BlackMale
#> 2834     Emily female white    0 WhiteFemale
#> 2835    Keisha female black    0 BlackFemale
#> 2836   Tanisha female black    0 BlackFemale
#> 2837     Emily female white    0 WhiteFemale
#> 2838     Kenya female black    0 BlackFemale
#> 2839   Kristen female white    0 WhiteFemale
#> 2840   Latonya female black    0 BlackFemale
#> 2841   Kristen female white    0 WhiteFemale
#> 2842    Latoya female black    0 BlackFemale
#> 2843    Tamika female black    0 BlackFemale
#> 2844      Todd   male white    0   WhiteMale
#> 2845      Jill female white    1 WhiteFemale
#> 2846   Kristen female white    1 WhiteFemale
#> 2847    Latoya female black    1 BlackFemale
#> 2848    Tamika female black    0 BlackFemale
#> 2849   Kristen female white    1 WhiteFemale
#> 2850    Tamika female black    0 BlackFemale
#> 2851     Aisha female black    0 BlackFemale
#> 2852     Ebony female black    0 BlackFemale
#> 2853     Emily female white    0 WhiteFemale
#> 2854      Jill female white    0 WhiteFemale
#> 2855    Latoya female black    0 BlackFemale
#> 2856    Laurie female white    0 WhiteFemale
#> 2857   Darnell   male black    0   BlackMale
#> 2858       Jay   male white    0   WhiteMale
#> 2859   Lakisha female black    0 BlackFemale
#> 2860    Latoya female black    0 BlackFemale
#> 2861   Matthew   male white    0   WhiteMale
#> 2862  Meredith female white    0 WhiteFemale
#> 2863     Sarah female white    0 WhiteFemale
#> 2864    Tamika female black    0 BlackFemale
#> 2865   Allison female white    0 WhiteFemale
#> 2866     Ebony female black    0 BlackFemale
#> 2867      Jill female white    0 WhiteFemale
#> 2868    Keisha female black    0 BlackFemale
#> 2869     Jamal   male black    0   BlackMale
#> 2870  Meredith female white    0 WhiteFemale
#> 2871     Sarah female white    0 WhiteFemale
#> 2872   Tanisha female black    0 BlackFemale
#> 2873    Carrie female white    0 WhiteFemale
#> 2874    Latoya female black    0 BlackFemale
#> 2875   Allison female white    0 WhiteFemale
#> 2876     Hakim   male black    0   BlackMale
#> 2877      Jill female white    0 WhiteFemale
#> 2878    Keisha female black    0 BlackFemale
#> 2879   Kristen female white    0 WhiteFemale
#> 2880   Tanisha female black    0 BlackFemale
#> 2881      Anne female white    0 WhiteFemale
#> 2882    Keisha female black    0 BlackFemale
#> 2883     Kenya female black    1 BlackFemale
#> 2884   Kristen female white    1 WhiteFemale
#> 2885   Latonya female black    0 BlackFemale
#> 2886     Sarah female white    0 WhiteFemale
#> 2887     Aisha female black    0 BlackFemale
#> 2888     Emily female white    0 WhiteFemale
#> 2889       Jay   male white    0   WhiteMale
#> 2890   Kristen female white    0 WhiteFemale
#> 2891    Latoya female black    0 BlackFemale
#> 2892   Tanisha female black    0 BlackFemale
#> 2893      Anne female white    0 WhiteFemale
#> 2894    Carrie female white    1 WhiteFemale
#> 2895   Darnell   male black    0   BlackMale
#> 2896    Latoya female black    1 BlackFemale
#> 2897    Laurie female white    1 WhiteFemale
#> 2898   Tanisha female black    0 BlackFemale
#> 2899      Anne female white    0 WhiteFemale
#> 2900   Darnell   male black    0   BlackMale
#> 2901       Jay   male white    0   WhiteMale
#> 2902   Tanisha female black    0 BlackFemale
#> 2903    Carrie female white    0 WhiteFemale
#> 2904     Emily female white    1 WhiteFemale
#> 2905     Sarah female white    0 WhiteFemale
#> 2906    Tamika female black    1 BlackFemale
#> 2907   Tanisha female black    0 BlackFemale
#> 2908  Tremayne   male black    0   BlackMale
#> 2909      Anne female white    0 WhiteFemale
#> 2910      Jill female white    0 WhiteFemale
#> 2911     Kenya female black    0 BlackFemale
#> 2912   Lakisha female black    0 BlackFemale
#> 2913   Matthew   male white    0   WhiteMale
#> 2914    Tamika female black    0 BlackFemale
#> 2915   Matthew   male white    0   WhiteMale
#> 2916   Tanisha female black    0 BlackFemale
#> 2917      Anne female white    0 WhiteFemale
#> 2918    Latoya female black    0 BlackFemale
#> 2919  Meredith female white    0 WhiteFemale
#> 2920    Tamika female black    0 BlackFemale
#> 2921     Aisha female black    0 BlackFemale
#> 2922     Emily female white    0 WhiteFemale
#> 2923      Greg   male white    0   WhiteMale
#> 2924     Hakim   male black    0   BlackMale
#> 2925      Jill female white    0 WhiteFemale
#> 2926    Keisha female black    0 BlackFemale
#> 2927     Kenya female black    0 BlackFemale
#> 2928    Laurie female white    0 WhiteFemale
#> 2929     Sarah female white    0 WhiteFemale
#> 2930    Tamika female black    0 BlackFemale
#> 2931    Carrie female white    0 WhiteFemale
#> 2932     Ebony female black    0 BlackFemale
#> 2933     Jamal   male black    0   BlackMale
#> 2934      Jill female white    0 WhiteFemale
#> 2935     Kenya female black    0 BlackFemale
#> 2936    Latoya female black    0 BlackFemale
#> 2937  Meredith female white    0 WhiteFemale
#> 2938      Todd   male white    0   WhiteMale
#> 2939     Aisha female black    0 BlackFemale
#> 2940   Allison female white    0 WhiteFemale
#> 2941      Brad   male white    0   WhiteMale
#> 2942  Geoffrey   male white    0   WhiteMale
#> 2943     Hakim   male black    0   BlackMale
#> 2944    Latoya female black    0 BlackFemale
#> 2945     Sarah female white    0 WhiteFemale
#> 2946   Tanisha female black    0 BlackFemale
#> 2947   Allison female white    0 WhiteFemale
#> 2948   Allison female white    0 WhiteFemale
#> 2949      Anne female white    0 WhiteFemale
#> 2950      Brad   male white    1   WhiteMale
#> 2951   Brendan   male white    1   WhiteMale
#> 2952   Brendan   male white    0   WhiteMale
#> 2953     Brett   male white    0   WhiteMale
#> 2954     Brett   male white    0   WhiteMale
#> 2955   Darnell   male black    0   BlackMale
#> 2956     Ebony female black    0 BlackFemale
#> 2957     Emily female white    0 WhiteFemale
#> 2958      Greg   male white    0   WhiteMale
#> 2959     Hakim   male black    0   BlackMale
#> 2960      Jill female white    0 WhiteFemale
#> 2961   Kristen female white    0 WhiteFemale
#> 2962   Latonya female black    0 BlackFemale
#> 2963   Latonya female black    0 BlackFemale
#> 2964   Latonya female black    0 BlackFemale
#> 2965    Latoya female black    0 BlackFemale
#> 2966    Laurie female white    0 WhiteFemale
#> 2967  Meredith female white    0 WhiteFemale
#> 2968      Neil   male white    0   WhiteMale
#> 2969   Rasheed   male black    0   BlackMale
#> 2970   Rasheed   male black    0   BlackMale
#> 2971     Sarah female white    0 WhiteFemale
#> 2972    Tamika female black    1 BlackFemale
#> 2973    Tamika female black    0 BlackFemale
#> 2974    Tamika female black    0 BlackFemale
#> 2975    Tamika female black    0 BlackFemale
#> 2976    Tamika female black    0 BlackFemale
#> 2977    Tamika female black    0 BlackFemale
#> 2978      Todd   male white    0   WhiteMale
#> 2979      Todd   male white    0   WhiteMale
#> 2980  Tremayne   male black    0   BlackMale
#> 2981    Tyrone   male black    0   BlackMale
#> 2982    Tyrone   male black    0   BlackMale
#> 2983     Ebony female black    0 BlackFemale
#> 2984   Kristen female white    0 WhiteFemale
#> 2985    Latoya female black    0 BlackFemale
#> 2986     Sarah female white    0 WhiteFemale
#> 2987      Anne female white    0 WhiteFemale
#> 2988     Emily female white    0 WhiteFemale
#> 2989     Kenya female black    0 BlackFemale
#> 2990    Latoya female black    0 BlackFemale
#> 2991   Allison female white    0 WhiteFemale
#> 2992     Ebony female black    0 BlackFemale
#> 2993    Keisha female black    0 BlackFemale
#> 2994   Kristen female white    0 WhiteFemale
#> 2995      Brad   male white    0   WhiteMale
#> 2996   Brendan   male white    0   WhiteMale
#> 2997     Brett   male white    0   WhiteMale
#> 2998    Carrie female white    0 WhiteFemale
#> 2999   Darnell   male black    0   BlackMale
#> 3000     Ebony female black    0 BlackFemale
#> 3001      Greg   male white    0   WhiteMale
#> 3002      Greg   male white    0   WhiteMale
#> 3003     Jamal   male black    0   BlackMale
#> 3004    Kareem   male black    0   BlackMale
#> 3005    Keisha female black    0 BlackFemale
#> 3006   Lakisha female black    0 BlackFemale
#> 3007    Latoya female black    0 BlackFemale
#> 3008    Latoya female black    0 BlackFemale
#> 3009    Latoya female black    1 BlackFemale
#> 3010    Laurie female white    0 WhiteFemale
#> 3011      Neil   male white    0   WhiteMale
#> 3012      Neil   male white    0   WhiteMale
#> 3013      Neil   male white    0   WhiteMale
#> 3014   Rasheed   male black    0   BlackMale
#> 3015     Sarah female white    0 WhiteFemale
#> 3016     Sarah female white    0 WhiteFemale
#> 3017   Tanisha female black    0 BlackFemale
#> 3018  Tremayne   male black    0   BlackMale
#> 3019    Carrie female white    0 WhiteFemale
#> 3020     Emily female white    1 WhiteFemale
#> 3021   Latonya female black    1 BlackFemale
#> 3022   Tanisha female black    0 BlackFemale
#> 3023   Allison female white    0 WhiteFemale
#> 3024     Kenya female black    0 BlackFemale
#> 3025   Kristen female white    0 WhiteFemale
#> 3026   Latonya female black    0 BlackFemale
#> 3027   Allison female white    0 WhiteFemale
#> 3028    Carrie female white    0 WhiteFemale
#> 3029    Keisha female black    0 BlackFemale
#> 3030   Tanisha female black    0 BlackFemale
#> 3031      Anne female white    0 WhiteFemale
#> 3032    Carrie female white    0 WhiteFemale
#> 3033   Lakisha female black    0 BlackFemale
#> 3034   Tanisha female black    0 BlackFemale
#> 3035      Anne female white    0 WhiteFemale
#> 3036     Ebony female black    0 BlackFemale
#> 3037     Kenya female black    0 BlackFemale
#> 3038  Meredith female white    0 WhiteFemale
#> 3039     Emily female white    0 WhiteFemale
#> 3040  Geoffrey   male white    0   WhiteMale
#> 3041   Rasheed   male black    0   BlackMale
#> 3042  Tremayne   male black    0   BlackMale
#> 3043     Ebony female black    1 BlackFemale
#> 3044      Jill female white    0 WhiteFemale
#> 3045   Kristen female white    0 WhiteFemale
#> 3046   Latonya female black    0 BlackFemale
#> 3047      Anne female white    0 WhiteFemale
#> 3048    Keisha female black    0 BlackFemale
#> 3049     Sarah female white    0 WhiteFemale
#> 3050   Tanisha female black    0 BlackFemale
#> 3051     Aisha female black    0 BlackFemale
#> 3052      Brad   male white    0   WhiteMale
#> 3053     Brett   male white    0   WhiteMale
#> 3054    Carrie female white    0 WhiteFemale
#> 3055    Carrie female white    0 WhiteFemale
#> 3056     Ebony female black    0 BlackFemale
#> 3057  Geoffrey   male white    0   WhiteMale
#> 3058    Kareem   male black    0   BlackMale
#> 3059    Kareem   male black    0   BlackMale
#> 3060    Keisha female black    0 BlackFemale
#> 3061      Neil   male white    0   WhiteMale
#> 3062  Tremayne   male black    0   BlackMale
#> 3063      Jill female white    0 WhiteFemale
#> 3064     Kenya female black    0 BlackFemale
#> 3065   Latonya female black    0 BlackFemale
#> 3066    Laurie female white    0 WhiteFemale
#> 3067    Carrie female white    0 WhiteFemale
#> 3068      Jill female white    0 WhiteFemale
#> 3069    Keisha female black    0 BlackFemale
#> 3070     Kenya female black    0 BlackFemale
#> 3071   Allison female white    0 WhiteFemale
#> 3072     Emily female white    0 WhiteFemale
#> 3073    Latoya female black    0 BlackFemale
#> 3074   Tanisha female black    0 BlackFemale
#> 3075      Anne female white    0 WhiteFemale
#> 3076    Carrie female white    0 WhiteFemale
#> 3077   Lakisha female black    0 BlackFemale
#> 3078   Latonya female black    0 BlackFemale
#> 3079   Allison female white    0 WhiteFemale
#> 3080     Ebony female black    0 BlackFemale
#> 3081  Meredith female white    0 WhiteFemale
#> 3082    Tamika female black    0 BlackFemale
#> 3083      Jill female white    0 WhiteFemale
#> 3084   Kristen female white    0 WhiteFemale
#> 3085    Latoya female black    0 BlackFemale
#> 3086    Tamika female black    0 BlackFemale
#> 3087     Aisha female black    0 BlackFemale
#> 3088   Lakisha female black    0 BlackFemale
#> 3089    Laurie female white    0 WhiteFemale
#> 3090  Meredith female white    0 WhiteFemale
#> 3091     Emily female white    0 WhiteFemale
#> 3092   Lakisha female black    0 BlackFemale
#> 3093     Sarah female white    0 WhiteFemale
#> 3094   Tanisha female black    0 BlackFemale
#> 3095     Emily female white    0 WhiteFemale
#> 3096     Hakim   male black    1   BlackMale
#> 3097    Laurie female white    0 WhiteFemale
#> 3098    Tyrone   male black    0   BlackMale
#> 3099      Anne female white    0 WhiteFemale
#> 3100     Emily female white    0 WhiteFemale
#> 3101    Tamika female black    0 BlackFemale
#> 3102    Tamika female black    0 BlackFemale
#> 3103     Aisha female black    0 BlackFemale
#> 3104   Allison female white    0 WhiteFemale
#> 3105    Carrie female white    0 WhiteFemale
#> 3106     Emily female white    0 WhiteFemale
#> 3107     Emily female white    0 WhiteFemale
#> 3108  Geoffrey   male white    0   WhiteMale
#> 3109      Greg   male white    0   WhiteMale
#> 3110     Hakim   male black    0   BlackMale
#> 3111     Hakim   male black    0   BlackMale
#> 3112       Jay   male white    0   WhiteMale
#> 3113    Keisha female black    0 BlackFemale
#> 3114   Lakisha female black    0 BlackFemale
#> 3115    Latoya female black    0 BlackFemale
#> 3116    Laurie female white    0 WhiteFemale
#> 3117   Matthew   male white    0   WhiteMale
#> 3118   Rasheed   male black    0   BlackMale
#> 3119   Tanisha female black    0 BlackFemale
#> 3120      Todd   male white    0   WhiteMale
#> 3121  Tremayne   male black    0   BlackMale
#> 3122    Tyrone   male black    0   BlackMale
#> 3123   Kristen female white    0 WhiteFemale
#> 3124   Lakisha female black    0 BlackFemale
#> 3125   Matthew   male white    0   WhiteMale
#> 3126  Tremayne   male black    0   BlackMale
#> 3127   Allison female white    0 WhiteFemale
#> 3128    Carrie female white    0 WhiteFemale
#> 3129     Kenya female black    0 BlackFemale
#> 3130    Latoya female black    0 BlackFemale
#> 3131      Brad   male white    0   WhiteMale
#> 3132   Brendan   male white    0   WhiteMale
#> 3133     Brett   male white    0   WhiteMale
#> 3134    Carrie female white    0 WhiteFemale
#> 3135   Darnell   male black    0   BlackMale
#> 3136  Geoffrey   male white    0   WhiteMale
#> 3137      Greg   male white    0   WhiteMale
#> 3138     Jamal   male black    0   BlackMale
#> 3139  Jermaine   male black    0   BlackMale
#> 3140    Kareem   male black    0   BlackMale
#> 3141    Keisha female black    0 BlackFemale
#> 3142   Kristen female white    0 WhiteFemale
#> 3143   Kristen female white    0 WhiteFemale
#> 3144   Latonya female black    0 BlackFemale
#> 3145   Latonya female black    0 BlackFemale
#> 3146    Latoya female black    0 BlackFemale
#> 3147    Laurie female white    0 WhiteFemale
#> 3148     Leroy   male black    0   BlackMale
#> 3149      Neil   male white    0   WhiteMale
#> 3150      Neil   male white    0   WhiteMale
#> 3151     Sarah female white    0 WhiteFemale
#> 3152    Tamika female black    0 BlackFemale
#> 3153  Tremayne   male black    0   BlackMale
#> 3154    Tyrone   male black    0   BlackMale
#> 3155     Aisha female black    0 BlackFemale
#> 3156   Allison female white    0 WhiteFemale
#> 3157      Jill female white    1 WhiteFemale
#> 3158    Tamika female black    0 BlackFemale
#> 3159     Aisha female black    0 BlackFemale
#> 3160   Allison female white    0 WhiteFemale
#> 3161     Ebony female black    0 BlackFemale
#> 3162     Ebony female black    0 BlackFemale
#> 3163     Emily female white    0 WhiteFemale
#> 3164      Greg   male white    0   WhiteMale
#> 3165     Hakim   male black    0   BlackMale
#> 3166      Jill female white    0 WhiteFemale
#> 3167    Kareem   male black    0   BlackMale
#> 3168    Keisha female black    0 BlackFemale
#> 3169   Lakisha female black    1 BlackFemale
#> 3170    Laurie female white    0 WhiteFemale
#> 3171    Laurie female white    0 WhiteFemale
#> 3172   Matthew   male white    1   WhiteMale
#> 3173  Meredith female white    1 WhiteFemale
#> 3174      Neil   male white    0   WhiteMale
#> 3175   Rasheed   male black    0   BlackMale
#> 3176     Sarah female white    0 WhiteFemale
#> 3177   Tanisha female black    0 BlackFemale
#> 3178    Tyrone   male black    0   BlackMale
#> 3179     Ebony female black    1 BlackFemale
#> 3180      Jill female white    0 WhiteFemale
#> 3181   Matthew   male white    0   WhiteMale
#> 3182  Tremayne   male black    0   BlackMale
#> 3183    Carrie female white    0 WhiteFemale
#> 3184     Ebony female black    0 BlackFemale
#> 3185      Jill female white    0 WhiteFemale
#> 3186    Tamika female black    0 BlackFemale
#> 3187      Brad   male white    0   WhiteMale
#> 3188      Brad   male white    0   WhiteMale
#> 3189  Geoffrey   male white    0   WhiteMale
#> 3190    Kareem   male black    0   BlackMale
#> 3191    Keisha female black    0 BlackFemale
#> 3192    Keisha female black    0 BlackFemale
#> 3193     Kenya female black    0 BlackFemale
#> 3194   Kristen female white    0 WhiteFemale
#> 3195   Lakisha female black    0 BlackFemale
#> 3196   Lakisha female black    0 BlackFemale
#> 3197    Laurie female white    0 WhiteFemale
#> 3198     Leroy   male black    1   BlackMale
#> 3199  Meredith female white    0 WhiteFemale
#> 3200      Neil   male white    0   WhiteMale
#> 3201      Neil   male white    0   WhiteMale
#> 3202   Rasheed   male black    0   BlackMale
#> 3203   Rasheed   male black    0   BlackMale
#> 3204   Rasheed   male black    0   BlackMale
#> 3205     Sarah female white    0 WhiteFemale
#> 3206      Todd   male white    0   WhiteMale
#> 3207     Aisha female black    0 BlackFemale
#> 3208   Allison female white    0 WhiteFemale
#> 3209      Anne female white    0 WhiteFemale
#> 3210      Brad   male white    0   WhiteMale
#> 3211    Carrie female white    0 WhiteFemale
#> 3212    Kareem   male black    0   BlackMale
#> 3213    Keisha female black    0 BlackFemale
#> 3214     Kenya female black    0 BlackFemale
#> 3215   Kristen female white    0 WhiteFemale
#> 3216   Lakisha female black    0 BlackFemale
#> 3217    Latoya female black    0 BlackFemale
#> 3218   Matthew   male white    0   WhiteMale
#> 3219  Meredith female white    0 WhiteFemale
#> 3220      Neil   male white    0   WhiteMale
#> 3221  Tremayne   male black    0   BlackMale
#> 3222    Tyrone   male black    0   BlackMale
#> 3223   Brendan   male white    0   WhiteMale
#> 3224    Carrie female white    0 WhiteFemale
#> 3225  Geoffrey   male white    0   WhiteMale
#> 3226     Jamal   male black    0   BlackMale
#> 3227      Jill female white    0 WhiteFemale
#> 3228    Kareem   male black    0   BlackMale
#> 3229   Kristen female white    0 WhiteFemale
#> 3230    Latoya female black    0 BlackFemale
#> 3231    Latoya female black    0 BlackFemale
#> 3232     Leroy   male black    0   BlackMale
#> 3233   Matthew   male white    0   WhiteMale
#> 3234   Tanisha female black    0 BlackFemale
#> 3235   Brendan   male white    0   WhiteMale
#> 3236      Greg   male white    0   WhiteMale
#> 3237    Kareem   male black    0   BlackMale
#> 3238     Kenya female black    0 BlackFemale
#> 3239   Latonya female black    0 BlackFemale
#> 3240    Laurie female white    0 WhiteFemale
#> 3241  Meredith female white    0 WhiteFemale
#> 3242  Tremayne   male black    0   BlackMale
#> 3243     Emily female white    0 WhiteFemale
#> 3244     Hakim   male black    0   BlackMale
#> 3245    Latoya female black    0 BlackFemale
#> 3246      Todd   male white    0   WhiteMale
#> 3247     Aisha female black    0 BlackFemale
#> 3248     Ebony female black    1 BlackFemale
#> 3249  Geoffrey   male white    1   WhiteMale
#> 3250     Jamal   male black    0   BlackMale
#> 3251  Jermaine   male black    0   BlackMale
#> 3252   Lakisha female black    0 BlackFemale
#> 3253  Meredith female white    0 WhiteFemale
#> 3254  Meredith female white    0 WhiteFemale
#> 3255      Neil   male white    0   WhiteMale
#> 3256     Sarah female white    0 WhiteFemale
#> 3257     Sarah female white    1 WhiteFemale
#> 3258    Tyrone   male black    1   BlackMale
#> 3259  Jermaine   male black    0   BlackMale
#> 3260      Jill female white    0 WhiteFemale
#> 3261   Kristen female white    1 WhiteFemale
#> 3262     Leroy   male black    0   BlackMale
#> 3263   Allison female white    0 WhiteFemale
#> 3264   Latonya female black    0 BlackFemale
#> 3265     Aisha female black    0 BlackFemale
#> 3266   Allison female white    0 WhiteFemale
#> 3267     Brett   male white    0   WhiteMale
#> 3268    Carrie female white    0 WhiteFemale
#> 3269     Kenya female black    0 BlackFemale
#> 3270    Latoya female black    0 BlackFemale
#> 3271     Aisha female black    0 BlackFemale
#> 3272      Anne female white    0 WhiteFemale
#> 3273      Jill female white    0 WhiteFemale
#> 3274   Tanisha female black    0 BlackFemale
#> 3275      Brad   male white    1   WhiteMale
#> 3276     Emily female white    1 WhiteFemale
#> 3277  Jermaine   male black    1   BlackMale
#> 3278   Lakisha female black    1 BlackFemale
#> 3279   Allison female white    0 WhiteFemale
#> 3280     Leroy   male black    1   BlackMale
#> 3281   Allison female white    0 WhiteFemale
#> 3282    Carrie female white    0 WhiteFemale
#> 3283       Jay   male white    0   WhiteMale
#> 3284    Keisha female black    0 BlackFemale
#> 3285   Lakisha female black    0 BlackFemale
#> 3286   Latonya female black    0 BlackFemale
#> 3287  Meredith female white    0 WhiteFemale
#> 3288    Tyrone   male black    0   BlackMale
#> 3289      Anne female white    0 WhiteFemale
#> 3290    Keisha female black    0 BlackFemale
#> 3291  Meredith female white    0 WhiteFemale
#> 3292   Tanisha female black    0 BlackFemale
#> 3293      Anne female white    0 WhiteFemale
#> 3294   Darnell   male black    0   BlackMale
#> 3295     Ebony female black    0 BlackFemale
#> 3296     Emily female white    0 WhiteFemale
#> 3297     Sarah female white    0 WhiteFemale
#> 3298   Tanisha female black    0 BlackFemale
#> 3299   Allison female white    0 WhiteFemale
#> 3300     Emily female white    1 WhiteFemale
#> 3301   Latonya female black    1 BlackFemale
#> 3302    Latoya female black    0 BlackFemale
#> 3303   Allison female white    0 WhiteFemale
#> 3304      Anne female white    0 WhiteFemale
#> 3305     Jamal   male black    0   BlackMale
#> 3306  Jermaine   male black    0   BlackMale
#> 3307     Emily female white    0 WhiteFemale
#> 3308   Lakisha female black    0 BlackFemale
#> 3309    Latoya female black    0 BlackFemale
#> 3310  Meredith female white    0 WhiteFemale
#> 3311   Allison female white    1 WhiteFemale
#> 3312     Brett   male white    0   WhiteMale
#> 3313     Kenya female black    0 BlackFemale
#> 3314    Latoya female black    0 BlackFemale
#> 3315     Leroy   male black    0   BlackMale
#> 3316      Todd   male white    0   WhiteMale
#> 3317      Anne female white    0 WhiteFemale
#> 3318      Anne female white    0 WhiteFemale
#> 3319     Ebony female black    0 BlackFemale
#> 3320   Tanisha female black    0 BlackFemale
#> 3321     Aisha female black    0 BlackFemale
#> 3322   Brendan   male white    0   WhiteMale
#> 3323     Brett   male white    0   WhiteMale
#> 3324    Carrie female white    0 WhiteFemale
#> 3325   Darnell   male black    0   BlackMale
#> 3326     Ebony female black    0 BlackFemale
#> 3327     Ebony female black    0 BlackFemale
#> 3328   Kristen female white    0 WhiteFemale
#> 3329     Aisha female black    0 BlackFemale
#> 3330      Greg   male white    0   WhiteMale
#> 3331      Jill female white    0 WhiteFemale
#> 3332     Kenya female black    0 BlackFemale
#> 3333  Meredith female white    0 WhiteFemale
#> 3334   Tanisha female black    0 BlackFemale
#> 3335     Jamal   male black    0   BlackMale
#> 3336      Neil   male white    0   WhiteMale
#> 3337   Brendan   male white    0   WhiteMale
#> 3338     Jamal   male black    0   BlackMale
#> 3339      Todd   male white    0   WhiteMale
#> 3340    Tyrone   male black    0   BlackMale
#> 3341      Todd   male white    1   WhiteMale
#> 3342    Tyrone   male black    1   BlackMale
#> 3343     Emily female white    0 WhiteFemale
#> 3344     Emily female white    0 WhiteFemale
#> 3345  Jermaine   male black    0   BlackMale
#> 3346     Kenya female black    0 BlackFemale
#> 3347   Lakisha female black    0 BlackFemale
#> 3348     Leroy   male black    0   BlackMale
#> 3349  Meredith female white    1 WhiteFemale
#> 3350     Sarah female white    0 WhiteFemale
#> 3351     Ebony female black    0 BlackFemale
#> 3352     Emily female white    0 WhiteFemale
#> 3353      Jill female white    0 WhiteFemale
#> 3354      Jill female white    0 WhiteFemale
#> 3355    Keisha female black    0 BlackFemale
#> 3356    Keisha female black    0 BlackFemale
#> 3357    Latoya female black    0 BlackFemale
#> 3358  Meredith female white    0 WhiteFemale
#> 3359     Aisha female black    1 BlackFemale
#> 3360   Darnell   male black    1   BlackMale
#> 3361     Ebony female black    0 BlackFemale
#> 3362       Jay   male white    0   WhiteMale
#> 3363      Jill female white    0 WhiteFemale
#> 3364    Keisha female black    0 BlackFemale
#> 3365  Meredith female white    1 WhiteFemale
#> 3366  Meredith female white    0 WhiteFemale
#> 3367     Aisha female black    0 BlackFemale
#> 3368    Carrie female white    0 WhiteFemale
#> 3369  Meredith female white    0 WhiteFemale
#> 3370   Tanisha female black    0 BlackFemale
#> 3371      Brad   male white    1   WhiteMale
#> 3372     Ebony female black    0 BlackFemale
#> 3373     Emily female white    0 WhiteFemale
#> 3374   Kristen female white    0 WhiteFemale
#> 3375   Rasheed   male black    0   BlackMale
#> 3376    Tamika female black    0 BlackFemale
#> 3377      Jill female white    0 WhiteFemale
#> 3378  Tremayne   male black    0   BlackMale
#> 3379     Sarah female white    0 WhiteFemale
#> 3380    Tamika female black    0 BlackFemale
#> 3381   Allison female white    0 WhiteFemale
#> 3382      Anne female white    1 WhiteFemale
#> 3383    Carrie female white    0 WhiteFemale
#> 3384     Ebony female black    1 BlackFemale
#> 3385   Latonya female black    0 BlackFemale
#> 3386     Leroy   male black    1   BlackMale
#> 3387      Anne female white    0 WhiteFemale
#> 3388     Jamal   male black    0   BlackMale
#> 3389    Latoya female black    0 BlackFemale
#> 3390    Laurie female white    0 WhiteFemale
#> 3391     Sarah female white    0 WhiteFemale
#> 3392   Tanisha female black    0 BlackFemale
#> 3393   Allison female white    0 WhiteFemale
#> 3394    Keisha female black    0 BlackFemale
#> 3395   Lakisha female black    0 BlackFemale
#> 3396    Latoya female black    1 BlackFemale
#> 3397    Laurie female white    1 WhiteFemale
#> 3398  Meredith female white    0 WhiteFemale
#> 3399     Aisha female black    0 BlackFemale
#> 3400   Allison female white    0 WhiteFemale
#> 3401     Emily female white    0 WhiteFemale
#> 3402    Latoya female black    0 BlackFemale
#> 3403    Laurie female white    0 WhiteFemale
#> 3404    Tamika female black    0 BlackFemale
#> 3405      Anne female white    0 WhiteFemale
#> 3406     Brett   male white    0   WhiteMale
#> 3407  Jermaine   male black    0   BlackMale
#> 3408   Latonya female black    0 BlackFemale
#> 3409   Allison female white    0 WhiteFemale
#> 3410    Keisha female black    0 BlackFemale
#> 3411    Laurie female white    0 WhiteFemale
#> 3412     Leroy   male black    0   BlackMale
#> 3413   Tanisha female black    0 BlackFemale
#> 3414      Todd   male white    0   WhiteMale
#> 3415    Carrie female white    0 WhiteFemale
#> 3416     Hakim   male black    0   BlackMale
#> 3417     Aisha female black    0 BlackFemale
#> 3418   Allison female white    0 WhiteFemale
#> 3419      Jill female white    0 WhiteFemale
#> 3420   Latonya female black    0 BlackFemale
#> 3421   Darnell   male black    0   BlackMale
#> 3422     Emily female white    0 WhiteFemale
#> 3423   Kristen female white    0 WhiteFemale
#> 3424   Latonya female black    0 BlackFemale
#> 3425    Laurie female white    0 WhiteFemale
#> 3426    Tamika female black    0 BlackFemale
#> 3427     Aisha female black    0 BlackFemale
#> 3428   Allison female white    0 WhiteFemale
#> 3429    Carrie female white    0 WhiteFemale
#> 3430    Tamika female black    0 BlackFemale
#> 3431     Ebony female black    0 BlackFemale
#> 3432  Meredith female white    0 WhiteFemale
#> 3433      Neil   male white    0   WhiteMale
#> 3434  Tremayne   male black    0   BlackMale
#> 3435     Aisha female black    0 BlackFemale
#> 3436   Allison female white    0 WhiteFemale
#> 3437     Ebony female black    0 BlackFemale
#> 3438     Hakim   male black    0   BlackMale
#> 3439       Jay   male white    1   WhiteMale
#> 3440      Jill female white    0 WhiteFemale
#> 3441   Lakisha female black    0 BlackFemale
#> 3442      Neil   male white    0   WhiteMale
#> 3443   Allison female white    0 WhiteFemale
#> 3444   Brendan   male white    0   WhiteMale
#> 3445   Darnell   male black    0   BlackMale
#> 3446     Ebony female black    0 BlackFemale
#> 3447  Geoffrey   male white    0   WhiteMale
#> 3448  Geoffrey   male white    0   WhiteMale
#> 3449  Geoffrey   male white    0   WhiteMale
#> 3450      Greg   male white    0   WhiteMale
#> 3451       Jay   male white    0   WhiteMale
#> 3452  Jermaine   male black    0   BlackMale
#> 3453   Lakisha female black    0 BlackFemale
#> 3454   Latonya female black    0 BlackFemale
#> 3455   Matthew   male white    0   WhiteMale
#> 3456      Neil   male white    0   WhiteMale
#> 3457   Rasheed   male black    0   BlackMale
#> 3458   Rasheed   male black    0   BlackMale
#> 3459   Rasheed   male black    0   BlackMale
#> 3460     Sarah female white    0 WhiteFemale
#> 3461     Sarah female white    0 WhiteFemale
#> 3462     Sarah female white    0 WhiteFemale
#> 3463    Tamika female black    0 BlackFemale
#> 3464   Tanisha female black    0 BlackFemale
#> 3465  Tremayne   male black    0   BlackMale
#> 3466  Tremayne   male black    0   BlackMale
#> 3467   Brendan   male white    0   WhiteMale
#> 3468   Brendan   male white    0   WhiteMale
#> 3469      Greg   male white    0   WhiteMale
#> 3470     Jamal   male black    0   BlackMale
#> 3471  Jermaine   male black    0   BlackMale
#> 3472    Kareem   male black    0   BlackMale
#> 3473    Keisha female black    0 BlackFemale
#> 3474    Laurie female white    0 WhiteFemale
#> 3475    Laurie female white    0 WhiteFemale
#> 3476     Leroy   male black    0   BlackMale
#> 3477     Leroy   male black    0   BlackMale
#> 3478      Neil   male white    0   WhiteMale
#> 3479     Sarah female white    0 WhiteFemale
#> 3480    Tamika female black    0 BlackFemale
#> 3481   Tanisha female black    0 BlackFemale
#> 3482      Todd   male white    0   WhiteMale
#> 3483     Ebony female black    0 BlackFemale
#> 3484      Greg   male white    0   WhiteMale
#> 3485      Greg   male white    1   WhiteMale
#> 3486     Hakim   male black    0   BlackMale
#> 3487     Hakim   male black    0   BlackMale
#> 3488    Kareem   male black    0   BlackMale
#> 3489    Kareem   male black    0   BlackMale
#> 3490     Kenya female black    0 BlackFemale
#> 3491   Kristen female white    0 WhiteFemale
#> 3492   Kristen female white    1 WhiteFemale
#> 3493   Lakisha female black    0 BlackFemale
#> 3494    Latoya female black    0 BlackFemale
#> 3495    Laurie female white    0 WhiteFemale
#> 3496  Meredith female white    0 WhiteFemale
#> 3497      Neil   male white    0   WhiteMale
#> 3498      Neil   male white    0   WhiteMale
#> 3499    Tamika female black    0 BlackFemale
#> 3500      Todd   male white    0   WhiteMale
#> 3501      Todd   male white    0   WhiteMale
#> 3502    Tyrone   male black    0   BlackMale
#> 3503     Jamal   male black    0   BlackMale
#> 3504    Kareem   male black    0   BlackMale
#> 3505    Laurie female white    0 WhiteFemale
#> 3506      Todd   male white    0   WhiteMale
#> 3507     Aisha female black    0 BlackFemale
#> 3508      Anne female white    0 WhiteFemale
#> 3509   Brendan   male white    0   WhiteMale
#> 3510     Brett   male white    0   WhiteMale
#> 3511     Emily female white    0 WhiteFemale
#> 3512      Greg   male white    0   WhiteMale
#> 3513     Jamal   male black    0   BlackMale
#> 3514  Jermaine   male black    0   BlackMale
#> 3515   Latonya female black    0 BlackFemale
#> 3516   Latonya female black    0 BlackFemale
#> 3517     Leroy   male black    0   BlackMale
#> 3518  Meredith female white    0 WhiteFemale
#> 3519   Rasheed   male black    0   BlackMale
#> 3520   Rasheed   male black    0   BlackMale
#> 3521     Sarah female white    0 WhiteFemale
#> 3522      Todd   male white    0   WhiteMale
#> 3523      Brad   male white    0   WhiteMale
#> 3524     Ebony female black    0 BlackFemale
#> 3525      Greg   male white    0   WhiteMale
#> 3526     Hakim   male black    0   BlackMale
#> 3527     Emily female white    0 WhiteFemale
#> 3528     Kenya female black    0 BlackFemale
#> 3529     Sarah female white    0 WhiteFemale
#> 3530    Tamika female black    0 BlackFemale
#> 3531      Brad   male white    0   WhiteMale
#> 3532    Carrie female white    0 WhiteFemale
#> 3533     Ebony female black    0 BlackFemale
#> 3534  Geoffrey   male white    0   WhiteMale
#> 3535  Geoffrey   male white    0   WhiteMale
#> 3536     Jamal   male black    0   BlackMale
#> 3537    Kareem   male black    0   BlackMale
#> 3538   Kristen female white    0 WhiteFemale
#> 3539   Lakisha female black    0 BlackFemale
#> 3540     Leroy   male black    0   BlackMale
#> 3541      Neil   male white    0   WhiteMale
#> 3542    Tamika female black    0 BlackFemale
#> 3543     Aisha female black    0 BlackFemale
#> 3544   Allison female white    0 WhiteFemale
#> 3545      Anne female white    0 WhiteFemale
#> 3546      Anne female white    0 WhiteFemale
#> 3547      Brad   male white    0   WhiteMale
#> 3548   Brendan   male white    0   WhiteMale
#> 3549     Brett   male white    0   WhiteMale
#> 3550  Jermaine   male black    0   BlackMale
#> 3551   Lakisha female black    0 BlackFemale
#> 3552   Latonya female black    0 BlackFemale
#> 3553   Latonya female black    0 BlackFemale
#> 3554    Laurie female white    0 WhiteFemale
#> 3555     Leroy   male black    0   BlackMale
#> 3556  Meredith female white    0 WhiteFemale
#> 3557   Rasheed   male black    0   BlackMale
#> 3558  Tremayne   male black    0   BlackMale
#> 3559   Allison female white    0 WhiteFemale
#> 3560      Anne female white    0 WhiteFemale
#> 3561  Geoffrey   male white    0   WhiteMale
#> 3562     Jamal   male black    0   BlackMale
#> 3563    Kareem   male black    0   BlackMale
#> 3564   Kristen female white    0 WhiteFemale
#> 3565    Tamika female black    0 BlackFemale
#> 3566   Tanisha female black    0 BlackFemale
#> 3567      Anne female white    0 WhiteFemale
#> 3568     Emily female white    0 WhiteFemale
#> 3569     Hakim   male black    0   BlackMale
#> 3570      Jill female white    0 WhiteFemale
#> 3571     Kenya female black    0 BlackFemale
#> 3572   Kristen female white    0 WhiteFemale
#> 3573   Latonya female black    0 BlackFemale
#> 3574   Matthew   male white    0   WhiteMale
#> 3575  Meredith female white    0 WhiteFemale
#> 3576   Rasheed   male black    0   BlackMale
#> 3577  Tremayne   male black    0   BlackMale
#> 3578  Tremayne   male black    0   BlackMale
#> 3579  Jermaine   male black    0   BlackMale
#> 3580    Laurie female white    1 WhiteFemale
#> 3581   Matthew   male white    0   WhiteMale
#> 3582   Rasheed   male black    0   BlackMale
#> 3583     Brett   male white    0   WhiteMale
#> 3584     Emily female white    0 WhiteFemale
#> 3585  Geoffrey   male white    0   WhiteMale
#> 3586     Jamal   male black    0   BlackMale
#> 3587     Jamal   male black    1   BlackMale
#> 3588     Jamal   male black    0   BlackMale
#> 3589    Kareem   male black    0   BlackMale
#> 3590   Latonya female black    0 BlackFemale
#> 3591    Laurie female white    0 WhiteFemale
#> 3592      Neil   male white    1   WhiteMale
#> 3593     Sarah female white    0 WhiteFemale
#> 3594    Tyrone   male black    0   BlackMale
#> 3595     Ebony female black    0 BlackFemale
#> 3596     Jamal   male black    0   BlackMale
#> 3597     Sarah female white    0 WhiteFemale
#> 3598      Todd   male white    0   WhiteMale
#> 3599     Ebony female black    1 BlackFemale
#> 3600      Jill female white    1 WhiteFemale
#> 3601   Kristen female white    1 WhiteFemale
#> 3602   Tanisha female black    0 BlackFemale
#> 3603    Carrie female white    0 WhiteFemale
#> 3604   Darnell   male black    0   BlackMale
#> 3605  Geoffrey   male white    0   WhiteMale
#> 3606  Geoffrey   male white    0   WhiteMale
#> 3607  Jermaine   male black    0   BlackMale
#> 3608   Latonya female black    0 BlackFemale
#> 3609   Matthew   male white    0   WhiteMale
#> 3610   Tanisha female black    0 BlackFemale
#> 3611   Allison female white    0 WhiteFemale
#> 3612   Darnell   male black    0   BlackMale
#> 3613       Jay   male white    1   WhiteMale
#> 3614    Tyrone   male black    0   BlackMale
#> 3615   Allison female white    0 WhiteFemale
#> 3616      Anne female white    0 WhiteFemale
#> 3617      Anne female white    0 WhiteFemale
#> 3618     Ebony female black    0 BlackFemale
#> 3619   Lakisha female black    0 BlackFemale
#> 3620     Sarah female white    0 WhiteFemale
#> 3621   Tanisha female black    0 BlackFemale
#> 3622   Tanisha female black    0 BlackFemale
#> 3623   Brendan   male white    0   WhiteMale
#> 3624     Ebony female black    0 BlackFemale
#> 3625      Greg   male white    0   WhiteMale
#> 3626    Latoya female black    1 BlackFemale
#> 3627      Brad   male white    1   WhiteMale
#> 3628     Ebony female black    0 BlackFemale
#> 3629      Neil   male white    1   WhiteMale
#> 3630   Rasheed   male black    1   BlackMale
#> 3631    Carrie female white    1 WhiteFemale
#> 3632    Latoya female black    1 BlackFemale
#> 3633      Anne female white    0 WhiteFemale
#> 3634    Carrie female white    1 WhiteFemale
#> 3635     Ebony female black    0 BlackFemale
#> 3636     Hakim   male black    0   BlackMale
#> 3637    Keisha female black    1 BlackFemale
#> 3638     Kenya female black    0 BlackFemale
#> 3639      Neil   male white    0   WhiteMale
#> 3640      Todd   male white    0   WhiteMale
#> 3641   Kristen female white    0 WhiteFemale
#> 3642     Sarah female white    0 WhiteFemale
#> 3643    Tamika female black    0 BlackFemale
#> 3644   Tanisha female black    0 BlackFemale
#> 3645   Allison female white    1 WhiteFemale
#> 3646     Ebony female black    1 BlackFemale
#> 3647    Latoya female black    1 BlackFemale
#> 3648    Laurie female white    0 WhiteFemale
#> 3649   Darnell   male black    0   BlackMale
#> 3650       Jay   male white    0   WhiteMale
#> 3651   Brendan   male white    0   WhiteMale
#> 3652   Darnell   male black    0   BlackMale
#> 3653  Geoffrey   male white    0   WhiteMale
#> 3654    Latoya female black    0 BlackFemale
#> 3655     Aisha female black    0 BlackFemale
#> 3656   Allison female white    0 WhiteFemale
#> 3657       Jay   male white    0   WhiteMale
#> 3658     Kenya female black    0 BlackFemale
#> 3659   Kristen female white    0 WhiteFemale
#> 3660   Lakisha female black    0 BlackFemale
#> 3661  Meredith female white    0 WhiteFemale
#> 3662    Tyrone   male black    0   BlackMale
#> 3663      Anne female white    0 WhiteFemale
#> 3664    Carrie female white    0 WhiteFemale
#> 3665     Kenya female black    0 BlackFemale
#> 3666    Latoya female black    0 BlackFemale
#> 3667    Carrie female white    0 WhiteFemale
#> 3668      Greg   male white    0   WhiteMale
#> 3669       Jay   male white    0   WhiteMale
#> 3670     Kenya female black    0 BlackFemale
#> 3671    Latoya female black    0 BlackFemale
#> 3672  Meredith female white    0 WhiteFemale
#> 3673   Rasheed   male black    0   BlackMale
#> 3674   Tanisha female black    0 BlackFemale
#> 3675      Anne female white    0 WhiteFemale
#> 3676    Latoya female black    0 BlackFemale
#> 3677     Sarah female white    0 WhiteFemale
#> 3678   Tanisha female black    0 BlackFemale
#> 3679    Carrie female white    0 WhiteFemale
#> 3680     Hakim   male black    0   BlackMale
#> 3681     Emily female white    0 WhiteFemale
#> 3682   Lakisha female black    0 BlackFemale
#> 3683    Latoya female black    0 BlackFemale
#> 3684     Sarah female white    0 WhiteFemale
#> 3685   Allison female white    0 WhiteFemale
#> 3686     Ebony female black    0 BlackFemale
#> 3687   Kristen female white    0 WhiteFemale
#> 3688    Tamika female black    0 BlackFemale
#> 3689   Brendan   male white    0   WhiteMale
#> 3690    Latoya female black    0 BlackFemale
#> 3691   Brendan   male white    0   WhiteMale
#> 3692     Ebony female black    1 BlackFemale
#> 3693     Emily female white    1 WhiteFemale
#> 3694   Latonya female black    1 BlackFemale
#> 3695    Latoya female black    0 BlackFemale
#> 3696    Laurie female white    1 WhiteFemale
#> 3697     Aisha female black    1 BlackFemale
#> 3698    Carrie female white    0 WhiteFemale
#> 3699  Geoffrey   male white    0   WhiteMale
#> 3700  Jermaine   male black    0   BlackMale
#> 3701    Keisha female black    0 BlackFemale
#> 3702   Kristen female white    1 WhiteFemale
#> 3703   Latonya female black    0 BlackFemale
#> 3704    Laurie female white    0 WhiteFemale
#> 3705   Lakisha female black    0 BlackFemale
#> 3706     Sarah female white    0 WhiteFemale
#> 3707     Emily female white    0 WhiteFemale
#> 3708     Jamal   male black    0   BlackMale
#> 3709      Brad   male white    0   WhiteMale
#> 3710    Tamika female black    0 BlackFemale
#> 3711   Allison female white    0 WhiteFemale
#> 3712   Latonya female black    0 BlackFemale
#> 3713  Meredith female white    0 WhiteFemale
#> 3714    Tamika female black    0 BlackFemale
#> 3715     Ebony female black    0 BlackFemale
#> 3716  Geoffrey   male white    1   WhiteMale
#> 3717    Keisha female black    0 BlackFemale
#> 3718    Laurie female white    0 WhiteFemale
#> 3719  Meredith female white    0 WhiteFemale
#> 3720   Tanisha female black    0 BlackFemale
#> 3721     Aisha female black    0 BlackFemale
#> 3722      Brad   male white    0   WhiteMale
#> 3723     Leroy   male black    0   BlackMale
#> 3724      Neil   male white    0   WhiteMale
#> 3725   Lakisha female black    0 BlackFemale
#> 3726    Latoya female black    0 BlackFemale
#> 3727  Meredith female white    0 WhiteFemale
#> 3728     Sarah female white    0 WhiteFemale
#> 3729   Kristen female white    0 WhiteFemale
#> 3730   Latonya female black    0 BlackFemale
#> 3731    Laurie female white    0 WhiteFemale
#> 3732     Sarah female white    0 WhiteFemale
#> 3733    Tamika female black    0 BlackFemale
#> 3734   Tanisha female black    0 BlackFemale
#> 3735   Allison female white    0 WhiteFemale
#> 3736     Kenya female black    0 BlackFemale
#> 3737  Meredith female white    0 WhiteFemale
#> 3738    Tamika female black    0 BlackFemale
#> 3739      Anne female white    0 WhiteFemale
#> 3740    Keisha female black    0 BlackFemale
#> 3741   Kristen female white    0 WhiteFemale
#> 3742   Lakisha female black    0 BlackFemale
#> 3743     Aisha female black    0 BlackFemale
#> 3744   Allison female white    0 WhiteFemale
#> 3745    Carrie female white    0 WhiteFemale
#> 3746   Darnell   male black    0   BlackMale
#> 3747      Jill female white    0 WhiteFemale
#> 3748    Keisha female black    0 BlackFemale
#> 3749   Allison female white    0 WhiteFemale
#> 3750     Brett   male white    0   WhiteMale
#> 3751     Emily female white    0 WhiteFemale
#> 3752   Latonya female black    0 BlackFemale
#> 3753    Latoya female black    0 BlackFemale
#> 3754    Tyrone   male black    0   BlackMale
#> 3755  Geoffrey   male white    0   WhiteMale
#> 3756      Jill female white    0 WhiteFemale
#> 3757     Kenya female black    1 BlackFemale
#> 3758   Latonya female black    0 BlackFemale
#> 3759    Laurie female white    0 WhiteFemale
#> 3760   Rasheed   male black    0   BlackMale
#> 3761      Anne female white    0 WhiteFemale
#> 3762     Ebony female black    0 BlackFemale
#> 3763     Emily female white    0 WhiteFemale
#> 3764   Tanisha female black    0 BlackFemale
#> 3765   Allison female white    0 WhiteFemale
#> 3766      Anne female white    0 WhiteFemale
#> 3767     Ebony female black    0 BlackFemale
#> 3768     Emily female white    0 WhiteFemale
#> 3769     Kenya female black    0 BlackFemale
#> 3770   Tanisha female black    0 BlackFemale
#> 3771   Allison female white    0 WhiteFemale
#> 3772     Jamal   male black    0   BlackMale
#> 3773       Jay   male white    1   WhiteMale
#> 3774    Keisha female black    0 BlackFemale
#> 3775      Brad   male white    0   WhiteMale
#> 3776    Kareem   male black    0   BlackMale
#> 3777    Carrie female white    0 WhiteFemale
#> 3778     Ebony female black    0 BlackFemale
#> 3779   Latonya female black    0 BlackFemale
#> 3780  Meredith female white    0 WhiteFemale
#> 3781      Anne female white    0 WhiteFemale
#> 3782    Latoya female black    0 BlackFemale
#> 3783  Meredith female white    0 WhiteFemale
#> 3784  Meredith female white    0 WhiteFemale
#> 3785    Tamika female black    0 BlackFemale
#> 3786   Tanisha female black    0 BlackFemale
#> 3787      Anne female white    0 WhiteFemale
#> 3788     Ebony female black    0 BlackFemale
#> 3789   Kristen female white    0 WhiteFemale
#> 3790   Tanisha female black    0 BlackFemale
#> 3791   Allison female white    1 WhiteFemale
#> 3792     Brett   male white    0   WhiteMale
#> 3793     Ebony female black    0 BlackFemale
#> 3794       Jay   male white    0   WhiteMale
#> 3795      Jill female white    0 WhiteFemale
#> 3796    Kareem   male black    0   BlackMale
#> 3797     Kenya female black    0 BlackFemale
#> 3798   Latonya female black    0 BlackFemale
#> 3799   Allison female white    1 WhiteFemale
#> 3800     Ebony female black    0 BlackFemale
#> 3801     Emily female white    0 WhiteFemale
#> 3802  Geoffrey   male white    0   WhiteMale
#> 3803   Latonya female black    0 BlackFemale
#> 3804     Leroy   male black    0   BlackMale
#> 3805      Todd   male white    0   WhiteMale
#> 3806  Tremayne   male black    0   BlackMale
#> 3807     Aisha female black    0 BlackFemale
#> 3808     Aisha female black    1 BlackFemale
#> 3809      Anne female white    0 WhiteFemale
#> 3810      Brad   male white    0   WhiteMale
#> 3811      Brad   male white    1   WhiteMale
#> 3812   Brendan   male white    0   WhiteMale
#> 3813    Carrie female white    0 WhiteFemale
#> 3814    Carrie female white    0 WhiteFemale
#> 3815   Darnell   male black    0   BlackMale
#> 3816     Ebony female black    0 BlackFemale
#> 3817     Ebony female black    0 BlackFemale
#> 3818     Hakim   male black    0   BlackMale
#> 3819     Hakim   male black    0   BlackMale
#> 3820       Jay   male white    0   WhiteMale
#> 3821      Jill female white    0 WhiteFemale
#> 3822    Kareem   male black    0   BlackMale
#> 3823    Keisha female black    0 BlackFemale
#> 3824     Kenya female black    0 BlackFemale
#> 3825   Kristen female white    0 WhiteFemale
#> 3826   Lakisha female black    0 BlackFemale
#> 3827    Laurie female white    0 WhiteFemale
#> 3828   Matthew   male white    0   WhiteMale
#> 3829  Meredith female white    0 WhiteFemale
#> 3830   Rasheed   male black    0   BlackMale
#> 3831   Tanisha female black    0 BlackFemale
#> 3832      Todd   male white    0   WhiteMale
#> 3833      Todd   male white    0   WhiteMale
#> 3834    Tyrone   male black    0   BlackMale
#> 3835      Anne female white    0 WhiteFemale
#> 3836      Anne female white    0 WhiteFemale
#> 3837     Ebony female black    0 BlackFemale
#> 3838      Jill female white    0 WhiteFemale
#> 3839     Kenya female black    0 BlackFemale
#> 3840  Meredith female white    0 WhiteFemale
#> 3841  Meredith female white    0 WhiteFemale
#> 3842   Rasheed   male black    0   BlackMale
#> 3843   Rasheed   male black    0   BlackMale
#> 3844    Tamika female black    0 BlackFemale
#> 3845      Todd   male white    0   WhiteMale
#> 3846  Tremayne   male black    0   BlackMale
#> 3847     Aisha female black    0 BlackFemale
#> 3848      Anne female white    0 WhiteFemale
#> 3849   Brendan   male white    0   WhiteMale
#> 3850     Leroy   male black    0   BlackMale
#> 3851   Allison female white    0 WhiteFemale
#> 3852  Geoffrey   male white    0   WhiteMale
#> 3853     Hakim   male black    0   BlackMale
#> 3854   Rasheed   male black    0   BlackMale
#> 3855      Anne female white    0 WhiteFemale
#> 3856     Ebony female black    0 BlackFemale
#> 3857    Laurie female white    0 WhiteFemale
#> 3858   Tanisha female black    0 BlackFemale
#> 3859     Aisha female black    0 BlackFemale
#> 3860   Brendan   male white    0   WhiteMale
#> 3861      Neil   male white    0   WhiteMale
#> 3862    Tamika female black    0 BlackFemale
#> 3863   Brendan   male white    0   WhiteMale
#> 3864     Kenya female black    0 BlackFemale
#> 3865      Neil   male white    0   WhiteMale
#> 3866    Tyrone   male black    0   BlackMale
#> 3867      Anne female white    0 WhiteFemale
#> 3868   Brendan   male white    0   WhiteMale
#> 3869     Brett   male white    0   WhiteMale
#> 3870      Greg   male white    0   WhiteMale
#> 3871     Hakim   male black    0   BlackMale
#> 3872     Jamal   male black    0   BlackMale
#> 3873  Jermaine   male black    0   BlackMale
#> 3874    Kareem   male black    0   BlackMale
#> 3875   Brendan   male white    0   WhiteMale
#> 3876     Jamal   male black    0   BlackMale
#> 3877   Latonya female black    0 BlackFemale
#> 3878   Matthew   male white    0   WhiteMale
#> 3879    Carrie female white    0 WhiteFemale
#> 3880     Ebony female black    0 BlackFemale
#> 3881     Emily female white    0 WhiteFemale
#> 3882      Jill female white    0 WhiteFemale
#> 3883    Tamika female black    0 BlackFemale
#> 3884   Tanisha female black    0 BlackFemale
#> 3885      Todd   male white    0   WhiteMale
#> 3886    Tyrone   male black    0   BlackMale
#> 3887     Aisha female black    0 BlackFemale
#> 3888   Brendan   male white    0   WhiteMale
#> 3889       Jay   male white    0   WhiteMale
#> 3890   Lakisha female black    0 BlackFemale
#> 3891     Brett   male white    0   WhiteMale
#> 3892    Keisha female black    0 BlackFemale
#> 3893    Laurie female white    0 WhiteFemale
#> 3894   Rasheed   male black    0   BlackMale
#> 3895     Brett   male white    0   WhiteMale
#> 3896     Hakim   male black    0   BlackMale
#> 3897     Leroy   male black    0   BlackMale
#> 3898      Todd   male white    0   WhiteMale
#> 3899     Aisha female black    0 BlackFemale
#> 3900     Brett   male white    0   WhiteMale
#> 3901   Lakisha female black    0 BlackFemale
#> 3902   Matthew   male white    0   WhiteMale
#> 3903      Anne female white    0 WhiteFemale
#> 3904     Kenya female black    0 BlackFemale
#> 3905   Lakisha female black    0 BlackFemale
#> 3906     Sarah female white    0 WhiteFemale
#> 3907     Emily female white    0 WhiteFemale
#> 3908     Jamal   male black    0   BlackMale
#> 3909  Jermaine   male black    0   BlackMale
#> 3910     Sarah female white    0 WhiteFemale
#> 3911      Greg   male white    0   WhiteMale
#> 3912     Jamal   male black    0   BlackMale
#> 3913   Lakisha female black    0 BlackFemale
#> 3914      Todd   male white    0   WhiteMale
#> 3915    Carrie female white    0 WhiteFemale
#> 3916   Lakisha female black    0 BlackFemale
#> 3917   Latonya female black    0 BlackFemale
#> 3918  Meredith female white    1 WhiteFemale
#> 3919      Anne female white    0 WhiteFemale
#> 3920    Carrie female white    0 WhiteFemale
#> 3921  Jermaine   male black    0   BlackMale
#> 3922    Keisha female black    0 BlackFemale
#> 3923    Latoya female black    0 BlackFemale
#> 3924  Meredith female white    0 WhiteFemale
#> 3925     Aisha female black    0 BlackFemale
#> 3926    Carrie female white    0 WhiteFemale
#> 3927      Anne female white    0 WhiteFemale
#> 3928     Emily female white    0 WhiteFemale
#> 3929    Latoya female black    0 BlackFemale
#> 3930    Tamika female black    0 BlackFemale
#> 3931      Anne female white    0 WhiteFemale
#> 3932    Kareem   male black    0   BlackMale
#> 3933  Meredith female white    0 WhiteFemale
#> 3934   Rasheed   male black    0   BlackMale
#> 3935     Aisha female black    0 BlackFemale
#> 3936     Aisha female black    0 BlackFemale
#> 3937     Emily female white    0 WhiteFemale
#> 3938   Latonya female black    0 BlackFemale
#> 3939    Laurie female white    0 WhiteFemale
#> 3940  Meredith female white    0 WhiteFemale
#> 3941     Aisha female black    0 BlackFemale
#> 3942    Keisha female black    0 BlackFemale
#> 3943    Laurie female white    0 WhiteFemale
#> 3944  Meredith female white    0 WhiteFemale
#> 3945     Aisha female black    0 BlackFemale
#> 3946     Emily female white    0 WhiteFemale
#> 3947   Kristen female white    0 WhiteFemale
#> 3948   Tanisha female black    0 BlackFemale
#> 3949   Allison female white    0 WhiteFemale
#> 3950     Ebony female black    0 BlackFemale
#> 3951      Greg   male white    0   WhiteMale
#> 3952   Lakisha female black    0 BlackFemale
#> 3953    Carrie female white    0 WhiteFemale
#> 3954     Ebony female black    1 BlackFemale
#> 3955    Latoya female black    0 BlackFemale
#> 3956     Sarah female white    0 WhiteFemale
#> 3957   Kristen female white    0 WhiteFemale
#> 3958    Laurie female white    0 WhiteFemale
#> 3959    Tamika female black    0 BlackFemale
#> 3960   Tanisha female black    0 BlackFemale
#> 3961     Aisha female black    0 BlackFemale
#> 3962   Allison female white    0 WhiteFemale
#> 3963    Carrie female white    0 WhiteFemale
#> 3964   Darnell   male black    0   BlackMale
#> 3965     Emily female white    0 WhiteFemale
#> 3966    Keisha female black    0 BlackFemale
#> 3967    Laurie female white    0 WhiteFemale
#> 3968    Tamika female black    0 BlackFemale
#> 3969       Jay   male white    0   WhiteMale
#> 3970   Latonya female black    0 BlackFemale
#> 3971     Aisha female black    0 BlackFemale
#> 3972   Allison female white    0 WhiteFemale
#> 3973      Jill female white    0 WhiteFemale
#> 3974   Lakisha female black    0 BlackFemale
#> 3975   Latonya female black    0 BlackFemale
#> 3976    Laurie female white    0 WhiteFemale
#> 3977     Sarah female white    0 WhiteFemale
#> 3978   Tanisha female black    0 BlackFemale
#> 3979      Anne female white    0 WhiteFemale
#> 3980   Latonya female black    0 BlackFemale
#> 3981  Meredith female white    0 WhiteFemale
#> 3982    Tamika female black    0 BlackFemale
#> 3983   Brendan   male white    0   WhiteMale
#> 3984     Jamal   male black    0   BlackMale
#> 3985   Matthew   male white    0   WhiteMale
#> 3986  Tremayne   male black    0   BlackMale
#> 3987   Allison female white    0 WhiteFemale
#> 3988    Latoya female black    0 BlackFemale
#> 3989      Neil   male white    0   WhiteMale
#> 3990    Tyrone   male black    0   BlackMale
#> 3991   Brendan   male white    0   WhiteMale
#> 3992     Ebony female black    0 BlackFemale
#> 3993     Sarah female white    0 WhiteFemale
#> 3994   Tanisha female black    0 BlackFemale
#> 3995      Anne female white    0 WhiteFemale
#> 3996   Brendan   male white    0   WhiteMale
#> 3997     Ebony female black    0 BlackFemale
#> 3998     Hakim   male black    0   BlackMale
#> 3999   Kristen female white    0 WhiteFemale
#> 4000    Tamika female black    0 BlackFemale
#> 4001    Carrie female white    0 WhiteFemale
#> 4002  Jermaine   male black    0   BlackMale
#> 4003      Jill female white    0 WhiteFemale
#> 4004    Keisha female black    0 BlackFemale
#> 4005    Latoya female black    0 BlackFemale
#> 4006   Matthew   male white    0   WhiteMale
#> 4007    Carrie female white    1 WhiteFemale
#> 4008     Kenya female black    1 BlackFemale
#> 4009     Aisha female black    0 BlackFemale
#> 4010    Laurie female white    0 WhiteFemale
#> 4011     Sarah female white    0 WhiteFemale
#> 4012     Sarah female white    0 WhiteFemale
#> 4013    Tamika female black    0 BlackFemale
#> 4014   Tanisha female black    0 BlackFemale
#> 4015    Carrie female white    0 WhiteFemale
#> 4016   Latonya female black    0 BlackFemale
#> 4017    Laurie female white    0 WhiteFemale
#> 4018   Tanisha female black    0 BlackFemale
#> 4019      Anne female white    1 WhiteFemale
#> 4020   Rasheed   male black    0   BlackMale
#> 4021      Jill female white    0 WhiteFemale
#> 4022    Keisha female black    0 BlackFemale
#> 4023   Kristen female white    0 WhiteFemale
#> 4024   Tanisha female black    0 BlackFemale
#> 4025   Allison female white    0 WhiteFemale
#> 4026     Emily female white    0 WhiteFemale
#> 4027   Lakisha female black    0 BlackFemale
#> 4028   Latonya female black    0 BlackFemale
#> 4029   Matthew   male white    0   WhiteMale
#> 4030    Tyrone   male black    0   BlackMale
#> 4031   Kristen female white    0 WhiteFemale
#> 4032    Latoya female black    0 BlackFemale
#> 4033    Laurie female white    0 WhiteFemale
#> 4034    Tamika female black    0 BlackFemale
#> 4035     Emily female white    0 WhiteFemale
#> 4036    Keisha female black    0 BlackFemale
#> 4037    Laurie female white    0 WhiteFemale
#> 4038     Sarah female white    0 WhiteFemale
#> 4039    Tamika female black    0 BlackFemale
#> 4040   Tanisha female black    0 BlackFemale
#> 4041     Aisha female black    0 BlackFemale
#> 4042   Kristen female white    0 WhiteFemale
#> 4043   Lakisha female black    0 BlackFemale
#> 4044    Laurie female white    0 WhiteFemale
#> 4045     Aisha female black    0 BlackFemale
#> 4046   Allison female white    1 WhiteFemale
#> 4047    Latoya female black    0 BlackFemale
#> 4048    Laurie female white    0 WhiteFemale
#> 4049   Allison female white    0 WhiteFemale
#> 4050      Anne female white    0 WhiteFemale
#> 4051      Anne female white    0 WhiteFemale
#> 4052   Darnell   male black    0   BlackMale
#> 4053    Keisha female black    0 BlackFemale
#> 4054    Latoya female black    0 BlackFemale
#> 4055   Tanisha female black    0 BlackFemale
#> 4056      Todd   male white    0   WhiteMale
#> 4057     Ebony female black    0 BlackFemale
#> 4058     Emily female white    0 WhiteFemale
#> 4059   Latonya female black    0 BlackFemale
#> 4060    Laurie female white    0 WhiteFemale
#> 4061     Aisha female black    0 BlackFemale
#> 4062   Allison female white    0 WhiteFemale
#> 4063     Jamal   male black    0   BlackMale
#> 4064       Jay   male white    0   WhiteMale
#> 4065      Jill female white    0 WhiteFemale
#> 4066   Latonya female black    0 BlackFemale
#> 4067   Allison female white    1 WhiteFemale
#> 4068      Anne female white    0 WhiteFemale
#> 4069     Ebony female black    0 BlackFemale
#> 4070     Kenya female black    0 BlackFemale
#> 4071     Emily female white    1 WhiteFemale
#> 4072  Geoffrey   male white    1   WhiteMale
#> 4073    Kareem   male black    1   BlackMale
#> 4074     Kenya female black    1 BlackFemale
#> 4075   Kristen female white    0 WhiteFemale
#> 4076   Latonya female black    0 BlackFemale
#> 4077  Meredith female white    0 WhiteFemale
#> 4078   Tanisha female black    0 BlackFemale
#> 4079     Aisha female black    0 BlackFemale
#> 4080      Anne female white    0 WhiteFemale
#> 4081   Brendan   male white    0   WhiteMale
#> 4082     Emily female white    0 WhiteFemale
#> 4083       Jay   male white    0   WhiteMale
#> 4084    Keisha female black    0 BlackFemale
#> 4085   Latonya female black    1 BlackFemale
#> 4086    Tamika female black    1 BlackFemale
#> 4087     Aisha female black    0 BlackFemale
#> 4088      Anne female white    0 WhiteFemale
#> 4089      Brad   male white    0   WhiteMale
#> 4090    Carrie female white    0 WhiteFemale
#> 4091     Ebony female black    0 BlackFemale
#> 4092     Emily female white    0 WhiteFemale
#> 4093  Geoffrey   male white    0   WhiteMale
#> 4094      Greg   male white    0   WhiteMale
#> 4095      Greg   male white    0   WhiteMale
#> 4096     Hakim   male black    0   BlackMale
#> 4097     Hakim   male black    0   BlackMale
#> 4098  Jermaine   male black    0   BlackMale
#> 4099      Jill female white    0 WhiteFemale
#> 4100      Jill female white    0 WhiteFemale
#> 4101    Kareem   male black    0   BlackMale
#> 4102    Keisha female black    0 BlackFemale
#> 4103     Kenya female black    0 BlackFemale
#> 4104    Latoya female black    0 BlackFemale
#> 4105    Latoya female black    0 BlackFemale
#> 4106    Laurie female white    0 WhiteFemale
#> 4107   Matthew   male white    0   WhiteMale
#> 4108  Meredith female white    0 WhiteFemale
#> 4109     Sarah female white    0 WhiteFemale
#> 4110    Tamika female black    0 BlackFemale
#> 4111      Todd   male white    0   WhiteMale
#> 4112  Tremayne   male black    0   BlackMale
#> 4113  Tremayne   male black    0   BlackMale
#> 4114    Tyrone   male black    0   BlackMale
#> 4115     Ebony female black    0 BlackFemale
#> 4116     Emily female white    0 WhiteFemale
#> 4117      Jill female white    0 WhiteFemale
#> 4118   Lakisha female black    0 BlackFemale
#> 4119      Greg   male white    0   WhiteMale
#> 4120       Jay   male white    0   WhiteMale
#> 4121     Leroy   male black    0   BlackMale
#> 4122   Rasheed   male black    0   BlackMale
#> 4123     Aisha female black    0 BlackFemale
#> 4124    Kareem   male black    0   BlackMale
#> 4125   Matthew   male white    0   WhiteMale
#> 4126  Meredith female white    0 WhiteFemale
#> 4127      Greg   male white    1   WhiteMale
#> 4128       Jay   male white    1   WhiteMale
#> 4129    Kareem   male black    1   BlackMale
#> 4130    Tamika female black    1 BlackFemale
#> 4131      Anne female white    0 WhiteFemale
#> 4132    Latoya female black    0 BlackFemale
#> 4133  Meredith female white    0 WhiteFemale
#> 4134   Tanisha female black    0 BlackFemale
#> 4135      Greg   male white    0   WhiteMale
#> 4136     Jamal   male black    0   BlackMale
#> 4137    Latoya female black    0 BlackFemale
#> 4138      Neil   male white    0   WhiteMale
#> 4139   Allison female white    0 WhiteFemale
#> 4140     Ebony female black    0 BlackFemale
#> 4141   Lakisha female black    0 BlackFemale
#> 4142  Meredith female white    0 WhiteFemale
#> 4143     Brett   male white    1   WhiteMale
#> 4144     Ebony female black    1 BlackFemale
#> 4145      Neil   male white    0   WhiteMale
#> 4146  Tremayne   male black    1   BlackMale
#> 4147      Anne female white    0 WhiteFemale
#> 4148    Kareem   male black    0   BlackMale
#> 4149     Kenya female black    0 BlackFemale
#> 4150   Matthew   male white    0   WhiteMale
#> 4151      Jill female white    0 WhiteFemale
#> 4152     Kenya female black    0 BlackFemale
#> 4153     Sarah female white    0 WhiteFemale
#> 4154    Tamika female black    0 BlackFemale
#> 4155      Brad   male white    0   WhiteMale
#> 4156  Jermaine   male black    0   BlackMale
#> 4157      Neil   male white    0   WhiteMale
#> 4158    Tamika female black    0 BlackFemale
#> 4159   Lakisha female black    0 BlackFemale
#> 4160   Matthew   male white    0   WhiteMale
#> 4161  Meredith female white    0 WhiteFemale
#> 4162   Rasheed   male black    0   BlackMale
#> 4163      Anne female white    0 WhiteFemale
#> 4164   Rasheed   male black    0   BlackMale
#> 4165     Sarah female white    0 WhiteFemale
#> 4166  Tremayne   male black    0   BlackMale
#> 4167      Greg   male white    0   WhiteMale
#> 4168   Rasheed   male black    0   BlackMale
#> 4169   Tanisha female black    1 BlackFemale
#> 4170      Todd   male white    0   WhiteMale
#> 4171     Brett   male white    0   WhiteMale
#> 4172     Leroy   male black    0   BlackMale
#> 4173   Matthew   male white    0   WhiteMale
#> 4174    Tamika female black    0 BlackFemale
#> 4175     Aisha female black    0 BlackFemale
#> 4176   Allison female white    0 WhiteFemale
#> 4177     Sarah female white    0 WhiteFemale
#> 4178    Tamika female black    0 BlackFemale
#> 4179   Allison female white    0 WhiteFemale
#> 4180   Allison female white    0 WhiteFemale
#> 4181      Anne female white    0 WhiteFemale
#> 4182     Ebony female black    0 BlackFemale
#> 4183   Lakisha female black    0 BlackFemale
#> 4184   Latonya female black    0 BlackFemale
#> 4185   Kristen female white    0 WhiteFemale
#> 4186     Sarah female white    0 WhiteFemale
#> 4187    Tamika female black    0 BlackFemale
#> 4188   Tanisha female black    0 BlackFemale
#> 4189      Jill female white    0 WhiteFemale
#> 4190    Latoya female black    0 BlackFemale
#> 4191   Kristen female white    1 WhiteFemale
#> 4192   Lakisha female black    0 BlackFemale
#> 4193   Latonya female black    0 BlackFemale
#> 4194  Meredith female white    1 WhiteFemale
#> 4195      Anne female white    0 WhiteFemale
#> 4196    Carrie female white    0 WhiteFemale
#> 4197     Ebony female black    0 BlackFemale
#> 4198     Emily female white    0 WhiteFemale
#> 4199      Jill female white    0 WhiteFemale
#> 4200     Kenya female black    0 BlackFemale
#> 4201   Tanisha female black    0 BlackFemale
#> 4202  Tremayne   male black    0   BlackMale
#> 4203    Carrie female white    0 WhiteFemale
#> 4204      Jill female white    0 WhiteFemale
#> 4205    Latoya female black    0 BlackFemale
#> 4206   Tanisha female black    0 BlackFemale
#> 4207    Laurie female white    0 WhiteFemale
#> 4208    Tamika female black    0 BlackFemale
#> 4209     Sarah female white    0 WhiteFemale
#> 4210    Tamika female black    0 BlackFemale
#> 4211     Emily female white    0 WhiteFemale
#> 4212     Kenya female black    0 BlackFemale
#> 4213   Kristen female white    0 WhiteFemale
#> 4214   Latonya female black    0 BlackFemale
#> 4215      Anne female white    0 WhiteFemale
#> 4216    Carrie female white    0 WhiteFemale
#> 4217   Darnell   male black    0   BlackMale
#> 4218     Hakim   male black    0   BlackMale
#> 4219       Jay   male white    0   WhiteMale
#> 4220      Jill female white    0 WhiteFemale
#> 4221   Lakisha female black    0 BlackFemale
#> 4222    Tamika female black    0 BlackFemale
#> 4223     Kenya female black    0 BlackFemale
#> 4224   Kristen female white    0 WhiteFemale
#> 4225    Laurie female white    0 WhiteFemale
#> 4226    Tamika female black    0 BlackFemale
#> 4227   Allison female white    0 WhiteFemale
#> 4228    Keisha female black    0 BlackFemale
#> 4229   Kristen female white    0 WhiteFemale
#> 4230     Sarah female white    0 WhiteFemale
#> 4231    Tamika female black    0 BlackFemale
#> 4232  Tremayne   male black    0   BlackMale
#> 4233      Anne female white    0 WhiteFemale
#> 4234     Ebony female black    0 BlackFemale
#> 4235     Kenya female black    0 BlackFemale
#> 4236   Kristen female white    0 WhiteFemale
#> 4237     Aisha female black    0 BlackFemale
#> 4238   Allison female white    0 WhiteFemale
#> 4239    Carrie female white    0 WhiteFemale
#> 4240    Keisha female black    0 BlackFemale
#> 4241   Allison female white    0 WhiteFemale
#> 4242  Jermaine   male black    1   BlackMale
#> 4243     Leroy   male black    0   BlackMale
#> 4244      Neil   male white    1   WhiteMale
#> 4245       Jay   male white    0   WhiteMale
#> 4246      Jill female white    1 WhiteFemale
#> 4247     Kenya female black    1 BlackFemale
#> 4248   Kristen female white    0 WhiteFemale
#> 4249    Latoya female black    1 BlackFemale
#> 4250   Rasheed   male black    0   BlackMale
#> 4251     Ebony female black    0 BlackFemale
#> 4252  Geoffrey   male white    0   WhiteMale
#> 4253       Jay   male white    0   WhiteMale
#> 4254      Jill female white    0 WhiteFemale
#> 4255     Kenya female black    0 BlackFemale
#> 4256   Latonya female black    0 BlackFemale
#> 4257     Sarah female white    0 WhiteFemale
#> 4258   Tanisha female black    0 BlackFemale
#> 4259   Brendan   male white    0   WhiteMale
#> 4260     Emily female white    0 WhiteFemale
#> 4261   Kristen female white    0 WhiteFemale
#> 4262    Latoya female black    0 BlackFemale
#> 4263   Rasheed   male black    0   BlackMale
#> 4264    Tamika female black    0 BlackFemale
#> 4265      Jill female white    0 WhiteFemale
#> 4266    Latoya female black    0 BlackFemale
#> 4267    Laurie female white    0 WhiteFemale
#> 4268    Tamika female black    0 BlackFemale
#> 4269    Carrie female white    0 WhiteFemale
#> 4270     Ebony female black    0 BlackFemale
#> 4271     Ebony female black    0 BlackFemale
#> 4272     Kenya female black    0 BlackFemale
#> 4273   Kristen female white    0 WhiteFemale
#> 4274      Todd   male white    0   WhiteMale
#> 4275     Aisha female black    0 BlackFemale
#> 4276   Allison female white    0 WhiteFemale
#> 4277    Carrie female white    0 WhiteFemale
#> 4278    Latoya female black    0 BlackFemale
#> 4279    Laurie female white    0 WhiteFemale
#> 4280     Sarah female white    0 WhiteFemale
#> 4281    Tamika female black    0 BlackFemale
#> 4282   Tanisha female black    0 BlackFemale
#> 4283    Carrie female white    0 WhiteFemale
#> 4284    Keisha female black    0 BlackFemale
#> 4285   Latonya female black    0 BlackFemale
#> 4286     Leroy   male black    1   BlackMale
#> 4287      Neil   male white    1   WhiteMale
#> 4288     Sarah female white    0 WhiteFemale
#> 4289     Aisha female black    0 BlackFemale
#> 4290      Anne female white    0 WhiteFemale
#> 4291    Latoya female black    0 BlackFemale
#> 4292  Meredith female white    0 WhiteFemale
#> 4293    Carrie female white    0 WhiteFemale
#> 4294     Kenya female black    0 BlackFemale
#> 4295   Kristen female white    1 WhiteFemale
#> 4296   Lakisha female black    0 BlackFemale
#> 4297  Meredith female white    1 WhiteFemale
#> 4298  Tremayne   male black    0   BlackMale
#> 4299      Jill female white    0 WhiteFemale
#> 4300   Kristen female white    0 WhiteFemale
#> 4301    Latoya female black    0 BlackFemale
#> 4302    Tamika female black    0 BlackFemale
#> 4303    Carrie female white    0 WhiteFemale
#> 4304     Emily female white    0 WhiteFemale
#> 4305    Latoya female black    0 BlackFemale
#> 4306   Tanisha female black    0 BlackFemale
#> 4307     Ebony female black    0 BlackFemale
#> 4308     Emily female white    0 WhiteFemale
#> 4309    Laurie female white    0 WhiteFemale
#> 4310  Tremayne   male black    0   BlackMale
#> 4311    Laurie female white    0 WhiteFemale
#> 4312    Tamika female black    0 BlackFemale
#> 4313    Carrie female white    0 WhiteFemale
#> 4314   Lakisha female black    0 BlackFemale
#> 4315   Latonya female black    0 BlackFemale
#> 4316  Meredith female white    0 WhiteFemale
#> 4317   Allison female white    0 WhiteFemale
#> 4318    Carrie female white    0 WhiteFemale
#> 4319      Jill female white    0 WhiteFemale
#> 4320    Kareem   male black    0   BlackMale
#> 4321   Latonya female black    0 BlackFemale
#> 4322    Latoya female black    0 BlackFemale
#> 4323      Anne female white    0 WhiteFemale
#> 4324     Emily female white    0 WhiteFemale
#> 4325     Kenya female black    0 BlackFemale
#> 4326   Tanisha female black    0 BlackFemale
#> 4327  Jermaine   male black    0   BlackMale
#> 4328   Latonya female black    0 BlackFemale
#> 4329    Laurie female white    0 WhiteFemale
#> 4330     Sarah female white    0 WhiteFemale
#> 4331  Jermaine   male black    0   BlackMale
#> 4332     Kenya female black    0 BlackFemale
#> 4333   Kristen female white    1 WhiteFemale
#> 4334  Meredith female white    0 WhiteFemale
#> 4335     Sarah female white    1 WhiteFemale
#> 4336   Tanisha female black    1 BlackFemale
#> 4337      Anne female white    0 WhiteFemale
#> 4338      Brad   male white    0   WhiteMale
#> 4339     Emily female white    0 WhiteFemale
#> 4340     Hakim   male black    0   BlackMale
#> 4341  Jermaine   male black    0   BlackMale
#> 4342  Jermaine   male black    0   BlackMale
#> 4343      Jill female white    0 WhiteFemale
#> 4344      Jill female white    0 WhiteFemale
#> 4345    Keisha female black    0 BlackFemale
#> 4346   Lakisha female black    0 BlackFemale
#> 4347   Lakisha female black    0 BlackFemale
#> 4348   Latonya female black    0 BlackFemale
#> 4349    Latoya female black    0 BlackFemale
#> 4350    Latoya female black    0 BlackFemale
#> 4351    Latoya female black    0 BlackFemale
#> 4352    Laurie female white    0 WhiteFemale
#> 4353    Laurie female white    0 WhiteFemale
#> 4354    Laurie female white    0 WhiteFemale
#> 4355   Matthew   male white    0   WhiteMale
#> 4356  Meredith female white    0 WhiteFemale
#> 4357   Rasheed   male black    0   BlackMale
#> 4358     Sarah female white    0 WhiteFemale
#> 4359      Todd   male white    0   WhiteMale
#> 4360  Tremayne   male black    0   BlackMale
#> 4361      Anne female white    0 WhiteFemale
#> 4362      Jill female white    0 WhiteFemale
#> 4363    Latoya female black    1 BlackFemale
#> 4364    Tamika female black    0 BlackFemale
#> 4365      Greg   male white    0   WhiteMale
#> 4366       Jay   male white    0   WhiteMale
#> 4367   Latonya female black    0 BlackFemale
#> 4368    Tyrone   male black    0   BlackMale
#> 4369      Brad   male white    0   WhiteMale
#> 4370   Kristen female white    1 WhiteFemale
#> 4371    Latoya female black    0 BlackFemale
#> 4372   Tanisha female black    0 BlackFemale
#> 4373   Kristen female white    0 WhiteFemale
#> 4374   Latonya female black    0 BlackFemale
#> 4375     Sarah female white    0 WhiteFemale
#> 4376   Tanisha female black    0 BlackFemale
#> 4377   Darnell   male black    0   BlackMale
#> 4378    Keisha female black    0 BlackFemale
#> 4379  Meredith female white    0 WhiteFemale
#> 4380      Neil   male white    0   WhiteMale
#> 4381  Geoffrey   male white    0   WhiteMale
#> 4382    Keisha female black    0 BlackFemale
#> 4383   Latonya female black    0 BlackFemale
#> 4384   Matthew   male white    0   WhiteMale
#> 4385      Brad   male white    0   WhiteMale
#> 4386      Greg   male white    0   WhiteMale
#> 4387    Latoya female black    0 BlackFemale
#> 4388  Tremayne   male black    0   BlackMale
#> 4389  Geoffrey   male white    0   WhiteMale
#> 4390    Latoya female black    0 BlackFemale
#> 4391      Neil   male white    0   WhiteMale
#> 4392    Tyrone   male black    0   BlackMale
#> 4393      Anne female white    0 WhiteFemale
#> 4394     Emily female white    0 WhiteFemale
#> 4395     Hakim   male black    0   BlackMale
#> 4396   Latonya female black    0 BlackFemale
#> 4397     Ebony female black    0 BlackFemale
#> 4398    Laurie female white    0 WhiteFemale
#> 4399  Meredith female white    0 WhiteFemale
#> 4400    Tamika female black    0 BlackFemale
#> 4401      Greg   male white    1   WhiteMale
#> 4402    Latoya female black    1 BlackFemale
#> 4403      Neil   male white    0   WhiteMale
#> 4404   Tanisha female black    1 BlackFemale
#> 4405   Allison female white    0 WhiteFemale
#> 4406     Ebony female black    0 BlackFemale
#> 4407      Jill female white    0 WhiteFemale
#> 4408     Kenya female black    0 BlackFemale
#> 4409     Ebony female black    1 BlackFemale
#> 4410     Emily female white    1 WhiteFemale
#> 4411     Aisha female black    0 BlackFemale
#> 4412    Carrie female white    1 WhiteFemale
#> 4413     Ebony female black    0 BlackFemale
#> 4414     Emily female white    0 WhiteFemale
#> 4415     Emily female white    0 WhiteFemale
#> 4416    Kareem   male black    0   BlackMale
#> 4417   Matthew   male white    0   WhiteMale
#> 4418  Tremayne   male black    0   BlackMale
#> 4419   Kristen female white    0 WhiteFemale
#> 4420     Sarah female white    0 WhiteFemale
#> 4421    Tamika female black    0 BlackFemale
#> 4422   Tanisha female black    0 BlackFemale
#> 4423   Allison female white    0 WhiteFemale
#> 4424    Keisha female black    0 BlackFemale
#> 4425   Kristen female white    0 WhiteFemale
#> 4426    Tamika female black    0 BlackFemale
#> 4427     Brett   male white    0   WhiteMale
#> 4428     Jamal   male black    1   BlackMale
#> 4429      Anne female white    0 WhiteFemale
#> 4430     Ebony female black    0 BlackFemale
#> 4431     Emily female white    0 WhiteFemale
#> 4432   Rasheed   male black    0   BlackMale
#> 4433      Anne female white    0 WhiteFemale
#> 4434      Jill female white    0 WhiteFemale
#> 4435     Kenya female black    0 BlackFemale
#> 4436    Latoya female black    0 BlackFemale
#> 4437     Aisha female black    0 BlackFemale
#> 4438      Anne female white    0 WhiteFemale
#> 4439    Latoya female black    0 BlackFemale
#> 4440  Meredith female white    0 WhiteFemale
#> 4441     Kenya female black    0 BlackFemale
#> 4442   Kristen female white    0 WhiteFemale
#> 4443    Laurie female white    0 WhiteFemale
#> 4444    Tamika female black    0 BlackFemale
#> 4445      Anne female white    0 WhiteFemale
#> 4446     Ebony female black    0 BlackFemale
#> 4447    Keisha female black    0 BlackFemale
#> 4448    Laurie female white    0 WhiteFemale
#> 4449     Aisha female black    0 BlackFemale
#> 4450      Anne female white    0 WhiteFemale
#> 4451      Jill female white    0 WhiteFemale
#> 4452   Kristen female white    0 WhiteFemale
#> 4453   Lakisha female black    0 BlackFemale
#> 4454   Rasheed   male black    0   BlackMale
#> 4455     Aisha female black    0 BlackFemale
#> 4456      Anne female white    0 WhiteFemale
#> 4457     Emily female white    0 WhiteFemale
#> 4458    Tamika female black    0 BlackFemale
#> 4459      Anne female white    0 WhiteFemale
#> 4460     Emily female white    0 WhiteFemale
#> 4461  Jermaine   male black    0   BlackMale
#> 4462   Latonya female black    0 BlackFemale
#> 4463   Latonya female black    0 BlackFemale
#> 4464    Laurie female white    0 WhiteFemale
#> 4465     Aisha female black    0 BlackFemale
#> 4466  Meredith female white    0 WhiteFemale
#> 4467     Sarah female white    0 WhiteFemale
#> 4468   Tanisha female black    0 BlackFemale
#> 4469     Brett   male white    0   WhiteMale
#> 4470     Leroy   male black    0   BlackMale
#> 4471   Brendan   male white    0   WhiteMale
#> 4472  Geoffrey   male white    0   WhiteMale
#> 4473     Jamal   male black    0   BlackMale
#> 4474    Kareem   male black    0   BlackMale
#> 4475   Matthew   male white    1   WhiteMale
#> 4476  Tremayne   male black    0   BlackMale
#> 4477      Anne female white    0 WhiteFemale
#> 4478     Kenya female black    0 BlackFemale
#> 4479    Laurie female white    0 WhiteFemale
#> 4480   Tanisha female black    0 BlackFemale
#> 4481      Anne female white    0 WhiteFemale
#> 4482      Jill female white    0 WhiteFemale
#> 4483    Keisha female black    0 BlackFemale
#> 4484   Kristen female white    0 WhiteFemale
#> 4485   Lakisha female black    0 BlackFemale
#> 4486   Latonya female black    0 BlackFemale
#> 4487     Aisha female black    0 BlackFemale
#> 4488      Anne female white    0 WhiteFemale
#> 4489   Kristen female white    0 WhiteFemale
#> 4490   Matthew   male white    0   WhiteMale
#> 4491    Tamika female black    0 BlackFemale
#> 4492   Tanisha female black    0 BlackFemale
#> 4493     Aisha female black    0 BlackFemale
#> 4494   Allison female white    0 WhiteFemale
#> 4495   Lakisha female black    0 BlackFemale
#> 4496     Sarah female white    0 WhiteFemale
#> 4497     Aisha female black    0 BlackFemale
#> 4498     Emily female white    0 WhiteFemale
#> 4499    Keisha female black    0 BlackFemale
#> 4500     Kenya female black    0 BlackFemale
#> 4501    Laurie female white    0 WhiteFemale
#> 4502     Sarah female white    0 WhiteFemale
#> 4503   Allison female white    0 WhiteFemale
#> 4504     Emily female white    0 WhiteFemale
#> 4505    Tamika female black    0 BlackFemale
#> 4506   Tanisha female black    0 BlackFemale
#> 4507    Carrie female white    0 WhiteFemale
#> 4508     Kenya female black    0 BlackFemale
#> 4509     Sarah female white    0 WhiteFemale
#> 4510   Tanisha female black    0 BlackFemale
#> 4511   Allison female white    0 WhiteFemale
#> 4512   Darnell   male black    0   BlackMale
#> 4513     Ebony female black    0 BlackFemale
#> 4514       Jay   male white    0   WhiteMale
#> 4515      Jill female white    0 WhiteFemale
#> 4516    Keisha female black    0 BlackFemale
#> 4517    Laurie female white    0 WhiteFemale
#> 4518     Sarah female white    0 WhiteFemale
#> 4519    Tamika female black    0 BlackFemale
#> 4520   Tanisha female black    0 BlackFemale
#> 4521     Aisha female black    0 BlackFemale
#> 4522   Allison female white    0 WhiteFemale
#> 4523     Brett   male white    0   WhiteMale
#> 4524  Jermaine   male black    0   BlackMale
#> 4525      Jill female white    0 WhiteFemale
#> 4526    Keisha female black    0 BlackFemale
#> 4527      Anne female white    0 WhiteFemale
#> 4528   Latonya female black    0 BlackFemale
#> 4529    Laurie female white    0 WhiteFemale
#> 4530   Tanisha female black    0 BlackFemale
#> 4531     Aisha female black    0 BlackFemale
#> 4532    Carrie female white    0 WhiteFemale
#> 4533   Kristen female white    0 WhiteFemale
#> 4534    Tamika female black    0 BlackFemale
#> 4535   Brendan   male white    0   WhiteMale
#> 4536    Carrie female white    0 WhiteFemale
#> 4537   Lakisha female black    0 BlackFemale
#> 4538   Latonya female black    0 BlackFemale
#> 4539    Latoya female black    0 BlackFemale
#> 4540  Meredith female white    0 WhiteFemale
#> 4541     Brett   male white    0   WhiteMale
#> 4542   Latonya female black    0 BlackFemale
#> 4543      Anne female white    0 WhiteFemale
#> 4544     Emily female white    0 WhiteFemale
#> 4545    Latoya female black    0 BlackFemale
#> 4546    Tamika female black    0 BlackFemale
#> 4547    Carrie female white    0 WhiteFemale
#> 4548   Latonya female black    0 BlackFemale
#> 4549    Laurie female white    0 WhiteFemale
#> 4550  Tremayne   male black    0   BlackMale
#> 4551     Aisha female black    0 BlackFemale
#> 4552    Carrie female white    0 WhiteFemale
#> 4553    Carrie female white    0 WhiteFemale
#> 4554     Emily female white    0 WhiteFemale
#> 4555      Jill female white    0 WhiteFemale
#> 4556     Kenya female black    0 BlackFemale
#> 4557   Latonya female black    0 BlackFemale
#> 4558   Tanisha female black    0 BlackFemale
#> 4559   Allison female white    1 WhiteFemale
#> 4560    Carrie female white    0 WhiteFemale
#> 4561     Ebony female black    0 BlackFemale
#> 4562     Leroy   male black    1   BlackMale
#> 4563      Anne female white    0 WhiteFemale
#> 4564      Anne female white    0 WhiteFemale
#> 4565      Brad   male white    0   WhiteMale
#> 4566     Brett   male white    0   WhiteMale
#> 4567     Brett   male white    0   WhiteMale
#> 4568    Carrie female white    0 WhiteFemale
#> 4569   Darnell   male black    0   BlackMale
#> 4570     Ebony female black    0 BlackFemale
#> 4571     Emily female white    0 WhiteFemale
#> 4572     Hakim   male black    0   BlackMale
#> 4573     Jamal   male black    0   BlackMale
#> 4574     Jamal   male black    0   BlackMale
#> 4575       Jay   male white    0   WhiteMale
#> 4576       Jay   male white    0   WhiteMale
#> 4577  Jermaine   male black    0   BlackMale
#> 4578   Kristen female white    0 WhiteFemale
#> 4579   Kristen female white    0 WhiteFemale
#> 4580   Lakisha female black    0 BlackFemale
#> 4581    Latoya female black    0 BlackFemale
#> 4582  Meredith female white    0 WhiteFemale
#> 4583  Meredith female white    0 WhiteFemale
#> 4584      Neil   male white    0   WhiteMale
#> 4585   Rasheed   male black    0   BlackMale
#> 4586   Rasheed   male black    0   BlackMale
#> 4587     Sarah female white    0 WhiteFemale
#> 4588     Sarah female white    0 WhiteFemale
#> 4589    Tamika female black    0 BlackFemale
#> 4590    Tamika female black    0 BlackFemale
#> 4591   Tanisha female black    0 BlackFemale
#> 4592  Tremayne   male black    0   BlackMale
#> 4593  Tremayne   male black    0   BlackMale
#> 4594    Tyrone   male black    0   BlackMale
#> 4595   Allison female white    0 WhiteFemale
#> 4596      Jill female white    0 WhiteFemale
#> 4597    Tamika female black    0 BlackFemale
#> 4598  Tremayne   male black    0   BlackMale
#> 4599     Aisha female black    0 BlackFemale
#> 4600   Brendan   male white    0   WhiteMale
#> 4601  Jermaine   male black    0   BlackMale
#> 4602      Jill female white    0 WhiteFemale
#> 4603      Jill female white    0 WhiteFemale
#> 4604     Kenya female black    1 BlackFemale
#> 4605     Sarah female white    0 WhiteFemale
#> 4606    Tamika female black    0 BlackFemale
#> 4607   Kristen female white    0 WhiteFemale
#> 4608    Latoya female black    0 BlackFemale
#> 4609     Leroy   male black    0   BlackMale
#> 4610  Meredith female white    0 WhiteFemale
#> 4611      Jill female white    0 WhiteFemale
#> 4612   Kristen female white    1 WhiteFemale
#> 4613    Latoya female black    0 BlackFemale
#> 4614    Tamika female black    0 BlackFemale
#> 4615      Anne female white    0 WhiteFemale
#> 4616   Latonya female black    0 BlackFemale
#> 4617      Neil   male white    0   WhiteMale
#> 4618   Rasheed   male black    0   BlackMale
#> 4619   Allison female white    0 WhiteFemale
#> 4620     Emily female white    0 WhiteFemale
#> 4621   Lakisha female black    0 BlackFemale
#> 4622   Tanisha female black    0 BlackFemale
#> 4623      Greg   male white    0   WhiteMale
#> 4624     Kenya female black    0 BlackFemale
#> 4625   Kristen female white    0 WhiteFemale
#> 4626    Tamika female black    0 BlackFemale
#> 4627     Brett   male white    0   WhiteMale
#> 4628   Darnell   male black    0   BlackMale
#> 4629     Ebony female black    0 BlackFemale
#> 4630  Meredith female white    0 WhiteFemale
#> 4631     Ebony female black    0 BlackFemale
#> 4632   Kristen female white    0 WhiteFemale
#> 4633    Latoya female black    0 BlackFemale
#> 4634     Sarah female white    0 WhiteFemale
#> 4635      Brad   male white    0   WhiteMale
#> 4636   Latonya female black    0 BlackFemale
#> 4637   Rasheed   male black    0   BlackMale
#> 4638     Sarah female white    0 WhiteFemale
#> 4639     Aisha female black    0 BlackFemale
#> 4640    Latoya female black    0 BlackFemale
#> 4641    Laurie female white    0 WhiteFemale
#> 4642  Meredith female white    0 WhiteFemale
#> 4643   Brendan   male white    0   WhiteMale
#> 4644     Emily female white    0 WhiteFemale
#> 4645     Kenya female black    0 BlackFemale
#> 4646     Kenya female black    0 BlackFemale
#> 4647   Kristen female white    0 WhiteFemale
#> 4648   Latonya female black    0 BlackFemale
#> 4649   Rasheed   male black    0   BlackMale
#> 4650     Sarah female white    0 WhiteFemale
#> 4651   Allison female white    0 WhiteFemale
#> 4652    Keisha female black    0 BlackFemale
#> 4653   Kristen female white    0 WhiteFemale
#> 4654    Tamika female black    0 BlackFemale
#> 4655   Allison female white    0 WhiteFemale
#> 4656    Keisha female black    0 BlackFemale
#> 4657   Kristen female white    0 WhiteFemale
#> 4658    Tamika female black    0 BlackFemale
#> 4659     Jamal   male black    0   BlackMale
#> 4660    Kareem   male black    0   BlackMale
#> 4661   Kristen female white    0 WhiteFemale
#> 4662    Laurie female white    0 WhiteFemale
#> 4663     Emily female white    0 WhiteFemale
#> 4664   Kristen female white    0 WhiteFemale
#> 4665   Kristen female white    0 WhiteFemale
#> 4666   Rasheed   male black    0   BlackMale
#> 4667    Tamika female black    0 BlackFemale
#> 4668    Tamika female black    0 BlackFemale
#> 4669     Aisha female black    0 BlackFemale
#> 4670     Emily female white    0 WhiteFemale
#> 4671     Kenya female black    0 BlackFemale
#> 4672     Sarah female white    0 WhiteFemale
#> 4673     Aisha female black    0 BlackFemale
#> 4674      Anne female white    0 WhiteFemale
#> 4675     Emily female white    0 WhiteFemale
#> 4676    Tamika female black    0 BlackFemale
#> 4677      Jill female white    0 WhiteFemale
#> 4678   Lakisha female black    1 BlackFemale
#> 4679    Latoya female black    1 BlackFemale
#> 4680    Laurie female white    0 WhiteFemale
#> 4681    Carrie female white    0 WhiteFemale
#> 4682   Kristen female white    0 WhiteFemale
#> 4683   Latonya female black    0 BlackFemale
#> 4684    Tamika female black    0 BlackFemale
#> 4685     Aisha female black    0 BlackFemale
#> 4686  Geoffrey   male white    0   WhiteMale
#> 4687      Jill female white    0 WhiteFemale
#> 4688   Kristen female white    0 WhiteFemale
#> 4689   Tanisha female black    0 BlackFemale
#> 4690  Tremayne   male black    0   BlackMale
#> 4691     Aisha female black    0 BlackFemale
#> 4692   Allison female white    0 WhiteFemale
#> 4693    Latoya female black    0 BlackFemale
#> 4694     Sarah female white    0 WhiteFemale
#> 4695    Carrie female white    0 WhiteFemale
#> 4696     Ebony female black    0 BlackFemale
#> 4697     Emily female white    0 WhiteFemale
#> 4698    Tamika female black    0 BlackFemale
#> 4699     Aisha female black    0 BlackFemale
#> 4700    Carrie female white    1 WhiteFemale
#> 4701   Lakisha female black    0 BlackFemale
#> 4702     Sarah female white    1 WhiteFemale
#> 4703     Jamal   male black    0   BlackMale
#> 4704      Neil   male white    1   WhiteMale
#> 4705      Todd   male white    0   WhiteMale
#> 4706    Tyrone   male black    1   BlackMale
#> 4707       Jay   male white    0   WhiteMale
#> 4708      Neil   male white    0   WhiteMale
#> 4709  Tremayne   male black    0   BlackMale
#> 4710    Tyrone   male black    0   BlackMale
#> 4711     Hakim   male black    0   BlackMale
#> 4712       Jay   male white    0   WhiteMale
#> 4713     Kenya female black    0 BlackFemale
#> 4714    Laurie female white    0 WhiteFemale
#> 4715   Allison female white    0 WhiteFemale
#> 4716   Kristen female white    0 WhiteFemale
#> 4717   Latonya female black    0 BlackFemale
#> 4718    Tamika female black    0 BlackFemale
#> 4719     Aisha female black    0 BlackFemale
#> 4720   Allison female white    0 WhiteFemale
#> 4721    Carrie female white    0 WhiteFemale
#> 4722      Jill female white    0 WhiteFemale
#> 4723   Lakisha female black    0 BlackFemale
#> 4724    Tamika female black    0 BlackFemale
#> 4725     Aisha female black    0 BlackFemale
#> 4726   Allison female white    1 WhiteFemale
#> 4727     Emily female white    0 WhiteFemale
#> 4728     Emily female white    0 WhiteFemale
#> 4729     Kenya female black    1 BlackFemale
#> 4730     Leroy   male black    0   BlackMale
#> 4731     Aisha female black    0 BlackFemale
#> 4732      Anne female white    0 WhiteFemale
#> 4733    Carrie female white    0 WhiteFemale
#> 4734   Lakisha female black    0 BlackFemale
#> 4735      Jill female white    0 WhiteFemale
#> 4736     Kenya female black    1 BlackFemale
#> 4737   Kristen female white    1 WhiteFemale
#> 4738   Latonya female black    1 BlackFemale
#> 4739   Latonya female black    0 BlackFemale
#> 4740     Sarah female white    1 WhiteFemale
#> 4741     Ebony female black    0 BlackFemale
#> 4742      Jill female white    0 WhiteFemale
#> 4743   Kristen female white    0 WhiteFemale
#> 4744    Latoya female black    0 BlackFemale
#> 4745      Anne female white    0 WhiteFemale
#> 4746     Emily female white    0 WhiteFemale
#> 4747   Lakisha female black    0 BlackFemale
#> 4748     Sarah female white    0 WhiteFemale
#> 4749    Tamika female black    0 BlackFemale
#> 4750    Tamika female black    0 BlackFemale
#> 4751    Carrie female white    0 WhiteFemale
#> 4752     Kenya female black    0 BlackFemale
#> 4753  Meredith female white    0 WhiteFemale
#> 4754   Tanisha female black    0 BlackFemale
#> 4755   Allison female white    0 WhiteFemale
#> 4756   Allison female white    0 WhiteFemale
#> 4757     Emily female white    0 WhiteFemale
#> 4758     Kenya female black    1 BlackFemale
#> 4759   Lakisha female black    0 BlackFemale
#> 4760   Latonya female black    0 BlackFemale
#> 4761     Aisha female black    0 BlackFemale
#> 4762    Carrie female white    0 WhiteFemale
#> 4763   Kristen female white    0 WhiteFemale
#> 4764    Tamika female black    0 BlackFemale
#> 4765      Jill female white    0 WhiteFemale
#> 4766    Tamika female black    0 BlackFemale
#> 4767      Anne female white    0 WhiteFemale
#> 4768       Jay   male white    0   WhiteMale
#> 4769   Latonya female black    0 BlackFemale
#> 4770    Latoya female black    0 BlackFemale
#> 4771  Meredith female white    0 WhiteFemale
#> 4772   Tanisha female black    0 BlackFemale
#> 4773    Laurie female white    0 WhiteFemale
#> 4774    Tyrone   male black    0   BlackMale
#> 4775     Aisha female black    0 BlackFemale
#> 4776   Allison female white    0 WhiteFemale
#> 4777     Sarah female white    0 WhiteFemale
#> 4778    Tamika female black    0 BlackFemale
#> 4779      Brad   male white    0   WhiteMale
#> 4780    Carrie female white    0 WhiteFemale
#> 4781   Latonya female black    0 BlackFemale
#> 4782   Latonya female black    0 BlackFemale
#> 4783   Brendan   male white    1   WhiteMale
#> 4784     Ebony female black    1 BlackFemale
#> 4785     Emily female white    0 WhiteFemale
#> 4786      Jill female white    0 WhiteFemale
#> 4787     Kenya female black    0 BlackFemale
#> 4788    Latoya female black    0 BlackFemale
#> 4789    Laurie female white    1 WhiteFemale
#> 4790    Tamika female black    0 BlackFemale
#> 4791  Geoffrey   male white    0   WhiteMale
#> 4792      Greg   male white    0   WhiteMale
#> 4793    Kareem   male black    0   BlackMale
#> 4794  Tremayne   male black    0   BlackMale
#> 4795      Brad   male white    0   WhiteMale
#> 4796   Darnell   male black    0   BlackMale
#> 4797     Ebony female black    0 BlackFemale
#> 4798     Emily female white    0 WhiteFemale
#> 4799  Geoffrey   male white    0   WhiteMale
#> 4800      Greg   male white    0   WhiteMale
#> 4801     Hakim   male black    0   BlackMale
#> 4802     Jamal   male black    0   BlackMale
#> 4803       Jay   male white    0   WhiteMale
#> 4804      Jill female white    0 WhiteFemale
#> 4805    Kareem   male black    0   BlackMale
#> 4806    Kareem   male black    0   BlackMale
#> 4807     Kenya female black    0 BlackFemale
#> 4808     Kenya female black    0 BlackFemale
#> 4809   Lakisha female black    0 BlackFemale
#> 4810    Laurie female white    0 WhiteFemale
#> 4811    Laurie female white    0 WhiteFemale
#> 4812    Laurie female white    0 WhiteFemale
#> 4813     Leroy   male black    0   BlackMale
#> 4814  Meredith female white    0 WhiteFemale
#> 4815  Meredith female white    0 WhiteFemale
#> 4816   Rasheed   male black    0   BlackMale
#> 4817     Sarah female white    0 WhiteFemale
#> 4818     Sarah female white    0 WhiteFemale
#> 4819   Tanisha female black    0 BlackFemale
#> 4820      Todd   male white    0   WhiteMale
#> 4821  Tremayne   male black    0   BlackMale
#> 4822    Tyrone   male black    0   BlackMale
#> 4823   Allison female white    0 WhiteFemale
#> 4824   Latonya female black    0 BlackFemale
#> 4825  Meredith female white    0 WhiteFemale
#> 4826    Tamika female black    0 BlackFemale
#> 4827      Brad   male white    1   WhiteMale
#> 4828    Kareem   male black    0   BlackMale
#> 4829    Keisha female black    0 BlackFemale
#> 4830   Matthew   male white    1   WhiteMale
#> 4831      Anne female white    0 WhiteFemale
#> 4832     Emily female white    0 WhiteFemale
#> 4833   Lakisha female black    0 BlackFemale
#> 4834    Tamika female black    0 BlackFemale
#> 4835      Brad   male white    0   WhiteMale
#> 4836   Darnell   male black    0   BlackMale
#> 4837      Todd   male white    0   WhiteMale
#> 4838  Tremayne   male black    0   BlackMale
#> 4839   Brendan   male white    0   WhiteMale
#> 4840     Brett   male white    0   WhiteMale
#> 4841     Jamal   male black    0   BlackMale
#> 4842    Kareem   male black    0   BlackMale
#> 4843     Kenya female black    0 BlackFemale
#> 4844   Kristen female white    1 WhiteFemale
#> 4845    Latoya female black    0 BlackFemale
#> 4846    Laurie female white    0 WhiteFemale
#> 4847    Carrie female white    1 WhiteFemale
#> 4848   Kristen female white    1 WhiteFemale
#> 4849   Latonya female black    1 BlackFemale
#> 4850    Tyrone   male black    0   BlackMale
#> 4851     Ebony female black    0 BlackFemale
#> 4852      Jill female white    0 WhiteFemale
#> 4853  Meredith female white    0 WhiteFemale
#> 4854   Tanisha female black    0 BlackFemale
#> 4855  Geoffrey   male white    0   WhiteMale
#> 4856      Greg   male white    0   WhiteMale
#> 4857     Jamal   male black    0   BlackMale
#> 4858    Tamika female black    0 BlackFemale
#> 4859     Jamal   male black    0   BlackMale
#> 4860   Latonya female black    1 BlackFemale
#> 4861   Matthew   male white    0   WhiteMale
#> 4862     Sarah female white    1 WhiteFemale
#> 4863   Allison female white    0 WhiteFemale
#> 4864      Jill female white    0 WhiteFemale
#> 4865   Lakisha female black    0 BlackFemale
#> 4866    Tamika female black    0 BlackFemale
#> 4867     Ebony female black    0 BlackFemale
#> 4868       Jay   male white    0   WhiteMale
#> 4869   Latonya female black    0 BlackFemale
#> 4870    Laurie female white    0 WhiteFemale
```

Since the logic of this is so simple, we can create this variable by 
using `str_c` to combine the vectors of `sex` and `race`, after using `str_to_title` to capitalize them first.

```r
library(stringr)
resume <-
  resume %>%
  mutate(type = str_c(str_to_title(race), str_to_title(sex)))
```

Some of the reasons given for using factors in this chapter are not as important given the functionality in modern **tidyverse** packages.
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

## Causal Affects and the Counterfactual
 
Load the data using the **readr** function 

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

Use a grouped summarize instead of `tapply`,

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

Get the turnout for the control group

```r
gotv_control <-
  (filter(gotv_by_group, messages == "Control"))[["turnout"]]
```

Subtract the control group turnout from all groups


```r
gotv_by_group %>%
  mutate(diff_control = turnout - gotv_control)
#> # A tibble: 4 x 3
#>     messages turnout diff_control
#>        <chr>   <dbl>        <dbl>
#> 1 Civic Duty   0.315       0.0179
#> 2    Control   0.297       0.0000
#> 3  Hawthorne   0.322       0.0257
#> 4  Neighbors   0.378       0.0813
```

We could have also done this in one step like,

```r
gotv_by_group %>%
  mutate(control = mean(turnout[messages == "Control"]),
         control_diff = turnout - control)
#> # A tibble: 4 x 4
#>     messages turnout control control_diff
#>        <chr>   <dbl>   <dbl>        <dbl>
#> 1 Civic Duty   0.315   0.297       0.0179
#> 2    Control   0.297   0.297       0.0000
#> 3  Hawthorne   0.322   0.297       0.0257
#> 4  Neighbors   0.378   0.297       0.0813
```

We can compare the differences of variables across the groups easily using a grouped summarize

```r
gotv_by_group %>%
  mutate(control = mean(turnout[messages == "Control"]),
         control_diff = turnout - control)
#> # A tibble: 4 x 4
#>     messages turnout control control_diff
#>        <chr>   <dbl>   <dbl>        <dbl>
#> 1 Civic Duty   0.315   0.297       0.0179
#> 2    Control   0.297   0.297       0.0000
#> 3  Hawthorne   0.322   0.297       0.0257
#> 4  Neighbors   0.378   0.297       0.0813
```


**Pro-tip** The `summarise_at` functions allows you summarize one-or-more columns with one-or-more functions.
In addition to `age`, 2004 turnout, and household size, we'll also compare proportion female,

```r
social %>%
  group_by(messages) %>%
  mutate(age = 2006 - yearofbirth,
         female = (sex == "female")) %>%
  select(-age, -sex) %>%
  summarise_all(mean)
#> # A tibble: 4 x 6
#>     messages yearofbirth primary2004 primary2006 hhsize female
#>        <chr>       <dbl>       <dbl>       <dbl>  <dbl>  <dbl>
#> 1 Civic Duty        1956       0.399       0.315   2.19  0.500
#> 2    Control        1956       0.400       0.297   2.18  0.499
#> 3  Hawthorne        1956       0.403       0.322   2.18  0.499
#> 4  Neighbors        1956       0.407       0.378   2.19  0.500
```

## Observational Studies

Load the `minwage` dataset from its URL using `readr::read_csv`:

```r
minwage_url <- "https://raw.githubusercontent.com/kosukeimai/qss/master/CAUSALITY/minwage.csv"
minwage <- read_csv(minwage_url)
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

We can extract the state from the final two characters of the location variable using the **stringr** function `str_sub` (R4DS Ch 14: Strings):

```r
library(stringr)
minwage <-
  mutate(minwage, state = str_sub(location, -2L))
```
Alternatively, since everything is either PA or NJ

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
minwage <-
  minwage %>%
  mutate(totalAfter = fullAfter + partAfter,
        fullPropAfter = fullAfter / totalAfter)
```

Now calculate the average for each state:

```r
full_prop_by_state <-
  minwage %>%
  group_by(state) %>%
  summarise(fullPropAfter = mean(fullPropAfter))
full_prop_by_state
#> # A tibble: 2 x 2
#>   state fullPropAfter
#>   <chr>         <dbl>
#> 1    NJ         0.320
#> 2    PA         0.272
```

We could compute the difference by  

```r
(filter(full_prop_by_state, state == "NJ")[["fullPropAfter"]] - 
  filter(full_prop_by_state, state == "PA")[["fullPropAfter"]])
#> [1] 0.0481
```
or using **tidyr** functions `spread` (R4DS Ch 11: Tidy Data):

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

We can easily compare these using a simple dot-plot:

```r
ggplot(chains_by_state, aes(x = chain, y = prop, colour = state)) +
  geom_point() + 
  coord_flip()
```

<img src="causality_files/figure-html/unnamed-chunk-43-1.png" width="70%" style="display: block; margin: auto;" />

In the QSS text, only Burger King restaurants are compared. 
However, **dplyr** makes this easy.
All we have to do is change the `group_by` statement we used last time,
and add chain to it:


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

<img src="causality_files/figure-html/unnamed-chunk-45-1.png" width="70%" style="display: block; margin: auto;" />

To calculate the differences, we need to get the data frame 

1. The join method.

   1. Create New Jersey and Pennsylvania data sets with `chain` and prop full employed columns.
   2. Merge the two data sets on `chain`.
   

```r
chains_nj <- full_prop_by_state_chain %>%
  ungroup() %>%
  filter(state == "NJ") %>%
  select(-state) %>%
  rename(NJ = fullPropAfter)
chains_pa <- full_prop_by_state_chain %>%
  ungroup() %>%
  filter(state == "PA") %>%
  select(-state) %>%
  rename(PA = fullPropAfter)

full_prop_state_chain_diff <- 
  full_join(chains_nj, chains_pa, by = "chain") %>%
  mutate(diff = NJ - PA)
full_prop_state_chain_diff
#> # A tibble: 4 x 4
#>        chain    NJ    PA   diff
#>        <chr> <dbl> <dbl>  <dbl>
#> 1 burgerking 0.358 0.321 0.0364
#> 2        kfc 0.328 0.236 0.0918
#> 3       roys 0.283 0.213 0.0697
#> 4     wendys 0.260 0.248 0.0117
```

Q: In the code above why did I remove the `state` variable and rename the `fullPropAfter` variable before merging? What happens if I didn't?

2. The spread/gather method. We can also use the `spread` and `gather` functions from **tidyr**. In this example it is much more compact code.


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
#> # A tibble: 1 x 1
#>     diff
#>    <dbl>
#> 1 0.0239
```

The difference-in-differences design uses the difference in the before-and-after differences for each state.

```r
diff_by_state <-
  minwage %>%
  group_by(state) %>%
  summarise(diff = mean(fullPropAfter) - mean(fullPropBefore))

filter(diff_by_state, state == "NJ")[["diff"]] -
  filter(diff_by_state, state == "PA")[["diff"]]
#> [1] 0.0616
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

<img src="causality_files/figure-html/unnamed-chunk-52-1.png" width="70%" style="display: block; margin: auto;" />



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

We calculate the IQR for each state's wages after the passage of the law using the same grouped summarize as we used before:

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
or, more compactly, using `summarise_at`:

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

