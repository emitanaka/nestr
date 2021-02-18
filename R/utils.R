

ndigits <- function(x, min_ndigits = NULL) {
  max(c(floor(log10(abs(x))) + 1,
        max(min_ndigits, nestr_opt("min_ndigits"), 1)))
}
