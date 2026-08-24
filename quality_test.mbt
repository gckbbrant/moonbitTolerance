///|
test "sensitivity ranking and equal RSS budget are actionable" {
  let chain = Chain::new("rank", [
    Dimension::new("small", 10.0, 0.1),
    Dimension::new("large", 2.0, 0.4),
    Dimension::new("medium", 1.0, 0.2),
  ])
  let ranked = sensitivity_items(chain.worst_case())
  assert_eq(ranked[0].name, "large")
  assert_true(ranked[0].fraction > ranked[1].fraction)
  let budget = equal_rss_budget(chain, 0.3)
  assert_eq(budget.length(), 3)
  assert_true(budget[0].1.is_close(budget[1].1))
}

///|
test "capability report combines statistics with an acceptance window" {
  let window = AcceptanceWindow::new(4.95, 5.05)
  let report = capability_report([4.98, 5.0, 5.02, 5.01, 4.99], window)
  assert_eq(report.observed_yield, 1.0)
  assert_true(report.cpk > 1.0)
  assert_eq(report.statistics.count, 5)
}

///|
test "capability report handles a zero-variance inspection batch" {
  let report = capability_report(
    [5.0, 5.0, 5.0],
    AcceptanceWindow::new(4.0, 6.0),
  )
  assert_eq(report.observed_yield, 1.0)
  assert_true(report.cp > 1.0e300)
  assert_true(capability_to_csv(report).contains("cp,cpu,cpl,cpk"))
}

///|
test "geometric tolerance checks use the selected mode" {
  let position = position_tolerance(0.5)
  let concentricity = concentricity_tolerance(0.5)
  let runout = runout_tolerance(0.5)
  match position.evaluate(Vector2::new(0.3, 0.4), Vector2::zero()) {
    Satisfied => ()
    _ => fail("position tolerance should be satisfied")
  }
  match position.evaluate(Vector2::new(0.6, 0.0), Vector2::zero()) {
    Violated => ()
    _ => fail("position tolerance should be violated")
  }
  match runout.evaluate(Vector2::new(1.4, 0.0), Vector2::new(1.0, 0.0)) {
    Satisfied => ()
    _ => fail("runout tolerance should be satisfied")
  }
  match concentricity.evaluate(Vector2::new(0.0, 0.4), Vector2::zero()) {
    Satisfied => ()
    _ => fail("concentricity tolerance should be satisfied")
  }
}

///|
test "reports are stable CSV documents" {
  let summary = Chain::new("csv", [Dimension::new("x", 1.0, 0.1)]).simulate(
    16,
    SamplingPolicy::new(seed=9U),
    AcceptanceWindow::new(0.8, 1.2),
  )
  let csv = simulation_to_csv(summary)
  assert_true(csv.contains("nominal,minimum,maximum"))
  assert_true(csv.contains("yield_rate"))
}
