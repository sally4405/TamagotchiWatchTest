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
