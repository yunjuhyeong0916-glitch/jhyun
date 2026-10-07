# 검증 상태 한눈에 보기

[저장소 첫 화면](../README.md) · [DSP·FPGA 검증 근거](../projects/zcu208-pam4-dsp-portfolio/docs/validation.md) · [LPDDR·USB 논문·근거](../projects/high-speed-interface-research/docs/evidence.md)

| 자료 | 확인한 내용 | 범위 |
|---|---|---|
| 대표 프로젝트의 FIR RTL | 2026-09-09 XSim 테스트 3종 PASS | 공개 소스에 대한 기존 FIR 테스트 재실행 |
| MLSD 메트릭 RTL 최소 예제 | 2026-10-07 두 합성 채널 PASS, 조건별 512심볼의 행렬·Python 복원 확인 | [예제](../projects/zcu208-pam4-dsp-portfolio/examples/mlsd_minimal/); g2=0, RTL traceback 제외 |
| MLSD 전체 어댑터 회귀 | 2026-10-07 두 조건 FAIL, 첫 검사 word lane 1 출력 불일치 | [실패 기록](../projects/zcu208-pam4-dsp-portfolio/reports/mlsd_adapter_audit_20261007/); 원본 RTL 유지, 데이터·valid·metadata 정렬 추가 확인 필요 |
| 대표 프로젝트의 FPGA 보고서 | 2026-06-29 기록의 WNS +0.083 ns, TNS 0.000 ns | 기존 구현 기록 검토, 이번 재배치배선 결과가 아님 |
| FPGA 프로젝트·산출물 | 2026-10-07 로컬 원 프로젝트의 XPR·BD·XDC·BIT·LTX·XSA 존재와 해시, 공개 소스 29개와 원본 해시 일치 | [산출물 목록](../projects/zcu208-pam4-dsp-portfolio/reports/fpga_artifact_inventory_20261007.json), 당시 비트스트림의 빌드 입력과 공개 소스의 일치까지 증명하지 않음 |
| JTAG 다운로드·보드 초기 동작 | [실행 가이드](../projects/zcu208-pam4-dsp-portfolio/docs/fpga-bringup.md) 작성 | 이번 문서 추가에서 하드웨어 연결·다운로드·RFDC 초기화·ILA 캡처 미실행 |
| Vitis PS 앱·초기화 구성 | 2026-10-07 A53 Standalone 설정·C 소스·FSBL·PMUFW·앱 ELF·XSCT 로드 순서 검토 | [Vitis 안내](../projects/zcu208-pam4-dsp-portfolio/docs/vitis-bringup.md), [파일·해시 비교](../projects/zcu208-pam4-dsp-portfolio/reports/vitis_artifact_inventory_20261007.json); 앱 재빌드·보드/SD 실행 미실행, Vitis와 기존 Vivado 폴더의 `.bit` 해시 차이 확인 |
| LPDDR TX 회로 | 작성자 제공 자료·관련 논문의 TX 단독 시뮬레이션과 개인 설계·측정 전 검증 범위 | [LPDDR](../projects/high-speed-interface-research/docs/lpddr.md), Combo PHY 공동 실측과 구분 |
| LPDDR TX Verilog 동작 모델 | 2026-10-07 제공 소스·문서의 TX 구조 검토, 기존 VCS·Questa 파형·코드별 Eye·4-DQ 출력 이미지 확인 | [TX 모델링과 그림](../projects/high-speed-interface-research/docs/lpddr-tx-modeling.md); 20 Gb/s는 모델 조건, 새 시뮬레이션·합성·칩 측정 미실행 |
| LPDDR Combo PHY | A-SSCC 공식 논문 정보의 14 Gb/s/pin·4-DQ 측정 조건과 Eye·RX 마진 | 공동 칩 측정 결과이며, 전체 PHY를 개인 설계했다고 표시하지 않음 |
| USB4 PAM-3 | TX 40 Gb/s/lane·RX 25.6 GBaud/lane 모델 검증과 제작 TX 32 Gb/s 공동 측정 | [USB PAM-3](../projects/high-speed-interface-research/docs/usb4-pam3.md), 모델·실리콘·개인 기여를 구분 |
| USB TX 모델링 개발 기록 | 2026-10-07 USB 관련 PPTX 126개·1,508장 검토, 논리·Serializer·FFE·채널·VCS/POSIM 기존 이미지 12개 추출 | [모델링 과정](../projects/high-speed-interface-research/docs/usb-tx-modeling.md); 하위 11-bit 오류 관측과 클록 엣지 글리치, ideal power labeling 조건을 명시. 새 시뮬레이션·P&R·칩 측정 미실행 |
| USB RX CTLE 모델 | 2026-10-07 동작점 설정·R/C 제어 AC 응답·보상 조정·Sampler 연결 조건을 검토하고 기존 그림 7개 선별 | [CTLE 모델링](../projects/high-speed-interface-research/docs/usb-rx-ctle-modeling.md); PNG 5개 원본 유지·EMF 2개 렌더링. 모델의 부하 가정·수동 설정과 공동 RX 결과 구분, 새 시뮬레이션·실리콘 측정 미실행 |
| 측정 장비 사용 | 이력서·측정 활동 자료와 작성자의 2026-10-07 확인: 86100D·86118A, M8195A, E3631A, MP1800A를 LPDDR·USB 모두에 사용 | [장비별 활용](../projects/high-speed-interface-research/docs/measurement-equipment.md), 제조사 사양은 개인 측정 성과와 구분 |
| 검증 그림·AWG 설정 화면 | 2026-10-07 작성자 제공 논문·측정자료에서 추출, 축·주석·파형 유지 | [그림과 조건](../projects/high-speed-interface-research/docs/verification-figures.md), [출처·해시](figure-sources.json); 새 칩 측정 제외 |
| MLSD 비교·변형 실험 | 소스 보존과 `.f` 참조 파일의 존재 점검 | 이번 정리에서 VCS 시뮬레이션 미실행 |
| 구조별 참고 코어 | 폴더 관계와 README 점검 | 이번 정리에서 개별 기능 검증 미실행 |
| 이전 Vivado 프로젝트 | 파일 내용과 내부 폴더 관계 보존 | 이번 정리에서 프로젝트 실행·재구현 미실행 |

시뮬레이션 PASS, FPGA 타이밍 결과, 실제 보드 BER는 서로 다른 검증 항목입니다. 이 저장소에서는 결과가 나온 프로젝트·소스·조건을 함께 기록합니다. LPDDR·USB 파트는 기존 연구·논문·측정 활동의 요약이며, 이번 문서 추가에서 회로 시뮬레이션이나 실리콘 측정을 다시 수행하지 않았습니다. DSP 공개 소스 묶음의 보드 BER 재현 범위는 해당 [검증 문서](../projects/zcu208-pam4-dsp-portfolio/docs/validation.md)를 따릅니다.
