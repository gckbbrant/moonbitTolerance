///|
/// The three practical fit outcomes for a hole and shaft pair.
pub enum FitClassification {
  Clearance
  Transition
  Interference
} derive(Debug, Eq)

///|
/// Worst-case clearance analysis for a cylindrical fit.
pub struct FitAnalysis {
  hole_nominal : Double
  shaft_nominal : Double
  nominal_clearance : Double
  minimum_clearance : Double
  maximum_clearance : Double
  classification : FitClassification
} derive(Debug, Eq)

///|
/// Classify a clearance interval by its position relative to zero.
pub fn classify_clearance(clearance : Interval) -> FitClassification {
  if clearance.lower > 0.0 {
    Clearance
  } else if clearance.upper < 0.0 {
    Interference
  } else {
    Transition
  }
}

///|
/// Analyze the complete worst-case range of a hole and shaft fit.
pub fn analyze_fit(hole : Dimension, shaft : Dimension) -> FitAnalysis {
  let nominal_clearance = hole.nominal - shaft.nominal
  let total_tolerance = hole.tolerance + shaft.tolerance
  let minimum_clearance = nominal_clearance - total_tolerance
  let maximum_clearance = nominal_clearance + total_tolerance
  let clearance = Interval::new(minimum_clearance, maximum_clearance)
  {
    hole_nominal: hole.nominal,
    shaft_nominal: shaft.nominal,
    nominal_clearance,
    minimum_clearance,
    maximum_clearance,
    classification: classify_clearance(clearance),
  }
}

///|
/// Return the complete clearance interval for a fit.
pub fn FitAnalysis::clearance(self : FitAnalysis) -> Interval {
  Interval::new(self.minimum_clearance, self.maximum_clearance)
}

///|
/// Return whether every possible fit outcome lies in the requested interval.
pub fn FitAnalysis::accepts(self : FitAnalysis, requested : Interval) -> Bool {
  self.minimum_clearance >= requested.lower &&
  self.maximum_clearance <= requested.upper
}

///|
/// Return the signed margin to the requested clearance interval.
pub fn FitAnalysis::margin(self : FitAnalysis, requested : Interval) -> Double {
  let lower_margin = self.minimum_clearance - requested.lower
  let upper_margin = requested.upper - self.maximum_clearance
  if lower_margin < upper_margin {
    lower_margin
  } else {
    upper_margin
  }
}

///|
/// Return whether the fit guarantees at least the requested clearance.
pub fn FitAnalysis::guarantees_clearance(
  self : FitAnalysis,
  minimum : Double,
) -> Bool {
  self.minimum_clearance >= minimum
}

///|
/// Return whether the fit guarantees no more than the requested clearance.
pub fn FitAnalysis::limits_clearance(
  self : FitAnalysis,
  maximum : Double,
) -> Bool {
  self.maximum_clearance <= maximum
}

///|
/// A named assembly fit requirement for batch evaluation.
pub struct FitRequirement {
  name : String
  minimum_clearance : Double
  maximum_clearance : Double
} derive(Debug, Eq)

///|
/// Create a fit requirement with explicit lower and upper bounds.
pub fn FitRequirement::new(
  name : String,
  minimum_clearance : Double,
  maximum_clearance : Double,
) -> FitRequirement {
  if maximum_clearance < minimum_clearance {
    abort("fit requirement maximum must not be below minimum")
  }
  { name, minimum_clearance, maximum_clearance }
}

///|
/// Evaluate a fit against a named requirement.
pub fn FitRequirement::evaluate(
  self : FitRequirement,
  fit : FitAnalysis,
) -> ConstraintStatus {
  let requested = Interval::new(self.minimum_clearance, self.maximum_clearance)
  if fit.accepts(requested) {
    Satisfied
  } else if fit.clearance().intersects(requested) {
    Inconclusive
  } else {
    Violated
  }
}

///|
/// Summarize a collection of fit requirements for one analyzed fit.
pub struct FitRequirementReport {
  passed : Int
  failed : Int
  inconclusive : Int
  statuses : Array[(String, ConstraintStatus)]
} derive(Debug, Eq)

///|
/// Evaluate all requirements while preserving their names.
pub fn evaluate_fit_requirements(
  fit : FitAnalysis,
  requirements : Array[FitRequirement],
) -> FitRequirementReport {
  let mut passed = 0
  let mut failed = 0
  let mut inconclusive = 0
  let statuses = requirements.map(requirement => {
    let status = requirement.evaluate(fit)
    match status {
      Satisfied => passed += 1
      Violated => failed += 1
      Inconclusive => inconclusive += 1
    }
    (requirement.name, status)
  })
  { passed, failed, inconclusive, statuses }
}
