import 'package:flutter/material.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _allNotifications = true;
  bool _messageNotifications = true;
  bool _groupNotifications = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '알림 설정',
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
            // 알림 설정
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '알림',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            _buildSwitchTile(
              title: '전체 알림',
              subtitle: '모든 알림을 수신합니다',
              value: _allNotifications,
              onChanged: (value) {
                setState(() {
                  _allNotifications = value;
                });
              },
            ),
            const Divider(height: 1),
            _buildSwitchTile(
              title: '메시지 알림',
              subtitle: '1:1 메시지 알림을 수신합니다',
              value: _messageNotifications,
              onChanged: (value) {
                setState(() {
                  _messageNotifications = value;
                });
              },
            ),
            const Divider(height: 1),
            _buildSwitchTile(
              title: '그룹 메시지 알림',
              subtitle: '팀 메시지 알림을 수신합니다',
              value: _groupNotifications,
              onChanged: (value) {
                setState(() {
                  _groupNotifications = value;
                });
              },
            ),
            const SizedBox(height: 20),

            // 소리 및 진동
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '소리 및 진동',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            _buildSwitchTile(
              title: '소리',
              subtitle: '알림 시 소리가 울립니다',
              value: _soundEnabled,
              onChanged: (value) {
                setState(() {
                  _soundEnabled = value;
                });
              },
            ),
            const Divider(height: 1),
            _buildSwitchTile(
              title: '진동',
              subtitle: '알림 시 진동합니다',
              value: _vibrationEnabled,
              onChanged: (value) {
                setState(() {
                  _vibrationEnabled = value;
                });
              },
            ),
            const SizedBox(height: 20),

            // 알림 설정 조언
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '알림이 많으면 방해가 될 수 있습니다. 필요한 알림만 활성화하는 것을 권장합니다.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue,
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
}
