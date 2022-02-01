
<!-- README.md is generated from README.Rmd. Please edit that file -->

# nestr

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html)
[![CRAN
status](https://www.r-pkg.org/badges/version/nestr)](https://CRAN.R-project.org/package=nestr)
<!-- badges: end -->

## Installation

You can install the stable version on CRAN:

``` r
install.packages("nestr")
```

Or alternatively, you can install the development version from Github
using below.

``` r
# install.packages("remotes")
remotes::install_github("emitanaka/nestr")
```

## Getting started

``` r
library(nestr)
```

The main purpose of `nestr` R-package is to build nested (or
hierarchical) structures with output as a list or a data frame. The
syntax is particularly useful when the child units are unbalanced across
the parental levels.

``` r
nest_in(c("a", "c", "a", "b"), # parental vector
        2 ~ 3, # level 2 has 3 children
        . ~ 1) # the remaining levels have 1 child 
#> $a
#> [1] "1"
#> 
#> $c
#> [1] "1"
#> 
#> $a
#> [1] "1"
#> 
#> $b
#> [1] "1" "2" "3"
```

The parental vector may be a factor with different ordering of the
levels.

``` r
nest_in(factor(c("a", "c", "a", "b"), levels = c("a", "c", "b")), # parental vector
        2 ~ 3, # level 2 has 3 children
        . ~ 1) # the remaining levels have 1 child 
#> $a
#> [1] "1"
#> 
#> $c
#> [1] "1" "2" "3"
#> 
#> $a
#> [1] "1"
#> 
#> $b
#> [1] "1"
```

Or you can refer the parental level by character.

``` r
nest_in(c("a", "c", "a", "b"), # parental vector
        "b" ~ 3, # "b" has 3 children
        . ~ 1) # the remaining levels have 1 child 
#> $a
#> [1] "1"
#> 
#> $c
#> [1] "1"
#> 
#> $a
#> [1] "1"
#> 
#> $b
#> [1] "1" "2" "3"
```

A more interesting example.

``` r
nest_in(c("Math", "Science", "Economics", "Art"), 
               "Science" ~ 2,
    c("Art", "Math") ~ 10,
                    . ~ 3,
        prefix = "student-",
        leading0 = 4)
#> $Math
#> [1] "student-0001" "student-0002" "student-0003"
#> 
#> $Science
#> [1] "student-0001" "student-0002"
#> 
#> $Economics
#> [1] "student-0001" "student-0002" "student-0003"
#> 
#> $Art
#>  [1] "student-0001" "student-0002" "student-0003" "student-0004" "student-0005"
#>  [6] "student-0006" "student-0007" "student-0008" "student-0009" "student-0010"
```

## `edibble::nested_in` and `nestr::nest_in`

The syntax of `nestr` is similar to `edibble::nested_in` which is used
within the
[`edibble::set_units`](https://edibble.emitanaka.org/reference/set_units.html)
to construct nested (or hierarchical) structures.

Unlike `edibble::nested_in`, the `nestr::nest_in` returns a data frame.
You may also notice that the name of the function is different although
both share virtually the same syntax. One way to remember the
differences in function name is that `nested_in` is for `edibble` and is
meant for construction of the experimental design (notice the “ed” in
the function name). When the verb is written in present tense
(i.e. `nest_in`), it’s part of `nestr` and your focus is to create a
structure in the present.

## `amplify`

The `dplyr::mutate` function modifies, creates or deletes columns but
doesn’t alter the number of rows. The `nestr::amplify` function can
create new columns which generally increase (or amplify) the size of the
row dimension. The columns that were amplified as a result of the
created column will be duplicated. If you are familiar with gene
replication process then you can recall these functions in those terms.
An amplified gene is just a duplication of the original. A mutated gene
modifies the original state.

``` r
df <- data.frame(country = c("AU", "NZ", "JPN", "CHN", "USA")) %>% 
  amplify(soil = nest_in(country, 
                            "AU" ~ 10,
                            "NZ" ~ 8,
                               . ~ 5,
                           prefix = "sample",
                           leading0 = TRUE),
          rep = nest_in(soil, 
                          1:3 ~ 3, # first 3 samples have 3 technical rep
                            . ~ 2)) # remaining have two rep

tibble::as_tibble(df)
#> # A tibble: 71 × 3
#>    country soil     rep  
#>    <chr>   <chr>    <chr>
#>  1 AU      sample01 1    
#>  2 AU      sample01 2    
#>  3 AU      sample01 3    
#>  4 JPN     sample01 1    
#>  5 JPN     sample01 2    
#>  6 JPN     sample01 3    
#>  7 NZ      sample01 1    
#>  8 NZ      sample01 2    
#>  9 NZ      sample01 3    
#> 10 CHN     sample01 1    
#> # … with 61 more rows
```

## `tidyverse`

For those who want to stay within the tidyverse framework, this is in
fact doable just using `dplyr` and `tidyr`.

The semantics are less direct, however and chaining of nesting structure
is cumbersome. For example, see the equivalent example from before
below.

``` r
library(dplyr)
library(tidyr)
data.frame(country = c("AU", "NZ", "JPN", "CHN", "USA")) %>% 
  mutate(soil = case_when(country=="AU" ~ list(sprintf("sample%.2d", 1:10)),
                          country=="NZ" ~ list(sprintf("sample%.2d", 1:8)),
                               TRUE ~ list(sprintf("sample%.2d", 1:5)))) %>% 
  unnest_longer(soil) %>% 
  mutate(rep = case_when(soil %in% c("sample01", "sample02", "sample03") ~ list(1:3),
                           TRUE ~ list(1:2))) %>% 
  unnest_longer(rep)
#> # A tibble: 81 × 3
#>    country soil       rep
#>    <chr>   <chr>    <int>
#>  1 AU      sample01     1
#>  2 AU      sample01     2
#>  3 AU      sample01     3
#>  4 AU      sample02     1
#>  5 AU      sample02     2
#>  6 AU      sample02     3
#>  7 AU      sample03     1
#>  8 AU      sample03     2
#>  9 AU      sample03     3
#> 10 AU      sample04     1
#> # … with 71 more rows
```

The intent I think is more clear from the above `amplify` example. It’s
a personal preference so use what suits your own situation!
