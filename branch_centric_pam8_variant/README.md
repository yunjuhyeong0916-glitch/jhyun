True branch-level Top-K reduced-state variant of the 4-architecture MLSD comparison folder.

This folder is self-contained for VCS comparison of:
- unified true branch-level Top-K reduced-state variant (4-state/8-state budget preserved) built from the committed baseline

- all-FS
- hybrid
- all-RS
- unified

How this folder is organized:
- all_fs/    : original all-FS reference set
- all_rs/    : original all-RS reference set
- hybrid/    : original hybrid reference set
- unified/   : original unified reference set
- *.sv       : self-contained compare wrappers and shared helper RTL
- tb_mlsd_4way_compare.sv : common 4-way comparison testbench with noise/channel mismatch sweep
- mlsd_4way_compare_root.f : VCS filelist using files in this top folder

Sweep configuration in TB:
- modes: NRZ, PAM4, PAM8
- channel cases: [1 2 1], [1 2 0], [1 1 1], [0 2 1]
- noise magnitudes: 0, 2, 4, 8
- lag sweep: nominal (TB-1) with offset sweep of +/-4
- absolute SER is polarity-aware: match if y == exp or y == -exp

Suggested VCS command:
  vcs -sverilog -full64 -f D:\rs_mlsd_4arch_compare_adaptive_k_chaware\branch_centric_pam8_variant\mlsd_4way_compare_root.f -top tb_mlsd_4way_compare
  simv

Additional realistic channel-based comparison:
- fir_siso_wide.sv : digital FIR channel model used ahead of the 4 DUTs
- tb_mlsd_4way_channel_compare.sv : 4-way comparison TB using raw symbol generation -> FIR channel -> MLSD
- mlsd_4way_channel_compare_root.f : VCS filelist for the channel-based comparison

Suggested VCS command for FIR-channel sweep:
  vcs -sverilog -full64 -f D:\rs_mlsd_4arch_compare_adaptive_k_chaware\branch_centric_pam8_variant\mlsd_4way_channel_compare_root.f -top tb_mlsd_4way_channel_compare
  simv



