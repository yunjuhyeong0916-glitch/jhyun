# LPDDR TX 회로 설계·검증: FFE와 PEX 이후 동작 확인

[LPDDR 연구 개요](lpddr.md) · [TX Verilog 모델링](lpddr-tx-modeling.md) · [측정 장비](measurement-equipment.md) · [논문·담당 역할](evidence.md)

**담당:** 28-nm CMOS TX 회로 설계·Schematic/Post-Layout 검증. **검증:** 회로 시뮬레이션.

[TX Verilog 모델](lpddr-tx-modeling.md) · [Combo PHY 제작 칩 측정](lpddr.md#검증-결과와-조건)

## 1. Main 데이터와 1-UI 지연 데이터를 함께 사용하는 TX

PI-LVSTL TX에 main·1-UI 지연 경로를 두고 드라이버 세그먼트와 FFE 계수를 제어해 de-emphasis를 적용했습니다. [ICEIC 2025](https://doi.org/10.1109/ICEIC64972.2025.10879746)

<details>
<summary>TX 데이터·클록·ZQ 경로 구조도 보기</summary>

![64비트 PRBS와 직렬화 및 main과 1UI 지연 FFE 경로, 클록과 ZQ 보정 블록으로 구성된 TX](../assets/lpddr_tx_circuit_architecture.jpg)

**회로 구성:** 64-bit PRBS → 64:4 → 4:1 직렬화 → main/1-UI 지연 FFE.

</details>

**ZQ 시험 설정:** 외부 지정 코드를 선택해 출력 임피던스를 제어했습니다.

## 2. FFE 적용 전후의 Eye로 보상 효과 확인

15.6-Gb/s TX의 FFE off/on 시뮬레이션에서 **Eye 폭 37 → 45.4 ps, 높이 56.5 → 75.1 mV**를 확인했습니다.

| FFE off | FFE on |
|---|---|
| ![FFE off 조건의 TX 시뮬레이션 Eye, 폭 37ps 높이 56.5mV](../assets/lpddr_tx_circuit_eye_ffe_off.png) | ![FFE on 조건의 TX 시뮬레이션 Eye, 폭 45.4ps 높이 75.1mV](../assets/lpddr_tx_circuit_eye_ffe_on.png) |

**조건:** 15.6 Gb/s 회로 시뮬레이션. ICEIC 논문 조건은 내부 전원 1.05 V·드라이버 전원 0.5 V·채널 손실 8.7 dB입니다.

## 3. PEX 이후 데이터율·전력 검증

배선 기생성분이 TX 동작에 미치는 영향을 확인하기 위해 DRC·LVS를 거쳐 기생성분을 추출하고, 추출 netlist를 FineSim에서 시뮬레이션했습니다. TX의 LVS 정합성을 확인했습니다.

출력 PRBS7 한 주기의 127 bits가 약 8.14 ns에 반복되어 **127 / 8.14 ns ≈ 15.6 Gb/s**로 계산됩니다.

<details>
<summary>PRBS7 출력 주기로 데이터율 확인</summary>

![TX 시뮬레이션 출력에서 PRBS7 한 주기 8.14ns를 확인한 파형](../assets/lpddr_tx_circuit_prbs7_period.png)

**속도 확인:** 127-bit 반복 패턴과 8.14-ns 구간을 이용한 PRBS7 출력 데이터율 계산입니다.

</details>

전력은 내부 전원과 드라이버 전원의 기여를 각각 계산했습니다. 선택한 시뮬레이션 구간의 평균전류 크기는 VDD2H에서 9.86 mA, VDDQ에서 3.16 mA입니다. 두 레일을 합하면 **9.86 mA × 1.05 V + 3.16 mA × 0.5 V ≈ 11.93 mW**, 이를 15.6 Gb/s로 나누면 **약 0.76 pJ/bit**입니다.

<details>
<summary>두 전원 레일의 평균전류 파형 보기</summary>

![내부 전원과 드라이버 전원의 시뮬레이션 전류 및 평균값](../assets/lpddr_tx_circuit_supply_current.png)

**전류 판독:** 선택 구간의 평균전류 크기를 사용했습니다. 그래프의 음수 부호는 전압원 전류의 기준 방향입니다.

</details>

<a id="4-시험자료의-갱신값과-논문공동-측정의-구분"></a>

<details>
<summary>추가 회로 시뮬레이션의 TX Eye·면적·전력</summary>

## 4. 추가 회로 시뮬레이션

11월 4일 추가 시뮬레이션의 TX Eye는 **46 ps·75.7 mV**입니다. 앞의 FFE 적용 전후 비교는 10월 시뮬레이션 결과입니다.

![추가 회로 시뮬레이션의 TX Eye, 폭 46ps 높이 75.7mV](../assets/lpddr_tx_circuit_updated_eye.png)

| 항목 | 결과 | 조건 |
|---|---|---|
| TX 데이터율 | 15.6 Gb/s | PRBS7 출력 주기로 확인한 시뮬레이션 |
| TX 전원·전력·에너지 | 1.05 V / 0.5 V, 약 11.93 mW·0.76 pJ/bit | 두 전원 레일을 합산한 TX 결과 |
| TX 면적 | 0.0201 mm² | PRBS·데이터·드라이버·ZQ·클록 경로를 포함한 TX 합계 |
| TX Eye | 46 ps·75.7 mV | 해당 시뮬레이션 버전의 Eye 폭·높이 |

</details>

## 관련 논문

- [ICEIC 2025: 저전압 NRZ TX](https://doi.org/10.1109/ICEIC64972.2025.10879746) — 저전압 TX 구조와 15.6-Gb/s·0.76-pJ/bit 시뮬레이션.
- [A-SSCC 2026: LPDDR4X/5/5X Combo PHY](https://epapers2.org/asscc2026/ESR/paper_details.php?paper_id=1141) — 설계한 TX가 적용된 Combo PHY의 제작 칩 측정. 채택·발표 예정.
