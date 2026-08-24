///|
/// Analysis methods available to a repeatable engineering scenario.
pub enum ScenarioMethod {
  WorstCase
  RSS
  MonteCarlo
  AcceptanceSimulation
} derive(Debug, Eq)

///|
/// Select worst-case interval analysis.
pub fn worst_case_method() -> ScenarioMethod {
  WorstCase
}

///|
/// Select root-sum-square analysis.
pub fn rss_method() -> ScenarioMethod {
  RSS
}

///|
/// Select seeded Monte Carlo analysis.
pub fn monte_carlo_method() -> ScenarioMethod {
  MonteCarlo
}

///|
/// Select distribution-aware acceptance-window simulation.
pub fn acceptance_simulation_method() -> ScenarioMethod {
  AcceptanceSimulation
}

///|
/// Inputs for a named, reproducible analysis scenario.
pub struct ScenarioSpec {
  name : String
  chain : Chain
  analysis_method : ScenarioMethod
  samples : Int
  window : AcceptanceWindow
  policy : SamplingPolicy
} derive(Debug)

///|
/// Construct a scenario with a default seeded uniform sampling policy.
pub fn ScenarioSpec::new(
  name : String,
  chain : Chain,
  analysis_method : ScenarioMethod,
  samples : Int,
  window : AcceptanceWindow,
) -> ScenarioSpec {
  if samples <= 0 {
    abort("scenario sample count must be positive")
  }
  {
    name,
    chain,
    analysis_method,
    samples,
    window,
    policy: SamplingPolicy::new(seed=1U),
  }
}

///|
/// Replace the default policy while preserving the other scenario inputs.
pub fn ScenarioSpec::with_policy(
  self : ScenarioSpec,
  policy : SamplingPolicy,
) -> ScenarioSpec {
  { ..self, policy, }
}

///|
/// A normalized result independent of the selected analysis method.
pub struct ScenarioResult {
  name : String
  analysis_method : ScenarioMethod
  nominal : Double
  lower : Double
  upper : Double
  mean : Double
  standard_deviation : Double
  yield_rate : Double
  sensitivity : Array[(String, Double)]
} derive(Debug, Eq)

///|
fn scenario_from_analysis(
  spec : ScenarioSpec,
  result : AnalysisResult,
) -> ScenarioResult {
  {
    name: spec.name,
    analysis_method: spec.analysis_method,
    nominal: result.nominal,
    lower: result.lower,
    upper: result.upper,
    mean: result.mean,
    standard_deviation: result.standard_deviation,
    yield_rate: result.yield_rate,
    sensitivity: result.sensitivity,
  }
}

///|
fn scenario_from_simulation(
  spec : ScenarioSpec,
  result : SimulationSummary,
) -> ScenarioResult {
  {
    name: spec.name,
    analysis_method: spec.analysis_method,
    nominal: result.nominal,
    lower: result.minimum,
    upper: result.maximum,
    mean: result.mean,
    standard_deviation: result.standard_deviation,
    yield_rate: result.yield_rate,
    sensitivity: result.sensitivity,
  }
}

///|
/// Execute a scenario using its declared method and deterministic inputs.
pub fn run_scenario(spec : ScenarioSpec) -> ScenarioResult {
  match spec.analysis_method {
    WorstCase => scenario_from_analysis(spec, spec.chain.worst_case())
    RSS => scenario_from_analysis(spec, spec.chain.rss())
    MonteCarlo =>
      scenario_from_analysis(
        spec,
        spec.chain.monte_carlo(spec.samples, seed=spec.policy.seed),
      )
    AcceptanceSimulation =>
      scenario_from_simulation(
        spec,
        spec.chain.simulate(spec.samples, spec.policy, spec.window),
      )
  }
}

///|
/// Comparison of two normalized scenario outcomes.
pub struct ScenarioComparison {
  baseline_name : String
  candidate_name : String
  nominal_delta : Double
  standard_deviation_delta : Double
  yield_delta : Double
  interval_overlap : Bool
} derive(Debug, Eq)

///|
/// Compare nominal, variation, yield, and interval overlap between scenarios.
pub fn compare_scenarios(
  baseline : ScenarioResult,
  candidate : ScenarioResult,
) -> ScenarioComparison {
  {
    baseline_name: baseline.name,
    candidate_name: candidate.name,
    nominal_delta: candidate.nominal - baseline.nominal,
    standard_deviation_delta: candidate.standard_deviation -
    baseline.standard_deviation,
    yield_delta: candidate.yield_rate - baseline.yield_rate,
    interval_overlap: candidate.lower <= baseline.upper &&
    baseline.lower <= candidate.upper,
  }
}

///|
/// Return whether a scenario interval remains inside an acceptance window.
pub fn ScenarioResult::within_window(
  self : ScenarioResult,
  window : AcceptanceWindow,
) -> Bool {
  self.lower >= window.lower && self.upper <= window.upper
}

///|
/// Return the method-independent interval of a scenario result.
pub fn ScenarioResult::interval(self : ScenarioResult) -> Interval {
  Interval::new(self.lower, self.upper)
}
