# CLAUDE.md

This file provides guidance to Claude Code when working with code in this repository.

## 프로젝트 개요

**듀얼 플랫폼 다마고치 게임**: watchOS에서 캐릭터를 키우고, iOS에서 관리 및 확장 기능 제공

### 앱 역할 분담

#### watchOS 앱 (메인 게임플레이)
- 캐릭터와의 실시간 상호작용 (아이템 사용, 수면 등)
- HealthKit으로 걸음수 수집 및 재화 획득
- SpriteKit 기반 캐릭터 애니메이션
- 손목에서 즉시 확인 가능한 빠른 체크인

#### iOS 앱 (컴패니언 - 계획 중)
- 컬렉션 도감 및 상세 통계
- 네트워크 기능 (유저 만남, 번식, 커뮤니티)
- 복잡한 UI 및 설정 관리

### 데이터 동기화
- App Groups (`group.com.sello.WatchTest`)로 실시간 데이터 공유
- CloudKit (향후 계획): 멀티 디바이스 동기화

### 핵심 기술 스택
- **SpriteKit**: 파츠 조합 및 캐릭터 애니메이션 (watchOS)
- **HealthKit**: 걸음수 데이터 수집 및 재화 변환 (watchOS 전용)
- **SwiftUI**: 전체 UI 프레임워크
- **Core Data**: 캐릭터 영속성 관리 (향후 계획)
- **Networking**: REST API (향후 계획)

### 개발 방향
단계별 학습을 통해 HealthKit과 SpriteKit을 점진적으로 익히며 구현. 작동하는 코드를 먼저 만들고 점진적으로 개선하는 방식.

## Claude 작업 방식

### 핵심 원칙: 학습 중심 프로젝트
**이 프로젝트는 학습을 위한 프로젝트입니다.** 사용자가 직접 코드를 작성하며 학습하는 것이 목표입니다.

### 코드 제공 방식
**절대로 파일을 직접 수정하지 않습니다.**

1. **코드는 Claude에 작성해서 보여주기**
   - 사용자가 Xcode에서 직접 타이핑할 수 있도록 전체 코드를 보여줌
   - 코드 블록으로 명확하게 표시
   - "복사해서 붙여넣으세요" 같은 표현 금지 (사용자가 직접 타이핑함)

2. **파일 수정 전 반드시 현재 상태 확인**
   - Read 도구로 파일 내용 먼저 확인
   - 이미 수정된 내용을 다시 수정하지 않도록 주의

3. **설명 수준 (사용자는 iOS 개발자)**
   - **기본적인 Swift/iOS 개념 설명 불필요**
   - **watchOS 특화 내용만 설명**: 제약사항, iOS와의 차이점, watchOS 전용 API
   - **SpriteKit 관련 설명**: 처음 다루는 프레임워크이므로 개념 설명 필요
   - 일반적인 SwiftUI 등은 설명 생략

### 작업 진행 방식
1. 구현할 내용을 단계별로 설명
2. 필요한 파일 경로와 구조 안내
3. **전체 코드를 코드 블록으로 보여주기**
4. **필요한 부분만 간단히 설명** (watchOS/SpriteKit 중심)
5. 구현 시 주의할 점 설명
6. 사용자가 Xcode에서 직접 타이핑
7. 작성된 코드에 대한 피드백 및 개선 제안

### 세션 간 기억 사항
세션이 끝나도 다음 세션에서 일관된 작업 방식을 유지하기 위해 이 문서에 중요 사항 기록

### CLAUDE.md 자동 업데이트 규칙
사용자가 다음과 같은 피드백을 주면 **즉시 CLAUDE.md를 업데이트**:
- 작업 방식에 대한 지적 (예: "너무 자세해", "직접 하지 마", "이렇게 해줘")
- 설명 스타일에 대한 수정 요청
- 반복되는 실수에 대한 지적
- 세션 간 기억해야 할 중요한 규칙

**업데이트 후 사용자에게 알림**: "CLAUDE.md 업데이트 완료"

## 빌드 및 테스트

### 기본 빌드
```bash
# Watch 앱 빌드
xcodebuild -scheme "WatchTest Watch App" -configuration Debug -sdk watchsimulator \
  -destination 'platform=watchOS Simulator,name=Apple Watch Series 10 (46mm)'

# iOS 앱 빌드
xcodebuild -scheme WatchTest -configuration Debug -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

### 테스트
```bash
# Watch 앱 Unit 테스트
xcodebuild test -scheme "WatchTest Watch App" \
  -destination 'platform=watchOS Simulator,name=Apple Watch Series 10 (46mm)'
