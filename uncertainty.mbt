///|
/// One independent uncertainty source and its local sensitivity.
pub struct UncertaintySource {
  name : String
  standard_uncertainty : Double
  sensitivity : Double
} derive(Debug, Eq)

///|
/// Construct an uncertainty source.
pub fn UncertaintySource::new(
  name : String,
  standard_uncertainty : Double,
  sensitivity : Double,
) -> UncertaintySource {
  if standard_uncertainty < 0.0 {
    abort("standard uncertainty must be non-negative")
  }
  { name, standard_uncertainty, sensitivity }
}

///|
/// One propagated contribution in an uncertainty budget.
pub struct UncertaintyContribution {
  name : String
  effective_uncertainty : Double
  variance : Double
  fraction : Double
} derive(Debug, Eq)

///|
/// Combined RSS uncertainty and its named contributors.
pub struct UncertaintyBudget {
  contributors : Array[UncertaintyContribution]
  combined : Double
  total_variance : Double
} derive(Debug, Eq)

///|
/// Combine independent uncertainty sources by root-sum-square propagation.
pub fn uncertainty_budget(
  sources : Array[UncertaintySource],
) -> UncertaintyBudget {
  if sources.length() == 0 {
    abort("uncertainty budget must contain at least one source")
  }
  let effective = sources.map(source => {
    source.standard_uncertainty * source.sensitivity
  })
  let mut total_variance = 0.0
  for value in effective {
    total_variance += value * value
  }
  let combined = total_variance.sqrt()
  let contributors = sources.map(source => {
    let value = source.standard_uncertainty * source.sensitivity
    let variance = value * value
    let fraction = if total_variance == 0.0 {
      0.0
    } else {
      variance / total_variance
    }
    { name: source.name, effective_uncertainty: value, variance, fraction }
  })
  { contributors, combined, total_variance }
}

///|
/// Return a symmetric interval at a requested coverage multiplier.
pub fn UncertaintyBudget::interval(
  self : UncertaintyBudget,
  nominal : Double,
  coverage_factor : Double,
) -> Interval {
  if coverage_factor < 0.0 {
    abort("uncertainty coverage factor must be non-negative")
  }
  let margin = self.combined * coverage_factor
  Interval::new(nominal - margin, nominal + margin)
}

///|
/// Return the largest effective uncertainty contributor.
pub fn UncertaintyBudget::largest(
  self : UncertaintyBudget,
) -> UncertaintyContribution {
  let mut largest = self.contributors[0]
  for contributor in self.contributors {
    if contributor.variance > largest.variance {
      largest = contributor
    }
  }
  largest
}

///|
/// Return contributors ordered by variance fraction.
pub fn UncertaintyBudget::ranked(
  self : UncertaintyBudget,
) -> Array[UncertaintyContribution] {
  let result = self.contributors
  for index in 1..<result.length() {
    let current = result[index]
    let mut position = index
    while position > 0 && result[position - 1].fraction < current.fraction {
      result[position] = result[position - 1]
      position -= 1
    }
    result[position] = current
  }
  result
}

///|
/// Calculate the reduction in combined uncertainty after removing a source.
pub fn uncertainty_without(
  budget : UncertaintyBudget,
  source_name : String,
) -> Double {
  let mut remaining_variance = budget.total_variance
  for contributor in budget.contributors {
    if contributor.name == source_name {
      remaining_variance -= contributor.variance
    }
  }
  if remaining_variance <= 0.0 {
    0.0
  } else {
    remaining_variance.sqrt()
  }
}
