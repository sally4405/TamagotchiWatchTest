# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 프로젝트 개요

**듀얼 플랫폼 다마고치 게임**: watchOS에서 캐릭터를 키우고, iOS에서 관리 및 확장 기능 제공

### 앱 역할 분담

#### watchOS 앱 (메인 게임플레이)
- **일상 관리**: 캐릭터와의 실시간 상호작용 (밥주기, 놀아주기)
- **걸음수 수집**: HealthKit 통합으로 자동 재화 획득
- **간단한 애니메이션**: 캐릭터 관찰 및 기본 상태 확인
- **빠른 체크인**: 손목에서 즉시 확인 가능한 UX

#### iOS 앱 (컴패니언 - 확장 기능)
- **컬렉션 도감**: 키웠던 모든 다마고치 기록 및 조회
- **상세 통계**: 각 캐릭터의 성장 히스토리, 유전자 정보, 그래프
- **네트워크 기능**:
  - 다른 유저와의 만남 및 번식
  - 친구 목록 관리
  - 커뮤니티 기능 (랭킹, 갤러리 등)
- **복잡한 UI**: 유전자 조합 시뮬레이터, 캐릭터 비교, 필터링
- **설정 및 관리**: 알림 설정, 계정 관리, 백업/복원

### 데이터 동기화
- **App Groups** (`group.com.sello.WatchTest`)로 실시간 데이터 공유
- **CloudKit** (향후): 멀티 디바이스 동기화 및 백업

**핵심 기술 스택:**
- **SpriteKit**: 파츠 조합 및 캐릭터 애니메이션 (watchOS)
- **HealthKit**: 걸음수 데이터 수집 및 재화 변환 (watchOS)
- **SwiftUI**: 전체 UI 프레임워크 (iOS + watchOS)
- **Core Data**: 캐릭터 영속성 관리 (iOS 중심, watchOS 동기화)
- **Networking**: REST API 또는 WebSocket (iOS 중심, watchOS는 제한적)
- **WeatherKit**: (테스트 완료 후 제거 예정)

**개발 방향:**
튜토리얼 단계별 학습을 통해 HealthKit과 SpriteKit을 점진적으로 익혀가며 구현합니다.

## 프로젝트 구조

```
WatchTest.xcodeproj
├── WatchTest/                          # iOS 컴패니언 앱
│   ├── WatchTestApp.swift
│   ├── ContentView.swift               # 현재: WeatherKit 테스트
│   │                                   # 향후: 메인 탭 뷰 (도감, 네트워크, 설정)
│   ├── Views/                          # (생성 예정)
│   │   ├── CollectionView.swift       # 다마고치 도감
│   │   ├── TamagotchiDetailView.swift # 개별 캐릭터 상세 정보
│   │   ├── StatisticsView.swift       # 그래프 및 통계
│   │   ├── NetworkView.swift          # 유저 탐색 및 번식
│   │   ├── FriendsView.swift          # 친구 목록
│   │   └── SettingsView.swift         # 설정 화면
│   │
│   ├── ViewModels/                     # (생성 예정)
│   │   ├── CollectionViewModel.swift
│   │   └── NetworkViewModel.swift
│   │
│   └── Services/                       # (생성 예정)
│       ├── NetworkService.swift       # API 통신
│       └── SyncService.swift          # Watch ↔ iOS 동기화
│
├── WatchTest Watch App/                # watchOS 메인 게임 앱
│   ├── WatchTestApp.swift              # 앱 진입점
│   ├── ContentView.swift               # 현재: WeatherKit 테스트
│   │                                   # 향후: 메인 탭 뷰 컨테이너
│   ├── GameScene/                      # (생성 예정) SpriteKit 관련
│   │   ├── TamagotchiScene.swift      # 게임 씬
│   │   ├── TamagotchiNode.swift       # 파츠 조합 캐릭터 노드
│   │   └── AnimationController.swift  # 애니메이션 관리
│   │
│   ├── Views/                          # (생성 예정) SwiftUI 뷰
│   │   ├── GameView.swift             # SpriteKit 씬 래퍼
│   │   ├── StatsView.swift            # 캐릭터 상태 표시 (Watch용 간단)
│   │   └── ActionsView.swift          # 상호작용 버튼
│   │
│   ├── Models/                         # (생성 예정) Watch 전용 모델
│   │   ├── StepCounter.swift          # HealthKit 걸음수 관리
│   │   └── CurrencyManager.swift      # 재화 시스템
│   │
│   └── Resources/                      # (생성 예정) 리소스
│       └── TamagotchiParts.atlas/     # 파츠 이미지들
│
└── Shared/                             # (생성 예정) iOS/watchOS 공유 코드
    ├── Models/
    │   ├── Tamagotchi.swift           # 캐릭터 데이터 모델
    │   ├── TamagotchiGenes.swift      # 유전자/외모 시스템
    │   └── TamagotchiState.swift      # 상태 (배고픔, 행복도 등)
    │
    ├── Persistence/
    │   ├── PersistenceController.swift # Core Data 스택
    │   └── TamagotchiDataModel.xcdatamodeld
    │
    └── Utilities/
        ├── AppGroupManager.swift       # App Group 데이터 동기화
        └── Constants.swift             # 공통 상수
```

