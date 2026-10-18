<a id="page-top"></a>

<p align="right"><a href="usb4-pam3.md#page-top"><img src="../../../assets/readme/nav-ko.svg" alt="한국어" width="96" height="30"></a></p>

# USB PAM-3 | TX/RX modeling and silicon evaluation

[Home](https://github.com/yunjuhyeong0916-glitch/jhyun/blob/main/README.en.md#page-top) · [Project](../README.en.md#page-top) · [Detailed notes (Korean)](usb4-pam3.md#page-top)

I modeled and verified the **TX logic path and RX CTLE**, connected them to the transceiver model, and participated in differential measurements of the TX chip. The logic implementation covers 11B7S encoding and scrambling, followed by synthesis/P&R and electrical-layer integration.

<a id="usb-tx-top-architecture"></a>

## TX top architecture

<a href="https://github.com/yunjuhyeong0916-glitch/jhyun/blob/main/projects/high-speed-interface-research/assets/usb_pam3_paper_top_architecture.png" title="View full-size USB PAM-3 TX architecture"><img src="../assets/usb_pam3_paper_top_architecture.png" alt="USB PAM-3 TX top architecture including logic, serialization, retimer, UI delays, four-tap FFE and clock path" width="715"></a>

My contribution covers the **11B7S encoder/scrambler RTL and electrical-layer integration**. The TX routes serialized data through a retimer and UI-delay paths to the main/four-tap FFE drivers. The gray RS-FEC and pre-coder blocks are omitted in this implementation. [IEEE TVLSI Fig. 1](https://doi.org/10.1109/TVLSI.2026.3701343)

| Evaluation | Result |
|---|---|
| TX model and simulation | **40 Gb/s/lane** |
| RX integrated model and simulation | **25.6 GBaud/lane** |
| 28-nm TX silicon | **32 Gb/s**, 150-preset four-tap FFE |

[TX model and FFE comparison](usb-tx-modeling.en.md#page-top) · [RX CTLE comparison](usb-rx-ctle-modeling.en.md#page-top)

## Channel-dependent silicon evaluation

<a href="https://github.com/yunjuhyeong0916-glitch/jhyun/blob/main/projects/high-speed-interface-research/assets/pam3_measured_ffe_eye.png" title="View full-size measured PAM-3 eyes"><img src="../assets/pam3_measured_ffe_eye.png" alt="Measured PAM-3 eyes before and after FFE on the same channel" width="715"></a>

At 32 Gb/s, PRBS15 and CH3 loss of 17.3 dB at 10.24 GHz, the selected FFE preset produces upper/lower eye heights of **21.16 / 19.80 mV**. [Setup, pattern conditions and BER results](pam3-differential-measurement.en.md#page-top)

**Publications:** SMACD 2025 TX/RX models and IEEE TVLSI 2026 TX silicon paper, **co-first author**. [Publication list](../../../docs/publications.en.md#page-top)

---

[Home](https://github.com/yunjuhyeong0916-glitch/jhyun/blob/main/README.en.md#page-top) · [Project](../README.en.md#page-top) · [Detailed notes (Korean)](usb4-pam3.md#page-top) · [Back to top](#page-top)
