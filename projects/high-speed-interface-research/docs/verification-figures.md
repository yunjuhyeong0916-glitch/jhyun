# LPDDR·USB 검증 그림과 해석

[파트 개요](../README.md) · [LPDDR](lpddr.md) · [USB PAM-3](usb4-pam3.md) · [장비 활용](measurement-equipment.md)

기존 논문과 측정 활동 자료에서 추출한 그림입니다. 시뮬레이션, 공동 칩 실측과 계측기 설정 확인을 각각 표시했습니다. 원본의 축·주석·파형을 유지했으며, 출처 파일과 그림의 해시는 [추출 기록](../../../docs/figure-sources.json)에 있습니다.

**PCB·HFSS 설계 화면과 실제 보드·본딩·계측 사진**은 [보드 배선에서 실제 측정 경로까지](pcb-hfss-verification.md)에 모았습니다. 원본 이미지 10개에 분석 구간·주파수·손실과 해석 범위를 붙였습니다.

LPDDR Combo의 **TX Verilog 모델 검증 파형**은 [TX 모델링 상세 페이지](lpddr-tx-modeling.md)에 모았습니다. VCS·Questa 파형, pre-emphasis 코드별 Eye 4종과 4-DQ 통합 출력을 모델 조건과 함께 볼 수 있습니다.

LPDDR의 **TX 회로·FFE·PEX 이후 검증**은 [회로 설계·검증 과정](lpddr-tx-circuit-verification.md)에 정리했습니다. 과제·시험 제출자료의 구조도, FFE off/on Eye와 PRBS7 주기·전원 전류·갱신 Eye 등 원본 그림 6개를 확인할 수 있습니다.

USB의 **TX 모델링·논리 복원·Scrambler on/off·Serializer·FFE·채널·VCS/POSIM 비교**는 [TX 모델링 과정과 검증 그림](usb-tx-modeling.md)에 모았습니다. 아래 제작 TX의 공동 실측 Eye와 검증 단계를 구분합니다.

USB의 **RX CTLE 동작점·R/C 제어 AC 응답·입출력 Eye**는 [CTLE 모델링과 보상 조정](usb-rx-ctle-modeling.md)에 모았습니다. 단품 CTLE 모델, 공동 RX 통합과 제작 TX 측정의 범위를 각각 표시했습니다.

## LPDDR TX: FFE 적용 전후의 시뮬레이션

![저전압 NRZ TX의 FFE 적용 전후 시뮬레이션 Eye](../assets/lpddr_tx_simulated_eye.png)

**조건·출처:** 28-nm TX, 15.6 Gb/s, 내부 전원 1.05 V·드라이버 전원 0.5 V, 8.7-dB 채널 조건. 작성자 제공 [ICEIC 2025 논문](https://doi.org/10.1109/ICEIC64972.2025.10879746), p. 3 Fig. 6. 위 (a)는 FFE 적용 전, 아래 (b)는 2-tap FFE 적용 후의 **시뮬레이션**입니다.

Eye 폭은 37 ps에서 45.4 ps로, 높이는 56.5 mV에서 75 mV로 바뀝니다. 개인 TX 설계와 측정 전 검증의 근거로 읽으며, 아래 공동 Combo PHY 실측과 검증 단계를 구분합니다.

## LPDDR Combo PHY: 공동 칩의 Eye와 RX Shmoo

![4-DQ 활성 조건의 LPDDR Combo PHY TX Eye와 RX Shmoo](../assets/lpddr_combo_measured_eye_shmoo.png)

**조건·출처:** 14 Gb/s/pin, 4-DQ 활성. 작성자 제공 [A-SSCC 2026 Combo PHY 논문](https://epapers2.org/asscc2026/ESR/paper_details.php?paper_id=1141), p. 2 Fig. 5의 TX Eye·RX Shmoo 영역. **공동 실리콘 측정 결과**입니다.

개인 설계 TX가 적용된 칩의 TX Eye는 0.41 UI·65.3 mV, 공동 RX 평가의 마진은 0.25 UI·25 mV로 보고되었습니다. 개인 담당은 TX 설계·측정 전 검증과 PCB·계측 참여 범위이며, RX 전체 회로 설계와 구분합니다.

## USB PAM-3: 같은 채널·패턴에서 FFE 효과 확인

![PAM-3 제작 TX의 FFE 적용 전후 차동 Eye](../assets/pam3_measured_ffe_eye.png)

**조건·출처:** 32 Gb/s, CH#3, PRBS15, scrambler enabled. 채널 손실은 10.24 GHz에서 17.3 dB로 보고되었습니다. 작성자 제공 [TVLSI 관련 논문](https://doi.org/10.1109/TVLSI.2026.3701343), p. 7 Fig. 13(a),(b). **공동 TX 실리콘 측정 결과**입니다.

왼쪽은 FFE 적용 전, 오른쪽은 같은 채널·패턴의 FFE 적용 후입니다. 상·하단 Eye를 각각 확인해 PAM-3의 판정 여유를 평가했습니다. 개인 기여인 모델·논리 RTL·차동 신호 평가와 공동 아날로그 TX 성능의 관계는 [USB 담당 범위](usb4-pam3.md)에 설명합니다.

## AWG 속도 변경: 설정값과 실제 입력을 맞추기

| 샘플레이트 연동 수정 전 | 샘플레이트 연동 수정 후 |
|---|---|
| ![샘플레이트 불일치 상태의 장비 화면](../assets/awg_sample_rate_before.png) | ![샘플레이트 수정 후 장비 화면](../assets/awg_sample_rate_after.png) |

**조건·출처:** 작성자 제공 `250413_측정자동화_진행상황_AWG.pptx`, slide 41의 원본 내장 이미지. 자료에 기록된 목표는 데이터 13.2 Gb/s에 대응하는 825-MHz AUX 입력입니다. 두 화면은 **계측기 입력 주파수 확인**의 근거입니다.

속도를 바꾸면서 파형 파일만 교체했을 때는 목표와 다른 주파수가 관측됐습니다. BIN 파일에 샘플레이트 정보가 포함되지 않는 점을 확인하고 파일·샘플레이트 설정을 함께 변경했습니다. 이 화면은 변경한 설정이 실제 출력에 반영되는지 확인한 기록이며, 해당 데이터율에서의 칩 BER 달성 결과는 별도로 관측해야 합니다. [문제 판단과 수정 과정](measurement-equipment.md#awg-파일-전송-이후의-실제-출력까지-확인)

**판독 범위:** 기존 논문·활동 자료의 결과를 제시한 것이며, 이번 정리에서 칩 측정을 다시 실행하지 않았습니다. 825 MHz와 데이터 속도의 1/16 관계는 이 사례의 설정입니다.
