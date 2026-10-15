<a id="page-top"></a>

<p align="right">
<a href="profile.en.md#page-top" title="View this research CV in English"><img src="../assets/readme/nav-en.svg" alt="English" width="96" height="30"></a>
</p>

# 윤주형 | 연구 이력

**이메일:** [wngud1074@kw.ac.kr](mailto:wngud1074@kw.ac.kr)

<p>
  <a href="https://github.com/yunjuhyeong0916-glitch/jhyun#page-top" title="포트폴리오 홈으로 돌아가기"><img src="../assets/readme/nav-home.svg" alt="포트폴리오 홈으로 돌아가기" width="70" height="30"></a>
  <a href="glossary.md#page-top"><img src="../assets/readme/nav-terms.svg" alt="용어 안내" width="102" height="30"></a>
</p>

[JEDEC LPDDR](concepts/interfaces.md#term-lpddr)·[USB4 Gen4](concepts/interfaces.md#term-usb4) 기반의 인터페이스 회로와 초고속 통신을 위한 [DSP](concepts/hardware-workflow.md#term-dsp) 기반 송수신기를 설계·검증합니다.

## 학력

- **광운대학교 전자통신공학과**<br> 석사과정 · 2024.09–현재<br> 2026.08 수료 · **2027.02 졸업 예정**<br> **평점 4.35/4.50**
- **광운대학교 전자융합공학과**<br> **2022.03 편입 · 2024.08 학사 졸업**<br> **평점 3.60/4.50**
- **백석대학교 ICT학부**<br> 정보보호학전공 · 2017.03 입학<br> 광운대학교 편입 전 학력

## 수상 내역

**2024 한국 대학생 반도체 회로설계 경진대회**<br> **동상 · 팀 수상**

2024.12.11 · 사단법인 반도체공학회

28 nm CMOS 기반 저전압·저전력 NRZ 송수신기 설계로 수상했습니다. **[TX](concepts/interfaces.md#term-phy) 회로 설계·검증**을 담당했습니다. [관련 TX 설계·검증](../projects/high-speed-interface-research/docs/lpddr-tx-circuit-verification.md#page-top)

<a id="참여-프로젝트"></a>

## 참여 연구과제

### 01 · DSP 기반 송수신기 연구

#### 200+Gbps급 차세대 초고속 인터페이스 반도체 설계 기술

> **참여기간:** 2026.04.01–2026.12.31 **(진&#8288;행&nbsp;중)**<br> **참여 형태:** 학생연구원<br> **연구비 주관:** 성균관대학교 산학협력단

**담당:** [PAM4](concepts/pam-signaling.md#term-pam4) 송수신 필터와 [MLSD](concepts/mlsd.md#page-top "연속된 수신 신호를 함께 비교해 데이터열을 찾는 기법") 검출기의 [RTL](concepts/hardware-workflow.md#term-rtl) 설계, [RFSoC](concepts/hardware-workflow.md#term-fpga-rfsoc) 통합·보드 검증. [DSP 기반 송수신기 연구](../projects/zcu208-pam4-dsp-portfolio/README.md#page-top)

RTL·테스트벤치 작성과 반복 검증·측정 자동화 코드 구성에 [AI·MATLAB MCP](ai-assisted-dsp-workflow.md#page-top)를 활용합니다.

---

### 02 · LPDDR 인터페이스 연구

#### Memory Interface Architecture 탐구 및 검증

> **참여기간:** 2025.01.01–2026.12.31 **(진&#8288;행&nbsp;중)**

**담당:** DQ TX 회로 설계·검증과 TX Verilog 모델링, 측정용 PCB 설계·HFSS 분석. [LPDDR Combo 설계·검증](../projects/high-speed-interface-research/docs/lpddr-combo.md#page-top)

#### 차세대 LPDDR 5/6급 메모리 인터페이스 IP 기술 개발

> **참여기간:** 2023.09.04–2024.08.30<br> **참여 형태:** 학부 인턴<br> **발주처:** 한국산업기술평가관리원

**담당:** 15.6-Gb/s 저전압 TX 회로 설계, Schematic·Post-Layout 검증. [LPDDR TX 회로 설계·검증](../projects/high-speed-interface-research/docs/lpddr-tx-circuit-verification.md#page-top)

---

### 03 · USB 인터페이스 연구

#### Near-display processing (NDP) 기반의 테라급 라이트 필드 디스플레이 시스템 개발

> **참여기간:** 2024.04.01–2026.12.31 **(진&#8288;행&nbsp;중)**<br> **참여 형태:** 학생연구원<br> **연구비 지원:** 한국연구재단 · **연구비 주관:** 한양대학교

**담당:** USB4 Gen4 TX RTL·RX CTLE 모델링과 송수신 통합 검증, TX 칩의 차동 PAM&#8209;3 측정 참여. [USB4 설계·검증](../projects/high-speed-interface-research/docs/usb4-pam3.md#page-top)

---

## 주요 논문

### DSP 기반 송수신기

- **A-SSCC 2026 · 제1저자 · 채택:** [DS-SBM 기반 RFSoC PAM4 송수신기](https://epapers2.org/asscc2026/ESR/paper_details.php?paper_id=1351)

### LPDDR 인터페이스

- **A-SSCC 2026 · 공동저자 · 채택:** [LPDDR4X/5/5X Combo PHY](https://epapers2.org/asscc2026/ESR/paper_details.php?paper_id=1141)
- **ICEIC 2025 · 공동 제1저자:** [15.6-Gb/s 저전압 NRZ TX](https://doi.org/10.1109/ICEIC64972.2025.10879746)

### USB 인터페이스

- **IEEE TVLSI 2026 · 공동 제1저자:** [150-preset 4-tap FFE를 적용한 PAM&#8209;3 TX](https://doi.org/10.1109/TVLSI.2026.3701343)
- **SMACD 2025 · 공동 제1저자:** [USB4 Gen4 PAM&#8209;3 TX 모델](https://doi.org/10.1109/SMACD65553.2025.11092283)
- **SMACD 2025 · 공동 제1저자:** [PAM&#8209;3 RX 모델](https://doi.org/10.1109/SMACD65553.2025.11092233)

[논문 제목·검증 범위 전체 보기](publications.md#page-top)

## 진행 중인 논문·특허

- [석사 학위논문 · DS-SBM 설계·RFSoC 검증](https://github.com/yunjuhyeong0916-glitch/pam4-mlsd-research/blob/main/projects/pam4-mlsd-thesis/README.md#page-top) **(원고 마무리 중)**
- [Journal · DP-SMM 설계·검증](https://github.com/yunjuhyeong0916-glitch/pam4-mlsd-research/blob/main/projects/dp-smm-journal/README.md#page-top) **(진&#8288;행&nbsp;중)**
- [DP-SMM 특허 출원 준비](https://github.com/yunjuhyeong0916-glitch/pam4-mlsd-research/blob/main/docs/publications.md#page-top)

---

<p>
  <a href="https://github.com/yunjuhyeong0916-glitch/jhyun#page-top" title="포트폴리오 홈으로 돌아가기"><img src="../assets/readme/nav-home.svg" alt="포트폴리오 홈으로 돌아가기" width="70" height="30"></a>
  <a href="#page-top" title="페이지 맨 위로 이동"><img src="../assets/readme/nav-top.svg" alt="페이지 맨 위로 이동" width="100" height="30"></a>
</p>
