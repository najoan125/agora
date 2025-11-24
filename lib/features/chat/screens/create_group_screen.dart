import 'package:flutter/material.dart';
import 'package:agora/core/theme.dart';
import 'package:agora/features/chat/screens/select_members_screen.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _nameController = TextEditingController();
  List<String> _selectedMembers = [];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _selectMembers() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SelectMembersScreen(),
      ),
    );

    if (result != null && result is List<String>) {
      setState(() {
        _selectedMembers = result;
      });
    }
  }

  void _createGroup() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('그룹 이름을 입력해주세요.')),
      );
      return;
    }

    if (_selectedMembers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('그룹 멤버를 선택해주세요.')),
      );
      return;
    }

    // Create group data
    final newGroup = {
      'name': _nameController.text,
      'image': 'https://picsum.photos/seed/${_nameController.text.hashCode.abs()}/200/200',
      'info': '${_selectedMembers.length}명',
      'members': _selectedMembers,
    };

    // Return the created group
    Navigator.pop(context, newGroup);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '그룹 생성',
          style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppTheme.textPrimary),
            onPressed: () {
              // Settings (mock)
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'group name',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE0E0E0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  hintText: '그룹 이름을 입력하세요',
                  hintStyle: TextStyle(color: Color(0xFFCCCCCC)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'members',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _selectMembers,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    '+ 그룹 인원 추가',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            if (_selectedMembers.isNotEmpty) ...[
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _selectedMembers.length,
                  itemBuilder: (context, index) {
                    final memberName = _selectedMembers[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: NetworkImage(
                                  'https://picsum.photos/seed/${memberName.hashCode.abs()}/200/200',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            memberName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ] else
              const Spacer(),
            
            SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _createGroup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD9D9D9), // Light grey as in design
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'Create Group',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
