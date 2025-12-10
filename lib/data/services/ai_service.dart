import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../core/exception/app_exception.dart';

/// AI 서비스 - Google Generative AI SDK (Gemini) 연동
class AIService {
  // Gemini API 키
  static const String _apiKey = 'AIzaSyDKlR4P2xC-C6hNehYTHDyw2HwGjzbT2ng';
  static const String _modelName = 'gemini-2.5-flash';

  late final GenerativeModel _model;

  AIService() {
    _model = GenerativeModel(
      model: _modelName,
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        maxOutputTokens: 1000,
      ),
    );
    _printAvailableModels();
  }

  /// 디버깅용: 사용 가능한 모델 목록 출력
  Future<void> _printAvailableModels() async {
    try {
      final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models?key=$_apiKey');
      final response = await http.get(url);
      print('>>> Checking Available Models...');
      print('>>> Status Code: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final models = data['models'] as List?;
        if (models != null) {
          print('>>> Available Models:');
          for (var m in models) {
            print('  - ${m['name']} (Methods: ${m['supportedGenerationMethods']})');
          }
        }
      } else {
        print('>>> Failed to list models: ${response.body}');
      }
    } catch (e) {
      print('>>> Error checking models: $e');
    }
  }

  /// 공통 요청 처리 메서드
  Future<Result<String>> _generateContent({
    required String prompt,
    double temperature = 0.7,
  }) async {
    try {
      // 온도 설정이 다를 경우 새로운 config로 모델 생성 (선택적)
      // 여기서는 간단히 기본 모델 사용하거나, 메서드별로 config 조정 가능하지만
      // SDK는 인스턴스별 설정을 따르므로, 필요하다면 chat session이나 runtime option 확인 필요.
      // 현재 SDK 버전에서는 generateContent에 직접 config를 넘길 수 없으므로(초기화 시 설정),
      // 온도가 중요한 경우 모델을 새로 만들거나 하나로 통일.
      // 편의상 0.7로 통일하되, 번역 등은 낮추는 게 좋으므로
      // 필요 시 인스턴스를 분리하는 것이 정석이나, 여기서는 일단 하나로 진행.

      // * 중요: API 키 유효성 체크는 런타임에 발생.

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      if (response.text != null) {
        return Success(response.text!.trim());
      } else {
        return Failure(AppException.unknown(message: 'AI 응답이 비어있습니다.'));
      }
    } on GenerativeAIException catch (e) {
      print('>>> Gemini SDK Error: $e');
      return Failure(AppException.validation(
          userMessage: 'AI 서비스 오류가 발생했습니다.', message: e.toString()));
    } catch (e) {
      print('>>> Unknown AI Error: $e');
      return Failure(AppException.unknown(message: e.toString()));
    }
  }

  /// 아이디어 제안
  Future<Result<List<String>>> suggestIdeas({
    required List<String> recentMessages,
    String? currentInput,
  }) async {
    final messagesContext = recentMessages.take(10).join('\n');
    final userPrompt = currentInput?.isNotEmpty == true
        ? '현재 입력 중인 메시지: $currentInput'
        : '대화 맥락을 기반으로 아이디어를 제안해주세요.';

    final prompt = '''
당신은 채팅 대화에서 유용한 아이디어와 답변을 제안하는 어시스턴트입니다.
최근 대화 내용을 바탕으로 사용자가 답변할 수 있는 3가지 아이디어나 답변 제안을 해주세요.
각 제안은 간결하고 대화에 맞는 것이어야 합니다.
번호를 붙여서 한 줄에 하나씩 작성해주세요. (예: 1. 제안된 답변)
설명이나 추가 텍스트는 포함하지 마세요.
한국어로 응답해주세요.

최근 대화:
$messagesContext

$userPrompt
''';

    final result = await _generateContent(prompt: prompt);

    return result.when(
      success: (text) {
        final lines = text
            .split('\n')
            .where((line) => line.trim().isNotEmpty)
            .map((line) => line.replaceAll(RegExp(r'^\d+[\.\)]\s*'), '').trim())
            .where((line) => line.isNotEmpty)
            .take(3)
            .toList();
        return Success(lines);
      },
      failure: (error) => Failure(error),
    );
  }

  /// 메시지 번역
  Future<Result<String>> translateMessage({
    required String message,
    required String targetLanguage,
  }) async {
    final prompt = '''
당신은 전문 번역가입니다. 
주어진 메시지를 $targetLanguage로 자연스럽게 번역해주세요.
번역된 텍스트만 반환하고, 설명이나 추가 텍스트는 포함하지 마세요.

메시지: $message
''';
    // 번역은 낮은 온도가 좋지만, 일단 기본 설정 사용
    return _generateContent(prompt: prompt);
  }

  /// 문법 검사
  Future<Result<String>> checkGrammar({
    required String message,
  }) async {
    final prompt = '''
당신은 한국어 문법 전문가입니다.
주어진 메시지의 문법, 맞춤법, 띄어쓰기를 검사하고 수정해주세요.
다음 형식으로 응답해주세요:

📝 원문: (원래 문장)
✅ 수정: (수정된 문장)
💡 설명: (수정 사항에 대한 간단한 설명)

문법이 완벽하다면 "문법이 완벽합니다! ✨"라고만 응답해주세요.

검사할 메시지: $message
''';
    return _generateContent(prompt: prompt);
  }

  /// 톤 변경
  Future<Result<List<String>>> changeTone({
    required String message,
    required ToneType targetTone,
  }) async {
    final toneDescription = switch (targetTone) {
      ToneType.formal => '격식체 (존댓말, 공식적인 표현)',
      ToneType.casual => '비격식체 (반말, 친근한 표현)',
      ToneType.friendly => '친근한 톤 (이모지 포함, 밝고 따뜻한 표현)',
      ToneType.professional => '비즈니스 톤 (전문적이고 정중한 표현)',
      ToneType.polite => '정중한 톤 (매우 공손하고 예의 바른 표현)',
    };

    final prompt = '''
당신은 메시지 톤 변환 전문가입니다.
주어진 메시지를 $toneDescription으로 변환하여 3가지 다른 버전을 제안해주세요.
각 제안은 원래 의미를 유지해야 합니다.
번호를 붙여서 한 줄에 하나씩 작성해주세요. (예: 1. 변환된 메시지)
설명이나 추가 텍스트는 포함하지 마세요.

변환할 메시지: $message
''';

    final result = await _generateContent(prompt: prompt);

    return result.when(
      success: (text) {
        final lines = text
            .split('\n')
            .where((line) => line.trim().isNotEmpty)
            .map((line) => line.replaceAll(RegExp(r'^\d+[\.\)]\s*'), '').trim())
            .where((line) => line.isNotEmpty)
            .take(3)
            .toList();
        return Success(lines);
      },
      failure: (error) => Failure(error),
    );
  }

  /// 채팅 요약
  Future<Result<String>> summarizeChat({
    required List<String> messages,
  }) async {
    final chatContent = messages.join('\n');

    final prompt = '''
당신은 대화 요약 전문가입니다.
주어진 채팅 내용을 간결하고 명확하게 요약해주세요.

다음 형식으로 응답해주세요:

📋 대화 요약
- 주요 주제: (대화의 주요 주제)
- 핵심 내용: (중요한 포인트들을 bullet point로)
- 결론/다음 단계: (결론이나 합의된 사항)

한국어로 응답해주세요.

대화 내용:
$chatContent
''';
    return _generateContent(prompt: prompt);
  }

  /// 빠른 답장 제안
  Future<Result<List<String>>> suggestQuickReplies({
    required String lastMessage,
    required List<String> context,
  }) async {
    final prompt = '''
당신은 채팅 답변 제안 어시스턴트입니다.
마지막 메시지에 대한 3개의 빠른 답장 옵션을 제안해주세요.
각 답장은 한 줄로 간결하게 작성하고, 번호를 붙여주세요.
다양한 톤과 내용으로 제안해주세요.

대화 맥락:
${context.take(5).join('\n')}

마지막 메시지: $lastMessage

이 메시지에 대한 3개의 답장 옵션을 제안해주세요.
''';

    final result = await _generateContent(prompt: prompt);

    return result.when(
      success: (text) {
        final lines = text
            .split('\n')
            .where((line) => line.trim().isNotEmpty)
            .map((line) => line.replaceAll(RegExp(r'^\d+[\.\)]\s*'), '').trim())
            .where((line) => line.isNotEmpty)
            .take(3)
            .toList();
        return Success(lines);
      },
      failure: (error) => Failure(error),
    );
  }
}

/// 톤 타입 열거형
enum ToneType {
  formal, // 격식체
  casual, // 비격식체
  friendly, // 친근한
  professional, // 비즈니스
  polite; // 정중한

  String get label {
    switch (this) {
      case ToneType.formal:
        return '격식체 (존댓말)';
      case ToneType.casual:
        return '비격식체 (반말)';
      case ToneType.friendly:
        return '친근한 톤 (이모지)';
      case ToneType.professional:
        return '비즈니스 톤';
      case ToneType.polite:
        return '정중한 톤';
    }
  }
}
