# AI 활용 | RTL 구현·FPGA 측정 자동화

[DSP 기반 송수신기 연구](../README.md#dsp-기반-송수신기-연구) · [문서 지도](repository-map.md) · [English](ai-assisted-dsp-workflow.en.md)

PAM4 수신기의 모델이나 계수를 바꾸면 RTL 검증과 FPGA 평가도 반복해야 했습니다. 이 과정에서 **RTL·테스트벤치**와 **FPGA 제어·데이터 수집·분석 코드**를 작성·수정하는 데 AI를 활용했습니다. MATLAB MCP는 Codex에서 MATLAB 모델을 실행하고 결과를 확인하는 연결 수단으로 사용했습니다.

![AI를 활용한 두 작업: 모델 조건에 맞춘 RTL·테스트벤치 작성과 출력 대조, ZCU208 계수 설정·캡처 수집·BER 분석을 위한 제어 코드와 실행 스크립트 구성.](../assets/ai_workflow_ko.svg)

## RTL·테스트벤치 작성과 수정

MATLAB/Simulink에서 정의한 동작과 입출력·고정소수점 조건을 기준으로 RTL과 테스트벤치를 작성·수정하는 데 AI를 활용했습니다. 같은 입력 벡터를 고정소수점 참조 모델과 RTL에 넣고 **FFE 출력·검출기 판정·출력 시점**을 대조했습니다. 결과가 다른 구간은 코드를 수정하고 다시 실행해 확인했습니다.

[모델·RTL 검증 결과](../projects/dp-smm-journal/docs/validation.md)

## ZCU208의 계수별 평가 자동화

필터 계수 후보별 수신 성능을 비교하기 위해 **Vitis 제어 코드, 조건별 캡처·저장 스크립트, Python 분석 코드**를 작성·수정하는 데 AI를 활용했습니다. 이 코드를 연결해 계수 적용부터 결과 수집·비교까지 반복하는 측정 자동화 harness를 구성했습니다.

계수가 실제 FPGA에 반영됐는지 확인하고, 조건별 데이터와 PL PRBS 검사 결과를 수집했습니다. Python에서는 **오류 수와 검사 비트 수로 BER를 계산**해 계수 후보별 결과를 비교했습니다.

[Vitis 계수 적용·데이터 수집](../projects/zcu208-pam4-dsp-portfolio/docs/vitis-bringup.md) · [A-SSCC 측정 결과](../projects/zcu208-pam4-dsp-portfolio/docs/validation.md)

---

[DSP 기반 송수신기 연구로 돌아가기](../README.md#dsp-기반-송수신기-연구)
