///|
/// Reporting rounding policies for engineering values.
pub enum RoundingMode {
  Nearest
  Down
  Up
  TowardZero
} derive(Debug, Eq)

///|
/// Select nearest-half-up rounding.
pub fn nearest_rounding() -> RoundingMode {
  Nearest
}

///|
/// Select downward rounding.
pub fn down_rounding() -> RoundingMode {
  Down
}

///|
/// Select upward rounding.
pub fn up_rounding() -> RoundingMode {
  Up
}

///|
/// Select truncation toward zero.
pub fn toward_zero_rounding() -> RoundingMode {
  TowardZero
}

///|
fn decimal_factor(decimals : Int) -> Double {
  if decimals < 0 {
    abort("decimal places must be non-negative")
  }
  let mut factor = 1.0
  for _ in 0..<decimals {
    factor *= 10.0
  }
  factor
}

///|
fn nearest_integer(value : Double) -> Double {
  if value >= 0.0 {
    (value + 0.5).floor()
  } else {
    (value - 0.5).ceil()
  }
}

///|
/// Round a value to a fixed number of decimal places.
pub fn round_to(value : Double, decimals : Int, mode : RoundingMode) -> Double {
  let factor = decimal_factor(decimals)
  let scaled = value * factor
  let rounded = match mode {
    Nearest => nearest_integer(scaled)
    Down => scaled.floor()
    Up => scaled.ceil()
    TowardZero => scaled.to_int().to_double()
  }
  rounded / factor
}

///|
/// Round an interval outward so it remains conservative.
pub fn round_interval(value : Interval, decimals : Int) -> Interval {
  let factor = decimal_factor(decimals)
  let lower = (value.lower * factor).floor() / factor
  let upper = (value.upper * factor).ceil() / factor
  Interval::new(lower, upper)
}

///|
/// Apply reporting rounding to a measurement array without changing its order.
pub fn round_values(
  values : Array[Double],
  decimals : Int,
  mode : RoundingMode,
) -> Array[Double] {
  values.map(value => round_to(value, decimals, mode))
}

///|
/// Round a sample summary while preserving its count and extrema semantics.
pub fn round_statistics(
  statistics : SampleStatistics,
  decimals : Int,
) -> SampleStatistics {
  {
    count: statistics.count,
    mean: round_to(statistics.mean, decimals, Nearest),
    variance: round_to(statistics.variance, decimals, Nearest),
    standard_deviation: round_to(
      statistics.standard_deviation,
      decimals,
      Nearest,
    ),
    minimum: round_to(statistics.minimum, decimals, Down),
    maximum: round_to(statistics.maximum, decimals, Up),
  }
}
