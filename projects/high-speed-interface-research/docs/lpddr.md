# LPDDR: TX 회로 설계·모델링과 Combo PHY 검증

[파트 개요](../README.md) · [USB PAM-3](usb4-pam3.md) · [측정 장비](measurement-equipment.md) · [논문·근거](evidence.md)

**개인 담당:** 최종 Combo PHY에 적용된 TX 회로 직접 설계와 해당 TX의 측정 전 Schematic·Post-Layout 검증 전담, Controller PHY의 TX Verilog 동작 모델링. 측정용 PCB 설계·HFSS 채널 분석과 공동 실리콘 평가에 참여했습니다.

## 낮은 전압에서도 채널을 통과하는 TX 설계

드라이버 전압을 낮추면 전력 소모를 줄일 수 있지만, 채널 손실 이후의 신호 여유와 임피던스 정합을 함께 확보해야 합니다. 이 조건을 다루기 위해 28-nm CMOS의 0.5-V VDDQ TX에 PI-LVSTL 드라이버, 2-tap de-emphasis FFE와 ZQ 보정을 적용했습니다. FFE를 적용한 출력 파형과 임피던스 보정 동작을 확인하고, 배선 기생성분을 반영한 Post-Layout 검증으로 설계 판단을 점검했습니다.

이 TX 설계와 측정 전 검증은 개인 담당 범위입니다. TX가 포함된 LPDDR4X/5/5X Combo PHY의 클록·RX·전체 통합 및 최종 칩 성능은 공동 연구 범위로 구분합니다.

[TX 회로 설계·검증 과정](lpddr-tx-circuit-verification.md)에서는 과제 보고서와 시험 제출자료를 바탕으로 main/1-UI 지연 경로의 구조, FFE 적용 전후 Eye, LVS·PEX 이후 PRBS 출력 주기와 두 전원 레일의 에너지 계산을 설명합니다. 구조도·검증 그림 6개에 출처와 조건을 붙였으며, 시험자료의 시뮬레이션 시연과 실제 칩 측정을 구분했습니다.

## TX 동작 모델에서 직렬화와 보상 경로 확인

병렬 데이터가 직렬 출력으로 바뀌는 과정에서는 비트 순서·클록 위상과 보상용 지연 데이터의 관계를 함께 확인해야 합니다. LPDDR Combo Controller PHY에서는 TX 경로의 Verilog 동작 모델링을 맡아, 32:1 직렬화·위상 정렬과 main/1UI 지연 데이터 기반 pre-emphasis를 다뤘습니다. [TX 모델 구조·검증 파형](lpddr-tx-modeling.md)에 기존 VCS·Questa 결과, 레벨 코드별 Eye와 4-DQ 통합 출력을 정리했습니다.

## 보드 경로를 포함해 파형 해석

회로에서 얻은 파형과 실측 결과를 비교하려면 칩 밖의 전송 경로도 확인해야 합니다. 측정용 PCB를 직접 설계하고 HFSS의 S-parameter·전자기장 해석으로 신호 경로를 분석했습니다. 특정 주파수 대역의 손실 증가를 검토하며 배치·배선을 수정했고, COB 실장 이후의 출력 Eye를 보드·채널 조건과 함께 해석했습니다. 이 과정은 회로 시뮬레이션, 보드 해석과 실리콘 측정을 연결하는 담당 경험입니다.

[PCB·HFSS 사진과 설명](pcb-hfss-verification.md)에는 설계 화면·제작 보드·와이어 본딩과 HFSS 해석 구간·S-parameter 곡선을 연결했습니다. 6.4-GHz 표시값은 보드 해석 결과로 설명하며, 공동 칩 Eye의 개선량으로 바꾸지 않았습니다.

## 검증 결과와 조건

| 검증 단계 | 결과·조건 | 기여·해석 범위 | 관련 논문 |
|---|---|---|---|
| TX 단독 시뮬레이션 | 15.6 Gb/s, 0.76 pJ/bit; 내부 전원 1.05 V·드라이버 전원 0.5 V, 채널 손실 8.7 dB 조건 | 개인 TX 설계·검증, 제작 칩 실측과 구분 | [ICEIC 2025: 저전압 NRZ TX](https://doi.org/10.1109/ICEIC64972.2025.10879746) |
| TX Verilog 동작 모델 | 20 Gb/s·PRBS7·LPDDR5/5X 모드, 채널 손실 12.5 dB @ 10 GHz | 개인 TX 모델링; 기존 파형·코드별 Eye 관찰, 회로·칩 성능과 구분 | [제공 모델링 자료의 TX 결과](lpddr-tx-modeling.md) |
| Combo PHY TX Eye | 14 Gb/s/pin·4-DQ 활성 조건에서 0.41 UI·65.3 mV | 개인 설계 TX가 적용된 공동 칩의 실측 | [A-SSCC 2026: Combo PHY](https://epapers2.org/asscc2026/ESR/paper_details.php?paper_id=1141) |
| Combo PHY RX margin | TX–RX 연결·4-DQ 활성 조건에서 0.25 UI·25 mV | 공동 RX Shmoo 평가 결과; 개인 RX 회로 설계나 자동화에 따른 마진 개선량으로 해석하지 않음 | [A-SSCC 2026: Combo PHY](https://epapers2.org/asscc2026/ESR/paper_details.php?paper_id=1141) |

결과는 표에 연결한 논문과 작성자 제공 연구자료를 기준으로 정리했습니다. A-SSCC 2026 Combo PHY 논문은 2026-10-07 공식 정보 기준 채택·발표 예정입니다. 동작 모델·회로 시뮬레이션·실리콘 측정은 구성과 조건이 다르므로 각 데이터율을 직접적인 성능 증감으로 비교하지 않습니다. [논문 전체 제목과 근거](evidence.md)

## 측정 장비와 사용 목적

[검증 그림: TX 시뮬레이션 Eye·공동 칩 Eye와 Shmoo](verification-figures.md#lpddr-tx-ffe-적용-전후의-시뮬레이션)에서 위 결과의 실제 파형을 확인할 수 있습니다.

LPDDR 평가에는 Keysight 86100D·86118A, M8195A AWG, E3631A 전원공급기와 Anritsu MP1800A BERT를 사용했습니다. 파형·Eye 관측, 입력 신호 공급, 전원·기준전압 변경과 오류 집계를 역할별로 연결했습니다. RX 조건을 반복 변경하는 자동화에서는 칩의 Vref와 BERT의 판정 임계값을 구분하고, 전원 변화가 출력 레벨에 미치는 영향을 측정 설정에 반영했습니다.

장비별 활용과 AWG·Shmoo 자동화의 상세 범위는 [측정 장비와 활용 사례](measurement-equipment.md)에서 확인할 수 있습니다.
