<a id="page-top"></a>

<p align="right">
<a href="README.md" title="한국어 포트폴리오 보기"><img src="assets/readme/nav-ko.svg" alt="한국어" width="87" height="30"></a>
</p>

# [Juhyeong Yun](docs/profile.en.md) | High-Speed Interface & DSP Transceiver Research

Kwangwoon University · Master's thesis research in progress

I'm Juhyeong Yun. My research covers **high-speed interfaces based on JEDEC [LPDDR](projects/high-speed-interface-research/docs/lpddr.md) and [USB4 Gen4](projects/high-speed-interface-research/docs/usb4-pam3.md) specifications** and **[DSP-based transceivers](projects/README.md#dsp-transceiver-research) for ultra-high-speed communication**.

I design circuits and systems that compensate for channel loss and [ISI](docs/concepts/equalization.en.md#term-isi) to support reliable data transmission at high speeds.

In line with current design trends, I use [AI](docs/ai-assisted-dsp-workflow.en.md) to assist with RTL, testbench and automation code for repeatable verification and measurements.

<p>
<a href="#dsp-research"><img src="assets/readme/nav-dsp.svg" alt="DSP / FPGA" width="115" height="30"></a>
<a href="#interface-research"><img src="assets/readme/nav-interface.svg" alt="LPDDR / USB" width="125" height="30"></a>
<a href="#measurement--verification"><img src="assets/readme/nav-measurement-en.svg" alt="Verification" width="119" height="30"></a>
<a href="#research-publications"><img src="assets/readme/nav-papers-en.svg" alt="Papers" width="90" height="30"></a>
<a href="docs/ai-assisted-dsp-workflow.en.md"><img src="assets/readme/nav-ai-en.svg" alt="AI workflow" width="118" height="30"></a>
<a href="docs/glossary.en.md"><img src="assets/readme/nav-terms-en.svg" alt="Terms" width="86" height="30"></a>
</p>

<a id="dsp-research"></a>

## DSP transceiver research

### [A-SSCC 2026 | DS-SBM-based PAM4 transceiver DSP](projects/zcu208-pam4-dsp-portfolio/)

<p>
<a href="projects/zcu208-pam4-dsp-portfolio/README.md#asscc-result"><img src="projects/zcu208-pam4-dsp-portfolio/assets/mlsd_paper_isi_measurement_setup.png" alt="ZCU208, XM655 and ISI-board setup for PAM4 transceiver evaluation" width="840"></a>
</p>

The ZCU208 DAC sends a signal through an ISI board to the ADC, evaluating the implemented receiver DSP and detector.

<blockquote>
<strong>41-dB channel · PRBS7 BER &lt; 10⁻⁷ · PRBS15 BER &lt; 2×10⁻⁶</strong><br>
<strong>My role:</strong> PAM4 TX/RX filter and MLSD detector RTL, RFSoC integration, control and board validation.<br>
Results reported in A-SSCC 2026 · <strong>First author · Accepted</strong>
</blockquote>

[Measurement and implementation results](projects/zcu208-pam4-dsp-portfolio/README.md#asscc-result) · [Architecture](projects/zcu208-pam4-dsp-portfolio/docs/architecture.md) · [MLSD example](docs/concepts/mlsd.en.md) · [Paper](https://epapers2.org/asscc2026/ESR/paper_details.php?paper_id=1351)

<a id="masters-thesis--ds-sbm-and-dp-smm-comparison-in-progress"></a>
<a id="journal-preparation--dp-smm-design-and-verification-in-progress"></a>

My [**DS-SBM thesis**](https://github.com/yunjuhyeong0916-glitch/pam4-mlsd-research/blob/main/projects/pam4-mlsd-thesis/README.en.md) is being finalized. The follow-up [**DP-SMM journal research**](https://github.com/yunjuhyeong0916-glitch/pam4-mlsd-research/blob/main/projects/dp-smm-journal/README.md) is documented in a separate project.

<details>
<summary><strong>View research · A-SSCC / AI assistance</strong></summary>

### FPGA implementation and board control

I integrated **[32-lane PAM4 DSP](projects/zcu208-pam4-dsp-portfolio/docs/architecture.md)**, TX FIR, RX [21-tap FIR](docs/concepts/equalization.en.md#term-fir-taps) and [DS-SBM RS-MLSD](docs/concepts/mlsd.en.md) with the ZCU208 RFSoC. The [Vivado / Vitis flow](projects/zcu208-pam4-dsp-portfolio/docs/vitis-bringup.md) covers JTAG programming, CLK104 / RFDC initialization and coefficient updates. Measurement signals pass from the DAC through an [ISI board](projects/zcu208-pam4-dsp-portfolio/docs/validation.md#isi-보드를-통한-rfsoc-측정) to ADC capture.

[A-SSCC project](projects/zcu208-pam4-dsp-portfolio/) · [Design decisions](projects/zcu208-pam4-dsp-portfolio/docs/design-decisions.md) · [Vitis / FPGA bring-up](projects/zcu208-pam4-dsp-portfolio/docs/vitis-bringup.md) · [Measurement and implementation results](projects/zcu208-pam4-dsp-portfolio/docs/validation.md)

<a id="ai-assistance"></a>

### AI assistance | RTL and measurement automation with MATLAB MCP

I used AI to help develop RTL and testbenches, plus automation code connecting ZCU208 coefficient settings, data collection and BER analysis.

[Toolbox roles and automation harness diagrams](docs/ai-assisted-dsp-workflow.en.md)

</details>

<a id="lpddr--usb-research"></a>
<a id="interface-research"></a>

## LPDDR / USB interface research

<p>
<a href="projects/high-speed-interface-research/docs/lpddr-tx-circuit-verification.md" title="LPDDR 15.6 Gb/s TX circuit design and verification"><img src="assets/readme/nav-lpddr-15p6.svg" alt="LPDDR 15.6 Gb/s TX circuit design and verification" width="147" height="30"></a>
<a href="projects/high-speed-interface-research/docs/lpddr-combo.md" title="LPDDR Combo PHY architecture, TX design, modeling and silicon validation"><img src="assets/readme/nav-lpddr-combo.svg" alt="LPDDR Combo PHY architecture, TX design, modeling and silicon validation" width="132" height="30"></a>
<a href="projects/high-speed-interface-research/docs/usb-tx-modeling.md" title="USB TX modeling and RTL verification"><img src="assets/readme/nav-usb-tx.svg" alt="USB TX modeling and RTL verification" width="90" height="30"></a>
<a href="projects/high-speed-interface-research/docs/usb-rx-ctle-modeling.md" title="USB RX CTLE modeling"><img src="assets/readme/nav-usb-rx.svg" alt="USB RX CTLE modeling" width="90" height="30"></a>
<a href="projects/high-speed-interface-research/docs/pam3-differential-measurement.md" title="USB TX silicon measurements, differential PAM-3 and FFE verification"><img src="assets/readme/nav-usb-tx-measurement-en.svg" alt="USB TX silicon measurements, differential PAM-3 and FFE verification" width="174" height="30"></a>
</p>

### [LPDDR 15.6&nbsp;Gb/s | Low-voltage TX circuit design](projects/high-speed-interface-research/docs/lpddr-tx-circuit-verification.md)

<p>
<a href="projects/high-speed-interface-research/docs/lpddr-tx-circuit-verification.md#2-ffe-적용-전후의-eye로-보상-효과-확인"><img src="projects/high-speed-interface-research/assets/lpddr_tx_circuit_eye_ffe_off.png" alt="15.6-Gb/s TX circuit simulation with FFE off" width="48%"></a>
<a href="projects/high-speed-interface-research/docs/lpddr-tx-circuit-verification.md#2-ffe-적용-전후의-eye로-보상-효과-확인"><img src="projects/high-speed-interface-research/assets/lpddr_tx_circuit_eye_ffe_on.png" alt="15.6-Gb/s TX circuit simulation with FFE on" width="48%"></a>
</p>

**Circuit-simulation eyes:** FFE off on the left, FFE on on the right, compared at the same data rate.

<blockquote>
<strong>15.6&nbsp;Gb/s · Eye width 37 → 45.4&nbsp;ps · Height 56.5 → 75.1&nbsp;mV</strong><br>
<strong>My role:</strong> 28-nm TX circuit design and schematic/post-layout verification.<br>
Circuit simulation · 8.7-dB channel loss · ICEIC 2025 <strong>Co-first author</strong>
</blockquote>

[Circuit and verification results](projects/high-speed-interface-research/docs/lpddr-tx-circuit-verification.md) · [FFE principles](docs/concepts/equalization.en.md#term-ffe) · [Paper](https://doi.org/10.1109/ICEIC64972.2025.10879746)

---

### [LPDDR Combo | TX design, modeling and 28-nm silicon evaluation](projects/high-speed-interface-research/docs/lpddr-combo.md)

<p align="center">
<a href="projects/high-speed-interface-research/docs/lpddr-combo.md#lpddr-combo-result"><img src="projects/high-speed-interface-research/assets/pcb_hfss_lpddr_wirebond_photo.png" alt="COB assembly and wire bonds of the LPDDR Combo PHY" width="40%"></a>
<a href="projects/high-speed-interface-research/docs/lpddr-combo.md#lpddr-combo-result"><img src="projects/high-speed-interface-research/assets/lpddr_combo_measured_eye_shmoo.png" alt="Measured TX eye and RX Shmoo at 14 Gb/s/pin with four DQs active" width="34%"></a>
</p>

COB assembly and wire bonds on the left; **measured TX eye and RX Shmoo at 14&nbsp;Gb/s/pin with four DQs active** on the right.

<blockquote>
<strong>14&nbsp;Gb/s/pin · TX eye 0.41&nbsp;UI / 65.3&nbsp;mV</strong><br>
<strong>My role:</strong> TX circuit/model design, measurement PCB design and HFSS analysis; participation in chip measurements.<br>
28-nm silicon measurements · A-SSCC 2026 <strong>Co-author · Accepted</strong>
</blockquote>

[TX model and measurement results](projects/high-speed-interface-research/docs/lpddr-combo.md#lpddr-combo-result) · [PCB/HFSS](projects/high-speed-interface-research/docs/lpddr-combo-si-pi.md) · [Reading Eye and Shmoo](docs/concepts/measurements.en.md) · [Paper](https://epapers2.org/asscc2026/ESR/paper_details.php?paper_id=1141)

---

### [USB&nbsp;PAM&#8209;3 | TX/RX modeling and TX silicon evaluation](projects/high-speed-interface-research/docs/usb4-pam3.md)

<p>
<a href="projects/high-speed-interface-research/docs/pam3-differential-measurement.md"><img src="projects/high-speed-interface-research/assets/pam3_measurement_setup.jpeg" alt="Lab setups for USB PAM-3 TX eye and BER measurements" width="800"></a>
</p>

Lab setups connect the TX board, channel and instruments. The eyes below compare FFE off and on on the same channel.

<p>
<a href="projects/high-speed-interface-research/docs/pam3-differential-measurement.md#pam3-ffe-result"><img src="projects/high-speed-interface-research/assets/pam3_measured_ffe_eye.png" alt="Measured PAM-3 eyes with FFE off and on on the same CH3 channel" width="800"></a>
</p>

<blockquote>
<strong>32&nbsp;Gb/s · Eye height with FFE: upper 21.16&nbsp;mV / lower 19.80&nbsp;mV</strong><br>
CH3: 17.3-dB loss at 10.24&nbsp;GHz · PRBS15 · scrambler on<br>
<strong>My role:</strong> TX RTL, RX CTLE modeling and integrated verification; participation in differential TX silicon measurements.<br>
IEEE TVLSI 2026 <strong>Co-first author</strong>
</blockquote>

[Measurements and FFE settings](projects/high-speed-interface-research/docs/pam3-differential-measurement.md#pam3-ffe-result) · [TX models](projects/high-speed-interface-research/docs/usb-tx-modeling.md) · [RX CTLE](projects/high-speed-interface-research/docs/usb-rx-ctle-modeling.md) · [Paper](https://doi.org/10.1109/TVLSI.2026.3701343)

<details>
<summary><strong>View design and verification · TX / RX / PCB / HFSS / Measurements</strong></summary>

| Research | Design and verification work | Key results |
|---|---|---|
| [LPDDR](projects/high-speed-interface-research/docs/lpddr.md) | [TX circuits](projects/high-speed-interface-research/docs/lpddr-tx-circuit-verification.md), [TX Verilog models](projects/high-speed-interface-research/docs/lpddr-tx-modeling.md), [PCB / HFSS](projects/high-speed-interface-research/docs/pcb-hfss-verification.md) | 15.6-Gb/s TX circuit simulation; participation in 14-Gb/s/pin Combo PHY measurements |
| [USB&nbsp;PAM&#8209;3](projects/high-speed-interface-research/docs/usb4-pam3.md) | [TX models / RTL](projects/high-speed-interface-research/docs/usb-tx-modeling.md), [RX CTLE models](projects/high-speed-interface-research/docs/usb-rx-ctle-modeling.md), [Differential PAM-3 measurements / FFE](projects/high-speed-interface-research/docs/pam3-differential-measurement.md) | Integrated TX/RX model verification; differential signal evaluation and FFE-effect checks on a 32-Gb/s TX chip |

[PCB / HFSS](projects/high-speed-interface-research/docs/pcb-hfss-verification.md) · [LPDDR / USB interface research](projects/high-speed-interface-research/)

</details>

## Measurement / verification

### FPGA measurement and validation

- **[RFSoC measurements](projects/zcu208-pam4-dsp-portfolio/docs/validation.md#isi-보드를-통한-rfsoc-측정):** Captured signals through the ZCU208 DAC → ISI board → ADC path and evaluated BER using PL PRBS checker counts.

- **[FPGA implementation · Vivado](projects/zcu208-pam4-dsp-portfolio/docs/validation.md#fpga-자원타이밍):** Checked resource utilization and timing margin after RTL implementation.

- **[Board setup and control · Vitis](projects/zcu208-pam4-dsp-portfolio/docs/vitis-bringup.md):** Configured JTAG launch, clock and RFDC initialization, RX coefficient updates and data collection.

- **[Measurement automation](docs/ai-assisted-dsp-workflow.en.md#zcu208-measurement-harness):** Connected condition-specific app builds and execution with UART logging, then calculated BER from ILA counts in Python.

<a id="28-nm-silicon-validation-with-pcb-design-and-hfss-analysis"></a>

### 28-nm chip measurements / PCB and HFSS analysis

- **[PCB design and HFSS analysis](projects/high-speed-interface-research/docs/pcb-hfss-verification.md):** Analyzed transmission characteristics of the LPDDR measurement PCB and reviewed USB TX ground and power paths.

- **28-nm chip measurements:** Measured [LPDDR TX eyes and RX Shmoo](projects/high-speed-interface-research/docs/verification-figures.md) and compared [USB differential PAM&#8209;3 upper and lower eyes before and after FFE](projects/high-speed-interface-research/docs/pam3-differential-measurement.md).

- **[Instrument automation](projects/high-speed-interface-research/docs/measurement-equipment.md):** Coordinated power-supply, BERT and I2C control for voltage and timing sweeps. Applied early error stops and boundary searches, and logged results to CSV.

## Research publications

### DSP-based transceivers

- **A-SSCC 2026 · First author · Accepted:** [DS-SBM RFSoC PAM4 transceiver](https://epapers2.org/asscc2026/ESR/paper_details.php?paper_id=1351)

### LPDDR interfaces

- **A-SSCC 2026 · Co-author · Accepted:** [LPDDR4X/5/5X Combo PHY](https://epapers2.org/asscc2026/ESR/paper_details.php?paper_id=1141)
- **ICEIC 2025 · Co-first author:** [15.6-Gb/s low-voltage NRZ TX](https://doi.org/10.1109/ICEIC64972.2025.10879746)

### USB interfaces

- **IEEE TVLSI 2026 · Co-first author:** [PAM&#8209;3 TX with 150-preset four-tap FFE](https://doi.org/10.1109/TVLSI.2026.3701343)
- **SMACD 2025 · Co-first author:** [USB4 Gen4 PAM&#8209;3 TX model](https://doi.org/10.1109/SMACD65553.2025.11092283)
- **SMACD 2025 · Co-first author:** [PAM&#8209;3 RX model](https://doi.org/10.1109/SMACD65553.2025.11092233)

Both A-SSCC 2026 papers are accepted, with presentations forthcoming as of 2026-10-07. [Full publication list](docs/publications.md)

---

[Repository map](docs/repository-map.md) · [Verification status](docs/validation-status.md) · [Term guide](docs/glossary.en.md)

<!-- page-navigation:bottom -->
<p>
  <a href="#page-top" title="Back to top"><img src="assets/readme/nav-top-en.svg" alt="Back to top" width="124" height="30"></a>
</p>
<!-- /page-navigation:bottom -->
