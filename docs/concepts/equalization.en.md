<a id="page-top"></a>

<p align="right"><a href="equalization.md"><img src="../../assets/readme/nav-ko.svg" alt="한국어" width="87" height="30"></a></p>

# ISI and equalization | Compensating for overlapping symbols

[← Term guide](../glossary.en.md) · [CV](../profile.en.md) · [Home](../../README.en.md)

**Equalization compensates for channel distortion so that a receiver can distinguish transmitted data more reliably.**

<a id="term-isi"></a>

## One symbol can affect the next observation

Traces, connectors and cables can spread a waveform in time or create reflections. **ISI (Inter-Symbol Interference)** occurs when one symbol influences observations of other symbols. Equalization uses the channel response to reduce this effect. [MathWorks equalization overview](https://www.mathworks.com/help/comm/ug/equalization.html)

If a sample contains `the current symbol + part of a previous symbol`, its amplitude depends on the preceding data. A receiver can compensate for this relationship or exploit it in detection using [MLSD](mlsd.en.md).

<a id="term-ffe"></a>

## FFE, CTLE and DFE

**FFE (Feed-Forward Equalizer)** combines weighted signal values from several time instants. A TX FFE shapes a waveform before transmission; an RX FFE compensates received samples. [FFE documentation](https://www.mathworks.com/help/serdes/ref/serdes.ffe-system-object.html)

<a id="term-ctle"></a>

**CTLE (Continuous-Time Linear Equalizer)** adjusts gain with frequency. It can relatively boost fast-changing components attenuated by a channel. The USB RX work here includes behavioral modeling of this circuit. [CTLE documentation](https://www.mathworks.com/help/serdes/ref/serdes.ctle-system-object.html)

<a id="term-dfe"></a>

**DFE (Decision-Feedback Equalizer)** uses previously detected symbols to estimate and subtract their contribution to the current observation. Its feedback path therefore depends on earlier decisions. [DFE documentation](https://www.mathworks.com/help/serdes/ref/serdes.dfe-system-object.html)

<a id="term-fir-taps"></a>

## FIR, taps and coefficients

An **FIR (Finite Impulse Response)** filter forms a weighted sum of input samples from several time instants. Each delayed-sample contribution is a **tap**; its weight is a **coefficient**.

A `21-tap RX FFE` combines 21 sample positions for receiver equalization. The project implements this operation in [RTL](hardware-workflow.en.md#term-rtl) for parallel FPGA processing. [RX FIR implementation](../../projects/zcu208-pam4-dsp-portfolio/docs/architecture.md)

<a id="term-pr"></a>

## PR defines the response used by MLSD

A **partial-response (PR) target** describes how current and previous symbols should contribute at the detector input. Equalization shapes the response, and MLSD uses that target to predict candidate observations.

The A-SSCC DS-SBM receiver uses **RX FFE → three-tap PR FIR → MLSD**. [Implemented signal path](../../projects/zcu208-pam4-dsp-portfolio/docs/architecture.md)

## Related research

[USB TX FFE models](../../projects/high-speed-interface-research/docs/usb-tx-modeling.md) · [USB RX CTLE models](../../projects/high-speed-interface-research/docs/usb-rx-ctle-modeling.md) · [PAM4 receiver DSP](../../projects/zcu208-pam4-dsp-portfolio/docs/design-decisions.md)

---

[← Term guide](../glossary.en.md) · [CV](../profile.en.md) · [Home](../../README.en.md) · [Back to top](#page-top)
