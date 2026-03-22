Compile-friendly hybrid MLSD set.

Structure:
- NRZ: full-state MLSD
- PAM4/PAM8: reduced-state MLSD
- Flattened helper module ports for ACS, survivor memory, traceback

Included traceback variants:
- traceback_flat.sv: default combinational traceback, preserves the current one-sample-per-cycle style but leaves a long timing path.
- traceback_flat_seq.sv: optional sequential traceback, intended for timing-friendly integration at lower throughput.

Notes:
- Internal arrays remain inside lane cores, but inter-module ports avoid unpacked array ports.
- The current lane cores still instantiate traceback_flat.sv by default.
- Use traceback_flat_seq.sv only if you are willing to redesign output handshaking and latency around a multi-cycle traceback engine.
- Top module name remains RX_TRIPLEMODE_MLSD_DSP_64LANE_8B.


