<a id="page-top"></a>

# 연구 성과 논문

<!-- page-navigation:top -->
<p>
  <a href="README.md" title="문서 목록으로 돌아가기"><img src="../assets/readme/nav-back-docs.svg" alt="문서 목록으로 돌아가기" width="110" height="30"></a>
  <a href="../README.md" title="홈으로 돌아가기"><img src="../assets/readme/nav-home.svg" alt="홈으로 돌아가기" width="70" height="30"></a>
</p>
<!-- /page-navigation:top -->

[A-SSCC DSP 프로젝트](../projects/zcu208-pam4-dsp-portfolio/) · [LPDDR·USB 인터페이스 연구](../projects/high-speed-interface-research/)

기준일: **2026-10-07**.

| 연구 | 논문·공식 링크 | 학술지·학회 | 결과의 범위 |
|---|---|---|---|
| DSP 기반 송수신기·MLSD | [An FPGA-Verified DAC/ADC-DSP-Based PAM4 Transceiver with Dual-Survivor Segmented Branch Metric-Matrix-Based Reduced-State MLSD](https://epapers2.org/asscc2026/ESR/paper_details.php?paper_id=1351) | A-SSCC 2026 · 채택·발표 예정 | DS-SBM RS-MLSD 연구와 ZCU208 RFSoC 시스템 검증 |
| LPDDR 저전압 TX | [A 1.05-V/0.5-V 15.6-Gb/s NRZ Transmitter Achieving 0.76-pJ/bit Energy Efficiency for Low-Power Memory Interfaces](https://doi.org/10.1109/ICEIC64972.2025.10879746) | ICEIC 2025 | 28-nm 저전압 TX 단독 시뮬레이션 |
| LPDDR Combo PHY | [A 14-Gb/s/pin LPDDR4X/5/5X Backward-Compatible Combo Controller PHY with Pipelined Sub-LSB ZQ Calibration and Preamble-Aware Fast-Settling Phase Interpolator](https://epapers2.org/asscc2026/ESR/paper_details.php?paper_id=1141) | A-SSCC 2026 · 채택·발표 예정 | 설계한 TX가 적용된 Combo PHY의 제작 칩 측정 |
| USB PAM-3 TX 모델 | [SystemVerilog-Based Modeling and Verification of 40-Gb/s/Lane PAM-3 Transmitter for USB4.0 Gen4](https://doi.org/10.1109/SMACD65553.2025.11092283) | SMACD 2025 | 40 Gb/s/lane TX 모델·시뮬레이션 |
| USB PAM-3 RX 모델 | [SystemVerilog-Based Modeling and Verification of 25.6-GBaud/Lane PAM-3 Receiver](https://doi.org/10.1109/SMACD65553.2025.11092233) | SMACD 2025 | 25.6 GBaud/lane RX 모델·시뮬레이션 |
| PAM-3 TX 칩 | [A 0.0549-pJ/bit/pin/dB PAM-3 Transmitter With Reconfigurable 150-Preset Four-Tap FFE for Various Channel Environments](https://doi.org/10.1109/TVLSI.2026.3701343) | IEEE Transactions on Very Large Scale Integration (VLSI) Systems, 2026 | 28-nm·32-Gb/s TX, 150-preset 4-tap FFE의 제작 칩 측정 |

## 준비 중인 연구

[학위논문·Journal·DP-SMM 특허 출원 준비](https://github.com/yunjuhyeong0916-glitch/pam4-mlsd-research/blob/main/docs/publications.md)는 별도 연구 저장소에서 확인할 수 있습니다.

## 관련 설계·결과

- **A-SSCC · DS-SBM:** [설계 구조](../projects/zcu208-pam4-dsp-portfolio/docs/architecture.md), [측정·구현 결과](../projects/zcu208-pam4-dsp-portfolio/docs/validation.md).
- **LPDDR:** [TX 설계·회로 검증과 제작 칩 측정](../projects/high-speed-interface-research/docs/lpddr.md#검증-결과와-조건).
- **USB PAM-3:** [TX·RX 모델과 TX 칩 결과](../projects/high-speed-interface-research/docs/usb4-pam3.md#모델과-실리콘-결과의-구분), [차동 PAM-3 측정·채널별 FFE 검증](../projects/high-speed-interface-research/docs/pam3-differential-measurement.md).
- **계측:** [장비별 역할·자동화·PCB·채널 분석](../projects/high-speed-interface-research/docs/measurement-equipment.md), [담당 역할·검증 자료](../projects/high-speed-interface-research/docs/evidence.md).

<!-- page-navigation:bottom -->
<p>
  <a href="README.md" title="문서 목록으로 돌아가기"><img src="../assets/readme/nav-back-docs.svg" alt="문서 목록으로 돌아가기" width="110" height="30"></a>
  <a href="../README.md" title="홈으로 돌아가기"><img src="../assets/readme/nav-home.svg" alt="홈으로 돌아가기" width="70" height="30"></a>
  <a href="#page-top" title="페이지 맨 위로 이동"><img src="../assets/readme/nav-top.svg" alt="페이지 맨 위로 이동" width="100" height="30"></a>
</p>
<!-- /page-navigation:bottom -->
