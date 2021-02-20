
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
nest_in(c(1:3, 2:3), # parental vector
        1 ~ 3, # level 1 has 3 children
        . ~ 1) # the remaining levels have 1 child 
#> $`1`
#> [1] "1" "2" "3"
#> 
#> $`2`
#> [1] "1"
#> 
#> $`3`
#> [1] "1"
#> 
#> $`2`
#> [1] "1"
#> 
#> $`3`
#> [1] "1"
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
nest_in(c("John", "Jane", "Ann", "Thomas", "Helen"), 
               "John" ~ 2,
    c("Ann", "Helen") ~ 10,
                    . ~ 3,
        prefix = "chick-",
        leading0 = 4)
#> $John
#> [1] "chick-0001" "chick-0002"
#> 
#> $Jane
#> [1] "chick-0001" "chick-0002" "chick-0003"
#> 
#> $Ann
#>  [1] "chick-0001" "chick-0002" "chick-0003" "chick-0004" "chick-0005"
#>  [6] "chick-0006" "chick-0007" "chick-0008" "chick-0009" "chick-0010"
#> 
#> $Thomas
#> [1] "chick-0001" "chick-0002" "chick-0003"
#> 
#> $Helen
#>  [1] "chick-0001" "chick-0002" "chick-0003" "chick-0004" "chick-0005"
#>  [6] "chick-0006" "chick-0007" "chick-0008" "chick-0009" "chick-0010"
```

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
#> # A tibble: 81 x 3
#>    country soil     rep  
#>    <chr>   <chr>    <chr>
#>  1 AU      sample01 1    
#>  2 AU      sample01 2    
#>  3 AU      sample01 3    
#>  4 NZ      sample01 1    
#>  5 NZ      sample01 2    
#>  6 NZ      sample01 3    
#>  7 CHN     sample01 1    
#>  8 CHN     sample01 2    
#>  9 CHN     sample01 3    
#> 10 USA     sample01 1    
#> # … with 71 more rows

table(df$country, df$soil)
#>      
#>       sample01 sample02 sample03 sample04 sample05 sample06 sample07 sample08
#>   AU         3        3        3        2        2        2        2        2
#>   CHN        3        3        3        2        2        0        0        0
#>   JPN        3        3        3        2        2        0        0        0
#>   NZ         3        3        3        2        2        2        2        2
#>   USA        3        3        3        2        2        0        0        0
#>      
#>       sample09 sample10
#>   AU         2        2
#>   CHN        0        0
#>   JPN        0        0
#>   NZ         0        0
#>   USA        0        0
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
  mutate(soil = case_when(country=="AU" ~ list(sprintf("sample%.2d", 1:10)),
                          country=="NZ" ~ list(sprintf("sample%.2d", 1:8)),
                               TRUE ~ list(sprintf("sample%.2d", 1:5)))) %>% 
  unnest_longer(soil) %>% 
  mutate(rep = case_when(soil %in% c("sample01", "sample02", "sample03") ~ list(1:3),
                           TRUE ~ list(1:2))) %>% 
  unnest_longer(rep)
#> # A tibble: 81 x 3
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

The intent I think is more clear from the above `amplify` example.
