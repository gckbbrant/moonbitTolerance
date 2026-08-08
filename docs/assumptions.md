# Analysis assumptions

The first release models every tolerance as a symmetric interval around its nominal value. Worst-case analysis treats every contributor as moving in the direction that widens the result. RSS uses the square root of the sum of squared tolerances and reports a three-sigma interval. Monte Carlo samples each contributor from a uniform interval with a deterministic linear-congruential generator.

These choices are intentionally visible in the API documentation. Production users can compare the assumptions with their process capability data before using the result for a drawing or acceptance decision.
