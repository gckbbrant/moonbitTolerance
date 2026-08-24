///|
/// A sample-size plan for estimating an acceptance yield.
pub struct SamplePlan {
  expected_yield : Double
  confidence : Double
  margin : Double
  z_score : Double
  samples : Int
  expected_half_width : Double
} derive(Debug, Eq)

///|
/// Calculate a conservative normal-approximation sample-size plan.
pub fn sample_plan(
  expected_yield : Double,
  margin : Double,
  z_score : Double,
) -> SamplePlan {
  if expected_yield < 0.0 || expected_yield > 1.0 {
    abort("expected yield must be between zero and one")
  }
  if margin <= 0.0 || z_score <= 0.0 {
    abort("sample-plan margin and z score must be positive")
  }
  let variance = expected_yield * (1.0 - expected_yield)
  let raw = z_score * z_score * variance / (margin * margin)
  let samples = if raw < 1.0 { 1 } else { raw.ceil().to_int() }
  let expected_half_width = z_score * (variance / samples.to_double()).sqrt()
  {
    expected_yield,
    confidence: 1.0 - 2.0 * (1.0 - normal_cdf(z_score)),
    margin,
    z_score,
    samples,
    expected_half_width,
  }
}

// Abramowitz-Stegun-style approximation sufficient for planning output.

///|
fn normal_cdf(value : Double) -> Double {
  let absolute = value.abs()
  let t = 1.0 / (1.0 + 0.2316419 * absolute)
  let polynomial = (
      (((1.330274429 * t - 1.821255978) * t + 1.781477937) * t - 0.356563782) *
      t +
      0.319381530
    ) *
    t
  let density = 0.3989422804014327 * @math.exp(-0.5 * absolute * absolute)
  let upper = density * polynomial
  if value >= 0.0 {
    1.0 - upper
  } else {
    upper
  }
}

///|
/// Worst-case and RSS feasibility against one acceptance window.
pub struct FeasibilityReport {
  nominal : Double
  window : AcceptanceWindow
  worst_case_interval : Interval
  rss_interval : Interval
  worst_case_margin : Double
  rss_margin : Double
  worst_case_passes : Bool
  rss_passes : Bool
} derive(Debug, Eq)

///|
fn interval_acceptance_margin(
  interval : Interval,
  window : AcceptanceWindow,
) -> Double {
  let lower_margin = interval.lower - window.lower
  let upper_margin = window.upper - interval.upper
  if lower_margin < upper_margin {
    lower_margin
  } else {
    upper_margin
  }
}

///|
/// Compare conservative worst-case and three-sigma RSS intervals.
pub fn feasibility_report(
  chain : Chain,
  window : AcceptanceWindow,
) -> FeasibilityReport {
  let worst_case = chain_interval(chain)
  let rss_result = chain.rss()
  let rss = Interval::new(rss_result.lower, rss_result.upper)
  let worst_case_margin = interval_acceptance_margin(worst_case, window)
  let rss_margin = interval_acceptance_margin(rss, window)
  {
    nominal: chain.nominal(),
    window,
    worst_case_interval: worst_case,
    rss_interval: rss,
    worst_case_margin,
    rss_margin,
    worst_case_passes: worst_case_margin >= 0.0,
    rss_passes: rss_margin >= 0.0,
  }
}

///|
/// Return the maximum RSS standard deviation allowed by a window at a coverage factor.
pub fn required_rss_budget(
  chain : Chain,
  window : AcceptanceWindow,
  coverage_factor : Double,
) -> Double {
  if coverage_factor <= 0.0 {
    abort("RSS coverage factor must be positive")
  }
  let nominal = chain.nominal()
  let lower = nominal - window.lower
  let upper = window.upper - nominal
  let available = if lower < upper { lower } else { upper }
  if available <= 0.0 {
    0.0
  } else {
    available / coverage_factor
  }
}

///|
/// Return whether a proposed RSS standard deviation meets a window.
pub fn rss_budget_is_feasible(
  chain : Chain,
  window : AcceptanceWindow,
  standard_deviation : Double,
  coverage_factor : Double,
) -> Bool {
  standard_deviation <= required_rss_budget(chain, window, coverage_factor)
}
