# 윤주형 | 고속 인터페이스 RTL·FPGA 포트폴리오

고속 신호의 왜곡 보상과 데이터 복원을 위한 디지털 회로 설계·검증 자료입니다. 아래 대표 프로젝트에서 병렬 DSP 구조, RTL 소스, 테스트벤치와 FPGA 구현 기록을 확인할 수 있습니다.

## 대표 프로젝트

### [ZCU208 기반 32-lane PAM4 송수신 DSP 설계·검증](projects/zcu208-pam4-dsp-portfolio/)

4 GS/s로 설정한 RFSoC ADC·DAC와 32-lane 병렬 DSP를 연결한 프로젝트입니다. TX/RX FIR 필터, PAM4 reduced-state MLSD 검출기, 계수 설정 및 PRBS 검사·디버깅 경로를 다룹니다.

- **설계:** 고정소수점 신호처리의 Verilog/SystemVerilog 구현, 병렬화와 파이프라인 구성
- **검증:** FIR 테스트벤치 3종 재실행 PASS, 기존 FPGA 배치배선 보고서의 결과와 검증 범위 정리
- **자료:** [프로젝트 요약](projects/zcu208-pam4-dsp-portfolio/README.md) · [대표 소스 안내](projects/zcu208-pam4-dsp-portfolio/docs/architecture.md) · [검증 근거](projects/zcu208-pam4-dsp-portfolio/docs/validation.md)

## 기존 MLSD 비교 실험 자료

아래 내용과 기존 디렉터리는 별도 버전의 MLSD 비교 실험 자료입니다. 대표 프로젝트의 구조·성능 결과와 구분해 보실 수 있도록 기존 설명을 유지했습니다.

Top-level 4-architecture MLSD comparison folder.

This folder is self-contained for VCS comparison of:
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
  vcs -sverilog -full64 -f D:\rs_mlsd_4arch_compare\mlsd_4way_compare_root.f -top tb_mlsd_4way_compare
  simv

Additional realistic channel-based comparison:
- fir_siso_wide.sv : digital FIR channel model used ahead of the 4 DUTs
- tb_mlsd_4way_channel_compare.sv : 4-way comparison TB using raw symbol generation -> FIR channel -> MLSD
- mlsd_4way_channel_compare_root.f : VCS filelist for the channel-based comparison

Suggested VCS command for FIR-channel sweep:
  vcs -sverilog -full64 -f D:\rs_mlsd_4arch_compare\mlsd_4way_channel_compare_root.f -top tb_mlsd_4way_channel_compare
  simv
