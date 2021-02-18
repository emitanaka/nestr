
<!-- README.md is generated from README.Rmd. Please edit that file -->

# nestr

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
<!-- badges: end -->

``` r
library(nestr)
```

``` r
nest_in(1:3, 
        1 ~ 3,
        . ~ 1)
#>   parent child
#> 1      1     1
#> 2      1     2
#> 3      1     3
#> 4      2     1
#> 5      3     1
```

For those who want to stay within the tidyverse framework, this is in
fact doable just using `dplyr` and `tidyr`.

``` r
library(tidyverse)
data.frame(x = 1:3) %>% 
  mutate(y = case_when(x==1 ~ list(1:3),
                       TRUE ~ list(1:2))) %>% 
  unnest_longer(y)
#> # A tibble: 7 x 2
#>       x     y
#>   <int> <int>
#> 1     1     1
#> 2     1     2
#> 3     1     3
#> 4     2     1
#> 5     2     2
#> 6     3     1
#> 7     3     2
```

The semantics are less direct, however and chaining of nesting structure
is cumbersome.
