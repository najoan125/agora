import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'add_friend_screen.dart';
import 'team_detail_screen.dart';
import 'team_chat_screen.dart';
import 'add_team_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _friends = [];
  List<Map<String, dynamic>> _blockedFriends = [];
  List<Map<String, dynamic>> _teamMembers = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleFavorite(int index) {
    setState(() {
      _friends[index]['isFavorite'] = !(_friends[index]['isFavorite'] as bool);
    });
  }

  void _blockFriend(int index) {
    final friend = _friends[index];
    setState(() {
      _blockedFriends.add(friend);
      _friends.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${friend['name']}님을(를) 차단했습니다'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _unblockFriend(int index) {
    final friend = _blockedFriends[index];
    setState(() {
      friend['isFavorite'] = false;
      _friends.add(friend);
      _blockedFriends.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${friend['name']}님을(를) 차단 해제했습니다'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '홈',
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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddFriendScreen(
                    onFriendAdded: (friend) {
                      setState(() {
                        if (!_friends
                            .any((f) => f['phone'] == friend['phone'])) {
                          _friends.add({
                            ...friend,
                            'statusMessage': '상태메세지를 입력해주세요',
                            'isFavorite': false,
                          });
                        }
                      });
                    },
                  ),
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: '친구'),
            Tab(text: '팀원'),
            Tab(text: '차단'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFriendsList(),
          _buildTeamList(),
          _buildBlockedFriendsList(),
        ],
      ),
    );
  }

  Widget _buildFriendsList() {
    if (_friends.isEmpty) {
      return Column(
        children: [
          // 내 프로필 카드
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade100, Colors.cyan.shade100],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Text('🧑', style: TextStyle(fontSize: 36)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'OOO 프로필',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '상세메세지',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline,
                      size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 20),
                  Text(
                    '친구를 추가해보세요',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddFriendScreen(
                            onFriendAdded: (friend) {
                              setState(() {
                                if (!_friends.any(
                                    (f) => f['phone'] == friend['phone'])) {
                                  _friends.add({
                                    ...friend,
                                    'statusMessage': '상태메세지를 입력해주세요',
                                    'isFavorite': false,
                                  });
                                }
                              });
                            },
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('친구 추가'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12),
                      backgroundColor: Colors.blue.shade400,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    final filteredFriends = _searchQuery.isEmpty
        ? _friends
        : _friends
            .where((friend) => friend['name']!
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()))
            .toList();

    // 친구를 카테고리별로 분류
    final favoriteFriends = filteredFriends
        .where((f) => f['isFavorite'] as bool? ?? false)
        .toList();
    final birthdayFriends = filteredFriends
        .where((f) =>
            (f['isBirthday'] as bool? ?? false) &&
            !(f['isFavorite'] as bool? ?? false))
        .toList();
    final otherFriends = filteredFriends
        .where((f) =>
            !(f['isFavorite'] as bool? ?? false) &&
            !(f['isBirthday'] as bool? ?? false))
        .toList();

    return Column(
      children: [
        // 내 프로필 카드
        Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade100, Colors.cyan.shade100],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Text('🧑', style: TextStyle(fontSize: 36)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'OOO 프로필',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '상태메세지',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // 검색창
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: '친구 검색',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                      child: const Icon(Icons.clear),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
        ),
        // 친구 목록
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              // 즐겨찾기 친구
              if (favoriteFriends.isNotEmpty) ...[
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Icon(Icons.star, size: 18, color: Colors.amber),
                      const SizedBox(width: 8),
                      Text(
                        '즐겨찾기',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                ...favoriteFriends.asMap().entries.map((entry) {
                  final index = _friends.indexOf(entry.value);
                  final friend = entry.value;
                  final isFavorite = friend['isFavorite'] as bool? ?? false;
                  return _buildFriendTile(
                    index: index,
                    name: friend['name'] ?? '알 수 없음',
                    statusMessage: friend['statusMessage'] ?? '상태메세지를 입력해주세요',
                    avatar: friend['avatar'] ?? '👤',
                    isFavorite: isFavorite,
                  );
                }),
              ],
              // 생일인 친구
              if (birthdayFriends.isNotEmpty) ...[
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Icon(Icons.cake, size: 18, color: Colors.pink),
                      const SizedBox(width: 8),
                      Text(
                        '생일',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                ...birthdayFriends.asMap().entries.map((entry) {
                  final index = _friends.indexOf(entry.value);
                  final friend = entry.value;
                  final isFavorite = friend['isFavorite'] as bool? ?? false;
                  return _buildFriendTile(
                    index: index,
                    name: friend['name'] ?? '알 수 없음',
                    statusMessage: friend['statusMessage'] ?? '상태메세지를 입력해주세요',
                    avatar: friend['avatar'] ?? '👤',
                    isFavorite: isFavorite,
                  );
                }),
              ],
              // 일반 친구
              if (otherFriends.isNotEmpty) ...[
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text(
                    '친구',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ),
                ...otherFriends.asMap().entries.map((entry) {
                  final index = _friends.indexOf(entry.value);
                  final friend = entry.value;
                  final isFavorite = friend['isFavorite'] as bool? ?? false;
                  return _buildFriendTile(
                    index: index,
                    name: friend['name'] ?? '알 수 없음',
                    statusMessage: friend['statusMessage'] ?? '상태메세지를 입력해주세요',
                    avatar: friend['avatar'] ?? '👤',
                    isFavorite: isFavorite,
                  );
                }),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTeamList() {
    final teams = [
      {
        'name': '개발팀',
        'member': '5명',
        'icon': '👨‍💻',
        'members': ['김철수', '이순신', '박준호', '정재훈', '최동욱']
      },
      {
        'name': '마케팅팀',
        'member': '3명',
        'icon': '📊',
        'members': ['이영희', '최수진', '홍명희']
      },
      {
        'name': '디자인팀',
        'member': '4명',
        'icon': '🎨',
        'members': ['장예은', '유미영', '조은희', '김지은']
      },
      {
        'name': '기획팀',
        'member': '2명',
        'icon': '📋',
        'members': ['박민준', '정준호']
      },
    ];

    return Column(
      children: [
        // 내 프로필 카드
        Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade100, Colors.cyan.shade100],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Text('🧑', style: TextStyle(fontSize: 36)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'OOO 프로필',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '상세메세지',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // 팀원 목록
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              // 팀 추가 버튼
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddTeamScreen(
                          onTeamAdded: (team) {
                            setState(() {
                              // 팀 추가 로직
                              _teamMembers.add({
                                'name': team['name'],
                                'member': team['member'],
                                'icon': team['icon'],
                                'members': team['members'],
                              });
                            });
                          },
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('팀 추가'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade400,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              // 팀 목록
              ...teams.map((team) {
                return _buildTeamTile(
                  name: team['name'] as String,
                  member: team['member'] as String,
                  icon: team['icon'] as String,
                  members: team['members'] as List<String>,
                );
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFriendTile({
    required int index,
    required String name,
    required String statusMessage,
    required String avatar,
    required bool isFavorite,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
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
        title: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          statusMessage,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: PopupMenuButton<int>(
          itemBuilder: (context) => [
            PopupMenuItem<int>(
              value: 1,
              child: Row(
                children: [
                  Icon(
                    isFavorite ? Icons.star : Icons.star_outline,
                    size: 18,
                    color: isFavorite ? Colors.amber : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(isFavorite ? '즐겨찾기 제거' : '즐겨찾기 추가'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem<int>(
              value: 2,
              child: const Row(
                children: [
                  Icon(Icons.block, size: 18, color: Colors.red),
                  SizedBox(width: 8),
                  Text('차단'),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 1) {
              _toggleFavorite(index);
            } else if (value == 2) {
              _blockFriend(index);
            }
          },
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfileScreen(
                userName: name,
                userImage: 'https://i.pravatar.cc/150?u=$name',
                status: statusMessage,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTeamTile({
    required String name,
    required String member,
    required String icon,
    required List<String> members,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade100, Colors.purple.shade100],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(icon, style: const TextStyle(fontSize: 32)),
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              member,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              children: members.take(3).map((memberName) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    memberName,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.blue.shade700,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TeamDetailScreen(
                teamName: name,
                teamIcon: icon,
                members: members,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBlockedFriendsList() {
    if (_blockedFriends.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.block_outlined, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 20),
            Text(
              '차단한 친구가 없습니다',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _blockedFriends.length,
      itemBuilder: (context, index) {
        final friend = _blockedFriends[index];
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(friend['avatar'] ?? '👤',
                    style: const TextStyle(fontSize: 28)),
              ),
            ),
            title: Text(
              friend['name'] ?? '알 수 없음',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            subtitle: Text(
              friend['statusMessage'] ?? '상태메세지를 입력해주세요',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade400,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
              onPressed: () => _unblockFriend(index),
              child: const Text(
                '차단 해제',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ),
        );
      },
    );
  }
}
