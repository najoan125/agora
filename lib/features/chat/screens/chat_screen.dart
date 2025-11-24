// 채팅 목록 화면
import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../data/data_manager.dart';
import '../widgets/chat_tile.dart';
import 'conversation_screen.dart';
import 'team_chat_screen.dart';

import 'create_chat_folder_screen.dart';

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
  
  // Custom Chat Folders
  final List<Map<String, dynamic>> _friendChatFolders = [];
  final List<Map<String, dynamic>> _teamChatFolders = [];
  Map<String, dynamic>? _selectedFolder;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          // Reset selected folder when switching tabs
          _selectedFolder = null;
          _showUnreadOnly = false;
        });
      }
    });
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

  int get _totalUnreadCount {
    return _dataManager.chats.fold(0, (sum, chat) => sum + (chat['unread'] as int? ?? 0));
  }

  @override
  Widget build(BuildContext context) {
    final bool isTeamTab = _tabController.index == 1;
    final currentFolders = isTeamTab ? _teamChatFolders : _friendChatFolders;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              '채팅',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
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
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  labelColor: Colors.black,
                  unselectedLabelColor: const Color(0xFF8E8E93),
                  indicatorColor: Colors.black,
                  indicatorWeight: 1.0,
                  labelPadding: EdgeInsets.zero,
                  indicatorSize: TabBarIndicatorSize.tab,
                  tabs: [
                    _buildTab('친구', 0),
                    _buildTab('팀원', 1),
                  ],
                ),
              ),
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
              crossAxisAlignment: CrossAxisAlignment.start,
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
                
                // Filter Row (All / Unread / Custom Folders)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip(
                          label: '전체',
                          isSelected: !_showUnreadOnly && _selectedFolder == null,
                          onTap: () {
                            setState(() {
                              _showUnreadOnly = false;
                              _selectedFolder = null;
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          label: '안읽음',
                          isSelected: _showUnreadOnly,
                          count: _totalUnreadCount,
                          onTap: () {
                            setState(() {
                              _showUnreadOnly = true;
                              _selectedFolder = null;
                            });
                          },
                          isUnreadFilter: true,
                        ),
                        const SizedBox(width: 8),
                        
                        // Custom Folder Chips
                        ...currentFolders.map((folder) {
                          final folderName = folder['name'] as String;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: _buildFilterChip(
                              label: folderName,
                              isSelected: _selectedFolder == folder,
                              onTap: () {
                                setState(() {
                                  if (_selectedFolder == folder) {
                                    _selectedFolder = null; // Toggle off
                                  } else {
                                    _selectedFolder = folder;
                                    _showUnreadOnly = false; // Disable unread filter
                                  }
                                });
                              },
                              onDelete: () {
                                setState(() {
                                  currentFolders.remove(folder);
                                  if (_selectedFolder == folder) {
                                    _selectedFolder = null;
                                  }
                                });
                              },
                            ),
                          );
                        }).toList(),

                        // Add button
                        GestureDetector(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CreateChatFolderScreen(isTeam: isTeamTab),
                              ),
                            );
                            
                            if (result != null && result is Map<String, dynamic>) {
                              setState(() {
                                currentFolders.add(result);
                              });
                            }
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: const Icon(Icons.add, size: 20, color: Colors.grey),
                          ),
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
                        '메시지 수신 시뮬레이션',
                        Icons.send_to_mobile,
                        () {
                          _toggleMenu();
                          _dataManager.receiveMockMessage();
                          setState(() {}); // Refresh UI
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('새로운 메시지가 도착했습니다'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTab(String text, int index) {
    // Check if this tab is selected
    final bool isSelected = _tabController.index == index;
    return Tab(
      height: 48,
      child: Container(
        color: isSelected ? const Color(0xFFEBF5FF) : Colors.white, // Light blue for selected
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    int? count,
    bool isUnreadFilter = false,
    VoidCallback? onDelete,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF1A1A1A) : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF1A1A1A),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
            if (count != null && count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5A00), // Orange badge
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            if (onDelete != null && isSelected) ...[
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onDelete,
                child: const Icon(Icons.close, size: 16, color: Colors.white),
              ),
            ],
          ],
        ),
      ),
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
          ],
        ),
      ),
    );
  }

  Widget _buildChatList({required bool isTeam}) {
    var chats = _dataManager.chats.where((chat) {
      final bool chatIsTeam = chat['isTeam'] ?? false;
      return chatIsTeam == isTeam;
    }).toList();

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      chats = chats.where((chat) =>
          chat['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          chat['message'].toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    // Filter by unread
    if (_showUnreadOnly) {
      chats = chats.where((chat) => (chat['unread'] ?? 0) > 0).toList();
    }
    
    // Filter by selected folder
    if (_selectedFolder != null) {
      final members = List<String>.from(_selectedFolder!['members'] ?? []);
      chats = chats.where((chat) => members.contains(chat['name'])).toList();
    }

    if (chats.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      itemCount: chats.length,
      itemBuilder: (context, index) {
        final chat = chats[index];
        return ChatTile(
          chat: chat,
          onTap: () {
            // Clear unread count
            setState(() {
              _dataManager.clearUnread(chat['id']);
            });

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
              ).then((_) => setState(() {})); // Refresh on return
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
              ).then((_) => setState(() {})); // Refresh on return
            }
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    String message = '대화가 없습니다';
    if (_showUnreadOnly) message = '안읽은 메시지가 없습니다';
    if (_selectedFolder != null) message = '${_selectedFolder!['name']} 폴더에 대화가 없습니다';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: AppTheme.textTertiary),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.textSecondary),
          ),
          if (!_showUnreadOnly && _selectedFolder == null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                '새로운 대화를 시작해보세요',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
        ],
      ),
    );
  }
}
