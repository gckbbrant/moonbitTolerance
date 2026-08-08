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
}
