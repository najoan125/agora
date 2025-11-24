import 'package:flutter/material.dart';
import '../../../data/data_manager.dart';

class AddPositionScreen extends StatefulWidget {
  final String teamName;
  final VoidCallback onPositionAdded;

  const AddPositionScreen({
    Key? key,
    required this.teamName,
    required this.onPositionAdded,
  }) : super(key: key);

  @override
  State<AddPositionScreen> createState() => _AddPositionScreenState();
}

class _AddPositionScreenState extends State<AddPositionScreen> {
  final TextEditingController _positionNameController = TextEditingController();
  bool _permNotice = false;
  bool _permAddMember = false;
  bool _permManageRoles = false;

  @override
  void dispose() {
    _positionNameController.dispose();
    super.dispose();
  }

  void _createPosition() {
    if (_positionNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('직급 이름을 입력해주세요')),
      );
      return;
    }

    final permissions = <String>[];
    if (_permNotice) permissions.add('notice');
    if (_permAddMember) permissions.add('add_member');
    if (_permManageRoles) permissions.add('manage_roles');

    DataManager().addTeamRole(
      widget.teamName,
      _positionNameController.text,
      permissions,
    );

    widget.onPositionAdded();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('새 직급(섹션) 추가'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '직급 이름',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _positionNameController,
              decoration: InputDecoration(
                hintText: '예: 인턴, 매니저',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              '권한 설정',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            _buildPermissionTile(
              title: '공지사항 등록',
              subtitle: '팀 내 공지사항을 작성하고 게시할 수 있습니다.',
              value: _permNotice,
              onChanged: (val) => setState(() => _permNotice = val),
            ),
            const SizedBox(height: 12),
            _buildPermissionTile(
              title: '팀원 추가',
              subtitle: '새로운 팀원을 초대하거나 추가할 수 있습니다.',
              value: _permAddMember,
              onChanged: (val) => setState(() => _permAddMember = val),
            ),
            const SizedBox(height: 12),
            _buildPermissionTile(
              title: '직급 관리',
              subtitle: '새로운 직급을 생성하고 권한을 설정할 수 있습니다.',
              value: _permManageRoles,
              onChanged: (val) => setState(() => _permManageRoles = val),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: _createPosition,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade400,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              '추가하기',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: CheckboxListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
        value: value,
        onChanged: (val) => onChanged(val!),
        activeColor: Colors.blue.shade400,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
