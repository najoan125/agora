import 'package:flutter/material.dart';
import 'package:agora/core/theme.dart';
import 'package:agora/features/chat/screens/select_chats_screen.dart';

class CreateChatFolderScreen extends StatefulWidget {
  final bool isTeam;
  const CreateChatFolderScreen({super.key, required this.isTeam});

  @override
  State<CreateChatFolderScreen> createState() => _CreateChatFolderScreenState();
}

class _CreateChatFolderScreenState extends State<CreateChatFolderScreen> {
  final TextEditingController _nameController = TextEditingController();
  List<String> _selectedMembers = [];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _addMembers() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectChatsScreen(isTeam: widget.isTeam),
      ),
    );

    if (result != null && result is List<String>) {
      setState(() {
        for (var name in result) {
          if (!_selectedMembers.contains(name)) {
            _selectedMembers.add(name);
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '폴더 만들기',
          style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _nameController.text.isNotEmpty
                ? () {
                    Navigator.pop(context, {
                      'name': _nameController.text,
                      'members': _selectedMembers,
                    });
                  }
                : null,
            child: Text(
              '완료',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _nameController.text.isNotEmpty ? AppTheme.primaryColor : AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              maxLength: 10,
              onChanged: (value) => setState(() {}),
              decoration: const InputDecoration(
                hintText: '폴더 이름',
                hintStyle: TextStyle(color: Color(0xFFCCCCCC)),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFE0E0E0)),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                counterText: '',
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              '등록한 채팅방',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Add Button Chip
                GestureDetector(
                  onTap: _addMembers,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.add, size: 16, color: AppTheme.textSecondary),
                        SizedBox(width: 4),
                        Text(
                          '채팅방 추가',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Selected Members Chips
                ..._selectedMembers.map((member) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        member,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedMembers.remove(member);
                          });
                        },
                        child: const Icon(Icons.close, size: 14, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
