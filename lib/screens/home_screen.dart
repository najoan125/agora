import 'package:flutter/material.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
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
          '홈',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: '친구'),
            Tab(text: '팀원'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFriendsList(),
          _buildTeamList(),
        ],
      ),
    );
  }

  Widget _buildFriendsList() {
    final friends = [
      {'name': '김철수', 'status': '온라인', 'avatar': '👨'},
      {'name': '이영희', 'status': '온라인', 'avatar': '👩'},
      {'name': '박민준', 'status': '자리비움', 'avatar': '👨'},
      {'name': '최수진', 'status': '오프라인', 'avatar': '👩'},
      {'name': '정준호', 'status': '온라인', 'avatar': '👨'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: friends.length,
      itemBuilder: (context, index) {
        final friend = friends[index];
        return _buildFriendTile(
          name: friend['name'] as String,
          status: friend['status'] as String,
          avatar: friend['avatar'] as String,
        );
      },
    );
  }

  Widget _buildTeamList() {
    final teams = [
      {'name': '개발팀', 'member': '5명', 'icon': '👥'},
      {'name': '마케팅팀', 'member': '3명', 'icon': '📊'},
      {'name': '디자인팀', 'member': '4명', 'icon': '🎨'},
      {'name': '기획팀', 'member': '2명', 'icon': '📋'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: teams.length,
      itemBuilder: (context, index) {
        final team = teams[index];
        return _buildTeamTile(
          name: team['name'] as String,
          member: team['member'] as String,
          icon: team['icon'] as String,
        );
      },
    );
  }

  Widget _buildFriendTile({
    required String name,
    required String status,
    required String avatar,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Stack(
        children: [
          Container(
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
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: status == '온라인'
                    ? Colors.green
                    : status == '자리비움'
                        ? Colors.orange
                        : Colors.grey,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        ],
      ),
      title: Text(
        name,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        status,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileScreen(
              userName: name,
              userImage: 'https://i.pravatar.cc/150?u=$name',
              status: status,
            ),
          ),
        );
      },
    );
  }

  Widget _buildTeamTile({
    required String name,
    required String member,
    required String icon,
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
      title: Text(
        name,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        member,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {},
    );
  }
}
