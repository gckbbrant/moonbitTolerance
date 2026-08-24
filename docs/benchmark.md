# Benchmark record

The CLI benchmark uses five public-API chains and 10,000 deterministic samples per chain. Each case runs the seeded distribution sampler through an explicit acceptance window, so the reported yield is calculated from pass/fail outcomes rather than being hard-coded to the worst-case interval. It is a reproducibility check and a small integration workload, not a claim about all manufacturing workloads.

Command:

```text
moon run cmd/main
```

Toolchain: `moonc v0.10.9+6e6c44045` with `moon 0.1.20260819` on Windows. Three warm-cache runs of the command took 224.127 ms, 235.269 ms, and 236.669 ms on the recording machine. These timings include process startup and should not be compared across machines as a throughput claim.

The deterministic output recorded from the same run was:

```text
small-fit: mean=-1.4998201830714004, sigma=0.023263447376091758, yield=0.8212
bearing-seat: mean=-2.999822048752443, sigma=0.01630426902401489, yield=0.8338
housing-stack: mean=-6.0002636372712574, sigma=0.05803037764907987, yield=0.8326
long-actuator: mean=-11.999813581170061, sigma=0.12978410494704778, yield=0.8333
precision-stage: mean=-24.000311778353023, sigma=0.023150598049633635, yield=0.8336
```

The deterministic tests validate the sampled distribution, acceptance-window yield, interval arithmetic, covariance propagation, and statistics directly through the public API. They are not presented as measurements from a physical machine.
