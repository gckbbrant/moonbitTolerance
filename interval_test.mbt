///|
test "interval arithmetic preserves conservative bounds" {
  let left = Interval::new(1.0, 2.0)
  let right = Interval::new(-3.0, 4.0)
  assert_eq(left.add(right), Interval::new(-2.0, 6.0))
  assert_eq(left.sub(right), Interval::new(-3.0, 5.0))
  assert_eq(left.mul(right), Interval::new(-6.0, 8.0))
  assert_eq(left.scale(-2.0), Interval::new(-4.0, -2.0))
  assert_true(left.contains(1.0))
  assert_true(left.contains(2.0))
  assert_true(left.intersects(Interval::new(2.0, 3.0)))
  assert_eq(
    left.intersection(Interval::new(2.0, 3.0)),
    Some(Interval::point(2.0)),
  )
}

///|
test "interval division rejects a denominator crossing zero" {
  assert_eq(Interval::new(1.0, 2.0).divide(Interval::new(-1.0, 1.0)), None)
  assert_eq(
    Interval::new(2.0, 4.0).divide(Interval::new(2.0, 4.0)),
    Some(Interval::new(0.5, 2.0)),
  )
  assert_eq(Interval::new(-2.0, 3.0).absolute(), Interval::new(0.0, 3.0))
}

///|
test "dimension chains expose interval and vector bounds" {
  let chain = Chain::new("assembly", [
    Dimension::new("base", 10.0, 0.2),
    Dimension::new("cover", 2.0, 0.1, direction=negative_direction()),
  ])
  let bounds = chain_interval(chain)
  assert_true(bounds.lower.is_close(7.7))
  assert_true(bounds.upper.is_close(8.3))
  let vector = IntervalVector2::new(
    Interval::new(3.0, 4.0),
    Interval::new(-1.0, 1.0),
  )
  assert_true(vector.magnitude_bounds().upper > 4.0)
}
