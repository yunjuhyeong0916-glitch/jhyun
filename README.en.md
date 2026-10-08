# Juhyeong Yun | Hardware Design & Verification

I'm Juhyeong Yun, a researcher working on high-speed interface circuits and DSP. My current research compares DS-SBM and DP-SMM PAM4 receivers, focusing on how retaining alternative paths affects detection performance.

I focus on whether the intended behavior of a design is preserved in hardware. I compare model and RTL decisions and evaluate system behavior through FPGA implementation and board measurements.

[DSP / FPGA](#dsp-transceiver-research) · [LPDDR / USB](#lpddr--usb-research) · [Verification](#measurement--verification) · [Papers](#research-publications) · [GitHub profile](https://github.com/yunjuhyeong0916-glitch) · [한국어](README.md)

## DSP transceiver research

The ongoing master's thesis compares DS-SBM and DP-SMM and evaluates candidate retention. The journal project develops DP-SMM, and the A-SSCC study validates a DS-SBM RFSoC transceiver.

### Master's thesis | DS-SBM and DP-SMM comparison (in progress)

Compared the signal paths, candidate retention and frame-boundary updates of the two architectures. Identical-input R=1/R=2 tests within DP-SMM evaluate how matrix-path retention affects error counts.

[Thesis project](projects/pam4-mlsd-thesis/) · [Architecture comparison](projects/pam4-mlsd-thesis/docs/architecture.md) · [Model and RTL results](projects/pam4-mlsd-thesis/docs/validation.md)

### Journal preparation | DP-SMM design and verification (in progress)

Extended the DS-SBM segment-matrix architecture to retain two path proposals per entry through matrix composition and rescore them using actual symbol histories. Two accumulated-metric survivors per state carry alternative paths into the next frame. Verified the RTL against a reference model and completed FPGA place and route; board measurements are planned with a **21-tap RX FFE + DP-SMM** receiver.

**A patent application for DP-SMM is in preparation.**

[DP-SMM journal project](projects/dp-smm-journal/) · [DS-SBM / DP-SMM comparison figure](projects/dp-smm-journal/#ds-sbm에서-확장한-점) · [RTL verification and FPGA implementation](projects/dp-smm-journal/docs/validation.md)

### A-SSCC 2026 | DS-SBM-based PAM4 transceiver DSP

Integrated **32-lane PAM4 DSP**, TX FIR, RX 21-tap FIR and DS-SBM RS-MLSD with the ZCU208 RFSoC. The Vivado / Vitis flow covers JTAG programming, CLK104 / RFDC initialization and coefficient updates. Measurement signals pass from the DAC through an ISI board to ADC capture.

[A-SSCC project](projects/zcu208-pam4-dsp-portfolio/) · [Design decisions](projects/zcu208-pam4-dsp-portfolio/docs/design-decisions.md) · [Vitis / FPGA bring-up](projects/zcu208-pam4-dsp-portfolio/docs/vitis-bringup.md) · [Measurement and implementation results](projects/zcu208-pam4-dsp-portfolio/docs/validation.md)

<a id="ai-assistance"></a>

### AI assistance | RTL and measurement automation with MATLAB MCP

I used AI to help develop RTL and testbenches, plus automation code connecting ZCU208 coefficient settings, data collection and BER analysis.

[View the illustrated workflow](docs/ai-assisted-dsp-workflow.en.md)

## LPDDR / USB research

| Research | Design and verification work | Key results |
|---|---|---|
| [LPDDR](projects/high-speed-interface-research/docs/lpddr.md) | [TX circuits](projects/high-speed-interface-research/docs/lpddr-tx-circuit-verification.md), [TX Verilog models](projects/high-speed-interface-research/docs/lpddr-tx-modeling.md), [PCB / HFSS](projects/high-speed-interface-research/docs/pcb-hfss-verification.md) | 14 Gb/s/pin Combo PHY; TX eye 0.41 UI / 65.3 mV; RX margin 0.25 UI / 25 mV |
| [USB&nbsp;PAM&#8209;3](projects/high-speed-interface-research/docs/usb4-pam3.md) | [TX models / RTL](projects/high-speed-interface-research/docs/usb-tx-modeling.md), [RX CTLE models](projects/high-speed-interface-research/docs/usb-rx-ctle-modeling.md), [Differential PAM-3 measurements / FFE](projects/high-speed-interface-research/docs/pam3-differential-measurement.md) | 32 Gb/s, PRBS15, 17.3-dB loss at 10.24 GHz<br>Upper eye: 11.19 ps / 21.16 mV<br>Lower eye: 11.67 ps / 19.80 mV |

[PCB / HFSS](projects/high-speed-interface-research/docs/pcb-hfss-verification.md) · [LPDDR / USB projects](projects/high-speed-interface-research/)

## Measurement / verification

| Area | Evaluation and verification | Details |
|---|---|---|
| Master's thesis<br>(in progress) | DS-SBM / DP-SMM architecture comparison, candidate retention and RTL behavior under identical inputs | [Model / RTL comparison](projects/pam4-mlsd-thesis/docs/validation.md) |
| Journal preparation<br>(in progress) | DP-SMM reference-model / RTL checks and FPGA implementation; board measurements in preparation | [RTL / FPGA implementation](projects/dp-smm-journal/docs/validation.md) |
| RFSoC system | ADC capture after the ISI board, BER, FPGA resources and timing | [A-SSCC measurements / implementation](projects/zcu208-pam4-dsp-portfolio/docs/validation.md) |
| Waveforms / operating margins | LPDDR TX eye / RX Shmoo and differential PAM-3 upper / lower eyes before and after FFE | [Eye / Shmoo](projects/high-speed-interface-research/docs/verification-figures.md)<br>[PAM-3 measurements / FFE](projects/high-speed-interface-research/docs/pam3-differential-measurement.md) |
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
