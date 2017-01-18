
# Discovery

The idea of tidy data and the common feature of tidyverse packages is that data should be stored in data frames with certain conventions.
This works well with naturally tabular data, the type which has been common in social science applications.
But there are other domains in which other data structures are more appropriate because they more naturally model the data or processes, or for computational reasons.
The three applications in this chapter: text, networks, and spatial data are examples where the tidy data structure is less of an advantage.
I will still rely on **ggplot2** for plotting, and use tidy verse compatible packages where appropriate.

- Textual data: [tidytext](https://cran.r-project.org/package=tidytext) 
- Network data: [igraph](https://cran.r-project.org/package=igraph) for network computation, as in the chapter. But several **ggplot2**2 extension packages for plotting the networks.
- Spatial data: [ggplot2](https://cran.r-project.org/package=ggplot2) has some built-in support for maps. The [map](https://cran.r-project.org/package=map) package provides map data.

See the [R for Data Science](http://r4ds.had.co.nz/) section [12.7 Non-tidy data](http://r4ds.had.co.nz/tidy-data.html#non-tidy-data) and this post on [Non-tidy data](http://simplystatistics.org/2016/02/17/non-tidy-data/) by Jeff Leek for more on non-tidy data.


## Prerequisites


```r
library("tidyverse")
library("lubridate")
library("stringr")
library("forcats")
library("modelr")
```

## Textual data


```r
library("tm")
#> Loading required package: NLP
#> 
#> Attaching package: 'NLP'
#> The following object is masked from 'package:ggplot2':
#> 
#>     annotate
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


**Original**

```r
## load the raw corpus
corpus.raw <- Corpus(DirSource(directory = "federalist", pattern = "fp")) 
corpus.raw

## make lower case
corpus.prep <- tm_map(corpus.raw, content_transformer(tolower)) 
## remove white space
corpus.prep <- tm_map(corpus.prep, stripWhitespace) 
## remove punctuation 
corpus.prep <- tm_map(corpus.prep, removePunctuation)

## remove numbers
corpus.prep <- tm_map(corpus.prep, removeNumbers) 

head(stopwords("english"))

## remove stop words 
corpus <- tm_map(corpus.prep, removeWords, stopwords("english")) 

## finally stem remaining words
corpus <- tm_map(corpus, stemDocument) 

## the output is truncated here to save space
content(corpus[[10]]) # Essay No. 10
```

We can cast data into the **tidytext** format either from the `Corpus` object, 
or, after processing, from the document-term matrix object.



```r
DIR_SOURCE <- file.path("qss", "DISCOVERY", "federalist")
corpus_raw <- Corpus(DirSource(directory = DIR_SOURCE, pattern = "fp")) 
corpus_raw
#> <<VCorpus>>
#> Metadata:  corpus specific: 0, document level (indexed): 0
#> Content:  documents: 85
```

Use the [tidy](https://www.rdocumentation.org/packages/tidyytext/topics/tidy.Corpus) function to convert it to a data frame with one row per document.

```r
corpus_tidy <- tidy(corpus_raw)
corpus_tidy
#> # A tibble: 85 × 8
#>   author       datetimestamp description heading       id language origin
#>    <lgl>              <dttm>       <lgl>   <lgl>    <chr>    <chr>  <lgl>
#> 1     NA 2017-01-16 18:48:05          NA      NA fp01.txt       en     NA
#> 2     NA 2017-01-16 18:48:05          NA      NA fp02.txt       en     NA
#> 3     NA 2017-01-16 18:48:05          NA      NA fp03.txt       en     NA
#> 4     NA 2017-01-16 18:48:05          NA      NA fp04.txt       en     NA
#> 5     NA 2017-01-16 18:48:05          NA      NA fp05.txt       en     NA
#> 6     NA 2017-01-16 18:48:05          NA      NA fp06.txt       en     NA
#> # ... with 79 more rows, and 1 more variables: text <chr>
```
The `text` column contains the text of the documents themselves.
Since most of the metadata is irrelevant, we'll delete those columns, 
keeping only the document (`id`) and `text` columns.

```r
corpus_tidy <- select(corpus_tidy, id, text)
```
Also, we want to extract the essay number and use that as the document id rather than its file name.

```r
corpus_tidy <- mutate(corpus_tidy, 
                      document = as.integer(str_extract(id, "\\d+"))) %>%
  select(-id)
```



The  tokenizes the document texts.

```r
tokens <- corpus_tidy %>%
  # tokenizes into words and stems them
  unnest_tokens(word, text, token = "word_stems") %>%
  # remove any numbers in the strings
  mutate(word = str_replace_all(word, "\\d+", "")) %>%
  # drop any empty strings
  filter(word != "")
tokens
#> # A tibble: 187,412 × 2
#>   document      word
#>      <int>     <chr>
#> 1        1     after
#> 2        1        an
#> 3        1 unequivoc
#> 4        1    experi
#> 5        1        of
#> 6        1       the
#> # ... with 1.874e+05 more rows
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

**Original:**

```r
dtm <- DocumentTermMatrix(corpus)
dtm
inspect(dtm[1:5, 1:8])
dtm.mat <- as.matrix(dtm)
```

In `tokens` there is one observation for each token (word) in the each document.
This is almost equivalent to a document-term matrix.
For a document-term matrix we need documents, and terms as the keys for the data
and a column with the number of times the term appeared in the document.


```r
dtm <- count(tokens, document, word)
head(dtm)
#> Source: local data frame [6 x 3]
#> Groups: document [1]
#> 
#>   document        word     n
#>      <int>       <chr> <int>
#> 1        1           1     1
#> 2        1      absurd     1
#> 3        1    accident     1
#> 4        1 acknowledge     1
#> 5        1         act     1
#> 6        1    actuated     1
```


### Topic Discovery

**Original:**

```r
library(wordcloud)

wordcloud(colnames(dtm.mat), dtm.mat[12, ], max.words = 20)  # essay No. 12
wordcloud(colnames(dtm.mat), dtm.mat[24, ], max.words = 20)  # essay No. 24
```

Plot the word-clouds for essays 12 and 24:

```r
library("wordcloud")
#> Loading required package: RColorBrewer
filter(dtm, document == 12) %>%
  {wordcloud(.$word, .$n, max.words = 20)}
```

<img src="discovery_files/figure-html/unnamed-chunk-14-1.png" width="70%" style="display: block; margin: auto;" />

```r
filter(dtm, document == 24) %>%
  {wordcloud(.$word, .$n, max.words = 20)}
```

<img src="discovery_files/figure-html/unnamed-chunk-15-1.png" width="70%" style="display: block; margin: auto;" />

**Original:**

```r
stemCompletion(c("revenu", "commerc", "peac", "army"), corpus.prep)
```


**Original:**

```r
dtm.tfidf <- weightTfIdf(dtm) # tf-idf calculation

dtm.tfidf.mat <- as.matrix(dtm.tfidf)  # convert to matrix

## 10 most important words for Paper No. 12
head(sort(dtm.tfidf.mat[12, ], decreasing = TRUE), n = 10)

## 10 most important words for Paper No. 24
head(sort(dtm.tfidf.mat[24, ], decreasing = TRUE), n = 10)
```

**tidyverse:** Use the function [bind_tf_idf](https://www.rdocumentation.org/packages/tidytext/topics/bind_tf_idf) to add a column with the tf-idf to the data frame.

```r
dtm <- bind_tf_idf(dtm, word, document, n)
dtm
#> Source: local data frame [42,978 x 6]
#> Groups: document [?]
#> 
#>   document        word     n      tf   idf  tf_idf
#>      <int>       <chr> <int>   <dbl> <dbl>   <dbl>
#> 1        1           1     1 0.00186 0.832 0.00155
#> 2        1      absurd     1 0.00186 2.245 0.00417
#> 3        1    accident     1 0.00186 3.750 0.00697
#> 4        1 acknowledge     1 0.00186 2.497 0.00464
#> 5        1         act     1 0.00186 0.705 0.00131
#> 6        1    actuated     1 0.00186 2.651 0.00493
#> # ... with 4.297e+04 more rows
```

The 10 most important words for Paper No. 12 are

```r
dtm %>%
  filter(document == 12) %>%
  top_n(10, tf_idf)
#> Source: local data frame [10 x 6]
#> Groups: document [1]
#> 
#>   document        word     n      tf   idf tf_idf
#>      <int>       <chr> <int>   <dbl> <dbl>  <dbl>
#> 1       12        cent     2 0.00250  4.44 0.0111
#> 2       12  contraband     3 0.00375  4.44 0.0167
#> 3       12      duties     8 0.01001  1.26 0.0127
#> 4       12      excise     2 0.00250  4.44 0.0111
#> 5       12 importation     3 0.00375  3.06 0.0115
#> 6       12     patrols     3 0.00375  4.44 0.0167
#> # ... with 4 more rows
```
and for Paper No. 24,

```r
dtm %>%
  filter(document == 24) %>%
  top_n(10, tf_idf)
#> Source: local data frame [10 x 6]
#> Groups: document [1]
#> 
#>   document           word     n      tf   idf tf_idf
#>      <int>          <chr> <int>   <dbl> <dbl>  <dbl>
#> 1       24         armies     5 0.00770  1.73 0.0134
#> 2       24           dock     3 0.00462  4.44 0.0205
#> 3       24 establishments     7 0.01079  1.55 0.0167
#> 4       24       frontier     3 0.00462  2.83 0.0131
#> 5       24      garrisons     6 0.00924  2.83 0.0262
#> 6       24          posts     3 0.00462  3.06 0.0141
#> # ... with 4 more rows
```

The slightly different results from the book are due to tokenization differences.

**Original:**

```r
k <- 4  # number of clusters
## subset The Federalist papers written by Hamilton
hamilton <- c(1, 6:9, 11:13, 15:17, 21:36, 59:61, 65:85)
dtm.tfidf.hamilton <- dtm.tfidf.mat[hamilton, ]

## run k-means
km.out <- kmeans(dtm.tfidf.hamilton, centers = k)
km.out$iter # check the convergence; number of iterations may vary

## label each centroid with the corresponding term
colnames(km.out$centers) <- colnames(dtm.tfidf.hamilton)

for (i in 1:k) { # loop for each cluster
    cat("CLUSTER", i, "\n")
    cat("Top 10 words:\n") # 10 most important terms at the centroid
    print(head(sort(km.out$centers[i, ], decreasing = TRUE), n = 10))
    cat("\n")
    cat("Federalist Papers classified: \n") # extract essays classified
    print(rownames(dtm.tfidf.hamilton)[km.out$cluster == i])
    cat("\n")
}
```

**tidyverse:** Subset those documents known to have been written by Hamilton.

```r
HAMILTON_ESSAYS <- c(1, 6:9, 11:13, 15:17, 21:36, 59:61, 65:85)
dtm_hamilton <- filter(dtm, document %in% HAMILTON_ESSAYS)
```

The [kmeans](https://www.rdocumentation.org/packages/stats/topics/kmeans) function expects the input to be rows for observations and columns for each variable: in our case that would be documents as rows, and words as columns, with the tf-idf as the cell values. 
We could use `spread` to do this, but that would be a large matrix.

```r
CLUSTERS <- 4
km_out <-
  kmeans(cast_dtm(dtm_hamilton, document, word, tf_idf), centers = CLUSTERS, nstart = 10)
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
#> [1]    4 6457
```

```r
hamilton_words <- bind_cols(hamilton_words, as_tibble(t(km_out$centers)))
hamilton_words
#> # A tibble: 6,457 × 5
#>          word      `1`      `2`     `3`      `4`
#>         <chr>    <dbl>    <dbl>   <dbl>    <dbl>
#> 1           1 0.000897 0.000627 0.00251 0.000569
#> 2      absurd 0.000797 0.000633 0.00000 0.000000
#> 3    accident 0.000000 0.000307 0.00000 0.000000
#> 4 acknowledge 0.000886 0.000724 0.00000 0.000000
#> 5         act 0.000438 0.000757 0.00000 0.001071
#> 6    actuated 0.000000 0.000380 0.00000 0.000000
#> # ... with 6,451 more rows
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
#> CLUSTER  1 :  court, jurisdiction, courts, supreme, inferior, trial, tribunals, cognizance, jury, appellate 
#> 
#> CLUSTER  2 :  national, taxes, duties, revenue, army, military, militia, taxation, clause, elections 
#> 
#> CLUSTER  3 :  judges, compensation, inability, office, diminished, salaries, bench, faculties, insanity, subsistence 
#> 
#> CLUSTER  4 :  court, executive, appointment, senate, appointments, president, impeachments, nomination, governor, vacancies
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
--------  --------------------------------------------------------------------------------------------------------------
1         court, jurisdiction, courts, supreme, inferior, trial, tribunals, cognizance, jury, appellate                 
2         national, taxes, duties, revenue, army, military, militia, taxation, clause, elections                        
3         judges, compensation, inability, office, diminished, salaries, bench, faculties, insanity, subsistence        
4         court, executive, appointment, senate, appointments, president, impeachments, nomination, governor, vacancies 

Or to print out the documents in each cluster,

```r
enframe(km_out$cluster, "document", "cluster") %>%
  group_by(cluster) %>%
  summarise(documents = str_c(document, collapse = ", ")) %>%
  knitr::kable()
```



 cluster  documents                                                                                                                                                             
--------  ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
       1  74                                                                                                                                                                    
       2  67                                                                                                                                                                    
       3  1, 6, 7, 8, 9, 11, 12, 13, 15, 16, 17, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 34, 35, 36, 59, 60, 61, 65, 66, 68, 69, 70, 71, 72, 73, 75, 76, 77, 78, 79, 84, 85 
       4  32, 33, 80, 81, 82, 83                                                                                                                                                



### Authorship Prediction

**Original:**

```r
## document-term matrix converted to matrix for manipulation 
dtm1 <- as.matrix(DocumentTermMatrix(corpus.prep)) 
tfm <- dtm1 / rowSums(dtm1) * 1000 # term frequency per 1000 words

## words of interest
words <- c("although", "always", "commonly", "consequently",
           "considerable", "enough", "there", "upon", "while", "whilst")

## select only these words
tfm <- tfm[, words]

## essays written by Madison: `hamilton' defined earlier
madison <- c(10, 14, 37:48, 58)

## average among Hamilton/Madison essays
tfm.ave <- rbind(colSums(tfm[hamilton, ]) / length(hamilton), 
                 colSums(tfm[madison, ]) / length(madison))
tfm.ave
```


**tidyverse:** We'll create a data-frame with the known 

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
although           0.013   0.584     0.222
always             0.563   0.999     0.166
commonly           0.198   0.139     0.000
consequently       0.019   0.503     0.371
considerable       0.406   0.087     0.133
enough             0.295   0.000     0.000
there              3.303   1.026     0.917
upon               3.291   0.120     0.164
while              0.274   0.207     0.000
whilst             0.005   0.000     0.315


**Original:**

```r
author <- rep(NA, nrow(dtm1)) # a vector with missing values
author[hamilton] <- 1  # 1 if Hamilton
author[madison] <- -1  # -1 if Madison

## data frame for regression
author.data <- data.frame(author = author[c(hamilton, madison)], 
                          tfm[c(hamilton, madison), ])

hm.fit <- lm(author ~ upon + there + consequently + whilst, 
             data = author.data)
hm.fit

hm.fitted <- fitted(hm.fit) # fitted values
sd(hm.fitted)
```


**tidyverse:**

```r
library("modelr")
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
#>       -0.195         0.213         0.118        -0.596        -0.910

author_data <- author_data %>%
  add_predictions(hm_fit) %>%
  mutate(pred_author = if_else(pred >= 0, "Hamilton", "Madison"))

sd(author_data$pred)
#> [1] 0.79
```

These coefficients are a little different, probably due to differences in the 
tokenization procedure, and in particular, the document size normalization.

### Cross-Validation

**Original:**

```r
## proportion of correctly classified essays by Hamilton
mean(hm.fitted[author.data$author == 1] > 0)

## proportion of correctly classified essays by Madison
mean(hm.fitted[author.data$author == -1] < 0)
```

**tidyverse:** For cross-validation, I rely on the [modelr](https://cran.r-project.org/package=modelr) package function `RDoc("modelr::crossv_kfold")`. See the tutorial [Cross validation of linear regression with modelr](https://rpubs.com/dgrtwo/cv-modelr) for more on using **modelr** for cross validation or [k-fold cross-validation with modelr and broom](https://drsimonj.svbtle.com/k-fold-cross-validation-with-modelr-and-broom).

In sample, this regression perfectly predicts the authorship of the documents with known authors.

```r
author_data %>%
  filter(!is.na(author)) %>%
  group_by(author) %>%
  summarise(`Proportion Correct` = mean(author == pred_author))
#> # A tibble: 2 × 2
#>     author `Proportion Correct`
#>      <chr>                <dbl>
#> 1 Hamilton                    1
#> 2  Madison                    1
```

Create the cross-validation data-sets using . 
As in the chapter, I will use a leave-one-out cross-validation, which is a k-fold crossvalidation where k is the number of observations. 
To simplify this, I define the `crossv_loo` function that runs `crossv_kfold` with `k = nrow(data)`.

```r
crossv_loo <- function(data, id = ".id") {
  crossv_kfold(data, k = nrow(data), id = id)
}

# leave one out cross-validation object
cv <- author_data %>%
  filter(!is.na(author)) %>%
  crossv_loo()
```

Now estimate the model for each training dataset

```r
models <- purrr::map(cv$train, ~ lm(author2 ~ upon + there + consequently + whilst,
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
#> # A tibble: 2 × 2
#>     author `mean(correct)`
#>      <chr>           <dbl>
#> 1 Hamilton           1.000
#> 2  Madison           0.786
```



**Original:**

```r
n <- nrow(author.data)
hm.classify <- rep(NA, n) # a container vector with missing values 

for (i in 1:n) {
    ## fit the model to the data after removing the ith observation
    sub.fit <- lm(author ~ upon + there + consequently + whilst, 
                  data = author.data[-i, ]) # exclude ith row
    ## predict the authorship for the ith observation
    hm.classify[i] <- predict(sub.fit, newdata = author.data[i, ])
}

## proportion of correctly classified essays by Hamilton
mean(hm.classify[author.data$author == 1] > 0)

## proportion of correctly classified essays by Madison
mean(hm.classify[author.data$author == -1] < 0)
```

**Original:**

```r
disputed <- c(49, 50:57, 62, 63) # 11 essays with disputed authorship
tf.disputed <- as.data.frame(tfm[disputed, ])

## prediction of disputed authorship
pred <- predict(hm.fit, newdata = tf.disputed)
pred # predicted values
```

**tidyverse:**
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
       18   -0.359  Madison     
       19   -0.586  Madison     
       20   -0.055  Madison     
       49   -0.966  Madison     
       50   -0.002  Madison     
       51   -1.522  Madison     
       52   -0.195  Madison     
       53   -0.506  Madison     
       54   -0.520  Madison     
       55    0.094  Hamilton    
       56   -0.550  Madison     
       57   -1.219  Madison     
       62   -0.944  Madison     
       63   -0.184  Madison     


```r
par(cex = 1.25)
## fitted values for essays authored by Hamilton; red squares
plot(hamilton, hm.fitted[author.data$author == 1], pch = 15, 
     xlim = c(1, 85), ylim  = c(-2, 2), col = "red", 
     xlab = "Federalist Papers", ylab = "Predicted values")
abline(h = 0, lty = "dashed")

## essays authored by Madison; blue circles
points(madison, hm.fitted[author.data$author == -1], 
       pch = 16, col = "blue")

## disputed authorship; black triangles
points(disputed, pred, pch = 17) 

```


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
       x = "Federalist Papers", y = "Predicted values")
```

<img src="discovery_files/figure-html/unnamed-chunk-46-1.png" width="70%" style="display: block; margin: auto;" />


## Network Data

Network data is area for which the tidyverse is not well suited.
The [igraph](https://cran.r-project.org/package=igraph), [sna](https://cran.r-project.org/package=sna), and [network](https://cran.r-project.org/package=network) packages are the best in class. 
See the Social Network Analysis section of the [Social Sciences Task View](https://cran.r-project.org/web/views/SocialSciences.html).
See this tutorial by Katherin Ognyanova, [Static and dynamic nework visualization with R](https://rpubs.com/kateto/netviz), for a good overview of network visualization with those packages in R.

There are several packages that plot networks in ggplot2.

- [ggnetwork](https://cran.r-project.org/package=ggnetwork)
- [ggraph](https://cran.r-project.org/package=ggraph)
- [geomnet](https://cran.r-project.org/package=geomnet)
- [GGally](https://cran.r-project.org/package=GGally) functions [ggnet](https://ggobi.github.io/ggally/rd.html#ggnet), `ggnet2`, and `ggnetworkmap`.
- [ggCompNet](https://cran.r-project.org/package=ggCompNet) compares the speed of various network plotting packages in R.
 
See this [presentation](http://curleylab.psych.columbia.edu/netviz/netviz1.html#/12) for an overview of some of those packages for data visualization.

Examples: [Network Visualization Examples with the ggplot2 Package](https://cran.r-project.org/web/packages/ggCompNet/vignettes/examples-from-paper.html)


```r
library("igraph")
```



### Twitter Following Network

**Original:**

```r
twitter <- read.csv("twitter-following.csv")
senator <- read.csv("twitter-senator.csv")
```

**tidyverse:**

```r
twitter <- read_csv(qss_data_url("discovery", "twitter-following.csv"))
#> Parsed with column specification:
#> cols(
#>   following = col_character(),
#>   followed = col_character()
#> )
senator <- read_csv(qss_data_url("discovery", "twitter-senator.csv"))
#> Parsed with column specification:
#> cols(
#>   screen_name = col_character(),
#>   name = col_character(),
#>   party = col_character(),
#>   state = col_character()
#> )
```

**Original:**

```r
n <- nrow(senator) # number of senators

## initialize adjacency matrix
twitter.adj <- matrix(0, nrow = n, ncol = n)

## assign screen names to rows and columns
colnames(twitter.adj) <- rownames(twitter.adj) <- senator$screen_name

## change `0' to `1' when edge goes from node `i' to node `j'
for (i in 1:nrow(twitter)) {
    twitter.adj[twitter$following[i], twitter$followed[i]] <- 1
}

twitter.adj <- graph.adjacency(twitter.adj, mode = "directed", diag = FALSE)

```

**tidyverse:**
Simply use the  function since `twitter` consists of edges (a link from a senator to another).
SInce `graph_from_edgelist` expects a matrix, convert the data frame to a matrix using .

```r
twitter_adj <- graph_from_edgelist(as.matrix(twitter))
```


**original:**

```r
senator$indegree <- degree(twitter.adj, mode = "in")
senator$outdegree <- degree(twitter.adj, mode = "out") 

in.order <- order(senator$indegree, decreasing = TRUE)
out.order <- order(senator$outdegree, decreasing = TRUE)

## 3 greatest indegree
senator[in.order[1:3], ]

## 3 greatest outdegree
senator[out.order[1:3], ]
```

**tidyverse:** Add in- and out-degree varibles to the `senator` data frame:

```r
senator <-
  mutate(senator,
         indegree = degree(twitter_adj, mode = "in"),
         outdegree = degree(twitter_adj, mode = "out"))
```

Now find the senators with the 3 greatest in-degrees

```r
arrange(senator, desc(indegree)) %>%
  slice(1:3) %>%
  select(name, party, state, indegree, outdegree)
#> # A tibble: 3 × 5
#>                name party state indegree outdegree
#>               <chr> <chr> <chr>    <dbl>     <dbl>
#> 1        Tom Cotton     R    AR       64        15
#> 2 Richard J. Durbin     D    IL       60        87
#> 3     John Barrasso     R    WY       58        79
```
or using the  function:

```r
top_n(senator, 3, indegree) %>%
  arrange(desc(indegree)) %>%
  select(name, party, state, indegree, outdegree)
#> # A tibble: 5 × 5
#>                name party state indegree outdegree
#>               <chr> <chr> <chr>    <dbl>     <dbl>
#> 1        Tom Cotton     R    AR       64        15
#> 2 Richard J. Durbin     D    IL       60        87
#> 3     John Barrasso     R    WY       58        79
#> 4      Joe Donnelly     D    IN       58         9
#> 5    Orrin G. Hatch     R    UT       58        50
```
The `top_n` function catches that three senators are tied for 3rd highest outdegree, whereas the simply sorting and slicing cannot.

And we can find the senators with the three highest out-degrees similarly,

```r
top_n(senator, 3, outdegree) %>%
  arrange(desc(outdegree)) %>%
  select(name, party, state, indegree, outdegree)
#> # A tibble: 4 × 5
#>               name party state indegree outdegree
#>              <chr> <chr> <chr>    <dbl>     <dbl>
#> 1     Thad Cochran     R    MS       55        89
#> 2     Steve Daines     R    MT       30        88
#> 3      John McCain     R    AZ       41        88
#> 4 Joe Manchin, III     D    WV       43        88
```



**original:**

```r
n <- nrow(senator)
## color: Democrats = `blue', Republicans = `red', Independent = `black'
col <- rep("red", n)
col[senator$party == "D"] <- "blue"
col[senator$party == "I"] <- "black"

## pch: Democrats = circle, Republicans = diamond, Independent = cross
pch <- rep(16, n)
pch[senator$party == "D"] <- 17
pch[senator$party == "I"] <- 4

par(cex = 1.25)
## plot for comparing two closeness measures (incoming vs. outgoing)
plot(closeness(twitter.adj, mode = "in"), 
     closeness(twitter.adj, mode = "out"), pch = pch, col = col, 
     main = "Closeness", xlab = "Incoming path", ylab = "Outgoing path")

## plot for comparing directed and undirected betweenness
plot(betweenness(twitter.adj, directed = TRUE), 
     betweenness(twitter.adj, directed = FALSE), pch = pch, col = col,
     main = "Betweenness", xlab = "Directed", ylab = "Undirected")

```


**tidyverse**

```r
# Define scales to reuse for the plots
scale_colour_parties <- scale_colour_manual("Party", values = c(R = "red",
                                                       D = "blue",
                                                       I = "green"))
scale_shape_parties <- scale_shape_manual("Party", values = c(R = 16, 
                                                              D = 17, 
                                                              I = 4))


senator %>%
  mutate(closeness_in = closeness(twitter_adj, mode = "in"),
         closeness_out = closeness(twitter_adj, mode = "out")) %>%
  ggplot(aes(x = closeness_in, y = closeness_out,
             colour = party, shape = party)) +
  geom_abline(intercept = 0, slope = 1, colour = "white", size = 2) +
  geom_point() +
  scale_colour_parties +
  scale_shape_parties +
  labs(main = "Closeness", x = "Incoming path", y = "Outgoing path")
```

<img src="discovery_files/figure-html/unnamed-chunk-58-1.png" width="70%" style="display: block; margin: auto;" />

What does the reference line indicate? What does that say about senators twitter
networks?



```r
senator %>%
  mutate(betweenness_dir = betweenness(twitter_adj, directed = TRUE),
         betweenness_undir = betweenness(twitter_adj, directed = FALSE)) %>%
  ggplot(aes(x = betweenness_dir, y = betweenness_undir, colour = party,
             shape = party)) +
  geom_abline(intercept = 0, slope = 1, colour = "white", size = 2) +
  geom_point() +
  scale_colour_parties +
  scale_shape_parties +
  coord_fixed() +
  labs(main = "Betweenness", x = "Directed", y = "Undirected")
```

<img src="discovery_files/figure-html/unnamed-chunk-59-1.png" width="70%" style="display: block; margin: auto;" />


We've covered three different methods of calculating the importance of a node in a network: degree, closeness, and centrality. 
But what do they mean? What's the "best" measure of importance?
The answer to the the former is "it depends on the question".
There are probably other papers out there on this, but Borgatti (2005) is a good
discussion:

> Borgatti, Stephen. 2005. "Centrality and Network Flow". *Social Networks*.
  [DOI](https://dx.doi.org/doi:10.1016/j.socnet.2004.11.008)

**Original:**

```r
senator$pagerank <- page.rank(twitter.adj)$vector

par(cex = 1.25)
## `col' parameter is defined earlier
plot(twitter.adj, vertex.size = senator$pagerank * 1000, 
     vertex.color = col, vertex.label = NA, 
     edge.arrow.size = 0.1, edge.width = 0.5)
```


Add and plot page-rank:

```r
senator <- mutate(senator, page_rank = page_rank(twitter_adj)[["vector"]])

library("GGally")
#> 
#> Attaching package: 'GGally'
#> The following object is masked from 'package:dplyr':
#> 
#>     nasa
library("intergraph")
ggnet(twitter_adj, mode = "target")
#> Loading required package: network
#> network: Classes for Relational Data
#> Version 1.13.0 created on 2015-08-31.
#> copyright (c) 2005, Carter T. Butts, University of California-Irvine
#>                     Mark S. Handcock, University of California -- Los Angeles
#>                     David R. Hunter, Penn State University
#>                     Martina Morris, University of Washington
#>                     Skye Bender-deMoll, University of Washington
#>  For citation information, type citation("network").
#>  Type help("network-package") to get started.
#> 
#> Attaching package: 'network'
#> The following objects are masked from 'package:igraph':
#> 
#>     %c%, %s%, add.edges, add.vertices, delete.edges,
#>     delete.vertices, get.edge.attribute, get.edges,
#>     get.vertex.attribute, is.bipartite, is.directed,
#>     list.edge.attributes, list.vertex.attributes,
#>     set.edge.attribute, set.vertex.attribute
#> Loading required package: sna
#> Loading required package: statnet.common
#> sna: Tools for Social Network Analysis
#> Version 2.4 created on 2016-07-23.
#> copyright (c) 2005, Carter T. Butts, University of California-Irvine
#>  For citation information, type citation("sna").
#>  Type help(package="sna") to get started.
#> 
#> Attaching package: 'sna'
#> The following objects are masked from 'package:igraph':
#> 
#>     betweenness, bonpow, closeness, components, degree,
#>     dyad.census, evcent, hierarchy, is.connected, neighborhood,
#>     triad.census
#> Loading required package: scales
#> 
#> Attaching package: 'scales'
#> The following object is masked from 'package:purrr':
#> 
#>     discard
#> The following objects are masked from 'package:readr':
#> 
#>     col_factor, col_numeric
```

<img src="discovery_files/figure-html/unnamed-chunk-61-1.png" width="70%" style="display: block; margin: auto;" />



## Spatial Data in R


Some resources on plotting spatial data in R:

- [ggplot2](https://cran.r-project.org/package=ggplot2) has several map-related functions

  - [borders](http://docs.ggplot2.org/current/borders.html)
  - [fortify.map](http://docs.ggplot2.org/current/fortify.map.html)
  - [map_data](http://docs.ggplot2.org/current/map_data.html)

- [ggmap](https://cran.r-project.org/package=ggmap) allows ggplot to us a map from Google Maps, OpenStreet Maps or similar as a background for the plot.

  - David Kahle and Hadley Wickham. 2013. [ggmap: Spatial Visualization with ggplot2](https://journal.r-project.org/archive/2013-1/kahle-wickham.pdf). *Journal of Statistical Software*
  - Github [dkahle/ggmamp](https://github.com/dkahle/ggmap)

- [tmap](https://cran.r-project.org/package=tmap) is not built on ggplot2 but uses a ggplot2-like API for network data.
- [leaflet](https://cran.r-project.org/package=leaflet) is an R interface to a popular javascript mapping library.

Here are few tutorials on plotting spatial data in ggplot2:

- [Making Maps with R](http://eriqande.github.io/rep-res-web/lectures/making-maps-with-R.html)
- [Plotting Data on a World Map](https://www.r-bloggers.com/r-beginners-plotting-locations-on-to-a-world-map/)
- [Introduciton to Spatial Data and ggplot2](https://rpubs.com/m_dev/Intro-to-Spatial-Data-and-ggplot2)



```r
library("ggrepel")
```


```r
data("us.cities", package = "maps")
glimpse(us.cities)
#> Observations: 1,005
#> Variables: 6
#> $ name        <chr> "Abilene TX", "Akron OH", "Alameda CA", "Albany GA...
#> $ country.etc <chr> "TX", "OH", "CA", "GA", "NY", "OR", "NM", "LA", "V...
#> $ pop         <int> 113888, 206634, 70069, 75510, 93576, 45535, 494962...
#> $ lat         <dbl> 32.5, 41.1, 37.8, 31.6, 42.7, 44.6, 35.1, 31.3, 38...
#> $ long        <dbl> -99.7, -81.5, -122.3, -84.2, -73.8, -123.1, -106.6...
#> $ capital     <int> 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,...
```


```r
usa_map <- map_data("usa")
capitals <- filter(us.cities,
                   capital == 2, 
                   !country.etc %in% c("HI", "AK"))
ggplot() +
  geom_map(map = usa_map) +
  borders(database = "usa") +
  geom_point(aes(x = long, y = lat, size = pop), 
             data = capitals) +
  # scale size area ensures: 0 = no area
  scale_size_area() +
  coord_quickmap() +
  theme_void() +
  labs(x = "", y = "", title = "US State Capitals",
       size = "Population")
```

<img src="discovery_files/figure-html/unnamed-chunk-64-1.png" width="70%" style="display: block; margin: auto;" />


```r
cal_cities <- filter(us.cities, country.etc == "CA") %>%
  top_n(7, pop)

ggplot() +
  borders(database = "state", regions = "California") +
  geom_point(aes(x = long, y = lat), data = cal_cities) +
  geom_text_repel(aes(x = long, y = lat, label = name), data = cal_cities) +
  coord_quickmap() +
  theme_minimal() +
  labs(x = "", y = "")
```

<img src="discovery_files/figure-html/unnamed-chunk-65-1.png" width="70%" style="display: block; margin: auto;" />



### Colors in R

For more resources on using colors in R

- `R4DS` chapter [Graphics for Communication](http://r4ds.had.co.nz/graphics-for-communication.html#replacing-a-scale)
- ggplot2 book Chapter "Scales"
- Jenny Bryan [Using colors in R](https://www.stat.ubc.ca/~jenny/STAT545A/block14_colors.html)
- Achim Zeileis, Kurt Hornik, Paul Murrell (2009). Escaping RGBland: Selecting Colors for Statistical Graphics. Computational Statistics & Data Analysis [DOI](http://dx.doi.org/10.1016/j.csda.2008.11.033)
- [colorspace vignette](https://cran.r-project.org/web/packages/colorspace/vignettes/hcl-colors.pdf)
- Maureen Stone [Choosing Colors for Data Visualization](https://www.perceptualedge.com/articles/b-eye/choosing_colors.pdf)
- [ColorBrewer](http://colorbrewer2.org) A website with a variety of palettes, primarily designed for maps, but also useful in data viz.
- Stephen Few [Practical Rules for Using Color in Charts](http://www.perceptualedge.com/articles/visual_business_intelligence/rules_for_using_color.pdf)
- [Why Should Engineers and Scientists by Worried About Color?](http://www.research.ibm.com/people/l/lloydt/color/color.HTM)
- [A Better Default Colormap for Matplotlib](https://www.youtube.com/watch?v=xAoljeRJ3lU) A SciPy 2015 talk that describes how the [viridis](https://cran.r-project.org/package=viridis) was created.
- [Evaluation of Artery Visualizations for Heart Disease Diagnosis](http://www.eecs.harvard.edu/~kgajos/papers/2011/borkin11-infoviz.pdf) Using the wrong color scale can be deadly ... literally.
- The python package matplotlib has a good discussion of [colormaps](http://matplotlib.org/users/colormaps.html).
- Peter Kovesi [Good Color Maps: How to Design Them](https://arxiv.org/pdf/1509.03700v1.pdf).
- See the [viridis](https://cran.r-project.org/package=viridis), [ggthemes](https://cran.r-project.org/package=ggthemes), [dichromat](https://cran.r-project.org/package=dichromat), and [pals](https://cran.r-project.org/package=pals) packages for color palettes.


Use [scale_identity](http://docs.ggplot2.org/current/scale_identity.html) for the color and alpha scales since the values
of the variables are the values of the scale itself (the color names, and the 
alpha values).

```r
ggplot(tibble(x = rep(1:4, each = 2),
              y = x + rep(c(0, 0.2), times = 2),
              colour = rep(c("black", "red"), each = 4),
              alpha = c(1, 1, 0.5, 0.5, 1, 1, 0.5, 0.5)),
  aes(x = x, y = y, colour = colour, alpha = alpha)) +
  geom_point(size = 15) +
  scale_color_identity() +
  scale_alpha_identity() +
  theme_bw() +
  theme(panel.grid = element_blank())
```

<img src="discovery_files/figure-html/unnamed-chunk-66-1.png" width="70%" style="display: block; margin: auto;" />


### United States Presidential Elections

**Original:**

```r
pres08 <- read.csv("pres08.csv")
## two-party vote share
pres08$Dem <- pres08$Obama / (pres08$Obama + pres08$McCain)
pres08$Rep <- pres08$McCain / (pres08$Obama + pres08$McCain) ## color for California
cal.color <- rgb(red = pres08$Rep[pres08$state == "CA"],
                 blue = pres08$Dem[pres08$state == "CA"],
                 green = 0)
```

**tidyverse:**

```r
pres08 <- read_csv(qss_data_url("discovery", "pres08.csv")) %>%
  mutate(Dem = Obama / (Obama + McCain),
         Rep = McCain / (Obama + McCain))
#> Parsed with column specification:
#> cols(
#>   state.name = col_character(),
#>   state = col_character(),
#>   Obama = col_integer(),
#>   McCain = col_integer(),
#>   EV = col_integer()
#> )
```

**Original:**

```r
## California as a blue state
map(database = "state", regions = "California", col = "blue",
    fill = TRUE)
## California as a purple state
map(database = "state", regions = "California", col = cal.color,
    fill = TRUE)
```

**tidyverse:**

```r
ggplot() +
  borders(database = "state", regions = "California", fill = "blue") +
  coord_quickmap() +
  theme_void() 
```

<img src="discovery_files/figure-html/unnamed-chunk-70-1.png" width="70%" style="display: block; margin: auto;" />


```r
cal_color <- filter(pres08, state == "CA") %>%
  {rgb(red = .$Rep, green = 0, blue = .$Dem)}
  
ggplot() +
  borders(database = "state", regions = "California", fill = cal_color) +
  coord_quickmap() +
  theme_void()
```

<img src="discovery_files/figure-html/unnamed-chunk-71-1.png" width="70%" style="display: block; margin: auto;" />


```r
# America as red and blue states
map(database = "state") # create a map 
for (i  in 1:nrow(pres08)) {
    if ((pres08$state[i] != "HI") & (pres08$state[i] != "AK") &
        (pres08$state[i] != "DC")) {
        map(database = "state", regions = pres08$state.name[i],
            col = ifelse(pres08$Rep[i] > pres08$Dem[i], "red", "blue"),
            fill = TRUE, add = TRUE)
    }
}

## America as purple states 
map(database = "state") # create a map 
for (i in 1:nrow(pres08)) {
    if ((pres08$state[i] != "HI") & (pres08$state[i] != "AK") &
        (pres08$state[i] != "DC")) {
        map(database = "state", regions = pres08$state.name[i],
            col = rgb(red = pres08$Rep[i], blue = pres08$Dem[i],
               green = 0), fill = TRUE, add = TRUE)
    }
}                      
```


```r
states <- map_data("state") %>%
  left_join(mutate(pres08, state.name = str_to_lower(state.name)),
            by = c("region" = "state.name")) %>%
  # drops DC
  filter(!is.na(EV)) %>%
  mutate(party = if_else(Dem > Rep, "Dem", "Rep"),
         color = map2_chr(Dem, Rep, ~ rgb(blue = .x, red = .y, green = 0)))

ggplot(states) +
  geom_polygon(aes(group = group, x = long, y = lat,
                   fill = party)) +
  coord_quickmap() +
  scale_fill_manual(values = c("Rep" = "red", "Dem" = "blue")) +
  theme_void() +
  labs(x = "", y = "")
```

<img src="discovery_files/figure-html/unnamed-chunk-73-1.png" width="70%" style="display: block; margin: auto;" />

For plotting the purple states, I use  since the `color` column contains the RGB values to use in the plot:

```r
ggplot(states) +
  geom_polygon(aes(group = group, x = long, y = lat,
                   fill = color)) +
  coord_quickmap() +
  scale_fill_identity() +
  theme_void() +
  labs(x = "", y = "")
```

<img src="discovery_files/figure-html/unnamed-chunk-74-1.png" width="70%" style="display: block; margin: auto;" />

However, plotting purple states is not a good data visualization.
Even though the colors are a proportional mixture of red and blue, human visual perception doesn't work that way.

The proportion of the democratic vote is best thought of a diverging scale with 0.5 is midpoint.
And since the Democratic Party is associated with the color blue and the Republican Party is associated with the color red.
The Color Brewer palette [RdBu](http://colorbrewer2.org/#type=diverging&scheme=RdBu&n=11) is an example:

```r
ggplot(states) +
  geom_polygon(aes(group = group, x = long, y = lat, fill = Dem)) +
  scale_fill_distiller("% Obama", direction = 1, limits = c(0, 1), type = "div", palette = "RdBu") +
  coord_quickmap() +
  theme_void() +
  labs(x = "", y = "")
```

<img src="discovery_files/figure-html/unnamed-chunk-75-1.png" width="70%" style="display: block; margin: auto;" />




### Expansion of Walmart

**Original:**

```r
walmart <- read.csv("walmart.csv")
## red = WalMartStore, blue = SuperCenter, green = DistributionCenter
walmart$storecolors <- NA # create an empty vector
walmart$storecolors[walmart$type == "Wal-MartStore"] <-
    rgb(red = 1, green = 0, blue = 0, alpha = 1/3)
walmart$storecolors[walmart$type == "SuperCenter"] <-
    rgb(red = 0, green = 0, blue = 1, alpha = 1/3)
walmart$storecolors[walmart$type == "DistributionCenter"] <-
rgb(red = 0, green = 1, blue = 0, alpha = 1/3)
## larger circles for DistributionCenter
walmart$storesize <- ifelse(walmart$type == "DistributionCenter", 1, 0.5)
```

**tidyverse:** We don't need to do the direct mapping since 

```r
walmart <- read_csv(qss_data_url("discovery", "walmart.csv"))
#> Parsed with column specification:
#> cols(
#>   opendate = col_date(format = ""),
#>   st.address = col_character(),
#>   city = col_character(),
#>   state = col_character(),
#>   long = col_double(),
#>   lat = col_double(),
#>   type = col_character()
#> )

ggplot() +
  borders(database = "state") +
  geom_point(aes(x = long, y = lat, colour = type, size = size),
             data = mutate(walmart, 
                           size = if_else(type == "DistributionCenter", 2, 1)), alpha = 1 / 3) +
  coord_quickmap() +
  scale_size_identity() +
  theme_void() 
```

<img src="discovery_files/figure-html/unnamed-chunk-77-1.png" width="70%" style="display: block; margin: auto;" />
We don't need to worry about colors since `ggplot` handles that.

To make a plot showing all Walmart stores opened up through that year, I write a function, that takes the year and dataset as parameters.

Since I am calling the function for its side effect (printing the plot) rather than the value it returns, I use the [walk](https://www.rdocumentation.org/packages/purrr/topics/walk) function rather than [map](https://www.rdocumentation.org/packages/purrr/topics/map). See [R for Data Science](http://r4ds.had.co.nz/), [Chapter 21.8: Walk](http://r4ds.had.co.nz/iteration.html#walk) for more information.

```r
map_walmart <- function(year, .data) {
  .data <- filter(.data, opendate < make_date(year, 1, 1)) %>%
    mutate(size = if_else(type == "DistributionCenter", 2, 1))
  ggplot() +
    borders(database = "state") +
    geom_point(aes(x = long, y = lat, colour = type, size = size),
               data = .data, alpha = 1 / 3) +
    coord_quickmap() +
    scale_size_identity() +
    theme_void() +
    ggtitle(year)
}

years <- c(1975, 1985, 1995, 2005)
walk(years, ~ print(map_walmart(.x, walmart)))
```

<img src="discovery_files/figure-html/unnamed-chunk-78-1.png" width="70%" style="display: block; margin: auto;" /><img src="discovery_files/figure-html/unnamed-chunk-78-2.png" width="70%" style="display: block; margin: auto;" /><img src="discovery_files/figure-html/unnamed-chunk-78-3.png" width="70%" style="display: block; margin: auto;" /><img src="discovery_files/figure-html/unnamed-chunk-78-4.png" width="70%" style="display: block; margin: auto;" />


### Animation in R

For easy animation with [ggplot2](https://cran.r-project.org/package=ggplot2), use the [gganimate](https://github.com/dgrtwo/gganimate) package.
Note that the **gganimate** package is not on CRAN, so you have to install it with the [devtools](https://cran.r-project.org/package=devtools) package:

```r
install.packages("cowplot")
devtools::install_github("dgrtwo/animate")
```

An animation is a series of frames. 
The [gganimate](https://cran.r-project.org/package=gganimate) package works by adding a `frame` aesthetic to ggplots, and function  will animate the plot.

I use `frame = year(opendate)` to have the animation use each year as a frame, and `cumulative = TRUE` so that the previous years are shown.

```r
library("gganimate")
walmart_animated <-
  ggplot() +
    borders(database = "state") +
    geom_point(aes(x = long, y = lat,
                   colour = type,
                   fill = type,
                   frame = year(opendate),
                   cumulative = TRUE),
               data = walmart) +
    coord_quickmap() +
    theme_void()
gganimate(walmart_animated)
```

<img src="discovery_files/figure-html/unnamed-chunk-80-1.png" width="70%" style="display: block; margin: auto;" /><img src="discovery_files/figure-html/unnamed-chunk-80-2.png" width="70%" style="display: block; margin: auto;" /><img src="discovery_files/figure-html/unnamed-chunk-80-3.png" width="70%" style="display: block; margin: auto;" /><img src="discovery_files/figure-html/unnamed-chunk-80-4.png" width="70%" style="display: block; margin: auto;" /><img src="discovery_files/figure-html/unnamed-chunk-80-5.png" width="70%" style="display: block; margin: auto;" /><img src="discovery_files/figure-html/unnamed-chunk-80-6.png" width="70%" style="display: block; margin: auto;" /><img src="discovery_files/figure-html/unnamed-chunk-80-7.png" width="70%" style="display: block; margin: auto;" /><img src="discovery_files/figure-html/unnamed-chunk-80-8.png" width="70%" style="display: block; margin: auto;" /><img src="discovery_files/figure-html/unnamed-chunk-80-9.png" width="70%" style="display: block; margin: auto;" /><img src="discovery_files/figure-html/unnamed-chunk-80-10.png" width="70%" style="display: block; margin: auto;" /><img src="discovery_files/figure-html/unnamed-chunk-80-11.png" width="70%" style="display: block; margin: auto;" /><img src="discovery_files/figure-html/unnamed-chunk-80-12.png" width="70%" style="display: block; margin: auto;" /><img src="discovery_files/figure-html/unnamed-chunk-80-13.png" width="70%" style="display: block; margin: auto;" /><img src="discovery_files/figure-html/unnamed-chunk-80-14.png" width="70%" style="display: block; margin: auto;" /><img src="discovery_files/figure-html/unnamed-chunk-80-15.png" width="70%" style="display: block; margin: auto;" /><img src="discovery_files/figure-html/unnamed-chunk-80-16.png" width="70%" style="display: block; margin: auto;" /><img src="discovery_files/figure-html/unnamed-chunk-80-17.png" width="70%" style="display: block; margin: auto;" /><img src="discovery_files/figure-html/unnamed-chunk-80-18.png" width="70%" style="display: block; margin: auto;" /><img src="discovery_files/figure-html/unnamed-chunk-80-19.png" width="70%" style="display: block; margin: auto;" /><img src="discovery_files/figure-html/unnamed-chunk-80-20.png" width="70%" style="display: block; margin: auto;" /><img src="discovery_files/figure-html/unnamed-chunk-80-21.png" width="70%" style="display: block; margin: auto;" /><img src="discovery_files/figure-html/unnamed-chunk-80-22.png" width="70%" style="display: block; margin: auto;" /><img src="discovery_files/figure-html/unnamed-chunk-80-23.png" width="70%" style="display: block; margin: auto;" /><img src="discovery_files/figure-html/unnamed-chunk-80-24.png" width="70%" style="display: block; margin: auto;" /><img src="discovery_files/figure-html/unnamed-chunk-80-25.png" width="70%" style="display: block; margin: auto;" /><img src="discovery_files/figure-html/unnamed-chunk-80-26.png" width="70%" style="display: block; margin: auto;" /><img src="discovery_files/figure-html/unnamed-chunk-80-27.png" width="70%" style="display: block; margin: auto;" /><img src="discovery_files/figure-html/unnamed-chunk-80-28.png" width="70%" style="display: block; margin: auto;" /><img src="discovery_files/figure-html/unnamed-chunk-80-29.png" width="70%" style="display: block; margin: auto;" /><img src="discovery_files/figure-html/unnamed-chunk-80-30.png" width="70%" style="display: block; margin: auto;" /><img src="discovery_files/figure-html/unnamed-chunk-80-31.png" width="70%" style="display: block; margin: auto;" /><img src="discovery_files/figure-html/unnamed-chunk-80-32.png" width="70%" style="display: block; margin: auto;" /><img src="discovery_files/figure-html/unnamed-chunk-80-33.png" width="70%" style="display: block; margin: auto;" /><img src="discovery_files/figure-html/unnamed-chunk-80-34.png" width="70%" style="display: block; margin: auto;" /><img src="discovery_files/figure-html/unnamed-chunk-80-35.png" width="70%" style="display: block; margin: auto;" /><img src="discovery_files/figure-html/unnamed-chunk-80-36.png" width="70%" style="display: block; margin: auto;" /><img src="discovery_files/figure-html/unnamed-chunk-80-37.png" width="70%" style="display: block; margin: auto;" /><img src="discovery_files/figure-html/unnamed-chunk-80-38.png" width="70%" style="display: block; margin: auto;" /><img src="discovery_files/figure-html/unnamed-chunk-80-39.png" width="70%" style="display: block; margin: auto;" /><img src="discovery_files/figure-html/unnamed-chunk-80-40.png" width="70%" style="display: block; margin: auto;" /><img src="discovery_files/figure-html/unnamed-chunk-80-41.png" width="70%" style="display: block; margin: auto;" /><img src="discovery_files/figure-html/unnamed-chunk-80-42.png" width="70%" style="display: block; margin: auto;" /><img src="discovery_files/figure-html/unnamed-chunk-80-43.png" width="70%" style="display: block; margin: auto;" />
