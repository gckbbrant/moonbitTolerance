///|
/// A closed numeric interval used for conservative tolerance propagation.
pub struct Interval {
  lower : Double
  upper : Double
} derive(Debug, Eq)

///|
/// Construct an interval. Bounds are inclusive and must be ordered.
pub fn Interval::new(lower : Double, upper : Double) -> Interval {
  if upper < lower {
    abort("interval upper bound must not be below lower bound")
  }
  { lower, upper }
}

///|
/// Construct an interval containing a single value.
pub fn Interval::point(value : Double) -> Interval {
  { lower: value, upper: value }
}

///|
/// Return the interval width.
pub fn Interval::width(self : Interval) -> Double {
  self.upper - self.lower
}

///|
/// Return the interval midpoint.
pub fn Interval::midpoint(self : Interval) -> Double {
  (self.lower + self.upper) / 2.0
}

///|
/// Return whether the value is inside the closed interval.
pub fn Interval::contains(self : Interval, value : Double) -> Bool {
  value >= self.lower && value <= self.upper
}

///|
/// Return whether two closed intervals overlap or touch.
pub fn Interval::intersects(self : Interval, other : Interval) -> Bool {
  self.lower <= other.upper && other.lower <= self.upper
}

///|
/// Return the overlap of two intervals, if one exists.
pub fn Interval::intersection(self : Interval, other : Interval) -> Interval? {
  let lower = if self.lower > other.lower { self.lower } else { other.lower }
  let upper = if self.upper < other.upper { self.upper } else { other.upper }
  if lower <= upper {
    Some({ lower, upper })
  } else {
    None
  }
}

///|
/// Return the smallest interval containing both operands.
pub fn Interval::hull(self : Interval, other : Interval) -> Interval {
  let lower = if self.lower < other.lower { self.lower } else { other.lower }
  let upper = if self.upper > other.upper { self.upper } else { other.upper }
  { lower, upper }
}

///|
/// Add two intervals.
pub fn Interval::add(self : Interval, other : Interval) -> Interval {
  { lower: self.lower + other.lower, upper: self.upper + other.upper }
}

///|
/// Subtract two intervals.
pub fn Interval::sub(self : Interval, other : Interval) -> Interval {
  { lower: self.lower - other.upper, upper: self.upper - other.lower }
}

///|
/// Negate an interval.
pub fn Interval::negate(self : Interval) -> Interval {
  { lower: -self.upper, upper: -self.lower }
}

///|
fn interval_min4(a : Double, b : Double, c : Double, d : Double) -> Double {
  let first = if a < b { a } else { b }
  let second = if c < d { c } else { d }
  if first < second {
    first
  } else {
    second
  }
}

///|
fn interval_max4(a : Double, b : Double, c : Double, d : Double) -> Double {
  let first = if a > b { a } else { b }
  let second = if c > d { c } else { d }
  if first > second {
    first
  } else {
    second
  }
}

///|
/// Multiply two intervals using all endpoint combinations.
pub fn Interval::mul(self : Interval, other : Interval) -> Interval {
  let a = self.lower * other.lower
  let b = self.lower * other.upper
  let c = self.upper * other.lower
  let d = self.upper * other.upper
  { lower: interval_min4(a, b, c, d), upper: interval_max4(a, b, c, d) }
}

///|
/// Scale an interval, preserving its ordering for negative factors.
pub fn Interval::scale(self : Interval, factor : Double) -> Interval {
  if factor >= 0.0 {
    { lower: self.lower * factor, upper: self.upper * factor }
  } else {
    { lower: self.upper * factor, upper: self.lower * factor }
  }
}

///|
/// Divide by an interval. Division is undefined when the denominator contains zero.
pub fn Interval::divide(self : Interval, denominator : Interval) -> Interval? {
  if denominator.contains(0.0) {
    None
  } else {
    Some(
      self.mul({
        lower: 1.0 / denominator.upper,
        upper: 1.0 / denominator.lower,
      }),
    )
  }
}

///|
/// Return the absolute-value enclosure of the interval.
pub fn Interval::absolute(self : Interval) -> Interval {
  if self.lower >= 0.0 {
    self
  } else if self.upper <= 0.0 {
    self.negate()
  } else {
    let upper = if -self.lower > self.upper { -self.lower } else { self.upper }
    { lower: 0.0, upper }
  }
}

///|
/// Return the distance from a value to this interval, or zero when contained.
pub fn Interval::distance_to(self : Interval, value : Double) -> Double {
  if value < self.lower {
    self.lower - value
  } else if value > self.upper {
    value - self.upper
  } else {
    0.0
  }
}

///|
/// Return the one-dimensional conservative interval for a signed dimension.
pub fn dimension_interval(dimension : Dimension) -> Interval {
  let center = signed_nominal(dimension)
  { lower: center - dimension.tolerance, upper: center + dimension.tolerance }
}

///|
/// Propagate a dimension chain with interval arithmetic.
pub fn chain_interval(chain : Chain) -> Interval {
  let mut result = Interval::point(0.0)
  for dimension in chain.dimensions {
    result = result.add(dimension_interval(dimension))
  }
  result
}

///|
/// A two-dimensional rectangular interval.
pub struct IntervalVector2 {
  x : Interval
  y : Interval
} derive(Debug, Eq)

///|
/// Construct a rectangular vector interval.
pub fn IntervalVector2::new(x : Interval, y : Interval) -> IntervalVector2 {
  { x, y }
}

///|
/// Add rectangular vector intervals component by component.
pub fn IntervalVector2::add(
  self : IntervalVector2,
  other : IntervalVector2,
) -> IntervalVector2 {
  { x: self.x.add(other.x), y: self.y.add(other.y) }
}

///|
fn interval_closest_to_zero(interval : Interval) -> Double {
  if interval.contains(0.0) {
    0.0
  } else {
    let lower = interval.lower.abs()
    let upper = interval.upper.abs()
    if lower < upper {
      lower
    } else {
      upper
    }
  }
}

///|
fn interval_farthest_from_zero(interval : Interval) -> Double {
  let lower = interval.lower.abs()
  let upper = interval.upper.abs()
  if lower > upper {
    lower
  } else {
    upper
  }
}

///|
/// Return conservative lower and upper bounds for vector magnitude.
pub fn IntervalVector2::magnitude_bounds(self : IntervalVector2) -> Interval {
  let x_lower = interval_closest_to_zero(self.x)
  let y_lower = interval_closest_to_zero(self.y)
  let x_upper = interval_farthest_from_zero(self.x)
  let y_upper = interval_farthest_from_zero(self.y)
  {
    lower: (x_lower * x_lower + y_lower * y_lower).sqrt(),
    upper: (x_upper * x_upper + y_upper * y_upper).sqrt(),
  }
}
