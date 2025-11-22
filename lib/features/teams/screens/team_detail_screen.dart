// 팀 상세 정보 및 관리 화면
import 'package:flutter/material.dart';
import '../../chat/screens/team_chat_screen.dart';
import '../../chat/screens/conversation_screen.dart';
import 'add_team_member_screen.dart';

class TeamDetailScreen extends StatefulWidget {
  final String teamName;
  final String teamIcon;
  final List<String> members;
  final String? teamImage;

  const TeamDetailScreen({
    Key? key,
    required this.teamName,
    required this.teamIcon,
    required this.members,
    this.teamImage,
  }) : super(key: key);

  @override
  State<TeamDetailScreen> createState() => _TeamDetailScreenState();
}

class _TeamDetailScreenState extends State<TeamDetailScreen> {
  late List<String> _members;
  late TextEditingController _teamNameController;
  late TextEditingController _noticeController;
  Map<String, String> _memberNicknames = {};

  @override
  void initState() {
    super.initState();
    _members = List<String>.from(widget.members);
    _teamNameController = TextEditingController(text: widget.teamName);
    _noticeController = TextEditingController(text: '');
  }

  @override
  void dispose() {
    _teamNameController.dispose();
    _noticeController.dispose();
    super.dispose();
  }

  void _addTeamMember() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTeamMemberScreen(
          onMemberAdded: (memberName) {
            setState(() {
              if (!_members.contains(memberName)) {
                _members.add(memberName);
              }
            });
          },
        ),
      ),
    );
  }

  void _removeMember(int index) {
    final memberName = _members[index];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('팀원 제거'),
        content: Text('$memberName을(를) 제거하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _members.removeAt(index);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$memberName을(를) 제거했습니다')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
            ),
            child: const Text('제거'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('팀 정보'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'rename',
                child: const Row(
                  children: [
                    Icon(Icons.edit, size: 18, color: Colors.blue),
                    SizedBox(width: 12),
                    Text('팀 이름 변경'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'notice',
                child: const Row(
                  children: [
                    Icon(Icons.notifications, size: 18, color: Colors.green),
                    SizedBox(width: 12),
                    Text('팀 공지 설정'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'rename') {
                _showTeamRenameDialog();
              } else if (value == 'notice') {
                _showTeamNoticeDialog();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // 팀 정보 카드
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                        image: NetworkImage(
                          widget.teamImage ?? 'https://picsum.photos/seed/${widget.teamName}/200/200',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.teamName,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_members.length}명',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // 팀 채팅 버튼
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TeamChatScreen(
                              teamName: widget.teamName,
                              teamIcon: widget.teamIcon,
                              teamImage: widget.teamImage,
                              members: _members,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text('팀 채팅'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade400,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 팀원 추가 버튼
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _addTeamMember,
                      icon: const Icon(Icons.person_add_outlined),
                      label: const Text('팀원 추가'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade400,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // 팀원 섹션
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '팀원 (${_members.length}명)',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_members.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          '팀원을 추가해주세요',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
                    )
                  else
                    ..._members.asMap().entries.map((entry) {
                      final index = entry.key;
                      final member = entry.value;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: DecorationImage(
                                  image: NetworkImage(
                                    'https://picsum.photos/seed/${member.hashCode.abs()}/200/200',
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    member,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '팀원',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuButton<int>(
                              itemBuilder: (context) => [
                                PopupMenuItem<int>(
                                  value: 1,
                                  child: const Row(
                                    children: [
                                      Icon(Icons.message_outlined,
                                          size: 18, color: Colors.blue),
                                      SizedBox(width: 8),
                                      Text('메시지'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem<int>(
                                  value: 3,
                                  child: const Row(
                                    children: [
                                      Icon(Icons.edit,
                                          size: 18, color: Colors.green),
                                      SizedBox(width: 8),
                                      Text('별명 설정'),
                                    ],
                                  ),
                                ),
                                const PopupMenuDivider(),
                                PopupMenuItem<int>(
                                  value: 2,
                                  child: const Row(
                                    children: [
                                      Icon(Icons.delete_outline,
                                          size: 18, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text('추방'),
                                    ],
                                  ),
                                ),
                              ],
                              onSelected: (value) {
                                if (value == 1) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ConversationScreen(
                                        userName: member,
                                        userImage:
                                            'https://i.pravatar.cc/150?u=$member',
                                      ),
                                    ),
                                  );
                                } else if (value == 2) {
                                  _removeMember(index);
                                } else if (value == 3) {
                                  _showMemberNicknameDialog(member);
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTeamRenameDialog() {
    _teamNameController.text = widget.teamName;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('팀 이름 변경'),
        content: TextField(
          controller: _teamNameController,
          decoration: InputDecoration(
            hintText: '새로운 팀 이름을 입력하세요',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.blue.shade400),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade400,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('팀 이름이 변경되었습니다: ${_teamNameController.text}'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  void _showTeamNoticeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('팀 공지 설정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '팀 공지를 입력하세요',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noticeController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: '팀 공지 내용을 입력해주세요',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.blue.shade400),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade400,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('팀 공지가 설정되었습니다'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  void _showMemberNicknameDialog(String member) {
    TextEditingController nicknameController =
        TextEditingController(text: _memberNicknames[member] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('별명 설정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$member의 별명을 설정하세요',
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nicknameController,
              decoration: InputDecoration(
                hintText: '별명을 입력하세요',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.blue.shade400),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade400,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _memberNicknames[member] = nicknameController.text;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      '${nicknameController.text.isEmpty ? "별명이 제거되었습니다" : "별명이 저장되었습니다: ${nicknameController.text}"}'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }
}
