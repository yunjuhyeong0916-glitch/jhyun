# 전체 자료 지도

[저장소 첫 화면](../README.md)

## 읽는 순서

**프로젝트 이해:** [대표 프로젝트 요약](../projects/zcu208-pam4-dsp-portfolio/) → [구현 구조](../projects/zcu208-pam4-dsp-portfolio/docs/architecture.md) → [검증 근거](../projects/zcu208-pam4-dsp-portfolio/docs/validation.md)

**코드 검토:** [대표 RTL 안내](../projects/zcu208-pam4-dsp-portfolio/docs/architecture.md) → [테스트벤치](../projects/zcu208-pam4-dsp-portfolio/tb/) → [재현 방법](../projects/zcu208-pam4-dsp-portfolio/docs/reproduce.md)

**MLSD 아이디어와 실행:** [잔류 ISI·ACS 병렬화·후보 보존](../projects/zcu208-pam4-dsp-portfolio/docs/design-decisions.md) → [입력·기준값·메트릭 RTL 최소 예제](../projects/zcu208-pam4-dsp-portfolio/examples/mlsd_minimal/) → [PASS와 어댑터 불일치의 검증 범위](../projects/zcu208-pam4-dsp-portfolio/docs/validation.md)

**FPGA 구현·보드 구동:** [Vivado 빌드·JTAG 다운로드](../projects/zcu208-pam4-dsp-portfolio/docs/fpga-bringup.md) → [Vitis·PS 앱·CLK104/RFDC 초기화](../projects/zcu208-pam4-dsp-portfolio/docs/vitis-bringup.md) → [Vivado 산출물](../projects/zcu208-pam4-dsp-portfolio/reports/fpga_artifact_inventory_20261007.json) / [Vitis 파일·해시 비교](../projects/zcu208-pam4-dsp-portfolio/reports/vitis_artifact_inventory_20261007.json) → [검증 범위](../projects/zcu208-pam4-dsp-portfolio/docs/validation.md)

**LPDDR·USB 연구:** [회로·모델링·실리콘 평가 개요](../projects/high-speed-interface-research/) → [LPDDR](../projects/high-speed-interface-research/docs/lpddr.md) / [USB PAM-3](../projects/high-speed-interface-research/docs/usb4-pam3.md) → [측정 장비와 활용](../projects/high-speed-interface-research/docs/measurement-equipment.md) → [논문·근거](../projects/high-speed-interface-research/docs/evidence.md)

**성과 논문 확인:** [전체 논문 6편·공식 링크·검증 범위](publications.md) → 해당 프로젝트의 담당 역할과 결과 설명

**LPDDR TX 모델링:** [32:1 직렬화·위상 정렬·pre-emphasis 구조와 기존 검증 파형](../projects/high-speed-interface-research/docs/lpddr-tx-modeling.md) → [회로·실리콘 결과와 비교 범위](../projects/high-speed-interface-research/docs/lpddr.md)

**LPDDR TX 회로 검증:** [회로 구조·FFE 적용 전후 Eye·LVS/PEX·PRBS7 속도·두 전원 레일의 에너지](../projects/high-speed-interface-research/docs/lpddr-tx-circuit-verification.md)

**USB TX 모델링:** [인코딩·기대값·XMODEL 복원·우회 경로·Serializer·FFE·채널·VCS/POSIM 비교](../projects/high-speed-interface-research/docs/usb-tx-modeling.md)

**USB RX CTLE:** [동작점·R/C AC 응답·중간 레벨 보상·Sampler 연결](../projects/high-speed-interface-research/docs/usb-rx-ctle-modeling.md)

**검증 그림 확인:** [LPDDR·USB Eye·Shmoo와 AWG 설정 전후](../projects/high-speed-interface-research/docs/verification-figures.md)

**PCB·HFSS 사진과 해석:** [PCB 배치·제작·본딩·HFSS 모델·전달 특성·계측 환경](../projects/high-speed-interface-research/docs/pcb-hfss-verification.md)

**연구 이력 탐색:** [MLSD 비교 실험](../experiments/) → [참고 코어](../reference/mlsd-cores/) → [이전 보드 자료](../archive/)

## 폴더 구조

```text
jhyun/
├── README.md                         한국어 포트폴리오 첫 화면
├── README.en.md                      English overview
├── projects/
│   ├── zcu208-pam4-dsp-portfolio/     DSP·MLSD RTL · FPGA 구현·구동
│   └── high-speed-interface-research/ LPDDR·USB 회로·모델·계측 연구
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
