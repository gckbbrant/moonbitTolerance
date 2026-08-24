///|
test "running statistics match batch statistics and merge correctly" {
  let first = running_statistics([1.0, 2.0, 3.0])
  let second = running_statistics([4.0, 5.0])
  let merged = first.merge(second).finish()
  let batch = summarize_samples([1.0, 2.0, 3.0, 4.0, 5.0])
  assert_eq(merged.count, batch.count)
  assert_true(merged.mean.is_close(batch.mean))
  assert_true(merged.variance.is_close(batch.variance))
  assert_eq(merged.minimum, 1.0)
  assert_eq(merged.maximum, 5.0)
}

///|
test "control limits and inspection reports expose yield" {
  let values = [9.8, 10.0, 10.1, 9.9, 10.2, 20.0]
  let baseline = [9.8, 10.0, 10.1, 9.9, 10.2]
  let limits = control_limits(baseline, sigma_multiplier=3.0)
  assert_true(limits.lower < limits.center)
  assert_true(limits.upper > limits.center)
  assert_true(!within_control_limits(12.0, limits))
  let report = inspect_batch(values, AcceptanceWindow::new(9.5, 10.5))
  assert_eq(report.accepted, 5)
  assert_eq(report.rejected, 1)
  assert_true(report.yield_rate.is_close(5.0 / 6.0))
}

///|
test "yield confidence stays within probability bounds" {
  let estimate = estimate_yield(
    [1.0, 1.1, 2.0, 1.2],
    AcceptanceWindow::new(0.0, 1.5),
  )
  assert_eq(estimate.accepted, 3)
  assert_eq(estimate.total, 4)
  assert_true(estimate.lower_bound >= 0.0)
  assert_true(estimate.upper_bound <= 1.0)
}

///|
test "tolerance allocation supports equal and weighted plans" {
  let chain = Chain::new("allocation", [
    Dimension::new("a", 10.0, 0.1),
    Dimension::new("b", 20.0, 0.3),
    Dimension::new("c", 5.0, 0.2),
  ])
  let equal = allocate_chain(chain, 0.6, equal_allocation())
  assert_true(equal.total_rss.is_close(0.6))
  assert_true(
    equal.items[0].allocated_tolerance.is_close(
      equal.items[1].allocated_tolerance,
    ),
  )
  let weighted = allocate_chain(chain, 0.6, proportional_allocation())
  assert_true(
    weighted.items[1].allocated_tolerance >
    weighted.items[0].allocated_tolerance,
  )
}
