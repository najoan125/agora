// 채팅 목록 화면
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../../../shared/providers/chat_provider.dart';
import '../../../shared/providers/chat_folder_provider.dart';
import '../../../shared/providers/riverpod_profile_provider.dart';
import '../../../data/models/chat/chat.dart';
import '../widgets/chat_tile.dart';
import 'conversation_screen.dart';
import 'team_chat_screen.dart';
import 'create_chat_folder_screen.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _menuAnimationController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isMenuOpen = false;
  bool _isSearching = false;
  bool _showUnreadOnly = false;

  // Selected folder
  String? _selectedFolderId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedFolderId = null;
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

  @override
  Widget build(BuildContext context) {
    final bool isTeamTab = _tabController.index == 1;
    final foldersAsync = ref.watch(chatFolderListProvider);
    final chatsAsync = ref.watch(chatListProvider);

    // Calculate total unread count
    final totalUnreadCount = chatsAsync.when(
      loading: () => 0,
      error: (_, __) => 0,
      data: (chats) => chats.fold(0, (sum, chat) => sum + chat.unreadCount),
    );

    final myProfile = ref.watch(myProfileProvider);
    final currentUserId = myProfile.when(
      data: (profile) => profile?.agoraId ?? '',
      loading: () => '',
      error: (_, __) => '',
    );

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
                foldersAsync.when(
                  loading: () => const SizedBox(
                    height: 60,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (folders) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip(
                              label: '전체',
                              isSelected: !_showUnreadOnly && _selectedFolderId == null,
                              onTap: () {
                                setState(() {
                                  _showUnreadOnly = false;
                                  _selectedFolderId = null;
                                });
                              },
                            ),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              label: '안읽음',
                              isSelected: _showUnreadOnly,
                              count: totalUnreadCount,
                              onTap: () {
                                setState(() {
                                  _showUnreadOnly = true;
                                  _selectedFolderId = null;
                                });
                              },
                              isUnreadFilter: true,
                            ),
                            const SizedBox(width: 8),

                            // Custom Folder Chips
                            ...folders.map((folder) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: _buildFilterChip(
                                  label: folder.name,
                                  isSelected: _selectedFolderId == folder.id.toString(),
                                  onTap: () {
                                    setState(() {
                                      if (_selectedFolderId == folder.id.toString()) {
                                        _selectedFolderId = null;
                                      } else {
                                        _selectedFolderId = folder.id.toString();
                                        _showUnreadOnly = false;
                                      }
                                    });
                                  },
                                  onDelete: () async {
                                    final notifier = ref.read(chatFolderActionProvider.notifier);
                                    final success = await notifier.deleteFolder(folder.id.toString());
                                    if (success && mounted) {
                                      if (_selectedFolderId == folder.id.toString()) {
                                        setState(() {
                                          _selectedFolderId = null;
                                        });
                                      }
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('폴더 "${folder.name}"이(가) 삭제되었습니다')),
                                      );
                                    }
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

                                if (result != null && result == true) {
                                  ref.invalidate(chatFolderListProvider);
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
                    );
                  },
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
                      '새로고침',
                      Icons.refresh,
                      () {
                        _toggleMenu();
                        ref.invalidate(chatListProvider);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('채팅 목록을 새로고침합니다'),
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
                  color: const Color(0xFFFF5A00),
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
    final chatsAsync = ref.watch(chatListProvider);
    final myProfile = ref.watch(myProfileProvider);
    final currentUserId = myProfile.when(
      data: (profile) => profile?.agoraId ?? '',
      loading: () => '',
      error: (_, __) => '',
    );

    return chatsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 48, color: AppTheme.textSecondary),
            const SizedBox(height: 16),
            const Text(
              '채팅 목록을 불러올 수 없습니다',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => ref.invalidate(chatListProvider),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
      data: (chats) {
        // Filter by team type (group vs direct)
        var filteredChats = chats.where((chat) =>
            (chat.type == ChatType.group) == isTeam
        ).toList();

        // Filter by search query
        if (_searchQuery.isNotEmpty) {
          filteredChats = filteredChats.where((chat) {
            final chatName = chat.name ?? '';
            final messageContent = chat.lastMessage?.content ?? '';
            return chatName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                messageContent.toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();
        }

        // Filter by unread
        if (_showUnreadOnly) {
          filteredChats = filteredChats.where((chat) => chat.unreadCount > 0).toList();
        }

        // Filter by selected folder
        if (_selectedFolderId != null) {
          final foldersAsync = ref.watch(chatFolderListProvider);
          foldersAsync.whenData((folders) {
            final selectedFolder = folders.firstWhere(
              (f) => f.id.toString() == _selectedFolderId,
              orElse: () => folders.first,
            );
            final chatIds = selectedFolder.chatIds?.map((id) => id.toString()).toList() ?? [];
            filteredChats = filteredChats.where((chat) => chatIds.contains(chat.id.toString())).toList();
          });
        }

        if (filteredChats.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(chatListProvider);
          },
          child: ListView.builder(
            itemCount: filteredChats.length,
            itemBuilder: (context, index) {
              final chat = filteredChats[index];
              final isGroupChat = chat.type == ChatType.group;
              return ChatTile(
                chat: _chatToMap(chat, currentUserId),
                onTap: () {
                  if (isGroupChat) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TeamChatScreen(
                          teamName: chat.name ?? '그룹 채팅',
                          teamIcon: '👥',
                          teamImage: chat.profileImageUrl,
                          members: [], // Will be loaded from participants
                        ),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ConversationScreen(
                          chatId: chat.id.toString(),
                          userName: chat.getDisplayName(currentUserId),
                          userImage: chat.getDisplayImage(currentUserId) ?? '',
                          isTeam: false,
                        ),
                      ),
                    );
                  }
                },
              );
            },
          ),
        );
      },
    );
  }

  Map<String, dynamic> _chatToMap(Chat chat, String currentUserId) {
    final name = chat.getDisplayName(currentUserId);
    return {
      'id': chat.id,
      'name': name,
      'image': chat.getDisplayImage(currentUserId),
      'avatar': name.isNotEmpty ? name[0] : '?',
      'message': chat.lastMessage?.content ?? '',
      'time': _formatTime(chat.lastMessage?.createdAt),
      'unread': chat.unreadCount,
      'isTeam': chat.type == ChatType.group,
      'isOnline': true,
    };
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inDays > 0) {
      return '${diff.inDays}일 전';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}시간 전';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}분 전';
    } else {
      return '방금';
    }
  }

  Widget _buildEmptyState() {
    String message = '대화가 없습니다';
    if (_showUnreadOnly) message = '안읽은 메시지가 없습니다';

    // Get folder name if selected
    if (_selectedFolderId != null) {
      final foldersAsync = ref.watch(chatFolderListProvider);
      foldersAsync.whenData((folders) {
        final folder = folders.firstWhere(
          (f) => f.id.toString() == _selectedFolderId,
          orElse: () => folders.first,
        );
        message = '${folder.name} 폴더에 대화가 없습니다';
      });
    }

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
          if (!_showUnreadOnly && _selectedFolderId == null)
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
