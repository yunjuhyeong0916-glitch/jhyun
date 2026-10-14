<a id="page-top"></a>

<p align="right"><a href="pam-signaling.en.md"><img src="../../assets/readme/nav-en.svg" alt="English" width="96" height="30"></a></p>

# PAM4·PAM-3·NRZ | 신호 레벨과 전송 속도

[← 용어 안내](../glossary.md) · [연구 이력](../profile.md) · [홈](../../README.md)

**NRZ·PAM-3·PAM4는 데이터를 신호의 높이로 표현하는 방식입니다.** 이 포트폴리오에서는 각각 두 레벨·세 레벨·네 레벨의 신호를 가리킵니다.

한 번의 전송에서 선택하는 신호 값을 **심볼(symbol)**이라고 합니다. 두 레벨을 쓰는 NRZ는 심볼 하나에 1비트, 네 레벨을 쓰는 PAM4는 2비트를 표현할 수 있습니다. [Keysight의 비트·심볼 설명](https://helpfiles.keysight.com/scopes/FlexDCA-PG/Content/Topics/Quick-Start/theory_bits_vs_symbols.htm)

![같은 전체 높이 범위 안에서 NRZ는 두 레벨, PAM-3는 세 레벨, PAM4는 네 레벨을 사용하는 개념도](../../assets/concepts/pam-levels.svg)

<a id="term-pam4"></a>

## PAM4는 왜 사용하나요?

같은 심볼 속도에서 더 많은 비트를 보낼 수 있기 때문입니다. 예를 들어 **2 GBd의 PAM4는 부호화 오버헤드를 제외한 비트 속도로 4 Gb/s**에 해당합니다.

전체 전압 범위가 같다면 네 레벨 사이의 간격은 두 레벨을 쓸 때보다 좁아집니다. 따라서 수신기에서 잡음·왜곡을 다루는 [등화](equalization.md)와 [MLSD](mlsd.md) 같은 검출 기법이 중요해집니다. [Tektronix PAM4 설명](https://www.tek.com/de/blog/time-get-ready-pam4)

<a id="term-pam3"></a>

## PAM-3에서는 비트를 어떻게 보내나요?

세 레벨은 `0/1` 두 비트의 네 조합과 수가 다르므로 여러 비트를 묶어 심볼열로 바꾸는 코딩을 사용합니다. 이 포트폴리오의 USB TX 모델에는 **11비트를 7개 심볼로 바꾸는 11B7S 인코더**가 들어갑니다. [USB TX 모델](../../projects/high-speed-interface-research/docs/usb-tx-modeling.md)

USB4 Version 2.0은 PAM3 기반 물리 계층을 도입했습니다. 포트폴리오의 USB4 Gen4 연구는 이 신호 방식의 송수신 모델과 TX 평가를 다룹니다. [USB-IF 공식 발표](https://www.usb.org/sites/default/files/2022-10/USB-IF%20USB%2080Gbps%20Announcement_FINAL_v2.pdf)

<a id="term-rates"></a>

## Gb/s·GBd·GS/s·UI 읽기

- **Gb/s:** 초당 보내는 비트 수. `1 Gb/s = 초당 10억 비트`입니다.
- **GBd 또는 GBaud:** 초당 보내는 심볼 수. PAM4에서는 심볼 하나가 2비트를 표현합니다.
- **GS/s:** ADC·DAC 등이 초당 다루는 샘플 수. 샘플 수와 심볼 수의 관계는 샘플링 설정에 따라 정해집니다.
- **UI(Unit Interval):** 이 포트폴리오의 PAM 신호에서 심볼 하나의 기준 시간. `2 GBd`라면 `1 UI = 0.5 ns`입니다.

비트 속도·심볼 속도·샘플링 속도를 구분하면 회로의 전송 속도와 FPGA 데이터 처리량을 읽기 쉬워집니다. [비트 속도·심볼 속도·UI 정의](https://helpfiles.keysight.com/scopes/FlexDCA-PG/Content/Topics/Quick-Start/theory_bits_vs_symbols.htm)

## 관련 연구

[NRZ TX 회로](../../projects/high-speed-interface-research/docs/lpddr-tx-circuit-verification.md) · [USB PAM-3 연구](../../projects/high-speed-interface-research/docs/usb4-pam3.md) · [PAM4 DSP 연구](../../projects/zcu208-pam4-dsp-portfolio/)

---

[← 용어 안내](../glossary.md) · [연구 이력](../profile.md) · [홈](../../README.md) · [맨 위로](#page-top)
