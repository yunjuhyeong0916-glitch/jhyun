<a id="page-top"></a>

<p align="right"><a href="interfaces.en.md#page-top"><img src="../../assets/readme/nav-en.svg" alt="English" width="96" height="30"></a></p>

# LPDDR·USB4·PHY | 인터페이스 회로와 보드의 역할

[← 용어 안내](../glossary.md#page-top) · [연구 이력](../profile.md#page-top) · [홈](https://github.com/yunjuhyeong0916-glitch/jhyun#page-top)

**고속 인터페이스는 두 장치가 데이터를 전기 신호로 주고받는 연결입니다.** 이 연구에서는 메모리와 연결하는 LPDDR, 주변 장치와 연결하는 USB4 계열의 송수신 회로·모델을 다룹니다.

<a id="term-phy"></a>

## PHY·TX·RX: 실제 신호를 보내고 받는 부분

**PHY**(Physical Layer)는 데이터를 전기 신호로 바꾸어 보내고, 받은 신호에서 데이터를 복원하는 물리 계층입니다. **TX**(Transmitter)는 송신부, **RX**(Receiver)는 수신부입니다.

컨트롤러가 통신 순서와 동작을 정한다면, PHY는 실제 전압·타이밍 조건에서 신호가 전달되도록 합니다. 이력서의 **TX 회로 설계**는 이 송신 경로의 회로와 검증을 맡았다는 뜻입니다. [LPDDR Combo에서 담당한 TX](../../projects/high-speed-interface-research/docs/lpddr-combo.md#page-top)

<a id="term-lpddr"></a>

## LPDDR·JEDEC·Combo PHY

**LPDDR**(Low-Power Double Data Rate)는 전력 효율을 고려한 DRAM 메모리 규격 계열입니다. **JEDEC**은 이런 메모리 표준을 제정하는 표준화 기구입니다. [Micron LPDDR 안내](https://www.micron.com/products/memory/lpddr-components) · [JEDEC](https://www.jedec.org/)

**Combo PHY**는 여러 세대의 인터페이스를 하나의 PHY에서 지원하는 구조입니다. 이 포트폴리오의 LPDDR4X/5/5X Combo PHY는 동작 모드에 맞게 데이터·클록 경로를 바꿔 사용합니다. [세대별 경로와 TX 구현](../../projects/high-speed-interface-research/docs/lpddr-combo.md#page-top)

<a id="term-usb4"></a>

## USB4 Gen4·PAM-3

USB4는 장치 간 데이터 연결을 위한 규격입니다. USB4 Version 2.0의 Gen4 신호 방식에는 [PAM-3](pam-signaling.md#term-pam3)가 사용됩니다. 이 연구에서는 송수신 모델을 구성하고 TX 칩의 출력 신호를 평가했습니다. [USB-IF 공식 발표](https://www.usb.org/sites/default/files/2022-10/USB-IF%20USB%2080Gbps%20Announcement_FINAL_v2.pdf) · [관련 연구](../../projects/high-speed-interface-research/docs/usb4-pam3.md#page-top)

<a id="term-zq"></a>

## ZQ calibration: 출력 임피던스를 맞추는 보정

신호가 전송 경로를 따라 잘 전달되도록 송신 드라이버의 출력 저항을 기준에 맞추는 과정입니다. 이 연구의 TX는 ZQ 보정과 출력 파형 보상을 함께 고려했습니다. [TX 회로 설계·검증](../../projects/high-speed-interface-research/docs/lpddr-tx-circuit-verification.md#page-top)

<a id="term-si-pi"></a>

## PCB·SI·PI·HFSS는 왜 함께 나오나요?

**PCB**는 칩·커넥터·전원 등을 연결하는 회로 기판입니다. **SI**(Signal Integrity)는 데이터 신호의 파형과 타이밍 품질, **PI**(Power Integrity)는 회로에 공급되는 전원·접지의 품질을 다룹니다.

**HFSS**는 기판 배선 등의 전자기장 특성을 해석하는 도구입니다. **S-parameter**는 주파수별 반사·전달 특성을 표현합니다. 두 포트의 예에서 `S11`은 입력 쪽 반사, `S21`은 입력에서 출력으로의 전달을 나타냅니다. [Ansys HFSS](https://ansys.synopsys.com/products/electronics/ansys-hfss) · [반사·전달 계수 설명](https://optics.ansys.com/hc/en-us/articles/360042095873-Metamaterial-S-parameter-extraction)

이 포트폴리오에서는 측정용 PCB의 배선·접지·전원 연결과 HFSS 전달 특성을 검토해, 제작 칩을 평가할 신호 경로를 구성했습니다. [PCB·HFSS 설명과 사진](../../projects/high-speed-interface-research/docs/pcb-hfss-verification.md#page-top)

<a id="term-ndp"></a>

## NDP는 어떤 과제인가요?

여기서 **NDP는 Near-display processing**을 뜻합니다. 연구 이력의 NDP 항목은 테라급 라이트 필드 디스플레이 시스템 개발 과제이며, 담당 범위는 USB4/DisplayPort 인터페이스 회로 모델링·검증입니다. [참여 연구과제](../profile.md#참여-프로젝트)

---

[← 용어 안내](../glossary.md#page-top) · [연구 이력](../profile.md#page-top) · [홈](https://github.com/yunjuhyeong0916-glitch/jhyun#page-top) · [맨 위로](#page-top)
