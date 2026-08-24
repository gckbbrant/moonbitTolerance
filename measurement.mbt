///|
/// Gauge repeatability and reproducibility results for a crossed study.
pub struct GaugeRRReport {
  part_count : Int
  operator_count : Int
  repeat_count : Int
  total_measurements : Int
  repeatability : Double
  reproducibility : Double
  part_to_part : Double
  total_variation : Double
  percent_tolerance : Double
  ndc : Double
} derive(Debug, Eq)

///|
fn measurement_group(
  values : Array[Double],
  start : Int,
  count : Int,
) -> Array[Double] {
  let group = []
  for index in 0..<count {
    group.push(values[start + index])
  }
  group
}

///|
/// Calculate a crossed gauge R&R study.
///
/// Values are ordered part-major, then operator-major, then repeat-major.
pub fn gauge_rr(
  values : Array[Double],
  part_count : Int,
  operator_count : Int,
  repeat_count : Int,
  tolerance_width : Double,
) -> GaugeRRReport {
  if part_count <= 0 || operator_count <= 0 || repeat_count <= 0 {
    abort("gauge R&R dimensions must be positive")
  }
  if tolerance_width <= 0.0 {
    abort("gauge tolerance width must be positive")
  }
  let expected = part_count * operator_count * repeat_count
  if values.length() != expected {
    abort("gauge R&R values do not match the study dimensions")
  }
  let mut pooled_variance = 0.0
  let mut subgroup_count = 0
  let operator_values = []
  for _ in 0..<operator_count {
    operator_values.push([])
  }
  let part_means = []
  for part in 0..<part_count {
    let part_values = []
    for operator in 0..<operator_count {
      let start = (part * operator_count + operator) * repeat_count
      let subgroup = measurement_group(values, start, repeat_count)
      let subgroup_stats = summarize_samples(subgroup)
      pooled_variance += subgroup_stats.variance * repeat_count.to_double()
      subgroup_count += repeat_count
      operator_values[operator].append(subgroup)
      part_values.append(subgroup)
    }
    part_means.push(summarize_samples(part_values).mean)
  }
  let repeatability = (pooled_variance / subgroup_count.to_double()).sqrt()
  let operator_means = operator_values.map(values_for_operator => {
    summarize_samples(values_for_operator).mean
  })
  let reproducibility = summarize_samples(operator_means).standard_deviation
  let part_to_part = summarize_samples(part_means).standard_deviation
  let total_variation = (repeatability * repeatability +
  reproducibility * reproducibility).sqrt()
  let percent_tolerance = total_variation / tolerance_width * 100.0
  let ndc = if total_variation == 0.0 {
    0.0
  } else {
    1.41 * part_to_part / total_variation
  }
  {
    part_count,
    operator_count,
    repeat_count,
    total_measurements: expected,
    repeatability,
    reproducibility,
    part_to_part,
    total_variation,
    percent_tolerance,
    ndc,
  }
}

///|
/// A measured bias relative to a reference value.
pub struct BiasReport {
  count : Int
  reference : Double
  mean : Double
  bias : Double
  standard_deviation : Double
  maximum_absolute_error : Double
} derive(Debug, Eq)

///|
/// Calculate mean bias and maximum absolute error against a reference.
pub fn measurement_bias(
  values : Array[Double],
  reference : Double,
) -> BiasReport {
  let statistics = summarize_samples(values)
  let mut maximum_absolute_error = 0.0
  for value in values {
    let error = (value - reference).abs()
    if error > maximum_absolute_error {
      maximum_absolute_error = error
    }
  }
  {
    count: statistics.count,
    reference,
    mean: statistics.mean,
    bias: statistics.mean - reference,
    standard_deviation: statistics.standard_deviation,
    maximum_absolute_error,
  }
}

///|
/// Return the average absolute error against a reference.
pub fn mean_absolute_error(
  values : Array[Double],
  reference : Double,
) -> Double {
  let mut total = 0.0
  for value in values {
    total += (value - reference).abs()
  }
  total / values.length().to_double()
}

///|
/// Return the percentage of measurements inside an interval.
pub fn measurement_yield(
  values : Array[Double],
  window : AcceptanceWindow,
) -> Double {
  let mut accepted = 0
  for value in values {
    if window.contains(value) {
      accepted += 1
    }
  }
  accepted.to_double() / values.length().to_double()
}
