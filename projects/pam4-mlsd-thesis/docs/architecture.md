# 학위논문 프로젝트의 MLSD 구조·검증 범위

[프로젝트](../README.md) · [검증 결과](validation.md) · [A-SSCC 설계 판단](../../zcu208-pam4-dsp-portfolio/docs/design-decisions.md)

## 검증에 사용한 RTL

2026년 10월 검증의 기준은 **2026-09-09 RTL**입니다. 이전 상태별 nearest branch 후보 두 개를 보존하고, 도착 상태가 연결되지 않는 경우 destination rescue를 사용합니다. 8-lane 메트릭 타일의 변환을 결합해 32-lane 경로에 연결하는 구조입니다.

| 단계 | 검사 방법 | 현재 확인 범위 |
|---|---|---|
| Branch 메트릭 | 산술·후보 보존·목적 상태 도달을 기준값과 비교 | memory-0/1 두 조건 PASS |
| 8심볼 min-plus 결합 | RTL block 행렬을 기준 행렬과 비교 | 두 조건 PASS |
| 경로 복원 참조 | RTL 행렬을 Python traceback에 입력 | 두 조건에서 각각 512레벨 일치 |
| 전체 어댑터 | 32-lane RTL 출력과 기대 심볼 비교 | 두 조건 FAIL, 정렬 원인 검토 중 |

메트릭 행렬 검사와 Python 복원은 전체 RTL traceback의 정합성을 확인하는 단계와 구분합니다. memory-2 이력을 포함한 전체 경로 Rank-2·16-state MLSD와의 동등성은 미검증입니다.

## A-SSCC 논문과의 구조 비교

| 항목 | A-SSCC 논문 | 학위논문 검증의 기준 RTL |
|---|---|---|
| 32-symbol 처리의 구간 표현 | 8개 4-symbol 구간의 계층적 결합 | xform export의 4개 8-lane 타일 |
| 후보 유지의 설명 | 상태별 두 survivor branch, 8 active branches/symbol | 이전 상태별 nearest branch 후보 두 개와 destination rescue |
| 확인 근거 | 논문 구조·검출기 자원 비교·RFSoC 측정 | 9월 FIR 회귀, 10월 메트릭·전체 어댑터 검사 |

후보 수와 구간 표현이 다르므로 논문의 구조 설명을 해당 RTL의 검증 결과로 바로 대체할 수 없습니다. [논문 구조·설계 판단](../../zcu208-pam4-dsp-portfolio/docs/design-decisions.md) · [공식 논문 정보](https://epapers2.org/asscc2026/ESR/paper_details.php?paper_id=1351)

## 버전과 실행 시점

| 구분 | 시점 | 내용 |
|---|---|---|
| RFSoC 시스템·기존 구현 기록 | 2026년 6월 | A-SSCC 프로젝트에 정리한 캡처·분석·자원·타이밍 |
| 검증 기준 RTL·FIR 회귀 | 2026-09-09 | FIR 3종 PASS |
| 학위논문 추가 검증 | 2026-10-07 | 위 RTL의 메트릭 PASS·전체 어댑터 FAIL |

측정 당시 bitstream과 2026-09-09 RTL의 빌드 대응은 미확인입니다. [검증 조건·결과](validation.md)
