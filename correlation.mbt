///|
/// A pairwise correlation coefficient between two dimension contributors.
pub struct CorrelationTerm {
  first : Int
  second : Int
  coefficient : Double
} derive(Debug, Eq)

///|
/// Construct a correlation term with a coefficient in [-1, 1].
pub fn CorrelationTerm::new(
  first : Int,
  second : Int,
  coefficient : Double,
) -> CorrelationTerm {
  if first < 0 || second < 0 {
    abort("correlation indices must be non-negative")
  }
  if coefficient < -1.0 || coefficient > 1.0 {
    abort("correlation coefficient must be between -1 and 1")
  }
  { first, second, coefficient }
}

///|
/// RSS variation after applying pairwise correlation adjustments.
pub struct CorrelatedRSSReport {
  independent_variance : Double
  correlation_adjustment : Double
  variance : Double
  standard_deviation : Double
} derive(Debug, Eq)

///|
/// Calculate a correlation-aware RSS uncertainty estimate.
pub fn correlated_rss(
  dimensions : Array[Dimension],
  terms : Array[CorrelationTerm],
) -> CorrelatedRSSReport {
  if dimensions.length() == 0 {
    abort("correlated RSS requires at least one dimension")
  }
  let mut independent_variance = 0.0
  for dimension in dimensions {
    independent_variance += dimension.tolerance * dimension.tolerance
  }
  let mut correlation_adjustment = 0.0
  for term in terms {
    if term.first >= dimensions.length() || term.second >= dimensions.length() {
      abort("correlation index exceeds dimension count")
    }
    let first = dimensions[term.first].tolerance
    let second = dimensions[term.second].tolerance
    correlation_adjustment += 2.0 * term.coefficient * first * second
  }
  let variance = independent_variance + correlation_adjustment
  if variance < 0.0 {
    abort("correlation terms produce negative variance")
  }
  {
    independent_variance,
    correlation_adjustment,
    variance,
    standard_deviation: variance.sqrt(),
  }
}

///|
/// Return a nominal interval using a correlation-aware standard deviation.
pub fn correlated_interval(
  chain : Chain,
  terms : Array[CorrelationTerm],
  coverage_factor : Double,
) -> Interval {
  if coverage_factor < 0.0 {
    abort("correlation coverage factor must be non-negative")
  }
  let dimensions = chain.dimensions
  let report = correlated_rss(dimensions, terms)
  let margin = report.standard_deviation * coverage_factor
  Interval::new(chain.nominal() - margin, chain.nominal() + margin)
}

///|
/// Return the correlation-adjusted standard deviation for a chain.
pub fn correlated_standard_deviation(
  chain : Chain,
  terms : Array[CorrelationTerm],
) -> Double {
  correlated_rss(chain.dimensions, terms).standard_deviation
}
