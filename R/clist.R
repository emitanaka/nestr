#' @export
format.clist <- function(x, ..., dict = FALSE) {
  class(x) <- setdiff(class(x), "clist")
  if(dict) {
    x
  } else {
    order <- attr(x, "order")
    x[order]
  }
}

#' @export
print.clist <- function(x, ...) {
  print(format(x, ...))
}

#str.clist <- function(x, ...) {
#  str(format(x), ...)
#}

#' @export
`[.clist` <- function(x, i, ...) {
  iorder <- attr(x, "order")[i]
  format(x, dict = TRUE)[iorder]
}

#' @export
`[[.clist` <- function(x, i, ...) {
  iorder <- attr(x, "order")[i]
  format(x, dict = TRUE)[[iorder]]
}


#' @export
`[<-.clist` <- function(x, i, ..., value) {
  res <- format(x)
  res[i] <- value
  res
}

#' @export
`[[<-.clist` <- function(x, i, ..., value) {
  res <- format(x)
  res[[i]] <- value
  res
}

#' @export
as.list.clist <- function(x, ...) {
  format(x)
}

#' @export
length.clist <- function(x, ...) {
  length(attr(x, "order"))
}
