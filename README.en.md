# Juhyeong Yun | High-Speed Interface Hardware Design & Verification

Circuit, modeling, RTL/FPGA and measurement work for high-speed interfaces.

[한국어](README.md) · [DSP/MLSD project](projects/zcu208-pam4-dsp-portfolio/) · [FPGA build & JTAG bring-up](projects/zcu208-pam4-dsp-portfolio/docs/fpga-bringup.md) · [LPDDR & USB research](projects/high-speed-interface-research/) · [Measurement equipment](projects/high-speed-interface-research/docs/measurement-equipment.md) · [Publications](docs/publications.md)

## Individual contribution and shared results

| Research | Direct work | Integration / joint evaluation |
|---|---|---|
| DSP transceiver | MLSD architecture and fixed-point RTL; reference-model comparison and verification paths | RFSoC datapath integration using existing RFDC IP |
| LPDDR | TX design and its schematic / post-layout verification | PCB / HFSS analysis and joint Combo PHY evaluation |
| USB PAM-3 | TX logical-layer and RX CTLE models; 11B7S / scrambler RTL synthesis, P&R and integration checks | PCB / channel work and joint fabricated-TX measurements |

The [source figures](projects/high-speed-interface-research/docs/verification-figures.md) show LPDDR simulated/measured eyes, USB FFE measurements and AWG sample-rate troubleshooting, with conditions and paper links. The [MLSD design rationale](projects/zcu208-pam4-dsp-portfolio/docs/design-decisions.md) explains residual ISI, ACS dependency, segmentation and candidate preservation. Detailed pages are in Korean.

## Featured project

**32-lane PAM4 transceiver DSP on ZCU208 RFSoC.** The project includes TX/RX FIR filters, a reduced-state MLSD detector, runtime coefficient loading, and PRBS checking/debug interfaces. The original RFDC configuration uses a 4 GS/s sample rate.

- **Implementation:** Verilog/SystemVerilog, parallel datapaths, fixed-point arithmetic and pipelines.
- **Fresh verification:** Three existing FIR equivalence testbenches passed with the published RTL in Vivado XSim 2022.2 on 2026-09-09.
- **Executable MLSD example:** On 2026-10-07, the published metric tile passed arithmetic/composition checks on two synthetic channels; Python traceback of its actual output recovered 512 levels per case. A separate full-adapter regression found an output mismatch. [Example, results and limitation](projects/zcu208-pam4-dsp-portfolio/examples/mlsd_minimal/)
- **Historical FPGA evidence:** A 2026-06-29 post-route physopt report records +0.083 ns WNS and 0.000 ns TNS under the constraints used in that run. This is not a fresh implementation of the current source snapshot or a complete CDC/I/O signoff.
- **Published material:** 26 original RTL files and three original FIR testbenches, plus MLSD example/regression testbenches, runners, design rationale, source figures and report extracts.

[Explore the project](projects/zcu208-pam4-dsp-portfolio/) · [Read the source guide](projects/zcu208-pam4-dsp-portfolio/docs/architecture.md) · [Run the FIR tests](projects/zcu208-pam4-dsp-portfolio/docs/reproduce.md)

Related paper: [A-SSCC 2026 — FPGA-verified PAM4 transceiver with DS-SBM RS-MLSD](https://epapers2.org/asscc2026/ESR/paper_details.php?paper_id=1351), **accepted for a lecture presentation** as of 2026-10-07. The [architecture guide](projects/zcu208-pam4-dsp-portfolio/docs/architecture.md#관련-논문과-공개-소스의-관계) distinguishes the paper version from the published RTL snapshot.

## LPDDR and USB: circuit, modeling and silicon evaluation

[This research section](projects/high-speed-interface-research/) covers personally designed LPDDR TX circuitry and pre-measurement verification, USB4 PAM-3 modeling and encoder/scrambler RTL, PCB/HFSS work, and shared silicon measurements. Individual contribution and joint chip results are stated separately.

The [equipment guide](projects/high-speed-interface-research/docs/measurement-equipment.md) records use of Keysight 86100D/86118A, M8195A, E3631A and Anritsu MP1800A in both projects, with channel-board, real-time oscilloscope and measurement-automation experience. The detailed research and equipment pages are in Korean.

## Research publications

| Research | Paper links |
|---|---|
| DSP transceiver / MLSD | [A-SSCC 2026: RFSoC-verified PAM4 / RS-MLSD](https://epapers2.org/asscc2026/ESR/paper_details.php?paper_id=1351) |
| LPDDR | [ICEIC 2025: low-voltage NRZ TX simulation](https://doi.org/10.1109/ICEIC64972.2025.10879746) · [A-SSCC 2026: 14-Gb/s/pin Combo PHY measurements](https://epapers2.org/asscc2026/ESR/paper_details.php?paper_id=1141) |
| USB PAM-3 | [SMACD 2025: TX model](https://doi.org/10.1109/SMACD65553.2025.11092283) · [SMACD 2025: RX model](https://doi.org/10.1109/SMACD65553.2025.11092233) · [IEEE TVLSI 2026: fabricated TX measurements](https://doi.org/10.1109/TVLSI.2026.3701343) |

The [publication index](docs/publications.md) lists full titles, venues and evidence scopes. Both A-SSCC 2026 papers are accepted for lecture presentations, with presentations forthcoming as of 2026-10-07.

## Repository map

The DSP project has two reading paths: [MLSD/RTL architecture](projects/zcu208-pam4-dsp-portfolio/docs/architecture.md) and [FPGA implementation and JTAG board bring-up](projects/zcu208-pam4-dsp-portfolio/docs/fpga-bringup.md). The bring-up guide is in Korean and covers build inputs, programming artifacts, Hardware Manager steps, and initial data-path checks. Its local artifact inventory is dated 2026-10-07; it does not establish a new board run or measured BER. [LPDDR and USB research](projects/high-speed-interface-research/) has a separate path through circuit/model work, measurement equipment and supporting papers.

| Directory | Contents |
|---|---|
| [projects/](projects/) | DSP/FPGA implementation and LPDDR/USB circuit and measurement research |
| [experiments/](experiments/) | Separate MLSD architecture-comparison and branch-centric experiments |
| [reference/](reference/) | Architecture-specific reference RTL |
| [archive/](archive/) | Earlier Vivado board-project snapshot |
| [docs/](docs/) | Navigation, path migration and verification status |

Verification results apply only to the stated project, sources, configuration and date. Older experiments have not been revalidated as part of this repository reorganization. The featured source package does not reproduce the complete board build or establish a final measured BER.
