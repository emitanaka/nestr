# From dplyr::relocate
.relocate <- function(.data, ..., .before = NULL, .after = NULL) {
  to_move <- unname(tidyselect::eval_select(expr(c(...)), .data))

  .before <- enquo(.before)
  .after <- enquo(.after)
  has_before <- !quo_is_null(.before)
  has_after <- !quo_is_null(.after)

  if (has_before && has_after) {
    abort("Must supply only one of `.before` and `.after`")
  } else if (has_before) {
    where <- min(unname(tidyselect::eval_select(.before, .data)))
    to_move <- c(setdiff(to_move, where), where)
  } else if (has_after) {
    where <- max(unname(tidyselect::eval_select(.after, .data)))
    to_move <- c(where, setdiff(to_move, where))
  } else {
    where <- 1L
    to_move <- union(to_move, where)
  }

  lhs <- setdiff(rlang::seq2(1, where - 1), to_move)
  rhs <- setdiff(rlang::seq2(where + 1, ncol(.data)), to_move)

  .data[vec_unique(c(lhs, to_move, rhs))]
}
