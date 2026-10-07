# 기술 용어

[저장소 첫 화면](../README.md) · [대표 프로젝트](../projects/zcu208-pam4-dsp-portfolio/)

| 용어 | 이 저장소에서의 의미 |
|---|---|
| PAM4 | 네 가지 신호 레벨로 데이터를 표현하는 방식 |
| LPDDR | 저전력 메모리 인터페이스. 이 저장소에서는 TX 회로와 Combo PHY 평가를 다룸 |
| PAM-3 | 세 가지 신호 레벨로 데이터를 표현하는 방식. USB4 관련 모델링·TX 실리콘 연구에서 사용 |
| FFE / CTLE / DFE | 여러 시점의 신호를 가중 합산하는 등화 / 연속시간 선형 등화 / 이전 판정값을 이용한 등화 |
| ZQ calibration | 드라이버의 출력 임피던스를 기준에 맞추기 위한 보정 |
| AWG / BERT | 임의 파형 발생기 / 비트 오류율 시험 장비 |
| Shmoo | 전압·타이밍 등 조건을 바꾸며 동작 영역을 표시한 평가 결과 |
| HFSS / S-parameter | 전자기장 해석 도구 / 주파수에 따른 전송·반사 특성 표현 |
| DSP | 신호 보정·판별 등을 디지털 연산으로 처리하는 회로 |
| RTL | 레지스터와 연산·제어 동작을 기술한 하드웨어 소스 |
| FPGA / RFSoC | 설계한 회로를 구현하는 재구성 가능한 장치 / ADC·DAC가 통합된 SoC |
| PS / PL | SoC의 프로세서 영역 / FPGA 회로 영역. 이 프로젝트에서는 PS 앱이 PL의 모드·계수를 설정 |
| Vivado / Vitis | PL 회로 구현·디버깅 도구 / PS 제어 앱·플랫폼·부트 구성의 개발·실행 도구 |
| XSA / BSP / ELF | 하드웨어 전달 파일 / 해당 하드웨어의 소프트웨어 지원 구성 / CPU에서 실행할 프로그램 파일 |
| FSBL / PMUFW | 초기 하드웨어 설정·다음 실행 파일 로딩을 담당하는 부트로더 / 플랫폼 관리 프로세서의 펌웨어 |
| FIR | 여러 시점의 샘플에 계수를 곱해 합산하는 디지털 필터 |
| MLSD | 연속된 수신 신호의 정보를 이용해 송신 데이터열을 판별하는 방식 |
| DS-SBM | Dual-Survivor Segmented Branch Metric-Matrix. 상태별 두 survivor branch와 구간별 BM 행렬 결합을 사용하는 A-SSCC의 축소 상태 MLSD 구조 |
| DP-SMM | Dual-Path Segmented Metric-Matrix. 행렬 원소별 두 경로 후보와 상태별 두 경계 survivor를 유지하는 Journal 준비 연구의 축소 상태 MLSD 구조 |
| PR 목표 | 검출기가 예상 수신 샘플을 계산할 때 사용하는 부분응답 계수. DS-SBM은 별도 PR FIR을 두고, DP-SMM은 예상 샘플 계산에 반영 |
| BM / PM | 후보 전이의 비용인 branch metric / 경로를 따라 누적한 비용인 path metric |
| Survivor | 후보 선택 후 다음 단계로 전달하는 분기·경로 정보. 보존 위치와 개수는 검출기 구조에 따라 다름 |
| II | Initiation interval. 연속 입력을 받아들일 수 있는 최소 클록 간격 |
| 32-lane | 한 클록에서 처리하는 병렬 데이터 수. 물리적 연결 32개라는 뜻은 아님 |
| GS/s | 초당 10억 샘플 단위의 샘플링 속도 |
| PRBS | 송수신 데이터와 오류를 비교하는 데 사용하는 의사난수 비트 패턴 |
| Testbench | 회로에 입력을 주고 동작이나 출력을 점검하는 검증용 코드 |
| WNS / TNS | 타이밍 보고서의 최악 slack / 음수 slack 합계. 적용된 제약과 함께 해석 |
| ILA | FPGA 내부 신호를 관찰하기 위한 디버깅 수단 |
