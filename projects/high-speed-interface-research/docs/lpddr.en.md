<a id="page-top"></a>

<p align="right"><a href="lpddr.md#page-top"><img src="../../../assets/readme/nav-ko.svg" alt="한국어" width="96" height="30"></a></p>

# LPDDR interface research

[Home](https://github.com/yunjuhyeong0916-glitch/jhyun/blob/main/README.en.md#page-top) · [Project](../README.en.md#page-top) · [Detailed notes (Korean)](lpddr.md#page-top)

The work covers **15.6-Gb/s low-voltage TX circuit design** and **DQ TX circuit/behavioral modeling for an LPDDR4X/5/5X Combo PHY**.

## LPDDR 15.6 Gb/s TX

I used a main and one-UI-delayed data path for de-emphasis at a 0.5-V driver supply. Schematic/post-layout simulations show an eye-width change from **37 to 45.4 ps** and eye height from **56.5 to 75.1 mV**, at 15.6 Gb/s and 8.7-dB channel loss. TX energy is **0.76 pJ/bit**.

[Circuit architecture and FFE comparison](lpddr-tx-circuit-verification.en.md#page-top)

## LPDDR Combo PHY

The Combo PHY shares and reconfigures clock/phase resources across LPDDR4X and LPDDR5/5X modes. My role covers **DQ TX circuit design and TX Verilog behavioral modeling**, measurement PCB design/HFSS analysis and participation in chip evaluation.

At **14 Gb/s/pin with four DQs active**, the measured TX eye is **0.41 UI / 65.3 mV** and RX margin is **0.25 UI / 25 mV**.

[Combo architecture, TX model and silicon results](lpddr-combo.en.md#page-top) · [PCB and HFSS](pcb-hfss-verification.en.md#page-top)

---

[Home](https://github.com/yunjuhyeong0916-glitch/jhyun/blob/main/README.en.md#page-top) · [Project](../README.en.md#page-top) · [Detailed notes (Korean)](lpddr.md#page-top) · [Back to top](#page-top)
