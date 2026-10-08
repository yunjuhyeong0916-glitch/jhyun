<a id="page-top"></a>

<p align="right">
<a href="README.md" title="한국어 포트폴리오 보기"><img src="assets/readme/nav-ko.svg" alt="한국어" width="87" height="30"></a>
</p>

# Juhyeong Yun | High-Speed Interface & DSP Transceiver Research

Kwangwoon University · Master's thesis research in progress · [GitHub profile](https://github.com/yunjuhyeong0916-glitch)

I'm Juhyeong Yun. My research covers **high-speed interfaces based on JEDEC [LPDDR](projects/high-speed-interface-research/docs/lpddr.md) and [USB4 Gen4](projects/high-speed-interface-research/docs/usb4-pam3.md) specifications** and **[DSP-based transceivers](projects/README.md#dsp-transceiver-research) for ultra-high-speed communication**.

I design circuits and systems that compensate for channel loss and ISI to support reliable data transmission at high speeds.

In line with current design trends, I use [AI](docs/ai-assisted-dsp-workflow.en.md) to assist with RTL, testbench and automation code for repeatable verification and measurements.

<p>
<a href="#measurement--verification"><img src="assets/readme/nav-measurement-en.svg" alt="Verification" width="119" height="30"></a>
<a href="#research-publications"><img src="assets/readme/nav-papers-en.svg" alt="Papers" width="90" height="30"></a>
<a href="docs/ai-assisted-dsp-workflow.en.md"><img src="assets/readme/nav-ai-en.svg" alt="AI workflow" width="118" height="30"></a>
</p>

<p>
<a href="projects/README.md#dsp-transceiver-research"><img src="assets/readme/research-dsp-en.svg" alt="DSP transceiver research — Detector RTL design and RFSoC board validation" width="410"></a>
<a href="projects/high-speed-interface-research/"><img src="assets/readme/research-interface-en.svg" alt="LPDDR / USB interfaces — TX circuits · TX/RX models · Silicon measurements" width="410"></a>
</p>

## DSP transceiver research

<p>
<a href="projects/pam4-mlsd-thesis/"><img src="assets/readme/status-thesis-en.svg" alt="Thesis · In progress" width="166" height="30"></a>
<a href="projects/dp-smm-journal/"><img src="assets/readme/status-journal-en.svg" alt="Journal · In progress" width="174" height="30"></a>
<a href="projects/zcu208-pam4-dsp-portfolio/"><img src="assets/readme/status-asscc-en.svg" alt="A-SSCC 2026 · Accepted" width="194" height="30"></a>
</p>

