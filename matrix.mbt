///|
/// A compact two-by-two matrix for projected tolerance transforms.
pub struct Matrix2 {
  m11 : Double
  m12 : Double
  m21 : Double
  m22 : Double
} derive(Debug, Eq)

///|
/// Construct a matrix from row-major entries.
pub fn Matrix2::new(
  m11 : Double,
  m12 : Double,
  m21 : Double,
  m22 : Double,
) -> Matrix2 {
  { m11, m12, m21, m22 }
}

///|
/// Construct the identity matrix.
pub fn Matrix2::identity() -> Matrix2 {
  { m11: 1.0, m12: 0.0, m21: 0.0, m22: 1.0 }
}

///|
/// Construct a two-dimensional rotation matrix.
pub fn Matrix2::rotation(angle_radians : Double) -> Matrix2 {
  let cosine = @math.cos(angle_radians)
  let sine = @math.sin(angle_radians)
  { m11: cosine, m12: -sine, m21: sine, m22: cosine }
}

///|
/// Construct a diagonal scale matrix.
pub fn Matrix2::scale(x : Double, y : Double) -> Matrix2 {
  { m11: x, m12: 0.0, m21: 0.0, m22: y }
}

///|
/// Apply the matrix to a vector.
pub fn Matrix2::apply(self : Matrix2, vector : Vector2) -> Vector2 {
  Vector2::new(
    self.m11 * vector.x + self.m12 * vector.y,
    self.m21 * vector.x + self.m22 * vector.y,
  )
}

///|
/// Multiply two matrices.
pub fn Matrix2::multiply(self : Matrix2, other : Matrix2) -> Matrix2 {
  {
    m11: self.m11 * other.m11 + self.m12 * other.m21,
    m12: self.m11 * other.m12 + self.m12 * other.m22,
    m21: self.m21 * other.m11 + self.m22 * other.m21,
    m22: self.m21 * other.m12 + self.m22 * other.m22,
  }
}

///|
/// Return the transpose.
pub fn Matrix2::transpose(self : Matrix2) -> Matrix2 {
  { m11: self.m11, m12: self.m21, m21: self.m12, m22: self.m22 }
}

///|
/// Return the determinant.
pub fn Matrix2::determinant(self : Matrix2) -> Double {
  self.m11 * self.m22 - self.m12 * self.m21
}

///|
/// Return the inverse, if the determinant is non-zero.
pub fn Matrix2::inverse(self : Matrix2) -> Matrix2? {
  let determinant = self.determinant()
  if determinant == 0.0 {
    None
  } else {
    Some({
      m11: self.m22 / determinant,
      m12: -self.m12 / determinant,
      m21: -self.m21 / determinant,
      m22: self.m11 / determinant,
    })
  }
}

///|
/// Return the matrix as an orthonormal transform within tolerance.
pub fn Matrix2::is_orthonormal(self : Matrix2) -> Bool {
  let product = self.transpose().multiply(self)
  product.m11.is_close(1.0, absolute_tolerance=0.000000001) &&
  product.m22.is_close(1.0, absolute_tolerance=0.000000001) &&
  product.m12.is_close(0.0, absolute_tolerance=0.000000001) &&
  product.m21.is_close(0.0, absolute_tolerance=0.000000001)
}

///|
/// A rigid or affine two-dimensional transform.
pub struct Transform2 {
  linear : Matrix2
  translation : Vector2
} derive(Debug, Eq)

///|
/// Construct a transform from a linear matrix and translation.
pub fn Transform2::new(linear : Matrix2, translation : Vector2) -> Transform2 {
  { linear, translation }
}

///|
/// Apply a transform to a point.
pub fn Transform2::apply(self : Transform2, point : Vector2) -> Vector2 {
  self.linear.apply(point).add(self.translation)
}

///|
/// Compose this transform after another transform.
pub fn Transform2::compose(self : Transform2, other : Transform2) -> Transform2 {
  {
    linear: self.linear.multiply(other.linear),
    translation: self.linear.apply(other.translation).add(self.translation),
  }
}

///|
/// Return the inverse transform when its linear part is invertible.
pub fn Transform2::inverse(self : Transform2) -> Transform2? {
  match self.linear.inverse() {
    None => None
    Some(linear) =>
      Some({ linear, translation: linear.apply(self.translation.scale(-1.0)) })
  }
}
