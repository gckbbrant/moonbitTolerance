# moonbitTolerance

Deterministic mechanical tolerance stack-up analysis for MoonBit. The library is a reusable calculation kernel for CAD-adjacent tools, process planning, inspection software, and manufacturing data pipelines.

## Project positioning

`moonbitTolerance` keeps geometry, statistical assumptions, constraint evaluation, and reporting separate from any CAD file format. It is suitable when a host application needs reproducible one-dimensional or projected two-dimensional tolerance calculations with explicit assumptions.

## Core capabilities

- Signed one-dimensional dimension chains with worst-case, RSS, and seeded Monte Carlo analysis.
- Two-dimensional vector dimensions and projected stack-up intervals.
- Uniform, triangular, and bounded normal-approximation sampling policies.
- Process capability indices (`Cp`, `Cpu`, `Cpl`, and `Cpk`).
- Gap constraints with satisfied, violated, and inconclusive outcomes.
- CSV result export for small downstream reporting adapters.
- Acceptance-window simulation summaries with deterministic seeds.
- Conservative interval arithmetic, correlation-aware RSS propagation, and uncertainty budgets.
- Hole/shaft fit classification, datum-frame feature checks, specification reports, and gauge R&R studies.
- Scenario comparison, process trends, sample-size planning, tolerance allocation, and tightening recommendations.
- Millimeter/inch/micrometer normalization with engineering-safe reporting rounding.
- Native CLI demonstration and benchmark suite.

## Quick start

Requirements: MoonBit stable toolchain and a native-capable host for the CLI.

```bash
moon test --target wasm-gc --deny-warn
moon run cmd/main
```

```mbt
let chain = @moonbitTolerance.Chain::new("shaft", [
  @moonbitTolerance.Dimension::new("housing", 20.0, 0.05),
  @moonbitTolerance.Dimension::new(
    "cover", 0.2, 0.02,
    direction=@moonbitTolerance.negative_direction(),
  ),
])
let result = chain.monte_carlo(10000, seed=42U)
```

## CLI

`moon run cmd/main` prints a small RSS analysis and runs the deterministic benchmark suite. The CLI is intentionally a host-integration example; applications should import the root package and keep their own I/O boundary.

## Architecture

The root package owns the public engineering types. `tolerance.mbt` contains the one-dimensional kernel; `interval.mbt`, `geometry.mbt`, `matrix.mbt`, and `correlation.mbt` contain conservative numeric propagation; `distributions.mbt`, `simulation.mbt`, `scenario.mbt`, and `planning.mbt` contain deterministic analysis workflows; `statistics.mbt`, `engineering.mbt`, `measurement.mbt`, `capability.mbt`, and `process.mbt` contain inspection and process analytics; `assembly.mbt`, `gdt.mbt`, `geometric.mbt`, and `specification.mbt` contain manufacturing acceptance checks; `allocation.mbt`, `optimizer.mbt`, `uncertainty.mbt`, `units.mbt`, and `rounding.mbt` support design decisions and host integration. `reporting.mbt` and `validation.mbt` keep text output and preflight checks at the boundary. `cmd/main` is an executable consumer of the package.

## Benchmark

The benchmark suite uses the same public API as an application: five chains with 4, 8, 16, 32, and 64 contributors, each sampled with an explicit seed. Run it with:

```bash
moon run cmd/main
```

The output is deterministic for a fixed toolchain, sample count, and seed. The acceptance window is deliberately narrower than the physical worst-case interval so the benchmark exercises both passing and failing samples. The repository does not claim a hardware-independent throughput number; wall-clock measurements belong to the machine and backend that produced them.

## Testing

```bash
moon fmt --check
moon check --deny-warn
moon test --target wasm-gc --deny-warn
moon test --target native --deny-warn
moon info
```

Tests cover invalid-input guards, signed dimensions, deterministic sampling, distribution differences, acceptance-window yield, interval arithmetic, covariance and correlation propagation, quantiles, process capability edges, measurement studies, fit classification, datum-frame checks, trend analysis, allocation planning, units, reporting, and constraints.

## CI

GitHub Actions runs formatting, warning-free type checking, generated-interface drift detection, coverage analysis, wasm-gc tests, and native tests on Linux, macOS, and Windows. The workflow installs the current MoonBit stable toolchain using the official installer and keeps the generated interface under review.

## License

Apache-2.0. See [LICENSE](LICENSE).

## Development

See [CONTRIBUTING.md](CONTRIBUTING.md) for the local validation loop and [docs/assumptions.md](docs/assumptions.md) for modeling assumptions.
