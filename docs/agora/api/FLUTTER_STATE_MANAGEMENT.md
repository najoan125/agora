# Flutter 상태 관리 패턴

## 개요

Riverpod을 사용한 효율적인 상태 관리

---

## 1. Riverpod 소개

### 특징

- **선언형**: 상태를 선언적으로 정의
- **타입 안정성**: 제네릭으로 타입 보장
- **의존성 주입**: 자동 의존성 해결
- **성능**: 필요한 부분만 리빌드
- **테스트 용이**: Mock 생성 간편

---

## 2. Provider 종류

### 2.1 State Provider (간단한 상태)

```dart
// 카운터 예제
final counterProvider = StateProvider<int>((ref) => 0);

// 사용
class CounterWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);

    return Text('$count',
      style: Theme.of(context).textTheme.headline6
    );
  }
}

// 업데이트
ref.read(counterProvider.notifier).state++;
```

### 2.2 State Notifier Provider (복잡한 상태)

```dart
// 상태 클래스
class UserState {
  final String name;
  final String email;
  final bool isLoading;
  final String? error;

  UserState({
    required this.name,
    required this.email,
    this.isLoading = false,
    this.error,
  });

  UserState copyWith({
    String? name,
    String? email,
    bool? isLoading,
    String? error,
  }) {
    return UserState(
      name: name ?? this.name,
      email: email ?? this.email,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Notifier
class UserNotifier extends StateNotifier<UserState> {
  final UserRepository userRepository;

  UserNotifier(this.userRepository)
      : super(UserState(name: '', email: ''));

  Future<void> updateUser(String name) async {
    state = state.copyWith(isLoading: true);

    try {
      await userRepository.updateUser(name);
      state = state.copyWith(
        name: name,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

// Provider
final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier(ref.watch(userRepositoryProvider));
});

// 사용
class UserScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return Column(
      children: [
        Text(user.name),
        if (user.isLoading) CircularProgressIndicator(),
        if (user.error != null) Text('Error: ${user.error}'),
        ElevatedButton(
          onPressed: () {
            ref.read(userProvider.notifier).updateUser('New Name');
          },
          child: Text('Update'),
        ),
      ],
    );
  }
}
```

### 2.3 Future Provider (비동기 데이터)

```dart
// 데이터 조회
final userFutureProvider = FutureProvider<User>((ref) async {
  final userRepository = ref.watch(userRepositoryProvider);
  return userRepository.getUser();
});

// 사용
class UserDetailScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userFutureProvider);

    return userAsync.when(
      data: (user) => Text(user.name),
      loading: () => CircularProgressIndicator(),
      error: (error, stackTrace) => Text('Error: $error'),
    );
  }
}

// 수동 갱신
ElevatedButton(
  onPressed: () {
    ref.refresh(userFutureProvider);
  },
  child: Text('Refresh'),
)
```

### 2.4 Family Modifier (매개변수화)

```dart
// 특정 사용자 조회
final userByIdProvider = FutureProvider.family<User, int>((ref, userId) async {
  final userRepository = ref.watch(userRepositoryProvider);
  return userRepository.getUserById(userId);
});

// 사용
class UserDetailScreen extends ConsumerWidget {
  final int userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userByIdProvider(userId));

    return userAsync.when(
      data: (user) => Text(user.name),
      loading: () => CircularProgressIndicator(),
      error: (error, stackTrace) => Text('Error: $error'),
    );
  }
}
```

### 2.5 Select (특정 필드만 감시)

```dart
// 전체 상태 감시
final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier();
});

// 특정 필드만 감시 (리빌드 최적화)
final userNameProvider = Provider((ref) {
  return ref.watch(userProvider.select((state) => state.name));
});

// 사용
class UserNameWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(userNameProvider);
    // name이 변경될 때만 리빌드
    return Text(name);
  }
}
```

---

## 3. 인증 상태 관리 (실제 예제)

### lib/presentation/providers/auth_state_provider.dart

