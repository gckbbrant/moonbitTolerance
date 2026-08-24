///|
fn csv_number(value : Double) -> String {
  "\{value}"
}

///|
pub fn simulation_to_csv(summary : SimulationSummary) -> String {
  let builder = StringBuilder()
  builder.write_string(
    "nominal,minimum,maximum,mean,standard_deviation,yield_rate,samples\n",
  )
  builder.write_string(csv_number(summary.nominal))
  builder.write_string(",")
  builder.write_string(csv_number(summary.minimum))
  builder.write_string(",")
  builder.write_string(csv_number(summary.maximum))
  builder.write_string(",")
  builder.write_string(csv_number(summary.mean))
  builder.write_string(",")
  builder.write_string(csv_number(summary.standard_deviation))
  builder.write_string(",")
  builder.write_string(csv_number(summary.yield_rate))
  builder.write_string(",")
  builder.write_string("\{summary.samples}\n")
  builder.to_string()
}

///|
pub fn capability_to_csv(report : CapabilityReport) -> String {
  let builder = StringBuilder()
  builder.write_string("cp,cpu,cpl,cpk,observed_yield,count\n")
  builder.write_string("\{report.cp},\{report.cpu},\{report.cpl},")
  builder.write_string("\{report.cpk},\{report.observed_yield},")
  builder.write_string("\{report.statistics.count}\n")
  builder.to_string()
}

///|
/// Serialize a scenario result for downstream comparison reports.
pub fn scenario_to_csv(result : ScenarioResult) -> String {
  let builder = StringBuilder()
  builder.write_string(
    "name,nominal,lower,upper,mean,standard_deviation,yield_rate\n",
  )
  builder.write_string(result.name)
  builder.write_string(",")
  builder.write_string("\{result.nominal},\{result.lower},\{result.upper},")
  builder.write_string("\{result.mean},\{result.standard_deviation},")
  builder.write_string("\{result.yield_rate}\n")
  builder.to_string()
}

///|
/// Serialize histogram bins as a stable CSV table.
pub fn histogram_to_csv(value : Histogram) -> String {
  let builder = StringBuilder()
  builder.write_string("lower,upper,count\n")
  for bin in value.bins {
    builder.write_string("\{bin.lower},\{bin.upper},\{bin.count}\n")
  }
  builder.to_string()
}

///|
/// Serialize an allocation plan as a stable CSV table.
pub fn allocation_to_csv(report : AllocationReport) -> String {
  let builder = StringBuilder()
  builder.write_string("name,nominal,allocated_tolerance,variance_fraction\n")
  for item in report.items {
    builder.write_string(
      "\{item.name},\{item.nominal},\{item.allocated_tolerance},\{item.variance_fraction}\n",
    )
  }
  builder.to_string()
}

///|
/// Serialize uncertainty contributions as a stable CSV table.
pub fn uncertainty_to_csv(budget : UncertaintyBudget) -> String {
  let builder = StringBuilder()
  builder.write_string("name,effective_uncertainty,variance,fraction\n")
  for contributor in budget.contributors {
    builder.write_string(
      "\{contributor.name},\{contributor.effective_uncertainty},\{contributor.variance},\{contributor.fraction}\n",
    )
  }
  builder.to_string()
}

///|
/// Serialize the complete fit range and classification.
pub fn fit_to_csv(fit : FitAnalysis) -> String {
  let builder = StringBuilder()
  builder.write_string(
    "hole_nominal,shaft_nominal,nominal_clearance,minimum_clearance,maximum_clearance\n",
  )
  builder.write_string(
    "\{fit.hole_nominal},\{fit.shaft_nominal},\{fit.nominal_clearance},\{fit.minimum_clearance},\{fit.maximum_clearance}\n",
  )
  builder.to_string()
}
