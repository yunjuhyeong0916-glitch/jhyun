VCS suite for 4-way MLSD architecture comparison.

Architectures under comparison:
- all-FS
- hybrid (NRZ=FS, PAM4/PAM8=RS, split cores)
- all-RS
- unified (NRZ=FS, PAM4/PAM8=RS, shared core)

Files:
- tb_mlsd_4way_compare.sv : common comparison testbench with noise/channel mismatch sweep
- mlsd_4way_compare.f     : VCS filelist

Sweep configuration in TB:
- modes: NRZ, PAM4, PAM8
- channel cases: [1 2 1], [1 2 0], [1 1 1], [0 2 1]
- noise magnitudes: 0, 2, 4, 8
- lag sweep: nominal (TB-1) with offset sweep of +/-4
- absolute SER is polarity-aware: match if y == exp or y == -exp

Suggested VCS command:
  vcs -sverilog -full64 -f D:\rs_mlsd_4arch_compare\vcs_suite\mlsd_4way_compare.f -top tb_mlsd_4way_compare
  ./simv

Additional realistic channel-based comparison:
- fir_siso_wide.sv : digital FIR channel model used ahead of the 4 DUTs
- tb_mlsd_4way_channel_compare.sv : 4-way comparison TB using raw symbol generation -> FIR channel -> MLSD
- mlsd_4way_channel_compare.f : VCS filelist for the channel-based comparison

Suggested VCS command for FIR-channel sweep:
  vcs -sverilog -full64 -f D:\rs_mlsd_4arch_compare\vcs_suite\mlsd_4way_channel_compare.f -top tb_mlsd_4way_channel_compare
  simv
