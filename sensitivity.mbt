///|
pub struct SensitivityItem {
  name : String
  contribution : Double
  fraction : Double
} derive(Debug, Eq)

///|
pub fn sensitivity_items(result : AnalysisResult) -> Array[SensitivityItem] {
  let mut total = 0.0
  for item in result.sensitivity {
    total += item.1.abs()
  }
  let items = result.sensitivity.map(item => {
    let contribution = item.1.abs()
    let fraction = if total == 0.0 { 0.0 } else { contribution / total }
    { name: item.0, contribution, fraction }
  })
  for index in 1..<items.length() {
    let current = items[index]
    let mut position = index
    while position > 0 &&
          items[position - 1].contribution < current.contribution {
      items[position] = items[position - 1]
      position -= 1
    }
    items[position] = current
  }
  items
}

///|
pub fn equal_rss_budget(
  chain : Chain,
  total_rss : Double,
) -> Array[(String, Double)] {
  if total_rss < 0.0 {
    abort("total RSS budget must be non-negative")
  }
  let count = chain.dimensions.length()
  if count == 0 {
    abort("cannot allocate a budget to an empty chain")
  }
  let each = total_rss / count.to_double().sqrt()
  chain.dimensions.map(d => (d.name, each))
}
