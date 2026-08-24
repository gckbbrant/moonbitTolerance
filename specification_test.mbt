///|
test "specifications classify measurements and retain margins" {
  let spec = Specification::new(9.5, 10.5, 10.0)
  match spec.classify(9.0) {
    BelowLower => ()
    _ => fail("measurement below lower specification was not classified")
  }
  match spec.classify(11.0) {
    AboveUpper => ()
    _ => fail("measurement above upper specification was not classified")
  }
  assert_true(spec.margin(10.0).is_close(0.5))
  let report = evaluate_specification([9.8, 10.0, 10.2, 11.0], spec)
  assert_eq(report.accepted, 3)
  assert_eq(report.upper_failures, 1)
}
