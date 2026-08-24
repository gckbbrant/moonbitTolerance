///|
test "sample planning returns a conservative positive plan" {
  let plan = sample_plan(0.95, 0.02, 1.96)
  assert_true(plan.samples > 100)
  assert_true(plan.expected_half_width <= 0.02)
  assert_true(plan.confidence > 0.94 && plan.confidence < 0.96)
}

///|
test "feasibility report compares worst case and RSS margins" {
  let chain = Chain::new("feasible", [
    Dimension::new("a", 10.0, 0.1),
    Dimension::new("b", 5.0, 0.1),
  ])
  let report = feasibility_report(chain, AcceptanceWindow::new(14.5, 15.5))
  assert_true(report.worst_case_margin > 0.0)
  assert_true(report.rss_margin > 0.0)
  assert_true(report.worst_case_passes)
}
