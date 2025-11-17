# WatchTest - Tamagotchi Game

iOS와 watchOS를 연동한 듀얼 플랫폼 다마고치 게임 프로젝트

## 개요

watchOS에서 다마고치를 키우고, iOS에서 다마고치를 관리하는 구조의 게임입니다. HealthKit을 통해 걸음수를 수집하여 재화로 전환하고, SpriteKit으로 파츠 조합 기반 캐릭터 애니메이션을 구현했습니다.

### 프로젝트 목적
- watchOS/iOS 듀얼 플랫폼 개발 학습
- HealthKit 데이터 수집 및 활용
- SpriteKit 파츠 조합 시스템 구현
- WatchConnectivity를 통한 플랫폼 간 데이터 동기화

---

## 주요 기능

### iOS 앱 (컴패니언 앱)
- 다마고치 생성, 수정, 삭제
- 다마고치 목록 관리
- 선택된 다마고치를 watchOS로 전달
- watchOS 인벤토리 조회 (읽기 전용)

### watchOS 앱 (메인 게임)
- 선택된 다마고치 표시 및 상호작용
- HealthKit 걸음수 수집 → 코인 환전
- 아이템 구매 및 사용 (음식, 장난감)
- 수면 시스템 (energy 회복, fullness 감소)
- SpriteKit 기반 캐릭터 애니메이션 (파츠별 독립 애니메이션)
- 배경 선택 (방 3종, 공원 1종)

---

## 기술 스택

- **SwiftUI**: 전체 UI 프레임워크
- **SpriteKit**: 캐릭터 애니메이션 (watchOS)
- **HealthKit**: 걸음수 데이터 수집 (watchOS)
- **WatchConnectivity**: iOS ↔ watchOS 데이터 동기화
- **UserDefaults**: 각 앱 내부 데이터 영속성 (App Groups)
- **Codable**: 데이터 직렬화 (JSON)

---

## 프로젝트 구조

```
WatchTest/
├── Shared/                          # iOS/watchOS 공유 코드
│   ├── Models/
│   │   ├── Tamagotchi.swift        # 다마고치 모델 (TamagotchiStats, ItemEffects 포함)
│   │   ├── Item.swift              # 아이템 모델
│   │   ├── Items.swift             # 아이템 목록
│   │   └── InventoryManager.swift  # 인벤토리 관리
│   ├── Assets.xcassets/            # 공유 리소스 (아이템 이미지)
│   └── Constants.swift             # 공유 상수 (UserDefaults 키, App Group)
│
├── WatchTest/ (iOS)
│   ├── Models/
│   │   └── TamagotchiManager.swift # 다마고치 목록 관리
│   ├── Services/
│   │   └── WatchConnectivityManager.swift  # iOS-Watch 통신
│   └── Views/
│       ├── TamagotchiListView.swift   # 다마고치 목록 (선택/수정/삭제)
│       ├── AddTamagotchiView.swift    # 다마고치 추가
│       ├── EditTamagotchiView.swift   # 다마고치 수정
│       └── InventoryView.swift        # watchOS 인벤토리 조회
│
└── WatchTest Watch App/ (watchOS)
    ├── Models/
    │   ├── TamagotchiManager.swift    # 다마고치 상태 및 액션
    │   ├── StepCounter.swift          # HealthKit 걸음수
    │   └── CurrencyManager.swift      # 재화 시스템
    ├── Services/
    │   └── WatchConnectivityManager.swift  # Watch-iOS 통신
    ├── GameScene/
    │   ├── TamagotchiScene.swift      # SpriteKit 씬
    │   └── TamagotchiCharacter.swift  # 캐릭터 노드 (파츠 조합)
    └── Views/
        ├── MainView.swift             # 메인 게임 화면
        ├── ShopView.swift             # 상점
        ├── ExchangeView.swift         # 코인 환전
        └── ItemSelectionSheet.swift   # 아이템 선택
```

---

## 핵심 구현 설명

### 1. 데이터 모델

#### Tamagotchi (Shared)
```swift
struct Tamagotchi: Identifiable, Codable {
    let id: UUID
    var name: String
    var imageSetName: String
    var stats: TamagotchiStats
}

struct TamagotchiStats: Codable {
    var energy, fullness, happiness: Int  // 0-100
    mutating func apply(_ effects: ItemEffects)  // 효과 적용 + clamp
}
```

#### 역할 분리
- **iOS TamagotchiManager**: 다마고치 목록 관리 (생성/수정/삭제/선택)
- **watchOS TamagotchiManager**: 현재 다마고치 상태 및 액션 (아이템/수면)

