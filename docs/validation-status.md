# 검증 상태

[첫 화면](../README.md) · [논문](publications.md)

기준일: **2026-10-07**.

## 학위논문 | DS-SBM·DP-SMM 비교 (진행 중)

| 항목 | 결과 | 조건 |
|---|---|---|
| 구조 비교 | 신호 경로·행렬 후보·경계 PM 갱신 비교 | DS-SBM과 DP-SMM |
| 후보 보존 효과 | R=2의 오류 수가 R=1보다 36.9%·46.1% 감소 | memory-2 합성 응답 A·B, SNR 16 dB, 경계 후보 수 K_H=2 고정 |
| R=1/R=2 코어 RTL | 참조 출력·메트릭·경로 정보 일치 | 연속·간격 입력, reset 후 재시작 |
| DP-SMM 실측 | 예정 | AWG 기반 ADC-DSP 수신 평가 |

[동일 입력 비교·RTL 검증 조건](../projects/pam4-mlsd-thesis/docs/validation.md).

## Journal 준비 | DP-SMM

| 항목 | 결과 | 조건·출처 |
|---|---|---|
| 검출기 코어 RTL | 대응 bit-accurate 참조와 일치, 지연 23클록·II=1 | 개정 K=2 및 행렬 K=1 비교 코어 |
| RX FFE 통합 RTL | 참조와 일치, 지연 24클록·II=1 | 11-tap RX FFE·검출기 통합 |
| 검출기 FPGA 자원 | LUT 266,664·FF 168,330·BRAM 240·DSP 1,664 | Journal 초안의 post-route 구현, RX FFE 제외 |
| 보드 실측 | 예정 | BER·PR 등고선·연속 처리율 |

[Journal RTL 검증·구현 조건](../projects/dp-smm-journal/docs/validation.md).

## A-SSCC 2026 | DS-SBM PAM4 DSP

| 항목 | 결과 | 조건·출처 |
|---|---|---|
| RFSoC 시스템 BER | PRBS7 < 10⁻⁷, PRBS15 < 2×10⁻⁶ | A-SSCC 2026 Fig. 5, 41-dB 손실·ISI 보드 통과 후 ADC 캡처 |
| 전체 TRX 자원 | LUT 189,108·FF 188,846·DSP 950·BRAM 24.5 | 2026-06-14 placed 요약, 논문 반올림 수치와 일치 |
| FPGA 구현 | WNS +0.083 ns·WHS +0.010 ns, 배선 오류 0 | 2026-06-29 post-route physopt 보고서 |

[DS-SBM 상세 결과·측정 및 분석 조건](../projects/zcu208-pam4-dsp-portfolio/docs/validation.md).

## LPDDR·USB

| 항목 | 결과 | 조건·출처 |
|---|---|---|
| LPDDR TX 회로 | 15.6 Gb/s·0.76 pJ/bit | ICEIC 2025, 회로 시뮬레이션 |
| LPDDR TX 동작 모델 | 20 Gb/s, 직렬화·pre-emphasis 파형·Eye | 기존 VCS·Questa 모델 시뮬레이션 |
| LPDDR Combo PHY | 14 Gb/s/pin, TX 0.41 UI·65.3 mV, RX 0.25 UI·25 mV | A-SSCC 2026, 제작 칩 측정 |
| USB TX·RX 모델 | TX 40 Gb/s/lane·RX 25.6 GBaud/lane | SMACD 2025, 모델·시뮬레이션 |
| PAM-3 제작 TX | 32 Gb/s·150-preset 4-tap FFE | IEEE TVLSI 2026, 제작 칩 측정 |

[논문별 결과·담당 역할](../projects/high-speed-interface-research/docs/evidence.md) · [측정 그림](../projects/high-speed-interface-research/docs/verification-figures.md)
