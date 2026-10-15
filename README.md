<a id="page-top"></a>

<p align="right">
<a href="README.en.md" title="View this portfolio in English"><img src="assets/readme/nav-en.svg" alt="English" width="96" height="30"></a>
</p>

# [윤주형](docs/profile.md) | High-Speed Interface·DSP Transceiver 연구

광운대학교 · 석사 학위논문 연구 중

안녕하세요. 윤주형입니다. **JEDEC [LPDDR](projects/high-speed-interface-research/docs/lpddr.md) 및 [USB4 Gen4](projects/high-speed-interface-research/docs/usb4-pam3.md) 규격 기반의 High-Speed Interface 연구**와 <strong>Ultra High-Speed 통신을 위한 <a href="projects/README.md#dsp-transceiver-research">DSP 기반 Transceiver 연구</a></strong>를 진행하고 있습니다.

채널 손실과 [ISI](docs/concepts/equalization.md#term-isi)를 고려해 신호를 보상하고, 높은 전송 속도에서도 데이터를 안정적으로 주고받을 수 있는 회로와 시스템을 설계합니다.

최근 설계 트렌드에 맞게 [AI](docs/ai-assisted-dsp-workflow.md)를 RTL·테스트벤치 작성과 반복 검증·측정 자동화 코드 구성에 활용합니다.

<p>
<a href="#dsp-research"><img src="assets/readme/nav-dsp.svg" alt="DSP / FPGA" width="115" height="30"></a>
<a href="#interface-research"><img src="assets/readme/nav-interface.svg" alt="LPDDR / USB" width="125" height="30"></a>
<a href="#측정검증"><img src="assets/readme/nav-measurement.svg" alt="측정·검증" width="113" height="30"></a>
<a href="#연구-성과-논문"><img src="assets/readme/nav-papers.svg" alt="논문" width="76" height="30"></a>
<a href="docs/ai-assisted-dsp-workflow.md"><img src="assets/readme/nav-ai.svg" alt="AI 활용" width="94" height="30"></a>
<a href="docs/glossary.md"><img src="assets/readme/nav-terms.svg" alt="용어 안내" width="102" height="30"></a>
</p>

<a id="dsp-research"></a>

## DSP 기반 송수신기 연구

### [A-SSCC 2026 | DS-SBM 기반 PAM4 송수신 DSP](projects/zcu208-pam4-dsp-portfolio/)

<p>
<a href="projects/zcu208-pam4-dsp-portfolio/README.md#asscc-result"><img src="projects/zcu208-pam4-dsp-portfolio/assets/mlsd_paper_isi_measurement_setup.png" alt="ZCU208·XM655와 ISI 보드를 연결한 PAM4 송수신 평가 구성" width="840"></a>
</p>

ZCU208의 DAC에서 ISI 보드를 거쳐 ADC로 신호를 받아, 설계한 수신 DSP와 검출기의 동작을 평가했습니다.

<blockquote>
<strong>41&nbsp;dB 채널 · PRBS7 BER &lt; 10⁻⁷ · PRBS15 BER &lt; 2×10⁻⁶</strong><br>
<strong>담당:</strong> PAM4 TX·RX 필터와 MLSD 검출기 RTL 설계, RFSoC 통합·제어와 보드 검증.<br>
A-SSCC 2026 논문 보고값 · <strong>제1저자 · 채택</strong>
</blockquote>

[측정·구현 결과](projects/zcu208-pam4-dsp-portfolio/README.md#asscc-result) · [설계 구조](projects/zcu208-pam4-dsp-portfolio/docs/architecture.md) · [MLSD를 예제로 이해하기](docs/concepts/mlsd.md) · [논문](https://epapers2.org/asscc2026/ESR/paper_details.php?paper_id=1351)

<a id="학위논문-연구--ds-sbmdp-smm-비교-진행-중"></a>
<a id="journal-준비--dp-smm-설계검증-진행-중"></a>

진행 중인 [**학위논문·Journal 연구**](https://github.com/yunjuhyeong0916-glitch/pam4-mlsd-research/blob/main/README.md)는 별도 저장소에서 볼 수 있습니다.

<details>
<summary><strong>연구 내용 보기 · A-SSCC / AI 활용</strong></summary>

### FPGA 구현과 보드 구동

ZCU208 RFSoC에 <strong><a href="projects/zcu208-pam4-dsp-portfolio/docs/architecture.md">32-lane PAM4 DSP</a></strong>의 TX FIR·RX [21-tap FIR](docs/concepts/equalization.md#term-fir-taps)·[DS-SBM RS-MLSD](docs/concepts/mlsd.md)를 통합했습니다. [Vivado·Vitis](projects/zcu208-pam4-dsp-portfolio/docs/vitis-bringup.md)로 JTAG 다운로드, CLK104·RFDC 초기화와 계수 적용을 구성하고, DAC에서 [ISI 보드](projects/zcu208-pam4-dsp-portfolio/docs/validation.md#isi-보드를-통한-rfsoc-측정)를 거쳐 ADC로 수신 신호를 캡처했습니다.

[A-SSCC 프로젝트](projects/zcu208-pam4-dsp-portfolio/) · [설계 판단](projects/zcu208-pam4-dsp-portfolio/docs/design-decisions.md) · [Vitis·FPGA 구동](projects/zcu208-pam4-dsp-portfolio/docs/vitis-bringup.md) · [측정·구현 결과](projects/zcu208-pam4-dsp-portfolio/docs/validation.md)

<a id="ai-활용-범위"></a>

### AI 활용 | MATLAB MCP 기반 RTL·측정 자동화

RTL·테스트벤치 작성과 ZCU208의 계수 설정·데이터 수집·BER 분석을 연결하는 자동화 코드 구성에 AI를 활용했습니다.

[사용 Toolbox·자동화 harness 연결 구조](docs/ai-assisted-dsp-workflow.md)

</details>

<a id="lpddrusb-연구"></a>
<a id="interface-research"></a>

## LPDDR·USB 인터페이스 연구

<p>
<a href="projects/high-speed-interface-research/docs/lpddr-tx-circuit-verification.md" title="LPDDR 15.6 Gb/s TX 회로 설계·검증"><img src="assets/readme/nav-lpddr-15p6.svg" alt="LPDDR 15.6 Gb/s TX 회로 설계·검증" width="147" height="30"></a>
<a href="projects/high-speed-interface-research/docs/lpddr-combo.md" title="LPDDR Combo PHY 구조·TX 설계·모델링·칩 검증"><img src="assets/readme/nav-lpddr-combo.svg" alt="LPDDR Combo PHY 구조·TX 설계·모델링·칩 검증" width="132" height="30"></a>
<a href="projects/high-speed-interface-research/docs/usb-tx-modeling.md" title="USB TX 모델링·RTL 검증"><img src="assets/readme/nav-usb-tx.svg" alt="USB TX 모델링·RTL 검증" width="90" height="30"></a>
<a href="projects/high-speed-interface-research/docs/usb-rx-ctle-modeling.md" title="USB RX CTLE 모델링"><img src="assets/readme/nav-usb-rx.svg" alt="USB RX CTLE 모델링" width="90" height="30"></a>
<a href="projects/high-speed-interface-research/docs/pam3-differential-measurement.md" title="USB TX 칩 측정·차동 PAM-3·FFE 검증"><img src="assets/readme/nav-usb-tx-measurement.svg" alt="USB TX 칩 측정·차동 PAM-3·FFE 검증" width="142" height="30"></a>
</p>

### [LPDDR 15.6&nbsp;Gb/s | 저전압 TX 회로 설계](projects/high-speed-interface-research/docs/lpddr-tx-circuit-verification.md)

<p>
<a href="projects/high-speed-interface-research/docs/lpddr-tx-circuit-verification.md#2-ffe-적용-전후의-eye로-보상-효과-확인"><img src="projects/high-speed-interface-research/assets/lpddr_tx_circuit_eye_ffe_off.png" alt="15.6 Gb/s TX 회로 시뮬레이션: FFE off Eye" width="48%"></a>
<a href="projects/high-speed-interface-research/docs/lpddr-tx-circuit-verification.md#2-ffe-적용-전후의-eye로-보상-효과-확인"><img src="projects/high-speed-interface-research/assets/lpddr_tx_circuit_eye_ffe_on.png" alt="15.6 Gb/s TX 회로 시뮬레이션: FFE on Eye" width="48%"></a>
</p>

왼쪽은 FFE off, 오른쪽은 FFE on의 **회로 시뮬레이션 Eye**입니다. 같은 전송 속도에서 출력 보상 전후를 비교했습니다.

<blockquote>
<strong>15.6&nbsp;Gb/s · Eye 폭 37 → 45.4&nbsp;ps · 높이 56.5 → 75.1&nbsp;mV</strong><br>
<strong>담당:</strong> 28&nbsp;nm TX 회로 설계와 Schematic·Post-Layout 검증.<br>
회로 시뮬레이션 · 채널 손실 8.7&nbsp;dB · ICEIC 2025 <strong>공동 제1저자</strong>
</blockquote>

[회로 구조·검증 결과](projects/high-speed-interface-research/docs/lpddr-tx-circuit-verification.md) · [FFE 원리](docs/concepts/equalization.md#term-ffe) · [논문](https://doi.org/10.1109/ICEIC64972.2025.10879746)

---

### [LPDDR Combo | TX 설계·모델링과 28&nbsp;nm 칩 평가](projects/high-speed-interface-research/docs/lpddr-combo.md)

<p align="center">
<a href="projects/high-speed-interface-research/docs/lpddr-combo.md#lpddr-combo-result"><img src="projects/high-speed-interface-research/assets/pcb_hfss_lpddr_wirebond_photo.png" alt="LPDDR Combo PHY의 COB 실장·와이어 본딩 사진" width="40%"></a>
<a href="projects/high-speed-interface-research/docs/lpddr-combo.md#lpddr-combo-result"><img src="projects/high-speed-interface-research/assets/lpddr_combo_measured_eye_shmoo.png" alt="14 Gb/s/pin·4-DQ 활성 조건에서 측정한 TX Eye와 RX Shmoo" width="34%"></a>
</p>

왼쪽은 COB 실장·와이어 본딩, 오른쪽은 **14&nbsp;Gb/s/pin·4-DQ 활성 조건의 TX Eye와 RX Shmoo**입니다.

<blockquote>
<strong>14&nbsp;Gb/s/pin · TX Eye 0.41&nbsp;UI / 65.3&nbsp;mV</strong><br>
<strong>담당:</strong> DQ TX 회로·Verilog 모델, 측정용 PCB 설계·HFSS 분석. 칩 측정 참여.<br>
28&nbsp;nm 제작 칩 측정 · A-SSCC 2026 <strong>공동저자 · 채택</strong>
</blockquote>

[TX 모델·측정 결과](projects/high-speed-interface-research/docs/lpddr-combo.md#lpddr-combo-result) · [PCB·HFSS](projects/high-speed-interface-research/docs/lpddr-combo-si-pi.md) · [Eye·Shmoo 읽기](docs/concepts/measurements.md) · [논문](https://epapers2.org/asscc2026/ESR/paper_details.php?paper_id=1141)

---

### [USB&nbsp;PAM&#8209;3 | TX·RX 모델링과 TX 칩 평가](projects/high-speed-interface-research/docs/usb4-pam3.md)

<p>
<a href="projects/high-speed-interface-research/docs/pam3-differential-measurement.md"><img src="projects/high-speed-interface-research/assets/pam3_measurement_setup.jpeg" alt="USB PAM-3 TX의 실제 Eye·BER 측정 환경" width="800"></a>
</p>

TX 보드·채널·계측기를 연결한 실제 평가 환경입니다. 아래는 같은 채널에서 FFE off/on을 비교한 출력 Eye입니다.

<p>
<a href="projects/high-speed-interface-research/docs/pam3-differential-measurement.md#pam3-ffe-result"><img src="projects/high-speed-interface-research/assets/pam3_measured_ffe_eye.png" alt="같은 CH#3에서 FFE off와 on을 비교한 실측 PAM-3 Eye" width="800"></a>
</p>

<blockquote>
<strong>32&nbsp;Gb/s · FFE 적용 후 Eye 높이: 상단 21.16&nbsp;mV / 하단 19.80&nbsp;mV</strong><br>
CH#3 손실 17.3&nbsp;dB @ 10.24&nbsp;GHz · PRBS15 · scrambler on<br>
<strong>담당:</strong> TX RTL·RX CTLE 모델링과 통합 검증, TX 칩의 차동 신호 측정 참여.<br>
IEEE TVLSI 2026 <strong>공동 제1저자</strong>
</blockquote>

[측정 결과·FFE 설정](projects/high-speed-interface-research/docs/pam3-differential-measurement.md#pam3-ffe-result) · [TX 모델](projects/high-speed-interface-research/docs/usb-tx-modeling.md) · [RX CTLE](projects/high-speed-interface-research/docs/usb-rx-ctle-modeling.md) · [논문](https://doi.org/10.1109/TVLSI.2026.3701343)

<details>
<summary><strong>설계·검증 내용 보기 · TX / RX / PCB·HFSS / 측정</strong></summary>

| 연구 | 담당 설계·검증 | 대표 성과 |
|---|---|---|
| [LPDDR](projects/high-speed-interface-research/docs/lpddr.md) | [TX 회로 설계·검증](projects/high-speed-interface-research/docs/lpddr-tx-circuit-verification.md), [TX Verilog 모델링](projects/high-speed-interface-research/docs/lpddr-tx-modeling.md), [PCB·HFSS](projects/high-speed-interface-research/docs/pcb-hfss-verification.md) | 15.6 Gb/s TX 회로 시뮬레이션, 14 Gb/s/pin Combo PHY 실측 참여 |
| [USB&nbsp;PAM&#8209;3](projects/high-speed-interface-research/docs/usb4-pam3.md) | [TX 모델링·RTL 검증](projects/high-speed-interface-research/docs/usb-tx-modeling.md), [RX CTLE 모델링](projects/high-speed-interface-research/docs/usb-rx-ctle-modeling.md), [차동 PAM-3 측정·FFE 검증](projects/high-speed-interface-research/docs/pam3-differential-measurement.md) | 송수신 모델 통합 검증, 32 Gb/s TX 칩의 차동 신호 평가·FFE 효과 확인 |

[PCB·HFSS](projects/high-speed-interface-research/docs/pcb-hfss-verification.md) · [LPDDR·USB 인터페이스 연구](projects/high-speed-interface-research/)

</details>

## 측정·검증

### FPGA 측정·검증

- **[RFSoC 실측](projects/zcu208-pam4-dsp-portfolio/docs/validation.md#isi-보드를-통한-rfsoc-측정):** ZCU208 DAC → ISI 보드 → ADC 경로의 신호를 캡처하고 PL PRBS 검사기 집계값으로 BER을 평가했습니다.

- **[FPGA 구현 · Vivado](projects/zcu208-pam4-dsp-portfolio/docs/validation.md#fpga-자원타이밍):** RTL 구현 결과의 자원 사용량과 타이밍 여유를 확인했습니다.

- **[보드 초기화·제어 · Vitis](projects/zcu208-pam4-dsp-portfolio/docs/vitis-bringup.md):** JTAG 실행, 클록·RFDC 초기화, RX 계수 적용과 데이터 수집을 구성했습니다.

- **[측정 자동화](docs/ai-assisted-dsp-workflow.md#zcu208-측정-harness):** 조건별 앱 빌드·실행과 UART 기록을 묶고, ILA 집계값을 Python으로 분석해 BER을 산출했습니다.

<a id="pcbhfss-기반-28-nm-실리콘-칩-검증"></a>

### 28 nm 칩 측정·PCB/HFSS 분석

- **[PCB·HFSS 설계·분석](projects/high-speed-interface-research/docs/pcb-hfss-verification.md):** LPDDR 측정용 PCB의 전달 특성을 분석하고, USB TX의 접지·전원 경로를 검토했습니다.

- **28 nm 칩 측정:** [LPDDR TX Eye·RX Shmoo](projects/high-speed-interface-research/docs/verification-figures.md)를 측정하고, [USB 차동 PAM&#8209;3의 FFE 적용 전후 상·하단 Eye](projects/high-speed-interface-research/docs/pam3-differential-measurement.md)를 비교했습니다.

- **[계측 자동화](projects/high-speed-interface-research/docs/measurement-equipment.md):** 전원·BERT·I2C를 연동해 전압·타이밍을 스윕하고, 오류 조기 종료·경계 탐색을 적용했습니다. 결과는 CSV로 기록했습니다.

## 연구 성과 논문

### DSP 기반 송수신기

- **A-SSCC 2026 · 제1저자 · 채택:** [DS-SBM 기반 RFSoC PAM4 송수신기](https://epapers2.org/asscc2026/ESR/paper_details.php?paper_id=1351)

### LPDDR 인터페이스

- **A-SSCC 2026 · 공동저자 · 채택:** [LPDDR4X/5/5X Combo PHY](https://epapers2.org/asscc2026/ESR/paper_details.php?paper_id=1141)
- **ICEIC 2025 · 공동 제1저자:** [15.6-Gb/s 저전압 NRZ TX](https://doi.org/10.1109/ICEIC64972.2025.10879746)

### USB 인터페이스

- **IEEE TVLSI 2026 · 공동 제1저자:** [150-preset 4-tap FFE를 적용한 PAM&#8209;3 TX](https://doi.org/10.1109/TVLSI.2026.3701343)
- **SMACD 2025 · 공동 제1저자:** [USB4 Gen4 PAM&#8209;3 TX 모델](https://doi.org/10.1109/SMACD65553.2025.11092283)
- **SMACD 2025 · 공동 제1저자:** [PAM&#8209;3 RX 모델](https://doi.org/10.1109/SMACD65553.2025.11092233)

A-SSCC 2026 두 편: 채택·발표 예정(2026-10-07 기준). [전체 논문 목록](docs/publications.md)

---

[문서 지도](docs/repository-map.md) · [검증 상태](docs/validation-status.md) · [용어 안내](docs/glossary.md)

<!-- page-navigation:bottom -->
<p>
  <a href="#page-top" title="페이지 맨 위로 이동"><img src="assets/readme/nav-top.svg" alt="페이지 맨 위로 이동" width="100" height="30"></a>
</p>
<!-- /page-navigation:bottom -->
