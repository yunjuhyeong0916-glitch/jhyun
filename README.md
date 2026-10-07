# 윤주형 | 고속 인터페이스 HW 설계·검증 포트폴리오

**고속 인터페이스의 회로·모델·RTL 구현과 보드 측정 검증을 연결합니다.**

DSP 기반 송수신기 연구의 MLSD·RTL·FPGA 자료와 LPDDR·USB PAM-3 프로젝트의 회로 설계, 모델링, PCB·채널 분석 및 계측 경험을 모았습니다.

[MLSD·RTL 구조](projects/zcu208-pam4-dsp-portfolio/docs/architecture.md) · [FPGA 구현·JTAG 구동](projects/zcu208-pam4-dsp-portfolio/docs/fpga-bringup.md) · [LPDDR·USB 연구](projects/high-speed-interface-research/) · [측정 장비·활용](projects/high-speed-interface-research/docs/measurement-equipment.md) · [성과 논문](docs/publications.md) · [English](README.en.md)

## 처음 방문하셨다면

| 보고 싶은 내용 | 시작할 자료 |
|---|---|
| 어떤 프로젝트인지 빠르게 이해하기 | [PAM4 송수신 DSP 프로젝트 요약](projects/zcu208-pam4-dsp-portfolio/README.md) |
| 설계 구조와 구현 코드 확인하기 | [구조 설명과 대표 RTL 안내](projects/zcu208-pam4-dsp-portfolio/docs/architecture.md) |
| FPGA 구현과 보드 실행 과정 확인하기 | [Vivado 빌드·JTAG 다운로드·초기 동작 확인](projects/zcu208-pam4-dsp-portfolio/docs/fpga-bringup.md) |
| LPDDR·USB 프로젝트와 담당 역할 확인하기 | [회로·모델링·실리콘 평가 파트](projects/high-speed-interface-research/) |
| 사용한 측정 장비와 활용 방법 확인하기 | [장비별 역할·측정 조건·자동화 사례](projects/high-speed-interface-research/docs/measurement-equipment.md) |
| 연구 성과의 논문과 공식 정보 확인하기 | [프로젝트별 성과 논문 6편](docs/publications.md) |
| 실제 확인된 검증 결과 살펴보기 | [테스트 결과와 FPGA 구현 근거](projects/zcu208-pam4-dsp-portfolio/docs/validation.md) |
| 직접 시뮬레이션 실행하기 | [FIR 테스트 3종 재현 방법](projects/zcu208-pam4-dsp-portfolio/docs/reproduce.md) |

## DSP 기반 송수신기 연구 — ZCU208 PAM4

고속 신호의 왜곡을 보상하고 수신 데이터를 복원하기 위해 **32-lane 병렬 DSP, 송수신 FIR 필터, PAM4 reduced-state MLSD 검출기**를 구성한 FPGA 프로젝트입니다. 4 GS/s로 설정한 RFSoC ADC·DAC와 연결되는 데이터 경로, 런타임 계수 제어, PRBS 검사 및 디버깅 구조를 다룹니다.

| 설계 | 검증 | 구현 환경 |
|---|---|---|
| 병렬 RTL · 고정소수점 연산 · 파이프라인 | 기준 회로와 출력 비교 · 구현 보고서 분석 | Verilog/SystemVerilog · Vivado/XSim · ZCU208 |

- **FIR 테스트 3종 PASS** — 공개한 RTL과 기존 TB를 2026-09-09 다시 실행했습니다.
- **FPGA 구현 기록** — 2026-06-29의 기존 post-route physopt 보고서에서 WNS +0.083 ns, TNS 0.000 ns를 확인했습니다. 적용된 제약에 대한 과거 구현 결과이며, 현재 소스를 새로 배치배선한 결과는 아닙니다.
- **공개 자료** — RTL 26개, FIR 테스트벤치 3개, 구조 설명, 재현 스크립트, 구현 보고서와 출처 기록을 제공합니다.

**[프로젝트 자세히 보기 →](projects/zcu208-pam4-dsp-portfolio/)**

