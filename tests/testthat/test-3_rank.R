test_that("ranking algorithm", {
  # row _id:63547e354f042e0713951435
  r <-
    data.frame(
      sidewalk = '有設置人行道或騎樓',
      protective = '實體人行道(有實體分隔)',
      wheelchair = '輪椅可以通行（寬於100公分）',
      walkRisk = '有機車行駛',
      occupation = ''
    )
  expect_equal(a1(convert_score(r, 'a1')), 6.4)
  expect_equal(b1(convert_score(r, 'b1')), 4)
  expect_equal(c1(convert_score(r, 'c1')), 4)

  # row _id: 6354c5fd4f042e221695143d
  r <-
    data.frame(
      sidewalk = '有人行道或騎樓',
      protective = '實體人行道(有實體分隔)',
      wheelchair = '輪椅無法通行（窄於100公分）',
      walkRisk = '有機車行駛',
      occupation = ''
    )
  expect_equal(a1(convert_score(r, 'a1')), 5.4)
  expect_equal(b1(convert_score(r, 'b1')), 1.5)
  expect_equal(c1(convert_score(r, 'c1')), 2)
  
  # row _id: 635744264f042eaeec951455
  r <-
    data.frame(
      sidewalk = '有設置人行道或騎樓',
      protective = '實體人行道(有實體分隔)',
      wheelchair = '輪椅可以通行（寬於100公分）',
      walkRisk = '無車輛行駛',
      occupation = ''
    )
  expect_equal(a1(convert_score(r, 'a1')), 10)
  expect_equal(b1(convert_score(r, 'b1')), 10)
  expect_equal(c1(convert_score(r, 'c1')), 10)

  # row _id: 6357cc384f042e1e31951479
  r <-
    data.frame(
      sidewalk = '沒有設置人行道或騎樓',
      protective = '沒有人行道或騎樓',
      wheelchair = '沒有人行道或騎樓',
      walkRisk = '有汽車行駛',
      occupation = '沒有人行道或騎樓'
    )
  expect_equal(a1(convert_score(r, 'a1')), 0)
  expect_equal(b1(convert_score(r, 'b1')), -10)
  expect_equal(c1(convert_score(r, 'c1')), 0)

  # row _id: 6382fe51d8489c725f0a598e
  r <-
    data.frame(
      sidewalk = '有設置人行道或騎樓',
      protective = '騎樓',
      wheelchair = '輪椅無法通行（窄於100公分）',
      walkRisk = '有機車行駛',
      occupation = '私人佔用（臨時停車）'
    )
  expect_equal(a1(convert_score(r, 'a1')), 4.2)
  expect_equal(b1(convert_score(r, 'b1')), -4.5)
  expect_equal(c1(convert_score(r, 'c1')), 0.8)
})
