# Juhyeong Yun | Hardware Design & Verification

I'm Juhyeong Yun. My research covers **high-speed interfaces based on JEDEC [LPDDR](projects/high-speed-interface-research/docs/lpddr.md) and [USB4 Gen4](projects/high-speed-interface-research/docs/usb4-pam3.md) specifications** and **[DSP-based transceivers](projects/) for ultra-high-speed communication**.

I design [circuits](projects/high-speed-interface-research/docs/lpddr-tx-circuit-verification.md) and [systems](projects/zcu208-pam4-dsp-portfolio/docs/architecture.md) that compensate for channel loss and ISI to support reliable data transmission at high speeds.

In line with current design trends, I use [AI](docs/ai-assisted-dsp-workflow.en.md) to assist with RTL and testbench development and with verification and measurement automation. My automation scripts allow checks to be repeated under the same conditions after design changes.

[DSP / FPGA](#dsp-transceiver-research) · [LPDDR / USB interfaces](#lpddr--usb-interface-research) · [Verification](#measurement--verification) · [Papers](#research-publications) · [GitHub profile](https://github.com/yunjuhyeong0916-glitch) · [한국어](README.md)

## DSP transceiver research

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

<details>
<summary><strong>View design and verification · TX / RX / PCB / HFSS / Measurements</strong></summary>

| Research | Design and verification work | Key results |
|---|---|---|
| [LPDDR](projects/high-speed-interface-research/docs/lpddr.md) | [TX circuits](projects/high-speed-interface-research/docs/lpddr-tx-circuit-verification.md), [TX Verilog models](projects/high-speed-interface-research/docs/lpddr-tx-modeling.md), [PCB / HFSS](projects/high-speed-interface-research/docs/pcb-hfss-verification.md) | 14 Gb/s/pin Combo PHY; TX eye 0.41 UI / 65.3 mV; RX margin 0.25 UI / 25 mV |
| [USB&nbsp;PAM&#8209;3](projects/high-speed-interface-research/docs/usb4-pam3.md) | [TX models / RTL](projects/high-speed-interface-research/docs/usb-tx-modeling.md), [RX CTLE models](projects/high-speed-interface-research/docs/usb-rx-ctle-modeling.md), [Differential PAM-3 measurements / FFE](projects/high-speed-interface-research/docs/pam3-differential-measurement.md) | 32 Gb/s, PRBS15, 17.3-dB loss at 10.24 GHz<br>Upper eye: 11.19 ps / 21.16 mV<br>Lower eye: 11.67 ps / 19.80 mV |

[PCB / HFSS](projects/high-speed-interface-research/docs/pcb-hfss-verification.md) · [LPDDR / USB interface research](projects/high-speed-interface-research/)

</details>

## Measurement / verification

### FPGA measurement and validation

| Area | Evaluation and verification | Details |
|---|---|---|
| RFSoC measurements | ZCU208 DAC → ISI board → ADC capture; BER evaluation using PL PRBS checker counts | [ISI-board measurements / BER](projects/zcu208-pam4-dsp-portfolio/docs/validation.md#isi-보드를-통한-rfsoc-측정) |
| FPGA implementation / bring-up | Resource and timing checks; JTAG launch, clock / RFDC initialization and coefficient updates | [Implementation results](projects/zcu208-pam4-dsp-portfolio/docs/validation.md#fpga-자원타이밍)<br>[Vitis bring-up](projects/zcu208-pam4-dsp-portfolio/docs/vitis-bringup.md) |
| Measurement automation | Condition-specific app builds and execution, UART capture and storage, and Python BER analysis of ILA counters | [Measurement harness diagram](docs/ai-assisted-dsp-workflow.en.md#zcu208-measurement-harness) |

### 28-nm silicon validation with PCB design and HFSS analysis

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
