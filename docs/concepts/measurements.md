<a id="page-top"></a>

<p align="right"><a href="measurements.en.md"><img src="../../assets/readme/nav-en.svg" alt="English" width="96" height="30"></a></p>

# Eye·BER·Shmoo | 측정 결과 읽기

[← 용어 안내](../glossary.md) · [연구 이력](../profile.md) · [홈](../../README.md)

**Eye는 신호를 구분할 여유를, BER는 실제 비트 판정의 오류 비율을, Shmoo는 조건에 따른 동작 영역을 보여줍니다.** 같은 회로를 서로 다른 관점에서 평가하는 방법입니다.

<a id="term-eye"></a>

## Eye diagram: 신호를 구분할 공간과 시간

파형을 심볼 주기에 맞춰 여러 번 겹치면 눈처럼 열린 영역이 나타납니다. 이를 **Eye diagram**이라고 합니다. 세로 방향의 **Eye height**는 신호 레벨을 구분할 전압 여유, 가로 방향의 **Eye width**는 판정 시점의 시간 여유를 읽는 데 사용합니다. [Keysight Eye diagram 안내](https://helpfiles.keysight.com/csg/N1930xB/Analyzing/Analyzing_Data_using_Eye_Diagrams.html)

[PAM-3](pam-signaling.md#term-pam3)는 인접한 세 레벨 사이에 두 Eye가 생겨 상·하단을 함께 봅니다. 포트폴리오의 Eye 사진은 [LPDDR·USB 칩 평가 자료](../../projects/high-speed-interface-research/docs/verification-figures.md)에서 볼 수 있습니다.

**Timing opening**은 지정한 오류 판정 기준을 만족하는 시간축 범위입니다. 화면에서 읽는 파형의 폭과 함께, 어떤 조건·기준으로 얻은 값인지 살펴보면 됩니다.

<a id="term-ber"></a>

## BER: 비교한 비트 중 몇 개가 틀렸는가

**BER(Bit Error Ratio)**는 `오류 비트 수 ÷ 비교한 전체 비트 수`입니다. 설명용으로 1,000,000비트 중 10비트가 틀리면 BER는 `10⁻⁵`입니다. [Keysight BER 정의](https://helpfiles.keysight.com/csg/89600B/Webhelp/Subsystems/flexframe/content/trc_carrier_summary.htm)

**PRBS(Pseudo-Random Binary Sequence)**는 송수신 결과를 비교할 때 사용하는, 규칙적으로 재생성할 수 있는 비트 패턴입니다. 수신 결과를 기대 패턴과 맞춰 오류를 셉니다. 이 연구에서는 RFSoC 내부 검사기의 오류 수와 검사 비트 수로 BER를 계산했습니다. [RFSoC 측정·BER 결과](../../projects/zcu208-pam4-dsp-portfolio/docs/validation.md#isi-보드를-통한-rfsoc-측정)

Eye는 파형을 관찰하는 방법이고, BER는 데이터를 판정한 결과를 세는 방법입니다. 두 결과를 함께 보면 파형 변화가 수신 동작에 어떻게 이어지는지 파악할 수 있습니다.

<a id="term-shmoo"></a>

## Shmoo: 조건을 바꿔도 동작하는 영역

전원 전압·판정 시점 같은 조건을 바꾸고, 각 조합에서 통과 여부를 표시한 결과입니다. 한 점의 동작뿐 아니라 주변에 어느 정도 여유가 있는지 볼 수 있습니다. [NI Shmoo 안내](https://www.ni.com/docs/en-US/bundle/ni-digital-pattern/page/shmoo-plot.html)

포트폴리오의 LPDDR RX 평가에서는 전압·타이밍에 따른 동작 영역을 확인했습니다. [LPDDR RX Shmoo](../../projects/high-speed-interface-research/docs/verification-figures.md)

<a id="term-equipment"></a>

## AWG·BERT·오실로스코프의 역할

- **AWG:** 설정한 파형을 만들어 수신기에 입력합니다.
- **BERT:** 알려진 비트 패턴을 만들거나 수신 패턴과 비교해 비트 오류를 측정합니다.
- **오실로스코프:** 시간에 따른 전압 파형과 Eye를 관찰합니다.

이 연구에서는 장비 제어와 전압·타이밍 스윕, 결과 저장을 연결했습니다. [장비별 역할·측정 자동화](../../projects/high-speed-interface-research/docs/measurement-equipment.md)

---

[← 용어 안내](../glossary.md) · [연구 이력](../profile.md) · [홈](../../README.md) · [맨 위로](#page-top)
