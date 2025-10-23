import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '채팅',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.blue),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: '친구'),
            Tab(text: '팀'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFriendChatList(),
          _buildTeamChatList(),
        ],
      ),
    );
  }

  Widget _buildFriendChatList() {
    final chats = [
      {
        'name': '김철수',
        'message': '내일 회의 시간이 바뀌었어',
        'time': '방금',
        'avatar': '👨',
        'unread': 2,
      },
      {
        'name': '이영희',
        'message': '프로젝트 파일 올렸습니다',
        'time': '1시간 전',
        'avatar': '👩',
        'unread': 0,
      },
      {
        'name': '박민준',
        'message': '좋은 아이디어 감사합니다!',
        'time': '어제',
        'avatar': '👨',
        'unread': 0,
      },
      {
        'name': '최수진',
        'message': '다음 주 일정 확인했어요',
        'time': '2일 전',
        'avatar': '👩',
        'unread': 0,
      },
      {
        'name': '정준호',
        'message': '코드 리뷰 완료했습니다',
        'time': '3일 전',
        'avatar': '👨',
        'unread': 1,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: chats.length,
      itemBuilder: (context, index) {
        final chat = chats[index];
        return _buildChatTile(
          name: chat['name'] as String,
          message: chat['message'] as String,
          time: chat['time'] as String,
          avatar: chat['avatar'] as String,
          unread: chat['unread'] as int,
        );
      },
    );
  }

  Widget _buildTeamChatList() {
    final chats = [
      {
        'name': '개발팀',
        'message': '김철수: 이번 주 스프린트 종료합니다',
        'time': '방금',
        'icon': '👥',
        'unread': 5,
      },
      {
        'name': '마케팅팀',
        'message': '이영희: 캠페인 결과 보고서 올렸습니다',
        'time': '1시간 전',
        'icon': '📊',
        'unread': 0,
      },
      {
        'name': '디자인팀',
        'message': '박민준: 새로운 디자인 안 공유합니다',
        'time': '2시간 전',
        'icon': '🎨',
        'unread': 3,
      },
      {
        'name': '기획팀',
        'message': '최수진: 이번 분기 전략 회의 예정',
        'time': '어제',
        'icon': '📋',
        'unread': 0,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: chats.length,
      itemBuilder: (context, index) {
        final chat = chats[index];
        return _buildTeamChatTile(
          name: chat['name'] as String,
          message: chat['message'] as String,
          time: chat['time'] as String,
          icon: chat['icon'] as String,
          unread: chat['unread'] as int,
        );
      },
    );
  }

  Widget _buildChatTile({
    required String name,
    required String message,
    required String time,
    required String avatar,
    required int unread,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(avatar, style: const TextStyle(fontSize: 28)),
        ),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
      subtitle: Text(
        message,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
        ),
      ),
      trailing: unread > 0
          ? Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  unread.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          : null,
      onTap: () {},
    );
  }

  Widget _buildTeamChatTile({
    required String name,
    required String message,
    required String time,
    required String icon,
    required int unread,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(icon, style: const TextStyle(fontSize: 28)),
        ),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
      subtitle: Text(
        message,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
        ),
      ),
      trailing: unread > 0
          ? Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  unread.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          : null,
      onTap: () {},
    );
  }
}