```dart
enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthState {
  final AuthStatus status;
  final String? userId;
  final String? email;
  final String? agoraId;
  final String? error;
  final String? accessToken;

  AuthState({
    required this.status,
    this.userId,
    this.email,
    this.agoraId,
    this.error,
    this.accessToken,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? userId,
    String? email,
    String? agoraId,
    String? error,
    String? accessToken,
  }) {
    return AuthState(
      status: status ?? this.status,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      agoraId: agoraId ?? this.agoraId,
      error: error ?? this.error,
      accessToken: accessToken ?? this.accessToken,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository authRepository;

  AuthNotifier(this.authRepository)
      : super(AuthState(status: AuthStatus.initial)) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final isLoggedIn = await authRepository.isLoggedIn();
      if (isLoggedIn) {
        final email = await authRepository.getUserEmail();
        state = state.copyWith(
          status: AuthStatus.authenticated,
          email: email,
        );
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: e.toString(),
      );
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      await authRepository.login(email, password);
      final user = await authRepository.getUser();

      state = state.copyWith(
        status: AuthStatus.authenticated,
        userId: user.id.toString(),
        email: user.email,
        agoraId: user.agoraId,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: e.toString(),
      );
    }
  }

  Future<void> logout() async {
    try {
      await authRepository.logout();
      state = AuthState(status: AuthStatus.unauthenticated);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> refreshToken() async {
    try {
      await authRepository.refreshAccessToken();
    } catch (e) {
      await logout();
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

// 편의용 Provider
final isAuthenticatedProvider = Provider((ref) {
  return ref.watch(authProvider.select((state) => state.status == AuthStatus.authenticated));
});

final currentUserEmailProvider = Provider((ref) {
  return ref.watch(authProvider.select((state) => state.email));
});
```

---

## 4. 프로필 상태 관리

### lib/presentation/providers/profile_provider.dart

```dart
class ProfileState {
  final String agoraId;
  final String displayName;
  final String? profileImage;
  final String? bio;
  final bool isLoading;
  final String? error;

  ProfileState({
    required this.agoraId,
    required this.displayName,
    this.profileImage,
    this.bio,
    this.isLoading = false,
    this.error,
  });

  ProfileState copyWith({
    String? agoraId,
    String? displayName,
    String? profileImage,
    String? bio,
    bool? isLoading,
    String? error,
  }) {
    return ProfileState(
      agoraId: agoraId ?? this.agoraId,
      displayName: displayName ?? this.displayName,
      profileImage: profileImage ?? this.profileImage,
      bio: bio ?? this.bio,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final ProfileRepository profileRepository;

  ProfileNotifier(this.profileRepository)
      : super(ProfileState(agoraId: '', displayName: '')) {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await profileRepository.getMyProfile();
      state = ProfileState(
        agoraId: profile.agoraId,
        displayName: profile.displayName,
        profileImage: profile.profileImage,
        bio: profile.bio,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateDisplayName(String displayName) async {
    state = state.copyWith(isLoading: true);

    try {
      await profileRepository.updateProfile(displayName: displayName);
      state = state.copyWith(
        displayName: displayName,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> updateProfileImage(String imagePath) async {
    state = state.copyWith(isLoading: true);

    try {
      final result = await profileRepository.uploadProfileImage(imagePath);
      state = state.copyWith(
        profileImage: result.fileUrl,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    await _loadProfile();
  }
}

final profileProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier(ref.watch(profileRepositoryProvider));
});
```

---

## 5. 채팅 상태 관리

### lib/presentation/providers/chat_provider.dart

```dart
class ChatListNotifier extends StateNotifier<AsyncValue<List<Chat>>> {
  final ChatRepository chatRepository;

  ChatListNotifier(this.chatRepository)
      : super(const AsyncValue.loading()) {
    _loadChats();
  }

  Future<void> _loadChats() async {
    try {
      final chats = await chatRepository.getChatList();
      state = AsyncValue.data(chats);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createChat(String targetAgoraId) async {
    try {
      final newChat = await chatRepository.createChat(targetAgoraId);
      state.whenData((chats) {
        state = AsyncValue.data([newChat, ...chats]);
      });
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    await _loadChats();
  }
}

final chatListProvider =
    StateNotifierProvider<ChatListNotifier, AsyncValue<List<Chat>>>((ref) {
  return ChatListNotifier(ref.watch(chatRepositoryProvider));
});

// 특정 채팅방의 메시지
final chatMessagesProvider = FutureProvider.family<List<ChatMessage>, int>((
  ref,
  chatId,
) async {
  final chatRepository = ref.watch(chatRepositoryProvider);
  return chatRepository.getMessages(chatId);
});
```

---

## 6. 친구 관계 상태 관리

### lib/presentation/providers/friend_provider.dart

