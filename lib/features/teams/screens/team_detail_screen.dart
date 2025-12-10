// 팀 상세 정보 및 관리 화면
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../chat/screens/team_chat_screen.dart';
import '../../chat/screens/conversation_screen.dart';
import 'add_team_member_screen.dart';
import 'add_position_screen.dart';
import 'org_chart_screen.dart';
import 'create_notice_screen.dart';
import 'notice_list_screen.dart';
import '../../../data/data_manager.dart';
import '../../../data/models/team/team.dart';
import '../../../data/services/team_service.dart';

class TeamDetailScreen extends ConsumerStatefulWidget {
  final Team team;

  const TeamDetailScreen({
    Key? key,
    required this.team,
  }) : super(key: key);

  @override
  ConsumerState<TeamDetailScreen> createState() => _TeamDetailScreenState();
}

class _TeamDetailScreenState extends ConsumerState<TeamDetailScreen> {
  List<TeamMember> _apiMembers = [];
  bool _isLoadingMembers = true;
  late List<String> _members;
  Map<String, List<String>> _membersByRole = {};
  List<Map<String, dynamic>> _roleDefinitions = [];
  late TextEditingController _teamNameController;
  late String _teamName;
  
  // Permissions
  bool _canCreateNotice = false;
  bool _canAddMember = false;
  bool _canManageRoles = false;

  @override
  void initState() {
    super.initState();
    _members = []; // Initialize with empty list, will be loaded from API
    _teamName = widget.team.name;
    _teamNameController = TextEditingController(text: widget.team.name);
    _loadTeamMembers();
    _refreshRoles();
  }

