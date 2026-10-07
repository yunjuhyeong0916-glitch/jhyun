# LPDDR·USB 고속 인터페이스 회로·모델링·실리콘 평가

[저장소 첫 화면](../../README.md) · [측정·자동화](docs/measurement-equipment.md) · [검증 그림](docs/verification-figures.md) · [논문](docs/evidence.md)

LPDDR 저전압 TX를 설계하고 Schematic·Post-Layout 검증을 수행했습니다. USB PAM-3에서는 TX 논리 RTL·동작 모델과 RX CTLE 모델을 구현하고, 송수신 통합·제작 TX의 차동 신호 평가에 참여했습니다.

## 설계·결과

| 프로젝트 | 담당 설계·검증 | 결과 |
|---|---|---|
| [LPDDR](docs/lpddr.md) | [TX 회로](docs/lpddr-tx-circuit-verification.md), [TX Verilog 모델](docs/lpddr-tx-modeling.md), PCB·HFSS, 공동 평가 | TX 시뮬레이션 15.6 Gb/s·0.76 pJ/bit, 공동 Combo PHY 실측 14 Gb/s/pin |
| [USB PAM-3](docs/usb4-pam3.md) | [TX 모델·RTL·Serializer](docs/usb-tx-modeling.md), [RX CTLE 모델](docs/usb-rx-ctle-modeling.md), PCB·채널 분석·차동 측정 | TX 모델 40 Gb/s/lane, RX 모델 25.6 GBaud/lane, 공동 TX 실측 32 Gb/s |

## PCB·계측

PCB 배치·배선과 HFSS S-parameter 분석을 수행하고, COB 실장 이후의 출력 Eye를 평가했습니다. 86100D·86118A로 Eye를 관측하고, M8195A·MP1800A·E3631A·I2C를 연동해 입력·전압·타이밍 조건과 오류 집계를 제어했습니다.

- [PCB·HFSS 설계·해석](docs/pcb-hfss-verification.md)
- [AWG 샘플레이트 연동·Shmoo 경계 탐색](docs/measurement-equipment.md)
- [TX Eye·RX Shmoo](docs/verification-figures.md)

## 연구 성과 논문

| 연구 | 모델·시뮬레이션 | 실리콘 평가 |
|---|---|---|
| LPDDR | [ICEIC 2025 · 저전압 NRZ TX](https://doi.org/10.1109/ICEIC64972.2025.10879746) | [A-SSCC 2026 · 14-Gb/s/pin Combo PHY](https://epapers2.org/asscc2026/ESR/paper_details.php?paper_id=1141), 채택·발표 예정 |
| USB PAM-3 | [SMACD 2025 · TX 모델](https://doi.org/10.1109/SMACD65553.2025.11092283) · [SMACD 2025 · RX 모델](https://doi.org/10.1109/SMACD65553.2025.11092233) | [IEEE TVLSI 2026 · 32-Gb/s TX·150-preset FFE](https://doi.org/10.1109/TVLSI.2026.3701343) |

[논문별 결과·담당 역할](docs/evidence.md) · [전체 논문 목록](../../docs/publications.md)
