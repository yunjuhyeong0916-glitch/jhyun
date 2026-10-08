# AI assistance | RTL implementation and FPGA measurement automation

[DSP transceiver research](../README.en.md#dsp-transceiver-research) · [Repository map](repository-map.md) · [한국어](ai-assisted-dsp-workflow.md)

Changes to the PAM4 receiver model or coefficients required repeated RTL checks and FPGA evaluations. I used AI to help write and revise **RTL, testbenches, FPGA control code, data-collection scripts and analysis code**. MATLAB MCP connected Codex to MATLAB for model execution and result inspection.

![Two AI applications: writing RTL and testbenches from model conditions and comparing outputs; developing control and execution scripts for ZCU208 coefficient updates, capture collection and BER analysis.](../assets/ai_workflow_en.svg)

## Writing and revising RTL and testbenches

AI assisted with writing and revising RTL and testbenches based on the behavior, interfaces and fixed-point conditions defined in MATLAB/Simulink. I applied identical input vectors to the fixed-point reference model and RTL, comparing **FFE outputs, detector decisions and output timing**. Mismatched stages were revised and rerun.

[Model–RTL verification results](../projects/dp-smm-journal/docs/validation.md)

## Automating coefficient evaluations on ZCU208

To compare receiver performance across filter-coefficient candidates, I used AI to help write and revise **Vitis control code, capture and storage scripts, and Python analysis code**. These formed a measurement-automation harness connecting coefficient updates with repeated result collection and comparison.

I checked that coefficient updates reached the FPGA and collected data and PL PRBS checker results for each condition. Python calculated **BER from error counts and checked-bit counts** to compare coefficient candidates.

[Vitis coefficient updates and data collection](../projects/zcu208-pam4-dsp-portfolio/docs/vitis-bringup.md) · [A-SSCC measurement results](../projects/zcu208-pam4-dsp-portfolio/docs/validation.md)

---

[Back to DSP transceiver research](../README.en.md#dsp-transceiver-research)
