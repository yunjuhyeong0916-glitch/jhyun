# DSP 설계 구조

[프로젝트](../README.md) · [MLSD 설계 판단](design-decisions.md) · [측정·검증 결과](validation.md)

## 병렬 데이터 경로

ZCU208의 XCZU48DR-FSVG1517-2-E에서 ADC·DAC를 각각 4 GS/s로 설정했습니다. 기존 구현 보고서의 ADC 클록은 125 MHz, DAC 클록은 500 MHz입니다. ADC 병렬 경로의 설계 처리량은 **32 samples × 125 MHz = 4 Gsamples/s**입니다.

| 블록 | 역할 | 설계 항목 |
|---|---|---|
| PRBS·PAM4 생성 | 송신 패턴·심볼 레벨 생성 | 병렬 패턴 순서·레벨 매핑 |
| TX FIR | 송신 파형 보상 | 8-tap 고정소수점 연산·파이프라인 |
| RFDC·FIFO | DAC 송신·ADC 수신과 병렬 데이터 연결 | valid·ready·레인 순서 |
| RX FIR | 수신 채널 등화 | 21-tap·포화 연산·지연 정렬 |
| 메트릭 타일 | 심볼 후보의 거리·상태 변환 계산 | 8-lane 병렬 연산·후보 보존 |
| min-plus 결합 | 구간별 상태 변환 연결 | 32-lane 변환·파이프라인 경계 |
| 경로 복원 | 상태 이력으로 수신 심볼 결정 | metric·survivor·valid 정렬 |
| 런타임 제어 | FIR·검출기 설정 적용 | BRAM 계수 로딩·GPIO·PS 제어 |
| PRBS·ILA | 데이터·오류·내부 상태 관측 | lock 이후 오류 집계·캡처 |

## MLSD 메트릭

이전 상태마다 nearest branch 후보 두 개를 보존하고, 도착 상태가 연결되지 않는 경우 destination rescue를 사용합니다. 전체 경로 Rank-2·16-state MLSD와의 동등성은 미검증입니다.

## FIR 검증

기준 회로와 비교 회로의 지연을 맞춘 뒤 32개 lane의 고정소수점 출력을 비교했습니다. TX FIR와 RX EQ21의 세 테스트가 통과했습니다. [입력·지연·결과](validation.md#fir-출력-정합성)

## 논문·RTL 버전

| 버전 | 구조·검증 |
|---|---|
| A-SSCC 2026 논문 | DS-SBM RS-MLSD·ZCU208 RFSoC·ISI 보드 시스템 측정 |
| 2026-09-09 RTL | FIR 3종 PASS, 메트릭 검증 PASS, 전체 MLSD 어댑터 출력 불일치 |

[관련 논문](https://epapers2.org/asscc2026/ESR/paper_details.php?paper_id=1351) · [검증 결과](validation.md)
