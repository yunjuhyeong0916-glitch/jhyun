# 검증 결과와 근거

## 기존 FIR 테스트 재실행: 2026-09-09

환경: Windows, Vivado XSim 2022.2. 실행일: 2026-09-09. RTL과 테스트벤치는 원본 그대로 복사했습니다.

| 기존 테스트벤치 | 결과 | TB의 실행 주기 설정 | 정렬 기준 |
|---|---|---:|---|
| TX FIR systolic equivalence | PASS | 800 | 기준 회로 대비 추가 지연 7 cycles |
| RX EQ21 segmented/transposed equivalence | PASS | 900 | 비교 지연 7 cycles |
| RX EQ21 old/segmented equivalence | PASS | 900 | 회로 간 지연 차이 3 cycles |

근거: [재실행 결과 JSON](../reports/fir_validation_20260909.json), [테스트벤치](../tb/), [실행 스크립트](../scripts/run_fir_tests.py).

TB 출력의 `checked=800/900`은 TB의 전체 반복 횟수입니다. 실제 출력 비교는 각 TB가 정한 초기 대기 구간 이후에 수행하므로 800/900개 출력 전체를 비교했다는 뜻으로 사용하지 않습니다. 입력은 TB에 구현된 의사난수·계수 조건이며, 이 결과는 모든 입력에 대한 형식적 동등성 증명이 아닙니다. MLSD 전체 검출기 정합성과 보드 실측은 이번 재실행 범위에 포함되지 않습니다.

## MLSD 메트릭 최소 예제와 어댑터 회귀: 2026-10-07

Windows·Vivado XSim 2022.2에서 새 테스트벤치로 원본 RTL을 실행했습니다. 합성 채널 두 조건 모두 메트릭 모듈 검사는 통과했고, 전체 어댑터는 출력 불일치가 발생했습니다.

| 검사 | 결과 | 확인 범위 |
|---|---|---|
| 8-lane branch 산술·후보 보존·목적 상태 도달 | 두 조건 PASS | 조건별 512심볼 × 16원소, signed 8-bit·Q8·L1 |
| 8심볼 block min-plus 결합 | 두 조건 PASS | 조건별 block 행렬 1,024원소 |
| 실제 RTL 행렬의 Python traceback | 두 조건 PASS | 조건별 512레벨 모두 기준값 일치; RTL traceback 제외 |
| 변조한 기대값의 불일치 검출 | PASS | 기대 심볼 한 개 변경을 오류로 검출 |
| 32-lane 전체 보드 어댑터 | 두 조건 FAIL | 첫 검사 word lane 1: 기대 32, 실제 -32 |

메트릭 타일의 관측 지연은 6 cycles(8-ns TB 클록)입니다. 단순 slicer는 잔류 ISI 벡터에서 203/512심볼 오류, RTL 행렬을 이용한 Python 복원은 0/512심볼 오류였습니다. 이는 결정적 예제의 심볼 비교이며, BER·일반 알고리즘 동등성·FPGA 타이밍 성과로 해석하지 않습니다. `g2=0`인 memory-0/1 입력이므로 memory-2 reduced-state 이력 동작도 검증하지 않습니다.

[예제·실행 명령·상세 조건](../examples/mlsd_minimal/) · [메트릭 PASS 기록](../reports/mlsd_metric_example_20261007/summary.json) · [어댑터 FAIL 기록](../reports/mlsd_adapter_audit_20261007/summary.json)

## 원 프로젝트의 기존 FPGA 구현 기록

아래 값은 2026-06-29 생성된 `impl_1` 보고서를 2026-09-09에 읽어 확인한 것입니다. 이번 RTL 복사본으로 합성·배치배선을 다시 실행하지 않았으며, 당시 구현 입력과 이번 소스 사이의 일치를 보증할 소스 해시 기록도 없습니다.

| 항목 | 값 | 구현 단계 |
|---|---:|---|
| Setup WNS | +0.083 ns | Post-route physopt |
| Setup TNS | 0.000 ns | Post-route physopt |
| Hold WHS | +0.010 ns | Post-route physopt |
| Hold THS | 0.000 ns | Post-route physopt |
| Fully routed / routable nets | 419,666 / 419,666 | Route status |
| Routing errors | 0 | Route status |
| CLB LUTs | 204,436 / 425,280 (48.07%) | Placed utilization |
| CLB Registers | 217,999 / 850,560 (25.63%) | Placed utilization |
| DSPs | 940 / 4,272 (22.00%) | Placed utilization |
| Block RAM Tile | 24.5 / 1,080 (2.27%) | Placed utilization |

자원 값은 전체 설계의 **placed** 보고서에서 가져왔으며, MLSD 단독 자원 또는 post-route physopt 단계의 자원으로 표시하지 않습니다. `.bit` 파일의 존재도 원 프로젝트에서 확인했지만 배포하지 않습니다.

원 보고서는 적용된 사용자 타이밍 제약을 만족한다고 기록합니다. 동시에 `no_output_delay (2)`와 CDC·리셋·동기화 관련 methodology warning을 포함합니다. 따라서 모든 I/O 제약과 CDC 검토까지 완료한 signoff로 표현하지 않습니다. 포함된 methodology 표 자체에도 이전 분석 결과일 수 있다는 도구 안내가 있습니다.

보고서 근거:

- [Post-route physopt timing summary 발췌](../reports/design_1_wrapper_timing_summary_postroute_physopted_excerpt.txt)
- [Placed utilization](../reports/design_1_wrapper_utilization_placed.txt)
- [Route status](../reports/design_1_wrapper_route_status.txt)
- [원 보고서 해시와 경로](../reports/report_provenance.json)

## 관련 논문의 시스템 검증

[A-SSCC 2026 관련 논문 공식 정보](https://epapers2.org/asscc2026/ESR/paper_details.php?paper_id=1351)에는 DS-SBM RS-MLSD를 포함한 PAM4 송수신기의 ZCU208 RFSoC 시스템 검증이 보고되어 있습니다. 논문의 결과는 해당 논문 버전과 측정 조건에 연결됩니다. 이 폴더의 FIR 재실행 결과·기존 구현 보고서와의 관계는 [논문과 공개 소스의 관계](architecture.md#관련-논문과-공개-소스의-관계)에서 확인할 수 있습니다.

논문 버전의 상세 측정자료는 추가할 예정입니다. 아래 그림은 논문에 보고된 시스템 측정 결과입니다.

![논문에 보고된 RFSoC 시스템의 PRBS7·PRBS15 BER 컨투어](../assets/mlsd_paper_measured_ber_contours.png)

**조건·관련 논문:** A-SSCC 2026 논문 p. 2 Fig. 5의 BER contour 영역. 논문에 보고된 41-dB 손실 조건에서 PRBS7 BER < 10⁻⁷, PRBS15 BER < 2 × 10⁻⁶의 결과입니다. 논문 버전의 시스템 측정이며, 위 합성 벡터 검사나 공개 어댑터의 새 보드 실행 결과와 구분합니다. [공식 정보](https://epapers2.org/asscc2026/ESR/paper_details.php?paper_id=1351)

## 공개 RTL의 검증 범위

공개 RTL 스냅샷으로 논문의 보드 BER와 무오류 수신 시간을 재현한 결과는 아직 포함하지 않았습니다. 이는 위 논문 버전의 시스템 측정과 별개 항목입니다. 전체 MLSD의 엄밀한 알고리즘 동등성, ASIC PPA와 물리설계 signoff도 공개본의 검증 범위에 포함되지 않습니다. 기존 ADC replay 후보별 score는 최종 BER와 구분합니다.
