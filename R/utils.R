

ndigits <- function(x, min_ndigits = NULL) {
  max(c(floor(log10(abs(x))) + 1,
        max(min_ndigits, as.numeric(nestr_opt("nestr.leading_zero")), 1)))
}

make_labels <- function(n, leading0, prefix, suffix) {
  if(!isFALSE(leading0)) {
    min_ndigits <- as.integer(leading0)
    sprintf(paste0("%s%.", ndigits(n, min_ndigits), "d%s"), prefix, 1:n, suffix)
  } else {
    paste0(prefix, 1:n, suffix)
  }
}
