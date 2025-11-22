import 'package:flutter/material.dart';
import 'package:agora/core/theme.dart';
import 'package:agora/data/data_manager.dart';

class CreateGroupChatScreen extends StatefulWidget {
  const CreateGroupChatScreen({super.key});

  @override
  State<CreateGroupChatScreen> createState() => _CreateGroupChatScreenState();
}

class _CreateGroupChatScreenState extends State<CreateGroupChatScreen> {
  final DataManager _dataManager = DataManager();
  final Set<String> _selectedFriendIds = {};
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final friends = _dataManager.friends;
    final filteredFriends = _searchQuery.isEmpty
        ? friends
        : friends.where((f) => f['name'].toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '대화상대 선택',
          style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _selectedFriendIds.isEmpty
                ? null
                : () {
                    // Return selected friend IDs to the caller
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
      body: Column(
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
              height: 80,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: _selectedFriendIds.length,
                separatorBuilder: (context, index) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final friendId = _selectedFriendIds.elementAt(index);
                  // In a real app, we would look up the friend object by ID. 
                  // For this mock, we'll just find the first friend with this name (assuming name is ID for now)
                  // or better, we should have unique IDs. 
                  // Let's assume the 'name' is unique enough for this mock or find the friend object.
                  final friend = friends.firstWhere((f) => f['name'] == friendId, orElse: () => {});
                  
                  return Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: friend['image'] != null
                                  ? DecorationImage(image: NetworkImage(friend['image']), fit: BoxFit.cover)
                                  : null,
                              color: Colors.grey[300],
                            ),
                            child: friend['image'] == null
                                ? Center(child: Text(friend['name']?[0] ?? '', style: const TextStyle(fontSize: 14)))
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
                                width: 16,
                                height: 16,
                                decoration: const BoxDecoration(
                                  color: Colors.black,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, size: 12, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        friend['name'] ?? '',
                        style: const TextStyle(fontSize: 11, color: AppTheme.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                final isSelected = _selectedFriendIds.contains(friend['name']);

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: friend['image'] != null
                            ? DecorationImage(image: NetworkImage(friend['image']), fit: BoxFit.cover)
                            : null,
                        color: Colors.grey[300],
                      ),
                      child: friend['image'] == null
                          ? Center(child: Text(friend['name']?[0] ?? '', style: const TextStyle(fontSize: 20)))
                          : null,
                    ),
                    title: Text(
                      friend['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    trailing: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                        border: Border.all(
                          color: isSelected ? AppTheme.primaryColor : const Color(0xFFE0E0E0),
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                          : null,
                    ),
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedFriendIds.remove(friend['name']);
                        } else {
                          _selectedFriendIds.add(friend['name']);
                        }
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