**My role and key result:** Implemented PAM4 transceiver DSP and detector RTL and [validated receiver performance on an RFSoC board](projects/zcu208-pam4-dsp-portfolio/docs/validation.md#isi-보드를-통한-rfsoc-측정). The resulting [A-SSCC 2026 paper](https://epapers2.org/asscc2026/ESR/paper_details.php?paper_id=1351) was accepted.

<details>
<summary><strong>View research · Thesis / Journal preparation / A-SSCC / AI assistance</strong></summary>

The ongoing [master's thesis](projects/pam4-mlsd-thesis/) compares DS-SBM and DP-SMM and evaluates candidate retention. The [journal project](projects/dp-smm-journal/) develops DP-SMM, and the [A-SSCC study](projects/zcu208-pam4-dsp-portfolio/) validates a DS-SBM RFSoC transceiver.

### Master's thesis | DS-SBM and DP-SMM comparison (in progress)

Compared the [signal paths, candidate retention and frame-boundary updates](projects/pam4-mlsd-thesis/docs/architecture.md) of the two architectures. Identical-input R=1/R=2 tests within DP-SMM evaluate [how matrix-path retention affects error counts](projects/pam4-mlsd-thesis/docs/validation.md#동일-입력에서의-후보-보존-효과).

[Thesis project](projects/pam4-mlsd-thesis/) · [Architecture comparison](projects/pam4-mlsd-thesis/docs/architecture.md) · [Model and RTL results](projects/pam4-mlsd-thesis/docs/validation.md)

### Journal preparation | DP-SMM design and verification (in progress)

Extended the DS-SBM segment-matrix architecture to retain [two path proposals per entry](projects/dp-smm-journal/docs/architecture.md) through matrix composition and rescore them using actual symbol histories. Two accumulated-metric survivors per state carry alternative paths into the next frame. Verified the [RTL against a reference model](projects/dp-smm-journal/docs/validation.md) and completed FPGA place and route; board measurements are planned with a **21-tap RX FFE + DP-SMM** receiver.

**A patent application for DP-SMM is in preparation.**

[DP-SMM journal project](projects/dp-smm-journal/) · [DS-SBM / DP-SMM comparison figure](projects/dp-smm-journal/#ds-sbm에서-확장한-점) · [RTL verification and FPGA implementation](projects/dp-smm-journal/docs/validation.md)

### A-SSCC 2026 | DS-SBM-based PAM4 transceiver DSP

Integrated **[32-lane PAM4 DSP](projects/zcu208-pam4-dsp-portfolio/docs/architecture.md)**, TX FIR, RX 21-tap FIR and DS-SBM RS-MLSD with the ZCU208 RFSoC. The [Vivado / Vitis flow](projects/zcu208-pam4-dsp-portfolio/docs/vitis-bringup.md) covers JTAG programming, CLK104 / RFDC initialization and coefficient updates. Measurement signals pass from the DAC through an [ISI board](projects/zcu208-pam4-dsp-portfolio/docs/validation.md#isi-보드를-통한-rfsoc-측정) to ADC capture.

[A-SSCC project](projects/zcu208-pam4-dsp-portfolio/) · [Design decisions](projects/zcu208-pam4-dsp-portfolio/docs/design-decisions.md) · [Vitis / FPGA bring-up](projects/zcu208-pam4-dsp-portfolio/docs/vitis-bringup.md) · [Measurement and implementation results](projects/zcu208-pam4-dsp-portfolio/docs/validation.md)

<a id="ai-assistance"></a>

### AI assistance | RTL and measurement automation with MATLAB MCP

I used AI to help develop RTL and testbenches, plus automation code connecting ZCU208 coefficient settings, data collection and BER analysis.

[Toolbox roles and automation harness diagrams](docs/ai-assisted-dsp-workflow.en.md)

</details>

<a id="lpddr--usb-research"></a>

## LPDDR / USB interface research

<p>
<a href="projects/high-speed-interface-research/docs/lpddr-tx-circuit-verification.md" title="LPDDR 15.6 Gb/s TX circuit design and verification"><img src="assets/readme/nav-lpddr-15p6.svg" alt="LPDDR 15.6 Gb/s TX circuit design and verification" width="147" height="30"></a>
<a href="projects/high-speed-interface-research/docs/lpddr-combo.md" title="LPDDR Combo PHY architecture, TX design, modeling and silicon validation"><img src="assets/readme/nav-lpddr-combo.svg" alt="LPDDR Combo PHY architecture, TX design, modeling and silicon validation" width="132" height="30"></a>
<a href="projects/high-speed-interface-research/docs/usb-tx-modeling.md" title="USB TX modeling and RTL verification"><img src="assets/readme/nav-usb-tx.svg" alt="USB TX modeling and RTL verification" width="90" height="30"></a>
<a href="projects/high-speed-interface-research/docs/usb-rx-ctle-modeling.md" title="USB RX CTLE modeling"><img src="assets/readme/nav-usb-rx.svg" alt="USB RX CTLE modeling" width="90" height="30"></a>
<a href="projects/high-speed-interface-research/docs/pam3-differential-measurement.md" title="USB TX silicon measurements, differential PAM-3 and FFE verification"><img src="assets/readme/nav-usb-tx-measurement-en.svg" alt="USB TX silicon measurements, differential PAM-3 and FFE verification" width="174" height="30"></a>
</p>

- **LPDDR:** Designed a [15.6-Gb/s low-voltage TX circuit](projects/high-speed-interface-research/docs/lpddr-tx-circuit-verification.md) and verified it with post-layout simulation. Participated in measurements of a [28-nm Combo PHY](projects/high-speed-interface-research/docs/lpddr-combo.md) at 14 Gb/s/pin.
- **USB:** Designed and verified [TX RTL](projects/high-speed-interface-research/docs/usb-tx-modeling.md) and [RX CTLE behavioral models](projects/high-speed-interface-research/docs/usb-rx-ctle-modeling.md), and participated in [differential PAM-3 measurements of a 32-Gb/s TX chip](projects/high-speed-interface-research/docs/pam3-differential-measurement.md).

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

| Area | Evaluation and verification | Details |
|---|---|---|
| RFSoC measurements | ZCU208 DAC → ISI board → ADC capture; BER evaluation using PL PRBS checker counts | [ISI-board measurements / BER](projects/zcu208-pam4-dsp-portfolio/docs/validation.md#isi-보드를-통한-rfsoc-측정) |
| FPGA implementation / bring-up | Resource and timing checks; JTAG launch, clock / RFDC initialization and coefficient updates | [Implementation results](projects/zcu208-pam4-dsp-portfolio/docs/validation.md#fpga-자원타이밍)<br>[Vitis bring-up](projects/zcu208-pam4-dsp-portfolio/docs/vitis-bringup.md) |
| Measurement automation | Condition-specific app builds and execution, UART capture and storage, and Python BER analysis of ILA counters | [Measurement harness diagram](docs/ai-assisted-dsp-workflow.en.md#zcu208-measurement-harness) |

<a id="28-nm-silicon-validation-with-pcb-design-and-hfss-analysis"></a>

### 28-nm chip measurements / PCB and HFSS analysis

| Area | Evaluation and verification | Details |
|---|---|---|
| PCB / HFSS | LPDDR measurement-PCB design and transmission analysis; USB TX board ground and power-path review | [PCB design / HFSS analysis](projects/high-speed-interface-research/docs/pcb-hfss-verification.md) |
| 28-nm silicon measurements | LPDDR TX eye / RX Shmoo and USB differential PAM-3 upper / lower eyes before and after FFE | [Eye / Shmoo](projects/high-speed-interface-research/docs/verification-figures.md)<br>[PAM-3 measurements / FFE](projects/high-speed-interface-research/docs/pam3-differential-measurement.md) |
| Measurement automation | Power-supply / BERT / I2C control, voltage / timing sweeps, early error termination, boundary search and CSV logging | [Equipment / control](projects/high-speed-interface-research/docs/measurement-equipment.md) |

## Research publications

| Research | Paper links |
|---|---|
| DSP / MLSD | [A-SSCC 2026 · RFSoC-verified PAM4 transceiver](https://epapers2.org/asscc2026/ESR/paper_details.php?paper_id=1351) |
| LPDDR | [ICEIC 2025 · NRZ TX](https://doi.org/10.1109/ICEIC64972.2025.10879746) · [A-SSCC 2026 · Combo PHY](https://epapers2.org/asscc2026/ESR/paper_details.php?paper_id=1141) |
| USB PAM-3 | [SMACD 2025 · TX model](https://doi.org/10.1109/SMACD65553.2025.11092283) · [SMACD 2025 · RX model](https://doi.org/10.1109/SMACD65553.2025.11092233) · [IEEE TVLSI 2026 · fabricated TX](https://doi.org/10.1109/TVLSI.2026.3701343) |

Both A-SSCC 2026 papers are accepted, with presentations forthcoming as of 2026-10-07. [Full publication list](docs/publications.md)

---

[Repository map](docs/repository-map.md) · [Verification status](docs/validation-status.md) · [Glossary](docs/glossary.md)

<!-- page-navigation:bottom -->
<p>
  <a href="#page-top" title="Back to top"><img src="assets/readme/nav-top-en.svg" alt="Back to top" width="124" height="30"></a>
</p>
<!-- /page-navigation:bottom -->
