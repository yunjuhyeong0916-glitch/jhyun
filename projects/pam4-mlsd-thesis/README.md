# 학위논문 연구 | PAM4 MLSD RTL 설계·검증

등화 뒤에 남은 ISI를 처리하는 PAM4 MLSD의 고정소수점 RTL을 검증하는 연구입니다. 메트릭 계산이 기준 모델과 일치하는지, 전체 경로가 같은 심볼을 복원하는지를 나누어 확인하고 있습니다.

[구조·검증 범위](docs/architecture.md) · [10월 검증 결과](docs/validation.md) · [A-SSCC 2026 프로젝트](../zcu208-pam4-dsp-portfolio/)

## 2026년 10월 진행 내용

2026-09-09 RTL을 기준으로 **10월 7일**에 메트릭 모듈과 32-lane 전체 어댑터를 검사했습니다. 메트릭 모듈은 두 합성 채널에서 기준값과 일치했고, 전체 어댑터에서는 출력 불일치가 남아 있습니다.

| 검증 대상 | 결과 | 확인 범위 |
|---|---|---|
| Branch 메트릭·8심볼 min-plus 결합 | 두 조건 PASS | 조건별 512심볼, branch·block 행렬 비교 |
| RTL 행렬을 이용한 Python 경로 복원 | 두 조건 PASS | 조건별 512레벨 모두 기준값 일치 |
| 기대값 변조 검출 | PASS | 기대 심볼 한 개 변경을 오류로 검출 |
| 32-lane 전체 MLSD 어댑터 | 두 조건 FAIL | 첫 검사 word lane 1 기대 32 / 실제 −32 |

합성 입력의 memory-0/1 조건에서 실행한 XSim 검증입니다. 전체 RTL 경로 복원과 보드 BER 검증은 남아 있습니다. [입력·클록·지연·결과](docs/validation.md)

## 남은 검증

- 전체 어댑터의 데이터·valid·경로 이력 정렬을 점검하고 출력 불일치의 원인을 확인합니다.
- memory-2 이력과 overflow·포화 경계를 포함해 기준 모델과 비교합니다.
- 검증한 RTL과 보드 bitstream의 빌드 대응을 확인한 뒤 해당 버전의 보드 BER를 평가합니다.

## A-SSCC 연구와의 관계

두 프로젝트는 PAM4 등화·MLSD와 ZCU208 데이터 경로를 공통 기반으로 사용합니다. A-SSCC 프로젝트에는 논문 구조와 RFSoC 시스템 측정, 6월 캡처·구현 기록을 정리했습니다. 이 프로젝트에는 공통 RTL의 9월 FIR 회귀를 기준 기록으로 두고, 10월 MLSD 추가 검증과 진행 중인 과제를 모았습니다.

6월 기록은 10월에 저장소에 추가됐지만 측정·분석 시점은 6월입니다. 논문 측정 결과와 10월 검증에 사용한 RTL의 빌드 대응은 미확인입니다.

[A-SSCC 측정·구현 결과](../zcu208-pam4-dsp-portfolio/docs/validation.md) · [논문·RTL 구조 비교](docs/architecture.md)

**도구:** Verilog / SystemVerilog · Vivado XSim 2022.2 · Python
