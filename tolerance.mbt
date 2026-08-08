///|
pub enum Direction {
  Positive
  Negative
} derive(Debug, Eq)

///|
pub fn negative_direction() -> Direction {
  Negative
}

///|
pub struct Dimension {
  name : String
  nominal : Double
  tolerance : Double
  direction : Direction
} derive(Debug, Eq)

///|
pub fn Dimension::new(
  name : String,
  nominal : Double,
  tolerance : Double,
  direction? : Direction = Positive,
) -> Dimension {
  if tolerance < 0.0 {
    abort("tolerance must be non-negative")
  }
  { name, nominal, tolerance, direction }
}

///|
pub struct Chain {
  name : String
  dimensions : Array[Dimension]
} derive(Debug)

///|
pub fn Chain::new(name : String, dimensions : Array[Dimension]) -> Chain {
  if dimensions.length() == 0 {
    abort("a chain must contain at least one dimension")
  }
  { name, dimensions }
}

///|
pub struct AnalysisResult {
  nominal : Double
  lower : Double
  upper : Double
  mean : Double
  standard_deviation : Double
  yield_rate : Double
  sensitivity : Array[(String, Double)]
} derive(Debug)

///|
fn signed_nominal(d : Dimension) -> Double {
  match d.direction {
    Positive => d.nominal
    Negative => -d.nominal
  }
}

///|
pub fn Chain::nominal(self : Chain) -> Double {
  self.dimensions.fold(init=0.0, (sum, d) => sum + signed_nominal(d))
}

///|
pub fn Chain::worst_case(self : Chain) -> AnalysisResult {
  let mut total = 0.0
  let mut span = 0.0
  for d in self.dimensions {
    total += signed_nominal(d)
    span += d.tolerance
  }
  let sensitivities = self.dimensions.map(d => (d.name, d.tolerance))
  {
    nominal: total,
    lower: total - span,
    upper: total + span,
    mean: total,
    standard_deviation: span,
    yield_rate: 1.0,
    sensitivity: sensitivities,
  }
}

///|
pub fn Chain::rss(self : Chain) -> AnalysisResult {
  let mut total = 0.0
  let mut variance = 0.0
  for d in self.dimensions {
    total += signed_nominal(d)
    variance += d.tolerance * d.tolerance
  }
  let sigma = variance.sqrt()
  let sensitivities = self.dimensions.map(d => {
    (d.name, d.tolerance * d.tolerance)
  })
  {
    nominal: total,
    lower: total - 3.0 * sigma,
    upper: total + 3.0 * sigma,
    mean: total,
    standard_deviation: sigma,
    yield_rate: 0.9973,
    sensitivity: sensitivities,
  }
}

///|
pub fn Chain::monte_carlo(
  self : Chain,
  samples : Int,
  seed? : UInt = 1U,
) -> AnalysisResult {
  if samples <= 0 {
    abort("samples must be positive")
  }
  let mut state = seed
  let mut total = 0.0
  let mut square_total = 0.0
  let mut pass = 0
  let worst = self.worst_case()
  for _ in 0..<samples {
    let mut value = 0.0
    for d in self.dimensions {
      state = state * 1664525U + 1013904223U
      let unit = state.to_double() / 4294967295.0
      let deviation = (unit * 2.0 - 1.0) * d.tolerance
      value += signed_nominal(d) + deviation
    }
    total += value
    square_total += value * value
    if value >= worst.lower && value <= worst.upper {
      pass += 1
    }
  }
  let mean = total / samples.to_double()
  let variance = square_total / samples.to_double() - mean * mean
  {
    nominal: worst.nominal,
    lower: worst.lower,
    upper: worst.upper,
    mean,
    standard_deviation: variance.sqrt(),
    yield_rate: pass.to_double() / samples.to_double(),
    sensitivity: worst.sensitivity,
  }
}
