# 윤주형 | HW 설계·검증

**고속 인터페이스 · DSP · RTL/FPGA**

회로·모델·RTL 구현을 FPGA와 측정 검증으로 연결합니다. DSP 기반 송수신기 연구와 LPDDR·USB PAM-3 프로젝트의 설계 판단, 개인 기여, 검증 자료를 모았습니다.

[DSP·FPGA](#dsp-기반-송수신기-연구) · [LPDDR·USB](#lpddrusb-연구) · [측정·검증](#측정검증) · [논문](#연구-성과-논문) · [English](README.en.md)

## DSP 기반 송수신기 연구

채널 왜곡을 보상하고 수신 데이터를 복원하는 **32-lane PAM4 DSP**를 ZCU208 RFSoC에 연결한 프로젝트입니다.

### MLSD·RTL 설계

연속된 심볼 정보를 활용하는 MLSD를 고정소수점 RTL로 구현하고, 메트릭 계산·행렬 결합·경로 복원의 병렬 구조를 다뤘습니다. 설계 선택의 이유부터 실제 소스와 실행 예제까지 확인할 수 있습니다.

[설계 판단](projects/zcu208-pam4-dsp-portfolio/docs/design-decisions.md) · [구조와 코드](projects/zcu208-pam4-dsp-portfolio/docs/architecture.md) · [최소 실행 예제](projects/zcu208-pam4-dsp-portfolio/examples/mlsd_minimal/)

### FPGA 구현·보드 구동

RFDC 등 기존 IP와 DSP 데이터 경로를 통합했습니다. Vivado 빌드·JTAG 다운로드에서 Vitis의 PS 제어 앱, 클록·RFDC 초기화와 계수 적용까지 보드 구동 과정을 설명합니다.

[Vivado·JTAG](projects/zcu208-pam4-dsp-portfolio/docs/fpga-bringup.md) · [Vitis·PS 제어·초기화](projects/zcu208-pam4-dsp-portfolio/docs/vitis-bringup.md) · [프로젝트 전체 보기](projects/zcu208-pam4-dsp-portfolio/)

## LPDDR·USB 연구

개인 설계·검증 범위와 공동 실리콘 평가 결과를 함께 정리했습니다.

| 연구 | 직접 담당한 설계·검증 | 공동 평가 |
|---|---|---|
| [LPDDR](projects/high-speed-interface-research/docs/lpddr.md) | [TX 회로 설계·검증](projects/high-speed-interface-research/docs/lpddr-tx-circuit-verification.md), [TX Verilog 모델링](projects/high-speed-interface-research/docs/lpddr-tx-modeling.md) | Combo PHY의 TX Eye·RX 마진 |
| [USB PAM-3](projects/high-speed-interface-research/docs/usb4-pam3.md) | [TX 모델링·RTL 검증](projects/high-speed-interface-research/docs/usb-tx-modeling.md), [RX CTLE 모델링](projects/high-speed-interface-research/docs/usb-rx-ctle-modeling.md) | 제작 TX의 차동 신호 측정 |

PCB 설계·제작 사진과 HFSS 해석은 [보드 배선에서 실제 측정 경로까지](projects/high-speed-interface-research/docs/pcb-hfss-verification.md), 계측 경험은 [LPDDR·USB 연구 파트](projects/high-speed-interface-research/)에서 확인할 수 있습니다.

## 측정·검증

LPDDR·USB 두 프로젝트에서 **86100D·86118A 샘플링 시스템, M8195A AWG, MP1800A BERT, E3631A 전원공급기**를 활용했습니다. 장비별 역할과 측정 자동화 사례를 실제 파형·설정 화면에 연결했습니다.

[장비 활용·자동화](projects/high-speed-interface-research/docs/measurement-equipment.md) · [Eye·Shmoo·AWG 설정 그림](projects/high-speed-interface-research/docs/verification-figures.md)

**공개 RTL의 검증 상태**

| 항목 | 결과 | 확인 범위 |
|---|---|---|
| FIR 테스트 3종 | PASS · 2026-09-09 | 기존 테스트벤치의 출력 정합성 |
| MLSD 메트릭 예제 | PASS · 2026-10-07 | 두 합성 채널의 RTL 행렬 검사·Python 복원 |
| MLSD 전체 어댑터 | FAIL · 2026-10-07 | 출력 불일치 미해결, 재현 로그 공개 |

FPGA 타이밍은 2026-06-29의 기존 구현 보고서를 기준으로 표시합니다. 논문 버전의 시스템 측정과 공개 소스의 실행 결과는 [검증 근거와 범위](projects/zcu208-pam4-dsp-portfolio/docs/validation.md)에 구분해 기록했습니다.

## 연구 성과 논문

| 연구 | 논문 링크 |
|---|---|
| DSP·MLSD | [A-SSCC 2026 · RFSoC 검증 PAM4 송수신기](https://epapers2.org/asscc2026/ESR/paper_details.php?paper_id=1351) |
| LPDDR | [ICEIC 2025 · NRZ TX](https://doi.org/10.1109/ICEIC64972.2025.10879746) · [A-SSCC 2026 · Combo PHY](https://epapers2.org/asscc2026/ESR/paper_details.php?paper_id=1141) |
| USB PAM-3 | [SMACD 2025 · TX 모델](https://doi.org/10.1109/SMACD65553.2025.11092283) · [SMACD 2025 · RX 모델](https://doi.org/10.1109/SMACD65553.2025.11092233) · [IEEE TVLSI 2026 · 제작 TX](https://doi.org/10.1109/TVLSI.2026.3701343) |

전체 제목과 논문별 검증 범위는 [성과 논문 목록](docs/publications.md)에 있습니다. A-SSCC 2026 두 편은 2026-10-07 공식 정보 기준 채택·발표 예정입니다.

---

[전체 자료 지도](docs/repository-map.md) · [검증 상태 한눈에 보기](docs/validation-status.md) · [기술 용어](docs/glossary.md)