## 빌드 및 테스트 명령어

### 기본 빌드
```bash
# Watch 앱 시뮬레이터 빌드 (메인 게임)
xcodebuild -scheme "WatchTest Watch App" -configuration Debug -sdk watchsimulator \
  -destination 'platform=watchOS Simulator,name=Apple Watch Series 10 (46mm)'

# iOS 앱 시뮬레이터 빌드 (컴패니언 앱)
xcodebuild -scheme WatchTest -configuration Debug -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 16'

# 양쪽 모두 동시 빌드 (페어링 테스트용)
xcodebuild -scheme WatchTest -configuration Debug -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 16' && \
xcodebuild -scheme "WatchTest Watch App" -configuration Debug -sdk watchsimulator \
  -destination 'platform=watchOS Simulator,name=Apple Watch Series 10 (46mm)'
```

### 테스트
```bash
# Watch 앱 Unit 테스트
xcodebuild test -scheme "WatchTest Watch App" \
  -destination 'platform=watchOS Simulator,name=Apple Watch Series 10 (46mm)'

# 특정 테스트만 실행
xcodebuild test -scheme "WatchTest Watch App" \
  -destination 'platform=watchOS Simulator,name=Apple Watch Series 10 (46mm)' \
  -only-testing:WatchTest_Watch_AppTests/StepCounterTests/testStepFetching
```

### 클린
```bash
xcodebuild clean -scheme "WatchTest Watch App"
```

## 개발 로드맵 및 튜토리얼

### Phase 0: 현재 상태 ✅
- [x] Xcode 프로젝트 생성 (iOS + watchOS 타겟)
- [x] WeatherKit 테스트 구현 완료
- [x] HealthKit Entitlement 추가 (권한 요청 코드는 미완성)
- [x] App Groups 설정 (`group.com.sello.WatchTest`)

### Phase 1: HealthKit 튜토리얼 학습 🎯
**목표:** 걸음수 데이터를 읽고 재화로 변환하는 기초 시스템 구축

#### Step 1.1: HealthKit 권한 요청
- [ ] `StepCounter.swift` 생성
- [ ] HKHealthStore 초기화 및 권한 요청 구현
- [ ] 권한 상태 확인 로직 추가
- [ ] UI에서 권한 요청 버튼 연결

**학습 포인트:**
- `HKHealthStore.requestAuthorization()` 사용법
- HealthKit 권한 모델 이해 (읽기 전용)
- watchOS에서의 HealthKit 접근 차이점

**참고 코드 위치:** `WatchTest Watch App/ContentView.swift:71-76` (기초 코드 존재)

#### Step 1.2: 걸음수 데이터 읽기
- [ ] 오늘 걸음수 조회 함수 구현
- [ ] 특정 기간 걸음수 조회 (어제, 이번 주 등)
- [ ] 실시간 걸음수 업데이트 Observer 추가
- [ ] UI에 걸음수 표시

