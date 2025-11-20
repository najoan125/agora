import 'package:flutter/material.dart';
import 'package:agora/screens/notification_settings_screen.dart';
import 'package:agora/screens/privacy_settings_screen.dart';
import 'package:agora/screens/security_settings_screen.dart';
import 'package:agora/screens/help_screen.dart';
import 'package:agora/screens/app_info_screen.dart';
import 'package:agora/screens/edit_profile_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '더보기',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Section
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Text('👤', style: TextStyle(fontSize: 48)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '김철수',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'kim.chulsu@agora.com',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const EditProfileScreen(
                              userName: '김철수',
                              userEmail: 'kim.chulsu@agora.com',
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        '프로필 수정',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),

            // Menu Items
            _buildMenuItem(
              icon: Icons.notifications_outlined,
              title: '알림 설정',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const NotificationSettingsScreen(),
                  ),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.privacy_tip_outlined,
              title: '개인정보 보호',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const PrivacySettingsScreen(),
                  ),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.lock_outlined,
              title: '보안',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SecuritySettingsScreen(),
                  ),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.help_outline,
              title: '도움말',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const HelpScreen(),
                  ),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.info_outline,
              title: '앱 정보',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AppInfoScreen(),
                  ),
                );
              },
            ),

            const Divider(),

            _buildMenuItem(
              icon: Icons.logout,
              title: '로그아웃',
              isDestructive: true,
              onTap: () {
                _showLogoutDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    bool isDestructive = false,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : Colors.grey,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          color: isDestructive ? Colors.red : Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Colors.grey[300],
      ),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말로 로그아웃 하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/',
                (route) => false,
              );
            },
            child: const Text(
              '로그아웃',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
