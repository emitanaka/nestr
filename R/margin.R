#' Calculate margin statistics
#'
#' @param x
#' @param f A function to evaluate for the given group.
#' @param group_by The indexing group for `f`.
#' @return A named list where name corresponds to group levels and
#' entries to the results of `f`.
#'
#'
#' @examples
#' with(PlantGrowth, margin_with(weight, sum, .group_by = group))
#' @export
margin_with <- function(.x, .f, ..., .group_by = NULL, .keyname = NULL) {
  keyname <- .keyname %||%
    tryCatch(as_string(enexpr(.group_by)), error = function(x) NULL)
  l <- split(.x, .group_by)
  res <- lapply(l, function(x) .f(x, ...))
  names(res) <- unique(.group_by)
  attr(res, "keyname") <- keyname
  res
}
