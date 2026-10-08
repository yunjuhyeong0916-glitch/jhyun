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
| [학위논문 · DS-SBM·DP-SMM 비교 (진행 중)](pam4-mlsd-thesis/) | 수신 검출기의 후보 보존 방식과 판정 성능 비교 | 동일 입력의 코어 비교, 모델·RTL의 판정 결과와 출력 타이밍 확인 |
| [Journal 준비 · DP-SMM (진행 중)](dp-smm-journal/) | 두 경로 후보를 남기고 실제 심볼 이력으로 다시 평가하는 검출기 설계 | 참조 모델·RTL 일치, FPGA 배치배선, 보드 측정 준비 |
| [A-SSCC 2026 · DS-SBM PAM4 DSP](zcu208-pam4-dsp-portfolio/) | PAM4 송수신 DSP·검출기 RTL 구현과 RFSoC 보드 통합 | ISI 보드 수신 검증, FPGA 자원·타이밍 확인, A-SSCC 2026 채택 |

## LPDDR·USB 인터페이스 연구

| 프로젝트 | 담당 설계·검증 | 결과 |
|---|---|---|
| [LPDDR 15.6 Gb/s TX](high-speed-interface-research/docs/lpddr-tx-circuit-verification.md) | 저전압 TX 회로 설계·Post-Layout 검증 | 15.6 Gb/s·0.76 pJ/bit 회로 시뮬레이션 |
| [LPDDR Combo PHY](high-speed-interface-research/docs/lpddr-combo.md) | TX 회로·Verilog 동작 모델, PCB 설계·HFSS 분석과 제작 칩 측정 참여 | 28-nm 칩의 14 Gb/s/pin TX Eye·RX Shmoo 평가 |
| [USB TX·RX](high-speed-interface-research/docs/usb4-pam3.md) | TX 논리 RTL·RX CTLE 모델과 송수신 통합 검증, 제작 TX 측정 참여 | 40 Gb/s/lane TX 모델, 25.6 GBaud/lane RX 모델, 32 Gb/s TX 칩 평가 |

[인터페이스 연구 개요](high-speed-interface-research/) · [PCB·HFSS 분석](high-speed-interface-research/docs/pcb-hfss-verification.md) · [측정 장비·자동화](high-speed-interface-research/docs/measurement-equipment.md)

<!-- page-navigation:bottom -->
<p>
  <a href="../README.md" title="홈으로 돌아가기"><img src="../assets/readme/nav-home.svg" alt="홈으로 돌아가기" width="70" height="30"></a>
  <a href="#page-top" title="페이지 맨 위로 이동"><img src="../assets/readme/nav-top.svg" alt="페이지 맨 위로 이동" width="100" height="30"></a>
</p>
<!-- /page-navigation:bottom -->
