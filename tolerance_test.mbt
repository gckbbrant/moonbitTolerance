///|
test "worst case and rss" {
  let chain = Chain::new("shaft", [
    Dimension::new("a", 10.0, 0.1),
    Dimension::new("b", 5.0, 0.2, direction=negative_direction()),
  ])
  let worst = chain.worst_case()
  assert_eq(worst.nominal, 5.0)
  assert_eq(worst.lower, 4.7)
  assert_eq(worst.upper, 5.3)
  let rss = chain.rss()
  assert_true(rss.standard_deviation > 0.22 && rss.standard_deviation < 0.224)
}

///|
test "monte carlo is deterministic" {
  let chain = Chain::new("fit", [Dimension::new("housing", 20.0, 0.05)])
  let a = chain.monte_carlo(200, seed=42U)
  let b = chain.monte_carlo(200, seed=42U)
  assert_eq(a.mean, b.mean)
  assert_true(a.yield_rate == 1.0)
}
