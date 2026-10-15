<a id="page-top"></a>

<p align="right"><a href="glossary.en.md"><img src="../assets/readme/nav-en.svg" alt="English" width="96" height="30"></a></p>

# 용어 안내 | 고속 인터페이스·DSP 연구

<!-- page-navigation:top -->
<p>
  <a href="README.md" title="문서 목록으로 돌아가기"><img src="../assets/readme/nav-back-docs.svg" alt="문서 목록으로 돌아가기" width="110" height="30"></a>
  <a href="../README.md" title="홈으로 돌아가기"><img src="../assets/readme/nav-home.svg" alt="홈으로 돌아가기" width="70" height="30"></a>
</p>
<!-- /page-navigation:top -->

[연구 이력](profile.md) · [대표 프로젝트](../projects/zcu208-pam4-dsp-portfolio/)

처음이라면 **[PAM 신호](concepts/pam-signaling.md) → [ISI·등화](concepts/equalization.md) → [MLSD](concepts/mlsd.md)** 순서로 읽어 보세요. 신호 표현부터 수신 판정까지 이어집니다. 구현 과정은 [RTL·FPGA](concepts/hardware-workflow.md), 결과 해석은 [Eye·BER·Shmoo](concepts/measurements.md)에서 볼 수 있습니다.

## 주제별로 읽기

- **[MLSD](concepts/mlsd.md):** 연속된 수신 신호에서 데이터열을 찾는 방법
- **[PAM4·PAM-3·NRZ](concepts/pam-signaling.md):** 신호 레벨과 Gb/s·GBd·GS/s의 차이
- **[ISI·FFE·CTLE·DFE](concepts/equalization.md):** 신호가 겹치는 이유와 등화기의 역할
- **[DSP·RTL·FPGA·RFSoC](concepts/hardware-workflow.md):** 알고리즘을 회로로 구현하고 보드에서 확인하는 흐름
- **[LPDDR·USB4·PHY](concepts/interfaces.md):** 송수신 회로와 PCB·SI·PI·HFSS의 관계
- **[Eye·BER·Shmoo](concepts/measurements.md):** 파형·비트 오류·동작 마진을 읽는 방법

## 짧게 찾아보기


