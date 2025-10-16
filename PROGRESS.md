# 개발 진행 기록

## Phase 1: HealthKit 기초

### Step 1.1: 권한 요청
- Watch App 타겟 Info에 `NSHealthShareUsageDescription` 추가
- `WatchTest Watch App/Models/StepCounter.swift` 생성
- `HKHealthStore`, `ObservableObject` 기본 구조
- **주의**: Privacy 설정은 Watch App 타겟에만 추가
