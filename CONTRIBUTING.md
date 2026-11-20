# Contributing

This is a private academic team project. Retain the original copyright and usage notices in all source and derived files. Confirm permission before publishing any source or project artifacts.

## Workflow

1. Start from the repository's current integration/default branch and create a descriptive branch such as `docs/build-guide` or `fix/load-use-stall`.
2. Keep changes focused. Edit the tracked sources directly; place the generated Vivado project outside this repository.
3. Run `bash scripts/run_tests.sh` for RTL changes. Explain any failures or simulator limitations in the pull request.
4. For FPGA integration, clock, or constraints changes, run Vivado synthesis and implementation, review timing, and test the appropriate board. Record the Vivado version, FPGA/board, selected constraint file, and clock settings.
5. Update documentation and benchmark results when behaviour or measurements change.
6. Submit a pull request to the current integration/default branch with the purpose, affected behaviour, and verification results. Do not use the old `asst2` workflow for this checkout.

## Files and results

- Commit HDL, required `.mem` images, constraints, scripts, and documentation.
- Keep simulator outputs, waveforms, Vivado caches, and generated run directories out of Git.
- The existing demonstration bitstream is retained deliberately. Replace it only alongside a documented build configuration and board validation.
- Keep historical assignments in Git history rather than duplicating them in the current tree.
- Attribute individual work accurately; merging a teammate's feature is not authorship of that implementation.
- Report benchmark inputs, compiler settings, operating clocks, predictor configuration/state, and validation status. Distinguish same-clock predictor improvements from comparisons at different CPU clocks.

See [docs/BUILD.md](docs/BUILD.md) for setup and simulation details.
