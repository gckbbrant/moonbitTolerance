///|
/// Strategies for distributing a total RSS tolerance budget.
pub enum AllocationStrategy {
  Equal
  Proportional
  Sensitivity
} derive(Debug, Eq)

///|
/// Create an equal-contribution allocation strategy.
pub fn equal_allocation() -> AllocationStrategy {
  Equal
}

///|
/// Create a strategy proportional to each current tolerance.
pub fn proportional_allocation() -> AllocationStrategy {
  Proportional
}

///|
/// Create a strategy that emphasizes contributors with larger variance.
pub fn sensitivity_allocation() -> AllocationStrategy {
  Sensitivity
}

///|
/// One allocated dimension in a tolerance budget plan.
pub struct AllocationItem {
  name : String
  nominal : Double
  allocated_tolerance : Double
  variance_fraction : Double
  weight : Double
} derive(Debug, Eq)

///|
/// A complete RSS allocation and its resulting worst-case span.
pub struct AllocationReport {
  items : Array[AllocationItem]
  total_nominal : Double
  total_rss : Double
  worst_case_span : Double
  strategy : AllocationStrategy
} derive(Debug, Eq)

///|
fn allocation_weight(
  dimension : Dimension,
  strategy : AllocationStrategy,
) -> Double {
  match strategy {
    Equal => 1.0
    Proportional => dimension.tolerance
    Sensitivity => dimension.tolerance * dimension.tolerance
  }
}

///|
fn sum_squared(values : Array[Double]) -> Double {
  let mut total = 0.0
  for value in values {
    total += value * value
  }
  total
}

///|
fn allocation_total_nominal(chain : Chain) -> Double {
  chain.nominal()
}

///|
/// Allocate an RSS budget while preserving contributor names and nominal values.
pub fn allocate_chain(
  chain : Chain,
  total_rss : Double,
  strategy : AllocationStrategy,
) -> AllocationReport {
  if total_rss < 0.0 {
    abort("total RSS budget must be non-negative")
  }
  let weights = chain.dimensions.map(d => allocation_weight(d, strategy))
  let squared = sum_squared(weights)
  let effective_weights = if squared == 0.0 {
    weights.map(_ => 1.0)
  } else {
    weights
  }
  let normalizer = sum_squared(effective_weights).sqrt()
  let scale = if normalizer == 0.0 { 0.0 } else { total_rss / normalizer }
  let total_variance = total_rss * total_rss
  let items = []
  let mut worst_case_span = 0.0
  for index in 0..<chain.dimensions.length() {
    let dimension = chain.dimensions[index]
    let weight = effective_weights[index]
    let allocated = weight * scale
    let contribution = allocated * allocated
    let fraction = if total_variance == 0.0 {
      0.0
    } else {
      contribution / total_variance
    }
    worst_case_span += allocated
    items.push({
      name: dimension.name,
      nominal: signed_nominal(dimension),
      allocated_tolerance: allocated,
      variance_fraction: fraction,
      weight,
    })
  }
  {
    items,
    total_nominal: allocation_total_nominal(chain),
    total_rss: sum_squared(items.map(item => item.allocated_tolerance)).sqrt(),
    worst_case_span,
    strategy,
  }
}

///|
/// Return the conservative interval resulting from an allocation plan.
pub fn AllocationReport::interval(self : AllocationReport) -> Interval {
  Interval::new(
    self.total_nominal - self.worst_case_span,
    self.total_nominal + self.worst_case_span,
  )
}

///|
/// Return the largest allocated contributor.
pub fn AllocationReport::largest_contributor(
  self : AllocationReport,
) -> AllocationItem {
  let mut largest = self.items[0]
  for item in self.items {
    if item.allocated_tolerance > largest.allocated_tolerance {
      largest = item
    }
  }
  largest
}

///|
/// Allocate the same tolerance to every contributor for a requested RSS budget.
pub fn equal_tolerance_for_budget(
  chain : Chain,
  total_rss : Double,
) -> AllocationReport {
  allocate_chain(chain, total_rss, Equal)
}

///|
/// Allocate the requested RSS budget according to current tolerance sensitivity.
pub fn sensitivity_tolerance_for_budget(
  chain : Chain,
  total_rss : Double,
) -> AllocationReport {
  allocate_chain(chain, total_rss, Sensitivity)
}
