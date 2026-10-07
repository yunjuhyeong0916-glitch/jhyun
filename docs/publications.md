# 연구 성과 논문

[저장소 첫 화면](../README.md) · [학위논문 (진행 중)](../projects/pam4-mlsd-thesis/) · [Journal 준비 (진행 중)](../projects/dp-smm-journal/) · [A-SSCC DSP 프로젝트](../projects/zcu208-pam4-dsp-portfolio/) · [LPDDR·USB 연구](../projects/high-speed-interface-research/)

기준일: **2026-10-07**.

| 연구 | 논문·공식 링크 | 학술지·학회 | 결과의 범위 |
|---|---|---|---|
| DSP 기반 송수신기·MLSD | [An FPGA-Verified DAC/ADC-DSP-Based PAM4 Transceiver with Dual-Survivor Segmented Branch Metric-Matrix-Based Reduced-State MLSD](https://epapers2.org/asscc2026/ESR/paper_details.php?paper_id=1351) | A-SSCC 2026 · 채택·발표 예정 | DS-SBM RS-MLSD 연구와 ZCU208 RFSoC 시스템 검증 |
| LPDDR 저전압 TX | [A 1.05-V/0.5-V 15.6-Gb/s NRZ Transmitter Achieving 0.76-pJ/bit Energy Efficiency for Low-Power Memory Interfaces](https://doi.org/10.1109/ICEIC64972.2025.10879746) | ICEIC 2025 | 28-nm 저전압 TX 단독 시뮬레이션 |
| LPDDR Combo PHY | [A 14-Gb/s/pin LPDDR4X/5/5X Backward-Compatible Combo Controller PHY with Pipelined Sub-LSB ZQ Calibration and Preamble-Aware Fast-Settling Phase Interpolator](https://epapers2.org/asscc2026/ESR/paper_details.php?paper_id=1141) | A-SSCC 2026 · 채택·발표 예정 | 설계한 TX가 적용된 Combo PHY의 제작 칩 측정 |
| USB PAM-3 TX 모델 | [SystemVerilog-Based Modeling and Verification of 40-Gb/s/Lane PAM-3 Transmitter for USB4.0 Gen4](https://doi.org/10.1109/SMACD65553.2025.11092283) | SMACD 2025 | 40 Gb/s/lane TX 모델·시뮬레이션 |
| USB PAM-3 RX 모델 | [SystemVerilog-Based Modeling and Verification of 25.6-GBaud/Lane PAM-3 Receiver](https://doi.org/10.1109/SMACD65553.2025.11092233) | SMACD 2025 | 25.6 GBaud/lane RX 모델·시뮬레이션 |
| PAM-3 제작 TX | [A 0.0549-pJ/bit/pin/dB PAM-3 Transmitter With Reconfigurable 150-Preset Four-Tap FFE for Various Channel Environments](https://doi.org/10.1109/TVLSI.2026.3701343) | IEEE Transactions on Very Large Scale Integration (VLSI) Systems, 2026 | 28-nm·32-Gb/s TX, 150-preset 4-tap FFE의 제작 칩 측정 |

## 준비 중인 연구

- **학위논문 · DS-SBM·DP-SMM 비교 (진행 중):** 두 구조의 차이와 동일 입력의 후보 보존 효과를 평가했습니다. DP-SMM 실측은 예정입니다. [프로젝트](../projects/pam4-mlsd-thesis/)
- **Journal · DP-SMM (진행 중):** *A Segmented Metric-Matrix-Based MLSD Architecture with Dual-Path Reduced-State Detection for PAM4 Wireline Transceivers on an RFSoC Platform*. 구간 메트릭 행렬의 두 경로 후보 보존·실제 이력 재평가와 FPGA 구현을 다루는 원고를 준비 중입니다. [프로젝트](../projects/dp-smm-journal/)

## 관련 설계·결과

- **학위논문 · DS-SBM·DP-SMM 비교 (진행 중):** [구조 비교](../projects/pam4-mlsd-thesis/docs/architecture.md), [모델·RTL 비교 결과](../projects/pam4-mlsd-thesis/docs/validation.md).
- **Journal · DP-SMM (진행 중):** [검출기 구조](../projects/dp-smm-journal/docs/architecture.md), [RTL 검증·FPGA 구현](../projects/dp-smm-journal/docs/validation.md).
- **A-SSCC · DS-SBM:** [설계 구조](../projects/zcu208-pam4-dsp-portfolio/docs/architecture.md), [측정·구현 결과](../projects/zcu208-pam4-dsp-portfolio/docs/validation.md).
- **LPDDR:** [TX 설계·회로 검증과 제작 칩 측정](../projects/high-speed-interface-research/docs/lpddr.md#검증-결과와-조건).
- **USB PAM-3:** [TX·RX 모델과 제작 TX 결과](../projects/high-speed-interface-research/docs/usb4-pam3.md#모델과-실리콘-결과의-구분), [차동 PAM-3 측정·채널별 FFE 검증](../projects/high-speed-interface-research/docs/pam3-differential-measurement.md).
- **계측:** [장비별 역할·자동화·PCB·채널 분석](../projects/high-speed-interface-research/docs/measurement-equipment.md), [담당 역할·검증 자료](../projects/high-speed-interface-research/docs/evidence.md).
