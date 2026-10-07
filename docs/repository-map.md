# 전체 자료 지도

[저장소 첫 화면](../README.md)

## 읽는 순서

**프로젝트 이해:** [대표 프로젝트 요약](../projects/zcu208-pam4-dsp-portfolio/) → [구현 구조](../projects/zcu208-pam4-dsp-portfolio/docs/architecture.md) → [검증 근거](../projects/zcu208-pam4-dsp-portfolio/docs/validation.md)

**코드 검토:** [대표 RTL 안내](../projects/zcu208-pam4-dsp-portfolio/docs/architecture.md) → [테스트벤치](../projects/zcu208-pam4-dsp-portfolio/tb/) → [재현 방법](../projects/zcu208-pam4-dsp-portfolio/docs/reproduce.md)

**FPGA 구현·보드 구동:** [Vivado 빌드·JTAG 다운로드·초기 동작 확인](../projects/zcu208-pam4-dsp-portfolio/docs/fpga-bringup.md) → [원 프로젝트 산출물 확인 기록](../projects/zcu208-pam4-dsp-portfolio/reports/fpga_artifact_inventory_20261007.json) → [검증 범위](../projects/zcu208-pam4-dsp-portfolio/docs/validation.md)

**연구 이력 탐색:** [MLSD 비교 실험](../experiments/) → [참고 코어](../reference/mlsd-cores/) → [이전 보드 자료](../archive/)

## 폴더 구조

```text
jhyun/
├── README.md                         한국어 포트폴리오 첫 화면
├── README.en.md                      English overview
├── projects/
│   └── zcu208-pam4-dsp-portfolio/     대표 프로젝트 · 소스 · 검증 근거
├── experiments/
│   ├── mlsd-architecture-comparison/ 네 MLSD 구조의 비교 실험
│   └── branch-centric-pam8/          별도 branch-centric 변형
├── reference/
│   └── mlsd-cores/                   구조별 참고 RTL
├── archive/
│   └── vivado-trx-wber-v2/           이전 보드 프로젝트
└── docs/                             자료 안내 · 검증 상태 · 용어
```

## 이전 경로에서 찾기

2026-09-09 저장소 정리 기준입니다. 기존 커밋의 링크는 Git 이력에서 그대로 조회할 수 있습니다.

| 이전 위치 | 현재 위치 |
|---|---|
| 루트의 `*.sv`, `*.f` | [experiments/mlsd-architecture-comparison/](../experiments/mlsd-architecture-comparison/) |
| `vcs_suite/` | [experiments/mlsd-architecture-comparison/vcs_suite/](../experiments/mlsd-architecture-comparison/vcs_suite/) |
| `README_vcs_suite.md` | [VCS 안내](../experiments/mlsd-architecture-comparison/README_vcs_suite.md) |
| `branch_centric_pam8_variant/` | [experiments/branch-centric-pam8/](../experiments/branch-centric-pam8/) |
| `dsp based rx/` | [reference/mlsd-cores/](../reference/mlsd-cores/) |
| `DSP based TRX on FPGA/` | [archive/vivado-trx-wber-v2/](../archive/vivado-trx-wber-v2/) |
| `projects/zcu208-pam4-dsp-portfolio/` | 기존 위치와 공개 링크 유지 |

## 실행 파일 목록

14개 `.f` 파일의 개인 PC 절대경로를 각 폴더의 상대경로로 바꿨습니다. `vcs -f ...`를 실행하기 전에 해당 `.f`가 있는 폴더로 이동해야 합니다. 파일 순서와 컴파일 옵션, 참조하는 RTL 내용은 유지했습니다.

이 정리에서 RTL·보드 파일은 원문을 유지했고 유사한 소스를 합치거나 제거하지 않았습니다. 변형 실험 안에 함께 보관된 보드 자료와 코어 모음도 그 버전의 스냅샷으로 유지했습니다.
