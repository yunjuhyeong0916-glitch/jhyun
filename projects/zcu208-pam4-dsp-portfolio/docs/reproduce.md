# FIR 시뮬레이션 재현

## 준비

- Python 3.9 이상: 표준 라이브러리만 사용합니다.
- Vivado 2022.2의 `xvlog`, `xelab`, `xsim`: 공개본 재실행에 사용한 버전입니다.
- `rtl/`, `tb/`, `scripts/` 디렉터리 구조를 그대로 유지합니다.

포트폴리오 폴더에서 실행하는 Windows 예:

```powershell
python scripts/run_fir_tests.py --vivado-bin "C:\Xilinx\Vivado\2022.2\bin"
```

Vivado 설치 위치가 다르면 `--vivado-bin`을 변경합니다. 스크립트는 실행 위치와 무관하게 자신의 상위 폴더에서 소스를 찾습니다.

## 실행 내용

1. FIR RTL과 각 기존 테스트벤치를 `xvlog -sv`로 컴파일합니다.
2. `xelab`으로 해당 TB를 elaboration합니다.
3. `xsim -runall`로 시뮬레이션하고 예상 PASS 문구와 종료 상태를 확인합니다.
4. 세 결과를 JSON으로 출력하고, 세 테스트가 모두 통과한 경우에만 종료 코드 0을 반환합니다.

생성 파일은 이 폴더 아래 `work/fir_<실행시각>/`에 저장되며 Git에서 제외됩니다. 실패 시 각 테스트의 `step_0.txt`, `step_1.txt`, `step_2.txt`에서 실패 단계를 확인합니다.

## 재현 범위

이 명령은 대표 FIR 테스트 3종을 실행합니다. 보드용 전체 Vivado 프로젝트를 생성하거나 MLSD 전체 검출기를 검증하지는 않습니다. 전체 보드 재현에는 원 BD·제약 파일·가져온 소스, RFDC 및 기타 AMD/Xilinx IP 생성, 보드 설정과 실행 소프트웨어가 추가로 필요합니다.
