///|
test "allocation, fit requirements, and uncertainty helpers cover edge paths" {
  let chain = Chain::new("edges", [
    Dimension::new("a", 10.0, 0.1),
    Dimension::new("b", 10.0, 0.2),
  ])
  let sensitivity = sensitivity_tolerance_for_budget(chain, 0.2)
  assert_true(sensitivity.largest_contributor().allocated_tolerance > 0.0)
  assert_true(sensitivity.interval().contains(20.0))
  let equal = equal_tolerance_for_budget(chain, 0.0)
  assert_eq(equal.total_rss, 0.0)
  let fit = analyze_fit(
    Dimension::new("hole", 10.2, 0.05),
    Dimension::new("shaft", 10.0, 0.03),
  )
  assert_true(fit.guarantees_clearance(0.1))
  assert_true(fit.limits_clearance(0.3))
  let requirements = evaluate_fit_requirements(fit, [
    FitRequirement::new("pass", 0.1, 0.3),
    FitRequirement::new("overlap", 0.2, 0.3),
    FitRequirement::new("fail", 0.4, 0.5),
  ])
  assert_eq(requirements.passed, 1)
  assert_eq(requirements.inconclusive, 1)
  assert_eq(requirements.failed, 1)
  let source = UncertaintySource::new("x", 0.1, 1.0)
  let budget = uncertainty_budget([source])
  assert_true(budget.interval(5.0, 2.0).contains(5.1))
  assert_eq(budget.largest().name, "x")
  assert_eq(budget.ranked().length(), 1)
  assert_eq(uncertainty_without(budget, "x"), 0.0)
}

///|
test "numeric, matrix, histogram, and correlation edges remain bounded" {
  let interval = Interval::new(-2.0, 3.0)
  assert_eq(interval.hull(Interval::new(4.0, 5.0)), Interval::new(-2.0, 5.0))
  assert_eq(interval.midpoint(), 0.5)
  assert_eq(interval.width(), 5.0)
  assert_eq(interval.distance_to(5.0), 2.0)
  let vectors = IntervalVector2::new(interval, Interval::point(2.0)).add(
    IntervalVector2::new(Interval::point(1.0), Interval::point(-2.0)),
  )
  assert_true(vectors.magnitude_bounds().contains(0.0))
  let matrix = Matrix2::rotation(0.0)
  assert_true(matrix.is_orthonormal())
  assert_true(matrix.multiply(Matrix2::identity()).determinant().is_close(1.0))
  match Matrix2::scale(1.0, 0.0).inverse() {
    None => ()
    Some(_) => fail("singular matrix should not have an inverse")
  }
  let histogram = histogram([-1.0, 0.0, 1.0], 2)
  assert_eq(histogram.bin_for(-2.0), 0)
  assert_eq(histogram.bin_for(2.0), 1)
  assert_eq(histogram.frequency(0), 1)
  assert_eq(histogram.cumulative_fraction(-2.0), 0.0)
  assert_eq(histogram.cumulative_fraction(2.0), 1.0)
  let chain = Chain::new("corr", [
    Dimension::new("a", 1.0, 0.2),
    Dimension::new("b", 1.0, 0.3),
  ])
  assert_true(correlated_standard_deviation(chain, []).is_close(0.3605551275))
  assert_true(
    correlated_interval(chain, [CorrelationTerm::new(0, 1, -0.2)], 3.0).width() >
    0.0,
  )
}

