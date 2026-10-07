# Vitis: PS 제어·RFDC 초기화와 FPGA 실행

[프로젝트 요약](../README.md) · [Vivado 구현·JTAG 다운로드](fpga-bringup.md) · [RTL 구조](architecture.md) · [Vitis 구성 확인 기록](../reports/vitis_artifact_inventory_20261007.json)

**Vitis는 PS에서 실행할 제어 프로그램을 빌드하고, 보드 초기화와 PL의 런타임 설정을 연결하는 역할을 합니다.** Vivado에서 PL 회로를 다운로드한 뒤에도 보드 클록, RFDC와 DSP 제어 상태가 준비되어야 송수신 경로를 사용할 수 있습니다. 이 프로젝트의 PS 앱은 XSA 기반 플랫폼과 Cortex-A53의 Standalone 환경에서 클록·RFDC 초기화와 DSP 설정을 수행하도록 구성됐습니다.

**확인 기준: 2026-10-07.** 로컬 `DSP_TRX_FINAL_PAM4` Vitis 프로젝트의 설정·C 소스·실행 스크립트·산출물을 읽어 정리했습니다. 이번에는 앱 빌드나 보드 실행을 다시 수행하지 않았습니다. 공개 범위는 구성·절차와 파일 해시이며, 전체 Vitis workspace·드라이버 소스·ELF는 포함하지 않습니다.

## 1. Vivado 하드웨어와 Vitis 앱의 연결

