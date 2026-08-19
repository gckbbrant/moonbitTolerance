# Benchmark record

The CLI benchmark uses five public-API chains and 10,000 deterministic samples per chain. It is a reproducibility check and a small integration workload, not a claim about all manufacturing workloads.

Command:

```text
moon run cmd/main
```

Toolchain: `moon 0.1.20260807 (4da23f8 2026-08-07)`, native target, Windows x64. Three wall-clock measurements of the complete CLI process were 184.8978 ms, 161.0965 ms, and 167.0095 ms. These include process startup and compilation-cache effects and should not be compared across machines as a throughput claim.

The deterministic output recorded from the same run was:

```text
small-fit: mean=-1.4998201830714004, sigma=0.023263447376091758, yield=1
bearing-seat: mean=-2.999822048752443, sigma=0.01630426902401489, yield=1
housing-stack: mean=-6.0002636372712574, sigma=0.05803037764907987, yield=1
long-actuator: mean=-11.999813581170061, sigma=0.12978410494704778, yield=1
precision-stage: mean=-24.000311778353023, sigma=0.023150598049633635, yield=1
```

The repository also contains 512 deterministic reference vectors for regression testing. They validate interval arithmetic and RSS shape; they are not presented as measurements from a physical machine.
