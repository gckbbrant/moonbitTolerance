///|
pub enum ConstraintStatus {
  Satisfied
  Violated
  Inconclusive
} derive(Debug, Eq)

///|
pub struct GapConstraint {
  name : String
  minimum : Double
  maximum : Double
} derive(Debug)

///|
pub fn GapConstraint::new(
  name : String,
  minimum : Double,
  maximum : Double,
) -> GapConstraint {
  if maximum < minimum {
    abort("maximum must not be below minimum")
  }
  { name, minimum, maximum }
}

///|
pub fn GapConstraint::evaluate(
  self : GapConstraint,
  result : AnalysisResult,
) -> ConstraintStatus {
  if result.lower >= self.minimum && result.upper <= self.maximum {
    Satisfied
  } else if result.upper < self.minimum || result.lower > self.maximum {
    Violated
  } else {
    Inconclusive
  }
}

///|
pub struct ConstraintReport {
  passed : Int
  failed : Int
  inconclusive : Int
  statuses : Array[(String, ConstraintStatus)]
} derive(Debug)

///|
pub fn evaluate_constraints(
  result : AnalysisResult,
  constraints : Array[GapConstraint],
) -> ConstraintReport {
  let mut passed = 0
  let mut failed = 0
  let mut inconclusive = 0
  let statuses = constraints.map(c => {
    let status = c.evaluate(result)
    match status {
      Satisfied => passed += 1
      Violated => failed += 1
      Inconclusive => inconclusive += 1
    }
    (c.name, status)
  })
  { passed, failed, inconclusive, statuses }
}

///|
pub fn interval_contains(result : AnalysisResult, value : Double) -> Bool {
  value >= result.lower && value <= result.upper
}

///|
pub fn interval_width(result : AnalysisResult) -> Double {
  result.upper - result.lower
}

///|
pub fn result_to_csv(result : AnalysisResult) -> String {
  let header = "nominal,lower,upper,mean,standard_deviation,yield_rate\n"
  let values = "\{result.nominal},\{result.lower},\{result.upper},\{result.mean},"
  let tail = "\{result.standard_deviation},\{result.yield_rate}\n"
  header + values + tail
}