관련 연구 논문: [A-SSCC 2026 — FPGA 검증 PAM4 송수신기·DS-SBM RS-MLSD](https://epapers2.org/asscc2026/ESR/paper_details.php?paper_id=1351) **(채택·발표 예정)**. 논문 버전과 공개 RTL 스냅샷의 관계는 [구조 문서](projects/zcu208-pam4-dsp-portfolio/docs/architecture.md#관련-논문과-공개-소스의-관계)에 설명합니다.

## MLSD·RTL 설계와 FPGA 보드 구동

같은 프로젝트를 두 관점에서 살펴볼 수 있습니다.

| 관점 | 다루는 내용 | 시작할 자료 |
|---|---|---|
| MLSD·RTL 설계 | 메트릭 계산, 변환 결합, 경로 복원과 병렬 데이터 처리 | [설계 구조와 대표 RTL](projects/zcu208-pam4-dsp-portfolio/docs/architecture.md) |
| FPGA 구현·보드 구동 | RFSoC 통합, 합성·배치배선, 비트스트림, JTAG 다운로드와 초기 동작 확인 | [FPGA 구현·JTAG 구동](projects/zcu208-pam4-dsp-portfolio/docs/fpga-bringup.md) |

보드 구동 문서는 원 프로젝트의 설정·산출물 확인과 실행 절차를 정리합니다. 자료 확인 범위와 하드웨어 실행 여부는 [검증 상태](docs/validation-status.md)에 표시합니다.

## LPDDR·USB — 회로·모델링·실리콘 평가

회로와 모델에서 확인한 동작이 실제 보드에서도 유지되는지 판단하려면 전송 채널과 측정 조건을 함께 살펴야 합니다. 이 파트는 LPDDR·USB 연구의 설계 판단과 담당 역할을 설명하고, PCB·HFSS 분석과 장비를 활용한 검증 과정으로 연결합니다.

| 연구 | 개인 담당 범위와 검증 | 자료 |
|---|---|---|
| LPDDR 메모리 인터페이스 | TX 직접 설계·측정 전 Schematic/Post-Layout 검증, 측정 PCB·채널 분석; Combo PHY 성능은 공동 실측 | [LPDDR 설계·검증](projects/high-speed-interface-research/docs/lpddr.md) |
| USB4 PAM-3 인터페이스 | TX 논리 경로·RX CTLE 모델링 및 통합 검증, 인코더·스크램블러 RTL, 차동 PAM-3 측정; 제작 TX 성능은 공동 결과 | [USB 모델링·실리콘 평가](projects/high-speed-interface-research/docs/usb4-pam3.md) |

**공통 계측:** Keysight 86100D·86118A, M8195A AWG, E3631A 전원공급기, Anritsu MP1800A BERT를 두 프로젝트에서 활용했습니다. 채널보드와 실시간 오실로스코프 사용, 장비 설정·결과 수집 자동화는 [측정 장비와 활용 사례](projects/high-speed-interface-research/docs/measurement-equipment.md)에 정리했습니다.

## 연구 성과 논문

| 연구 | 논문 바로가기 |
|---|---|
| DSP 기반 송수신기·MLSD | [A-SSCC 2026: RFSoC 검증 PAM4·RS-MLSD](https://epapers2.org/asscc2026/ESR/paper_details.php?paper_id=1351) |
| LPDDR | [ICEIC 2025: 저전압 NRZ TX 시뮬레이션](https://doi.org/10.1109/ICEIC64972.2025.10879746) · [A-SSCC 2026: 14-Gb/s/pin Combo PHY 실측](https://epapers2.org/asscc2026/ESR/paper_details.php?paper_id=1141) |
| USB PAM-3 | [SMACD 2025: TX 모델](https://doi.org/10.1109/SMACD65553.2025.11092283) · [SMACD 2025: RX 모델](https://doi.org/10.1109/SMACD65553.2025.11092233) · [IEEE TVLSI 2026: 제작 TX 실측](https://doi.org/10.1109/TVLSI.2026.3701343) |

전체 제목·학술지/학회·검증 범위는 [성과 논문 목록](docs/publications.md)에 정리했습니다. A-SSCC 2026 두 편은 2026-10-07 공식 정보 기준 채택·발표 예정입니다.

## 저장소 구성

| 폴더 | 내용 | 자료의 성격 |
|---|---|---|
| [projects/](projects/) | DSP 기반 송수신기 연구, LPDDR·USB 회로·계측 연구 | 프로젝트별 담당 역할과 검증 근거 |
| [experiments/](experiments/) | MLSD 구조 비교, branch-centric 변형 | 별도 연구·시뮬레이션 실험 |
| [reference/](reference/) | full-state / reduced-state / hybrid / unified 코어 | 구조별 참고 RTL |
| [archive/](archive/) | 이전 Vivado 보드 프로젝트 | 과거 구현 스냅샷 |
| [docs/](docs/) | 읽는 순서, 경로 안내, 용어와 검증 상태 | 저장소 사용 안내 |

각 폴더는 서로 다른 목적과 버전의 자료입니다. FIR PASS·FPGA 타이밍, 회로·모델 시뮬레이션, 공동 실리콘 측정은 해당 프로젝트와 조건에 연결해 읽습니다. [검증 상태 한눈에 보기](docs/validation-status.md)

## 기술 용어가 낯설다면

**PAM4**는 네 단계의 신호 레벨로 데이터를 표현하는 방식이고, **FIR**은 신호를 보정하는 디지털 필터, **MLSD**는 연속된 신호 정보를 이용해 데이터를 판별하는 검출 방식입니다. [짧은 용어 설명](docs/glossary.md)
