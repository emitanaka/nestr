
#' Create a nested structure
#'
#' This function results in a two column data frame with nested structure.
#' Currently only one parent is supported and child is only specified by
#' giving the number of levels. (This will change shortly).
#'
#' @param x A vector where each entry is the level of a parent. It may
#' be a factor or character. If character, levels are ordered alphanumerically.
#' @param ... A single integer, character vector or sequence of
#'  two-sided formula. If a single integer or character vector then each parent will have
#'  children specified by the given value. If it is sequence of two-sided formula, then the left hand
#'  side (LHS) specifies the level as an integer or character. E.g. `1`
#'  means the first level of the parent vector. If it is a
#'  character then it is assumed that it corresponds to the label of
#'  the parental level. Vector is supported for LHS.
#'  The right hand side (RHS) can only be an integer or a character vector.
#' @param prefix The prefix for the child labels.
#' @param suffix The suffix for the child labels.
#' @param leading0 By default it is `FALSE`. If `TRUE`, this is the
#'  same as setting `0` or `1`. If a positive integer is
#'  specified then it corresponds to the minimum number of digits
#'  for the child labels and there will be leading zeros augmented so
#'  that the minimum number is met.
#' @param distinct A logical value to indicate whether the child labels
#'  across parents should be distinct. The labels are only
#'  distinct if the RHS of the formula is numeric.
#' @param compact A logical value to indicate whether the returned list
#'  should be a compact representation or not. Ignored if distinct is `TRUE`
#'  since it's not possible to make compact representation if unit labels
#'  are all distinct.
#' @param keyname The name of the parent variable. It's usually the key
#' that connects the output to another table.
#'
#' @importFrom rlang is_formula
#' @return A named list where the entry corresponding to the child levels
#' and the names correspond to parental levels.
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
                    prefix = "", suffix = "",
                    distinct = FALSE, leading0 = FALSE,
                    compact = TRUE, keyname = NULL) {

  keyname <- keyname %||%
    tryCatch(as_string(enexpr(x)), error = function(x) NULL)


  fs <- list2(...)
  n <- length(fs)

  if(n==0) {
    abort("No nesting structure specified.")
  }

  levels <- levels(x) %||% as.character(unique(x))
  m <- length(levels)
  done <- rep(FALSE, m)
  reps <- vector(mode = "list", length = m)
  names(reps) <- levels

  if(n==1L && !is_formula(fs[[1L]])) {
    reps[levels] <- list(fs[[1L]])
  } else {
    for(i in seq_along(fs)) {
      pair <- eval_formula(fs[[i]], caller_env())
      if(is_symbol(pair$lhs, name = ".")) {
        reps[levels[!done]] <- list(pair$rhs)
      } else {
        igroup <- switch(class(pair$lhs),
                         integer = pair$lhs,
                         numeric = pair$lhs,
                         character = match(pair$lhs, levels),
                         abort("LHS currently needs to be integer, numeric, or character"))
        reps[igroup] <- list(pair$rhs)
        done[igroup] <- TRUE
      }
    }
  }

  numeric_units <- unlist(reps[sapply(reps, is.numeric)]) %||% 0
  non_numeric_units_list <- reps[sapply(reps, function(x) !is.numeric(x))]
  if(distinct) {
    # distinct only if RHS is numeric
    total_numeric_units <- sum(numeric_units)
    out <- split(make_labels(total_numeric_units, leading0, prefix, suffix),
                   rep(names(numeric_units), numeric_units))
    out <- c(out, non_numeric_units_list)
    out <- out[levels]
  } else {
    labels <- make_labels(max(numeric_units), leading0, prefix, suffix)
    if(compact) {
        out <- lapply(numeric_units, function(n) labels[1:n])
        out <- c(out, non_numeric_units_list)
        out <- out[levels]
        attr(out, "order") <- match(x, levels)
        class(out) <- c("clist", class(out))
    } else {
        out <- lapply(reps[as.character(x)], function(val) {
            if(is.numeric(val)) return(labels[1:val])
            val
          })
        names(out) <- as.character(x)
    }
  }

  attr(out, "keyname") <- keyname
  out
}

eval_formula <- function(f, env) {
  lhs <- f_lhs(f)
  if(!is_formula(f) || is_null(lhs)) {
    abort("Input must be two-sided formula.")
  }
  env <- f_env(f) %||% env
  if(!is_symbol(lhs, name = ".")) {
    lhs <- eval_tidy(lhs, env = env)
  }
  list(lhs = lhs,
       rhs = eval_tidy(f_rhs(f), env = env))
}
