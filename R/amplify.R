#' Create or modify a column with nesting structure
#'
#' @param .data An object with the data.
#' @param ... Name-value pairs.
#'
#' @export
amplify <- function(.data, ...) {
  UseMethod("amplify")
}

#' @export
amplify.data.frame <- function(.data, ...,
                               .keep = c("all", "used", "unused", "none"),
                               .before = NULL, .after = NULL) {
  keep <- match.arg(.keep)

  out <- amplify_data(.data, ...)

  .before <- enquo(.before)
  .after <- enquo(.after)
  if (!quo_is_null(.before) || !quo_is_null(.after)) {
    new <- setdiff(names(cols), names(.data))
    out <- relocate(out, !!new, .before = !!.before, .after = !!.after)
  }
}


# Helpers -----------------------------------------------------------------


amplify_cols <- function(.data, ...) {
  dots <- enquos(...)
  dots_names <- names(dots)
  auto_named_dots <- names(enquos(..., .named = TRUE))
  if (length(dots) == 0L) {
    return(NULL)
  }

  new_data <- .data

  for(i in seq_along(dots)) {
    res <- eval_tidy(dots[[i]], new_data)
    not_named <- (is.null(dots_names) || dots_names[i] == "")
    name <- if (not_named) auto_named_dots[i] else dots_names[i]
    names(res)[2] <- name
    new_data <- merge(new_data, res, by = names(res)[1])
  }
  new_data
}

