# 개발 진행 기록

## 전체 구조

watchOS 앱 중심의 다마고치 게임. HealthKit으로 걸음수를 수집해 재화를 획득하고, SpriteKit 기반 캐릭터와 상호작용하는 구조.

```
WatchTest Watch App/
├── Models/
│   ├── StepCounter.swift           # HealthKit 걸음수 관리
│   ├── CurrencyManager.swift       # 재화 시스템 (걸음수→코인)
│   ├── CharacterStats.swift        # 캐릭터 상태 (energy, fullness, happiness)
│   ├── InventoryManager.swift      # 인벤토리 관리
│   ├── Item.swift                  # 아이템 데이터 모델
│   └── Items.swift                 # 아이템 목록
├── GameScene/
│   ├── TamagotchiScene.swift       # SpriteKit 씬
│   └── TamagotchiCharacter.swift   # 캐릭터 노드 (파츠 조합)
├── Views/
│   ├── ContentView.swift           # 메뉴 (NavigationStack)
│   ├── MainView.swift              # 메인 게임 화면
│   ├── ExchangeView.swift          # 코인 환전
│   ├── ShopView.swift              # 상점
│   ├── InventoryView.swift         # 인벤토리
│   ├── ItemSelectionSheet.swift    # 아이템 선택 시트
│   └── DebugView.swift             # 디버깅 도구
└── WatchTestApp.swift              # 앱 진입점
```

iOS 앱은 아직 미구현 (ContentView만 존재).

## 구현 순서

### 1. HealthKit 권한 및 걸음수 읽기
- StepCounter.swift 생성, HKHealthStore 초기화
- requestAuthorization() 함수로 걸음수 읽기 권한 요청 (async/await)
- fetchTodaySteps() 함수로 HKStatisticsQuery 사용해 오늘 걸음수 조회
- Calendar.startOfDay로 오늘 0시~현재 시간 범위 설정
- @MainActor 선언으로 Sendable 경고 해결
- Privacy 설정은 Watch App 타겟에만 추가 (NSHealthShareUsageDescription)

### 2. 재화 시스템 구현
- CurrencyManager.swift 생성
- App Groups UserDefaults로 iOS와 데이터 공유 (group.com.sello.WatchTest)
- processSteps() 함수로 100걸음 단위로 코인 환전
- lastProcessedDate로 날짜 변경 감지 및 중복 지급 방지
- lastProcessedSteps로 증분만 계산해 환전
- 남은 걸음수는 보존

### 3. 메뉴 기반 앱 구조
- ContentView를 NavigationStack 기반 메뉴 리스트로 변경
- ExchangeView 생성 (환전 가능 걸음수 표시 및 코인 환전 버튼)
- WatchTestApp에서 StepCounter, CurrencyManager를 environmentObject로 주입
- DebugView 생성 (#if DEBUG 블록으로 걸음수 추가/리셋 버튼, Release 빌드에서 제거)

### 4. SpriteKit 기초 및 캐릭터 노드
- TamagotchiScene.swift 생성, SKScene 초기화
- SwiftUI에서 SpriteView로 씬 표시
- backgroundColor = .clear로 투명 배경 설정
- containerNode 계층 구조 생성 (씬 중심에 컨테이너 배치)
- TamagotchiCharacter.swift 생성, SKNode 기반 캐릭터 노드

### 5. 캐릭터 파츠 조합 시스템
- TamagotchiCharacter에 body, head, leftArm, rightArm, leftLeg, rightLeg 노드 추가
- body를 중심(0,0)으로 배치, head는 body 위, arms/legs는 좌우 배치
- anchorPoint 조정으로 팔/다리 회전 중심 설정 (팔: 어깨, 다리: 엉덩이)
- zPosition으로 렌더링 순서 관리 (legs/arms: 0, body: 1, head: 2)
- 파츠 이미지는 Assets.xcassets/Character1 폴더에 저장

### 6. 캐릭터 애니메이션 구현
- handleTap() 함수로 탭 위치의 노드 감지
- nodes(at:) 사용해 탭된 파츠 식별
- 파츠별 애니메이션:
  - head: 좌우로 기울이기 (tiltAction)
  - arms/legs: 펼치기 (spreadAction)
  - body: 랜덤 액션 (전구, 점프, 팔 흔들기)
- SKAction.sequence로 애니메이션 체이닝
- NotificationCenter로 body→scene 이벤트 전달 (전구 이펙트)

### 7. 캐릭터 상태 시스템
- CharacterStats.swift 생성, ObservableObject로 상태 관리
- @Published 변수: energy, fullness, happiness (0-100)
- App Groups UserDefaults로 데이터 영속화
- clamp() 함수로 값 범위 제한
- CharacterState enum (idle, sleeping)
- applyItem() 함수로 아이템 효과 적용 (ItemEffects 구조체)

### 8. 수면 시스템
- startSleeping() 함수로 수면 상태 전환
- Timer로 1초마다 상태 변화 적용 (energy +1, fullness -1)
- energy가 max 또는 fullness가 min이면 자동으로 깨어남 (wakeUp)
- TamagotchiScene에 showSleepIndicator() 함수로 수면 이펙트 표시
- MainView에서 onChange로 상태 변화 감지 및 이펙트 표시/숨김

### 9. 이펙트 시스템
- TamagotchiScene에 effectTopNode, effectItemNode 추가 (캐릭터 위, 아이템 위치)
- showEffect() 함수로 이미지 기반 이펙트 표시 (하트, 전구, 수면, 아이템 등)
- fadeAlpha로 페이드 인/아웃 애니메이션
- duration 파라미터로 자동 사라짐 or 상시 표시
- showStatChange() 함수로 스탯 변화 표시 (SKLabelNode로 +/- 값 표시, 떠오르며 페이드)

### 10. 아이템 시스템
- Item.swift: id, name, imageName, price, category, effects
- ItemCategory enum: food, toy
- Items.swift: 아이템 목록 정의 (음식, 장난감 등)
- InventoryManager.swift: 아이템 구매/사용 관리, App Groups UserDefaults 저장
- ItemEffects 구조체로 아이템 효과 정의 (energy, fullness, happiness)

### 11. 상점 및 인벤토리 UI
- ShopView: 아이템 목록을 Grid로 표시, 가격 표시, 구매 버튼
- InventoryView: 보유 아이템 목록 표시, 수량 표시
- ItemSelectionSheet: 음식/장난감 선택 시트, Grid 레이아웃
- CurrencyManager의 코인과 연동해 구매 처리

### 12. 메인 화면 레이아웃
- MainView.swift 생성
- 배경 이미지 (room1~3, park1) 선택 가능
- 상태바 (energy, fullness, happiness) 표시, 프로그레스 바 형태
- SpriteView로 캐릭터 표시, onTapGesture로 탭 이벤트 전달
- 액션 버튼 (수면, 음식, 장난감) 우측 배치
- sleeping 상태일 때 버튼 비활성화 및 투명도 조정
- 배경 선택 버튼 (3개 방 + 1개 공원)

### 13. 아이템 사용 연동
- ItemSelectionSheet에서 아이템 선택 시 completion 콜백
- MainView에서 scene.showItemEffect() 호출로 아이템 이미지 표시
- showStatChanges() 함수로 스탯 변화량 (+/-) 표시
- 아이템 이펙트 → 하트 이펙트 순차 표시 (completion 콜백)
