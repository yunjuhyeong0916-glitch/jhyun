# 연구 성과와 담당 역할

[파트 개요](../README.md) · [LPDDR](lpddr.md) · [USB PAM-3](usb4-pam3.md) · [측정 장비](measurement-equipment.md) · [전체 논문 목록](../../../docs/publications.md)

기준일: **2026-10-07**.

## 연구별 성과

| 연구·관련 논문 | 결과 |
|---|---|
| LPDDR 저전압 TX · [ICEIC 2025](https://doi.org/10.1109/ICEIC64972.2025.10879746) | 28-nm TX 회로 시뮬레이션, 15.6 Gb/s·0.76 pJ/bit |
| LPDDR Combo PHY · [A-SSCC 2026](https://epapers2.org/asscc2026/ESR/paper_details.php?paper_id=1141) | 제작 칩 실측, 14 Gb/s/pin·TX Eye·4-DQ RX 마진 |
| USB TX 모델 · [SMACD 2025](https://doi.org/10.1109/SMACD65553.2025.11092283) | 40 Gb/s/lane TX 동작 모델·시뮬레이션 |
| USB RX 모델 · [SMACD 2025](https://doi.org/10.1109/SMACD65553.2025.11092233) | 25.6 GBaud/lane RX 동작 모델·시뮬레이션 |
| PAM-3 TX · [IEEE TVLSI 2026](https://doi.org/10.1109/TVLSI.2026.3701343) | 28-nm 제작 칩 실측, 32 Gb/s·150-preset 4-tap FFE |

Combo PHY 논문: 채택·발표 예정. [전체 논문](../../../docs/publications.md)

## 담당 역할과 검증 자료

| 항목 | 담당 역할·결과 |
|---|---|
| LPDDR 담당 역할 | TX 회로 설계·Schematic·Post-Layout 검증, 측정용 PCB 설계·HFSS 분석과 제작 칩 측정 참여 |
| LPDDR TX 회로 검증 | [TX 구조·FFE·PEX 이후 검증](lpddr-tx-circuit-verification.md): FFE 적용 전후 Eye, LVS·PEX, PRBS7 데이터율, 전력·에너지·면적 |
| LPDDR TX 동작 모델 | [32:1 직렬화·위상 정렬·pre-emphasis](lpddr-tx-modeling.md) 모델링 담당. 20-Gb/s 모델 조건의 VCS·Questa 파형, 코드별 Eye와 4-DQ 통합 출력 |
| USB 담당 역할 | TX 논리계층·RX CTLE 모델, 11B7S·스크램블러 RTL 합성·P&R·전기 계층 연결 검증, PCB·채널 분석과 차동 PAM-3 측정 |
| USB TX 모델링 과정 | [TX 논리 RTL·XMODEL 통합·Serializer 검증](usb-tx-modeling.md) 담당. 기대값 계산, 논리 복원·우회 제어와 FFE·채널 연결, 구현 후 VCS·POSIM 비교 |
| USB RX CTLE 모델링 | [CTLE 동작점·R/C 제어·입출력 Eye](usb-rx-ctle-modeling.md)와 Sampler 연결 조건 확인. CTLE 모델링·RX 통합 검증 |
| USB 차동 PAM-3 측정 | [측정 구성·채널별 FFE 설정·상하단 Eye·BER bathtub](pam3-differential-measurement.md). 32-Gb/s 제작 TX의 채널별 측정 결과 |
| 공통 측정 장비 | 86100D·86118A, M8195A, E3631A, MP1800A를 LPDDR·USB 양쪽 평가에 사용 |
| PCB·HFSS 사진과 해석 | [배치·배선·HFSS 모델·손실·제작·계측 사진](pcb-hfss-verification.md): LPDDR 보드 설계·분석과 USB TX 보드 검토 |
| RX 자동화 | 2025.03~05 평가의 I2C·전원·BERT 연동, AWG 파일·샘플레이트 수정, 오류 조기 종료·경계 탐색·CSV 기록 |
| 채널보드·실시간 스코프 | M8049A-003, DPO5204B·DSA72004B 등 사용. 실험별 선로·스코프 설정 |
