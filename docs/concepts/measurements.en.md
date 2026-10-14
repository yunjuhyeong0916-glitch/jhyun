<a id="page-top"></a>

<p align="right"><a href="measurements.md"><img src="../../assets/readme/nav-ko.svg" alt="한국어" width="87" height="30"></a></p>

# Eye, BER and Shmoo | Reading measurement results

[← Term guide](../glossary.en.md) · [CV](../profile.en.md) · [Home](../../README.en.md)

**An eye diagram shows voltage and timing margins, BER counts incorrect bit decisions, and a Shmoo plot maps operation across test conditions.** They provide complementary views of a circuit or system.

<a id="term-eye"></a>

## Eye diagram: room to distinguish signal levels

Overlaying waveform segments aligned to symbol timing produces an **eye diagram**. **Eye height** helps assess vertical voltage margin; **eye width** helps assess horizontal timing margin. [Keysight eye-diagram guide](https://helpfiles.keysight.com/csg/N1930xB/Analyzing/Analyzing_Data_using_Eye_Diagrams.html)

[PAM-3](pam-signaling.en.md#term-pam3) has two eyes between its three levels, so both upper and lower eyes are examined. [LPDDR and USB chip-evaluation figures](../../projects/high-speed-interface-research/docs/verification-figures.md)

**Timing opening** refers to a timing range meeting a specified error criterion. Read the width together with its test conditions and acceptance criterion.

<a id="term-ber"></a>

## BER: how many compared bits were incorrect?

**BER (Bit Error Ratio)** is `bit errors ÷ compared bits`. For an illustrative count of ten errors in 1,000,000 bits, BER is `10⁻⁵`. [Keysight BER definition](https://helpfiles.keysight.com/csg/89600B/Webhelp/Subsystems/flexframe/content/trc_carrier_summary.htm)

A **PRBS (Pseudo-Random Binary Sequence)** is a reproducible bit pattern used to compare transmitted and recovered data. The RFSoC work calculates BER from the internal checker's error count and compared-bit count. [RFSoC measurements and BER](../../projects/zcu208-pam4-dsp-portfolio/docs/validation.md#isi-보드를-통한-rfsoc-측정)

An eye diagram observes the waveform; BER evaluates detected data. Reading both helps connect a change in signal shape to receiver behavior.

<a id="term-shmoo"></a>

## Shmoo: operating regions across conditions

A Shmoo plot varies parameters such as supply voltage and sampling time, marking pass or fail for each combination. It shows the operating region around a nominal test point. [NI Shmoo guide](https://www.ni.com/docs/en-US/bundle/ni-digital-pattern/page/shmoo-plot.html)

The LPDDR RX evaluation maps operation across voltage and timing. [LPDDR RX Shmoo figures](../../projects/high-speed-interface-research/docs/verification-figures.md)

<a id="term-equipment"></a>

## AWG, BERT and oscilloscope

- **AWG:** generates a specified waveform as receiver input.
- **BERT:** generates known bit patterns and/or compares received patterns to measure bit errors.
- **Oscilloscope:** observes voltage waveforms over time and eye diagrams.

The measurement work connects instrument control, voltage/timing sweeps and result logging. [Instrument roles and automation](../../projects/high-speed-interface-research/docs/measurement-equipment.md)

---

[← Term guide](../glossary.en.md) · [CV](../profile.en.md) · [Home](../../README.en.md) · [Back to top](#page-top)
