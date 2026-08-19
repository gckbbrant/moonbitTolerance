///|
pub struct Vector2 {
  x : Double
  y : Double
} derive(Debug, Eq)

///|
pub fn Vector2::new(x : Double, y : Double) -> Vector2 {
  { x, y }
}

///|
pub fn Vector2::zero() -> Vector2 {
  { x: 0.0, y: 0.0 }
}

///|
pub fn Vector2::add(self : Vector2, other : Vector2) -> Vector2 {
  { x: self.x + other.x, y: self.y + other.y }
}

///|
pub fn Vector2::sub(self : Vector2, other : Vector2) -> Vector2 {
  { x: self.x - other.x, y: self.y - other.y }
}

///|
pub fn Vector2::scale(self : Vector2, factor : Double) -> Vector2 {
  { x: self.x * factor, y: self.y * factor }
}

///|
pub fn Vector2::dot(self : Vector2, other : Vector2) -> Double {
  self.x * other.x + self.y * other.y
}

///|
pub fn Vector2::length_squared(self : Vector2) -> Double {
  self.dot(self)
}

///|
pub fn Vector2::length(self : Vector2) -> Double {
  self.length_squared().sqrt()
}

///|
pub fn Vector2::normalize(self : Vector2) -> Vector2 {
  let length = self.length()
  if length == 0.0 {
    Vector2::zero()
  } else {
    self.scale(1.0 / length)
  }
}

///|
pub struct ProjectedDimension {
  name : String
  vector : Vector2
  tolerance : Double
} derive(Debug)

///|
pub fn ProjectedDimension::new(
  name : String,
  vector : Vector2,
  tolerance : Double,
) -> ProjectedDimension {
  if tolerance < 0.0 {
    abort("tolerance must be non-negative")
  }
  { name, vector, tolerance }
}

///|
pub struct ProjectedResult {
  nominal : Vector2
  lower_x : Double
  upper_x : Double
  lower_y : Double
  upper_y : Double
  radial_tolerance : Double
  sensitivity : Array[(String, Double)]
} derive(Debug)

///|
pub fn project_chain(dimensions : Array[ProjectedDimension]) -> ProjectedResult {
  if dimensions.length() == 0 {
    abort("a projected chain must not be empty")
  }
  let mut nominal = Vector2::zero()
  let mut variance = 0.0
  let mut x_span = 0.0
  let mut y_span = 0.0
  for dimension in dimensions {
    nominal = nominal.add(dimension.vector)
    variance += dimension.tolerance * dimension.tolerance
    x_span += dimension.vector.x.abs() * dimension.tolerance
    y_span += dimension.vector.y.abs() * dimension.tolerance
  }
  let sensitivities = dimensions.map(d => (d.name, d.tolerance))
  {
    nominal,
    lower_x: nominal.x - x_span,
    upper_x: nominal.x + x_span,
    lower_y: nominal.y - y_span,
    upper_y: nominal.y + y_span,
    radial_tolerance: variance.sqrt(),
    sensitivity: sensitivities,
  }
}

///|
pub fn project_direction(angle_radians : Double) -> Vector2 {
  { x: @math.cos(angle_radians), y: @math.sin(angle_radians) }
}

///|
pub fn project_signed(value : Double, angle_radians : Double) -> Vector2 {
  project_direction(angle_radians).scale(value)
}
