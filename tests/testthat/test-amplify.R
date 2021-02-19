test_that("amplify", {
  data.frame(x = 1:2) %>%
    amplify(y = nest_in(x, 3))
})
