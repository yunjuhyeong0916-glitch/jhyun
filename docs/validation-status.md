<a id="page-top"></a>

# 검증 상태

<!-- page-navigation:top -->
<p>
  <a href="README.md" title="문서 목록으로 돌아가기"><img src="../assets/readme/nav-back-docs.svg" alt="문서 목록으로 돌아가기" width="110" height="30"></a>
  <a href="../README.md" title="홈으로 돌아가기"><img src="../assets/readme/nav-home.svg" alt="홈으로 돌아가기" width="70" height="30"></a>
</p>
<!-- /page-navigation:top -->

[논문](publications.md)

기준일: **2026-10-07**.

<a id="학위논문--ds-sbmdp-smm-비교-진행-중"></a>
<a id="journal-준비--dp-smm-진행-중"></a>

진행 중인 [학위논문·Journal 검증 현황](https://github.com/yunjuhyeong0916-glitch/pam4-mlsd-research/blob/main/docs/validation-status.md)은 연구 저장소에 정리했습니다.

## A-SSCC 2026 | DS-SBM PAM4 DSP

| 항목 | 결과 | 조건·출처 |
|---|---|---|
| RFSoC 시스템 BER | PRBS7 < 10⁻⁷, PRBS15 < 2×10⁻⁶ | A-SSCC 2026 Fig. 5, 41-dB 손실·ISI 보드 통과 후 ADC 캡처 |
| 전체 TRX 자원 | LUT 189,108·FF 188,846·DSP 950·BRAM 24.5 | 전체 TRX, 2026-06-14 배치(placed) 결과 |
| FPGA 구현 | WNS +0.083 ns·WHS +0.010 ns, 배선 오류 0 | 2026-06-29 post-route physopt 보고서 |

[DS-SBM 상세 결과·측정 및 분석 조건](../projects/zcu208-pam4-dsp-portfolio/docs/validation.md).

## LPDDR·USB 인터페이스 연구

| 항목 | 결과 | 조건·출처 |
|---|---|---|
| LPDDR TX 회로 | 15.6 Gb/s·0.76 pJ/bit | ICEIC 2025, 회로 시뮬레이션 |
| LPDDR TX 동작 모델 | 20 Gb/s, 직렬화·pre-emphasis 파형·Eye | 기존 VCS·Questa 모델 시뮬레이션 |
| LPDDR Combo PHY | 14 Gb/s/pin, TX 0.41 UI·65.3 mV, RX 0.25 UI·25 mV | A-SSCC 2026, 제작 칩 측정 |
| USB TX·RX 모델 | TX 40 Gb/s/lane·RX 25.6 GBaud/lane | SMACD 2025, 모델·시뮬레이션 |
| PAM-3 TX 칩 | 32 Gb/s·150-preset 4-tap FFE | IEEE TVLSI 2026, 제작 칩 측정 |

[논문별 결과·담당 역할](../projects/high-speed-interface-research/docs/evidence.md) · [측정 그림](../projects/high-speed-interface-research/docs/verification-figures.md)

<!-- page-navigation:bottom -->
<p>
  <a href="README.md" title="문서 목록으로 돌아가기"><img src="../assets/readme/nav-back-docs.svg" alt="문서 목록으로 돌아가기" width="110" height="30"></a>
  <a href="../README.md" title="홈으로 돌아가기"><img src="../assets/readme/nav-home.svg" alt="홈으로 돌아가기" width="70" height="30"></a>
  <a href="#page-top" title="페이지 맨 위로 이동"><img src="../assets/readme/nav-top.svg" alt="페이지 맨 위로 이동" width="100" height="30"></a>
</p>
<!-- /page-navigation:bottom -->
