# KnuMiniGroup iOS — 설정 안내

## 프로젝트 구조 (Android와 동일한 MVVM + Repository + DataSource)

```
knu_minigroup/
├── App/EndPoint.swift              # Android app.EndPoint 대응
├── Helper/                         # Resource(Callback), PreferenceManager, HttpClient(Volley 대응),
│                                   # HtmlUtil(jericho 대응), DateUtil, ImageLoader, Toast 확장
├── Dto/                            # User, GroupItem, ArticleItem, ReplyItem, MessageItem,
│                                   # MemberItem, TimetableItem, YouTubeItem
├── Data/                           # Repository (얇은 위임 계층)
│   ├── Remote/                     # XxxRemoteDataSource (Firebase RTDB + LMS/학교 서버 HTTP)
│   └── Local/                      # TimetableLocalDataSource (UserDefaults)
├── ViewModel/                      # Combine @Published 기반 (LiveData 대응)
└── Viewcontrollers/                # 스토리보드 기반 View + ViewModel 바인딩
```

- Minimum Deployment: **iOS 15.6**
- Firebase는 SPM(firebase-ios-sdk 10.x)으로 등록되어 있음 — Xcode가 처음 열 때 자동으로 받아온다.

## 반드시 해야 하는 것: GoogleService-Info.plist

Android 앱과 같은 Firebase 프로젝트(**hhp227-ed727**)에 iOS 앱을 등록해야 한다.

1. [Firebase Console](https://console.firebase.google.com/project/hhp227-ed727) → 프로젝트 설정 → 앱 추가 → iOS
2. 번들 ID: `com.hhp227.knu-minigroup`
3. 내려받은 `GoogleService-Info.plist`를 Xcode에서 `knu_minigroup/` 그룹에 추가 (Copy items if needed + 타겟 체크)
4. Firebase Console → Authentication → 로그인 방법에서 **이메일/비밀번호**가 켜져 있는지 확인 (Android와 공용)

plist가 없으면 앱은 실행되지만 Firebase 기능(로그인/소모임/게시판/채팅)이 동작하지 않는다
(AppDelegate에서 plist 존재시에만 `FirebaseApp.configure()` 호출).

## 로그인

Android와 동일: KNU 통합로그인(knusso) 시도 후 성공하면 Firebase Auth(`아이디@knu.ac.kr`)로
로그인/자동가입. 테스트 계정 `TestUser` / `TestUser` 는 SSO를 우회한다.

## LMS 서버 폐쇄 관련 (Android와 동일한 제약)

- 인기 소모임, 그룹 이미지 업로드, 게시글 이미지 업로드, LMS 학기시간표, 멤버 관리 목록은
  LMS(lms.knu.ac.kr) 폐쇄로 동작하지 않음 — 코드/메소드는 Android와 동일하게 유지되어 있어
  서버가 살아나면 그대로 사용 가능.
- 학사일정(Tab2), 학식 식단, 셔틀 시간표, 대학 공지는 학교 홈페이지 기반이라 동작한다.
  (식단 서버는 http라 Info.plist에 ATS 예외 등록됨)

## 남은 작업 (스토리보드가 필요한 부분)

- MockTimetable/SemesterTimetable/Picture 화면은 기존 플레이스홀더 유지 (ViewModel은 준비됨:
  `MockTimeTableViewModel`, `SemesterTimeTableViewModel`)
- 채팅은 전송 후 재조회 방식 (Android의 ChildEventListener 실시간 수신은 추후)
- 멤버 탭은 Firebase members 목록의 uid 기반 표시 (Android도 이 부분 미완성)
- 드로어 메뉴는 기존 3개(소모임/공지/시간표) 유지 — 식단/셔틀 ViewModel은 준비되어 있어
  스토리보드에 씬만 추가하면 연결 가능
