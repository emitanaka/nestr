test_that("nesting", {
  expect_equal(nest_in(1:3,
                       1 ~ 3,
                       . ~ 2),
               data.frame(parent = rep(1:3, c(3, 2, 2)),
                          child = as.character(c(1, 2, 3, 1, 2, 1, 2))))

  expect_equal(nest_in(c("A", "B", "C"),
                       1 ~ 3,
                       . ~ 2),
               data.frame(parent = rep(c("A", "B", "C"), c(3, 2, 2)),
                          child = as.character(c(1, 2, 3, 1, 2, 1, 2))))

  expect_equal(nest_in(c("A", "B", "C"),
                       "B" ~ 3,
                       . ~ 2),
               data.frame(parent = rep(c("A", "B", "C"), c(2, 3, 2)),
                          child = as.character(c(1, 2, 1, 2, 3, 1, 2))))

  expect_equal(nest_in(c("A", "B", "C"),
                       1 ~ 10,
                       . ~ 2),
               data.frame(parent = rep(c("A", "B", "C"), c(10, 2, 2)),
                          child = as.character(c(1:10, 1, 2, 1, 2))))

  expect_equal(nest_in(c("A", "B", "C"),
                       1 ~ 10,
                       . ~ 2, leading0 = TRUE),
               data.frame(parent = rep(c("A", "B", "C"), c(10, 2, 2)),
                          child = sprintf("%.2d", c(1:10, 1, 2, 1, 2))))

  expect_equal(nest_in(c("A", "B", "C"),
                       1 ~ 10,
                       . ~ 2, leading0 = TRUE, min_ndigits = 4),
               data.frame(parent = rep(c("A", "B", "C"), c(10, 2, 2)),
                          child = sprintf("%.4d", c(1:10, 1, 2, 1, 2))))

  expect_equal(nest_in(c("A", "B", "C"),
                       1 ~ 10,
                       . ~ 2, leading0 = TRUE, min_ndigits = 4,
                       suffix = "test", prefix = "pre"),
               data.frame(parent = rep(c("A", "B", "C"), c(10, 2, 2)),
                          child = sprintf("pre%.4dtest", c(1:10, 1, 2, 1, 2))))

  expect_equal(nest_in(c("A", "B", "C"),
                       1 ~ 10, prefix = "student",
                       . ~ 2, name = "student", name_parent = "class"),
               data.frame(class = rep(c("A", "B", "C"), c(10, 2, 2)),
                          student = sprintf("student%d", c(1:10, 1, 2, 1, 2))))
})
