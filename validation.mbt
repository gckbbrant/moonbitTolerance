///|
/// A non-throwing validation message for host applications.
pub struct ValidationIssue {
  scope : String
  message : String
} derive(Debug, Eq)

///|
/// Result of preflight validation before running an analysis.
pub struct ValidationReport {
  valid : Bool
  issue_count : Int
  issues : Array[ValidationIssue]
} derive(Debug, Eq)

///|
fn push_issue(
  issues : Array[ValidationIssue],
  scope : String,
  message : String,
) -> Unit {
  issues.push({ scope, message })
  ()
}

///|
/// Validate a dimension chain without aborting on the first issue.
pub fn validate_chain(chain : Chain) -> ValidationReport {
  let issues = []
  if chain.name == "" {
    push_issue(issues, "chain", "chain name is empty")
  }
  if chain.dimensions.length() == 0 {
    push_issue(issues, "chain", "chain has no dimensions")
  }
  for dimension in chain.dimensions {
    if dimension.name == "" {
      push_issue(issues, "dimension", "dimension name is empty")
    }
    if dimension.tolerance < 0.0 {
      push_issue(issues, dimension.name, "tolerance is negative")
    }
  }
  { valid: issues.length() == 0, issue_count: issues.length(), issues }
}

///|
/// Validate an acceptance window without modifying it.
pub fn validate_window(window : AcceptanceWindow) -> ValidationReport {
  let issues = []
  if window.upper < window.lower {
    push_issue(issues, "window", "upper bound is below lower bound")
  }
  { valid: issues.length() == 0, issue_count: issues.length(), issues }
}

///|
/// Validate a batch and its acceptance window before inspection.
pub fn validate_measurements(
  values : Array[Double],
  window : AcceptanceWindow,
) -> ValidationReport {
  let issues = []
  if values.length() == 0 {
    push_issue(issues, "measurements", "measurement batch is empty")
  }
  if window.upper < window.lower {
    push_issue(issues, "window", "upper bound is below lower bound")
  }
  { valid: issues.length() == 0, issue_count: issues.length(), issues }
}

///|
/// Combine validation reports from a chain and measurement batch.
pub fn combine_validation(
  first : ValidationReport,
  second : ValidationReport,
) -> ValidationReport {
  let issues = []
  issues.append(first.issues)
  issues.append(second.issues)
  { valid: issues.length() == 0, issue_count: issues.length(), issues }
}
