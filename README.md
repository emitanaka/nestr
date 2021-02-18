
<!-- README.md is generated from README.Rmd. Please edit that file -->

# nestr

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
<!-- badges: end -->

``` r
library(nestr)
```

## `edibble::nested_in` and `nestr::nest_in`

The syntax of `nestr` is the similar to `edibble::nested_in` which is
used within the
[`edibble::set_units`](https://edibble.emitanaka.org/reference/set_units.html)
to construct nested (or hierarchical) structures.

The syntax proves useful in situations where the child units are
unbalanced across the parental levels.

``` r
nest_in(1:3, # parental vector
        1 ~ 3, # level 1 has 3 children
        . ~ 1) # the remaining levels have 1 child 
#>   parent child
#> 1      1     1
#> 2      1     2
#> 3      1     3
#> 4      2     1
#> 5      3     1
```

Unlike `edibble::nested_in`, the `nestr::nest_in` returns a data frame.
You may also notice that the name of the function is different although
both share similar syntax. One way to remember the differences in
function name is that `nest`**`ed`**`_in` is for `edibble` and is meant
for construction of the experimental design. When the verb is written in
present tense (i.e. `nest_in`), it’s part of `nestr` and your focus is
to create a structure in the present.

A more interesing example.

``` r
farmer <- c("John", "Jane", "Ann", "Thomas", "Helen")
nest_in(farmer, 
               "John" ~ 2,
    c("Ann", "Helen") ~ 10,
                    . ~ 3,
        name = "chick",
        prefix = "chick-",
        leading0 = 4)
#>    farmer      chick
#> 1    John chick-0001
#> 2    John chick-0002
#> 3    Jane chick-0001
#> 4    Jane chick-0002
#> 5    Jane chick-0003
#> 6     Ann chick-0001
#> 7     Ann chick-0002
#> 8     Ann chick-0003
#> 9     Ann chick-0004
#> 10    Ann chick-0005
#> 11    Ann chick-0006
#> 12    Ann chick-0007
#> 13    Ann chick-0008
#> 14    Ann chick-0009
#> 15    Ann chick-0010
#> 16 Thomas chick-0001
#> 17 Thomas chick-0002
#> 18 Thomas chick-0003
#> 19  Helen chick-0001
#> 20  Helen chick-0002
#> 21  Helen chick-0003
#> 22  Helen chick-0004
#> 23  Helen chick-0005
#> 24  Helen chick-0006
#> 25  Helen chick-0007
#> 26  Helen chick-0008
#> 27  Helen chick-0009
#> 28  Helen chick-0010
```

## `amplify`

Not implemented yet.

The `dplyr::mutate` function modifies, creates or deletes columns but
doesn’t alter the number of rows. The `nestr::amplify` function can
create new columns which generally increase (or amplify) the size of the
row dimension. The columns that were amplified as a result of the
created column will be duplicated. If you are familiar with gene
replication process then you can recall these functions in those terms.
An amplified gene is just a duplication of the original. A mutated gene
modifies the original state.

``` r
data.frame(country = c("AU", "NZ", "JPN", "CHN", "USA")) %>% 
  amplify(person = nest_in(country, 
                            "AU" ~ 20,
                            "NZ" ~ 10,
                               . ~ 100),
          child = nest_in(person, 
                          1:10 ~ 3,
                             . ~ 2))
```

## `tidyverse`

For those who want to stay within the tidyverse framework, this is in
fact doable just using `dplyr` and `tidyr`.

``` r
library(tidyverse)
data.frame(parent = 1:3) %>% 
  mutate(child = case_when(parent==1 ~ list(1:3),
                       TRUE ~ list(1:2))) %>% 
  unnest_longer(child)
#> # A tibble: 7 x 2
#>   parent child
#>    <int> <int>
#> 1      1     1
#> 2      1     2
#> 3      1     3
#> 4      2     1
#> 5      2     2
#> 6      3     1
#> 7      3     2
```

The semantics are less direct, however and chaining of nesting structure
is cumbersome. For example, see the country example below.

``` r
data.frame(country = c("AU", "NZ", "JPN", "CHN", "USA")) %>% 
  mutate(person = case_when(country=="AU" ~ list(1:20),
                            country=="NZ" ~ list(1:10),
                               TRUE ~ list(1:100))) %>% 
  unnest_longer(person) %>% 
  mutate(child = case_when(person %in% unique(person)[1:10] ~ list(1:3),
                           TRUE ~ list(1:2))) %>% 
  unnest_longer(child)
#> # A tibble: 710 x 3
#>    country person child
#>    <chr>    <int> <int>
#>  1 AU           1     1
#>  2 AU           1     2
#>  3 AU           1     3
#>  4 AU           2     1
#>  5 AU           2     2
#>  6 AU           2     3
#>  7 AU           3     1
#>  8 AU           3     2
#>  9 AU           3     3
#> 10 AU           4     1
#> # … with 700 more rows
```

The intent I think is more clear from the above `amplify` example.
