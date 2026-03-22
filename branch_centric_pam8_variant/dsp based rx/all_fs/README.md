All-FS MLSD comparison set.

Structure:
- NRZ: full-state MLSD
- PAM4: full-state MLSD
- PAM8: full-state MLSD
- Generic PR2 full-state lane core with up to 64 states (M^2)

Notes:
- This folder is intended as the high-complexity comparison baseline against hybrid and all-RS folders.
- Branch complexity per lane per symbol is M^3.
- Default traceback is combinational; optional traceback_flat_seq.sv is included for timing experiments.
- Top module name: RX_FSMLSD_DSP_64LANE_8B.


