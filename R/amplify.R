#' Amplify the data frame with a given structure
#'
#' The `dplyr::mutate` function modifies, deletes or creates a new column for
#' a data frame without altering the number of rows. The `amplify` function
#' can create new columns which generally increase (or amplify) the size of the
#' row dimension. The observations in other columns are duplicated.
#'
#' If you are familiar with gene replication process then you can recall these
#' functions in genetic terms; an amplified gene is a duplication of the
#' original while a mutated gene modifies the original state.
#'
#' @param .data An object with the data.
#' @param ... Name-value pairs.
#'
#' @return Returns a data frame.
#' @examples
#' df <- data.frame(x = 1:3, y = c("a", "b", "b"))
#' amplify(df, z = nest_in(y, "a" ~ 5,
#'                            "b" ~ 3))
#'
#' @export
amplify <- function(.data, ...) {
  UseMethod("amplify")
}

#' @rdname amplify
#' @param .keep,.before,.after Use to control which columns are retained and how it is ordered
#' in the output. See documentation of `dplyr::mutate` for more information.
#' @export
amplify.data.frame <- function(.data, ...,
                               .keep = c("all", "used", "unused", "none"),
                               .before = NULL, .after = NULL) {
  keep <- match.arg(.keep)

  out <- amplify_data(.data, ...)

  .before <- enquo(.before)
  .after <- enquo(.after)
  if (!quo_is_null(.before) || !quo_is_null(.after)) {
    new <- setdiff(names(out), names(.data))
    out <- .relocate(out, !!new, .before = !!.before, .after = !!.after)
  }
  out
}


# Helpers -----------------------------------------------------------------


amplify_data <- function(.data, ...) {
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
    current_names <- colnames(new_data)
    keydf <- key_data_frame(res, name)
    # if name already exists, then append
    if(name %in% current_names) {
      keydf[setdiff(current_names, names(keydf))] <- NA
      new_data <- rbind(new_data, keydf)
    } else {
      column_order <- c(current_names, name)
      # merge seems to move the "by" variable to first column
      new_data <- merge(new_data, keydf, by = attr(res, "keyname"),
                        sort = FALSE, all.x = TRUE)
      new_data <- new_data[column_order]
    }
  }
  new_data
}

key_data_frame <- function(x, name, ...) {
  keyvals <- names(x)
  keyname <- attr(x, "keyname")
  out <- list()
  out[[keyname]] <- rep(keyvals, sapply(unclass(x), length))
  out[[name]] <- unname(unlist(x))
  as.data.frame(out)
}
