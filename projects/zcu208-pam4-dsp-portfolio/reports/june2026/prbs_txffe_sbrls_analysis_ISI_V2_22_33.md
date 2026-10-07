# TX FFE Validation Analysis: ISI_V2 iladata22/33

Source files:
- `E:\ZCU208_work\vivado\DSP_based_TRX_32lane_PAM4_4GS\ILADATA\ISI_V2\iladata22.csv`
- `E:\ZCU208_work\vivado\DSP_based_TRX_32lane_PAM4_4GS\ILADATA\ISI_V2\iladata33.csv`

## Configuration Inferred

This capture is no longer the ext-pattern SBR frame. `slot0` is a PRBS-like TX waveform with the SBR-derived TX FFE candidate applied. At this stage, the purpose is TX FFE tap fixing from the DAC-input/ADC-output behavior, before RX FFE/EQ tap selection.

Expected Vitis patch candidate:
- TX FFE taps: `[-75, 112, 27, 2, 0, -1, 2, 0]`
- Packed hex: `0x0002FF00021B70B5`
- `ext_ptrn_en=0`

## RFDC / ADC Summary

| metric | value |
|---|---:|
| TX8 RMS | 36.68 |
| TX8 rail count | 9.41 % |
| ADC peak | 5884 |
| ADC full-scale usage | 18.0 % |
| TX-to-ADC correlation | 0.731 |
| LS channel fit corr | 0.932 |
| LS residual RMS | 958 |

The ADC path is not saturating. The SBR-derived TX FFE candidate gives a strong RFDC correlation compared with earlier captures, but the TX waveform has moderate internal rail hits.

## EQ / MLSD Snapshot, Not Yet A Decision Metric

| metric | value |
|---|---:|
| EQ8 RMS | 38.39 |
| EQ8 min / max | -74 / 96 |
| EQ8 p01 / p99 | -62 / 91 |

MLSD/probe0 distribution:

| level | percent |
|---:|---:|
| -96 | 0.79 % |
| -32 | 54.20 % |
| +32 | 37.14 % |
| +96 | 7.87 % |

Four output levels are present, but this is only a sanity snapshot. It should not be used yet to choose MLSD/threshold settings because the current phase is still TX FFE tap validation.

## Future Threshold Estimate From EQ8

Current PRBS frontend threshold candidate:
- `[-21, -2, 16]`
- EQ8 bucket split: `[28.26, 24.34, 16.06, 31.34] %`

Balanced quantile threshold from this capture:
- `[-28, -8, 26]`
- EQ8 bucket split: `[24.52, 24.39, 25.77, 25.32] %`

K-means state estimate:
- centers: `[-43.86, -13.36, 16.49, 64.24]`
- thresholds: `[-28.61, 1.56, 40.37]`

## Recommendation For Current Stage

For TX FFE fixing, evaluate this candidate primarily by RFDC/ADC metrics:

- TX-to-ADC correlation improved to `0.731`.
- ADC peak remains safe at about `18.0 %FS`.
- TX internal rail hits are moderate at `9.41 %`.
- LS fit correlation is `0.932`, suggesting the channel response is more consistently explainable than the raw SBR capture.

Do not change RX thresholds/levels from this report yet. The next fair TX FFE decision should compare this SBR-LS candidate against legacy/safe/full TX FFE candidates under the same PRBS capture condition.