Vivado의 XSA가 PS·PL 하드웨어 정보를 Vitis에 전달하고, Vitis 플랫폼의 BSP가 그 하드웨어에 맞는 드라이버와 주소 정의를 제공합니다. 따라서 하드웨어를 바꾸면 플랫폼과 앱도 함께 갱신해야 합니다. [AMD의 Vitis 2022.2 플랫폼·Standalone 앱 생성 절차](https://xilinx.github.io/Embedded-Design-Tutorials/docs/2022.2/build/html/docs/Introduction/ZynqMPSoC-EDT/4-build-sw-for-ps-subsystems.html)

| 구성 | 로컬에서 확인한 값·역할 |
|---|---|
| 도구 기준 | Vitis 2022.2; 기존 XSCT 실행 스크립트의 도구 경로에서 확인 |
| 하드웨어 플랫폼 | `design_1_wrapper`, Vivado에서 내보낸 `.xsa` 사용 |
| 앱·실행 CPU | `DSP_based_TRX` · `psu_cortexa53_0` · 64-bit |
| 실행 환경 | `standalone_domain` · Standalone |
| 부트 구성 | A53용 `zynqmp_fsbl`, PMU용 `zynqmp_pmufw` 도메인 |
| 앱 소스·바이너리 | `main.c`·`main.h` 등 C 소스 → `DSP_based_TRX.elf` |
| 하드웨어 주소 | BSP의 `xparameters.h`와 앱의 프로젝트 전용 정의를 대조 |

이 구성은 PS 제어 소프트웨어와 DSP 하드웨어의 연결을 보여줍니다. RFDC·보드 클록 드라이버는 기존 AMD/Xilinx 구성요소를 활용한 부분으로, 해당 드라이버 전체의 직접 작성 기여와 구분합니다.

## 2. XSA에서 앱 빌드·JTAG 실행까지

아래는 **Vitis 2022.2 GUI 기준의 재실행 안내**입니다. AMD 튜토리얼의 Zynq UltraScale+ 소프트웨어 절차를 적용하되, 보드 연결·부트 스위치·클록 조건은 [ZCU208 UG1410](https://docs.amd.com/v/u/en-US/ug1410-zcu208-eval-bd)을 기준으로 확인합니다.

1. **하드웨어 준비:** Vivado에서 사용할 구현의 XSA를 내보내고, 해당 `.bit`·`.ltx`와 버전을 함께 기록합니다. XSA의 bitstream 포함 여부도 확인합니다.
2. **플랫폼 생성·갱신:** Vitis의 **File → New → Platform Project**에서 XSA를 선택합니다. 이 프로젝트의 설정은 `psu_cortexa53_0`, Standalone, 64-bit입니다. **Generate Boot Components**와 A53 FSBL target을 확인하고, 기존 플랫폼을 사용할 때도 새 XSA에 맞춰 BSP를 다시 생성합니다.
3. **BSP 점검:** RFDC 드라이버·libmetal, AXI 주소 정의와 UART stdout 설정을 확인합니다. 앱의 고정 주소·클록 설정과 linker script도 해당 하드웨어에 맞춰 검토합니다.
4. **앱 빌드:** **Application Project**를 같은 플랫폼·도메인에 연결하고 필요한 C 소스·헤더·링커 설정으로 빌드합니다. 앱 ELF와 사용할 FSBL·PMUFW를 식별합니다.
5. **연결 준비:** 보드의 JTAG와 UART를 연결하고, BSP에 맞는 COM 포트·통신 속도로 터미널을 엽니다.
6. **실행 설정 확인:** **Run/Debug Configurations → Xilinx Application Debugger**에서 대상 CPU, PL bitstream, PS 초기화 방법과 앱 ELF를 확인합니다. GUI와 XSCT 실행 중 사용할 경로를 정해 초기화·다운로드 순서를 확인합니다.
7. **앱 실행·관찰:** 디버깅 시 `main`의 breakpoint 이후 실행을 계속하고, UART 초기화 로그와 RFDC·DSP 상태를 확인합니다.

로컬 XSCT 스크립트에서 확인한 실행 순서는 **시스템 리셋 → PL `.bit` 다운로드 → A53에서 FSBL 실행 → `XFsbl_Exit`에서 정지 → 앱 ELF 다운로드·실행**입니다. 스크립트는 PMUFW를 명시적으로 다운로드하지 않으므로, PMUFW 도메인의 존재와 실제 실행 시 로딩 여부를 같은 사실로 취급하지 않습니다. 사용할 부트·디버그 구성에 맞춰 확인해야 합니다.

## 3. 앱이 준비하는 클록·RFDC·DSP 상태

검토한 `main.c`는 먼저 GPIO와 RX 계수 BRAM의 기본 상태를 준비한 뒤, CLK104와 RFDC를 초기화하는 경로를 갖습니다. 중간에 멈춰 원인을 좁히는 진단 분기도 있어, 빌드 시 선택한 옵션에 따라 실행 경로가 달라집니다.

| 단계 | 소스에서 확인한 처리 | 실행할 때 확인할 내용 |
|---|---|---|
| 제어·계수 준비 | `InitSwControlGpio`, `InitFfeCoeffGpio`, `InitRxCoeffBram`, RX threshold 설정 | 송수신 모드·PRBS·필터·MLSD 선택과 계수 기본값 |
| 보드 클록 준비 | `XRFClk_Init`, CLK104 reset, LMK·LMX 설정 | XSA/RFDC와 일치하는 클록 계획, 실제 공급·lock 상태 |
| RFDC 드라이버 준비 | `metal_init`, `XRFdc_LookupConfig`, `XRFdc_CfgInitialize` | 장치 설정·주소와 API 반환값 |
| Converter startup | 프로젝트의 `rfdcStartup`, tile 상태 조회·startup 호출 | 사용하는 ADC/DAC tile의 startup 상태와 데이터 유효 신호 |
| 관측 데이터 확보 | RX debug capture 상태 확인, BRAM 데이터의 UART CSV 출력 | capture 완료·timeout, 선택한 경로와 데이터 형식 |

RFDC API의 기본 사용은 [AMD/Xilinx embeddedsw 2022.2 예제](https://github.com/Xilinx/embeddedsw/blob/xilinx_v2022.2/XilinxProcessorIPLib/drivers/rfdc/examples/xrfdc_selftest_example.c)에서도 확인할 수 있습니다. 그 self-test는 외부 클록에 의존하지 않는 설정 검사이므로, 프로젝트의 CLK104 설정·converter startup·실제 데이터 관측을 대신하는 시험으로 사용하지 않습니다.

정상 구동을 점검할 때는 초기화 단계별 반환값과 실제 tile·데이터 상태를 함께 봅니다. 앱의 완료 문구만으로 ADC/DAC 경로 전체의 동작을 판정하지 않습니다. 소스의 진단 정지 옵션과 시작 시 sweep·capture 옵션도 함께 기록합니다.

## 4. 계수를 쓴 시점과 DSP에 적용된 시점

PS는 AXI GPIO로 모드·필터 제어를 설정하고, AXI BRAM Controller를 통해 RX 계수와 제어값을 씁니다. 검토한 앱에는 메모리에 쓴 값을 다시 읽어 비교하고, 계수 쓰기가 끝난 뒤 commit sequence를 갱신하는 처리가 있습니다.

PL의 [RX 계수 로더](../rtl/pam4_rx_coeff_bram_loader.sv)는 BRAM의 값을 shadow bank에 읽은 뒤, commit 변경과 `cfg_apply_ready` 조건에 따라 active bank를 갱신합니다. 따라서 **메모리에 쓴 값 확인 → commit 갱신 → 실제 적용 상태 확인**을 구분해야 합니다. `COMMIT_SEQ`의 `0x00C`는 BRAM 내부 offset이며, CPU의 전체 주소는 해당 하드웨어의 AXI base address와 결합합니다.

실제 적용 여부는 구현에 연결된 `cfg_active_commit_seq` 등의 관측 경로로 확인합니다. PS의 메모리 비교만으로 PL active bank의 적용까지 확인했다고 기록하지 않습니다. ILA 관측 시에도 해당 구현의 `.ltx`에 필요한 probe가 있는지 확인합니다.

## 5. 결과 수집과 PRBS·BER의 연결

현재 앱 소스에서 직접 확인한 수집 기능은 **RX debug capture를 BRAM에서 읽어 UART CSV로 출력하는 경로**입니다. 이 캡처를 사용하려면 해당 BRAM capture 하드웨어와 상태·데이터 주소가 구현에 포함되어 있어야 합니다.

PRBS 오류 검출·집계는 [PL PRBS 검사기](../rtl/RX_PRBSCHK_MULTI_TOP_32LANE_BER_AUTO.sv)의 역할입니다. 검사기는 `lock`, `bit_cnt_total`, `err_cnt_total` 등을 출력하지만, 이번에 검토한 앱에서 이 카운터를 직접 읽는 PS 경로는 확인하지 못했습니다. 보드 BER를 기록하려면 실제 연결된 ILA/VIO 또는 PS 읽기 경로를 먼저 확인하고, 동일 관측 구간의 검사 비트 수·오류 수·lock 상태·패턴·경로 설정을 함께 확보해야 합니다.

Python에서 BER를 계산·비교할 때도 debug 샘플 CSV와 PRBS 카운터를 구분합니다. 계수·경로를 바꾼 뒤에는 적용 완료와 검사 시작 조건을 확인해, 서로 다른 설정 구간의 누적값이 섞이지 않도록 관측 범위를 정합니다. 논문 버전의 시스템 BER는 [검증 근거](validation.md#관련-논문의-시스템-검증)에 따로 연결했습니다.

## 6. 실행 오류를 단계별로 좁히는 방법

| 증상 | 확인할 단계 |
|---|---|
| ELF 다운로드·실행 전에 debugger 오류 | XSA·플랫폼 갱신, target 선택, PS 초기화·launch 스크립트 |
| 앱이 `main`에 도달하지 않음 | FSBL/PS 초기화, DDR·링커 배치, 대상 A53와 앱 ELF |
| UART 로그가 중간에서 멈춤 | `main` breakpoint 이후 재개 여부, 해당 단계 반환값, 진단 정지 옵션 |
| RFDC 초기화 이후 데이터가 없음 | 클록 공급·lock, tile startup, 데이터 경로 클록·리셋·valid |
| 계수는 읽히지만 DSP 출력이 바뀌지 않음 | override·경로 선택, commit 갱신과 PL의 active 적용 상태 |

로컬에는 Vitis의 생성된 `loadhw -regs`에서 `can't read "map": no such variable`이 발생한 기록과, 해당 명령을 거치지 않고 `.bit`·FSBL·앱을 순서대로 로드하는 XSCT 스크립트가 있습니다. **디버거의 하드웨어 정보 로딩 오류와 CLK104/RFDC 실행 중 보드 상태 문제를 나눠 확인한 사례**입니다. 이 우회 스크립트의 존재를 모든 Vitis 버전에 적용되는 해결책이나 현재 보드 실행 성공으로 표시하지 않습니다.

## 7. JTAG 실행과 SD 부팅 이미지

JTAG에서는 PC의 debugger가 파일을 로드하고 실행을 제어합니다. SD에서 전원 인가 후 실행하려면 Bootgen 또는 **Xilinx → Create Boot Image**로 부트 이미지를 구성하는 단계가 추가됩니다. [AMD 2022.2 Boot and Configuration](https://xilinx.github.io/Embedded-Design-Tutorials/docs/2022.2/build/html/docs/Introduction/ZynqMPSoC-EDT/8-boot-and-configuration.html)

Standalone DSP 앱의 부팅 구성을 준비할 때는 동일 하드웨어의 **FSBL·PMUFW·PL bitstream·A53 앱 ELF**와 각 partition의 대상·실행 속성을 검토합니다. 생성된 `BOOT.BIN`을 사용한 전원 재인가 시험에서 앱 로그·클록/RFDC 초기화·DSP 관측까지 확인해야 자동 구동 결과를 남길 수 있습니다.

별도 로컬 `boot/output.bif`에서 확인한 partition은 FSBL 하나뿐입니다. 해당 파일은 DSP 앱과 PL까지 포함하는 부팅 이미지의 근거가 아니며, 이 포트폴리오에서는 SD 자동 구동을 새로 검증한 것으로 표시하지 않습니다.

## 8. 이번에 확인한 파일 조합과 범위

Vitis의 `hw/design_1_wrapper.xsa`는 [기존 Vivado 산출물 목록](../reports/fpga_artifact_inventory_20261007.json)의 XSA와 SHA-256이 같습니다. Vitis의 `hw/design_1_wrapper.bit`도 그 XSA 안의 비트스트림과 바이트가 일치합니다. 다만 기존 목록의 **Vivado `impl_1` 폴더에 따로 저장된 `.bit`와는 해시가 다릅니다.** 같은 파일 이름을 근거로 두 구현의 비트스트림·타이밍 보고서·`.ltx`를 섞어 사용하면 안 됩니다.

플랫폼·앱 설정, 주요 C 소스, XSA·bitstream·FSBL·PMUFW·앱 ELF와 로드 스크립트의 해시는 [Vitis 확인 기록](../reports/vitis_artifact_inventory_20261007.json)에 남겼습니다. 파일 존재·일부 해시 일치는 확인했지만, 현재 C 소스와 기존 ELF의 빌드 일치, 전체 공개 RTL과 XSA의 빌드 일치, 보드 실행·RFDC 초기화·BER는 이번 작업에서 검증하지 않았습니다.
