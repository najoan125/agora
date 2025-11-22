// 채팅 목록 화면
import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../data/data_manager.dart';
import '../widgets/chat_tile.dart';
import 'conversation_screen.dart';
import 'team_chat_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final DataManager _dataManager = DataManager();
  late TabController _tabController;
  late AnimationController _menuAnimationController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isMenuOpen = false;
  bool _isSearching = false;
  bool _showUnreadOnly = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _menuAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _menuAnimationController.dispose();
    _searchController.dispose();
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

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchQuery = '';
        _searchController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.search, size: 28, color: Colors.black),
                onPressed: _toggleSearch,
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
              labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              tabs: const [
                Tab(text: '친구'),
                Tab(text: '팀원'),
              ],
            ),
          ),
          body: GestureDetector(
            onTap: () {
              if (_isMenuOpen) {
                _toggleMenu();
              }
              FocusScope.of(context).unfocus();
            },
            behavior: HitTestBehavior.translucent,
            child: Column(
              children: [
                if (_isSearching)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: Colors.white,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              autofocus: true,
                              decoration: const InputDecoration(
                                hintText: '메시지 검색',
                                filled: false,
                                fillColor: Colors.transparent,
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                hintStyle: TextStyle(color: Colors.grey),
                                contentPadding: EdgeInsets.symmetric(vertical: 10),
                                isDense: true,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value;
                                });
                              },
                            ),
                          ),
                          if (_searchQuery.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _searchQuery = '';
                                  _searchController.clear();
                                });
                              },
                              child: const Icon(Icons.close, color: Colors.grey, size: 20),
                            )
                          else
                            GestureDetector(
                              onTap: _toggleSearch,
                              child: const Icon(Icons.close, color: Colors.grey, size: 20),
                            ),
                        ],
                      ),
                    ),
                  ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildChatList(isTeam: false),
                      _buildChatList(isTeam: true),
                    ],
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              // Start new chat
            },
            backgroundColor: AppTheme.primaryColor,
            child: const Icon(Icons.edit, color: Colors.white),
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
                width: 220,
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
                    _buildMenuItem(
                      '안읽은 메시지 확인',
                      Icons.mark_email_unread_outlined,
                      () {
                        _toggleMenu();
                        setState(() {
                          _showUnreadOnly = !_showUnreadOnly;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(_showUnreadOnly
                                ? '안읽은 메시지만 표시합니다'
                                : '모든 메시지를 표시합니다'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      isSelected: _showUnreadOnly,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMenuItem(String title, IconData icon, VoidCallback onTap, {bool isSelected = false}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        color: isSelected ? Colors.grey[100] : null,
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (isSelected) ...[
              const Spacer(),
              const Icon(Icons.check, size: 16, color: AppTheme.primaryColor),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChatList({required bool isTeam}) {
    final chats = _dataManager.chats.where((chat) {
      final bool chatIsTeam = chat['isTeam'] ?? false;
      return chatIsTeam == isTeam;
    }).toList();

    var filteredChats = _searchQuery.isEmpty
        ? chats
        : chats.where((chat) =>
            chat['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
            chat['message'].toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    if (_showUnreadOnly) {
      filteredChats = filteredChats.where((chat) => (chat['unread'] ?? 0) > 0).toList();
    }

    if (filteredChats.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      itemCount: filteredChats.length,
      itemBuilder: (context, index) {
        final chat = filteredChats[index];
        return ChatTile(
          chat: chat,
          onTap: () {
            if (chat['isTeam'] == true) {
              // Find team data to get members
              final team = _dataManager.teams.firstWhere(
                (t) => t['name'] == chat['name'],
                orElse: () => {'members': <String>[], 'icon': '👥'},
              );
              
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TeamChatScreen(
                    teamName: chat['name'],
                    teamIcon: chat['avatar'] ?? '👥',
                    teamImage: chat['image'],
                    members: List<String>.from(team['members'] ?? []),
                  ),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ConversationScreen(
                    userName: chat['name'],
                    userImage: chat['image'] ?? '',
                    isTeam: false,
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: AppTheme.textTertiary),
          const SizedBox(height: 16),
          Text(
            '대화가 없습니다',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            '새로운 대화를 시작해보세요',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
