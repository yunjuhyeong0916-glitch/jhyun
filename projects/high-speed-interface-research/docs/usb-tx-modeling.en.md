<a id="page-top"></a>

<p align="right"><a href="usb-tx-modeling.md#page-top"><img src="../../../assets/readme/nav-ko.svg" alt="한국어" width="96" height="30"></a></p>

# USB TX | Logic RTL and electrical-layer modeling

[Home](https://github.com/yunjuhyeong0916-glitch/jhyun/blob/main/README.en.md#page-top) · [Project](usb4-pam3.en.md#page-top) · [Detailed notes (Korean)](usb-tx-modeling.md#page-top)

The TX model needs the encoder, scrambler, serializers and driver to agree on symbol codes and bit order. I implemented TX logic RTL/XMODEL integration, checked serializer stages and compared logic outputs after synthesis/P&R and electrical-layer integration.

<a id="usb-tx-ffe-result"></a>

## Channel-included FFE comparison

<table>
<thead><tr><th align="center" width="50%">FFE OFF · Preset 0</th><th align="center" width="50%">FFE ON · Preset 7</th></tr></thead>
<tbody><tr>
<td align="center" valign="top"><a href="../assets/usb_tx_model_channel_ffe_off.png"><img src="../assets/usb_tx_model_channel_ffe_off.png" alt="TX model eye with main tap only" width="330"></a></td>
<td align="center" valign="top"><a href="../assets/usb_tx_model_channel_ffe_preset7.png"><img src="../assets/usb_tx_model_channel_ffe_preset7.png" alt="TX model eye with pre/post-cursor compensation" width="330"></a></td>
</tr></tbody>
</table>

**Model conditions:** 25.6 GBaud, 1 UI = 39.0625 ps, VDD 1 V, tail-current setting 5 mA, channel loss 9.89 dB at 12.8 GHz. The model uses ideal current sources and manually selected coefficients.

<details>
<summary>FFE coefficients</summary>

Order: `C[-2], C[-1], C[0], C[1]`.

- **Preset 0:** `0, 0, 1, 0`
- **Preset 7:** `0, -0.05, 0.8, -0.15`

</details>

## Verification approach

Sixteen 11B7S encoders map 176 input bits to 112 PAM-3 symbols represented on a 224-bit bus. I independently calculated encoder/scrambler expectations and tracked MSB/LSB ordering through serialization. RTL, P&R netlist and electrical-layer outputs were compared using VCS and POSIM.

[SMACD TX model paper](https://doi.org/10.1109/SMACD65553.2025.11092283) · [TX silicon measurements](pam3-differential-measurement.en.md#page-top) · [RX CTLE](usb-rx-ctle-modeling.en.md#page-top)

---

[Home](https://github.com/yunjuhyeong0916-glitch/jhyun/blob/main/README.en.md#page-top) · [Project](usb4-pam3.en.md#page-top) · [Detailed notes (Korean)](usb-tx-modeling.md#page-top) · [Back to top](#page-top)
