# iOS-watchOS 연동 설계

## 개요

아이폰 앱에서 다마고치 목록을 관리하고, 선택된 다마고치를 워치 앱에서 표시 및 상호작용하는 구조. WatchConnectivity를 통해 데이터 동기화.

## 데이터 모델

### Shared: Tamagotchi 모델
```swift
struct Tamagotchi: Identifiable, Codable {
    let id: UUID
    var name: String
    var imageSetName: String
    var stats: TamagotchiStats
}

struct TamagotchiStats: Codable {
    var energy: Int                 // 0-100
    var fullness: Int               // 0-100
    var happiness: Int              // 0-100

    mutating func apply(_ effects: ItemEffects)
}

struct ItemEffects: Codable {
    let energy: Int?
    let fullness: Int?
    let happiness: Int?
}
```

### watchOS: TamagotchiManager
- 단일 다마고치 관리 (`currentTamagotchi: Tamagotchi?`)
- 상태 관리 (`currentState: TamagotchiState` - idle, sleeping)
- 액션 처리 (applyItem, startSleeping, wakeUp)
- UserDefaults에 Tamagotchi 객체 전체 저장 (JSON)

## iOS 앱 구조

### TamagotchiManager
```swift
@MainActor
class TamagotchiManager: ObservableObject {
    @Published var tamagotchis: [Tamagotchi]
    @Published var selectedTamagotchiId: UUID?

    // UserDefaults 저장 (iOS 앱 내부 전용)
    // 키: "tamagotchi_list", "selected_tamagotchi_id"

    func addTamagotchi(name: String, imageSetName: String)
    func selectTamagochi(id: UUID)
    func updateStats(id: UUID, stats: TamagotchiStats)
}
```

### WatchConnectivityManager
```swift
@MainActor
class WatchConnectivityManager: NSObject, ObservableObject {
    weak var tamagotchiManager: TamagotchiManager?

    // iOS → Watch: 선택된 다마고치 전송
    func sendTamagotchiToWatch(_ tamagotchi: Tamagotchi)

    // Watch → iOS: stats 업데이트 수신
    // didReceiveMessage, didReceiveUserInfo 구현
}
```

## watchOS 앱 구조

### TamagotchiManager
```swift
@MainActor
class TamagotchiManager: ObservableObject {
    @Published var currentTamagotchi: Tamagotchi?
    @Published var currentState: TamagotchiState

    // UserDefaults 저장 (watchOS 앱 내부 전용)
    // 키: "selected_tamagotchi" (Tamagotchi 객체 전체, JSON)

    func loadTamagotchi(_ tamagotchi: Tamagotchi)
    func applyItem(_ effects: ItemEffects)
    func startSleeping()
    func wakeUp()
}
```

### WatchConnectivityManager
```swift
@MainActor
class WatchConnectivityManager: NSObject, ObservableObject {
    weak var tamagotchiManager: TamagotchiManager?

    // iOS → Watch: 다마고치 수신
    // didReceiveMessage, didReceiveUserInfo, didReceiveApplicationContext 구현

    // Watch → iOS: stats 전송 (다마고치 전환 시에만)
    func sendStatsToiPhone(id: UUID, stats: TamagotchiStats)
}
```

## 동기화 방식 (WatchConnectivity)

### iOS → watchOS 전달

**다마고치 선택 시:**
1. iOS에서 `selectTamagochi(id)` 호출
2. WatchConnectivityManager.sendTamagotchiToWatch(tamagotchi)
3. Tamagotchi 객체 → Dictionary (id, name, imageSetName, stats.*)
4. isReachable == true → `sendMessage` (즉시 전송)
5. isReachable == false → `updateApplicationContext` (백그라운드 전송)
6. watchOS가 수신 → TamagotchiStats 재조립 → Tamagotchi 객체 생성
7. TamagotchiManager.loadTamagotchi() 호출

**전송 메시지 형식:**
```swift
[
    "type": "selectTamagotchi",
    "id": UUID 문자열,
    "name": String,
    "imageSetName": String,
    "energy": Int,
    "fullness": Int,
    "happiness": Int
]
```

### watchOS → iOS 전달