```dart
final friendListProvider = FutureProvider<List<Friend>>((ref) async {
  final friendRepository = ref.watch(friendRepositoryProvider);
  return friendRepository.getFriends();
});

final friendRequestsProvider = FutureProvider<List<FriendRequest>>((ref) async {
  final friendRepository = ref.watch(friendRepositoryProvider);
  return friendRepository.getReceivedRequests();
});

// 특정 사용자가 친구인지 확인
final isFriendProvider = Provider.family<Future<bool>, String>((ref, agoraId) async {
  final friendRepository = ref.watch(friendRepositoryProvider);
  final friends = await ref.watch(friendListProvider.future);
  return friends.any((f) => f.agoraId == agoraId);
});

class FriendActionNotifier extends StateNotifier<AsyncValue<void>> {
  final FriendRepository friendRepository;

  FriendActionNotifier(this.friendRepository)
      : super(const AsyncValue.data(null));

  Future<void> sendFriendRequest(String agoraId) async {
    state = const AsyncValue.loading();
    try {
      await friendRepository.sendFriendRequest(agoraId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> acceptFriendRequest(int requestId) async {
    state = const AsyncValue.loading();
    try {
      await friendRepository.acceptFriendRequest(requestId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> rejectFriendRequest(int requestId) async {
    state = const AsyncValue.loading();
    try {
      await friendRepository.rejectFriendRequest(requestId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> removeFriend(int friendId) async {
    state = const AsyncValue.loading();
    try {
      await friendRepository.removeFriend(friendId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final friendActionProvider = StateNotifierProvider<FriendActionNotifier, AsyncValue<void>>((ref) {
  return FriendActionNotifier(ref.watch(friendRepositoryProvider));
});
```

---

## 7. 의존성 주입 (Repository)

```dart
// API
final apiClientProvider = Provider((ref) => ApiClient());

// API 데이터 소스
final chatApiProvider = Provider((ref) => ChatApi(ref.watch(apiClientProvider)));
final profileApiProvider = Provider((ref) => ProfileApi(ref.watch(apiClientProvider)));
final friendApiProvider = Provider((ref) => FriendApi(ref.watch(apiClientProvider)));

// Repository
final chatRepositoryProvider = Provider((ref) => ChatRepository(
  chatApi: ref.watch(chatApiProvider),
));

final profileRepositoryProvider = Provider((ref) => ProfileRepository(
  profileApi: ref.watch(profileApiProvider),
));

final friendRepositoryProvider = Provider((ref) => FriendRepository(
  friendApi: ref.watch(friendApiProvider),
));

// 로컬 저장소
final secureStorageProvider = Provider((ref) => SecureStorageManager());

// 인증
final authRepositoryProvider = Provider((ref) => AuthRepository(
  authApi: ref.watch(authApiProvider),
  storage: ref.watch(secureStorageProvider),
));
```

---

## 8. 사용 패턴 정리

### 패턴 1: 읽기만 하는 경우

```dart
final count = ref.watch(counterProvider);
```

### 패턴 2: 쓰기 + 읽기

```dart
final count = ref.watch(counterProvider);
ref.read(counterProvider.notifier).state++;
```

### 패턴 3: 콜백에서 상태 업데이트

```dart
ElevatedButton(
  onPressed: () {
    ref.read(counterProvider.notifier).state++;
  },
  child: Text('Increment'),
)
```

### 패턴 4: 의존성 기반 상태

```dart
final userIdProvider = Provider((ref) {
  final auth = ref.watch(authProvider);
  return auth.userId;
});
```

### 패턴 5: 상태 갱신 (캐시 무효화)

```dart
ElevatedButton(
  onPressed: () {
    ref.refresh(chatListProvider);
  },
  child: Text('Refresh'),
)
```

---

## 9. 테스트 예제

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  test('counter increment', () {
    final container = ProviderContainer();
    expect(container.read(counterProvider), 0);

    container.read(counterProvider.notifier).state++;
    expect(container.read(counterProvider), 1);
  });

  test('auth provider', () async {
    final mockAuthRepository = MockAuthRepository();

    when(mockAuthRepository.isLoggedIn())
        .thenAnswer((_) async => true);

    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockAuthRepository),
      ],
    );

    await container.read(authProvider.notifier).checkAuthStatus();

    expect(
      container.read(authProvider).status,
      AuthStatus.authenticated,
    );
  });
}
```

---

## 주의사항

1. **Select 사용**: 전체 상태가 아닌 특정 필드만 감시
2. **AsyncValue.when**: Future 상태 처리 시 필수
3. **메모리**: Provider는 기본적으로 유지되므로, 필요 시 `.autoDispose` 사용
4. **의존성**: 선언 순서 중요 (하위 레벨 → 상위 레벨)

---

## 다음 단계

Flutter 가이드 작성 완료! 이제 docs/auth/ 디렉토리의 인증 가이드를 작성하면 됩니다.
