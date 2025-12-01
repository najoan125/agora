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
import 'package:audioplayers/audioplayers.dart';
import 'media_gallery_screen.dart';

class ConversationScreen extends StatefulWidget {
  final String userName;
  final String userImage;
  final bool isTeam;

  const ConversationScreen({
    Key? key,
    required this.userName,
    required this.userImage,
    this.isTeam = false,
  }) : super(key: key);

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _showSearch = false;
  List<ChatMessage> _searchResults = [];
  List<XFile> _selectedImages = []; // Changed from single to list
  List<PlatformFile> _selectedFiles = []; // Changed from single to list
  String? _selectedVoiceMemo;
  int _voiceMemoDuration = 0;
  
  // 음성 메모 미리보기 재생용
  final AudioPlayer _previewAudioPlayer = AudioPlayer();
  bool _isPreviewPlaying = false;
  Duration _previewCurrentPosition = Duration.zero;
  Duration _previewTotalDuration = Duration.zero;

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
    
    // Dummy messages
    _messages.addAll([
      ChatMessage(
        text: "안녕하세요! 오늘 일정 확인하셨나요?",
        isMe: false,
        time: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      ChatMessage(
        text: "네, 확인했습니다. 2시에 회의 맞죠?",
        isMe: true,
        time: DateTime.now().subtract(const Duration(minutes: 4)),
      ),
      ChatMessage(
        text: "네 맞습니다. 회의실 A에서 뵙겠습니다.",
        isMe: false,
        time: DateTime.now().subtract(const Duration(minutes: 3)),
      ),
    ]);
  }

  @override
  void dispose() {
    _previewAudioPlayer.dispose();
    _messageController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSubmitted(String text) async {
    if (text.trim().isEmpty && _selectedImages.isEmpty && _selectedFiles.isEmpty && _selectedVoiceMemo == null) return;

    try {
      // Convert multiple images to bytes
      List<Uint8List>? imageBytesList;
      if (_selectedImages.isNotEmpty) {
        imageBytesList = [];
        for (var image in _selectedImages) {
          final bytes = await image.readAsBytes();
          imageBytesList.add(bytes);
          print('📸 Image processed: ${bytes.length} bytes');
        }
        print('📸 Total images processed: ${imageBytesList.length}');
      }

      // Convert multiple files to a list
      List<Map<String, dynamic>>? filesList;
      if (_selectedFiles.isNotEmpty) {
        filesList = [];
        for (var file in _selectedFiles) {
          Uint8List? fileBytes;
          if (file.bytes != null) {
            fileBytes = file.bytes;
          } else if (file.path != null) {
            fileBytes = await File(file.path!).readAsBytes();
          }
          
          filesList.add({
            'name': file.name,
            'size': file.size,
            'path': file.path,
            'bytes': fileBytes,
          });
          print('📎 File processed: ${file.name}, ${file.size} bytes');
        }
        print('📎 Total files processed: ${filesList.length}');
      }

      _messageController.clear();
      setState(() {
        print('📤 Sending message: images=${imageBytesList?.length}, files=${filesList?.length}, voice=${_selectedVoiceMemo}');
        _messages.insert(
            0,
            ChatMessage(
              text: _selectedVoiceMemo != null ? "음성 메모" : text,
              isMe: true,
              time: DateTime.now(),
              imageBytesList: imageBytesList,
              filesList: filesList,
              audioPath: _selectedVoiceMemo,
              audioDuration: _selectedVoiceMemo != null ? Duration(seconds: _voiceMemoDuration) : null,
            ));
        _selectedImages = [];
        _selectedFiles = [];
        _selectedVoiceMemo = null;
        _voiceMemoDuration = 0;
      });

      // Auto-reply simulation
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _messages.insert(
                0,
                ChatMessage(
                  text: "자동 응답입니다. 잠시 후 다시 연락드리겠습니다.",
                  isMe: false,
                  time: DateTime.now(),
                ));
          });
        }
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

