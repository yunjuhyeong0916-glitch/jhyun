# MLSD 메트릭 RTL 최소 실행 예제

[프로젝트](../../README.md) · [설계 판단](../../docs/design-decisions.md) · [검증 범위](../../docs/validation.md)

잔류 ISI가 있으면 같은 수신 샘플이라도 직전 심볼에 따라 해석이 달라집니다. 이 예제는 공개한 **8-lane 메트릭 RTL**에 합성 입력을 넣고, 실제로 출력된 sparse branch matrix를 Python에서 경로 복원하여 기준 심볼과 비교합니다. RTL의 전체 traceback·보드 경로 검증은 아래의 별도 회귀 테스트로 구분합니다.

## 실행

Python 3.9 이상과 Vivado XSim 2022.2를 사용합니다. 실행 스크립트는 Python 표준 라이브러리만 필요합니다. 프로젝트 폴더에서:

```powershell
# Vivado 없이 입력 산술·독립 Viterbi 기준값 확인
python scripts/run_mlsd_example.py --check-vectors-only

# 공개 RTL 컴파일·실행, 행렬 검사·심볼 복원·실패 감지 확인
python scripts/run_mlsd_example.py --vivado-bin "C:\Xilinx\Vivado\2022.2\bin" --check-failure-path
```

완료 시 두 조건의 `status: PASS`, `Mismatch detection: PASS`와 결과 JSON 경로를 출력하고 종료 코드 0을 반환합니다. 결과·원시 행렬 CSV·복원 CSV·도구 로그는 Git에서 제외되는 `work/mlsd_minimal_<실행시각>/`에 저장됩니다. 입력·RTL·TB·실행 스크립트의 SHA-256도 기록합니다. [2026-10-07 실행 기록](../../reports/mlsd_metric_example_20261007/summary.json)

## 입력과 기대 출력

PAM4 레벨은 `[-96, -32, 32, 96]`, 초기 직전 레벨은 `-96`입니다. 각 CSV는 512개 심볼과 정수 잡음 `[-3, 3]`을 포함합니다. `state`는 레벨 인덱스이며, 기대 출력은 전송한 **8-bit 레벨**입니다. 비트 매핑·PRBS BER는 이 예제의 비교 항목에 포함하지 않습니다.

`sample[n] = ((g0_q8 × level[n] + g1_q8 × level[n-1]) >> 8) + noise[n]`

| 입력 | Q8 계수 `(g0, g1, g2)` | 의미 | 메모리 없는 slicer 오류 | RTL 행렬 + Python 복원 오류 |
|---|---|---|---:|---:|
| [memoryless.csv](memoryless.csv) | `(256, 0, 0)` | 현재 심볼만 관측 | 0 / 512 | 0 / 512 |
| [residual_isi.csv](residual_isi.csv) | `(192, 128, 0)` | 직전 심볼의 영향이 남은 채널 | 203 / 512 | 0 / 512 |

위 값은 이 두 결정적 합성 벡터의 심볼 오류 수입니다. Slicer는 `g0 × level`에 가장 가까운 레벨을 고릅니다. 비교 기준은 모든 상태 전이를 탐색하는 독립 4-state·memory-1 L1 Viterbi이며, RTL은 직전 상태별 가까운 두 branch와 destination rescue를 사용합니다. 특정 벡터에서의 일치는 다른 채널이나 full-state MLSD와의 일반적 동등성을 의미하지 않습니다.

![잔류 ISI 합성 입력과 실제 RTL 메트릭으로 복원한 심볼](../../assets/mlsd_minimal_recovery.png)

**그림:** [실행 CSV](../../reports/mlsd_metric_example_20261007/residual_isi_recovery.csv)에서 생성한 합성 데이터 검증 그림입니다. FPGA 측정 파형이 아닙니다. [그림 생성 코드](../../scripts/plot_mlsd_example.py)

그림을 다시 만들려면 별도로 `matplotlib`을 설치한 환경에서 다음을 실행합니다. 검증 실행 자체는 이 패키지가 필요하지 않습니다.

```powershell
python scripts/plot_mlsd_example.py reports/mlsd_metric_example_20261007/residual_isi_recovery.csv assets/mlsd_minimal_recovery.png
```

## PASS 기준과 지연

- 각 조건에서 64개 8-lane 입력을 받아 512개 심볼의 행렬을 빠짐없이 출력합니다. 연속 입력과 두 번의 3-cycle valid 공백을 포함합니다.
- unknown 출력, 중복·누락 행렬, 출력 수·지연 변화를 실패로 처리합니다.
- 심볼별 16개 행렬 원소(총 8,192개)의 유한 메트릭이 Q8 채널 예측과 L1 거리 산술에 일치해야 합니다. 가까운 두 branch의 보존과 모든 목적 상태의 도달 가능성을 검사합니다.
- 8심볼 block 행렬 원소 1,024개가 출력 lane 행렬의 정규화 min-plus 곱과 일치해야 합니다.
- 실제 RTL 행렬의 Python traceback 결과가 512개 기대 레벨 모두와 일치해야 합니다. 기대 심볼 하나를 일부러 바꾼 검사는 불일치를 검출해야 합니다.

2026-10-07 실행에서 메트릭 타일의 입력 수락부터 행렬 출력까지 **6 cycles**였습니다. TB 클록은 8 ns이며, 합성 타이밍이나 RTL 전체 검출기의 판정 지연을 나타내지 않습니다. 고정소수점 조건은 signed 8-bit 입력, Q8 계수, 12-bit unsigned 메트릭, `4095`의 INF 예약값, L1 거리, pair normalization입니다. 이 입력은 overflow/saturation 경계를 시험하지 않습니다.

## 전체 어댑터 회귀 테스트에서 확인한 불일치

```powershell
python scripts/run_mlsd_example.py --vivado-bin "C:\Xilinx\Vivado\2022.2\bin" --audit-adapter
```

이 명령은 원본 **32-lane 보드 어댑터·xform export·RTL traceback**까지 연결합니다. EQ를 우회하고 `g2=0`, `TB=40`을 사용하며, 준비용 2 word 이후 512개 레벨을 비교합니다. 2026-10-07 실행에서는 두 조건 모두 첫 검사 word의 lane 1에서 기대 `32`, 실제 `-32`로 실패했습니다. 스크립트는 이를 숨기지 않고 **종료 코드 1**과 FAIL JSON을 반환합니다. [실패 기록·로그](../../reports/mlsd_adapter_audit_20261007/)

Memoryless 조건의 첫 검사 출력 전체는 네 번째 입력 word의 기대 레벨과 일치했습니다. [rowpipe](../../rtl/ds_sbmm_rs4_apply_xform_rowpipe.sv)의 기본 설정에서는 데이터 레지스터가 `in_valid` 때 갱신되는 반면, `out_valid`는 세 valid 레지스터를 거칩니다. 출력 데이터·valid·trace metadata의 정렬을 추가로 확인해야 합니다. 전체 원인을 확정하거나 RTL을 수정한 상태는 아니며, **원본 RTL 26개는 그대로 보존**했습니다. 따라서 위의 메트릭 모듈 PASS를 전체 어댑터 PASS로 확장하지 않습니다.
