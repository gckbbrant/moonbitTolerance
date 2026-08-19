# API overview

The public surface is intentionally small:

- `Dimension::new` creates a signed nominal contribution and symmetric tolerance.
- `Chain::worst_case` computes the interval widened by every contributor.
- `Chain::rss` computes the independent-contributor RSS estimate.
- `Chain::monte_carlo` repeats seeded sampling and reports observed statistics.
- `Vector2`, `ProjectedDimension`, and `project_chain` cover projected two-dimensional stacks.
- `SamplingPolicy`, `sample_deviation`, and `ProcessCapability` expose distribution and process inputs.
- `GapConstraint`, `evaluate_constraints`, and `result_to_csv` support downstream acceptance/reporting flows.
- `standard_profiles`, `calibration_points`, and `reference_vectors` provide structured engineering fixtures.

`AnalysisResult.sensitivity` keeps contributor names beside their tolerance influence so a caller can rank redesign candidates without depending on private implementation details.