**다마고치 전환 시에만:**
1. iOS에서 새 다마고치 선택
2. watchOS의 loadTamagotchi() 호출됨
3. 기존 currentTamagotchi가 있고 ID가 다르면 → sendStatsToiPhone(id, stats)
4. TamagotchiStats → Dictionary
5. isReachable == true → `sendMessage` (즉시 전송)
6. isReachable == false → `transferUserInfo` (백그라운드 전송)
7. iOS가 수신 → TamagotchiStats 재조립 → updateStats(id, stats)

**전송 메시지 형식:**
```swift
[
    "type": "updateStats",
    "id": UUID 문자열,
    "energy": Int,
    "fullness": Int,
    "happiness": Int
]
```

### 로컬 저장 방식

**iOS (UserDefaults):**
- `tamagotchi_list`: [Tamagotchi] 배열 (JSON)
- `selected_tamagotchi_id`: UUID 문자열

**watchOS (UserDefaults):**
- `selected_tamagotchi`: Tamagotchi 객체 전체 (JSON)

**App Groups는 사용하지만 플랫폼 간 통신 불가:**
- iOS-iOS, watchOS-watchOS 내부에서만 공유 가능
- iOS ↔ watchOS는 WatchConnectivity 필수

## 데이터 흐름

### 시나리오 1: iOS에서 다마고치 선택

```
[iOS]
1. 사용자가 다마고치 선택
2. selectTamagochi(id) 호출
3. selectedTamagotchiId = id, UserDefaults 저장
4. WatchConnectivityManager.sendTamagotchiToWatch(tamagotchi)
   ↓ WatchConnectivity
[watchOS]
5. didReceiveMessage 수신
6. Tamagotchi 객체 재조립
7. loadTamagotchi() 호출
8. 기존 다마고치 있으면 → sendStatsToiPhone() (iOS DB 업데이트)
9. currentTamagotchi = 새 다마고치, UserDefaults 저장
10. MainView onChange 트리거 → 씬 재생성
```

### 시나리오 2: watchOS에서 게임 플레이

```
[watchOS]
1. 사용자가 아이템 사용 또는 수면
2. applyItem(effects) 또는 startSleeping()
3. currentTamagotchi.stats 변경
4. UserDefaults 저장 (watchOS 내부만)
5. iOS로 실시간 전송 ❌ (다마고치 전환 시에만 전송)
```

### 시나리오 3: 앱 재시작

```
[iOS]
1. TamagotchiManager.init()
2. UserDefaults에서 tamagotchiList, selectedId 로드
3. UI에 목록 표시

[watchOS]
1. TamagotchiManager.init()
2. UserDefaults에서 Tamagotchi 객체 로드 (JSON 디코딩)
3. currentTamagotchi 복원, currentState = .idle
4. MainView onAppear → 씬 생성
```

## 주의사항

### Assets 구조
```
WatchTest Watch App/Assets.xcassets/
├── Character1/
│   ├── body.imageset
│   ├── head.imageset
│   └── ...
└── Character2/
    └── ...

WatchTest/Assets.xcassets/
└── Characters/
    ├── charater1.imageset (전체 이미지)
    └── character2.imageset (전체 이미지)
```

이미지 로딩:
- watchOS: `Character1/body` 형태로 파츠 개별 로딩
- iOS: `Characters/charater1` 형태로 전체 이미지 로딩

### 동기화 타이밍

**실시간 동기화 없음:**
- watchOS에서 stats 변경 시 iOS로 전송하지 않음
- 다마고치 전환 시에만 기존 stats를 iOS로 전송하여 DB 업데이트
- 사용자가 watchOS에서 게임 플레이 → iOS에서 다른 다마고치 선택 → 그때 stats 동기화

**장점:**
- 배터리 절약 (불필요한 통신 감소)
- WatchConnectivity 메시지 수 최소화

**단점:**
- iOS 앱에서 실시간 stats 확인 불가
- 다마고치 전환하지 않으면 stats 유실 가능 (향후 개선 필요)

### state 처리

- `currentState`는 watchOS 전용 (idle, sleeping)
- UserDefaults에 저장하지 않음 (앱 재시작 시 항상 idle)
- iOS는 state 정보를 알 필요 없음
- 다마고치 전환 시 항상 idle로 초기화
