#' @export
nest_in <- function(.x, ..., name = "y", prefix = name, suffix = NULL, unique = FALSE) {
  x_name <- tryCatch(as_string(enexpr(.x)), error = function(x) 'x')
  dots <- enquos(...)
  levels <- unique(.x)
  levels_left <- levels
  reps <- vector(mode = "integer", length = length(levels))
  for(i in seq_along(dots)) {
    expr <- quo_get_expr(dots[[i]])
    # nested_in(unit, 2)
    if(is.numeric(expr) & length(dots)==1L) {
      nrep <- expr
      reps <- rep(nrep, length(levels))
    } else {
      # nested_in(unit, . ~ 2)
      # support for single nesting unit only
      lhs <- f_lhs(expr)
      rhs <- f_rhs(expr)
      nc <- eval(rhs) # only numeric value supported for now
      if(is_symbol(lhs, name = ".")) {
        np_left <- length(levels_left)
        reps[levels %in% levels_left] <- nc
      } else {
        elhs <- eval(lhs)
        igroup <- switch(class(elhs),
                         integer = elhs,
                         numeric = elhs,
                         character = match(elhs, levels),
                         abort("LHS currently needs to be integer, numeric, or character"))
        reps[igroup] <- nc
        levels_left <- setdiff(levels_left, levels[igroup])
      }
    }
  }
  names(reps) <- levels
  out <- list()
  out[[x_name]] <- rep(.x, times = reps[.x])

  if(unique) {
    out[[name]] <- paste0(prefix, 1:sum(reps), suffix)
  } else {
    labels <- paste0(prefix, 1:max(reps), suffix)
    out[[name]] <- unlist(lapply(reps[.x], function(n) labels[1:n]))
  }
  as.data.frame(out)
}
