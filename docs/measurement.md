
# Measurement

## Prerequisites


```r
library("tidyverse")
library("forcats")
library("broom")
library("tidyr")
```

## Measuring Civilian Victimization during Wartime


```r
data("afghan", package = "qss")
```

Summarize the variables of interest

```r
afghan %>%
  select(age, educ.years, employed, income) %>%
  summary()
#>       age         educ.years    employed        income         
#>  Min.   :15.0   Min.   : 0   Min.   :0.000   Length:2754       
#>  1st Qu.:22.0   1st Qu.: 0   1st Qu.:0.000   Class :character  
#>  Median :30.0   Median : 1   Median :1.000   Mode  :character  
#>  Mean   :32.4   Mean   : 4   Mean   :0.583                     
#>  3rd Qu.:40.0   3rd Qu.: 8   3rd Qu.:1.000                     
#>  Max.   :80.0   Max.   :18   Max.   :1.000
```

With `income`,  never converts strings to factors by default.
To get a summary of the different levels, either convert it to a factor (R4DS Ch 15), or use `count()`

```r
afghan %>%
  count(income)
#> # A tibble: 6 x 2
#>            income     n
#>             <chr> <int>
#> 1   10,001-20,000   616
#> 2    2,001-10,000  1420
#> 3   20,001-30,000    93
#> 4 less than 2,000   457
#> 5     over 30,000    14
#> 6            <NA>   154
```

Count the number a proportion of respondents who answer that they were harmed by the ISF (`violent.exp.ISAF`) and (`violent.exp.taliban`) respectively,

```r
afghan %>%
  group_by(violent.exp.ISAF, violent.exp.taliban) %>%
  count() %>%
  ungroup() %>%
  mutate(prop = n / sum(n))
#> # A tibble: 9 x 4
#>   violent.exp.ISAF violent.exp.taliban     n    prop
#>              <int>               <int> <int>   <dbl>
#> 1                0                   0  1330 0.48293
#> 2                0                   1   354 0.12854
#> 3                0                  NA    22 0.00799
#> 4                1                   0   475 0.17248
#> 5                1                   1   526 0.19099
#> 6                1                  NA    22 0.00799
#> # ... with 3 more rows
```
We need to use `ungroup()` in order to ensure that `sum(n)` sums over the entire
dataset as opposed to only within categories of `violent.exp.ISAF`.


Unlike `prop.table`, the code above does not drop missing values.
We can drop those values by adding a `filter` verb and using `!is.na()` to test
for missing values in those variables:

```r
afghan %>%
  filter(!is.na(violent.exp.ISAF), !is.na(violent.exp.taliban)) %>%
  group_by(violent.exp.ISAF, violent.exp.taliban) %>%
  count() %>%
  ungroup() %>%
  mutate(prop = n / sum(n))
#> # A tibble: 4 x 4
#>   violent.exp.ISAF violent.exp.taliban     n  prop
#>              <int>               <int> <int> <dbl>
#> 1                0                   0  1330 0.495
#> 2                0                   1   354 0.132
#> 3                1                   0   475 0.177
#> 4                1                   1   526 0.196
```

### Handling Missing Data in R

We already observed the issues with `NA` values in calculating the proportion
answering the "experienced violence" questions.

You can filter rows with specific variables having missing values using `filter`
as shown above.

However, `na.omit` works with tibbles just like any other data frame.

```r
na.omit(afghan)
#>      province       district village.id age educ.years employed
#> 1       Logar   Baraki Barak         80  26         10        0
#> 2       Logar   Baraki Barak         80  49          3        1
#> 3       Logar   Baraki Barak         80  60          0        1
#> 4       Logar   Baraki Barak         80  34         14        1
#> 5       Logar   Baraki Barak         80  21         12        1
#> 7       Logar   Baraki Barak         80  42          6        1
#> 8       Logar   Baraki Barak         80  39         12        1
#> 9       Logar   Baraki Barak         80  20          5        1
#> 11      Logar   Baraki Barak         35  33         11        1
#> 12      Logar   Baraki Barak         35  59          0        1
#> 13      Logar   Baraki Barak         35  18          7        1
#> 14      Logar   Baraki Barak         35  36          4        1
#> 15      Logar   Baraki Barak         35  40          8        1
#> 16      Logar   Baraki Barak         35  50         12        1
#> 17      Logar   Baraki Barak         35  30          2        1
#> 18      Logar   Baraki Barak         35  50          0        1
#> 19      Logar   Baraki Barak        121  35         12        1
#> 20      Logar   Baraki Barak        121  37          8        1
#> 21      Logar   Baraki Barak        121  31         12        1
#> 22      Logar   Baraki Barak        121  60         12        1
#> 23      Logar   Baraki Barak        121  35          6        0
#> 24      Logar   Baraki Barak        121  48          0        0
#> 25      Logar   Baraki Barak        121  33         12        1
#> 26      Logar   Baraki Barak        121  44         12        1
#> 27      Logar   Baraki Barak        121  53          6        1
#> 28      Logar   Baraki Barak         12  32          6        1
#> 29      Logar   Baraki Barak         12  36          8        1
#> 30      Logar   Baraki Barak         12  38          6        1
#> 31      Logar   Baraki Barak         12  39          3        1
#> 32      Logar   Baraki Barak         12  43         10        1
#> 33      Logar   Baraki Barak         12  20          3        1
#> 34      Logar   Baraki Barak         12  71         12        0
#> 35      Logar   Baraki Barak         12  63          8        1
#> 36      Logar   Baraki Barak         12  33          0        1
#> 37      Logar   Baraki Barak         97  21          2        1
#> 38      Logar   Baraki Barak         97  17          8        0
#> 39      Logar   Baraki Barak         97  30          0        0
#> 40      Logar   Baraki Barak         97  17          6        0
#> 41      Logar   Baraki Barak         97  40         12        1
#> 42      Logar   Baraki Barak         97  20         10        0
#> 43      Logar   Baraki Barak         97  18          9        0
#> 44      Logar   Baraki Barak         97  22         12        1
#> 45      Logar   Baraki Barak         97  52          0        1
#> 46      Logar   Baraki Barak        154  49          3        1
#> 47      Logar   Baraki Barak        154  55          6        0
#> 48      Logar   Baraki Barak        154  27         10        1
#> 50      Logar   Baraki Barak        154  42          4        1
#> 51      Logar   Baraki Barak        154  66          0        0
#> 52      Logar   Baraki Barak        154  38         12        1
#> 53      Logar   Baraki Barak        154  25          0        1
#> 54      Logar   Baraki Barak        154  24         10        1
#> 55      Logar   Baraki Barak         99  18          6        0
#> 56      Logar   Baraki Barak         99  24         10        1
#> 57      Logar   Baraki Barak         99  56          0        1
#> 58      Logar   Baraki Barak         99  32         12        1
#> 59      Logar   Baraki Barak         99  27          9        0
#> 60      Logar   Baraki Barak         99  33         12        1
#> 61      Logar   Baraki Barak         99  66          0        0
#> 62      Logar   Baraki Barak         99  43         12        1
#> 63      Logar   Baraki Barak         99  34          0        0
#> 64      Logar   Baraki Barak        170  29          9        1
#> 65      Logar   Baraki Barak        170  43          5        1
#> 66      Logar   Baraki Barak        170  33         14        1
#> 67      Logar   Baraki Barak        170  22          7        0
#> 68      Logar   Baraki Barak        170  73          5        0
#> 69      Logar   Baraki Barak        170  27         10        1
#> 70      Logar   Baraki Barak        170  37          8        1
#> 71      Logar   Baraki Barak        170  18          3        0
#> 72      Logar   Baraki Barak        170  40          9        1
#> 73      Logar   Baraki Barak        100  26         11        1
#> 74      Logar   Baraki Barak        100  22         12        0
#> 75      Logar   Baraki Barak        100  36          4        1
#> 76      Logar   Baraki Barak        100  29         14        1
#> 77      Logar   Baraki Barak        100  18          6        0
#> 78      Logar   Baraki Barak        100  41         10        1
#> 79      Logar   Baraki Barak        100  30         14        1
#> 80      Logar   Baraki Barak        100  73          4        0
#> 81      Logar   Baraki Barak        100  19          0        1
#> 82      Logar   Baraki Barak         87  49          9        1
#> 84      Logar   Baraki Barak         87  36         12        1
#> 85      Logar   Baraki Barak         87  42          0        1
#> 86      Logar   Baraki Barak         87  63          0        1
#> 87      Logar   Baraki Barak         87  20          7        0
#> 88      Logar   Baraki Barak         87  53         12        1
#> 89      Logar   Baraki Barak         87  40         10        1
#> 90      Logar   Baraki Barak         87  27          4        0
#> 91      Logar   Baraki Barak         46  62          6        0
#> 92      Logar   Baraki Barak         46  31          4        1
#> 93      Logar   Baraki Barak         46  21          9        0
#> 94      Logar   Baraki Barak         46  53         12        1
#> 95      Logar   Baraki Barak         46  25          0        1
#> 96      Logar   Baraki Barak         46  49          6        1
#> 97      Logar   Baraki Barak         46  31          0        0
#> 98      Logar   Baraki Barak         46  40         10        1
#> 99      Logar   Baraki Barak         46  23         14        1
#> 100     Logar   Baraki Barak         46  18          0        0
#> 101     Logar   Baraki Barak         46  73         12        0
#> 102     Logar   Baraki Barak         46  29          2        1
#> 103     Logar   Baraki Barak         46  32          8        1
#> 104     Logar   Baraki Barak         46  55         12        1
#> 105     Logar   Baraki Barak         46  47         10        1
#> 106     Logar   Baraki Barak         46  38          7        1
#> 107     Logar   Baraki Barak         46  39          6        1
#> 108     Logar   Baraki Barak         46  55          6        1
#> 109     Logar   Baraki Barak        102  22         12        1
#> 110     Logar   Baraki Barak        102  35          6        1
#> 111     Logar   Baraki Barak        102  70          8        1
#> 112     Logar   Baraki Barak        102  37          8        0
#> 113     Logar   Baraki Barak        102  24         12        1
#> 114     Logar   Baraki Barak        102  40          6        1
#> 115     Logar   Baraki Barak        102  39         12        1
#> 116     Logar   Baraki Barak        102  25         12        1
#> 117     Logar   Baraki Barak        102  45         12        1
#> 118     Logar   Baraki Barak        102  33          9        1
#> 120     Logar   Baraki Barak        102  73          7        1
#> 121     Logar   Baraki Barak        102  72         12        1
#> 122     Logar   Baraki Barak        102  51          3        1
#> 123     Logar   Baraki Barak        102  24         12        1
#> 124     Logar   Baraki Barak        102  31          6        1
#> 125     Logar   Baraki Barak        102  40         11        1
#> 126     Logar   Baraki Barak        102  30         10        1
#> 127     Logar   Baraki Barak        101  18          3        0
#> 128     Logar   Baraki Barak        101  29          2        1
#> 129     Logar   Baraki Barak        101  21         12        1
#> 130     Logar   Baraki Barak        101  61          6        1
#> 131     Logar   Baraki Barak        101  60         12        1
#> 132     Logar   Baraki Barak        101  23         14        1
#> 133     Logar   Baraki Barak        101  50          0        1
#> 134     Logar   Baraki Barak        101  55          2        1
#> 135     Logar   Baraki Barak        101  33         12        1
#> 136     Logar   Baraki Barak        101  33         14        1
#> 137     Logar   Baraki Barak        101  41         12        1
#> 138     Logar   Baraki Barak        101  71          2        1
#> 139     Logar   Baraki Barak        101  28          2        1
#> 140     Logar   Baraki Barak        101  36          2        1
#> 141     Logar   Baraki Barak        101  50          8        1
#> 142     Logar   Baraki Barak        101  37          8        1
#> 143     Logar   Baraki Barak        101  60          3        1
#> 144     Logar   Baraki Barak        101  45         12        1
#> 145     Logar   Baraki Barak         20  20         12        0
#> 146     Logar   Baraki Barak         20  18          0        1
#> 147     Logar   Baraki Barak         20  19          0        1
#> 148     Logar   Baraki Barak         20  24         10        1
#> 149     Logar   Baraki Barak         20  33         12        1
#> 150     Logar   Baraki Barak         20  52         12        1
#> 151     Logar   Baraki Barak         20  50         10        1
#> 152     Logar   Baraki Barak         20  19          6        1
#> 153     Logar   Baraki Barak         20  47         12        1
#> 154     Logar   Baraki Barak         20  30          0        1
#> 155     Logar   Baraki Barak         20  51         12        1
#> 156     Logar   Baraki Barak         20  42         12        1
#> 157     Logar   Baraki Barak         20  59         12        1
#> 158     Logar   Baraki Barak         20  30          0        1
#> 159     Logar   Baraki Barak         20  62          5        1
#> 160     Logar   Baraki Barak         20  59          0        1
#> 161     Logar   Baraki Barak         20  41          8        1
#> 162     Logar   Baraki Barak         20  25         12        1
#> 163     Logar   Baraki Barak        130  43         12        1
#> 164     Logar   Baraki Barak        130  29          6        0
#> 165     Logar   Baraki Barak        130  32         11        1
#> 166     Logar   Baraki Barak        130  50         10        1
#> 167     Logar   Baraki Barak        130  20          3        1
#> 169     Logar   Baraki Barak        130  48         12        1
#> 170     Logar   Baraki Barak        130  26         12        1
#> 171     Logar   Baraki Barak        130  42          7        1
#> 172     Logar   Baraki Barak        130  22         14        1
#> 173     Logar   Baraki Barak        130  68          3        0
#> 174     Logar   Baraki Barak        130  36         12        1
#> 175     Logar   Baraki Barak        130  45          8        1
#> 177     Logar   Baraki Barak        130  33          9        1
#> 178     Logar   Baraki Barak        130  55          0        1
#> 179     Logar   Baraki Barak        130  41          4        1
#> 180     Logar   Baraki Barak        130  47          0        1
#> 181     Logar         Khoshi        137  53          0        0
#> 182     Logar         Khoshi        137  42          0        1
#> 183     Logar         Khoshi        137  32          7        1
#> 184     Logar         Khoshi        137  27          6        1
#> 185     Logar         Khoshi        137  40         12        0
#> 186     Logar         Khoshi        137  61          3        1
#> 187     Logar         Khoshi        137  19          3        1
#> 188     Logar         Khoshi        137  16          0        1
#> 189     Logar         Khoshi        137  23          4        1
#> 190     Logar         Khoshi         24  25          8        0
#> 191     Logar         Khoshi         24  22         12        1
#> 192     Logar         Khoshi         24  27          0        0
#> 193     Logar         Khoshi         24  30          0        0
#> 194     Logar         Khoshi         24  50          0        1
#> 195     Logar         Khoshi         24  21          0        1
#> 196     Logar         Khoshi         24  19          6        1
#> 197     Logar         Khoshi         24  70          0        0
#> 198     Logar         Khoshi         24  40         12        1
#> 199     Logar         Khoshi         29  38          8        1
#> 200     Logar         Khoshi         29  32         14        1
#> 201     Logar         Khoshi         29  18          5        0
#> 202     Logar         Khoshi         29  41          9        1
#> 203     Logar         Khoshi         29  59          0        0
#> 204     Logar         Khoshi         29  67         11        0
#> 205     Logar         Khoshi         29  24         16        1
#> 206     Logar         Khoshi         29  46         10        1
#> 207     Logar         Khoshi         29  52          2        1
#> 208     Logar         Khoshi        182  75          6        0
#> 209     Logar         Khoshi        182  25          2        1
#> 210     Logar         Khoshi        182  19         10        0
#> 211     Logar         Khoshi        182  45         12        1
#> 212     Logar         Khoshi        182  22          0        1
#> 213     Logar         Khoshi        182  21          6        0
#> 214     Logar         Khoshi        182  40          7        1
#> 215     Logar         Khoshi        182  24          2        0
#> 216     Logar         Khoshi        182  23          0        0
#> 217     Logar         Khoshi        187  30          0        1
#> 218     Logar         Khoshi        187  27          0        1
#> 219     Logar         Khoshi        187  23          6        1
#> 220     Logar         Khoshi        187  63          4        0
#> 221     Logar         Khoshi        187  42          7        1
#> 222     Logar         Khoshi        187  30         10        1
#> 223     Logar         Khoshi        187  20          5        0
#> 224     Logar         Khoshi        187  25         10        1
#> 226     Logar         Khoshi        187  38          2        1
#> 227     Logar         Khoshi        187  43         11        1
#> 228     Logar         Khoshi        187  27         10        0
#> 229     Logar         Khoshi        187  18          4        1
#> 230     Logar         Khoshi        187  28         12        1
#> 231     Logar         Khoshi        187  60          0        1
#> 232     Logar         Khoshi        187  21         12        1
#> 233     Logar         Khoshi        187  43          6        1
#> 234     Logar         Khoshi        187  25          0        1
#> 235     Logar      Puli Alam         75  30          7        1
#> 236     Logar      Puli Alam         75  28         12        1
#> 237     Logar      Puli Alam         75  59         16        1
#> 238     Logar      Puli Alam         75  23          0        1
#> 239     Logar      Puli Alam         75  50          4        1
#> 240     Logar      Puli Alam         75  56         14        1
#> 241     Logar      Puli Alam         75  38         10        1
#> 242     Logar      Puli Alam         75  17          2        0
#> 243     Logar      Puli Alam         75  41          0        0
#> 245     Logar      Puli Alam         50  23          9        1
#> 246     Logar      Puli Alam         50  34          0        1
#> 247     Logar      Puli Alam         50  42         14        1
#> 248     Logar      Puli Alam         50  58          0        1
#> 250     Logar      Puli Alam         50  39         12        1
#> 251     Logar      Puli Alam         50  24          9        1
#> 253     Logar      Puli Alam         41  23          0        1
#> 254     Logar      Puli Alam         41  18          0        0
#> 255     Logar      Puli Alam         41  22         12        0
#> 256     Logar      Puli Alam         41  35          0        1
#> 257     Logar      Puli Alam         41  24         11        0
#> 258     Logar      Puli Alam         41  22          0        0
#> 259     Logar      Puli Alam         41  24          0        0
#> 260     Logar      Puli Alam         41  35         14        0
#> 261     Logar      Puli Alam         41  28         12        1
#> 262     Logar      Puli Alam        134  47          3        1
#> 263     Logar      Puli Alam        134  35         10        1
#> 264     Logar      Puli Alam        134  72          2        0
#> 265     Logar      Puli Alam        134  58          8        0
#> 266     Logar      Puli Alam        134  53          9        1
#> 267     Logar      Puli Alam        134  43         16        1
#> 268     Logar      Puli Alam        134  27         12        1
#> 269     Logar      Puli Alam        134  26          0        1
#> 270     Logar      Puli Alam        134  62         10        1
#> 271     Logar      Puli Alam        181  33          6        1
#> 272     Logar      Puli Alam        181  44          0        1
#> 273     Logar      Puli Alam        181  59         12        1
#> 274     Logar      Puli Alam        181  25          0        1
#> 276     Logar      Puli Alam        181  34         12        1
#> 277     Logar      Puli Alam        181  40          9        1
#> 278     Logar      Puli Alam        181  58         11        0
#> 279     Logar      Puli Alam        181  23         12        0
#> 280     Logar      Puli Alam        202  27         16        1
#> 281     Logar      Puli Alam        202  30          6        1
#> 282     Logar      Puli Alam        202  27          0        1
#> 283     Logar      Puli Alam        202  26         11        1
#> 284     Logar      Puli Alam        202  33          3        1
#> 285     Logar      Puli Alam        202  43         12        1
#> 286     Logar      Puli Alam        202  30          8        1
#> 287     Logar      Puli Alam        202  24          6        1
#> 288     Logar      Puli Alam        202  18          8        1
#> 289     Logar      Puli Alam        172  22         10        0
#> 290     Logar      Puli Alam        172  44          5        1
#> 291     Logar      Puli Alam        172  21          5        0
#> 292     Logar      Puli Alam        172  35          7        1
#> 293     Logar      Puli Alam        172  47          0        1
#> 294     Logar      Puli Alam        172  29         10        1
#> 295     Logar      Puli Alam        172  18          0        0
#> 296     Logar      Puli Alam        172  24         12        0
#> 297     Logar      Puli Alam        172  46         11        1
#> 298     Logar      Puli Alam        127  31          6        1
#> 299     Logar      Puli Alam        127  19          9        0
#> 300     Logar      Puli Alam        127  42         14        1
#> 301     Logar      Puli Alam        127  20          2        1
#> 302     Logar      Puli Alam        127  45          0        1
#> 303     Logar      Puli Alam        127  55          7        1
#> 304     Logar      Puli Alam        127  28         12        1
#> 305     Logar      Puli Alam        127  26          5        0
#> 306     Logar      Puli Alam        127  37         10        1
#> 307     Logar      Puli Alam         72  25          0        1
#> 308     Logar      Puli Alam         72  59         12        0
#> 309     Logar      Puli Alam         72  18          0        0
#> 310     Logar      Puli Alam         72  37          0        1
#> 311     Logar      Puli Alam         72  22         10        1
#> 312     Logar      Puli Alam         72  26          0        1
#> 313     Logar      Puli Alam         72  23          9        0
#> 314     Logar      Puli Alam         72  37          0        0
#> 315     Logar      Puli Alam         72  26          0        1
#> 316     Logar      Puli Alam        111  50         14        0
#> 317     Logar      Puli Alam        111  26          0        1
#> 318     Logar      Puli Alam        111  55          8        1
#> 319     Logar      Puli Alam        111  17          0        0
#> 320     Logar      Puli Alam        111  35         10        0
#> 321     Logar      Puli Alam        111  50         12        0
#> 322     Logar      Puli Alam        111  22         12        0
#> 323     Logar      Puli Alam        111  20          0        0
#> 324     Logar      Puli Alam        111  58         14        1
#> 325     Logar      Puli Alam         30  24          9        0
#> 326     Logar      Puli Alam         30  45          2        1
#> 327     Logar      Puli Alam         30  38          8        1
#> 328     Logar      Puli Alam         30  18         12        1
#> 329     Logar      Puli Alam         30  27          0        0
#> 330     Logar      Puli Alam         30  30          7        1
#> 331     Logar      Puli Alam         30  35          3        1
#> 332     Logar      Puli Alam         30  22         12        1
#> 333     Logar      Puli Alam         30  20          6        0
#> 334     Logar      Puli Alam         34  27          6        1
#> 335     Logar      Puli Alam         34  29          3        1
#> 336     Logar      Puli Alam         34  47          0        1
#> 337     Logar      Puli Alam         34  47          9        1
#> 338     Logar      Puli Alam         34  30         16        1
#> 339     Logar      Puli Alam         34  18          6        0
#> 340     Logar      Puli Alam         34  35          7        1
#> 341     Logar      Puli Alam         34  19          0        0
#> 342     Logar      Puli Alam         34  43         10        1
#> 343     Logar      Puli Alam        192  25          6        1
#> 344     Logar      Puli Alam        192  29          9        1
#> 345     Logar      Puli Alam        192  18          4        0
#> 346     Logar      Puli Alam        192  22         12        1
#> 348     Logar      Puli Alam        192  33         14        1
#> 349     Logar      Puli Alam        192  24          0        1
#> 350     Logar      Puli Alam        192  46          3        1
#> 351     Logar      Puli Alam        192  55          0        1
#> 352     Logar      Puli Alam        192  55          2        1
#> 354     Logar      Puli Alam        192  42         12        1
#> 355     Logar      Puli Alam        192  31          0        1
#> 356     Logar      Puli Alam        192  48          3        1
#> 357     Logar      Puli Alam        192  53          0        1
#> 358     Logar      Puli Alam        192  49         10        1
#> 360     Logar      Puli Alam        192  37          0        0
#> 361     Logar      Puli Alam         98  21         12        0
#> 362     Logar      Puli Alam         98  32          6        1
#> 363     Logar      Puli Alam         98  41          0        1
#> 364     Logar      Puli Alam         98  51         10        0
#> 365     Logar      Puli Alam         98  67          0        0
#> 366     Logar      Puli Alam         98  47         10        1
#> 367     Logar      Puli Alam         98  33          9        1
#> 368     Logar      Puli Alam         98  56          7        1
#> 369     Logar      Puli Alam         98  18          9        0
#> 370     Logar      Puli Alam         98  36          3        1
#> 371     Logar      Puli Alam         98  35          0        1
#> 373     Logar      Puli Alam         98  26         10        1
#> 374     Logar      Puli Alam         98  62          0        1
#> 375     Logar      Puli Alam         98  36         12        1
#> 376     Logar      Puli Alam         98  37         11        1
#> 377     Logar      Puli Alam         98  20          7        0
#> 378     Logar      Puli Alam         98  53          0        1
#> 380     Logar      Puli Alam        126  16          9        0
#> 381     Logar      Puli Alam        126  42          0        0
#> 382     Logar      Puli Alam        126  29          7        0
#> 383     Logar      Puli Alam        126  33         12        1
#> 384     Logar      Puli Alam        126  28         10        1
#> 385     Logar      Puli Alam        126  18         10        0
#> 386     Logar      Puli Alam        126  43          0        1
#> 387     Logar      Puli Alam        126  21          9        1
#> 388     Logar      Puli Alam        126  32          0        1
#> 389     Logar      Puli Alam        126  21         10        0
#> 390     Logar      Puli Alam        126  21         11        0
#> 391     Logar      Puli Alam        126  48          0        0
#> 392     Logar      Puli Alam        126  39          0        1
#> 393     Logar      Puli Alam        126  25         14        1
#> 394     Logar      Puli Alam        126  29          4        1
#> 395     Logar      Puli Alam        126  49         12        1
#> 396     Logar      Puli Alam        126  44          0        1
#> 397     Logar      Puli Alam         85  33         10        1
#> 398     Logar      Puli Alam         85  36          9        1
#> 399     Logar      Puli Alam         85  50          5        1
#> 400     Logar      Puli Alam         85  28          3        0
#> 401     Logar      Puli Alam         85  36         16        1
#> 402     Logar      Puli Alam         85  27          5        1
#> 403     Logar      Puli Alam         85  49          8        1
#> 404     Logar      Puli Alam         85  29          0        0
#> 405     Logar      Puli Alam         85  30          9        1
#> 406     Logar      Puli Alam         85  25          7        1
#> 407     Logar      Puli Alam         85  21          4        0
#> 408     Logar      Puli Alam         85  66          0        0
#> 409     Logar      Puli Alam         85  61          3        1
#> 410     Logar      Puli Alam         85  40         10        1
#> 411     Logar      Puli Alam         85  52          5        1
#> 412     Logar      Puli Alam         85  28         11        1
#> 413     Logar      Puli Alam         85  44         12        1
#> 415     Logar      Puli Alam         82  42          3        1
#> 416     Logar      Puli Alam         82  22          6        1
#> 418     Logar      Puli Alam         82  32          3        1
#> 419     Logar      Puli Alam         82  27          9        1
#> 421     Logar      Puli Alam         82  33         14        1
#> 422     Logar      Puli Alam         82  22          5        0
#> 423     Logar      Puli Alam         82  30          7        1
#> 424     Logar      Puli Alam         82  44         12        1
#> 425     Logar      Puli Alam         82  28          0        1
#> 426     Logar      Puli Alam         82  27          2        1
#> 427     Logar      Puli Alam         82  20          8        0
#> 428     Logar      Puli Alam         82  47          3        1
#> 429     Logar      Puli Alam         82  28         16        1
#> 430     Logar      Puli Alam         82  50          0        1
#> 431     Logar      Puli Alam         82  39          2        0
#> 432     Logar      Puli Alam         82  39         10        1
#> 433     Logar      Puli Alam        162  47         12        1
#> 434     Logar      Puli Alam        162  58          0        0
#> 435     Logar      Puli Alam        162  43          4        1
#> 436     Logar      Puli Alam        162  33          2        0
#> 438     Logar      Puli Alam        162  67          5        0
#> 439     Logar      Puli Alam        162  20          0        1
#> 440     Logar      Puli Alam        162  19          6        0
#> 441     Logar      Puli Alam        162  38          3        1
#> 442     Logar      Puli Alam        162  44         12        1
#> 443     Logar      Puli Alam        162  30          8        1
#> 444     Logar      Puli Alam        162  51         10        1
#> 445     Logar      Puli Alam        162  24          0        0
#> 446     Logar      Puli Alam        162  31         12        1
#> 447     Logar      Puli Alam        162  45          0        1
#> 448     Logar      Puli Alam        162  53          7        1
#> 449     Logar      Puli Alam        162  29          9        1
#> 450     Logar      Puli Alam        162  21          3        1
#> 451     Logar      Puli Alam        136  47          6        1
#> 452     Logar      Puli Alam        136  26          9        1
#> 453     Logar      Puli Alam        136  31          0        1
#> 454     Logar      Puli Alam        136  38         12        1
#> 455     Logar      Puli Alam        136  21          6        1
#> 456     Logar      Puli Alam        136  28          0        1
#> 457     Logar      Puli Alam        136  33          0        1
#> 458     Logar      Puli Alam        136  45          9        1
#> 460     Logar      Puli Alam        136  63          6        1
#> 461     Logar      Puli Alam        136  36         12        1
#> 462     Logar      Puli Alam        136  46         12        1
#> 463     Logar      Puli Alam        136  19          9        0
#> 465     Logar      Puli Alam        136  31         12        1
#> 466     Logar      Puli Alam        136  29          6        1
#> 467     Logar      Puli Alam        136  29          6        1
#> 468     Logar      Puli Alam        136  37          0        0
#> 469     Logar      Puli Alam         90  18          4        0
#> 470     Logar      Puli Alam         90  49          6        1
#> 471     Logar      Puli Alam         90  41         10        1
#> 472     Logar      Puli Alam         90  32         12        1
#> 473     Logar      Puli Alam         90  24          9        1
#> 474     Logar      Puli Alam         90  18          0        0
#> 475     Logar      Puli Alam         90  23         10        1
#> 476     Logar      Puli Alam         90  25         18        1
#> 477     Logar      Puli Alam         90  62          2        1
#> 478     Logar      Puli Alam         90  56         12        1
#> 479     Logar      Puli Alam         90  19          0        0
#> 480     Logar      Puli Alam         90  33         10        1
#> 481     Logar      Puli Alam         90  44          6        1
#> 482     Logar      Puli Alam         90  53          7        1
#> 483     Logar      Puli Alam         90  20          6        1
#> 484     Logar      Puli Alam         90  41         18        1
#> 485     Logar      Puli Alam         90  26          8        1
#> 486     Logar      Puli Alam         90  19          6        0
#> 487     Kunar       Asadabad        120  22          6        0
#> 488     Kunar       Asadabad        120  24          0        1
#> 489     Kunar       Asadabad        120  27         12        1
#> 490     Kunar       Asadabad        120  20         10        0
#> 491     Kunar       Asadabad        120  24         12        1
#> 492     Kunar       Asadabad        120  27         12        0
#> 493     Kunar       Asadabad        120  18         10        0
#> 494     Kunar       Asadabad        120  25          0        1
#> 495     Kunar       Asadabad        120  35          0        0
#> 496     Kunar       Asadabad        120  21         12        0
#> 497     Kunar       Asadabad        120  28         12        0
#> 498     Kunar       Asadabad        120  25         12        1
#> 499     Kunar       Asadabad        120  25          0        0
#> 500     Kunar       Asadabad        120  29          7        0
#> 501     Kunar       Asadabad        120  25         14        1
#> 502     Kunar       Asadabad        120  27         12        0
#> 503     Kunar       Asadabad        120  30          0        0
#> 504     Kunar       Asadabad        120  20         12        0
#> 505     Kunar       Asadabad        110  43         12        0
#> 506     Kunar       Asadabad        110  52         14        0
#> 507     Kunar       Asadabad        110  25         12        0
#> 508     Kunar       Asadabad        110  41          6        1
#> 509     Kunar       Asadabad        110  17          6        0
#> 510     Kunar       Asadabad        110  21          8        0
#> 511     Kunar       Asadabad        110  44         14        0
#> 512     Kunar       Asadabad        110  35         12        1
#> 513     Kunar       Asadabad        110  23          6        0
#> 514     Kunar       Asadabad        110  40         12        0
#> 515     Kunar       Asadabad        110  55          0        0
#> 516     Kunar       Asadabad        110  35         10        1
#> 517     Kunar       Asadabad        110  23         14        0
#> 518     Kunar       Asadabad        110  30          0        0
#> 519     Kunar       Asadabad        110  23         12        0
#> 520     Kunar       Asadabad        110  32          0        1
#> 521     Kunar       Asadabad        110  43         12        1
#> 522     Kunar       Asadabad        110  16          6        0
#> 523     Kunar       Asadabad         86  17         10        0
#> 524     Kunar       Asadabad         86  43          0        1
#> 525     Kunar       Asadabad         86  21          8        0
#> 526     Kunar       Asadabad         86  32         12        0
#> 527     Kunar       Asadabad         86  18          9        0
#> 528     Kunar       Asadabad         86  17         12        0
#> 529     Kunar       Asadabad         86  16          0        0
#> 530     Kunar       Asadabad         86  25          8        0
#> 531     Kunar       Asadabad         86  35          0        0
#> 532     Kunar       Asadabad         86  16         10        0
#> 533     Kunar       Asadabad         86  21          0        1
#> 534     Kunar       Asadabad         86  19          0        0
#> 535     Kunar       Asadabad         86  34          9        0
#> 536     Kunar       Asadabad         86  25          0        0
#> 537     Kunar       Asadabad         86  29         11        1
#> 538     Kunar       Asadabad         86  26          0        0
#> 539     Kunar       Asadabad         86  19          0        0
#> 540     Kunar       Asadabad         86  32          0        1
#> 541     Kunar     Chapa Dara         94  40         10        0
#> 542     Kunar     Chapa Dara         94  35          6        0
#> 543     Kunar     Chapa Dara         94  28         12        0
#> 544     Kunar     Chapa Dara         94  25          0        1
#> 545     Kunar     Chapa Dara         94  50         12        1
#> 546     Kunar     Chapa Dara         94  35         11        1
#> 547     Kunar     Chapa Dara         94  30         13        1
#> 548     Kunar     Chapa Dara         94  25          0        0
#> 549     Kunar     Chapa Dara         94  30         12        0
#> 550     Kunar     Chapa Dara         45  36          0        0
#> 551     Kunar     Chapa Dara         45  39          8        0
#> 552     Kunar     Chapa Dara         45  25          0        0
#> 553     Kunar     Chapa Dara         45  30         10        0
#> 554     Kunar     Chapa Dara         45  35          0        0
#> 555     Kunar     Chapa Dara         45  62         12        0
#> 556     Kunar     Chapa Dara         45  45          0        1
#> 557     Kunar     Chapa Dara         45  54          0        1
#> 558     Kunar     Chapa Dara         45  28          0        0
#> 559     Kunar     Chapa Dara         47  25         12        0
#> 560     Kunar     Chapa Dara         47  18         12        1
#> 561     Kunar     Chapa Dara         47  35         14        0
#> 562     Kunar     Chapa Dara         47  35          8        0
#> 563     Kunar     Chapa Dara         47  23         14        1
#> 564     Kunar     Chapa Dara         47  45         10        0
#> 565     Kunar     Chapa Dara         47  23          0        0
#> 566     Kunar     Chapa Dara         47  42          0        1
#> 567     Kunar     Chapa Dara         47  35         10        1
#> 568     Kunar     Chapa Dara        138  30          0        1
#> 569     Kunar     Chapa Dara        138  50         12        1
#> 570     Kunar     Chapa Dara        138  25          0        0
#> 571     Kunar     Chapa Dara        138  53          0        1
#> 572     Kunar     Chapa Dara        138  32          6        1
#> 573     Kunar     Chapa Dara        138  22          0        0
#> 574     Kunar     Chapa Dara        138  32          0        1
#> 575     Kunar     Chapa Dara        138  60          0        0
#> 576     Kunar     Chapa Dara        138  45          0        1
#> 577     Kunar     Chapa Dara        113  35          8        0
#> 578     Kunar     Chapa Dara        113  30         13        0
#> 579     Kunar     Chapa Dara        113  35         14        1
#> 580     Kunar     Chapa Dara        113  30          0        0
#> 581     Kunar     Chapa Dara        113  26          0        0
#> 582     Kunar     Chapa Dara        113  42         14        1
#> 583     Kunar     Chapa Dara        113  33          8        0
#> 584     Kunar     Chapa Dara        113  62          0        0
#> 585     Kunar     Chapa Dara        113  26          0        1
#> 586     Kunar     Chapa Dara        113  30         14        1
#> 587     Kunar     Chapa Dara        113  45          0        1
#> 588     Kunar     Chapa Dara        113  35         12        1
#> 589     Kunar     Chapa Dara        113  22         11        0
#> 590     Kunar     Chapa Dara        113  27         12        1
#> 591     Kunar     Chapa Dara        113  20         10        0
#> 592     Kunar     Chapa Dara        113  35          8        0
#> 593     Kunar     Chapa Dara        113  65          0        0
#> 594     Kunar     Chapa Dara        113  75         12        1
#> 595     Kunar     Chapa Dara        122  36          8        0
#> 596     Kunar     Chapa Dara        122  49         10        1
#> 597     Kunar     Chapa Dara        122  25          0        0
#> 598     Kunar     Chapa Dara        122  34          6        1
#> 599     Kunar     Chapa Dara        122  54         12        1
#> 600     Kunar     Chapa Dara        122  34          8        0
#> 601     Kunar     Chapa Dara        122  48          0        0
#> 602     Kunar     Chapa Dara        122  32         14        1
#> 603     Kunar     Chapa Dara        122  22         11        0
#> 604     Kunar     Chapa Dara        122  49          8        0
#> 605     Kunar     Chapa Dara        122  72          0        0
#> 606     Kunar     Chapa Dara        122  18         12        0
#> 607     Kunar     Chapa Dara        122  17         10        0
#> 608     Kunar     Chapa Dara        122  26          0        0
#> 609     Kunar     Chapa Dara        122  17          8        0
#> 610     Kunar     Chapa Dara        122  56          8        1
#> 611     Kunar     Chapa Dara        122  27          0        1
#> 612     Kunar     Chapa Dara        122  36         12        1
#> 613     Kunar     Chapa Dara          3  26          8        0
#> 614     Kunar     Chapa Dara          3  22         12        1
#> 615     Kunar     Chapa Dara          3  30         12        1
#> 616     Kunar     Chapa Dara          3  22          8        1
#> 617     Kunar     Chapa Dara          3  29          0        0
#> 618     Kunar     Chapa Dara          3  30         10        0
#> 619     Kunar     Chapa Dara          3  27         13        1
#> 620     Kunar     Chapa Dara          3  25          0        1
#> 621     Kunar     Chapa Dara          3  27          0        1
#> 622     Kunar     Chapa Dara          3  31          8        1
#> 623     Kunar     Chapa Dara          3  21          0        0
#> 624     Kunar     Chapa Dara          3  23         10        0
#> 625     Kunar     Chapa Dara          3  29          0        0
#> 626     Kunar     Chapa Dara          3  33          0        0
#> 627     Kunar     Chapa Dara          3  24          0        0
#> 628     Kunar     Chapa Dara          3  21          8        0
#> 629     Kunar     Chapa Dara          3  24          8        0
#> 630     Kunar     Chapa Dara          3  24          0        0
#> 631     Kunar     Chapa Dara        103  58          0        0
#> 632     Kunar     Chapa Dara        103  60          0        1
#> 633     Kunar     Chapa Dara        103  18          6        0
#> 634     Kunar     Chapa Dara        103  25          0        1
#> 635     Kunar     Chapa Dara        103  23          0        0
#> 636     Kunar     Chapa Dara        103  52         14        1
#> 637     Kunar     Chapa Dara        103  18         12        1
#> 638     Kunar     Chapa Dara        103  18          3        0
#> 639     Kunar     Chapa Dara        103  28          8        0
#> 640     Kunar     Chapa Dara        103  55          0        0
#> 641     Kunar     Chapa Dara        103  35          8        0
#> 642     Kunar     Chapa Dara        103  38         14        1
#> 643     Kunar     Chapa Dara        103  47          0        1
#> 644     Kunar     Chapa Dara        103  65          3        0
#> 645     Kunar     Chapa Dara        103  16          1        0
#> 646     Kunar     Chapa Dara        103  63         12        1
#> 647     Kunar     Chapa Dara        103  45          0        0
#> 648     Kunar     Chapa Dara        103  28         12        0
#> 649     Kunar         Dangam         79  21          8        0
#> 650     Kunar         Dangam         79  24         11        1
#> 652     Kunar         Dangam         79  27         12        1
#> 654     Kunar         Dangam         79  28         12        1
#> 655     Kunar         Dangam         79  24         10        1
#> 656     Kunar         Dangam         79  29          0        1
#> 657     Kunar         Dangam         79  18          9        0
#> 658     Kunar         Dangam        176  17         11        0
#> 659     Kunar         Dangam        176  18          4        0
#> 660     Kunar         Dangam        176  22         12        0
#> 661     Kunar         Dangam        176  55          0        1
#> 662     Kunar         Dangam        176  19          3        0
#> 663     Kunar         Dangam        176  19         12        1
#> 664     Kunar         Dangam        176  61          0        1
#> 665     Kunar         Dangam        176  17         10        0
#> 666     Kunar         Dangam        176  51          0        0
#> 667     Kunar         Dangam        189  44          0        0
#> 668     Kunar         Dangam        189  30          0        0
#> 669     Kunar         Dangam        189  18         10        0
#> 670     Kunar         Dangam        189  33          8        1
#> 671     Kunar         Dangam        189  21          8        0
#> 672     Kunar         Dangam        189  24          8        1
#> 673     Kunar         Dangam        189  34          0        1
#> 674     Kunar         Dangam        189  35          0        1
#> 675     Kunar         Dangam        189  50          0        0
#> 676     Kunar         Dangam        163  50          0        1
#> 677     Kunar         Dangam        163  47          0        1
#> 678     Kunar         Dangam        163  17          0        1
#> 679     Kunar         Dangam        163  24          0        1
#> 680     Kunar         Dangam        163  25          6        1
#> 681     Kunar         Dangam        163  24          0        1
#> 682     Kunar         Dangam        163  30          0        1
#> 683     Kunar         Dangam        163  18         10        1
#> 684     Kunar         Dangam        163  45          0        1
#> 685     Kunar         Dangam        163  27          0        1
#> 686     Kunar         Dangam        163  29          8        1
#> 687     Kunar         Dangam        163  35          0        1
#> 688     Kunar         Dangam        163  22         10        1
#> 689     Kunar         Dangam        163  28          0        1
#> 690     Kunar         Dangam        163  30          6        1
#> 691     Kunar         Dangam        163  34          0        1
#> 692     Kunar         Dangam        163  23          8        1
#> 693     Kunar         Dangam        163  19          6        1
#> 694     Kunar         Dangam         26  65          6        1
#> 695     Kunar         Dangam         26  48         10        1
#> 696     Kunar         Dangam         26  22          9        0
#> 697     Kunar         Dangam         26  24          0        1
#> 698     Kunar         Dangam         26  19          8        0
#> 699     Kunar         Dangam         26  33          0        1
#> 700     Kunar         Dangam         26  30          0        1
#> 701     Kunar         Dangam         26  22          8        0
#> 702     Kunar         Dangam         26  33          0        1
#> 703     Kunar         Dangam         26  20          7        0
#> 704     Kunar         Dangam         26  48          0        0
#> 705     Kunar         Dangam         26  18         10        0
#> 706     Kunar         Dangam         26  20         12        1
#> 707     Kunar         Dangam         26  45          0        1
#> 708     Kunar         Dangam         26  20          0        0
#> 709     Kunar         Dangam         26  28          0        1
#> 710     Kunar         Dangam         26  44          7        1
#> 711     Kunar         Dangam         26  22          8        0
#> 712     Kunar      Ghaziabad         78  40         12        1
#> 713     Kunar      Ghaziabad         78  45          0        0
#> 714     Kunar      Ghaziabad         78  60          3        0
#> 715     Kunar      Ghaziabad         78  37          3        0
#> 716     Kunar      Ghaziabad         78  35          0        0
#> 717     Kunar      Ghaziabad         78  38         12        1
#> 718     Kunar      Ghaziabad         78  70          0        0
#> 719     Kunar      Ghaziabad         78  28         12        1
#> 720     Kunar      Ghaziabad         78  41          0        0
#> 721     Kunar      Ghaziabad         11  36         12        1
#> 722     Kunar      Ghaziabad         11  30          0        0
#> 723     Kunar      Ghaziabad         11  38         12        1
#> 724     Kunar      Ghaziabad         11  50          0        0
#> 725     Kunar      Ghaziabad         11  28          0        0
#> 726     Kunar      Ghaziabad         11  48         12        1
#> 727     Kunar      Ghaziabad         11  42          0        0
#> 728     Kunar      Ghaziabad         11  50         12        0
#> 729     Kunar      Ghaziabad         11  33         12        1
#> 730     Kunar      Ghaziabad         25  15          3        1
#> 731     Kunar      Ghaziabad         25  28          3        1
#> 732     Kunar      Ghaziabad         25  28          0        1
#> 733     Kunar      Ghaziabad         25  17          5        0
#> 735     Kunar      Ghaziabad         25  34         12        1
#> 736     Kunar      Ghaziabad         25  39          0        1
#> 737     Kunar      Ghaziabad         25  18          9        1
#> 738     Kunar      Ghaziabad         25  44          0        1
#> 739     Kunar      Ghaziabad        146  30          0        0
#> 740     Kunar      Ghaziabad        146  32          3        1
#> 741     Kunar      Ghaziabad        146  25          4        1
#> 742     Kunar      Ghaziabad        146  55          0        1
#> 743     Kunar      Ghaziabad        146  26          0        1
#> 744     Kunar      Ghaziabad        146  29          7        1
#> 745     Kunar      Ghaziabad        146  25          0        0
#> 746     Kunar      Ghaziabad        146  30          8        1
#> 747     Kunar      Ghaziabad        146  19         11        0
#> 748     Kunar      Ghaziabad        146  22          6        0
#> 749     Kunar      Ghaziabad        146  22          7        1
#> 750     Kunar      Ghaziabad        146  27          0        1
#> 751     Kunar      Ghaziabad        146  68          0        0
#> 752     Kunar      Ghaziabad        146  31          6        1
#> 753     Kunar      Ghaziabad        146  27          4        0
#> 754     Kunar      Ghaziabad        146  78          0        0
#> 755     Kunar      Ghaziabad        146  33         12        1
#> 756     Kunar      Ghaziabad        146  39          7        1
#> 757     Kunar      Ghaziabad         71  42         14        1
#> 758     Kunar      Ghaziabad         71  27         12        1
#> 759     Kunar      Ghaziabad         71  18         12        0
#> 760     Kunar      Ghaziabad         71  22          8        1
#> 761     Kunar      Ghaziabad         71  65          0        0
#> 762     Kunar      Ghaziabad         71  28          4        1
#> 763     Kunar      Ghaziabad         71  18         10        0
#> 764     Kunar      Ghaziabad         71  28         16        0
#> 765     Kunar      Ghaziabad         71  30          4        1
#> 766     Kunar      Ghaziabad         71  38          3        1
#> 767     Kunar      Ghaziabad         71  25         12        1
#> 768     Kunar      Ghaziabad         71  22          8        0
#> 769     Kunar      Ghaziabad         71  40         14        1
#> 770     Kunar      Ghaziabad         71  25          6        1
#> 771     Kunar      Ghaziabad         71  20          4        1
#> 772     Kunar      Ghaziabad         71  50          0        1
#> 773     Kunar      Ghaziabad         71  18          9        0
#> 774     Kunar      Ghaziabad         71  16          7        0
#> 775     Kunar       Wata Pur         52  27          0        1
#> 776     Kunar       Wata Pur         52  30          8        1
#> 777     Kunar       Wata Pur         52  25         12        0
#> 778     Kunar       Wata Pur         52  37          0        1
#> 779     Kunar       Wata Pur         52  27         10        1
#> 780     Kunar       Wata Pur         52  40          0        1
#> 781     Kunar       Wata Pur         52  30          6        1
#> 782     Kunar       Wata Pur         52  37          0        1
#> 783     Kunar       Wata Pur         52  18          8        0
#> 784     Kunar       Wata Pur         67  31         10        1
#> 785     Kunar       Wata Pur         67  40         12        0
#> 786     Kunar       Wata Pur         67  26          2        0
#> 787     Kunar       Wata Pur         67  23         11        0
#> 788     Kunar       Wata Pur         67  27          0        1
#> 789     Kunar       Wata Pur         67  26          7        0
#> 790     Kunar       Wata Pur         67  28         12        1
#> 791     Kunar       Wata Pur         67  31          3        0
#> 792     Kunar       Wata Pur         67  21         12        1
#> 793     Kunar       Wata Pur        115  28         12        0
#> 794     Kunar       Wata Pur        115  46         12        0
#> 795     Kunar       Wata Pur        115  27          5        1
#> 796     Kunar       Wata Pur        115  24         10        1
#> 797     Kunar       Wata Pur        115  24          0        0
#> 798     Kunar       Wata Pur        115  20          6        1
#> 799     Kunar       Wata Pur        115  22          6        1
#> 800     Kunar       Wata Pur        115  31         12        0
#> 801     Kunar       Wata Pur        115  24         10        0
#> 802     Kunar       Wata Pur        174  21         11        0
#> 803     Kunar       Wata Pur        174  28          0        1
#> 804     Kunar       Wata Pur        174  40          8        1
#> 805     Kunar       Wata Pur        174  43          8        1
#> 806     Kunar       Wata Pur        174  50          0        1
#> 807     Kunar       Wata Pur        174  27          6        1
#> 808     Kunar       Wata Pur        174  30          0        1
#> 809     Kunar       Wata Pur        174  18          9        1
#> 810     Kunar       Wata Pur        174  23          0        1
#> 811     Kunar       Wata Pur        204  53         12        0
#> 812     Kunar       Wata Pur        204  46         12        0
#> 813     Kunar       Wata Pur        204  25          4        0
#> 814     Kunar       Wata Pur        204  45         12        0
#> 815     Kunar       Wata Pur        204  60          6        1
#> 816     Kunar       Wata Pur        204  18          9        0
#> 817     Kunar       Wata Pur        204  21         10        0
#> 818     Kunar       Wata Pur        204  24          3        1
#> 819     Kunar       Wata Pur        204  32          0        1
#> 820     Kunar       Wata Pur         48  23          9        0
#> 821     Kunar       Wata Pur         48  30         10        0
#> 822     Kunar       Wata Pur         48  42         12        1
#> 823     Kunar       Wata Pur         48  23          8        0
#> 824     Kunar       Wata Pur         48  60          0        1
#> 825     Kunar       Wata Pur         48  22         12        1
#> 826     Kunar       Wata Pur         48  20         12        0
#> 827     Kunar       Wata Pur         48  29         10        1
#> 828     Kunar       Wata Pur         48  43         12        0
#> 829     Kunar       Wata Pur        196  19          0        0
#> 830     Kunar       Wata Pur        196  53         11        0
#> 831     Kunar       Wata Pur        196  22          0        0
#> 832     Kunar       Wata Pur        196  21          5        1
#> 833     Kunar       Wata Pur        196  20         10        0
#> 834     Kunar       Wata Pur        196  25          0        0
#> 835     Kunar       Wata Pur        196  21          0        0
#> 836     Kunar       Wata Pur        196  49          0        1
#> 837     Kunar       Wata Pur        196  37         12        0
#> 838     Kunar       Wata Pur        196  51          0        0
#> 839     Kunar       Wata Pur        196  19         10        1
#> 840     Kunar       Wata Pur        196  43          0        1
#> 841     Kunar       Wata Pur        196  70          0        0
#> 842     Kunar       Wata Pur        196  31          0        1
#> 843     Kunar       Wata Pur        196  20         10        1
#> 844     Kunar       Wata Pur        196  18         10        0
#> 845     Kunar       Wata Pur        196  73          0        0
#> 846     Kunar       Wata Pur        196  48          0        1
#> 847     Kunar       Wata Pur        193  23          0        0
#> 848     Kunar       Wata Pur        193  32          0        0
#> 849     Kunar       Wata Pur        193  19          8        0
#> 850     Kunar       Wata Pur        193  27          0        1
#> 851     Kunar       Wata Pur        193  38          0        0
#> 852     Kunar       Wata Pur        193  36         12        0
#> 853     Kunar       Wata Pur        193  27          0        1
#> 854     Kunar       Wata Pur        193  43         12        0
#> 855     Kunar       Wata Pur        193  28          3        1
#> 856     Kunar       Wata Pur        193  24          0        1
#> 857     Kunar       Wata Pur        193  20          0        0
#> 858     Kunar       Wata Pur        193  27         12        1
#> 859     Kunar       Wata Pur        193  25         12        0
#> 860     Kunar       Wata Pur        193  37         12        0
#> 861     Kunar       Wata Pur        193  29          5        1
#> 862     Kunar       Wata Pur        193  28          0        1
#> 863     Kunar       Wata Pur        193  26          0        1
#> 864     Kunar       Wata Pur        193  23         12        0
#> 865     Kunar       Wata Pur        160  52         12        0
#> 866     Kunar       Wata Pur        160  44         12        1
#> 867     Kunar       Wata Pur        160  22         11        0
#> 868     Kunar       Wata Pur        160  25          0        1
#> 869     Kunar       Wata Pur        160  52          0        0
#> 870     Kunar       Wata Pur        160  60          0        0
#> 871     Kunar       Wata Pur        160  44         10        1
#> 872     Kunar       Wata Pur        160  53         12        0
#> 873     Kunar       Wata Pur        160  22         12        0
#> 874     Kunar       Wata Pur        160  44         12        1
#> 875     Kunar       Wata Pur        160  55          0        0
#> 876     Kunar       Wata Pur        160  25         12        0
#> 877     Kunar       Wata Pur        160  28          0        0
#> 878     Kunar       Wata Pur        160  42          0        1
#> 879     Kunar       Wata Pur        160  32         12        1
#> 880     Kunar       Wata Pur        160  18         11        0
#> 881     Kunar       Wata Pur        160  50          0        1
#> 882     Kunar       Wata Pur        160  28          0        1
#> 883     Khost            Bak          7  21          9        0
#> 884     Khost            Bak          7  16          0        1
#> 885     Khost            Bak          7  20          0        1
#> 886     Khost            Bak          7  27          5        0
#> 887     Khost            Bak          7  25          0        1
#> 888     Khost            Bak          7  45          0        1
#> 889     Khost            Bak          7  43         10        1
#> 890     Khost            Bak          7  35          0        1
#> 891     Khost            Bak          7  18          0        1
#> 892     Khost            Bak        164  18          8        0
#> 893     Khost            Bak        164  30          5        1
#> 894     Khost            Bak        164  20          0        0
#> 895     Khost            Bak        164  22          9        0
#> 896     Khost            Bak        164  50          2        1
#> 897     Khost            Bak        164  40          0        1
#> 898     Khost            Bak        164  60          0        1
#> 899     Khost            Bak        164  20          0        1
#> 900     Khost            Bak        164  40          0        0
#> 901     Khost            Bak        104  28          0        1
#> 902     Khost            Bak        104  58          0        0
#> 903     Khost            Bak        104  35          0        0
#> 904     Khost            Bak        104  53          7        0
#> 905     Khost            Bak        104  20         10        0
#> 906     Khost            Bak        104  33         11        0
#> 907     Khost            Bak        104  18         10        0
#> 908     Khost            Bak        104  17          0        0
#> 909     Khost            Bak        104  42          0        0
#> 910     Khost            Bak        104  32          8        0
#> 911     Khost            Bak        104  22         11        0
#> 912     Khost            Bak        104  19         12        0
#> 913     Khost            Bak        104  18          0        1
#> 914     Khost            Bak        104  47          0        1
#> 915     Khost            Bak        104  16          2        0
#> 916     Khost            Bak        104  21          4        0
#> 917     Khost            Bak        104  23          5        0
#> 918     Khost            Bak        104  27          9        0
#> 919     Khost            Bak        132  26          8        1
#> 920     Khost            Bak        132  43          0        1
#> 921     Khost            Bak        132  40          7        0
#> 922     Khost            Bak        132  33         11        1
#> 923     Khost            Bak        132  47         12        0
#> 924     Khost            Bak        132  43         11        0
#> 925     Khost            Bak        132  29          5        1
#> 926     Khost            Bak        132  29          6        0
#> 927     Khost            Bak        132  18          5        1
#> 928     Khost            Bak        132  17          4        1
#> 929     Khost            Bak        132  17          8        0
#> 930     Khost            Bak        132  44         11        0
#> 931     Khost            Bak        132  46          0        1
#> 932     Khost            Bak        132  30         10        0
#> 933     Khost            Bak        132  22          8        1
#> 934     Khost            Bak        132  24          9        1
#> 935     Khost            Bak        132  20          5        0
#> 936     Khost            Bak        132  33          0        0
#> 937     Khost          Khost        165  54          4        1
#> 938     Khost          Khost        165  24          7        1
#> 939     Khost          Khost        165  30          6        1
#> 940     Khost          Khost        165  38          9        1
#> 941     Khost          Khost        165  50         14        1
#> 942     Khost          Khost        165  34         10        1
#> 943     Khost          Khost        165  28          6        0
#> 944     Khost          Khost        165  48          8        1
#> 945     Khost          Khost        165  28          5        0
#> 946     Khost          Khost         54  28          7        1
#> 947     Khost          Khost         54  29         12        0
#> 948     Khost          Khost         54  18         10        0
#> 949     Khost          Khost         54  29          5        1
#> 950     Khost          Khost         54  38         10        1
#> 951     Khost          Khost         54  55          5        1
#> 952     Khost          Khost         54  42         12        1
#> 953     Khost          Khost         54  26          8        1
#> 954     Khost          Khost         54  40          9        1
#> 955     Khost          Khost         66  32          3        1
#> 956     Khost          Khost         66  21          8        1
#> 957     Khost          Khost         66  19          3        1
#> 958     Khost          Khost         66  43          7        1
#> 959     Khost          Khost         66  33          0        1
#> 960     Khost          Khost         66  29         12        1
#> 961     Khost          Khost         66  17          8        0
#> 962     Khost          Khost         66  24          9        1
#> 963     Khost          Khost         66  18          0        0
#> 964     Khost          Khost         61  18          6        0
#> 965     Khost          Khost         61  33          7        1
#> 966     Khost          Khost         61  22         12        1
#> 967     Khost          Khost         61  25          0        1
#> 968     Khost          Khost         61  19          0        1
#> 969     Khost          Khost         61  32         10        1
#> 970     Khost          Khost         61  35          0        1
#> 971     Khost          Khost         61  39          0        1
#> 972     Khost          Khost         61  41          9        0
#> 973     Khost          Khost        166  28         18        1
#> 974     Khost          Khost        166  24          4        1
#> 975     Khost          Khost        166  31          5        1
#> 976     Khost          Khost        166  26         12        1
#> 977     Khost          Khost        166  30          6        1
#> 978     Khost          Khost        166  20          3        1
#> 979     Khost          Khost        166  39          3        1
#> 980     Khost          Khost        166  33          8        1
#> 981     Khost          Khost        166  26          8        1
#> 982     Khost          Khost         92  43          6        1
#> 983     Khost          Khost         92  19         11        0
#> 984     Khost          Khost         92  16          9        0
#> 985     Khost          Khost         92  49          4        1
#> 986     Khost          Khost         92  26          3        1
#> 987     Khost          Khost         92  36         12        1
#> 988     Khost          Khost         92  49          7        1
#> 989     Khost          Khost         92  38          0        1
#> 990     Khost          Khost         92  26          3        1
#> 991     Khost          Khost         88  60          0        1
#> 992     Khost          Khost         88  37          5        1
#> 993     Khost          Khost         88  58          9        1
#> 994     Khost          Khost         88  49         12        1
#> 995     Khost          Khost         88  46         12        1
#> 996     Khost          Khost         88  51          0        1
#> 997     Khost          Khost         88  25         12        0
#> 998     Khost          Khost         88  22         11        1
#> 999     Khost          Khost         88  43          5        1
#> 1000    Khost          Khost        112  30         11        1
#> 1001    Khost          Khost        112  31         16        1
#> 1002    Khost          Khost        112  39          8        1
#> 1003    Khost          Khost        112  23          8        1
#> 1004    Khost          Khost        112  41          0        0
#> 1005    Khost          Khost        112  36          8        1
#> 1006    Khost          Khost        112  28          9        0
#> 1007    Khost          Khost        112  44         12        1
#> 1008    Khost          Khost        112  35          0        1
#> 1009    Khost          Khost        112  47          0        1
#> 1010    Khost          Khost        112  51         18        1
#> 1011    Khost          Khost        112  19         12        0
#> 1012    Khost          Khost        112  16         10        0
#> 1014    Khost          Khost        112  60          9        0
#> 1015    Khost          Khost        112  28         12        1
#> 1016    Khost          Khost        112  47         10        1
#> 1017    Khost          Khost        112  22          7        1
#> 1018    Khost          Khost        156  27         12        1
#> 1019    Khost          Khost        156  22         12        1
#> 1020    Khost          Khost        156  35         10        1
#> 1021    Khost          Khost        156  56          8        0
#> 1022    Khost          Khost        156  18          9        0
#> 1023    Khost          Khost        156  22          6        0
#> 1024    Khost          Khost        156  19         11        1
#> 1025    Khost          Khost        156  28          0        1
#> 1026    Khost          Khost        156  19          8        0
#> 1027    Khost          Khost        156  39         12        0
#> 1028    Khost          Khost        156  33          7        1
#> 1029    Khost          Khost        156  20         12        0
#> 1030    Khost          Khost        156  49          7        1
#> 1031    Khost          Khost        156  35         10        1
#> 1032    Khost          Khost        156  29         12        1
#> 1033    Khost          Khost        156  18         10        0
#> 1034    Khost          Khost        156  55          8        0
#> 1035    Khost          Khost        156  24         12        1
#> 1036    Khost          Khost         93  21         11        0
#> 1037    Khost          Khost         93  22         10        0
#> 1038    Khost          Khost         93  42          6        1
#> 1039    Khost          Khost         93  22          8        0
#> 1040    Khost          Khost         93  17          9        0
#> 1041    Khost          Khost         93  52          4        1
#> 1042    Khost          Khost         93  48          8        1
#> 1043    Khost          Khost         93  17          5        0
#> 1044    Khost          Khost         93  54          6        0
#> 1045    Khost          Khost         93  46          7        1
#> 1046    Khost          Khost         93  26          4        0
#> 1047    Khost          Khost         93  56          5        0
#> 1048    Khost          Khost         93  43          6        1
#> 1049    Khost          Khost         93  18          7        0
#> 1050    Khost          Khost         93  36          8        1
#> 1051    Khost          Khost         93  50         10        1
#> 1052    Khost          Khost         93  20          4        0
#> 1053    Khost          Khost         93  26          8        1
#> 1054    Khost          Khost          1  25         11        1
#> 1055    Khost          Khost          1  25          6        1
#> 1056    Khost          Khost          1  28          6        0
#> 1057    Khost          Khost          1  39          0        1
#> 1058    Khost          Khost          1  25         11        1
#> 1059    Khost          Khost          1  30         10        1
#> 1060    Khost          Khost          1  38          0        1
#> 1061    Khost          Khost          1  19          7        1
#> 1062    Khost          Khost          1  20          0        1
#> 1063    Khost          Khost          1  18          3        0
#> 1064    Khost          Khost          1  58          0        1
#> 1065    Khost          Khost          1  26         12        0
#> 1066    Khost          Khost          1  39          9        1
#> 1067    Khost          Khost          1  50          8        0
#> 1068    Khost          Khost          1  39          0        1
#> 1069    Khost          Khost          1  28          6        0
#> 1070    Khost          Khost          1  38         10        1
#> 1071    Khost          Khost          1  50         12        0
#> 1072    Khost          Khost         42  24         15        0
#> 1073    Khost          Khost         42  23          0        0
#> 1074    Khost          Khost         42  26          0        0
#> 1075    Khost          Khost         42  35         12        1
#> 1076    Khost          Khost         42  54         12        0
#> 1077    Khost          Khost         42  25         11        0
#> 1078    Khost          Khost         42  18         12        1
#> 1080    Khost          Khost         42  55          0        0
#> 1081    Khost          Khost         42  39          0        0
#> 1083    Khost          Khost         42  30          0        0
#> 1084    Khost          Khost         42  61          6        0
#> 1085    Khost          Khost         42  32         12        0
#> 1086    Khost          Khost         42  47          0        1
#> 1087    Khost          Khost         42  17          0        0
#> 1088    Khost          Khost         42  24         12        1
#> 1089    Khost          Khost         42  40         12        0
#> 1090    Khost          Khost         49  32         10        1
#> 1091    Khost          Khost         49  50          0        1
#> 1092    Khost          Khost         49  26         10        0
#> 1093    Khost          Khost         49  28         10        0
#> 1094    Khost          Khost         49  27         10        0
#> 1095    Khost          Khost         49  35         13        0
#> 1096    Khost          Khost         49  29          8        1
#> 1097    Khost          Khost         49  55         10        0
#> 1098    Khost          Khost         49  48         13        0
#> 1099    Khost          Khost         49  23          0        0
#> 1100    Khost          Khost         49  22          0        0
#> 1101    Khost          Khost         49  50          0        0
#> 1102    Khost          Khost         49  30         12        0
#> 1103    Khost          Khost         49  35         10        0
#> 1104    Khost          Khost         49  30         12        1
#> 1105    Khost          Khost         49  45          0        0
#> 1106    Khost          Khost         49  25         12        0
#> 1107    Khost          Khost         49  47         10        0
#> 1108    Khost          Khost        179  21         12        0
#> 1109    Khost          Khost        179  30          8        0
#> 1110    Khost          Khost        179  18          9        0
#> 1111    Khost          Khost        179  18         12        0
#> 1112    Khost          Khost        179  24          0        1
#> 1113    Khost          Khost        179  20          0        1
#> 1114    Khost          Khost        179  26          0        1
#> 1115    Khost          Khost        179  19          9        1
#> 1116    Khost          Khost        179  32         12        0
#> 1117    Khost          Khost        179  18          0        1
#> 1118    Khost          Khost        179  25         12        1
#> 1119    Khost          Khost        179  26         10        1
#> 1120    Khost          Khost        179  21         12        0
#> 1121    Khost          Khost        179  18         10        1
#> 1122    Khost          Khost        179  30         12        0
#> 1123    Khost          Khost        179  24          0        1
#> 1124    Khost          Khost        179  52         12        1
#> 1125    Khost          Khost        179  18          0        1
#> 1126    Khost          Khost         69  40          9        1
#> 1127    Khost          Khost         69  50          3        0
#> 1128    Khost          Khost         69  21          9        0
#> 1129    Khost          Khost         69  18         10        0
#> 1130    Khost          Khost         69  22          8        1
#> 1131    Khost          Khost         69  25         12        0
#> 1132    Khost          Khost         69  24          9        0
#> 1133    Khost          Khost         69  28          9        1
#> 1134    Khost          Khost         69  53          8        1
#> 1135    Khost          Khost         69  21         13        1
#> 1136    Khost          Khost         69  17          8        0
#> 1137    Khost          Khost         69  52          9        1
#> 1138    Khost          Khost         69  28          6        0
#> 1139    Khost          Khost         69  20         11        0
#> 1140    Khost          Khost         69  18         10        0
#> 1141    Khost          Khost         69  48          7        1
#> 1142    Khost          Khost         69  33         14        1
#> 1143    Khost          Khost         69  30          9        0
#> 1144    Khost          Khost        180  30          3        1
#> 1145    Khost          Khost        180  53          8        0
#> 1146    Khost          Khost        180  30         12        1
#> 1147    Khost          Khost        180  48          4        1
#> 1148    Khost          Khost        180  51         10        1
#> 1149    Khost          Khost        180  58         12        1
#> 1150    Khost          Khost        180  38          4        1
#> 1151    Khost          Khost        180  56          7        0
#> 1152    Khost          Khost        180  43         12        0
#> 1153    Khost          Khost        180  58         10        0
#> 1154    Khost          Khost        180  42         10        1
#> 1155    Khost          Khost        180  59         10        0
#> 1156    Khost          Khost        180  48         10        1
#> 1157    Khost          Khost        180  53         10        1
#> 1158    Khost          Khost        180  30          6        0
#> 1159    Khost          Khost        180  32         10        1
#> 1160    Khost          Khost        180  33         10        1
#> 1161    Khost          Khost        180  60          6        1
#> 1162    Khost          Khost        106  38          9        0
#> 1163    Khost          Khost        106  30         11        0
#> 1164    Khost          Khost        106  20          0        1
#> 1165    Khost          Khost        106  28          0        0
#> 1166    Khost          Khost        106  23          0        0
#> 1167    Khost          Khost        106  18          0        1
#> 1168    Khost          Khost        106  25          0        0
#> 1169    Khost          Khost        106  43          0        0
#> 1170    Khost          Khost        106  33          0        0
#> 1171    Khost          Khost        106  30          0        0
#> 1172    Khost          Khost        106  28          0        0
#> 1173    Khost          Khost        106  43          0        0
#> 1174    Khost          Khost        106  38          0        1
#> 1175    Khost          Khost        106  38          0        0
#> 1176    Khost          Khost        106  30          0        0
#> 1177    Khost          Khost        106  28          0        1
#> 1178    Khost          Khost        106  38          0        0
#> 1179    Khost          Khost        106  18          0        1
#> 1180    Khost       Qalandar         68  25         10        1
#> 1181    Khost       Qalandar         68  58         10        0
#> 1182    Khost       Qalandar         68  16          5        0
#> 1183    Khost       Qalandar         68  55          0        1
#> 1184    Khost       Qalandar         68  40          0        1
#> 1185    Khost       Qalandar         68  33         12        1
#> 1186    Khost       Qalandar         68  43          0        1
#> 1187    Khost       Qalandar         68  28          6        1
#> 1188    Khost       Qalandar         68  30          0        1
#> 1189    Khost       Qalandar          5  40          0        1
#> 1190    Khost       Qalandar          5  44          5        1
#> 1191    Khost       Qalandar          5  22         10        0
#> 1192    Khost       Qalandar          5  23          0        1
#> 1193    Khost       Qalandar          5  30         12        1
#> 1194    Khost       Qalandar          5  50          0        1
#> 1195    Khost       Qalandar          5  35          0        1
#> 1196    Khost       Qalandar          5  25         10        1
#> 1197    Khost       Qalandar          5  33          8        1
#> 1198    Khost       Qalandar          5  26          4        1
#> 1199    Khost       Qalandar          5  37          0        1
#> 1200    Khost       Qalandar          5  44          6        1
#> 1201    Khost       Qalandar          5  42          5        1
#> 1202    Khost       Qalandar          5  39          4        1
#> 1203    Khost       Qalandar          5  24         12        1
#> 1204    Khost       Qalandar          5  20         10        0
#> 1205    Khost       Qalandar          5  23         12        0
#> 1206    Khost       Qalandar          5  25         12        0
#> 1207    Khost       Qalandar         43  20          0        1
#> 1208    Khost       Qalandar         43  22          8        1
#> 1209    Khost       Qalandar         43  18          0        0
#> 1210    Khost       Qalandar         43  30         11        0
#> 1211    Khost       Qalandar         43  53          0        0
#> 1212    Khost       Qalandar         43  22          0        0
#> 1214    Khost       Qalandar         43  18          0        1
#> 1215    Khost       Qalandar         43  46          0        0
#> 1216    Khost       Qalandar         43  70          0        0
#> 1217    Khost       Qalandar         43  50          0        0
#> 1218    Khost       Qalandar         43  36          0        1
#> 1219    Khost       Qalandar         43  18          0        0
#> 1220    Khost       Qalandar         43  18         10        0
#> 1221    Khost       Qalandar         43  17          0        1
#> 1222    Khost       Qalandar         43  25          6        0
#> 1223    Khost       Qalandar         43  18          9        0
#> 1224    Khost       Qalandar         43  30          0        0
#> 1225    Khost       Qalandar        195  25         12        1
#> 1226    Khost       Qalandar        195  38          9        1
#> 1227    Khost       Qalandar        195  20          7        1
#> 1228    Khost       Qalandar        195  50         12        1
#> 1229    Khost       Qalandar        195  23          9        1
#> 1230    Khost       Qalandar        195  54         10        1
#> 1231    Khost       Qalandar        195  19          7        1
#> 1232    Khost       Qalandar        195  44         10        0
#> 1233    Khost       Qalandar        195  21          0        0
#> 1234    Khost       Qalandar        195  50          0        0
#> 1235    Khost       Qalandar        195  18          5        1
#> 1236    Khost       Qalandar        195  45          0        1
#> 1237    Khost       Qalandar        195  18          7        0
#> 1238    Khost       Qalandar        195  21          0        0
#> 1239    Khost       Qalandar        195  28         12        1
#> 1240    Khost       Qalandar        195  29          6        0
#> 1241    Khost       Qalandar        195  22          0        0
#> 1242    Khost       Qalandar        195  22          8        1
#> 1243    Khost          Spira         36  60          7        1
#> 1244    Khost          Spira         36  23          7        1
#> 1245    Khost          Spira         36  33          9        1
#> 1246    Khost          Spira         36  32         12        1
#> 1247    Khost          Spira         36  18         11        0
#> 1248    Khost          Spira         36  37          0        0
#> 1249    Khost          Spira         36  33          6        1
#> 1250    Khost          Spira         36  29         11        1
#> 1251    Khost          Spira         36  49          0        0
#> 1252    Khost          Spira        107  43          4        1
#> 1253    Khost          Spira        107  25          0        1
#> 1254    Khost          Spira        107  37         12        1
#> 1255    Khost          Spira        107  63          5        1
#> 1256    Khost          Spira        107  21          0        0
#> 1257    Khost          Spira        107  27         12        1
#> 1258    Khost          Spira        107  25         12        1
#> 1259    Khost          Spira        107  33          0        0
#> 1260    Khost          Spira        107  33          9        1
#> 1261    Khost          Spira        157  45          2        1
#> 1262    Khost          Spira        157  26          0        1
#> 1263    Khost          Spira        157  33         12        1
#> 1264    Khost          Spira        157  23          0        0
#> 1265    Khost          Spira        157  61          0        1
#> 1266    Khost          Spira        157  39          5        1
#> 1267    Khost          Spira        157  44         12        1
#> 1268    Khost          Spira        157  20          0        1
#> 1269    Khost          Spira        157  30         12        1
#> 1270    Khost          Spira        141  18          7        1
#> 1271    Khost          Spira        141  46          0        1
#> 1272    Khost          Spira        141  30          0        0
#> 1273    Khost          Spira        141  62          0        1
#> 1274    Khost          Spira        141  18         10        0
#> 1275    Khost          Spira        141  60          4        0
#> 1276    Khost          Spira        141  25         10        1
#> 1277    Khost          Spira        141  53          0        1
#> 1278    Khost          Spira        141  58          6        1
#> 1279    Khost          Spira        141  28          0        1
#> 1280    Khost          Spira        141  53          9        1
#> 1281    Khost          Spira        141  48          7        1
#> 1282    Khost          Spira        141  24         12        1
#> 1283    Khost          Spira        141  21         12        1
#> 1284    Khost          Spira        141  55          4        1
#> 1285    Khost          Spira        141  50          0        1
#> 1286    Khost          Spira        141  41          0        1
#> 1287    Khost          Spira        141  23          8        1
#> 1288    Khost          Spira        149  26          0        0
#> 1289    Khost          Spira        149  30          5        0
#> 1290    Khost          Spira        149  50          8        0
#> 1291    Khost          Spira        149  21         12        1
#> 1292    Khost          Spira        149  32         10        1
#> 1293    Khost          Spira        149  18          9        0
#> 1297    Khost          Spira        149  25          8        0
#> 1300    Khost          Spira        149  37          8        1
#> 1303    Khost          Spira        149  30          0        0
#> 1305    Khost          Spira        149  36         12        1
#> 1306    Khost          Spira         58  30          9        1
#> 1307    Khost          Spira         58  55          7        1
#> 1308    Khost          Spira         58  52          5        1
#> 1309    Khost          Spira         58  27          7        0
#> 1310    Khost          Spira         58  30          0        0
#> 1311    Khost          Spira         58  51          6        1
#> 1312    Khost          Spira         58  22          0        1
#> 1313    Khost          Spira         58  21          5        0
#> 1314    Khost          Spira         58  52          4        0
#> 1315    Khost          Spira         58  41         12        0
#> 1316    Khost          Spira         58  20          7        0
#> 1317    Khost          Spira         58  53          8        1
#> 1318    Khost          Spira         58  39          4        0
#> 1319    Khost          Spira         58  36          8        1
#> 1320    Khost          Spira         58  20          5        0
#> 1321    Khost          Spira         58  50          0        1
#> 1322    Khost          Spira         58  49         12        0
#> 1323    Khost          Spira         58  26          9        1
#> 1324    Khost          Spira        186  35          0        0
#> 1325    Khost          Spira        186  25         10        0
#> 1326    Khost          Spira        186  30          5        0
#> 1327    Khost          Spira        186  27         10        1
#> 1328    Khost          Spira        186  70          0        1
#> 1329    Khost          Spira        186  25          5        1
#> 1330    Khost          Spira        186  50          0        0
#> 1331    Khost          Spira        186  60          0        1
#> 1332    Khost          Spira        186  25          2        1
#> 1333    Khost          Spira        186  27          5        1
#> 1334    Khost          Spira        186  45         10        1
#> 1335    Khost          Spira        186  18          0        1
#> 1336    Khost          Spira        186  70          0        0
#> 1337    Khost          Spira        186  42          5        0
#> 1338    Khost          Spira        186  31          0        0
#> 1339    Khost          Spira        186  28          0        1
#> 1340    Khost          Spira        186  41         10        1
#> 1341    Khost          Spira        186  50          5        0
#> 1342    Khost           Tani         73  30         12        1
#> 1343    Khost           Tani         73  23          0        0
#> 1344    Khost           Tani         73  36         11        1
#> 1345    Khost           Tani         73  54         14        0
#> 1346    Khost           Tani         73  20         12        0
#> 1347    Khost           Tani         73  27         10        1
#> 1348    Khost           Tani         73  22         12        0
#> 1349    Khost           Tani         73  23          8        0
#> 1350    Khost           Tani         73  37         14        0
#> 1351    Khost           Tani        125  53         10        0
#> 1352    Khost           Tani        125  37         10        0
#> 1353    Khost           Tani        125  28          0        1
#> 1354    Khost           Tani        125  22         12        0
#> 1355    Khost           Tani        125  40         11        1
#> 1356    Khost           Tani        125  35          0        1
#> 1357    Khost           Tani        125  30         10        1
#> 1358    Khost           Tani        125  18         10        0
#> 1359    Khost           Tani        125  36          7        0
#> 1360    Khost           Tani         77  18         10        0
#> 1361    Khost           Tani         77  31          0        1
#> 1362    Khost           Tani         77  35         13        1
#> 1363    Khost           Tani         77  38         12        1
#> 1364    Khost           Tani         77  28         11        0
#> 1365    Khost           Tani         77  29         10        0
#> 1366    Khost           Tani         77  29          9        1
#> 1367    Khost           Tani         77  25          8        0
#> 1368    Khost           Tani         77  17          9        0
#> 1369    Khost           Tani         37  19         10        0
#> 1370    Khost           Tani         37  35         11        0
#> 1371    Khost           Tani         37  50          0        1
#> 1372    Khost           Tani         37  29          0        1
#> 1373    Khost           Tani         37  27          0        0
#> 1374    Khost           Tani         37  23         11        0
#> 1375    Khost           Tani         37  27         10        1
#> 1376    Khost           Tani         37  47         11        0
#> 1377    Khost           Tani         37  34          0        0
#> 1378    Khost           Tani        117  17         10        0
#> 1379    Khost           Tani        117  19         12        0
#> 1380    Khost           Tani        117  29          6        0
#> 1381    Khost           Tani        117  39          9        1
#> 1382    Khost           Tani        117  40         12        1
#> 1383    Khost           Tani        117  27          0        0
#> 1384    Khost           Tani        117  35          0        1
#> 1385    Khost           Tani        117  50          5        1
#> 1386    Khost           Tani        117  58          0        1
#> 1387    Khost           Tani         55  26         14        1
#> 1388    Khost           Tani         55  30          4        1
#> 1389    Khost           Tani         55  30          0        1
#> 1390    Khost           Tani         55  36          4        0
#> 1391    Khost           Tani         55  62          0        0
#> 1392    Khost           Tani         55  33          0        1
#> 1393    Khost           Tani         55  20          8        1
#> 1394    Khost           Tani         55  19         10        0
#> 1395    Khost           Tani         55  31         12        0
#> 1396    Khost           Tani         59  24         10        1
#> 1397    Khost           Tani         59  31          0        1
#> 1398    Khost           Tani         59  58          0        1
#> 1399    Khost           Tani         59  20         11        0
#> 1400    Khost           Tani         59  30          5        0
#> 1401    Khost           Tani         59  28          0        1
#> 1402    Khost           Tani         59  39          0        1
#> 1403    Khost           Tani         59  17          9        0
#> 1404    Khost           Tani         59  22          0        0
#> 1405    Khost           Tani        198  28          3        0
#> 1406    Khost           Tani        198  20          0        0
#> 1407    Khost           Tani        198  21          0        1
#> 1408    Khost           Tani        198  20          2        1
#> 1409    Khost           Tani        198  28          0        0
#> 1410    Khost           Tani        198  28          0        1
#> 1411    Khost           Tani        198  20          3        1
#> 1412    Khost           Tani        198  21          6        0
#> 1413    Khost           Tani        198  25          0        1
#> 1414    Khost           Tani        198  20          7        0
#> 1415    Khost           Tani        198  25          5        0
#> 1416    Khost           Tani        198  43          2        1
#> 1417    Khost           Tani        198  21          0        0
#> 1418    Khost           Tani        198  19          4        1
#> 1419    Khost           Tani        198  23          6        0
#> 1420    Khost           Tani        198  23          4        1
#> 1421    Khost           Tani        198  20          0        0
#> 1422    Khost           Tani        198  45          8        1
#> 1423    Khost           Tani        109  17          5        0
#> 1424    Khost           Tani        109  35         12        0
#> 1425    Khost           Tani        109  24          0        0
#> 1426    Khost           Tani        109  25          0        0
#> 1427    Khost           Tani        109  25          2        0
#> 1428    Khost           Tani        109  50          0        0
#> 1429    Khost           Tani        109  55          0        0
#> 1430    Khost           Tani        109  24          0        1
#> 1431    Khost           Tani        109  25          7        0
#> 1432    Khost           Tani        109  33          8        0
#> 1433    Khost           Tani        109  28          0        1
#> 1434    Khost           Tani        109  29          4        0
#> 1435    Khost           Tani        109  30          6        0
#> 1436    Khost           Tani        109  35          3        0
#> 1437    Khost           Tani        109  30          0        1
#> 1438    Khost           Tani        109  45          0        0
#> 1439    Khost           Tani        109  50          0        0
#> 1440    Khost           Tani        109  40          0        0
#> 1441    Khost           Tani        142  30          0        0
#> 1442    Khost           Tani        142  35          0        0
#> 1443    Khost           Tani        142  50          2        0
#> 1444    Khost           Tani        142  57         12        1
#> 1445    Khost           Tani        142  26          0        1
#> 1446    Khost           Tani        142  30          0        0
#> 1447    Khost           Tani        142  30          0        0
#> 1448    Khost           Tani        142  30          0        0
#> 1449    Khost           Tani        142  38          0        0
#> 1450    Khost           Tani        142  50          0        1
#> 1451    Khost           Tani        142  25          0        0
#> 1452    Khost           Tani        142  22          5        0
#> 1453    Khost           Tani        142  30          0        0
#> 1454    Khost           Tani        142  48         12        1
#> 1455    Khost           Tani        142  44         12        1
#> 1456    Khost           Tani        142  28          0        1
#> 1457    Khost           Tani        142  18          0        0
#> 1458    Khost           Tani        142  28          9        1
#> 1459    Khost           Tani         21  18          0        0
#> 1460    Khost           Tani         21  18          0        0
#> 1461    Khost           Tani         21  20         10        0
#> 1462    Khost           Tani         21  25          5        0
#> 1463    Khost           Tani         21  40          8        1
#> 1464    Khost           Tani         21  18          0        0
#> 1465    Khost           Tani         21  30          0        0
#> 1466    Khost           Tani         21  20          0        0
#> 1467    Khost           Tani         21  18         10        0
#> 1469    Khost           Tani         21  18          0        0
#> 1470    Khost           Tani         21  35         10        0
#> 1471    Khost           Tani         21  19          0        0
#> 1472    Khost           Tani         21  18          6        0
#> 1473    Khost           Tani         21  30          5        0
#> 1474    Khost           Tani         21  32          8        1
#> 1475    Khost           Tani         21  58          0        0
#> 1476    Khost           Tani         21  16          0        0
#> 1477    Khost           Tani        140  40          0        1
#> 1478    Khost           Tani        140  35          0        1
#> 1479    Khost           Tani        140  31         12        1
#> 1480    Khost           Tani        140  28         11        1
#> 1481    Khost           Tani        140  51          0        1
#> 1482    Khost           Tani        140  30         12        1
#> 1483    Khost           Tani        140  36          0        1
#> 1484    Khost           Tani        140  41          0        0
#> 1485    Khost           Tani        140  33          8        1
#> 1486    Khost           Tani        140  43          0        1
#> 1487    Khost           Tani        140  34          0        1
#> 1488    Khost           Tani        140  38         10        1
#> 1489    Khost           Tani        140  24          9        0
#> 1490    Khost           Tani        140  28          0        1
#> 1491    Khost           Tani        140  53         12        1
#> 1492    Khost           Tani        140  44          6        1
#> 1493    Khost           Tani        140  32          0        1
#> 1494    Khost           Tani        140  49         12        1
#> 1495    Khost           Tani        153  32          8        1
#> 1496    Khost           Tani        153  22          0        1
#> 1497    Khost           Tani        153  36         10        1
#> 1498    Khost           Tani        153  27          0        1
#> 1499    Khost           Tani        153  36          0        1
#> 1500    Khost           Tani        153  21          8        0
#> 1501    Khost           Tani        153  30         10        1
#> 1502    Khost           Tani        153  52         12        1
#> 1503    Khost           Tani        153  45          0        1
#> 1504    Khost           Tani        153  54         10        1
#> 1505    Khost           Tani        153  30          5        0
#> 1506    Khost           Tani        153  36          0        0
#> 1507    Khost           Tani        153  50          7        1
#> 1508    Khost           Tani        153  30          5        1
#> 1509    Khost           Tani        153  16          4        0
#> 1510    Khost           Tani        153  22          6        1
#> 1511    Khost           Tani        153  38         10        1
#> 1513  Helmand        Garmser         15  20          6        0
#> 1521  Helmand        Garmser         15  40          0        1
#> 1522  Helmand        Garmser         19  40          0        1
#> 1523  Helmand        Garmser         19  18          3        0
#> 1524  Helmand        Garmser         19  28          0        1
#> 1525  Helmand        Garmser         19  51          3        0
#> 1526  Helmand        Garmser         19  48          0        1
#> 1527  Helmand        Garmser         19  33          2        1
#> 1528  Helmand        Garmser         19  27          3        1
#> 1529  Helmand        Garmser         19  19          0        0
#> 1530  Helmand        Garmser         19  50          0        1
#> 1531  Helmand        Garmser        161  23          0        1
#> 1532  Helmand        Garmser        161  27          2        1
#> 1533  Helmand        Garmser        161  50          1        0
#> 1534  Helmand        Garmser        161  35          0        1
#> 1535  Helmand        Garmser        161  33          1        1
#> 1536  Helmand        Garmser        161  40          0        1
#> 1537  Helmand        Garmser        161  29          0        1
#> 1538  Helmand        Garmser        161  43          0        1
#> 1539  Helmand        Garmser        161  33          1        1
#> 1540  Helmand        Garmser         16  26          0        1
#> 1542  Helmand        Garmser         16  22          0        0
#> 1543  Helmand        Garmser         16  22          0        1
#> 1544  Helmand        Garmser         16  20          0        1
#> 1545  Helmand        Garmser         16  21          0        1
#> 1546  Helmand        Garmser         16  20          0        1
#> 1547  Helmand        Garmser         16  25          0        1
#> 1548  Helmand        Garmser         16  22          0        1
#> 1550  Helmand        Garmser         18  40          0        1
#> 1551  Helmand        Garmser         18  25          0        0
#> 1552  Helmand        Garmser         18  40          0        1
#> 1553  Helmand        Garmser         18  35          0        1
#> 1555  Helmand        Garmser         18  34          0        0
#> 1556  Helmand        Garmser         18  25          0        1
#> 1558  Helmand        Garmser          2  19          0        0
#> 1559  Helmand        Garmser          2  22          0        0
#> 1560  Helmand        Garmser          2  41          0        1
#> 1561  Helmand        Garmser          2  48          0        1
#> 1562  Helmand        Garmser          2  31          0        1
#> 1563  Helmand        Garmser          2  22          0        1
#> 1564  Helmand        Garmser          2  42          0        1
#> 1566  Helmand        Garmser          2  32          0        1
#> 1567  Helmand        Garmser        173  16          0        0
#> 1570  Helmand        Garmser        173  28          0        1
#> 1571  Helmand        Garmser        173  33          0        1
#> 1572  Helmand        Garmser        173  49          0        1
#> 1573  Helmand        Garmser        173  29          0        1
#> 1574  Helmand        Garmser        173  47          0        1
#> 1577  Helmand        Garmser         39  17          0        0
#> 1578  Helmand        Garmser         39  46          6        1
#> 1579  Helmand        Garmser         39  22          0        1
#> 1580  Helmand        Garmser         39  16          0        0
#> 1581  Helmand        Garmser         39  21          0        1
#> 1582  Helmand        Garmser         39  29          0        1
#> 1583  Helmand        Garmser         39  21          2        0
#> 1584  Helmand        Garmser         39  31          0        0
#> 1586  Helmand        Garmser         39  19          1        0
#> 1587  Helmand        Garmser         39  43          0        1
#> 1588  Helmand        Garmser         39  46          3        1
#> 1590  Helmand        Garmser         39  28          0        1
#> 1594  Helmand        Garmser         53  36          0        1
#> 1595  Helmand        Garmser         53  23          0        0
#> 1596  Helmand        Garmser         53  34          4        1
#> 1597  Helmand        Garmser         53  20          0        1
#> 1599  Helmand        Garmser         53  21          5        1
#> 1600  Helmand        Garmser         53  31          0        1
#> 1602  Helmand        Garmser         53  22          4        1
#> 1604  Helmand        Garmser         53  30          0        1
#> 1605  Helmand        Garmser         53  30          0        1
#> 1606  Helmand        Garmser         53  34          0        1
#> 1607  Helmand        Garmser         53  39          4        1
#> 1609  Helmand        Garmser         53  27          0        1
#> 1610  Helmand        Garmser         53  30          0        1
#> 1611  Helmand        Garmser         53  23          5        0
#> 1612  Helmand        Garmser        155  21          0        1
#> 1613  Helmand        Garmser        155  22          0        1
#> 1614  Helmand        Garmser        155  16          0        0
#> 1615  Helmand        Garmser        155  34          4        1
#> 1616  Helmand        Garmser        155  37          5        1
#> 1617  Helmand        Garmser        155  16          0        0
#> 1618  Helmand        Garmser        155  39          0        1
#> 1619  Helmand        Garmser        155  19          3        1
#> 1620  Helmand        Garmser        155  18          0        0
#> 1621  Helmand        Garmser        155  29          0        1
#> 1622  Helmand        Garmser        155  38          0        1
#> 1623  Helmand        Garmser        155  30          5        1
#> 1624  Helmand        Garmser        155  26          0        1
#> 1625  Helmand        Garmser        155  22          3        1
#> 1626  Helmand        Garmser        155  36          0        1
#> 1627  Helmand        Garmser        155  34          4        1
#> 1628  Helmand        Garmser        155  23          0        1
#> 1629  Helmand        Garmser        155  20          0        1
#> 1635  Helmand        Garmser         14  22          0        1
#> 1637  Helmand        Garmser         14  18          0        1
#> 1643  Helmand        Garmser         14  18          0        0
#> 1645  Helmand        Garmser         14  51          0        0
#> 1648  Helmand        Garmser         83  20          3        0
#> 1650  Helmand        Garmser         83  58          0        0
#> 1651  Helmand        Garmser         83  55          6        0
#> 1653  Helmand        Garmser         83  55          0        0
#> 1654  Helmand        Garmser         83  17          0        0
#> 1655  Helmand        Garmser         83  19          3        1
#> 1657  Helmand        Garmser         83  45          9        1
#> 1662  Helmand        Garmser         83  44          0        1
#> 1665  Helmand        Garmser         83  19          0        1
#> 1666  Helmand        Garmser         13  31          0        1
#> 1667  Helmand        Garmser         13  19          0        0
#> 1668  Helmand        Garmser         13  23          0        0
#> 1669  Helmand        Garmser         13  18          0        0
#> 1670  Helmand        Garmser         13  32          0        1
#> 1671  Helmand        Garmser         13  34          6        1
#> 1673  Helmand        Garmser         13  18          0        0
#> 1674  Helmand        Garmser         13  34          0        1
#> 1675  Helmand        Garmser         13  22          0        1
#> 1676  Helmand        Garmser         13  17          0        0
#> 1677  Helmand        Garmser         13  37          5        1
#> 1678  Helmand        Garmser         13  39          6        1
#> 1679  Helmand        Garmser         13  34          0        1
#> 1681  Helmand        Garmser         13  16          0        0
#> 1682  Helmand        Garmser         13  25          0        1
#> 1683  Helmand        Garmser         13  18          0        0
#> 1684  Helmand        Garmser         17  25          0        1
#> 1685  Helmand        Garmser         17  26          0        1
#> 1686  Helmand        Garmser         17  30          0        0
#> 1687  Helmand        Garmser         17  26          0        1
#> 1688  Helmand        Garmser         17  25          2        0
#> 1689  Helmand        Garmser         17  21          0        0
#> 1690  Helmand        Garmser         17  47          8        1
#> 1691  Helmand        Garmser         17  21          0        1
#> 1694  Helmand        Garmser         17  41          0        1
#> 1695  Helmand        Garmser         17  28          2        1
#> 1696  Helmand        Garmser         17  38          0        1
#> 1698  Helmand        Garmser         17  36          0        1
#> 1700  Helmand        Garmser         17  29          0        1
#> 1701  Helmand        Garmser         17  43          5        0
#> 1702  Helmand        Garmser        200  20          0        1
#> 1703  Helmand        Garmser        200  20          0        1
#> 1704  Helmand        Garmser        200  50          0        0
#> 1705  Helmand        Garmser        200  25          0        1
#> 1706  Helmand        Garmser        200  39          0        1
#> 1707  Helmand        Garmser        200  49          0        1
#> 1708  Helmand        Garmser        200  40          0        0
#> 1709  Helmand        Garmser        200  27          0        1
#> 1710  Helmand        Garmser        200  28          0        1
#> 1711  Helmand        Garmser        200  18          2        0
#> 1712  Helmand        Garmser        200  20          0        1
#> 1714  Helmand        Garmser        200  52          0        0
#> 1715  Helmand        Garmser        200  25          0        1
#> 1718  Helmand        Garmser        200  45          0        1
#> 1720  Helmand        Garmser         81  23          0        1
#> 1721  Helmand        Garmser         81  20          0        1
#> 1722  Helmand        Garmser         81  34          0        1
#> 1724  Helmand        Garmser         81  38          0        1
#> 1725  Helmand        Garmser         81  22          6        1
#> 1726  Helmand        Garmser         81  31          5        1
#> 1727  Helmand        Garmser         81  35          0        1
#> 1728  Helmand        Garmser         81  17          0        0
#> 1730  Helmand        Garmser         81  18          0        1
#> 1731  Helmand        Garmser         81  41          6        1
#> 1734  Helmand        Garmser         81  37          0        1
#> 1735  Helmand        Garmser         81  40          5        1
#> 1737  Helmand        Garmser         81  20          0        1
#> 1738  Helmand    Lashkar Gah          8  22         12        1
#> 1739  Helmand    Lashkar Gah          8  33          0        1
#> 1740  Helmand    Lashkar Gah          8  35         14        1
#> 1741  Helmand    Lashkar Gah          8  44          0        1
#> 1742  Helmand    Lashkar Gah          8  31          9        1
#> 1743  Helmand    Lashkar Gah          8  25         12        1
#> 1744  Helmand    Lashkar Gah          8  50          0        1
#> 1745  Helmand    Lashkar Gah          8  32         14        1
#> 1746  Helmand    Lashkar Gah          8  20          0        1
#> 1747  Helmand    Lashkar Gah         89  47          0        1
#> 1748  Helmand    Lashkar Gah         89  48          8        1
#> 1749  Helmand    Lashkar Gah         89  26          0        1
#> 1750  Helmand    Lashkar Gah         89  29          5        1
#> 1751  Helmand    Lashkar Gah         89  23          0        0
#> 1752  Helmand    Lashkar Gah         89  42          0        1
#> 1753  Helmand    Lashkar Gah         89  54         12        1
#> 1754  Helmand    Lashkar Gah         89  26          0        1
#> 1755  Helmand    Lashkar Gah         89  25          0        1
#> 1756  Helmand    Lashkar Gah         56  21          0        1
#> 1757  Helmand    Lashkar Gah         56  27         15        1
#> 1758  Helmand    Lashkar Gah         56  48          8        1
#> 1759  Helmand    Lashkar Gah         56  36          0        1
#> 1760  Helmand    Lashkar Gah         56  34          9        1
#> 1761  Helmand    Lashkar Gah         56  48          0        1
#> 1762  Helmand    Lashkar Gah         56  46          0        1
#> 1763  Helmand    Lashkar Gah         56  20          0        0
#> 1764  Helmand    Lashkar Gah         56  50          0        1
#> 1765  Helmand    Lashkar Gah         10  49          6        1
#> 1766  Helmand    Lashkar Gah         10  23         10        1
#> 1767  Helmand    Lashkar Gah         10  22          0        1
#> 1768  Helmand    Lashkar Gah         10  31          8        1
#> 1769  Helmand    Lashkar Gah         10  29          0        1
#> 1770  Helmand    Lashkar Gah         10  31          3        1
#> 1771  Helmand    Lashkar Gah         10  29         12        1
#> 1772  Helmand    Lashkar Gah         10  30          3        1
#> 1773  Helmand    Lashkar Gah         10  29          0        1
#> 1774  Helmand    Lashkar Gah         95  27          0        1
#> 1775  Helmand    Lashkar Gah         95  21          0        1
#> 1776  Helmand    Lashkar Gah         95  27         10        1
#> 1777  Helmand    Lashkar Gah         95  33          7        1
#> 1778  Helmand    Lashkar Gah         95  43          0        1
#> 1779  Helmand    Lashkar Gah         95  20          0        1
#> 1780  Helmand    Lashkar Gah         95  40          0        1
#> 1781  Helmand    Lashkar Gah         95  22          0        1
#> 1782  Helmand    Lashkar Gah         95  33          0        1
#> 1783  Helmand    Lashkar Gah         95  30          0        1
#> 1784  Helmand    Lashkar Gah         95  43          9        1
#> 1785  Helmand    Lashkar Gah         95  23          0        1
#> 1786  Helmand    Lashkar Gah         95  20          0        1
#> 1787  Helmand    Lashkar Gah         95  35          0        1
#> 1788  Helmand    Lashkar Gah         95  30          0        1
#> 1789  Helmand    Lashkar Gah         95  43          0        1
#> 1790  Helmand    Lashkar Gah         95  37          0        1
#> 1791  Helmand    Lashkar Gah         95  30          0        1
#> 1792  Helmand    Lashkar Gah         27  48          8        1
#> 1793  Helmand    Lashkar Gah         27  50          0        1
#> 1794  Helmand    Lashkar Gah         27  20          0        0
#> 1795  Helmand    Lashkar Gah         27  30         12        1
#> 1796  Helmand    Lashkar Gah         27  50          0        1
#> 1797  Helmand    Lashkar Gah         27  22          5        1
#> 1798  Helmand    Lashkar Gah         27  51         14        1
#> 1799  Helmand    Lashkar Gah         27  24          0        1
#> 1800  Helmand    Lashkar Gah         27  30          0        1
#> 1801  Helmand    Lashkar Gah         27  25         10        1
#> 1802  Helmand    Lashkar Gah         27  29          0        0
#> 1803  Helmand    Lashkar Gah         27  26          8        1
#> 1804  Helmand    Lashkar Gah         27  27         12        1
#> 1805  Helmand    Lashkar Gah         27  25          8        1
#> 1806  Helmand    Lashkar Gah         27  25          9        1
#> 1807  Helmand    Lashkar Gah         27  40         12        1
#> 1808  Helmand    Lashkar Gah         27  28          0        1
#> 1809  Helmand    Lashkar Gah         27  20          0        1
#> 1810  Helmand    Lashkar Gah        201  26          8        0
#> 1811  Helmand    Lashkar Gah        201  36         14        1
#> 1812  Helmand    Lashkar Gah        201  20         10        1
#> 1813  Helmand    Lashkar Gah        201  46         14        1
#> 1814  Helmand    Lashkar Gah        201  29         12        1
#> 1815  Helmand    Lashkar Gah        201  42          0        1
#> 1816  Helmand    Lashkar Gah        201  28         10        0
#> 1817  Helmand    Lashkar Gah        201  41          0        1
#> 1818  Helmand    Lashkar Gah        201  25          0        1
#> 1819  Helmand    Lashkar Gah        201  29          0        1
#> 1820  Helmand    Lashkar Gah        201  41         12        1
#> 1821  Helmand    Lashkar Gah        201  27          0        1
#> 1822  Helmand    Lashkar Gah        201  26         10        1
#> 1823  Helmand    Lashkar Gah        201  18          6        0
#> 1824  Helmand    Lashkar Gah        201  28         12        1
#> 1825  Helmand    Lashkar Gah        201  25          0        0
#> 1826  Helmand    Lashkar Gah        201  28          0        1
#> 1827  Helmand    Lashkar Gah        201  28          0        1
#> 1828  Helmand    Lashkar Gah         51  30          0        0
#> 1829  Helmand    Lashkar Gah         51  20         10        0
#> 1830  Helmand    Lashkar Gah         51  28         14        1
#> 1831  Helmand    Lashkar Gah         51  18          8        0
#> 1832  Helmand    Lashkar Gah         51  40         12        1
#> 1833  Helmand    Lashkar Gah         51  29         12        0
#> 1834  Helmand    Lashkar Gah         51  25         12        0
#> 1835  Helmand    Lashkar Gah         51  20          9        0
#> 1836  Helmand    Lashkar Gah         51  18         10        0
#> 1837  Helmand    Lashkar Gah         51  45          0        0
#> 1838  Helmand    Lashkar Gah         51  30          0        1
#> 1839  Helmand    Lashkar Gah         51  18          0        0
#> 1840  Helmand    Lashkar Gah         51  52          0        1
#> 1841  Helmand    Lashkar Gah         51  70          0        1
#> 1842  Helmand    Lashkar Gah         51  55          0        1
#> 1843  Helmand    Lashkar Gah         51  60         10        0
#> 1844  Helmand    Lashkar Gah         51  50          0        1
#> 1845  Helmand    Lashkar Gah         51  25          0        1
#> 1846  Helmand      Musa Qala        203  22          0        0
#> 1847  Helmand      Musa Qala        203  20          0        0
#> 1848  Helmand      Musa Qala        203  22          5        0
#> 1849  Helmand      Musa Qala        203  16          0        0
#> 1850  Helmand      Musa Qala        203  25         10        0
#> 1851  Helmand      Musa Qala        203  35          8        0
#> 1852  Helmand      Musa Qala        203  22          0        0
#> 1853  Helmand      Musa Qala        203  26          0        1
#> 1854  Helmand      Musa Qala        203  40          0        0
#> 1855  Helmand      Musa Qala        183  39          0        0
#> 1856  Helmand      Musa Qala        183  19          0        0
#> 1857  Helmand      Musa Qala        183  46          0        0
#> 1858  Helmand      Musa Qala        183  43          0        1
#> 1859  Helmand      Musa Qala        183  18          0        0
#> 1860  Helmand      Musa Qala        183  21          0        0
#> 1861  Helmand      Musa Qala        183  38          0        0
#> 1862  Helmand      Musa Qala        183  19          0        0
#> 1863  Helmand      Musa Qala        183  17          0        0
#> 1864  Helmand      Musa Qala         31  26          0        1
#> 1865  Helmand      Musa Qala         31  25          0        1
#> 1866  Helmand      Musa Qala         31  25          0        1
#> 1867  Helmand      Musa Qala         31  30          0        1
#> 1868  Helmand      Musa Qala         31  20          0        0
#> 1869  Helmand      Musa Qala         31  20          0        0
#> 1870  Helmand      Musa Qala         31  21          0        1
#> 1871  Helmand      Musa Qala         31  17          0        0
#> 1872  Helmand      Musa Qala         31  30          0        0
#> 1873  Helmand      Musa Qala        148  21          0        1
#> 1874  Helmand      Musa Qala        148  40          0        1
#> 1875  Helmand      Musa Qala        148  31          5        1
#> 1876  Helmand      Musa Qala        148  21          5        1
#> 1877  Helmand      Musa Qala        148  29          0        1
#> 1878  Helmand      Musa Qala        148  27          9        1
#> 1879  Helmand      Musa Qala        148  19          0        1
#> 1880  Helmand      Musa Qala        148  20          5        1
#> 1881  Helmand      Musa Qala        148  40          0        1
#> 1882  Helmand      Musa Qala        148  22          0        1
#> 1883  Helmand      Musa Qala        148  17          5        1
#> 1884  Helmand      Musa Qala        148  59          0        0
#> 1885  Helmand      Musa Qala        148  27          6        1
#> 1886  Helmand      Musa Qala        148  35         12        1
#> 1887  Helmand      Musa Qala        148  25          0        1
#> 1888  Helmand      Musa Qala        148  51          6        1
#> 1889  Helmand      Musa Qala        148  19          0        1
#> 1890  Helmand      Musa Qala        148  47          0        1
#> 1891  Helmand      Musa Qala        119  52          0        1
#> 1892  Helmand      Musa Qala        119  32          0        1
#> 1893  Helmand      Musa Qala        119  29          0        1
#> 1894  Helmand      Musa Qala        119  50          0        1
#> 1895  Helmand      Musa Qala        119  32          0        1
#> 1896  Helmand      Musa Qala        119  30          0        1
#> 1897  Helmand      Musa Qala        119  65          0        0
#> 1898  Helmand      Musa Qala        119  22          0        0
#> 1899  Helmand      Musa Qala        119  25          0        1
#> 1900  Helmand      Musa Qala        119  16          0        0
#> 1901  Helmand      Musa Qala        119  70          0        1
#> 1902  Helmand      Musa Qala        119  35          0        0
#> 1903  Helmand      Musa Qala        119  41          0        0
#> 1904  Helmand      Musa Qala        119  60          0        1
#> 1905  Helmand      Musa Qala        119  30          0        1
#> 1906  Helmand      Musa Qala        119  25          0        1
#> 1907  Helmand      Musa Qala        119  27          0        1
#> 1908  Helmand      Musa Qala        119  52          0        1
#> 1910  Helmand      Musa Qala         60  33          6        1
#> 1912  Helmand      Musa Qala         60  35          0        1
#> 1913  Helmand      Musa Qala         60  18          0        0
#> 1914  Helmand      Musa Qala         60  23          6        1
#> 1915  Helmand      Musa Qala         60  30          3        1
#> 1916  Helmand      Musa Qala         60  39          7        1
#> 1917  Helmand      Musa Qala         60  17          0        0
#> 1919  Helmand      Musa Qala         60  17          0        0
#> 1920  Helmand      Musa Qala         60  21          4        1
#> 1922  Helmand      Musa Qala         60  41          5        1
#> 1923  Helmand      Musa Qala         60  16          0        0
#> 1925  Helmand      Musa Qala         60  53          0        1
#> 1926  Helmand      Musa Qala         60  29          0        1
#> 1927  Helmand      Musa Qala        135  18          0        1
#> 1928  Helmand      Musa Qala        135  39          0        1
#> 1929  Helmand      Musa Qala        135  18          0        0
#> 1930  Helmand      Musa Qala        135  32          0        1
#> 1931  Helmand      Musa Qala        135  42          0        1
#> 1932  Helmand      Musa Qala        135  34          5        1
#> 1933  Helmand      Musa Qala        135  19          0        0
#> 1934  Helmand      Musa Qala        135  32          0        1
#> 1935  Helmand      Musa Qala        135  33          3        1
#> 1936  Helmand      Musa Qala        135  17          0        0
#> 1937  Helmand      Musa Qala        135  19          0        1
#> 1938  Helmand      Musa Qala        135  32          6        1
#> 1939  Helmand      Musa Qala        135  18          0        0
#> 1940  Helmand      Musa Qala        135  34          0        1
#> 1941  Helmand      Musa Qala        135  40          0        1
#> 1942  Helmand      Musa Qala        135  24          4        1
#> 1943  Helmand      Musa Qala        135  21          0        1
#> 1944  Helmand      Musa Qala        135  35         12        1
#> 1945  Helmand      Musa Qala         64  22          0        1
#> 1946  Helmand      Musa Qala         64  25          4        1
#> 1947  Helmand      Musa Qala         64  20          0        0
#> 1948  Helmand      Musa Qala         64  23          0        1
#> 1949  Helmand      Musa Qala         64  34          0        1
#> 1950  Helmand      Musa Qala         64  24          0        1
#> 1951  Helmand      Musa Qala         64  21          0        0
#> 1952  Helmand      Musa Qala         64  20          0        1
#> 1953  Helmand      Musa Qala         64  20          0        0
#> 1954  Helmand      Musa Qala         64  29          5        1
#> 1955  Helmand      Musa Qala         64  18          0        0
#> 1956  Helmand      Musa Qala         64  18          3        0
#> 1957  Helmand      Musa Qala         64  38          0        1
#> 1958  Helmand      Musa Qala         64  32          0        1
#> 1959  Helmand      Musa Qala         64  30          2        1
#> 1960  Helmand      Musa Qala         64  18          0        0
#> 1961  Helmand      Musa Qala         64  19          0        1
#> 1962  Helmand      Musa Qala         64  33          0        1
#> 1965  Helmand      Musa Qala        171  21          0        0
#> 1970  Helmand      Musa Qala        171  30          2        1
#> 1972  Helmand      Musa Qala        171  35          3        1
#> 1974  Helmand      Musa Qala        171  16          0        0
#> 1975  Helmand      Musa Qala        171  47          5        1
#> 1980  Helmand      Musa Qala        171  40         12        1
#> 1981  Helmand      Musa Qala        129  25          0        1
#> 1982  Helmand      Musa Qala        129  29          5        1
#> 1983  Helmand      Musa Qala        129  31          0        1
#> 1984  Helmand      Musa Qala        129  42          5        1
#> 1985  Helmand      Musa Qala        129  20          0        0
#> 1986  Helmand      Musa Qala        129  29          8        1
#> 1987  Helmand      Musa Qala        129  29          0        1
#> 1988  Helmand      Musa Qala        129  28          5        1
#> 1989  Helmand      Musa Qala        129  22          0        1
#> 1990  Helmand      Musa Qala        129  29          0        1
#> 1991  Helmand      Musa Qala        129  50          0        1
#> 1992  Helmand      Musa Qala        129  41         10        1
#> 1993  Helmand      Musa Qala        129  28          0        1
#> 1994  Helmand      Musa Qala        129  41          0        1
#> 1995  Helmand      Musa Qala        129  28          8        1
#> 1996  Helmand      Musa Qala        129  51          0        1
#> 1997  Helmand      Musa Qala        129  22          0        0
#> 1998  Helmand      Musa Qala        129  40          8        1
#> 1999  Helmand      Musa Qala          6  20          0        0
#> 2000  Helmand      Musa Qala          6  35          0        1
#> 2001  Helmand      Musa Qala          6  30          0        1
#> 2002  Helmand      Musa Qala          6  22          8        1
#> 2003  Helmand      Musa Qala          6  20          0        0
#> 2004  Helmand      Musa Qala          6  20          3        0
#> 2005  Helmand      Musa Qala          6  30          0        0
#> 2006  Helmand      Musa Qala          6  35          0        1
#> 2007  Helmand      Musa Qala          6  35          0        1
#> 2008  Helmand      Musa Qala          6  35          0        0
#> 2009  Helmand      Musa Qala          6  18          0        0
#> 2010  Helmand      Musa Qala          6  20          0        1
#> 2011  Helmand      Musa Qala          6  26          5        1
#> 2012  Helmand      Musa Qala          6  36          8        1
#> 2013  Helmand      Musa Qala          6  25          8        1
#> 2014  Helmand      Musa Qala          6  40          8        1
#> 2015  Helmand      Musa Qala          6  23         10        1
#> 2016  Helmand      Musa Qala          6  25          0        1
#> 2017  Helmand      Musa Qala        184  31          0        1
#> 2018  Helmand      Musa Qala        184  22          5        1
#> 2019  Helmand      Musa Qala        184  25          0        1
#> 2020  Helmand      Musa Qala        184  50          0        1
#> 2021  Helmand      Musa Qala        184  20          6        1
#> 2022  Helmand      Musa Qala        184  20          0        0
#> 2023  Helmand      Musa Qala        184  42          0        1
#> 2024  Helmand      Musa Qala        184  28          5        1
#> 2025  Helmand      Musa Qala        184  25          0        1
#> 2026  Helmand      Musa Qala        184  50          0        1
#> 2027  Helmand      Musa Qala        184  40          0        1
#> 2028  Helmand      Musa Qala        184  28          5        1
#> 2029  Helmand      Musa Qala        184  21          0        0
#> 2030  Helmand      Musa Qala        184  46          5        1
#> 2031  Helmand      Musa Qala        184  20          0        1
#> 2032  Helmand      Musa Qala        184  41          0        1
#> 2033  Helmand      Musa Qala        184  45          0        1
#> 2034  Helmand      Musa Qala        184  50          0        1
#> 2035  Helmand      Musa Qala         65  22          0        1
#> 2036  Helmand      Musa Qala         65  26          0        1
#> 2037  Helmand      Musa Qala         65  57          9        1
#> 2038  Helmand      Musa Qala         65  44          6        1
#> 2039  Helmand      Musa Qala         65  29          0        1
#> 2040  Helmand      Musa Qala         65  38          0        1
#> 2041  Helmand      Musa Qala         65  35          0        1
#> 2042  Helmand      Musa Qala         65  33          6        1
#> 2043  Helmand      Musa Qala         65  35         12        1
#> 2044  Helmand      Musa Qala         65  41          0        1
#> 2045  Helmand      Musa Qala         65  29          0        1
#> 2046  Helmand      Musa Qala         65  22          0        1
#> 2047  Helmand      Musa Qala         65  39          0        0
#> 2048  Helmand      Musa Qala         65  41          0        1
#> 2049  Helmand      Musa Qala         65  17          0        1
#> 2050  Helmand      Musa Qala         65  27          8        1
#> 2051  Helmand      Musa Qala         65  57          6        0
#> 2052  Helmand      Musa Qala         65  44          0        1
#> 2053  Helmand      Musa Qala        143  41          0        1
#> 2054  Helmand      Musa Qala        143  39         12        0
#> 2055  Helmand      Musa Qala        143  41          0        1
#> 2056  Helmand      Musa Qala        143  27          8        1
#> 2057  Helmand      Musa Qala        143  41          8        1
#> 2058  Helmand      Musa Qala        143  27          0        1
#> 2059  Helmand      Musa Qala        143  38          0        1
#> 2060  Helmand      Musa Qala        143  38          0        1
#> 2061  Helmand      Musa Qala        143  32          9        1
#> 2062  Helmand      Musa Qala        143  48          9        1
#> 2063  Helmand      Musa Qala        143  32          0        1
#> 2064  Helmand      Musa Qala        143  52         12        1
#> 2065  Helmand      Musa Qala        143  41          9        1
#> 2066  Helmand      Musa Qala        143  30          0        1
#> 2067  Helmand      Musa Qala        143  55         12        0
#> 2068  Helmand      Musa Qala        143  19          0        1
#> 2069  Helmand      Musa Qala        143  27          0        1
#> 2070  Helmand      Musa Qala        143  44          9        1
#> 2072  Helmand        Naw Zad        147  19          7        1
#> 2073  Helmand        Naw Zad        147  19          8        0
#> 2074  Helmand        Naw Zad        147  19          0        1
#> 2075  Helmand        Naw Zad        147  35          0        1
#> 2076  Helmand        Naw Zad        147  20          4        0
#> 2077  Helmand        Naw Zad        147  21          0        0
#> 2078  Helmand        Naw Zad        147  22          6        1
#> 2079  Helmand        Naw Zad        147  21          5        1
#> 2081  Helmand        Naw Zad         33  23          0        1
#> 2082  Helmand        Naw Zad         33  27          0        0
#> 2083  Helmand        Naw Zad         33  21          0        1
#> 2084  Helmand        Naw Zad         33  30          0        1
#> 2085  Helmand        Naw Zad         33  21          0        1
#> 2086  Helmand        Naw Zad         33  29          0        1
#> 2087  Helmand        Naw Zad         33  31          0        0
#> 2088  Helmand        Naw Zad         33  22          0        1
#> 2089  Helmand        Naw Zad         62  22          0        0
#> 2090  Helmand        Naw Zad         62  17          0        0
#> 2091  Helmand        Naw Zad         62  29          0        1
#> 2092  Helmand        Naw Zad         62  33          0        1
#> 2093  Helmand        Naw Zad         62  25          0        0
#> 2094  Helmand        Naw Zad         62  30          0        0
#> 2095  Helmand        Naw Zad         62  23          0        1
#> 2096  Helmand        Naw Zad         62  20          0        0
#> 2097  Helmand        Naw Zad         62  45          0        0
#> 2098  Helmand        Naw Zad        124  16          0        0
#> 2099  Helmand        Naw Zad        124  20          0        1
#> 2100  Helmand        Naw Zad        124  26          0        1
#> 2101  Helmand        Naw Zad        124  42          0        1
#> 2102  Helmand        Naw Zad        124  22          0        1
#> 2103  Helmand        Naw Zad        124  20          0        0
#> 2104  Helmand        Naw Zad        124  16          0        0
#> 2106  Helmand        Naw Zad        124  33          0        0
#> 2107  Helmand        Naw Zad         76  25          0        1
#> 2108  Helmand        Naw Zad         76  19          4        0
#> 2109  Helmand        Naw Zad         76  19          0        1
#> 2110  Helmand        Naw Zad         76  20          0        0
#> 2111  Helmand        Naw Zad         76  45          0        0
#> 2112  Helmand        Naw Zad         76  22          0        0
#> 2113  Helmand        Naw Zad         76  32          0        1
#> 2114  Helmand        Naw Zad         76  18          0        0
#> 2115  Helmand        Naw Zad         76  44          0        1
#> 2116  Helmand        Naw Zad        128  22          0        1
#> 2117  Helmand        Naw Zad        128  49          0        1
#> 2118  Helmand        Naw Zad        128  33          0        1
#> 2119  Helmand        Naw Zad        128  25          0        1
#> 2120  Helmand        Naw Zad        128  25          0        0
#> 2121  Helmand        Naw Zad        128  46          0        0
#> 2122  Helmand        Naw Zad        128  35          0        1
#> 2123  Helmand        Naw Zad        128  22          0        1
#> 2124  Helmand        Naw Zad        128  43          0        0
#> 2125  Helmand        Naw Zad        168  19          0        0
#> 2126  Helmand        Naw Zad        168  19          0        0
#> 2127  Helmand        Naw Zad        168  19          0        0
#> 2128  Helmand        Naw Zad        168  26          0        0
#> 2129  Helmand        Naw Zad        168  19          0        1
#> 2130  Helmand        Naw Zad        168  19          0        1
#> 2131  Helmand        Naw Zad        168  43          0        1
#> 2132  Helmand        Naw Zad        168  18          0        1
#> 2133  Helmand        Naw Zad        168  22          0        1
#> 2134  Helmand        Naw Zad        194  26          0        0
#> 2135  Helmand        Naw Zad        194  40          0        1
#> 2136  Helmand        Naw Zad        194  30          0        0
#> 2137  Helmand        Naw Zad        194  27          0        0
#> 2138  Helmand        Naw Zad        194  30          0        1
#> 2139  Helmand        Naw Zad        194  28          0        0
#> 2140  Helmand        Naw Zad        194  35          0        1
#> 2141  Helmand        Naw Zad        194  23          0        1
#> 2142  Helmand        Naw Zad        194  30          0        1
#> 2143  Helmand        Naw Zad          4  19          0        0
#> 2144  Helmand        Naw Zad          4  35          0        0
#> 2145  Helmand        Naw Zad          4  46          0        0
#> 2146  Helmand        Naw Zad          4  19          0        1
#> 2147  Helmand        Naw Zad          4  38          0        0
#> 2148  Helmand        Naw Zad          4  22          0        1
#> 2149  Helmand        Naw Zad          4  17          0        0
#> 2150  Helmand        Naw Zad          4  21          0        0
#> 2151  Helmand        Naw Zad          4  42          0        0
#> 2152  Helmand        Naw Zad          4  21          0        1
#> 2153  Helmand        Naw Zad          4  18          0        0
#> 2154  Helmand        Naw Zad          4  38          0        0
#> 2155  Helmand        Naw Zad          4  33          0        0
#> 2156  Helmand        Naw Zad          4  16          0        0
#> 2157  Helmand        Naw Zad          4  34          0        0
#> 2158  Helmand        Naw Zad          4  22          0        0
#> 2159  Helmand        Naw Zad          4  22          0        0
#> 2160  Helmand        Naw Zad          4  32          0        0
#> 2161  Helmand        Naw Zad        191  45          0        1
#> 2162  Helmand        Naw Zad        191  22          0        0
#> 2163  Helmand        Naw Zad        191  19          0        1
#> 2164  Helmand        Naw Zad        191  44          0        1
#> 2165  Helmand        Naw Zad        191  22          0        1
#> 2166  Helmand        Naw Zad        191  18          0        1
#> 2167  Helmand        Naw Zad        191  19          0        1
#> 2168  Helmand        Naw Zad        191  16          0        0
#> 2170  Helmand        Naw Zad        191  33          0        1
#> 2171  Helmand        Naw Zad        191  52          0        0
#> 2172  Helmand        Naw Zad        191  23          0        0
#> 2173  Helmand        Naw Zad        191  21          0        1
#> 2175  Helmand        Naw Zad        191  25          0        0
#> 2176  Helmand        Naw Zad        191  22          0        1
#> 2177  Helmand        Naw Zad        191  22          0        0
#> 2179  Helmand        Naw Zad        197  29          0        1
#> 2180  Helmand        Naw Zad        197  36          6        1
#> 2181  Helmand        Naw Zad        197  22          3        1
#> 2182  Helmand        Naw Zad        197  42          0        1
#> 2183  Helmand        Naw Zad        197  31          5        1
#> 2184  Helmand        Naw Zad        197  22          0        0
#> 2185  Helmand        Naw Zad        197  20          6        1
#> 2186  Helmand        Naw Zad        197  31          0        1
#> 2187  Helmand        Naw Zad        197  26          0        1
#> 2188  Helmand        Naw Zad        197  60          0        0
#> 2189  Helmand        Naw Zad        197  40          0        1
#> 2190  Helmand        Naw Zad        197  24          8        1
#> 2191  Helmand        Naw Zad        197  25          8        1
#> 2192  Helmand        Naw Zad        197  60          0        0
#> 2193  Helmand        Naw Zad        197  20          0        0
#> 2194  Helmand        Naw Zad        197  24          6        1
#> 2195  Helmand        Naw Zad        197  32          0        1
#> 2196  Helmand        Naw Zad        197  22          6        1
#> 2197  Helmand        Naw Zad         32  20          0        1
#> 2198  Helmand        Naw Zad         32  21          0        1
#> 2200  Helmand        Naw Zad         32  28          0        1
#> 2201  Helmand        Naw Zad         32  46          0        1
#> 2202  Helmand        Naw Zad         32  24          0        1
#> 2203  Helmand        Naw Zad         32  18          0        1
#> 2204  Helmand        Naw Zad         32  48          0        1
#> 2207  Helmand        Naw Zad         32  29          0        1
#> 2208  Helmand        Naw Zad         32  22          0        1
#> 2211  Helmand        Naw Zad         32  44          0        0
#> 2212  Helmand        Naw Zad         32  20          0        1
#> 2214  Helmand        Naw Zad         32  38          0        1
#> 2215  Helmand        Naw Zad         23  38          0        0
#> 2216  Helmand        Naw Zad         23  40          3        0
#> 2217  Helmand        Naw Zad         23  60          0        0
#> 2218  Helmand        Naw Zad         23  35          0        0
#> 2219  Helmand        Naw Zad         23  25          2        0
#> 2220  Helmand        Naw Zad         23  20          0        0
#> 2221  Helmand        Naw Zad         23  60          0        0
#> 2222  Helmand        Naw Zad         23  25          0        0
#> 2223  Helmand        Naw Zad         23  27          0        0
#> 2224  Helmand        Naw Zad         23  54          3        0
#> 2225  Helmand        Naw Zad         23  31          3        0
#> 2226  Helmand        Naw Zad         23  28          0        0
#> 2227  Helmand        Naw Zad         23  21          0        0
#> 2228  Helmand        Naw Zad         23  42          0        0
#> 2229  Helmand        Naw Zad         23  30          0        0
#> 2230  Helmand        Naw Zad         23  25          3        0
#> 2231  Helmand        Naw Zad         23  70          0        0
#> 2232  Helmand        Naw Zad         23  48          2        0
#> 2233  Helmand        Naw Zad         96  28          0        1
#> 2235  Helmand        Naw Zad         96  30          0        0
#> 2236  Helmand        Naw Zad         96  20          0        0
#> 2237  Helmand        Naw Zad         96  28          0        0
#> 2238  Helmand        Naw Zad         96  38          0        0
#> 2240  Helmand        Naw Zad         96  42          0        0
#> 2242  Helmand        Naw Zad         96  35          0        0
#> 2243  Helmand        Naw Zad         96  25          0        0
#> 2244  Helmand        Naw Zad         96  50          0        0
#> 2245  Helmand        Naw Zad         96  42          0        0
#> 2246  Helmand        Naw Zad         96  30          0        0
#> 2248  Helmand        Naw Zad         96  25          0        0
#> 2249  Helmand        Naw Zad         96  28          0        0
#> 2250  Helmand        Naw Zad         96  30          0        0
#> 2251  Helmand        Naw Zad        159  60          0        1
#> 2252  Helmand        Naw Zad        159  26          2        0
#> 2253  Helmand        Naw Zad        159  18          0        1
#> 2254  Helmand        Naw Zad        159  50          4        0
#> 2255  Helmand        Naw Zad        159  30          1        1
#> 2256  Helmand        Naw Zad        159  40          0        0
#> 2257  Helmand        Naw Zad        159  20          0        0
#> 2258  Helmand        Naw Zad        159  30          0        1
#> 2259  Helmand        Naw Zad        159  20          0        0
#> 2260  Helmand        Naw Zad        159  18          0        0
#> 2261  Helmand        Naw Zad        159  60          0        0
#> 2262  Helmand        Naw Zad        159  25          0        0
#> 2263  Helmand        Naw Zad        159  18          0        0
#> 2264  Helmand        Naw Zad        159  50          0        0
#> 2265  Helmand        Naw Zad        159  50          0        0
#> 2266  Helmand        Naw Zad        159  20          0        0
#> 2267  Helmand        Naw Zad        159  44          0        0
#> 2268  Helmand        Naw Zad        159  66          0        0
#> 2269  Helmand        Naw Zad        108  25          0        1
#> 2270  Helmand        Naw Zad        108  44          0        1
#> 2271  Helmand        Naw Zad        108  47          0        1
#> 2272  Helmand        Naw Zad        108  31          0        1
#> 2274  Helmand        Naw Zad        108  16          0        0
#> 2276  Helmand        Naw Zad        108  32          0        1
#> 2277  Helmand        Naw Zad        108  31          2        1
#> 2278  Helmand        Naw Zad        108  16          0        0
#> 2279  Helmand        Naw Zad        108  18          5        1
#> 2282  Helmand        Naw Zad        108  40          1        1
#> 2283  Helmand        Naw Zad        108  38          0        1
#> 2284  Helmand        Naw Zad        108  46          0        1
#> 2285  Helmand        Naw Zad        108  44          0        1
#> 2286  Helmand        Naw Zad        108  21          0        1
#> 2287  Helmand         Washer         84  21          0        0
#> 2288  Helmand         Washer         84  28          0        1
#> 2289  Helmand         Washer         84  31          0        1
#> 2291  Helmand         Washer         84  23          0        1
#> 2292  Helmand         Washer         84  33          0        1
#> 2294  Helmand         Washer         84  39         10        1
#> 2295  Helmand         Washer         84  35          8        1
#> 2296  Helmand         Washer         38  20          0        1
#> 2297  Helmand         Washer         38  30          0        0
#> 2298  Helmand         Washer         38  39          0        1
#> 2299  Helmand         Washer         38  32          0        1
#> 2300  Helmand         Washer         38  30          0        0
#> 2301  Helmand         Washer         38  42          0        0
#> 2302  Helmand         Washer         38  33          0        0
#> 2303  Helmand         Washer         38  26          0        0
#> 2304  Helmand         Washer         38  27          0        0
#> 2305  Helmand         Washer        185  50         12        1
#> 2306  Helmand         Washer        185  22          0        1
#> 2307  Helmand         Washer        185  33         12        1
#> 2308  Helmand         Washer        185  50          1        0
#> 2309  Helmand         Washer        185  20          0        0
#> 2310  Helmand         Washer        185  18          0        1
#> 2311  Helmand         Washer        185  58          3        0
#> 2312  Helmand         Washer        185  33          3        1
#> 2313  Helmand         Washer        185  50         11        1
#> 2314  Helmand         Washer        151  19          0        0
#> 2315  Helmand         Washer        151  23          0        0
#> 2316  Helmand         Washer        151  23          0        1
#> 2317  Helmand         Washer        151  24          0        0
#> 2318  Helmand         Washer        151  35          0        1
#> 2319  Helmand         Washer        151  25          0        1
#> 2320  Helmand         Washer        151  22          0        0
#> 2321  Helmand         Washer        151  46          0        1
#> 2322  Helmand         Washer        151  35          0        1
#> 2323  Helmand         Washer        177  23          0        1
#> 2324  Helmand         Washer        177  25          0        0
#> 2325  Helmand         Washer        177  30          0        0
#> 2326  Helmand         Washer        177  24          0        1
#> 2327  Helmand         Washer        177  25          0        1
#> 2328  Helmand         Washer        177  33          0        1
#> 2329  Helmand         Washer        177  22          0        0
#> 2330  Helmand         Washer        177  32          0        0
#> 2331  Helmand         Washer        177  18          0        0
#> 2332  Helmand         Washer          9  20          0        0
#> 2333  Helmand         Washer          9  26          2        1
#> 2342  Helmand         Washer          9  24          0        0
#> 2344  Helmand         Washer          9  41          0        1
#> 2348  Helmand         Washer          9  18          0        1
#> 2352  Helmand         Washer         57  23          0        1
#> 2354  Helmand         Washer         57  37          3        1
#> 2357  Helmand         Washer         57  38          5        1
#> 2359  Helmand         Washer         57  21          0        1
#> 2361  Helmand         Washer         57  26          0        1
#> 2365  Helmand         Washer         57  49          0        1
#> 2367  Helmand         Washer         57  22          0        1
#> 2368  Uruzgan       Dihrawud        105  35          0        0
#> 2369  Uruzgan       Dihrawud        105  28          0        0
#> 2370  Uruzgan       Dihrawud        105  45          0        0
#> 2371  Uruzgan       Dihrawud        105  39          0        0
#> 2372  Uruzgan       Dihrawud        105  38          0        0
#> 2373  Uruzgan       Dihrawud        105  42          0        0
#> 2374  Uruzgan       Dihrawud        105  25          0        0
#> 2375  Uruzgan       Dihrawud        105  31          0        1
#> 2376  Uruzgan       Dihrawud        105  35          0        1
#> 2377  Uruzgan       Dihrawud        123  33          0        1
#> 2378  Uruzgan       Dihrawud        123  29          0        1
#> 2379  Uruzgan       Dihrawud        123  24          0        1
#> 2380  Uruzgan       Dihrawud        123  18          0        0
#> 2381  Uruzgan       Dihrawud        123  28          2        1
#> 2382  Uruzgan       Dihrawud        123  29          0        1
#> 2383  Uruzgan       Dihrawud        123  22          0        1
#> 2384  Uruzgan       Dihrawud        123  32          0        1
#> 2385  Uruzgan       Dihrawud        123  19          0        0
#> 2386  Uruzgan       Dihrawud        178  35          0        1
#> 2387  Uruzgan       Dihrawud        178  23          0        1
#> 2388  Uruzgan       Dihrawud        178  23          0        1
#> 2389  Uruzgan       Dihrawud        178  36          0        1
#> 2390  Uruzgan       Dihrawud        178  52          0        1
#> 2391  Uruzgan       Dihrawud        178  22          0        1
#> 2392  Uruzgan       Dihrawud        178  36          0        1
#> 2393  Uruzgan       Dihrawud        178  19          2        0
#> 2394  Uruzgan       Dihrawud        178  25          0        1
#> 2395  Uruzgan       Dihrawud        133  31          0        0
#> 2396  Uruzgan       Dihrawud        133  37          0        0
#> 2397  Uruzgan       Dihrawud        133  40          0        0
#> 2398  Uruzgan       Dihrawud        133  42          0        0
#> 2399  Uruzgan       Dihrawud        133  30          0        0
#> 2400  Uruzgan       Dihrawud        133  38          0        0
#> 2401  Uruzgan       Dihrawud        133  27          0        0
#> 2402  Uruzgan       Dihrawud        133  43          0        0
#> 2403  Uruzgan       Dihrawud        133  37          0        0
#> 2404  Uruzgan       Dihrawud        152  39          0        1
#> 2405  Uruzgan       Dihrawud        152  19          0        0
#> 2406  Uruzgan       Dihrawud        152  31          3        1
#> 2407  Uruzgan       Dihrawud        152  39          0        1
#> 2408  Uruzgan       Dihrawud        152  45          0        1
#> 2409  Uruzgan       Dihrawud        152  29          2        0
#> 2410  Uruzgan       Dihrawud        152  21          0        1
#> 2411  Uruzgan       Dihrawud        152  21          0        0
#> 2412  Uruzgan       Dihrawud        152  46          0        1
#> 2413  Uruzgan       Dihrawud        199  51         12        1
#> 2414  Uruzgan       Dihrawud        199  59          3        1
#> 2415  Uruzgan       Dihrawud        199  51          5        1
#> 2416  Uruzgan       Dihrawud        199  19          0        0
#> 2417  Uruzgan       Dihrawud        199  23          5        1
#> 2418  Uruzgan       Dihrawud        199  21          0        1
#> 2419  Uruzgan       Dihrawud        199  44          0        1
#> 2420  Uruzgan       Dihrawud        199  51          0        0
#> 2421  Uruzgan       Dihrawud        199  33          0        0
#> 2422  Uruzgan       Dihrawud        199  26          0        0
#> 2423  Uruzgan       Dihrawud        199  31          0        0
#> 2424  Uruzgan       Dihrawud        199  51          0        0
#> 2426  Uruzgan       Dihrawud        199  34          8        1
#> 2427  Uruzgan       Dihrawud        199  32          2        0
#> 2428  Uruzgan       Dihrawud        199  41          0        0
#> 2429  Uruzgan       Dihrawud        199  65          0        0
#> 2430  Uruzgan       Dihrawud        199  37          4        1
#> 2431  Uruzgan       Dihrawud        150  32          0        1
#> 2434  Uruzgan       Dihrawud        150  25          0        1
#> 2435  Uruzgan       Dihrawud        150  31          0        1
#> 2436  Uruzgan       Dihrawud        150  30          1        1
#> 2437  Uruzgan       Dihrawud        150  37          2        1
#> 2438  Uruzgan       Dihrawud        150  30          1        1
#> 2439  Uruzgan       Dihrawud        150  39          1        1
#> 2441  Uruzgan       Dihrawud        150  32          1        1
#> 2442  Uruzgan       Dihrawud        150  30          1        1
#> 2443  Uruzgan       Dihrawud        150  31          1        1
#> 2444  Uruzgan       Dihrawud        150  33          2        1
#> 2445  Uruzgan       Dihrawud        150  31          0        1
#> 2446  Uruzgan       Dihrawud        150  30          1        1
#> 2449  Uruzgan       Dihrawud        116  29          0        1
#> 2450  Uruzgan       Dihrawud        116  41          0        1
#> 2451  Uruzgan       Dihrawud        116  22          0        1
#> 2452  Uruzgan       Dihrawud        116  41          0        1
#> 2453  Uruzgan       Dihrawud        116  38          0        1
#> 2454  Uruzgan       Dihrawud        116  46          0        1
#> 2455  Uruzgan       Dihrawud        116  41          0        1
#> 2456  Uruzgan       Dihrawud        116  21          0        0
#> 2457  Uruzgan       Dihrawud        116  33          0        0
#> 2458  Uruzgan       Dihrawud        116  34          0        1
#> 2459  Uruzgan       Dihrawud        116  32          3        1
#> 2460  Uruzgan       Dihrawud        116  39          0        0
#> 2461  Uruzgan       Dihrawud        116  28          4        0
#> 2463  Uruzgan       Dihrawud        116  21          0        0
#> 2464  Uruzgan       Dihrawud        116  37          0        1
#> 2465  Uruzgan       Dihrawud        116  36          0        1
#> 2466  Uruzgan       Dihrawud        116  32          0        0
#> 2467  Uruzgan       Dihrawud        145  26          0        0
#> 2468  Uruzgan       Dihrawud        145  25          0        1
#> 2469  Uruzgan       Dihrawud        145  34          4        1
#> 2470  Uruzgan       Dihrawud        145  18          0        0
#> 2471  Uruzgan       Dihrawud        145  31          0        1
#> 2472  Uruzgan       Dihrawud        145  39          0        0
#> 2473  Uruzgan       Dihrawud        145  18          0        1
#> 2474  Uruzgan       Dihrawud        145  35          0        1
#> 2475  Uruzgan       Dihrawud        145  32          3        1
#> 2476  Uruzgan       Dihrawud        145  24          0        1
#> 2477  Uruzgan       Dihrawud        145  32          0        1
#> 2478  Uruzgan       Dihrawud        145  40          4        0
#> 2479  Uruzgan       Dihrawud        145  35          0        1
#> 2480  Uruzgan       Dihrawud        145  31          0        1
#> 2481  Uruzgan       Dihrawud        145  18          0        0
#> 2482  Uruzgan       Dihrawud        145  29          0        0
#> 2483  Uruzgan       Dihrawud        145  29          0        0
#> 2484  Uruzgan       Dihrawud        145  24          5        1
#> 2485  Uruzgan   Khas Uruzgan         70  20          0        0
#> 2486  Uruzgan   Khas Uruzgan         70  20          0        0
#> 2487  Uruzgan   Khas Uruzgan         70  30          8        0
#> 2488  Uruzgan   Khas Uruzgan         70  30          0        1
#> 2489  Uruzgan   Khas Uruzgan         70  24          0        0
#> 2490  Uruzgan   Khas Uruzgan         70  39          0        0
#> 2494  Uruzgan   Khas Uruzgan        175  30          1        1
#> 2498  Uruzgan   Khas Uruzgan        175  30          1        1
#> 2499  Uruzgan   Khas Uruzgan        175  28          0        1
#> 2502  Uruzgan   Khas Uruzgan        175  30          1        0
#> 2503  Uruzgan   Khas Uruzgan        188  31          0        0
#> 2504  Uruzgan   Khas Uruzgan        188  32          0        0
#> 2505  Uruzgan   Khas Uruzgan        188  41          0        0
#> 2506  Uruzgan   Khas Uruzgan        188  34          0        1
#> 2507  Uruzgan   Khas Uruzgan        188  34          0        1
#> 2508  Uruzgan   Khas Uruzgan        188  21          0        0
#> 2509  Uruzgan   Khas Uruzgan        188  22          0        0
#> 2510  Uruzgan   Khas Uruzgan        188  32          0        1
#> 2511  Uruzgan   Khas Uruzgan        188  31          0        1
#> 2512  Uruzgan   Khas Uruzgan        144  49          2        1
#> 2513  Uruzgan   Khas Uruzgan        144  25          0        0
#> 2515  Uruzgan   Khas Uruzgan        144  41          0        0
#> 2517  Uruzgan   Khas Uruzgan        144  51          0        1
#> 2519  Uruzgan   Khas Uruzgan        144  25          0        0
#> 2520  Uruzgan   Khas Uruzgan        144  30          0        1
#> 2521  Uruzgan   Khas Uruzgan        167  44          0        0
#> 2522  Uruzgan   Khas Uruzgan        167  22          0        0
#> 2524  Uruzgan   Khas Uruzgan        167  50          0        1
#> 2525  Uruzgan   Khas Uruzgan        167  33          0        1
#> 2526  Uruzgan   Khas Uruzgan        167  52          0        1
#> 2527  Uruzgan   Khas Uruzgan        167  25          0        0
#> 2529  Uruzgan   Khas Uruzgan        167  22          0        0
#> 2530  Uruzgan   Khas Uruzgan         91  26          0        0
#> 2531  Uruzgan   Khas Uruzgan         91  36          0        1
#> 2532  Uruzgan   Khas Uruzgan         91  39          0        0
#> 2533  Uruzgan   Khas Uruzgan         91  40          0        0
#> 2534  Uruzgan   Khas Uruzgan         91  18          0        0
#> 2535  Uruzgan   Khas Uruzgan         91  39          0        0
#> 2536  Uruzgan   Khas Uruzgan         91  25          0        0
#> 2537  Uruzgan   Khas Uruzgan         91  31          0        0
#> 2538  Uruzgan   Khas Uruzgan         91  36          0        1
#> 2539  Uruzgan   Khas Uruzgan         91  46          7        0
#> 2540  Uruzgan   Khas Uruzgan         91  29          6        1
#> 2541  Uruzgan   Khas Uruzgan         91  36          0        0
#> 2542  Uruzgan   Khas Uruzgan         91  28          0        0
#> 2543  Uruzgan   Khas Uruzgan         91  18          0        0
#> 2544  Uruzgan   Khas Uruzgan         91  34          0        1
#> 2545  Uruzgan   Khas Uruzgan         91  32          0        1
#> 2546  Uruzgan   Khas Uruzgan         91  30          5        0
#> 2547  Uruzgan   Khas Uruzgan         91  29          0        1
#> 2548  Uruzgan   Khas Uruzgan         44  38          0        0
#> 2549  Uruzgan   Khas Uruzgan         44  50          0        0
#> 2550  Uruzgan   Khas Uruzgan         44  36          0        0
#> 2551  Uruzgan   Khas Uruzgan         44  18          0        1
#> 2552  Uruzgan   Khas Uruzgan         44  24          0        0
#> 2553  Uruzgan   Khas Uruzgan         44  32          0        0
#> 2554  Uruzgan   Khas Uruzgan         44  35          0        1
#> 2555  Uruzgan   Khas Uruzgan         44  18          8        0
#> 2556  Uruzgan   Khas Uruzgan         44  29          0        0
#> 2557  Uruzgan   Khas Uruzgan         44  31          0        1
#> 2558  Uruzgan   Khas Uruzgan         44  40         10        0
#> 2559  Uruzgan   Khas Uruzgan         44  29         12        1
#> 2560  Uruzgan   Khas Uruzgan         44  18          0        0
#> 2561  Uruzgan   Khas Uruzgan         44  29          8        0
#> 2562  Uruzgan   Khas Uruzgan         44  36          0        0
#> 2563  Uruzgan   Khas Uruzgan         44  20          0        1
#> 2564  Uruzgan   Khas Uruzgan         44  30          0        1
#> 2565  Uruzgan   Khas Uruzgan         44  25          0        1
#> 2566  Uruzgan   Khas Uruzgan         63  20          2        0
#> 2567  Uruzgan   Khas Uruzgan         63  19          1        0
#> 2568  Uruzgan   Khas Uruzgan         63  22          1        0
#> 2569  Uruzgan   Khas Uruzgan         63  20          2        0
#> 2570  Uruzgan   Khas Uruzgan         63  22          0        0
#> 2571  Uruzgan   Khas Uruzgan         63  25          0        0
#> 2572  Uruzgan   Khas Uruzgan         63  25          3        1
#> 2573  Uruzgan   Khas Uruzgan         63  22          1        0
#> 2576  Uruzgan   Khas Uruzgan         63  19          2        0
#> 2577  Uruzgan   Khas Uruzgan         63  30          5        0
#> 2578  Uruzgan   Khas Uruzgan         63  22          3        0
#> 2579  Uruzgan   Khas Uruzgan         63  33          0        0
#> 2580  Uruzgan   Khas Uruzgan         63  25          6        0
#> 2581  Uruzgan   Khas Uruzgan         63  30          9        0
#> 2582  Uruzgan   Khas Uruzgan         63  19          2        0
#> 2583  Uruzgan   Khas Uruzgan         63  23          9        0
#> 2585  Uruzgan   Khas Uruzgan        158  35          5        0
#> 2586  Uruzgan   Khas Uruzgan        158  24          2        0
#> 2587  Uruzgan   Khas Uruzgan        158  25          0        0
#> 2589  Uruzgan   Khas Uruzgan        158  32          0        0
#> 2591  Uruzgan   Khas Uruzgan        158  55          0        0
#> 2593  Uruzgan   Khas Uruzgan        158  32          0        0
#> 2594  Uruzgan   Khas Uruzgan        158  52          0        0
#> 2595  Uruzgan   Khas Uruzgan        158  19          4        0
#> 2597  Uruzgan   Khas Uruzgan        158  24          0        0
#> 2599  Uruzgan   Khas Uruzgan        158  51          0        1
#> 2600  Uruzgan   Khas Uruzgan        158  25          0        0
#> 2601  Uruzgan   Khas Uruzgan        158  20          0        0
#> 2602  Uruzgan Shahidi Hassas        114  35          5        1
#> 2603  Uruzgan Shahidi Hassas        114  41          0        0
#> 2604  Uruzgan Shahidi Hassas        114  30          8        1
#> 2605  Uruzgan Shahidi Hassas        114  28          0        0
#> 2606  Uruzgan Shahidi Hassas        114  38          5        1
#> 2607  Uruzgan Shahidi Hassas        114  29          0        0
#> 2608  Uruzgan Shahidi Hassas        114  41          3        0
#> 2609  Uruzgan Shahidi Hassas        114  47          0        0
#> 2610  Uruzgan Shahidi Hassas        114  38          5        1
#> 2611  Uruzgan Shahidi Hassas        118  49          7        1
#> 2612  Uruzgan Shahidi Hassas        118  26          6        1
#> 2613  Uruzgan Shahidi Hassas        118  23          0        1
#> 2614  Uruzgan Shahidi Hassas        118  21          0        0
#> 2615  Uruzgan Shahidi Hassas        118  33          0        0
#> 2616  Uruzgan Shahidi Hassas        118  55         12        1
#> 2617  Uruzgan Shahidi Hassas        118  62         12        1
#> 2618  Uruzgan Shahidi Hassas        118  50          0        1
#> 2619  Uruzgan Shahidi Hassas        118  40          5        1
#> 2620  Uruzgan Shahidi Hassas         22  20          0        0
#> 2621  Uruzgan Shahidi Hassas         22  31          0        0
#> 2622  Uruzgan Shahidi Hassas         22  52         12        1
#> 2623  Uruzgan Shahidi Hassas         22  52         12        1
#> 2624  Uruzgan Shahidi Hassas         22  19          0        0
#> 2625  Uruzgan Shahidi Hassas         22  30          0        1
#> 2626  Uruzgan Shahidi Hassas         22  61          5        1
#> 2628  Uruzgan Shahidi Hassas         22  23          5        1
#> 2629  Uruzgan Shahidi Hassas        190  32          2        1
#> 2630  Uruzgan Shahidi Hassas        190  30          2        1
#> 2631  Uruzgan Shahidi Hassas        190  39          1        0
#> 2632  Uruzgan Shahidi Hassas        190  22          0        1
#> 2633  Uruzgan Shahidi Hassas        190  38          3        1
#> 2634  Uruzgan Shahidi Hassas        190  29          0        0
#> 2635  Uruzgan Shahidi Hassas        190  25          1        1
#> 2636  Uruzgan Shahidi Hassas        190  29          1        1
#> 2637  Uruzgan Shahidi Hassas        190  31          3        1
#> 2638  Uruzgan Shahidi Hassas        190  39          2        1
#> 2639  Uruzgan Shahidi Hassas        190  30          2        1
#> 2640  Uruzgan Shahidi Hassas        190  29          1        1
#> 2641  Uruzgan Shahidi Hassas        190  41          2        0
#> 2642  Uruzgan Shahidi Hassas        190  32          2        0
#> 2643  Uruzgan Shahidi Hassas        190  33          5        1
#> 2644  Uruzgan Shahidi Hassas        190  29          0        1
#> 2645  Uruzgan Shahidi Hassas        190  30          2        1
#> 2647  Uruzgan Shahidi Hassas         74  36          0        1
#> 2648  Uruzgan Shahidi Hassas         74  21          0        0
#> 2649  Uruzgan Shahidi Hassas         74  36          0        0
#> 2650  Uruzgan Shahidi Hassas         74  29          0        0
#> 2651  Uruzgan Shahidi Hassas         74  39          0        1
#> 2652  Uruzgan Shahidi Hassas         74  32          0        1
#> 2653  Uruzgan Shahidi Hassas         74  26          0        1
#> 2654  Uruzgan Shahidi Hassas         74  31          0        1
#> 2656  Uruzgan Shahidi Hassas         74  32          0        1
#> 2657  Uruzgan Shahidi Hassas         74  39          0        1
#> 2658  Uruzgan Shahidi Hassas         74  22          4        0
#> 2659  Uruzgan Shahidi Hassas         74  45          0        1
#> 2660  Uruzgan Shahidi Hassas         74  47          0        0
#> 2661  Uruzgan Shahidi Hassas         74  21          0        0
#> 2662  Uruzgan Shahidi Hassas         74  36          0        1
#> 2663  Uruzgan Shahidi Hassas         74  31          0        1
#> 2664  Uruzgan Shahidi Hassas         74  33          0        1
#> 2665  Uruzgan Shahidi Hassas        169  39          0        0
#> 2666  Uruzgan Shahidi Hassas        169  26          0        0
#> 2667  Uruzgan Shahidi Hassas        169  31          3        0
#> 2668  Uruzgan Shahidi Hassas        169  37          0        1
#> 2669  Uruzgan Shahidi Hassas        169  19          0        0
#> 2670  Uruzgan Shahidi Hassas        169  22          0        0
#> 2671  Uruzgan Shahidi Hassas        169  41          0        1
#> 2672  Uruzgan Shahidi Hassas        169  31          0        1
#> 2673  Uruzgan Shahidi Hassas        169  33          0        1
#> 2674  Uruzgan Shahidi Hassas        169  31          0        1
#> 2675  Uruzgan Shahidi Hassas        169  36          0        0
#> 2676  Uruzgan Shahidi Hassas        169  19          0        0
#> 2677  Uruzgan Shahidi Hassas        169  20          0        0
#> 2678  Uruzgan Shahidi Hassas        169  24          0        1
#> 2680  Uruzgan Shahidi Hassas        169  26          0        0
#> 2681  Uruzgan Shahidi Hassas        169  34          0        1
#> 2682  Uruzgan Shahidi Hassas        169  32          0        1
#> 2683  Uruzgan Shahidi Hassas        131  28          0        0
#> 2684  Uruzgan Shahidi Hassas        131  34          0        1
#> 2685  Uruzgan Shahidi Hassas        131  36          3        1
#> 2686  Uruzgan Shahidi Hassas        131  26          0        0
#> 2687  Uruzgan Shahidi Hassas        131  29          0        1
#> 2688  Uruzgan Shahidi Hassas        131  31          0        0
#> 2689  Uruzgan Shahidi Hassas        131  36          0        1
#> 2690  Uruzgan Shahidi Hassas        131  42          0        1
#> 2691  Uruzgan Shahidi Hassas        131  43          0        1
#> 2692  Uruzgan Shahidi Hassas        131  33          0        1
#> 2693  Uruzgan Shahidi Hassas        131  36          0        1
#> 2694  Uruzgan Shahidi Hassas        131  41          0        1
#> 2695  Uruzgan Shahidi Hassas        131  26          0        0
#> 2696  Uruzgan Shahidi Hassas        131  21          0        0
#> 2697  Uruzgan Shahidi Hassas        131  43          0        0
#> 2698  Uruzgan Shahidi Hassas        131  31          0        0
#> 2699  Uruzgan Shahidi Hassas        131  39          0        1
#> 2700  Uruzgan Shahidi Hassas        131  35          0        1
#> 2701  Uruzgan Shahidi Hassas        139  29          2        1
#> 2702  Uruzgan Shahidi Hassas        139  38          1        1
#> 2703  Uruzgan Shahidi Hassas        139  30          0        0
#> 2704  Uruzgan Shahidi Hassas        139  30          1        1
#> 2705  Uruzgan Shahidi Hassas        139  29          0        1
#> 2706  Uruzgan Shahidi Hassas        139  28          0        1
#> 2707  Uruzgan Shahidi Hassas        139  21          0        1
#> 2708  Uruzgan Shahidi Hassas        139  33          1        1
#> 2709  Uruzgan Shahidi Hassas        139  30          1        1
#> 2710  Uruzgan Shahidi Hassas        139  22          0        1
#> 2711  Uruzgan Shahidi Hassas        139  32          0        0
#> 2713  Uruzgan Shahidi Hassas        139  30          0        1
#> 2714  Uruzgan Shahidi Hassas        139  32          1        1
#> 2715  Uruzgan Shahidi Hassas        139  30          0        1
#> 2716  Uruzgan Shahidi Hassas        139  25          0        0
#> 2717  Uruzgan Shahidi Hassas        139  30          1        0
#> 2718  Uruzgan Shahidi Hassas        139  30          1        1
#> 2719  Uruzgan Shahidi Hassas         40  30          5        1
#> 2720  Uruzgan Shahidi Hassas         40  40          0        0
#> 2721  Uruzgan Shahidi Hassas         40  80          0        1
#> 2722  Uruzgan Shahidi Hassas         40  20          0        0
#> 2723  Uruzgan Shahidi Hassas         40  33          0        0
#> 2724  Uruzgan Shahidi Hassas         40  22          0        0
#> 2725  Uruzgan Shahidi Hassas         40  20          0        0
#> 2726  Uruzgan Shahidi Hassas         40  50          0        0
#> 2727  Uruzgan Shahidi Hassas         40  23          5        0
#> 2728  Uruzgan Shahidi Hassas         40  43          0        0
#> 2729  Uruzgan Shahidi Hassas         40  27          0        0
#> 2730  Uruzgan Shahidi Hassas         40  28          0        0
#> 2731  Uruzgan Shahidi Hassas         40  20          0        0
#> 2732  Uruzgan Shahidi Hassas         40  23          0        0
#> 2734  Uruzgan Shahidi Hassas         40  25          3        0
#> 2735  Uruzgan Shahidi Hassas         40  20          3        1
#> 2736  Uruzgan Shahidi Hassas         40  30          3        0
#> 2737  Uruzgan Shahidi Hassas         28  30          0        1
#> 2738  Uruzgan Shahidi Hassas         28  32          0        1
#> 2739  Uruzgan Shahidi Hassas         28  25          0        0
#> 2740  Uruzgan Shahidi Hassas         28  24          0        0
#> 2741  Uruzgan Shahidi Hassas         28  19          0        0
#> 2742  Uruzgan Shahidi Hassas         28  39          0        0
#> 2743  Uruzgan Shahidi Hassas         28  25          0        1
#> 2744  Uruzgan Shahidi Hassas         28  27          0        0
#> 2745  Uruzgan Shahidi Hassas         28  31          0        1
#> 2746  Uruzgan Shahidi Hassas         28  25          0        1
#> 2747  Uruzgan Shahidi Hassas         28  36          0        1
#> 2748  Uruzgan Shahidi Hassas         28  28          0        0
#> 2749  Uruzgan Shahidi Hassas         28  28          0        1
#> 2750  Uruzgan Shahidi Hassas         28  30          0        0
#> 2751  Uruzgan Shahidi Hassas         28  19          0        1
#> 2752  Uruzgan Shahidi Hassas         28  25          5        1
#> 2753  Uruzgan Shahidi Hassas         28  32          0        1
#> 2754  Uruzgan Shahidi Hassas         28  18          0        0
#>               income violent.exp.ISAF violent.exp.taliban list.group
#> 1       2,001-10,000                0                   0    control
#> 2       2,001-10,000                0                   0    control
#> 3       2,001-10,000                1                   0    control
#> 4       2,001-10,000                0                   0       ISAF
#> 5       2,001-10,000                0                   0       ISAF
#> 7      10,001-20,000                0                   0    taliban
#> 8       2,001-10,000                0                   1    taliban
#> 9       2,001-10,000                0                   0    taliban
#> 11     10,001-20,000                1                   0    control
#> 12      2,001-10,000                0                   0    control
#> 13      2,001-10,000                0                   0       ISAF
#> 14      2,001-10,000                0                   0       ISAF
#> 15      2,001-10,000                0                   0       ISAF
#> 16      2,001-10,000                0                   0    taliban
#> 17      2,001-10,000                0                   0    taliban
#> 18      2,001-10,000                0                   0    taliban
#> 19      2,001-10,000                0                   0    control
#> 20      2,001-10,000                0                   1    control
#> 21     10,001-20,000                0                   0    control
#> 22      2,001-10,000                0                   0       ISAF
#> 23   less than 2,000                0                   1       ISAF
#> 24   less than 2,000                1                   1       ISAF
#> 25      2,001-10,000                0                   0    taliban
#> 26      2,001-10,000                1                   0    taliban
#> 27      2,001-10,000                1                   1    taliban
#> 28      2,001-10,000                0                   1    control
#> 29      2,001-10,000                0                   0    control
#> 30      2,001-10,000                1                   0    control
#> 31      2,001-10,000                0                   0       ISAF
#> 32      2,001-10,000                0                   0       ISAF
#> 33      2,001-10,000                1                   0       ISAF
#> 34      2,001-10,000                0                   0    taliban
#> 35      2,001-10,000                1                   0    taliban
#> 36      2,001-10,000                0                   0    taliban
#> 37      2,001-10,000                0                   0    control
#> 38      2,001-10,000                0                   0    control
#> 39     10,001-20,000                0                   0    control
#> 40      2,001-10,000                0                   0       ISAF
#> 41      2,001-10,000                0                   0       ISAF
#> 42     10,001-20,000                0                   0       ISAF
#> 43      2,001-10,000                0                   0    taliban
#> 44      2,001-10,000                0                   0    taliban
#> 45      2,001-10,000                0                   0    taliban
#> 46   less than 2,000                0                   0    control
#> 47      2,001-10,000                1                   0    control
#> 48      2,001-10,000                0                   0    control
#> 50      2,001-10,000                0                   0       ISAF
#> 51      2,001-10,000                0                   0       ISAF
#> 52     10,001-20,000                0                   0    taliban
#> 53     10,001-20,000                0                   0    taliban
#> 54      2,001-10,000                0                   0    taliban
#> 55      2,001-10,000                0                   0    control
#> 56      2,001-10,000                0                   0    control
#> 57      2,001-10,000                0                   0    control
#> 58      2,001-10,000                0                   0       ISAF
#> 59      2,001-10,000                0                   0       ISAF
#> 60      2,001-10,000                0                   0       ISAF
#> 61     10,001-20,000                0                   0    taliban
#> 62     10,001-20,000                0                   0    taliban
#> 63   less than 2,000                1                   0    taliban
#> 64      2,001-10,000                0                   0    control
#> 65   less than 2,000                0                   1    control
#> 66      2,001-10,000                0                   0    control
#> 67   less than 2,000                1                   0       ISAF
#> 68      2,001-10,000                0                   0       ISAF
#> 69      2,001-10,000                0                   0       ISAF
#> 70      2,001-10,000                1                   0    taliban
#> 71      2,001-10,000                0                   0    taliban
#> 72   less than 2,000                0                   0    taliban
#> 73      2,001-10,000                0                   0    control
#> 74      2,001-10,000                0                   0    control
#> 75   less than 2,000                0                   0    control
#> 76      2,001-10,000                0                   0       ISAF
#> 77   less than 2,000                1                   0       ISAF
#> 78      2,001-10,000                1                   0       ISAF
#> 79      2,001-10,000                0                   0    taliban
#> 80      2,001-10,000                0                   0    taliban
#> 81   less than 2,000                0                   0    taliban
#> 82      2,001-10,000                0                   0    control
#> 84      2,001-10,000                0                   0    control
#> 85      2,001-10,000                0                   0       ISAF
#> 86      2,001-10,000                0                   0       ISAF
#> 87   less than 2,000                1                   0       ISAF
#> 88   less than 2,000                0                   0    taliban
#> 89     10,001-20,000                1                   0    taliban
#> 90      2,001-10,000                0                   0    taliban
#> 91      2,001-10,000                0                   0    control
#> 92     10,001-20,000                1                   0    control
#> 93      2,001-10,000                0                   0    control
#> 94     10,001-20,000                1                   0    control
#> 95      2,001-10,000                0                   0    control
#> 96     10,001-20,000                1                   0    control
#> 97   less than 2,000                0                   0       ISAF
#> 98      2,001-10,000                0                   0       ISAF
#> 99      2,001-10,000                0                   1       ISAF
#> 100  less than 2,000                0                   0       ISAF
#> 101    10,001-20,000                0                   0       ISAF
#> 102     2,001-10,000                0                   0       ISAF
#> 103     2,001-10,000                0                   0    taliban
#> 104     2,001-10,000                0                   0    taliban
#> 105     2,001-10,000                0                   0    taliban
#> 106    10,001-20,000                0                   0    taliban
#> 107     2,001-10,000                0                   0    taliban
#> 108  less than 2,000                0                   0    taliban
#> 109     2,001-10,000                0                   0    control
#> 110     2,001-10,000                0                   1    control
#> 111    10,001-20,000                0                   1    control
#> 112  less than 2,000                1                   0    control
#> 113    10,001-20,000                1                   0    control
#> 114     2,001-10,000                1                   0    control
#> 115     2,001-10,000                1                   0       ISAF
#> 116    10,001-20,000                0                   0       ISAF
#> 117     2,001-10,000                1                   0       ISAF
#> 118     2,001-10,000                1                   0       ISAF
#> 120     2,001-10,000                0                   0       ISAF
#> 121    10,001-20,000                1                   0    taliban
#> 122    10,001-20,000                0                   1    taliban
#> 123    10,001-20,000                1                   0    taliban
#> 124     2,001-10,000                1                   1    taliban
#> 125    10,001-20,000                0                   1    taliban
#> 126    10,001-20,000                1                   0    taliban
#> 127  less than 2,000                0                   0    control
#> 128     2,001-10,000                0                   0    control
#> 129     2,001-10,000                0                   1    control
#> 130     2,001-10,000                1                   0    control
#> 131    10,001-20,000                0                   0    control
#> 132    10,001-20,000                1                   0    control
#> 133     2,001-10,000                0                   0       ISAF
#> 134    10,001-20,000                0                   0       ISAF
#> 135     2,001-10,000                0                   0       ISAF
#> 136     2,001-10,000                0                   0       ISAF
#> 137     2,001-10,000                0                   0       ISAF
#> 138     2,001-10,000                0                   0       ISAF
#> 139    10,001-20,000                0                   0    taliban
#> 140     2,001-10,000                0                   1    taliban
#> 141     2,001-10,000                0                   1    taliban
#> 142    10,001-20,000                0                   0    taliban
#> 143     2,001-10,000                1                   1    taliban
#> 144     2,001-10,000                1                   1    taliban
#> 145     2,001-10,000                0                   1    control
#> 146  less than 2,000                0                   0    control
#> 147     2,001-10,000                0                   0    control
#> 148    10,001-20,000                0                   1    control
#> 149     2,001-10,000                0                   1    control
#> 150     2,001-10,000                1                   1    control
#> 151     2,001-10,000                0                   0       ISAF
#> 152    10,001-20,000                0                   0       ISAF
#> 153    10,001-20,000                0                   0       ISAF
#> 154     2,001-10,000                1                   0       ISAF
#> 155     2,001-10,000                0                   0       ISAF
#> 156    10,001-20,000                0                   0       ISAF
#> 157     2,001-10,000                1                   0    taliban
#> 158     2,001-10,000                1                   0    taliban
#> 159     2,001-10,000                1                   0    taliban
#> 160     2,001-10,000                1                   0    taliban
#> 161     2,001-10,000                0                   0    taliban
#> 162     2,001-10,000                0                   0    taliban
#> 163     2,001-10,000                0                   0    control
#> 164  less than 2,000                1                   0    control
#> 165     2,001-10,000                0                   0    control
#> 166     2,001-10,000                0                   0    control
#> 167  less than 2,000                0                   0    control
#> 169     2,001-10,000                0                   0       ISAF
#> 170     2,001-10,000                0                   0       ISAF
#> 171     2,001-10,000                1                   0       ISAF
#> 172     2,001-10,000                0                   0       ISAF
#> 173    10,001-20,000                0                   1       ISAF
#> 174     2,001-10,000                0                   0       ISAF
#> 175  less than 2,000                1                   0    taliban
#> 177     2,001-10,000                0                   0    taliban
#> 178  less than 2,000                0                   0    taliban
#> 179    10,001-20,000                0                   0    taliban
#> 180  less than 2,000                1                   0    taliban
#> 181     2,001-10,000                0                   0    control
#> 182     2,001-10,000                1                   0    control
#> 183    10,001-20,000                0                   0    control
#> 184     2,001-10,000                1                   0       ISAF
#> 185     2,001-10,000                1                   0       ISAF
#> 186    10,001-20,000                0                   1       ISAF
#> 187     2,001-10,000                0                   1    taliban
#> 188     2,001-10,000                0                   0    taliban
#> 189     2,001-10,000                0                   0    taliban
#> 190  less than 2,000                0                   0    control
#> 191    10,001-20,000                0                   0    control
#> 192     2,001-10,000                0                   1    control
#> 193     2,001-10,000                0                   1       ISAF
#> 194  less than 2,000                0                   1       ISAF
#> 195     2,001-10,000                1                   0       ISAF
#> 196     2,001-10,000                0                   0    taliban
#> 197     2,001-10,000                0                   0    taliban
#> 198     2,001-10,000                0                   0    taliban
#> 199     2,001-10,000                0                   0    control
#> 200     2,001-10,000                0                   0    control
#> 201  less than 2,000                0                   0    control
#> 202     2,001-10,000                0                   0       ISAF
#> 203  less than 2,000                0                   0       ISAF
#> 204     2,001-10,000                0                   0       ISAF
#> 205     2,001-10,000                0                   0    taliban
#> 206     2,001-10,000                1                   0    taliban
#> 207  less than 2,000                0                   0    taliban
#> 208    20,001-30,000                0                   0    control
#> 209     2,001-10,000                0                   0    control
#> 210     2,001-10,000                0                   0    control
#> 211     2,001-10,000                0                   0       ISAF
#> 212     2,001-10,000                1                   0       ISAF
#> 213     2,001-10,000                0                   0       ISAF
#> 214    10,001-20,000                0                   0    taliban
#> 215     2,001-10,000                0                   1    taliban
#> 216    10,001-20,000                0                   1    taliban
#> 217     2,001-10,000                0                   0    control
#> 218     2,001-10,000                0                   0    control
#> 219     2,001-10,000                0                   0    control
#> 220     2,001-10,000                0                   0    control
#> 221     2,001-10,000                0                   1    control
#> 222     2,001-10,000                0                   0    control
#> 223     2,001-10,000                0                   0       ISAF
#> 224     2,001-10,000                0                   0       ISAF
#> 226     2,001-10,000                0                   0       ISAF
#> 227     2,001-10,000                1                   0       ISAF
#> 228  less than 2,000                0                   0       ISAF
#> 229     2,001-10,000                1                   0    taliban
#> 230     2,001-10,000                1                   0    taliban
#> 231    10,001-20,000                0                   0    taliban
#> 232     2,001-10,000                0                   0    taliban
#> 233     2,001-10,000                0                   0    taliban
#> 234     2,001-10,000                0                   0    taliban
#> 235  less than 2,000                0                   0    control
#> 236     2,001-10,000                0                   0    control
#> 237     2,001-10,000                0                   0    control
#> 238     2,001-10,000                0                   0       ISAF
#> 239  less than 2,000                0                   0       ISAF
#> 240     2,001-10,000                0                   0       ISAF
#> 241    10,001-20,000                0                   0    taliban
#> 242  less than 2,000                1                   0    taliban
#> 243  less than 2,000                0                   0    taliban
#> 245  less than 2,000                0                   0    control
#> 246     2,001-10,000                1                   0    control
#> 247     2,001-10,000                0                   0       ISAF
#> 248  less than 2,000                0                   0       ISAF
#> 250    10,001-20,000                0                   0    taliban
#> 251     2,001-10,000                0                   0    taliban
#> 253     2,001-10,000                0                   0    control
#> 254     2,001-10,000                0                   0    control
#> 255     2,001-10,000                0                   0    control
#> 256    10,001-20,000                0                   0       ISAF
#> 257     2,001-10,000                0                   0       ISAF
#> 258    10,001-20,000                0                   0       ISAF
#> 259     2,001-10,000                0                   0    taliban
#> 260    10,001-20,000                0                   0    taliban
#> 261    10,001-20,000                0                   0    taliban
#> 262     2,001-10,000                0                   0    control
#> 263     2,001-10,000                0                   0    control
#> 264     2,001-10,000                0                   0    control
#> 265     2,001-10,000                0                   0       ISAF
#> 266    10,001-20,000                0                   0       ISAF
#> 267     2,001-10,000                0                   0       ISAF
#> 268    10,001-20,000                0                   0    taliban
#> 269  less than 2,000                0                   0    taliban
#> 270  less than 2,000                0                   0    taliban
#> 271     2,001-10,000                0                   0    control
#> 272  less than 2,000                0                   0    control
#> 273     2,001-10,000                0                   0    control
#> 274     2,001-10,000                0                   0       ISAF
#> 276     2,001-10,000                0                   0       ISAF
#> 277     2,001-10,000                0                   0    taliban
#> 278     2,001-10,000                0                   0    taliban
#> 279  less than 2,000                0                   0    taliban
#> 280    10,001-20,000                0                   0    control
#> 281     2,001-10,000                0                   0    control
#> 282  less than 2,000                0                   0    control
#> 283  less than 2,000                1                   0       ISAF
#> 284     2,001-10,000                0                   0       ISAF
#> 285     2,001-10,000                0                   0       ISAF
#> 286     2,001-10,000                0                   0    taliban
#> 287     2,001-10,000                0                   0    taliban
#> 288     2,001-10,000                0                   0    taliban
#> 289     2,001-10,000                0                   0    control
#> 290     2,001-10,000                0                   0    control
#> 291  less than 2,000                0                   0    control
#> 292     2,001-10,000                0                   0       ISAF
#> 293     2,001-10,000                0                   0       ISAF
#> 294     2,001-10,000                0                   0       ISAF
#> 295     2,001-10,000                0                   0    taliban
#> 296     2,001-10,000                0                   0    taliban
#> 297     2,001-10,000                0                   0    taliban
#> 298     2,001-10,000                0                   0    control
#> 299  less than 2,000                0                   0    control
#> 300     2,001-10,000                0                   0    control
#> 301     2,001-10,000                1                   0       ISAF
#> 302    10,001-20,000                0                   0       ISAF
#> 303    10,001-20,000                0                   0       ISAF
#> 304     2,001-10,000                0                   0    taliban
#> 305     2,001-10,000                0                   0    taliban
#> 306    10,001-20,000                0                   0    taliban
#> 307     2,001-10,000                0                   0    control
#> 308  less than 2,000                0                   0    control
#> 309  less than 2,000                1                   0    control
#> 310    10,001-20,000                0                   0       ISAF
#> 311     2,001-10,000                0                   0       ISAF
#> 312     2,001-10,000                0                   0       ISAF
#> 313     2,001-10,000                0                   0    taliban
#> 314  less than 2,000                0                   0    taliban
#> 315     2,001-10,000                0                   0    taliban
#> 316     2,001-10,000                0                   0    control
#> 317     2,001-10,000                0                   0    control
#> 318     2,001-10,000                0                   0    control
#> 319    10,001-20,000                0                   0       ISAF
#> 320    10,001-20,000                0                   0       ISAF
#> 321    10,001-20,000                0                   0       ISAF
#> 322     2,001-10,000                0                   0    taliban
#> 323      over 30,000                0                   0    taliban
#> 324    10,001-20,000                0                   0    taliban
#> 325     2,001-10,000                0                   0    control
#> 326  less than 2,000                0                   0    control
#> 327     2,001-10,000                0                   0    control
#> 328     2,001-10,000                0                   0       ISAF
#> 329  less than 2,000                0                   0       ISAF
#> 330     2,001-10,000                0                   0       ISAF
#> 331     2,001-10,000                0                   0    taliban
#> 332     2,001-10,000                0                   0    taliban
#> 333     2,001-10,000                0                   0    taliban
#> 334     2,001-10,000                0                   0    control
#> 335     2,001-10,000                0                   0    control
#> 336    10,001-20,000                0                   0    control
#> 337     2,001-10,000                0                   0       ISAF
#> 338     2,001-10,000                0                   0       ISAF
#> 339     2,001-10,000                0                   0       ISAF
#> 340     2,001-10,000                0                   0    taliban
#> 341    10,001-20,000                0                   0    taliban
#> 342     2,001-10,000                0                   0    taliban
#> 343     2,001-10,000                0                   0    control
#> 344     2,001-10,000                0                   0    control
#> 345     2,001-10,000                1                   0    control
#> 346     2,001-10,000                0                   0    control
#> 348    10,001-20,000                0                   0    control
#> 349     2,001-10,000                0                   0       ISAF
#> 350     2,001-10,000                0                   0       ISAF
#> 351     2,001-10,000                0                   0       ISAF
#> 352    10,001-20,000                0                   0       ISAF
#> 354     2,001-10,000                0                   0       ISAF
#> 355     2,001-10,000                0                   0    taliban
#> 356     2,001-10,000                0                   1    taliban
#> 357     2,001-10,000                1                   0    taliban
#> 358    20,001-30,000                0                   0    taliban
#> 360  less than 2,000                0                   0    taliban
#> 361     2,001-10,000                0                   0    control
#> 362    10,001-20,000                0                   0    control
#> 363     2,001-10,000                0                   0    control
#> 364     2,001-10,000                0                   1    control
#> 365    10,001-20,000                0                   0    control
#> 366    20,001-30,000                0                   0    control
#> 367    10,001-20,000                1                   0       ISAF
#> 368     2,001-10,000                0                   0       ISAF
#> 369    10,001-20,000                0                   0       ISAF
#> 370     2,001-10,000                0                   0       ISAF
#> 371     2,001-10,000                0                   0       ISAF
#> 373     2,001-10,000                0                   0    taliban
#> 374  less than 2,000                0                   0    taliban
#> 375    10,001-20,000                0                   0    taliban
#> 376    20,001-30,000                0                   0    taliban
#> 377     2,001-10,000                0                   0    taliban
#> 378     2,001-10,000                0                   0    taliban
#> 380     2,001-10,000                0                   0    control
#> 381     2,001-10,000                0                   0    control
#> 382     2,001-10,000                0                   0    control
#> 383    10,001-20,000                0                   0    control
#> 384     2,001-10,000                0                   0    control
#> 385     2,001-10,000                0                   0       ISAF
#> 386    10,001-20,000                0                   0       ISAF
#> 387    10,001-20,000                0                   0       ISAF
#> 388     2,001-10,000                0                   0       ISAF
#> 389     2,001-10,000                0                   0       ISAF
#> 390     2,001-10,000                0                   0       ISAF
#> 391     2,001-10,000                0                   0    taliban
#> 392     2,001-10,000                1                   0    taliban
#> 393    20,001-30,000                0                   0    taliban
#> 394    10,001-20,000                0                   0    taliban
#> 395    10,001-20,000                0                   0    taliban
#> 396     2,001-10,000                0                   0    taliban
#> 397     2,001-10,000                0                   0    control
#> 398    10,001-20,000                0                   0    control
#> 399  less than 2,000                1                   0    control
#> 400  less than 2,000                0                   0    control
#> 401     2,001-10,000                0                   0    control
#> 402  less than 2,000                0                   0    control
#> 403    10,001-20,000                0                   0       ISAF
#> 404  less than 2,000                0                   0       ISAF
#> 405     2,001-10,000                0                   0       ISAF
#> 406     2,001-10,000                0                   0       ISAF
#> 407     2,001-10,000                0                   0       ISAF
#> 408     2,001-10,000                0                   0       ISAF
#> 409  less than 2,000                0                   0    taliban
#> 410    10,001-20,000                0                   0    taliban
#> 411     2,001-10,000                0                   0    taliban
#> 412    10,001-20,000                0                   0    taliban
#> 413     2,001-10,000                0                   0    taliban
#> 415     2,001-10,000                0                   1    control
#> 416     2,001-10,000                0                   0    control
#> 418  less than 2,000                0                   0    control
#> 419     2,001-10,000                0                   0    control
#> 421     2,001-10,000                0                   0       ISAF
#> 422  less than 2,000                0                   0       ISAF
#> 423     2,001-10,000                0                   0       ISAF
#> 424    10,001-20,000                0                   0       ISAF
#> 425     2,001-10,000                0                   0       ISAF
#> 426     2,001-10,000                0                   0       ISAF
#> 427     2,001-10,000                0                   0    taliban
#> 428     2,001-10,000                0                   0    taliban
#> 429     2,001-10,000                0                   0    taliban
#> 430     2,001-10,000                0                   0    taliban
#> 431  less than 2,000                0                   0    taliban
#> 432     2,001-10,000                0                   0    taliban
#> 433    10,001-20,000                0                   0    control
#> 434  less than 2,000                0                   0    control
#> 435     2,001-10,000                0                   0    control
#> 436     2,001-10,000                1                   0    control
#> 438     2,001-10,000                0                   0    control
#> 439     2,001-10,000                0                   0       ISAF
#> 440  less than 2,000                0                   0       ISAF
#> 441     2,001-10,000                0                   0       ISAF
#> 442     2,001-10,000                0                   0       ISAF
#> 443    10,001-20,000                0                   0       ISAF
#> 444     2,001-10,000                0                   0       ISAF
#> 445     2,001-10,000                0                   0    taliban
#> 446     2,001-10,000                0                   0    taliban
#> 447  less than 2,000                0                   0    taliban
#> 448     2,001-10,000                0                   0    taliban
#> 449     2,001-10,000                0                   0    taliban
#> 450     2,001-10,000                0                   0    taliban
#> 451     2,001-10,000                1                   0    control
#> 452     2,001-10,000                0                   0    control
#> 453     2,001-10,000                0                   1    control
#> 454    10,001-20,000                0                   0    control
#> 455     2,001-10,000                1                   0    control
#> 456    20,001-30,000                0                   0    control
#> 457     2,001-10,000                0                   0       ISAF
#> 458     2,001-10,000                0                   0       ISAF
#> 460    20,001-30,000                0                   0       ISAF
#> 461     2,001-10,000                0                   0       ISAF
#> 462     2,001-10,000                0                   1       ISAF
#> 463    10,001-20,000                0                   0    taliban
#> 465     2,001-10,000                0                   0    taliban
#> 466    10,001-20,000                0                   0    taliban
#> 467     2,001-10,000                0                   0    taliban
#> 468  less than 2,000                0                   0    taliban
#> 469     2,001-10,000                0                   0    control
#> 470     2,001-10,000                0                   1    control
#> 471    10,001-20,000                1                   0    control
#> 472     2,001-10,000                0                   0    control
#> 473    10,001-20,000                0                   0    control
#> 474     2,001-10,000                0                   0    control
#> 475    10,001-20,000                0                   0       ISAF
#> 476    10,001-20,000                0                   0       ISAF
#> 477     2,001-10,000                0                   0       ISAF
#> 478    10,001-20,000                0                   0       ISAF
#> 479  less than 2,000                0                   0       ISAF
#> 480     2,001-10,000                0                   0       ISAF
#> 481     2,001-10,000                0                   0    taliban
#> 482     2,001-10,000                1                   0    taliban
#> 483     2,001-10,000                0                   0    taliban
#> 484    20,001-30,000                1                   0    taliban
#> 485    10,001-20,000                0                   1    taliban
#> 486     2,001-10,000                0                   1    taliban
#> 487     2,001-10,000                0                   0    control
#> 488    10,001-20,000                0                   0    control
#> 489     2,001-10,000                0                   0    control
#> 490     2,001-10,000                0                   0    control
#> 491     2,001-10,000                1                   0    control
#> 492     2,001-10,000                0                   0    control
#> 493     2,001-10,000                0                   0       ISAF
#> 494     2,001-10,000                0                   0       ISAF
#> 495     2,001-10,000                0                   0       ISAF
#> 496     2,001-10,000                0                   0       ISAF
#> 497     2,001-10,000                0                   0       ISAF
#> 498     2,001-10,000                0                   0       ISAF
#> 499     2,001-10,000                0                   0    taliban
#> 500     2,001-10,000                0                   0    taliban
#> 501     2,001-10,000                0                   0    taliban
#> 502     2,001-10,000                0                   0    taliban
#> 503  less than 2,000                0                   0    taliban
#> 504  less than 2,000                0                   0    taliban
#> 505     2,001-10,000                0                   1    control
#> 506    10,001-20,000                0                   0    control
#> 507     2,001-10,000                0                   1    control
#> 508     2,001-10,000                0                   1    control
#> 509     2,001-10,000                1                   1    control
#> 510     2,001-10,000                0                   1    control
#> 511    10,001-20,000                0                   1       ISAF
#> 512     2,001-10,000                0                   0       ISAF
#> 513    10,001-20,000                0                   0       ISAF
#> 514     2,001-10,000                0                   0       ISAF
#> 515     2,001-10,000                1                   0       ISAF
#> 516     2,001-10,000                0                   0       ISAF
#> 517    10,001-20,000                1                   0    taliban
#> 518     2,001-10,000                0                   0    taliban
#> 519     2,001-10,000                0                   1    taliban
#> 520    10,001-20,000                0                   0    taliban
#> 521     2,001-10,000                0                   0    taliban
#> 522    10,001-20,000                0                   0    taliban
#> 523     2,001-10,000                0                   0    control
#> 524     2,001-10,000                0                   0    control
#> 525  less than 2,000                0                   0    control
#> 526    10,001-20,000                0                   0    control
#> 527     2,001-10,000                0                   0    control
#> 528     2,001-10,000                1                   0    control
#> 529     2,001-10,000                0                   0       ISAF
#> 530    10,001-20,000                1                   0       ISAF
#> 531     2,001-10,000                1                   0       ISAF
#> 532     2,001-10,000                0                   0       ISAF
#> 533    10,001-20,000                0                   0       ISAF
#> 534     2,001-10,000                0                   0       ISAF
#> 535     2,001-10,000                0                   0    taliban
#> 536    10,001-20,000                0                   0    taliban
#> 537     2,001-10,000                1                   0    taliban
#> 538  less than 2,000                1                   0    taliban
#> 539     2,001-10,000                0                   0    taliban
#> 540     2,001-10,000                0                   0    taliban
#> 541     2,001-10,000                1                   0    control
#> 542  less than 2,000                1                   0    control
#> 543  less than 2,000                0                   1    control
#> 544  less than 2,000                1                   0       ISAF
#> 545     2,001-10,000                1                   0       ISAF
#> 546     2,001-10,000                1                   0       ISAF
#> 547  less than 2,000                1                   0    taliban
#> 548  less than 2,000                1                   1    taliban
#> 549  less than 2,000                1                   0    taliban
#> 550     2,001-10,000                1                   1    control
#> 551     2,001-10,000                0                   1    control
#> 552     2,001-10,000                1                   0    control
#> 553    10,001-20,000                1                   0       ISAF
#> 554     2,001-10,000                0                   1       ISAF
#> 555    10,001-20,000                0                   0       ISAF
#> 556    10,001-20,000                1                   0    taliban
#> 557     2,001-10,000                1                   0    taliban
#> 558    10,001-20,000                0                   1    taliban
#> 559     2,001-10,000                1                   1    control
#> 560    10,001-20,000                1                   0    control
#> 561     2,001-10,000                1                   0    control
#> 562     2,001-10,000                1                   0       ISAF
#> 563     2,001-10,000                1                   0       ISAF
#> 564     2,001-10,000                1                   0       ISAF
#> 565     2,001-10,000                1                   0    taliban
#> 566     2,001-10,000                0                   0    taliban
#> 567  less than 2,000                0                   0    taliban
#> 568    10,001-20,000                0                   1    control
#> 569    10,001-20,000                1                   0    control
#> 570     2,001-10,000                0                   1    control
#> 571     2,001-10,000                0                   0       ISAF
#> 572     2,001-10,000                0                   1       ISAF
#> 573    10,001-20,000                1                   0       ISAF
#> 574    10,001-20,000                0                   0    taliban
#> 575     2,001-10,000                1                   0    taliban
#> 576     2,001-10,000                1                   0    taliban
#> 577     2,001-10,000                0                   0    control
#> 578     2,001-10,000                0                   1    control
#> 579     2,001-10,000                0                   1    control
#> 580    10,001-20,000                0                   0    control
#> 581     2,001-10,000                1                   0    control
#> 582    20,001-30,000                0                   0    control
#> 583     2,001-10,000                0                   1       ISAF
#> 584     2,001-10,000                0                   0       ISAF
#> 585     2,001-10,000                0                   0       ISAF
#> 586    10,001-20,000                0                   0       ISAF
#> 587    10,001-20,000                0                   0       ISAF
#> 588    10,001-20,000                0                   0       ISAF
#> 589     2,001-10,000                0                   0    taliban
#> 590    10,001-20,000                0                   0    taliban
#> 591     2,001-10,000                0                   0    taliban
#> 592     2,001-10,000                0                   0    taliban
#> 593     2,001-10,000                0                   0    taliban
#> 594    10,001-20,000                0                   0    taliban
#> 595     2,001-10,000                1                   0    control
#> 596    10,001-20,000                0                   0    control
#> 597     2,001-10,000                0                   0    control
#> 598     2,001-10,000                0                   0    control
#> 599     2,001-10,000                0                   0    control
#> 600     2,001-10,000                0                   0    control
#> 601     2,001-10,000                0                   0       ISAF
#> 602    10,001-20,000                1                   1       ISAF
#> 603     2,001-10,000                0                   0       ISAF
#> 604     2,001-10,000                0                   0       ISAF
#> 605     2,001-10,000                0                   0       ISAF
#> 606     2,001-10,000                0                   1       ISAF
#> 607     2,001-10,000                0                   0    taliban
#> 608     2,001-10,000                0                   0    taliban
#> 609     2,001-10,000                0                   0    taliban
#> 610    10,001-20,000                0                   0    taliban
#> 611     2,001-10,000                1                   0    taliban
#> 612     2,001-10,000                1                   0    taliban
#> 613     2,001-10,000                0                   1    control
#> 614    10,001-20,000                0                   0    control
#> 615    10,001-20,000                0                   1    control
#> 616    10,001-20,000                0                   0    control
#> 617     2,001-10,000                0                   0    control
#> 618  less than 2,000                0                   0    control
#> 619     2,001-10,000                0                   1       ISAF
#> 620    10,001-20,000                0                   1       ISAF
#> 621    10,001-20,000                0                   1       ISAF
#> 622    10,001-20,000                1                   1       ISAF
#> 623     2,001-10,000                1                   0       ISAF
#> 624    10,001-20,000                1                   1       ISAF
#> 625    10,001-20,000                1                   1    taliban
#> 626    20,001-30,000                1                   0    taliban
#> 627     2,001-10,000                0                   0    taliban
#> 628     2,001-10,000                0                   0    taliban
#> 629     2,001-10,000                0                   1    taliban
#> 630     2,001-10,000                1                   0    taliban
#> 631  less than 2,000                0                   0    control
#> 632     2,001-10,000                1                   0    control
#> 633    10,001-20,000                0                   0    control
#> 634    10,001-20,000                1                   1    control
#> 635     2,001-10,000                1                   1    control
#> 636  less than 2,000                1                   1    control
#> 637     2,001-10,000                0                   1       ISAF
#> 638    20,001-30,000                0                   0       ISAF
#> 639    10,001-20,000                1                   1       ISAF
#> 640    10,001-20,000                0                   0       ISAF
#> 641     2,001-10,000                0                   0       ISAF
#> 642  less than 2,000                1                   1       ISAF
#> 643    10,001-20,000                0                   0    taliban
#> 644     2,001-10,000                1                   1    taliban
#> 645    20,001-30,000                1                   1    taliban
#> 646     2,001-10,000                0                   0    taliban
#> 647    10,001-20,000                0                   0    taliban
#> 648     2,001-10,000                1                   1    taliban
#> 649     2,001-10,000                0                   0    control
#> 650     2,001-10,000                1                   1    control
#> 652     2,001-10,000                0                   0       ISAF
#> 654     2,001-10,000                1                   1       ISAF
#> 655  less than 2,000                1                   1    taliban
#> 656     2,001-10,000                1                   0    taliban
#> 657     2,001-10,000                1                   0    taliban
#> 658    10,001-20,000                0                   1    control
#> 659     2,001-10,000                1                   1    control
#> 660     2,001-10,000                1                   1    control
#> 661     2,001-10,000                0                   1       ISAF
#> 662    10,001-20,000                1                   1       ISAF
#> 663     2,001-10,000                1                   1       ISAF
#> 664    10,001-20,000                1                   1    taliban
#> 665  less than 2,000                1                   1    taliban
#> 666     2,001-10,000                1                   1    taliban
#> 667     2,001-10,000                1                   1    control
#> 668    10,001-20,000                1                   1    control
#> 669     2,001-10,000                1                   1    control
#> 670     2,001-10,000                1                   1       ISAF
#> 671     2,001-10,000                1                   1       ISAF
#> 672     2,001-10,000                0                   1       ISAF
#> 673  less than 2,000                0                   1    taliban
#> 674     2,001-10,000                1                   1    taliban
#> 675     2,001-10,000                1                   1    taliban
#> 676    10,001-20,000                0                   0    control
#> 677     2,001-10,000                1                   0    control
#> 678     2,001-10,000                1                   0    control
#> 679     2,001-10,000                0                   0    control
#> 680    10,001-20,000                0                   1    control
#> 681     2,001-10,000                1                   1    control
#> 682     2,001-10,000                1                   1       ISAF
#> 683     2,001-10,000                1                   0       ISAF
#> 684     2,001-10,000                1                   0       ISAF
#> 685     2,001-10,000                0                   1       ISAF
#> 686    10,001-20,000                1                   0       ISAF
#> 687    10,001-20,000                1                   0       ISAF
#> 688     2,001-10,000                0                   0    taliban
#> 689     2,001-10,000                0                   0    taliban
#> 690     2,001-10,000                0                   0    taliban
#> 691     2,001-10,000                0                   0    taliban
#> 692     2,001-10,000                1                   1    taliban
#> 693     2,001-10,000                0                   0    taliban
#> 694     2,001-10,000                0                   0    control
#> 695  less than 2,000                0                   0    control
#> 696     2,001-10,000                0                   0    control
#> 697     2,001-10,000                0                   0    control
#> 698  less than 2,000                0                   0    control
#> 699     2,001-10,000                1                   0    control
#> 700     2,001-10,000                0                   0       ISAF
#> 701     2,001-10,000                0                   0       ISAF
#> 702     2,001-10,000                0                   0       ISAF
#> 703     2,001-10,000                0                   0       ISAF
#> 704  less than 2,000                0                   0       ISAF
#> 705     2,001-10,000                0                   0       ISAF
#> 706    10,001-20,000                0                   0    taliban
#> 707     2,001-10,000                0                   0    taliban
#> 708     2,001-10,000                0                   0    taliban
#> 709     2,001-10,000                0                   0    taliban
#> 710     2,001-10,000                0                   0    taliban
#> 711  less than 2,000                0                   0    taliban
#> 712     2,001-10,000                0                   0    control
#> 713     2,001-10,000                0                   0    control
#> 714     2,001-10,000                1                   0    control
#> 715    10,001-20,000                0                   0       ISAF
#> 716     2,001-10,000                0                   1       ISAF
#> 717    10,001-20,000                1                   0       ISAF
#> 718     2,001-10,000                0                   0    taliban
#> 719     2,001-10,000                1                   0    taliban
#> 720     2,001-10,000                1                   0    taliban
#> 721    10,001-20,000                0                   0    control
#> 722     2,001-10,000                1                   1    control
#> 723     2,001-10,000                1                   1    control
#> 724     2,001-10,000                1                   1       ISAF
#> 725    10,001-20,000                1                   1       ISAF
#> 726     2,001-10,000                1                   1       ISAF
#> 727     2,001-10,000                1                   1    taliban
#> 728     2,001-10,000                1                   1    taliban
#> 729     2,001-10,000                1                   1    taliban
#> 730     2,001-10,000                1                   0    control
#> 731    10,001-20,000                0                   0    control
#> 732     2,001-10,000                1                   0    control
#> 733     2,001-10,000                1                   0       ISAF
#> 735    10,001-20,000                1                   0       ISAF
#> 736     2,001-10,000                0                   0    taliban
#> 737    10,001-20,000                0                   0    taliban
#> 738    10,001-20,000                1                   0    taliban
#> 739     2,001-10,000                1                   1    control
#> 740     2,001-10,000                0                   0    control
#> 741    10,001-20,000                1                   1    control
#> 742     2,001-10,000                1                   1    control
#> 743     2,001-10,000                0                   0    control
#> 744     2,001-10,000                1                   1    control
#> 745     2,001-10,000                1                   1       ISAF
#> 746     2,001-10,000                0                   0       ISAF
#> 747    10,001-20,000                1                   0       ISAF
#> 748    10,001-20,000                1                   1       ISAF
#> 749    10,001-20,000                1                   1       ISAF
#> 750  less than 2,000                1                   1       ISAF
#> 751     2,001-10,000                1                   1    taliban
#> 752     2,001-10,000                1                   1    taliban
#> 753     2,001-10,000                1                   1    taliban
#> 754    10,001-20,000                1                   1    taliban
#> 755    10,001-20,000                1                   1    taliban
#> 756     2,001-10,000                1                   0    taliban
#> 757    20,001-30,000                1                   0    control
#> 758     2,001-10,000                0                   0    control
#> 759     2,001-10,000                0                   0    control
#> 760     2,001-10,000                0                   0    control
#> 761    10,001-20,000                0                   0    control
#> 762    20,001-30,000                0                   0    control
#> 763     2,001-10,000                0                   0       ISAF
#> 764    10,001-20,000                0                   0       ISAF
#> 765    10,001-20,000                0                   0       ISAF
#> 766     2,001-10,000                1                   0       ISAF
#> 767    10,001-20,000                1                   0       ISAF
#> 768     2,001-10,000                1                   0       ISAF
#> 769    10,001-20,000                1                   1    taliban
#> 770    10,001-20,000                1                   1    taliban
#> 771     2,001-10,000                1                   1    taliban
#> 772     2,001-10,000                1                   1    taliban
#> 773  less than 2,000                1                   1    taliban
#> 774    10,001-20,000                1                   1    taliban
#> 775     2,001-10,000                0                   1    control
#> 776    10,001-20,000                1                   0    control
#> 777     2,001-10,000                0                   1    control
#> 778     2,001-10,000                1                   1       ISAF
#> 779     2,001-10,000                0                   1       ISAF
#> 780     2,001-10,000                1                   0       ISAF
#> 781     2,001-10,000                0                   1    taliban
#> 782     2,001-10,000                1                   0    taliban
#> 783     2,001-10,000                0                   1    taliban
#> 784     2,001-10,000                0                   0    control
#> 785     2,001-10,000                0                   0    control
#> 786     2,001-10,000                0                   0    control
#> 787     2,001-10,000                1                   0       ISAF
#> 788     2,001-10,000                0                   0       ISAF
#> 789     2,001-10,000                0                   0       ISAF
#> 790     2,001-10,000                0                   0    taliban
#> 791     2,001-10,000                0                   0    taliban
#> 792     2,001-10,000                0                   1    taliban
#> 793     2,001-10,000                0                   0    control
#> 794  less than 2,000                0                   0    control
#> 795     2,001-10,000                1                   0    control
#> 796  less than 2,000                0                   0       ISAF
#> 797     2,001-10,000                0                   0       ISAF
#> 798     2,001-10,000                0                   0       ISAF
#> 799  less than 2,000                0                   0    taliban
#> 800  less than 2,000                1                   0    taliban
#> 801  less than 2,000                0                   0    taliban
#> 802     2,001-10,000                1                   1    control
#> 803     2,001-10,000                0                   1    control
#> 804     2,001-10,000                0                   1    control
#> 805     2,001-10,000                0                   1       ISAF
#> 806     2,001-10,000                0                   1       ISAF
#> 807     2,001-10,000                0                   1       ISAF
#> 808    10,001-20,000                0                   1    taliban
#> 809     2,001-10,000                0                   1    taliban
#> 810     2,001-10,000                1                   0    taliban
#> 811    10,001-20,000                1                   0    control
#> 812     2,001-10,000                1                   0    control
#> 813     2,001-10,000                0                   0    control
#> 814    10,001-20,000                0                   0       ISAF
#> 815     2,001-10,000                0                   0       ISAF
#> 816    10,001-20,000                0                   1       ISAF
#> 817     2,001-10,000                0                   1    taliban
#> 818     2,001-10,000                0                   0    taliban
#> 819    10,001-20,000                0                   1    taliban
#> 820     2,001-10,000                1                   0    control
#> 821     2,001-10,000                1                   1    control
#> 822    10,001-20,000                0                   0    control
#> 823     2,001-10,000                0                   0       ISAF
#> 824    10,001-20,000                1                   1       ISAF
#> 825     2,001-10,000                1                   1       ISAF
#> 826    10,001-20,000                0                   0    taliban
#> 827     2,001-10,000                0                   0    taliban
#> 828     2,001-10,000                1                   0    taliban
#> 829     2,001-10,000                0                   0    control
#> 830    10,001-20,000                1                   0    control
#> 831     2,001-10,000                0                   0    control
#> 832    10,001-20,000                0                   0    control
#> 833    20,001-30,000                0                   0    control
#> 834    20,001-30,000                0                   0    control
#> 835     2,001-10,000                0                   1       ISAF
#> 836    10,001-20,000                1                   1       ISAF
#> 837     2,001-10,000                0                   0       ISAF
#> 838     2,001-10,000                1                   0       ISAF
#> 839    10,001-20,000                0                   0       ISAF
#> 840    10,001-20,000                0                   0       ISAF
#> 841    20,001-30,000                0                   0    taliban
#> 842    10,001-20,000                0                   0    taliban
#> 843      over 30,000                0                   0    taliban
#> 844    10,001-20,000                0                   0    taliban
#> 845    10,001-20,000                0                   1    taliban
#> 846    10,001-20,000                1                   0    taliban
#> 847     2,001-10,000                0                   0    control
#> 848  less than 2,000                0                   0    control
#> 849     2,001-10,000                0                   0    control
#> 850     2,001-10,000                0                   0    control
#> 851     2,001-10,000                0                   0    control
#> 852     2,001-10,000                0                   0    control
#> 853     2,001-10,000                1                   0       ISAF
#> 854     2,001-10,000                0                   0       ISAF
#> 855     2,001-10,000                0                   0       ISAF
#> 856     2,001-10,000                1                   0       ISAF
#> 857     2,001-10,000                0                   0       ISAF
#> 858     2,001-10,000                0                   0       ISAF
#> 859     2,001-10,000                0                   0    taliban
#> 860     2,001-10,000                0                   0    taliban
#> 861     2,001-10,000                1                   0    taliban
#> 862     2,001-10,000                1                   0    taliban
#> 863     2,001-10,000                1                   0    taliban
#> 864     2,001-10,000                1                   0    taliban
#> 865     2,001-10,000                1                   0    control
#> 866     2,001-10,000                1                   0    control
#> 867  less than 2,000                0                   0    control
#> 868     2,001-10,000                0                   0    control
#> 869     2,001-10,000                1                   0    control
#> 870     2,001-10,000                1                   0    control
#> 871     2,001-10,000                0                   0       ISAF
#> 872     2,001-10,000                0                   0       ISAF
#> 873     2,001-10,000                1                   0       ISAF
#> 874     2,001-10,000                0                   0       ISAF
#> 875     2,001-10,000                0                   0       ISAF
#> 876  less than 2,000                0                   1       ISAF
#> 877  less than 2,000                0                   0    taliban
#> 878    10,001-20,000                0                   0    taliban
#> 879     2,001-10,000                0                   0    taliban
#> 880  less than 2,000                0                   0    taliban
#> 881     2,001-10,000                0                   0    taliban
#> 882     2,001-10,000                0                   0    taliban
#> 883    10,001-20,000                0                   0    control
#> 884    20,001-30,000                0                   0    control
#> 885     2,001-10,000                0                   0    control
#> 886    10,001-20,000                0                   0       ISAF
#> 887    10,001-20,000                0                   0       ISAF
#> 888      over 30,000                0                   0       ISAF
#> 889    10,001-20,000                0                   0    taliban
#> 890  less than 2,000                0                   0    taliban
#> 891     2,001-10,000                0                   0    taliban
#> 892     2,001-10,000                0                   0    control
#> 893     2,001-10,000                0                   0    control
#> 894  less than 2,000                0                   0    control
#> 895     2,001-10,000                0                   0       ISAF
#> 896    10,001-20,000                0                   1       ISAF
#> 897    10,001-20,000                1                   0       ISAF
#> 898     2,001-10,000                1                   1    taliban
#> 899    10,001-20,000                1                   1    taliban
#> 900  less than 2,000                1                   1    taliban
#> 901    10,001-20,000                0                   1    control
#> 902    10,001-20,000                1                   1    control
#> 903     2,001-10,000                1                   1    control
#> 904     2,001-10,000                0                   0    control
#> 905     2,001-10,000                0                   0    control
#> 906    10,001-20,000                1                   1    control
#> 907    20,001-30,000                0                   1       ISAF
#> 908     2,001-10,000                1                   1       ISAF
#> 909    10,001-20,000                1                   1       ISAF
#> 910    20,001-30,000                1                   1       ISAF
#> 911     2,001-10,000                1                   1       ISAF
#> 912    20,001-30,000                1                   1       ISAF
#> 913    10,001-20,000                1                   1    taliban
#> 914    10,001-20,000                1                   1    taliban
#> 915    20,001-30,000                1                   1    taliban
#> 916     2,001-10,000                0                   1    taliban
#> 917  less than 2,000                1                   1    taliban
#> 918    10,001-20,000                1                   1    taliban
#> 919  less than 2,000                0                   0    control
#> 920    10,001-20,000                0                   0    control
#> 921     2,001-10,000                1                   0    control
#> 922    10,001-20,000                0                   0    control
#> 923     2,001-10,000                1                   1    control
#> 924    10,001-20,000                0                   0    control
#> 925     2,001-10,000                0                   1       ISAF
#> 926     2,001-10,000                0                   1       ISAF
#> 927    10,001-20,000                0                   0       ISAF
#> 928     2,001-10,000                1                   0       ISAF
#> 929     2,001-10,000                0                   0       ISAF
#> 930    10,001-20,000                1                   0       ISAF
#> 931  less than 2,000                0                   0    taliban
#> 932  less than 2,000                0                   1    taliban
#> 933     2,001-10,000                0                   0    taliban
#> 934  less than 2,000                1                   1    taliban
#> 935     2,001-10,000                1                   0    taliban
#> 936  less than 2,000                0                   0    taliban
#> 937    10,001-20,000                0                   0    control
#> 938     2,001-10,000                0                   0    control
#> 939    10,001-20,000                0                   0    control
#> 940    10,001-20,000                0                   0       ISAF
#> 941    10,001-20,000                0                   1       ISAF
#> 942    10,001-20,000                1                   1       ISAF
#> 943    20,001-30,000                1                   0    taliban
#> 944    10,001-20,000                0                   0    taliban
#> 945    10,001-20,000                0                   1    taliban
#> 946    20,001-30,000                0                   1    control
#> 947    10,001-20,000                1                   0    control
#> 948    10,001-20,000                1                   0    control
#> 949     2,001-10,000                0                   0       ISAF
#> 950    10,001-20,000                1                   0       ISAF
#> 951    10,001-20,000                0                   0       ISAF
#> 952    10,001-20,000                1                   0    taliban
#> 953    20,001-30,000                1                   0    taliban
#> 954    10,001-20,000                0                   0    taliban
#> 955    10,001-20,000                0                   0    control
#> 956     2,001-10,000                0                   1    control
#> 957    20,001-30,000                0                   1    control
#> 958     2,001-10,000                0                   0       ISAF
#> 959    10,001-20,000                0                   1       ISAF
#> 960    20,001-30,000                0                   0       ISAF
#> 961     2,001-10,000                0                   1    taliban
#> 962     2,001-10,000                1                   1    taliban
#> 963    20,001-30,000                0                   1    taliban
#> 964    10,001-20,000                0                   0    control
#> 965     2,001-10,000                0                   0    control
#> 966    10,001-20,000                0                   0    control
#> 967    10,001-20,000                0                   1       ISAF
#> 968     2,001-10,000                1                   0       ISAF
#> 969     2,001-10,000                1                   1       ISAF
#> 970    20,001-30,000                0                   0    taliban
#> 971    20,001-30,000                0                   0    taliban
#> 972     2,001-10,000                1                   0    taliban
#> 973    10,001-20,000                0                   0    control
#> 974     2,001-10,000                0                   0    control
#> 975    10,001-20,000                0                   1    control
#> 976     2,001-10,000                0                   0       ISAF
#> 977     2,001-10,000                0                   0       ISAF
#> 978     2,001-10,000                0                   0       ISAF
#> 979     2,001-10,000                0                   0    taliban
#> 980    10,001-20,000                0                   0    taliban
#> 981     2,001-10,000                0                   0    taliban
#> 982     2,001-10,000                0                   0    control
#> 983    10,001-20,000                0                   0    control
#> 984     2,001-10,000                0                   0    control
#> 985     2,001-10,000                0                   0       ISAF
#> 986     2,001-10,000                0                   0       ISAF
#> 987    10,001-20,000                0                   0       ISAF
#> 988    10,001-20,000                0                   1    taliban
#> 989     2,001-10,000                0                   0    taliban
#> 990     2,001-10,000                0                   0    taliban
#> 991     2,001-10,000                0                   0    control
#> 992     2,001-10,000                0                   0    control
#> 993    10,001-20,000                0                   0    control
#> 994    10,001-20,000                0                   0       ISAF
#> 995    10,001-20,000                0                   0       ISAF
#> 996     2,001-10,000                0                   0       ISAF
#> 997     2,001-10,000                0                   0    taliban
#> 998     2,001-10,000                0                   0    taliban
#> 999    10,001-20,000                0                   0    taliban
#> 1000    2,001-10,000                0                   0    control
#> 1001    2,001-10,000                1                   0    control
#> 1002   10,001-20,000                0                   0    control
#> 1003   10,001-20,000                0                   0    control
#> 1004   10,001-20,000                0                   0    control
#> 1005    2,001-10,000                0                   0    control
#> 1006 less than 2,000                1                   1       ISAF
#> 1007    2,001-10,000                0                   0       ISAF
#> 1008    2,001-10,000                0                   1       ISAF
#> 1009   10,001-20,000                0                   1       ISAF
#> 1010   10,001-20,000                0                   0       ISAF
#> 1011    2,001-10,000                0                   0       ISAF
#> 1012 less than 2,000                0                   0    taliban
#> 1014   20,001-30,000                0                   0    taliban
#> 1015   10,001-20,000                1                   0    taliban
#> 1016   10,001-20,000                0                   1    taliban
#> 1017     over 30,000                0                   0    taliban
#> 1018   10,001-20,000                0                   0    control
#> 1019   20,001-30,000                0                   0    control
#> 1020   20,001-30,000                0                   0    control
#> 1021    2,001-10,000                0                   0    control
#> 1022    2,001-10,000                0                   0    control
#> 1023    2,001-10,000                0                   0    control
#> 1024    2,001-10,000                0                   0       ISAF
#> 1025   10,001-20,000                0                   1       ISAF
#> 1026   20,001-30,000                0                   0       ISAF
#> 1027    2,001-10,000                0                   0       ISAF
#> 1028   10,001-20,000                0                   0       ISAF
#> 1029    2,001-10,000                0                   0       ISAF
#> 1030   10,001-20,000                0                   0    taliban
#> 1031   10,001-20,000                0                   0    taliban
#> 1032    2,001-10,000                0                   0    taliban
#> 1033   10,001-20,000                0                   0    taliban
#> 1034    2,001-10,000                0                   0    taliban
#> 1035   10,001-20,000                0                   0    taliban
#> 1036 less than 2,000                0                   0    control
#> 1037   10,001-20,000                0                   0    control
#> 1038   10,001-20,000                0                   0    control
#> 1039    2,001-10,000                1                   0    control
#> 1040    2,001-10,000                0                   1    control
#> 1041   20,001-30,000                0                   0    control
#> 1042   10,001-20,000                0                   0       ISAF
#> 1043   10,001-20,000                0                   0       ISAF
#> 1044   10,001-20,000                0                   0       ISAF
#> 1045   10,001-20,000                0                   0       ISAF
#> 1046    2,001-10,000                1                   1       ISAF
#> 1047   20,001-30,000                1                   0       ISAF
#> 1048   10,001-20,000                0                   0    taliban
#> 1049   10,001-20,000                0                   0    taliban
#> 1050   10,001-20,000                0                   0    taliban
#> 1051   10,001-20,000                1                   0    taliban
#> 1052   10,001-20,000                0                   0    taliban
#> 1053   10,001-20,000                0                   1    taliban
#> 1054   10,001-20,000                0                   0    control
#> 1055   10,001-20,000                1                   1    control
#> 1056    2,001-10,000                0                   0    control
#> 1057   10,001-20,000                0                   1    control
#> 1058    2,001-10,000                0                   1    control
#> 1059   10,001-20,000                1                   1    control
#> 1060   10,001-20,000                0                   1       ISAF
#> 1061    2,001-10,000                1                   0       ISAF
#> 1062   20,001-30,000                1                   0       ISAF
#> 1063    2,001-10,000                0                   0       ISAF
#> 1064    2,001-10,000                0                   0       ISAF
#> 1065   10,001-20,000                0                   0       ISAF
#> 1066   10,001-20,000                0                   0    taliban
#> 1067    2,001-10,000                0                   0    taliban
#> 1068   10,001-20,000                1                   1    taliban
#> 1069   10,001-20,000                0                   0    taliban
#> 1070    2,001-10,000                1                   1    taliban
#> 1071    2,001-10,000                0                   0    taliban
#> 1072    2,001-10,000                0                   0    control
#> 1073    2,001-10,000                0                   0    control
#> 1074   10,001-20,000                0                   0    control
#> 1075   20,001-30,000                1                   0    control
#> 1076   20,001-30,000                1                   1    control
#> 1077    2,001-10,000                1                   0    control
#> 1078   10,001-20,000                1                   1       ISAF
#> 1080 less than 2,000                0                   0       ISAF
#> 1081 less than 2,000                1                   0       ISAF
#> 1083   10,001-20,000                0                   0       ISAF
#> 1084   10,001-20,000                1                   0    taliban
#> 1085   20,001-30,000                0                   1    taliban
#> 1086    2,001-10,000                1                   1    taliban
#> 1087    2,001-10,000                0                   0    taliban
#> 1088   10,001-20,000                0                   0    taliban
#> 1089   20,001-30,000                1                   0    taliban
#> 1090    2,001-10,000                0                   0    control
#> 1091    2,001-10,000                1                   0    control
#> 1092   10,001-20,000                0                   0    control
#> 1093    2,001-10,000                0                   0    control
#> 1094   10,001-20,000                1                   1    control
#> 1095   10,001-20,000                1                   1    control
#> 1096   10,001-20,000                1                   1       ISAF
#> 1097   10,001-20,000                1                   1       ISAF
#> 1098   10,001-20,000                1                   1       ISAF
#> 1099   10,001-20,000                1                   1       ISAF
#> 1100   10,001-20,000                1                   1       ISAF
#> 1101   10,001-20,000                1                   1       ISAF
#> 1102   10,001-20,000                1                   1    taliban
#> 1103   10,001-20,000                1                   1    taliban
#> 1104   10,001-20,000                1                   1    taliban
#> 1105   10,001-20,000                1                   1    taliban
#> 1106    2,001-10,000                1                   1    taliban
#> 1107    2,001-10,000                1                   1    taliban
#> 1108   10,001-20,000                0                   0    control
#> 1109    2,001-10,000                0                   0    control
#> 1110 less than 2,000                0                   0    control
#> 1111 less than 2,000                0                   0    control
#> 1112    2,001-10,000                0                   0    control
#> 1113   20,001-30,000                0                   0    control
#> 1114    2,001-10,000                0                   0       ISAF
#> 1115   20,001-30,000                0                   0       ISAF
#> 1116    2,001-10,000                0                   0       ISAF
#> 1117 less than 2,000                0                   0       ISAF
#> 1118    2,001-10,000                0                   0       ISAF
#> 1119    2,001-10,000                0                   0       ISAF
#> 1120 less than 2,000                0                   0    taliban
#> 1121   10,001-20,000                0                   0    taliban
#> 1122    2,001-10,000                0                   0    taliban
#> 1123   10,001-20,000                0                   0    taliban
#> 1124    2,001-10,000                0                   0    taliban
#> 1125    2,001-10,000                0                   0    taliban
#> 1126   10,001-20,000                0                   0    control
#> 1127    2,001-10,000                0                   0    control
#> 1128   10,001-20,000                0                   0    control
#> 1129    2,001-10,000                0                   0    control
#> 1130    2,001-10,000                0                   0    control
#> 1131    2,001-10,000                0                   0    control
#> 1132    2,001-10,000                0                   0       ISAF
#> 1133   10,001-20,000                0                   0       ISAF
#> 1134    2,001-10,000                0                   0       ISAF
#> 1135    2,001-10,000                1                   0       ISAF
#> 1136   10,001-20,000                0                   0       ISAF
#> 1137   10,001-20,000                1                   0       ISAF
#> 1138   10,001-20,000                0                   0    taliban
#> 1139    2,001-10,000                0                   0    taliban
#> 1140    2,001-10,000                0                   0    taliban
#> 1141    2,001-10,000                0                   0    taliban
#> 1142   10,001-20,000                0                   0    taliban
#> 1143    2,001-10,000                0                   0    taliban
#> 1144    2,001-10,000                1                   0    control
#> 1145   10,001-20,000                1                   1    control
#> 1146    2,001-10,000                0                   0    control
#> 1147   10,001-20,000                0                   0    control
#> 1148   10,001-20,000                1                   0    control
#> 1149   10,001-20,000                1                   0    control
#> 1150   10,001-20,000                1                   0       ISAF
#> 1151   10,001-20,000                1                   1       ISAF
#> 1152   10,001-20,000                1                   1       ISAF
#> 1153   10,001-20,000                1                   1       ISAF
#> 1154   10,001-20,000                1                   1       ISAF
#> 1155   10,001-20,000                0                   1       ISAF
#> 1156   10,001-20,000                1                   1    taliban
#> 1157   10,001-20,000                1                   1    taliban
#> 1158   20,001-30,000                1                   1    taliban
#> 1159   20,001-30,000                1                   1    taliban
#> 1160   20,001-30,000                1                   1    taliban
#> 1161   10,001-20,000                0                   0    taliban
#> 1162   10,001-20,000                0                   0    control
#> 1163    2,001-10,000                0                   0    control
#> 1164   10,001-20,000                0                   0    control
#> 1165   10,001-20,000                0                   0    control
#> 1166   10,001-20,000                0                   0    control
#> 1167   10,001-20,000                0                   0    control
#> 1168   10,001-20,000                0                   0       ISAF
#> 1169   20,001-30,000                0                   0       ISAF
#> 1170   10,001-20,000                0                   0       ISAF
#> 1171   10,001-20,000                0                   0       ISAF
#> 1172   10,001-20,000                0                   0       ISAF
#> 1173   10,001-20,000                0                   0       ISAF
#> 1174   20,001-30,000                1                   0    taliban
#> 1175   10,001-20,000                1                   1    taliban
#> 1176   10,001-20,000                0                   1    taliban
#> 1177   10,001-20,000                0                   0    taliban
#> 1178   10,001-20,000                0                   0    taliban
#> 1179   10,001-20,000                0                   0    taliban
#> 1180   20,001-30,000                1                   1    control
#> 1181    2,001-10,000                0                   0    control
#> 1182   10,001-20,000                0                   1    control
#> 1183    2,001-10,000                0                   0       ISAF
#> 1184   20,001-30,000                0                   1       ISAF
#> 1185    2,001-10,000                0                   0       ISAF
#> 1186   10,001-20,000                1                   0    taliban
#> 1187    2,001-10,000                0                   0    taliban
#> 1188    2,001-10,000                0                   1    taliban
#> 1189    2,001-10,000                1                   1    control
#> 1190    2,001-10,000                1                   0    control
#> 1191    2,001-10,000                0                   1    control
#> 1192    2,001-10,000                1                   0    control
#> 1193   10,001-20,000                1                   0    control
#> 1194    2,001-10,000                1                   1    control
#> 1195   10,001-20,000                1                   0       ISAF
#> 1196    2,001-10,000                0                   0       ISAF
#> 1197    2,001-10,000                1                   0       ISAF
#> 1198    2,001-10,000                0                   0       ISAF
#> 1199    2,001-10,000                0                   0       ISAF
#> 1200   10,001-20,000                0                   0       ISAF
#> 1201   10,001-20,000                1                   1    taliban
#> 1202    2,001-10,000                0                   0    taliban
#> 1203    2,001-10,000                0                   0    taliban
#> 1204    2,001-10,000                1                   0    taliban
#> 1205    2,001-10,000                0                   0    taliban
#> 1206 less than 2,000                0                   1    taliban
#> 1207   10,001-20,000                0                   0    control
#> 1208   10,001-20,000                0                   1    control
#> 1209 less than 2,000                1                   0    control
#> 1210   10,001-20,000                0                   1    control
#> 1211   20,001-30,000                0                   0    control
#> 1212    2,001-10,000                0                   0    control
#> 1214   10,001-20,000                0                   0       ISAF
#> 1215   20,001-30,000                0                   0       ISAF
#> 1216   10,001-20,000                0                   0       ISAF
#> 1217   20,001-30,000                0                   0       ISAF
#> 1218 less than 2,000                0                   0       ISAF
#> 1219   10,001-20,000                0                   0    taliban
#> 1220   10,001-20,000                1                   0    taliban
#> 1221   10,001-20,000                0                   1    taliban
#> 1222    2,001-10,000                1                   1    taliban
#> 1223 less than 2,000                1                   0    taliban
#> 1224    2,001-10,000                0                   1    taliban
#> 1225   10,001-20,000                0                   0    control
#> 1226    2,001-10,000                0                   0    control
#> 1227   10,001-20,000                0                   0    control
#> 1228    2,001-10,000                0                   1    control
#> 1229    2,001-10,000                0                   0    control
#> 1230 less than 2,000                0                   0    control
#> 1231 less than 2,000                0                   0       ISAF
#> 1232 less than 2,000                0                   0       ISAF
#> 1233 less than 2,000                0                   0       ISAF
#> 1234 less than 2,000                0                   0       ISAF
#> 1235    2,001-10,000                0                   0       ISAF
#> 1236    2,001-10,000                0                   0       ISAF
#> 1237    2,001-10,000                1                   0    taliban
#> 1238 less than 2,000                0                   0    taliban
#> 1239 less than 2,000                0                   0    taliban
#> 1240   20,001-30,000                1                   1    taliban
#> 1241    2,001-10,000                0                   1    taliban
#> 1242    2,001-10,000                0                   0    taliban
#> 1243   10,001-20,000                0                   0    control
#> 1244    2,001-10,000                0                   0    control
#> 1245 less than 2,000                0                   0    control
#> 1246    2,001-10,000                0                   0       ISAF
#> 1247 less than 2,000                0                   0       ISAF
#> 1248 less than 2,000                0                   0       ISAF
#> 1249    2,001-10,000                0                   0    taliban
#> 1250   10,001-20,000                0                   0    taliban
#> 1251    2,001-10,000                0                   0    taliban
#> 1252 less than 2,000                0                   0    control
#> 1253 less than 2,000                0                   0    control
#> 1254   10,001-20,000                0                   1    control
#> 1255    2,001-10,000                0                   0       ISAF
#> 1256 less than 2,000                0                   0       ISAF
#> 1257   10,001-20,000                0                   1       ISAF
#> 1258   10,001-20,000                0                   0    taliban
#> 1259 less than 2,000                0                   0    taliban
#> 1260     over 30,000                0                   0    taliban
#> 1261    2,001-10,000                0                   0    control
#> 1262 less than 2,000                0                   1    control
#> 1263   10,001-20,000                0                   0    control
#> 1264    2,001-10,000                1                   1       ISAF
#> 1265   10,001-20,000                1                   1       ISAF
#> 1266 less than 2,000                1                   1       ISAF
#> 1267    2,001-10,000                1                   1    taliban
#> 1268    2,001-10,000                1                   1    taliban
#> 1269     over 30,000                1                   1    taliban
#> 1270    2,001-10,000                0                   0    control
#> 1271    2,001-10,000                0                   0    control
#> 1272    2,001-10,000                0                   0    control
#> 1273    2,001-10,000                0                   0    control
#> 1274   10,001-20,000                0                   0    control
#> 1275   20,001-30,000                0                   0    control
#> 1276    2,001-10,000                0                   0       ISAF
#> 1277    2,001-10,000                0                   0       ISAF
#> 1278   20,001-30,000                0                   1       ISAF
#> 1279   10,001-20,000                0                   0       ISAF
#> 1280   20,001-30,000                0                   0       ISAF
#> 1281   10,001-20,000                0                   0       ISAF
#> 1282   20,001-30,000                0                   0    taliban
#> 1283   20,001-30,000                0                   0    taliban
#> 1284   10,001-20,000                1                   0    taliban
#> 1285    2,001-10,000                1                   0    taliban
#> 1286    2,001-10,000                0                   0    taliban
#> 1287   10,001-20,000                1                   0    taliban
#> 1288 less than 2,000                0                   0    control
#> 1289    2,001-10,000                1                   1    control
#> 1290    2,001-10,000                0                   0    control
#> 1291    2,001-10,000                0                   0    control
#> 1292    2,001-10,000                0                   1    control
#> 1293 less than 2,000                0                   0    control
#> 1297 less than 2,000                0                   0       ISAF
#> 1300    2,001-10,000                0                   0    taliban
#> 1303 less than 2,000                0                   1    taliban
#> 1305    2,001-10,000                0                   0    taliban
#> 1306   10,001-20,000                0                   1    control
#> 1307    2,001-10,000                0                   0    control
#> 1308    2,001-10,000                1                   0    control
#> 1309    2,001-10,000                1                   0    control
#> 1310 less than 2,000                0                   1    control
#> 1311    2,001-10,000                1                   0    control
#> 1312   10,001-20,000                1                   0       ISAF
#> 1313    2,001-10,000                1                   0       ISAF
#> 1314 less than 2,000                1                   0       ISAF
#> 1315 less than 2,000                0                   1       ISAF
#> 1316    2,001-10,000                1                   0       ISAF
#> 1317    2,001-10,000                0                   0       ISAF
#> 1318 less than 2,000                1                   0    taliban
#> 1319   10,001-20,000                1                   0    taliban
#> 1320 less than 2,000                1                   0    taliban
#> 1321    2,001-10,000                1                   0    taliban
#> 1322 less than 2,000                0                   0    taliban
#> 1323    2,001-10,000                0                   0    taliban
#> 1324    2,001-10,000                0                   0    control
#> 1325   10,001-20,000                0                   0    control
#> 1326 less than 2,000                0                   0    control
#> 1327    2,001-10,000                0                   0    control
#> 1328   10,001-20,000                0                   0    control
#> 1329   20,001-30,000                0                   0    control
#> 1330   20,001-30,000                1                   0       ISAF
#> 1331   10,001-20,000                0                   0       ISAF
#> 1332   20,001-30,000                0                   1       ISAF
#> 1333   10,001-20,000                0                   0       ISAF
#> 1334   10,001-20,000                0                   0       ISAF
#> 1335   10,001-20,000                1                   0       ISAF
#> 1336   20,001-30,000                0                   0    taliban
#> 1337   10,001-20,000                0                   0    taliban
#> 1338   20,001-30,000                0                   0    taliban
#> 1339   20,001-30,000                0                   0    taliban
#> 1340   10,001-20,000                0                   0    taliban
#> 1341   10,001-20,000                0                   0    taliban
#> 1342   10,001-20,000                0                   1    control
#> 1343   10,001-20,000                0                   0    control
#> 1344   10,001-20,000                0                   0    control
#> 1345   10,001-20,000                0                   0       ISAF
#> 1346   10,001-20,000                0                   0       ISAF
#> 1347    2,001-10,000                1                   1       ISAF
#> 1348    2,001-10,000                0                   0    taliban
#> 1349    2,001-10,000                0                   0    taliban
#> 1350   10,001-20,000                0                   0    taliban
#> 1351    2,001-10,000                0                   1    control
#> 1352   10,001-20,000                0                   0    control
#> 1353   10,001-20,000                0                   0    control
#> 1354   20,001-30,000                0                   1       ISAF
#> 1355   10,001-20,000                1                   0       ISAF
#> 1356    2,001-10,000                0                   0       ISAF
#> 1357   10,001-20,000                0                   0    taliban
#> 1358   10,001-20,000                1                   0    taliban
#> 1359    2,001-10,000                0                   0    taliban
#> 1360    2,001-10,000                0                   0    control
#> 1361   10,001-20,000                0                   0    control
#> 1362   20,001-30,000                0                   0    control
#> 1363   10,001-20,000                0                   0       ISAF
#> 1364    2,001-10,000                0                   0       ISAF
#> 1365   10,001-20,000                0                   0       ISAF
#> 1366    2,001-10,000                1                   1    taliban
#> 1367    2,001-10,000                0                   1    taliban
#> 1368   10,001-20,000                0                   0    taliban
#> 1369    2,001-10,000                0                   1    control
#> 1370   10,001-20,000                0                   0    control
#> 1371   10,001-20,000                1                   0    control
#> 1372   20,001-30,000                0                   0       ISAF
#> 1373    2,001-10,000                0                   0       ISAF
#> 1374   10,001-20,000                0                   0       ISAF
#> 1375    2,001-10,000                0                   0    taliban
#> 1376   10,001-20,000                0                   0    taliban
#> 1377    2,001-10,000                0                   0    taliban
#> 1378    2,001-10,000                0                   0    control
#> 1379    2,001-10,000                0                   0    control
#> 1380    2,001-10,000                0                   0    control
#> 1381   10,001-20,000                0                   0       ISAF
#> 1382   10,001-20,000                0                   0       ISAF
#> 1383    2,001-10,000                0                   0       ISAF
#> 1384    2,001-10,000                0                   0    taliban
#> 1385    2,001-10,000                0                   0    taliban
#> 1386    2,001-10,000                0                   0    taliban
#> 1387   10,001-20,000                0                   0    control
#> 1388   10,001-20,000                1                   0    control
#> 1389    2,001-10,000                0                   0    control
#> 1390   10,001-20,000                0                   0       ISAF
#> 1391    2,001-10,000                0                   0       ISAF
#> 1392    2,001-10,000                0                   0       ISAF
#> 1393   10,001-20,000                0                   0    taliban
#> 1394    2,001-10,000                0                   0    taliban
#> 1395    2,001-10,000                0                   0    taliban
#> 1396    2,001-10,000                0                   0    control
#> 1397    2,001-10,000                0                   0    control
#> 1398   10,001-20,000                0                   0    control
#> 1399   10,001-20,000                0                   0       ISAF
#> 1400    2,001-10,000                0                   0       ISAF
#> 1401    2,001-10,000                1                   0       ISAF
#> 1402    2,001-10,000                0                   0    taliban
#> 1403   10,001-20,000                0                   0    taliban
#> 1404    2,001-10,000                0                   0    taliban
#> 1405 less than 2,000                0                   0    control
#> 1406 less than 2,000                0                   0    control
#> 1407 less than 2,000                0                   0    control
#> 1408   10,001-20,000                0                   0    control
#> 1409    2,001-10,000                0                   0    control
#> 1410    2,001-10,000                0                   0    control
#> 1411   10,001-20,000                0                   0       ISAF
#> 1412   10,001-20,000                0                   0       ISAF
#> 1413 less than 2,000                0                   0       ISAF
#> 1414   10,001-20,000                0                   0       ISAF
#> 1415    2,001-10,000                0                   0       ISAF
#> 1416    2,001-10,000                0                   0       ISAF
#> 1417 less than 2,000                0                   0    taliban
#> 1418    2,001-10,000                0                   0    taliban
#> 1419 less than 2,000                1                   0    taliban
#> 1420    2,001-10,000                0                   0    taliban
#> 1421    2,001-10,000                1                   1    taliban
#> 1422   10,001-20,000                0                   0    taliban
#> 1423 less than 2,000                0                   0    control
#> 1424 less than 2,000                0                   0    control
#> 1425    2,001-10,000                0                   1    control
#> 1426   20,001-30,000                0                   0    control
#> 1427   20,001-30,000                0                   0    control
#> 1428   10,001-20,000                1                   1    control
#> 1429 less than 2,000                0                   0       ISAF
#> 1430    2,001-10,000                1                   0       ISAF
#> 1431    2,001-10,000                0                   0       ISAF
#> 1432   20,001-30,000                0                   0       ISAF
#> 1433 less than 2,000                0                   0       ISAF
#> 1434     over 30,000                0                   0       ISAF
#> 1435    2,001-10,000                0                   0    taliban
#> 1436 less than 2,000                0                   0    taliban
#> 1437     over 30,000                0                   0    taliban
#> 1438 less than 2,000                0                   0    taliban
#> 1439 less than 2,000                0                   0    taliban
#> 1440    2,001-10,000                0                   0    taliban
#> 1441    2,001-10,000                1                   1    control
#> 1442     over 30,000                0                   1    control
#> 1443 less than 2,000                1                   1    control
#> 1444   10,001-20,000                0                   1    control
#> 1445     over 30,000                0                   1    control
#> 1446   20,001-30,000                0                   1    control
#> 1447   10,001-20,000                0                   1       ISAF
#> 1448     over 30,000                0                   0       ISAF
#> 1449    2,001-10,000                0                   0       ISAF
#> 1450    2,001-10,000                1                   1       ISAF
#> 1451   10,001-20,000                0                   1       ISAF
#> 1452   10,001-20,000                0                   1       ISAF
#> 1453    2,001-10,000                0                   1    taliban
#> 1454 less than 2,000                1                   0    taliban
#> 1455    2,001-10,000                1                   1    taliban
#> 1456     over 30,000                1                   1    taliban
#> 1457    2,001-10,000                0                   0    taliban
#> 1458    2,001-10,000                0                   0    taliban
#> 1459    2,001-10,000                0                   0    control
#> 1460    2,001-10,000                0                   0    control
#> 1461    2,001-10,000                0                   0    control
#> 1462   10,001-20,000                0                   0    control
#> 1463   10,001-20,000                0                   0    control
#> 1464    2,001-10,000                0                   0    control
#> 1465    2,001-10,000                0                   0       ISAF
#> 1466    2,001-10,000                0                   0       ISAF
#> 1467   10,001-20,000                0                   0       ISAF
#> 1469   10,001-20,000                0                   0       ISAF
#> 1470 less than 2,000                0                   0       ISAF
#> 1471    2,001-10,000                1                   0    taliban
#> 1472    2,001-10,000                0                   1    taliban
#> 1473 less than 2,000                1                   1    taliban
#> 1474   10,001-20,000                0                   0    taliban
#> 1475   10,001-20,000                0                   0    taliban
#> 1476   10,001-20,000                0                   0    taliban
#> 1477    2,001-10,000                0                   0    control
#> 1478   10,001-20,000                0                   0    control
#> 1479   10,001-20,000                0                   0    control
#> 1480    2,001-10,000                0                   0    control
#> 1481 less than 2,000                0                   0    control
#> 1482    2,001-10,000                0                   0    control
#> 1483    2,001-10,000                0                   0       ISAF
#> 1484   10,001-20,000                0                   0       ISAF
#> 1485   20,001-30,000                0                   0       ISAF
#> 1486 less than 2,000                0                   0       ISAF
#> 1487    2,001-10,000                0                   0       ISAF
#> 1488   10,001-20,000                0                   0       ISAF
#> 1489    2,001-10,000                0                   0    taliban
#> 1490   10,001-20,000                0                   0    taliban
#> 1491   10,001-20,000                0                   0    taliban
#> 1492   10,001-20,000                1                   0    taliban
#> 1493   10,001-20,000                0                   0    taliban
#> 1494   10,001-20,000                0                   0    taliban
#> 1495   10,001-20,000                0                   1    control
#> 1496    2,001-10,000                0                   0    control
#> 1497    2,001-10,000                0                   0    control
#> 1498   10,001-20,000                0                   0    control
#> 1499   10,001-20,000                0                   0    control
#> 1500 less than 2,000                0                   0    control
#> 1501   10,001-20,000                0                   0       ISAF
#> 1502   10,001-20,000                0                   0       ISAF
#> 1503   10,001-20,000                0                   0       ISAF
#> 1504    2,001-10,000                1                   0       ISAF
#> 1505    2,001-10,000                0                   0       ISAF
#> 1506 less than 2,000                0                   0       ISAF
#> 1507   20,001-30,000                0                   0    taliban
#> 1508 less than 2,000                0                   0    taliban
#> 1509 less than 2,000                0                   0    taliban
#> 1510    2,001-10,000                0                   0    taliban
#> 1511    2,001-10,000                0                   0    taliban
#> 1513    2,001-10,000                0                   1    control
#> 1521    2,001-10,000                1                   0    taliban
#> 1522   10,001-20,000                0                   1    control
#> 1523    2,001-10,000                1                   1    control
#> 1524    2,001-10,000                0                   1    control
#> 1525   10,001-20,000                1                   1       ISAF
#> 1526    2,001-10,000                0                   1       ISAF
#> 1527    2,001-10,000                0                   0       ISAF
#> 1528   10,001-20,000                1                   0    taliban
#> 1529   10,001-20,000                0                   0    taliban
#> 1530    2,001-10,000                0                   1    taliban
#> 1531    2,001-10,000                1                   1    control
#> 1532   10,001-20,000                0                   0    control
#> 1533   10,001-20,000                1                   1    control
#> 1534   10,001-20,000                1                   1       ISAF
#> 1535 less than 2,000                0                   1       ISAF
#> 1536    2,001-10,000                0                   1       ISAF
#> 1537   10,001-20,000                0                   1    taliban
#> 1538   10,001-20,000                1                   0    taliban
#> 1539    2,001-10,000                1                   0    taliban
#> 1540   10,001-20,000                1                   1    control
#> 1542    2,001-10,000                1                   1    control
#> 1543   20,001-30,000                1                   1       ISAF
#> 1544    2,001-10,000                1                   1       ISAF
#> 1545    2,001-10,000                1                   1       ISAF
#> 1546   20,001-30,000                1                   1    taliban
#> 1547   10,001-20,000                1                   1    taliban
#> 1548   10,001-20,000                1                   1    taliban
#> 1550    2,001-10,000                0                   1    control
#> 1551 less than 2,000                1                   1    control
#> 1552    2,001-10,000                1                   1       ISAF
#> 1553   10,001-20,000                1                   1       ISAF
#> 1555 less than 2,000                0                   0    taliban
#> 1556 less than 2,000                1                   0    taliban
#> 1558    2,001-10,000                1                   1    control
#> 1559    2,001-10,000                1                   0    control
#> 1560    2,001-10,000                0                   1    control
#> 1561   10,001-20,000                1                   1       ISAF
#> 1562    2,001-10,000                1                   1       ISAF
#> 1563   20,001-30,000                1                   1       ISAF
#> 1564    2,001-10,000                1                   1    taliban
#> 1566   20,001-30,000                1                   1    taliban
#> 1567   10,001-20,000                1                   0    control
#> 1570    2,001-10,000                0                   0       ISAF
#> 1571    2,001-10,000                0                   0       ISAF
#> 1572   10,001-20,000                0                   0       ISAF
#> 1573    2,001-10,000                1                   0    taliban
#> 1574   10,001-20,000                1                   0    taliban
#> 1577   10,001-20,000                1                   1    control
#> 1578   10,001-20,000                1                   1    control
#> 1579   20,001-30,000                1                   1    control
#> 1580   10,001-20,000                0                   1    control
#> 1581    2,001-10,000                0                   0    control
#> 1582   10,001-20,000                0                   1       ISAF
#> 1583   10,001-20,000                0                   0       ISAF
#> 1584    2,001-10,000                1                   1       ISAF
#> 1586   10,001-20,000                0                   0       ISAF
#> 1587    2,001-10,000                0                   0       ISAF
#> 1588   10,001-20,000                1                   0    taliban
#> 1590   10,001-20,000                0                   1    taliban
#> 1594    2,001-10,000                0                   0    control
#> 1595    2,001-10,000                0                   0    control
#> 1596    2,001-10,000                0                   1    control
#> 1597    2,001-10,000                0                   0    control
#> 1599    2,001-10,000                0                   0    control
#> 1600    2,001-10,000                0                   0       ISAF
#> 1602    2,001-10,000                0                   1       ISAF
#> 1604    2,001-10,000                1                   1       ISAF
#> 1605    2,001-10,000                0                   0       ISAF
#> 1606    2,001-10,000                0                   1    taliban
#> 1607    2,001-10,000                1                   0    taliban
#> 1609    2,001-10,000                0                   1    taliban
#> 1610    2,001-10,000                0                   1    taliban
#> 1611    2,001-10,000                0                   0    taliban
#> 1612    2,001-10,000                0                   0    control
#> 1613    2,001-10,000                0                   0    control
#> 1614   10,001-20,000                0                   1    control
#> 1615    2,001-10,000                0                   1    control
#> 1616   10,001-20,000                0                   0    control
#> 1617   10,001-20,000                0                   0    control
#> 1618    2,001-10,000                0                   0       ISAF
#> 1619    2,001-10,000                0                   0       ISAF
#> 1620    2,001-10,000                1                   0       ISAF
#> 1621    2,001-10,000                0                   0       ISAF
#> 1622    2,001-10,000                0                   1       ISAF
#> 1623    2,001-10,000                0                   1       ISAF
#> 1624   10,001-20,000                1                   0    taliban
#> 1625    2,001-10,000                0                   1    taliban
#> 1626    2,001-10,000                0                   0    taliban
#> 1627    2,001-10,000                0                   0    taliban
#> 1628   10,001-20,000                0                   0    taliban
#> 1629    2,001-10,000                1                   0    taliban
#> 1635   10,001-20,000                0                   1    control
#> 1637    2,001-10,000                0                   0       ISAF
#> 1643   10,001-20,000                0                   0    taliban
#> 1645    2,001-10,000                0                   1    taliban
#> 1648    2,001-10,000                1                   0    control
#> 1650   10,001-20,000                0                   1    control
#> 1651   20,001-30,000                1                   0    control
#> 1653    2,001-10,000                0                   0    control
#> 1654    2,001-10,000                0                   1       ISAF
#> 1655    2,001-10,000                1                   0       ISAF
#> 1657    2,001-10,000                0                   0       ISAF
#> 1662   10,001-20,000                0                   0    taliban
#> 1665    2,001-10,000                0                   0    taliban
#> 1666    2,001-10,000                0                   1    control
#> 1667    2,001-10,000                1                   0    control
#> 1668   10,001-20,000                1                   0    control
#> 1669    2,001-10,000                0                   1    control
#> 1670    2,001-10,000                0                   0    control
#> 1671    2,001-10,000                0                   0    control
#> 1673   10,001-20,000                0                   0       ISAF
#> 1674    2,001-10,000                0                   0       ISAF
#> 1675   10,001-20,000                1                   0       ISAF
#> 1676    2,001-10,000                1                   0       ISAF
#> 1677    2,001-10,000                0                   0       ISAF
#> 1678    2,001-10,000                0                   0    taliban
#> 1679    2,001-10,000                0                   0    taliban
#> 1681    2,001-10,000                0                   0    taliban
#> 1682    2,001-10,000                0                   0    taliban
#> 1683    2,001-10,000                0                   0    taliban
#> 1684    2,001-10,000                0                   0    control
#> 1685   10,001-20,000                0                   0    control
#> 1686   10,001-20,000                1                   0    control
#> 1687   10,001-20,000                0                   0    control
#> 1688   10,001-20,000                0                   0    control
#> 1689   10,001-20,000                1                   0    control
#> 1690   10,001-20,000                0                   0       ISAF
#> 1691   10,001-20,000                0                   0       ISAF
#> 1694   10,001-20,000                0                   0       ISAF
#> 1695   10,001-20,000                1                   1       ISAF
#> 1696    2,001-10,000                1                   1    taliban
#> 1698   10,001-20,000                0                   0    taliban
#> 1700   10,001-20,000                1                   0    taliban
#> 1701    2,001-10,000                0                   1    taliban
#> 1702   10,001-20,000                0                   1    control
#> 1703    2,001-10,000                0                   0    control
#> 1704    2,001-10,000                1                   1    control
#> 1705    2,001-10,000                0                   0    control
#> 1706    2,001-10,000                0                   1    control
#> 1707   10,001-20,000                0                   0    control
#> 1708    2,001-10,000                0                   0       ISAF
#> 1709   10,001-20,000                0                   0       ISAF
#> 1710    2,001-10,000                1                   1       ISAF
#> 1711    2,001-10,000                0                   0       ISAF
#> 1712    2,001-10,000                0                   1       ISAF
#> 1714    2,001-10,000                0                   0    taliban
#> 1715   10,001-20,000                0                   0    taliban
#> 1718   10,001-20,000                0                   0    taliban
#> 1720    2,001-10,000                0                   0    control
#> 1721    2,001-10,000                0                   0    control
#> 1722    2,001-10,000                1                   0    control
#> 1724    2,001-10,000                0                   0    control
#> 1725    2,001-10,000                0                   1    control
#> 1726    2,001-10,000                0                   1       ISAF
#> 1727    2,001-10,000                0                   0       ISAF
#> 1728    2,001-10,000                0                   1       ISAF
#> 1730   10,001-20,000                0                   1       ISAF
#> 1731    2,001-10,000                0                   0       ISAF
#> 1734    2,001-10,000                0                   1    taliban
#> 1735    2,001-10,000                1                   0    taliban
#> 1737    2,001-10,000                0                   0    taliban
#> 1738    2,001-10,000                0                   0    control
#> 1739    2,001-10,000                1                   1    control
#> 1740    2,001-10,000                1                   0    control
#> 1741   10,001-20,000                1                   1       ISAF
#> 1742    2,001-10,000                1                   0       ISAF
#> 1743    2,001-10,000                1                   1       ISAF
#> 1744    2,001-10,000                1                   1    taliban
#> 1745    2,001-10,000                1                   0    taliban
#> 1746   10,001-20,000                0                   1    taliban
#> 1747    2,001-10,000                1                   0    control
#> 1748   10,001-20,000                0                   0    control
#> 1749    2,001-10,000                0                   0    control
#> 1750    2,001-10,000                0                   0       ISAF
#> 1751    2,001-10,000                1                   0       ISAF
#> 1752    2,001-10,000                1                   0       ISAF
#> 1753    2,001-10,000                0                   0    taliban
#> 1754   10,001-20,000                1                   0    taliban
#> 1755    2,001-10,000                1                   0    taliban
#> 1756    2,001-10,000                0                   0    control
#> 1757    2,001-10,000                0                   0    control
#> 1758    2,001-10,000                0                   0    control
#> 1759    2,001-10,000                1                   0       ISAF
#> 1760    2,001-10,000                1                   0       ISAF
#> 1761    2,001-10,000                0                   0       ISAF
#> 1762    2,001-10,000                0                   0    taliban
#> 1763    2,001-10,000                0                   0    taliban
#> 1764    2,001-10,000                1                   0    taliban
#> 1765    2,001-10,000                0                   0    control
#> 1766    2,001-10,000                0                   1    control
#> 1767    2,001-10,000                0                   0    control
#> 1768   10,001-20,000                0                   0       ISAF
#> 1769   10,001-20,000                0                   0       ISAF
#> 1770    2,001-10,000                1                   0       ISAF
#> 1771    2,001-10,000                0                   0    taliban
#> 1772    2,001-10,000                0                   0    taliban
#> 1773   10,001-20,000                1                   0    taliban
#> 1774    2,001-10,000                1                   0    control
#> 1775   10,001-20,000                1                   0    control
#> 1776    2,001-10,000                0                   0    control
#> 1777   10,001-20,000                1                   0    control
#> 1778    2,001-10,000                1                   1    control
#> 1779    2,001-10,000                1                   0    control
#> 1780    2,001-10,000                1                   0       ISAF
#> 1781    2,001-10,000                1                   1       ISAF
#> 1782    2,001-10,000                0                   1       ISAF
#> 1783 less than 2,000                1                   1       ISAF
#> 1784    2,001-10,000                1                   0       ISAF
#> 1785    2,001-10,000                1                   0       ISAF
#> 1786    2,001-10,000                1                   0    taliban
#> 1787    2,001-10,000                1                   0    taliban
#> 1788    2,001-10,000                1                   1    taliban
#> 1789    2,001-10,000                1                   1    taliban
#> 1790   10,001-20,000                1                   0    taliban
#> 1791    2,001-10,000                1                   0    taliban
#> 1792    2,001-10,000                0                   0    control
#> 1793    2,001-10,000                0                   1    control
#> 1794    2,001-10,000                0                   0    control
#> 1795    2,001-10,000                1                   0    control
#> 1796   10,001-20,000                0                   0    control
#> 1797    2,001-10,000                1                   0    control
#> 1798    2,001-10,000                0                   0       ISAF
#> 1799    2,001-10,000                1                   0       ISAF
#> 1800    2,001-10,000                0                   0       ISAF
#> 1801    2,001-10,000                0                   0       ISAF
#> 1802    2,001-10,000                1                   0       ISAF
#> 1803    2,001-10,000                0                   0       ISAF
#> 1804    2,001-10,000                0                   0    taliban
#> 1805   10,001-20,000                0                   0    taliban
#> 1806    2,001-10,000                0                   0    taliban
#> 1807    2,001-10,000                1                   0    taliban
#> 1808    2,001-10,000                0                   0    taliban
#> 1809    2,001-10,000                0                   0    taliban
#> 1810    2,001-10,000                0                   0    control
#> 1811    2,001-10,000                0                   1    control
#> 1812    2,001-10,000                1                   0    control
#> 1813    2,001-10,000                0                   0    control
#> 1814    2,001-10,000                0                   0    control
#> 1815    2,001-10,000                0                   0    control
#> 1816    2,001-10,000                0                   0       ISAF
#> 1817    2,001-10,000                0                   1       ISAF
#> 1818    2,001-10,000                1                   0       ISAF
#> 1819    2,001-10,000                0                   0       ISAF
#> 1820    2,001-10,000                0                   1       ISAF
#> 1821   10,001-20,000                0                   0       ISAF
#> 1822    2,001-10,000                0                   1    taliban
#> 1823    2,001-10,000                0                   0    taliban
#> 1824   10,001-20,000                1                   1    taliban
#> 1825    2,001-10,000                0                   0    taliban
#> 1826    2,001-10,000                1                   0    taliban
#> 1827    2,001-10,000                0                   0    taliban
#> 1828    2,001-10,000                1                   0    control
#> 1829    2,001-10,000                1                   0    control
#> 1830    2,001-10,000                1                   0    control
#> 1831    2,001-10,000                1                   1    control
#> 1832    2,001-10,000                1                   1    control
#> 1833    2,001-10,000                1                   1    control
#> 1834    2,001-10,000                1                   1       ISAF
#> 1835    2,001-10,000                1                   0       ISAF
#> 1836    2,001-10,000                1                   1       ISAF
#> 1837    2,001-10,000                1                   1       ISAF
#> 1838    2,001-10,000                1                   0       ISAF
#> 1839 less than 2,000                1                   0       ISAF
#> 1840    2,001-10,000                0                   1    taliban
#> 1841   10,001-20,000                1                   0    taliban
#> 1842    2,001-10,000                1                   1    taliban
#> 1843    2,001-10,000                0                   1    taliban
#> 1844    2,001-10,000                0                   0    taliban
#> 1845    2,001-10,000                1                   0    taliban
#> 1846   10,001-20,000                1                   1    control
#> 1847    2,001-10,000                1                   1    control
#> 1848    2,001-10,000                1                   1    control
#> 1849    2,001-10,000                1                   1       ISAF
#> 1850    2,001-10,000                1                   1       ISAF
#> 1851    2,001-10,000                1                   1       ISAF
#> 1852    2,001-10,000                1                   1    taliban
#> 1853   10,001-20,000                1                   1    taliban
#> 1854   10,001-20,000                1                   1    taliban
#> 1855    2,001-10,000                1                   1    control
#> 1856    2,001-10,000                1                   1    control
#> 1857    2,001-10,000                0                   0    control
#> 1858    2,001-10,000                0                   0       ISAF
#> 1859    2,001-10,000                1                   1       ISAF
#> 1860    2,001-10,000                1                   1       ISAF
#> 1861    2,001-10,000                0                   1    taliban
#> 1862    2,001-10,000                0                   0    taliban
#> 1863    2,001-10,000                1                   0    taliban
#> 1864    2,001-10,000                1                   0    control
#> 1865    2,001-10,000                1                   0    control
#> 1866    2,001-10,000                1                   1    control
#> 1867    2,001-10,000                1                   0       ISAF
#> 1868    2,001-10,000                1                   1       ISAF
#> 1869    2,001-10,000                1                   1       ISAF
#> 1870    2,001-10,000                1                   0    taliban
#> 1871   10,001-20,000                1                   1    taliban
#> 1872    2,001-10,000                1                   1    taliban
#> 1873    2,001-10,000                1                   0    control
#> 1874    2,001-10,000                1                   1    control
#> 1875   10,001-20,000                1                   1    control
#> 1876    2,001-10,000                1                   1    control
#> 1877    2,001-10,000                1                   1    control
#> 1878    2,001-10,000                0                   1    control
#> 1879    2,001-10,000                1                   1       ISAF
#> 1880   10,001-20,000                1                   1       ISAF
#> 1881    2,001-10,000                1                   1       ISAF
#> 1882    2,001-10,000                1                   1       ISAF
#> 1883    2,001-10,000                0                   1       ISAF
#> 1884    2,001-10,000                1                   1       ISAF
#> 1885    2,001-10,000                1                   1    taliban
#> 1886   10,001-20,000                1                   1    taliban
#> 1887    2,001-10,000                1                   0    taliban
#> 1888    2,001-10,000                1                   1    taliban
#> 1889    2,001-10,000                1                   1    taliban
#> 1890    2,001-10,000                1                   1    taliban
#> 1891    2,001-10,000                1                   0    control
#> 1892    2,001-10,000                1                   0    control
#> 1893    2,001-10,000                1                   0    control
#> 1894   10,001-20,000                1                   0    control
#> 1895   10,001-20,000                1                   0    control
#> 1896    2,001-10,000                1                   0    control
#> 1897    2,001-10,000                1                   0       ISAF
#> 1898    2,001-10,000                1                   0       ISAF
#> 1899    2,001-10,000                1                   0       ISAF
#> 1900    2,001-10,000                1                   0       ISAF
#> 1901   20,001-30,000                1                   0       ISAF
#> 1902    2,001-10,000                1                   0       ISAF
#> 1903    2,001-10,000                1                   0    taliban
#> 1904    2,001-10,000                1                   0    taliban
#> 1905    2,001-10,000                1                   0    taliban
#> 1906    2,001-10,000                1                   0    taliban
#> 1907    2,001-10,000                1                   0    taliban
#> 1908    2,001-10,000                1                   0    taliban
#> 1910   10,001-20,000                0                   1    control
#> 1912    2,001-10,000                0                   0    control
#> 1913    2,001-10,000                0                   0    control
#> 1914    2,001-10,000                0                   0    control
#> 1915    2,001-10,000                0                   0       ISAF
#> 1916    2,001-10,000                0                   0       ISAF
#> 1917    2,001-10,000                0                   1       ISAF
#> 1919   10,001-20,000                0                   0       ISAF
#> 1920    2,001-10,000                1                   0       ISAF
#> 1922    2,001-10,000                0                   0    taliban
#> 1923    2,001-10,000                0                   1    taliban
#> 1925    2,001-10,000                0                   0    taliban
#> 1926    2,001-10,000                0                   1    taliban
#> 1927    2,001-10,000                0                   0    control
#> 1928    2,001-10,000                0                   0    control
#> 1929    2,001-10,000                1                   0    control
#> 1930    2,001-10,000                0                   0    control
#> 1931   10,001-20,000                0                   0    control
#> 1932   10,001-20,000                1                   0    control
#> 1933    2,001-10,000                0                   0       ISAF
#> 1934   10,001-20,000                1                   0       ISAF
#> 1935   10,001-20,000                0                   0       ISAF
#> 1936    2,001-10,000                0                   0       ISAF
#> 1937    2,001-10,000                0                   0       ISAF
#> 1938    2,001-10,000                0                   0       ISAF
#> 1939    2,001-10,000                0                   0    taliban
#> 1940    2,001-10,000                0                   1    taliban
#> 1941    2,001-10,000                1                   1    taliban
#> 1942    2,001-10,000                0                   1    taliban
#> 1943    2,001-10,000                1                   0    taliban
#> 1944    2,001-10,000                0                   1    taliban
#> 1945   10,001-20,000                0                   0    control
#> 1946    2,001-10,000                0                   0    control
#> 1947    2,001-10,000                0                   0    control
#> 1948    2,001-10,000                0                   1    control
#> 1949    2,001-10,000                1                   0    control
#> 1950   10,001-20,000                0                   1    control
#> 1951    2,001-10,000                0                   0       ISAF
#> 1952    2,001-10,000                0                   0       ISAF
#> 1953    2,001-10,000                0                   0       ISAF
#> 1954    2,001-10,000                0                   0       ISAF
#> 1955    2,001-10,000                0                   0       ISAF
#> 1956   10,001-20,000                0                   0       ISAF
#> 1957   10,001-20,000                0                   0    taliban
#> 1958    2,001-10,000                1                   1    taliban
#> 1959    2,001-10,000                0                   0    taliban
#> 1960    2,001-10,000                0                   0    taliban
#> 1961    2,001-10,000                0                   0    taliban
#> 1962    2,001-10,000                0                   0    taliban
#> 1965   10,001-20,000                1                   0    control
#> 1970    2,001-10,000                1                   0       ISAF
#> 1972   10,001-20,000                0                   1       ISAF
#> 1974   10,001-20,000                0                   0       ISAF
#> 1975   20,001-30,000                0                   1    taliban
#> 1980   10,001-20,000                1                   1    taliban
#> 1981    2,001-10,000                1                   1    control
#> 1982    2,001-10,000                1                   0    control
#> 1983    2,001-10,000                0                   0    control
#> 1984   10,001-20,000                1                   1    control
#> 1985    2,001-10,000                0                   0    control
#> 1986    2,001-10,000                0                   0    control
#> 1987   10,001-20,000                0                   1       ISAF
#> 1988    2,001-10,000                1                   1       ISAF
#> 1989    2,001-10,000                0                   0       ISAF
#> 1990    2,001-10,000                0                   0       ISAF
#> 1991   10,001-20,000                0                   0       ISAF
#> 1992    2,001-10,000                0                   1       ISAF
#> 1993    2,001-10,000                1                   1    taliban
#> 1994    2,001-10,000                1                   0    taliban
#> 1995    2,001-10,000                0                   1    taliban
#> 1996    2,001-10,000                1                   1    taliban
#> 1997    2,001-10,000                0                   0    taliban
#> 1998    2,001-10,000                1                   0    taliban
#> 1999    2,001-10,000                1                   1    control
#> 2000    2,001-10,000                1                   1    control
#> 2001   10,001-20,000                1                   1    control
#> 2002   10,001-20,000                1                   1    control
#> 2003    2,001-10,000                1                   1    control
#> 2004    2,001-10,000                1                   1    control
#> 2005   10,001-20,000                1                   1       ISAF
#> 2006   10,001-20,000                1                   1       ISAF
#> 2007    2,001-10,000                1                   1       ISAF
#> 2008    2,001-10,000                1                   1       ISAF
#> 2009   10,001-20,000                1                   1       ISAF
#> 2010   10,001-20,000                1                   1       ISAF
#> 2011    2,001-10,000                1                   1    taliban
#> 2012    2,001-10,000                1                   1    taliban
#> 2013    2,001-10,000                1                   1    taliban
#> 2014   10,001-20,000                1                   1    taliban
#> 2015   10,001-20,000                1                   1    taliban
#> 2016    2,001-10,000                1                   1    taliban
#> 2017   10,001-20,000                1                   0    control
#> 2018   10,001-20,000                0                   0    control
#> 2019    2,001-10,000                1                   0    control
#> 2020   10,001-20,000                0                   0    control
#> 2021    2,001-10,000                1                   1    control
#> 2022    2,001-10,000                1                   1    control
#> 2023   10,001-20,000                0                   1       ISAF
#> 2024    2,001-10,000                1                   0       ISAF
#> 2025    2,001-10,000                0                   0       ISAF
#> 2026    2,001-10,000                1                   0       ISAF
#> 2027    2,001-10,000                0                   1       ISAF
#> 2028    2,001-10,000                0                   1       ISAF
#> 2029    2,001-10,000                0                   0    taliban
#> 2030    2,001-10,000                0                   0    taliban
#> 2031    2,001-10,000                1                   1    taliban
#> 2032    2,001-10,000                0                   0    taliban
#> 2033   10,001-20,000                1                   0    taliban
#> 2034    2,001-10,000                0                   0    taliban
#> 2035    2,001-10,000                0                   1    control
#> 2036    2,001-10,000                0                   0    control
#> 2037    2,001-10,000                0                   1    control
#> 2038   10,001-20,000                0                   1    control
#> 2039    2,001-10,000                0                   0    control
#> 2040    2,001-10,000                1                   0    control
#> 2041    2,001-10,000                0                   0       ISAF
#> 2042    2,001-10,000                0                   0       ISAF
#> 2043    2,001-10,000                0                   1       ISAF
#> 2044    2,001-10,000                0                   0       ISAF
#> 2045    2,001-10,000                0                   1       ISAF
#> 2046   10,001-20,000                0                   1       ISAF
#> 2047    2,001-10,000                0                   1    taliban
#> 2048    2,001-10,000                1                   0    taliban
#> 2049    2,001-10,000                0                   0    taliban
#> 2050    2,001-10,000                1                   1    taliban
#> 2051   10,001-20,000                0                   1    taliban
#> 2052    2,001-10,000                1                   0    taliban
#> 2053    2,001-10,000                0                   0    control
#> 2054    2,001-10,000                0                   1    control
#> 2055    2,001-10,000                1                   0    control
#> 2056    2,001-10,000                0                   1    control
#> 2057    2,001-10,000                1                   0    control
#> 2058    2,001-10,000                1                   0    control
#> 2059    2,001-10,000                1                   0       ISAF
#> 2060   10,001-20,000                0                   1       ISAF
#> 2061   10,001-20,000                1                   1       ISAF
#> 2062    2,001-10,000                1                   1       ISAF
#> 2063    2,001-10,000                0                   1       ISAF
#> 2064    2,001-10,000                0                   1       ISAF
#> 2065   10,001-20,000                1                   0    taliban
#> 2066    2,001-10,000                1                   1    taliban
#> 2067   10,001-20,000                1                   1    taliban
#> 2068    2,001-10,000                1                   1    taliban
#> 2069   10,001-20,000                1                   1    taliban
#> 2070    2,001-10,000                1                   1    taliban
#> 2072   10,001-20,000                0                   1    control
#> 2073    2,001-10,000                1                   1    control
#> 2074   10,001-20,000                1                   1       ISAF
#> 2075   10,001-20,000                1                   1       ISAF
#> 2076    2,001-10,000                0                   0       ISAF
#> 2077    2,001-10,000                1                   1    taliban
#> 2078   10,001-20,000                1                   0    taliban
#> 2079   10,001-20,000                1                   1    taliban
#> 2081    2,001-10,000                0                   0    control
#> 2082    2,001-10,000                0                   0    control
#> 2083    2,001-10,000                1                   0       ISAF
#> 2084    2,001-10,000                0                   1       ISAF
#> 2085    2,001-10,000                0                   0       ISAF
#> 2086    2,001-10,000                1                   1    taliban
#> 2087    2,001-10,000                0                   0    taliban
#> 2088   10,001-20,000                0                   0    taliban
#> 2089    2,001-10,000                1                   1    control
#> 2090    2,001-10,000                1                   1    control
#> 2091    2,001-10,000                1                   1    control
#> 2092   20,001-30,000                1                   1       ISAF
#> 2093 less than 2,000                1                   1       ISAF
#> 2094 less than 2,000                1                   1       ISAF
#> 2095   10,001-20,000                1                   1    taliban
#> 2096    2,001-10,000                1                   1    taliban
#> 2097    2,001-10,000                1                   1    taliban
#> 2098 less than 2,000                1                   1    control
#> 2099   10,001-20,000                0                   1    control
#> 2100   20,001-30,000                1                   1    control
#> 2101   10,001-20,000                1                   1       ISAF
#> 2102   10,001-20,000                1                   1       ISAF
#> 2103    2,001-10,000                1                   1       ISAF
#> 2104 less than 2,000                1                   1    taliban
#> 2106    2,001-10,000                1                   1    taliban
#> 2107   10,001-20,000                1                   1    control
#> 2108    2,001-10,000                1                   1    control
#> 2109   10,001-20,000                1                   1    control
#> 2110    2,001-10,000                1                   1       ISAF
#> 2111    2,001-10,000                1                   1       ISAF
#> 2112    2,001-10,000                1                   1       ISAF
#> 2113    2,001-10,000                1                   1    taliban
#> 2114 less than 2,000                1                   1    taliban
#> 2115   20,001-30,000                1                   1    taliban
#> 2116   10,001-20,000                1                   1    control
#> 2117   10,001-20,000                1                   1    control
#> 2118   20,001-30,000                1                   1    control
#> 2119   10,001-20,000                1                   1       ISAF
#> 2120    2,001-10,000                1                   1       ISAF
#> 2121    2,001-10,000                1                   1       ISAF
#> 2122   10,001-20,000                1                   1    taliban
#> 2123   20,001-30,000                1                   1    taliban
#> 2124    2,001-10,000                1                   1    taliban
#> 2125   20,001-30,000                1                   1    control
#> 2126   10,001-20,000                0                   1    control
#> 2127    2,001-10,000                1                   0    control
#> 2128   10,001-20,000                1                   1       ISAF
#> 2129   10,001-20,000                1                   1       ISAF
#> 2130    2,001-10,000                0                   0       ISAF
#> 2131   10,001-20,000                1                   1    taliban
#> 2132   10,001-20,000                0                   0    taliban
#> 2133   10,001-20,000                1                   0    taliban
#> 2134 less than 2,000                1                   1    control
#> 2135    2,001-10,000                1                   1    control
#> 2136    2,001-10,000                1                   1    control
#> 2137    2,001-10,000                1                   1       ISAF
#> 2138   10,001-20,000                1                   1       ISAF
#> 2139    2,001-10,000                1                   1       ISAF
#> 2140   10,001-20,000                1                   1    taliban
#> 2141    2,001-10,000                1                   1    taliban
#> 2142   10,001-20,000                1                   1    taliban
#> 2143    2,001-10,000                1                   1    control
#> 2144   10,001-20,000                1                   1    control
#> 2145   10,001-20,000                1                   0    control
#> 2146   10,001-20,000                0                   1    control
#> 2147    2,001-10,000                1                   1    control
#> 2148   10,001-20,000                1                   1    control
#> 2149    2,001-10,000                1                   0       ISAF
#> 2150   10,001-20,000                1                   1       ISAF
#> 2151   10,001-20,000                1                   1       ISAF
#> 2152   10,001-20,000                1                   1       ISAF
#> 2153   10,001-20,000                1                   1       ISAF
#> 2154    2,001-10,000                1                   1       ISAF
#> 2155   10,001-20,000                1                   1    taliban
#> 2156    2,001-10,000                1                   1    taliban
#> 2157   10,001-20,000                1                   1    taliban
#> 2158    2,001-10,000                1                   1    taliban
#> 2159   10,001-20,000                1                   1    taliban
#> 2160   10,001-20,000                0                   1    taliban
#> 2161   10,001-20,000                0                   0    control
#> 2162    2,001-10,000                0                   0    control
#> 2163    2,001-10,000                0                   0    control
#> 2164   10,001-20,000                0                   0    control
#> 2165    2,001-10,000                0                   0    control
#> 2166    2,001-10,000                0                   0    control
#> 2167    2,001-10,000                0                   1       ISAF
#> 2168    2,001-10,000                0                   0       ISAF
#> 2170    2,001-10,000                0                   1       ISAF
#> 2171    2,001-10,000                0                   0       ISAF
#> 2172    2,001-10,000                0                   0       ISAF
#> 2173   10,001-20,000                0                   0    taliban
#> 2175    2,001-10,000                1                   1    taliban
#> 2176   10,001-20,000                1                   0    taliban
#> 2177    2,001-10,000                1                   1    taliban
#> 2179    2,001-10,000                1                   0    control
#> 2180    2,001-10,000                0                   1    control
#> 2181    2,001-10,000                0                   0    control
#> 2182    2,001-10,000                1                   0    control
#> 2183   10,001-20,000                1                   0    control
#> 2184    2,001-10,000                0                   0    control
#> 2185    2,001-10,000                1                   1       ISAF
#> 2186   10,001-20,000                1                   0       ISAF
#> 2187    2,001-10,000                1                   0       ISAF
#> 2188    2,001-10,000                1                   0       ISAF
#> 2189    2,001-10,000                0                   0       ISAF
#> 2190    2,001-10,000                1                   1       ISAF
#> 2191    2,001-10,000                0                   1    taliban
#> 2192    2,001-10,000                0                   0    taliban
#> 2193    2,001-10,000                0                   0    taliban
#> 2194    2,001-10,000                1                   1    taliban
#> 2195 less than 2,000                0                   0    taliban
#> 2196    2,001-10,000                0                   0    taliban
#> 2197    2,001-10,000                1                   0    control
#> 2198    2,001-10,000                1                   0    control
#> 2200    2,001-10,000                0                   0    control
#> 2201    2,001-10,000                1                   0    control
#> 2202    2,001-10,000                0                   0    control
#> 2203    2,001-10,000                1                   0       ISAF
#> 2204    2,001-10,000                1                   0       ISAF
#> 2207    2,001-10,000                0                   0       ISAF
#> 2208    2,001-10,000                1                   0       ISAF
#> 2211    2,001-10,000                1                   0    taliban
#> 2212    2,001-10,000                1                   1    taliban
#> 2214    2,001-10,000                1                   0    taliban
#> 2215    2,001-10,000                1                   1    control
#> 2216    2,001-10,000                1                   1    control
#> 2217    2,001-10,000                1                   1    control
#> 2218 less than 2,000                0                   1    control
#> 2219    2,001-10,000                1                   1    control
#> 2220 less than 2,000                0                   1    control
#> 2221    2,001-10,000                1                   1       ISAF
#> 2222    2,001-10,000                0                   1       ISAF
#> 2223 less than 2,000                1                   0       ISAF
#> 2224    2,001-10,000                1                   1       ISAF
#> 2225    2,001-10,000                0                   1       ISAF
#> 2226    2,001-10,000                1                   1       ISAF
#> 2227 less than 2,000                0                   1    taliban
#> 2228 less than 2,000                0                   1    taliban
#> 2229 less than 2,000                0                   1    taliban
#> 2230    2,001-10,000                1                   1    taliban
#> 2231    2,001-10,000                1                   1    taliban
#> 2232    2,001-10,000                1                   1    taliban
#> 2233 less than 2,000                0                   1    control
#> 2235   10,001-20,000                1                   1    control
#> 2236   10,001-20,000                1                   1    control
#> 2237   10,001-20,000                1                   1    control
#> 2238    2,001-10,000                0                   0    control
#> 2240    2,001-10,000                1                   1       ISAF
#> 2242    2,001-10,000                1                   1       ISAF
#> 2243   10,001-20,000                0                   1       ISAF
#> 2244 less than 2,000                1                   1       ISAF
#> 2245   10,001-20,000                1                   1    taliban
#> 2246   10,001-20,000                1                   1    taliban
#> 2248 less than 2,000                1                   0    taliban
#> 2249    2,001-10,000                1                   0    taliban
#> 2250 less than 2,000                1                   1    taliban
#> 2251   10,001-20,000                1                   1    control
#> 2252    2,001-10,000                1                   1    control
#> 2253    2,001-10,000                1                   1    control
#> 2254 less than 2,000                1                   1    control
#> 2255    2,001-10,000                1                   1    control
#> 2256    2,001-10,000                1                   0    control
#> 2257    2,001-10,000                1                   0       ISAF
#> 2258   10,001-20,000                1                   0       ISAF
#> 2259 less than 2,000                0                   0       ISAF
#> 2260 less than 2,000                1                   1       ISAF
#> 2261    2,001-10,000                1                   1       ISAF
#> 2262    2,001-10,000                1                   0       ISAF
#> 2263    2,001-10,000                1                   1    taliban
#> 2264    2,001-10,000                1                   0    taliban
#> 2265    2,001-10,000                0                   0    taliban
#> 2266 less than 2,000                1                   0    taliban
#> 2267    2,001-10,000                1                   0    taliban
#> 2268    2,001-10,000                1                   0    taliban
#> 2269   20,001-30,000                1                   1    control
#> 2270   10,001-20,000                1                   1    control
#> 2271   10,001-20,000                1                   1    control
#> 2272    2,001-10,000                1                   1    control
#> 2274    2,001-10,000                1                   1    control
#> 2276    2,001-10,000                1                   1       ISAF
#> 2277   10,001-20,000                0                   0       ISAF
#> 2278 less than 2,000                1                   1       ISAF
#> 2279 less than 2,000                0                   0       ISAF
#> 2282    2,001-10,000                1                   1    taliban
#> 2283    2,001-10,000                1                   1    taliban
#> 2284   10,001-20,000                1                   1    taliban
#> 2285    2,001-10,000                1                   1    taliban
#> 2286   20,001-30,000                1                   1    taliban
#> 2287 less than 2,000                0                   1    control
#> 2288    2,001-10,000                0                   1    control
#> 2289    2,001-10,000                0                   1    control
#> 2291 less than 2,000                0                   1       ISAF
#> 2292    2,001-10,000                0                   1       ISAF
#> 2294    2,001-10,000                0                   0    taliban
#> 2295    2,001-10,000                0                   0    taliban
#> 2296   10,001-20,000                0                   1    control
#> 2297 less than 2,000                1                   1    control
#> 2298   10,001-20,000                1                   1    control
#> 2299   10,001-20,000                1                   1       ISAF
#> 2300   10,001-20,000                1                   1       ISAF
#> 2301    2,001-10,000                1                   0       ISAF
#> 2302   10,001-20,000                1                   1    taliban
#> 2303    2,001-10,000                1                   1    taliban
#> 2304    2,001-10,000                0                   1    taliban
#> 2305   10,001-20,000                0                   1    control
#> 2306    2,001-10,000                0                   1    control
#> 2307   10,001-20,000                1                   1    control
#> 2308    2,001-10,000                1                   1       ISAF
#> 2309    2,001-10,000                1                   1       ISAF
#> 2310 less than 2,000                1                   0       ISAF
#> 2311   10,001-20,000                0                   1    taliban
#> 2312 less than 2,000                0                   1    taliban
#> 2313    2,001-10,000                1                   1    taliban
#> 2314 less than 2,000                1                   1    control
#> 2315    2,001-10,000                1                   1    control
#> 2316   20,001-30,000                1                   1    control
#> 2317    2,001-10,000                1                   1       ISAF
#> 2318   10,001-20,000                1                   1       ISAF
#> 2319   10,001-20,000                1                   1       ISAF
#> 2320    2,001-10,000                1                   1    taliban
#> 2321    2,001-10,000                1                   1    taliban
#> 2322   10,001-20,000                1                   1    taliban
#> 2323   10,001-20,000                1                   1    control
#> 2324    2,001-10,000                1                   1    control
#> 2325    2,001-10,000                1                   0    control
#> 2326   10,001-20,000                1                   1       ISAF
#> 2327   10,001-20,000                1                   1       ISAF
#> 2328   10,001-20,000                1                   1       ISAF
#> 2329    2,001-10,000                1                   1    taliban
#> 2330 less than 2,000                1                   1    taliban
#> 2331    2,001-10,000                0                   1    taliban
#> 2332   10,001-20,000                1                   0    control
#> 2333   10,001-20,000                0                   1    control
#> 2342    2,001-10,000                1                   1       ISAF
#> 2344    2,001-10,000                0                   1    taliban
#> 2348    2,001-10,000                0                   0    taliban
#> 2352   10,001-20,000                0                   0    control
#> 2354    2,001-10,000                0                   1    control
#> 2357    2,001-10,000                1                   1       ISAF
#> 2359    2,001-10,000                1                   1       ISAF
#> 2361   10,001-20,000                0                   1       ISAF
#> 2365   10,001-20,000                1                   1    taliban
#> 2367    2,001-10,000                1                   1    taliban
#> 2368 less than 2,000                0                   0    control
#> 2369 less than 2,000                0                   0    control
#> 2370 less than 2,000                0                   0    control
#> 2371 less than 2,000                0                   1       ISAF
#> 2372 less than 2,000                0                   0       ISAF
#> 2373 less than 2,000                0                   0       ISAF
#> 2374 less than 2,000                0                   0    taliban
#> 2375    2,001-10,000                0                   0    taliban
#> 2376 less than 2,000                0                   0    taliban
#> 2377 less than 2,000                1                   0    control
#> 2378    2,001-10,000                0                   1    control
#> 2379 less than 2,000                0                   1    control
#> 2380    2,001-10,000                0                   0       ISAF
#> 2381    2,001-10,000                1                   1       ISAF
#> 2382 less than 2,000                1                   1       ISAF
#> 2383    2,001-10,000                1                   0    taliban
#> 2384 less than 2,000                0                   0    taliban
#> 2385    2,001-10,000                0                   1    taliban
#> 2386    2,001-10,000                1                   1    control
#> 2387    2,001-10,000                1                   1    control
#> 2388    2,001-10,000                1                   0    control
#> 2389    2,001-10,000                1                   1       ISAF
#> 2390 less than 2,000                1                   0       ISAF
#> 2391    2,001-10,000                1                   0       ISAF
#> 2392 less than 2,000                1                   0    taliban
#> 2393 less than 2,000                1                   0    taliban
#> 2394    2,001-10,000                1                   0    taliban
#> 2395 less than 2,000                1                   0    control
#> 2396 less than 2,000                0                   0    control
#> 2397 less than 2,000                0                   0    control
#> 2398 less than 2,000                0                   0       ISAF
#> 2399 less than 2,000                0                   0       ISAF
#> 2400 less than 2,000                0                   0       ISAF
#> 2401 less than 2,000                0                   0    taliban
#> 2402 less than 2,000                0                   0    taliban
#> 2403    2,001-10,000                0                   0    taliban
#> 2404 less than 2,000                0                   0    control
#> 2405    2,001-10,000                0                   1    control
#> 2406   10,001-20,000                1                   1    control
#> 2407 less than 2,000                0                   1       ISAF
#> 2408 less than 2,000                0                   0       ISAF
#> 2409 less than 2,000                0                   0       ISAF
#> 2410    2,001-10,000                0                   0    taliban
#> 2411    2,001-10,000                0                   1    taliban
#> 2412    2,001-10,000                0                   1    taliban
#> 2413   20,001-30,000                1                   1    control
#> 2414 less than 2,000                1                   1    control
#> 2415 less than 2,000                1                   0    control
#> 2416 less than 2,000                1                   0    control
#> 2417 less than 2,000                1                   1    control
#> 2418 less than 2,000                1                   1    control
#> 2419 less than 2,000                1                   0       ISAF
#> 2420 less than 2,000                1                   0       ISAF
#> 2421 less than 2,000                1                   1       ISAF
#> 2422 less than 2,000                1                   1       ISAF
#> 2423 less than 2,000                1                   1       ISAF
#> 2424 less than 2,000                0                   1       ISAF
#> 2426     over 30,000                1                   0    taliban
#> 2427 less than 2,000                1                   1    taliban
#> 2428 less than 2,000                1                   0    taliban
#> 2429 less than 2,000                1                   0    taliban
#> 2430 less than 2,000                1                   0    taliban
#> 2431    2,001-10,000                1                   0    control
#> 2434    2,001-10,000                1                   1    control
#> 2435    2,001-10,000                1                   1    control
#> 2436 less than 2,000                1                   0    control
#> 2437 less than 2,000                1                   0       ISAF
#> 2438 less than 2,000                1                   0       ISAF
#> 2439 less than 2,000                1                   0       ISAF
#> 2441    2,001-10,000                0                   0       ISAF
#> 2442 less than 2,000                0                   0       ISAF
#> 2443 less than 2,000                1                   0    taliban
#> 2444    2,001-10,000                0                   0    taliban
#> 2445 less than 2,000                0                   1    taliban
#> 2446 less than 2,000                0                   0    taliban
#> 2449    2,001-10,000                1                   0    control
#> 2450    2,001-10,000                0                   0    control
#> 2451 less than 2,000                0                   1    control
#> 2452 less than 2,000                0                   1    control
#> 2453 less than 2,000                1                   0    control
#> 2454    2,001-10,000                0                   1    control
#> 2455    2,001-10,000                1                   1       ISAF
#> 2456 less than 2,000                1                   0       ISAF
#> 2457 less than 2,000                0                   0       ISAF
#> 2458 less than 2,000                0                   1       ISAF
#> 2459    2,001-10,000                1                   0       ISAF
#> 2460    2,001-10,000                0                   1       ISAF
#> 2461    2,001-10,000                1                   1    taliban
#> 2463 less than 2,000                1                   1    taliban
#> 2464    2,001-10,000                1                   1    taliban
#> 2465 less than 2,000                0                   1    taliban
#> 2466 less than 2,000                0                   0    taliban
#> 2467    2,001-10,000                0                   0    control
#> 2468 less than 2,000                0                   1    control
#> 2469    2,001-10,000                0                   1    control
#> 2470    2,001-10,000                0                   0    control
#> 2471 less than 2,000                0                   1    control
#> 2472    2,001-10,000                0                   1    control
#> 2473 less than 2,000                0                   1       ISAF
#> 2474 less than 2,000                0                   0       ISAF
#> 2475    2,001-10,000                0                   0       ISAF
#> 2476    2,001-10,000                1                   0       ISAF
#> 2477 less than 2,000                0                   0       ISAF
#> 2478    2,001-10,000                0                   0       ISAF
#> 2479 less than 2,000                0                   1    taliban
#> 2480    2,001-10,000                0                   0    taliban
#> 2481    2,001-10,000                0                   0    taliban
#> 2482    2,001-10,000                0                   0    taliban
#> 2483    2,001-10,000                0                   1    taliban
#> 2484    2,001-10,000                0                   1    taliban
#> 2485 less than 2,000                1                   0    control
#> 2486    2,001-10,000                0                   0    control
#> 2487 less than 2,000                1                   1    control
#> 2488 less than 2,000                1                   1       ISAF
#> 2489   10,001-20,000                1                   0       ISAF
#> 2490 less than 2,000                1                   0       ISAF
#> 2494 less than 2,000                1                   1    control
#> 2498 less than 2,000                0                   1       ISAF
#> 2499 less than 2,000                0                   0       ISAF
#> 2502 less than 2,000                1                   0    taliban
#> 2503 less than 2,000                1                   1    control
#> 2504 less than 2,000                1                   1    control
#> 2505 less than 2,000                0                   1    control
#> 2506 less than 2,000                1                   1       ISAF
#> 2507 less than 2,000                1                   1       ISAF
#> 2508 less than 2,000                1                   1       ISAF
#> 2509     over 30,000                1                   1    taliban
#> 2510 less than 2,000                1                   1    taliban
#> 2511 less than 2,000                1                   0    taliban
#> 2512 less than 2,000                1                   1    control
#> 2513 less than 2,000                1                   0    control
#> 2515 less than 2,000                1                   1       ISAF
#> 2517 less than 2,000                1                   0       ISAF
#> 2519 less than 2,000                1                   1    taliban
#> 2520 less than 2,000                1                   0    taliban
#> 2521 less than 2,000                1                   1    control
#> 2522 less than 2,000                1                   0    control
#> 2524 less than 2,000                1                   0       ISAF
#> 2525 less than 2,000                1                   1       ISAF
#> 2526 less than 2,000                1                   1       ISAF
#> 2527 less than 2,000                1                   0    taliban
#> 2529 less than 2,000                1                   1    taliban
#> 2530 less than 2,000                0                   0    control
#> 2531 less than 2,000                0                   1    control
#> 2532    2,001-10,000                0                   1    control
#> 2533    2,001-10,000                0                   0    control
#> 2534    2,001-10,000                0                   1    control
#> 2535 less than 2,000                0                   0    control
#> 2536 less than 2,000                1                   0       ISAF
#> 2537 less than 2,000                0                   0       ISAF
#> 2538    2,001-10,000                0                   0       ISAF
#> 2539    2,001-10,000                0                   0       ISAF
#> 2540    2,001-10,000                0                   0       ISAF
#> 2541    2,001-10,000                0                   0       ISAF
#> 2542    2,001-10,000                0                   0    taliban
#> 2543 less than 2,000                0                   0    taliban
#> 2544    2,001-10,000                0                   0    taliban
#> 2545    2,001-10,000                0                   0    taliban
#> 2546    2,001-10,000                0                   0    taliban
#> 2547    2,001-10,000                0                   0    taliban
#> 2548    2,001-10,000                0                   0    control
#> 2549 less than 2,000                0                   0    control
#> 2550 less than 2,000                0                   0    control
#> 2551    2,001-10,000                0                   0    control
#> 2552    2,001-10,000                0                   0    control
#> 2553    2,001-10,000                0                   0    control
#> 2554    2,001-10,000                0                   0       ISAF
#> 2555    2,001-10,000                0                   0       ISAF
#> 2556    2,001-10,000                0                   0       ISAF
#> 2557    2,001-10,000                0                   0       ISAF
#> 2558    2,001-10,000                0                   1       ISAF
#> 2559    2,001-10,000                0                   0       ISAF
#> 2560    2,001-10,000                0                   1    taliban
#> 2561    2,001-10,000                0                   0    taliban
#> 2562    2,001-10,000                0                   0    taliban
#> 2563    2,001-10,000                0                   1    taliban
#> 2564    2,001-10,000                0                   0    taliban
#> 2565 less than 2,000                1                   1    taliban
#> 2566 less than 2,000                0                   1    control
#> 2567 less than 2,000                1                   1    control
#> 2568 less than 2,000                1                   1    control
#> 2569 less than 2,000                0                   1    control
#> 2570 less than 2,000                1                   1    control
#> 2571 less than 2,000                1                   1    control
#> 2572 less than 2,000                0                   1       ISAF
#> 2573 less than 2,000                1                   1       ISAF
#> 2576    2,001-10,000                1                   1       ISAF
#> 2577 less than 2,000                1                   1       ISAF
#> 2578 less than 2,000                1                   1    taliban
#> 2579    2,001-10,000                1                   1    taliban
#> 2580 less than 2,000                1                   1    taliban
#> 2581    2,001-10,000                1                   1    taliban
#> 2582 less than 2,000                1                   1    taliban
#> 2583 less than 2,000                1                   1    taliban
#> 2585 less than 2,000                1                   1    control
#> 2586 less than 2,000                1                   0    control
#> 2587 less than 2,000                0                   1    control
#> 2589    2,001-10,000                1                   1    control
#> 2591 less than 2,000                1                   1       ISAF
#> 2593    2,001-10,000                1                   1       ISAF
#> 2594    2,001-10,000                1                   1       ISAF
#> 2595    2,001-10,000                1                   1       ISAF
#> 2597 less than 2,000                1                   1    taliban
#> 2599 less than 2,000                0                   1    taliban
#> 2600 less than 2,000                1                   1    taliban
#> 2601    2,001-10,000                1                   1    taliban
#> 2602    2,001-10,000                0                   0    control
#> 2603 less than 2,000                0                   0    control
#> 2604    2,001-10,000                0                   0    control
#> 2605 less than 2,000                0                   0       ISAF
#> 2606 less than 2,000                0                   0       ISAF
#> 2607 less than 2,000                0                   0       ISAF
#> 2608 less than 2,000                0                   0    taliban
#> 2609 less than 2,000                0                   0    taliban
#> 2610    2,001-10,000                0                   0    taliban
#> 2611 less than 2,000                1                   1    control
#> 2612 less than 2,000                0                   1    control
#> 2613 less than 2,000                1                   1    control
#> 2614 less than 2,000                1                   1       ISAF
#> 2615 less than 2,000                1                   1       ISAF
#> 2616 less than 2,000                1                   1       ISAF
#> 2617 less than 2,000                1                   0    taliban
#> 2618 less than 2,000                1                   1    taliban
#> 2619 less than 2,000                1                   1    taliban
#> 2620 less than 2,000                1                   1    control
#> 2621 less than 2,000                1                   0    control
#> 2622 less than 2,000                1                   0    control
#> 2623 less than 2,000                1                   0       ISAF
#> 2624 less than 2,000                1                   0       ISAF
#> 2625 less than 2,000                1                   0       ISAF
#> 2626 less than 2,000                1                   1    taliban
#> 2628 less than 2,000                1                   1    taliban
#> 2629 less than 2,000                0                   0    control
#> 2630 less than 2,000                1                   0    control
#> 2631 less than 2,000                1                   0    control
#> 2632    2,001-10,000                1                   1    control
#> 2633    2,001-10,000                0                   0    control
#> 2634 less than 2,000                0                   0    control
#> 2635    2,001-10,000                0                   0       ISAF
#> 2636 less than 2,000                1                   0       ISAF
#> 2637 less than 2,000                0                   1       ISAF
#> 2638 less than 2,000                0                   0       ISAF
#> 2639 less than 2,000                1                   0       ISAF
#> 2640 less than 2,000                1                   1       ISAF
#> 2641   10,001-20,000                1                   0    taliban
#> 2642 less than 2,000                0                   1    taliban
#> 2643    2,001-10,000                0                   1    taliban
#> 2644 less than 2,000                1                   0    taliban
#> 2645    2,001-10,000                1                   0    taliban
#> 2647 less than 2,000                0                   1    control
#> 2648 less than 2,000                0                   1    control
#> 2649 less than 2,000                1                   0    control
#> 2650 less than 2,000                1                   1    control
#> 2651    2,001-10,000                0                   1    control
#> 2652 less than 2,000                1                   0    control
#> 2653 less than 2,000                1                   0       ISAF
#> 2654 less than 2,000                0                   0       ISAF
#> 2656 less than 2,000                1                   0       ISAF
#> 2657 less than 2,000                1                   0       ISAF
#> 2658 less than 2,000                0                   1       ISAF
#> 2659 less than 2,000                1                   1    taliban
#> 2660 less than 2,000                0                   1    taliban
#> 2661 less than 2,000                0                   0    taliban
#> 2662 less than 2,000                0                   1    taliban
#> 2663 less than 2,000                0                   1    taliban
#> 2664 less than 2,000                1                   1    taliban
#> 2665 less than 2,000                1                   0    control
#> 2666 less than 2,000                0                   0    control
#> 2667    2,001-10,000                0                   0    control
#> 2668    2,001-10,000                1                   0    control
#> 2669 less than 2,000                0                   0    control
#> 2670 less than 2,000                0                   1    control
#> 2671    2,001-10,000                1                   0       ISAF
#> 2672    2,001-10,000                0                   1       ISAF
#> 2673 less than 2,000                0                   1       ISAF
#> 2674 less than 2,000                0                   1       ISAF
#> 2675 less than 2,000                0                   0       ISAF
#> 2676 less than 2,000                0                   0       ISAF
#> 2677    2,001-10,000                0                   1    taliban
#> 2678 less than 2,000                0                   0    taliban
#> 2680 less than 2,000                0                   0    taliban
#> 2681 less than 2,000                0                   1    taliban
#> 2682 less than 2,000                0                   0    taliban
#> 2683 less than 2,000                0                   0    control
#> 2684    2,001-10,000                1                   1    control
#> 2685 less than 2,000                1                   0    control
#> 2686 less than 2,000                0                   1    control
#> 2687    2,001-10,000                0                   0    control
#> 2688 less than 2,000                1                   0    control
#> 2689    2,001-10,000                0                   1       ISAF
#> 2690 less than 2,000                1                   0       ISAF
#> 2691    2,001-10,000                0                   1       ISAF
#> 2692 less than 2,000                0                   1       ISAF
#> 2693 less than 2,000                0                   0       ISAF
#> 2694    2,001-10,000                0                   1       ISAF
#> 2695 less than 2,000                0                   1    taliban
#> 2696 less than 2,000                0                   0    taliban
#> 2697 less than 2,000                0                   0    taliban
#> 2698    2,001-10,000                0                   0    taliban
#> 2699 less than 2,000                0                   1    taliban
#> 2700 less than 2,000                0                   0    taliban
#> 2701    2,001-10,000                1                   0    control
#> 2702 less than 2,000                0                   0    control
#> 2703 less than 2,000                0                   0    control
#> 2704 less than 2,000                0                   0    control
#> 2705 less than 2,000                0                   0    control
#> 2706 less than 2,000                0                   0    control
#> 2707 less than 2,000                0                   0       ISAF
#> 2708    2,001-10,000                0                   1       ISAF
#> 2709 less than 2,000                1                   0       ISAF
#> 2710 less than 2,000                0                   1       ISAF
#> 2711 less than 2,000                1                   0       ISAF
#> 2713 less than 2,000                1                   0    taliban
#> 2714    2,001-10,000                1                   0    taliban
#> 2715 less than 2,000                1                   0    taliban
#> 2716 less than 2,000                1                   0    taliban
#> 2717    2,001-10,000                0                   0    taliban
#> 2718    2,001-10,000                1                   0    taliban
#> 2719 less than 2,000                1                   1    control
#> 2720 less than 2,000                1                   1    control
#> 2721 less than 2,000                1                   1    control
#> 2722 less than 2,000                1                   1    control
#> 2723 less than 2,000                0                   1    control
#> 2724 less than 2,000                1                   1    control
#> 2725 less than 2,000                1                   1       ISAF
#> 2726 less than 2,000                1                   1       ISAF
#> 2727 less than 2,000                0                   1       ISAF
#> 2728 less than 2,000                1                   1       ISAF
#> 2729 less than 2,000                1                   1       ISAF
#> 2730 less than 2,000                1                   1       ISAF
#> 2731 less than 2,000                1                   1    taliban
#> 2732 less than 2,000                1                   1    taliban
#> 2734 less than 2,000                1                   1    taliban
#> 2735 less than 2,000                1                   1    taliban
#> 2736 less than 2,000                1                   1    taliban
#> 2737    2,001-10,000                0                   0    control
#> 2738 less than 2,000                0                   0    control
#> 2739    2,001-10,000                0                   0    control
#> 2740    2,001-10,000                0                   1    control
#> 2741    2,001-10,000                1                   1    control
#> 2742    2,001-10,000                0                   0    control
#> 2743 less than 2,000                0                   0       ISAF
#> 2744    2,001-10,000                0                   0       ISAF
#> 2745    2,001-10,000                0                   0       ISAF
#> 2746    2,001-10,000                0                   0       ISAF
#> 2747 less than 2,000                0                   0       ISAF
#> 2748    2,001-10,000                1                   0       ISAF
#> 2749    2,001-10,000                0                   0    taliban
#> 2750 less than 2,000                0                   1    taliban
#> 2751    2,001-10,000                0                   0    taliban
#> 2752    2,001-10,000                0                   0    taliban
#> 2753 less than 2,000                0                   0    taliban
#> 2754 less than 2,000                1                   0    taliban
#>      list.response
#> 1                0
#> 2                1
#> 3                1
#> 4                3
#> 5                3
#> 7                1
#> 8                3
#> 9                1
#> 11               2
#> 12               3
#> 13               1
#> 14               1
#> 15               1
#> 16               3
#> 17               2
#> 18               3
#> 19               1
#> 20               1
#> 21               3
#> 22               0
#> 23               0
#> 24               0
#> 25               3
#> 26               1
#> 27               3
#> 28               2
#> 29               3
#> 30               1
#> 31               3
#> 32               2
#> 33               0
#> 34               3
#> 35               1
#> 36               2
#> 37               2
#> 38               3
#> 39               2
#> 40               3
#> 41               3
#> 42               3
#> 43               1
#> 44               2
#> 45               1
#> 46               2
#> 47               1
#> 48               0
#> 50               1
#> 51               1
#> 52               1
#> 53               2
#> 54               1
#> 55               1
#> 56               2
#> 57               3
#> 58               1
#> 59               3
#> 60               1
#> 61               3
#> 62               2
#> 63               1
#> 64               1
#> 65               3
#> 66               3
#> 67               1
#> 68               1
#> 69               3
#> 70               1
#> 71               2
#> 72               3
#> 73               1
#> 74               0
#> 75               2
#> 76               0
#> 77               1
#> 78               0
#> 79               1
#> 80               2
#> 81               2
#> 82               1
#> 84               3
#> 85               1
#> 86               1
#> 87               1
#> 88               3
#> 89               1
#> 90               1
#> 91               1
#> 92               3
#> 93               1
#> 94               3
#> 95               3
#> 96               3
#> 97               1
#> 98               3
#> 99               3
#> 100              2
#> 101              1
#> 102              1
#> 103              1
#> 104              1
#> 105              1
#> 106              1
#> 107              1
#> 108              3
#> 109              2
#> 110              2
#> 111              1
#> 112              3
#> 113              0
#> 114              0
#> 115              3
#> 116              1
#> 117              1
#> 118              1
#> 120              2
#> 121              1
#> 122              1
#> 123              2
#> 124              3
#> 125              3
#> 126              1
#> 127              1
#> 128              3
#> 129              0
#> 130              0
#> 131              2
#> 132              2
#> 133              3
#> 134              3
#> 135              3
#> 136              2
#> 137              3
#> 138              0
#> 139              1
#> 140              2
#> 141              1
#> 142              2
#> 143              1
#> 144              2
#> 145              2
#> 146              3
#> 147              2
#> 148              3
#> 149              0
#> 150              1
#> 151              2
#> 152              2
#> 153              1
#> 154              1
#> 155              1
#> 156              0
#> 157              1
#> 158              1
#> 159              3
#> 160              1
#> 161              3
#> 162              2
#> 163              1
#> 164              1
#> 165              2
#> 166              2
#> 167              3
#> 169              1
#> 170              2
#> 171              1
#> 172              3
#> 173              2
#> 174              2
#> 175              1
#> 177              2
#> 178              1
#> 179              2
#> 180              1
#> 181              0
#> 182              1
#> 183              0
#> 184              1
#> 185              1
#> 186              2
#> 187              1
#> 188              1
#> 189              1
#> 190              3
#> 191              2
#> 192              1
#> 193              2
#> 194              2
#> 195              0
#> 196              1
#> 197              3
#> 198              1
#> 199              3
#> 200              3
#> 201              2
#> 202              1
#> 203              0
#> 204              3
#> 205              1
#> 206              2
#> 207              2
#> 208              0
#> 209              1
#> 210              2
#> 211              2
#> 212              1
#> 213              1
#> 214              1
#> 215              2
#> 216              1
#> 217              2
#> 218              1
#> 219              1
#> 220              2
#> 221              2
#> 222              3
#> 223              0
#> 224              2
#> 226              0
#> 227              1
#> 228              2
#> 229              2
#> 230              3
#> 231              1
#> 232              1
#> 233              3
#> 234              2
#> 235              2
#> 236              2
#> 237              3
#> 238              2
#> 239              3
#> 240              1
#> 241              3
#> 242              2
#> 243              3
#> 245              3
#> 246              3
#> 247              1
#> 248              4
#> 250              3
#> 251              3
#> 253              2
#> 254              2
#> 255              3
#> 256              2
#> 257              2
#> 258              3
#> 259              1
#> 260              3
#> 261              2
#> 262              3
#> 263              1
#> 264              2
#> 265              1
#> 266              2
#> 267              3
#> 268              3
#> 269              3
#> 270              3
#> 271              3
#> 272              2
#> 273              3
#> 274              3
#> 276              4
#> 277              3
#> 278              1
#> 279              3
#> 280              1
#> 281              2
#> 282              2
#> 283              1
#> 284              1
#> 285              4
#> 286              1
#> 287              1
#> 288              3
#> 289              3
#> 290              3
#> 291              3
#> 292              2
#> 293              1
#> 294              2
#> 295              3
#> 296              3
#> 297              1
#> 298              3
#> 299              2
#> 300              2
#> 301              1
#> 302              4
#> 303              3
#> 304              3
#> 305              1
#> 306              2
#> 307              2
#> 308              1
#> 309              3
#> 310              2
#> 311              2
#> 312              1
#> 313              3
#> 314              2
#> 315              1
#> 316              2
#> 317              3
#> 318              3
#> 319              3
#> 320              3
#> 321              2
#> 322              2
#> 323              1
#> 324              2
#> 325              3
#> 326              3
#> 327              2
#> 328              4
#> 329              1
#> 330              4
#> 331              3
#> 332              2
#> 333              2
#> 334              3
#> 335              2
#> 336              2
#> 337              1
#> 338              3
#> 339              2
#> 340              1
#> 341              3
#> 342              2
#> 343              3
#> 344              1
#> 345              2
#> 346              3
#> 348              1
#> 349              2
#> 350              3
#> 351              1
#> 352              3
#> 354              3
#> 355              1
#> 356              2
#> 357              1
#> 358              3
#> 360              3
#> 361              3
#> 362              3
#> 363              1
#> 364              2
#> 365              3
#> 366              3
#> 367              1
#> 368              1
#> 369              2
#> 370              3
#> 371              1
#> 373              3
#> 374              3
#> 375              2
#> 376              1
#> 377              2
#> 378              3
#> 380              2
#> 381              2
#> 382              2
#> 383              2
#> 384              2
#> 385              2
#> 386              3
#> 387              3
#> 388              2
#> 389              3
#> 390              2
#> 391              3
#> 392              2
#> 393              1
#> 394              2
#> 395              1
#> 396              2
#> 397              3
#> 398              2
#> 399              1
#> 400              3
#> 401              2
#> 402              2
#> 403              1
#> 404              2
#> 405              1
#> 406              1
#> 407              4
#> 408              4
#> 409              3
#> 410              3
#> 411              2
#> 412              2
#> 413              1
#> 415              3
#> 416              3
#> 418              1
#> 419              1
#> 421              4
#> 422              1
#> 423              3
#> 424              4
#> 425              2
#> 426              1
#> 427              3
#> 428              3
#> 429              3
#> 430              1
#> 431              2
#> 432              3
#> 433              3
#> 434              3
#> 435              3
#> 436              2
#> 438              3
#> 439              4
#> 440              0
#> 441              1
#> 442              3
#> 443              4
#> 444              2
#> 445              3
#> 446              3
#> 447              3
#> 448              2
#> 449              1
#> 450              2
#> 451              2
#> 452              3
#> 453              3
#> 454              3
#> 455              1
#> 456              1
#> 457              3
#> 458              3
#> 460              4
#> 461              1
#> 462              3
#> 463              2
#> 465              3
#> 466              1
#> 467              3
#> 468              1
#> 469              1
#> 470              3
#> 471              3
#> 472              2
#> 473              1
#> 474              1
#> 475              3
#> 476              4
#> 477              1
#> 478              3
#> 479              1
#> 480              1
#> 481              3
#> 482              1
#> 483              3
#> 484              3
#> 485              3
#> 486              3
#> 487              3
#> 488              1
#> 489              3
#> 490              3
#> 491              3
#> 492              3
#> 493              4
#> 494              1
#> 495              3
#> 496              3
#> 497              3
#> 498              2
#> 499              3
#> 500              3
#> 501              3
#> 502              2
#> 503              2
#> 504              1
#> 505              2
#> 506              2
#> 507              3
#> 508              3
#> 509              2
#> 510              2
#> 511              1
#> 512              3
#> 513              3
#> 514              3
#> 515              4
#> 516              1
#> 517              2
#> 518              3
#> 519              3
#> 520              1
#> 521              1
#> 522              3
#> 523              3
#> 524              2
#> 525              3
#> 526              2
#> 527              2
#> 528              3
#> 529              3
#> 530              2
#> 531              3
#> 532              2
#> 533              3
#> 534              2
#> 535              3
#> 536              2
#> 537              3
#> 538              1
#> 539              1
#> 540              3
#> 541              2
#> 542              3
#> 543              0
#> 544              3
#> 545              0
#> 546              2
#> 547              1
#> 548              3
#> 549              1
#> 550              1
#> 551              1
#> 552              1
#> 553              1
#> 554              2
#> 555              2
#> 556              1
#> 557              2
#> 558              1
#> 559              3
#> 560              2
#> 561              1
#> 562              2
#> 563              2
#> 564              3
#> 565              1
#> 566              2
#> 567              1
#> 568              2
#> 569              2
#> 570              1
#> 571              2
#> 572              2
#> 573              1
#> 574              2
#> 575              1
#> 576              2
#> 577              2
#> 578              2
#> 579              3
#> 580              0
#> 581              1
#> 582              2
#> 583              3
#> 584              3
#> 585              1
#> 586              2
#> 587              2
#> 588              2
#> 589              2
#> 590              3
#> 591              1
#> 592              1
#> 593              2
#> 594              2
#> 595              3
#> 596              1
#> 597              2
#> 598              2
#> 599              0
#> 600              3
#> 601              0
#> 602              3
#> 603              3
#> 604              1
#> 605              3
#> 606              0
#> 607              1
#> 608              3
#> 609              2
#> 610              1
#> 611              2
#> 612              2
#> 613              2
#> 614              3
#> 615              0
#> 616              1
#> 617              2
#> 618              3
#> 619              2
#> 620              0
#> 621              0
#> 622              1
#> 623              3
#> 624              0
#> 625              1
#> 626              1
#> 627              1
#> 628              1
#> 629              3
#> 630              1
#> 631              1
#> 632              1
#> 633              1
#> 634              0
#> 635              3
#> 636              3
#> 637              3
#> 638              3
#> 639              3
#> 640              1
#> 641              3
#> 642              3
#> 643              3
#> 644              2
#> 645              1
#> 646              1
#> 647              1
#> 648              3
#> 649              1
#> 650              3
#> 652              0
#> 654              0
#> 655              2
#> 656              1
#> 657              1
#> 658              1
#> 659              2
#> 660              2
#> 661              2
#> 662              2
#> 663              3
#> 664              2
#> 665              3
#> 666              2
#> 667              2
#> 668              2
#> 669              1
#> 670              0
#> 671              1
#> 672              2
#> 673              1
#> 674              2
#> 675              1
#> 676              1
#> 677              0
#> 678              0
#> 679              3
#> 680              0
#> 681              2
#> 682              1
#> 683              2
#> 684              3
#> 685              3
#> 686              0
#> 687              2
#> 688              1
#> 689              2
#> 690              2
#> 691              1
#> 692              1
#> 693              1
#> 694              1
#> 695              2
#> 696              3
#> 697              3
#> 698              2
#> 699              2
#> 700              3
#> 701              2
#> 702              2
#> 703              2
#> 704              3
#> 705              1
#> 706              3
#> 707              1
#> 708              2
#> 709              1
#> 710              2
#> 711              3
#> 712              0
#> 713              2
#> 714              3
#> 715              0
#> 716              3
#> 717              1
#> 718              3
#> 719              1
#> 720              1
#> 721              3
#> 722              0
#> 723              0
#> 724              0
#> 725              3
#> 726              2
#> 727              3
#> 728              2
#> 729              2
#> 730              2
#> 731              3
#> 732              2
#> 733              0
#> 735              3
#> 736              1
#> 737              2
#> 738              1
#> 739              3
#> 740              0
#> 741              0
#> 742              2
#> 743              0
#> 744              2
#> 745              2
#> 746              2
#> 747              1
#> 748              0
#> 749              2
#> 750              1
#> 751              1
#> 752              1
#> 753              1
#> 754              2
#> 755              2
#> 756              1
#> 757              1
#> 758              2
#> 759              1
#> 760              1
#> 761              1
#> 762              2
#> 763              2
#> 764              1
#> 765              2
#> 766              2
#> 767              2
#> 768              2
#> 769              2
#> 770              3
#> 771              3
#> 772              1
#> 773              2
#> 774              1
#> 775              3
#> 776              2
#> 777              0
#> 778              3
#> 779              2
#> 780              3
#> 781              3
#> 782              1
#> 783              1
#> 784              2
#> 785              1
#> 786              1
#> 787              2
#> 788              2
#> 789              1
#> 790              2
#> 791              1
#> 792              2
#> 793              1
#> 794              2
#> 795              1
#> 796              1
#> 797              1
#> 798              2
#> 799              2
#> 800              1
#> 801              2
#> 802              0
#> 803              0
#> 804              2
#> 805              1
#> 806              3
#> 807              2
#> 808              2
#> 809              3
#> 810              3
#> 811              2
#> 812              3
#> 813              1
#> 814              2
#> 815              0
#> 816              3
#> 817              1
#> 818              2
#> 819              3
#> 820              2
#> 821              0
#> 822              3
#> 823              3
#> 824              2
#> 825              3
#> 826              2
#> 827              1
#> 828              2
#> 829              2
#> 830              1
#> 831              3
#> 832              3
#> 833              2
#> 834              3
#> 835              2
#> 836              1
#> 837              1
#> 838              0
#> 839              0
#> 840              0
#> 841              1
#> 842              1
#> 843              1
#> 844              1
#> 845              3
#> 846              1
#> 847              1
#> 848              1
#> 849              0
#> 850              2
#> 851              3
#> 852              3
#> 853              2
#> 854              3
#> 855              2
#> 856              3
#> 857              1
#> 858              3
#> 859              1
#> 860              3
#> 861              1
#> 862              1
#> 863              1
#> 864              1
#> 865              2
#> 866              0
#> 867              2
#> 868              3
#> 869              0
#> 870              2
#> 871              2
#> 872              0
#> 873              1
#> 874              2
#> 875              1
#> 876              3
#> 877              3
#> 878              2
#> 879              2
#> 880              1
#> 881              2
#> 882              3
#> 883              0
#> 884              2
#> 885              1
#> 886              2
#> 887              0
#> 888              2
#> 889              2
#> 890              2
#> 891              2
#> 892              1
#> 893              0
#> 894              0
#> 895              2
#> 896              2
#> 897              1
#> 898              2
#> 899              1
#> 900              1
#> 901              0
#> 902              3
#> 903              0
#> 904              3
#> 905              2
#> 906              1
#> 907              0
#> 908              2
#> 909              0
#> 910              0
#> 911              3
#> 912              3
#> 913              2
#> 914              3
#> 915              1
#> 916              3
#> 917              1
#> 918              3
#> 919              1
#> 920              2
#> 921              0
#> 922              2
#> 923              2
#> 924              3
#> 925              1
#> 926              3
#> 927              1
#> 928              2
#> 929              2
#> 930              0
#> 931              2
#> 932              1
#> 933              2
#> 934              2
#> 935              2
#> 936              1
#> 937              2
#> 938              3
#> 939              0
#> 940              3
#> 941              2
#> 942              2
#> 943              3
#> 944              2
#> 945              3
#> 946              2
#> 947              3
#> 948              3
#> 949              3
#> 950              3
#> 951              2
#> 952              3
#> 953              2
#> 954              3
#> 955              3
#> 956              3
#> 957              2
#> 958              3
#> 959              1
#> 960              4
#> 961              3
#> 962              1
#> 963              3
#> 964              2
#> 965              2
#> 966              3
#> 967              3
#> 968              2
#> 969              1
#> 970              1
#> 971              3
#> 972              1
#> 973              0
#> 974              3
#> 975              3
#> 976              4
#> 977              3
#> 978              3
#> 979              2
#> 980              3
#> 981              3
#> 982              3
#> 983              3
#> 984              3
#> 985              2
#> 986              1
#> 987              4
#> 988              3
#> 989              2
#> 990              3
#> 991              0
#> 992              3
#> 993              3
#> 994              4
#> 995              3
#> 996              1
#> 997              3
#> 998              3
#> 999              3
#> 1000             2
#> 1001             2
#> 1002             2
#> 1003             3
#> 1004             1
#> 1005             2
#> 1006             2
#> 1007             2
#> 1008             3
#> 1009             2
#> 1010             2
#> 1011             3
#> 1012             2
#> 1014             3
#> 1015             1
#> 1016             2
#> 1017             2
#> 1018             2
#> 1019             1
#> 1020             3
#> 1021             1
#> 1022             2
#> 1023             0
#> 1024             2
#> 1025             4
#> 1026             1
#> 1027             4
#> 1028             2
#> 1029             4
#> 1030             1
#> 1031             2
#> 1032             1
#> 1033             3
#> 1034             2
#> 1035             3
#> 1036             3
#> 1037             1
#> 1038             2
#> 1039             1
#> 1040             1
#> 1041             1
#> 1042             1
#> 1043             2
#> 1044             2
#> 1045             2
#> 1046             1
#> 1047             1
#> 1048             2
#> 1049             1
#> 1050             1
#> 1051             1
#> 1052             1
#> 1053             2
#> 1054             3
#> 1055             3
#> 1056             1
#> 1057             2
#> 1058             1
#> 1059             3
#> 1060             2
#> 1061             2
#> 1062             1
#> 1063             3
#> 1064             2
#> 1065             3
#> 1066             2
#> 1067             2
#> 1068             2
#> 1069             1
#> 1070             1
#> 1071             2
#> 1072             2
#> 1073             2
#> 1074             2
#> 1075             2
#> 1076             2
#> 1077             2
#> 1078             2
#> 1080             2
#> 1081             2
#> 1083             2
#> 1084             2
#> 1085             2
#> 1086             2
#> 1087             3
#> 1088             2
#> 1089             2
#> 1090             3
#> 1091             2
#> 1092             2
#> 1093             3
#> 1094             2
#> 1095             3
#> 1096             3
#> 1097             3
#> 1098             3
#> 1099             3
#> 1100             3
#> 1101             3
#> 1102             3
#> 1103             3
#> 1104             3
#> 1105             3
#> 1106             3
#> 1107             3
#> 1108             1
#> 1109             3
#> 1110             2
#> 1111             2
#> 1112             2
#> 1113             2
#> 1114             3
#> 1115             2
#> 1116             2
#> 1117             2
#> 1118             2
#> 1119             2
#> 1120             2
#> 1121             2
#> 1122             3
#> 1123             3
#> 1124             2
#> 1125             2
#> 1126             3
#> 1127             3
#> 1128             2
#> 1129             2
#> 1130             0
#> 1131             2
#> 1132             2
#> 1133             3
#> 1134             2
#> 1135             2
#> 1136             2
#> 1137             3
#> 1138             2
#> 1139             3
#> 1140             2
#> 1141             1
#> 1142             3
#> 1143             2
#> 1144             3
#> 1145             3
#> 1146             3
#> 1147             2
#> 1148             3
#> 1149             3
#> 1150             3
#> 1151             3
#> 1152             3
#> 1153             2
#> 1154             3
#> 1155             2
#> 1156             2
#> 1157             3
#> 1158             3
#> 1159             2
#> 1160             3
#> 1161             3
#> 1162             3
#> 1163             2
#> 1164             2
#> 1165             2
#> 1166             2
#> 1167             2
#> 1168             2
#> 1169             2
#> 1170             2
#> 1171             2
#> 1172             2
#> 1173             2
#> 1174             2
#> 1175             2
#> 1176             2
#> 1177             2
#> 1178             2
#> 1179             2
#> 1180             3
#> 1181             2
#> 1182             1
#> 1183             1
#> 1184             3
#> 1185             0
#> 1186             2
#> 1187             3
#> 1188             1
#> 1189             3
#> 1190             1
#> 1191             0
#> 1192             1
#> 1193             2
#> 1194             2
#> 1195             3
#> 1196             3
#> 1197             0
#> 1198             0
#> 1199             0
#> 1200             0
#> 1201             2
#> 1202             1
#> 1203             3
#> 1204             1
#> 1205             3
#> 1206             1
#> 1207             3
#> 1208             0
#> 1209             1
#> 1210             2
#> 1211             2
#> 1212             0
#> 1214             2
#> 1215             2
#> 1216             2
#> 1217             2
#> 1218             3
#> 1219             2
#> 1220             1
#> 1221             1
#> 1222             1
#> 1223             2
#> 1224             1
#> 1225             0
#> 1226             2
#> 1227             1
#> 1228             2
#> 1229             3
#> 1230             2
#> 1231             3
#> 1232             2
#> 1233             1
#> 1234             1
#> 1235             2
#> 1236             2
#> 1237             1
#> 1238             1
#> 1239             1
#> 1240             1
#> 1241             2
#> 1242             1
#> 1243             2
#> 1244             1
#> 1245             1
#> 1246             3
#> 1247             0
#> 1248             2
#> 1249             2
#> 1250             3
#> 1251             1
#> 1252             1
#> 1253             2
#> 1254             2
#> 1255             2
#> 1256             1
#> 1257             0
#> 1258             3
#> 1259             2
#> 1260             1
#> 1261             1
#> 1262             3
#> 1263             0
#> 1264             2
#> 1265             1
#> 1266             2
#> 1267             1
#> 1268             2
#> 1269             1
#> 1270             0
#> 1271             1
#> 1272             1
#> 1273             2
#> 1274             0
#> 1275             3
#> 1276             0
#> 1277             2
#> 1278             0
#> 1279             0
#> 1280             0
#> 1281             1
#> 1282             2
#> 1283             1
#> 1284             1
#> 1285             3
#> 1286             2
#> 1287             3
#> 1288             1
#> 1289             2
#> 1290             0
#> 1291             2
#> 1292             3
#> 1293             0
#> 1297             1
#> 1300             2
#> 1303             1
#> 1305             1
#> 1306             2
#> 1307             0
#> 1308             0
#> 1309             3
#> 1310             0
#> 1311             0
#> 1312             1
#> 1313             0
#> 1314             0
#> 1315             1
#> 1316             1
#> 1317             0
#> 1318             1
#> 1319             3
#> 1320             3
#> 1321             1
#> 1322             1
#> 1323             2
#> 1324             1
#> 1325             1
#> 1326             2
#> 1327             2
#> 1328             2
#> 1329             2
#> 1330             2
#> 1331             2
#> 1332             2
#> 1333             2
#> 1334             2
#> 1335             2
#> 1336             2
#> 1337             2
#> 1338             2
#> 1339             2
#> 1340             2
#> 1341             2
#> 1342             3
#> 1343             0
#> 1344             0
#> 1345             0
#> 1346             2
#> 1347             3
#> 1348             3
#> 1349             1
#> 1350             3
#> 1351             0
#> 1352             2
#> 1353             0
#> 1354             1
#> 1355             2
#> 1356             3
#> 1357             2
#> 1358             3
#> 1359             1
#> 1360             0
#> 1361             2
#> 1362             3
#> 1363             0
#> 1364             3
#> 1365             1
#> 1366             2
#> 1367             1
#> 1368             2
#> 1369             2
#> 1370             1
#> 1371             1
#> 1372             1
#> 1373             2
#> 1374             2
#> 1375             3
#> 1376             2
#> 1377             1
#> 1378             0
#> 1379             2
#> 1380             1
#> 1381             3
#> 1382             1
#> 1383             1
#> 1384             2
#> 1385             2
#> 1386             2
#> 1387             3
#> 1388             1
#> 1389             2
#> 1390             0
#> 1391             2
#> 1392             1
#> 1393             2
#> 1394             1
#> 1395             1
#> 1396             3
#> 1397             0
#> 1398             3
#> 1399             0
#> 1400             1
#> 1401             1
#> 1402             1
#> 1403             3
#> 1404             1
#> 1405             2
#> 1406             1
#> 1407             2
#> 1408             2
#> 1409             0
#> 1410             1
#> 1411             1
#> 1412             2
#> 1413             2
#> 1414             0
#> 1415             0
#> 1416             1
#> 1417             1
#> 1418             2
#> 1419             1
#> 1420             2
#> 1421             1
#> 1422             2
#> 1423             3
#> 1424             0
#> 1425             0
#> 1426             0
#> 1427             3
#> 1428             0
#> 1429             1
#> 1430             1
#> 1431             0
#> 1432             2
#> 1433             3
#> 1434             0
#> 1435             3
#> 1436             1
#> 1437             1
#> 1438             1
#> 1439             1
#> 1440             3
#> 1441             3
#> 1442             3
#> 1443             0
#> 1444             3
#> 1445             3
#> 1446             0
#> 1447             0
#> 1448             3
#> 1449             1
#> 1450             3
#> 1451             1
#> 1452             3
#> 1453             1
#> 1454             1
#> 1455             1
#> 1456             1
#> 1457             3
#> 1458             3
#> 1459             2
#> 1460             0
#> 1461             0
#> 1462             2
#> 1463             1
#> 1464             2
#> 1465             1
#> 1466             2
#> 1467             3
#> 1469             1
#> 1470             0
#> 1471             3
#> 1472             3
#> 1473             2
#> 1474             3
#> 1475             1
#> 1476             2
#> 1477             2
#> 1478             0
#> 1479             3
#> 1480             1
#> 1481             1
#> 1482             3
#> 1483             2
#> 1484             0
#> 1485             2
#> 1486             0
#> 1487             3
#> 1488             1
#> 1489             2
#> 1490             3
#> 1491             1
#> 1492             3
#> 1493             3
#> 1494             2
#> 1495             1
#> 1496             3
#> 1497             2
#> 1498             3
#> 1499             3
#> 1500             2
#> 1501             0
#> 1502             0
#> 1503             2
#> 1504             2
#> 1505             3
#> 1506             3
#> 1507             1
#> 1508             1
#> 1509             1
#> 1510             3
#> 1511             3
#> 1513             1
#> 1521             1
#> 1522             1
#> 1523             1
#> 1524             1
#> 1525             1
#> 1526             1
#> 1527             1
#> 1528             1
#> 1529             1
#> 1530             1
#> 1531             1
#> 1532             1
#> 1533             1
#> 1534             1
#> 1535             1
#> 1536             1
#> 1537             1
#> 1538             1
#> 1539             1
#> 1540             0
#> 1542             0
#> 1543             0
#> 1544             0
#> 1545             0
#> 1546             1
#> 1547             1
#> 1548             1
#> 1550             3
#> 1551             3
#> 1552             0
#> 1553             1
#> 1555             2
#> 1556             1
#> 1558             0
#> 1559             0
#> 1560             0
#> 1561             0
#> 1562             0
#> 1563             0
#> 1564             1
#> 1566             1
#> 1567             2
#> 1570             1
#> 1571             2
#> 1572             1
#> 1573             1
#> 1574             2
#> 1577             1
#> 1578             1
#> 1579             1
#> 1580             2
#> 1581             1
#> 1582             1
#> 1583             1
#> 1584             1
#> 1586             1
#> 1587             2
#> 1588             1
#> 1590             2
#> 1594             1
#> 1595             1
#> 1596             0
#> 1597             2
#> 1599             1
#> 1600             2
#> 1602             1
#> 1604             1
#> 1605             0
#> 1606             2
#> 1607             2
#> 1609             1
#> 1610             1
#> 1611             2
#> 1612             1
#> 1613             1
#> 1614             2
#> 1615             0
#> 1616             2
#> 1617             0
#> 1618             2
#> 1619             1
#> 1620             1
#> 1621             2
#> 1622             1
#> 1623             1
#> 1624             1
#> 1625             1
#> 1626             1
#> 1627             1
#> 1628             2
#> 1629             1
#> 1635             2
#> 1637             2
#> 1643             2
#> 1645             2
#> 1648             1
#> 1650             3
#> 1651             3
#> 1653             1
#> 1654             3
#> 1655             1
#> 1657             2
#> 1662             1
#> 1665             2
#> 1666             0
#> 1667             1
#> 1668             1
#> 1669             0
#> 1670             0
#> 1671             0
#> 1673             0
#> 1674             1
#> 1675             1
#> 1676             1
#> 1677             2
#> 1678             2
#> 1679             1
#> 1681             1
#> 1682             2
#> 1683             1
#> 1684             1
#> 1685             1
#> 1686             1
#> 1687             1
#> 1688             1
#> 1689             2
#> 1690             1
#> 1691             1
#> 1694             2
#> 1695             1
#> 1696             1
#> 1698             1
#> 1700             2
#> 1701             2
#> 1702             1
#> 1703             2
#> 1704             2
#> 1705             2
#> 1706             1
#> 1707             2
#> 1708             1
#> 1709             2
#> 1710             1
#> 1711             2
#> 1712             1
#> 1714             1
#> 1715             2
#> 1718             1
#> 1720             2
#> 1721             0
#> 1722             1
#> 1724             1
#> 1725             1
#> 1726             2
#> 1727             2
#> 1728             0
#> 1730             2
#> 1731             1
#> 1734             1
#> 1735             1
#> 1737             1
#> 1738             2
#> 1739             3
#> 1740             2
#> 1741             3
#> 1742             2
#> 1743             2
#> 1744             2
#> 1745             3
#> 1746             1
#> 1747             2
#> 1748             1
#> 1749             2
#> 1750             2
#> 1751             3
#> 1752             2
#> 1753             2
#> 1754             3
#> 1755             1
#> 1756             1
#> 1757             3
#> 1758             2
#> 1759             0
#> 1760             3
#> 1761             1
#> 1762             3
#> 1763             2
#> 1764             1
#> 1765             3
#> 1766             2
#> 1767             1
#> 1768             2
#> 1769             3
#> 1770             3
#> 1771             3
#> 1772             2
#> 1773             2
#> 1774             2
#> 1775             3
#> 1776             2
#> 1777             2
#> 1778             3
#> 1779             2
#> 1780             3
#> 1781             3
#> 1782             2
#> 1783             2
#> 1784             1
#> 1785             3
#> 1786             1
#> 1787             2
#> 1788             3
#> 1789             3
#> 1790             1
#> 1791             1
#> 1792             3
#> 1793             2
#> 1794             1
#> 1795             2
#> 1796             2
#> 1797             3
#> 1798             2
#> 1799             3
#> 1800             3
#> 1801             2
#> 1802             1
#> 1803             2
#> 1804             2
#> 1805             2
#> 1806             3
#> 1807             2
#> 1808             3
#> 1809             2
#> 1810             1
#> 1811             2
#> 1812             2
#> 1813             2
#> 1814             3
#> 1815             2
#> 1816             2
#> 1817             3
#> 1818             1
#> 1819             2
#> 1820             2
#> 1821             2
#> 1822             3
#> 1823             3
#> 1824             2
#> 1825             2
#> 1826             1
#> 1827             2
#> 1828             1
#> 1829             3
#> 1830             2
#> 1831             3
#> 1832             0
#> 1833             3
#> 1834             3
#> 1835             3
#> 1836             1
#> 1837             3
#> 1838             1
#> 1839             3
#> 1840             3
#> 1841             3
#> 1842             3
#> 1843             3
#> 1844             3
#> 1845             3
#> 1846             0
#> 1847             3
#> 1848             2
#> 1849             0
#> 1850             1
#> 1851             3
#> 1852             1
#> 1853             3
#> 1854             1
#> 1855             0
#> 1856             0
#> 1857             1
#> 1858             2
#> 1859             2
#> 1860             0
#> 1861             2
#> 1862             2
#> 1863             2
#> 1864             2
#> 1865             1
#> 1866             0
#> 1867             2
#> 1868             0
#> 1869             0
#> 1870             1
#> 1871             2
#> 1872             1
#> 1873             0
#> 1874             3
#> 1875             0
#> 1876             3
#> 1877             0
#> 1878             2
#> 1879             0
#> 1880             1
#> 1881             2
#> 1882             2
#> 1883             2
#> 1884             0
#> 1885             1
#> 1886             2
#> 1887             2
#> 1888             1
#> 1889             2
#> 1890             1
#> 1891             1
#> 1892             1
#> 1893             1
#> 1894             1
#> 1895             1
#> 1896             1
#> 1897             1
#> 1898             1
#> 1899             1
#> 1900             1
#> 1901             1
#> 1902             1
#> 1903             1
#> 1904             1
#> 1905             1
#> 1906             1
#> 1907             1
#> 1908             1
#> 1910             2
#> 1912             1
#> 1913             0
#> 1914             2
#> 1915             0
#> 1916             1
#> 1917             1
#> 1919             1
#> 1920             1
#> 1922             1
#> 1923             1
#> 1925             1
#> 1926             2
#> 1927             1
#> 1928             1
#> 1929             0
#> 1930             1
#> 1931             2
#> 1932             2
#> 1933             1
#> 1934             1
#> 1935             0
#> 1936             1
#> 1937             2
#> 1938             2
#> 1939             2
#> 1940             1
#> 1941             1
#> 1942             2
#> 1943             1
#> 1944             1
#> 1945             1
#> 1946             2
#> 1947             0
#> 1948             1
#> 1949             0
#> 1950             2
#> 1951             1
#> 1952             1
#> 1953             2
#> 1954             0
#> 1955             0
#> 1956             1
#> 1957             1
#> 1958             1
#> 1959             1
#> 1960             1
#> 1961             2
#> 1962             1
#> 1965             1
#> 1970             1
#> 1972             1
#> 1974             2
#> 1975             1
#> 1980             1
#> 1981             2
#> 1982             1
#> 1983             2
#> 1984             3
#> 1985             1
#> 1986             3
#> 1987             1
#> 1988             2
#> 1989             2
#> 1990             2
#> 1991             1
#> 1992             3
#> 1993             2
#> 1994             1
#> 1995             1
#> 1996             2
#> 1997             1
#> 1998             1
#> 1999             2
#> 2000             0
#> 2001             0
#> 2002             2
#> 2003             2
#> 2004             2
#> 2005             3
#> 2006             1
#> 2007             2
#> 2008             1
#> 2009             0
#> 2010             0
#> 2011             2
#> 2012             2
#> 2013             2
#> 2014             2
#> 2015             1
#> 2016             1
#> 2017             1
#> 2018             2
#> 2019             1
#> 2020             0
#> 2021             3
#> 2022             2
#> 2023             1
#> 2024             1
#> 2025             2
#> 2026             2
#> 2027             3
#> 2028             2
#> 2029             1
#> 2030             1
#> 2031             2
#> 2032             3
#> 2033             1
#> 2034             2
#> 2035             1
#> 2036             1
#> 2037             0
#> 2038             2
#> 2039             1
#> 2040             0
#> 2041             0
#> 2042             1
#> 2043             3
#> 2044             2
#> 2045             0
#> 2046             1
#> 2047             2
#> 2048             1
#> 2049             2
#> 2050             3
#> 2051             2
#> 2052             1
#> 2053             2
#> 2054             0
#> 2055             0
#> 2056             2
#> 2057             1
#> 2058             0
#> 2059             0
#> 2060             3
#> 2061             2
#> 2062             2
#> 2063             0
#> 2064             1
#> 2065             1
#> 2066             2
#> 2067             2
#> 2068             1
#> 2069             1
#> 2070             2
#> 2072             0
#> 2073             0
#> 2074             0
#> 2075             0
#> 2076             0
#> 2077             1
#> 2078             1
#> 2079             1
#> 2081             1
#> 2082             1
#> 2083             1
#> 2084             2
#> 2085             1
#> 2086             1
#> 2087             1
#> 2088             2
#> 2089             0
#> 2090             1
#> 2091             0
#> 2092             0
#> 2093             3
#> 2094             3
#> 2095             1
#> 2096             1
#> 2097             1
#> 2098             0
#> 2099             0
#> 2100             0
#> 2101             0
#> 2102             0
#> 2103             0
#> 2104             1
#> 2106             1
#> 2107             0
#> 2108             0
#> 2109             0
#> 2110             0
#> 2111             0
#> 2112             0
#> 2113             1
#> 2114             1
#> 2115             1
#> 2116             0
#> 2117             0
#> 2118             0
#> 2119             0
#> 2120             0
#> 2121             0
#> 2122             1
#> 2123             1
#> 2124             1
#> 2125             0
#> 2126             0
#> 2127             0
#> 2128             0
#> 2129             0
#> 2130             0
#> 2131             1
#> 2132             1
#> 2133             1
#> 2134             0
#> 2135             0
#> 2136             0
#> 2137             0
#> 2138             0
#> 2139             1
#> 2140             2
#> 2141             1
#> 2142             1
#> 2143             0
#> 2144             0
#> 2145             0
#> 2146             0
#> 2147             0
#> 2148             0
#> 2149             0
#> 2150             0
#> 2151             0
#> 2152             0
#> 2153             0
#> 2154             0
#> 2155             1
#> 2156             1
#> 2157             1
#> 2158             1
#> 2159             1
#> 2160             1
#> 2161             0
#> 2162             0
#> 2163             0
#> 2164             0
#> 2165             0
#> 2166             0
#> 2167             0
#> 2168             0
#> 2170             0
#> 2171             0
#> 2172             3
#> 2173             1
#> 2175             1
#> 2176             1
#> 2177             1
#> 2179             2
#> 2180             3
#> 2181             2
#> 2182             2
#> 2183             1
#> 2184             3
#> 2185             2
#> 2186             1
#> 2187             1
#> 2188             2
#> 2189             3
#> 2190             2
#> 2191             3
#> 2192             2
#> 2193             1
#> 2194             3
#> 2195             2
#> 2196             3
#> 2197             1
#> 2198             1
#> 2200             1
#> 2201             1
#> 2202             2
#> 2203             1
#> 2204             1
#> 2207             1
#> 2208             1
#> 2211             2
#> 2212             2
#> 2214             1
#> 2215             0
#> 2216             0
#> 2217             0
#> 2218             0
#> 2219             0
#> 2220             0
#> 2221             0
#> 2222             0
#> 2223             0
#> 2224             0
#> 2225             0
#> 2226             0
#> 2227             1
#> 2228             1
#> 2229             1
#> 2230             1
#> 2231             1
#> 2232             1
#> 2233             1
#> 2235             1
#> 2236             1
#> 2237             1
#> 2238             0
#> 2240             1
#> 2242             1
#> 2243             1
#> 2244             0
#> 2245             2
#> 2246             2
#> 2248             2
#> 2249             2
#> 2250             1
#> 2251             0
#> 2252             2
#> 2253             0
#> 2254             1
#> 2255             0
#> 2256             0
#> 2257             0
#> 2258             0
#> 2259             0
#> 2260             0
#> 2261             2
#> 2262             0
#> 2263             1
#> 2264             1
#> 2265             1
#> 2266             1
#> 2267             1
#> 2268             1
#> 2269             0
#> 2270             1
#> 2271             0
#> 2272             0
#> 2274             0
#> 2276             0
#> 2277             1
#> 2278             0
#> 2279             1
#> 2282             1
#> 2283             2
#> 2284             1
#> 2285             2
#> 2286             1
#> 2287             1
#> 2288             0
#> 2289             1
#> 2291             2
#> 2292             2
#> 2294             1
#> 2295             1
#> 2296             0
#> 2297             0
#> 2298             0
#> 2299             0
#> 2300             0
#> 2301             0
#> 2302             1
#> 2303             1
#> 2304             1
#> 2305             2
#> 2306             1
#> 2307             2
#> 2308             2
#> 2309             2
#> 2310             2
#> 2311             2
#> 2312             1
#> 2313             1
#> 2314             0
#> 2315             0
#> 2316             0
#> 2317             0
#> 2318             0
#> 2319             0
#> 2320             1
#> 2321             1
#> 2322             1
#> 2323             0
#> 2324             0
#> 2325             0
#> 2326             0
#> 2327             0
#> 2328             0
#> 2329             1
#> 2330             1
#> 2331             1
#> 2332             2
#> 2333             1
#> 2342             2
#> 2344             1
#> 2348             2
#> 2352             1
#> 2354             1
#> 2357             3
#> 2359             2
#> 2361             2
#> 2365             3
#> 2367             2
#> 2368             1
#> 2369             1
#> 2370             3
#> 2371             0
#> 2372             0
#> 2373             3
#> 2374             2
#> 2375             2
#> 2376             3
#> 2377             2
#> 2378             3
#> 2379             3
#> 2380             1
#> 2381             3
#> 2382             0
#> 2383             2
#> 2384             1
#> 2385             1
#> 2386             0
#> 2387             3
#> 2388             2
#> 2389             3
#> 2390             3
#> 2391             2
#> 2392             2
#> 2393             1
#> 2394             1
#> 2395             0
#> 2396             1
#> 2397             2
#> 2398             1
#> 2399             0
#> 2400             1
#> 2401             1
#> 2402             1
#> 2403             3
#> 2404             1
#> 2405             3
#> 2406             0
#> 2407             1
#> 2408             3
#> 2409             2
#> 2410             1
#> 2411             1
#> 2412             2
#> 2413             1
#> 2414             1
#> 2415             1
#> 2416             2
#> 2417             2
#> 2418             1
#> 2419             1
#> 2420             1
#> 2421             1
#> 2422             1
#> 2423             1
#> 2424             1
#> 2426             1
#> 2427             1
#> 2428             2
#> 2429             1
#> 2430             1
#> 2431             0
#> 2434             1
#> 2435             2
#> 2436             1
#> 2437             3
#> 2438             1
#> 2439             2
#> 2441             1
#> 2442             3
#> 2443             3
#> 2444             1
#> 2445             1
#> 2446             2
#> 2449             2
#> 2450             1
#> 2451             1
#> 2452             1
#> 2453             3
#> 2454             1
#> 2455             1
#> 2456             0
#> 2457             1
#> 2458             1
#> 2459             2
#> 2460             2
#> 2461             3
#> 2463             3
#> 2464             3
#> 2465             1
#> 2466             3
#> 2467             3
#> 2468             2
#> 2469             0
#> 2470             2
#> 2471             1
#> 2472             0
#> 2473             3
#> 2474             1
#> 2475             0
#> 2476             2
#> 2477             3
#> 2478             2
#> 2479             1
#> 2480             3
#> 2481             2
#> 2482             3
#> 2483             2
#> 2484             2
#> 2485             2
#> 2486             1
#> 2487             2
#> 2488             1
#> 2489             1
#> 2490             0
#> 2494             1
#> 2498             1
#> 2499             3
#> 2502             2
#> 2503             1
#> 2504             1
#> 2505             1
#> 2506             0
#> 2507             0
#> 2508             0
#> 2509             1
#> 2510             1
#> 2511             1
#> 2512             1
#> 2513             1
#> 2515             1
#> 2517             1
#> 2519             1
#> 2520             1
#> 2521             0
#> 2522             0
#> 2524             0
#> 2525             1
#> 2526             0
#> 2527             1
#> 2529             1
#> 2530             3
#> 2531             1
#> 2532             1
#> 2533             2
#> 2534             3
#> 2535             2
#> 2536             2
#> 2537             2
#> 2538             1
#> 2539             2
#> 2540             1
#> 2541             2
#> 2542             2
#> 2543             1
#> 2544             2
#> 2545             2
#> 2546             3
#> 2547             3
#> 2548             2
#> 2549             2
#> 2550             1
#> 2551             3
#> 2552             1
#> 2553             1
#> 2554             3
#> 2555             1
#> 2556             3
#> 2557             2
#> 2558             1
#> 2559             1
#> 2560             3
#> 2561             2
#> 2562             2
#> 2563             2
#> 2564             3
#> 2565             2
#> 2566             2
#> 2567             1
#> 2568             1
#> 2569             1
#> 2570             1
#> 2571             1
#> 2572             2
#> 2573             1
#> 2576             3
#> 2577             1
#> 2578             1
#> 2579             2
#> 2580             2
#> 2581             1
#> 2582             1
#> 2583             1
#> 2585             1
#> 2586             0
#> 2587             0
#> 2589             1
#> 2591             1
#> 2593             1
#> 2594             1
#> 2595             1
#> 2597             1
#> 2599             2
#> 2600             1
#> 2601             1
#> 2602             3
#> 2603             1
#> 2604             1
#> 2605             3
#> 2606             0
#> 2607             1
#> 2608             1
#> 2609             3
#> 2610             1
#> 2611             1
#> 2612             1
#> 2613             2
#> 2614             1
#> 2615             1
#> 2616             1
#> 2617             1
#> 2618             1
#> 2619             1
#> 2620             1
#> 2621             1
#> 2622             1
#> 2623             1
#> 2624             1
#> 2625             1
#> 2626             1
#> 2628             1
#> 2629             0
#> 2630             2
#> 2631             1
#> 2632             1
#> 2633             2
#> 2634             3
#> 2635             1
#> 2636             2
#> 2637             0
#> 2638             3
#> 2639             3
#> 2640             0
#> 2641             2
#> 2642             2
#> 2643             1
#> 2644             1
#> 2645             2
#> 2647             1
#> 2648             0
#> 2649             3
#> 2650             2
#> 2651             1
#> 2652             0
#> 2653             2
#> 2654             1
#> 2656             2
#> 2657             2
#> 2658             2
#> 2659             1
#> 2660             1
#> 2661             1
#> 2662             1
#> 2663             2
#> 2664             1
#> 2665             1
#> 2666             1
#> 2667             2
#> 2668             0
#> 2669             3
#> 2670             0
#> 2671             1
#> 2672             3
#> 2673             1
#> 2674             0
#> 2675             1
#> 2676             0
#> 2677             2
#> 2678             1
#> 2680             2
#> 2681             1
#> 2682             2
#> 2683             0
#> 2684             3
#> 2685             2
#> 2686             1
#> 2687             1
#> 2688             2
#> 2689             3
#> 2690             1
#> 2691             2
#> 2692             1
#> 2693             1
#> 2694             1
#> 2695             1
#> 2696             1
#> 2697             3
#> 2698             3
#> 2699             2
#> 2700             1
#> 2701             2
#> 2702             1
#> 2703             0
#> 2704             2
#> 2705             3
#> 2706             3
#> 2707             3
#> 2708             0
#> 2709             0
#> 2710             2
#> 2711             1
#> 2713             1
#> 2714             3
#> 2715             1
#> 2716             2
#> 2717             2
#> 2718             1
#> 2719             1
#> 2720             1
#> 2721             1
#> 2722             1
#> 2723             1
#> 2724             1
#> 2725             1
#> 2726             1
#> 2727             1
#> 2728             1
#> 2729             1
#> 2730             1
#> 2731             1
#> 2732             1
#> 2734             1
#> 2735             1
#> 2736             1
#> 2737             2
#> 2738             0
#> 2739             2
#> 2740             1
#> 2741             1
#> 2742             3
#> 2743             3
#> 2744             1
#> 2745             3
#> 2746             2
#> 2747             3
#> 2748             1
#> 2749             1
#> 2750             2
#> 2751             1
#> 2752             2
#> 2753             3
#> 2754             2
```

## Visualizing the Univariate Distribution 

### Barplot


```r
afghan <-
  afghan %>%
  mutate(violent.exp.ISAF.fct = 
           fct_explicit_na(fct_recode(factor(violent.exp.ISAF),
                                      Harm = "1", "No Harm" = "0"),
                           "No response"))
ggplot(afghan, aes(x = violent.exp.ISAF.fct, y = ..prop.., group = 1)) +
  geom_bar() +
  xlab("Response category") +
  ylab("Proportion of respondents") +
  ggtitle("Civilian Victimization by the ISAF")
```

<img src="measurement_files/figure-html/unnamed-chunk-9-1.png" width="70%" style="display: block; margin: auto;" />


```r
afghan <-
  afghan %>%
  mutate(violent.exp.taliban.fct = 
           fct_explicit_na(fct_recode(factor(violent.exp.taliban),
                                      Harm = "1", "No Harm" = "0"),
                           "No response"))
ggplot(afghan, aes(x = violent.exp.ISAF.fct, y = ..prop.., group = 1)) +
  geom_bar() +
  xlab("Response category") +
  ylab("Proportion of respondents") +
  ggtitle("Civilian Victimization by the Taliban")
```

<img src="measurement_files/figure-html/unnamed-chunk-10-1.png" width="70%" style="display: block; margin: auto;" />


This plot could improved by plotting the two values simultaneously to be able to better compare them.

This will require creating a data frame that has the following columns: perpetrator (`ISAF`, `Taliban`), response (`No Harm`, `Harm`, `No response`). 



```r
violent_exp <-
  afghan %>%
  select(violent.exp.ISAF, violent.exp.taliban) %>%
  gather(perpetrator, response) %>%
  mutate(perpetrator = str_replace(perpetrator, "violent\\.exp\\.", ""),
         perpetrator = str_replace(perpetrator, "taliban", "Taliban"),
         response = fct_recode(factor(response), "Harm" = "1", "No Harm" = "0"),
         response = fct_explicit_na(response, "No response"),
         response = fct_relevel(response, c("No response", "No Harm"))
         ) %>%
  count(perpetrator, response) %>%
  mutate(prop = n / sum(n))
         
ggplot(violent_exp, aes(x = prop, y = response, color = perpetrator)) +
  geom_point() +
  scale_color_manual(values = c(ISAF = "green", Taliban = "black"))
```

<img src="measurement_files/figure-html/unnamed-chunk-11-1.png" width="70%" style="display: block; margin: auto;" />

Black was chosen for the Taliban, and Green for ISAF because it is the color of their respective [flags](https://en.wikipedia.org/wiki/International_Security_Assistance_Force).


### Boxplot


```r
ggplot(afghan, aes(x = 1, y = age)) +
  geom_boxplot() +
  coord_flip() +
  labs(y = "Age", x = "") +
  ggtitle("Distribution of Age")
```

<img src="measurement_files/figure-html/unnamed-chunk-12-1.png" width="70%" style="display: block; margin: auto;" />



```r
ggplot(afghan, aes(y = educ.years, x = province)) +
  geom_boxplot() +
  coord_flip() +
  labs(x = "Province", y = "Years of education") +
  ggtitle("Education by Province")
```

<img src="measurement_files/figure-html/unnamed-chunk-13-1.png" width="70%" style="display: block; margin: auto;" />

Helmand and Uruzgan have much lower levels of education than the other
provinces, and also report higher levels of violence.

```r
afghan %>%
  group_by(province) %>%
  summarise(educ.years = mean(educ.years, na.rm = TRUE),
            violent.exp.taliban =
              mean(violent.exp.taliban, na.rm = TRUE),
            violent.exp.ISAF =
              mean(violent.exp.ISAF, na.rm = TRUE)) %>%
  arrange(educ.years)
#> # A tibble: 5 x 4
#>   province educ.years violent.exp.taliban violent.exp.ISAF
#>      <chr>      <dbl>               <dbl>            <dbl>
#> 1  Uruzgan       1.04              0.4545            0.496
#> 2  Helmand       1.60              0.5042            0.541
#> 3    Khost       5.79              0.2332            0.242
#> 4    Kunar       5.93              0.3030            0.399
#> 5    Logar       6.70              0.0802            0.144
```

### Printing and saving graphics

Use the function `ggsave()` to save **ggplot2** graphics. 

Also, R Markdown files have their own means of creating and saving plots
created by code-chunks.


## Survey Sampling

### The Role of Randomization

## load village data


```r
data("afghan.village", package = "qss")
```

Box-plots of altitude

```r
ggplot(afghan.village, aes(x = factor(village.surveyed,
                                      labels = c("sampled", "non-sampled")),
                           y = altitude)) +
  geom_boxplot() +
  labs(y = "Altitude (meter)", x = "") +
  coord_flip()
```

<img src="measurement_files/figure-html/unnamed-chunk-16-1.png" width="70%" style="display: block; margin: auto;" />

Box plots log-population values of sampled and non-sampled

```r
ggplot(afghan.village, aes(x = factor(village.surveyed,
                                      labels = c("sampled", "non-sampled")),
                           y = log(population))) +
  geom_boxplot() +
  labs(y = "log(population)", x = "") +
  coord_flip()
```

<img src="measurement_files/figure-html/unnamed-chunk-17-1.png" width="70%" style="display: block; margin: auto;" />

You can also compare these distributions by plotting their densities:

```r
ggplot(afghan.village, aes(colour = factor(village.surveyed,
                                      labels = c("sampled", "non-sampled")),
                           x = log(population))) +
  geom_density() +
  geom_rug() +
  labs(x = "log(population)", colour = "")
```

<img src="measurement_files/figure-html/unnamed-chunk-18-1.png" width="70%" style="display: block; margin: auto;" />
The function [geom_rug](http://docs.ggplot2.org/current/geom_rug.html), creates a rug plot, which puts small lines on the axis to represent the value of each observation.
It can be combined with a scatter or density plot to add extra detail.

### Non-response and other sources of bias

Calculate the rates of non-response by province to `violent.exp.ISAF` and
`violent.exp.taliban`:

```r
afghan %>%
  group_by(province) %>%
  summarise(ISAF = mean(is.na(violent.exp.ISAF)),
            taliban = mean(is.na(violent.exp.taliban))) %>%
  arrange(-ISAF)
#> # A tibble: 5 x 3
#>   province    ISAF taliban
#>      <chr>   <dbl>   <dbl>
#> 1  Uruzgan 0.02067 0.06202
#> 2  Helmand 0.01637 0.03041
#> 3    Khost 0.00476 0.00635
#> 4    Kunar 0.00000 0.00000
#> 5    Logar 0.00000 0.00000
```


Calculate the proportion who support the ISAF using the difference in means
between the ISAF and control groups:

```r
(mean(filter(afghan, list.group == "ISAF")$list.response) -
  mean(filter(afghan, list.group == "control")$list.response))
#> [1] 0.049
```


To calculate the table responses to the list experiment in the control, ISAF,
and Taliban groups>

```r
afghan %>%
  group_by(list.response, list.group) %>%
  count() %T>%
  glimpse() %>%
  spread(list.group, n, fill = 0)
#> Observations: 12
#> Variables: 3
#> $ list.response <int> 0, 0, 1, 1, 1, 2, 2, 2, 3, 3, 3, 4
#> $ list.group    <chr> "control", "ISAF", "control", "ISAF", "taliban",...
#> $ n             <int> 188, 174, 265, 278, 433, 265, 260, 287, 200, 182...
#> # A tibble: 5 x 4
#> # Groups:   list.response [5]
#>   list.response control  ISAF taliban
#> *         <int>   <dbl> <dbl>   <dbl>
#> 1             0     188   174       0
#> 2             1     265   278     433
#> 3             2     265   260     287
#> 4             3     200   182     198
#> 5             4       0    24       0
```

## Measuring Political Polarization


```r
data("congress", package = "qss")
```


```r
glimpse(congress)
#> Observations: 14,552
#> Variables: 7
#> $ congress <int> 80, 80, 80, 80, 80, 80, 80, 80, 80, 80, 80, 80, 80, 8...
#> $ district <int> 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 98, 98, 1, 2, 3, 4, 5, ...
#> $ state    <chr> "USA", "ALABAMA", "ALABAMA", "ALABAMA", "ALABAMA", "A...
#> $ party    <chr> "Democrat", "Democrat", "Democrat", "Democrat", "Demo...
#> $ name     <chr> "TRUMAN", "BOYKIN  F.", "GRANT  G.", "ANDREWS  G.", "...
#> $ dwnom1   <dbl> -0.276, -0.026, -0.042, -0.008, -0.082, -0.170, -0.12...
#> $ dwnom2   <dbl> 0.016, 0.796, 0.999, 1.005, 1.066, 0.870, 0.990, 0.89...
```


```r
q <- 
  congress %>%
  filter(congress %in% c(80, 112), 
         party %in% c("Democrat", "Republican")) %>%
  ggplot(aes(x = dwnom1, y = dwnom2, colour = party)) +
  geom_point() +
  facet_wrap(~ congress) +
  coord_fixed() +
  scale_y_continuous("racial liberalism/conservatism",
                     limits = c(-1.5, 1.5)) +
  scale_x_continuous("economic liberalism/conservatism",
                     limits = c(-1.5, 1.5))
q
```

<img src="measurement_files/figure-html/unnamed-chunk-24-1.png" width="70%" style="display: block; margin: auto;" />

However, since there are colors associated with Democrats (blue) and Republicans (blue), we should use them rather than the defaults.
There's some evidence that using semantically-resonant colors can help decoding data visualizations ([Lin, et al. 2013](http://vis.stanford.edu/files/2013-SemanticColor-EuroVis.pdf)).

Since I'll reuse the scale several times, I'll save it in a variable.

```r
scale_colour_parties <-
  scale_colour_manual(values = c(Democrat = "blue",
                                 Republican = "red",
                                 Other = "green"))
q + scale_colour_parties
```

<img src="measurement_files/figure-html/unnamed-chunk-25-1.png" width="70%" style="display: block; margin: auto;" />



```r
congress %>%
  ggplot(aes(x = dwnom1, y = dwnom2, colour = party)) +
  geom_point() +
  facet_wrap(~ congress) +
  coord_fixed() +
  scale_y_continuous("racial liberalism/conservatism",
                     limits = c(-1.5, 1.5)) +
  scale_x_continuous("economic liberalism/conservatism",
                     limits = c(-1.5, 1.5)) +
  scale_colour_parties
#> Warning: Removed 2 rows containing missing values (geom_point).
```

<img src="measurement_files/figure-html/unnamed-chunk-26-1.png" width="70%" style="display: block; margin: auto;" />


```r
congress %>%
  group_by(congress, party) %>%
  summarise(dwnom1 = mean(dwnom1)) %>%
  filter(party %in% c("Democrat", "Republican")) %>%
  ggplot(aes(x = congress, y = dwnom1, 
             colour = fct_reorder2(party, congress, dwnom1))) +
  geom_line() +
  scale_colour_parties +
  labs(y = "DW-NOMINATE score (1st Dimension)", x = "Congress",
       colour = "Party")
```

<img src="measurement_files/figure-html/unnamed-chunk-27-1.png" width="70%" style="display: block; margin: auto;" />



### Correlation

Let's plot the Gini coefficient

```r
data("USGini", package = "qss")
```


```r
ggplot(USGini, aes(x = year, y = gini)) +
  geom_point() +
  geom_line() +
  labs(x = "Year", y = "Gini coefficient") +
  ggtitle("Income Inequality")
```

<img src="measurement_files/figure-html/unnamed-chunk-29-1.png" width="70%" style="display: block; margin: auto;" />

To calculate a measure of party polarization take the code used in the plot of Republican and Democratic party median ideal points and adapt it to calculate the difference in the party medians:

```r
party_polarization <- 
  congress %>%
  group_by(congress, party) %>%
  summarise(dwnom1 = mean(dwnom1)) %>%
  filter(party %in% c("Democrat", "Republican")) %>%
  spread(party, dwnom1) %>%
  mutate(polarization = Republican - Democrat)
party_polarization
#> # A tibble: 33 x 4
#> # Groups:   congress [33]
#>   congress Democrat Republican polarization
#>      <int>    <dbl>      <dbl>        <dbl>
#> 1       80   -0.146      0.276        0.421
#> 2       81   -0.195      0.264        0.459
#> 3       82   -0.180      0.265        0.445
#> 4       83   -0.181      0.261        0.442
#> 5       84   -0.209      0.261        0.471
#> 6       85   -0.214      0.250        0.464
#> # ... with 27 more rows
```


```r
ggplot(party_polarization, aes(x = congress, y = polarization)) +
  geom_point() +
  geom_line() +
  ggtitle("Political Polarization") +
  labs(x = "Year", y = "Republican median − Democratic median")
```

<img src="measurement_files/figure-html/unnamed-chunk-31-1.png" width="70%" style="display: block; margin: auto;" />



### Quantile-Quantile Plot


```r
congress %>%
  filter(congress == 112, party %in% c("Republican", "Democrat")) %>%
  ggplot(aes(x = dwnom2, y = ..density..)) +
  geom_histogram() +
  facet_grid(party ~ .) + 
  labs(x = "racial liberalism/conservatism dimension")
#> `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.
```

<img src="measurement_files/figure-html/unnamed-chunk-32-1.png" width="70%" style="display: block; margin: auto;" />

*ggplot2* includes a `stat_qq` which can be used to create qq-plots but it is more suited to comparing a sample distribution with a theoretical distribution, usually the normal one.
However, we can calculate one by hand, which may give more insight into exactly what the qq-plot is doing.


```r
party_qtiles <- tibble(
  probs = seq(0, 1, by = 0.01),
  Democrat = quantile(filter(congress, congress == 112, party == "Democrat")$dwnom2,
         probs = probs),
  Republican = quantile(filter(congress, congress == 112, party == "Republican")$dwnom2,
         probs = probs)
)
party_qtiles
#> # A tibble: 101 x 3
#>   probs Democrat Republican
#>   <dbl>    <dbl>      <dbl>
#> 1  0.00   -0.925     -1.381
#> 2  0.01   -0.672     -0.720
#> 3  0.02   -0.619     -0.566
#> 4  0.03   -0.593     -0.526
#> 5  0.04   -0.567     -0.468
#> 6  0.05   -0.560     -0.436
#> # ... with 95 more rows
```

The plot looks different than the one in the text since the x- and y-scales are in the original values instead of z-scores (see the next section).

```r
party_qtiles %>%
  ggplot(aes(x = Democrat, y = Republican)) + 
  geom_point() +
  geom_abline() +
  coord_fixed()
```

<img src="measurement_files/figure-html/unnamed-chunk-34-1.png" width="70%" style="display: block; margin: auto;" />

## Clustering


### Matrices

While matrices are great for numerical computations, such as when you are 
implementing algorithms, generally keeping data in data frames is more convenient for data wrangling.

### Lists 

See R4DS [Chapter 20: Vectors](http://r4ds.had.co.nz/vectors.html),  [Chapter 21: Iteration](http://r4ds.had.co.nz/iteration.html) and the **purrr** package for more powerful methods of computing on lists.

### k-means algorithms

**TODO** A good visualization of the k-means algorithm and a simple, naive implementation in R.

Calculate the clusters by the 80th and 112th congresses,

```r
k80two.out <- 
  kmeans(select(filter(congress, congress == 80),
                       dwnom1, dwnom2),
              centers = 2, nstart = 5)
```

Add the cluster ids to data sets

```r
congress80 <- 
  congress %>%
  filter(congress == 80) %>%
  mutate(cluster2 = factor(k80two.out$cluster))
```

We will also create a data sets with the cluster centroids.
These are in the `centers` element of the cluster object.

```r
k80two.out$centers
#>    dwnom1 dwnom2
#> 1 -0.0484  0.783
#> 2  0.1468 -0.339
```
To make it easier to use with **ggplot2**, we need to convert this to a data frame.
The `tidy` function from the **broom** package:

```r
k80two.clusters <- tidy(k80two.out)
k80two.clusters
#>        x1     x2 size withinss cluster
#> 1 -0.0484  0.783  135     10.9       1
#> 2  0.1468 -0.339  311     54.9       2
```


Plot the ideal points and clusters

```r
ggplot() +
  geom_point(data = congress80,
             aes(x = dwnom1, y = dwnom2, colour = cluster2)) +
  geom_point(data = k80two.clusters, mapping = aes(x = x1, y = x2))
```

<img src="measurement_files/figure-html/unnamed-chunk-39-1.png" width="70%" style="display: block; margin: auto;" />

We can also plot,

```r
congress80 %>%
  group_by(party, cluster2) %>%
  count()
#> # A tibble: 5 x 3
#> # Groups:   party, cluster2 [5]
#>        party cluster2     n
#>        <chr>   <fctr> <int>
#> 1   Democrat        1   132
#> 2   Democrat        2    62
#> 3      Other        2     2
#> 4 Republican        1     3
#> 5 Republican        2   247
```

And now we can repeat these steps for the 112th congress:

```r
k112two.out <-
  kmeans(select(filter(congress, congress == 112),
                dwnom1, dwnom2),
         centers = 2, nstart = 5)

congress112 <-
  filter(congress, congress == 112) %>%
  mutate(cluster2 = factor(k112two.out$cluster))

k112two.clusters <- tidy(k112two.out)

ggplot() +
  geom_point(data = congress112,
             mapping = aes(x = dwnom1, y = dwnom2, colour = cluster2)) +
  geom_point(data = k112two.clusters,
             mapping = aes(x = x1, y = x2))
```

<img src="measurement_files/figure-html/unnamed-chunk-41-1.png" width="70%" style="display: block; margin: auto;" />


```r
congress112 %>%
  group_by(party, cluster2) %>%
  count()
#> # A tibble: 3 x 3
#> # Groups:   party, cluster2 [3]
#>        party cluster2     n
#>        <chr>   <fctr> <int>
#> 1   Democrat        2   200
#> 2 Republican        1   242
#> 3 Republican        2     1
```

Now repeat the same with four clusters on the 80th congress:

```r
k80four.out <-
  kmeans(select(filter(congress, congress == 80),
                dwnom1, dwnom2),
         centers = 4, nstart = 5)

congress80 <-
  filter(congress, congress == 80) %>%
  mutate(cluster2 = factor(k80four.out$cluster))

k80four.clusters <- tidy(k80four.out)

ggplot() +
  geom_point(data = congress80,
             mapping = aes(x = dwnom1, y = dwnom2, colour = cluster2)) +
  geom_point(data = k80four.clusters,
             mapping = aes(x = x1, y = x2), size = 3)
```

<img src="measurement_files/figure-html/unnamed-chunk-43-1.png" width="70%" style="display: block; margin: auto;" />

and on the 112th congress:

```r
k112four.out <-
  kmeans(select(filter(congress, congress == 112),
                dwnom1, dwnom2),
         centers = 4, nstart = 5)

congress112 <-
  filter(congress, congress == 112) %>%
  mutate(cluster2 = factor(k112four.out$cluster))

k112four.clusters <- tidy(k112four.out)

ggplot() +
  geom_point(data = congress112,
             mapping = aes(x = dwnom1, y = dwnom2, colour = cluster2)) +
  geom_point(data = k112four.clusters,
             mapping = aes(x = x1, y = x2), size = 3)
```

<img src="measurement_files/figure-html/unnamed-chunk-44-1.png" width="70%" style="display: block; margin: auto;" />
