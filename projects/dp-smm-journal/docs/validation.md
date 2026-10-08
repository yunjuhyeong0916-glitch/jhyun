<a id="page-top"></a>

# DP-SMM RTL 검증과 FPGA 구현

<!-- page-navigation:top -->
<p>
  <a href="../README.md" title="Journal 프로젝트로 돌아가기"><img src="../../../assets/readme/nav-back-journal.svg" alt="Journal 프로젝트로 돌아가기" width="156" height="30"></a>
  <a href="../../../README.md" title="홈으로 돌아가기"><img src="../../../assets/readme/nav-home.svg" alt="홈으로 돌아가기" width="70" height="30"></a>
</p>
<!-- /page-navigation:top -->

[검출기 구조](architecture.md) · [학위논문 비교 결과](../../pam4-mlsd-thesis/docs/validation.md)

## 기존 고정소수점 참조 모델과 RTL 검증

DP-SMM 검출기의 후보 선택, 실제 이력을 반영한 비용, 프레임 경계 survivor 선택과 경로 복원을 고정소수점 참조 모델과 비교했습니다. tie-break 동작과 PM 정규화도 같은 기준으로 검사했습니다. 아래는 검출기 코어와 **기존 11-tap RX FFE 통합 구성**의 검증 결과입니다. K는 행렬 원소별 경로 수, H는 상태별 경계 후보 수입니다.

| 대상 | 입력 범위 | 결과 | 지연·입력 간격 |
|---|---|---|---|
| K=2 검출 코어 | 4,096프레임 | 참조 모델 일치 | 23클록·II=1 |
| 행렬 K=1·경계 H=2 코어 | 4,096프레임 | 해당 참조 모델 일치 | 23클록·II=1 |
| 기존 11-tap RX FFE 포함 경로 | 128프레임 | 참조 모델 일치 | 24클록·II=1 |

K=1 비교 코어는 DP-SMM의 행렬 후보 수를 제한한 구조입니다. 각 코어를 대응 참조 모델과 비교해 구현 정합성을 확인했습니다. [학위논문의 동일 입력 R=1/R=2 평가](../../pam4-mlsd-thesis/docs/validation.md#동일-입력에서의-후보-보존-효과)

## 병렬 처리율

프레임 폭은 32심볼이며, 125 MHz에서 II=1로 처리하는 설계입니다. 계산상 처리율은 32 × 125 MHz = **4 Gsymbol/s**, 비부호화 PAM4 기준 **8 Gb/s**입니다. DP-SMM의 보드 연속 처리율은 실측 예정입니다.

## K=2 검출기의 FPGA 자원

ZCU208·ZU48DR 배치배선 결과입니다. 검출기 코어 범위에는 RX FFE가 포함되지 않습니다.

| 집계 범위 | LUT | 레지스터 | BRAM tiles | DSP slices |
|---|---:|---:|---:|---:|
| 검출기 코어 | 266,664 | 168,330 | 240 | 1,664 |
| 기존 11-tap RX FFE 통합 플랫폼 | 299,250 | 207,988 | 279.5 | 2,944 |

기존 통합 플랫폼에는 RX FFE, RFDC 인터페이스, 제어·검증 회로가 포함됩니다. **21-tap RX FFE**를 적용할 보드 평가용 수신기의 자원·타이밍은 해당 구현을 기준으로 집계합니다.

## 보드 측정 계획

**21-tap RX FFE + DP-SMM** 구성으로 보드 BER·PR 등고선·연속 처리율을 평가할 예정입니다. AWG 수신 평가와 물리 DAC-to-ADC 검증 결과는 측정 후 추가합니다.

[DS-SBM 시스템의 측정 결과](../../zcu208-pam4-dsp-portfolio/docs/validation.md)

<!-- page-navigation:bottom -->
<p>
  <a href="../README.md" title="Journal 프로젝트로 돌아가기"><img src="../../../assets/readme/nav-back-journal.svg" alt="Journal 프로젝트로 돌아가기" width="156" height="30"></a>
  <a href="../../../README.md" title="홈으로 돌아가기"><img src="../../../assets/readme/nav-home.svg" alt="홈으로 돌아가기" width="70" height="30"></a>
  <a href="#page-top" title="페이지 맨 위로 이동"><img src="../../../assets/readme/nav-top.svg" alt="페이지 맨 위로 이동" width="100" height="30"></a>
</p>
<!-- /page-navigation:bottom -->
