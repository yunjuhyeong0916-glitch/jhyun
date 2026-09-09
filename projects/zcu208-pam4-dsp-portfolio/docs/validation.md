# 검증 결과와 근거

## 이번 공개 소스에서 다시 실행한 검증

환경: Windows, Vivado XSim 2022.2. 실행일: 2026-09-09. RTL과 테스트벤치는 원본 그대로 복사했습니다.

| 기존 테스트벤치 | 결과 | TB의 실행 주기 설정 | 정렬 기준 |
|---|---|---:|---|
| TX FIR systolic equivalence | PASS | 800 | 기준 회로 대비 추가 지연 7 cycles |
| RX EQ21 segmented/transposed equivalence | PASS | 900 | 비교 지연 7 cycles |
| RX EQ21 old/segmented equivalence | PASS | 900 | 회로 간 지연 차이 3 cycles |

근거: [재실행 결과 JSON](../reports/fir_validation_20260909.json), [테스트벤치](../tb/), [실행 스크립트](../scripts/run_fir_tests.py).

TB 출력의 `checked=800/900`은 TB의 전체 반복 횟수입니다. 실제 출력 비교는 각 TB가 정한 초기 대기 구간 이후에 수행하므로 800/900개 출력 전체를 비교했다는 뜻으로 사용하지 않습니다. 입력은 TB에 구현된 의사난수·계수 조건이며, 이 결과는 모든 입력에 대한 형식적 동등성 증명이 아닙니다. MLSD 전체 검출기 정합성과 보드 실측은 이번 재실행 범위에 포함되지 않습니다.

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

## 이 자료에서 주장하지 않는 결과

최종 실측 BER, 무오류 수신 시간, 전체 MLSD의 엄밀한 알고리즘 동등성, ASIC PPA 및 물리설계 signoff는 이 공개 자료로 입증하지 않습니다. 기존 ADC replay 후보별 score도 최종 BER 성과에 포함하지 않았습니다.
