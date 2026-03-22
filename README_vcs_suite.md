VCS suite for 4-way MLSD architecture comparison.

Architectures under comparison:
- all-FS
- hybrid (NRZ=FS, PAM4/PAM8=RS, split cores)
- all-RS
- unified (NRZ=FS, PAM4/PAM8=RS, shared core)

Files:
- tb_mlsd_4way_compare.sv : common PR2-domain comparison testbench
- mlsd_4way_compare.f     : VCS filelist

Suggested VCS command:
  vcs -sverilog -full64 -f D:\rs_mlsd_4arch_compare\vcs_suite\mlsd_4way_compare.f -top tb_mlsd_4way_compare
  ./simv

Testbench behavior:
- Drives the same 64-lane PR2-domain stimulus into all 4 DUTs.
- Runs NRZ, PAM4, PAM8 phases sequentially.
- Reports per-mode symbol error rate against transmitted symbols.
- Reports mismatch rate of hybrid/all-RS/unified versus all-FS baseline.
- Default NOISE_MAG=0 for deterministic baseline comparison.
