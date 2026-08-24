///|
pub struct SampleStatistics {
  count : Int
  mean : Double
  variance : Double
  standard_deviation : Double
  minimum : Double
  maximum : Double
} derive(Debug, Eq)

///|
pub fn summarize_samples(values : Array[Double]) -> SampleStatistics {
  if values.length() == 0 {
    abort("cannot summarize an empty sample set")
  }
  let mut count = 0
  let mut mean = 0.0
  let mut second_moment = 0.0
  let mut minimum = 1.0e308
  let mut maximum = -1.0e308
  for value in values {
    count += 1
    let delta = value - mean
    mean += delta / count.to_double()
    let corrected_delta = value - mean
    second_moment += delta * corrected_delta
    if value < minimum {
      minimum = value
    }
    if value > maximum {
      maximum = value
    }
  }
  let variance = if count == 0 {
    0.0
  } else {
    second_moment / count.to_double()
  }
  {
    count,
    mean,
    variance,
    standard_deviation: variance.sqrt(),
    minimum,
    maximum,
  }
}

///|
pub fn quantile(values : Array[Double], probability : Double) -> Double {
  if values.length() == 0 {
    abort("cannot calculate a quantile from an empty sample set")
  }
  if probability < 0.0 || probability > 1.0 {
    abort("quantile probability must be between zero and one")
  }
  let sorted = values.copy()
  sorted.sort()
  let position = probability * (sorted.length() - 1).to_double()
  let lower_index = position.floor().to_int()
  let upper_index = if lower_index + 1 >= sorted.length() {
    lower_index
  } else {
    lower_index + 1
  }
  let fraction = position - lower_index.to_double()
  sorted[lower_index] + (sorted[upper_index] - sorted[lower_index]) * fraction
}
