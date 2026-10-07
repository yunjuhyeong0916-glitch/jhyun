# 메트릭 RTL 최소 예제 실행 기록

2026-10-07, Windows·Vivado XSim 2022.2. [실행 방법·조건·해석 범위](../../examples/mlsd_minimal/)

두 조건 모두 512개 심볼의 branch 메트릭·8심볼 block 행렬과 실제 RTL 행렬을 이용한 Python 경로 복원 검사를 통과했습니다. 준비된 기대값 한 개를 변조한 검사도 불일치를 검출했습니다. RTL traceback과 RFSoC 하드웨어 검증은 이 PASS 범위에 포함되지 않습니다.

- [결과·소스 해시·파일 해시](summary.json)
- [Memoryless 복원 CSV](memoryless_recovery.csv) · [잔류 ISI 복원 CSV](residual_isi_recovery.csv)
- 원시 행렬: `*_lane_metrics.csv`, `*_block_metrics.csv`
- XSim 실행 로그: `memoryless.log`, `residual_isi.log`; 빌드 로그: `build_0.log`, `build_1.log`
- [기대값 변조 검출 로그](negative_control.log)

공개 로그의 개인 PC 프로젝트·실행 폴더 경로는 `<PROJECT_ROOT>`, `<RUN_DIR>`로 바꿨습니다. 수치·진단 메시지는 유지했으며, 원시 로그와 공개 파일의 SHA-256을 결과 JSON에 기록했습니다.
