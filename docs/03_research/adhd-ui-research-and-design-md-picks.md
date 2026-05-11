# ADHD UI Research + DESIGN.md Picks

## 목적
성인 ADHD 사용자용 OwnUrTime UI에 맞는 색상/구성 원칙을 정하고,
`VoltAgent/awesome-design-md`에서 바로 참고 가능한 `DESIGN.md` 예시를 선정한다.

## 핵심 연구 요약
- ADHD에서는 시각 처리/색 구분 관련 차이가 보고됨.
  - https://pubmed.ncbi.nlm.nih.gov/24646898/
  - https://pubmed.ncbi.nlm.nih.gov/25344625/
- 성인 ADHD 디지털 개입에서는 "예쁜 화면"보다 사용성/레이아웃/기능 최적화가 참여 유지에 중요.
  - https://pubmed.ncbi.nlm.nih.gov/36269662/
  - https://pubmed.ncbi.nlm.nih.gov/39996148/
  - https://pubmed.ncbi.nlm.nih.gov/41625634/
- 색상 자체의 단일 정답보다 접근성 대비/예측 가능한 상호작용이 더 재현성 높은 기준.
  - https://www.w3.org/WAI/WCAG21/Understanding/contrast-minimum.html
  - https://www.w3.org/WAI/cognitive/

## OwnUrTime UI 원칙 (실행 규칙)
1. 고대비 텍스트(최소 AA), 저자극 배경.
2. 포인트 컬러는 CTA/핵심 상태에만 제한적으로 사용.
3. 색 단독 전달 금지(아이콘/텍스트 동시 표기).
4. 한 화면 한 핵심 행동(시작, 유지, 복귀).
5. 애니메이션은 짧고 목적형(주의 분산 방지).

## awesome-design-md 추천 3선
소스 레포:
https://github.com/VoltAgent/awesome-design-md/tree/main/design-md

### 1) Apple (최우선)
- 파일:
  - https://github.com/VoltAgent/awesome-design-md/tree/main/design-md/apple
  - https://raw.githubusercontent.com/VoltAgent/awesome-design-md/main/design-md/apple/DESIGN.md
- 맞는 이유:
  - iOS/macOS 우선 전략과 시각 톤 정합성 높음
  - 단일 액센트 + 절제된 표면 + 낮은 시각 노이즈
  - "집중 방해 요소 최소화"에 유리
- 적용 주의:
  - 마케팅형 풀블리드/히어로 성격은 앱 화면에 과함
  - 앱에서는 카드형 정보 밀도와 고정 CTA에 맞게 축소 적용

### 2) Cal.com (구조 참고용)
- 파일:
  - https://github.com/VoltAgent/awesome-design-md/tree/main/design-md/cal
  - https://raw.githubusercontent.com/VoltAgent/awesome-design-md/main/design-md/cal/DESIGN.md
- 맞는 이유:
  - 화이트 기반의 차분한 SaaS 구조
  - 카드/입력/버튼이 실무형이고 과장된 장식이 적음
  - 작업 관리/스케줄 도메인에 가까운 정보 배치 패턴
- 적용 주의:
  - 섹션 간 여백이 커서 모바일에서 행동 지연 가능
  - OwnUrTime 핵심 플로우는 더 압축된 레이아웃 권장

### 3) Linear (다크 모드 참고용)
- 파일:
  - https://github.com/VoltAgent/awesome-design-md/tree/main/design-md/linear.app
  - https://raw.githubusercontent.com/VoltAgent/awesome-design-md/main/design-md/linear.app/DESIGN.md
- 맞는 이유:
  - 컴포넌트 구조가 규칙적이고 화면 질서가 강함
  - 다크 모드에서 정보 계층과 포커스 강조 방식 참고 가치가 큼
- 적용 주의:
  - 기본 톤이 어두워 장시간 사용 시 피로 개인차 큼
  - 라이트 모드 기본, 다크는 선택 모드로 제공 권장

## 최종 권장 조합
- 기본 베이스: **Apple**
- 생산성 화면 구성: **Cal.com 일부 패턴**
- 다크 모드 컴포넌트 계층: **Linear 일부 패턴**

즉, 단일 복제보다 "Apple + Cal + Linear 하이브리드"가
OwnUrTime(ADHD 실행 보조, iOS/macOS 우선)에 가장 적합하다.

