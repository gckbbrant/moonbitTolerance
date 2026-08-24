///|
pub struct AcceptanceWindow {
  lower : Double
  upper : Double
} derive(Debug, Eq)

///|
pub fn AcceptanceWindow::new(
  lower : Double,
  upper : Double,
) -> AcceptanceWindow {
  if upper < lower {
    abort("upper acceptance bound must not be below lower bound")
  }
  { lower, upper }
}

///|
pub fn AcceptanceWindow::contains(
  self : AcceptanceWindow,
  value : Double,
) -> Bool {
  value >= self.lower && value <= self.upper
}

///|
pub struct SimulationSummary {
  nominal : Double
  minimum : Double
  maximum : Double
  mean : Double
  standard_deviation : Double
  yield_rate : Double
  samples : Int
  sensitivity : Array[(String, Double)]
} derive(Debug)

///|
pub fn Chain::simulate(
  self : Chain,
  samples : Int,
  policy : SamplingPolicy,
  window : AcceptanceWindow,
) -> SimulationSummary {
  if samples <= 0 {
    abort("samples must be positive")
  }
  let worst = self.worst_case()
  let mut state = policy.seed
  let mut total = 0.0
  let mut square_total = 0.0
  let mut minimum = 1.0e308
  let mut maximum = -1.0e308
  let mut passed = 0
  for _ in 0..<samples {
    let mut value = 0.0
    for dimension in self.dimensions {
      let (next, deviation) = sample_deviation_with_state(
        policy,
        state,
        dimension.tolerance,
      )
      state = next
      value += signed_nominal(dimension) + deviation
    }
    total += value
    square_total += value * value
    if value < minimum {
      minimum = value
    }
    if value > maximum {
      maximum = value
    }
    if window.contains(value) {
      passed += 1
    }
  }
  let mean = total / samples.to_double()
  let raw_variance = square_total / samples.to_double() - mean * mean
  let variance = if raw_variance < 0.0 { 0.0 } else { raw_variance }
  {
    nominal: worst.nominal,
    minimum,
    maximum,
    mean,
    standard_deviation: variance.sqrt(),
    yield_rate: passed.to_double() / samples.to_double(),
    samples,
    sensitivity: worst.sensitivity,
  }
}
