# 검증 상태 한눈에 보기

[저장소 첫 화면](../README.md) · [상세 검증 근거](../projects/zcu208-pam4-dsp-portfolio/docs/validation.md)

| 자료 | 확인한 내용 | 범위 |
|---|---|---|
| 대표 프로젝트의 FIR RTL | 2026-09-09 XSim 테스트 3종 PASS | 공개 소스에 대한 기존 FIR 테스트 재실행 |
| 대표 프로젝트의 FPGA 보고서 | 2026-06-29 기록의 WNS +0.083 ns, TNS 0.000 ns | 기존 구현 기록 검토, 이번 재배치배선 결과가 아님 |
| FPGA 프로젝트·산출물 | 2026-10-07 로컬 원 프로젝트의 XPR·BD·XDC·BIT·LTX·XSA 존재와 해시, 공개 소스 29개와 원본 해시 일치 | [산출물 목록](../projects/zcu208-pam4-dsp-portfolio/reports/fpga_artifact_inventory_20261007.json), 당시 비트스트림의 빌드 입력과 공개 소스의 일치까지 증명하지 않음 |
| JTAG 다운로드·보드 초기 동작 | [실행 가이드](../projects/zcu208-pam4-dsp-portfolio/docs/fpga-bringup.md) 작성 | 이번 문서 추가에서 하드웨어 연결·다운로드·RFDC 초기화·ILA 캡처 미실행 |
| MLSD 비교·변형 실험 | 소스 보존과 `.f` 참조 파일의 존재 점검 | 이번 정리에서 VCS 시뮬레이션 미실행 |
| 구조별 참고 코어 | 폴더 관계와 README 점검 | 이번 정리에서 개별 기능 검증 미실행 |
| 이전 Vivado 프로젝트 | 파일 내용과 내부 폴더 관계 보존 | 이번 정리에서 프로젝트 실행·재구현 미실행 |

시뮬레이션 PASS, FPGA 타이밍 결과, 실제 보드 BER는 서로 다른 검증 항목입니다. 이 저장소에서는 결과가 나온 소스·날짜·조건을 함께 기록합니다. 최종 실측 BER이나 모든 폴더에 대한 검증 완료를 주장하지 않습니다.
