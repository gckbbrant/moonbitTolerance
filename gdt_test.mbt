///|
test "datum frames and feature control evaluation are explicit" {
  let frame = DatumFrame::new(
    DatumReference::new("A", 1),
    DatumReference::new("B", 2),
    DatumReference::new("C", 3),
  )
  assert_true(frame.is_complete())
  assert_eq(frame.label(), "A|B|C")
  let control = FeatureControlFrame::position(0.5, frame)
  let result = evaluate_feature(
    control,
    FeatureMeasurement::new(
      "hole-axis",
      Vector2::zero(),
      Vector2::new(0.3, 0.4),
    ),
  )
  match result.status {
    Satisfied => ()
    _ => fail("feature position should be satisfied")
  }
  assert_true(result.margin.is_close(0.0))
}

///|
test "geometric report evaluates several measured features" {
  let frame = DatumFrame::single(DatumReference::new("A", 1))
  let controls = [
    FeatureControlFrame::position(0.2, frame),
    FeatureControlFrame::runout(0.1, frame),
  ]
  let measurements = [
    FeatureMeasurement::new("f1", Vector2::zero(), Vector2::new(0.1, 0.0)),
    FeatureMeasurement::new(
      "f2",
      Vector2::new(1.0, 0.0),
      Vector2::new(1.08, 0.0),
    ),
  ]
  let report = evaluate_features(controls, measurements)
  assert_eq(report.total, 2)
  assert_eq(report.passed, 2)
  assert_eq(report.failed, 0)
}
