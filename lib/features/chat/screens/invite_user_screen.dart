import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../data/data_manager.dart';

class InviteUserScreen extends StatefulWidget {
  const InviteUserScreen({Key? key}) : super(key: key);

  @override
  State<InviteUserScreen> createState() => _InviteUserScreenState();
}

class _InviteUserScreenState extends State<InviteUserScreen> {
  final DataManager _dataManager = DataManager();
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _friends = [];
  List<Map<String, dynamic>> _filteredFriends = [];
  final Set<String> _selectedUsers = {};

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  void _loadFriends() {
    setState(() {
      _friends = _dataManager.friends;
      _filteredFriends = _friends;
    });
  }

  void _filterFriends(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredFriends = _friends;
      } else {
        _filteredFriends = _friends
            .where((friend) =>
                friend['name'].toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _toggleSelection(String name) {
    setState(() {
      if (_selectedUsers.contains(name)) {
        _selectedUsers.remove(name);
      } else {
        _selectedUsers.add(name);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppTheme.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '대화상대 초대',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '이름으로 검색',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onChanged: _filterFriends,
            ),
          ),
          const SizedBox(height: 8),
          // Friend List
          Expanded(
            child: ListView.builder(
              itemCount: _filteredFriends.length,
              itemBuilder: (context, index) {
                final friend = _filteredFriends[index];
                final isSelected = _selectedUsers.contains(friend['name']);

                return ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(friend['image']),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  title: Text(
                    friend['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  trailing: Checkbox(
                    value: isSelected,
                    activeColor: const Color(0xFF0095F6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    onChanged: (value) => _toggleSelection(friend['name']),
                  ),
                  onTap: () => _toggleSelection(friend['name']),
                );
              },
            ),
          ),
          // Bottom Button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _selectedUsers.isEmpty
                      ? null
                      : () {
                          Navigator.pop(context, _selectedUsers.toList());
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  '${_selectedUsers.length}명을 초대했습니다.'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0095F6),
                    disabledBackgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _selectedUsers.isEmpty
                        ? '초대하기'
                        : '${_selectedUsers.length}명 초대하기',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
