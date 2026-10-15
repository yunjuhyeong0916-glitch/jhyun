<a id="page-top"></a>

<p align="right"><a href="README.md#page-top"><img src="../../assets/readme/nav-ko.svg" alt="한국어" width="96" height="30"></a></p>

# LPDDR and USB high-speed interface research

[Home](https://github.com/yunjuhyeong0916-glitch/jhyun/blob/main/README.en.md#page-top) · [Detailed notes (Korean)](README.md#page-top)

I designed and verified low-voltage LPDDR TX circuits and modeled the LPDDR Combo DQ TX path. For USB PAM-3, I implemented TX logic and RX CTLE models, verified their integration and participated in TX silicon measurements.

| Research | Design and verification | Result |
|---|---|---|
| [LPDDR 15.6 Gb/s TX](docs/lpddr-tx-circuit-verification.en.md#page-top) | TX circuit design and post-layout simulation | 15.6 Gb/s, 0.76 pJ/bit |
| [LPDDR Combo](docs/lpddr-combo.en.md#page-top) | DQ TX circuit/model, PCB/HFSS and measurement participation | 14 Gb/s/pin silicon evaluation |
| [USB TX/RX](docs/usb4-pam3.en.md#page-top) | TX logic RTL and RX CTLE models | 40-Gb/s/lane TX and 25.6-GBaud/lane RX models |
| [USB TX silicon](docs/pam3-differential-measurement.en.md#page-top) | Differential PAM-3 measurement participation | 32 Gb/s, channel-dependent FFE evaluation |

[PCB and HFSS](docs/pcb-hfss-verification.en.md#page-top) · [Equipment and automation](docs/measurement-equipment.en.md#page-top) · [Publications](../../docs/publications.en.md#page-top)

---

[Home](https://github.com/yunjuhyeong0916-glitch/jhyun/blob/main/README.en.md#page-top) · [Detailed notes (Korean)](README.md#page-top) · [Back to top](#page-top)
