# 관련 논문과 검증 근거

[파트 개요](../README.md) · [LPDDR](lpddr.md) · [USB PAM-3](usb4-pam3.md) · [측정 장비](measurement-equipment.md) · [전체 성과 논문 6편](../../../docs/publications.md)

기준일: **2026-10-07**.

## 논문별 결과의 범위

| 연구 자료 | 결과 |
|---|---|
| [A 1.05-V/0.5-V 15.6-Gb/s NRZ Transmitter Achieving 0.76-pJ/bit Energy Efficiency for Low-Power Memory Interfaces](https://doi.org/10.1109/ICEIC64972.2025.10879746) | LPDDR 지향 28-nm 저전압 TX의 구조와 15.6 Gb/s·0.76 pJ/bit 시뮬레이션 결과 |
| [A 14-Gb/s/pin LPDDR4X/5/5X Backward-Compatible Combo Controller PHY with Pipelined Sub-LSB ZQ Calibration and Preamble-Aware Fast-Settling Phase Interpolator](https://epapers2.org/asscc2026/ESR/paper_details.php?paper_id=1141) | 공식 논문 정보에서 확인한 공동 실리콘의 14 Gb/s/pin, TX Eye와 4-DQ RX 마진 |
| [SystemVerilog-Based Modeling and Verification of 40-Gb/s/Lane PAM-3 Transmitter for USB4.0 Gen4](https://doi.org/10.1109/SMACD65553.2025.11092283) | TX 모델 구성과 40 Gb/s/lane 모델·시뮬레이션 |
| [SystemVerilog-Based Modeling and Verification of 25.6-GBaud/Lane PAM-3 Receiver](https://doi.org/10.1109/SMACD65553.2025.11092233) | RX 모델 구성과 25.6 GBaud/lane 모델·시뮬레이션 |
| [A 0.0549-pJ/bit/pin/dB PAM-3 Transmitter With Reconfigurable 150-Preset Four-Tap FFE for Various Channel Environments](https://doi.org/10.1109/TVLSI.2026.3701343) | 28-nm 제작 PAM-3 TX의 32 Gb/s·150-preset 4-tap FFE 공동 실리콘 연구 |

Combo PHY 논문: 채택·발표 예정. [전체 논문](../../../docs/publications.md)

## 담당 역할과 검증 자료

| 항목 | 담당 역할·결과 |
|---|---|
| LPDDR 개인 기여 | 적용 TX 회로 설계와 Schematic·Post-Layout 검증 전담. 측정용 PCB·HFSS 분석과 공동 칩 평가 참여 |
| LPDDR TX 회로 검증 | [TX 구조·FFE·PEX 이후 검증](lpddr-tx-circuit-verification.md): FFE off/on Eye, LVS·PEX 기록, PRBS7 출력 주기, 두 전원 레일의 에너지 계산과 버전별 면적. 시험 제출용 회로 시뮬레이션 |
| LPDDR TX 동작 모델 | [32:1 직렬화·위상 정렬·pre-emphasis](lpddr-tx-modeling.md) 모델링 담당. 20-Gb/s 모델 조건의 VCS·Questa 파형, 코드별 Eye와 4-DQ 통합 출력 |
| USB 개인 기여 | TX 논리계층·RX CTLE 모델, 11B7S·스크램블러 RTL 합성·P&R·전기 계층 연결 검증, PCB·채널 분석과 차동 PAM-3 측정 |
| USB TX 모델링 과정 | [TX 논리 RTL·XMODEL 통합·Serializer 검증](usb-tx-modeling.md) 담당. 기대값 계산, 논리 복원·우회 제어와 FFE·채널 연결, 구현 후 VCS·POSIM 비교 |
| USB RX CTLE 모델링 | [CTLE 동작점·R/C 제어·입출력 Eye](usb-rx-ctle-modeling.md)와 Sampler 연결 조건 확인. CTLE 모델링·공동 RX 통합 검증 |
| 공통 측정 장비 | 86100D·86118A, M8195A, E3631A, MP1800A를 LPDDR·USB 양쪽 평가에 사용 |
| PCB·HFSS 사진과 해석 | [배치·배선·HFSS 모델·손실·제작·계측 사진](pcb-hfss-verification.md): 개인 LPDDR 보드 설계·분석과 공동 USB 보드 검토 |
| RX 자동화 | 2025.03~05 평가의 I2C·전원·BERT 연동, AWG 파일·샘플레이트 수정, 오류 조기 종료·경계 탐색·CSV 기록 |
| 채널보드·실시간 스코프 | M8049A-003, DPO5204B·DSA72004B 등 사용. 실험별 선로·스코프 설정 |
