# iOS-watchOS 연동 설계

## 개요

아이폰 앱에서 다마고치 목록을 관리하고, 선택된 다마고치를 워치 앱에서 표시 및 상호작용하는 구조.

## 데이터 모델

### iOS 앱: Tamagotchi 모델
```swift
struct Tamagotchi: Identifiable, Codable {
    let id: UUID
    var name: String
    var imageSetName: String        // "Character1", "Character2" 등
    var energy: Int                 // 0-100
    var fullness: Int               // 0-100
    var happiness: Int              // 0-100
}
```

### watchOS 앱: CharacterStats (기존 유지)
- 단일 다마고치만 관리
- state는 watchOS 전용 (idle, sleeping)
- 선택된 다마고치의 id, imageSetName, stats를 iOS로부터 전달받아 사용

## iOS 앱 구조

### TamagotchiManager (ObservableObject)
```swift
@MainActor
class TamagotchiManager: ObservableObject {
    @Published var tamagotchis: [Tamagotchi]
    @Published var selectedTamagotchiId: UUID?

    // App Groups UserDefaults로 저장
    // 키: "tamagotchi_list", "selected_tamagotchi_id"

    func addTamagotchi(name: String, imageSetName: String)
    func selectTamagotchi(id: UUID)
    func updateStats(id: UUID, energy: Int, fullness: Int, happiness: Int)
}
```

### UI 구조
```
TabView
├── 다마고치 목록 탭
│   ├── NavigationStack
│   ├── LazyVGrid (3칸)
│   │   └── TamagotchiCard
│   │       ├── 이미지 (Characters 폴더)
│   │       ├── 이름
│   │       ├── 선택중 표시 (테두리 색)
│   │       └── 선택됨 표시 (배경색)
│   ├── 플로팅 버튼 (선택 확정)
│   └── + 버튼 (새 다마고치 추가)
│       └── Sheet
│           ├── 이름 입력
│           └── 이미지셋 선택 (Characters 폴더 이미지)
│
└── 인벤토리 탭
    └── List
        └── 아이템 (이미지, 이름, 개수, effects)
```

## watchOS 앱 수정사항

### TamagotchiCharacter 수정
- `loadImageSet(_ name: String)` 함수 추가
- 이미지 이름을 동적으로 구성 ("{imageSetName}/body" 형식)
- 기존 노드 제거 후 새 이미지셋으로 재생성

### CharacterStats 수정
- 기존 구조 유지 (단일 다마고치)
- UserDefaults에서 선택된 다마고치 정보 로드
- 키: "selected_tamagotchi_id", "selected_tamagotchi_imageSetName", "selected_tamagotchi_energy", "selected_tamagotchi_fullness", "selected_tamagotchi_happiness"
- state는 UserDefaults에 저장하지 않음 (항상 idle로 시작)

### MainView 수정
- NotificationCenter로 선택된 다마고치 변경 감지
- 변경 감지 시 TamagotchiScene 재생성 또는 캐릭터 노드 교체
- 전환 애니메이션 추가 (fade out → 교체 → fade in)

## 동기화 방식

### App Groups UserDefaults
- Suite Name: `group.com.sello.WatchTest`

### iOS → watchOS 데이터 전달
**선택 변경 시:**
1. iOS에서 다마고치 선택 확정 시
2. 기존 선택된 다마고치의 현재 stats를 watchOS로부터 읽어와서 iOS의 해당 다마고치 객체에 저장
3. 새로 선택된 다마고치의 id, imageSetName, energy, fullness, happiness를 UserDefaults에 저장
4. NotificationCenter.default.post (이름: "TamagotchiSelectionChanged")

**전달 키:**
- `selected_tamagotchi_id`: UUID 문자열
- `selected_tamagotchi_imageSetName`: String
- `selected_tamagotchi_energy`: Int
- `selected_tamagotchi_fullness`: Int
- `selected_tamagotchi_happiness`: Int

### watchOS → iOS 데이터 전달
**stats 저장만:**
- CharacterStats의 energy, fullness, happiness가 변경될 때 UserDefaults에 저장
- iOS는 선택 변경 시에만 이 값을 읽어서 이전 다마고치 객체에 반영

### 변경 감지
- iOS: NotificationCenter.default.post로 변경 알림
- watchOS: UserDefaults.didChangeNotification 또는 NotificationCenter로 감지
- watchOS 앱이 foreground일 때 자동 새로고침

## 구현 순서

### 1. Shared 모델 생성
- Shared/Models/Tamagotchi.swift 생성
- Identifiable, Codable 구현

### 2. iOS TamagotchiManager 구현
- App Groups UserDefaults 연동
- CRUD 기능 (추가, 선택, stats 업데이트)
- 선택 변경 시 이전 다마고치 stats 저장 로직

### 3. iOS UI 구현
- TabView 기본 구조
- 다마고치 목록 (LazyVGrid, 선택/확정 UI)
- 다마고치 추가 Sheet (이름, 이미지셋 선택)
- 인벤토리 (InventoryManager 재사용)

### 4. watchOS TamagotchiCharacter 수정
- loadImageSet() 함수 추가
- 동적 이미지 로딩 구조
- 노드 재생성 로직

### 5. watchOS CharacterStats 수정
- UserDefaults에서 선택된 다마고치 정보 로드
- state는 항상 idle로 초기화
- stats 변경 시 UserDefaults 저장

### 6. watchOS MainView 수정
- 선택 변경 감지 (NotificationCenter 또는 UserDefaults 옵저버)
- TamagotchiScene 재생성 또는 캐릭터 교체
- 전환 애니메이션

### 7. 동기화 테스트
- iOS에서 다마고치 선택 → watchOS 반영 확인
- watchOS에서 stats 변경 → iOS 선택 변경 시 저장 확인
- 양방향 데이터 흐름 검증

## 개선 예정 사항

### 단기
- 다마고치 삭제 기능
- 다마고치 이름 수정 기능
- 이미지셋 변경 기능

### 중기
- Assets을 SpriteAtlas 형태로 구조화
- 다마고치 교체 시 부드러운 전환 애니메이션
- 백그라운드 동기화 최적화

### 장기
- UserDefaults → Core Data 마이그레이션
- WatchConnectivity 도입 (실시간 양방향 동기화)
- CloudKit 동기화 (멀티 디바이스 지원)

## 주의사항

### Assets 구조
현재 Assets 구조:
```
Assets.xcassets/
├── Character1/
│   ├── body.imageset
│   ├── head.imageset
│   ├── left_arm.imageset
│   └── ...
├── Character2/
│   ├── body.imageset
│   └── ...
└── Characters/
    ├── charater1.imageset (전체 이미지)
    └── character2.imageset (전체 이미지)
```

이미지 로딩 방식:
- watchOS: Character1/body 형태로 파츠 로딩
- iOS: Characters/charater1 형태로 전체 이미지 로딩

### 동기화 타이밍
- stats 변경마다 동기화하지 않음 (비효율)
- 선택 변경 시에만 이전 다마고치 stats를 저장
- watchOS는 항상 현재 선택된 다마고치 stats를 UserDefaults에 저장
- iOS는 선택 변경 시 UserDefaults에서 읽어서 이전 다마고치에 반영

### state 처리
- state는 watchOS 전용 (idle, sleeping)
- UserDefaults에 저장하지 않음
- 다마고치 선택 변경 시 항상 idle로 초기화
- iOS 앱은 state를 알 필요 없음
