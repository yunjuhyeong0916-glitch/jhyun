# 전체 보드 어댑터 회귀 테스트: FAIL

2026-10-07, Windows·Vivado XSim 2022.2. 원본 RTL은 수정하지 않았습니다.

```powershell
python scripts/run_mlsd_example.py --vivado-bin "C:\Xilinx\Vivado\2022.2\bin" --audit-adapter
```

두 합성 채널 모두 첫 검사 word의 lane 1에서 기대 레벨 32, 출력 레벨 -32로 실패했습니다. 명령은 종료 코드 1을 반환했습니다. 이 결과는 전체 어댑터의 PASS나 논문 버전의 FPGA 측정 재현으로 표시하지 않습니다. 메트릭 모듈의 별도 PASS와 [구분하여 읽습니다](../../examples/mlsd_minimal/#전체-어댑터-회귀-테스트에서-확인한-불일치).

[결과·소스 해시](summary.json) · [Memoryless 실패 로그](memoryless.log) · [잔류 ISI 실패 로그](residual_isi.log)

공개 로그의 개인 PC 프로젝트·실행 폴더 경로는 `<PROJECT_ROOT>`, `<RUN_DIR>`로 바꿨습니다. 수치·진단 메시지는 유지했으며, 원시 로그와 공개 파일의 SHA-256을 결과 JSON에 기록했습니다.
