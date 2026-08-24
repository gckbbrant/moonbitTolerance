///|
pub struct BenchmarkCase {
  name : String
  dimensions : Int
  tolerance : Double
  seed : UInt
} derive(Debug)

///|
pub fn BenchmarkCase::chain(self : BenchmarkCase) -> Chain {
  let dimensions = []
  for index in 0..<self.dimensions {
    dimensions.push(
      Dimension::new(
        "d{index}",
        (index + 1).to_double() * 0.75,
        self.tolerance,
        direction=if index % 2 == 0 { Positive } else { Negative },
      ),
    )
  }
  Chain::new(self.name, dimensions)
}

///|
pub fn run_benchmark_case(
  case : BenchmarkCase,
  samples : Int,
) -> AnalysisResult {
  case.chain().monte_carlo(samples, seed=case.seed)
}

///|
pub fn run_acceptance_benchmark_case(
  case : BenchmarkCase,
  samples : Int,
) -> SimulationSummary {
  let chain = case.chain()
  let nominal = chain.nominal()
  let half_width = case.tolerance * case.dimensions.to_double().sqrt() * 0.8
  let window = AcceptanceWindow::new(nominal - half_width, nominal + half_width)
  chain.simulate(samples, SamplingPolicy::new(seed=case.seed), window)
}

///|
pub fn benchmark_suite() -> Array[BenchmarkCase] {
  [
    { name: "small-fit", dimensions: 4, tolerance: 0.02, seed: 11U },
    { name: "bearing-seat", dimensions: 8, tolerance: 0.01, seed: 17U },
    { name: "housing-stack", dimensions: 16, tolerance: 0.025, seed: 23U },
    { name: "long-actuator", dimensions: 32, tolerance: 0.04, seed: 31U },
    { name: "precision-stage", dimensions: 64, tolerance: 0.005, seed: 47U },
  ]
}
