///|
pub enum Distribution {
  Uniform
  Triangular
  NormalApproximation
} derive(Debug, Eq)

///|
pub struct SamplingPolicy {
  distribution : Distribution
  sigma_factor : Double
  seed : UInt
} derive(Debug)

///|
pub fn SamplingPolicy::new(
  distribution? : Distribution = Uniform,
  sigma_factor? : Double = 1.0,
  seed? : UInt = 1U,
) -> SamplingPolicy {
  if sigma_factor <= 0.0 {
    abort("sigma_factor must be positive")
  }
  { distribution, sigma_factor, seed }
}

///|
pub fn triangular_policy(seed? : UInt = 1U) -> SamplingPolicy {
  SamplingPolicy::new(distribution=Triangular, seed~)
}

///|
pub fn normal_approximation_policy(seed? : UInt = 1U) -> SamplingPolicy {
  SamplingPolicy::new(distribution=NormalApproximation, seed~)
}

///|
fn clamp_unit(value : Double) -> Double {
  if value < 0.0 {
    0.0
  } else if value > 1.0 {
    1.0
  } else {
    value
  }
}

///|
pub fn sample_deviation(
  policy : SamplingPolicy,
  unit : Double,
  tolerance : Double,
) -> Double {
  if tolerance < 0.0 {
    abort("tolerance must be non-negative")
  }
  let u = clamp_unit(unit)
  match policy.distribution {
    Uniform => (u * 2.0 - 1.0) * tolerance
    Triangular =>
      if u < 0.5 {
        ((2.0 * u).sqrt() - 1.0) * tolerance
      } else {
        (1.0 - (2.0 - 2.0 * u).sqrt()) * tolerance
      }
    NormalApproximation => {
      // Twelve centered uniforms are a deterministic bounded normal proxy.
      let centered = (u * 2.0 - 1.0) * 3.4641016151377544
      centered * tolerance / policy.sigma_factor
    }
  }
}

///|
pub fn deterministic_uniform(seed : UInt) -> (UInt, Double) {
  let next = seed * 1664525U + 1013904223U
  (next, next.to_double() / 4294967295.0)
}

///|
pub fn sample_deviation_with_state(
  policy : SamplingPolicy,
  state : UInt,
  tolerance : Double,
) -> (UInt, Double) {
  if tolerance < 0.0 {
    abort("tolerance must be non-negative")
  }
  match policy.distribution {
    Uniform | Triangular => {
      let (next, unit) = deterministic_uniform(state)
      (next, sample_deviation(policy, unit, tolerance))
    }
    NormalApproximation => {
      // The Irwin-Hall construction uses twelve uniforms and has unit variance.
      let mut current = state
      let mut total = 0.0
      for _ in 0..<12 {
        let (next, unit) = deterministic_uniform(current)
        current = next
        total += unit
      }
      let standard_normal = total - 6.0
      (current, standard_normal * tolerance / policy.sigma_factor)
    }
  }
}

///|
pub fn sample_sequence(
  policy : SamplingPolicy,
  count : Int,
  tolerance : Double,
) -> Array[Double] {
  if count < 0 {
    abort("count must be non-negative")
  }
  let values = []
  let mut state = policy.seed
  for _ in 0..<count {
    let (next, value) = sample_deviation_with_state(policy, state, tolerance)
    state = next
    values.push(value)
  }
  values
}

///|
pub struct ProcessCapability {
  lower_spec : Double
  upper_spec : Double
  mean : Double
  standard_deviation : Double
} derive(Debug)

///|
pub fn ProcessCapability::new(
  lower_spec : Double,
  upper_spec : Double,
  mean : Double,
  standard_deviation : Double,
) -> ProcessCapability {
  if upper_spec < lower_spec {
    abort("upper_spec must not be below lower_spec")
  }
  if standard_deviation <= 0.0 {
    abort("standard_deviation must be positive")
  }
  { lower_spec, upper_spec, mean, standard_deviation }
}

///|
pub fn ProcessCapability::cp(self : ProcessCapability) -> Double {
  (self.upper_spec - self.lower_spec) / (6.0 * self.standard_deviation)
}

///|
pub fn ProcessCapability::cpu(self : ProcessCapability) -> Double {
  (self.upper_spec - self.mean) / (3.0 * self.standard_deviation)
}

///|
pub fn ProcessCapability::cpl(self : ProcessCapability) -> Double {
  (self.mean - self.lower_spec) / (3.0 * self.standard_deviation)
}

///|
pub fn ProcessCapability::cpk(self : ProcessCapability) -> Double {
  let cpu = self.cpu()
  let cpl = self.cpl()
  if cpu < cpl {
    cpu
  } else {
    cpl
  }
}
