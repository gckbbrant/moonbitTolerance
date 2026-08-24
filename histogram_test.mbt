///|
test "histogram bins are deterministic and conserve samples" {
  let histogram = histogram([0.0, 0.1, 0.2, 0.8, 0.9, 1.0], 4)
  assert_eq(histogram.total, 6)
  assert_eq(histogram.bins.length(), 4)
  assert_eq(histogram.counted_samples(), 6)
  assert_true(histogram.cumulative_fraction(0.2) > 0.0)
  assert_true(histogram.percentile(0.5) >= 0.2)
}

///|
test "constant histograms remain useful" {
  let histogram = histogram([2.0, 2.0, 2.0], 3)
  assert_eq(histogram.total, 3)
  assert_eq(histogram.counted_samples(), 3)
  assert_eq(histogram.percentile(0.5), 2.0)
}
