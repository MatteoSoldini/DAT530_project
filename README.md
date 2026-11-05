# DAT 530 Project - Simulating a CI/CD Pipeline with GPenSIM

DAT530 Discrete Simulation and Performance Analysis, University of Stavanger.
Matteo Soldini, Jules Gombert.

A CI/CD pipeline modelled as a timed, colored Petri net and simulated with
GPenSIM in MATLAB. Commits go through build, tests, staging, performance
tests and production deployment, sharing a limited pool of runners.

## Requirements

- MATLAB
- [GPenSIM](https://www.davidrajuh.net/gpensim/) installed and on the MATLAB path
- Statistics and Machine Learning Toolbox (for `exprnd`)

## Files

| File | Purpose |
|---|---|
| `main.m` | Main simulation file: parameters, runs, results |
| `pn_pdf.m` | Petri net of the sequential pipeline |
| `par_tests_pn_pdf.m` | Petri net of the parallel testing pipeline |
| `COMMON_PRE.m` | Pre-processor: runner request, token selection, synchronization |
| `COMMON_POST.m` | Post-processor: runner release, timing metrics |

## How to run

1. Open the project folder in MATLAB.
2. Set the parameters at the top of `main.m`.
3. Run `main.m`.

The script runs the simulation 10 times (seeds 1 to 10) and prints the mean
and standard deviation of the number of deployed commits, throughput,
pipeline time, lead time and runner utilization. It also plots the token
counts of the places for the last run.
