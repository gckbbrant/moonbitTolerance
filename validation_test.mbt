///|
test "preflight validation returns host-friendly reports" {
  let chain = Chain::new("valid", [Dimension::new("x", 1.0, 0.1)])
  let chain_report = validate_chain(chain)
  assert_true(chain_report.valid)
  let measurement_report = validate_measurements(
    [1.0, 1.1],
    AcceptanceWindow::new(0.0, 2.0),
  )
  let combined = combine_validation(chain_report, measurement_report)
  assert_true(combined.valid)
  assert_eq(combined.issue_count, 0)
}
