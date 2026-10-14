<a id="page-top"></a>

<p align="right"><a href="equalization.en.md"><img src="../../assets/readme/nav-en.svg" alt="English" width="96" height="30"></a></p>

# ISI·등화 | 겹쳐 보이는 신호를 보상하는 방법

[← 용어 안내](../glossary.md) · [연구 이력](../profile.md) · [홈](../../README.md)

**등화(Equalization)는 채널을 지나며 변한 신호를 보상해, 수신기가 데이터를 구분하기 쉽게 만드는 과정입니다.**

<a id="term-isi"></a>

## 이전 신호의 꼬리가 다음 신호에 겹칩니다

신호가 배선·커넥터·케이블을 통과하면 파형이 퍼지거나 반사될 수 있습니다. 한 심볼의 영향이 다른 심볼을 관측하는 시점까지 남는 현상이 **ISI(Inter-Symbol Interference)**입니다. 등화기는 채널 응답을 고려해 이런 영향을 줄입니다. [MathWorks 등화 설명](https://www.mathworks.com/help/comm/ug/equalization.html)

예를 들어 수신값이 `현재 심볼 + 이전 심볼의 일부`라면, 같은 데이터를 보내도 앞선 데이터에 따라 수신 높이가 달라집니다. 수신기는 이 관계를 보상하거나 [MLSD](mlsd.md)처럼 검출에 활용할 수 있습니다.

<a id="term-ffe"></a>

## FFE·CTLE·DFE는 어떻게 다른가요?

**FFE(Feed-Forward Equalizer)**는 여러 시점의 신호에 가중치를 곱해 합칩니다. 송신 FFE는 채널을 지나기 전 파형을 조정하고, 수신 FFE는 받은 신호를 보상합니다. [FFE 공식 설명](https://www.mathworks.com/help/serdes/ref/serdes.ffe-system-object.html)

<a id="term-ctle"></a>

**CTLE(Continuous-Time Linear Equalizer)**는 주파수에 따라 이득을 조정하는 연속시간 회로입니다. 채널에서 약해진 빠른 신호 성분을 상대적으로 보강합니다. 이 포트폴리오의 USB RX에서는 그 동작을 모델링했습니다. [CTLE 공식 설명](https://www.mathworks.com/help/serdes/ref/serdes.ctle-system-object.html)

<a id="term-dfe"></a>

**DFE(Decision-Feedback Equalizer)**는 이미 판정한 이전 심볼로 그 심볼이 현재 신호에 남기는 영향을 예상하고 빼 줍니다. 판정값이 다시 계산에 사용되는 피드백 구조입니다. [DFE 공식 설명](https://www.mathworks.com/help/serdes/ref/serdes.dfe-system-object.html)

<a id="term-fir-taps"></a>

## FIR·tap·계수는 무엇인가요?

**FIR(Finite Impulse Response)**은 여러 시점의 입력 샘플을 가중 합산하는 필터 구조입니다. 각 샘플을 가져오는 항을 **tap**, 그 항에 곱하는 가중치를 **계수(coefficient)**라고 부릅니다.

`21-tap RX FFE`는 21개 시점의 샘플을 가중 합산하는 수신 등화 구조를 뜻합니다. 이 연구에서는 이를 [RTL](hardware-workflow.md#term-rtl)로 구현해 FPGA에서 병렬 처리합니다. [RX FIR 구현과 계수](../../projects/zcu208-pam4-dsp-portfolio/docs/architecture.md)

<a id="term-pr"></a>

## PR은 MLSD가 비교할 응답의 모양을 정합니다

**PR(Partial Response) 목표**는 검출기 입력에서 기대하는, 현재·이전 심볼의 영향 관계입니다. 등화 출력을 정해진 응답에 가깝게 만들고, MLSD가 그 응답으로 후보별 예상 신호를 계산합니다.

A-SSCC DS-SBM 수신 경로는 **RX FFE → 3-tap PR FIR → MLSD**로 구성했습니다. [실제 신호 경로](../../projects/zcu208-pam4-dsp-portfolio/docs/architecture.md)

## 관련 연구

[USB TX FFE 모델](../../projects/high-speed-interface-research/docs/usb-tx-modeling.md) · [USB RX CTLE 모델](../../projects/high-speed-interface-research/docs/usb-rx-ctle-modeling.md) · [PAM4 수신 DSP](../../projects/zcu208-pam4-dsp-portfolio/docs/design-decisions.md)

---

[← 용어 안내](../glossary.md) · [연구 이력](../profile.md) · [홈](../../README.md) · [맨 위로](#page-top)
