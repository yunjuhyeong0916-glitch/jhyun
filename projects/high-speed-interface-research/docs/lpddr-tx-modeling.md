# LPDDR Combo PHY: TX Verilog 모델링과 검증 파형

[LPDDR 회로·제작 칩 측정](lpddr.md) · [TX 회로 설계·검증](lpddr-tx-circuit-verification.md) · [파트 개요](../README.md) · [검증 그림](verification-figures.md) · [논문·근거](evidence.md)

**담당:** TX Verilog 동작 모델링. 32-bit 병렬 입력을 직렬화하고, 위상 정렬된 main/1UI 지연 데이터로 pre-emphasis 출력을 생성했습니다.

## 직렬화와 출력 보상을 연결한 TX 구조

32→16→8→4 직렬화와 위상 정렬·4:1 직렬화를 연결했습니다. `real` 출력과 다중 클록 에지를 사용하는 이벤트 기반 동작 모델입니다.

```mermaid
flowchart LR
    A[32-bit 병렬 입력] --> B[32 → 16 → 8 → 4]
    B --> C[위상 정렬 / 4:1 직렬화]
    C --> D[Main / 1UI 지연 데이터]
    D --> E[Pre-emphasis]
    E --> F[실수값 TX 출력]
    G[모드 / 2-bit 레벨 코드] --> E
```

| TX 구성 | 기능 |
|---|---|
| `DQ_TX` | 직렬화 경로와 출력 보상 모델을 연결하고, 모드·레벨 설정을 출력에 반영 |
| `SER_32to1` · `ALIGNER_TX` | 단계별 직렬화와 클록 위상 정렬을 통해 main 데이터와 1UI 지연 데이터를 생성 |
| `EQ_PREEMP_TX` | 두 데이터 사이의 전이를 검출하고, 모드별 swing과 레벨 코드에 따른 pre-emphasis를 실수값 출력으로 표현 |

클록은 공통 `LOCAL_CLK`에서 공급합니다.

## 단일 TX: 직렬화·보상·채널 출력의 관계

PRBS7 병렬 입력을 인가하고 직렬 데이터·1UI 지연·pre-emphasis·채널 출력을 관찰했습니다.

| 시뮬레이션 조건 | 설정 |
|---|---|
| 데이터율·입력 패턴 | 20 Gb/s · PRBS7 |
| 동작 모드 | `mode_sel = 0` · LPDDR5/5X |
| 채널 손실 | 12.5 dB @ 10 GHz |
| 결과 화면 | VCS · Questa |

**VCS 파형 — 직렬 데이터부터 채널 출력까지**

![VCS에서 관찰한 TX 직렬 데이터, 1UI 지연 데이터, pre-emphasis 출력과 채널 출력](../assets/lpddr_combo_tx_model_waveform_vcs.png)

**관측 신호:** 위부터 `ser_out`, `ser_delay_out`, `dout_pre`, `ch_out`.

**Questa 파형 — TX 출력과 채널 출력**

![Questa에서 관찰한 TX pre-emphasis 출력과 채널 출력](../assets/lpddr_combo_tx_model_waveform_questa.png)

**검증 방식:** VCS·Questa 파형 관찰.

## Pre-emphasis 코드에 따른 Eye 변화

2-bit 레벨 코드 `00`–`11`에 따른 pre-emphasis 출력 Eye입니다.

| 레벨 코드 `00` | 레벨 코드 `01` |
|---|---|
| ![Pre-emphasis 코드 00의 모델 시뮬레이션 Eye](../assets/lpddr_combo_tx_model_eye_00.png) | ![Pre-emphasis 코드 01의 모델 시뮬레이션 Eye](../assets/lpddr_combo_tx_model_eye_01.png) |

| 레벨 코드 `10` | 레벨 코드 `11` |
|---|---|
| ![Pre-emphasis 코드 10의 모델 시뮬레이션 Eye](../assets/lpddr_combo_tx_model_eye_10.png) | ![Pre-emphasis 코드 11의 모델 시뮬레이션 Eye](../assets/lpddr_combo_tx_model_eye_11.png) |

## 4-DQ 통합 환경에서 직렬 출력 확인

![Combo PHY 통합 모델의 Write 동작에서 관찰한 네 DQ TX 출력](../assets/lpddr_combo_tx_model_dq4_prbs.png)

**Write·PRBS7 동작 모델:** 위부터 DQ0–DQ3. 32-bit 병렬 입력을 인가해 네 DQ의 직렬 출력 패턴을 확인했습니다.

<a id="회로모델실리콘-결과의-검증-범위"></a>

## 검증 결과

| 자료 | 검증 단계와 기여 | 근거 |
|---|---|---|
| 20-Gb/s 파형·Eye | TX 동작 모델 시뮬레이션 | 위 TX 구조·단일 TX·4-DQ 검증 파형 |
| 15.6 Gb/s · 0.76 pJ/bit TX | TX 회로 설계·Schematic/Post-Layout 검증 | [ICEIC 2025](https://doi.org/10.1109/ICEIC64972.2025.10879746) · [회로 결과](lpddr.md#검증-결과와-조건) |
| 14 Gb/s/pin · 4-DQ Combo PHY | 설계한 TX가 적용된 Combo PHY의 제작 칩 측정 | [A-SSCC 2026](https://epapers2.org/asscc2026/ESR/paper_details.php?paper_id=1141) · [실측 그림](verification-figures.md#lpddr-combo-phy-공동-칩의-eye와-rx-shmoo) |
