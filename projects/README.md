<a id="page-top"></a>

<a id="프로젝트"></a>

# 연구 프로젝트

<!-- page-navigation:top -->
<p>
  <a href="../README.md" title="홈으로 돌아가기"><img src="../assets/readme/nav-home.svg" alt="홈으로 돌아가기" width="70" height="30"></a>
</p>
<!-- /page-navigation:top -->

[논문](../docs/publications.md)

<a id="dsp-transceiver-research"></a>

## DSP 기반 송수신기 연구

| 프로젝트 | 설계·검증 | 결과 |
|---|---|---|
| [A-SSCC 2026 · DS-SBM PAM4 DSP](zcu208-pam4-dsp-portfolio/) | PAM4 송수신 DSP·검출기 RTL 구현과 RFSoC 보드 통합 | ISI 보드 수신 검증, FPGA 자원·타이밍 확인, A-SSCC 2026 채택 |

진행 중인 [학위논문·Journal 연구](https://github.com/yunjuhyeong0916-glitch/pam4-mlsd-research/blob/main/README.md)는 별도 연구 저장소에 정리했습니다.

## LPDDR·USB 인터페이스 연구

| 프로젝트 | 담당 설계·검증 | 결과 |
|---|---|---|
| [LPDDR 15.6 Gb/s TX](high-speed-interface-research/docs/lpddr-tx-circuit-verification.md) | 저전압 TX 회로 설계·Post-Layout 검증 | 15.6 Gb/s·0.76 pJ/bit 회로 시뮬레이션 |
| [LPDDR Combo PHY](high-speed-interface-research/docs/lpddr-combo.md) | TX 회로·Verilog 동작 모델, PCB 설계·HFSS 분석과 제작 칩 측정 참여 | 28-nm 칩의 14 Gb/s/pin TX Eye·RX Shmoo 평가 |
| [USB TX·RX](high-speed-interface-research/docs/usb4-pam3.md) | TX 논리 RTL·RX CTLE 모델과 송수신 통합 검증, TX 칩 측정 참여 | 40 Gb/s/lane TX 모델, 25.6 GBaud/lane RX 모델, 32 Gb/s TX 칩 평가 |

[인터페이스 연구 개요](high-speed-interface-research/) · [PCB·HFSS 분석](high-speed-interface-research/docs/pcb-hfss-verification.md) · [측정 장비·자동화](high-speed-interface-research/docs/measurement-equipment.md)

<!-- page-navigation:bottom -->
<p>
  <a href="../README.md" title="홈으로 돌아가기"><img src="../assets/readme/nav-home.svg" alt="홈으로 돌아가기" width="70" height="30"></a>
  <a href="#page-top" title="페이지 맨 위로 이동"><img src="../assets/readme/nav-top.svg" alt="페이지 맨 위로 이동" width="100" height="30"></a>
</p>
<!-- /page-navigation:bottom -->
