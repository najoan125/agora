// 그룹 채팅 대화 화면
import 'package:flutter/material.dart';
import '../../../core/theme.dart';

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
  List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();

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
      ),
      ChatMessage(
        text: '오늘 모임 시간 확정됐나요?',
        isMe: false,
        time: DateTime.now().subtract(const Duration(minutes: 25)),
        sender: members[1 % members.length],
      ),
      ChatMessage(
        text: '오후 3시로 정했어요!',
        isMe: false,
        time: DateTime.now().subtract(const Duration(minutes: 20)),
        sender: members[2 % members.length],
      ),
    ];
  }

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
        ),
      );
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
              ),
            );
          });
        }
      });
    }
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
              // 검색 기능 구현
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
                    // Member List
                    SizedBox(
                      height: 150, // Limit height for member list
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          // Me
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(12),
                                    image: const DecorationImage(
                                      image: NetworkImage(
                                          'https://picsum.photos/id/1005/200/200'), // My image
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  '나',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Other Members
                          ...widget.members.map((member) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(12),
                                        image: DecorationImage(
                                          image: NetworkImage(
                                            'https://picsum.photos/seed/${member.hashCode}/200/200',
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      member,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        _showInviteDialog(context);
                      },
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: const Icon(Icons.add, color: Colors.grey),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            '대화상대 초대',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppTheme.textSecondary,
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
          Expanded(
            child: ListView.builder(
              reverse: true,
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return GroupMessageBubble(
                  message: message.text,
                  isMe: message.isMe,
                  time: message.time,
                  sender: message.sender,
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

  void _showInviteDialog(BuildContext context) {
    final friends = [
      {'name': '김철수', 'image': 'https://picsum.photos/id/1011/200/200'},
      {'name': '이영희', 'image': 'https://picsum.photos/id/1027/200/200'},
      {'name': '박지성', 'image': 'https://picsum.photos/id/1005/200/200'},
      {'name': '최민호', 'image': 'https://picsum.photos/id/1012/200/200'},
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('대화상대 초대'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: friends.length,
            itemBuilder: (context, index) {
              final friend = friends[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(friend['image']!),
                ),
                title: Text(friend['name']!),
                trailing: Checkbox(
                  value: false,
                  onChanged: (value) {},
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showToast(context, '초대 메시지를 보냈습니다');
            },
            child: const Text('초대'),
          ),
        ],
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
        child: Row(
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
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String text;
  final bool isMe;
  final DateTime time;
  final String sender;

  ChatMessage({
    required this.text,
    required this.isMe,
    required this.time,
    required this.sender,
  });
}

class GroupMessageBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final DateTime time;
  final String sender;

  const GroupMessageBubble({
    Key? key,
    required this.message,
    required this.isMe,
    required this.time,
    required this.sender,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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
                image: DecorationImage(
                  image: NetworkImage(
                    'https://picsum.photos/seed/${sender.hashCode.abs()}/200/200',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
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
                          color: AppTheme.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isMe
                          ? const Color(0xFF0095F6)
                          : const Color(
                              0xFFF0F0F0), // Solid blue for me, light grey for others
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft: Radius.circular(isMe ? 20 : 4),
                        bottomRight: Radius.circular(isMe ? 4 : 20),
                      ),
                    ),
                    child: Text(
                      message,
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.black,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  if (!isMe) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(
                        '${time.hour}:${time.minute.toString().padLeft(2, '0')}',
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