**학습 포인트:**
- `HKQuantityType.stepCount` 사용
- `HKStatisticsQuery` vs `HKObserverQuery` 차이
- Date 범위 설정 및 쿼리 최적화

#### Step 1.3: 재화 시스템 구축
- [ ] `CurrencyManager.swift` 생성
- [ ] 걸음수 → 코인 변환 로직 (예: 100걸음 = 1코인)
- [ ] 코인 저장/불러오기 (UserDefaults 또는 App Group)
- [ ] 코인 사용 함수 (차감, 부족 시 처리)

**학습 포인트:**
- UserDefaults vs App Group 데이터 공유
- 걸음수 증분 계산 (중복 지급 방지)

### Phase 2: SpriteKit 튜토리얼 학습 🎯
**목표:** 기본 SpriteKit 씬을 만들고 간단한 애니메이션 구현

#### Step 2.1: SpriteKit 기초 설정
- [ ] `TamagotchiScene.swift` 생성
- [ ] SwiftUI에서 `SpriteView`로 씬 표시
- [ ] 배경색 설정 및 노드 추가 테스트
- [ ] 탭 제스처 반응 구현

**학습 포인트:**
- `SKScene` 라이프사이클 (`didMove(to:)`, `update()`)
- `SKNode` 계층 구조
- SwiftUI ↔ SpriteKit 데이터 전달

#### Step 2.2: 이미지 스프라이트 표시
- [ ] 테스트용 캐릭터 이미지 추가 (단일 이미지)
- [ ] `SKSpriteNode`로 이미지 표시
- [ ] 위치, 크기, zPosition 조정
- [ ] 간단한 회전/이동 애니메이션 추가

**학습 포인트:**
- `SKSpriteNode` 생성 방법
- `SKAction`을 이용한 애니메이션
- 좌표계 이해 (center vs bottom-left)

#### Step 2.3: 프레임 애니메이션
- [ ] 여러 프레임 이미지 준비 (예: idle 상태 3프레임)
- [ ] `SKAction.animate(with:)` 사용
- [ ] 반복 애니메이션 구현
- [ ] 애니메이션 상태 전환 (idle → eating → idle)

**학습 포인트:**
- Texture Atlas 사용법
- 프레임 타이밍 조절
- 애니메이션 완료 콜백

### Phase 3: 파츠 조합 시스템 🎯
**목표:** 눈, 입, 귀 등을 조합하여 다양한 캐릭터 생성

#### Step 3.1: 기본 파츠 시스템
- [ ] `TamagotchiGenes.swift` 모델 생성 (body, eyes, mouth, ears)
- [ ] 파츠별 이미지 리소스 추가
- [ ] `TamagotchiNode.swift` 생성 - 파츠 조합 로직
- [ ] 유전자 값에 따라 다른 외모 표시

**학습 포인트:**
- 노드 계층 구조 (부모-자식 관계)
- 상대 위치 및 z-index 관리
- 동적 텍스처 로딩

#### Step 3.2: 파츠별 독립 애니메이션
- [ ] 귀 흔들기 애니메이션
- [ ] 눈 깜빡이기 애니메이션
- [ ] 입 움직이기 애니메이션 (먹을 때)
- [ ] 여러 애니메이션 동시 실행

**학습 포인트:**
- 개별 노드에 애니메이션 적용
- 애니메이션 동기화 vs 비동기화
- 타이밍 함수 (easeIn, easeOut 등)

#### Step 3.3: 유전자 조합 알고리즘
- [ ] 부모 2개의 유전자 입력
- [ ] 자식 유전자 생성 (무작위 조합)
- [ ] 희귀도 시스템 추가 (특정 파츠는 낮은 확률)
- [ ] 생성된 캐릭터 씬에 표시

### Phase 4: 상호작용 시스템 🎯
**목표:** 코인을 사용해 캐릭터와 상호작용

#### Step 4.1: 기본 액션 구현
- [ ] 밥 주기 버튼 (SwiftUI) → SpriteKit 애니메이션 트리거
- [ ] 놀아주기 버튼 → 캐릭터 반응 애니메이션
- [ ] 코인 차감 로직 연동
- [ ] 캐릭터 상태(배고픔, 행복도) 데이터 모델 생성

