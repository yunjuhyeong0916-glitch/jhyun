# FPGA 구현·JTAG 다운로드와 보드 초기 동작

[프로젝트 요약](../README.md) · [MLSD·RTL 구조](architecture.md) · [검증 근거](validation.md) · [산출물 확인 기록](../reports/fpga_artifact_inventory_20261007.json)

이 문서는 ZCU208에서 PAM4 송수신 DSP를 구동할 때 필요한 빌드 입력, JTAG 다운로드와 초기 동작 확인을 설명합니다. MLSD의 메트릭·경로 복원 구조는 [RTL 문서](architecture.md)에서 다룹니다.

**확인 기준: 2026-10-07.** 원 프로젝트의 설정과 산출물을 읽고 공개 소스 29개의 원본 해시를 대조했습니다. 아래 절차는 문서화한 실행 안내이며, 이번 작업에서 보드를 연결하거나 다운로드·측정을 다시 수행하지 않았습니다. 공개 저장소에는 전체 Vivado 프로젝트와 실행 바이너리가 포함되어 있지 않습니다.

## 1. RTL을 RFSoC 시스템에 연결하는 과정

MLSD 입력을 병렬로 처리하려면 샘플의 순서뿐 아니라 클록을 건너는 데이터와 유효 신호도 맞춰야 합니다. 원 BD에는 RF Data Converter, Zynq PS, FIFO, 리셋 제어, AXI GPIO와 AXI BRAM Controller가 들어 있습니다. 공개 RTL에서는 데이터 연결과 런타임 설정을 확인할 수 있습니다.

| 연결 과제 | 구현에서 볼 부분 | 공개 근거 |
|---|---|---|
| ADC 스트림을 RX 데이터 경로로 전달 | FIFO 연결, RX 도메인의 데이터 유효 신호 | [ADC→FIFO 연결](../rtl/axis_8x16_sink_to_fifo_gen.v), [RX shim](../rtl/rx_bd_shim_raw1024_to_bitplanes_rxdsp8b.v) |
| 보드에서 검출 경로·필터 설정 변경 | GPIO 제어 필드와 RX 경로 선택 | [제어 필드](../rtl/gpio_ctrl_unpack_sync.v), [RX 통합](../rtl/rx_bd_shim_raw1024_to_bitplanes_mmrs_mlsd_fitfirst.v) |
| 계수 쓰기와 실제 적용 시점 구분 | BRAM shadow→active bank 갱신, commit sequence | [RX 계수 로더](../rtl/pam4_rx_coeff_bram_loader.sv) |
| 초기 구동 후 데이터 관찰 | decision/debug valid, PRBS 검사 입력과 카운터 | [RX shim](../rtl/rx_bd_shim_raw1024_to_bitplanes_rxdsp8b.v), [PRBS 검사기](../rtl/RX_PRBSCHK_MULTI_TOP_32LANE_BER_AUTO.sv) |

이 표는 소스에서 확인되는 연결 역할을 설명합니다. 해당 코드의 존재만으로 전체 CDC나 보드 동작 검증이 완료되었다고 판단하지 않습니다.

## 2. 빌드 환경과 준비할 파일

| 항목 | 원 프로젝트에서 확인한 설정 |
|---|---|
| 도구 | Vivado 2022.2 |
| 보드·FPGA | ZCU208 · `xczu48dr-fsvg1517-2-e` |
| Board part | `xilinx.com:zcu208:part0:2.0` |
| Top | `design_1_wrapper` |
| RFDC 샘플링 설정 | `ADC2_Sampling_Rate = 4`, `DAC0_Sampling_Rate = 4` GS/s |
| 기존 보고서의 클록 | `RFADC2_CLK` 125 MHz, `RFDAC0_CLK` 500 MHz |

설정은 XPR·BD와 [기존 구현 보고서](../reports/design_1_wrapper_timing_summary_postroute_physopted_excerpt.txt) 기준입니다. 샘플링 설정과 보고서의 클록은 실제 보드에서 확인한 동작 속도와 구분합니다.

원 프로젝트를 빌드하려면 전체 RTL 의존성, `design_1.bd`, `top.xdc`, IP 설정·초기화 파일과 해당 버전의 보드 정의가 필요합니다. 일반적인 진행 순서는 다음과 같습니다.

1. Vivado에서 프로젝트를 열고 누락된 소스, top, part와 IP 상태를 확인합니다.
2. BD를 Validate하고 IP output products와 top wrapper를 준비합니다.
3. 합성 후 배치배선을 실행하고 timing·route·DRC·methodology 보고서를 검토합니다.
4. 비트스트림을 생성하고 같은 구현의 ILA probes 파일을 함께 보관합니다.
5. PS 제어 소프트웨어를 사용하는 경우 해당 하드웨어의 XSA와 소프트웨어 빌드도 연결합니다.

