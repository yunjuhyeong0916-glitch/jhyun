Unified MLSD comparison set.

Structure:
- NRZ: full-state MLSD path inside shared trellis engine
- PAM4/PAM8: reduced-state MLSD path inside the same shared trellis engine
- Shared BM/PM/survivor/traceback hardware across all modes

Notes:
- This folder is intended to compare a unified engine against the split-core hybrid design.
- It reduces duplicated FS/RS blocks at the top level.
- Default traceback is combinational; optional traceback_flat_seq.sv is included for timing experiments.
- Top module name: RX_UNIFIED_MLSD_DSP_64LANE_8B.