```

## 개발 시 중요 사항

### watchOS 전용 기능
- **HealthKit**: iOS 앱은 HealthKit 사용하지 않음 (Watch에서만 걸음수 수집)
- **SpriteKit**: iOS에서는 SpriteKit 미사용 (정적 이미지만 표시)
- **게임플레이**: 모든 상호작용은 watchOS에서만 발생

### watchOS 제약사항
- 화면 크기 매우 작음 (40-49mm) → UI 요소는 크고 간단하게
- 배터리 제약 → 복잡한 애니메이션 제한적 사용
- 세션 시간 짧음 → 빠른 체크인 중심 설계
- 메모리 제한 → 리소스 크기 주의
- 네트워크 제한 → iOS 앱 프록시 방식 권장

### watchOS 코드 작성 시 주의
- **반드시 watchOS에서 동작하는 API인지 확인**
- UIKit API 사용 불가 → SwiftUI 또는 SpriteKit 사용
- 백그라운드 작업 매우 제한적
- 메모리 누수 방지 (weak self, deinit 확인)

### App Groups 데이터 공유
UserDefaults, FileManager, Core Data 모두 App Groups 경로 사용 가능.

**UserDefaults 예시:**
```swift
let shared = UserDefaults(suiteName: "group.com.sello.WatchTest")
shared?.set(value, forKey: "key")
```

**Core Data 예시:**
```swift
let containerURL = FileManager.default.containerURL(
    forSecurityApplicationGroupIdentifier: "group.com.sello.WatchTest"
)
```

### SpriteKit 성능 팁
- Texture Atlas (`.atlas` 폴더) 사용으로 자동 최적화
- 자주 생성/삭제되는 노드는 풀링 사용
- 화면 밖이면 애니메이션 일시정지
- watchOS는 30fps도 충분할 수 있음 (배터리 고려)

### iOS vs watchOS 차이점
| 기능 | watchOS | iOS |
|------|---------|-----|
| 게임 플레이 | 메인 | 없음 |
| SpriteKit | 사용 | 미사용 |
| HealthKit | 걸음수 수집 | 미사용 |
| 네트워크 | 제한적 | 모든 API |
| Core Data | 읽기/쓰기 | 메인 저장소 |
| 복잡한 UI | 간단하게 | 상세 정보 |
| 백그라운드 작업 | 매우 제한적 | 자유로움 |

## PROGRESS.md 작성 가이드

PROGRESS.md는 **개발 히스토리를 순차적으로 기록하는 문서**입니다.

### 작성 원칙
1. **체크 표시(✅, ❌, 🎯 등) 사용 금지** - 상태 표시 없이 내용만 기록
2. **"완료", "진행 중", "예정" 같은 상태 표현 금지** - 사실만 기술
3. **일기장처럼 작성 금지** - 간결한 요약만
4. **순차적 기록** - 개발 순서대로 무엇을 했는지만 기록
5. **기술적 내용 중심** - 감정이나 평가 없이 구현 내용만
6. **리팩토링/정리 작업 제외** - 코드 정리, 리소스 정리, 파일 이동 등은 기록하지 않음
7. **결과론적으로만 기록** - 새로운 기능 구현만 기록, 유지보수 작업은 제외

### 작성 구조
```markdown
# 개발 진행 기록

## 전체 구조
(현재 프로젝트의 전체 구조를 간략히 설명)

## 구현 순서

### 1. 제목
(무엇을 구현했는지)
- 주요 구현 내용 나열
- 기술적 포인트 간략히
- 주의사항이나 특이사항

### 2. 제목
...
```

### 예시 (좋은 작성)
```markdown
### HealthKit 권한 요청 구현
- StepCounter.swift 생성, HKHealthStore 초기화
- requestAuthorization() 함수로 걸음수 권한 요청
- ContentView에서 버튼으로 권한 요청 트리거
- Privacy 설정은 Watch App 타겟에만 추가
```

### 예시 (나쁜 작성)
```markdown
### Step 1.1: HealthKit 권한 요청 ✅
- [x] StepCounter.swift 생성 완료!
- [x] 권한 요청 구현 완료!
오늘은 HealthKit 권한을 성공적으로 구현했습니다. 생각보다 쉬웠어요.
다음에는 걸음수를 읽어오는 기능을 구현할 예정입니다.
```

## Development Team
- `DEVELOPMENT_TEAM = JT5962HWNA` (다른 개발자는 자신의 팀 ID로 변경 필요)