현재 공개 폴더는 선별한 소스와 보고서 묶음입니다. FIR [재현 명령](reproduce.md)은 필터 시뮬레이션만 실행하므로 위 전체 보드 빌드와 구분합니다.

## 3. JTAG 실행에 필요한 산출물

2026-10-07 로컬 원 프로젝트에서 다음 파일을 확인하고 SHA-256을 기록했습니다. 목록은 [JSON 확인 기록](../reports/fpga_artifact_inventory_20261007.json)에서 볼 수 있습니다. 바이너리와 전체 프로젝트 파일 자체는 배포하지 않습니다.

| 파일 | 용도 | 현재 공개 상태 |
|---|---|---|
| 프로젝트 `.xpr`, `design_1.bd`, `top.xdc` | 빌드 설정, 시스템 연결과 제약 | 로컬 존재·해시 기록 |
| `design_1_wrapper.bit` | JTAG를 통한 PL 회로 프로그래밍 | 로컬 존재·해시 기록 |
| `design_1_wrapper.ltx` | ILA·VIO의 probe 정보 | 로컬 존재·해시 기록 |
| `design_1_wrapper.xsa` | PS 소프트웨어에서 사용할 하드웨어 정보 | 로컬 존재·해시 기록 |
| 보드 클록·PS·RFDC 초기화 소프트웨어와 설정 | 필요한 클록과 converter·제어 상태 준비 | 이 공개본에 실행 가능한 절차·바이너리 미포함 |

파일의 존재와 해시는 산출물을 식별하기 위한 기록입니다. 과거 비트스트림을 만든 당시의 전체 입력 소스와 공개 스냅샷이 같다는 증거는 별도로 필요합니다. `.bit`와 `.ltx`도 같은 구현에서 생성된 조합인지 확인한 뒤 사용합니다.

## 4. Hardware Manager에서 JTAG 다운로드

