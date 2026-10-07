# 학위논문 연구 | DS-SBM·DP-SMM 비교 (진행 중)

축소 상태 MLSD의 후보 선택이 판정 성능에 미치는 영향을 연구하고 있습니다. **DS-SBM과 DP-SMM의 신호 경로·후보 보존·메트릭 합성·프레임 경계 갱신**을 비교하고, 동일 입력의 코어 시험으로 행렬 경로 수의 영향을 확인했습니다.

[첫 화면](../../README.md) · [구조 비교](docs/architecture.md) · [모델·RTL 비교 결과](docs/validation.md) · [A-SSCC DS-SBM](../zcu208-pam4-dsp-portfolio/) · [Journal DP-SMM](../dp-smm-journal/)

## 비교의 핵심

![DS-SBM과 DP-SMM의 관측 입력·행렬 경로 보존·프레임 경계 갱신 비교](assets/thesis_architecture_comparison.png)

왼쪽 DS-SBM은 행렬 원소별 한 경로를, 오른쪽 DP-SMM은 두 경로 후보와 이력 정보를 유지합니다. 프레임 경계에서 비용을 결합하는 방식까지 나란히 비교했습니다.

| 항목 | DS-SBM | DP-SMM |
|---|---|---|
| 관측 신호 | 21-tap RX FFE 뒤 별도 PR FIR 출력 | 11-tap RX FFE 출력, PR 목표는 예상 샘플 계산에 사용 |
| 행렬 원소별 경로 | 한 경로 | 두 경로 후보와 이력 반영 비용 정보 |
| 프레임 경계 | 가시 상태별 PM 한 개 | 가시 상태별 PM·이력 후보 두 개 |

두 수신기의 필터와 관측 경로가 달라, 행렬 후보 수의 효과는 FFE 뒤의 동일 코어 입력에서 R=1/R=2를 비교해 평가했습니다. [비교 구조와 조건](docs/architecture.md)

## 확인한 결과

후보 경로의 비용과 복원 심볼이 함께 전달되는지 확인하기 위해 참조 모델과 RTL의 내부 비용·이력·출력을 대조했습니다. 연속 입력과 공백 입력, 처리 중 리셋에서도 복원 순서와 지연이 기준과 일치했습니다.

경계 후보 수를 두 개로 고정한 합성 입력 비교에서는, SNR 16 dB의 응답 A·B에서 R=2의 오류 수가 R=1보다 각각 **36.9%·46.1% 감소**했습니다. 이 결과는 DP-SMM 코어의 행렬 후보 보존 효과를 확인한 것입니다. [입력 조건·오류 수·RTL 검증 범위](docs/validation.md)

## 하드웨어 검증

DS-SBM RFSoC 송수신 시스템의 측정 결과는 추정 손실 41 dB에서 PRBS7 BER < 10⁻⁷·PRBS15 BER < 2×10⁻⁶입니다. DP-SMM은 보드 측정 준비 단계이며, AWG 기반 ADC-DSP 수신 경로의 BER·PR 등고선·연속 처리율을 평가할 예정입니다.

[DS-SBM 시스템 측정](../zcu208-pam4-dsp-portfolio/docs/validation.md) · [DP-SMM 구조와 Journal 준비](../dp-smm-journal/)

**도구:** Verilog / SystemVerilog · Vivado XSim 2022.2 · Python
