<a id="page-top"></a>

# Journal 준비 | DP-SMM 기반 PAM4 검출기 (진행 중)

<!-- page-navigation:top -->
<p>
  <a href="../README.md" title="연구 목록으로 돌아가기"><img src="../../assets/readme/nav-back-research.svg" alt="연구 목록으로 돌아가기" width="110" height="30"></a>
  <a href="../../README.md" title="홈으로 돌아가기"><img src="../../assets/readme/nav-home.svg" alt="홈으로 돌아가기" width="70" height="30"></a>
</p>
<!-- /page-navigation:top -->

구간 계산에서 제외될 수 있는 대안 경로를 최종 판정에 활용하기 위해 **DP-SMM 수신 검출기**를 설계했습니다. [DS-SBM의 구간 행렬 구조](../zcu208-pam4-dsp-portfolio/docs/architecture.md)를 확장해 두 경로 후보를 남기고, [실제 심볼 이력으로 비용을 다시 계산](docs/architecture.md#실제-이력에-따른-비용과-프레임-경계-선택)한 뒤 최종 경로를 선택합니다.

검출기 RTL과 참조 모델의 일치를 확인하고 FPGA 배치배선을 수행했습니다. **21-tap RX FFE + DP-SMM** 수신 구성의 보드 실측을 준비하고 있습니다.

[검출기 구조](docs/architecture.md) · [RTL 검증·FPGA 구현](docs/validation.md) · [DS-SBM·DP-SMM 비교 연구](../pam4-mlsd-thesis/)

**DP-SMM 특허 출원 준비 중.**

## DS-SBM에서 확장한 점

![21-tap RX FFE를 공통으로 사용하는 DS-SBM과 DP-SMM의 신호 경로·후보 보존·프레임 경계 선택 비교](assets/ds_sbm_dp_smm_21tap_comparison.svg)

왼쪽 DS-SBM은 각 행렬 원소에 한 경로를 남기고, 오른쪽 DP-SMM은 두 경로를 합성 단계까지 유지합니다. DP-SMM에서는 실제 이력으로 비용을 다시 평가한 뒤, 상태별 두 후보의 PM·이력을 다음 프레임으로 전달합니다. 두 방식 모두 32심볼 구간 행렬을 병렬 처리하며, 진행할 DP-SMM 수신 구성의 RX FFE도 **21-tap**입니다.

<details>
<summary>분기·행렬 경로·경계 후보의 세부 비교</summary>

| 항목 | DS-SBM | DP-SMM |
|---|---|---|
| 분기·BM 처리 | 상태별 두 survivor branch, 심볼당 총 8개 전파 | 심볼당 64개 memory-2 BM 가설을 ROM에서 공급 |
| 행렬 원소별 경로 | 한 경로 보존 | 두 경로와 심볼 이력·복원 정보 보존 |
| 경로 비용과 선택 | 구간 최소 비용을 합성하고 유입 PM과 결합 | 두 제안 경로를 실제 이력으로 재평가한 뒤 유입 PM과 결합 |
| 프레임 경계 | visible state별 PM 한 개 전달 | visible state별 PM·이력을 가진 후보 두 개 전달 |
| 검출기 관측 입력 | 21-tap RX FFE 뒤 별도 3-tap PR FIR 출력 | 21-tap RX FFE 출력, PR 목표는 예상 샘플 계산에 사용하는 구성으로 진행 예정 |

DS-SBM의 ‘dual-survivor’는 상태별로 전파하는 두 survivor branch를 뜻합니다. DP-SMM의 ‘dual-path’는 같은 시작·종료 상태를 잇는 행렬 원소에 남기는 두 경로를 뜻합니다. [신호 경로·후보 보존 위치 비교](../pam4-mlsd-thesis/docs/architecture.md)

</details>

## 두 번째 경로가 최종 선택되는 과정

![DP-SMM 검증 벡터에서 제안 비용 21·22의 두 경로가 이력 반영 후 31·27이 되어 두 번째 경로가 선택되는 과정](assets/dp_smm_rescoring_selection.svg)

기존 검증 벡터에서 경로 B는 제안 비용이 22로 경로 A의 21보다 컸습니다. 실제 심볼 이력을 반영하면 비용이 각각 27과 31이 되어 B가 선택됐습니다. DP-SMM은 두 후보를 남겨 두어, 이처럼 비용 순위가 바뀌는 경로를 심볼 복원에 활용합니다. [검증 벡터·RTL 복원 결과](../pam4-mlsd-thesis/docs/validation.md#두-번째-후보가-최종-선택에-사용된-예)

**후보 보존 효과:** DP-SMM의 동일 입력 R=1/R=2 코어 비교에서 경계 후보 수를 두 개로 고정했습니다. 합성 응답 A·B의 SNR 16 dB 조건에서, 행렬 원소별 두 경로를 남긴 R=2의 비트 오류 수가 R=1보다 각각 **36.9%·46.1% 감소**했습니다. [비교 조건·오류 수](../pam4-mlsd-thesis/docs/validation.md#동일-입력에서의-후보-보존-효과)

## 32심볼 병렬 처리 구조

![DP-SMM의 32심볼 프레임 분할과 구간 행렬 합성·PM 갱신·경로 복원](assets/dp_smm_frame_schedule.jpg)

여덟 개의 4심볼 기초 행렬을 네 개의 8심볼 세그먼트로 묶고, 두 단계의 rank-2 min-plus 합성으로 32심볼 프레임 행렬을 만듭니다. 구간 계산에는 이전 프레임의 누적 PM을 넣지 않고, 프레임 경계에서 이력을 반영한 비용과 결합합니다.

## RTL 검증 결과

| 검증 대상 | 결과 | 범위 |
|---|---|---|
| 두 경로 검출 코어 | 참조 모델 일치 | 제안 후보·이력 반영 비용·경계 survivor·복원 출력 |
| 행렬 K=1·경계 H=2 비교 코어 | 해당 참조 모델과 일치 | 행렬 후보 수를 제한한 비교 구조 |
| 연속 입력 처리 | II=1 | 검출기 코어 지연 23클록 |

32심볼·125 MHz·II=1의 설계 처리율은 **4 Gsymbol/s**, 비부호화 PAM4 **8 Gb/s**입니다. 기존 FFE 통합 시험과 FPGA 자원은 [검증 조건·구현 자원](docs/validation.md)에 정리했습니다.

## 측정 준비

**21-tap RX FFE + DP-SMM** 구성으로 보드 실측을 준비합니다. AWG 기반 ADC-DSP 수신 경로와 DAC–ISI 보드–ADC 송수신 경로에서 BER·PR 등고선·연속 처리율을 평가할 예정입니다.

[A-SSCC DS-SBM](../zcu208-pam4-dsp-portfolio/) · [학위논문 비교 연구](../pam4-mlsd-thesis/) · [연구 성과 논문](../../docs/publications.md)

<!-- page-navigation:bottom -->
<p>
  <a href="../README.md" title="연구 목록으로 돌아가기"><img src="../../assets/readme/nav-back-research.svg" alt="연구 목록으로 돌아가기" width="110" height="30"></a>
  <a href="../../README.md" title="홈으로 돌아가기"><img src="../../assets/readme/nav-home.svg" alt="홈으로 돌아가기" width="70" height="30"></a>
  <a href="#page-top" title="페이지 맨 위로 이동"><img src="../../assets/readme/nav-top.svg" alt="페이지 맨 위로 이동" width="100" height="30"></a>
</p>
<!-- /page-navigation:bottom -->