///|
test "inspection, trend, scenario, specification, and reporting edges" {
  let values = [9.8, 10.0, 10.1, 10.0]
  let limits = control_limits(values)
  assert_eq(control_limit_violations([9.0, 10.0, 11.0], limits), 2)
  let merged = RunningStatistics::new()
    .merge(running_statistics(values))
    .finish()
  assert_eq(merged.count, 4)
  assert_true(mean_absolute_error(values, 10.0) > 0.0)
  assert_true(measurement_yield(values, AcceptanceWindow::new(9.9, 10.1)) > 0.0)
  let trend = linear_trend([1.0, 2.0, 3.0, 4.0])
  assert_true(trend.slope.is_close(1.0))
  assert_eq(moving_average([1.0, 2.0, 3.0], 2), [1.5, 2.5])
  assert_true(
    defects_per_million(
      process_performance([1.0, 2.0], AcceptanceWindow::new(0.0, 1.5)),
    ) >
    0.0,
  )
  assert_true(
    centering_margin(10.0, AcceptanceWindow::new(9.0, 11.0)).is_close(1.0),
  )
  let chain = Chain::new("reports", [Dimension::new("x", 10.0, 0.1)])
  let window = AcceptanceWindow::new(9.5, 10.5)
  let scenario = run_scenario(
    ScenarioSpec::new("scenario", chain, worst_case_method(), 8, window),
  )
  assert_true(scenario.within_window(window))
  assert_true(scenario.interval().contains(10.0))
  assert_true(scenario_to_csv(scenario).contains("name,nominal"))
  assert_true(
    histogram_to_csv(histogram(values, 2)).contains("lower,upper,count"),
  )
  assert_true(
    fit_to_csv(
      analyze_fit(Dimension::new("h", 2.0, 0.1), Dimension::new("s", 1.0, 0.1)),
    ).contains("hole_nominal"),
  )
  let specification = Specification::new(9.0, 11.0, 10.0)
  assert_true(specification.window().contains(10.0))
  assert_true(specification.contains(10.0))
  assert_true(specification_report_placeholder(specification))
}

///|
fn specification_report_placeholder(specification : Specification) -> Bool {
  let report = evaluate_specification([9.0, 10.0, 11.0], specification)
  report.accepted == 3
}

///|
test "units, rounding, validation, and CSV adapters stay deterministic" {
  let length = Length::from_millimeters(2.0)
  let tolerance = LengthTolerance::symmetric(
    length,
    Length::from_micrometers(100.0),
  )
  assert_true(tolerance.interval().contains(2.0))
  assert_true(length.add(Length::from_inches(1.0)).to_inches() > 1.0)
  assert_true(
    length
    .sub(Length::from_millimeters(1.0))
    .scale(2.0)
    .to_millimeters()
    .is_close(2.0),
  )
  let angle = Angle::from_degrees(45.0).add(Angle::from_degrees(45.0))
  assert_true(angle.direction().x.is_close(0.0, absolute_tolerance=0.000000001))
  assert_eq(round_to(-1.235, 2, nearest_rounding()), -1.24)
  assert_eq(round_to(1.239, 2, down_rounding()), 1.23)
  assert_eq(round_to(1.231, 2, up_rounding()), 1.24)
  assert_eq(round_to(-1.239, 2, toward_zero_rounding()), -1.23)
  assert_eq(round_values([1.234, 2.345], 2, nearest_rounding()), [1.23, 2.35])
  let rounded = round_statistics(summarize_samples([1.234, 2.345]), 2)
  assert_eq(rounded.count, 2)
  let chain_report = validate_chain(
    Chain::new("v", [Dimension::new("x", 1.0, 0.1)]),
  )
  let window_report = validate_window(AcceptanceWindow::new(0.0, 1.0))
  let empty_report = validate_measurements([], AcceptanceWindow::new(0.0, 1.0))
  assert_true(chain_report.valid && window_report.valid && !empty_report.valid)
  let allocation = allocate_chain(
    Chain::new("a", [Dimension::new("x", 1.0, 0.1)]),
    0.1,
    equal_allocation(),
  )
  assert_true(allocation_to_csv(allocation).contains("allocated_tolerance"))
  let uncertainty = uncertainty_budget([UncertaintySource::new("x", 0.1, 1.0)])
  assert_true(uncertainty_to_csv(uncertainty).contains("effective_uncertainty"))
}
