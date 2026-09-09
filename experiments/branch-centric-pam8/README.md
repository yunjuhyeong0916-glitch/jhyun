# Branch-centric MLSD 변형 실험

[실험 목록](../README.md) · [기본 구조 비교](../mlsd-architecture-comparison/)

Branch 후보 선택을 변경한 unified reduced-state MLSD와 기본 비교 구조들을 보관한 별도 실험 버전입니다. 기존 설명은 branch-level Top-K 선택과 작은 gap 조건의 fallback을 다루며, 실제 동작 범위는 이 폴더의 RTL과 TB를 기준으로 확인해야 합니다.

## 자료 구성

| 위치 | 내용 |
|---|---|
| [cmp_unified_mlsd_core_lane_8b.sv](cmp_unified_mlsd_core_lane_8b.sv) | Unified 검출 코어 |
| [tb_mlsd_4way_compare.sv](tb_mlsd_4way_compare.sv) | 네 구조 비교 TB |
| [tb_mlsd_4way_channel_compare.sv](tb_mlsd_4way_channel_compare.sv) | FIR 채널 포함 비교 TB |
| [vcs_suite/](vcs_suite/) | 이 변형에 함께 보관된 비교 소스 묶음 |
| [dsp based rx/](dsp%20based%20rx/) | 이 버전의 구조별 코어 스냅샷 |
| [DSP based TRX on FPGA/](DSP%20based%20TRX%20on%20FPGA/) | 이 버전에 함께 보관된 이전 보드 자료 |

## 실행 경로

VCS가 설치된 환경에서 저장소 루트를 기준으로 실행합니다.

```bash
cd experiments/branch-centric-pam8
vcs -sverilog -full64 -f mlsd_4way_compare_root.f -top tb_mlsd_4way_compare -o simv
./simv
```

파일 목록은 각 `.f`가 있는 폴더를 작업 디렉터리로 사용할 때 해석됩니다. 기존 소스·설정·보드 자료를 유지했으며, 유사한 파일을 다른 버전과 병합하지 않았습니다. 이번 정리에서는 VCS 실행, 알고리즘 동등성 또는 성능 개선 여부를 새로 검증하지 않았습니다.
