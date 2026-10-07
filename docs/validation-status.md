# 검증 상태

[첫 화면](../README.md) · [논문](publications.md)

기준일: **2026-10-07**.

## A-SSCC 2026 | ZCU208 PAM4 DSP

| 항목 | 결과 | 조건·출처 |
|---|---|---|
| RFSoC 시스템 BER | PRBS7 < 10⁻⁷, PRBS15 < 2×10⁻⁶ | A-SSCC 2026 Fig. 5, 41-dB 손실·ISI 보드 통과 후 ADC 캡처 |
| 전체 TRX 자원 | LUT 189,108·FF 188,846·DSP 950·BRAM 24.5 | 2026-06-14 placed 요약, 논문 반올림 수치와 일치 |
| 기존 FPGA 구현 | WNS +0.083 ns·WHS +0.010 ns, 배선 오류 0 | 2026-06-29 post-route physopt; 외부 I/O·CDC·reset 경고 검토 남음 |

[상세 결과·측정 및 분석 조건](../projects/zcu208-pam4-dsp-portfolio/docs/validation.md). 2026-09-09 RTL과 측정 당시 bitstream의 빌드 대응은 미확인입니다.

## 학위논문 연구 | PAM4 MLSD RTL

| 항목 | 결과 | 조건·출처 |
|---|---|---|
| 공통 RTL의 FIR 회귀 기준 | PASS | 2026-09-09, 지연 정렬 후 32-lane 고정소수점 출력 비교 |
| MLSD 메트릭 | 두 조건 PASS, 각각 512심볼 | 2026-10-07, memory-0/1 합성 입력·RTL 행렬·Python 경로 복원 |
| 전체 MLSD 어댑터 | 두 조건 FAIL | 2026-10-07, 첫 검사 word lane 1 기대 32 / 실제 −32 |

[10월 결과·입력·검증 범위](../projects/pam4-mlsd-thesis/docs/validation.md). 전체 RTL traceback·memory-2·overflow 경계와 해당 RTL의 보드 BER 검증은 남아 있습니다.

## LPDDR·USB

| 항목 | 결과 | 조건·출처 |
|---|---|---|
| LPDDR 개인 TX 회로 | 15.6 Gb/s·0.76 pJ/bit | ICEIC 2025, 회로 시뮬레이션 |
| LPDDR TX 동작 모델 | 20 Gb/s, 직렬화·pre-emphasis 파형·Eye | 기존 VCS·Questa 모델 시뮬레이션 |
| 공동 LPDDR Combo PHY | 14 Gb/s/pin, TX 0.41 UI·65.3 mV, RX 0.25 UI·25 mV | A-SSCC 2026, 공동 실리콘 측정 |
| USB TX·RX 모델 | TX 40 Gb/s/lane·RX 25.6 GBaud/lane | SMACD 2025, 모델·시뮬레이션 |
| 공동 PAM-3 제작 TX | 32 Gb/s·150-preset 4-tap FFE | IEEE TVLSI 2026, 공동 실리콘 측정 |

[논문별 결과·담당 역할](../projects/high-speed-interface-research/docs/evidence.md) · [측정 그림](../projects/high-speed-interface-research/docs/verification-figures.md)
