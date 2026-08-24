///|
test "two-dimensional transforms compose and invert" {
  let transform = Transform2::new(
    Matrix2::rotation(1.5707963267948966),
    Vector2::new(2.0, 3.0),
  )
  let point = transform.apply(Vector2::new(1.0, 0.0))
  assert_true(point.x.is_close(2.0))
  assert_true(point.y.is_close(4.0))
  let recovered = transform.inverse().unwrap().apply(point)
  assert_true(recovered.x.is_close(1.0))
  assert_true(recovered.y.is_close(0.0))
}

///|
test "correlation terms adjust RSS uncertainty" {
  let dimensions = [
    Dimension::new("x", 1.0, 0.2),
    Dimension::new("y", 1.0, 0.3),
  ]
  let report = correlated_rss(dimensions, [CorrelationTerm::new(0, 1, 0.5)])
  assert_true(report.standard_deviation > 0.3)
  assert_true(report.standard_deviation < 0.5)
}
