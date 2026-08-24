///|
/// Process performance facts for an inspection batch.
pub struct ProcessPerformance {
  statistics : SampleStatistics
  accepted : Int
  rejected : Int
  lower_defects : Int
  upper_defects : Int
  observed_yield : Double
  defect_rate : Double
  capability : CapabilityReport
} derive(Debug, Eq)

///|
/// Count accepted, lower-side, and upper-side observations.
pub fn process_performance(
  values : Array[Double],
  window : AcceptanceWindow,
) -> ProcessPerformance {
  let statistics = summarize_samples(values)
  let capability = capability_report(values, window)
  let mut accepted = 0
  let mut lower_defects = 0
  let mut upper_defects = 0
  for value in values {
    if value < window.lower {
      lower_defects += 1
    } else if value > window.upper {
      upper_defects += 1
    } else {
      accepted += 1
    }
  }
  let rejected = lower_defects + upper_defects
  {
    statistics,
    accepted,
    rejected,
    lower_defects,
    upper_defects,
    observed_yield: accepted.to_double() / statistics.count.to_double(),
    defect_rate: rejected.to_double() / statistics.count.to_double(),
    capability,
  }
}

///|
/// Return the indices of values outside a closed screening band.
pub fn outlier_indices(
  values : Array[Double],
  lower : Double,
  upper : Double,
) -> Array[Int] {
  if upper < lower {
    abort("outlier upper bound must not be below lower bound")
  }
  let result = []
  for index in 0..<values.length() {
    if values[index] < lower || values[index] > upper {
      result.push(index)
    }
  }
  result
}

///|
/// Convert an observed defect rate to parts per million.
pub fn defects_per_million(report : ProcessPerformance) -> Double {
  report.defect_rate * 1_000_000.0
}

///|
/// A least-squares linear trend over equally spaced observations.
pub struct TrendReport {
  count : Int
  slope : Double
  intercept : Double
  r_squared : Double
} derive(Debug, Eq)

///|
/// Calculate an equally-spaced least-squares process trend.
pub fn linear_trend(values : Array[Double]) -> TrendReport {
  if values.length() < 2 {
    abort("a trend requires at least two observations")
  }
  let count = values.length()
  let n = count.to_double()
  let mean_x = (n - 1.0) / 2.0
  let statistics = summarize_samples(values)
  let mean_y = statistics.mean
  let mut xx = 0.0
  let mut xy = 0.0
  let mut yy = 0.0
  for index in 0..<count {
    let x = index.to_double()
    let dx = x - mean_x
    let dy = values[index] - mean_y
    xx += dx * dx
    xy += dx * dy
    yy += dy * dy
  }
  let slope = if xx == 0.0 { 0.0 } else { xy / xx }
  let intercept = mean_y - slope * mean_x
  let r_squared = if yy == 0.0 { 1.0 } else { xy * xy / (xx * yy) }
  { count, slope, intercept, r_squared }
}

///|
/// Calculate simple trailing moving averages.
pub fn moving_average(values : Array[Double], window : Int) -> Array[Double] {
  if window <= 0 {
    abort("moving-average window must be positive")
  }
  if values.length() < window {
    []
  } else {
    let result = []
    for start in 0..<(values.length() - window + 1) {
      let mut total = 0.0
      for offset in 0..<window {
        total += values[start + offset]
      }
      result.push(total / window.to_double())
    }
    result
  }
}

///|
/// Return the signed distance from a process mean to the nearest specification edge.
pub fn centering_margin(mean : Double, window : AcceptanceWindow) -> Double {
  let lower = mean - window.lower
  let upper = window.upper - mean
  if lower < upper {
    lower
  } else {
    upper
  }
}
