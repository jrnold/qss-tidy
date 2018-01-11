
## Textual data

### Prerequisites {-}


```r
library("tidyverse")
library("lubridate")
library("stringr")
library("forcats")
library("modelr")
library("tm")
library("SnowballC")
library("tidytext")
```


This section will primarily use the [tidytext](https://cran.r-project.org/package=tidytext) package.
It is a relatively new package.
The [tm](https://cran.r-project.org/package=tm) and [quanteda](https://cran.r-project.org/package=quanteda) (by Ken Benoit) packages are more established and use the document-term matrix format as described in the QSS chapter.
The **tidytext** package stores everything in a data frame; this may be less efficient than the other packages, but has the benefit of being able to easily take advantage of the tidyverse ecosystem.
If your corpus is not too large, this shouldn't be an issue.

See [Tidy Text Mining with R](http://tidytextmining.com/) for a full introduction to using **tidytext**.

In tidy data, each row is an observation and each column is a variable.
In the **tidytext** package, documents are stored as data frames with **one-term-per-row**.

We can cast data into the **tidytext** format either from the `Corpus` object,
or, after processing, from the document-term matrix object.


```r
DIR_SOURCE <- system.file("extdata/federalist", package = "qss")
corpus_raw <- VCorpus(DirSource(directory = DIR_SOURCE, pattern = "fp"))
corpus_raw
#> <<VCorpus>>
#> Metadata:  corpus specific: 0, document level (indexed): 0
#> Content:  documents: 85
```

Use the function [tidy](https://www.rdocumentation.org/packages/tidyytext/topics/tidy.Corpus) to convert the  to a data frame with one row per document.

```r
corpus_tidy <- tidy(corpus_raw, "corpus")
corpus_tidy
#> # A tibble: 85 x 8
#>   author datetimestamp       description heading id     lang… orig… text  
#>   <lgl>  <dttm>              <lgl>       <lgl>   <chr>  <chr> <lgl> <chr> 
#> 1 NA     2018-01-10 16:44:39 NA          NA      fp01.… en    NA    AFTER…
#> 2 NA     2018-01-10 16:44:39 NA          NA      fp02.… en    NA    "WHEN…
#> 3 NA     2018-01-10 16:44:39 NA          NA      fp03.… en    NA    IT IS…
#> 4 NA     2018-01-10 16:44:39 NA          NA      fp04.… en    NA    "MY L…
#> 5 NA     2018-01-10 16:44:39 NA          NA      fp05.… en    NA    "QUEE…
#> 6 NA     2018-01-10 16:44:39 NA          NA      fp06.… en    NA    "THE …
#> # ... with 79 more rows
```

The `text` column contains the text of the documents themselves.
Since most of the metadata columns are either missings or irrelevant for
our purposes, we'll delete those columns,
keeping only the document (`id`) and `text` columns.

```r
corpus_tidy <- select(corpus_tidy, id, text)
```
Also, we want to extract the essay number and use that as the document id rather than its file name.

```r
corpus_tidy <-
  mutate(corpus_tidy, document = as.integer(str_extract(id, "\\d+"))) %>%
  select(-id)
```

The function  tokenizes the document texts:

```r
tokens <- corpus_tidy %>%
  # tokenizes into words and stems them
  unnest_tokens(word, text, token = "word_stems") %>%
  # remove any numbers in the strings
  mutate(word = str_replace_all(word, "\\d+", "")) %>%
  # drop any empty strings
  filter(word != "")
tokens
#> # A tibble: 202,089 x 2
#>   document word     
#>      <int> <chr>    
#> 1        1 after    
#> 2        1 an       
#> 3        1 unequivoc
#> 4        1 experi   
#> 5        1 of       
#> 6        1 the      
#> # ... with 2.021e+05 more rows
```


The `unnest_tokens` function uses the [tokenizers](https://cran.r-project.org/package=tokenizers) package to tokenize the text.
By default, it uses the  function which removes punctuation, and lowercases the words.
I set the tokenizer to  to stem the word, using the [SnowballC](https://cran.r-project.org/package=SnowballC) package.

We can remove stop-words with an [anti_join](https://www.rdocumentation.org/packages/dplyr/topics/anti_join) on the dataset [stop_words](https://www.rdocumentation.org/packages/tidytext/topics/stop_words)

```r
data("stop_words", package = "tidytext")
tokens <- anti_join(tokens, stop_words, by = "word")
```


### Document-Term Matrix

In `tokens` there is one observation for each token (word) in the each document.
This is almost equivalent to a document-term matrix.
For a document-term matrix we need documents, and terms as the keys for the data
and a column with the number of times the term appeared in the document.


```r
dtm <- count(tokens, document, word)
head(dtm)
#> # A tibble: 6 x 3
#>   document word           n
#>      <int> <chr>      <int>
#> 1        1 abl            1
#> 2        1 absurd         1
#> 3        1 accid          1
#> 4        1 accord         1
#> 5        1 acknowledg     1
#> 6        1 act            1
```


### Topic Discovery


Plot the word-clouds for essays 12 and 24:

```r
library("wordcloud")
filter(dtm, document == 12) %>% {
    wordcloud(.$word, .$n, max.words = 20)
  }
```

<img src="discovery-textual_files/figure-html/unnamed-chunk-10-1.png" width="70%" style="display: block; margin: auto;" />

```r
filter(dtm, document == 24) %>% {
    wordcloud(.$word, .$n, max.words = 20)
  }
```

<img src="discovery-textual_files/figure-html/unnamed-chunk-11-1.png" width="70%" style="display: block; margin: auto;" />


Use the function [bind_tf_idf](https://www.rdocumentation.org/packages/tidytext/topics/bind_tf_idf) to add a column with the tf-idf to the data frame.

```r
dtm <- bind_tf_idf(dtm, word, document, n)
dtm
#> # A tibble: 38,847 x 6
#>   document word           n      tf   idf   tf_idf
#>      <int> <chr>      <int>   <dbl> <dbl>    <dbl>
#> 1        1 abl            1 0.00145 0.705 0.00102 
#> 2        1 absurd         1 0.00145 1.73  0.00251 
#> 3        1 accid          1 0.00145 3.75  0.00543 
#> 4        1 accord         1 0.00145 0.754 0.00109 
#> 5        1 acknowledg     1 0.00145 1.55  0.00225 
#> 6        1 act            1 0.00145 0.400 0.000579
#> # ... with 3.884e+04 more rows
```

The 10 most important words for Paper No. 12 are

```r
dtm %>%
  filter(document == 12) %>%
  top_n(10, tf_idf)
#> # A tibble: 10 x 6
#>   document word           n      tf   idf  tf_idf
#>      <int> <chr>      <int>   <dbl> <dbl>   <dbl>
#> 1       12 cent           2 0.00199  4.44 0.00884
#> 2       12 coast          3 0.00299  3.75 0.0112 
#> 3       12 commerc        8 0.00796  1.11 0.00884
#> 4       12 contraband     3 0.00299  4.44 0.0133 
#> 5       12 excis          5 0.00498  2.65 0.0132 
#> 6       12 gallon         2 0.00199  4.44 0.00884
#> # ... with 4 more rows
```
and for Paper No. 24,

```r
dtm %>%
  filter(document == 24) %>%
  top_n(10, tf_idf)
#> # A tibble: 10 x 6
#>   document word         n      tf   idf  tf_idf
#>      <int> <chr>    <int>   <dbl> <dbl>   <dbl>
#> 1       24 armi         7 0.00858  1.26 0.0108 
#> 2       24 arsenal      2 0.00245  3.75 0.00919
#> 3       24 dock         3 0.00368  4.44 0.0163 
#> 4       24 frontier     3 0.00368  2.83 0.0104 
#> 5       24 garrison     6 0.00735  2.83 0.0208 
#> 6       24 nearer       2 0.00245  3.34 0.00820
#> # ... with 4 more rows
```

The slightly different results from the book are due to tokenization differences.

Subset those documents known to have been written by Hamilton.

```r
HAMILTON_ESSAYS <- c(1, 6:9, 11:13, 15:17, 21:36, 59:61, 65:85)
dtm_hamilton <- filter(dtm, document %in% HAMILTON_ESSAYS)
```

The [kmeans](https://www.rdocumentation.org/packages/stats/topics/kmeans) function expects the input to be rows for observations and columns for each variable: in our case that would be documents as rows, and words as columns, with the tf-idf as the cell values.
We could use `spread` to do this, but that would be a large matrix.

```r
CLUSTERS <- 4
km_out <-
  kmeans(cast_dtm(dtm_hamilton, document, word, tf_idf), centers = CLUSTERS,
         nstart = 10)
km_out$iter
#> [1] 3
```

Data frame with the unique terms used by Hamilton. I extract these from the
column names of the DTM after `cast_dtm` to ensure that the order is the same as the
k-means results.

```r
hamilton_words <-
  tibble(word = colnames(cast_dtm(dtm_hamilton, document, word, tf_idf)))
```

The centers of the clusters is a cluster x word matrix. We want to transpose it
and then append columns to `hamilton_words` so the location of each word in the cluster is listed.

```r
dim(km_out$centers)
#> [1]    4 3850
```

```r
hamilton_words <- bind_cols(hamilton_words, as_tibble(t(km_out$centers)))
hamilton_words
#> # A tibble: 3,850 x 5
#>   word            `1`      `2`     `3`      `4`
#>   <chr>         <dbl>    <dbl>   <dbl>    <dbl>
#> 1 abl        0.000939 0.000743 0       0       
#> 2 absurd     0        0.000517 0       0.000882
#> 3 accid      0        0.000202 0       0       
#> 4 accord     0        0.000399 0       0.000852
#> 5 acknowledg 0        0.000388 0       0.000473
#> 6 act        0        0.000560 0.00176 0.000631
#> # ... with 3,844 more rows
```
To find the top 10 words in each centroid, we use `top_n` with `group_by`:

```r
top_words_cluster <-
  gather(hamilton_words, cluster, value, -word) %>%
  group_by(cluster) %>%
  top_n(10, value)
```

We can print them out using a for loop

```r
for (i in 1:CLUSTERS) {
  cat("CLUSTER ", i, ": ",
      str_c(filter(top_words_cluster, cluster == i)$word, collapse = ", "),
      "\n\n")
}
#> CLUSTER  1 :  presid, appoint, senat, claus, expir, fill, recess, session, unfound, vacanc 
#> 
#> CLUSTER  2 :  offic, presid, tax, land, revenu, armi, militia, senat, taxat, claus 
#> 
#> CLUSTER  3 :  sedit, guilt, chief, clemenc, impun, plead, crime, pardon, treason, conniv 
#> 
#> CLUSTER  4 :  court, jurisdict, inferior, suprem, trial, tribun, cogniz, juri, impeach, appel
```

This is alternative code that prints out a table:

```r
gather(hamilton_words, cluster, value, -word) %>%
  group_by(cluster) %>%
  top_n(10, value) %>%
  summarise(top_words = str_c(word, collapse = ", ")) %>%
  knitr::kable()
```



cluster   top_words                                                                       
--------  --------------------------------------------------------------------------------
1         presid, appoint, senat, claus, expir, fill, recess, session, unfound, vacanc    
2         offic, presid, tax, land, revenu, armi, militia, senat, taxat, claus            
3         sedit, guilt, chief, clemenc, impun, plead, crime, pardon, treason, conniv      
4         court, jurisdict, inferior, suprem, trial, tribun, cogniz, juri, impeach, appel 

Or to print out the documents in each cluster,

```r
enframe(km_out$cluster, "document", "cluster") %>%
  group_by(cluster) %>%
  summarise(documents = str_c(document, collapse = ", ")) %>%
  knitr::kable()
```



 cluster  documents                                                                                                                                                                     
--------  ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
       1  67                                                                                                                                                                            
       2  1, 6, 7, 8, 9, 11, 12, 13, 15, 16, 17, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 59, 60, 61, 66, 68, 69, 70, 71, 72, 73, 75, 76, 77, 78, 79, 80, 84, 85 
       3  74                                                                                                                                                                            
       4  65, 81, 82, 83                                                                                                                                                                



### Authorship Prediction

We'll create a data-frame with the known

```r
MADISON_ESSAYS <- c(10, 14, 37:48, 58)
JAY_ESSAYS <- c(2:5, 64)
known_essays <- bind_rows(tibble(document = MADISON_ESSAYS,
                                 author = "Madison"),
                          tibble(document = HAMILTON_ESSAYS,
                                 author = "Hamilton"),
                          tibble(document = JAY_ESSAYS,
                                 author = "Jay"))
```



```r
STYLE_WORDS <-
  tibble(word = c("although", "always", "commonly", "consequently",
                  "considerable", "enough", "there", "upon", "while", "whilst"))

hm_tfm <-
  unnest_tokens(corpus_tidy, word, text) %>%
  count(document, word) %>%
  # term freq per 1000 words
  group_by(document) %>%
  mutate(count = n / sum(n) * 1000) %>%
  select(-n) %>%
  inner_join(STYLE_WORDS, by = "word") %>%
  # merge known essays
  left_join(known_essays, by = "document") %>%
  # make wide with each word a column
  # fill empty values with 0
  spread(word, count, fill = 0)
```

Calculate average usage by each author of each word

```r
hm_tfm %>%
  # remove docs with no author
  filter(!is.na(author)) %>%
  # convert back to long (tidy) format to make it easier to summarize
  gather(word, count, -document, -author) %>%
  # calculate averge document word usage by author
  group_by(author, word) %>%
  summarise(avg_count = mean(count)) %>%
  spread(author, avg_count) %>%
  knitr::kable()
```



word            Hamilton     Jay   Madison
-------------  ---------  ------  --------
although           0.012   0.543     0.206
always             0.522   0.929     0.154
commonly           0.184   0.129     0.000
consequently       0.018   0.469     0.344
considerable       0.377   0.081     0.123
enough             0.274   0.000     0.000
there              3.065   0.954     0.849
upon               3.054   0.112     0.152
while              0.255   0.192     0.000
whilst             0.005   0.000     0.292


```r
author_data <-
  hm_tfm %>%
  ungroup() %>%
  filter(is.na(author) | author != "Jay") %>%
  mutate(author2 = case_when(.$author == "Hamilton" ~ 1,
                             .$author == "Madison" ~ -1,
                             TRUE ~ NA_real_))

hm_fit <- lm(author2 ~ upon + there + consequently + whilst,
             data = author_data)
hm_fit
#> 
#> Call:
#> lm(formula = author2 ~ upon + there + consequently + whilst, 
#>     data = author_data)
#> 
#> Coefficients:
#>  (Intercept)          upon         there  consequently        whilst  
#>       -0.195         0.229         0.127        -0.644        -0.984

author_data <- author_data %>%
  add_predictions(hm_fit) %>%
  mutate(pred_author = if_else(pred >= 0, "Hamilton", "Madison"))

sd(author_data$pred)
#> [1] 0.79
```

These coefficients are a little different, probably due to differences in the
tokenization procedure, and in particular, the document size normalization.

### Cross-Validation


**tidyverse:** For cross-validation, I rely on the [modelr](https://cran.r-project.org/package=modelr) package function `RDoc("modelr::crossv_kfold")`. See the tutorial [Cross validation of linear regression with modelr](https://rpubs.com/dgrtwo/cv-modelr) for more on using **modelr** for cross validation or [k-fold cross-validation with modelr and broom](https://drsimonj.svbtle.com/k-fold-cross-validation-with-modelr-and-broom).

In sample, this regression perfectly predicts the authorship of the documents with known authors.

```r
author_data %>%
  filter(!is.na(author)) %>%
  group_by(author) %>%
  summarise(`Proportion Correct` = mean(author == pred_author))
#> # A tibble: 2 x 2
#>   author   `Proportion Correct`
#>   <chr>                   <dbl>
#> 1 Hamilton                 1.00
#> 2 Madison                  1.00
```

Create the cross-validation data-sets using .
As in the chapter, I will use a leave-one-out cross-validation, which is a k-fold cross-validation where k is the number of observations.
To simplify this, I define the `crossv_loo` function that runs `crossv_kfold` with `k = nrow(data)`.

```r
crossv_loo <- function(data, id = ".id") {
  modelr::crossv_kfold(data, k = nrow(data), id = id)
}

# leave one out cross-validation object
cv <- author_data %>%
  filter(!is.na(author)) %>%
  crossv_loo()
```

Now estimate the model for each training dataset

```r
models <- map(cv$train, ~ lm(author2 ~ upon + there + consequently + whilst,
                             data = ., model = FALSE))
```
Note that I use `purrr::map` to ensure that the correct `map()` function is used since the **maps** package also defines a `map`.

Now calculate the test performance on the held out observation,

```r
test <- map2_df(models, cv$test,
                function(mod, test) {
                  add_predictions(as.data.frame(test), mod) %>%
                    mutate(pred_author =
                             if_else(pred >= 0, "Hamilton", "Madison"),
                           correct = (pred_author == author))
                })
test %>%
  group_by(author) %>%
  summarise(mean(correct))
#> # A tibble: 2 x 2
#>   author   `mean(correct)`
#>   <chr>              <dbl>
#> 1 Hamilton           1.00 
#> 2 Madison            0.786
```

When adding prediction with `add_predictions` it added predictions for missing  values as well.

Table of authorship of disputed papers

```r
author_data %>%
  filter(is.na(author)) %>%
  select(document, pred, pred_author) %>%
  knitr::kable()
```



 document     pred  pred_author 
---------  -------  ------------
       18   -0.360  Madison     
       19   -0.587  Madison     
       20   -0.055  Madison     
       49   -0.966  Madison     
       50   -0.003  Madison     
       51   -1.520  Madison     
       52   -0.195  Madison     
       53   -0.506  Madison     
       54   -0.521  Madison     
       55    0.094  Hamilton    
       56   -0.550  Madison     
       57   -1.221  Madison     
       62   -0.946  Madison     
       63   -0.184  Madison     



```r
disputed_essays <- filter(author_data, is.na(author))$document

ggplot(mutate(author_data,
              author = fct_explicit_na(factor(author), "Disputed")),
       aes(y = document, x = pred, colour = author, shape = author)) +
  geom_ref_line(v = 0) +
  geom_point() +
  scale_y_continuous(breaks = seq(10, 80, by = 10),
                     minor_breaks = seq(5, 80, by = 5)) +
  scale_color_manual(values = c("Madison" = "blue",
                                "Hamilton" = "red",
                                "Disputed" = "black")) +
  scale_shape_manual(values = c("Madison" = 16, "Hamilton" = 15,
                                 "Disputed" = 17)) +
  labs(colour = "Author", shape = "Author",
       y = "Federalist Papers", x = "Predicted values")
```

<img src="discovery-textual_files/figure-html/unnamed-chunk-33-1.png" width="70%" style="display: block; margin: auto;" />
