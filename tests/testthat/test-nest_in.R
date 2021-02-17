test_that("nesting", {
  nest_in(1:3,
          1 ~ 3,
          . ~ 2)
})
