///|
/// A nominal value with explicit lower and upper specification limits.
pub struct Specification {
  lower : Double
  upper : Double
  nominal : Double
} derive(Debug, Eq)

///|
/// Construct a specification band.
pub fn Specification::new(
  lower : Double,
  upper : Double,
  nominal : Double,
) -> Specification {
  if upper < lower {
    abort("specification upper bound must not be below lower bound")
  }
  if nominal < lower || nominal > upper {
    abort("specification nominal must lie within its limits")
  }
  { lower, upper, nominal }
}

///|
/// Return the specification as an acceptance window.
pub fn Specification::window(self : Specification) -> AcceptanceWindow {
  AcceptanceWindow::new(self.lower, self.upper)
}

///|
/// Return whether a value is within specification.
pub fn Specification::contains(self : Specification, value : Double) -> Bool {
  value >= self.lower && value <= self.upper
}

///|
/// Return the signed margin to the nearest limit.
pub fn Specification::margin(self : Specification, value : Double) -> Double {
  let lower = value - self.lower
  let upper = self.upper - value
  if lower < upper {
    lower
  } else {
    upper
  }
}

///|
/// Classification of one measurement against a specification band.
pub enum SpecificationStatus {
  BelowLower
  WithinSpecification
  AboveUpper
} derive(Debug, Eq)

///|
/// Classify a measurement against both limits.
pub fn Specification::classify(
  self : Specification,
  value : Double,
) -> SpecificationStatus {
  if value < self.lower {
    BelowLower
  } else if value > self.upper {
    AboveUpper
  } else {
    WithinSpecification
  }
}

///|
/// Aggregated specification results for an inspection batch.
pub struct SpecificationReport {
  count : Int
  accepted : Int
  lower_failures : Int
  upper_failures : Int
  yield_rate : Double
  mean_margin : Double
} derive(Debug, Eq)

///|
/// Evaluate every value and preserve lower/upper defect directions.
pub fn evaluate_specification(
  values : Array[Double],
  specification : Specification,
) -> SpecificationReport {
  if values.length() == 0 {
    abort("cannot evaluate an empty specification batch")
  }
  let mut accepted = 0
  let mut lower_failures = 0
  let mut upper_failures = 0
  let mut margin_total = 0.0
  for value in values {
    margin_total += specification.margin(value)
    match specification.classify(value) {
      BelowLower => lower_failures += 1
      WithinSpecification => accepted += 1
      AboveUpper => upper_failures += 1
    }
  }
  {
    count: values.length(),
    accepted,
    lower_failures,
    upper_failures,
    yield_rate: accepted.to_double() / values.length().to_double(),
    mean_margin: margin_total / values.length().to_double(),
  }
}
