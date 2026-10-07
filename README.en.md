# Juhyeong Yun | Hardware Design & Verification

**High-speed interfaces · DSP · RTL/FPGA**

Design and verification of PAM4 transceiver DSP, low-voltage LPDDR transmitters and USB PAM-3 interfaces. Work spans circuits, behavioral models and RTL, with FPGA and silicon evaluation.

[DSP / FPGA](#dsp-transceiver-research) · [LPDDR / USB](#lpddr--usb-research) · [Verification](#measurement--verification) · [Papers](#research-publications) · [한국어](README.md)

## DSP transceiver research

Two projects: the A-SSCC RFSoC transceiver study and ongoing MLSD RTL verification for a master's thesis.

### A-SSCC 2026 | ZCU208 PAM4 transceiver DSP

Integrated **32-lane PAM4 DSP**, TX FIR, RX 21-tap FIR and reduced-state MLSD with RFSoC. The Vivado / Vitis flow covers JTAG programming, CLK104 / RFDC initialization and coefficient updates. Measurement signals pass from the DAC through an ISI board to ADC capture.

[A-SSCC project](projects/zcu208-pam4-dsp-portfolio/) · [Design decisions](projects/zcu208-pam4-dsp-portfolio/docs/design-decisions.md) · [Measurement and implementation results](projects/zcu208-pam4-dsp-portfolio/docs/validation.md)

### Master's thesis | PAM4 MLSD RTL design and verification

Ongoing verification of MLSD metric calculation and full-path recovery under residual ISI. In **October 2026**, metric checks and Python reference recovery passed on synthetic channels; the full RTL adapter's output mismatch remains under investigation.

[Thesis project](projects/pam4-mlsd-thesis/) · [Architecture and scope](projects/pam4-mlsd-thesis/docs/architecture.md) · [October verification](projects/pam4-mlsd-thesis/docs/validation.md)

## LPDDR / USB research

| Research | Design and verification work | Joint silicon results |
|---|---|---|
| [LPDDR](projects/high-speed-interface-research/docs/lpddr.md) | [TX circuits](projects/high-speed-interface-research/docs/lpddr-tx-circuit-verification.md), [TX Verilog models](projects/high-speed-interface-research/docs/lpddr-tx-modeling.md), PCB / HFSS | 14 Gb/s/pin Combo PHY; TX eye 0.41 UI / 65.3 mV; RX margin 0.25 UI / 25 mV |
| [USB PAM-3](projects/high-speed-interface-research/docs/usb4-pam3.md) | [TX models / RTL](projects/high-speed-interface-research/docs/usb-tx-modeling.md), [RX CTLE models](projects/high-speed-interface-research/docs/usb-rx-ctle-modeling.md), differential-signal evaluation | 28-nm, 32-Gb/s TX with 150-preset four-tap FFE |

[PCB / HFSS](projects/high-speed-interface-research/docs/pcb-hfss-verification.md) · [LPDDR / USB projects](projects/high-speed-interface-research/)

## Measurement / verification

Eye measurements with 86100D / 86118A and stimulus generation with M8195A AWG. MP1800A BERT, E3631A and I2C control support voltage / timing sweeps, early error termination, boundary search and CSV collection.

[Equipment and automation](projects/high-speed-interface-research/docs/measurement-equipment.md) · [Eye / Shmoo figures](projects/high-speed-interface-research/docs/verification-figures.md)

| Project | Item | Result and conditions |
|---|---|---|
| A-SSCC | FPGA timing | WNS +0.083 ns / WHS +0.010 ns; existing post-route physopt report dated 2026-06-29 |
| Thesis / shared RTL baseline | Three FIR tests | PASS; output equivalence under existing testbenches, 2026-09-09 |
| Thesis | MLSD metric verification | PASS; two synthetic channels, RTL matrices and Python recovery, 2026-10-07 |
| Thesis | Full MLSD adapter | FAIL; output mismatch, data / valid alignment under review, 2026-10-07 |

[A-SSCC measurements and implementation](projects/zcu208-pam4-dsp-portfolio/docs/validation.md) · [Thesis verification](projects/pam4-mlsd-thesis/docs/validation.md)

## Research publications

| Research | Paper links |
|---|---|
| DSP / MLSD | [A-SSCC 2026 · RFSoC-verified PAM4 transceiver](https://epapers2.org/asscc2026/ESR/paper_details.php?paper_id=1351) |
| LPDDR | [ICEIC 2025 · NRZ TX](https://doi.org/10.1109/ICEIC64972.2025.10879746) · [A-SSCC 2026 · Combo PHY](https://epapers2.org/asscc2026/ESR/paper_details.php?paper_id=1141) |
| USB PAM-3 | [SMACD 2025 · TX model](https://doi.org/10.1109/SMACD65553.2025.11092283) · [SMACD 2025 · RX model](https://doi.org/10.1109/SMACD65553.2025.11092233) · [IEEE TVLSI 2026 · fabricated TX](https://doi.org/10.1109/TVLSI.2026.3701343) |

Both A-SSCC 2026 papers are accepted, with presentations forthcoming as of 2026-10-07. [Full publication list](docs/publications.md)

---

[Repository map](docs/repository-map.md) · [Verification status](docs/validation-status.md) · [Glossary](docs/glossary.md)
