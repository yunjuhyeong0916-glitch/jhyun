# 학위논문 DP-SMM 구조·검증 범위

[프로젝트](../README.md) · [DP-SMM 검증 결과](validation.md) · [A-SSCC DS-SBM 설계 판단](../../zcu208-pam4-dsp-portfolio/docs/design-decisions.md)

## DP-SMM 검증에 사용한 RTL

DP-SMM 연구의 2026년 10월 검증은 **2026-09-09 RTL**을 기준으로 수행했습니다. 검사한 RTL은 이전 상태별 nearest branch 후보 두 개를 보존하고, 도착 상태가 연결되지 않는 경우 destination rescue를 사용합니다. 8-lane 메트릭 타일의 변환을 결합해 32-lane 경로에 연결하는 구조입니다.

| 단계 | 검사 방법 | 현재 확인 범위 |
|---|---|---|
| Branch 메트릭 | 산술·후보 보존·목적 상태 도달을 기준값과 비교 | memory-0/1 두 조건 PASS |
| 8심볼 min-plus 결합 | RTL block 행렬을 기준 행렬과 비교 | 두 조건 PASS |
| 경로 복원 참조 | RTL 행렬을 Python traceback에 입력 | 두 조건에서 각각 512레벨 일치 |
| 전체 어댑터 | 32-lane RTL 출력과 기대 심볼 비교 | 두 조건 FAIL, 정렬 원인 검토 중 |

메트릭 행렬과 Python 복원 검사는 g₂=0인 memory-0/1 조건에서 수행했습니다. memory-2 이력을 포함한 DP-SMM 전체 RTL 경로의 정합성은 추가 검증 대상입니다.

## DS-SBM과 DP-SMM 검증의 구분

| 항목 | A-SSCC DS-SBM | 학위논문 DP-SMM 검증에 사용한 RTL |
|---|---|---|
| 32-symbol 처리의 구간 표현 | 8개 4-symbol 구간의 계층적 결합 | xform export의 4개 8-lane 타일 |
| 후보 유지의 설명 | 상태별 두 survivor branch, 8 active branches/symbol | 이전 상태별 nearest branch 후보 두 개와 destination rescue |
| 확인 근거 | DS-SBM 논문 구조·검출기 자원 비교·RFSoC 측정 | 메트릭 행렬·Python 참조 복원·전체 어댑터 검사 |

A-SSCC의 RFSoC 측정 성과는 DS-SBM 결과이며, DP-SMM의 정합성은 학위논문 검증에서 확인합니다. [DS-SBM 구조·설계 판단](../../zcu208-pam4-dsp-portfolio/docs/design-decisions.md) · [DP-SMM 검증 조건·결과](validation.md)
