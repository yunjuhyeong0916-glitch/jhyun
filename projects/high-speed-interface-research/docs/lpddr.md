# LPDDR: TX 회로 설계·모델링과 Combo PHY 검증

[파트 개요](../README.md) · [USB PAM-3](usb4-pam3.md) · [측정 장비](measurement-equipment.md) · [논문·근거](evidence.md)

Combo PHY의 TX 회로와 TX Verilog 동작 모델을 설계했습니다. 회로의 Schematic·Post-Layout 검증과 측정용 PCB 설계·HFSS 분석을 수행하고, 제작 칩 측정에 참여했습니다.

## 낮은 전압에서도 채널을 통과하는 TX 설계

28-nm CMOS의 0.5-V VDDQ TX에 PI-LVSTL 드라이버, 2-tap de-emphasis FFE와 ZQ 제어를 적용했습니다. Schematic·Post-Layout 시뮬레이션에서 출력 Eye와 배선 기생성분의 영향을 확인했습니다.

[TX 구조·FFE Eye·LVS/PEX·전력](lpddr-tx-circuit-verification.md)

## TX 동작 모델에서 직렬화와 보상 경로 확인

LPDDR Combo Controller PHY의 TX Verilog 동작 모델에서 32:1 직렬화·위상 정렬과 main/1UI 지연 데이터 기반 pre-emphasis를 구현했습니다. VCS·Questa로 코드별 Eye와 4-DQ 통합 출력을 확인했습니다. [TX 모델](lpddr-tx-modeling.md)

## 보드 경로를 포함해 파형 해석

측정용 PCB를 설계하고 HFSS S-parameter·전자기장 해석으로 신호 경로를 분석했습니다. 주파수별 손실과 notch를 검토하며 배치·배선을 수정하고, COB 실장 후 출력 Eye를 평가했습니다.

[PCB 배치·제작·본딩·HFSS](pcb-hfss-verification.md)

## 검증 결과와 조건

| 검증 단계 | 결과·조건 | 담당·평가 | 관련 논문 |
|---|---|---|---|
| TX 단독 시뮬레이션 | 15.6 Gb/s, 0.76 pJ/bit; 내부 전원 1.05 V·드라이버 전원 0.5 V, 채널 손실 8.7 dB 조건 | TX 회로 설계·검증 | [ICEIC 2025: 저전압 NRZ TX](https://doi.org/10.1109/ICEIC64972.2025.10879746) |
| TX Verilog 동작 모델 | 20 Gb/s·PRBS7·LPDDR5/5X 모드, 채널 손실 12.5 dB @ 10 GHz | TX 모델링·파형·코드별 Eye | [TX 모델 검증 결과](lpddr-tx-modeling.md) |
| Combo PHY TX Eye | 14 Gb/s/pin·4-DQ 활성 조건에서 0.41 UI·65.3 mV | 설계한 TX가 적용된 Combo PHY의 제작 칩 측정 | [A-SSCC 2026: Combo PHY](https://epapers2.org/asscc2026/ESR/paper_details.php?paper_id=1141) |
| Combo PHY RX margin | TX–RX 연결·4-DQ 활성 조건에서 0.25 UI·25 mV | RX Shmoo 측정 참여 | [A-SSCC 2026: Combo PHY](https://epapers2.org/asscc2026/ESR/paper_details.php?paper_id=1141) |

A-SSCC 2026 Combo PHY 논문: 채택·발표 예정(2026-10-07 기준). [논문](evidence.md)

## 측정 장비와 사용 목적

[TX 시뮬레이션 Eye·제작 칩 Eye·Shmoo](verification-figures.md#lpddr-tx-ffe-적용-전후의-시뮬레이션)

86100D·86118A로 Eye를 관측하고, M8195A·E3631A·MP1800A로 입력·전원 조건과 오류 집계를 제어했습니다. RX 자동화에서는 칩의 Vref와 BERT 판정 임계값을 각각 관리하고, 전원 변화에 맞춰 오류 판정 설정을 갱신했습니다.

[장비·AWG·Shmoo 자동화](measurement-equipment.md)
