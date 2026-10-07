# 학위논문 연구 검증 결과

[프로젝트](../README.md) · [구조·검증 범위](architecture.md) · [A-SSCC 측정·구현 결과](../../zcu208-pam4-dsp-portfolio/docs/validation.md)

기준일: **2026-10-07**. 10월 검증은 2026-09-09 RTL을 사용했습니다.

## 10월 MLSD 메트릭·전체 어댑터

**실행:** 2026-10-07, Vivado XSim 2022.2. g₂=0인 memory-0/1 합성 채널 두 조건, PAM4 레벨 [−96, −32, 32, 96], signed 8-bit·Q8·L1 메트릭입니다.

| 검사 | 결과 | 확인 범위 |
|---|---|---|
| Branch 산술·후보 보존·목적 상태 도달 | 두 조건 PASS | 조건별 512심볼 × 16원소 |
| 8심볼 block min-plus 결합 | 두 조건 PASS | 조건별 block 행렬 1,024원소 |
| RTL 행렬의 Python traceback | 두 조건 PASS | 조건별 512레벨 모두 기준값 일치 |
| 기대값 변조 검출 | PASS | 기대 심볼 한 개 변경을 오류로 검출 |
| 32-lane 전체 보드 어댑터 | 두 조건 FAIL | 첫 검사 word lane 1 기대 32 / 실제 −32 |

![합성 채널에서 slicer와 RTL 행렬·Python 복원을 비교한 결과](../assets/mlsd_minimal_recovery.png)

**합성 입력 결과:** 잔류 ISI 벡터에서 slicer 오류 203/512, RTL 행렬·Python 복원 오류 0/512. 두 수치는 결정적 합성 입력의 레벨 오류 수입니다. 메트릭 지연은 6 cycles, 테스트벤치 클록 주기는 8 ns입니다. 전체 RTL traceback, memory-2 이력과 overflow·포화 경계는 미검증입니다.

### 전체 어댑터 출력 불일치

메트릭 모듈이 통과한 두 채널 조건에서 전체 어댑터는 모두 실패했습니다. 첫 검사 word의 lane 1에서 기대값 32와 실제값 −32가 달랐습니다. 데이터·valid·경로 이력의 정렬을 점검할 필요가 있으며, 불일치 원인은 아직 확정하지 않았습니다.

## FIR 출력 정합성

공통 RTL의 사전 회귀 기록입니다. **실행:** 2026-09-09, Vivado XSim 2022.2. 기준·비교 회로의 지연을 정렬한 뒤 32-lane 고정소수점 출력을 비교했습니다.

| 검사 | 결과 | 전체 반복 수 | 지연 정렬 |
|---|---|---:|---|
| TX FIR systolic equivalence | PASS | 800 | 추가 지연 7 cycles |
| RX EQ21 segmented/transposed equivalence | PASS | 900 | 비교 지연 7 cycles |
| RX EQ21 old/segmented equivalence | PASS | 900 | 회로 간 지연 차이 3 cycles |

출력 비교는 초기 대기 이후 시작했습니다. 입력은 테스트벤치의 의사난수·계수 조건입니다.

## 검증 상태

| 항목 | 상태 |
|---|---|
| FIR 회귀 기준 | 2026-09-09 PASS |
| 메트릭 모듈·Python 참조 복원 | 2026-10-07 두 조건 PASS |
| 전체 MLSD 어댑터 | 2026-10-07 두 조건 FAIL·출력 불일치, 정렬 원인 검토 필요 |
| 2026-09-09 RTL의 보드 BER·무오류 관측 시간 | 미재현 |
| 전체 MLSD 알고리즘 동등성·ASIC PPA·물리 signoff | 미검증 |

A-SSCC 논문에 보고한 시스템 BER와 6월 ADC 캡처·재생·통계 분석은 [별도 프로젝트의 측정 결과](../../zcu208-pam4-dsp-portfolio/docs/validation.md)에 정리했습니다.
