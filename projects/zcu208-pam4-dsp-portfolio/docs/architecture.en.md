<a id="page-top"></a>

<p align="right"><a href="architecture.md#page-top"><img src="../../../assets/readme/nav-ko.svg" alt="한국어" width="96" height="30"></a></p>

# DS-SBM | Transceiver architecture

[Home](https://github.com/yunjuhyeong0916-glitch/jhyun/blob/main/README.en.md#page-top) · [Project](../README.en.md#page-top) · [Detailed notes (Korean)](architecture.md#page-top)

<a id="asscc-top-architecture"></a>

## Top architecture

<a href="https://github.com/yunjuhyeong0916-glitch/jhyun/blob/main/projects/zcu208-pam4-dsp-portfolio/assets/mlsd_paper_system_architecture.svg" title="View full-size A-SSCC PAM4 transceiver architecture"><img src="../assets/mlsd_paper_system_architecture.svg" alt="A-SSCC system architecture showing PS, PL, RF Data Converter and ISI-board connections" width="715"></a>

The system connects PS control, the PL TX/RX data paths, the RF Data Converter and the ISI board. The PS applies settings through GPIO and BRAM; the PL processes DAC transmit and ADC receive data. [A-SSCC Fig. 2, system panel](https://epapers2.org/asscc2026/ESR/paper_details.php?paper_id=1351)

<a id="parallel-datapath"></a>

## 32-symbol parallel processing

The ADC-side datapath processes **32 samples per clock at 125 MHz**, giving 4 Gsamples/s. Fixed-point arithmetic and pipeline alignment connect the filters, metrics, survivor information and output-valid timing.

<a id="design-choices"></a>

## Reduced states and segmented metrics

DS-SBM uses **four reduced states (visible states), each propagating two survivor branches**. It divides 32 symbols into eight four-symbol segments and combines their metric matrices through min-plus composition. This organizes parallel computation around the sequential dependency of symbol-by-symbol ACS updates.

RX FFE coefficients compensate the channel. The separate three-tap PR filter shapes the residual response used to predict detector observations. [Design rationale and equations (Korean)](design-decisions.md#page-top)

[Results and detector resource comparison](validation.en.md#page-top) · [PS/PL control](vitis-bringup.en.md#page-top)

---

[Home](https://github.com/yunjuhyeong0916-glitch/jhyun/blob/main/README.en.md#page-top) · [Project](../README.en.md#page-top) · [Detailed notes (Korean)](architecture.md#page-top) · [Back to top](#page-top)
