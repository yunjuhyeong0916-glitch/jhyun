<a id="page-top"></a>

<p align="right"><a href="hardware-workflow.md#page-top"><img src="../../assets/readme/nav-ko.svg" alt="한국어" width="87" height="30"></a></p>

# DSP, RTL, FPGA and RFSoC | From algorithm to board evaluation

[← Term guide](../glossary.en.md#page-top) · [CV](../profile.en.md#page-top) · [Home](../../README.en.md#page-top)

**DSP describes signal-processing operations, RTL describes a digital circuit, and an FPGA implements that circuit in configurable hardware.** Connecting these stages makes it possible to evaluate an algorithm using physical signals.

![Define the algorithm in a model, describe the circuit in RTL, implement it on an FPGA and evaluate signals on a board](../../assets/concepts/hardware-flow.svg)

<a id="term-dsp"></a>

## DSP: define the signal-processing operations

**DSP** (Digital Signal Processing) operates on sampled signals using digital arithmetic. The receiver here uses an [FFE](equalization.en.md#term-ffe) for compensation and [MLSD](mlsd.en.md#page-top) for sequence detection.

<a id="term-rtl"></a>

## RTL: describe arithmetic, storage and data movement

A register stores a value, and a clock provides the timing reference. **RTL** (Register-Transfer Level) specifies values held in registers and the operations and transfers performed between clock events. Verilog and SystemVerilog describe the filter and detector datapaths and control. Parallel arithmetic and pipeline alignment are part of the circuit design. [Project RTL architecture](../../projects/zcu208-pam4-dsp-portfolio/docs/architecture.en.md#page-top)

<a id="term-fpga-rfsoc"></a>

## FPGA and RFSoC: implement the circuit

An **FPGA** (Field-Programmable Gate Array) provides configurable logic and connections. An **RFSoC** integrates processor resources, programmable logic and high-speed **ADCs and DACs**. A DAC converts digital samples to an analog signal; an ADC converts an analog signal to samples. [AMD Zynq UltraScale+ RFSoC](https://www.amd.com/en/products/adaptive-socs-and-fpgas/soc/zynq-ultrascale-plus-rfsoc.html)

<a id="term-ps-pl"></a>

## PS and PL: control software and signal-processing hardware

- **PS (Processing System):** runs control software. Here it initializes clocks and converters, applies coefficients and collects data.
- **PL (Programmable Logic):** runs the implemented RTL, including filters, detection and PRBS error counting.

**ZCU208** is the RFSoC evaluation board used in this research. [Board startup and control](../../projects/zcu208-pam4-dsp-portfolio/docs/vitis-bringup.en.md#page-top)

<a id="term-tools"></a>

## Vivado, Vitis and ILA

Here, **Vivado** supports RTL simulation and FPGA implementation; **Vitis** builds and runs the PS control application. An **ILA** (Integrated Logic Analyzer) observes internal FPGA signals for debugging. [AMD embedded development flow](https://xilinx.github.io/Embedded-Design-Tutorials/docs/2022.2/build/html/docs/Introduction/ZynqMPSoC-EDT/4-build-sw-for-ps-subsystems.html)

<a id="term-verification"></a>

## Compare the model with the circuit

A **testbench** supplies inputs and checks circuit behavior. Model and RTL outputs are compared using the same inputs, followed by FPGA resource and timing checks. [Implementation and verification results](../../projects/zcu208-pam4-dsp-portfolio/docs/validation.en.md#fpga-resources-and-timing)

<a id="term-timing"></a>

<details>
<summary>Implementation metrics · WNS and TNS</summary>

**Slack** is the margin against a timing requirement. **WNS** reports the worst slack and **TNS** the sum of negative slack. These are read alongside resource usage in implementation reports.

</details>

<a id="term-parallelism"></a>

<details>
<summary>Parallel processing · 32 lanes and II</summary>

**32-symbol parallel processing (32-lane)** means processing 32 symbols together in one clock cycle here. **II (Initiation Interval)** is the minimum clock interval between accepted input groups. Data width, clock rate and II together determine throughput. [Parallel datapath](../../projects/zcu208-pam4-dsp-portfolio/docs/architecture.en.md#parallel-datapath)

</details>

## Related research

[A-SSCC FPGA project](../../projects/zcu208-pam4-dsp-portfolio/README.en.md#page-top) · [Automation harness](../ai-assisted-dsp-workflow.en.md#page-top)

---

[← Term guide](../glossary.en.md#page-top) · [CV](../profile.en.md#page-top) · [Home](../../README.en.md#page-top) · [Back to top](#page-top)
