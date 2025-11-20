import 'package:flutter/material.dart';
import 'add_team_member_screen.dart';

class AddTeamScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onTeamAdded;

  const AddTeamScreen({
    Key? key,
    required this.onTeamAdded,
  }) : super(key: key);

  @override
  State<AddTeamScreen> createState() => _AddTeamScreenState();
}

class _AddTeamScreenState extends State<AddTeamScreen> {
  late TextEditingController _teamNameController;
  late TextEditingController _teamDescriptionController;
  String _selectedIcon = '👨‍💻';

  final List<String> _availableIcons = [
    '👨‍💻',
    '📊',
    '🎨',
    '📋',
    '🚀',
    '💼',
    '🎯',
    '📱'
  ];

  @override
  void initState() {
    super.initState();
    _teamNameController = TextEditingController();
    _teamDescriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _teamNameController.dispose();
    _teamDescriptionController.dispose();
    super.dispose();
  }

  void _addTeam() {
    if (_teamNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('팀 이름을 입력해주세요')),
      );
      return;
    }

    final newTeam = {
      'name': _teamNameController.text,
      'member': '0명',
      'icon': _selectedIcon,
      'members': [],
    };

    widget.onTeamAdded(newTeam);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${_teamNameController.text}을 생성했습니다')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('팀 만들기'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 팀 아이콘 선택
            Text(
              '팀 아이콘 선택',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('아이콘 선택'),
                    content: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableIcons.map((icon) {
                        final isSelected = _selectedIcon == icon;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedIcon = icon;
                            });
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.blue.shade200
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.blue.shade400
                                    : Colors.grey.shade300,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                icon,
                                style: const TextStyle(fontSize: 32),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade50,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _selectedIcon,
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '현재 선택: $_selectedIcon',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      color: Colors.grey.shade600,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // 팀 이름 입력
            Text(
              '팀 이름',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _teamNameController,
              decoration: InputDecoration(
                hintText: '팀 이름을 입력하세요',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.blue.shade400),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
            const SizedBox(height: 20),
            // 팀 설명 입력
            Text(
              '팀 설명 (선택)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _teamDescriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: '팀 설명을 입력하세요',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.blue.shade400),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
            const SizedBox(height: 32),
            // 버튼들
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _addTeam,
                    icon: const Icon(Icons.add),
                    label: const Text('팀 만들기'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade400,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddTeamMemberScreen(
                            onMemberAdded: (memberName) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('$memberName을(를) 추가했습니다'),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.person_add),
                    label: const Text('팀원 추가'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade400,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
