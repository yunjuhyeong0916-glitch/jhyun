# 연구 성과 논문

[저장소 첫 화면](../README.md) · [DSP·MLSD 프로젝트](../projects/zcu208-pam4-dsp-portfolio/) · [LPDDR·USB 연구](../projects/high-speed-interface-research/)

프로젝트별 성과와 연결되는 논문 6편입니다. DOI가 등록된 논문은 DOI로, A-SSCC 2026 논문은 공식 논문 정보 페이지로 연결합니다. 확인 기준일: **2026-10-07**.

| 연구 | 논문·공식 링크 | 학술지·학회 | 결과의 범위 |
|---|---|---|---|
| DSP 기반 송수신기·MLSD | [An FPGA-Verified DAC/ADC-DSP-Based PAM4 Transceiver with Dual-Survivor Segmented Branch Metric-Matrix-Based Reduced-State MLSD](https://epapers2.org/asscc2026/ESR/paper_details.php?paper_id=1351) | A-SSCC 2026 · 채택·발표 예정 | DS-SBM RS-MLSD 연구와 ZCU208 RFSoC 시스템 검증 |
| LPDDR 저전압 TX | [A 1.05-V/0.5-V 15.6-Gb/s NRZ Transmitter Achieving 0.76-pJ/bit Energy Efficiency for Low-Power Memory Interfaces](https://doi.org/10.1109/ICEIC64972.2025.10879746) | ICEIC 2025 | 28-nm 저전압 TX 단독 시뮬레이션 |
| LPDDR Combo PHY | [A 14-Gb/s/pin LPDDR4X/5/5X Backward-Compatible Combo Controller PHY with Pipelined Sub-LSB ZQ Calibration and Preamble-Aware Fast-Settling Phase Interpolator](https://epapers2.org/asscc2026/ESR/paper_details.php?paper_id=1141) | A-SSCC 2026 · 채택·발표 예정 | 개인 설계 TX가 적용된 공동 Combo PHY의 실리콘 측정 |
| USB PAM-3 TX 모델 | [SystemVerilog-Based Modeling and Verification of 40-Gb/s/Lane PAM-3 Transmitter for USB4.0 Gen4](https://doi.org/10.1109/SMACD65553.2025.11092283) | SMACD 2025 | 40 Gb/s/lane TX 모델·시뮬레이션 |
| USB PAM-3 RX 모델 | [SystemVerilog-Based Modeling and Verification of 25.6-GBaud/Lane PAM-3 Receiver](https://doi.org/10.1109/SMACD65553.2025.11092233) | SMACD 2025 | 25.6 GBaud/lane RX 모델·시뮬레이션 |
| PAM-3 제작 TX | [A 0.0549-pJ/bit/pin/dB PAM-3 Transmitter With Reconfigurable 150-Preset Four-Tap FFE for Various Channel Environments](https://doi.org/10.1109/TVLSI.2026.3701343) | IEEE Transactions on Very Large Scale Integration (VLSI) Systems, 2026 | 28-nm·32-Gb/s TX, 150-preset 4-tap FFE의 공동 실리콘 연구 |

## 프로젝트 설명과 함께 읽기

- **DSP·MLSD:** [논문과 공개 소스의 관계](../projects/zcu208-pam4-dsp-portfolio/docs/architecture.md#관련-논문과-공개-소스의-관계), [공개본의 검증 근거](../projects/zcu208-pam4-dsp-portfolio/docs/validation.md). 논문의 알고리즘·시스템 결과와 공개 RTL 스냅샷의 재현 범위는 각각 확인합니다.
- **LPDDR:** [개인 TX 설계·측정 전 검증과 공동 칩 결과](../projects/high-speed-interface-research/docs/lpddr.md#검증-결과와-조건).
- **USB PAM-3:** [TX·RX 모델과 제작 TX 결과](../projects/high-speed-interface-research/docs/usb4-pam3.md#모델과-실리콘-결과의-구분).
- **계측:** [장비별 역할·자동화·PCB·채널 분석](../projects/high-speed-interface-research/docs/measurement-equipment.md), [개인 기여·장비 사용의 근거](../projects/high-speed-interface-research/docs/evidence.md).

## 링크와 상태의 확인 기준

DOI 4건은 Crossref 등록정보에서 제목·학술지/학회·연도를 확인했습니다. A-SSCC 2026 두 편은 공식 페이지의 제목과 `Accept as Lecture` 상태를 확인했으며, 발표 예정 상태로 표기했습니다. 개인 담당 역할은 각 프로젝트 문서에 설명합니다.
