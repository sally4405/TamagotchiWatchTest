# 개발 진행 기록

## Phase 1: HealthKit 기초

### Step 1.1: 권한 요청 ✅
- Watch App 타겟 Info에 `NSHealthShareUsageDescription` 추가
- `WatchTest Watch App/Models/StepCounter.swift` 생성
- `HKHealthStore`, `ObservableObject`, `@Published` 변수
- `requestAuthorization()` 함수: `async/await`, `HKQuantityType.stepCount`
- `ContentView`에서 `@StateObject`로 연결, 버튼으로 권한 요청
- **주의**: Privacy 설정은 Watch App 타겟에만 추가, iOS 앱 불필요

### Step 1.2: 걸음수 데이터 읽기 ✅
- `StepCounter`에 `@Published var todaySteps: Int` 추가
- `fetchTodaySteps()` 함수: `HKStatisticsQuery`로 오늘 걸음수 조회
- `Calendar.startOfDay`로 오늘 0시~현재 시간 범위 설정
- `HKQuery.predicateForSamples`로 날짜 필터링
- `.cumulativeSum` 옵션으로 걸음수 합산
- `Task { @MainActor in }`: 백그라운드 스레드에서 UI 업데이트 처리
- `ContentView`에 걸음수 표시 UI 추가, `.task` modifier로 자동 조회
- **주의**: `StepCounter`를 `@MainActor`로 선언해 Sendable 경고 해결

### Step 1.3: 주기적 업데이트 ✅
- `.refreshable` modifier로 pull-to-refresh 구현
- Digital Crown 또는 스와이프로 수동 새로고침

### Step 1.4: 재화 시스템 및 메뉴 구조 ✅
- `WatchTest Watch App/Models/CurrencyManager.swift` 생성
- App Groups UserDefaults로 iOS와 데이터 공유 (`group.com.sello.WatchTest`)
- 날짜별 걸음수 처리: `lastProcessedDate`로 날짜 변경 감지
- 100걸음 단위로 환전, 남은 걸음수는 보존
- 중복 지급 방지: `lastProcessedSteps`로 증분만 계산
- **메뉴 기반 구조로 변경**:
  - `ContentView`: NavigationStack 기반 메뉴 리스트
  - `Views/MainView.swift`: 메인 화면 (캐릭터 화면 예정)
  - `Views/ExchangeView.swift`: 환전 가능 걸음수 표시 및 코인 환전
- `WatchTestApp`에서 `StepCounter`, `CurrencyManager`를 environmentObject로 주입
- **테스트 도구**: `#if DEBUG` 블록으로 걸음수 추가/리셋 버튼 (Release 빌드에서 자동 제거)
- **주의**: `UserDefaults(suiteName:)`이 nil일 경우 `.standard` 사용

---

## Phase 1 완료! 🎉

HealthKit 기초를 완료했습니다:
- ✅ 권한 요청 및 상태 관리
- ✅ 오늘 걸음수 조회 및 새로고침
- ✅ 걸음수 → 코인 변환 시스템
- ✅ 날짜별 중복 방지 로직
- ✅ 메뉴 기반 앱 구조
