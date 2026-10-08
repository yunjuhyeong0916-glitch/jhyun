<a id="page-top"></a>

# DP-SMM 검출기 구조

<!-- page-navigation:top -->
<p>
  <a href="../README.md" title="Journal 프로젝트로 돌아가기"><img src="../../../assets/readme/nav-back-journal.svg" alt="Journal 프로젝트로 돌아가기" width="156" height="30"></a>
  <a href="../../../README.md" title="홈으로 돌아가기"><img src="../../../assets/readme/nav-home.svg" alt="홈으로 돌아가기" width="70" height="30"></a>
</p>
<!-- /page-navigation:top -->

[검증·구현 결과](validation.md) · [DS-SBM과의 구조 비교](../../pam4-mlsd-thesis/docs/architecture.md)

## 21-tap RX FFE를 사용하는 수신 구성

![21-tap RX FFE 기준 DS-SBM과 DP-SMM의 PR 처리·행렬 경로 수·경계 PM 비교](../assets/ds_sbm_dp_smm_21tap_comparison.svg)

DP-SMM의 보드 평가는 **21-tap RX FFE**를 적용한 수신 구성으로 준비하고 있습니다. DS-SBM은 FFE 뒤의 별도 3-tap PR FIR 출력을 검출기에 입력합니다. DP-SMM은 FFE 출력을 직접 입력하고, PR 목표를 후보 심볼열의 예상 샘플 계산에 사용합니다.

## DS-SBM의 한 경로 선택을 두 경로 보존으로 확장

DS-SBM은 survivor branch로 만든 구간 행렬에서 시작·종료 상태마다 한 경로를 남깁니다. 중간 합성에서 제외된 경로는 뒤의 비용 계산에 참여할 수 없습니다. DP-SMM은 같은 상태 쌍의 두 경로를 유지하고, 프레임 전체의 후보가 만들어진 뒤 실제 내부 심볼 이력과 유입 survivor의 생략 심볼을 반영해 비용을 다시 평가합니다.