---

### 2. WatchConnectivity 동기화

**iOS ↔ watchOS는 파일 시스템을 공유하지 않으므로 WatchConnectivity 필수**

#### iOS → watchOS

```swift
// 다마고치 선택 시
func selectTamagotchi(id: UUID) {
    WatchConnectivityManager.shared.sendTamagotchiToWatch(tamagotchi)
    // isReachable ? sendMessage : updateApplicationContext
}
```

메시지 형식:
```json
{
  "type": "selectTamagotchi",
  "id": "UUID",
  "name": "이름",
  "imageSetName": "Character1",
  "energy": 100,
  "fullness": 100,
  "happiness": 100
}
```

#### watchOS → iOS

**다마고치 전환 시에만 stats 전송 (실시간 전송 없음):**
```swift
func loadTamagotchi(_ newTamagotchi: Tamagotchi) {
    // 기존 다마고치가 있고 ID가 다르면
    if let current = currentTamagotchi, current.id != newTamagotchi.id {
        sendStatsToiPhone(id: current.id, stats: current.stats)
    }
    currentTamagotchi = newTamagotchi
}
```

**인벤토리는 변경 시마다 자동 전송:**
```swift
// InventoryManager.saveData()
WatchConnectivityManager.shared.sendInventoryToiPhone(items)
// updateApplicationContext 사용 (최신 상태만 유지)
```

#### 주요 WatchConnectivity 메서드

- **sendMessage**: 즉시 전송, Watch/iOS 앱을 백그라운드에서 깨움, 양방향 통신 가능
- **updateApplicationContext**: 최신 값만 유지 (이전 값 덮어씀), 백그라운드 전송
- **transferUserInfo**: FIFO 큐, 모든 변경 순서대로 전달, 백그라운드 전송

---

### 3. SpriteKit 파츠 조합 시스템

#### TamagotchiCharacter (SKNode)

```
TamagotchiCharacter
├── bodyNode (중심 0,0)
├── headNode (body 위)
├── leftArmNode (왼쪽 팔)
├── rightArmNode (오른쪽 팔)
├── leftLegNode (왼쪽 다리)
└── rightLegNode (오른쪽 다리)
```

**핵심 개념:**
- 모든 파츠는 **이미지 원본 크기 그대로** 사용
- body.position = (0, 0)을 기준으로 상대 배치
- anchorPoint 조정으로 회전 중심 설정 (팔/다리)

#### TamagotchiScene 스케일링

```swift
// 1. 캐릭터 크기 계산 (원본)
let characterSize = character.calculateSize()

// 2. 목표 높이 설정 (화면상 175)
let scale = 175 / characterSize.height

// 3. characterNode에 스케일 적용
character.setScale(scale)
```

**결과:**
- Character1 (원본 500) × 0.35 = 175
- Character2 (원본 375) × 0.47 = 175
- **화면에서 동일한 크기로 보임**

#### 탭 제스처 좌표 변환

```swift
// SwiftUI 좌표 → SpriteKit 씬 좌표
scenePoint = (x × scaleX, (viewHeight - y) × scaleY)

// 씬 좌표 → containerNode 로컬 좌표
scenePoint -= container.position

// characterNode 스케일 역변환
scenePoint /= character.scale

// characterNode 위치 오프셋 제거
scenePoint -= character.position
```

---

### 4. HealthKit 걸음수 시스템

```swift
// 1. 권한 요청
HKHealthStore.requestAuthorization()

// 2. 오늘 걸음수 조회
HKStatisticsQuery(
    quantityType: .stepCount,
    range: startOfDay...now
)

// 3. 재화 변환
CurrencyManager.processSteps(currentSteps)
// 100걸음 = 1코인
```

**중복 지급 방지:**
- `lastProcessedSteps`: 마지막 처리된 걸음수
- `lastProcessedDate`: 날짜 변경 감지
- 증분만 계산하여 코인 지급

---

## 데이터 저장 방식

### iOS (UserDefaults)
- `tamagotchi_list`: [Tamagotchi] 배열 (JSON)
- `selected_tamagotchi_id`: UUID 문자열

### watchOS (UserDefaults)
- `selected_tamagotchi`: Tamagotchi 객체 전체 (JSON)
- `inventory_items`: [String: Int] 딕셔너리 (JSON)
- `user_coins`: Int

**App Groups 사용:**
- Suite Name: `group.com.sello.WatchTest`
- iOS-iOS, watchOS-watchOS 내에서만 데이터 공유 가능
- **iOS ↔ watchOS 간 통신은 WatchConnectivity 필수**

