<a id="page-top"></a>

<p align="right"><a href="usb-rx-ctle-modeling.md#page-top"><img src="../../../assets/readme/nav-ko.svg" alt="한국어" width="96" height="30"></a></p>

# USB RX CTLE | Operating point and compensation

[Home](https://github.com/yunjuhyeong0916-glitch/jhyun/blob/main/README.en.md#page-top) · [Project](usb4-pam3.en.md#page-top) · [Detailed notes (Korean)](usb-rx-ctle-modeling.md#page-top)

I modeled the CTLE and verified its integration into the RX. Fixing the bias and input common-mode condition before sweeping R/C made it possible to compare frequency response without changing several operating-point variables at once.

<a id="usb-rx-ctle-result"></a>

## CTLE input/output comparison

<table>
<thead><tr><th align="center" width="50%">CTLE input</th><th align="center" width="50%">CTLE output</th></tr></thead>
<tbody><tr>
<td align="center" valign="top"><a href="../assets/usb_rx_ctle_input_eye_ffe_off.png"><img src="../assets/usb_rx_ctle_input_eye_ffe_off.png" alt="Channel-distorted PAM-3 at the CTLE input" width="330"></a></td>
<td align="center" valign="top"><a href="../assets/usb_rx_ctle_output_eye_ffe_off.png"><img src="../assets/usb_rx_ctle_output_eye_ffe_off.png" alt="PAM-3 after CTLE compensation" width="330"></a></td>
</tr></tbody>
</table>

**Conditions:** scrambled PAM-3 data, TX FFE off, selected CTLE setting in the integrated model.

## Design decisions

I adjusted the XMODEL device operating point and RZ/CZ controls, compared AC responses and checked middle-level stability. Connecting the CTLE to the sampler also required checking load and common-mode conditions; the standalone 850-mV common-mode setting became about 700 mV in RX integration.

The related **25.6-GBaud/lane RX model** includes CTLE, DFE and CDR. My contribution covers CTLE modeling and integrated RX verification. [SMACD RX model paper](https://doi.org/10.1109/SMACD65553.2025.11092233)

[TX modeling](usb-tx-modeling.en.md#page-top) · [TX silicon measurements](pam3-differential-measurement.en.md#page-top)

---

[Home](https://github.com/yunjuhyeong0916-glitch/jhyun/blob/main/README.en.md#page-top) · [Project](usb4-pam3.en.md#page-top) · [Detailed notes (Korean)](usb-rx-ctle-modeling.md#page-top) · [Back to top](#page-top)
