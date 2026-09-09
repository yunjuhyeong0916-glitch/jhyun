# 설계 구조와 소스 안내

## 프로젝트 기준

- 원 프로젝트: `DSP_based_TRX_32lane_PAM4_4GS_OPT`
- FPGA: `xczu48dr-fsvg1517-2-e`, 보드: ZCU208
- 원 프로젝트 top: `design_1_wrapper`
- 원 BD의 `ADC2_Sampling_Rate`, `DAC0_Sampling_Rate`: 각각 `4` GS/s 설정
- 기존 구현 보고서의 클록: `RFADC2_CLK` 125 MHz, `RFDAC0_CLK` 500 MHz
- 이 폴더의 RTL 복사 기준일: 2026-09-09

32-lane은 한 클록에 처리하는 병렬 데이터 수를 뜻합니다. 물리적 송수신 채널 32개를 뜻하지 않습니다. 32 samples × 125 MHz = 4 Gsamples/s는 데이터 경로의 명목 처리량 계산이며, 최종 검출 결과의 연속 출력이나 실측 데이터율을 별도로 보증하지 않습니다. 4 GS/s 설정을 200 Gb/s 실측 성과로 해석하지 않습니다.

## 대표 소스

| 영역 | 파일 | 읽을 내용 |
|---|---|---|
| 송신 패턴 | [TX_PRBS_MULTI_TOP_32LANE.sv](../rtl/TX_PRBS_MULTI_TOP_32LANE.sv), [PAM4_2b_to_8b.sv](../rtl/PAM4_2b_to_8b.sv) | PRBS 생성 및 PAM4 레벨 매핑 |
| 송신 필터 연결 | [TX_PAM_FIR_TOP.sv](../rtl/TX_PAM_FIR_TOP.sv), [TX_PAM_FIR_TOP_FLAT.sv](../rtl/TX_PAM_FIR_TOP_FLAT.sv) | 병렬 FIR 입력·출력 구성 |
| FIR 구현 | [pam4_fir_ffe_32lane_filters.sv](../rtl/pam4_fir_ffe_32lane_filters.sv) | TX 8-tap FIR, RX 21-tap FIR, 고정소수점 연산과 파이프라인 |
| 수신 인터페이스 | [rx_bd_shim_raw1024_to_bitplanes_rxdsp8b.v](../rtl/rx_bd_shim_raw1024_to_bitplanes_rxdsp8b.v) | FIFO 데이터 유효 신호, 계수 로딩, 디버그 출력 연결 |
| 수신 데이터 경로 | [rx_bd_shim_raw1024_to_bitplanes_mmrs_mlsd_fitfirst.v](../rtl/rx_bd_shim_raw1024_to_bitplanes_mmrs_mlsd_fitfirst.v) | EQ·검출 경로 선택과 통합 |
| MLSD 메트릭 | [ds_sbmm_rs4_metric_tile8_dual_survivor.sv](../rtl/ds_sbmm_rs4_metric_tile8_dual_survivor.sv) | 8-lane nearest-branch 메트릭 변환 타일 |
| MLSD 변환 결합 | [ds_sbmm_rs4_xform_export32.sv](../rtl/ds_sbmm_rs4_xform_export32.sv) | 32-lane 변환 연결과 출력 |
| MLSD 경로 복원 | [ds_sbmm_rs4_trace_shell32_rowpipe.sv](../rtl/ds_sbmm_rs4_trace_shell32_rowpipe.sv), [ds_sbmm_rs4_trace32_board_adapter.sv](../rtl/ds_sbmm_rs4_trace32_board_adapter.sv) | 경로 메트릭 및 trace/board 연결 |
| 계수 제어 | [pam4_rx_coeff_bram_loader.sv](../rtl/pam4_rx_coeff_bram_loader.sv) | BRAM을 통한 런타임 설정 갱신 |
| 오류 검사 | [RX_PRBSCHK_MULTI_TOP_32LANE_BER_AUTO.sv](../rtl/RX_PRBSCHK_MULTI_TOP_32LANE_BER_AUTO.sv) | PRBS 기준의 수신 데이터 검사 |

소스 파일명과 내부 모듈명이 일부 다릅니다. 원 프로젝트의 기존 명칭을 유지하기 위해 소스는 바꾸지 않고 복사했습니다. 26개 RTL 파일은 `sources_1/new`의 소스 스냅샷이며, 파일 존재가 모든 모듈의 활성화 또는 개별 검증 완료를 의미하지는 않습니다.

## MLSD 구조의 해석

이 버전의 metric tile에 있는 `SEGMENT_BRANCH_SURVIVORS`는 이전 상태별로 유지하는 branch 후보 수를 지정합니다. 파일명에 있는 dual-survivor를 전체 경로의 최상위 두 survivor를 엄밀히 유지하는 알고리즘으로 일반화하지 않습니다. 완전한 16-state MLSD와의 동등성이나 별도 후속 Rank-2 프로젝트의 결과도 이 버전에 적용하지 않습니다.

## 구현과 검증의 연결

필터 파이프라인을 바꾸면 출력 값뿐 아니라 출력 시점도 달라집니다. 공개한 FIR 테스트벤치는 기준 회로와 비교 회로 사이의 지연을 맞춘 후 32개 lane의 출력을 비교합니다. 이 방식으로 병렬 구조의 고정소수점 연산과 데이터 정렬을 함께 확인합니다. 검증한 입력 범위는 [검증 문서](validation.md)에 기록했습니다.
