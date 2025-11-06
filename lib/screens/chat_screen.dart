import 'package:flutter/material.dart';
import 'conversation_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  final List<String> _recentSearches = [];

  // 동적 채팅 목록
  late List<Map<String, dynamic>> _friendChats;
  late List<Map<String, dynamic>> _teamChats;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // 초기 채팅 목록
    _friendChats = [
      {
        'name': '김진규',
        'message': '내일 회의 시간이 바뀌었어',
        'time': '방금',
        'avatar': '👨',
        'unread': 2,
        'image': 'https://i.pravatar.cc/150?u=김진규',
      },
      {
        'name': '이영희',
        'message': '프로젝트 파일 올렸습니다',
        'time': '1시간 전',
        'avatar': '👩',
        'unread': 0,
        'image': 'https://i.pravatar.cc/150?u=이영희',
      },
      {
        'name': '박민준',
        'message': '좋은 아이디어 감사합니다!',
        'time': '어제',
        'avatar': '👨',
        'unread': 0,
        'image': 'https://i.pravatar.cc/150?u=박민준',
      },
      {
        'name': '최수진',
        'message': '다음 주 일정 확인했어요',
        'time': '2일 전',
        'avatar': '👩',
        'unread': 0,
        'image': 'https://i.pravatar.cc/150?u=최수진',
      },
      {
        'name': '정준호',
        'message': '코드 리뷰 완료했습니다',
        'time': '3일 전',
        'avatar': '👨',
        'unread': 1,
        'image': 'https://i.pravatar.cc/150?u=정준호',
      },
    ];

    _teamChats = [
      {
        'name': '개발팀',
        'message': '김철수: 이번 주 스프린트 종료합니다',
        'time': '방금',
        'icon': '👥',
        'unread': 5,
        'image': 'https://i.pravatar.cc/150?u=개발팀',
      },
      {
        'name': '마케팅팀',
        'message': '이영희: 캠페인 결과 보고서 올렸습니다',
        'time': '1시간 전',
        'icon': '📊',
        'unread': 0,
        'image': 'https://i.pravatar.cc/150?u=마케팅팀',
      },
      {
        'name': '디자인팀',
        'message': '박민준: 새로운 디자인 안 공유합니다',
        'time': '2시간 전',
        'icon': '🎨',
        'unread': 3,
        'image': 'https://i.pravatar.cc/150?u=디자인팀',
      },
      {
        'name': '기획팀',
        'message': '최수진: 이번 분기 전략 회의 예정',
        'time': '어제',
        'icon': '📋',
        'unread': 0,
        'image': 'https://i.pravatar.cc/150?u=기획팀',
      },
    ];
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
          // 플러스 아이콘 - 새 채팅 생성
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.blue),
            onPressed: () {
              _showNewChatDialog(context);
            },
          ),
          // 설정 아이콘
          PopupMenuButton<String>(
            icon: const Icon(Icons.settings, color: Colors.black),
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'sort_name',
                child: const Text('이름순 정렬'),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('이름순으로 정렬했습니다')),
                  );
                },
              ),
              PopupMenuItem(
                value: 'sort_time',
                child: const Text('최근순 정렬'),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('최근순으로 정렬했습니다')),
                  );
                },
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'settings',
                child: const Text('전체 설정'),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('설정 페이지로 이동합니다')),
                  );
                },
              ),
            ],
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
      body: Column(
        children: [
          // 검색바
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: '검색...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  // 검색어 입력 시 최근 검색어에 추가
                  if (value.isNotEmpty && !_recentSearches.contains(value)) {
                    _recentSearches.insert(0, value);
                    if (_recentSearches.length > 5) {
                      _recentSearches.removeLast();
                    }
                  }
                });
              },
            ),
          ),
          // 최근 검색어 표시 (검색 결과가 없을 때)
          if (_searchQuery.isEmpty && _recentSearches.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '최근 검색어',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _recentSearches
                        .map((search) => GestureDetector(
                              onTap: () {
                                setState(() {
                                  _searchQuery = search;
                                });
                              },
                              child: Chip(
                                label: Text(search),
                                onDeleted: () {
                                  setState(() {
                                    _recentSearches.remove(search);
                                  });
                                },
                              ),
                            ))
                        .toList(),
                  ),
                  const Divider(),
                ],
              ),
            ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFriendChatList(),
                _buildTeamChatList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendChatList() {
    final filteredChats = _searchQuery.isEmpty
        ? _friendChats
        : _friendChats
            .where((chat) =>
                (chat['name'] as String).contains(_searchQuery) ||
                (chat['message'] as String).contains(_searchQuery))
            .toList();

    return filteredChats.isEmpty
        ? Center(
            child: Text(_searchQuery.isEmpty
                ? '채팅 목록이 없습니다'
                : '검색 결과가 없습니다'),
          )
        : ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: filteredChats.length,
            itemBuilder: (context, index) {
              final chat = filteredChats[index];
              return _buildChatTile(
                name: chat['name'] as String,
                message: chat['message'] as String,
                time: chat['time'] as String,
                avatar: chat['avatar'] as String,
                unread: chat['unread'] as int,
                userImage: chat['image'] as String,
                isTeam: false,
                onExit: () {
                  setState(() {
                    _friendChats.removeWhere((c) => c['name'] == chat['name']);
                  });
                },
              );
            },
          );
  }

  Widget _buildTeamChatList() {
    final filteredChats = _searchQuery.isEmpty
        ? _teamChats
        : _teamChats
            .where((chat) =>
                (chat['name'] as String).contains(_searchQuery) ||
                (chat['message'] as String).contains(_searchQuery))
            .toList();

    return filteredChats.isEmpty
        ? Center(
            child: Text(_searchQuery.isEmpty
                ? '채팅 목록이 없습니다'
                : '검색 결과가 없습니다'),
          )
        : ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: filteredChats.length,
            itemBuilder: (context, index) {
              final chat = filteredChats[index];
              return _buildTeamChatTile(
                name: chat['name'] as String,
                message: chat['message'] as String,
                time: chat['time'] as String,
                icon: chat['icon'] as String,
                unread: chat['unread'] as int,
                userImage: chat['image'] as String,
                onExit: () {
                  setState(() {
                    _teamChats.removeWhere((c) => c['name'] == chat['name']);
                  });
                },
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
    required String userImage,
    required bool isTeam,
    required Function() onExit,
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
          child: CircleAvatar(
            backgroundImage: NetworkImage(userImage),
            radius: 25,
          ),
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
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConversationScreen(
              userName: name,
              userImage: userImage,
              isTeam: isTeam,
            ),
          ),
        ).then((result) {
          if (result == true) {
            onExit();
          }
        });
      },
    );
  }

  Widget _buildTeamChatTile({
    required String name,
    required String message,
    required String time,
    required String icon,
    required int unread,
    required String userImage,
    required Function() onExit,
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
          child: CircleAvatar(
            backgroundImage: NetworkImage(userImage),
            radius: 25,
          ),
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
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConversationScreen(
              userName: name,
              userImage: userImage,
              isTeam: true,
            ),
          ),
        ).then((result) {
          if (result == true) {
            onExit();
          }
        });
      },
    );
  }

  void _showNewChatDialog(BuildContext context) {
    final friends = [
      {'name': '김진규', 'avatar': '👨', 'image': 'https://i.pravatar.cc/150?u=김진규'},
      {'name': '이영희', 'avatar': '👩', 'image': 'https://i.pravatar.cc/150?u=이영희'},
      {'name': '박민준', 'avatar': '👨', 'image': 'https://i.pravatar.cc/150?u=박민준'},
      {'name': '최수진', 'avatar': '👩', 'image': 'https://i.pravatar.cc/150?u=최수진'},
      {'name': '정준호', 'avatar': '👨', 'image': 'https://i.pravatar.cc/150?u=정준호'},
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('새 채팅 시작'),
        content: friends.isEmpty
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text('채팅방을 만들 친구가 없습니다'),
              )
            : SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: friends.length,
                  itemBuilder: (context, index) {
                    final friend = friends[index];
                    return ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(friend['avatar'] as String,
                              style: const TextStyle(fontSize: 20)),
                        ),
                      ),
                      title: Text(friend['name'] as String),
                      onTap: () {
                        Navigator.pop(context);
                        // 새 채팅을 목록에 추가
                        final newChat = {
                          'name': friend['name'],
                          'message': '새로운 채팅',
                          'time': '방금',
                          'avatar': friend['avatar'],
                          'unread': 0,
                          'image': friend['image'],
                        };

                        // 이미 존재하는지 확인
                        final exists = _friendChats.any((c) => c['name'] == newChat['name']);
                        if (!exists) {
                          setState(() {
                            _friendChats.insert(0, newChat);
                          });
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ConversationScreen(
                              userName: friend['name'] as String,
                              userImage: friend['image'] as String,
                              isTeam: false,
                            ),
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                '${friend['name']}과의 새 채팅이 시작되었습니다'),
                            behavior: SnackBarBehavior.floating,
                            margin: const EdgeInsets.only(bottom: 100, left: 16, right: 16),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
        ],
      ),
    );
  }
}
