<a id="page-top"></a>

<p align="right"><a href="interfaces.md#page-top"><img src="../../assets/readme/nav-ko.svg" alt="한국어" width="87" height="30"></a></p>

# LPDDR, USB4 and PHY | Interface circuits and boards

[← Term guide](../glossary.en.md#page-top) · [CV](../profile.en.md#page-top) · [Home](../../README.en.md#page-top)

**A high-speed interface connects devices using electrical signals.** This research covers LPDDR memory interfaces and USB4-family transmitter and receiver circuits and models.

<a id="term-phy"></a>

## PHY, TX and RX

The **PHY** (Physical Layer) converts data to transmitted electrical signals and recovers data from received signals. **TX** means transmitter and **RX** means receiver.

A controller manages communication operations; the PHY implements the electrical signal path and timing. **TX circuit design** in the CV refers to responsibility for the transmitter path and its verification. [TX work in the LPDDR Combo project](../../projects/high-speed-interface-research/docs/lpddr-combo.en.md#page-top)

<a id="term-lpddr"></a>

## LPDDR, JEDEC and Combo PHY

**LPDDR** (Low-Power Double Data Rate) is a family of power-conscious DRAM standards. **JEDEC** develops memory standards of this kind. [Micron LPDDR overview](https://www.micron.com/products/memory/lpddr-components) · [JEDEC](https://www.jedec.org/)

A **Combo PHY** supports multiple interface generations in one PHY. The LPDDR4X/5/5X design here selects and configures data and clock paths for each operating mode. [Generation-dependent paths and TX implementation](../../projects/high-speed-interface-research/docs/lpddr-combo.en.md#page-top)

<a id="term-usb4"></a>

## USB4 Gen4 and PAM-3

USB4 specifies communication between devices. Gen4 signaling in USB4 Version 2.0 uses [PAM-3](pam-signaling.en.md#term-pam3). The work includes TX/RX modeling and evaluation of TX silicon output signals. [USB-IF announcement](https://www.usb.org/sites/default/files/2022-10/USB-IF%20USB%2080Gbps%20Announcement_FINAL_v2.pdf) · [Related research](../../projects/high-speed-interface-research/docs/usb4-pam3.en.md#page-top)

<a id="term-zq"></a>

## ZQ calibration: adjust driver impedance

ZQ calibration adjusts transmitter output resistance toward a reference value to support signal transfer along the channel. The TX work combines impedance calibration and waveform compensation. [TX circuit design and verification](../../projects/high-speed-interface-research/docs/lpddr-tx-circuit-verification.en.md#page-top)

<a id="term-si-pi"></a>

## PCB, SI, PI and HFSS

A **PCB** connects chips, connectors and power networks. **SI** (Signal Integrity) concerns signal shape and timing. **PI** (Power Integrity) concerns the quality of power and ground delivered to circuits.

**HFSS** performs electromagnetic analysis of structures such as board interconnects. **S-parameters** describe frequency-dependent reflection and transmission. In a two-port example, `S11` describes reflection at the input and `S21` transmission from input to output. [Ansys HFSS](https://ansys.synopsys.com/products/electronics/ansys-hfss) · [Reflection and transmission coefficients](https://optics.ansys.com/hc/en-us/articles/360042095873-Metamaterial-S-parameter-extraction)

The portfolio includes measurement-board routing, ground and power connections, and HFSS transmission analysis used to construct chip-evaluation paths. [PCB/HFSS figures and explanation](../../projects/high-speed-interface-research/docs/pcb-hfss-verification.en.md#page-top)

<a id="term-ndp"></a>

## What is the NDP project?

**NDP means Near-display processing here.** The CV entry concerns a terabit-scale light-field display system project. My role covers USB4/DisplayPort interface circuit modeling and verification. [Research projects](../profile.en.md#project-participation)

---

[← Term guide](../glossary.en.md#page-top) · [CV](../profile.en.md#page-top) · [Home](../../README.en.md#page-top) · [Back to top](#page-top)
