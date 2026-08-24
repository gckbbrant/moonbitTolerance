///|
test "scenario workflows expose comparable analysis outcomes" {
  let chain = Chain::new("workflow", [
    Dimension::new("a", 10.0, 0.1),
    Dimension::new("b", 5.0, 0.2),
  ])
  let window = AcceptanceWindow::new(14.5, 15.5)
  let rss = run_scenario(
    ScenarioSpec::new("rss", chain, rss_method(), 128, window),
  )
  let monte = run_scenario(
    ScenarioSpec::new("monte", chain, monte_carlo_method(), 128, window),
  )
  assert_eq(rss.name, "rss")
  assert_true(rss.standard_deviation > 0.0)
  let comparison = compare_scenarios(rss, monte)
  assert_true(comparison.nominal_delta.is_close(0.0))
}

///|
test "measurement studies separate repeatability and reproducibility" {
  let report = gauge_rr(
    [10.0, 10.1, 10.0, 10.2, 10.3, 10.2, 9.9, 10.0],
    2,
    2,
    2,
    1.0,
  )
  assert_eq(report.total_measurements, 8)
  assert_true(report.repeatability >= 0.0)
  assert_true(report.reproducibility >= 0.0)
  let bias = measurement_bias([9.9, 10.0, 10.1], 10.0)
  assert_true(bias.bias.abs() < 0.001)
}

///|
test "tightening plan ranks the highest variance contributors" {
  let chain = Chain::new("plan", [
    Dimension::new("low", 1.0, 0.1),
    Dimension::new("high", 1.0, 0.4),
    Dimension::new("medium", 1.0, 0.2),
  ])
  let plan = propose_tightening(chain, 0.3, 2)
  assert_eq(plan.length(), 2)
  assert_eq(plan[0].name, "high")
  assert_true(plan[0].expected_reduction > 0.0)
}

///|
test "process performance and outlier reports are actionable" {
  let values = [9.9, 10.0, 10.1, 10.0, 11.0]
  let report = process_performance(values, AcceptanceWindow::new(9.5, 10.5))
  assert_eq(report.accepted, 4)
  assert_eq(report.rejected, 1)
  let outliers = outlier_indices(values, 9.95, 10.2)
  assert_eq(outliers, [0, 4])
}

///|
test "uncertainty budgets preserve contributor fractions" {
  let budget = uncertainty_budget([
    UncertaintySource::new("fixture", 0.1, 1.0),
    UncertaintySource::new("gauge", 0.2, 1.0),
  ])
  assert_true(
    budget.combined.is_close(0.2236067977, absolute_tolerance=0.000000001),
  )
  assert_true(budget.contributors[1].fraction > budget.contributors[0].fraction)
}
