<a id="page-top"></a>

<p align="right">
<a href="profile.en.md" title="View this research CV in English"><img src="../assets/readme/nav-en.svg" alt="English" width="96" height="30"></a>
</p>

# 윤주형 | 연구 이력

<p>
  <a href="../README.md" title="포트폴리오 홈으로 돌아가기"><img src="../assets/readme/nav-home.svg" alt="포트폴리오 홈으로 돌아가기" width="70" height="30"></a>
</p>

고속 인터페이스의 송신 회로와 수신 DSP를 설계·검증합니다. **JEDEC LPDDR·USB4 Gen4 기반의 High-Speed Interface 연구**와 **Ultra High-Speed 통신을 위한 DSP 기반 Transceiver 연구**를 진행하고 있습니다.

## 학력

- **광운대학교 전자통신공학과**<br> 석사과정 · 2024.09–현재<br> 2026.08 수료 · 학위논문 연구등록 · **2027.02 졸업 예정**<br> **평점 4.35/4.50**
- **광운대학교 전자융합공학과**<br> **2022.03 편입 · 2024.08 학사 졸업**<br> **평점 3.60/4.50**
- **백석대학교 ICT학부**<br> 정보보호학전공 · 2017.03 입학<br> 광운대학교 편입 전 학력

## 수상 내역

**2024 한국 대학생 반도체 회로설계 경진대회 · 동상**

2024.12.11 · 사단법인 반도체공학회 · 팀 수상

28 nm CMOS 기반 저전압·저전력 NRZ 송수신기 설계로 수상했습니다. **TX 회로 설계·검증**을 담당했습니다. [관련 TX 설계·검증](../projects/high-speed-interface-research/docs/lpddr-tx-circuit-verification.md)

## 연구·설계 경험

### LPDDR TX·Combo PHY

낮은 드라이버 전압에서 채널 손실을 보상하도록 main·1-UI 지연 경로의 FFE를 설계했습니다. DRC·LVS·PEX를 거쳐 배선 기생성분을 반영한 **28 nm TX Post-Layout 시뮬레이션에서 15.6 Gb/s·0.76 pJ/bit**를 확인했습니다.

LPDDR4X/5/5X Combo PHY에서는 **DQ TX 회로 설계·검증과 TX Verilog 동작 모델링**을 맡았습니다. 직렬화·위상 정렬·pre-emphasis의 연결을 확인하고, 설계한 TX가 적용된 **14 Gb/s/pin 제작 칩의 공동 측정**에 참여했습니다.

[TX 회로·검증 결과](../projects/high-speed-interface-research/docs/lpddr-tx-circuit-verification.md) · [Combo PHY 담당 범위](../projects/high-speed-interface-research/docs/lpddr-combo.md) · [TX 모델](../projects/high-speed-interface-research/docs/lpddr-tx-modeling.md)

### USB4 TX·RX 모델·측정

논리 RTL과 전기 계층 모델이 이어지는 구간을 검증하기 위해 **11B7S·스크램블러와 Serializer·FFE 경로**를 연결했습니다. TX RTL의 합성·P&R 이후 VCS·POSIM 결과를 비교하고, RX에서는 **CTLE 동작 모델과 Sampler의 연결 조건**을 확인했습니다.

**28 nm·32 Gb/s TX 칩의 공동 측정**에 참여해, 채널별 FFE 설정에 따른 차동 PAM&#8209;3의 상·하단 Eye와 BER bathtub을 평가했습니다.

