<a id="page-top"></a>

# USB4 PAM-3: 모델·RTL 검증과 제작 칩 측정

<!-- page-navigation:top -->
<p>
  <a href="../README.md" title="LPDDR·USB 인터페이스 연구로 돌아가기"><img src="../../../assets/readme/nav-back-interface.svg" alt="LPDDR·USB 인터페이스 연구로 돌아가기" width="146" height="30"></a>
  <a href="../../../README.md" title="홈으로 돌아가기"><img src="../../../assets/readme/nav-home.svg" alt="홈으로 돌아가기" width="70" height="30"></a>
</p>
<!-- /page-navigation:top -->

[LPDDR](lpddr.md) · [측정 장비](measurement-equipment.md) · [논문·담당 역할](evidence.md)

TX 논리계층·RX CTLE 모델링과 송수신 통합 검증을 맡았습니다. 11B7S 인코더·스크램블러 RTL을 합성·P&R해 전기 계층과 연결했으며, 제작 TX 평가에서는 PCB·채널 분석과 차동 PAM-3 측정에 참여했습니다.

## 모델로 논리·전기 계층의 동작을 연결

SystemVerilog·XMODEL로 TX 논리계층과 RX CTLE를 모델링하고, 송수신 모델을 통합해 인코딩·스크램블링과 수신 데이터 복원을 검증했습니다.

CTLE의 R·C와 바이어스를 조정해 채널 보상과 PAM-3 중간 레벨 안정성을 확인했습니다.

## TX 모델링과 검증 과정

176-bit 입력을 16개의 11B7S 인코더와 112개 Scrambler로 처리했습니다. 기대값 계산, Serializer·FFE·채널 연결과 구현 후 VCS·POSIM 출력을 대조했습니다. [TX 모델·검증](usb-tx-modeling.md)

## RX CTLE 모델링과 보상 조정

바이어스·입력 공통전압을 정한 뒤 R·C 제어별 AC 응답과 CTLE 입출력 Eye를 확인했습니다. 중간 레벨의 흔들림과 Sampler 연결에 따른 부하·공통전압 변화를 반영했습니다. [CTLE 모델](usb-rx-ctle-modeling.md)

## 논리 경로를 제작 TX에 연결

11B7S 인코더·스크램블러 RTL을 합성·P&R하고 PAM-3 TX의 전기 계층에 연결했습니다. 구현 블록은 인코더·스크램블러이며, RS-FEC·precoder는 미포함입니다.

<a id="채널별-ffe-효과를-차동-신호로-확인"></a>

## 차동 PAM-3 측정과 채널별 FFE 효과 검증

제작 TX의 평가는 채널 조건과 FFE 설정을 함께 바꾸며 수행했습니다. Keysight 86100D·86118A로 차동 PAM-3 신호를 측정하고 상단·하단 Eye의 폭과 높이를 확인했습니다. 제작 칩에서 32 Gb/s 동작과 채널별 FFE 효과를 확인했습니다.

CH#3의 손실 17.3 dB @ 10.24 GHz·PRBS15 조건에서, FFE 적용 후 상단 Eye는 11.19 ps·21.16 mV, 하단은 11.67 ps·19.80 mV입니다. [측정 구성·채널별 FFE 설정·Eye 비교표](pam3-differential-measurement.md)

입력·오류·전원 제어에는 M8195A AWG, MP1800A BERT와 E3631A를 활용했습니다. [장비·자동화](measurement-equipment.md)

<a id="모델과-실리콘-결과의-구분"></a>

## 검증 결과

[CH#3·PRBS15의 FFE 적용 전후 실측 Eye](verification-figures.md#usb-pam-3-같은-채널패턴에서-ffe-효과-확인)

USB TX 보드에서는 GND via와 전원 공급 경로를 검토했습니다. HFSS의 12.8-GHz 손실은 CLK 약 1.11 dB, DATA 약 1.25 dB입니다. [보드·해석](pcb-hfss-verification.md#4-usb-보드에서는-신호-경로와-전원-공급-경로를-함께-검토)

| 단계 | 대표 결과 | 근거·범위 |
|---|---|---|
| TX 모델 | 40 Gb/s/lane | [SMACD 2025: TX 모델 논문](https://doi.org/10.1109/SMACD65553.2025.11092283), SystemVerilog 모델·시뮬레이션 |
| RX 모델 | 25.6 GBaud/lane | [SMACD 2025: RX 모델 논문](https://doi.org/10.1109/SMACD65553.2025.11092233), RX 통합 모델·시뮬레이션 |
| 제작 PAM-3 TX | 28-nm CMOS, 32 Gb/s, 150-preset 4-tap FFE | [IEEE TVLSI 2026: PAM-3 TX·150-preset FFE 논문](https://doi.org/10.1109/TVLSI.2026.3701343), 제작 칩 측정 |

[논문·담당 역할](evidence.md) · [MLSD·LPDDR를 포함한 전체 성과 논문](../../../docs/publications.md)

<!-- page-navigation:bottom -->
<p>
  <a href="../README.md" title="LPDDR·USB 인터페이스 연구로 돌아가기"><img src="../../../assets/readme/nav-back-interface.svg" alt="LPDDR·USB 인터페이스 연구로 돌아가기" width="146" height="30"></a>
  <a href="../../../README.md" title="홈으로 돌아가기"><img src="../../../assets/readme/nav-home.svg" alt="홈으로 돌아가기" width="70" height="30"></a>
  <a href="#page-top" title="페이지 맨 위로 이동"><img src="../../../assets/readme/nav-top.svg" alt="페이지 맨 위로 이동" width="100" height="30"></a>
</p>
<!-- /page-navigation:bottom -->
