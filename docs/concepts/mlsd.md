<a id="page-top"></a>

<p align="right"><a href="mlsd.en.md"><img src="../../assets/readme/nav-en.svg" alt="English" width="96" height="30"></a></p>

# MLSD | 연속된 신호에서 송신 데이터 찾기

[← 용어 안내](../glossary.md) · [연구 이력](../profile.md) · [홈](../../README.md)

**MLSD(Maximum-Likelihood Sequence Detection)는 연속해서 받은 신호를 함께 비교해, 어떤 데이터열을 보냈을 가능성이 높은지 찾는 수신 기법입니다.**

배선이나 케이블을 통과한 신호에는 앞서 보낸 신호의 영향이 남을 수 있습니다. 이런 [ISI](equalization.md#term-isi)가 있으면 수신기는 현재 신호의 높이와 앞뒤 데이터의 관계를 함께 살펴야 합니다. 공식 자료에서는 같은 계열의 기법을 MLSE(Maximum-Likelihood Sequence Estimation)로 설명합니다. [MathWorks MLSE 안내](https://www.mathworks.com/help/comm/ug/mlse-equalizers.html)

## 후보 데이터가 만드는 신호를 비교합니다

![받은 신호열을 바탕으로 각 후보의 예상 신호를 계산하고, 오차를 누적해 송신 데이터열을 선택하는 과정](../../assets/concepts/mlsd-flow.svg)

후보 데이터열마다 채널을 지난 뒤의 신호를 예상하고, 관측값과의 차이를 계산합니다. 예를 들어 제곱오차를 사용하는 조건에서는 이 차이의 제곱을 더해, 누적값이 작은 경로를 선택합니다. Viterbi 알고리즘은 이런 경로 탐색을 효율적으로 수행하는 대표적인 방법입니다. [MLSE 알고리즘 설명](https://www.mathworks.com/help/comm/ref/comm.mlseequalizer-system-object.html)

## 작은 숫자로 보는 예

두 레벨 `−1, +1`을 사용하는 설명용 예입니다. 앞선 심볼이 `+1`이고, 채널 응답을 `현재 심볼 + 0.5 × 이전 심볼`로 두겠습니다. 수신한 두 값은 `(0.7,−1.5)`입니다.

| 후보 | 예상값 | 오차 합 |
|---|---|---|
| `(+1,+1)` | `(1.5,1.5)` | 9.64 |
| `(+1,−1)` | `(1.5,−0.5)` | 1.64 |
| **`(−1,−1)`** | **`(−0.5,−1.5)`** | **1.44** |
| `(−1,+1)` | `(−0.5,0.5)` | 5.44 |

첫 관측값 `0.7`만 비교하면 예상값 `1.5`가 `−0.5`보다 가까워 첫 심볼을 `+1`로 고를 수 있습니다. 두 관측값의 오차를 합하면 **`(−1,−1)`이 전체 신호를 더 잘 설명**합니다. 이것이 여러 시점의 정보를 함께 사용하는 이유입니다.

<a id="term-metrics"></a>

## State·metric·survivor는 무엇인가요?

- **State:** 다음 신호를 예상하는 데 필요한 이전 심볼 이력을 구분한 것.
- **Branch metric(BM):** 한 후보 전이가 현재 관측값과 얼마나 다른지 나타내는 비용.
- **Path metric(PM):** 경로를 따라 누적한 비용.
- **Survivor:** 비교를 거쳐 다음 계산으로 넘기는 후보 경로 또는 분기 정보.

[PAM4](pam-signaling.md#term-pam4)에서 이전 두 심볼의 모든 조합을 상태로 두면 `4 × 4 = 16`개가 필요합니다. 신호 레벨이나 기억할 이력이 늘면 상태 수도 빠르게 커집니다. 이 때문에 하드웨어에서는 계산량과 후보 보존 방식을 함께 설계합니다. [상태 수와 채널 기억 길이](https://www.mathworks.com/help/comm/ref/comm.mlseequalizer-system-object.html)

<a id="term-research"></a>

## 이 포트폴리오의 DS-SBM·DP-SMM

**RS-MLSD**의 RS는 Reduced-State를 뜻합니다. 상태와 후보를 줄여 하드웨어 비용을 낮추는 방향입니다.

**DS-SBM**은 A-SSCC 연구의 검출기 구조입니다. 상태별 두 survivor branch를 사용하고, 구간별 비용을 행렬로 묶어 병렬 계산합니다. [설계 판단과 논문 구조](../../projects/zcu208-pam4-dsp-portfolio/docs/design-decisions.md)

**DP-SMM**은 같은 시작·종료 상태를 연결하는 행렬 원소에 두 경로 후보를 남기고, 실제 심볼 이력을 반영해 비용을 다시 평가하는 후속 구조입니다. 두 이름의 차이는 **후보를 어느 위치에서 어떻게 보존하는가**에 있습니다. [Journal 연구의 구조 설명](https://github.com/yunjuhyeong0916-glitch/pam4-mlsd-research/blob/main/projects/dp-smm-journal/README.md)

MLSD의 회로 구현은 [RTL·FPGA 안내](hardware-workflow.md), 수신 성능을 읽는 방법은 [BER 안내](measurements.md#term-ber)에서 이어서 볼 수 있습니다.

---

[← 용어 안내](../glossary.md) · [연구 이력](../profile.md) · [홈](../../README.md) · [맨 위로](#page-top)
