import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agora/core/theme.dart';
import 'package:agora/shared/providers/friend_provider.dart';
import 'package:agora/data/models/friend/friend.dart';

class SelectMembersScreen extends ConsumerStatefulWidget {
  final List<int>? existingMemberIds;
  final String? title;

  const SelectMembersScreen({
    super.key,
    this.existingMemberIds,
    this.title,
  });

  @override
  ConsumerState<SelectMembersScreen> createState() => _SelectMembersScreenState();
}

class _SelectMembersScreenState extends ConsumerState<SelectMembersScreen> {
  final Set<int> _selectedFriendIds = {};
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 기존 멤버는 선택 불가능하도록 처리하거나 애초에 목록에서 제외하는 것이 좋으나
    // 여기서는 선택된 상태가 아니라 그냥 비활성화 처리 또는 아예 안보여주는게 깔끔함.
    // 사용자는 "초대할 사람"을 찾는 것이므로 이미 있는 사람은 안보이는게 나을 수도 있음.
    // 하지만 "누가 있는지" 확인 차원에서는 보이는게 나음.
    // 보통 메신저는 "이미 참여 중"이라고 표시하고 선택 불가로 만듦.
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final friendsAsync = ref.watch(friendListProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title ?? '대화상대 선택',
          style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _selectedFriendIds.isEmpty
                ? null
                : () {
                    // 선택된 친구 ID 목록 반환
                    Navigator.pop(context, _selectedFriendIds.toList());
                  },
            child: Text(
              '확인',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _selectedFriendIds.isEmpty ? AppTheme.textSecondary : AppTheme.primaryColor,
              ),
            ),
          ),
        ],
      ),
      body: friendsAsync.when(
        data: (friends) {
          final filteredFriends = _searchQuery.isEmpty
              ? friends
              : friends
                  .where((f) =>
                      f.displayName.toLowerCase().contains(_searchQuery.toLowerCase()))
                  .toList();

          return Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: const InputDecoration(
                      hintText: '이름 검색',
                      prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ),

              // Selected Friends Horizontal List
              if (_selectedFriendIds.isNotEmpty)
                Container(
                  height: 100,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedFriendIds.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      final friendId = _selectedFriendIds.elementAt(index);
                      final friend = friends.firstWhere(
                        (f) => f.id == friendId,
                        orElse: () => friends.first, // Fallback (should not happen)
                      );

                      return Column(
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.grey[200]!),
                                  image: friend.profileImageUrl != null
                                      ? DecorationImage(
                                          image: NetworkImage(friend.profileImageUrl!),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                  color: Colors.grey[100],
                                ),
                                child: friend.profileImageUrl == null
                                    ? Center(
                                        child: Text(
                                          friend.displayName.isNotEmpty
                                              ? friend.displayName[0]
                                              : '?',
                                          style: const TextStyle(fontSize: 20),
                                        ),
                                      )
                                    : null,
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedFriendIds.remove(friendId);
                                    });
                                  },
                                  child: Container(
                                    width: 18,
                                    height: 18,
                                    decoration: const BoxDecoration(
                                      color: Colors.black,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close,
                                        size: 12, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          SizedBox(
                            width: 60,
                            child: Text(
                              friend.displayName,
                              style: const TextStyle(
                                  fontSize: 12, color: AppTheme.textPrimary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

              // Friends List
              Expanded(
                child: ListView.builder(
                  itemCount: filteredFriends.length,
                  itemBuilder: (context, index) {
                    final friend = filteredFriends[index];
                    final isSelected = _selectedFriendIds.contains(friend.id);
                    final isExisting =
                        widget.existingMemberIds?.contains(friend.id) ?? false;

                    return ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey[200]!),
                          image: friend.profileImageUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(friend.profileImageUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                          color: Colors.grey[100],
                        ),
                        child: friend.profileImageUrl == null
                            ? Center(
                                child: Text(
                                  friend.displayName.isNotEmpty
                                      ? friend.displayName[0]
                                      : '?',
                                  style: const TextStyle(fontSize: 20),
                                ),
                              )
                            : null,
                      ),
                      title: Text(
                        friend.displayName,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isExisting
                              ? AppTheme.textSecondary
                              : AppTheme.textPrimary,
                          fontSize: 16,
                        ),
                      ),
                      trailing: isExisting
                          ? const Text(
                              '참여 중',
                              style: TextStyle(
                                  color: AppTheme.textSecondary, fontSize: 13),
                            )
                          : Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? AppTheme.primaryColor
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isSelected
                                      ? AppTheme.primaryColor
                                      : const Color(0xFFE0E0E0),
                                  width: 2,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check,
                                      size: 16, color: Colors.white)
                                  : null,
                            ),
                      onTap: isExisting
                          ? null
                          : () {
                              setState(() {
                                if (isSelected) {
                                  _selectedFriendIds.remove(friend.id);
                                } else {
                                  _selectedFriendIds.add(friend.id);
                                }
                              });
                            },
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('오류 발생: $err')),
      ),
    );
  }
}
