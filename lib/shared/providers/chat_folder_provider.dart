import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/chat_folder_service.dart';
import '../../data/models/chat/chat_folder.dart';

/// ChatFolder 서비스 Provider
final chatFolderServiceProvider = Provider<ChatFolderService>((ref) {
  return ChatFolderService();
});

/// 채팅 폴더 목록 Provider
final chatFolderListProvider =
    FutureProvider.autoDispose<List<ChatFolder>>((ref) async {
  final service = ref.watch(chatFolderServiceProvider);
  final result = await service.getFolders();

  return result.when(
    success: (folders) => folders,
    failure: (error) => throw error,
  );
});

/// 채팅 폴더 작업 상태
class ChatFolderActionState {
  final bool isLoading;
  final String? error;
  final String? successMessage;

  const ChatFolderActionState({
    this.isLoading = false,
    this.error,
    this.successMessage,
  });
}

/// 채팅 폴더 작업 Notifier
class ChatFolderActionNotifier extends StateNotifier<ChatFolderActionState> {
  final ChatFolderService _service;
  final Ref _ref;

  ChatFolderActionNotifier(this._service, this._ref)
      : super(const ChatFolderActionState());

  /// 폴더 생성
  Future<ChatFolder?> createFolder({
    required String name,
    String? color,
  }) async {
    state = const ChatFolderActionState(isLoading: true);

    final result = await _service.createFolder(
      name: name,
      color: color,
    );

    return result.when(
      success: (folder) {
        state = const ChatFolderActionState(successMessage: '폴더가 생성되었습니다.');
        _ref.invalidate(chatFolderListProvider);
        return folder;
      },
      failure: (error) {
        state = ChatFolderActionState(error: error.displayMessage);
        return null;
      },
    );
  }

  /// 폴더 수정
  Future<bool> updateFolder(
    String folderId, {
    String? name,
    String? color,
  }) async {
    state = const ChatFolderActionState(isLoading: true);

    final result = await _service.updateFolder(
      folderId,
      name: name,
      color: color,
    );

    return result.when(
      success: (_) {
        state = const ChatFolderActionState(successMessage: '폴더가 수정되었습니다.');
        _ref.invalidate(chatFolderListProvider);
        return true;
      },
      failure: (error) {
        state = ChatFolderActionState(error: error.displayMessage);
        return false;
      },
    );
  }

  /// 폴더 삭제
  Future<bool> deleteFolder(String folderId) async {
    state = const ChatFolderActionState(isLoading: true);

    final result = await _service.deleteFolder(folderId);

    return result.when(
      success: (_) {
        state = const ChatFolderActionState();
        _ref.invalidate(chatFolderListProvider);
        return true;
      },
      failure: (error) {
        state = ChatFolderActionState(error: error.displayMessage);
        return false;
      },
    );
  }

  /// 채팅을 폴더에 추가
  Future<bool> addChatToFolder(String chatId, String folderId) async {
    state = const ChatFolderActionState(isLoading: true);

    final result = await _service.addChatToFolder(chatId, folderId);

    return result.when(
      success: (_) {
        state = const ChatFolderActionState();
        _ref.invalidate(chatFolderListProvider);
        return true;
      },
      failure: (error) {
        state = ChatFolderActionState(error: error.displayMessage);
        return false;
      },
    );
  }

  /// 채팅을 폴더에서 제거
  Future<bool> removeChatFromFolder(String chatId, String folderId) async {
    state = const ChatFolderActionState(isLoading: true);

    final result = await _service.removeChatFromFolder(chatId, folderId);

    return result.when(
      success: (_) {
        state = const ChatFolderActionState();
        _ref.invalidate(chatFolderListProvider);
        return true;
      },
      failure: (error) {
        state = ChatFolderActionState(error: error.displayMessage);
        return false;
      },
    );
  }

  void clearError() {
    state = const ChatFolderActionState();
  }

  void clearSuccessMessage() {
    state = const ChatFolderActionState();
  }
}

/// 채팅 폴더 작업 Provider
final chatFolderActionProvider =
    StateNotifierProvider<ChatFolderActionNotifier, ChatFolderActionState>(
        (ref) {
  final service = ref.watch(chatFolderServiceProvider);
  return ChatFolderActionNotifier(service, ref);
});
