
#' Create a nested structure
#'
#' This function results in a two column data frame with nested structure.
#' Currently only one parent is supported and child is only specified by
#' giving the number of levels. (This will change shortly).
#'
#' @param .x A vector where each entry is a parent.
#' @param ... A single integer or sequence of two-sided formula. If a
#'  single integer then each parent will have children specified by that
#'  integer. If it is sequence of two-sided formula, then the left hand
#'  side (LHS) specifies the level as an integer or character. E.g. `1`
#'  means the first unique entry of the parent vector. If it is a
#'  character then it is assumed that it corresponds to the label of
#'  the parental level. Vector is supported for LHS.
#'  The right hand side (RHS) only supports numbers at the moment and
#'  corresponds to the number of children for the parental levels specified
#'  on LHS of the corresponding formula.
#' @param name The name of the child variable.
#' @param name_parent The name of the parent variable. If the parent
#'  was parsed as an assigned object then the name of the object is
#'  taken as the name unless `name_parent` is specified.
#' @param prefix The prefix for the child labels.
#' @param suffix The suffix for the child labels.
#' @param leading0 By default it is `FALSE`. If `TRUE`, this is the
#'  same as setting `0` or `1`. If a positive integer is
#'  specified then it corresponds to the minimum number of digits
#'  for the child labels and there will be leading zeros augmented so
#'  that the minimum number is met.
#' @param unique A logical value to indicate whether the child labels
#'  across parents should be unique.
#'
#' @return A two column data frame with the first column corresponding to
#'  parental levels and the second column corresponding to the child levels.
#'
#' @examples
#' # Each element in the supplied the vector has 4 child.
#' nest_in(1:3, 4)
#'
#' # if an object pointing to the vector is supplied then the
#' # name of the object is used as a column name instead
#' first_name <- c("Tom", "Helen")
#' nest_in(first_name, 4)
#'
#' # the variable name for parent and child can be overwritten
#' nest_in(first_name, 4, name = "pet", name_parent = "person")
#'
#' # prefix and suffix can be added to child labels
#' # along with other aesthesitics like leading zeroes
#' # with minimum number of digits.
#' nest_in(1:3, 10, prefix = "id-", suffix = "xy", leading0 = 4)
#'
#' # you can specify unbalanced nested structures
#' nest_in(2:4,
#'          1 ~ 3,
#'          2 ~ 4,
#'          3 ~ 2)
#'
#' # A `.` may be used to specify "otherwise".
#' nest_in(c("A", "B", "C", "D"),
#'              2:3 ~ 10,
#'                . ~ 3)
#'
#' # The parental level can be referred by its name or vectorised.
#' nest_in(c("A", "B", "C"),
#'          c("A", "B") ~ 10,
#'                  "C" ~ 3)
#'
#' @export
nest_in <- function(.x, ..., name = "child",
                    name_parent = NULL,
                    prefix = NULL, suffix = NULL,
                    unique = FALSE, leading0 = FALSE) {
  x_name <- name_parent %||%
    tryCatch(as_string(enexpr(.x)), error = function(x) "parent")
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
    out[[name]] <- make_labels(leading0, sum(reps), prefix, suffix)
  } else {
    labels <- make_labels(leading0, max(reps), prefix, suffix)
    out[[name]] <- unlist(lapply(reps[.x], function(n) labels[1:n]))
  }
  out <- as.data.frame(out)
  rownames(out) <- NULL
  out
}

make_labels <- function(leading0, n, prefix, suffix) {
  if(!isFALSE(leading0)) {
    min_ndigits <- as.integer(leading0)
    sprintf(paste0("%s%.", ndigits(n, min_ndigits), "d%s"), prefix, 1:n, suffix)
  } else {
    paste0(prefix, 1:n, suffix)
  }
}
