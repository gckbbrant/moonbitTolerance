///|
pub struct Covariance2 {
  xx : Double
  xy : Double
  yy : Double
} derive(Debug, Eq)

///|
pub fn covariance_of(dimensions : Array[ProjectedDimension]) -> Covariance2 {
  if dimensions.length() == 0 {
    abort("cannot calculate covariance for an empty projected chain")
  }
  let mut xx = 0.0
  let mut xy = 0.0
  let mut yy = 0.0
  for dimension in dimensions {
    let variance = dimension.tolerance * dimension.tolerance
    xx += dimension.vector.x * dimension.vector.x * variance
    xy += dimension.vector.x * dimension.vector.y * variance
    yy += dimension.vector.y * dimension.vector.y * variance
  }
  { xx, xy, yy }
}

///|
pub fn Covariance2::variance_along(
  self : Covariance2,
  direction : Vector2,
) -> Double {
  let xx = self.xx * direction.x * direction.x
  let xy = 2.0 * self.xy * direction.x * direction.y
  let yy = self.yy * direction.y * direction.y
  xx + xy + yy
}

///|
pub fn projected_standard_deviation(
  covariance : Covariance2,
  direction : Vector2,
) -> Double {
  let variance = covariance.variance_along(direction)
  if variance < 0.0 {
    0.0
  } else {
    variance.sqrt()
  }
}
