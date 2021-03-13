op.nestr <- list(
  nestr.leading_zero = FALSE
)

nestr_opt <- function(x, prefix = "nestr.") {
  if(missing(x)) {
    op.nestr
  } else {
    opt_name <- paste0(prefix, x)
    res <- getOption(opt_name)
    if(!is_null(res)) return(res)
    op.nestr[[opt_name]]
  }
}
