<a id="page-top"></a>

<p align="right"><a href="mlsd.md"><img src="../../assets/readme/nav-ko.svg" alt="한국어" width="87" height="30"></a></p>

# MLSD | Recovering a transmitted symbol sequence

[← Term guide](../glossary.en.md) · [CV](../profile.en.md) · [Home](../../README.en.md)

**MLSD (Maximum-Likelihood Sequence Detection) compares a sequence of received observations to find the most likely transmitted symbol sequence.**

A channel can spread one symbol into later symbol intervals. With this [intersymbol interference, or ISI](equalization.en.md#term-isi), detection benefits from considering the relationship between successive observations. Documentation also describes this family of methods as MLSE, or Maximum-Likelihood Sequence Estimation. [MathWorks MLSE overview](https://www.mathworks.com/help/comm/ug/mlse-equalizers.html)

## Compare the responses predicted by candidate sequences

![Receive observations, predict each candidate response, accumulate mismatch and select a symbol sequence](../../assets/concepts/mlsd-flow.svg)

Each candidate sequence predicts a channel output. A detector compares that prediction with the observations. Under a squared-error metric, it accumulates squared differences and selects a path with the smallest total. The Viterbi algorithm provides an efficient way to search these paths. [MLSE algorithm](https://www.mathworks.com/help/comm/ref/comm.mlseequalizer-system-object.html)

## A small numerical example

This illustration uses symbols `−1, +1`. The previous symbol is `+1`, and the channel response is `current symbol + 0.5 × previous symbol`. Two observations are `(0.7,−1.5)`.

| Symbols | Prediction | Cost |
|---|---|---|
| `(+1,+1)` | `(1.5,1.5)` | 9.64 |
| `(+1,−1)` | `(1.5,−0.5)` | 1.64 |
| **`(−1,−1)`** | **`(−0.5,−1.5)`** | **1.44** |
| `(−1,+1)` | `(−0.5,0.5)` | 5.44 |

For the first observation alone, `1.5` is closer to `0.7` than `−0.5`, favoring a first symbol of `+1`. Across both observations, **`(−1,−1)` gives the smaller total error**. Later evidence can change an earlier tentative decision.

<a id="term-metrics"></a>

## State, metric and survivor

- **State:** a representation of the symbol history needed to predict later observations.
- **Branch metric (BM):** the mismatch cost for one candidate transition.
- **Path metric (PM):** the cost accumulated along a path.
- **Survivor:** candidate path or branch information retained for subsequent processing.

With [PAM4](pam-signaling.en.md#term-pam4) and two previous symbols represented explicitly, there are `4 × 4 = 16` possible states. Longer channel memory and larger alphabets increase the state count. Hardware design therefore considers both computation and candidate retention. [State-count definition](https://www.mathworks.com/help/comm/ref/comm.mlseequalizer-system-object.html)

<a id="term-research"></a>

## DS-SBM and DP-SMM in this portfolio

**RS-MLSD** means reduced-state MLSD: a design approach that reduces states and candidates to lower hardware cost.

**DS-SBM** is the A-SSCC detector architecture. It propagates two survivor branches per visible state and combines segment costs as matrices for parallel processing. [Design decisions and architecture](../../projects/zcu208-pam4-dsp-portfolio/docs/design-decisions.md)

**DP-SMM** retains two candidate paths for a matrix element connecting the same start and end states, then reevaluates costs using actual symbol history. The distinction concerns **where and how candidates are retained**. [Journal research architecture](https://github.com/yunjuhyeong0916-glitch/pam4-mlsd-research/blob/main/projects/dp-smm-journal/README.md)

Continue with [RTL and FPGA implementation](hardware-workflow.en.md) or [BER evaluation](measurements.en.md#term-ber).

---

[← Term guide](../glossary.en.md) · [CV](../profile.en.md) · [Home](../../README.en.md) · [Back to top](#page-top)
