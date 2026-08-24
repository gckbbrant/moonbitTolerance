///|
test "simulation applies the selected distribution and acceptance window" {
  let chain = Chain::new("fit", [
    Dimension::new("housing", 10.0, 0.1),
    Dimension::new("cover", 5.0, 0.2, direction=negative_direction()),
  ])
  let window = AcceptanceWindow::new(4.95, 5.05)
  let policy = SamplingPolicy::new(seed=42U)
  let summary = chain.simulate(2000, policy, window)
  assert_eq(summary.samples, 2000)
  assert_true(summary.yield_rate > 0.0 && summary.yield_rate < 1.0)
  assert_true(summary.minimum < window.lower)
  assert_true(summary.maximum > window.upper)
}

///|
test "seeded distributions are reproducible and distinct" {
  let uniform = SamplingPolicy::new(seed=7U)
  let triangular = triangular_policy(seed=7U)
  let normal = normal_approximation_policy(seed=7U)
  let u = sample_sequence(uniform, 32, 0.1)
  let t = sample_sequence(triangular, 32, 0.1)
  let n = sample_sequence(normal, 32, 0.1)
  assert_eq(u, sample_sequence(uniform, 32, 0.1))
  assert_true(u != t)
  assert_true(t != n)
  assert_eq(sample_sequence(uniform, 0, 0.1).length(), 0)
}

///|
test "statistics expose quantiles and stable variance" {
  let statistics = summarize_samples([1.0, 2.0, 3.0, 4.0, 5.0])
  assert_eq(statistics.count, 5)
  assert_eq(statistics.mean, 3.0)
  assert_true(
    statistics.standard_deviation.is_close(
      1.41421356237,
      absolute_tolerance=0.000000001,
    ),
  )
  assert_eq(statistics.minimum, 1.0)
  assert_eq(statistics.maximum, 5.0)
  assert_eq(quantile([1.0, 2.0, 3.0, 4.0, 5.0], 0.5), 3.0)
  assert_eq(quantile([1.0, 2.0, 3.0, 4.0, 5.0], 0.0), 1.0)
  assert_eq(quantile([1.0, 2.0, 3.0, 4.0, 5.0], 1.0), 5.0)
  assert_eq(quantile([1.0, 2.0, 3.0, 4.0, 5.0], 0.25), 2.0)
}

///|
test "covariance propagation follows projected dimensions" {
  let dimensions = [
    ProjectedDimension::new("x", Vector2::new(1.0, 0.0), 0.2),
    ProjectedDimension::new("y", Vector2::new(0.0, 1.0), 0.3),
  ]
  let covariance = covariance_of(dimensions)
  assert_true(covariance.xx.is_close(0.04))
  assert_true(covariance.yy.is_close(0.09))
  assert_true(covariance.xy.is_close(0.0))
  assert_true(
    projected_standard_deviation(covariance, Vector2::new(1.0, 1.0)) > 0.3,
  )
}
