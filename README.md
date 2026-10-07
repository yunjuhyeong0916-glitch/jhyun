# 윤주형 | HW 설계·검증

**고속 인터페이스 · DSP · RTL/FPGA**

PAM4 송수신 DSP, LPDDR 저전압 TX와 USB PAM-3 인터페이스를 설계·검증했습니다. 회로·동작 모델·RTL 구현과 FPGA·실리콘 평가를 수행했습니다.

[DSP·FPGA](#dsp-기반-송수신기-연구) · [LPDDR·USB](#lpddrusb-연구) · [측정·검증](#측정검증) · [논문](#연구-성과-논문) · [English](README.en.md)

## DSP 기반 송수신기 연구

A-SSCC 연구에서는 DS-SBM RS-MLSD를 RFSoC 송수신 시스템에 구현했습니다. 학위논문에서는 DP-SMM의 메트릭 계산과 경로 복원을 검증하고 있습니다.

### A-SSCC 2026 | DS-SBM 기반 PAM4 송수신 DSP

ZCU208 RFSoC에 **32-lane PAM4 DSP**의 TX FIR·RX 21-tap FIR·DS-SBM RS-MLSD를 통합했습니다. Vivado·Vitis로 JTAG 다운로드, CLK104·RFDC 초기화와 계수 적용을 구성하고, DAC에서 ISI 보드를 거쳐 ADC로 수신 신호를 캡처했습니다.

[A-SSCC 프로젝트](projects/zcu208-pam4-dsp-portfolio/) · [설계 판단](projects/zcu208-pam4-dsp-portfolio/docs/design-decisions.md) · [측정·구현 결과](projects/zcu208-pam4-dsp-portfolio/docs/validation.md)

### 학위논문 연구 | DP-SMM 설계·검증

잔류 ISI를 처리하는 DP-SMM의 메트릭 행렬 계산·결합과 전체 경로 복원을 기준 모델과 비교하는 연구입니다.

[DP-SMM 학위논문 프로젝트](projects/pam4-mlsd-thesis/) · [구조·검증 범위](projects/pam4-mlsd-thesis/docs/architecture.md) · [DP-SMM 검증 결과](projects/pam4-mlsd-thesis/docs/validation.md)

## LPDDR·USB 연구

| 연구 | 담당 설계·검증 | 공동 실리콘 결과 |
|---|---|---|
| [LPDDR](projects/high-speed-interface-research/docs/lpddr.md) | [TX 회로 설계·검증](projects/high-speed-interface-research/docs/lpddr-tx-circuit-verification.md), [TX Verilog 모델링](projects/high-speed-interface-research/docs/lpddr-tx-modeling.md), [PCB·HFSS](projects/high-speed-interface-research/docs/pcb-hfss-verification.md) | 14 Gb/s/pin Combo PHY, TX Eye 0.41 UI·65.3 mV, RX 마진 0.25 UI·25 mV |
| [USB PAM-3](projects/high-speed-interface-research/docs/usb4-pam3.md) | [TX 모델링·RTL 검증](projects/high-speed-interface-research/docs/usb-tx-modeling.md), [RX CTLE 모델링](projects/high-speed-interface-research/docs/usb-rx-ctle-modeling.md), 차동 신호 평가 | 28-nm·32-Gb/s TX, 150-preset 4-tap FFE |

[PCB·HFSS](projects/high-speed-interface-research/docs/pcb-hfss-verification.md) · [LPDDR·USB 프로젝트](projects/high-speed-interface-research/)

## 측정·검증

86100D·86118A로 Eye를 관측하고, M8195A AWG로 입력 신호를 공급했습니다. MP1800A BERT·E3631A·I2C를 연동해 전압·타이밍 스윕, 오류 조기 종료·경계 탐색과 CSV 수집을 구현했습니다.

[장비·자동화](projects/high-speed-interface-research/docs/measurement-equipment.md) · [Eye·Shmoo](projects/high-speed-interface-research/docs/verification-figures.md)

[A-SSCC 측정·구현](projects/zcu208-pam4-dsp-portfolio/docs/validation.md) · [학위논문 검증](projects/pam4-mlsd-thesis/docs/validation.md)

## 연구 성과 논문

| 연구 | 논문 링크 |
|---|---|
| DSP·MLSD | [A-SSCC 2026 · RFSoC 검증 PAM4 송수신기](https://epapers2.org/asscc2026/ESR/paper_details.php?paper_id=1351) |
| LPDDR | [ICEIC 2025 · NRZ TX](https://doi.org/10.1109/ICEIC64972.2025.10879746) · [A-SSCC 2026 · Combo PHY](https://epapers2.org/asscc2026/ESR/paper_details.php?paper_id=1141) |
| USB PAM-3 | [SMACD 2025 · TX 모델](https://doi.org/10.1109/SMACD65553.2025.11092283) · [SMACD 2025 · RX 모델](https://doi.org/10.1109/SMACD65553.2025.11092233) · [IEEE TVLSI 2026 · 제작 TX](https://doi.org/10.1109/TVLSI.2026.3701343) |

A-SSCC 2026 두 편: 채택·발표 예정(2026-10-07 기준). [전체 논문 목록](docs/publications.md)

---

[문서 지도](docs/repository-map.md) · [검증 상태](docs/validation-status.md) · [기술 용어](docs/glossary.md)
