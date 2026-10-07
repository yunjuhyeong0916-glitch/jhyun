# Juhyeong Yun | Hardware Design & Verification

**High-speed interfaces · DSP · RTL/FPGA**

Design and verification of PAM4 transceiver DSP, low-voltage LPDDR transmitters and USB PAM-3 interfaces. Work spans circuits, behavioral models and RTL, with FPGA and silicon evaluation.

[DSP / FPGA](#dsp-transceiver-research) · [LPDDR / USB](#lpddr--usb-research) · [Verification](#measurement--verification) · [Papers](#research-publications) · [한국어](README.md)

## DSP transceiver research

The ongoing master's thesis compares DS-SBM and DP-SMM and evaluates candidate retention. The journal project develops DP-SMM, and the A-SSCC study validates a DS-SBM RFSoC transceiver.

### Master's thesis | DS-SBM and DP-SMM comparison (in progress)

Compared the signal paths, candidate retention and frame-boundary updates of the two architectures. Identical-input R=1/R=2 tests within DP-SMM evaluate how matrix-path retention affects error counts.

[Thesis project](projects/pam4-mlsd-thesis/) · [Architecture comparison](projects/pam4-mlsd-thesis/docs/architecture.md) · [Model and RTL results](projects/pam4-mlsd-thesis/docs/validation.md)

### Journal preparation | DP-SMM design and verification (in progress)

Designed a detector that composes segment metric matrices in parallel to reduce symbol-by-symbol path-metric dependencies. Each matrix entry retains two path proposals, which are rescored using actual symbol history before final selection. RTL verification and FPGA implementation are documented; board measurements are planned.

[DP-SMM journal project](projects/dp-smm-journal/) · [Detector architecture](projects/dp-smm-journal/docs/architecture.md) · [RTL verification and FPGA implementation](projects/dp-smm-journal/docs/validation.md)

### A-SSCC 2026 | DS-SBM-based PAM4 transceiver DSP

Integrated **32-lane PAM4 DSP**, TX FIR, RX 21-tap FIR and DS-SBM RS-MLSD with the ZCU208 RFSoC. The Vivado / Vitis flow covers JTAG programming, CLK104 / RFDC initialization and coefficient updates. Measurement signals pass from the DAC through an ISI board to ADC capture.

[A-SSCC project](projects/zcu208-pam4-dsp-portfolio/) · [Design decisions](projects/zcu208-pam4-dsp-portfolio/docs/design-decisions.md) · [Measurement and implementation results](projects/zcu208-pam4-dsp-portfolio/docs/validation.md)

## LPDDR / USB research

| Research | Design and verification work | Measured chip results |
|---|---|---|
| [LPDDR](projects/high-speed-interface-research/docs/lpddr.md) | [TX circuits](projects/high-speed-interface-research/docs/lpddr-tx-circuit-verification.md), [TX Verilog models](projects/high-speed-interface-research/docs/lpddr-tx-modeling.md), [PCB / HFSS](projects/high-speed-interface-research/docs/pcb-hfss-verification.md) | 14 Gb/s/pin Combo PHY; TX eye 0.41 UI / 65.3 mV; RX margin 0.25 UI / 25 mV |
| [USB PAM-3](projects/high-speed-interface-research/docs/usb4-pam3.md) | [TX models / RTL](projects/high-speed-interface-research/docs/usb-tx-modeling.md), [RX CTLE models](projects/high-speed-interface-research/docs/usb-rx-ctle-modeling.md), differential-signal evaluation | 28-nm, 32-Gb/s TX with 150-preset four-tap FFE |

[PCB / HFSS](projects/high-speed-interface-research/docs/pcb-hfss-verification.md) · [LPDDR / USB projects](projects/high-speed-interface-research/)

## Measurement / verification

Automated voltage and timing sweeps by coordinating BERT, power-supply and I2C control. Early error termination and boundary search support Shmoo measurements, with eye observations and CSV collection used to assess operating margins.

[Equipment and automation](projects/high-speed-interface-research/docs/measurement-equipment.md) · [Eye / Shmoo figures](projects/high-speed-interface-research/docs/verification-figures.md)

[A-SSCC measurements and implementation](projects/zcu208-pam4-dsp-portfolio/docs/validation.md) · [Journal RTL verification and implementation](projects/dp-smm-journal/docs/validation.md) · [Thesis comparison results](projects/pam4-mlsd-thesis/docs/validation.md)

## Research publications

| Research | Paper links |
|---|---|
| DSP / MLSD | [A-SSCC 2026 · RFSoC-verified PAM4 transceiver](https://epapers2.org/asscc2026/ESR/paper_details.php?paper_id=1351) |
| LPDDR | [ICEIC 2025 · NRZ TX](https://doi.org/10.1109/ICEIC64972.2025.10879746) · [A-SSCC 2026 · Combo PHY](https://epapers2.org/asscc2026/ESR/paper_details.php?paper_id=1141) |
| USB PAM-3 | [SMACD 2025 · TX model](https://doi.org/10.1109/SMACD65553.2025.11092283) · [SMACD 2025 · RX model](https://doi.org/10.1109/SMACD65553.2025.11092233) · [IEEE TVLSI 2026 · fabricated TX](https://doi.org/10.1109/TVLSI.2026.3701343) |

Both A-SSCC 2026 papers are accepted, with presentations forthcoming as of 2026-10-07. [Full publication list](docs/publications.md)

---

[Repository map](docs/repository-map.md) · [Verification status](docs/validation-status.md) · [Glossary](docs/glossary.md)
