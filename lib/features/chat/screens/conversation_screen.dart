import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import 'invite_user_screen.dart';
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
import '../../../services/websocket_service.dart';
import '../../../data/models/chat/chat.dart';

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

  // 음성 메모 미리보기 재생용
  final AudioPlayer _previewAudioPlayer = AudioPlayer();
  bool _isPreviewPlaying = false;
  Duration _previewCurrentPosition = Duration.zero;
  Duration _previewTotalDuration = Duration.zero;

  // WebSocket 연결 여부
  bool _isWebSocketInitialized = false;
  WebSocketService? _webSocketService;

  @override
  void initState() {
    super.initState();

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
    super.dispose();
  }

  void _handleSubmitted(String text) async {
    if (text.trim().isEmpty && _selectedImages.isEmpty && _selectedFiles.isEmpty && _selectedVoiceMemo == null) return;

    try {
      // TODO: 파일 업로드 구현 필요
      // 현재는 텍스트 메시지만 WebSocket으로 전송
      List<String>? fileIds;

      // 이미지나 파일이 있는 경우 파일 업로드 서비스 호출 필요
      if (_selectedImages.isNotEmpty || _selectedFiles.isNotEmpty) {
        // 파일 업로드 후 fileIds 획득
        // fileIds = await _uploadFiles();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('파일 업로드 기능은 준비 중입니다.')),
        );
      }

      // 메시지 타입 결정
      MessageType messageType = MessageType.text;
      String messageContent = text.trim().isEmpty ? "음성 메모" : text;

      if (_selectedVoiceMemo != null) {
        // 음성 메모의 경우 파일 업로드 후 FILE 타입으로 전송
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('음성 메모 업로드 기능은 준비 중입니다.')),
        );
      } else if (_selectedImages.isNotEmpty) {
        messageType = MessageType.image;
      } else if (_selectedFiles.isNotEmpty) {
        messageType = MessageType.file;
      }

      // WebSocket으로 메시지 전송
      final notifier = ref.read(messageListProvider(widget.chatId).notifier);
      notifier.sendMessage(
        content: messageContent,
        type: messageType,
        fileIds: fileIds,
      );

      // 입력 필드 초기화
      _messageController.clear();
      setState(() {
        _selectedImages = [];
        _selectedFiles = [];
        _selectedVoiceMemo = null;
        _voiceMemoDuration = 0;
      });
    } catch (e) {
      print('❌ Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('메시지 전송 중 오류가 발생했습니다: $e')),
      );
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
  local.ChatMessage _convertToLocalMessage(ChatMessage apiMessage, String currentUserId) {
    return local.ChatMessage(
      text: apiMessage.content,
      isMe: apiMessage.senderAgoraId == currentUserId,
      time: apiMessage.createdAt,
      sender: apiMessage.displayName,
      // TODO: 첨부파일 처리
      // imageUrl: apiMessage.attachments?.firstWhere((a) => a.mimeType.startsWith('image'))?.fileUrl,
      // fileName: apiMessage.attachments?.firstWhere((a) => !a.mimeType.startsWith('image'))?.fileName,
    );
  }

  /// 메시지 목록 빌드
  Widget _buildMessageList() {
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
                ref.read(messageListProvider(widget.chatId).notifier).loadMessages();
              },
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    // 메시지 목록 표시
    final messages = messageState.messages;

    // TODO: currentUserId는 실제로는 프로필 Provider에서 가져와야 함
    const currentUserId = 'me'; // 임시값

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        // 스크롤이 맨 아래에 도달하면 더 불러오기
        if (!messageState.isLoading &&
            messageState.hasMore &&
            scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
          ref.read(messageListProvider(widget.chatId).notifier).loadMessages(loadMore: true);
        }
        return false;
      },
      child: ListView.builder(
        reverse: true,
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        itemCount: messages.length + (messageState.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          // 더 불러오기 인디케이터
          if (index == messages.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final apiMessage = messages[index];
          final localMessage = _convertToLocalMessage(apiMessage, currentUserId);

          return MessageBubble(
            key: ValueKey(apiMessage.id),
            message: localMessage.text,
            isMe: localMessage.isMe,
            time: localMessage.time,
            userImage: widget.userImage,
            senderName: localMessage.sender ?? widget.userName,
            imageUrl: localMessage.imageUrl,
            fileName: localMessage.fileName,
            fileSize: localMessage.fileSize,
            reactions: localMessage.reactions,
            onReactionSelected: (emoji) {
              // TODO: 리액션 API 연동
              print('Reaction selected: $emoji for message ${apiMessage.id}');
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // WebSocket 연결 상태 감지
    final connectionState = ref.watch(webSocketConnectionStateProvider);

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
                    return const Icon(Icons.circle, color: Colors.green, size: 12);
                  case WebSocketConnectionState.connecting:
                    return const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  case WebSocketConnectionState.error:
                    return const Icon(Icons.circle, color: Colors.red, size: 12);
                  default:
                    return const Icon(Icons.circle, color: Colors.grey, size: 12);
                }
              },
              loading: () => const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              error: (_, __) => const Icon(Icons.circle, color: Colors.red, size: 12),
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
                          // Current User (Me)
                          Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: Column(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    shape: BoxShape.circle,
                                    image: const DecorationImage(
                                      image: NetworkImage(
                                          'https://picsum.photos/id/1005/200/200'), // My image
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  '나',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Other User
                          Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: Column(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    shape: BoxShape.circle,
                                    image: widget.userImage.isNotEmpty
                                        ? DecorationImage(
                                            image: NetworkImage(widget.userImage),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: widget.userImage.isEmpty
                                      ? const Icon(Icons.person,
                                          color: Colors.grey)
                                      : null,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  widget.userName,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Invite Button
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const InviteUserScreen(),
                                  ),
                                );
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
                      final messageState = ref.watch(messageListProvider(widget.chatId));

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
                                          iconTheme: const IconThemeData(color: Colors.white),
                                        ),
                                        backgroundColor: Colors.black,
                                        body: Center(
                                          child: Image.network(attachment.fileUrl),
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
                                        attachment.thumbnailUrl ?? attachment.fileUrl,
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
            child: _buildMessageList(),
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
                        _showToast(context, 'AI 아이디어를 제안했습니다');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.translate, color: Colors.green),
                      title: const Text('번역'),
                      subtitle: const Text('메시지를 번역합니다'),
                      onTap: () {
                        Navigator.pop(context);
                        _showToast(context, '메시지가 번역되었습니다');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.edit, color: Colors.blue),
                      title: const Text('문법 검사'),
                      subtitle: const Text('입력한 메시지의 문법을 검사합니다'),
                      onTap: () {
                        Navigator.pop(context);
                        _showToast(context, '문법 검사를 완료했습니다');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.star, color: Colors.purple),
                      title: const Text('톤 변경'),
                      subtitle: const Text('메시지의 톤을 변경합니다'),
                      onTap: () {
                        Navigator.pop(context);
                        _showToast(context, '톤을 변경했습니다');
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
                                    future: _selectedImages[index].readAsBytes(),
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
                        _isPreviewPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                        color: Colors.purple,
                        size: 40,
                      ),
                      onPressed: () async {
                        if (_isPreviewPlaying) {
                          await _previewAudioPlayer.pause();
                        } else {
                          // Web에서는 blob URL을 사용하므로 UrlSource 사용
                          if (_selectedVoiceMemo!.startsWith('blob:')) {
                            await _previewAudioPlayer.play(UrlSource(_selectedVoiceMemo!));
                          } else {
                            await _previewAudioPlayer.play(DeviceFileSource(_selectedVoiceMemo!));
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
                  icon: const Icon(Icons.auto_awesome, color: Color(0xFF0095F6)),
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
                  icon: const Icon(Icons.send, color: Color(0xFF0095F6), size: 28),
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