[USB TX 모델·RTL 검증](../projects/high-speed-interface-research/docs/usb-tx-modeling.md) · [RX CTLE 모델](../projects/high-speed-interface-research/docs/usb-rx-ctle-modeling.md) · [차동 PAM&#8209;3 측정](../projects/high-speed-interface-research/docs/pam3-differential-measurement.md)

### PAM4 DSP·RFSoC 검증

채널 보상과 MLSD 판정을 보드에서 평가하도록 **TX FIR·RX 21-tap FIR·DS-SBM RS-MLSD를 32-lane 병렬 RTL**로 구현하고 ZCU208 RFSoC에 통합했습니다. Vitis에서 클록·RFDC 초기화와 계수 적용을 제어하고, DAC → ISI 보드 → ADC 경로의 신호를 캡처해 PL PRBS 검사기의 집계값으로 BER을 평가했습니다.

FPGA 구현의 자원·타이밍 결과와 RFSoC 측정 결과를 정리한 **A-SSCC 2026 논문이 채택**됐습니다.

[A-SSCC 프로젝트](../projects/zcu208-pam4-dsp-portfolio/) · [설계 구조](../projects/zcu208-pam4-dsp-portfolio/docs/architecture.md) · [FPGA 구현·측정 결과](../projects/zcu208-pam4-dsp-portfolio/docs/validation.md) · [Vitis 보드 제어](../projects/zcu208-pam4-dsp-portfolio/docs/vitis-bringup.md)

## 측정 경로 설계와 자동화

LPDDR 측정용 PCB를 설계하고 HFSS로 신호 전달 특성을 분석했습니다. 제작 칩 평가에서는 전원·BERT·I2C 제어를 연동해 전압·타이밍을 스윕하고, 오류 조기 종료·경계 탐색과 CSV 기록으로 반복 평가를 자동화했습니다.

RFSoC에서는 조건별 Vitis 앱 실행, UART 데이터 수집과 ILA 집계값의 Python BER 분석을 harness로 연결했습니다. 최근 설계 트렌드에 맞게 **AI·MATLAB MCP를 RTL·테스트벤치 작성과 반복 검증·측정 자동화 코드 구성**에 활용합니다.

[PCB·HFSS](../projects/high-speed-interface-research/docs/pcb-hfss-verification.md) · [측정 장비·제어](../projects/high-speed-interface-research/docs/measurement-equipment.md) · [AI·Toolbox·자동화 harness](ai-assisted-dsp-workflow.md)

## 진행 중인 연구

- **[학위논문 · DS-SBM·DP-SMM 비교](https://github.com/yunjuhyeong0916-glitch/pam4-mlsd-research/blob/main/projects/pam4-mlsd-thesis/README.md) (진행 중):** 후보 보존 방식이 수신 판정에 미치는 영향을 모델·RTL에서 비교합니다.
- **[Journal · DP-SMM 설계·검증](https://github.com/yunjuhyeong0916-glitch/pam4-mlsd-research/blob/main/projects/dp-smm-journal/README.md) (진행 중):** 구간 메트릭 행렬의 두 경로 보존과 실제 심볼 이력에 따른 비용 재평가를 다룹니다. 21-tap RX FFE + DP-SMM 구성의 보드 측정을 준비하고 있습니다.
- **[DP-SMM 특허 출원 준비](https://github.com/yunjuhyeong0916-glitch/pam4-mlsd-research/blob/main/docs/publications.md):** 두 경로 후보 보존과 계층적 메트릭 합성을 이용한 PAM4 검출기 구조입니다.

## 주요 논문

- **A-SSCC 2026 · 채택:** [DS-SBM 기반 RFSoC PAM4 송수신기](https://epapers2.org/asscc2026/ESR/paper_details.php?paper_id=1351) · [LPDDR4X/5/5X Combo PHY](https://epapers2.org/asscc2026/ESR/paper_details.php?paper_id=1141)
- **ICEIC 2025:** [15.6-Gb/s 저전압 NRZ TX](https://doi.org/10.1109/ICEIC64972.2025.10879746)
- **SMACD 2025:** [USB4 Gen4 PAM&#8209;3 TX 모델](https://doi.org/10.1109/SMACD65553.2025.11092283) · [PAM&#8209;3 RX 모델](https://doi.org/10.1109/SMACD65553.2025.11092233)
- **IEEE TVLSI 2026:** [150-preset 4-tap FFE를 적용한 PAM&#8209;3 TX](https://doi.org/10.1109/TVLSI.2026.3701343)

[논문 제목·검증 범위 전체 보기](publications.md)

---

<p>
  <a href="../README.md" title="포트폴리오 홈으로 돌아가기"><img src="../assets/readme/nav-home.svg" alt="포트폴리오 홈으로 돌아가기" width="70" height="30"></a>
  <a href="#page-top" title="페이지 맨 위로 이동"><img src="../assets/readme/nav-top.svg" alt="페이지 맨 위로 이동" width="100" height="30"></a>
</p>
