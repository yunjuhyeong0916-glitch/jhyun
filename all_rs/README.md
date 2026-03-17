# All-RS MLSD Compare Folder

This folder contains the `all RS-MLSD` variant for structural comparison.

- `NRZ`: RS-MLSD path
- `PAM4`: RS-MLSD path
- `PAM8`: RS-MLSD path

Files:
- `RX_RSMLSD_DSP_64LANE_8B.sv`
- `rs_mlsd_core_lane_8b.sv`
- `acs_rsmlsd.sv`
- `rs_region_detector_mode_8b.sv`
- `RX_GRAY_DEMAP_64LANE_8B_CFG.sv`

Notes:
- This folder does not implement `NRZ = FS-MLSD`.
- It is intended for architecture and complexity comparison against a hybrid structure such as `NRZ = FS`, `PAM4/PAM8 = RS`.
