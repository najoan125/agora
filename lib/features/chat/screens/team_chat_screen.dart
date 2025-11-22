
// 팀 채팅 대화 화면
import 'package:flutter/material.dart';

import '../../../data/data_manager.dart';

class TeamChatScreen extends StatefulWidget {
  final String teamName;
  final String teamIcon;
  final String? teamImage;
  final List<String> members;

  const TeamChatScreen({
    Key? key,
    required this.teamName,
    required this.teamIcon,
    this.teamImage,
    required this.members,
  }) : super(key: key);

  @override
  State<TeamChatScreen> createState() => _TeamChatScreenState();
}

class _TeamChatScreenState extends State<TeamChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final DataManager _dataManager = DataManager();
  final List<ChatMessage> _messages = [
    ChatMessage(
      text: '안녕하세요. 오늘 회의 자료 올려드리겠습니다.',
      isMe: false,
      time: DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day, 10, 30),
      sender: '김철수',
      avatar: '👨',
      userImage: 'https://picsum.photos/id/1011/200/200',
    ),
    ChatMessage(
      text: '감사합니다!',
      isMe: false,
      time: DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day, 10, 35),
      sender: '이영희',
      avatar: '👩',
      userImage: 'https://picsum.photos/id/1027/200/200',
    ),
    ChatMessage(
      text: '오후 3시 회의 가능한가요?',
      isMe: false,
      time: DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day, 10, 40),
      sender: '박지성',
      avatar: '👨',
      userImage: 'https://picsum.photos/id/1005/200/200',
    ),
  ];
  final ScrollController _scrollController = ScrollController();
  bool _showSearch = false;
  List<ChatMessage> _searchResults = [];

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;

    _messageController.clear();
    setState(() {
      _messages.insert(
        0,
        ChatMessage(
          text: text,
          isMe: true,
          time: DateTime.now(),
          sender: '나',
          avatar: '🧑',
          userImage: _dataManager.currentUser['image'],
        ),
      );
    });

    // 자동 응답 예시
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _messages.insert(
            0,
            ChatMessage(
              text: "알겠습니다!",
              isMe: false,
              time: DateTime.now(),
              sender: '팀원',
              avatar: '👨',
              userImage: 'https://picsum.photos/id/1011/200/200',
            ),
          );
        });
      }
    });
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
    final currentUser = _dataManager.currentUser;
    final allMembers = [currentUser['name'], ...widget.members];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.teamName,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '${widget.members.length}명',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          // 검색 아이콘
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
          // 설정 아이콘
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_horiz, color: Colors.black),
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                enabled: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '팀 정보',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(8),
                              image: widget.teamImage != null
                                  ? DecorationImage(
                                      image: NetworkImage(widget.teamImage!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: widget.teamImage == null
                                ? Center(
                                    child: Text(
                                      widget.teamIcon,
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Text(widget.teamName),
                        ],
                      ),
                      const Divider(height: 24),
                      const Text(
                        '팀원',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...allMembers.map((member) {
                        final isMe = member == currentUser['name'];
                        // Find friend data for image
                        final friend = _dataManager.friends.firstWhere(
                          (f) => f['name'] == member,
                          orElse: () => {'image': null, 'avatar': '👤'},
                        );
                        final image = isMe ? currentUser['image'] : friend['image'];
                        final avatar = isMe ? currentUser['avatar'] : friend['avatar'];

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                  image: image != null
                                      ? DecorationImage(
                                          image: NetworkImage(image),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: image == null
                                    ? Center(
                                        child: Text(
                                          avatar ?? '👤',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                member,
                                style: TextStyle(
                                  fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                              if (isMe)
                                const Padding(
                                  padding: EdgeInsets.only(left: 4.0),
                                  child: Text(
                                    '(나)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
              const PopupMenuDivider(),
              // ... (rest of the menu items)
              PopupMenuItem(
                value: 'add_member',
                child: const Text('팀원 초대'),
                onTap: () {
                  Future.delayed(const Duration(milliseconds: 300), () {
                    _showToast(context, '팀원 초대 기능');
                  });
                },
              ),
              PopupMenuItem(
                value: 'report',
                child: const Text('신고하기'),
                onTap: () {
                  Future.delayed(const Duration(milliseconds: 300), () {
                    _showToast(context, '이 팀을 신고했습니다');
                  });
                },
              ),
              PopupMenuItem(
                value: 'exit',
                child: const Text('팀 나가기', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Future.delayed(const Duration(milliseconds: 300), () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('팀 나가기'),
                        content: Text('${widget.teamName} 팀을 나가시겠습니까?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('취소'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pop(context, true);
                              _showToast(context, '팀에서 나갔습니다');
                            },
                            child: const Text('나가기',
                                style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  });
                },
              ),
            ],
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 검색바 (조건부 표시)
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
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final message = _searchResults[index];
                      return TeamMessageBubble(
                        message: message.text,
                        isMe: message.isMe,
                        time: message.time,
                        sender: message.sender,
                        avatar: message.avatar,
                        userImage: message.userImage,
                      );
                    },
                  )
                : ListView.builder(
                    reverse: true,
                    controller: _scrollController,
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return TeamMessageBubble(
                        message: message.text,
                        isMe: message.isMe,
                        time: message.time,
                        sender: message.sender,
                        avatar: message.avatar,
                        userImage: message.userImage,
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  // 기능 버튼 그룹 - 좌측
                  Row(
                    children: [
                      // 첨부파일 아이콘
                      IconButton(
                        icon: const Icon(Icons.attach_file, color: Colors.grey),
                        iconSize: 22,
                        onPressed: () {
                          _showAttachmentMenu(context);
                        },
                      ),
                      // 카메라 아이콘
                      IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.grey),
                        iconSize: 22,
                        onPressed: () {
                          _openCamera(context);
                        },
                      ),
                      // AI 아이콘
                      IconButton(
                        icon:
                            const Icon(Icons.auto_awesome, color: Colors.blue),
                        iconSize: 22,
                        onPressed: () {
                          _showAIMenu(context);
                        },
                      ),
                    ],
                  ),
                  // 구분선
                  Container(
                    width: 1,
                    height: 28,
                    color: Colors.grey[300],
                  ),
                  // 입력란
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: '메시지를 입력하세요',
                        filled: false,
                        fillColor: Colors.transparent,
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                      onSubmitted: _handleSubmitted,
                    ),
                  ),
                  // 전송 버튼
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.blue),
                    iconSize: 22,
                    onPressed: () => _handleSubmitted(_messageController.text),
                  ),
                ],
              ),
            ),
          ),
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
                        _showToast(context, '사진을 선택했습니다');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.folder, color: Colors.orange),
                      title: const Text('파일'),
                      onTap: () {
                        Navigator.pop(context);
                        _showToast(context, '파일을 선택했습니다');
                      },
                    ),
                    ListTile(
                      leading:
                          const Icon(Icons.music_note, color: Colors.purple),
                      title: const Text('음성 메모'),
                      onTap: () {
                        Navigator.pop(context);
                        _showToast(context, '음성 메모를 녹음하고 있습니다');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.location_on, color: Colors.red),
                      title: const Text('위치'),
                      onTap: () {
                        Navigator.pop(context);
                        _showToast(context, '위치를 공유했습니다');
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

  @override
  void dispose() {
    _messageController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String text;
  final bool isMe;
  final DateTime time;
  final String sender;
  final String avatar;
  final String? userImage;

  ChatMessage({
    required this.text,
    required this.isMe,
    required this.time,
    required this.sender,
    required this.avatar,
    this.userImage,
  });
}

class TeamMessageBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final DateTime time;
  final String sender;
  final String avatar;
  final String? userImage;

  const TeamMessageBubble({
    Key? key,
    required this.message,
    required this.isMe,
    required this.time,
    required this.sender,
    required this.avatar,
    this.userImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
                image: userImage != null
                    ? DecorationImage(
                        image: NetworkImage(userImage!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: userImage == null
                  ? Center(
                      child: Text(
                        avatar,
                        style: const TextStyle(fontSize: 16),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
          ],
          Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (!isMe) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    sender,
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
                  if (isMe) ...[
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Text(
                        '${time.hour}:${time.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blue : Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      message,
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  if (!isMe) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(
                        '${time.hour}:${time.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          if (isMe) const SizedBox(width: 24),
        ],
      ),
    );
  }
}
