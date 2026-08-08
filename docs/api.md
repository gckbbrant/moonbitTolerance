# API sketch

The public surface is intentionally small:

- `Dimension::new` creates a signed nominal contribution and symmetric tolerance.
- `Chain::worst_case` computes the interval widened by every contributor.
- `Chain::rss` computes the independent-contributor RSS estimate.
- `Chain::monte_carlo` repeats seeded sampling and reports observed statistics.

`AnalysisResult.sensitivity` keeps contributor names beside their tolerance influence so a caller can rank redesign candidates without depending on private implementation details.
