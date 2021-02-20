test_that("nesting", {
  expect_equal(nest_in(1:3,
                       1 ~ 3,
                       . ~ 2),
               list(`1` = as.character(1:3),
                    `2` = as.character(1:2),
                    `3` = as.character(1:2)))

  expect_equal(nest_in(c(1:3, 2:3),
                       1 ~ 3,
                       . ~ 2),
               list(`1` = as.character(1:3),
                    `2` = as.character(1:2),
                    `3` = as.character(1:2),
                    `2` = as.character(1:2),
                    `3` = as.character(1:2)))

  expect_equal(nest_in(c("A", "B", "C"),
                       1 ~ 3,
                       . ~ 2),
               list(A = as.character(1:3),
                    B = as.character(1:2),
                    C = as.character(1:2)
               ))

  expect_equal(nest_in(c("A", "B", "C"),
                       "B" ~ 3,
                       . ~ 2),
               list(A = as.character(1:2),
                    B = as.character(1:3),
                    C = as.character(1:2)
               ))

  expect_equal(nest_in(c("A", "B", "C"),
                       1 ~ 10,
                       . ~ 2),
               list(A = as.character(1:10),
                    B = as.character(1:2),
                    C = as.character(1:2)
               ))

  expect_equal(nest_in(c("A", "B", "C"),
                       1 ~ 10,
                       . ~ 2, leading0 = TRUE),
               list(A = sprintf("%.2d", c(1:10)),
                    B = sprintf("%.2d", c(1:2)),
                    C = sprintf("%.2d", c(1:2))
               ))

  expect_equal(nest_in(c("A", "B", "C"),
                       1 ~ 10,
                       . ~ 2, leading0 = 4),
               list(A = sprintf("%.4d", c(1:10)),
                    B = sprintf("%.4d", c(1:2)),
                    C = sprintf("%.4d", c(1:2))
               ))

  expect_equal(nest_in(c("A", "B", "C"),
                       1 ~ 10,
                       . ~ 2, leading0 = 4,
                       suffix = "test", prefix = "pre"),
               list(A = sprintf("pre%.4dtest", c(1:10)),
                    B = sprintf("pre%.4dtest", c(1:2)),
                    C = sprintf("pre%.4dtest", c(1:2))
               ))

  expect_equal(nest_in(2:4,
                       1 ~ 3,
                       2 ~ 4,
                       3 ~ 2),
               list(`2` = as.character(1:3),
                    `3` = as.character(1:4),
                    `4` = as.character(1:2))
               )
})
