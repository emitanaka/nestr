#' @export
nest_in <- function(.x, ..., name = "child", prefix = NULL, suffix = NULL,
                    unique = FALSE, leading0 = FALSE, min_ndigits = NULL,
                    name_parent = "parent") {
  x_name <- tryCatch(as_string(enexpr(.x)), error = function(x) name_parent)
  dots <- enquos(...)
  levels <- unique(.x)
  levels_left <- levels
  prefix <- prefix %||% ""
  suffix <- suffix %||% ""
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
    out[[name]] <- make_labels(leading0, min_ndigits, sum(reps), prefix, suffix)
  } else {
    labels <- make_labels(leading0, min_ndigits, max(reps), prefix, suffix)
    out[[name]] <- unlist(lapply(reps[.x], function(n) labels[1:n]))
  }
  out <- as.data.frame(out)
  rownames(out) <- NULL
  out
}

make_labels <- function(leading0, min_ndigits, n, prefix, suffix) {
  if(leading0) {
    sprintf(paste0("%s%.", ndigits(n, min_ndigits), "d%s"), prefix, 1:n, suffix)
  } else {
    paste0(prefix, 1:n, suffix)
  }
}
