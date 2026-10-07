# 관련 논문과 검증 근거

[파트 개요](../README.md) · [LPDDR](lpddr.md) · [USB PAM-3](usb4-pam3.md) · [측정 장비](measurement-equipment.md) · [전체 성과 논문 6편](../../../docs/publications.md)

정리 기준일: **2026-10-07**. 개인 담당 역할은 작성자 제공 이력서·연구소개서·측정 활동 자료와 작성자 설명을 기준으로 정리했습니다. 논문은 연구 구성과 결과의 근거이며, 공동저자라는 사실만으로 모든 블록을 개인 설계한 것으로 표시하지 않습니다.

## 논문별 결과의 범위

| 연구 자료 | 이 파트에서 사용한 근거 |
|---|---|
| [A 1.05-V/0.5-V 15.6-Gb/s NRZ Transmitter Achieving 0.76-pJ/bit Energy Efficiency for Low-Power Memory Interfaces](https://doi.org/10.1109/ICEIC64972.2025.10879746) | LPDDR 지향 28-nm 저전압 TX의 구조와 15.6 Gb/s·0.76 pJ/bit 시뮬레이션 결과 |
| [A 14-Gb/s/pin LPDDR4X/5/5X Backward-Compatible Combo Controller PHY with Pipelined Sub-LSB ZQ Calibration and Preamble-Aware Fast-Settling Phase Interpolator](https://epapers2.org/asscc2026/ESR/paper_details.php?paper_id=1141) | 공식 논문 정보에서 확인한 공동 실리콘의 14 Gb/s/pin, TX Eye와 4-DQ RX 마진 |
| [SystemVerilog-Based Modeling and Verification of 40-Gb/s/Lane PAM-3 Transmitter for USB4.0 Gen4](https://doi.org/10.1109/SMACD65553.2025.11092283) | TX 모델 구성과 40 Gb/s/lane 모델·시뮬레이션 |
| [SystemVerilog-Based Modeling and Verification of 25.6-GBaud/Lane PAM-3 Receiver](https://doi.org/10.1109/SMACD65553.2025.11092233) | RX 모델 구성과 25.6 GBaud/lane 모델·시뮬레이션 |
| [A 0.0549-pJ/bit/pin/dB PAM-3 Transmitter With Reconfigurable 150-Preset Four-Tap FFE for Various Channel Environments](https://doi.org/10.1109/TVLSI.2026.3701343) | 28-nm 제작 PAM-3 TX의 32 Gb/s·150-preset 4-tap FFE 공동 실리콘 연구 |

DOI 4건의 제목과 저자 정보는 2026-10-07 Crossref DOI 등록정보와 대조했습니다. Combo PHY 논문은 같은 날 A-SSCC 공식 논문 정보에서 제목·측정 조건을 확인했습니다. 모델·회로·실리콘 결과는 작성자 제공 논문 및 연구자료의 해당 범위를 따릅니다.

Combo PHY 논문은 공식 정보 기준 채택·발표 예정입니다. DSP·MLSD 관련 A-SSCC 논문을 포함한 전체 목록은 [연구 성과 논문](../../../docs/publications.md)에서 확인할 수 있습니다.

## 담당 역할과 장비 사용의 근거

| 항목 | 확인한 자료·설명 |
|---|---|
| LPDDR 개인 기여 | 작성자 제공 자료의 적용 TX 직접 설계, 해당 TX의 Schematic·Post-Layout 검증 전담, 측정용 PCB·HFSS 분석과 공동 칩 평가 |
| USB 개인 기여 | TX 논리계층·RX CTLE 모델, 11B7S·스크램블러 RTL 합성·P&R·전기 계층 연결 검증, PCB·채널 분석과 차동 PAM-3 측정 |
| 공통 측정 장비 | 제공 이력서·측정 자료의 86100D·86118A, M8195A, E3631A, MP1800A; 2026-10-07 작성자가 LPDDR·USB 양쪽에서 사용했다고 확인 |
| RX 자동화 | 2025.03~05 측정 활동 자료의 I2C·전원·BERT 연동, AWG 파일·샘플레이트 수정, 오류 조기 종료·경계 탐색·CSV 기록 |
| 채널보드·실시간 스코프 | 제공 자료의 M8049A-003, DPO5204B·DSA72004B 등 사용 이력. 실험별 선로·스코프·설정을 하나로 합치지 않음 |

측정 자동화 자료에는 루프백과 실제 칩 적용 단계가 모두 있습니다. 루프백의 오류 미검출을 칩 BER 성과로 바꾸지 않고, Shmoo 미측정 구간도 무오류 결과와 구분했습니다. 제조사 자료는 [장비 문서](measurement-equipment.md)에 연결했으며, 제조사 기능·최대 사양을 작성자의 실제 수행 성과로 사용하지 않습니다.

이 파트는 기존 연구를 설명하는 문서입니다. 이번 정리에서 회로 시뮬레이션, 장비 제어 코드, 실리콘 측정이나 원시 데이터 분석을 재실행하지 않았습니다. 원본 연구자료와 개인정보가 포함된 이력서는 이 저장소에 업로드하지 않았습니다.
