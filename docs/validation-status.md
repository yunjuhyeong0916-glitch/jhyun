# 검증 상태 한눈에 보기

[저장소 첫 화면](../README.md) · [DSP·FPGA 검증 근거](../projects/zcu208-pam4-dsp-portfolio/docs/validation.md) · [LPDDR·USB 논문·근거](../projects/high-speed-interface-research/docs/evidence.md)

| 자료 | 확인한 내용 | 범위 |
|---|---|---|
| 6월 결과와 A-SSCC 2026 자원 대조 | 6월 14일 전체 TRX LUT 189,108·FF 188,846·DSP 950·BRAM 24.5가 논문 표기와 모두 일치 | [수치 대조](../projects/zcu208-pam4-dsp-portfolio/docs/validation.md#a-sscc-2026과-6월-14일-fpga-자원-수치-대조); 저장된 placed 자원 요약·ZIP 사본 확인 |
| 6월 PRBS7·PRBS15 21-tap 컨투어 | PRBS7 표시 하한 10⁻⁷, PRBS15 원래 기대 BER 2.244×10⁻⁶·10⁶ 기준 반올림 표시 2×10⁻⁶ | [계산값·원본 CSV](../projects/zcu208-pam4-dsp-portfolio/docs/validation.md#6월-ber-컨투어와-논문-표시-수치-대조); 통계 분석, 최종 41-dB 온칩 BER 로그와 직접 대응 미확인 |
| 6월 ZCU208 보드 캡처·재생 | RFDC ILA·SBR·TX FFE·UART 기록 및 PRBS7 재생 794/64,384비트 오류 | [측정·분석 기록](../projects/zcu208-pam4-dsp-portfolio/docs/validation.md#6월-보드-캡처와-분석-기록); 초기 구동·캡처 재생의 조건에 적용 |
| 대표 프로젝트의 FIR RTL | 2026-09-09 XSim 테스트 3종 PASS | 공개 소스에 대한 기존 FIR 테스트 재실행 |
| MLSD 메트릭 RTL 최소 예제 | 2026-10-07 두 합성 채널 PASS, 조건별 512심볼의 행렬·Python 복원 확인 | [예제](../projects/zcu208-pam4-dsp-portfolio/examples/mlsd_minimal/); g2=0, RTL traceback 제외 |
| MLSD 전체 어댑터 회귀 | 2026-10-07 두 조건 FAIL, 첫 검사 word lane 1 출력 불일치 | [실패 기록](../projects/zcu208-pam4-dsp-portfolio/reports/mlsd_adapter_audit_20261007/); 원본 RTL 유지, 데이터·valid·metadata 정렬 추가 확인 필요 |
| MLSD 논문 시스템 측정 | 논문 버전의 ZCU208 RFSoC 시스템 측정 결과 | [논문 측정 결과](../projects/zcu208-pam4-dsp-portfolio/docs/validation.md#관련-논문의-시스템-검증); 6월 자원 요약·후처리 자료 추가, 최종 온칩 BER 로그와 공개 RTL 재현 범위는 구분 |
| 대표 프로젝트의 FPGA 보고서 | 2026-06-29 기록의 WNS +0.083 ns, TNS 0.000 ns | 기존 구현 기록 검토, 이번 재배치배선 결과가 아님 |
| FPGA 프로젝트·산출물 | 2026-10-07 로컬 원 프로젝트의 XPR·BD·XDC·BIT·LTX·XSA 존재와 해시, 공개 소스 29개와 원본 해시 일치 | [산출물 목록](../projects/zcu208-pam4-dsp-portfolio/reports/fpga_artifact_inventory_20261007.json), 당시 비트스트림의 빌드 입력과 공개 소스의 일치까지 증명하지 않음 |
| JTAG 다운로드·보드 초기 동작 | [실행 가이드](../projects/zcu208-pam4-dsp-portfolio/docs/fpga-bringup.md) 작성 | 이번 문서 추가에서 하드웨어 연결·다운로드·RFDC 초기화·ILA 캡처 미실행 |
| Vitis PS 앱·초기화 구성 | 2026-10-07 A53 Standalone 설정·C 소스·FSBL·PMUFW·앱 ELF·XSCT 로드 순서 검토 | [Vitis 안내](../projects/zcu208-pam4-dsp-portfolio/docs/vitis-bringup.md), [파일·해시 비교](../projects/zcu208-pam4-dsp-portfolio/reports/vitis_artifact_inventory_20261007.json); 앱 재빌드·보드/SD 실행 미실행, Vitis와 기존 Vivado 폴더의 `.bit` 해시 차이 확인 |
| LPDDR TX 회로 | 2026-10-07 TX 구조, FFE off/on Eye, LVS·PEX 기록, PRBS7 속도·두 전원 레일의 전력 산출 검토 | [TX 회로 설계·검증](../projects/high-speed-interface-research/docs/lpddr-tx-circuit-verification.md); 기존 회로 시뮬레이션·시험 시연 근거, 새 EDA 실행·실측 제외. 인증서 발급·JEDEC 적합성 미확인, 공동 Combo PHY 실측과 구분 |
| LPDDR TX Verilog 동작 모델 | 2026-10-07 TX 구조와 기존 VCS·Questa 파형·코드별 Eye·4-DQ 출력 확인 | [TX 모델링과 그림](../projects/high-speed-interface-research/docs/lpddr-tx-modeling.md); 20 Gb/s는 모델 조건, 새 시뮬레이션·합성·칩 측정 미실행 |
| LPDDR Combo PHY | A-SSCC 공식 논문 정보의 14 Gb/s/pin·4-DQ 측정 조건과 Eye·RX 마진 | 공동 칩 측정 결과이며, 전체 PHY를 개인 설계했다고 표시하지 않음 |
| USB4 PAM-3 | TX 40 Gb/s/lane·RX 25.6 GBaud/lane 모델 검증과 제작 TX 32 Gb/s 공동 측정 | [USB PAM-3](../projects/high-speed-interface-research/docs/usb4-pam3.md), 모델·실리콘·개인 기여를 구분 |
| USB TX 모델링 개발 기록 | 2026-10-07 논리·Serializer·FFE·채널·VCS/POSIM의 기존 검증 결과 검토 | [모델링 과정](../projects/high-speed-interface-research/docs/usb-tx-modeling.md); 하위 11-bit 오류 관측과 클록 엣지 글리치, ideal power labeling 조건을 명시. 새 시뮬레이션·P&R·칩 측정 미실행 |
| USB RX CTLE 모델 | 2026-10-07 동작점 설정·R/C 제어 AC 응답·보상 조정·Sampler 연결 조건 검토 | [CTLE 모델링](../projects/high-speed-interface-research/docs/usb-rx-ctle-modeling.md); 모델의 부하 가정·수동 설정과 공동 RX 결과 구분, 새 시뮬레이션·실리콘 측정 미실행 |
| 측정 장비 사용 | 86100D·86118A, M8195A, E3631A, MP1800A를 LPDDR·USB 평가에 사용 | [장비별 활용](../projects/high-speed-interface-research/docs/measurement-equipment.md), 제조사 사양은 개인 측정 성과와 구분 |
| PCB·HFSS 그림·사진 | 2026-10-07 배치·배선·모델·S-parameter·제작 보드·본딩·계측 환경의 기존 결과 검토 | [PCB·HFSS 설명](../projects/high-speed-interface-research/docs/pcb-hfss-verification.md); 기존 개인·공동 결과의 설명, 새 PCB 제작·HFSS 해석·VNA/칩 측정 제외. 동일 조건의 PCB 수정 전후 개선율과 Eye 개선 인과를 주장하지 않음 |
| 검증 그림·AWG 설정 화면 | 시뮬레이션·공동 칩 실측·계측기 설정 확인 결과 | [그림과 조건](../projects/high-speed-interface-research/docs/verification-figures.md); 2026-10-07 문서 검토에서 새 칩 측정 제외 |
| MLSD 비교·변형 실험 | 소스 보존과 `.f` 참조 파일의 존재 점검 | 이번 정리에서 VCS 시뮬레이션 미실행 |
| 구조별 참고 코어 | 폴더 관계와 README 점검 | 이번 정리에서 개별 기능 검증 미실행 |
| 이전 Vivado 프로젝트 | 파일 내용과 내부 폴더 관계 보존 | 이번 정리에서 프로젝트 실행·재구현 미실행 |

시뮬레이션 PASS, FPGA 타이밍 결과, 실제 보드 BER는 서로 다른 검증 항목입니다. 이 저장소에서는 결과가 나온 프로젝트·소스·조건을 함께 기록합니다. LPDDR·USB 파트는 기존 연구·논문·측정 활동의 요약이며, 이번 문서 추가에서 회로 시뮬레이션이나 실리콘 측정을 다시 수행하지 않았습니다. DSP 공개 소스 묶음의 보드 BER 재현 범위는 해당 [검증 문서](../projects/zcu208-pam4-dsp-portfolio/docs/validation.md)를 따릅니다.
