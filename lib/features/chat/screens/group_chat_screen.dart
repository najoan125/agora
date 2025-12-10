// 그룹 채팅 대화 화면
import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import 'invite_user_screen.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'dart:typed_data';
import 'dart:io';
import '../../../core/utils/file_download_helper.dart';
import '../widgets/voice_recorder_dialog.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/chat_message.dart';
import '../widgets/message_bubble.dart';

class GroupChatScreen extends StatefulWidget {
  final String groupName;
  final String? groupImage;
  final List<String> members;

  const GroupChatScreen({
    Key? key,
    required this.groupName,
    this.groupImage,
    required this.members,
  }) : super(key: key);

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _showSearch = false;
  List<ChatMessage> _searchResults = [];
  XFile? _selectedImage;
  PlatformFile? _selectedFile;

  @override
  void initState() {
    super.initState();
    _initializeMessages();
  }

  void _initializeMessages() {
    final members = widget.members;
    if (members.isEmpty) {
      _messages = [
        ChatMessage(
          text: '안녕하세요! 반갑습니다.',
          isMe: false,
          time: DateTime.now().subtract(const Duration(minutes: 30)),
          sender: '김철수',
          userImage: 'https://picsum.photos/id/64/200/200',
        ),
      ];
      return;
    }

    _messages = [
      ChatMessage(
        text: '안녕하세요! 반갑습니다.',
        isMe: false,
        time: DateTime.now().subtract(const Duration(minutes: 30)),
        sender: members[0 % members.length],
        userImage: 'https://picsum.photos/id/64/200/200',
      ),
      ChatMessage(
        text: '오늘 모임 시간 확정됐나요?',
        isMe: false,
        time: DateTime.now().subtract(const Duration(minutes: 25)),
        sender: members[1 % members.length],
        userImage: 'https://picsum.photos/id/91/200/200',
      ),
      ChatMessage(
        text: '오후 3시로 정했어요!',
        isMe: false,
        time: DateTime.now().subtract(const Duration(minutes: 20)),
        sender: members[2 % members.length],
        userImage: 'https://picsum.photos/id/103/200/200',
      ),
    ];
  }

