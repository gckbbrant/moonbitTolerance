# Roadmap

The current release covers the first engineering workflow: one- and two-dimensional tolerance propagation, deterministic sampling, inspection analytics, fit/GD&T-style checks, uncertainty budgets, and CSV boundary adapters.

Future work is intentionally focused on interoperability rather than larger fixture collections:

1. Add a documented JSON adapter package without coupling the calculation kernel to a CAD schema.
2. Add optional correlation-matrix and covariance import helpers for measurement systems.
3. Add property-based generators for dimension chains and cross-backend numerical differential checks.
4. Add examples that connect the public API to a CAD or inspection host while retaining deterministic core behavior.
