<a id="page-top"></a>

<p align="right"><a href="pcb-hfss-verification.md#page-top"><img src="../../../assets/readme/nav-ko.svg" alt="한국어" width="96" height="30"></a></p>

# PCB design and HFSS analysis

[Home](https://github.com/yunjuhyeong0916-glitch/jhyun/blob/main/README.en.md#page-top) · [Project](../README.en.md#page-top) · [Detailed notes (Korean)](pcb-hfss-verification.md#page-top)

I designed the **LPDDR measurement PCB’s circuit, placement and routing** and analyzed its transmission characteristics in HFSS. For the USB TX board, I reviewed GND vias, power delivery and connector clearance, and participated in chip evaluation.

## Board and electromagnetic model

| Measurement PCB | Pad-to-connector HFSS model |
|---|---|
| <img src="../assets/pcb_hfss_lpddr_board_photo.png" alt="Fabricated LPDDR measurement PCB" width="280"> | <img src="../assets/pcb_hfss_lpddr_model.jpg" alt="LPDDR signal routing, ground and vias in HFSS" width="280"> |

The HFSS analysis workflow imports PADS ODB++, checks stackup/materials/thickness and ports/reference ground, and validates the model. I examined frequency-dependent loss and notches to review placement and routing.

## Transmission results

The LPDDR model gives **−1.58 to −2.14 dB across six transmission paths at 6.4 GHz**. In the USB model, loss at 12.8 GHz is about **1.11 dB for CLK** and **1.25 dB for DATA**. These are HFSS electromagnetic-analysis results.

![LPDDR HFSS transmission markers at 6.4 GHz](../assets/pcb_hfss_lpddr_sparams_6p4ghz.jpg)

[LPDDR Combo silicon results](lpddr-combo.en.md#lpddr-combo-result) · [USB differential measurements](pam3-differential-measurement.en.md#page-top)

---

[Home](https://github.com/yunjuhyeong0916-glitch/jhyun/blob/main/README.en.md#page-top) · [Project](../README.en.md#page-top) · [Detailed notes (Korean)](pcb-hfss-verification.md#page-top) · [Back to top](#page-top)
