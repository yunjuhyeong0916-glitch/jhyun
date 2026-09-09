# MLSD 구조 비교 실험

[실험 목록](../README.md) · [저장소 첫 화면](../../README.md)

64-lane NRZ/PAM4/PAM8 신호를 대상으로 all-FS, hybrid, all-RS, unified 구조를 비교하기 위한 기존 RTL과 테스트벤치입니다. ZCU208 32-lane 대표 프로젝트와는 별도 버전입니다.

## 파일 찾기

| 자료 | 용도 |
|---|---|
| [tb_mlsd_4way_compare.sv](tb_mlsd_4way_compare.sv) | 네 구조에 공통 입력을 주는 비교 TB |
| [tb_mlsd_4way_channel_compare.sv](tb_mlsd_4way_channel_compare.sv) | FIR 채널을 포함한 비교 TB |
| [tb_unified_channel_compare.sv](tb_unified_channel_compare.sv) | Unified 구조용 채널 비교 TB |
| [mlsd_4way_compare_root.f](mlsd_4way_compare_root.f) | 이 폴더의 기본 비교 파일 목록 |
| [vcs_suite/](vcs_suite/) | 별도로 보관된 VCS 비교 소스 묶음 |
| [구조별 참고 코어](../../reference/mlsd-cores/) | all-FS / all-RS / hybrid / unified 참고 RTL |

## 실행 경로

VCS가 설치된 환경에서 저장소 루트를 기준으로 다음과 같이 실행합니다.

```bash
cd experiments/mlsd-architecture-comparison
vcs -sverilog -full64 -f mlsd_4way_compare_root.f -top tb_mlsd_4way_compare -o simv
./simv
```

채널 비교는 `mlsd_4way_channel_compare_root.f`와 `tb_mlsd_4way_channel_compare`를 사용합니다. 각 `.f`의 경로는 해당 파일이 있는 폴더를 작업 디렉터리로 사용할 때 해석됩니다.

## 결과를 읽을 때

기존 설명의 sweep 항목은 NRZ/PAM4/PAM8, 채널 조건, 잡음 크기 및 지연 탐색입니다. 실제 실행 조건은 선택한 TB의 parameter와 plusarg를 기준으로 확인합니다. 일부 TB의 polarity-aware score는 출력의 부호 반전을 허용하는 비교이므로 일반적인 실측 BER와 동일하게 해석하지 않습니다.

이번 정리에서는 파일 목록의 참조 대상 존재와 RTL 원문 보존만 점검했습니다. VCS 실행 성공, 최신 기능 검증 또는 구조 간 성능 우위를 새로 확인한 자료는 아닙니다. `vcs_suite/`는 별도 스냅샷으로 유지하므로 이 폴더의 소스와 자동으로 혼합하지 않습니다.
