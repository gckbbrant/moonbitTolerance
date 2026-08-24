///|
/// A length normalized to millimeters at the library boundary.
pub struct Length {
  millimeters : Double
} derive(Debug, Eq)

///|
/// Construct a normalized length in millimeters.
pub fn Length::from_millimeters(millimeters : Double) -> Length {
  { millimeters, }
}

///|
/// Construct a length from micrometers.
pub fn Length::from_micrometers(micrometers : Double) -> Length {
  { millimeters: micrometers / 1000.0 }
}

///|
/// Construct a length from international inches.
pub fn Length::from_inches(inches : Double) -> Length {
  { millimeters: inches * 25.4 }
}

///|
/// Return the length in millimeters.
pub fn Length::to_millimeters(self : Length) -> Double {
  self.millimeters
}

///|
/// Return the length in micrometers.
pub fn Length::to_micrometers(self : Length) -> Double {
  self.millimeters * 1000.0
}

///|
/// Return the length in international inches.
pub fn Length::to_inches(self : Length) -> Double {
  self.millimeters / 25.4
}

///|
/// Add two normalized lengths.
pub fn Length::add(self : Length, other : Length) -> Length {
  { millimeters: self.millimeters + other.millimeters }
}

///|
/// Subtract two normalized lengths.
pub fn Length::sub(self : Length, other : Length) -> Length {
  { millimeters: self.millimeters - other.millimeters }
}

///|
/// Scale a normalized length.
pub fn Length::scale(self : Length, factor : Double) -> Length {
  { millimeters: self.millimeters * factor }
}

///|
/// A tolerance expressed in the normalized length unit.
pub struct LengthTolerance {
  nominal : Length
  lower : Length
  upper : Length
} derive(Debug, Eq)

///|
/// Construct a symmetric length tolerance around a nominal value.
pub fn LengthTolerance::symmetric(
  nominal : Length,
  tolerance : Length,
) -> LengthTolerance {
  let lower = nominal.sub(tolerance)
  let upper = nominal.add(tolerance)
  { nominal, lower, upper }
}

///|
/// Return the corresponding interval in millimeters.
pub fn LengthTolerance::interval(self : LengthTolerance) -> Interval {
  Interval::new(self.lower.millimeters, self.upper.millimeters)
}

///|
/// An angle normalized to radians.
pub struct Angle {
  radians : Double
} derive(Debug, Eq)

///|
/// Construct an angle from radians.
pub fn Angle::from_radians(radians : Double) -> Angle {
  { radians, }
}

///|
/// Construct an angle from degrees.
pub fn Angle::from_degrees(degrees : Double) -> Angle {
  { radians: degrees * 3.141592653589793 / 180.0 }
}

///|
/// Return the angle in radians.
pub fn Angle::to_radians(self : Angle) -> Double {
  self.radians
}

///|
/// Return the angle in degrees.
pub fn Angle::to_degrees(self : Angle) -> Double {
  self.radians * 180.0 / 3.141592653589793
}

///|
/// Add two angles.
pub fn Angle::add(self : Angle, other : Angle) -> Angle {
  { radians: self.radians + other.radians }
}

///|
/// Return a unit direction vector for the angle.
pub fn Angle::direction(self : Angle) -> Vector2 {
  project_direction(self.radians)
}
