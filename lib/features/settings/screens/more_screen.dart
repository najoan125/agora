// 더보기 및 설정 메뉴 화면
import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../data/data_manager.dart';
import '../../profile/screens/profile_screen.dart';
import 'notification_settings_screen.dart';
import 'privacy_settings_screen.dart';
import 'security_settings_screen.dart';
import 'help_screen.dart';
import 'app_info_screen.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({Key? key}) : super(key: key);

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  final DataManager _dataManager = DataManager();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (Navigator.canPop(context)) ...[
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new,
                          color: AppTheme.textPrimary),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Text(
                    '더보기',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildProfileCard(),
              const SizedBox(height: 32),
              Text(
                '설정',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              _buildSettingsList(),
              const SizedBox(height: 32),
              _buildLogoutButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    final user = _dataManager.currentUser;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfileScreen(user: user)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                image: user['image'] != null
                    ? DecorationImage(
                        image: NetworkImage(user['image']),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: user['image'] == null
                  ? Center(
                      child: Text(user['avatar'] ?? '👤',
                          style: const TextStyle(fontSize: 30)),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user['name'] ?? 'Unknown',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user['email'] ?? '',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsList() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingItem(
            icon: Icons.notifications_outlined,
            title: '알림',
            color: Colors.blue,
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const NotificationSettingsScreen())),
          ),
          _buildDivider(),
          _buildSettingItem(
            icon: Icons.block_outlined,
            title: '차단된 사용자',
            color: Colors.red,
            onTap: () => _showBlockedListDialog(context),
          ),
          _buildDivider(),
          _buildSettingItem(
            icon: Icons.privacy_tip_outlined,
            title: '개인정보',
            color: Colors.green,
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const PrivacySettingsScreen())),
          ),
          _buildDivider(),
          _buildSettingItem(
            icon: Icons.security_outlined,
            title: '보안',
            color: Colors.orange,
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const SecuritySettingsScreen())),
          ),
          _buildDivider(),
          _buildSettingItem(
            icon: Icons.help_outline,
            title: '도움말 및 지원',
            color: Colors.purple,
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const HelpScreen())),
          ),
          _buildDivider(),
          _buildSettingItem(
            icon: Icons.info_outline,
            title: '앱 정보',
            color: Colors.grey,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AppInfoScreen())),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: AppTheme.textPrimary,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios,
          size: 14, color: AppTheme.textSecondary),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
        height: 1, thickness: 1, color: Colors.grey[100], indent: 60);
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () => _showLogoutDialog(context),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: AppTheme.errorColor.withOpacity(0.1),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: const Text(
          '로그아웃',
          style: TextStyle(
            color: AppTheme.errorColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃 하시겠습니까?'),
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
            child: const Text('로그아웃',
                style: TextStyle(color: AppTheme.errorColor)),
          ),
        ],
      ),
    );
  }

  void _showBlockedListDialog(BuildContext context) {
    final blockedUsers = _dataManager.blockedUsers;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('차단된 사용자'),
          content: SizedBox(
            width: double.maxFinite,
            child: blockedUsers.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('차단된 사용자가 없습니다', textAlign: TextAlign.center),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: blockedUsers.length,
                    itemBuilder: (context, index) {
                      final user = blockedUsers[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.surfaceColor,
                          child: Text(user['avatar'] ?? '👤'),
                        ),
                        title: Text(user['name']),
                        trailing: TextButton(
                          onPressed: () {
                            setState(() {
                              _dataManager.unblockUser(user['name']);
                            });
                          },
                          child: const Text('차단 해제'),
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('닫기'),
            ),
          ],
        ),
      ),
    );
  }
}
