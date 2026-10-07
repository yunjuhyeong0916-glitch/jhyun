# 윤주형 | 고속 인터페이스 RTL·FPGA 포트폴리오

**고속 신호를 처리하고 데이터를 복원하는 디지털 회로를 설계합니다.**

PAM4 송수신 DSP와 MLSD 검출기의 RTL 구현, 병렬 처리 구조, 시뮬레이션 및 FPGA 구현 자료를 모았습니다.

[대표 프로젝트](projects/zcu208-pam4-dsp-portfolio/) · [MLSD·RTL 구조](projects/zcu208-pam4-dsp-portfolio/docs/architecture.md) · [FPGA 구현·JTAG 구동](projects/zcu208-pam4-dsp-portfolio/docs/fpga-bringup.md) · [검증 결과](projects/zcu208-pam4-dsp-portfolio/docs/validation.md) · [English](README.en.md)

## 처음 방문하셨다면

| 보고 싶은 내용 | 시작할 자료 |
|---|---|
| 어떤 프로젝트인지 빠르게 이해하기 | [PAM4 송수신 DSP 프로젝트 요약](projects/zcu208-pam4-dsp-portfolio/README.md) |
| 설계 구조와 구현 코드 확인하기 | [구조 설명과 대표 RTL 안내](projects/zcu208-pam4-dsp-portfolio/docs/architecture.md) |
| FPGA 구현과 보드 실행 과정 확인하기 | [Vivado 빌드·JTAG 다운로드·초기 동작 확인](projects/zcu208-pam4-dsp-portfolio/docs/fpga-bringup.md) |
| 실제 확인된 검증 결과 살펴보기 | [테스트 결과와 FPGA 구현 근거](projects/zcu208-pam4-dsp-portfolio/docs/validation.md) |
| 직접 시뮬레이션 실행하기 | [FIR 테스트 3종 재현 방법](projects/zcu208-pam4-dsp-portfolio/docs/reproduce.md) |

## 대표 프로젝트 — ZCU208 PAM4 송수신 DSP

고속 신호의 왜곡을 보상하고 수신 데이터를 복원하기 위해 **32-lane 병렬 DSP, 송수신 FIR 필터, PAM4 reduced-state MLSD 검출기**를 구성한 FPGA 프로젝트입니다. 4 GS/s로 설정한 RFSoC ADC·DAC와 연결되는 데이터 경로, 런타임 계수 제어, PRBS 검사 및 디버깅 구조를 다룹니다.

| 설계 | 검증 | 구현 환경 |
|---|---|---|
| 병렬 RTL · 고정소수점 연산 · 파이프라인 | 기준 회로와 출력 비교 · 구현 보고서 분석 | Verilog/SystemVerilog · Vivado/XSim · ZCU208 |

- **FIR 테스트 3종 PASS** — 공개한 RTL과 기존 TB를 2026-09-09 다시 실행했습니다.
- **FPGA 구현 기록** — 2026-06-29의 기존 post-route physopt 보고서에서 WNS +0.083 ns, TNS 0.000 ns를 확인했습니다. 적용된 제약에 대한 과거 구현 결과이며, 현재 소스를 새로 배치배선한 결과는 아닙니다.
- **공개 자료** — RTL 26개, FIR 테스트벤치 3개, 구조 설명, 재현 스크립트, 구현 보고서와 출처 기록을 제공합니다.

**[프로젝트 자세히 보기 →](projects/zcu208-pam4-dsp-portfolio/)**

## MLSD·RTL 설계와 FPGA 보드 구동

같은 프로젝트를 두 관점에서 살펴볼 수 있습니다.

| 관점 | 다루는 내용 | 시작할 자료 |
|---|---|---|
| MLSD·RTL 설계 | 메트릭 계산, 변환 결합, 경로 복원과 병렬 데이터 처리 | [설계 구조와 대표 RTL](projects/zcu208-pam4-dsp-portfolio/docs/architecture.md) |
| FPGA 구현·보드 구동 | RFSoC 통합, 합성·배치배선, 비트스트림, JTAG 다운로드와 초기 동작 확인 | [FPGA 구현·JTAG 구동](projects/zcu208-pam4-dsp-portfolio/docs/fpga-bringup.md) |

보드 구동 문서는 원 프로젝트의 설정·산출물 확인과 실행 절차를 정리합니다. 자료 확인 범위와 하드웨어 실행 여부는 [검증 상태](docs/validation-status.md)에 표시합니다.

## 저장소 구성

| 폴더 | 내용 | 자료의 성격 |
|---|---|---|
| [projects/](projects/) | ZCU208 PAM4 송수신 DSP | 대표 포트폴리오와 검증 근거 |
| [experiments/](experiments/) | MLSD 구조 비교, branch-centric 변형 | 별도 연구·시뮬레이션 실험 |
| [reference/](reference/) | full-state / reduced-state / hybrid / unified 코어 | 구조별 참고 RTL |
| [archive/](archive/) | 이전 Vivado 보드 프로젝트 | 과거 구현 스냅샷 |
| [docs/](docs/) | 읽는 순서, 경로 안내, 용어와 검증 상태 | 저장소 사용 안내 |

각 폴더는 서로 다른 목적과 버전의 자료입니다. 대표 프로젝트에서 확인한 PASS나 타이밍 결과를 다른 실험 폴더의 검증 결과로 적용하지 않습니다. [검증 상태 한눈에 보기](docs/validation-status.md)

## 기술 용어가 낯설다면

**PAM4**는 네 단계의 신호 레벨로 데이터를 표현하는 방식이고, **FIR**은 신호를 보정하는 디지털 필터, **MLSD**는 연속된 신호 정보를 이용해 데이터를 판별하는 검출 방식입니다. [짧은 용어 설명](docs/glossary.md)
