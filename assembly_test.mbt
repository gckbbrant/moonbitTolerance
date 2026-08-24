///|
test "fit analysis distinguishes clearance transition and interference" {
  let clearance = analyze_fit(
    Dimension::new("hole", 10.2, 0.05),
    Dimension::new("shaft", 10.0, 0.03),
  )
  match clearance.classification {
    Clearance => ()
    _ => fail("positive worst-case clearance should classify as clearance")
  }
  assert_true(clearance.minimum_clearance > 0.0)
  let transition = analyze_fit(
    Dimension::new("hole", 10.0, 0.1),
    Dimension::new("shaft", 10.0, 0.1),
  )
  match transition.classification {
    Transition => ()
    _ => fail("overlapping clearance bounds should classify as transition")
  }
  let interference = analyze_fit(
    Dimension::new("hole", 9.8, 0.02),
    Dimension::new("shaft", 10.0, 0.02),
  )
  match interference.classification {
    Interference => ()
    _ => fail("negative worst-case clearance should classify as interference")
  }
}

///|
test "fit acceptance checks the complete worst-case clearance range" {
  let fit = analyze_fit(
    Dimension::new("hole", 10.2, 0.05),
    Dimension::new("shaft", 10.0, 0.03),
  )
  assert_true(fit.accepts(Interval::new(0.1, 0.3)))
  assert_true(!fit.accepts(Interval::new(0.2, 0.3)))
  assert_true(fit.margin(Interval::new(0.0, 0.1)) < 0.0)
}
