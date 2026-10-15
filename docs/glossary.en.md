<a id="page-top"></a>

<p align="right"><a href="glossary.md#page-top"><img src="../assets/readme/nav-ko.svg" alt="한국어" width="87" height="30"></a></p>

# Term guide | High-speed interfaces and DSP

[Documents](README.en.md#page-top) · [CV](profile.en.md#page-top) · [Home](../README.en.md#page-top)

Start with **[PAM signaling](concepts/pam-signaling.en.md#page-top) → [ISI and equalization](concepts/equalization.en.md#page-top) → [MLSD](concepts/mlsd.en.md#page-top)** to follow a signal from representation to detection. Continue with [RTL and FPGA](concepts/hardware-workflow.en.md#page-top) for implementation or [Eye, BER and Shmoo](concepts/measurements.en.md#page-top) for results.

## Read by topic

- **[MLSD](concepts/mlsd.en.md#page-top):** Recovering data from a sequence of observations
- **[PAM4·PAM-3·NRZ](concepts/pam-signaling.en.md#page-top):** Signal levels, bit rate, symbol rate and sample rate
- **[ISI·FFE·CTLE·DFE](concepts/equalization.en.md#page-top):** Why symbols overlap and how equalizers help
- **[DSP·RTL·FPGA·RFSoC](concepts/hardware-workflow.en.md#page-top):** From signal-processing algorithms to board evaluation
- **[LPDDR·USB4·PHY](concepts/interfaces.en.md#page-top):** Interface circuits, boards and signal integrity
- **[Eye·BER·Shmoo](concepts/measurements.en.md#page-top):** Reading waveforms, bit errors and operating margins

## Quick definitions

| Term | Meaning in this portfolio |
|---|---|
| [PAM4](concepts/pam-signaling.en.md#term-pam4) | Four-level signaling; two bits per symbol. |
| [LPDDR](concepts/interfaces.en.md#term-lpddr) | Low-power memory-interface standards; TX and Combo PHY work here. |
| [PAM-3](concepts/pam-signaling.en.md#term-pam3) | Three-level signaling used in the USB-related models and TX work. |
| [Eye opening / timing opening](concepts/measurements.en.md#term-eye) | Waveform opening / timing range meeting a specified error criterion. |
| [FFE / CTLE / DFE](concepts/equalization.en.md#page-top) | Weighted signal combination / continuous-time equalization / decision feedback. |
| [ZQ calibration](concepts/interfaces.en.md#term-zq) | Calibration of transmitter output impedance. |
| [AWG / BERT](concepts/measurements.en.md#term-equipment) | Arbitrary waveform generator / bit-error-ratio test equipment. |
| [Shmoo](concepts/measurements.en.md#term-shmoo) | An operating-region map across test conditions. |
| [HFSS / S-parameter](concepts/interfaces.en.md#term-si-pi) | Electromagnetic analysis software / frequency-dependent reflection and transmission. |
| [DSP](concepts/hardware-workflow.en.md#term-dsp) | Digital operations for signal compensation and detection. |
| [RTL](concepts/hardware-workflow.en.md#term-rtl) | A hardware description of register storage, arithmetic and control. |
| [FPGA / RFSoC](concepts/hardware-workflow.en.md#term-fpga-rfsoc) | Configurable circuit hardware / a SoC integrating processors, programmable logic and converters. |
| [PS / PL](concepts/hardware-workflow.en.md#term-ps-pl) | Processor subsystem / programmable logic. PS software configures PL modes and coefficients here. |
| [Vivado / Vitis](concepts/hardware-workflow.en.md#term-tools) | FPGA design and debugging / PS application and platform development in this project. |
| [FIR](concepts/equalization.en.md#term-fir-taps) | A filter forming a weighted sum of samples over a finite set of delays. |
| [MLSD](concepts/mlsd.en.md#page-top) | Detection using a sequence of received observations. |
| [GS/s](concepts/pam-signaling.en.md#term-rates) | Billions of samples per second. |
| [PRBS](concepts/measurements.en.md#term-ber) | A reproducible pseudo-random binary test pattern. |
| [Testbench](concepts/hardware-workflow.en.md#term-verification) | Code supplying inputs and checking circuit behavior. |
| [ILA](concepts/hardware-workflow.en.md#term-tools) | A facility for observing internal FPGA signals. |
| [ISI](concepts/equalization.en.md#term-isi) | One symbol influencing observations of other symbols. |
| [BER](concepts/measurements.en.md#term-ber) | Bit errors divided by compared bits. |
| [PHY / TX / RX](concepts/interfaces.en.md#term-phy) | Physical layer / transmitter / receiver. |
| [SI / PI](concepts/interfaces.en.md#term-si-pi) | Signal integrity / power integrity. |
| [NDP](concepts/interfaces.en.md#term-ndp) | Near-display processing in the display-system research project here. |

<details>
<summary>More terms · implementation, boot files and detector structures</summary>

| Term | Meaning in this portfolio |
|---|---|
| XSA / BSP / ELF | Hardware handoff file / board support software / processor executable. |
| FSBL / PMUFW | First-stage boot loader / platform-management firmware. |
| [DS-SBM](concepts/mlsd.en.md#term-research) | Dual-Survivor Segmented Branch Metric-Matrix; the A-SSCC reduced-state detector. |
| [DP-SMM](concepts/mlsd.en.md#term-research) | Dual-Path Segmented Metric-Matrix; the follow-up detector retaining two paths per matrix element. |
| [PR target](concepts/equalization.en.md#term-pr) | A partial-response target used to predict observations from candidate symbols. |
| [BM / PM](concepts/mlsd.en.md#term-metrics) | Branch mismatch cost / accumulated path cost. |
| [Survivor](concepts/mlsd.en.md#term-metrics) | Candidate information retained for subsequent detection steps. |
| [II](concepts/hardware-workflow.en.md#term-parallelism) | Initiation interval: minimum clock interval between accepted input groups. |
| [32-symbol parallel processing (32-lane)](concepts/hardware-workflow.en.md#term-parallelism) | The number of parallel data items processed per clock here. |
| [WNS / TNS](concepts/hardware-workflow.en.md#term-timing) | Worst slack / sum of negative slack in a timing report. |

</details>

---

[Documents](README.en.md#page-top) · [CV](profile.en.md#page-top) · [Home](../README.en.md#page-top) · [Back to top](#page-top)