| 용어 | 이 저장소에서의 의미 |
|---|---|
| [PAM4](concepts/pam-signaling.md#term-pam4) | 네 가지 신호 레벨로 데이터를 표현하는 방식 |
| [LPDDR](concepts/interfaces.md#term-lpddr) | 저전력 메모리 인터페이스. 이 저장소에서는 TX 회로와 Combo PHY 평가를 다룸 |
| [PAM-3](concepts/pam-signaling.md#term-pam3) | 세 가지 신호 레벨로 데이터를 표현하는 방식. USB4 관련 모델링·TX 실리콘 연구에서 사용 |
| [Eye opening / timing opening](concepts/measurements.md#term-eye) | Eye의 열린 영역 / 지정한 BER 기준에서 확보한 시간축 여유. 이 저장소에서는 Eye 폭·높이와 timing opening으로 평가 |
| [FFE / CTLE / DFE](concepts/equalization.md) | 여러 시점의 신호를 가중 합산하는 등화 / 연속시간 선형 등화 / 이전 판정값을 이용한 등화 |
| [ZQ calibration](concepts/interfaces.md#term-zq) | 드라이버의 출력 임피던스를 기준에 맞추기 위한 보정 |
| [AWG / BERT](concepts/measurements.md#term-equipment) | 임의 파형 발생기 / 비트 오류율 시험 장비 |
| [Shmoo](concepts/measurements.md#term-shmoo) | 전압·타이밍 등 조건을 바꾸며 동작 영역을 표시한 평가 결과 |
| [HFSS / S-parameter](concepts/interfaces.md#term-si-pi) | 전자기장 해석 도구 / 주파수에 따른 전송·반사 특성 표현 |
| [DSP](concepts/hardware-workflow.md#term-dsp) | 신호 보정·판별 등을 디지털 연산으로 처리하는 방식 |
| [RTL](concepts/hardware-workflow.md#term-rtl) | 레지스터와 연산·제어 동작을 기술한 하드웨어 소스 |
| [FPGA / RFSoC](concepts/hardware-workflow.md#term-fpga-rfsoc) | 설계한 회로를 구현하는 재구성 가능한 장치 / ADC·DAC가 통합된 SoC |
| [PS / PL](concepts/hardware-workflow.md#term-ps-pl) | SoC의 프로세서 영역 / FPGA 회로 영역. 이 프로젝트에서는 PS 앱이 PL의 모드·계수를 설정 |
| [Vivado / Vitis](concepts/hardware-workflow.md#term-tools) | PL 회로 구현·디버깅 도구 / PS 제어 앱·플랫폼·부트 구성의 개발·실행 도구 |
| [FIR](concepts/equalization.md#term-fir-taps) | 여러 시점의 샘플에 계수를 곱해 합산하는 디지털 필터 |
| [MLSD](concepts/mlsd.md) | 연속된 수신 신호의 정보를 이용해 송신 데이터열을 판별하는 방식 |
| [GS/s](concepts/pam-signaling.md#term-rates) | 초당 10억 샘플 단위의 샘플링 속도 |
| [PRBS](concepts/measurements.md#term-ber) | 송수신 데이터와 오류를 비교하는 데 사용하는 의사난수 비트 패턴 |
| [Testbench](concepts/hardware-workflow.md#term-verification) | 회로에 입력을 주고 동작이나 출력을 점검하는 검증용 코드 |
| [ILA](concepts/hardware-workflow.md#term-tools) | FPGA 내부 신호를 관찰하기 위한 디버깅 수단 |
| [ISI](concepts/equalization.md#term-isi) | 한 심볼의 영향이 다른 심볼의 관측 시점에 겹치는 현상 |
| [BER](concepts/measurements.md#term-ber) | 오류 비트 수 / 비교한 전체 비트 수 |
| [PHY / TX / RX](concepts/interfaces.md#term-phy) | 전기 신호를 주고받는 물리 계층 / 송신부 / 수신부 |
| [SI / PI](concepts/interfaces.md#term-si-pi) | 신호 파형·타이밍 품질 / 전원·접지 품질 |
| [NDP](concepts/interfaces.md#term-ndp) | 이력서에서는 Near-display processing 기반 디스플레이 시스템 개발 과제 |

<details>
<summary>구현·부팅·연구 구조 용어 더 보기</summary>

| 용어 | 이 저장소에서의 의미 |
|---|---|
| XSA / BSP / ELF | 하드웨어 전달 파일 / 해당 하드웨어의 소프트웨어 지원 구성 / CPU에서 실행할 프로그램 파일 |
| FSBL / PMUFW | 초기 하드웨어 설정·다음 실행 파일 로딩을 담당하는 부트로더 / 플랫폼 관리 프로세서의 펌웨어 |
| [DS-SBM](concepts/mlsd.md#term-research) | Dual-Survivor Segmented Branch Metric-Matrix. 상태별 두 survivor branch와 구간별 BM 행렬 결합을 사용하는 A-SSCC의 축소 상태 MLSD 구조 |
| [DP-SMM](concepts/mlsd.md#term-research) | Dual-Path Segmented Metric-Matrix. 행렬 원소별 두 경로 후보와 상태별 두 경계 survivor를 유지하는 Journal 준비 연구의 축소 상태 MLSD 구조 |
| [PR 목표](concepts/equalization.md#term-pr) | 검출기가 예상 수신 샘플을 계산할 때 사용하는 부분응답 계수. DS-SBM은 별도 PR FIR을 두고, DP-SMM은 예상 샘플 계산에 반영 |
| [BM / PM](concepts/mlsd.md#term-metrics) | 후보 전이의 비용인 branch metric / 경로를 따라 누적한 비용인 path metric |
| [Survivor](concepts/mlsd.md#term-metrics) | 후보 선택 후 다음 단계로 전달하는 분기·경로 정보. 보존 위치와 개수는 검출기 구조에 따라 다름 |
| [II](concepts/hardware-workflow.md#term-parallelism) | Initiation interval. 연속 입력을 받아들일 수 있는 최소 클록 간격 |
| [32-lane](concepts/hardware-workflow.md#term-parallelism) | 한 클록에서 처리하는 병렬 데이터 수. 물리적 연결 32개라는 뜻은 아님 |
| [WNS / TNS](concepts/hardware-workflow.md#term-timing) | 타이밍 보고서의 최악 slack / 음수 slack 합계. 적용된 제약과 함께 해석 |

</details>

<!-- page-navigation:bottom -->
<p>
  <a href="README.md" title="문서 목록으로 돌아가기"><img src="../assets/readme/nav-back-docs.svg" alt="문서 목록으로 돌아가기" width="110" height="30"></a>
  <a href="../README.md" title="홈으로 돌아가기"><img src="../assets/readme/nav-home.svg" alt="홈으로 돌아가기" width="70" height="30"></a>
  <a href="#page-top" title="페이지 맨 위로 이동"><img src="../assets/readme/nav-top.svg" alt="페이지 맨 위로 이동" width="100" height="30"></a>
</p>
<!-- /page-navigation:bottom -->
