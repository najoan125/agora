import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../data/models/team/team.dart';
import '../../shared/providers/riverpod_profile_provider.dart';
import '../../shared/providers/friend_provider.dart';
import '../../shared/providers/team_provider.dart';
import '../friends/widgets/friend_tile.dart';
import '../friends/widgets/friend_request_tile.dart';
import '../../shared/widgets/collapsible_section.dart';
import '../chat/widgets/group_chat_tile.dart';
import '../profile/screens/profile_screen.dart';
import '../profile/screens/edit_agora_profile_screen.dart';
import '../friends/screens/add_friend_screen.dart';
import '../teams/screens/team_detail_screen.dart';
import '../teams/screens/add_team_screen.dart';
import '../teams/screens/create_team_profile_screen.dart';

import 'screens/notification_screen.dart';
import '../chat/screens/create_group_screen.dart';
import '../chat/screens/group_chat_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _menuAnimationController;
  final FocusNode _searchFocusNode = FocusNode();
  String _sortOption = 'recent';
  String _searchQuery = '';
  bool _isMenuOpen = false;
  bool _isGroupChatExpanded = true;

  // Group Chats list (will be loaded from API)
  final List<Map<String, dynamic>> _groupChats = [];

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
      setState(() {});
    });
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
                            // Refresh friend list
                            ref.invalidate(friendListProvider);
                          },
                        ),
                      ),
                    );
                  },
                ),
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
    final profileAsync = ref.watch(myProfileProvider);
    final friendsAsync = ref.watch(friendListProvider);
    final requestsAsync = ref.watch(friendRequestsProvider);
    final birthdaysAsync = ref.watch(upcomingBirthdaysProvider);

    return profileAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('오류: $error')),
      data: (profile) {
        final user = profile != null
            ? {
                'name': profile.displayName,
                'statusMessage': profile.statusMessage ?? '상태 메시지를 설정하세요',
                'image': profile.profileImageUrl,
                'avatar': profile.displayName.isNotEmpty ? profile.displayName[0] : '?',
              }
            : {
                'name': '사용자',
                'statusMessage': '상태 메시지를 설정하세요',
                'image': null,
                'avatar': '?',
              };

        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(friendListProvider);
              ref.invalidate(friendRequestsProvider);
              ref.invalidate(upcomingBirthdaysProvider);
            },
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _buildProfileHeader(user),
                ),
                SliverAppBar(
                  backgroundColor: Colors.white,
                  expandedHeight: 74.0,
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
                      const SizedBox(height: 10),

                      // Group Chats Section
                      _buildGroupChatsSection(),

                      // Friend Requests
                      requestsAsync.when(
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (requests) {
                          if (requests.isEmpty) return const SizedBox.shrink();
                          return CollapsibleSection(
                            title: '친구 요청',
                            count: requests.length,
                            child: Column(
                              children: requests.map((request) {
                                return FriendRequestTile(
                                  request: {
                                    'name': request.senderDisplayName,
                                    'image': request.senderProfileImageUrl,
                                    'message': '',
                                  },
                                  onAccept: () async {
                                    final notifier = ref.read(friendActionProvider.notifier);
                                    final success = await notifier.acceptFriendRequest(request.id.toString());
                                    if (success && mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('${request.senderDisplayName}님을 친구로 추가했습니다')),
                                      );
                                    }
                                  },
                                  onDecline: () async {
                                    final notifier = ref.read(friendActionProvider.notifier);
                                    final success = await notifier.rejectFriendRequest(request.id.toString());
                                    if (success && mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('${request.senderDisplayName}님의 친구 요청을 거절했습니다')),
                                      );
                                    }
                                  },
                                );
                              }).toList(),
                            ),
                          );
                        },
                      ),

                      // Birthdays
                      birthdaysAsync.when(
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (birthdays) {
                          if (birthdays.isEmpty) return const SizedBox.shrink();
                          return CollapsibleSection(
                            title: '생일인 친구',
                            count: birthdays.length,
                            child: Column(
                              children: birthdays.map((friend) {
                                return FriendTile(
                                  friend: _friendToMap(friend),
                                  onTap: () => _navigateToProfile(_friendToMap(friend)),
                                  onFavoriteToggle: () async {
                                    final notifier = ref.read(friendActionProvider.notifier);
                                    await notifier.toggleFavorite(friend.id, friend.isFavorite);
                                  },
                                );
                              }).toList(),
                            ),
                          );
                        },
                      ),

                      // Friends List
                      friendsAsync.when(
                        loading: () => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        error: (error, _) => Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              children: [
                                const Icon(Icons.people_outline, size: 48, color: AppTheme.textSecondary),
                                const SizedBox(height: 16),
                                const Text(
                                  '친구 목록을 불러올 수 없습니다',
                                  style: TextStyle(color: AppTheme.textSecondary),
                                ),
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: () => ref.invalidate(friendListProvider),
                                  child: const Text('다시 시도'),
                                ),
                              ],
                            ),
                          ),
                        ),
                        data: (friends) {
                          var filteredFriends = friends.where((f) {
                            if (_searchQuery.isEmpty) return true;
                            return f.displayName.toLowerCase().contains(_searchQuery.toLowerCase());
                          }).toList();

                          if (_sortOption == 'name') {
                            filteredFriends.sort((a, b) => a.displayName.compareTo(b.displayName));
                          }

                          // 친구가 없는 경우
                          if (friends.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: Column(
                                  children: [
                                    const Icon(Icons.people_outline, size: 48, color: AppTheme.textSecondary),
                                    const SizedBox(height: 16),
                                    const Text(
                                      '아직 친구가 없습니다',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      '친구를 추가해보세요!',
                                      style: TextStyle(color: AppTheme.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          final favorites = filteredFriends.where((f) => f.isFavorite).toList();
                          final otherFriends = filteredFriends.where((f) => !f.isFavorite).toList();

                          return Column(
                            children: [
                              // Favorites
                              if (favorites.isNotEmpty)
                                CollapsibleSection(
                                  title: '즐겨찾기',
                                  count: favorites.length,
                                  child: Column(
                                    children: favorites.map((friend) {
                                      return FriendTile(
                                        friend: _friendToMap(friend),
                                        onTap: () => _navigateToProfile(_friendToMap(friend)),
                                        onFavoriteToggle: () async {
                                          final notifier = ref.read(friendActionProvider.notifier);
                                          await notifier.toggleFavorite(friend.id.toString(), friend.isFavorite);
                                        },
                                      );
                                    }).toList(),
                                  ),
                                ),

                              // All Friends
                              CollapsibleSection(
                                title: '친구 목록',
                                count: otherFriends.length,
                                child: Column(
                                  children: otherFriends.map((friend) {
                                    return FriendTile(
                                      friend: _friendToMap(friend),
                                      onTap: () => _navigateToProfile(_friendToMap(friend)),
                                      onFavoriteToggle: () async {
                                        final notifier = ref.read(friendActionProvider.notifier);
                                        await notifier.toggleFavorite(friend.id.toString(), friend.isFavorite);
                                      },
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGroupChatsSection() {
    return Column(
      children: [
        const Divider(height: 1, thickness: 1, color: Color(0xFFCCCCCC)),
        InkWell(
          onTap: () {
            setState(() {
              _isGroupChatExpanded = !_isGroupChatExpanded;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
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
                            builder: (context) => const CreateGroupScreen(),
                          ),
                        );

                        if (result != null && result is Map<String, dynamic>) {
                          setState(() {
                            _groupChats.insert(0, result);
                          });
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('그룹 "${result['name']}" 생성 완료!')),
                            );
                          }
                        }
                      },
                      child: Column(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFE0E0E0)),
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
                  ..._groupChats.map((chat) => Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: GroupChatTile(
                      name: chat['name']!,
                      image: chat['image'],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GroupChatScreen(
                              groupName: chat['name']!,
                              groupImage: chat['image'],
                              members: List<String>.from(chat['members'] ?? []),
                            ),
                          ),
                        );
                      },
                    ),
                  )).toList(),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTeamList() {
    final teamsAsync = ref.watch(teamListProvider);
    final teamProfileAsync = ref.watch(myTeamProfileProvider);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(teamListProvider);
          ref.invalidate(myTeamProfileProvider);
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _buildTeamProfileHeader(teamProfileAsync),
            ),
            SliverAppBar(
              backgroundColor: Colors.white,
              expandedHeight: 74.0,
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
                  teamsAsync.when(
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (error, stack) => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text('오류: $error'),
                      ),
                    ),
                    data: (teams) {
                      var filteredTeams = teams.where((t) {
                        if (_searchQuery.isEmpty) return true;
                        return t.name.toLowerCase().contains(_searchQuery.toLowerCase());
                      }).toList();

                      if (_sortOption == 'name') {
                        filteredTeams.sort((a, b) => a.name.compareTo(b.name));
                      }

                      return CollapsibleSection(
                        title: '팀 목록',
                        count: filteredTeams.length,
                        onAdd: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddTeamScreen(
                                onTeamAdded: (team) {
                                  ref.invalidate(teamListProvider);
                                },
                              ),
                            ),
                          );
                        },
                        child: teams.isEmpty
                            ? _buildEmptyTeamState()
                            : Column(
                                children: filteredTeams.map((team) => _buildTeamTile(team)).toList(),
                              ),
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyTeamState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Icon(Icons.groups_outlined, size: 48, color: AppTheme.textSecondary),
            const SizedBox(height: 16),
            const Text(
              '가입한 팀이 없습니다',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '팀을 만들거나 초대를 받아보세요!',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
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
              builder: (context) => const EditAgoraProfileScreen(),
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

  Widget _buildTeamProfileHeader(AsyncValue<TeamProfile?> teamProfileAsync) {
    return teamProfileAsync.when(
      loading: () => const SizedBox(
        height: 110,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => _buildCreateTeamProfileButton(),
      data: (teamProfile) {
        if (teamProfile == null) {
          return _buildCreateTeamProfileButton();
        }

        // 팀 프로필이 있는 경우 표시
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              // 팀 프로필 수정 화면으로 이동 (추후 구현 가능)
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
                      image: teamProfile.profileImageUrl != null
                          ? DecorationImage(
                              image: NetworkImage(teamProfile.profileImageUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: teamProfile.profileImageUrl == null
                        ? Center(
                            child: Text(
                              teamProfile.displayName.isNotEmpty ? teamProfile.displayName[0] : '?',
                              style: const TextStyle(fontSize: 30, color: Colors.white),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          teamProfile.displayName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        if (teamProfile.bio != null && teamProfile.bio!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            teamProfile.bio!,
                            style: const TextStyle(
                              fontSize: 15,
                              color: AppTheme.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCreateTeamProfileButton() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 20, bottom: 20, left: 24, right: 24),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300, width: 2),
            ),
            child: Icon(
              Icons.person_add,
              size: 35,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '팀 프로필을 만들어보세요',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '팀원들에게 보여질 프로필입니다',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateTeamProfileScreen(),
                ),
              );
              if (result == true && mounted) {
                ref.invalidate(myTeamProfileProvider);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('만들기'),
          ),
        ],
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

  Widget _buildTeamTile(dynamic team, {bool showBorder = true}) {
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
                teamName: team.name,
                teamIcon: '🛡️',
                members: [], // Will be loaded from API
                teamImage: team.profileImageUrl ??
                    'https://picsum.photos/seed/${team.name}/200/200',
              ),
            ),
          );
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: DecorationImage(
              image: NetworkImage(
                team.profileImageUrl ??
                    'https://picsum.photos/seed/${team.name}/200/200',
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: Text(
          team.name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: AppTheme.textPrimary,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            team.description ?? '${team.memberCount ?? 0}명',
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _friendToMap(dynamic friend) {
    return {
      'id': friend.id,
      'agoraId': friend.agoraId,
      'name': friend.displayName,
      'image': friend.profileImageUrl,
      'avatar': friend.displayName.isNotEmpty ? friend.displayName[0] : '?',
      'statusMessage': friend.statusMessage ?? '',
      'isOnline': friend.isOnline,
      'isFavorite': friend.isFavorite,
      'isBirthday': false, // Will be set from birthdays provider
    };
  }

  void _navigateToProfile(Map<String, dynamic> friend) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(user: friend),
      ),
    );
  }
}
