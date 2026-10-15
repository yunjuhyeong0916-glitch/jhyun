<a id="page-top"></a>

<p align="right"><a href="measurement-equipment.md#page-top"><img src="../../../assets/readme/nav-ko.svg" alt="한국어" width="96" height="30"></a></p>

# Measurement equipment and automation

[Home](https://github.com/yunjuhyeong0916-glitch/jhyun/blob/main/README.en.md#page-top) · [Project](../README.en.md#page-top) · [Detailed notes (Korean)](measurement-equipment.md#page-top)

I connected input generation, waveform observation, power settings and error counts for LPDDR/USB evaluation. The automation preserves instrument conditions and measured counts with each result.

| Equipment | Role |
|---|---|
| Keysight 86100D + 86118A | Waveform and eye observation |
| Keysight M8195A | Input/clock waveforms and phase conditions |
| Anritsu MP1800A | Pattern generation and error counting |
| Keysight E3631A | Supply and reference-voltage conditions |
| Aardvark / I2C | Chip timing/register control |
| Python / PyVISA / SCPI | Instrument control and CSV logging |

## Reliable conditions before a sweep

Supply changes affect output levels, so I managed the BERT decision threshold with the supply condition and kept it separate from the RX Vref setting. For AWG waveform changes, the BIN file and sample rate are set together; oscilloscope measurements check the resulting frequency and phase.

## Shmoo automation

Early termination at failing points and bidirectional boundary searches reduce time spent away from the operating boundary. CSV records retain conditions, counts and errors for measured points; skipped points are marked unmeasured.

[LPDDR silicon results](lpddr-combo.en.md#lpddr-combo-result) · [USB measurement setup](pam3-differential-measurement.en.md#page-top) · [FPGA measurement harness](../../../docs/ai-assisted-dsp-workflow.en.md#zcu208-measurement-harness)

---

[Home](https://github.com/yunjuhyeong0916-glitch/jhyun/blob/main/README.en.md#page-top) · [Project](../README.en.md#page-top) · [Detailed notes (Korean)](measurement-equipment.md#page-top) · [Back to top](#page-top)
