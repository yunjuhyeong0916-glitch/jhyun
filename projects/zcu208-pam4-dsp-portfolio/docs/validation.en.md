<a id="page-top"></a>

<p align="right"><a href="validation.md#page-top"><img src="../../../assets/readme/nav-ko.svg" alt="한국어" width="96" height="30"></a></p>

# DS-SBM | Board measurements and FPGA results

[Home](https://github.com/yunjuhyeong0916-glitch/jhyun/blob/main/README.en.md#page-top) · [Project](../README.en.md#page-top) · [Detailed notes (Korean)](validation.md#page-top)

<a id="board-measurements"></a>

## RFSoC board measurements

![ZCU208, XM655, ISI board and the total path response](../assets/mlsd_paper_isi_measurement_setup.png)

The DAC output passes through the ISI board and returns to the ADC and RX DSP. At **4 GS/s**, this path carries **uncoded PAM4 at 8 Gb/s**. Total path loss is estimated at **about 41 dB at 2 GHz**.

| Pattern | Reported BER |
|---|---:|
| PRBS7 | **< 10⁻⁷** |
| PRBS15 | **< 2×10⁻⁶** |

Each result uses the selected PR response for that pattern. The receiver is a 21-tap FFE followed by a 3-tap PR filter and DS-SBM. [A-SSCC Fig. 5](https://epapers2.org/asscc2026/ESR/paper_details.php?paper_id=1351)

![PRBS7 and PRBS15 BER contours across PR settings](../assets/mlsd_paper_measured_ber_contours.png)

The axes represent the two post-cursor PR settings; color represents log₁₀(BER).

<a id="fpga-resources-and-timing"></a>
<a id="detector-resources"></a>

## Detector resource comparison

| Detector | LUT | FF |
|---|---:|---:|
| RS-ACS | 258k | 80k |
| **DS-SBM** | **166k** | **62k** |
| **Reduction** | **35.7%** | **22.5%** |

These values cover the detector. [Detailed comparison (Korean)](https://github.com/yunjuhyeong0916-glitch/pam4-mlsd-research/blob/main/projects/pam4-mlsd-thesis/docs/validation.md#검출기-단독-자원-비교)

## Complete transceiver implementation

![FPGA placement and TX/RX resource distribution](../assets/mlsd_paper_fpga_resources_layout.jpg)

| LUT | FF | DSP | BRAM tiles |
|---:|---:|---:|---:|
| 189,108 | 188,846 | 950 | 24.5 |

The complete-transceiver figures are from the 2026-06-14 placed result. The 2026-06-29 post-route physopt report gives **WNS +0.083 ns, WHS +0.010 ns and TNS/THS 0**, with zero routing errors.

[Capture, replay and statistical analysis (Korean)](capture-analysis.md#page-top) · [Vitis control](vitis-bringup.en.md#page-top)

---

[Home](https://github.com/yunjuhyeong0916-glitch/jhyun/blob/main/README.en.md#page-top) · [Project](../README.en.md#page-top) · [Detailed notes (Korean)](validation.md#page-top) · [Back to top](#page-top)