  void _handleSubmitted(String text) async {
    if (text.trim().isEmpty && _selectedImage == null && _selectedFile == null) return;

    Uint8List? imageBytes;
    if (_selectedImage != null) {
      imageBytes = await _selectedImage!.readAsBytes();
    }

    Uint8List? fileBytes;
    if (_selectedFile != null) {
      if (_selectedFile!.bytes != null) {
        fileBytes = _selectedFile!.bytes;
      } else if (_selectedFile!.path != null) {
        fileBytes = await File(_selectedFile!.path!).readAsBytes();
      }
    }

    _messageController.clear();
    setState(() {
      _messages.insert(
        0,
        ChatMessage(
          text: text,
          isMe: true,
          time: DateTime.now(),
          sender: '나',
          imageBytes: imageBytes,
          fileName: _selectedFile?.name,
          fileSize: _selectedFile?.size,
          filePath: _selectedFile?.path,
          fileBytes: fileBytes,
        ),
      );
      _selectedImage = null;
      _selectedFile = null;
    });

    // 자동 응답 예시
    if (widget.members.isNotEmpty) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _messages.insert(
              0,
              ChatMessage(
                text: "좋아요!",
                isMe: false,
                time: DateTime.now(),
                sender: widget.members[
                    DateTime.now().millisecond % widget.members.length],
                userImage: 'https://picsum.photos/id/${(DateTime.now().millisecond % 50) + 50}/200/200',
              ),
            );
          });
        }
      });
    }
  }

  void _deleteMessage(String messageText) {
    setState(() {
      _messages.removeWhere((msg) => msg.text == messageText && msg.isMe);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('메시지가 삭제되었습니다'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleReply(String messageText, String senderName) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('답장 기능은 준비 중입니다'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _handleForward(String messageText) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('전달 기능은 준비 중입니다'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _handlePin(String messageText) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('메시지가 고정되었습니다'),
        duration: Duration(seconds: 1),
      ),
    );
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

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        setState(() {
          _selectedFile = result.files.first;
          _selectedImage = null;
        });
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
    }
  }

  void _showVoiceRecorder(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => VoiceRecorderDialog(
        onStop: (path, duration) {
          // TODO: Implement voice memo upload logic here
          _showToast(context, '음성 메모가 저장되었습니다');
          setState(() {
            _messages.insert(
                0,
                ChatMessage(
                  text: "음성 메모",
                  isMe: true,
                  time: DateTime.now(),
                  sender: '나',
                  audioPath: path,
                  audioDuration: Duration(seconds: duration),
                ));
          });
        },
      ),
    );
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.groupName,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${widget.members.length + 1}명',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
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
                    // Group Info
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(16),
                            image: widget.groupImage != null
                                ? DecorationImage(
                                    image: NetworkImage(widget.groupImage!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: widget.groupImage == null
                              ? const Center(
                                  child: Text('👥',
                                      style: TextStyle(fontSize: 24)))
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.groupName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '멤버 ${widget.members.length + 1}명',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Horizontal Member List
                    SizedBox(
                      height: 90,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.zero,
                        children: [
                          // Me
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
                          // Other Members
                          ...widget.members.map((member) => Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                          image: NetworkImage(
                                            'https://picsum.photos/seed/${member.hashCode}/200/200',
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      member,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              )),
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
                    onTap: () => _showToast(context, '사진/동영상 보관함'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.folder_outlined,
                        color: AppTheme.textPrimary),
                    title: const Text('파일'),
                    trailing: const Icon(Icons.arrow_forward_ios,
                        size: 14, color: AppTheme.textSecondary),
                    onTap: () => _showToast(context, '파일 보관함'),
                  ),
                  ListTile(
                    leading:
                        const Icon(Icons.link, color: AppTheme.textPrimary),
                    title: const Text('링크'),
                    trailing: const Icon(Icons.arrow_forward_ios,
                        size: 14, color: AppTheme.textSecondary),
                    onTap: () => _showToast(context, '링크 보관함'),
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
                        key: ValueKey('${message.time}_${message.text}'),
                        message: message.text,
                        isMe: message.isMe,
                        time: message.time,
                        senderName: message.sender,
                        userImage: message.userImage ?? message.avatar,
                        onDelete: _deleteMessage,
                        onReply: _handleReply,
                        onForward: _handleForward,
                        onPin: _handlePin,
                        imageBytes: message.imageBytes,
                        imageUrl: message.imageUrl,
                        fileName: message.fileName,
                        fileSize: message.fileSize,
                        filePath: message.filePath,
                        fileBytes: message.fileBytes,
                        audioPath: message.audioPath,
                        audioDuration: message.audioDuration,
                        reactions: message.reactions,
                        onReactionSelected: (emoji) {
                          setState(() {
                            if (index >= 0 && index < _searchResults.length) {
                              final updatedMessage = _searchResults[index].copyWith(
                                reactions: List.from(_searchResults[index].reactions)..add(emoji),
                              );
                              _searchResults[index] = updatedMessage;
                              
                              final originalIndex = _messages.indexWhere((m) => m.time == message.time && m.text == message.text);
                              if (originalIndex != -1) {
                                _messages[originalIndex] = updatedMessage;
                              }
                            }
                          });
                        },
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
                        key: ValueKey('${message.time}_${message.text}'),
                        message: message.text,
                        isMe: message.isMe,
                        time: message.time,
                        senderName: message.sender,
                        userImage: message.userImage ?? message.avatar,
                        onDelete: _deleteMessage,
                        onReply: _handleReply,
                        onForward: _handleForward,
                        onPin: _handlePin,
                        imageBytes: message.imageBytes,
                        imageUrl: message.imageUrl,
                        fileName: message.fileName,
                        fileSize: message.fileSize,
                        filePath: message.filePath,
                        fileBytes: message.fileBytes,
                        audioPath: message.audioPath,
                        audioDuration: message.audioDuration,
                        reactions: message.reactions,
                        onReactionSelected: (emoji) {
                          setState(() {
                            if (index >= 0 && index < _messages.length) {
                              final updatedMessage = _messages[index].copyWith(
                                reactions: List.from(_messages[index].reactions)..add(emoji),
                              );
                              _messages[index] = updatedMessage;
                            }
                          });
                        },
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
                      leading: const Icon(Icons.edit_note, color: Colors.blue),
                      title: const Text('메시지 생성'),
                      subtitle: const Text('AI가 메시지를 생성합니다'),
                      onTap: () {
                        Navigator.pop(context);
                        _showToast(context, 'AI 메시지를 생성했습니다');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.summarize, color: Colors.orange),
                      title: const Text('메시지 요약'),
                      subtitle: const Text('대화 내용을 요약합니다'),
                      onTap: () {
                        Navigator.pop(context);
                        _showToast(context, '메시지를 요약했습니다');
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
            if (_selectedImage != null)
              Container(
                padding: const EdgeInsets.all(8.0),
                margin: const EdgeInsets.only(bottom: 8.0),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: FutureBuilder<Uint8List>(
                        future: _selectedImage!.readAsBytes(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Image.memory(
                              snapshot.data!,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            );
                          }
                          return Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey[300],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '사진이 선택되었습니다',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _selectedImage = null;
                        });
                      },
                    ),
                  ],
                ),
              ),
            if (_selectedFile != null)
              Container(
                padding: const EdgeInsets.all(8.0),
                margin: const EdgeInsets.only(bottom: 8.0),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
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
                            _selectedFile!.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${(_selectedFile!.size / 1024).toStringAsFixed(1)} KB',
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
                      onPressed: () {
                        setState(() {
                          _selectedFile = null;
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

  @override
  void dispose() {
    _messageController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
}
}
