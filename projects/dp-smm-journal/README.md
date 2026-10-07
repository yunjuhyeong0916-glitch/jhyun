# Journal 준비 | DP-SMM 기반 PAM4 검출기

심볼별 경로 메트릭(PM) 갱신의 의존성을 줄이기 위해, 32심볼 프레임을 구간 메트릭 행렬로 처리하는 **DP-SMM RS-MLSD**를 설계했습니다. 행렬 원소마다 두 경로 후보를 보존하고, 실제 심볼 이력을 반영한 비용과 이전 프레임의 PM으로 최종 경로를 선택합니다.

[검출기 구조](docs/architecture.md) · [RTL 검증·FPGA 구현](docs/validation.md) · [DS-SBM·DP-SMM 비교 연구](../pam4-mlsd-thesis/)

## 32심볼 병렬 처리 구조

![DP-SMM의 32심볼 프레임 분할과 구간 행렬 합성·PM 갱신·경로 복원](assets/dp_smm_frame_schedule.jpg)

여덟 개의 4심볼 기초 행렬을 네 개의 8심볼 세그먼트로 묶고, 두 단계의 rank-2 min-plus 합성으로 32심볼 프레임 행렬을 만듭니다. 구간 계산에는 이전 프레임의 누적 PM을 넣지 않고, 프레임 경계에서 이력을 반영한 비용과 결합합니다.

## RTL 검증 결과

| 검증 대상 | 결과 | 범위 |
|---|---|---|
| 두 경로 검출 코어 | 참조 모델 일치 | 제안 후보·이력 반영 비용·경계 survivor·복원 출력 |
| 행렬 K=1·경계 H=2 비교 코어 | 해당 참조 모델과 일치 | 행렬 후보 수를 제한한 비교 구조 |
| RX FFE를 포함한 경로 | 참조 모델 일치 | 11-tap RX FFE·검출기 통합 |
| 연속 입력 처리 | II=1 | 코어 지연 23클록, FFE 포함 24클록 |

32심볼·125 MHz·II=1의 설계 처리율은 **4 Gsymbol/s**, 비부호화 PAM4 **8 Gb/s**입니다. [검증 조건·구현 자원](docs/validation.md)

## 측정 준비

DP-SMM 보드 실측은 예정입니다. AWG 기반 ADC-DSP 수신 경로와 DAC–ISI 보드–ADC 송수신 경로의 평가를 준비합니다. 기존 DS-SBM의 측정 성과는 [A-SSCC 프로젝트](../zcu208-pam4-dsp-portfolio/)에서 확인할 수 있습니다.

## 관련 연구

**Journal 원고 준비 중입니다.** 학위논문에서는 DS-SBM과 DP-SMM의 신호 경로·후보 보존·메트릭 합성을 비교하고, 동일 입력의 R=1/R=2 코어 검증을 다룹니다.

[A-SSCC DS-SBM](../zcu208-pam4-dsp-portfolio/) · [학위논문 비교 연구](../pam4-mlsd-thesis/) · [연구 성과 논문](../../docs/publications.md)
