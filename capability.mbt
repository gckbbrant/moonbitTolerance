///|
pub struct CapabilityReport {
  statistics : SampleStatistics
  cp : Double
  cpu : Double
  cpl : Double
  cpk : Double
  observed_yield : Double
} derive(Debug, Eq)

///|
pub fn capability_report(
  values : Array[Double],
  window : AcceptanceWindow,
) -> CapabilityReport {
  let statistics = summarize_samples(values)
  let standard_deviation = statistics.standard_deviation
  let capability = if standard_deviation == 0.0 {
    None
  } else {
    Some(
      ProcessCapability::new(
        window.lower,
        window.upper,
        statistics.mean,
        standard_deviation,
      ),
    )
  }
  let (cp, cpu, cpl, cpk) = match capability {
    None => {
      let inside = window.contains(statistics.mean)
      let value = if inside { 1.0e308 } else { 0.0 }
      (value, value, value, value)
    }
    Some(capability) =>
      (capability.cp(), capability.cpu(), capability.cpl(), capability.cpk())
  }
  let mut passed = 0
  for value in values {
    if window.contains(value) {
      passed += 1
    }
  }
  {
    statistics,
    cp,
    cpu,
    cpl,
    cpk,
    observed_yield: passed.to_double() / statistics.count.to_double(),
  }
}