이렇게 남긴 두 번째 경로는 최종 비용 비교에서 첫 번째 경로를 대신할 수 있습니다. 프레임 경계에서도 종료 상태별 PM·이력 후보를 두 개 유지해 다음 프레임에 전달합니다. **행렬 내부의 두 경로 보존**과 **프레임 사이의 두 후보 전달**을 각각 적용한 구조입니다. [DS-SBM·DP-SMM 비교표와 후보 보존 효과](../README.md#ds-sbm에서-확장한-점)

## 후보 생성과 누적 PM 갱신의 분리

DP-SMM은 **Dual-Path Segmented Metric-Matrix** 기반 축소 상태 MLSD입니다. 구간 안에서는 누적 PM과 독립적으로 경로 후보를 생성·합성하고, 프레임 경계에서 이전 프레임의 survivor와 결합합니다. 이 구분을 이용해 행렬 합성 계층 사이에 파이프라인을 배치했습니다.

| 단계 | 처리 내용 |
|---|---|
| 관측 입력 | 21-tap RX FFE 출력으로 진행 예정. PR 목표는 예상 샘플 계산에 사용 |
| BM 생성 | 프로파일 ROM에서 심볼당 64개 memory-2 BM 가설 공급 |
| 4심볼 기초 행렬 | 4×4 행렬의 시작·종료 상태별로 두 경로 후보 보존 |
| 구간 합성 | 4심볼 → 8심볼 → 16심볼 → 32심볼의 rank-2 min-plus 합성 |
| 이력 반영 비용 | 보존된 프레임 경로를 실제 내부 심볼 이력으로 재평가 |
| 프레임 경계 | 유입 PM·생략 심볼을 반영해 종료 상태별 두 survivor 선택 |
| 경로 복원 | 저장한 중간 상태·하위 경로 순위를 따라 현재 32심볼 복원 |

## 행렬 원소별 두 경로

![4심볼 기초 행렬의 두 경로와 8심볼 세그먼트 행렬 생성](../assets/dp_smm_matrix_paths.jpg)

하나의 4×4 행렬에서 **각 원소가 두 경로 레코드**를 가집니다. 기초 행렬의 첫 BM은 입력의 생략 심볼에 대해 최소화하고, 나머지 BM은 후보 경로의 심볼 이력으로 계산합니다. 합성 단계에서는 중간 visible state가 이어지는 후보들의 제안 비용을 더해 원소별 두 경로를 남깁니다.

행렬의 경로 순위와 프레임 경계의 survivor 순위는 각각의 선택 결과입니다. 심볼당 64개 BM 가설 생성, 행렬 원소별 두 후보 보존, 상태별 두 누적 survivor 보존은 서로 다른 수량입니다.

## 두 경로를 유지하는 계층적 합성

![여덟 개의 4심볼 기초 행렬에서 8·16·32심볼 행렬로 이어지는 두 경로 min-plus 합성 트리](../assets/dp_smm_min_plus_hierarchy.jpg)

최상단의 4심볼 행렬 두 개가 8심볼 세그먼트 M₀–M₃를 만듭니다. 이어 M₀:₁·M₂:₃을 거쳐 32심볼 M₀:₃으로 합성하며, 각 단계에서 원소별 두 경로를 남깁니다. 그림의 DS1·DS2는 해당 원소의 rank-0·rank-1 경로 레코드를 뜻합니다. 합성 시 선택한 중간 상태와 하위 경로 순위도 저장해 마지막 경로 복원에 사용합니다.

## 실제 이력에 따른 비용과 프레임 경계 선택

![DP-SMM 프레임 경계 PM 갱신과 계층적 경로 복원](../assets/dp_smm_boundary_recovery.jpg)

프레임 행렬에 남은 경로의 내부 비용을 실제 심볼 이력으로 다시 계산합니다. 유입 survivor의 생략 심볼로 첫 BM을 정하고 유입 PM을 더한 뒤, 종료 visible state별로 누적 비용이 작은 두 후보를 선택합니다. 네 입력 상태·두 유입 survivor·두 프레임 경로에 따라 종료 상태별 최대 16개 후보가 경쟁합니다.

![실제 이력으로 비용을 재평가한 뒤 제안 2위 경로를 선택하는 DP-SMM 검증 사례](../assets/dp_smm_rescoring_selection.svg)

기존 검증 벡터에서는 제안 비용이 21·22였던 두 경로가 실제 이력을 반영한 뒤 31·27로 바뀌어, 두 번째 경로가 최종 선택됐습니다. 유입 PM은 0인 조건으로, 두 경로를 유지한 덕분에 비용 순위가 바뀐 후보를 복원에 사용할 수 있었습니다. [RTL 대조와 복원 예](../../pam4-mlsd-thesis/docs/validation.md#두-번째-후보가-최종-선택에-사용된-예)

선택한 경로의 정규화 PM과 생략 심볼은 다음 프레임으로 전달합니다. 현재 프레임의 복원은 합성 트리에 저장된 선택 정보를 따라 수행합니다. 후보 제거 단계에서 버린 경로는 재평가로 복구되지 않으므로, 전체 상태 MLSD의 최적성과는 구분해 성능을 평가합니다.

[검증 결과](validation.md) · [학위논문의 후보 보존 비교](../../pam4-mlsd-thesis/docs/validation.md)

<!-- page-navigation:bottom -->
<p>
  <a href="../README.md" title="Journal 프로젝트로 돌아가기"><img src="../../../assets/readme/nav-back-journal.svg" alt="Journal 프로젝트로 돌아가기" width="156" height="30"></a>
  <a href="../../../README.md" title="홈으로 돌아가기"><img src="../../../assets/readme/nav-home.svg" alt="홈으로 돌아가기" width="70" height="30"></a>
  <a href="#page-top" title="페이지 맨 위로 이동"><img src="../../../assets/readme/nav-top.svg" alt="페이지 맨 위로 이동" width="100" height="30"></a>
</p>
<!-- /page-navigation:bottom -->