**학습 포인트:**
- SwiftUI → SpriteKit 이벤트 전달
- 상태 관리 (ObservableObject)
- 애니메이션 체이닝

#### Step 4.2: 고급 상호작용
- [ ] 파티클 효과 추가 (하트, 별 등)
- [ ] 사운드 효과 (AVFoundation)
- [ ] 터치 제스처로 쓰다듬기
- [ ] 상태에 따른 자동 애니메이션 변화

### Phase 5: 데이터 영속성 및 동기화 🎯
**목표:** iOS ↔ watchOS 데이터 공유 및 영속성

#### Step 5.1: Core Data 설정
- [ ] Shared 폴더에 Core Data 모델 생성
- [ ] `PersistenceController` 구현 (App Group 사용)
- [ ] iOS와 watchOS에서 동일한 데이터 접근
- [ ] 캐릭터 저장/불러오기 테스트

**학습 포인트:**
- Core Data + App Groups 설정
- NSPersistentCloudKitContainer vs NSPersistentContainer
- 멀티 타겟에서 Core Data 공유

#### Step 5.2: 백그라운드 동기화
- [ ] Watch에서 캐릭터 상태 변경 시 iOS로 전파
- [ ] iOS에서 네트워크 작업 완료 시 Watch로 전파
- [ ] WatchConnectivity 프레임워크 연동 (선택)
- [ ] 충돌 해결 로직 (같은 데이터 동시 수정 시)

#### Step 5.3: 성능 최적화 (watchOS)
- [ ] 메모리 최적화 (텍스처 캐싱, 노드 재사용)
- [ ] 배터리 최적화 (불필요한 애니메이션 일시정지)
- [ ] 백그라운드에서 HealthKit 업데이트

### Phase 6: iOS 컴패니언 앱 기능 🎯
**목표:** iOS에서만 가능한 확장 기능 구현

#### Step 6.1: 컬렉션 도감
- [ ] 키웠던 모든 캐릭터 리스트 표시
- [ ] 그리드/리스트 뷰 전환
- [ ] 필터링 (유전자 타입, 날짜 등)
- [ ] 검색 기능

#### Step 6.2: 상세 통계 뷰
- [ ] 개별 캐릭터 상세 페이지
- [ ] 성장 그래프 (Charts 프레임워크)
- [ ] 유전자 트리 시각화
- [ ] 타임라인 (주요 이벤트 기록)

#### Step 6.3: 설정 및 관리
- [ ] 알림 설정 (캐릭터 상태 알림)
- [ ] 계정 관리 (향후 로그인 시스템)
- [ ] 데이터 백업/복원
- [ ] 앱 정보 및 크레딧

### Phase 7: 네트워크 기능 (iOS 중심) 🔮
**목표:** 멀티플레이어 및 소셜 기능

#### Step 7.1: 서버 통신 기초
- [ ] REST API 구조 설계
- [ ] NetworkService 구현 (URLSession)
- [ ] 인증 시스템 (JWT 또는 OAuth)
- [ ] 에러 핸들링 및 재시도 로직

#### Step 7.2: 유저 탐색 및 매칭
- [ ] 주변 유저 탐색 (위치 기반 또는 랜덤)
- [ ] 유저 프로필 조회
- [ ] 친구 추가/삭제
- [ ] 친구 목록 관리

#### Step 7.3: 번식 시스템
- [ ] 다른 유저와 번식 요청/수락
- [ ] 유전자 조합 알고리즘 (서버 또는 클라이언트)
- [ ] 새 캐릭터 생성 및 양쪽 유저에게 전달
- [ ] 번식 히스토리 기록

#### Step 7.4: 커뮤니티 기능
- [ ] 랭킹 시스템 (레벨, 희귀도 등)
- [ ] 갤러리 (다른 유저 캐릭터 구경)
- [ ] 좋아요 및 댓글
- [ ] 이벤트 및 공지사항

## 현재 작업 진행 방침

