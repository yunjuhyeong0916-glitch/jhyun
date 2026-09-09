# VCS MLSD 비교 소스 묶음

[상위 실험 안내](../README.md)

all-FS, hybrid, all-RS, unified의 비교용 RTL과 TB를 함께 보관한 스냅샷입니다. 이 폴더의 파일 목록은 이 폴더의 소스만 참조합니다.

| 파일 목록 | Top module |
|---|---|
| [mlsd_4way_compare.f](mlsd_4way_compare.f) | `tb_mlsd_4way_compare` |
| [mlsd_4way_channel_compare.f](mlsd_4way_channel_compare.f) | `tb_mlsd_4way_channel_compare` |
| [mlsd_allfs_debug_1lane.f](mlsd_allfs_debug_1lane.f) | `tb_mlsd_allfs_debug_1lane` |

저장소 루트에서 시작하는 예:

```bash
cd experiments/branch-centric-pam8/vcs_suite
vcs -sverilog -full64 -f mlsd_4way_compare.f -top tb_mlsd_4way_compare -o simv
./simv
```

개인 PC의 절대경로를 제거하고 참조 파일의 존재를 점검했습니다. 이번 정리에서 VCS 실행 결과는 새로 확인하지 않았습니다. 상세 비교 조건은 선택한 TB의 parameter와 plusarg를 확인합니다.
