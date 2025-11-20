import 'package:flutter/material.dart';

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
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final List<ChatMessage> _messages = [];
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
          ));
    });

    // 자동 응답 예시
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _messages.insert(
            0,
            ChatMessage(
              text: "자동 응답",
              isMe: false,
              time: DateTime.now(),
            ));
      });
    });
  }

  void _searchMessages(String query) {
    setState(() {
      if (query.isEmpty) {
        _searchResults = [];
      } else {
        _searchResults = _messages
            .where((msg) =>
            msg.text.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserProfileScreen(
                  userName: widget.userName,
                  userImage: widget.userImage,
                  isTeam: widget.isTeam,
                ),
              ),
            );
          },
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(widget.userImage),
                radius: 20,
              ),
              const SizedBox(width: 10),
              Text(
                widget.userName,
                style: const TextStyle(color: Colors.black, fontSize: 16),
              ),
            ],
          ),
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
          // 설정 아이콘 (3개 점)
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
                      // 내 프로필 섹션
                      const Text(
                        '내 프로필',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundImage: const NetworkImage(
                              'https://i.pravatar.cc/150?u=me',
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text('내 이름'),
                        ],
                      ),
                      const Divider(height: 24),
                      // 상대방 프로필 섹션
                      const Text(
                        '대화 상대',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundImage: NetworkImage(widget.userImage),
                          ),
                          const SizedBox(width: 12),
                          Text(widget.userName),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'invite',
                child: const Text('친구 초대'),
                onTap: () {
                  Future.delayed(const Duration(milliseconds: 300), () {
                    _showInviteFriendToChat(context);
                  });
                },
              ),
              if (widget.isTeam)
                PopupMenuItem(
                  value: 'invite_group',
                  child: const Text('그룹 초대'),
                  onTap: () {
                    Future.delayed(const Duration(milliseconds: 300), () {
                      _showInviteFriendDialog(context);
                    });
                  },
                ),
              PopupMenuItem(
                value: 'report',
                child: const Text('신고하기'),
                onTap: () {
                  Future.delayed(const Duration(milliseconds: 300), () {
                    _showToast(context, '${widget.userName}을(를) 신고했습니다');
                  });
                },
              ),
              PopupMenuItem(
                value: 'block',
                child: const Text('차단하기'),
                onTap: () {
                  Future.delayed(const Duration(milliseconds: 300), () {
                    _showToast(context, '${widget.userName}을(를) 차단했습니다');
                  });
                },
              ),
              PopupMenuItem(
                value: 'exit',
                child: const Text('채팅방 나가기',
                    style: TextStyle(color: Colors.red)),
                onTap: () {
                  Future.delayed(const Duration(milliseconds: 300), () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('채팅방 나가기'),
                        content:
                        Text('${widget.userName}과의 채팅방을 나가시겠습니까?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('취소'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pop(context, true);
                              _showToast(context, '채팅방에서 나갔습니다');
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
                return MessageBubble(
                  message: message.text,
                  isMe: message.isMe,
                  time: message.time,
                );
              },
            )
                : ListView.builder(
              reverse: true,
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return MessageBubble(
                  message: message.text,
                  isMe: message.isMe,
                  time: message.time,
                );
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border(
                top: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Row(
              children: [
                // 첨부파일 아이콘
                IconButton(
                  icon: const Icon(Icons.attach_file, color: Colors.grey),
                  onPressed: () {
                    _showAttachmentMenu(context);
                  },
                ),
                // 카메라 아이콘
                IconButton(
                  icon: const Icon(Icons.camera_alt, color: Colors.grey),
                  onPressed: () {
                    _openCamera(context);
                  },
                ),
                // AI 아이콘
                IconButton(
                  icon: const Icon(Icons.auto_awesome, color: Colors.blue),
                  onPressed: () {
                    _showAIMenu(context);
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: '메시지를 입력하세요',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onSubmitted: _handleSubmitted,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: () => _handleSubmitted(_messageController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  void _showInviteFriendDialog(BuildContext context) {
    final friends = ['김철수', '이영희', '박민준', '최수진', '정준호'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('친구 초대'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: friends.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(friends[index]),
              onTap: () {
                Navigator.pop(context);
                _showToast(context, '${friends[index]}를 초대했습니다');
              },
            ),
          ),
        ),
      ),
    );
  }

  void _showInviteFriendToChat(BuildContext context) {
    final friends = ['김철수', '이영희', '박민준', '최수진', '정준호'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('새로운 대화상대 추가'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: friends.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(friends[index]),
              onTap: () {
                Navigator.pop(context);
                _showToast(context, '${friends[index]}를 추가했습니다');
              },
            ),
          ),
        ),
      ),
    );
  }

  void _showAttachmentMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: 200,
        padding: const EdgeInsets.symmetric(vertical: 16),
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
              leading: const Icon(Icons.music_note, color: Colors.purple),
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
        height: 250,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'AI 기능',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.lightbulb, color: Colors.yellow),
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

  ChatMessage({
    required this.text,
    required this.isMe,
    required this.time,
  });
}

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final DateTime time;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isMe,
    required this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment:
        isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 8),
          ],
          Column(
            crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isMe ? Colors.blue : Colors.grey[300],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  message,
                  style: TextStyle(
                    color: isMe ? Colors.white : Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${time.hour}:${time.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          if (isMe) const SizedBox(width: 24),
        ],
      ),
    );
  }
}

class UserProfileScreen extends StatelessWidget {
  final String userName;
  final String userImage;
  final bool isTeam;

  const UserProfileScreen({
    Key? key,
    required this.userName,
    required this.userImage,
    this.isTeam = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 32),
          Center(
            child: CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(userImage),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            userName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (isTeam)
            const Text(
              '팀 정보',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            )
          else
            const Text(
              '온라인',
              style: TextStyle(fontSize: 14, color: Colors.green),
            ),
          const SizedBox(height: 32),
          ListTile(
            leading: const Icon(Icons.block),
            title: const Text('차단하기'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${userName}을(를) 차단했습니다')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.report),
            title: const Text('신고하기'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${userName}을(를) 신고했습니다')),
              );
            },
          ),
        ],
      ),
    );
  }
}