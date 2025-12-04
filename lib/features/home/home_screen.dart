import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../data/data_manager.dart';
import '../../shared/providers/profile_provider.dart';
import '../friends/widgets/friend_tile.dart';
import '../friends/widgets/friend_request_tile.dart';
import '../../shared/widgets/collapsible_section.dart';
import '../chat/widgets/group_chat_tile.dart';
import '../profile/screens/profile_screen.dart';
import '../friends/screens/add_friend_screen.dart';
import '../teams/screens/team_detail_screen.dart';
import '../teams/screens/add_team_screen.dart';

import 'screens/notification_screen.dart';
import '../chat/screens/create_group_screen.dart';
import '../chat/screens/group_chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final DataManager _dataManager = DataManager();
  late TabController _tabController;
  late AnimationController _menuAnimationController;
  final FocusNode _searchFocusNode = FocusNode();
  String _sortOption = 'recent'; // 'recent' or 'name'
  String _searchQuery = '';
  bool _isMenuOpen = false;
  bool _isGroupChatExpanded = true;
  bool _isTeamListExpanded = true;

  // Group Chats list
  final List<Map<String, dynamic>> _groupChats = [
    {
      'name': '주말 등산',
      'image': 'https://picsum.photos/id/1036/200/200',
      'info': '이번 주 관악산?',
      'members': ['김철수', '이영희', '박민수']
    },
    {
      'name': '스터디 그룹',
      'image': 'https://picsum.photos/id/1010/200/200',
      'info': '오후 8시 줌 미팅',
      'members': ['최지은', '정우성', '한지민', '강동원']
    },
    {
      'name': '점심 팟',
      'image': 'https://picsum.photos/id/1080/200/200',
      'info': '오늘 메뉴는?',
      'members': ['김민지', '박서준']
    },
    {
      'name': '프로젝트 A',
      'image': 'https://picsum.photos/id/119/200/200',
      'info': '마감일 확인',
      'members': ['이준호', '송혜교', '현빈']
    },
    {
      'name': '영화 번개',
      'image': 'https://picsum.photos/id/1040/200/200',
      'info': '이번 주말 영화 보러 가실 분?',
      'members': ['박보검', '김유정']
    },
    {
      'name': '맛집 탐방',
      'image': 'https://picsum.photos/id/1060/200/200',
      'info': '강남역 맛집 추천 좀',
      'members': ['백종원', '성시경', '최자']
    },
    {
      'name': '독서 모임',
      'image': 'https://picsum.photos/id/1073/200/200',
      'info': '이번 달 도서 선정 투표',
      'members': ['김영하', '유시민']
    },
    {
      'name': '운동 인증',
      'image': 'https://picsum.photos/id/1025/200/200',
      'info': '오늘도 오운완!',
      'members': ['김종국', '비', '권상우']
    },
    {
      'name': '여행 계획',
      'image': 'https://picsum.photos/id/1015/200/200',
      'info': '제주도 비행기표 예매 완료',
      'members': ['나영석', '이서진']
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _menuAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _searchFocusNode.addListener(() {
      setState(() {});
    });
    _tabController.addListener(() {
      setState(() {}); // Rebuild to update AppBar icons when tab changes
    });
    
    // 프로필 정보 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
    });
  }

  Future<void> _loadProfile() async {
    final profileProvider = context.read<ProfileProvider>();
    await profileProvider.loadMyProfile();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _menuAnimationController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
      if (_isMenuOpen) {
        _menuAnimationController.forward();
      } else {
        _menuAnimationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            actions: [
              // Show person_add icon only on Friends tab (index 0)
              if (_tabController.index == 0)
                IconButton(
                  icon: const Icon(Icons.person_add_outlined,
                      color: AppTheme.textPrimary),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddFriendScreen(
                          onFriendAdded: (friend) {
                            setState(() {
                              _dataManager.addFriend(friend);
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
              // Show notification bell only on Team tab (index 1)
              if (_tabController.index == 1)
                IconButton(
                  icon: const Icon(Icons.notifications_outlined,
                      color: AppTheme.textPrimary),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const NotificationScreen()),
                    );
                  },
                ),
              IconButton(
                icon: AnimatedIcon(
                  icon: AnimatedIcons.menu_close,
                  progress: _menuAnimationController,
                  color: AppTheme.textPrimary,
                ),
                onPressed: _toggleMenu,
              ),
              const SizedBox(width: 16),
            ],
            bottom: TabBar(
              controller: _tabController,
              labelColor: AppTheme.textPrimary,
              unselectedLabelColor: AppTheme.textSecondary,
              indicatorColor: AppTheme.textPrimary,
              indicatorWeight: 2,
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              tabs: const [
                Tab(text: '친구'),
                Tab(text: '팀원'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildFriendsTab(),
              _buildTeamList(),
            ],
          ),
        ),
        if (_isMenuOpen)
          Positioned(
            top: 50,
            right: 20,
            child: Material(
              elevation: 16,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
              ),
              child: Container(
                width: 160,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildMenuItem('정렬하기', Icons.sort, () {
                      _toggleMenu();
                      _showSortDialog();
                    }),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('정렬'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('최신순'),
              onTap: () {
                setState(() {
                  _sortOption = 'recent';
                });
                Navigator.pop(context);
              },
              trailing: _sortOption == 'recent'
                  ? const Icon(Icons.check, color: Colors.blue)
                  : null,
            ),
            ListTile(
              leading: const Icon(Icons.sort_by_alpha),
              title: const Text('이름순'),
              onTap: () {
                setState(() {
                  _sortOption = 'name';
                });
                Navigator.pop(context);
              },
              trailing: _sortOption == 'name'
                  ? const Icon(Icons.check, color: Colors.blue)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppTheme.textPrimary),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendsTab() {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        // 프로필이 로드되지 않았으면 로딩 표시
        if (profileProvider.isLoading && profileProvider.myProfile == null) {
          return const Center(child: CircularProgressIndicator());
        }

        // 프로필 정보 가져오기 (없으면 기본값 사용)
        final profile = profileProvider.myProfile;
        final user = profile != null
            ? {
                'name': profile.displayName,
                'statusMessage': profile.statusMessage ?? '상태 메시지를 설정하세요',
                'image': profile.profileImageUrl,
                'avatar': profile.displayName.isNotEmpty ? profile.displayName[0] : '?',
              }
            : _dataManager.currentUser;

        final friends = _dataManager.friends;

        final filteredFriends = _searchQuery.isEmpty
            ? List<Map<String, dynamic>>.from(friends)
            : friends
                .where((f) =>
                    f['name'].toLowerCase().contains(_searchQuery.toLowerCase()))
                .toList();

        if (_sortOption == 'name') {
          filteredFriends
              .sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
        }
        // 'recent' option keeps the original order (assuming it's already sorted by recent or default)

        final favorites =
            filteredFriends.where((f) => f['isFavorite'] == true).toList();
        final birthdays =
            filteredFriends.where((f) => f['isBirthday'] == true).toList();
        final otherFriends = filteredFriends;
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _buildProfileHeader(user),
              ),
              SliverAppBar(
                backgroundColor: Colors.white,
                expandedHeight: 74.0, // Height of search bar + padding
                toolbarHeight: 74.0,
                collapsedHeight: 74.0,
                floating: true,
                snap: true,
                pinned: false,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.none,
                  background: _buildFloatingSearchBar(),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    // Recent & Related Searches - Removed
                    if (_searchFocusNode.hasFocus && _searchQuery.isEmpty)
                      const SizedBox.shrink(),

                    const SizedBox(height: 10),

                    // Group Chats with + icon and collapsible
                    Column(
                      children: [
                        const Divider(
                            height: 1, thickness: 1, color: Color(0xFFCCCCCC)),
                        InkWell(
                          onTap: () {
                            setState(() {
                              _isGroupChatExpanded = !_isGroupChatExpanded;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            child: Row(
                              children: [
                                const Text(
                                  '그룹채팅',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${_groupChats.length}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                const Spacer(),
                                const SizedBox(width: 8),
                                Icon(
                                  _isGroupChatExpanded
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  color: AppTheme.textSecondary,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_isGroupChatExpanded)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 12),
                            height: 120,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Create Group Button
                                  Padding(
                                    padding: const EdgeInsets.only(right: 20.0),
                                    child: GestureDetector(
                                      onTap: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const CreateGroupScreen(),
                                          ),
                                        );

                                        if (result != null &&
                                            result is Map<String, dynamic>) {
                                          setState(() {
                                            _groupChats.insert(0, result);
                                          });
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    '그룹 "${result['name']}" 생성 완료!')),
                                          );
                                        }
                                      },
                                      child: Column(
                                        children: [
                                          Container(
                                            width: 64,
                                            height: 64,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF5F5F5),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                  color: const Color(0xFFE0E0E0)),
                                            ),
                                            child: const Icon(
                                              Icons.add,
                                              color: AppTheme.textSecondary,
                                              size: 28,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          const Text(
                                            '그룹 생성',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: AppTheme.textPrimary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Existing Group Chats
                                  ..._groupChats
                                      .map((chat) => Padding(
                                            padding:
                                                const EdgeInsets.only(right: 20.0),
                                            child: GroupChatTile(
                                              name: chat['name']!,
                                              image: chat['image'],
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        GroupChatScreen(
                                                      groupName: chat['name']!,
                                                      groupImage: chat['image'],
                                                      members: List<String>.from(
                                                          chat['members'] ?? []),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ))
                                      .toList(),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),

                    // Favorites
                    if (favorites.isNotEmpty)
                      CollapsibleSection(
                        title: '즐겨찾기',
                        count: favorites.length,
                        child: Column(
                          children: favorites
                              .map((f) => FriendTile(
                                    friend: f,
                                    onTap: () => _navigateToProfile(f),
                                    onFavoriteToggle: () => setState(() =>
                                        _dataManager.toggleFavorite(f['name'])),
                                  ))
                              .toList(),
                        ),
                      ),

                    // Friend Requests
                    if (_dataManager.friendRequests.isNotEmpty)
                      CollapsibleSection(
                        title: '친구 요청',
                        count: _dataManager.friendRequests.length,
                        child: Column(
                          children: _dataManager.friendRequests
                              .asMap()
                              .entries
                              .map((entry) {
                            final index = entry.key;
                            final request = entry.value;
                            return FriendRequestTile(
                              request: request,
                              onAccept: () {
                                setState(() {
                                  _dataManager.acceptFriendRequest(index);
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('${request['name']}님을 친구로 추가했습니다')),
                                );
                              },
                              onDecline: () {
                                setState(() {
                                  _dataManager.removeFriendRequest(index);
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          '${request['name']}님의 친구 요청을 거절했습니다')),
                                );
                              },
                            );
                          }).toList(),
                        ),
                      ),

                    // Birthdays
                    if (birthdays.isNotEmpty)
                      CollapsibleSection(
                        title: '생일인 친구',
                        count: birthdays.length,
                        child: Column(
                          children: birthdays
                              .map((f) => FriendTile(
                                    friend: f,
                                    onTap: () => _navigateToProfile(f),
                                    onFavoriteToggle: () => setState(() =>
                                        _dataManager.toggleFavorite(f['name'])),
                                  ))
                              .toList(),
                        ),
                      ),

                    // Friends List
                    CollapsibleSection(
                      title: '친구 목록',
                      count: otherFriends.length,
                      child: Column(
                        children: otherFriends
                            .map((f) => FriendTile(
                                  friend: f,
                                  onTap: () => _navigateToProfile(f),
                                  onFavoriteToggle: () => setState(() =>
                                      _dataManager.toggleFavorite(f['name'])),
                                ))
                            .toList(),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  Widget _buildTeamList() {
    final user = _dataManager.currentUser;
    final teams = _dataManager.teams;
    
    final myTeams = teams.where((t) => (t['members'] as List).contains(user['name'])).toList();
    final otherTeams = teams.where((t) => !(t['members'] as List).contains(user['name'])).toList();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildProfileHeader(user),
          ),
          SliverAppBar(
            backgroundColor: Colors.white,
            expandedHeight: 74.0, // Height of search bar + padding
            toolbarHeight: 74.0,
            collapsedHeight: 74.0,
            floating: true,
            snap: true,
            pinned: false,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.none,
              background: _buildFloatingSearchBar(),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                const SizedBox(height: 20),
          
                // My Teams Section
                if (myTeams.isNotEmpty)
                  CollapsibleSection(
                    title: '내 소속',
                    count: myTeams.length,
                    child: Column(
                      children: myTeams.map((team) => _buildTeamTile(team, showBorder: false)).toList(),
                    ),
                  ),

                // Other Teams Section
                CollapsibleSection(
                  title: '팀 목록',
                  count: otherTeams.length,
                  onAdd: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddTeamScreen(
                          onTeamAdded: (team) {
                            setState(() {
                              _dataManager.addTeam(team);
                            });
                          },
                        ),
                      ),
                    );
                  },
                  child: Column(
                    children: otherTeams.map((team) => _buildTeamTile(team)).toList(),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(Map<String, dynamic> user) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfileScreen(user: user),
            ),
          );
        },
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.only(top: 20, bottom: 20, left: 24, right: 24),
          child: Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFFAAAAAA),
                  shape: BoxShape.circle,
                  image: user['image'] != null
                      ? DecorationImage(
                          image: NetworkImage(user['image']),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: user['image'] == null
                    ? Center(
                        child: Text(user['avatar'] ?? '',
                            style: const TextStyle(fontSize: 30)),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user['name'] ?? '',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user['statusMessage'] ?? '',
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      color: Colors.white,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(25),
        ),
        child: TextField(
          focusNode: _searchFocusNode,
          onChanged: (value) => setState(() => _searchQuery = value),
          onSubmitted: (value) {
            // Search logic if needed
          },
          decoration: const InputDecoration(
            hintText: '검색',
            prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 14),
            fillColor: Colors.transparent,
            hoverColor: Colors.transparent,
          ),
        ),
      ),
    );
  }

  Widget _buildTeamTile(Map<String, dynamic> team, {bool showBorder = true}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: showBorder
            ? const Border(
                bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
              )
            : null,
      ),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TeamDetailScreen(
                teamName: team['name'],
                teamIcon: team['icon'] ?? '🛡️',
                members: List<String>.from(team['members'] ?? []),
                teamImage: team['image'] ??
                    'https://picsum.photos/seed/${team['name']}/200/200',
              ),
            ),
          );
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20), // Rounded square
            image: DecorationImage(
              image: NetworkImage(
                team['image'] ??
                    'https://picsum.photos/seed/${team['name']}/200/200',
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: Text(
          team['name'],
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: AppTheme.textPrimary,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            team['member'] ?? '${(team['members'] as List).length}명',
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToProfile(Map<String, dynamic> friend) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(
          user: friend,
        ),
      ),
    );
  }
}