  @override
  Widget build(BuildContext context) {
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
            Column(
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MediaGalleryScreen(
                            messages: _messages,
                            initialTabIndex: 0,
                          ),
                        ),
                      );
                    },
                  ),
                  // Media Preview Section
                  Builder(
                    builder: (context) {
                      // Collect all images from both imageBytes and imageBytesList
                      final List<Uint8List> allImages = [];
                      
                      for (var message in _messages) {
                        if (message.imageBytesList != null && message.imageBytesList!.isNotEmpty) {
                          allImages.addAll(message.imageBytesList!);
                        } else if (message.imageBytes != null) {
                          allImages.add(message.imageBytes!);
                        }
                      }
                      
                      if (allImages.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      
                      return Container(
                        padding: const EdgeInsets.all(16),
                        child: SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: allImages.take(5).length,
                            itemBuilder: (context, index) {
                              final imageBytes = allImages[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => Scaffold(
                                        appBar: AppBar(backgroundColor: Colors.black, iconTheme: const IconThemeData(color: Colors.white)),
                                        backgroundColor: Colors.black,
                                        body: Center(
                                          child: Image.memory(imageBytes),
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
                                      image: MemoryImage(imageBytes),
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MediaGalleryScreen(
                            messages: _messages,
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MediaGalleryScreen(
                            messages: _messages,
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
            child: _searchResults.isNotEmpty
                ? ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 20),
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final message = _searchResults[index];
                      return MessageBubble(
                        message: message.text,
                        isMe: message.isMe,
                        time: message.time,
                        userImage: widget.userImage,
                        senderName: widget.userName,
                        imageBytes: message.imageBytes,
                        imageBytesList: message.imageBytesList,
                        imageUrl: message.imageUrl,
                        fileName: message.fileName,
                        fileSize: message.fileSize,
                        filePath: message.filePath,
                        fileBytes: message.fileBytes,
                        filesList: message.filesList,
                        audioPath: message.audioPath,
                        audioDuration: message.audioDuration,
                      );
                    },
                  )
                : ListView.builder(
                    reverse: true,
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 20),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return MessageBubble(
                        message: message.text,
                        isMe: message.isMe,
                        time: message.time,
                        userImage: widget.userImage,
                        senderName: widget.userName,
                        imageBytes: message.imageBytes,
                        imageBytesList: message.imageBytesList,
                        imageUrl: message.imageUrl,
                        fileName: message.fileName,
                        fileSize: message.fileSize,
                        filePath: message.filePath,
                        fileBytes: message.fileBytes,
                        filesList: message.filesList,
                        audioPath: message.audioPath,
                        audioDuration: message.audioDuration,
                      );
                    },
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MediaGalleryScreen(
                      messages: _messages,
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MediaGalleryScreen(
                      messages: _messages,
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MediaGalleryScreen(
                      messages: _messages,
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

class ChatMessage {
  final String text;
  final bool isMe;
  final DateTime time;
  final Uint8List? imageBytes; // Single image (backward compatibility)
  final List<Uint8List>? imageBytesList; // Multiple images
  final String? imageUrl;
  final String? fileName; // Single file (backward compatibility)
  final int? fileSize; // Single file (backward compatibility)
  final String? filePath; // Single file (backward compatibility)
  final Uint8List? fileBytes; // Single file (backward compatibility)
  final List<Map<String, dynamic>>? filesList; // Multiple files
  final String? audioPath;
  final Duration? audioDuration;

  ChatMessage({
    required this.text,
    required this.isMe,
    required this.time,
    this.imageBytes,
    this.imageBytesList,
    this.imageUrl,
    this.fileName,
    this.fileSize,
    this.filePath,
    this.fileBytes,
    this.filesList,
    this.audioPath,
    this.audioDuration,
  });
}

class MessageBubble extends StatefulWidget {
  final String message;
  final bool isMe;
  final DateTime time;
  final String? userImage;
  final String senderName;
  final Uint8List? imageBytes; // Single image (backward compatibility)
  final List<Uint8List>? imageBytesList; // Multiple images
  final String? imageUrl;
  final String? fileName; // Single file (backward compatibility)
  final int? fileSize; // Single file (backward compatibility)
  final String? filePath; // Single file (backward compatibility)
  final Uint8List? fileBytes; // Single file (backward compatibility)
  final List<Map<String, dynamic>>? filesList; // Multiple files
  final String? audioPath;
  final Duration? audioDuration;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isMe,
    required this.time,
    this.userImage,
    required this.senderName,
    this.imageBytes,
    this.imageBytesList,
    this.imageUrl,
    this.fileName,
    this.fileSize,
    this.filePath,
    this.fileBytes,
    this.filesList,
    this.audioPath,
    this.audioDuration,
  }) : super(key: key);

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  Timer? _positionTimer;

  @override
  void initState() {
    super.initState();
    if (widget.audioPath != null) {
      print('🎵 MessageBubble init: audioPath=${widget.audioPath}, audioDuration=${widget.audioDuration}');
      
      // Set initial duration from widget
      if (widget.audioDuration != null) {
        setState(() {
          _totalDuration = widget.audioDuration!;
        });
        print('⏱️ Initial duration set: ${widget.audioDuration}');
      }
      
      _audioPlayer.onPlayerStateChanged.listen((state) {
        if (mounted) {
          setState(() {
            _isPlaying = state == PlayerState.playing;
          });
        }
      });

      _audioPlayer.onDurationChanged.listen((duration) {
        if (mounted) {
          print('⏱️ Duration changed: $duration');
          // 0초로 변경되는 경우, 기존에 유효한 시간이 있다면 무시
          if (duration == Duration.zero && _totalDuration > Duration.zero) {
            print('⚠️ Ignoring zero duration update as we have valid duration: $_totalDuration');
            return;
          }
          setState(() {
            _totalDuration = duration;
          });
        }
      });

      _audioPlayer.onPositionChanged.listen((position) {
        if (mounted) {
          setState(() {
            _currentPosition = position;
          });
        }
      });

      _audioPlayer.onPlayerComplete.listen((event) {
        if (mounted) {
          setState(() {
            _isPlaying = false;
            _currentPosition = Duration.zero;
          });
        }
      });

      // Load audio source to get actual duration
      _loadAudioDuration();
    }
  }

  Future<void> _loadAudioDuration() async {
    try {
      print('📂 Loading audio file: ${widget.audioPath}');
      
      // Web에서는 blob URL을 사용하므로 setSourceUrl 사용
      if (widget.audioPath!.startsWith('blob:')) {
        print('🌐 Using setSourceUrl for blob URL');
        await _audioPlayer.setSourceUrl(widget.audioPath!);
      } else {
        print('📱 Using setSourceDeviceFile for file path');
        await _audioPlayer.setSourceDeviceFile(widget.audioPath!);
      }
      
      print('✅ Audio file loaded successfully');
      // Duration will be set via onDurationChanged listener
    } catch (e) {
      print('❌ Error loading audio duration: $e');
    }
  }

  @override
  void dispose() {
    _positionTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Future<void> _playPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      _positionTimer?.cancel();
      setState(() {
        _isPlaying = false;
      });
    } else {
      // Web에서는 blob URL을 사용하므로 UrlSource 사용
      if (widget.audioPath!.startsWith('blob:')) {
        await _audioPlayer.play(UrlSource(widget.audioPath!));
      } else {
        await _audioPlayer.play(DeviceFileSource(widget.audioPath!));
      }
      
      setState(() {
        _isPlaying = true;
      });
      
      // Web에서 position 업데이트를 위한 타이머
      _positionTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) async {
        if (mounted && _isPlaying) {
          final position = await _audioPlayer.getCurrentPosition();
          final duration = await _audioPlayer.getDuration();
          
          if (mounted) {
            setState(() {
              if (position != null) _currentPosition = position;
              if (duration != null && duration > Duration.zero) _totalDuration = duration;
            });
          }
          
          // 재생 완료 체크
          if (position != null && duration != null && position >= duration) {
            timer.cancel();
            if (mounted) {
              setState(() {
                _isPlaying = false;
                _currentPosition = Duration.zero;
              });
            }
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!widget.isMe) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
                image: widget.userImage != null && widget.userImage!.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(widget.userImage!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: widget.userImage == null || widget.userImage!.isEmpty
                  ? const Icon(Icons.person, size: 20, color: Colors.grey)
                  : null,
            ),
            const SizedBox(width: 8),
          ],
          Column(
            crossAxisAlignment:
                widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (!widget.isMe) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    widget.senderName,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (widget.isMe) ...[ 
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Text(
                        '${widget.time.hour}:${widget.time.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                  // 미디어 콘텐츠와 텍스트를 Column으로 분리
                  Column(
                    crossAxisAlignment: widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      // 이미지 표시 (말풍선 밖)
                      if (widget.imageBytes != null || (widget.imageBytesList != null && widget.imageBytesList!.isNotEmpty)) ...[
                        Builder(
                          builder: (context) {
                            final images = widget.imageBytesList ?? [widget.imageBytes!];
                            
                            if (images.length == 1) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => Scaffold(
                                        appBar: AppBar(backgroundColor: Colors.black, iconTheme: const IconThemeData(color: Colors.white)),
                                        backgroundColor: Colors.black,
                                        body: Center(
                                          child: Image.memory(images[0]),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 240,
                                      maxHeight: 320,
                                    ),
                                    child: Image.memory(
                                      images[0],
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              );
                            }

                            // Grid layout for multiple images
                            return SizedBox(
                              width: 240,
                              child: Wrap(
                                spacing: 4,
                                runSpacing: 4,
                                children: List.generate(images.length, (index) {
                                  // Calculate size based on image count
                                  double size;
                                  if (images.length == 2 || images.length == 4) {
                                    size = (240 - 4) / 2; // 2 columns
                                  } else {
                                    size = (240 - 8) / 3; // 3 columns
                                  }

                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => Scaffold(
                                            appBar: AppBar(backgroundColor: Colors.black, iconTheme: const IconThemeData(color: Colors.white)),
                                            backgroundColor: Colors.black,
                                            body: PageView.builder(
                                              controller: PageController(initialPage: index),
                                              itemCount: images.length,
                                              itemBuilder: (context, pageIndex) {
                                                return Center(
                                                  child: Image.memory(
                                                    images[pageIndex],
                                                    errorBuilder: (context, error, stackTrace) {
                                                      print('❌ Error displaying full screen image: $error');
                                                      return const Icon(Icons.error, color: Colors.white);
                                                    },
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.memory(
                                        images[index],
                                        width: size,
                                        height: size,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          print('❌ Error displaying grid image: $error');
                                          return Container(
                                            width: size,
                                            height: size,
                                            color: Colors.grey[300],
                                            child: const Icon(Icons.broken_image, color: Colors.grey),
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            );
                          },
                        ),
                        if (widget.message.isNotEmpty) const SizedBox(height: 8),
                      ],
                      // 파일 표시 (말풍선 밖)
                      // Multiple files support
                      if (widget.filesList != null && widget.filesList!.isNotEmpty) ...[
                        ...widget.filesList!.map((fileData) {
                          final fileName = fileData['name'] as String?;
                          final fileSize = fileData['size'] as int?;
                          final fileBytes = fileData['bytes'] as Uint8List?;
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: widget.isMe
                                    ? const Color(0xFF0095F6)
                                    : const Color(0xFFF0F0F0),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.insert_drive_file,
                                    color: widget.isMe ? Colors.white : Colors.blue,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (fileName != null)
                                        Text(
                                          fileName,
                                          style: TextStyle(
                                            color: widget.isMe ? Colors.white : Colors.black,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      if (fileSize != null)
                                        Text(
                                          '${(fileSize / 1024).toStringAsFixed(1)} KB',
                                          style: TextStyle(
                                            color: widget.isMe
                                                ? Colors.white.withValues(alpha: 0.8)
                                                : Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                    ],
                                  ),
                                  if (fileBytes != null && fileName != null) ...[ 
                                    const SizedBox(width: 12),
                                    IconButton(
                                      icon: Icon(
                                        Icons.download,
                                        color: widget.isMe ? Colors.white : Colors.blue,
                                        size: 24,
                                      ),
                                      onPressed: () async {
                                        await FileDownloadHelper.downloadFile(
                                          fileBytes: fileBytes,
                                          fileName: fileName,
                                        );
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('$fileName 다운로드 완료'),
                                              duration: const Duration(seconds: 2),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                        if (widget.message.isNotEmpty) const SizedBox(height: 8),
                      ]
                      // Single file (backward compatibility)
                      else if (widget.fileName != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: widget.isMe
                                ? const Color(0xFF0095F6)
                                : const Color(0xFFF0F0F0),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.insert_drive_file,
                                color: widget.isMe ? Colors.white : Colors.blue,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.fileName!,
                                    style: TextStyle(
                                      color: widget.isMe ? Colors.white : Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (widget.fileSize != null)
                                    Text(
                                      '${(widget.fileSize! / 1024).toStringAsFixed(1)} KB',
                                      style: TextStyle(
                                        color: widget.isMe
                                            ? Colors.white.withValues(alpha: 0.8)
                                            : Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                              if (widget.fileBytes != null) ...[
                                const SizedBox(width: 12),
                                IconButton(
                                  icon: Icon(
                                    Icons.download,
                                    color: widget.isMe ? Colors.white : Colors.blue,
                                    size: 24,
                                  ),
                                  onPressed: () async {
                                    if (widget.fileBytes != null && widget.fileName != null) {
                                      await FileDownloadHelper.downloadFile(
                                        fileBytes: widget.fileBytes!,
                                        fileName: widget.fileName!,
                                      );
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('${widget.fileName} 다운로드 완료'),
                                            duration: const Duration(seconds: 2),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (widget.message.isNotEmpty) const SizedBox(height: 8),
                      ],
                      // 오디오 플레이어 (말풍선 밖)
                      if (widget.audioPath != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: widget.isMe
                                ? const Color(0xFF0095F6)
                                : const Color(0xFFF0F0F0),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  _isPlaying ? Icons.pause : Icons.play_arrow,
                                  color: widget.isMe ? Colors.white : Colors.purple,
                                  size: 28,
                                ),
                                onPressed: _playPause,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '음성 메모',
                                    style: TextStyle(
                                      color: widget.isMe ? Colors.white : Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  SizedBox(
                                    width: 150,
                                    child: LinearProgressIndicator(
                                      value: (_totalDuration == Duration.zero && widget.audioDuration != null ? widget.audioDuration! : _totalDuration).inMilliseconds > 0
                                          ? (_currentPosition.inMilliseconds / (_totalDuration == Duration.zero && widget.audioDuration != null ? widget.audioDuration! : _totalDuration).inMilliseconds).clamp(0.0, 1.0)
                                          : 0.0,
                                      backgroundColor: widget.isMe ? Colors.white.withValues(alpha: 0.3) : Colors.grey[300],
                                      valueColor: AlwaysStoppedAnimation<Color>(widget.isMe ? Colors.white : Colors.purple),
                                      minHeight: 2,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_formatDuration(_currentPosition)} / ${_formatDuration(_totalDuration == Duration.zero && widget.audioDuration != null ? widget.audioDuration! : _totalDuration)}',
                                    style: TextStyle(
                                      color: widget.isMe
                                          ? Colors.white.withValues(alpha: 0.8)
                                          : Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (widget.message.isNotEmpty && widget.message != '음성 메모')
                          const SizedBox(height: 8),
                      ],
                      // 텍스트 메시지 (말풍선 안)
                      if (widget.message.isNotEmpty &&
                          (widget.audioPath == null || widget.message != '음성 메모'))
                        Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.7,
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: widget.isMe
                                ? const Color(0xFF0095F6)
                                : const Color(0xFFF0F0F0),
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(20),
                              topRight: const Radius.circular(20),
                              bottomLeft: Radius.circular(widget.isMe ? 20 : 4),
                              bottomRight: Radius.circular(widget.isMe ? 4 : 20),
                            ),
                          ),
                          child: Text(
                            widget.message,
                            style: TextStyle(
                              color: widget.isMe ? Colors.white : Colors.black,
                              fontSize: 15,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (!widget.isMe) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(
                        '${widget.time.hour}:${widget.time.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
