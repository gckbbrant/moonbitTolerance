///|
/// A datum label and its precedence in a datum reference frame.
pub struct DatumReference {
  label : String
  order : Int
} derive(Debug, Eq)

///|
/// Create a datum reference. Orders are normally one, two, and three.
pub fn DatumReference::new(label : String, order : Int) -> DatumReference {
  if order < 0 {
    abort("datum order must not be negative")
  }
  { label, order }
}

///|
/// A primary/secondary/tertiary datum reference frame.
pub struct DatumFrame {
  primary : DatumReference
  secondary : DatumReference
  tertiary : DatumReference
} derive(Debug, Eq)

///|
/// Construct a complete datum frame.
pub fn DatumFrame::new(
  primary : DatumReference,
  secondary : DatumReference,
  tertiary : DatumReference,
) -> DatumFrame {
  { primary, secondary, tertiary }
}

///|
/// Construct a frame containing only a primary datum.
pub fn DatumFrame::single(primary : DatumReference) -> DatumFrame {
  {
    primary,
    secondary: DatumReference::new("", 0),
    tertiary: DatumReference::new("", 0),
  }
}

///|
/// Return whether all three datum slots contain labels.
pub fn DatumFrame::is_complete(self : DatumFrame) -> Bool {
  self.primary.label != "" &&
  self.secondary.label != "" &&
  self.tertiary.label != ""
}

///|
/// Return a compact datum-frame label for reports.
pub fn DatumFrame::label(self : DatumFrame) -> String {
  if self.secondary.label == "" {
    self.primary.label
  } else if self.tertiary.label == "" {
    self.primary.label + "|" + self.secondary.label
  } else {
    self.primary.label + "|" + self.secondary.label + "|" + self.tertiary.label
  }
}

///|
/// A geometric characteristic attached to a datum frame.
pub struct FeatureControlFrame {
  mode : GeometricMode
  tolerance : Double
  datum_frame : DatumFrame
} derive(Debug, Eq)

///|
/// Create a position control frame.
pub fn FeatureControlFrame::position(
  tolerance : Double,
  datum_frame : DatumFrame,
) -> FeatureControlFrame {
  { mode: Position, tolerance, datum_frame }
}

///|
/// Create a concentricity control frame.
pub fn FeatureControlFrame::concentricity(
  tolerance : Double,
  datum_frame : DatumFrame,
) -> FeatureControlFrame {
  { mode: Concentricity, tolerance, datum_frame }
}

///|
/// Create a circular runout control frame.
pub fn FeatureControlFrame::runout(
  tolerance : Double,
  datum_frame : DatumFrame,
) -> FeatureControlFrame {
  { mode: Runout, tolerance, datum_frame }
}

///|
/// A measured feature center or radial reference.
pub struct FeatureMeasurement {
  name : String
  nominal : Vector2
  measured : Vector2
} derive(Debug, Eq)

///|
/// Create a measured feature record.
pub fn FeatureMeasurement::new(
  name : String,
  nominal : Vector2,
  measured : Vector2,
) -> FeatureMeasurement {
  { name, nominal, measured }
}

///|
/// Evaluation of one feature-control frame.
pub struct FeatureEvaluation {
  name : String
  status : ConstraintStatus
  deviation : Double
  margin : Double
  datum_label : String
} derive(Debug, Eq)

///|
/// Evaluate a measured feature against its control frame.
pub fn evaluate_feature(
  control : FeatureControlFrame,
  measurement : FeatureMeasurement,
) -> FeatureEvaluation {
  let tolerance = GeometricTolerance::new(control.mode, control.tolerance)
  let difference = measurement.measured.sub(measurement.nominal)
  let deviation = match control.mode {
    Position | Concentricity => difference.length()
    Runout =>
      (measurement.measured.length() - measurement.nominal.length()).abs()
  }
  let status = tolerance.evaluate(measurement.measured, measurement.nominal)
  {
    name: measurement.name,
    status,
    deviation,
    margin: control.tolerance - deviation,
    datum_label: control.datum_frame.label(),
  }
}

///|
/// Aggregate feature-control evaluations for a measurement batch.
pub struct FeatureEvaluationReport {
  total : Int
  passed : Int
  failed : Int
  evaluations : Array[FeatureEvaluation]
} derive(Debug, Eq)

///|
/// Evaluate corresponding controls and measurements in order.
pub fn evaluate_features(
  controls : Array[FeatureControlFrame],
  measurements : Array[FeatureMeasurement],
) -> FeatureEvaluationReport {
  if controls.length() != measurements.length() {
    abort("feature controls and measurements must have equal lengths")
  }
  let evaluations = []
  let mut passed = 0
  let mut failed = 0
  for index in 0..<controls.length() {
    let evaluation = evaluate_feature(controls[index], measurements[index])
    match evaluation.status {
      Satisfied => passed += 1
      _ => failed += 1
    }
    evaluations.push(evaluation)
  }
  { total: evaluations.length(), passed, failed, evaluations }
}
