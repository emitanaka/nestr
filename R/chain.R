
#' Link data frames as a chain
#'
#' @param ... A name-value pair where value is a data frame. The supplied
#' data frame should be linked by a key. The link is determined automatically by
#' the intersection of the column names but may be set manually by `link`.
#'
#' @examples
#' vs_info <- data.frame(engine = c(0, 1), info = c("flat", "unknown"))
#' chain(original = mtcars,
#'       vs_total = group_by(original, vs) %>%
#'                   summarise(across(everything(), sum)),
#'       vs_dict = data.frame(vs = c(0, 1), engine = c("V-shaped", "Straight")),
#'       vs_info = link(vs_info, original, .by = c(vs = "engine")))
#'
#'
#'
#' @export
chain <- function(..., .class = NULL) {
  dots <- enquos(...)
  dots_names <- names(dots)
  auto_named_dots <- names(enquos(..., .named = TRUE))

  if (length(dots) == 0L) {
    return(NULL)
  }

  out <- list()
  for(i in seq_along(dots)) {
    not_named <- (is.null(dots_names) || dots_names[i] == "")
    name <- if (not_named) auto_named_dots[i] else dots_names[i]
    out[[name]] <- eval_tidy(dots[[i]], out)
  }
  class(out) <- c(.class, "chain", class(out))
  out
}


#' @export
link <- function(.data, ..., .by = NULL) {
  dots <- enquos(...)
  dots_names <- names(dots)
  link <- list()
  link[dots_names] <- .by
  attr(.data, "link") <- link
  .data
}


#' @importFrom dplyr select
#' @export
select.chain <- function(.chain, .df, ...) {
  loc_data <- tidyselect::eval_select(rlang::enexpr(.df), .chain)
  data_names <- names(loc_data)
  subchain <- rlang::set_names(.chain[loc_data], data_names)
  dots <- enquos(...)
  if(length(dots) > 0L) {
    for(aname in data_names) {
      .data <- subchain[[aname]]
      loc <- tidyselect::eval_select(rlang::expr(c(...)), .data)
      subchain[[aname]] <- rlang::set_names(.data[loc], names(loc))
    }
  }
  subchain
}

