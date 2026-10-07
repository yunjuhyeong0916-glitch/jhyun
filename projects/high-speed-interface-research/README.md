# LPDDR·USB 고속 인터페이스 회로·모델링·실리콘 평가

[저장소 첫 화면](../../README.md) · [측정 장비와 활용](docs/measurement-equipment.md) · [검증 그림](docs/verification-figures.md) · [논문·근거](docs/evidence.md)

**회로와 모델에서 정한 설계 조건을 실제 보드의 파형·오류 평가로 연결한 연구입니다.** LPDDR에서는 저전압 TX의 채널 손실·임피던스 문제를 회로 설계와 측정 전 검증으로 다뤘습니다. USB PAM-3에서는 논리·전기 계층 모델과 RTL의 동작을 확인하고, 제작 TX의 채널별 신호를 측정했습니다. 두 프로젝트의 PCB·채널 분석과 계측 경험을 이 파트에서 함께 살펴볼 수 있습니다.

## 프로젝트별 담당 역할

| 연구 | 직접 수행·참여 범위 | 결과를 읽는 기준 |
|---|---|---|
| [LPDDR 메모리 인터페이스](docs/lpddr.md) | Combo PHY TX 회로 설계·Schematic/Post-Layout 검증 전담, [TX Verilog 모델링](docs/lpddr-tx-modeling.md), PCB·HFSS 분석과 공동 평가 참여 | TX 동작 모델·회로 시뮬레이션·공동 칩 실측을 구분 |
| [USB4 PAM-3 인터페이스](docs/usb4-pam3.md) | [TX 모델링·RTL·Serializer 검증](docs/usb-tx-modeling.md), [RX CTLE 모델링과 통합 검증](docs/usb-rx-ctle-modeling.md), PCB·채널 분석·차동 PAM-3 측정 참여 | 송수신 모델 결과와 28-nm 제작 TX의 공동 실측을 구분 |

## 연구 성과 논문

| 연구 | 모델·시뮬레이션 논문 | 실리콘 평가 논문 |
|---|---|---|
| LPDDR | [ICEIC 2025: 저전압 NRZ TX](https://doi.org/10.1109/ICEIC64972.2025.10879746) | [A-SSCC 2026: 14-Gb/s/pin Combo PHY](https://epapers2.org/asscc2026/ESR/paper_details.php?paper_id=1141), 채택·발표 예정 |
| USB PAM-3 | [SMACD 2025: 40-Gb/s/lane TX 모델](https://doi.org/10.1109/SMACD65553.2025.11092283) · [SMACD 2025: 25.6-GBaud/lane RX 모델](https://doi.org/10.1109/SMACD65553.2025.11092233) | [IEEE TVLSI 2026: 32-Gb/s PAM-3 TX·150-preset FFE](https://doi.org/10.1109/TVLSI.2026.3701343) |

전체 제목과 결과 범위는 [이 파트의 논문·근거](docs/evidence.md), MLSD를 포함한 전체 연구 목록은 [성과 논문 6편](../../docs/publications.md)에 정리했습니다.

## 측정 장비를 설계 판단과 연결

신호가 닫히거나 오류가 증가했을 때는 회로 동작, 채널 손실과 계측기 설정을 함께 확인해야 합니다. 86100D·86118A로 파형과 Eye를 관찰하고, MP1800A로 오류·관측량을 수집하며, M8195A와 E3631A로 입력·전원 조건을 설정했습니다. 이 장비들은 LPDDR와 USB 두 프로젝트에서 사용했습니다.

[장비 문서](docs/measurement-equipment.md)는 장비별 역할과 실제 활용을 정리하고, AWG 파형·샘플레이트 불일치 수정, 전원 조건과 오류 판정 임계값의 연동, Shmoo 경계 탐색 사례를 설명합니다. PCB·HFSS는 측정 결과를 전송 경로와 연결해 해석하는 공통 역량으로 포함했습니다.

## 읽는 순서

1. [LPDDR: TX 회로 설계와 검증](docs/lpddr.md) · [TX Verilog 구조·시뮬레이션 파형](docs/lpddr-tx-modeling.md)
2. [USB: PAM-3 모델·RTL과 실리콘 평가](docs/usb4-pam3.md) · [TX 모델링·검증](docs/usb-tx-modeling.md) · [RX CTLE 동작점·보상 조정](docs/usb-rx-ctle-modeling.md)
3. [측정 장비·PCB·채널 분석·자동화](docs/measurement-equipment.md)
4. [관련 논문과 근거 범위](docs/evidence.md)
5. [실제 Eye·Shmoo와 AWG 수정 전후 화면](docs/verification-figures.md)

설계·평가 개요와 관련 논문을 중심으로 구성했습니다. 기존 [DSP·MLSD RTL](../zcu208-pam4-dsp-portfolio/docs/architecture.md)과 [FPGA 구현·JTAG 구동](../zcu208-pam4-dsp-portfolio/docs/fpga-bringup.md)은 각 문서에서 이어 볼 수 있습니다.
