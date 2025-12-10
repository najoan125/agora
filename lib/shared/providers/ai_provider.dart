import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/ai_service.dart';

/// AI 서비스 Provider
final aiServiceProvider = Provider<AIService>((ref) {
  return AIService();
});

/// AI 요청 상태
class AIRequestState {
  final bool isLoading;
  final String? result;
  final List<String>? suggestions;
  final String? error;

  const AIRequestState({
    this.isLoading = false,
    this.result,
    this.suggestions,
    this.error,
  });

  AIRequestState copyWith({
    bool? isLoading,
    String? result,
    List<String>? suggestions,
    String? error,
  }) {
    return AIRequestState(
      isLoading: isLoading ?? this.isLoading,
      result: result,
      suggestions: suggestions,
      error: error,
    );
  }
}

/// AI 요청 Notifier
class AIRequestNotifier extends StateNotifier<AIRequestState> {
  final AIService _service;

  AIRequestNotifier(this._service) : super(const AIRequestState());

  /// 아이디어 제안
  Future<void> suggestIdeas({
    required List<String> recentMessages,
    String? currentInput,
  }) async {
    state = const AIRequestState(isLoading: true);

    final result = await _service.suggestIdeas(
      recentMessages: recentMessages,
      currentInput: currentInput,
    );

    result.when(
      success: (response) {
        state = AIRequestState(suggestions: response);
      },
      failure: (error) {
        state = AIRequestState(error: error.displayMessage);
      },
    );
  }

  /// 번역
  Future<void> translate({
    required String message,
    required String targetLanguage,
  }) async {
    state = const AIRequestState(isLoading: true);

    final result = await _service.translateMessage(
      message: message,
      targetLanguage: targetLanguage,
    );

    result.when(
      success: (response) {
        state = AIRequestState(result: response);
      },
      failure: (error) {
        state = AIRequestState(error: error.displayMessage);
      },
    );
  }

  /// 문법 검사
  Future<void> checkGrammar({
    required String message,
  }) async {
    state = const AIRequestState(isLoading: true);

    final result = await _service.checkGrammar(message: message);

    result.when(
      success: (response) {
        state = AIRequestState(result: response);
      },
      failure: (error) {
        state = AIRequestState(error: error.displayMessage);
      },
    );
  }

  /// 톤 변경
  Future<void> changeTone({
    required String message,
    required ToneType targetTone,
  }) async {
    state = const AIRequestState(isLoading: true);

    final result = await _service.changeTone(
      message: message,
      targetTone: targetTone,
    );

    result.when(
      success: (response) {
        state = AIRequestState(suggestions: response);
      },
      failure: (error) {
        state = AIRequestState(error: error.displayMessage);
      },
    );
  }

  /// 채팅 요약
  Future<void> summarizeChat({
    required List<String> messages,
  }) async {
    state = const AIRequestState(isLoading: true);

    final result = await _service.summarizeChat(messages: messages);

    result.when(
      success: (response) {
        state = AIRequestState(result: response);
      },
      failure: (error) {
        state = AIRequestState(error: error.displayMessage);
      },
    );
  }

  /// 빠른 답장 제안
  Future<List<String>> suggestQuickReplies({
    required String lastMessage,
    required List<String> context,
  }) async {
    final result = await _service.suggestQuickReplies(
      lastMessage: lastMessage,
      context: context,
    );

    return result.when(
      success: (suggestions) => suggestions,
      failure: (_) => [],
    );
  }

  /// 상태 초기화
  void reset() {
    state = const AIRequestState();
  }
}

/// AI 요청 Provider
final aiRequestProvider =
    StateNotifierProvider<AIRequestNotifier, AIRequestState>((ref) {
  final service = ref.watch(aiServiceProvider);
  return AIRequestNotifier(service);
});
