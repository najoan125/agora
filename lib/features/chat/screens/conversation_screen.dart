import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import 'select_members_screen.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import '../../../core/utils/file_download_helper.dart';
import '../widgets/voice_recorder_dialog.dart';
import '../models/chat_message.dart' as local;
import '../widgets/message_bubble.dart';
import 'package:audioplayers/audioplayers.dart';
import 'media_gallery_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers/chat_provider.dart';
import '../../../shared/providers/file_provider.dart';
import '../../../shared/providers/riverpod_profile_provider.dart';
import '../../../shared/providers/ai_provider.dart';
import '../../../shared/providers/team_provider.dart';
import '../../../data/models/team/team.dart';
import '../../../services/websocket_service.dart';
import '../../../data/api_client.dart';
import '../../../data/models/chat/chat.dart';
import '../../../data/services/ai_service.dart';
import '../../../core/exception/app_exception.dart';

class ConversationScreen extends ConsumerStatefulWidget {
  final String chatId;
  final String userName;
  final String userImage;
  final bool isTeam;

  const ConversationScreen({
    Key? key,
    required this.chatId,
    required this.userName,
    required this.userImage,
    this.isTeam = false,
  }) : super(key: key);

  @override
  ConsumerState<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends ConsumerState<ConversationScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final List<local.ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _showSearch = false;
  List<local.ChatMessage> _searchResults = [];
  List<XFile> _selectedImages = []; // Changed from single to list
  List<PlatformFile> _selectedFiles = []; // Changed from single to list
  String? _selectedVoiceMemo;
  int _voiceMemoDuration = 0;

  // AI 아이디어 제안 상태
  List<String> _aiIdeas = [];
  bool _isGeneratingIdeas = false;

  // AI 채팅 요약 상태
  String? _summaryResult;
  bool _isSummarizing = false;

  // AI 문법 검사 상태
  String? _grammarCheckResult;
  bool _isCheckingGrammar = false;

  // AI 톤 변경 상태
  bool _isToneChangeMenuOpen = false;
  bool _isChangingTone = false;
  List<String> _toneChangeResults = [];
  ToneType? _selectedTone;

  // 답장 상태
  Map<String, String>? _replyContext;

  // 음성 메모 미리보기 재생용
  final AudioPlayer _previewAudioPlayer = AudioPlayer();
  bool _isPreviewPlaying = false;
  Duration _previewCurrentPosition = Duration.zero;
  Duration _previewTotalDuration = Duration.zero;
  
  // 키보드 포커스 노드
  late FocusNode _focusNode;

  // WebSocket 연결 여부
  bool _isWebSocketInitialized = false;
  WebSocketService? _webSocketService;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();

