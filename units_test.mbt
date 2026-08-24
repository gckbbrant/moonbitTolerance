///|
test "length and angle conversions are reversible" {
  let length = Length::from_inches(1.0)
  assert_true(length.to_millimeters().is_close(25.4))
  assert_true(Length::from_micrometers(1000.0).to_millimeters().is_close(1.0))
  let angle = Angle::from_degrees(180.0)
  assert_true(angle.to_radians().is_close(3.141592653589793))
  assert_true(
    Angle::from_radians(angle.to_radians()).to_degrees().is_close(180.0),
  )
}