아래는 [AMD UG908 2022.2의 디바이스 프로그래밍 절차](https://docs.amd.com/r/2022.2-English/ug908-vivado-programming-debugging/Programming-the-Hardware-Device)를 적용하는 순서입니다. 보드 전원·USB JTAG 연결·부트 모드 스위치 위치는 [ZCU208 보드 가이드 UG1410](https://docs.amd.com/v/u/en-US/ug1410-zcu208-eval-bd)에 따라 확인합니다.

1. 보드를 준비하고 USB JTAG를 연결합니다. 필요한 보드 클록·PS 초기화는 실험 환경의 절차로 준비합니다.
2. Vivado의 **Open Hardware Manager → Open Target**에서 연결합니다. 여러 보드가 있으면 대상 케이블·보드를 직접 선택합니다.
3. JTAG chain에서 **ZU48DR FPGA 디바이스**를 선택합니다. ARM DAP 등 다른 chain 항목과 구분합니다.
4. **Program Device**에서 해당 구현의 `.bit`와 `.ltx`를 지정하고 다운로드합니다.
5. 완료 메시지와 Hardware Device Properties의 DONE 상태를 확인합니다. ILA가 포함된 설계라면 Refresh Device 후 디버그 코어가 인식되는지도 확인합니다.
6. 아래 초기 동작 확인으로 넘어갑니다. PL 다운로드 완료와 RFDC·DSP 데이터 경로의 실행 성공은 각각 확인합니다.

GUI에서 올바른 target을 연결한 뒤 사용할 수 있는 Tcl 예시입니다. 경로와 디바이스 이름을 실제 값으로 바꿔야 합니다.

```tcl
# Hardware Manager에서 target 연결을 마친 뒤 실행합니다.
get_hw_devices
set device_name {REPLACE_WITH_ZU48DR_DEVICE_NAME}
set device [get_hw_devices -quiet $device_name]
if {[llength $device] != 1} {
    error "Select exactly one ZU48DR device from get_hw_devices."
}
set bit_file {D:/fpga_artifacts/design_1_wrapper.bit}
set ltx_file {D:/fpga_artifacts/design_1_wrapper.ltx}
if {![file isfile $bit_file] || ![file isfile $ltx_file]} {
    error "Provide the bitstream and probes files for this implementation."
}
current_hw_device $device
set_property PROGRAM.FILE $bit_file $device
set_property PROBES.FILE $ltx_file $device
program_hw_devices $device
refresh_hw_device $device
```

이 예시는 PL 프로그래밍용입니다. 원 프로젝트의 PS·클록 제어·RFDC 초기화 소프트웨어를 추가로 확보해야 시스템 실행 절차를 완성할 수 있습니다.

## 5. 다운로드 이후 초기 동작 확인

이 순서는 문제를 좁히기 위한 확인 항목입니다. 정확한 레지스터 주소, 클록 설정 값과 초기화 순서는 사용하는 BD·소프트웨어 버전에서 확인해야 합니다.

| 단계 | 확인할 내용 | 확인 방법 |
|---|---|---|
| 클록·리셋 | 필요한 클록 공급과 lock, 각 도메인의 리셋 해제 | 보드 클록 설정, PS/RFDC 상태, 사용 가능한 ILA probe |
| ADC 데이터 입력 | 데이터가 들어올 때 RX 유효 신호가 동작하는지 | RX shim의 `rx_data_valid`와 데이터 변화 관찰 |
| 제어 설정 | 모드·PRBS·필터·MLSD 경로 선택이 의도한 값인지 | GPIO 제어 필드와 RX override 설정 확인 |
| 계수 반영 | 쓰기가 끝난 계수가 active bank에 적용되었는지 | `COMMIT_SEQ`, `cfg_active_commit_seq`, 적용 대기·busy 상태 확인 |
| 검출 출력 | 데이터와 출력 유효 신호가 함께 진행하는지 | `decision_valid`, `dbg_mlsd_valid` 등 해당 구현에 연결된 신호 관찰 |
| PRBS 검사 | 기준 패턴·출력 정렬·검사 시작 조건과 카운터 동작 | [검사기 RTL](../rtl/RX_PRBSCHK_MULTI_TOP_32LANE_BER_AUTO.sv)의 설정과 관측 범위 확인 |

계수 로더는 BRAM에 쓴 값을 shadow bank로 읽은 뒤, commit sequence 변경과 `cfg_apply_ready` 조건에 따라 active bank를 갱신합니다. 따라서 메모리 쓰기 완료와 실제 계수 적용을 따로 확인해야 합니다. 주소 표의 `0x00C` 등은 BRAM 내부 offset이며, CPU의 AXI base address는 해당 BD의 address map에서 확인합니다. [계수 로더의 주소·commit 정의](../rtl/pam4_rx_coeff_bram_loader.sv)

ILA probe에 내부 신호가 포함되어 있는지는 `.ltx`와 실제 구현으로 확인합니다. 코드의 신호 이름만으로 모든 신호를 관찰할 수 있다고 가정하지 않습니다.

## 6. 초기 구동에서 문제가 생겼을 때

| 증상 | 먼저 확인할 항목 |
|---|---|
| JTAG에서 보드가 보이지 않음 | 전원, USB JTAG 연결·드라이버, hw_server와 선택한 target |
| 다운로드 후 ILA가 보이지 않음 | `.bit`와 `.ltx` 조합, debug hub·ILA 클록 공급과 리셋 상태 |
| ADC 데이터 또는 RX valid가 멈춤 | 보드 클록·RFDC 초기화, FIFO와 RX 도메인 리셋·유효 신호 |
| 계수를 써도 출력이 변하지 않음 | override 설정, commit sequence 갱신, active commit와 적용 가능 조건 |
| PRBS 오류가 계속 증가함 | 송수신 패턴·모드, 비트 매핑·지연 정렬, RX 경로 선택, 실제 채널 조건 |

디버그 코어 연결은 클록 조건의 영향을 받습니다. AMD는 UltraScale+ 디버그 코어 사용 시 JTAG 클록이 debug hub 클록보다 최소 2.5배 느려야 한다고 설명합니다. 실제 주파수는 구현의 debug hub 클록을 확인한 뒤 정합니다. [UG908의 디버그 클록 지침](https://docs.amd.com/r/2022.2-English/ug908-vivado-programming-debugging/Debug-Cores-Clocking-Guidelines)

## 7. 실행 결과를 남기는 기준

보드 실행을 수행하면 소스 commit, Vivado·소프트웨어 버전, `.bit`·`.ltx` 해시, 클록·RFDC·제어 설정, 다운로드 로그와 ILA 캡처를 함께 남깁니다. PRBS 결과에는 검사한 비트 범위, 총 검사 비트 수, 오류 수와 관측 시간을 기록합니다. 이 기록이 있어야 특정 구현과 실행 조건에 결과를 연결할 수 있습니다.

현재의 [기존 FPGA 구현 기록](validation.md), [FIR 테스트 결과](../reports/fir_validation_20260909.json), 위 JTAG 절차의 실제 실행 여부는 서로 다른 항목입니다. 최신 상태는 [검증 상태 안내](../../../docs/validation-status.md)에 표시합니다.
