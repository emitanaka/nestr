
#' Create a nested structure
#'
#' This function results in a two column data frame with nested structure.
#' Currently only one parent is supported and child is only specified by
#' giving the number of levels. (This will change shortly).
#'
#' @param x A vector where each entry is a parent.
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
#' @param prefix The prefix for the child labels.
#' @param suffix The suffix for the child labels.
#' @param leading0 By default it is `FALSE`. If `TRUE`, this is the
#'  same as setting `0` or `1`. If a positive integer is
#'  specified then it corresponds to the minimum number of digits
#'  for the child labels and there will be leading zeros augmented so
#'  that the minimum number is met.
#' @param distinct A logical value to indicate whether the child labels
#'  across parents should be distinct.
#' @param compact A logical value to indicate whether the returned list
#'  should be a compact representation or not. Ignored if distinct is `TRUE`
#'  since it's not possible to make compact representation if unit labels
#'  are all distinct.
#'
#' @return A list with the first entry corresponding to
#'  parental levels and the second entry corresponding to the child levels.
#'
#' @examples
#' # Each element in the supplied the vector has 4 child.
#' nest_in(1:3, 4)
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
nest_in <- function(x, ...,
                    prefix = NULL, suffix = NULL,
                    distinct = FALSE, leading0 = FALSE,
                    compact = FALSE) {
  dots <- enquos(...)
  levels <- as.character(unique(x))
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

  if(distinct) {
      out <- split(make_labels(leading0, sum(reps), prefix, suffix),
                   rep(levels, reps))
  } else {
    labels <- make_labels(leading0, max(reps), prefix, suffix)
    if(compact) {
      out <- lapply(reps, function(n) labels[1:n])
      names(out) <- levels
      attr(out, "order") <- match(x, levels)
      class(out) <- c("clist", class(out))
    } else {
      out <- lapply(reps[as.character(x)], function(n) labels[1:n])
      names(out) <- as.character(x)
    }
  }
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
