///|
test "projection and constraints cover boundaries" {
  let projected = project_chain([
    ProjectedDimension::new("x", Vector2::new(10.0, 0.0), 0.1),
    ProjectedDimension::new("y", Vector2::new(0.0, 5.0), 0.2),
  ])
  assert_eq(projected.nominal, Vector2::new(10.0, 5.0))
  assert_true(projected.lower_x < projected.upper_x)
  let vector = Vector2::new(3.0, 4.0)
  assert_eq(vector.sub(Vector2::new(1.0, 2.0)), Vector2::new(2.0, 2.0))
  assert_eq(vector.scale(2.0), Vector2::new(6.0, 8.0))
  assert_eq(vector.dot(vector), 25.0)
  assert_eq(vector.length_squared(), 25.0)
  assert_eq(vector.length(), 5.0)
  assert_eq(Vector2::zero().normalize(), Vector2::zero())
  assert_true(vector.normalize().length() > 0.99)
  assert_true(project_direction(0.0).x > 0.99)
  assert_eq(project_signed(2.0, 0.0).x, 2.0)
  let chain = Chain::new("fit", [Dimension::new("a", 1.0, 0.1)])
  let report = evaluate_constraints(chain.worst_case(), [
    GapConstraint::new("ok", 0.0, 2.0),
  ])
  assert_eq(report.passed, 1)
  assert_eq(report.failed, 0)
  let failed = evaluate_constraints(chain.worst_case(), [
    GapConstraint::new("bad", 2.0, 3.0),
  ])
  assert_eq(failed.failed, 1)
  let mixed = evaluate_constraints(chain.worst_case(), [
    GapConstraint::new("mixed", 0.95, 1.05),
  ])
  assert_eq(mixed.inconclusive, 1)
  assert_true(interval_contains(chain.worst_case(), 1.0))
  assert_true(
    interval_width(chain.worst_case()) > 0.1999 &&
    interval_width(chain.worst_case()) < 0.2001,
  )
  assert_true(result_to_csv(chain.worst_case()).length() > 20)
}

///|
test "distribution and capability edge behavior" {
  let uniform = SamplingPolicy::new()
  assert_eq(sample_deviation(uniform, 0.0, 2.0), -2.0)
  assert_eq(sample_deviation(uniform, 1.0, 2.0), 2.0)
  let triangular = triangular_policy()
  let normal = normal_approximation_policy()
  assert_eq(sample_deviation(uniform, -1.0, 2.0), -2.0)
  assert_eq(sample_deviation(uniform, 2.0, 2.0), 2.0)
  assert_true(sample_deviation(triangular, 0.25, 2.0) < 0.0)
  assert_true(sample_deviation(triangular, 0.5, 2.0).abs() < 0.0001)
  assert_true(sample_deviation(normal, 0.5, 2.0).abs() < 0.0001)
  let (_, unit) = deterministic_uniform(42U)
  assert_true(unit >= 0.0 && unit <= 1.0)
  let capability = ProcessCapability::new(9.0, 11.0, 10.0, 0.1)
  assert_true(capability.cp() > 3.3)
  assert_true(capability.cpk() > 3.3)
  let off_center = ProcessCapability::new(9.0, 11.0, 9.2, 0.1)
  assert_true(off_center.cpk() < off_center.cpu())
}

///|
test "nominal and projected input paths" {
  let chain = Chain::new("signed", [
    Dimension::new("plus", 4.0, 0.2),
    Dimension::new("minus", 1.5, 0.1, direction=negative_direction()),
  ])
  assert_eq(chain.nominal(), 2.5)
  let projected = project_chain([
    ProjectedDimension::new("p", Vector2::new(1.0, 1.0), 0.0),
  ])
  assert_eq(projected.radial_tolerance, 0.0)
}

///|
test "benchmark suite is reproducible" {
  for case in benchmark_suite() {
    let first = run_acceptance_benchmark_case(case, 256)
    let second = run_acceptance_benchmark_case(case, 256)
    assert_eq(first.mean, second.mean)
    assert_eq(first.yield_rate, second.yield_rate)
    assert_true(first.yield_rate >= 0.0 && first.yield_rate <= 1.0)
  }
}