  Future<void> _loadTeamMembers() async {
    final teamService = TeamService();
    final result = await teamService.getTeamMembers(widget.team.id.toString());

    result.when(
      success: (members) {
        if (mounted) {
          setState(() {
            _apiMembers = members;
            _members = members.map((m) => m.effectiveDisplayName).toList();
            _isLoadingMembers = false;
            _refreshRoles();
          });
        }
      },
      failure: (error) {
        if (mounted) {
          setState(() => _isLoadingMembers = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('팀원 목록 로드 실패: ${error.displayMessage}')),
          );
        }
      },
    );
  }

  void _refreshRoles() {
    _roleDefinitions = DataManager().getRoleDefinitions(_teamName);
    
    // Sort roles: specific roles first (by permission count), 'member' last
    _roleDefinitions.sort((a, b) {
      if (a['id'] == 'member') return 1;
      if (b['id'] == 'member') return -1;
      
      final permsA = (a['permissions'] as List).length;
      final permsB = (b['permissions'] as List).length;
      return permsB.compareTo(permsA); // Descending
    });

    _membersByRole = {};
    
    // Initialize lists for each role
    for (var roleDef in _roleDefinitions) {
      _membersByRole[roleDef['id']] = [];
    }
    
    // Group members by role
    for (var member in _members) {
      final roleId = DataManager().getTeamRole(_teamName, member);
      if (_membersByRole.containsKey(roleId)) {
        _membersByRole[roleId]!.add(member);
      } else {
        // Fallback to 'member' or first role if roleId not found
        final defaultRole = _roleDefinitions.isNotEmpty ? _roleDefinitions.last['id'] : 'member';
         if (_membersByRole.containsKey(defaultRole)) {
            _membersByRole[defaultRole]!.add(member);
         }
      }
    }
    
    // Check permissions for current user
    final currentUser = DataManager().currentUser['name'];
    _canCreateNotice = DataManager().checkPermission(_teamName, currentUser, 'notice');
    _canAddMember = DataManager().checkPermission(_teamName, currentUser, 'add_member');
    _canManageRoles = DataManager().checkPermission(_teamName, currentUser, 'manage_roles');
    
    setState(() {});
  }

  @override
  void dispose() {
    _teamNameController.dispose();
    super.dispose();
  }

  void _addTeamMember() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTeamMemberScreen(
          onMembersAdded: (members) async {
            final teamService = TeamService();
            int successCount = 0;

            for (var member in members) {
              final agoraId = member['id'] as String?;
              if (agoraId != null) {
                final result = await teamService.inviteMember(
                  widget.team.id.toString(),
                  agoraId,
                );
                result.when(
                  success: (_) => successCount++,
                  failure: (error) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('초대 실패: ${error.displayMessage}')),
                      );
                    }
                  },
                );
              }
            }

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${successCount}명에게 초대를 보냈습니다')),
              );
              _loadTeamMembers(); // Reload member list
            }
          },
        ),
      ),
    );
  }

  void _removeMember(String memberName) {
    // Find the member in the API members list
    final member = _apiMembers.firstWhere(
      (m) => m.effectiveDisplayName == memberName,
      orElse: () => _apiMembers.first, // Fallback, should not happen
    );

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
            onPressed: () async {
              Navigator.pop(context);

              final teamService = TeamService();
              final result = await teamService.removeMember(
                widget.team.id.toString(),
                member.memberId.toString(),
              );

              result.when(
                success: (_) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$memberName을(를) 제거했습니다')),
                    );
                    _loadTeamMembers(); // Reload member list
                  }
                },
                failure: (error) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('제거 실패: ${error.displayMessage}')),
                    );
                  }
                },
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

  void _leaveTeam() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('팀 나가기'),
        content: const Text('정말로 팀을 나가시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              final currentUser = DataManager().currentUser['name'];
              setState(() {
                _members.remove(currentUser);
                DataManager().removeTeamMember(_teamName, currentUser);
                _refreshRoles();
              });
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('팀에서 나갔습니다')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
            ),
            child: const Text('나가기'),
          ),
        ],
      ),
    );
  }

  void _showChangeRoleDialog(String memberName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('직급 변경'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _roleDefinitions.map((role) {
            return ListTile(
              title: Text(role['name']),
              onTap: () {
                setState(() {
                  DataManager().setTeamRole(_teamName, memberName, role['id']);
                  _refreshRoles();
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$memberName님의 직급이 ${role['name']}(으)로 변경되었습니다')),
                );
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
        ],
      ),
    );
  }
  
  void _navigateToAddPositionScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPositionScreen(
          teamName: _teamName,
          onPositionAdded: () {
            _refreshRoles();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('새 직급이 추가되었습니다')),
            );
          },
        ),
      ),
    );
  }



  void _navigateToCreateNoticeScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateNoticeScreen(teamName: _teamName),
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
              setState(() {
                _teamName = _teamNameController.text;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('팀 이름이 변경되었습니다: $_teamName'),
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

  void _showDeleteTeamDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('팀 삭제'),
        content: const Text('정말로 팀을 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('팀이 삭제되었습니다'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  void _showChangeNameDialog(String currentName, int index) {
    TextEditingController nameController =
        TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('이름 변경'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$currentName의 이름을 변경하세요',
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: '새로운 이름을 입력하세요',
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
              final newName = nameController.text.trim();
              if (newName.isNotEmpty && newName != currentName) {
                setState(() {
                  DataManager().updateTeamMemberName(_teamName, currentName, newName);
                  _members[index] = newName;
                  _refreshRoles();
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('이름이 변경되었습니다: $newName'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              } else {
                 Navigator.pop(context);
              }
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
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
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NoticeListScreen(teamName: _teamName),
                ),
              );
            },
          ),
          if (_canManageRoles)
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
                  value: 'delete',
                  child: const Row(
                    children: [
                      Icon(Icons.delete_outline, size: 18, color: Colors.red),
                      SizedBox(width: 12),
                      Text('팀 삭제', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'rename') {
                  _showTeamRenameDialog();
                } else if (value == 'delete') {
                  _showDeleteTeamDialog();
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
                          widget.teamImage ??
                              'https://picsum.photos/seed/$_teamName/200/200',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _teamName,
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
                              teamName: _teamName,
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
                ],
              ),
            ),
            
            const SizedBox(height: 24),

            // 팀 관리 섹션 (Permissions Check)
            if (_canCreateNotice || _canAddMember || _canManageRoles) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '팀 관리',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        if (_canCreateNotice)
                          Expanded(
                            child: _buildManagementButton(
                              icon: Icons.campaign_outlined,
                              label: '공지사항 등록',
                              color: Colors.orange.shade400,
                              onTap: _navigateToCreateNoticeScreen,
                            ),
                          ),
                        if (_canCreateNotice && _canAddMember)
                          const SizedBox(width: 12),
                        if (_canAddMember)
                          Expanded(
                            child: _buildManagementButton(
                              icon: Icons.person_add_outlined,
                              label: '팀원 추가',
                              color: Colors.green.shade400,
                              onTap: _addTeamMember,
                            ),
                          ),
                         if (!_canCreateNotice && !_canAddMember)
                           const Spacer(), // Placeholder if only manage roles is available
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Dynamic Role Sections
            ..._roleDefinitions.map((role) {
              final members = _membersByRole[role['id']] ?? [];
              if (members.isEmpty) return const SizedBox.shrink();
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '${role['name']} (${members.length}명)',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: members.map((member) => _buildMemberTile(member, roleName: role['name'])).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              );
            }).toList(),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberTile(String member, {required String roleName}) {
    final isMe = member == DataManager().currentUser['name'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
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
                  DataManager().getMemberImage(member),
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
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  roleName,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<int>(
            itemBuilder: (context) => [
              if (!isMe)
                PopupMenuItem<int>(
                  value: 1,
                  child: const Row(
                    children: [
                      Icon(Icons.message_outlined, size: 18, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('메시지'),
                    ],
                  ),
                ),
              if (_canManageRoles) ...[
                PopupMenuItem<int>(
                  value: 3,
                  child: const Row(
                    children: [
                      Icon(Icons.edit, size: 18, color: Colors.green),
                      SizedBox(width: 8),
                      Text('이름 변경'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                if (isMe)
                  PopupMenuItem<int>(
                    value: 5,
                    child: const Row(
                      children: [
                        Icon(Icons.exit_to_app, size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text('나가기'),
                      ],
                    ),
                  )
                else
                  PopupMenuItem<int>(
                    value: 2,
                    child: const Row(
                      children: [
                        Icon(Icons.delete_outline, size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text('추방'),
                      ],
                    ),
                  ),
              ],
            ],
            onSelected: (value) {
              if (value == 1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ConversationScreen(
                      chatId: '', // TODO: Get or create chat ID for this member
                      userName: member,
                      userImage: DataManager().getMemberImage(member),
                    ),
                  ),
                );
              } else if (value == 2) {
                _removeMember(member);
              } else if (value == 3) {
                final index = _members.indexOf(member);
                if (index != -1) {
                  _showChangeNameDialog(member, index);
                }
              } else if (value == 5) {
                _leaveTeam();
              }
            },
          ),
        ],
      ),
    );
  }



}
