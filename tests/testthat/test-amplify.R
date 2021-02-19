test_that("amplify", {

  expect_equal(amplify(data.frame(x = 1:2) , y = nest_in(x, 3)),
               data.frame(x = rep(1:2, each = 3),
                          y = as.character(rep(1:3, times = 2))))

  expect_equal(amplify(data.frame(x = c(1, 1, 2)) , y = nest_in(x, 3)),
               data.frame(x = rep(c(1, 1, 2), each = 3),
                          y = as.character(rep(1:3, times = 3))))

})
