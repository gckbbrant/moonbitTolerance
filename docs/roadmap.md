# Roadmap

1. Add projected two-dimensional chains while retaining the one-dimensional API.
2. Add pluggable probability distributions and process capability inputs.
3. Add JSON and CSV adapters in a separate package.
4. Add constraint objects for gaps and GD&T-oriented checks after the numeric core is stable.

Each item is intentionally downstream of the current calculation kernel, so a future release can grow without changing the meaning of existing analysis methods.
