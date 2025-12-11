// 보안 설정 화면
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers/settings_provider.dart';

class SecuritySettingsScreen extends ConsumerStatefulWidget {
  const SecuritySettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends ConsumerState<SecuritySettingsScreen> {
  bool _twoFactorAuth = false;
  bool _biometricAuth = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '보안',
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
            // 비밀번호
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '비밀번호',
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
              leading: const Icon(Icons.lock_outline, color: Colors.grey),
              title: const Text(
                '비밀번호 변경',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: const Text(
                '정기적으로 비밀번호를 변경하면 계정이 더 안전합니다',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {
                _showChangePasswordDialog(context);
              },
            ),
            const SizedBox(height: 20),

            // 2단계 인증
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '인증',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            _buildSwitchTile(
              title: '2단계 인증',
              subtitle: '계정 보안을 강화하기 위해 2단계 인증을 사용합니다',
              value: _twoFactorAuth,
              onChanged: (value) {
                setState(() {
                  _twoFactorAuth = value;
                });
                if (value) {
                  _show2FASetupDialog(context);
                }
              },
            ),
            const Divider(height: 1),
            _buildSwitchTile(
              title: '생체인증 로그인',
              subtitle: '지문 또는 얼굴 인식으로 로그인합니다',
              value: _biometricAuth,
              onChanged: (value) {
                setState(() {
                  _biometricAuth = value;
                });
                if (value) {
                  _showBiometricSetupDialog(context);
                }
              },
            ),
            const SizedBox(height: 20),

            // 로그인 세션
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '로그인 세션',
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
              leading: const Icon(Icons.devices, color: Colors.grey),
              title: const Text(
                '활성 세션 관리',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: const Text(
                '다른 기기에서의 로그인 세션을 관리합니다',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {
                _showActiveSessions(context);
              },
            ),
            const SizedBox(height: 20),

            // 차단 목록
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
              leading: const Icon(Icons.block, color: Colors.grey),
              title: const Text(
                '차단 목록',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: const Text(
                '차단한 사용자 목록을 관리합니다',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {
                _showBlockedList(context);
              },
            ),
            const SizedBox(height: 20),

            // 계정 삭제
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                onPressed: () {
                  _showDeleteAccountDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.delete_forever),
                    SizedBox(width: 8),
                    Text('계정 삭제'),
                  ],
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

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('비밀번호 변경'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: '현재 비밀번호',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: '새 비밀번호',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: '비밀번호 확인',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
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
            onPressed: () async {
               if (newPasswordController.text != confirmPasswordController.text) {
                 ScaffoldMessenger.of(context).showSnackBar(
                   const SnackBar(content: Text('새 비밀번호가 일치하지 않습니다.')),
                 );
                 return;
               }
               if (currentPasswordController.text.isEmpty || newPasswordController.text.isEmpty) {
                 ScaffoldMessenger.of(context).showSnackBar(
                   const SnackBar(content: Text('비밀번호를 입력해주세요.')),
                 );
                 return;
               }

              final notifier = ref.read(settingsActionProvider.notifier);
              final success = await notifier.changePassword(
                currentPasswordController.text,
                newPasswordController.text,
                confirmPasswordController.text,
              );

              if (success && mounted) {
                Navigator.pop(context);
                final message = ref.read(settingsActionProvider).successMessage;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(message ?? '비밀번호가 변경되었습니다')),
                );
              } else if (mounted) {
                 final error = ref.read(settingsActionProvider).error;
                 ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(error ?? '비밀번호 변경에 실패했습니다')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
            child: const Text('변경'),
          ),
        ],
      ),
    );
  }

  void _show2FASetupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('2단계 인증 설정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('다음 앱 중 하나를 설치하고 사용하세요:'),
            const SizedBox(height: 12),
            const Text('• Google Authenticator'),
            const Text('• Microsoft Authenticator'),
            const Text('• Authy'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'QR Code Placeholder',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
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
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('2단계 인증이 활성화되었습니다')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showBiometricSetupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('생체인증 설정'),
        content: const Text(
          '지문 또는 얼굴 인식을 사용하여 더 빠르게 로그인할 수 있습니다.\n\n기기의 생체인증 설정을 확인해주세요.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('생체인증이 활성화되었습니다')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showActiveSessions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('활성 세션'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSessionItem('현재 기기 (이 기기)', 'Linux · Chrome · 지금'),
              const Divider(),
              _buildSessionItem('iPhone 12', 'iOS · Safari · 2시간 전'),
              const Divider(),
              _buildSessionItem('Windows PC', 'Windows · Chrome · 1일 전'),
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

  void _showBlockedList(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('차단 목록'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildBlockedUserItem('박영수', '2024년 1월 1일'),
              const Divider(),
              _buildBlockedUserItem('이민준', '2023년 12월 15일'),
              const SizedBox(height: 16),
              const Text(
                '차단한 사용자는 당신에게 메시지를 보낼 수 없습니다.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
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

  Widget _buildSessionItem(String deviceName, String info) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            deviceName,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            info,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockedUserItem(String userName, String blockedDate) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '차단 날짜: $blockedDate',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          TextButton(
            onPressed: () {},
            child: const Text(
              '차단 해제',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('계정 삭제'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '⚠️ 주의',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '계정을 삭제하면 다음과 같은 일이 발생합니다:',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 8),
            const Text(
              '• 모든 개인 정보가 삭제됩니다\n• 모든 채팅 기록이 삭제됩니다\n• 팀원 목록에서 제거됩니다\n• 이 작업은 되돌릴 수 없습니다',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '진행하시겠습니까?',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
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
            onPressed: () {
              Navigator.pop(context);
              _showFinalDeleteConfirmation(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  void _showFinalDeleteConfirmation(BuildContext context) {
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('계정 삭제 확인'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '최종 확인을 위해 비밀번호를 입력하세요',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: '비밀번호',
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
                  borderSide: BorderSide(color: Colors.red.shade400),
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
            onPressed: () {
              if (passwordController.text.isNotEmpty) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('계정이 삭제되었습니다'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
            ),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}
