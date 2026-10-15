<a id="page-top"></a>

<p align="right"><a href="pam3-differential-measurement.md#page-top"><img src="../../../assets/readme/nav-ko.svg" alt="한국어" width="96" height="30"></a></p>

# USB PAM-3 | Differential measurements and FFE

[Home](https://github.com/yunjuhyeong0916-glitch/jhyun/blob/main/README.en.md#page-top) · [Project](usb4-pam3.en.md#page-top) · [Detailed notes (Korean)](pam3-differential-measurement.md#page-top)

**My role:** participation in differential TX silicon measurements, comparing upper/lower eyes across channel loss and FFE presets. The chip uses 28-nm CMOS and a 150-preset four-tap FFE at **32 Gb/s**.

![Eye and BER measurement setups](../assets/pam3_measurement_setup.jpeg)

The eye setup observes TXP/TXN through the channel/cable/balun path with Keysight 86100D/86118A. The BER setup uses MP1800A pattern-generation/error-detection modules. [IEEE TVLSI paper](https://doi.org/10.1109/TVLSI.2026.3701343)

<a id="pam3-ffe-result"></a>

## FFE comparison on the same channel

![Measured PAM-3 eye before and after FFE on CH3](../assets/pam3_measured_ffe_eye.png)

**Conditions:** CH3 loss 17.3 dB at 10.24 GHz, 32 Gb/s, PRBS15, scrambler on. The eye opens with main/post/second-pre weights of **0.725 / 0.250 / 0.025**.

| Pattern | Upper eye | Lower eye |
|---|---|---|
| PRBS15 | 11.19 ps / 21.16 mV | 11.67 ps / 19.80 mV |
| PRBS31 | 10.24 ps / 20.94 mV | 9.76 ps / 17.12 mV |

Both rows use CH3, scrambler on and the same FFE preset.

## BER timing opening

At BER 10⁻¹², timing opening is **0.43 UI on CH2** and **0.33 UI on CH3**. This evaluation uses scrambler off and a PRBS7-period pattern. [Paper Section V-D](https://doi.org/10.1109/TVLSI.2026.3701343)

[TX/RX model overview](usb4-pam3.en.md#page-top) · [Equipment and automation](measurement-equipment.en.md#page-top)

---

[Home](https://github.com/yunjuhyeong0916-glitch/jhyun/blob/main/README.en.md#page-top) · [Project](usb4-pam3.en.md#page-top) · [Detailed notes (Korean)](pam3-differential-measurement.md#page-top) · [Back to top](#page-top)
