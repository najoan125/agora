// 더보기 및 설정 메뉴 화면
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/riverpod_profile_provider.dart';
import '../../../shared/providers/friend_provider.dart';
import '../../profile/screens/edit_agora_profile_screen.dart';
import 'notification_settings_screen.dart';
import 'privacy_settings_screen.dart';
import 'security_settings_screen.dart';
import 'help_screen.dart';
import 'app_info_screen.dart';

class MoreScreen extends ConsumerStatefulWidget {
  const MoreScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends ConsumerState<MoreScreen> {
  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(myProfileProvider);

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
              profileAsync.when(
                loading: () => _buildProfileCardLoading(),
                error: (_, __) => _buildProfileCardError(),
                data: (profile) => _buildProfileCard(profile),
              ),
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

  Widget _buildProfileCardLoading() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }

  Widget _buildProfileCardError() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.error_outline, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '프로필을 불러올 수 없습니다',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                TextButton(
                  onPressed: () => ref.invalidate(myProfileProvider),
                  child: const Text(
                    '다시 시도',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(dynamic profile) {
    final user = profile != null
        ? {
            'name': profile.displayName,
            'agoraId': '@${profile.agoraId}',
            'image': profile.profileImage,
            'avatar': profile.displayName.isNotEmpty ? profile.displayName[0] : '?',
          }
        : {
            'name': '사용자',
            'agoraId': '',
            'image': null,
            'avatar': '?',
          };

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EditAgoraProfileScreen()),
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
                    user['agoraId'] ?? '',
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
    final authState = ref.watch(authProvider);

    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: authState.isLoading ? null : () => _showLogoutDialog(context),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: AppTheme.errorColor.withOpacity(0.1),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: authState.isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text(
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
            onPressed: () async {
              Navigator.pop(context);

              // 로그아웃 처리
              final notifier = ref.read(authProvider.notifier);
              await notifier.logout();

              if (!mounted) return;

              // 로그인 화면으로 이동
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
    final blockedUsersAsync = ref.watch(blockedUsersProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('차단된 사용자'),
        content: SizedBox(
          width: double.maxFinite,
          child: blockedUsersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Text('차단 목록을 불러올 수 없습니다'),
            data: (blockedUsers) {
              if (blockedUsers.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('차단된 사용자가 없습니다', textAlign: TextAlign.center),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                itemCount: blockedUsers.length,
                itemBuilder: (context, index) {
                  final user = blockedUsers[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.surfaceColor,
                      backgroundImage: user.profileImageUrl != null
                          ? NetworkImage(user.profileImageUrl!)
                          : null,
                      child: user.profileImageUrl == null
                          ? Text(user.displayName.isNotEmpty
                              ? user.displayName[0]
                              : '?')
                          : null,
                    ),
                    title: Text(user.displayName),
                    trailing: TextButton(
                      onPressed: () async {
                        final notifier = ref.read(friendActionProvider.notifier);
                        final success = await notifier.unblockUser(user.id);
                        if (success && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${user.displayName}님의 차단을 해제했습니다')),
                          );
                        }
                      },
                      child: const Text('차단 해제'),
                    ),
                  );
                },
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
    );
  }
}
