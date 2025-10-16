# 개발 진행 기록

## Phase 1: HealthKit 기초

### Step 1.1: 권한 요청 ✅
- Watch App 타겟 Info에 `NSHealthShareUsageDescription` 추가
- `WatchTest Watch App/Models/StepCounter.swift` 생성
- `HKHealthStore`, `ObservableObject`, `@Published` 변수
- `requestAuthorization()` 함수: `async/await`, `HKQuantityType.stepCount`
- `ContentView`에서 `@StateObject`로 연결, 버튼으로 권한 요청
- **주의**: Privacy 설정은 Watch App 타겟에만 추가, iOS 앱 불필요
