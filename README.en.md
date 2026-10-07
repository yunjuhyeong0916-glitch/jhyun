# Juhyeong Yun | Hardware Design & Verification

**High-speed interfaces · DSP · RTL/FPGA**

Circuit, modeling and RTL work connected to FPGA and measurement verification. This portfolio covers DSP transceiver research and LPDDR / USB PAM-3 projects, with design rationale, individual contributions and supporting evidence.

[DSP / FPGA](#dsp-transceiver-research) · [LPDDR / USB](#lpddr--usb-research) · [Verification](#measurement--verification) · [Papers](#research-publications) · [한국어](README.md)

## DSP transceiver research

A **32-lane PAM4 DSP** connected to ZCU208 RFSoC to compensate channel distortion and recover received data.

### MLSD / RTL design

Fixed-point MLSD RTL uses sequence information, with parallel structures for metric calculation, matrix composition and path recovery. The documentation connects the design choices to the published source and executable examples.

[Design rationale](projects/zcu208-pam4-dsp-portfolio/docs/design-decisions.md) · [Architecture and code](projects/zcu208-pam4-dsp-portfolio/docs/architecture.md) · [Minimal example](projects/zcu208-pam4-dsp-portfolio/examples/mlsd_minimal/)

### FPGA implementation and board bring-up

The DSP datapath integrates existing IP including RFDC. The bring-up guide covers Vivado builds, programming artifacts, JTAG download and initial clock, reset and valid-signal checks.

[FPGA build / JTAG guide](projects/zcu208-pam4-dsp-portfolio/docs/fpga-bringup.md) · [Full project](projects/zcu208-pam4-dsp-portfolio/)

## LPDDR / USB research

Personal design and verification work is stated separately from joint silicon results.

| Research | Direct work | Joint evaluation |
|---|---|---|
| [LPDDR](projects/high-speed-interface-research/docs/lpddr.md) | TX circuit design / verification; [TX Verilog modeling](projects/high-speed-interface-research/docs/lpddr-tx-modeling.md) | Combo PHY TX eye and RX margins |
| [USB PAM-3](projects/high-speed-interface-research/docs/usb4-pam3.md) | TX logical-layer / RX CTLE models; encoder / scrambler RTL | Fabricated TX differential-signal measurements |

The [LPDDR / USB research section](projects/high-speed-interface-research/) also covers PCB / HFSS channel analysis and measurement work.

## Measurement / verification

Both projects used the **86100D / 86118A sampling system, M8195A AWG, MP1800A BERT and E3631A power supply**. Equipment roles and automation examples are linked to source waveforms and instrument screens.

[Equipment and automation](projects/high-speed-interface-research/docs/measurement-equipment.md) · [Eye / Shmoo / AWG figures](projects/high-speed-interface-research/docs/verification-figures.md)

**Published RTL verification status**

| Item | Result | Scope |
|---|---|---|
| Three FIR tests | PASS · 2026-09-09 | Output equivalence under existing testbenches |
| MLSD metric example | PASS · 2026-10-07 | RTL matrix checks and Python recovery on two synthetic channels |
| Full MLSD adapter | FAIL · 2026-10-07 | Unresolved output mismatch; reproduction logs included |

FPGA timing evidence comes from an existing 2026-06-29 implementation report. Paper-version system measurements and published-source execution results are documented with their respective [evidence and limits](projects/zcu208-pam4-dsp-portfolio/docs/validation.md).

## Research publications

| Research | Paper links |
|---|---|
| DSP / MLSD | [A-SSCC 2026 · RFSoC-verified PAM4 transceiver](https://epapers2.org/asscc2026/ESR/paper_details.php?paper_id=1351) |
| LPDDR | [ICEIC 2025 · NRZ TX](https://doi.org/10.1109/ICEIC64972.2025.10879746) · [A-SSCC 2026 · Combo PHY](https://epapers2.org/asscc2026/ESR/paper_details.php?paper_id=1141) |
| USB PAM-3 | [SMACD 2025 · TX model](https://doi.org/10.1109/SMACD65553.2025.11092283) · [SMACD 2025 · RX model](https://doi.org/10.1109/SMACD65553.2025.11092233) · [IEEE TVLSI 2026 · fabricated TX](https://doi.org/10.1109/TVLSI.2026.3701343) |

The [publication index](docs/publications.md) lists full titles and evidence scopes. Both A-SSCC 2026 papers are accepted for lecture presentations, with presentations forthcoming as of 2026-10-07.

---

[Repository map](docs/repository-map.md) · [Verification status](docs/validation-status.md) · [Glossary](docs/glossary.md)

Detailed project guides are in Korean.
