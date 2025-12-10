# 📱 Agora 프로젝트 기능 및 페이지 명세서

이 문서는 Agora 프로젝트의 주요 기능, 기술 스택, 그리고 화면 구성을 정리한 문서입니다. PPT 제작 시 기초 자료로 활용할 수 있습니다.

## 1. 프로젝트 개요 (Overview)
- **프로젝트명:** Agora (아고라)
- **주요 컨셉:** AI 기반의 스마트한 소통을 지원하는 팀 협업 및 메신저 플랫폼
- **핵심 가치:** Gemini AI를 활용한 의사소통 보조(번역, 요약, 교정)와 강력한 팀 관리 도구의 결합

---

## 2. 사용 기술 (Tech Stack)

### **Frontend**
- **Framework:** Flutter (Dart)
- **State Management:** Riverpod
- **Networking:** Dio (HTTP), STOMP Client (WebSocket)

### **AI & Intelligence**
- **Model:** Google Gemini 2.0 Flash
- **Features:** 텍스트 생성, 번역, 문법 교정, 감정/톤 분석, 대화 요약

### **Local & Storage**
- **Storage:** Shared Preferences, Flutter Secure Storage (보안 저장소)
- **Database:** (Local Caching 구조 적용 추정)

### **Modules & Libraries**
- **Media:** Image Picker, File Picker, Audioplayers, Record
- **UI/UX:** Flutter Local Notifications, Google Fonts, Flutter SVG

---

## 3. 핵심 기능 (Key Features)

### **🤖 AI 인공지능 비서 (Powered by Gemini)**
사용자의 생산성과 커뮤니케이션 품질을 높여주는 차별화 기능입니다.
*   **스마트 답장 제안:** 대화 맥락을 파악하여 적절한 답변 아이디어 제공
*   **실시간 번역:** 다국어 소통을 위한 메시지 자동 번역
*   **문법 및 맞춤법 교정:** 한국어 문법 오류 검사 및 수정 제안
*   **메시지 톤(Tone) 변환:** 상황에 맞춰 메시지 어조 변경 (비즈니스, 친근하게, 정중하게 등 5가지 모드)
*   **대화 요약:** 긴 채팅 내용을 핵심 주제와 결론 위주로 요약
*   **빠른 답장 추천:** 마지막 메시지에 바로 보낼 수 있는 3가지 단답형 옵션 제공

### **🏢 팀 협업 (Teams)**
조직적인 업무 처리를 위한 올인원 워크스페이스 기능입니다.
*   **팀/조직 관리:** 팀 생성, 멤버 초대 및 권한 부여
*   **스마트 조직도:** 팀원 구조 및 직책 시각화
*   **공유 캘린더:** 팀 일정 관리 및 공유
*   **공지사항 & 게시판:** 중요 사항 전파를 위한 공지 기능
*   **할 일(To-Do) 관리:** 개인 및 팀 업무 리스트 추적

### **💬 채팅 & 커뮤니케이션**
*   **다양한 채팅 모드:** 1:1 채팅, 그룹 채팅, 팀 전용 채팅방
*   **채팅방 폴더링:** 많은 채팅방을 효율적으로 관리하는 폴더 기능
*   **미디어 갤러리:** 대화 중 주고받은 사진/파일 모아보기
*   **실시간 알림:** 메시지 및 주요 활동 푸시 알림

---

## 4. 주요 페이지 구성 (Pages & Screens)

PPT의 각 장표에 들어갈 주요 화면 목록입니다.

### **🔐 인증 (Auth)**
| 화면명(Class) | 기능 설명 |
| :--- | :--- |
| **LoginScreen** | 이메일/비밀번호 로그인 |
| **SignupScreen** | 신규 회원가입 |
| **ForgotPasswordScreen** | 비밀번호 재설정 요청 |
| **PhoneVerificationScreen** | 휴대폰 본인 인증 |
| **AccountRecoveryHelp** | 계정 찾기 도움말 |

### **🏠 홈 & 메인 (Home)**
| 화면명(Class) | 기능 설명 |
| :--- | :--- |
| **HomeScreen** | 앱의 메인 대시보드 (하단 탭 내비게이션 포함) |

### **💬 채팅 (Chat)**
| 화면명(Class) | 기능 설명 |
| :--- | :--- |
| **ChatScreen** | 전체 채팅방 목록 리스트 |
| **ConversationScreen** | 1:1 대화방 상세 |
| **GroupChatScreen** | 여러 명과 대화하는 그룹 채팅 |
| **TeamChatScreen** | 팀원들과 소통하는 팀 전용 채팅 |
| **MediaGalleryScreen** | 채팅방 미디어 모아보기 |
| **CreateChatFolder** | 채팅방 정리용 폴더 생성 |

### **🏢 팀 워크스페이스 (Teams)**
| 화면명(Class) | 기능 설명 |
| :--- | :--- |
| **TeamDetailScreen** | 팀 메인 화면 및 대시보드 |
| **OrgChartScreen** | 조직도 보기 |
| **CalendarScreen** | 팀 일정/캘린더 뷰 |
| **NoticeListScreen** | 공지사항 목록 |
| **CreateNoticeScreen** | 공지 작성하기 |
| **TodoScreen** | 할 일(To-Do) 목록 및 관리 |
| **AddTeamMemberScreen** | 팀원 추가/초대 |

### **👤 프로필 (Profile)**
| 화면명(Class) | 기능 설명 |
| :--- | :--- |
| **ProfileScreen** | 내 프로필 상세 보기 |
| **EditProfileScreen** | 프로필 정보 및 사진 수정 |
| **AddFriendScreen** | 친구 검색 및 추가 |