1. **튜토리얼 진행 시**: 각 Step별로 작은 단위로 커밋하며 학습
2. **질문 우선**: 새로운 개념이 나오면 먼저 설명 요청
3. **테스트 코드 작성**: 가능한 한 각 기능마다 간단한 테스트 추가
4. **점진적 리팩토링**: 작동하는 코드를 먼저 만들고, 나중에 개선

## 기술 참고사항

### WeatherKit (테스트 완료)
- `WatchTest/ContentView.swift` 및 `WatchTest Watch App/ContentView.swift`에 구현
- Phase 1 시작 시 해당 코드는 제거하거나 별도 파일로 이동 예정

### HealthKit 설정
- Entitlements 파일에 이미 추가됨: `com.apple.developer.healthkit`
- Privacy 설정 필요: Info.plist에 `NSHealthShareUsageDescription` 추가 필요
- 실제 디바이스 또는 시뮬레이터 Health 앱에서 테스트 데이터 생성 가능
- **watchOS 전용**: iOS 앱은 HealthKit 사용하지 않음 (Watch에서만 걸음수 수집)

### App Groups 및 데이터 동기화
- 이미 설정됨: `group.com.sello.WatchTest`
- UserDefaults, FileManager, Core Data 모두 App Groups 경로 사용 가능
- **UserDefaults 예시:**
  ```swift
  let shared = UserDefaults(suiteName: "group.com.sello.WatchTest")
  shared?.set(coins, forKey: "userCoins")
  ```
- **Core Data 예시:**
  ```swift
  let containerURL = FileManager.default.containerURL(
      forSecurityApplicationGroupIdentifier: "group.com.sello.WatchTest"
  )
  ```

### SpriteKit 성능 팁
- **Texture Atlas 사용**: `.atlas` 폴더로 자동 최적화
- **노드 재사용**: 자주 생성/삭제되는 노드는 풀링 사용
- **불필요한 업데이트 중단**: 화면 밖이면 애니메이션 일시정지
- **프레임레이트 제한**: watchOS는 기본 60fps보다 30fps도 충분할 수 있음
- **watchOS 전용**: iOS에서는 SpriteKit 사용하지 않음 (정적 이미지만 표시)

### iOS vs watchOS 차이점
| 기능 | watchOS | iOS |
|------|---------|-----|
| 게임 플레이 | ✅ 메인 | ❌ 없음 |
| SpriteKit | ✅ 사용 | ❌ 미사용 |
| HealthKit | ✅ 걸음수 수집 | ❌ 미사용 |
| 네트워크 | ⚠️ 제한적 | ✅ 모든 API |
| Core Data | ✅ 읽기/쓰기 | ✅ 메인 저장소 |
| 복잡한 UI | ❌ 간단하게 | ✅ 상세 정보 |
| 백그라운드 작업 | ⚠️ 매우 제한적 | ✅ 자유로움 |

### watchOS 제약사항
- 화면 크기: 매우 작음 (40-49mm), UI 요소는 크고 간단하게
- 배터리: 복잡한 애니메이션은 제한적으로 사용
- 세션 시간: 사용자가 짧은 시간만 보는 것을 가정
- 메모리: iOS보다 훨씬 제한적, 리소스 크기 주의
- 네트워크: iOS 앱을 통한 프록시 방식 권장 (직접 API 호출은 비효율적)

## 다음 단계

**Phase 1 시작 준비:**
1. WeatherKit 테스트 코드 정리/이동
2. HealthKit 튜토리얼 Step 1.1 시작
3. 걸음수를 읽어서 콘솔에 출력하는 것을 첫 목표로 설정

**Claude에게 요청할 수 있는 것:**
- "Phase 1 Step 1.1 시작하자. HealthKit 권한 요청 코드를 단계별로 설명하면서 작성해줘"
- "지금 작성한 코드에서 HKStatisticsQuery가 정확히 어떻게 동작하는지 설명해줘"
- "SpriteKit의 좌표계가 SwiftUI와 어떻게 다른지 알려줘"
- "현재 코드의 메모리 사용을 최적화할 방법이 있을까?"

## Development Team
- `DEVELOPMENT_TEAM = JT5962HWNA` (다른 개발자는 자신의 팀 ID로 변경 필요)
