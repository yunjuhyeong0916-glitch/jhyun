<a id="page-top"></a>

<p align="right"><a href="vitis-bringup.md#page-top"><img src="../../../assets/readme/nav-ko.svg" alt="한국어" width="96" height="30"></a></p>

# Vitis | ZCU208 startup and PS control

[Home](https://github.com/yunjuhyeong0916-glitch/jhyun/blob/main/README.en.md#page-top) · [Project](../README.en.md#page-top) · [Detailed notes (Korean)](vitis-bringup.md#page-top)

I configured a **Cortex-A53 Standalone application** to control the PL transceiver. Vivado’s XSA supplies the hardware platform and addresses used by the Vitis 2022.2 BSP and application.

## JTAG startup

The XSCT sequence resets the system, loads the PL bitstream, runs the A53 FSBL to `XFsbl_Exit`, and downloads and runs the application ELF. The application prepares the DSP controls and coefficient memory, then initializes CLK104 and RFDC. UART status messages identify the initialization stage.

## Apply coefficients and collect data

The PS writes RX coefficients through AXI BRAM and reads them back before updating the commit sequence. The PL loader prepares a shadow bank and switches it to the active bank at a safe update point.

Received debug samples are read from capture BRAM and saved as UART CSV. BER uses the **PL PRBS checker’s lock status, checked-bit count and error count**; ILA CSV exports those counters for Python analysis.

[Board measurements](validation.en.md#board-measurements) · [Automation harness](../../../docs/ai-assisted-dsp-workflow.en.md#zcu208-measurement-harness)

---

[Home](https://github.com/yunjuhyeong0916-glitch/jhyun/blob/main/README.en.md#page-top) · [Project](../README.en.md#page-top) · [Detailed notes (Korean)](vitis-bringup.md#page-top) · [Back to top](#page-top)
