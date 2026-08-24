///|
test "engineering rounding preserves requested precision" {
  assert_true(round_to(1.234, 2, nearest_rounding()).is_close(1.23))
  assert_true(round_to(1.235, 2, nearest_rounding()).is_close(1.24))
  let rounded = round_interval(Interval::new(1.231, 1.239), 2)
  assert_eq(rounded, Interval::new(1.23, 1.24))
}
