///|
fn main {
  let chain = @lib.Chain::new("demo", [
    @lib.Dimension::new("housing", 20.0, 0.05),
    @lib.Dimension::new("cover", 0.2, 0.02, direction=@lib.negative_direction()),
  ])
  let result = chain.rss()
  println("moonbitTolerance demo")
  println("nominal = \{result.nominal}")
  println("3-sigma interval = [\{result.lower}, \{result.upper}]")
  println("benchmark samples = 10000")
  for case in @lib.benchmark_suite() {
    let benchmark = @lib.run_acceptance_benchmark_case(case, 10000)
    println(
      "\{case.name}: mean=\{benchmark.mean}, sigma=\{benchmark.standard_deviation}, yield=\{benchmark.yield_rate}",
    )
  }
}
