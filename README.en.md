# Juhyeong Yun | High-Speed Interface RTL & FPGA Portfolio

Digital signal-processing hardware for PAM4 transceivers and MLSD detection.

[한국어](README.md) · [Featured project](projects/zcu208-pam4-dsp-portfolio/) · [FPGA build & JTAG bring-up](projects/zcu208-pam4-dsp-portfolio/docs/fpga-bringup.md) · [Verification evidence](projects/zcu208-pam4-dsp-portfolio/docs/validation.md)

## Featured project

**32-lane PAM4 transceiver DSP on ZCU208 RFSoC.** The project includes TX/RX FIR filters, a reduced-state MLSD detector, runtime coefficient loading, and PRBS checking/debug interfaces. The original RFDC configuration uses a 4 GS/s sample rate.

- **Implementation:** Verilog/SystemVerilog, parallel datapaths, fixed-point arithmetic and pipelines.
- **Fresh verification:** Three existing FIR equivalence testbenches passed with the published RTL in Vivado XSim 2022.2 on 2026-09-09.
- **Historical FPGA evidence:** A 2026-06-29 post-route physopt report records +0.083 ns WNS and 0.000 ns TNS under the constraints used in that run. This is not a fresh implementation of the current source snapshot or a complete CDC/I/O signoff.
- **Published material:** 26 RTL files, three FIR testbenches, architecture notes, a simulation runner and implementation report extracts.

[Explore the project](projects/zcu208-pam4-dsp-portfolio/) · [Read the source guide](projects/zcu208-pam4-dsp-portfolio/docs/architecture.md) · [Run the FIR tests](projects/zcu208-pam4-dsp-portfolio/docs/reproduce.md)

## Repository map

The project has two reading paths: [MLSD/RTL architecture](projects/zcu208-pam4-dsp-portfolio/docs/architecture.md) and [FPGA implementation and JTAG board bring-up](projects/zcu208-pam4-dsp-portfolio/docs/fpga-bringup.md). The bring-up guide is in Korean and covers build inputs, programming artifacts, Hardware Manager steps, and initial data-path checks. Its local artifact inventory is dated 2026-10-07; it does not establish a new board run or measured BER.

| Directory | Contents |
|---|---|
| [projects/](projects/) | Featured project and its evidence |
| [experiments/](experiments/) | Separate MLSD architecture-comparison and branch-centric experiments |
| [reference/](reference/) | Architecture-specific reference RTL |
| [archive/](archive/) | Earlier Vivado board-project snapshot |
| [docs/](docs/) | Navigation, path migration and verification status |

Verification results apply only to the stated project, sources, configuration and date. Older experiments have not been revalidated as part of this repository reorganization. The featured source package does not reproduce the complete board build or establish a final measured BER.
