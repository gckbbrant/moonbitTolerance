///|
/// A mergeable accumulator for numerically stable sample statistics.
pub struct RunningStatistics {
  count : Int
  mean : Double
  second_moment : Double
  minimum : Double
  maximum : Double
} derive(Debug, Eq)

///|
/// Create an empty running accumulator.
pub fn RunningStatistics::new() -> RunningStatistics {
  {
    count: 0,
    mean: 0.0,
    second_moment: 0.0,
    minimum: 1.0e308,
    maximum: -1.0e308,
  }
}

///|
/// Add a value and return the updated accumulator.
pub fn RunningStatistics::add(
  self : RunningStatistics,
  value : Double,
) -> RunningStatistics {
  let count = self.count + 1
  let delta = value - self.mean
  let mean = self.mean + delta / count.to_double()
  let corrected_delta = value - mean
  let second_moment = self.second_moment + delta * corrected_delta
  let minimum = if value < self.minimum { value } else { self.minimum }
  let maximum = if value > self.maximum { value } else { self.maximum }
  { count, mean, second_moment, minimum, maximum }
}

///|
/// Add all values from an array.
pub fn RunningStatistics::add_all(
  self : RunningStatistics,
  values : Array[Double],
) -> RunningStatistics {
  let mut result = self
  for value in values {
    result = result.add(value)
  }
  result
}

///|
/// Merge two accumulators without replaying their original samples.
pub fn RunningStatistics::merge(
  self : RunningStatistics,
  other : RunningStatistics,
) -> RunningStatistics {
  if self.count == 0 {
    other
  } else if other.count == 0 {
    self
  } else {
    let total = self.count + other.count
    let delta = other.mean - self.mean
    let left_weight = self.count.to_double()
    let right_weight = other.count.to_double()
    let total_weight = total.to_double()
    let mean = self.mean + delta * right_weight / total_weight
    let second_moment = self.second_moment +
      other.second_moment +
      delta * delta * left_weight * right_weight / total_weight
    let minimum = if self.minimum < other.minimum {
      self.minimum
    } else {
      other.minimum
    }
    let maximum = if self.maximum > other.maximum {
      self.maximum
    } else {
      other.maximum
    }
    { count: total, mean, second_moment, minimum, maximum }
  }
}

///|
/// Finalize the accumulator as the package's sample-statistics type.
pub fn RunningStatistics::finish(self : RunningStatistics) -> SampleStatistics {
  if self.count == 0 {
    abort("cannot finish an empty running statistic")
  }
  let variance = self.second_moment / self.count.to_double()
  {
    count: self.count,
    mean: self.mean,
    variance,
    standard_deviation: variance.sqrt(),
    minimum: self.minimum,
    maximum: self.maximum,
  }
}

///|
/// Calculate a mergeable accumulator from all values.
pub fn running_statistics(values : Array[Double]) -> RunningStatistics {
  RunningStatistics::new().add_all(values)
}

///|
/// Three-sigma control limits around an observed center line.
pub struct ControlLimits {
  center : Double
  lower : Double
  upper : Double
  standard_deviation : Double
  sigma_multiplier : Double
} derive(Debug, Eq)

///|
/// Calculate symmetric control limits from a batch of observations.
pub fn control_limits(
  values : Array[Double],
  sigma_multiplier? : Double = 3.0,
) -> ControlLimits {
  if sigma_multiplier <= 0.0 {
    abort("sigma multiplier must be positive")
  }
  let statistics = summarize_samples(values)
  let margin = sigma_multiplier * statistics.standard_deviation
  {
    center: statistics.mean,
    lower: statistics.mean - margin,
    upper: statistics.mean + margin,
    standard_deviation: statistics.standard_deviation,
    sigma_multiplier,
  }
}

///|
/// Return whether an observation remains within control limits.
pub fn within_control_limits(value : Double, limits : ControlLimits) -> Bool {
  value >= limits.lower && value <= limits.upper
}

///|
/// Count observations outside the control limits.
pub fn control_limit_violations(
  values : Array[Double],
  limits : ControlLimits,
) -> Int {
  let mut count = 0
  for value in values {
    if !within_control_limits(value, limits) {
      count += 1
    }
  }
  count
}

///|
/// A batch inspection report against an explicit acceptance window.
pub struct InspectionReport {
  statistics : SampleStatistics
  window : AcceptanceWindow
  accepted : Int
  rejected : Int
  yield_rate : Double
  capability : CapabilityReport
} derive(Debug, Eq)

///|
/// Inspect a batch and combine observed yield with process capability.
pub fn inspect_batch(
  values : Array[Double],
  window : AcceptanceWindow,
) -> InspectionReport {
  let statistics = summarize_samples(values)
  let capability = capability_report(values, window)
  let mut accepted = 0
  for value in values {
    if window.contains(value) {
      accepted += 1
    }
  }
  let rejected = statistics.count - accepted
  {
    statistics,
    window,
    accepted,
    rejected,
    yield_rate: accepted.to_double() / statistics.count.to_double(),
    capability,
  }
}

///|
/// An approximate normal confidence interval for an observed yield.
pub struct YieldEstimate {
  accepted : Int
  total : Int
  rate : Double
  lower_bound : Double
  upper_bound : Double
} derive(Debug, Eq)

///|
fn clamp_probability(value : Double) -> Double {
  if value < 0.0 {
    0.0
  } else if value > 1.0 {
    1.0
  } else {
    value
  }
}

///|
/// Estimate yield and a 95% normal-approximation confidence interval.
pub fn estimate_yield(
  values : Array[Double],
  window : AcceptanceWindow,
) -> YieldEstimate {
  let report = inspect_batch(values, window)
  let total = report.statistics.count
  let rate = report.yield_rate
  let standard_error = (rate * (1.0 - rate) / total.to_double()).sqrt()
  let margin = 1.96 * standard_error
  {
    accepted: report.accepted,
    total,
    rate,
    lower_bound: clamp_probability(rate - margin),
    upper_bound: clamp_probability(rate + margin),
  }
}
