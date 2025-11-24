// 개인정보 보호 설정 화면
import 'package:flutter/material.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({Key? key}) : super(key: key);

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  String _profileVisibility = '모두'; // 모두, 친구만, 나만
  bool _lastSeenVisible = true;
  bool _onlineStatusVisible = true;
  bool _allowGroupInvite = true;
  bool _allowFriendRequest = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '개인정보 보호',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 프로필 공개 범위
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '프로필',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              title: const Text(
                '프로필 공개 범위',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: const Text(
                '누가 내 프로필을 볼 수 있는지 설정합니다',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              trailing: DropdownButton<String>(
                value: _profileVisibility,
                items: ['모두', '친구만', '친구 + 팀원', '나만'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _profileVisibility = newValue;
                    });
                  }
                },
              ),
            ),
            const Divider(height: 1),
            const SizedBox(height: 20),

            // 상태 표시
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '상태 표시',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            _buildSwitchTile(
              title: '마지막 접속 시간 공개',
              subtitle: '친구들이 당신의 마지막 접속 시간을 볼 수 있습니다',
              value: _lastSeenVisible,
              onChanged: (value) {
                setState(() {
                  _lastSeenVisible = value;
                });
              },
            ),
            const Divider(height: 1),
            _buildSwitchTile(
              title: '온라인 상태 공개',
              subtitle: '친구들이 당신이 온라인인지 알 수 있습니다',
              value: _onlineStatusVisible,
              onChanged: (value) {
                setState(() {
                  _onlineStatusVisible = value;
                });
              },
            ),
            const SizedBox(height: 20),

            // 수신 설정
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '수신 설정',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            _buildSwitchTile(
              title: '그룹 초대 수신',
              subtitle: '다른 사용자가 그룹에 초대할 수 있습니다',
              value: _allowGroupInvite,
              onChanged: (value) {
                setState(() {
                  _allowGroupInvite = value;
                });
              },
            ),
            const Divider(height: 1),
            _buildSwitchTile(
              title: '친구 요청 수신',
              subtitle: '다른 사용자가 친구 요청을 보낼 수 있습니다',
              value: _allowFriendRequest,
              onChanged: (value) {
                setState(() {
                  _allowFriendRequest = value;
                });
              },
            ),
            const SizedBox(height: 20),

            // 차단된 사용자
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '차단 관리',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              title: const Text(
                '차단한 사용자 관리',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: const Text(
                '차단한 친구, 팀원, 채팅창을 관리합니다',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {
                _showBlockedUsersManagement(context);
              },
            ),
            const SizedBox(height: 20),

            // 정보 박스
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '개인정보 보호 설정을 변경하면 즉시 적용됩니다.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.amber[900],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.blue,
      ),
    );
  }

  void _showBlockedUsersManagement(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('차단 관리'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '친구',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              _buildBlockedItemTile('박영수', '친구', '2024.01.01'),
              _buildBlockedItemTile('이민준', '친구', '2023.12.15'),
              const SizedBox(height: 16),
              const Text(
                '팀원',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              _buildBlockedItemTile('김철수', '팀원', '2024.01.05'),
              const SizedBox(height: 16),
              const Text(
                '채팅',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              _buildBlockedItemTile('개발팀', '팀 채팅', '2024.01.10'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockedItemTile(String name, String type, String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$type · $date',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(50, 20),
            ),
            child: const Text(
              '해제',
              style: TextStyle(
                fontSize: 11,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
