<a id="page-top"></a>

<p align="right"><a href="usb4-pam3.md#page-top"><img src="../../../assets/readme/nav-ko.svg" alt="한국어" width="96" height="30"></a></p>

# USB PAM-3 | TX/RX modeling and silicon evaluation

[Home](https://github.com/yunjuhyeong0916-glitch/jhyun/blob/main/README.en.md#page-top) · [Project](../README.en.md#page-top) · [Detailed notes (Korean)](usb4-pam3.md#page-top)

I modeled and verified the **TX logic path and RX CTLE**, connected them to the transceiver model, and participated in differential measurements of the TX chip. The logic implementation covers 11B7S encoding and scrambling, followed by synthesis/P&R and electrical-layer integration.

| Evaluation | Result |
|---|---|
| TX model and simulation | **40 Gb/s/lane** |
| RX integrated model and simulation | **25.6 GBaud/lane** |
| 28-nm TX silicon | **32 Gb/s**, 150-preset four-tap FFE |

[TX model and FFE comparison](usb-tx-modeling.en.md#page-top) · [RX CTLE comparison](usb-rx-ctle-modeling.en.md#page-top)

## Channel-dependent silicon evaluation

![Measured PAM-3 eyes before and after FFE on the same channel](../assets/pam3_measured_ffe_eye.png)

At 32 Gb/s, PRBS15 and CH3 loss of 17.3 dB at 10.24 GHz, the selected FFE preset produces upper/lower eye heights of **21.16 / 19.80 mV**. [Setup, pattern conditions and BER results](pam3-differential-measurement.en.md#page-top)

**Publications:** SMACD 2025 TX/RX models and IEEE TVLSI 2026 TX silicon paper, **co-first author**. [Publication list](../../../docs/publications.en.md#page-top)

---

[Home](https://github.com/yunjuhyeong0916-glitch/jhyun/blob/main/README.en.md#page-top) · [Project](../README.en.md#page-top) · [Detailed notes (Korean)](usb4-pam3.md#page-top) · [Back to top](#page-top)
