# moonbitTolerance

Deterministic mechanical tolerance stack-up analysis for MoonBit. The library is intended for CAD, process planning, and quality tooling that need a small, reusable calculation core rather than a full CAD system.

## What is included

- Signed one-dimensional dimension chains.
- Worst-case stack-up and RSS (3-sigma) estimates.
- Deterministic Monte Carlo sampling with an explicit seed.
- Mean, interval, standard deviation, yield rate, and sensitivity data.
- A tiny native CLI demo under `cmd/main`.

The first release deliberately keeps the public model small. Two-dimensional projected chains, richer distribution models, JSON/CSV adapters, and GD&T constraints are planned extension points; they are not represented as unfinished API placeholders.

## Quick start

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

## Engineering notes

`worst_case` sums absolute tolerance contributions. `rss` treats each tolerance as a symmetric independent contributor and reports a three-sigma interval. `monte_carlo` uses a fixed 32-bit linear-congruential generator; the same chain, sample count, and seed produce the same result on supported backends. These assumptions are explicit so downstream applications can replace them when their manufacturing data requires another distribution.

## Development

The repository is licensed under Apache-2.0. CI checks formatting, warning-free type checking, interface generation, and tests with MoonBit's current stable toolchain. See `proposal.md` for the one-page hackathon application.

## Scope boundary

This package is a calculation kernel. It does not parse drawing files, claim conformance to a particular GD&T standard, or replace a calibrated measurement system.
