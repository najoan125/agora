import 'package:flutter/material.dart';

class ConversationScreen extends StatefulWidget {
  final String userName;
  final String userImage;

  const ConversationScreen({
    Key? key,
    required this.userName,
    required this.userImage,
  }) : super(key: key);

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: GestureDetector(
          onTap: () {
            // 프로필 상세 페이지로 이동
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserProfileScreen(
                  userName: widget.userName,
                  userImage: widget.userImage,
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
              Text(widget.userName),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // 추가 메뉴 표시
              showModalBottomSheet(
                context: context,
                builder: (context) => Container(
                  height: 200,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.block),
                        title: const Text('차단하기'),
                        onTap: () {
                          Navigator.pop(context);
                          // 차단 로직 구현
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.report),
                        title: const Text('신고하기'),
                        onTap: () {
                          Navigator.pop(context);
                          // 신고 로직 구현
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
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
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () {
                    // 첨부 파일 메뉴 표시
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => Container(
                        height: 150,
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.photo),
                              title: const Text('사진 선택'),
                              onTap: () {
                                Navigator.pop(context);
                                // 사진 선택 로직 구현
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.camera_alt),
                              title: const Text('카메라'),
                              onTap: () {
                                Navigator.pop(context);
                                // 카메라 실행 로직 구현
                              },
                            ),
                          ],
                        ),
                      ),
                    );
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
                  icon: const Icon(Icons.send),
                  onPressed: () => _handleSubmitted(_messageController.text),
                ),
              ],
            ),
          ),
        ],
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

  const UserProfileScreen({
    Key? key,
    required this.userName,
    required this.userImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필'),
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
          const SizedBox(height: 32),
          ListTile(
            leading: const Icon(Icons.block),
            title: const Text('차단하기'),
            onTap: () {
              // 차단 로직 구현
            },
          ),
          ListTile(
            leading: const Icon(Icons.report),
            title: const Text('신고하기'),
            onTap: () {
              // 신고 로직 구현
            },
          ),
        ],
      ),
    );
  }
}
