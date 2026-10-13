<a id="page-top"></a>

<p align="right">
<a href="profile.md" title="한국어 연구 이력 보기"><img src="../assets/readme/nav-ko.svg" alt="한국어" width="87" height="30"></a>
</p>

# Juhyeong Yun | CV

<p>
  <a href="../README.en.md" title="Back to the portfolio home"><img src="../assets/readme/nav-home-en.svg" alt="Back to the portfolio home" width="86" height="30"></a>
</p>

I design and verify high-speed interface transmitter circuits and receiver DSP. My research covers **JEDEC LPDDR and USB4 Gen4 interfaces** and **DSP-based transceivers for ultra-high-speed communication**.

## Education

- **M.S. program, Electronics and Communications Engineering · Kwangwoon University** · Sep 2024–present<br>
  Coursework completed Aug 2026; registered for thesis research. **Expected graduation: Feb 2027.**
- **B.S., Electronic Convergence Engineering · Kwangwoon University** · Mar 2022–Aug 2024

## Research and design experience

### LPDDR TX circuits and Combo PHY modeling

I designed FFE using main and 1-UI-delayed paths to compensate channel loss at a low driver voltage. After DRC, LVS and parasitic extraction, **28-nm TX post-layout simulation showed 15.6 Gb/s and 0.76 pJ/bit**.

For the LPDDR4X/5/5X Combo PHY, I was responsible for **DQ TX circuit design and verification, and TX Verilog behavioral modeling**. I checked serialization, phase alignment and pre-emphasis, and participated in **joint measurements of the fabricated 14-Gb/s/pin chip incorporating the TX I designed**.

[TX circuit verification](../projects/high-speed-interface-research/docs/lpddr-tx-circuit-verification.md) · [Combo PHY contribution](../projects/high-speed-interface-research/docs/lpddr-combo.md) · [TX model](../projects/high-speed-interface-research/docs/lpddr-tx-modeling.md)

### USB4 TX and RX models, and differential signal evaluation

I connected **11B7S and scrambler RTL with the serializer and FFE paths** to verify the interface between logic and electrical-layer models. I compared VCS and POSIM waveforms after TX RTL synthesis and place-and-route. On the receiver side, I checked **the CTLE behavioral model and its connection to the sampler**.

I participated in **joint measurements of a 28-nm, 32-Gb/s TX chip**, evaluating differential PAM&#8209;3 upper and lower eyes and BER bathtubs under channel-specific FFE settings.

[USB TX modeling and RTL checks](../projects/high-speed-interface-research/docs/usb-tx-modeling.md) · [RX CTLE model](../projects/high-speed-interface-research/docs/usb-rx-ctle-modeling.md) · [Differential PAM&#8209;3 measurements](../projects/high-speed-interface-research/docs/pam3-differential-measurement.md)

### PAM4 DSP, RTL and RFSoC board validation

To evaluate channel compensation and MLSD detection on hardware, I implemented **TX FIR, RX 21-tap FIR and DS-SBM RS-MLSD as 32-lane parallel RTL** and integrated them on the ZCU208 RFSoC. I controlled clock and RFDC initialization and coefficient updates through Vitis, captured signals through the DAC → ISI board → ADC path, and evaluated BER using PL PRBS checker counts.

The **A-SSCC 2026 paper was accepted**, reporting FPGA resource and timing results alongside RFSoC measurements.

[A-SSCC project](../projects/zcu208-pam4-dsp-portfolio/) · [Architecture](../projects/zcu208-pam4-dsp-portfolio/docs/architecture.md) · [FPGA implementation and measurements](../projects/zcu208-pam4-dsp-portfolio/docs/validation.md) · [Vitis board control](../projects/zcu208-pam4-dsp-portfolio/docs/vitis-bringup.md)

## Measurement setup and automation

I designed the LPDDR measurement PCB and analyzed its signal transmission characteristics in HFSS. For silicon evaluation, I connected power-supply, BERT and I2C control for voltage and timing sweeps, automating repeated tests with early error stops, boundary searches and CSV logging.

For RFSoC measurements, I connected condition-specific Vitis app execution, UART data collection and Python BER analysis of ILA counts in a harness. In line with current design trends, I use **AI and MATLAB MCP for RTL, testbench and automation code supporting repeatable verification and measurements**.

[PCB and HFSS](../projects/high-speed-interface-research/docs/pcb-hfss-verification.md) · [Instruments and control](../projects/high-speed-interface-research/docs/measurement-equipment.md) · [AI, Toolbox roles and automation harness](ai-assisted-dsp-workflow.en.md)

## Ongoing research

- **[Master's thesis · DS-SBM and DP-SMM comparison](https://github.com/yunjuhyeong0916-glitch/pam4-mlsd-research/blob/main/projects/pam4-mlsd-thesis/README.md) (in progress):** Comparing how survivor retention affects receiver decisions in models and RTL.
- **[Journal preparation · DP-SMM design and verification](https://github.com/yunjuhyeong0916-glitch/pam4-mlsd-research/blob/main/projects/dp-smm-journal/README.md) (in progress):** Studying two-path retention in segmented metric matrices and cost re-evaluation using actual symbol history. Board measurements with a 21-tap RX FFE + DP-SMM configuration are being prepared.
- **[DP-SMM patent application preparation](https://github.com/yunjuhyeong0916-glitch/pam4-mlsd-research/blob/main/docs/publications.md):** A PAM4 detector using dual-path retention and hierarchical metric composition.

## Selected publications

- **A-SSCC 2026 · Accepted:** [DS-SBM RFSoC PAM4 transceiver](https://epapers2.org/asscc2026/ESR/paper_details.php?paper_id=1351) · [LPDDR4X/5/5X Combo PHY](https://epapers2.org/asscc2026/ESR/paper_details.php?paper_id=1141)
- **ICEIC 2025:** [15.6-Gb/s low-voltage NRZ TX](https://doi.org/10.1109/ICEIC64972.2025.10879746)
- **SMACD 2025:** [USB4 Gen4 PAM&#8209;3 TX model](https://doi.org/10.1109/SMACD65553.2025.11092283) · [PAM&#8209;3 RX model](https://doi.org/10.1109/SMACD65553.2025.11092233)
- **IEEE TVLSI 2026:** [PAM&#8209;3 TX with 150-preset four-tap FFE](https://doi.org/10.1109/TVLSI.2026.3701343)

[Full paper titles and validation scope](publications.md)

---

<p>
  <a href="../README.en.md" title="Back to the portfolio home"><img src="../assets/readme/nav-home-en.svg" alt="Back to the portfolio home" width="86" height="30"></a>
  <a href="#page-top" title="Back to top"><img src="../assets/readme/nav-top-en.svg" alt="Back to top" width="124" height="30"></a>
</p>