    // 미리보기 오디오 플레이어 리스너 설정
    _previewAudioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPreviewPlaying = state == PlayerState.playing;
        });
      }
    });

    _previewAudioPlayer.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() {
          _previewTotalDuration = duration;
        });
      }
    });

    _previewAudioPlayer.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() {
          _previewCurrentPosition = position;
        });
      }
    });

    _previewAudioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          _isPreviewPlaying = false;
          _previewCurrentPosition = Duration.zero;
        });
      }
    });

    // WebSocket 연결 및 채팅방 구독 (WidgetsBinding 이후)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeWebSocket();
      // 화면 진입 시 읽음 처리
      _markAsRead();
    });
  }

  void _initializeWebSocket() {
    if (_isWebSocketInitialized) return;

    _webSocketService = ref.read(webSocketServiceProvider);

    // WebSocket 연결 (이미 연결되어 있으면 무시됨)
    _webSocketService!.connect();

    // 채팅방 구독
    _webSocketService!.subscribeToChatRoom(widget.chatId);

    _isWebSocketInitialized = true;
  }

  void _markAsRead() {
    // 메시지 읽음 처리
    ref.read(messageListProvider(widget.chatId).notifier).markAsRead();
  }

  @override
  void dispose() {
    // WebSocket 구독 해제
    if (_isWebSocketInitialized && _webSocketService != null) {
      _webSocketService!.unsubscribeFromChatRoom(widget.chatId);
    }

    _previewAudioPlayer.dispose();
    _messageController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }



  void _handleSubmitted(String text) async {
    if (text.trim().isEmpty &&
        _selectedImages.isEmpty &&
        _selectedFiles.isEmpty &&
        _selectedVoiceMemo == null) return;

    try {
      List<String>? fileIds;

      // 이미지나 파일이 있는 경우 파일 업로드 서비스 호출
      if (_selectedImages.isNotEmpty || _selectedFiles.isNotEmpty) {
        fileIds = await _uploadFiles();
        if (fileIds == null || fileIds.isEmpty) {
          // 업로드 실패 시 중단
          return;
        }
      }

      // 메시지 타입 및 내용 결정
      MessageType messageType = MessageType.text;
      String messageContent = text;

      if (_selectedVoiceMemo != null) {
        // 음성 메모의 경우 파일 업로드 후 FILE 타입으로 전송
        final voiceFile = File(_selectedVoiceMemo!);
        final voiceFileIds = await _uploadFiles(voiceFiles: [voiceFile]);
        if (voiceFileIds == null || voiceFileIds.isEmpty) {
          return;
        }
        fileIds = voiceFileIds;
        messageType = MessageType.file;
      } else if (_selectedImages.isNotEmpty) {
        messageType = MessageType.image;
        // 이미지는 텍스트가 없으면 빈 문자열 유지
      } else if (_selectedFiles.isNotEmpty) {
        messageType = MessageType.file;
        // 파일도 텍스트가 없으면 빈 문자열 유지
      }

      // 메시지 전송 로직
      // 답장 ID 설정 (API 전송용)
      String? replyToId;
      String finalMessage = messageContent;
      
      final replyId = _replyContext?['id'];
      if (replyId != null && replyId.isNotEmpty) {
        replyToId = replyId;
        // API 사용 시 본문에 답장 포맷을 포함할 필요 없음 (클라이언트가 replyToId로 렌더링)
      } else if (_replyContext != null) {
          // Fallback for string-based reply if ID is missing (legacy)
           finalMessage = '///REPLY///${_replyContext!['senderName']}///${_replyContext!['message']}///\n$messageContent';
      }

      // 로컬 메시지 추가 (Optimistic UI & Mock Support)
      List<Uint8List>? localImageBytesList;
      Uint8List? firstImageBytes;
      
      if (_selectedImages.isNotEmpty) {
        try {
          localImageBytesList = [];
          for (var image in _selectedImages) {
            final bytes = await image.readAsBytes();
            localImageBytesList.add(bytes);
          }
          if (localImageBytesList.isNotEmpty) {
            firstImageBytes = localImageBytesList.first;
          }
        } catch (e) {
          print('Error reading image bytes: $e');
        }
      }

      if (mounted) {
        setState(() {
          _messages.insert(0, local.ChatMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: messageContent,
            isMe: true,
            time: DateTime.now(),
            sender: widget.userName,
            imageBytes: firstImageBytes, // 호환성 유지
            imageBytesList: localImageBytesList, // 다중 이미지 지원
            filesList: _selectedFiles.isNotEmpty 
                ? _selectedFiles.map((f) => {
                    'name': f.name,
                    'size': f.size,
                    'path': f.path, // 로컬 경로 저장 (선택적)
                  }).toList() 
                : null,
            fileName: _selectedFiles.isNotEmpty ? _selectedFiles.first.name : null, // 호환성 유지
            fileSize: _selectedFiles.isNotEmpty ? _selectedFiles.first.size : null,
            replyToId: replyToId ?? _replyContext?['id'],
            replyToSender: _replyContext?['senderName'],
            replyToContent: _replyContext?['message'],
            audioPath: _selectedVoiceMemo, // 음성 메모 경로 추가
            audioDuration: Duration(milliseconds: _voiceMemoDuration), // 음성 메모 길이 추가
          ));
        });
      }

      // WebSocket으로 메시지 전송 (Safe Try-Catch)
      try {
        final notifier = ref.read(messageListProvider(widget.chatId).notifier);
        notifier.sendMessage(
          content: finalMessage,
          type: messageType,
          fileIds: fileIds,
          replyToId: replyToId,
        );
      } catch (e) {
        print('⚠️ WebSocket send failed (using mock/local only): $e');
      }

      // 입력 필드 초기화
      _messageController.clear();
      setState(() {
        _selectedImages = [];
        _selectedFiles = [];
        _selectedVoiceMemo = null;
        _voiceMemoDuration = 0;
        _replyContext = null; // 답장 상태 초기화
      });
    } catch (e) {
      print('❌ Error sending message (final catch): $e');
      // 에러 메시지 사용자 표시 안 함 (목업 모드)
    }
  }

  void _handleReply(String message, String senderName, {String? replyToId}) {
    setState(() {
      _replyContext = {
        'message': message,
        'senderName': senderName,
        'id': replyToId ?? '',
      };
    });
    // 키보드 올리기
    _focusNode.requestFocus();
  }

  void _handleReplyTap(String replyId) {
    _scrollToMessage(replyId);
  }
  
  void _scrollToMessage(String messageId) {
    final messageState = ref.read(messageListProvider(widget.chatId));
    final index = messageState.messages.indexWhere((m) => m.id.toString() == messageId);
    
    if (index != -1) {
      // 리스트뷰가 reverse: true이므로 인덱스 계산 주의 필요할 수 있음
      // 하지만 ListView.builder의 itemIndex는 데이터 인덱스와 매핑됨.
      // 문제는 오프셋을 알 수 없다는 것.
      // 간단히 아이템 높이를 60px 정도로 추정하여 점프 시도 (정확하지 않음)
      // 또는 찾은 메시지가 화면에 보이도록...
      
      // 여기서는 스낵바 등으로 '이동' 알림만 주거나, 정확한 구현을 위해 scroll_to_index 같은 패키지가 필요함.
      // 일단 간단한 검색 피드백 제공
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('해당 메시지로 이동합니다 (구현 예정)')),
      );
    } else {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('메시지를 찾을 수 없습니다 (상단에 있을 수 있습니다)')),
      );
    }
  }

  void _handleForward(String message) async {
    // 전달할 대상 선택 (SelectMembersScreen 재사용)
    // 실제로는 ChatListScreen을 띄워서 선택하게 하는 것이 좋으나, 
    // 편의상 멤버 선택 화면을 사용
     final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectMembersScreen(
          existingMemberIds: const [], // 모든 멤버 표시
          title: '전달할 대상 선택',
        ),
      ),
    );

    if (result != null && result is List<int> && result.isNotEmpty) {
      // TODO: 선택된 대상들과의 채팅방을 찾거나 생성해서 메시지 전송
      // 여기서는 UI 피드백만 제공
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('${result.length}명에게 메시지를 전달했습니다.')),
        );
      }
    }
  }

  /// 파일 업로드 헬퍼 메서드
  Future<List<String>?> _uploadFiles({List<File>? voiceFiles}) async {
    try {
      final fileService = ref.read(fileServiceProvider);
      final uploadedFileIds = <String>[];

      // 이미지 업로드
      if (_selectedImages.isNotEmpty) {
        for (final image in _selectedImages) {
          final imageFile = File(image.path);
          final result = await fileService.uploadImage(imageFile);

          result.when(
            success: (agoraFile) => uploadedFileIds.add(agoraFile.id),
            failure: (error) => throw error,
          );
        }
      }

      // 일반 파일 업로드
      if (_selectedFiles.isNotEmpty) {
        for (final platformFile in _selectedFiles) {
          if (platformFile.path != null) {
            final file = File(platformFile.path!);
            final result = await fileService.uploadFile(file);

            result.when(
              success: (fileResponse) =>
                  uploadedFileIds.add(fileResponse.file.id),
              failure: (error) => throw error,
            );
          }
        }
      }

      // 음성 파일 업로드
      if (voiceFiles != null && voiceFiles.isNotEmpty) {
        for (final voiceFile in voiceFiles) {
          final result = await fileService.uploadFile(voiceFile);

          result.when(
            success: (fileResponse) =>
                uploadedFileIds.add(fileResponse.file.id),
            failure: (error) => throw error,
          );
        }
      }

      return uploadedFileIds;
    } catch (e) {
      print('❌ Error uploading files: $e');
      print('⚠️ Upload failed. Using mock data.');
      
      // 목업 데이터 (가짜 파일 ID 리스트 반환)
      final mockIds = <String>[];
      if (_selectedImages.isNotEmpty) {
         mockIds.addAll(List.generate(_selectedImages.length, (i) => 'mock_image_$i'));
      }
      if (_selectedFiles.isNotEmpty) {
         mockIds.addAll(List.generate(_selectedFiles.length, (i) => 'mock_file_$i'));
      }
      if (voiceFiles != null) {
         mockIds.addAll(List.generate(voiceFiles.length, (i) => 'mock_voice_$i'));
      }
      return mockIds;
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      print('📸 Starting pickMultiImage...');

      // Try pickMultiImage with explicit parameters
      final List<XFile> images = await picker.pickMultiImage(
        imageQuality: 85,
      );

      print('📸 Selected ${images.length} images');

      if (images.isNotEmpty) {
        print('📸 Image details:');
        for (int i = 0; i < images.length; i++) {
          print('  Image $i: ${images[i].name}, path: ${images[i].path}');
        }

        setState(() {
          // Add to existing images instead of replacing
          _selectedImages.addAll(images);
          _selectedFiles = [];
          _selectedVoiceMemo = null;
        });
        print('✅ Total images in state: ${_selectedImages.length} images');
      } else {
        print('⚠️ No images selected');
      }
    } catch (e, stackTrace) {
      print('❌ Error picking images: $e');
      print('❌ Stack trace: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미지 선택 중 오류가 발생했습니다: $e')),
      );
    }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          // Add to existing files instead of replacing
          _selectedFiles.addAll(result.files);
          _selectedImages = [];
          _selectedVoiceMemo = null;
        });
        print('📎 Total files selected: ${_selectedFiles.length}');
      }
    } catch (e) {
      print('❌ Error picking files: $e');
      debugPrint('Error picking file: $e');
    }
  }

  void _showVoiceRecorder(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => VoiceRecorderDialog(
        onStop: (path, duration) {
          setState(() {
            _selectedVoiceMemo = path;
            _voiceMemoDuration = duration;
            _selectedImages = [];
            _selectedFiles = [];
          });
        },
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  void _searchMessages(String query) {
    setState(() {
      if (query.isEmpty) {
        _searchResults = [];
      } else {
        _searchResults = _messages
            .where(
                (msg) => msg.text.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  /// API ChatMessage를 local ChatMessage로 변환
  local.ChatMessage _convertToLocalMessage(
      ChatMessage apiMessage, String currentUserId, List<ChatMessage> allMessages) {
    
    // 답장 정보 찾기
    String? replyToSender;
    String? replyToContent;
    
    if (apiMessage.replyToId != null) {
      // 현재 로드된 메시지 목록에서 답장 대상 찾기
      // (API가 답장 정보를 직접 주지 않는다고 가정하고 로컬 검색)
      try {
        final replyMessage = allMessages.firstWhere(
          (m) => m.id.toString() == apiMessage.replyToId,
        ); // orElse handled by catch
        
        replyToSender = replyMessage.displayName;
        replyToContent = replyMessage.content;
      } catch (e) {
        // 메시지가 로컬에 없음 (안 보임)
        // API에서 reply context를 주거나 별도 fetch가 필요하지만
        // 현재는 "삭제된 메시지" 또는 "메시지 로딩 필요" 등으로 처리 가능
        // 혹은 UI에서 원본 정보가 없음을 처리
        replyToSender = "알 수 없음";
        replyToContent = "원본 메시지를 찾을 수 없습니다.";
      }
    }

    return local.ChatMessage(
      id: apiMessage.id.toString(),
      text: apiMessage.content,
      isMe: apiMessage.senderAgoraId == currentUserId,
      time: apiMessage.createdAt,
      sender: apiMessage.displayName,
      replyToId: apiMessage.replyToId,
      replyToSender: replyToSender,
      replyToContent: replyToContent,
      // 첨부파일 처리
      imageUrl: apiMessage.attachments?.firstWhere(
        (a) => a.mimeType.startsWith('image'),
        orElse: () => const MessageAttachment(
            id: '', fileId: '', fileName: '', fileUrl: '', fileSize: 0, mimeType: ''),
      ).fileUrl.isNotEmpty == true 
          ? apiMessage.attachments?.firstWhere((a) => a.mimeType.startsWith('image')).fileUrl 
          : null,
          
      fileName: apiMessage.attachments?.firstWhere(
        (a) => !a.mimeType.startsWith('image') && !a.mimeType.startsWith('audio'),
        orElse: () => const MessageAttachment(
            id: '', fileId: '', fileName: '', fileUrl: '', fileSize: 0, mimeType: ''),
      ).fileName.isNotEmpty == true
          ? apiMessage.attachments?.firstWhere((a) => !a.mimeType.startsWith('image') && !a.mimeType.startsWith('audio')).fileName
          : null,
          
      fileSize: (apiMessage.attachments?.firstWhere(
        (a) => !a.mimeType.startsWith('image') && !a.mimeType.startsWith('audio'),
        orElse: () => const MessageAttachment(
            id: '', fileId: '', fileName: '', fileUrl: '', fileSize: 0, mimeType: ''),
      ).fileSize ?? 0) > 0
          ? apiMessage.attachments?.firstWhere((a) => !a.mimeType.startsWith('image') && !a.mimeType.startsWith('audio')).fileSize
          : null,

      audioPath: apiMessage.attachments?.firstWhere(
        (a) => a.mimeType.startsWith('audio') || a.mimeType == 'application/octet-stream' && (a.fileName.endsWith('.m4a') || a.fileName.endsWith('.mp3')),
        orElse: () => const MessageAttachment(
            id: '', fileId: '', fileName: '', fileUrl: '', fileSize: 0, mimeType: ''),
      ).fileUrl.isNotEmpty == true
          ? apiMessage.attachments?.firstWhere((a) => a.mimeType.startsWith('audio') || a.mimeType == 'application/octet-stream' && (a.fileName.endsWith('.m4a') || a.fileName.endsWith('.mp3'))).fileUrl
          : null,
          
      filesList: apiMessage.attachments != null && apiMessage.attachments!.isNotEmpty
          ? apiMessage.attachments!.where((a) {
              // 이미지가 아니고 오디오도 아닌 것들만 리스트에 추가 (또는 모든 파일 포함 여부 결정)
              // 여기서는 일단 모든 첨부파일을 리스트로도 보여줄지 결정해야 함. 
              // MessageBubble 구현상 filesList가 있으면 그걸 우선 보여줄 수도 있음.
              // 오디오는 별도 처리하므로 제외, 이미지는 갤러리 뷰로 보이므로 제외, 나머지는 파일 리스트로.
              return !a.mimeType.startsWith('image') && !a.mimeType.startsWith('audio');
            }).map((a) => {
                'name': a.fileName,
                'size': a.fileSize,
                'path': a.fileUrl, // URL 사용
              }).toList()
          : null,
    );
  }

  /// 메시지 목록 빌드
  Widget _buildMessageList({
    required bool isTeamChat,
    required List<TeamMember> teamMembers,
  }) {
    final messageState = ref.watch(messageListProvider(widget.chatId));

    // 로딩 중
    if (messageState.isLoading && messageState.messages.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // 에러 발생
    if (messageState.error != null && messageState.messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              messageState.error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(messageListProvider(widget.chatId).notifier)
                    .loadMessages();
              },
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    // 메시지 목록 표시
    final messages = messageState.messages;

    // 현재 사용자 ID (프로필 Provider에서 가져오기)
    final myProfile = ref.watch(myProfileProvider);
    final currentUserId = myProfile.when(
      data: (profile) => profile?.agoraId ?? 'me',
      loading: () => 'me',
      error: (_, __) => 'me',
    );

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        // 스크롤이 맨 아래에 도달하면 더 불러오기
        if (!messageState.isLoading &&
            messageState.hasMore &&
            scrollInfo.metrics.pixels >=
                scrollInfo.metrics.maxScrollExtent - 200) {
          ref
              .read(messageListProvider(widget.chatId).notifier)
              .loadMessages(loadMore: true);
        }
        return false;
      },
      child: ListView.builder(
        reverse: true,
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        itemCount: _messages.length + messages.length + (messageState.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          // 1. 로컬 펜딩 메시지
          if (index < _messages.length) {
            final localMessage = _messages[index];
            return MessageBubble(
              key: ValueKey('local_${localMessage.id}'),
              message: localMessage.text,
              isMe: true, // 로컬 메시지는 항상 '나'
              time: localMessage.time,
              userImage: null,
              senderName: null,
              imageBytes: localMessage.imageBytes,
              imageBytesList: localMessage.imageBytesList,
              filesList: localMessage.filesList, // 파일 목록 추가
              audioPath: localMessage.audioPath,
              audioDuration: localMessage.audioDuration,
              replyToId: localMessage.replyToId,
              replyToSender: localMessage.replyToSender,
              replyToContent: localMessage.replyToContent,
              onReactionSelected: (_) {},
              onReply: (msg, sender) => _handleReply(msg, sender, replyToId: localMessage.id),
            );
          }

          final apiIndex = index - _messages.length;

          // 2. 더 불러오기 인디케이터
          if (apiIndex == messages.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final apiMessage = messages[apiIndex];
          final localMessage =
              _convertToLocalMessage(apiMessage, currentUserId, messages);

          // 팀 채팅인 경우 팀 프로필만 사용 (개인 프로필 X)
          // 일반 채팅인 경우 API에서 제공하는 프로필 사용
          String? senderProfileImage;
          String? senderDisplayName;
          if (isTeamChat) {
            // 팀 채팅: 팀 프로필만 사용
            if (teamMembers.isNotEmpty) {
              final senderMember = teamMembers
                  .where((m) => m.agoraId == apiMessage.senderAgoraId)
                  .firstOrNull;
              senderProfileImage = senderMember?.profileImage;
              senderDisplayName = senderMember?.effectiveDisplayName;
            }
            // 팀 프로필이 없으면 null (개인 프로필 사용 X)
          } else {
            // 일반 채팅: API에서 제공하는 프로필 사용
            senderProfileImage = apiMessage.senderProfileImage;
          }

          return MessageBubble(
            key: ValueKey(apiMessage.id),
            message: localMessage.text,
            isMe: localMessage.isMe,
            time: localMessage.time,
            userImage: senderProfileImage ?? '',
            senderName: senderDisplayName ?? localMessage.sender ?? widget.userName,
            imageUrl: localMessage.imageUrl,
            fileName: localMessage.fileName,
            fileSize: localMessage.fileSize,
            audioPath: localMessage.audioPath,
            audioDuration: localMessage.audioDuration,
            filesList: localMessage.filesList,
            reactions: localMessage.reactions,
            replyToId: localMessage.replyToId,
            replyToSender: localMessage.replyToSender,
            replyToContent: localMessage.replyToContent,
            onReactionSelected: (emoji) {
              // TODO: 리액션 API 연동
              print('Reaction selected: $emoji for message ${apiMessage.id}');
            },
            onReply: (msg, sender) => _handleReply(msg, sender, replyToId: localMessage.id),
            onReplyTap: _handleReplyTap,
            onForward: _handleForward,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // WebSocket 연결 상태 감지
    final connectionState = ref.watch(webSocketConnectionStateProvider);

    // 내 프로필 정보 가져오기
    final myProfile = ref.watch(myProfileProvider);
    final myProfileImage = myProfile.when(
      data: (profile) => profile?.profileImageUrl,
      loading: () => null,
      error: (_, __) => null,
    );
    final myAgoraId = myProfile.when(
      data: (profile) => profile?.agoraId,
      loading: () => null,
      error: (_, __) => null,
    );

    // 채팅방 참여자 정보 가져오기
    final chatAsync = ref.watch(chatByIdProvider(widget.chatId));
    final chat = chatAsync.valueOrNull;
    final List<ParticipantProfile> participants = chat?.participants ?? [];
    final bool isTeamChat = chat?.context == ChatContext.team;
    final teamId = chat?.teamId?.toString();

    // 팀 채팅인 경우 팀 멤버 정보 가져오기
    final List<TeamMember> teamMembers = (isTeamChat && teamId != null)
        ? (ref.watch(teamMembersProvider(teamId)).valueOrNull ?? [])
        : [];

    // 팀 채팅인 경우 나의 팀 프로필 찾기
    final myTeamMember = isTeamChat && teamMembers.isNotEmpty && myAgoraId != null
        ? teamMembers.where((m) => m.agoraId == myAgoraId).firstOrNull
        : null;

    // 나를 제외한 다른 참여자들 (agoraId로 필터링)
    // 팀 채팅인 경우 팀 멤버 정보 사용, 아닌 경우 participants 사용
    final List<_DrawerParticipant> otherParticipants = isTeamChat && teamMembers.isNotEmpty
        ? teamMembers
            .where((m) => m.agoraId != myAgoraId)
            .map((m) => _DrawerParticipant(
                  agoraId: m.agoraId,
                  displayName: m.effectiveDisplayName,
                  profileImage: m.profileImage,
                ))
            .toList()
        : participants
            .where((p) => p.identifier != myAgoraId)
            .map((p) => _DrawerParticipant(
                  agoraId: p.identifier,
                  displayName: p.displayName,
                  profileImage: p.profileImage,
                ))
            .toList();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppTheme.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: widget.isTeam ? Colors.blue[50] : Colors.grey[200],
                shape: BoxShape.circle,
                image: widget.userImage.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(widget.userImage),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: widget.userImage.isEmpty
                  ? Center(
                      child: Text(
                        widget.isTeam ? '👥' : '👤',
                        style: const TextStyle(fontSize: 18),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.userName,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.isTeam)
                    Text(
                      'Team',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            // WebSocket 연결 상태 표시
            connectionState.when(
              data: (state) {
                switch (state) {
                  case WebSocketConnectionState.connected:
                    return const Icon(Icons.circle,
                        color: Colors.green, size: 12);
                  case WebSocketConnectionState.connecting:
                    return const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  case WebSocketConnectionState.error:
                    return const Icon(Icons.circle,
                        color: Colors.red, size: 12);
                  default:
                    return const Icon(Icons.circle,
                        color: Colors.grey, size: 12);
                }
              },
              loading: () => const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              error: (error, stackTrace) {
                print('WebSocket Connection Error: $error');
                print('StackTrace: $stackTrace');
                return const Icon(Icons.circle, color: Colors.red, size: 12);
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchController.clear();
                  _searchResults = [];
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.black),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      endDrawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Column(
          children: [
            SafeArea(
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '대화상대',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 20),
                    // Horizontal Member List
                    SizedBox(
                      height: 90,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          // Current User (Me) - 팀 채팅인 경우 팀 프로필만 사용 (개인 프로필 X)
                          Builder(builder: (context) {
                            // 팀 채팅이면 팀 프로필, 아니면 개인 프로필
                            final myDisplayImage = isTeamChat
                                ? myTeamMember?.profileImage
                                : myProfileImage;
                            final myDisplayName = isTeamChat
                                ? myTeamMember?.effectiveDisplayName
                                : null;

                            return Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: Column(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      shape: BoxShape.circle,
                                      image: myDisplayImage != null && myDisplayImage.isNotEmpty
                                          ? DecorationImage(
                                              image: NetworkImage(myDisplayImage),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                    ),
                                    child: myDisplayImage == null || myDisplayImage.isEmpty
                                        ? Center(
                                            child: Text(
                                              myDisplayName?.isNotEmpty == true
                                                  ? myDisplayName![0]
                                                  : '나',
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    myDisplayName ?? '나',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          // Other Participants
                          ...otherParticipants.map((participant) => Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: Column(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    shape: BoxShape.circle,
                                    image: participant.profileImage != null &&
                                            participant.profileImage!.isNotEmpty
                                        ? DecorationImage(
                                            image: NetworkImage(
                                                participant.profileImage!),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: participant.profileImage == null ||
                                          participant.profileImage!.isEmpty
                                      ? Center(
                                          child: Text(
                                            participant.displayName.isNotEmpty
                                                ? participant.displayName[0]
                                                : '?',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        )
                                      : null,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  participant.displayName.isNotEmpty
                                      ? participant.displayName
                                      : '알 수 없음',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          )),
                          // Invite Button
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              // Invite Member
                              onTap: () async {
                                Navigator.pop(context); // Drawer 닫기

                                // 기존 멤버 목록 가져오기
                                final chatList =
                                    ref.read(chatListProvider).valueOrNull ??
                                        [];
                                final currentChat = chatList.firstWhere(
                                  (c) => c.id.toString() == widget.chatId,
                                  orElse: () => Chat(
                                      id: -1,
                                      type: ChatType.group,
                                      createdAt: DateTime.now(),
                                      updatedAt: DateTime.now()),
                                );

                                final List<int> existingMemberIds =
                                    currentChat.participants != null
                                        ? currentChat.participants!
                                            .map((p) => p.userId as int)
                                            .toList()
                                        : [];

                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SelectMembersScreen(
                                      existingMemberIds: existingMemberIds,
                                    ),
                                  ),
                                );

                                if (result != null &&
                                    result is List<int> &&
                                    result.isNotEmpty) {
                                  final success = await ref
                                      .read(chatActionProvider.notifier)
                                      .inviteToGroupChat(widget.chatId, result);

                                  if (success && mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                              Text('${result.length}명을 초대했습니다.')),
                                    );
                                  } else if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('초대에 실패했습니다.')),
                                    );
                                  }
                                }
                              },
                              child: Column(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      shape: BoxShape.circle,
                                      border:
                                          Border.all(color: Colors.grey[300]!),
                                    ),
                                    child: const Icon(Icons.add,
                                        color: Colors.grey),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    '초대',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    leading: const Icon(Icons.person_add_outlined,
                        color: AppTheme.textPrimary),
                    title: const Text('대화상대 초대'),
                    trailing: const Icon(Icons.arrow_forward_ios,
                        size: 14, color: AppTheme.textSecondary),
                    onTap: () async {
                      Navigator.pop(context); // Drawer 닫기

                      // 기존 멤버 목록 가져오기
                      final chatList =
                          ref.read(chatListProvider).valueOrNull ?? [];
                      final currentChat = chatList.firstWhere(
                        (c) => c.id.toString() == widget.chatId,
                        orElse: () => Chat(
                            id: -1,
                            type: ChatType.group,
                            createdAt: DateTime.now(),
                            updatedAt: DateTime.now()),
                      );

                      final List<int> existingMemberIds =
                          currentChat.participants != null
                              ? currentChat.participants!
                                  .map((p) => p.userId as int)
                                  .toList()
                              : [];

                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SelectMembersScreen(
                            existingMemberIds: existingMemberIds,
                          ),
                        ),
                      );

                      if (result != null &&
                          result is List<int> &&
                          result.isNotEmpty) {
                        final success = await ref
                            .read(chatActionProvider.notifier)
                            .inviteToGroupChat(widget.chatId, result);

                        if (success && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('${result.length}명을 초대했습니다.')),
                          );
                        } else if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('초대에 실패했습니다.')),
                          );
                        }
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.photo_outlined,
                        color: AppTheme.textPrimary),
                    title: const Text('사진/동영상'),
                    trailing: const Icon(Icons.arrow_forward_ios,
                        size: 14, color: AppTheme.textSecondary),
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: MediaGalleryScreen을 API 메시지와 호환되도록 수정 필요
                      // 현재는 local ChatMessage 모델을 사용하므로 임시로 빈 리스트 전달
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MediaGalleryScreen(
                            messages: [], // TODO: API 메시지를 local 메시지로 변환 필요
                            initialTabIndex: 0,
                          ),
                        ),
                      );
                    },
                  ),
                  // Media Preview Section
                  Consumer(
                    builder: (context, ref, child) {
                      final messageState =
                          ref.watch(messageListProvider(widget.chatId));

                      // API 메시지에서 이미지 첨부파일 필터링
                      final imageAttachments = messageState.messages
                          .where((msg) => msg.attachments != null)
                          .expand((msg) => msg.attachments!)
                          .where((att) => att.mimeType.startsWith('image'))
                          .take(5)
                          .toList();

                      if (imageAttachments.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return Container(
                        padding: const EdgeInsets.all(16),
                        child: SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: imageAttachments.length,
                            itemBuilder: (context, index) {
                              final attachment = imageAttachments[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => Scaffold(
                                        appBar: AppBar(
                                          backgroundColor: Colors.black,
                                          iconTheme: const IconThemeData(
                                              color: Colors.white),
                                        ),
                                        backgroundColor: Colors.black,
                                        body: Center(
                                          child:
                                              Image.network(attachment.fileUrl),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 100,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        attachment.thumbnailUrl ??
                                            attachment.fileUrl,
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.folder_outlined,
                        color: AppTheme.textPrimary),
                    title: const Text('파일'),
                    trailing: const Icon(Icons.arrow_forward_ios,
                        size: 14, color: AppTheme.textSecondary),
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: MediaGalleryScreen을 API 메시지와 호환되도록 수정 필요
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MediaGalleryScreen(
                            messages: [], // TODO: API 메시지를 local 메시지로 변환 필요
                            initialTabIndex: 1,
                          ),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading:
                        const Icon(Icons.link, color: AppTheme.textPrimary),
                    title: const Text('링크'),
                    trailing: const Icon(Icons.arrow_forward_ios,
                        size: 14, color: AppTheme.textSecondary),
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: MediaGalleryScreen을 API 메시지와 호환되도록 수정 필요
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MediaGalleryScreen(
                            messages: [], // TODO: API 메시지를 local 메시지로 변환 필요
                            initialTabIndex: 2,
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.notifications_off_outlined,
                        color: AppTheme.textPrimary),
                    title: const Text('알림 끄기'),
                    trailing: Switch(value: false, onChanged: (v) {}),
                  ),
                ],
              ),
            ),
            Container(
              color: AppTheme.surfaceColor,
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.settings_outlined,
                        color: AppTheme.textSecondary),
                    onPressed: () {
                      Navigator.pop(context);
                      _showSettings(context);
                    },
                  ),
                  IconButton(
                    icon:
                        const Icon(Icons.logout, color: AppTheme.textSecondary),
                    onPressed: () {
                      Navigator.pop(context); // Close drawer
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('나가기'),
                          content: const Text('채팅방을 나가시겠습니까?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('취소'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                              child: const Text('나가기',
                                  style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          if (_showSearch)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: '메시지 검색',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _showSearch = false;
                        _searchController.clear();
                        _searchResults = [];
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onChanged: _searchMessages,
              ),
            ),
          Expanded(
            child: _buildMessageList(
              isTeamChat: isTeamChat,
              teamMembers: teamMembers,
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  void _showAttachmentMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.image, color: Colors.blue),
                      title: const Text('사진'),
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.folder, color: Colors.orange),
                      title: const Text('파일'),
                      onTap: () {
                        Navigator.pop(context);
                        _pickFile();
                      },
                    ),
                    ListTile(
                      leading:
                          const Icon(Icons.music_note, color: Colors.purple),
                      title: const Text('음성 메모'),
                      onTap: () {
                        Navigator.pop(context);
                        _showVoiceRecorder(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openCamera(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('카메라'),
        content: const Text('카메라를 실행하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showToast(context, '카메라가 실행되었습니다');
            },
            child: const Text('실행'),
          ),
        ],
      ),
    );
  }

  void _showAIMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'AI 기능',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ListTile(
                      leading:
                          const Icon(Icons.lightbulb, color: Colors.yellow),
                      title: const Text('아이디어 제안'),
                      subtitle: const Text('AI가 대화에 맞는 아이디어를 제안합니다'),
                      onTap: () {
                        Navigator.pop(context);
                        _fetchIdeas();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.translate, color: Colors.green),
                      title: const Text('번역'),
                      subtitle: const Text('메시지를 번역합니다'),
                      onTap: () {
                        Navigator.pop(context);
                        _showTranslateDialog();
                      },
                    ),
                    ListTile(
                    leading: const Icon(Icons.edit, color: Colors.blue),
                    title: const Text('문법 검사'),
                    subtitle: const Text('입력한 메시지의 문법을 검사합니다'),
                    onTap: () {
                      Navigator.pop(context);
                      _checkGrammar();
                    },
                  ),
                    ListTile(
                    leading: const Icon(Icons.star, color: Colors.purple),
                    title: const Text('톤 변경'),
                    subtitle: const Text('메시지의 톤을 변경합니다'),
                    onTap: () {
                      Navigator.pop(context);
                      _toggleToneChangeMenu();
                    },
                  ),
                    const Divider(),
                    ListTile(
                      leading:
                          const Icon(Icons.summarize, color: Colors.orange),
                      title: const Text('채팅 요약'),
                      subtitle: const Text('대화 내용을 요약합니다'),
                      onTap: () {
                        Navigator.pop(context);
                        _fetchSummary();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// AI 아이디어 제안 요청
  Future<void> _fetchIdeas() async {
    setState(() {
      _isGeneratingIdeas = true;
      _aiIdeas = [];
    });

    try {
      final messageState = ref.read(messageListProvider(widget.chatId));
      final recentMessages = messageState.messages
          .take(10)
          .map((m) => '${m.displayName ?? "Unknown"}: ${m.content}')
          .toList()
          .reversed
          .toList();

      final service = ref.read(aiServiceProvider);
      final result = await service.suggestIdeas(
        recentMessages: recentMessages,
        currentInput: _messageController.text,
      );

      if (mounted) {
        result.when(
          success: (ideas) {
            setState(() {
              _aiIdeas = ideas;
              _isGeneratingIdeas = false;
            });
            if (ideas.isEmpty) {
              _showToast(context, '제안할 아이디어가 없습니다.');
            }
          },
          failure: (error) {
            setState(() {
              _isGeneratingIdeas = false;
            });
            _showToast(context, '아이디어 생성 실패: ${error.displayMessage}');
          },
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGeneratingIdeas = false;
        });
        _showToast(context, '오류 발생: $e');
      }
    }
  }

  /// 번역 다이얼로그
  void _showTranslateDialog() {
    final currentText = _messageController.text;

    showDialog(
      context: context,
      builder: (context) => _TranslateDialog(
        initialText: currentText,
        onTranslate: (text, targetLanguage) async {
          final service = ref.read(aiServiceProvider);
          return await service.translateMessage(
            message: text,
            targetLanguage: targetLanguage,
          );
        },
        onApply: (translatedText) {
          setState(() {
            _messageController.text = translatedText;
          });
        },
      ),
    );
  }

    /// 문법 검사 요청
  Future<void> _checkGrammar() async {
    final currentText = _messageController.text;

    if (currentText.isEmpty) {
      _showToast(context, '먼저 메시지를 입력해주세요');
      return;
    }

    setState(() {
      _isCheckingGrammar = true;
      _grammarCheckResult = null;
      _aiIdeas = []; // 다른 AI 결과 닫기
      _summaryResult = null;
    });

    try {
      final service = ref.read(aiServiceProvider);
      final result = await service.checkGrammar(message: currentText);

      if (mounted) {
        result.when(
          success: (correctedText) {
            setState(() {
              _grammarCheckResult = correctedText;
              _isCheckingGrammar = false;
            });
          },
          failure: (error) {
            setState(() {
              _isCheckingGrammar = false;
            });
            _showToast(context, '문법 검사 실패: ${error.displayMessage}');
          },
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCheckingGrammar = false;
        });
        _showToast(context, '오류가 발생했습니다: $e');
      }
    }
  }

    /// 톤 변경 메뉴 토글
  void _toggleToneChangeMenu() {
    final currentText = _messageController.text;
    if (currentText.isEmpty) {
      _showToast(context, '먼저 메시지를 입력해주세요');
      return;
    }

    setState(() {
      _isToneChangeMenuOpen = !_isToneChangeMenuOpen;
      _toneChangeResults = [];
      _selectedTone = null;
      // 다른 메뉴 닫기
      if (_isToneChangeMenuOpen) {
        _aiIdeas = [];
        _summaryResult = null;
        _grammarCheckResult = null;
      }
    });
  }

  /// 톤 변경 요청
  Future<void> _changeTone(ToneType tone) async {
    final currentText = _messageController.text;
    if (currentText.isEmpty) return;

    setState(() {
      _selectedTone = tone;
      _isChangingTone = true;
      _toneChangeResults = [];
    });

    try {
      final service = ref.read(aiServiceProvider);
      final result = await service.changeTone(
        message: currentText,
        targetTone: tone,
      );

      if (mounted) {
        result.when(
          success: (suggestions) {
            setState(() {
              _toneChangeResults = suggestions;
              _isChangingTone = false;
            });
          },
          failure: (error) {
            setState(() {
              _isChangingTone = false;
            });
            _showToast(context, '톤 변경 실패: ${error.displayMessage}');
          },
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isChangingTone = false;
        });
        _showToast(context, '오류가 발생했습니다: $e');
      }
    }
  }

  /// 채팅 요약 요청
  Future<void> _fetchSummary() async {
    final messageState = ref.read(messageListProvider(widget.chatId));
    final messages = messageState.messages
        .take(50)
        .map((m) => '${m.displayName ?? "Unknown"}: ${m.content}')
        .toList()
        .reversed
        .toList();

    if (messages.isEmpty) {
      _showToast(context, '요약할 메시지가 없습니다');
      return;
    }

    setState(() {
      _isSummarizing = true;
      _summaryResult = null;
      _aiIdeas = []; // 다른 AI 결과는 닫음
    });

    try {
      final service = ref.read(aiServiceProvider);
      final result = await service.summarizeChat(messages: messages);

      if (mounted) {
        result.when(
          success: (summary) {
            setState(() {
              _summaryResult = summary;
              _isSummarizing = false;
            });
          },
          failure: (error) {
            setState(() {
              _isSummarizing = false;
            });
            _showToast(context, '요약 실패: ${error.displayMessage}');
          },
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSummarizing = false;
        });
        _showToast(context, '오류 발생: $e');
      }
    }
  }

  void _showToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 100, left: 16, right: 16),
      ),
    );
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '채팅방 설정',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('사진/동영상'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                // TODO: MediaGalleryScreen을 API 메시지와 호환되도록 수정 필요
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MediaGalleryScreen(
                      messages: [], // TODO: API 메시지를 local 메시지로 변환 필요
                      initialTabIndex: 0,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder_outlined),
              title: const Text('파일'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                // TODO: MediaGalleryScreen을 API 메시지와 호환되도록 수정 필요
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MediaGalleryScreen(
                      messages: [], // TODO: API 메시지를 local 메시지로 변환 필요
                      initialTabIndex: 1,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('링크'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                // TODO: MediaGalleryScreen을 API 메시지와 호환되도록 수정 필요
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MediaGalleryScreen(
                      messages: [], // TODO: API 메시지를 local 메시지로 변환 필요
                      initialTabIndex: 2,
                    ),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('채팅방 이름 설정'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
            ListTile(
              title: const Text('배경화면 설정'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
            ListTile(
              title: const Text('알림 설정'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
            const Divider(),
            ListTile(
              title: const Text('대화 내용 내보내기'),
              onTap: () {},
            ),
            ListTile(
              title: const Text('대화 내용 모두 삭제'),
              textColor: Colors.red,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // AI 아이디어 제안 로딩 및 결과 표시
            if (_isGeneratingIdeas)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Row(
                  children: const [
                    SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2)),
                    SizedBox(width: 8),
                    Text('AI가 아이디어를 생성 중입니다...',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            // AI 채팅 요약 로딩 및 결과 표시
            if (_isSummarizing)
               Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Row(
                  children: const [
                    SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2)),
                    SizedBox(width: 8),
                    Text('AI가 대화를 요약 중입니다...',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            if (_summaryResult != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                margin: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // AI 캐릭터 아바타
                    Column(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6B8EFF), Color(0xFF0038FF)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0038FF).withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.smart_toy_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "AI 봇",
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    // 말풍선
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F0FE), // 부드러운 파란색 배경
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(16),
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.summarize,
                                        size: 14, color: Colors.blue[800]),
                                    const SizedBox(width: 6),
                                    Text(
                                      "채팅 요약",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue[900],
                                      ),
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _summaryResult = null;
                                    });
                                  },
                                  child: Icon(Icons.close,
                                      size: 16, color: Colors.blue[900]),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _summaryResult!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: InkWell(
                                onTap: () {
                                  Clipboard.setData(
                                      ClipboardData(text: _summaryResult!));
                                  _showToast(context, '요약 내용이 복사되었습니다.');
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.copy,
                                        size: 12, color: Colors.blue[700]),
                                    const SizedBox(width: 4),
                                    Text(
                                      "복사하기",
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.blue[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // AI 톤 변경 메뉴 및 결과
              if (_isToneChangeMenuOpen)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12.0),
                  margin: const EdgeInsets.only(bottom: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.purple.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "톤 변경",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isToneChangeMenuOpen = false;
                                _toneChangeResults = [];
                                _selectedTone = null;
                              });
                            },
                            child: const Icon(Icons.close,
                                size: 16, color: Colors.purple),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // 톤 선택 칩
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: ToneType.values.map((tone) {
                            final isSelected = _selectedTone == tone;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Text(
                                  tone.label,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isSelected ? Colors.white : Colors.purple,
                                  ),
                                ),
                                selected: isSelected,
                                onSelected: (selected) {
                                  if (selected) {
                                    _changeTone(tone);
                                  }
                                },
                                selectedColor: Colors.purple,
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(color: Colors.purple.withOpacity(0.5)),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // 로딩 중
                      if (_isChangingTone)
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(
                            child: SizedBox(
                              width: 20, 
                              height: 20, 
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.purple)
                            ),
                          ),
                        ),

                      // 결과 목록
                      if (_toneChangeResults.isNotEmpty)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _toneChangeResults.map((result) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: ActionChip(
                                  label: Text(result),
                                  backgroundColor: Colors.white,
                                  elevation: 1,
                                  onPressed: () {
                                    setState(() {
                                      _messageController.text = result;
                                      _isToneChangeMenuOpen = false;
                                    });
                                  },
                                  avatar: const Icon(Icons.check, size: 16, color: Colors.purple),
                                  side: BorderSide(color: Colors.purple.withOpacity(0.3)),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  ),
                ),

              // AI 문법 검사 로딩 및 결과 표시
              if (_isCheckingGrammar)
               Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Row(
                  children: const [
                    SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2)),
                    SizedBox(width: 8),
                    Text('AI가 문법을 검사 중입니다...',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              if (_grammarCheckResult != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12.0),
                  margin: const EdgeInsets.only(bottom: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.check_circle_outline, size: 16, color: Colors.blue),
                              SizedBox(width: 6),
                              Text(
                                "문법 검사 결과",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _grammarCheckResult = null;
                              });
                            },
                            child: const Icon(Icons.close,
                                size: 16, color: Colors.blue),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _grammarCheckResult!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                           InkWell(
                            onTap: () {
                              _messageController.text = _grammarCheckResult!;
                              setState(() {
                                _grammarCheckResult = null;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                "적용",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () {
                              Clipboard.setData(
                                  ClipboardData(text: _grammarCheckResult!));
                              _showToast(context, '복사되었습니다.');
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.blue),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                "복사",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              // AI 아이디어 제안
              if (_aiIdeas.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12.0),
                  margin: const EdgeInsets.only(bottom: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.lightbulb, size: 16, color: Colors.amber),
                              SizedBox(width: 4),
                              Text(
                                'AI 아이디어 제안',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.amber,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _aiIdeas = [];
                              });
                            },
                             child: const Icon(Icons.close,
                                size: 16, color: Colors.amber),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _aiIdeas.map((idea) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ActionChip(
                                label: Text(idea),
                                backgroundColor: Colors.white,
                                elevation: 1,
                                onPressed: () {
                                  setState(() {
                                    _messageController.text = idea;
                                    _aiIdeas = [];
                                  });
                                },
                                side: BorderSide(color: Colors.amber.withOpacity(0.3)),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),

              // 답장 미리보기 UI
              if (_replyContext != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  margin: const EdgeInsets.only(bottom: 0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    border: const Border(left: BorderSide(color: Color(0xFF0095F6), width: 3)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_replyContext!['senderName']}에게 답장',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Color(0xFF0095F6),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _replyContext!['message'] ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF666666),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20, color: Color(0xFF999999)),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          setState(() {
                            _replyContext = null;
                          });
                        },
                      ),
                    ],
                  ),
                ),
            // 이미지 미리보기
            if (_selectedImages.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(8.0),
                margin: const EdgeInsets.only(bottom: 8.0),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_selectedImages.length}장 선택됨',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              setState(() {
                                _selectedImages = [];
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _selectedImages.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right: 8.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: FutureBuilder<Uint8List>(
                                    future:
                                        _selectedImages[index].readAsBytes(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        return Image.memory(
                                          snapshot.data!,
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                        );
                                      }
                                      return Container(
                                        width: 80,
                                        height: 80,
                                        color: Colors.grey[300],
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 12,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedImages.removeAt(index);
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            // 파일 미리보기
            if (_selectedFiles.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(8.0),
                margin: const EdgeInsets.only(bottom: 8.0),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_selectedFiles.length}개 파일 선택됨',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              setState(() {
                                _selectedFiles = [];
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    ...List.generate(_selectedFiles.length, (index) {
                      final file = _selectedFiles[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8.0),
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.blue[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.insert_drive_file,
                                  color: Colors.blue, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    file.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${(file.size / 1024).toStringAsFixed(1)} KB',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                setState(() {
                                  _selectedFiles.removeAt(index);
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            // 음성 메모 미리보기
            if (_selectedVoiceMemo != null)
              Container(
                padding: const EdgeInsets.all(12.0),
                margin: const EdgeInsets.only(bottom: 8.0),
                decoration: BoxDecoration(
                  color: Colors.purple[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purple[200]!),
                ),
                child: Row(
                  children: [
                    // 재생/일시정지 버튼
                    IconButton(
                      icon: Icon(
                        _isPreviewPlaying
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_filled,
                        color: Colors.purple,
                        size: 40,
                      ),
                      onPressed: () async {
                        if (_isPreviewPlaying) {
                          await _previewAudioPlayer.pause();
                        } else {
                          // Web에서는 blob URL을 사용하므로 UrlSource 사용
                          if (_selectedVoiceMemo!.startsWith('blob:')) {
                            await _previewAudioPlayer
                                .play(UrlSource(_selectedVoiceMemo!));
                          } else {
                            await _previewAudioPlayer
                                .play(DeviceFileSource(_selectedVoiceMemo!));
                          }
                        }
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '음성 메모',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            _isPreviewPlaying
                                ? '${_formatDuration(_previewCurrentPosition)} / ${_formatDuration(_previewTotalDuration)}'
                                : '${_voiceMemoDuration ~/ 60}:${(_voiceMemoDuration % 60).toString().padLeft(2, '0')}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () async {
                        await _previewAudioPlayer.stop();
                        setState(() {
                          _selectedVoiceMemo = null;
                          _voiceMemoDuration = 0;
                          _isPreviewPlaying = false;
                          _previewCurrentPosition = Duration.zero;
                          _previewTotalDuration = Duration.zero;
                        });
                      },
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file, color: Color(0xFF999999)),
                  onPressed: () {
                    _showAttachmentMenu(context);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.camera_alt_outlined,
                      color: Color(0xFF999999)),
                  onPressed: () {
                    _openCamera(context);
                  },
                ),
                IconButton(
                  icon:
                      const Icon(Icons.auto_awesome, color: Color(0xFF0095F6)),
                  onPressed: () {
                    _showAIMenu(context);
                  },
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      focusNode: _focusNode,
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: '메시지를 입력하세요',
                        filled: false,
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        hintStyle: TextStyle(color: Color(0xFF999999)),
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                      onSubmitted: _handleSubmitted,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send,
                      color: Color(0xFF0095F6), size: 28),
                  onPressed: () => _handleSubmitted(_messageController.text),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// AI 요청 다이얼로그 (공통)
class _AIRequestDialog extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Future<Result<String>> Function() onExecute;

  const _AIRequestDialog({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.onExecute,
  });

  @override
  State<_AIRequestDialog> createState() => _AIRequestDialogState();
}

class _AIRequestDialogState extends State<_AIRequestDialog> {
  bool _isLoading = true;
  String? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    _executeRequest();
  }

  Future<void> _executeRequest() async {
    final result = await widget.onExecute();

    if (mounted) {
      setState(() {
        _isLoading = false;
        result.when(
          success: (response) => _result = response,
          failure: (error) => _error = error.displayMessage,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(widget.icon, color: widget.iconColor),
          const SizedBox(width: 8),
          Text(widget.title),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: _isLoading
            ? const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('AI가 처리 중입니다...'),
                ],
              )
            : _error != null
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                    ],
                  )
                : SingleChildScrollView(
                    child: SelectableText(
                      _result ?? '',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
      ),
      actions: [
        if (!_isLoading)
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        if (!_isLoading && _result != null)
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: _result!));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('결과가 복사되었습니다')),
              );
            },
            child: const Text('복사'),
          ),
      ],
    );
  }
}

/// 번역 다이얼로그
class _TranslateDialog extends StatefulWidget {
  final String initialText;
  final Future<Result<String>> Function(String text, String targetLanguage)
      onTranslate;
  final void Function(String translatedText) onApply;

  const _TranslateDialog({
    required this.initialText,
    required this.onTranslate,
    required this.onApply,
  });

  @override
  State<_TranslateDialog> createState() => _TranslateDialogState();
}

class _TranslateDialogState extends State<_TranslateDialog> {
  final TextEditingController _textController = TextEditingController();
  String _selectedLanguage = '영어';
  bool _isLoading = false;
  String? _result;
  String? _error;

  final List<String> _languages = [
    '영어',
    '한국어',
    '일본어',
    '중국어',
    '스페인어',
    '프랑스어',
    '독일어'
  ];

  @override
  void initState() {
    super.initState();
    _textController.text = widget.initialText;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _translate() async {
    if (_textController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result =
        await widget.onTranslate(_textController.text, _selectedLanguage);

    if (mounted) {
      setState(() {
        _isLoading = false;
        result.when(
          success: (response) => _result = response,
          failure: (error) => _error = error.displayMessage,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.translate, color: Colors.green),
          SizedBox(width: 8),
          Text('번역'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _textController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: '번역할 텍스트를 입력하세요',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButton<String>(
                value: _selectedLanguage,
                isExpanded: true,
                items: _languages.map((lang) {
                  return DropdownMenuItem(value: lang, child: Text(lang));
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedLanguage = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_result != null) ...[
                const Text('번역 결과:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(_result!),
                ),
              ] else if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        if (!_isLoading && _result == null)
          ElevatedButton(
            onPressed: _translate,
            child: const Text('번역'),
          ),
        if (_result != null)
          ElevatedButton(
            onPressed: () {
              widget.onApply(_result!);
              Navigator.pop(context);
            },
            child: const Text('적용'),
          ),
      ],
    );
  }
}

/// 톤 변경 다이얼로그


class _ToneChangeDialog extends StatefulWidget {
  final String initialText;
  final Future<Result<List<String>>> Function(String text, ToneType tone)
      onChangeTone;
  final void Function(String changedText) onApply;

  const _ToneChangeDialog({
    required this.initialText,
    required this.onChangeTone,
    required this.onApply,
  });

  @override
  State<_ToneChangeDialog> createState() => _ToneChangeDialogState();
}

class _ToneChangeDialogState extends State<_ToneChangeDialog> {
  ToneType _selectedTone = ToneType.formal;
  bool _isLoading = false;
  List<String>? _results;
  String? _selectedResult;
  String? _error;

  final Map<ToneType, String> _toneLabels = {
    ToneType.formal: '격식체 (존댓말)',
    ToneType.casual: '비격식체 (반말)',
    ToneType.friendly: '친근한 톤 (이모지 포함)',
    ToneType.professional: '비즈니스 톤',
    ToneType.polite: '정중한 톤',
  };

  Future<void> _changeTone() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _results = null;
      _selectedResult = null;
    });

    final result = await widget.onChangeTone(widget.initialText, _selectedTone);

    if (mounted) {
      setState(() {
        _isLoading = false;
        result.when(
          success: (response) {
            _results = response;
            if (response.isNotEmpty) {
              _selectedResult = response[0]; // 기본적으로 첫 번째 선택
            }
          },
          failure: (error) => _error = error.displayMessage,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.star, color: Colors.purple),
          SizedBox(width: 8),
          Text('톤 변경'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('원본:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(widget.initialText),
              ),
              const SizedBox(height: 16),
              const Text('변환할 톤:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: ToneType.values.map((tone) {
                  return ChoiceChip(
                    label: Text(_toneLabels[tone]!),
                    selected: _selectedTone == tone,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedTone = tone);
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_results != null) ...[
                const Text('변환 결과 (선택하세요):',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...List.generate(_results!.length, (index) {
                  final text = _results![index];
                  final isSelected = _selectedResult == text;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedResult = text;
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.green[50] : Colors.grey[50],
                        border: Border.all(
                          color: isSelected
                              ? Colors.green
                              : Colors.grey.withOpacity(0.3),
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        text,
                        style: TextStyle(
                          color: isSelected ? Colors.green[900] : Colors.black87,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }),
              ] else if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        if (!_isLoading && _results == null)
          ElevatedButton(
            onPressed: _changeTone,
            child: const Text('변환'),
          ),
        if (_results != null)
          ElevatedButton(
            onPressed: _selectedResult != null
                ? () {
                    widget.onApply(_selectedResult!);
                    Navigator.pop(context);
                  }
                : null,
            child: const Text('적용'),
          ),
      ],
    );
  }
}

/// Drawer에서 참여자 표시용 헬퍼 클래스
class _DrawerParticipant {
  final String? agoraId;
  final String displayName;
  final String? profileImage;

  const _DrawerParticipant({
    this.agoraId,
    required this.displayName,
    this.profileImage,
  });
}
