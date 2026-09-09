# MLSD 코어 구조별 안내

[참고 자료 목록](../README.md) · [비교 실험](../../experiments/mlsd-architecture-comparison/)

| 구조 | 폴더 | 기존 설명의 설계 방향 |
|---|---|---|
| Full-state | [all_fs/](all_fs/) | Full-state MLSD 코어 |
| Reduced-state | [all_rs/](all_rs/) | Reduced-state MLSD 코어 |
| Hybrid | [hybrid/](hybrid/) | 변조 방식에 따라 FS/RS 코어를 나누어 사용하는 구조 |
| Unified | [unified/](unified/) | 공유 trellis engine에서 변조 모드를 처리하는 구조 |

각 폴더의 README에서 top module과 내부 구성을 확인할 수 있습니다. 이 자료의 존재만으로 네 구조의 동등성, PPA 우위 또는 최신 검증 완료를 의미하지는 않습니다.
