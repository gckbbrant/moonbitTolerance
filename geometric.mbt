///|
pub enum GeometricMode {
  Position
  Concentricity
  Runout
} derive(Debug, Eq)

///|
pub struct GeometricTolerance {
  mode : GeometricMode
  zone : Double
} derive(Debug, Eq)

///|
pub fn GeometricTolerance::new(
  mode : GeometricMode,
  zone : Double,
) -> GeometricTolerance {
  if zone < 0.0 {
    abort("geometric tolerance zone must be non-negative")
  }
  { mode, zone }
}

///|
/// Construct a position tolerance zone.
pub fn position_tolerance(zone : Double) -> GeometricTolerance {
  GeometricTolerance::new(Position, zone)
}

///|
/// Construct a concentricity tolerance zone.
pub fn concentricity_tolerance(zone : Double) -> GeometricTolerance {
  GeometricTolerance::new(Concentricity, zone)
}

///|
/// Construct a circular runout tolerance zone.
pub fn runout_tolerance(zone : Double) -> GeometricTolerance {
  GeometricTolerance::new(Runout, zone)
}

///|
pub fn GeometricTolerance::evaluate(
  self : GeometricTolerance,
  measured : Vector2,
  nominal : Vector2,
) -> ConstraintStatus {
  let error = match self.mode {
    Position | Concentricity => measured.sub(nominal).length()
    Runout => (measured.length() - nominal.length()).abs()
  }
  if error <= self.zone {
    Satisfied
  } else {
    Violated
  }
}
