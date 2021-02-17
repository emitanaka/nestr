test_that("amplify", {
  data.frame(x = 1:2) %>%
    amplify(y = nested_in(x, 3))
})
