///|
/// One contributor in a tolerance-tightening recommendation.
pub struct TighteningItem {
  name : String
  current_tolerance : Double
  proposed_tolerance : Double
  expected_reduction : Double
  priority : Double
} derive(Debug, Eq)

///|
/// A ranked plan for reducing a chain's RSS variation.
pub struct TighteningPlan {
  current_rss : Double
  target_rss : Double
  projected_rss : Double
  items : Array[TighteningItem]
} derive(Debug, Eq)

///|
fn tightening_priority(current : Double, proposed : Double) -> Double {
  if current == 0.0 {
    0.0
  } else {
    (current - proposed) / current
  }
}

///|
fn sort_tightening_items(
  items : Array[TighteningItem],
) -> Array[TighteningItem] {
  for index in 1..<items.length() {
    let current = items[index]
    let mut position = index
    while position > 0 &&
          items[position - 1].expected_reduction < current.expected_reduction {
      items[position] = items[position - 1]
      position -= 1
    }
    items[position] = current
  }
  items
}

///|
/// Recommend the contributors that most efficiently reduce RSS variation.
pub fn propose_tightening(
  chain : Chain,
  target_rss : Double,
  max_changes : Int,
) -> Array[TighteningItem] {
  if target_rss < 0.0 {
    abort("target RSS must be non-negative")
  }
  if max_changes <= 0 {
    abort("maximum tightening changes must be positive")
  }
  let current_rss = chain.rss().standard_deviation
  let scale = if current_rss == 0.0 || target_rss >= current_rss {
    1.0
  } else {
    target_rss / current_rss
  }
  let all_items = chain.dimensions.map(dimension => {
    let current = dimension.tolerance
    let proposed = current * scale
    {
      name: dimension.name,
      current_tolerance: current,
      proposed_tolerance: proposed,
      expected_reduction: current - proposed,
      priority: tightening_priority(current, proposed),
    }
  })
  let ranked = sort_tightening_items(all_items)
  let count = if max_changes < ranked.length() {
    max_changes
  } else {
    ranked.length()
  }
  let result = []
  for index in 0..<count {
    result.push(ranked[index])
  }
  result
}

///|
/// Return a complete tightening plan, including unchanged contributors.
pub fn tightening_plan(chain : Chain, target_rss : Double) -> TighteningPlan {
  let current_rss = chain.rss().standard_deviation
  let scale = if current_rss == 0.0 || target_rss >= current_rss {
    1.0
  } else {
    target_rss / current_rss
  }
  let items = chain.dimensions.map(dimension => {
    let proposed = dimension.tolerance * scale
    {
      name: dimension.name,
      current_tolerance: dimension.tolerance,
      proposed_tolerance: proposed,
      expected_reduction: dimension.tolerance - proposed,
      priority: tightening_priority(dimension.tolerance, proposed),
    }
  })
  {
    current_rss,
    target_rss,
    projected_rss: current_rss * scale,
    items: sort_tightening_items(items),
  }
}

///|
/// Return the sum of squared proposed tolerances in a plan.
pub fn TighteningPlan::projected_variance(self : TighteningPlan) -> Double {
  let mut variance = 0.0
  for item in self.items {
    variance += item.proposed_tolerance * item.proposed_tolerance
  }
  variance
}

///|
/// Return the largest proposed tolerance change.
pub fn TighteningPlan::largest_reduction(
  self : TighteningPlan,
) -> TighteningItem {
  self.items[0]
}
