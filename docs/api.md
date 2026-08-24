# API overview

The public surface is intentionally small:

- `Dimension::new` creates a signed nominal contribution and symmetric tolerance.
- `Chain::worst_case` computes the interval widened by every contributor.
- `Chain::rss` computes the independent-contributor RSS estimate.
- `Chain::monte_carlo` repeats seeded sampling and reports observed statistics.
- `Vector2`, `ProjectedDimension`, and `project_chain` cover projected two-dimensional stacks.
- `SamplingPolicy`, `sample_deviation`, and `ProcessCapability` expose distribution and process inputs.
- `GapConstraint`, `evaluate_constraints`, and `result_to_csv` support downstream acceptance/reporting flows.
- `AcceptanceWindow`, `Chain::simulate`, and `SimulationSummary` connect sampled results to an explicit acceptance interval.
- `summarize_samples` and `quantile` provide deterministic statistics for downstream process reports.
- `Covariance2`, `covariance_of`, and `projected_standard_deviation` propagate projected tolerance uncertainty.
- `CapabilityReport` and `capability_report` combine observed statistics with `Cp`, `Cpu`, `Cpl`, and `Cpk`.
- `GeometricTolerance` and its position, concentricity, and runout factories evaluate simple geometric zones.
- `simulation_to_csv` and `capability_to_csv` provide stable text adapters for reporting pipelines.
- `Interval`, `IntervalVector2`, and `chain_interval` provide conservative arithmetic for host-side feasibility checks.
- `ScenarioSpec`, `run_scenario`, `compare_scenarios`, `gauge_rr`, `process_performance`, and `sample_plan` compose repeatable workflows.
- `FitAnalysis`, `DatumFrame`, `Specification`, and `UncertaintyBudget` cover fit, GD&T-style, specification, and uncertainty reporting.
- `allocate_chain`, `propose_tightening`, `correlated_rss`, `Length`, `Angle`, and `round_interval` support design and integration tooling.

`AnalysisResult.sensitivity` keeps contributor names beside their tolerance influence so a caller can rank redesign candidates without depending on private implementation details.
