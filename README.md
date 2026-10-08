# 윤주형 | HW 설계·검증

안녕하세요. 윤주형입니다. **JEDEC LPDDR 및 USB4 Gen4 규격 기반의 High-Speed Interface 연구**와 **Ultra High-Speed 통신을 위한 DSP 기반 Transceiver 연구**를 진행하고 있습니다.

채널 손실과 ISI를 고려해 신호를 보상하고, 높은 전송 속도에서도 데이터를 안정적으로 주고받을 수 있는 회로와 시스템을 설계합니다.

설계 변경 후에도 같은 조건으로 검증을 반복할 수 있도록, AI를 RTL·테스트벤치 작성과 검증·측정 자동화 코드 구성에 활용하고 있습니다.

[DSP·FPGA](#dsp-기반-송수신기-연구) · [LPDDR·USB 인터페이스](#lpddrusb-인터페이스-연구) · [측정·검증](#측정검증) · [논문](#연구-성과-논문) · [GitHub 프로필](https://github.com/yunjuhyeong0916-glitch) · [English](README.en.md)

## DSP 기반 송수신기 연구

<details>
<summary><strong>연구 내용 보기 · 학위논문 / Journal 준비 / A-SSCC / AI 활용</strong></summary>

학위논문에서는 DS-SBM과 DP-SMM의 구조를 비교하고 후보 보존 효과를 검증하고 있습니다. Journal 준비 연구는 DP-SMM 설계를, A-SSCC 연구는 DS-SBM의 RFSoC 송수신 실측을 다룹니다.

### 학위논문 연구 | DS-SBM·DP-SMM 비교 (진행 중)

두 구조의 신호 경로·후보 보존·프레임 경계 갱신을 비교했습니다. DP-SMM에서는 행렬 원소마다 경로를 하나 또는 두 개 남기는 코어에 동일 입력을 적용해, 후보 보존이 오류 수에 미치는 영향을 확인했습니다.

[학위논문 프로젝트](projects/pam4-mlsd-thesis/) · [구조 비교](projects/pam4-mlsd-thesis/docs/architecture.md) · [모델·RTL 비교 결과](projects/pam4-mlsd-thesis/docs/validation.md)

### Journal 준비 | DP-SMM 설계·검증 (진행 중)

DS-SBM의 구간 행렬 구조를 확장해, 합성 단계마다 두 경로를 보존하고 실제 심볼 이력으로 비용을 재평가하는 DP-SMM 검출기를 설계했습니다. 프레임 경계에서도 상태별 두 후보를 남겨 다음 프레임의 판정에 활용합니다. 참조 모델과 RTL의 일치를 확인하고 FPGA 배치배선을 수행했으며, **21-tap RX FFE + DP-SMM** 구성으로 보드 실측을 준비합니다.

**DP-SMM 특허 출원 준비 중.**

[DP-SMM Journal 프로젝트](projects/dp-smm-journal/) · [DS-SBM·DP-SMM 비교 그림](projects/dp-smm-journal/#ds-sbm에서-확장한-점) · [RTL 검증·FPGA 구현](projects/dp-smm-journal/docs/validation.md)

### A-SSCC 2026 | DS-SBM 기반 PAM4 송수신 DSP

ZCU208 RFSoC에 **32-lane PAM4 DSP**의 TX FIR·RX 21-tap FIR·DS-SBM RS-MLSD를 통합했습니다. Vivado·Vitis로 JTAG 다운로드, CLK104·RFDC 초기화와 계수 적용을 구성하고, DAC에서 ISI 보드를 거쳐 ADC로 수신 신호를 캡처했습니다.

[A-SSCC 프로젝트](projects/zcu208-pam4-dsp-portfolio/) · [설계 판단](projects/zcu208-pam4-dsp-portfolio/docs/design-decisions.md) · [Vitis·FPGA 구동](projects/zcu208-pam4-dsp-portfolio/docs/vitis-bringup.md) · [측정·구현 결과](projects/zcu208-pam4-dsp-portfolio/docs/validation.md)

<a id="ai-활용-범위"></a>

### AI 활용 | MATLAB MCP 기반 RTL·측정 자동화

RTL·테스트벤치 작성과 ZCU208의 계수 설정·데이터 수집·BER 분석을 연결하는 자동화 코드 구성에 AI를 활용했습니다.

[사용 Toolbox·자동화 harness 연결 구조](docs/ai-assisted-dsp-workflow.md)

</details>

<a id="lpddrusb-연구"></a>

## LPDDR·USB 인터페이스 연구

<details>
<summary><strong>설계·검증 내용 보기 · TX / RX / PCB·HFSS / 측정</strong></summary>

| 연구 | 담당 설계·검증 | 대표 성과 |
|---|---|---|
| [LPDDR](projects/high-speed-interface-research/docs/lpddr.md) | [TX 회로 설계·검증](projects/high-speed-interface-research/docs/lpddr-tx-circuit-verification.md), [TX Verilog 모델링](projects/high-speed-interface-research/docs/lpddr-tx-modeling.md), [PCB·HFSS](projects/high-speed-interface-research/docs/pcb-hfss-verification.md) | 14 Gb/s/pin Combo PHY, TX Eye 0.41 UI·65.3 mV, RX 마진 0.25 UI·25 mV |
| [USB&nbsp;PAM&#8209;3](projects/high-speed-interface-research/docs/usb4-pam3.md) | [TX 모델링·RTL 검증](projects/high-speed-interface-research/docs/usb-tx-modeling.md), [RX CTLE 모델링](projects/high-speed-interface-research/docs/usb-rx-ctle-modeling.md), [차동 PAM-3 측정·FFE 검증](projects/high-speed-interface-research/docs/pam3-differential-measurement.md) | 32 Gb/s·PRBS15, 손실 17.3 dB @ 10.24 GHz<br>상단 Eye 11.19 ps·21.16 mV<br>하단 Eye 11.67 ps·19.80 mV |

[PCB·HFSS](projects/high-speed-interface-research/docs/pcb-hfss-verification.md) · [LPDDR·USB 인터페이스 연구](projects/high-speed-interface-research/)

</details>

## 측정·검증

### FPGA 측정·검증

| 항목 | 평가·검증 내용 | 상세 자료 |
|---|---|---|
| RFSoC 실측 | ZCU208 DAC → ISI 보드 → ADC 캡처, PL PRBS 검사기의 집계값으로 BER 평가 | [ISI 보드 측정·BER](projects/zcu208-pam4-dsp-portfolio/docs/validation.md#isi-보드를-통한-rfsoc-측정) |
| FPGA 구현·구동 | 자원·타이밍 확인, JTAG 실행·클록/RFDC 초기화·계수 적용 | [구현 결과](projects/zcu208-pam4-dsp-portfolio/docs/validation.md#fpga-자원타이밍)<br>[Vitis 구동](projects/zcu208-pam4-dsp-portfolio/docs/vitis-bringup.md) |
| 측정 자동화 | 조건별 앱 빌드·실행, UART 캡처·저장과 ILA 집계값의 Python BER 분석 | [측정 harness 연결 구조](docs/ai-assisted-dsp-workflow.md#zcu208-측정-harness) |

### PCB·HFSS 기반 28 nm 실리콘 칩 검증

| 항목 | 평가·검증 내용 | 상세 자료 |
|---|---|---|
| PCB·HFSS | LPDDR 측정용 PCB 설계·전달 특성 분석, USB TX 보드의 접지·전원 경로 검토 | [PCB 설계·HFSS 분석](projects/high-speed-interface-research/docs/pcb-hfss-verification.md) |
| 28 nm 칩 측정 | LPDDR TX Eye·RX Shmoo, USB 차동 PAM-3의 FFE 적용 전후 상·하단 Eye 비교 | [Eye·Shmoo](projects/high-speed-interface-research/docs/verification-figures.md)<br>[PAM-3 측정·FFE](projects/high-speed-interface-research/docs/pam3-differential-measurement.md) |
| 계측 자동화 | 전원·BERT·I2C 연동, 전압·타이밍 스윕과 오류 조기 종료·경계 탐색·CSV 기록 | [장비·제어 방법](projects/high-speed-interface-research/docs/measurement-equipment.md) |

## 연구 성과 논문

| 연구 | 논문 링크 |
|---|---|
| DSP·MLSD | [A-SSCC 2026 · RFSoC 검증 PAM4 송수신기](https://epapers2.org/asscc2026/ESR/paper_details.php?paper_id=1351) |
| LPDDR | [ICEIC 2025 · NRZ TX](https://doi.org/10.1109/ICEIC64972.2025.10879746) · [A-SSCC 2026 · Combo PHY](https://epapers2.org/asscc2026/ESR/paper_details.php?paper_id=1141) |
| USB PAM-3 | [SMACD 2025 · TX 모델](https://doi.org/10.1109/SMACD65553.2025.11092283) · [SMACD 2025 · RX 모델](https://doi.org/10.1109/SMACD65553.2025.11092233) · [IEEE TVLSI 2026 · 제작 TX](https://doi.org/10.1109/TVLSI.2026.3701343) |

A-SSCC 2026 두 편: 채택·발표 예정(2026-10-07 기준). [전체 논문 목록](docs/publications.md)

---

[문서 지도](docs/repository-map.md) · [검증 상태](docs/validation-status.md) · [기술 용어](docs/glossary.md)
