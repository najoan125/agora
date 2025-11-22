// 앱 버전 및 정보 화면
import 'package:flutter/material.dart';

class AppInfoScreen extends StatelessWidget {
  const AppInfoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '앱 정보',
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
            // 앱 로고 및 정보
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Center(
                      child: Text(
                        '💬',
                        style: TextStyle(fontSize: 60),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Agora',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '버전 1.0.0',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Build 1 (2024.01)',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            // 앱 소개
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Agora는 간단하고 빠른 메시징 앱입니다. 친구들과 실시간으로 대화하고, 파일을 공유하며, 그룹 채팅을 즐길 수 있습니다.\n\n현재 베타 버전으로 제공되고 있습니다.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const Divider(),

            // 앱 정보 섹션
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              alignment: Alignment.centerLeft,
              child: const Text(
                '정보',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            _buildInfoTile(
              icon: Icons.info_outline,
              title: '앱 이름',
              value: 'Agora Messenger',
            ),
            const Divider(height: 1, indent: 56),
            _buildInfoTile(
              icon: Icons.tag,
              title: '버전',
              value: '1.0.0',
            ),
            const Divider(height: 1, indent: 56),
            _buildInfoTile(
              icon: Icons.build,
              title: 'Build Number',
              value: '1',
            ),
            const Divider(height: 1, indent: 56),
            _buildInfoTile(
              icon: Icons.calendar_today,
              title: '출시일',
              value: '2024년 1월',
            ),
            const SizedBox(height: 20),

            // 개발 정보 섹션
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              alignment: Alignment.centerLeft,
              child: const Text(
                '개발',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            _buildInfoTile(
              icon: Icons.flutter_dash,
              title: 'Framework',
              value: 'Flutter 3.x',
            ),
            const Divider(height: 1, indent: 56),
            _buildInfoTile(
              icon: Icons.code,
              title: 'Language',
              value: 'Dart 3.0+',
            ),
            const Divider(height: 1, indent: 56),
            _buildInfoTile(
              icon: Icons.design_services,
              title: 'Design System',
              value: 'Material Design 3',
            ),
            const SizedBox(height: 20),

            // 지원 플랫폼
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              alignment: Alignment.centerLeft,
              child: const Text(
                '지원 플랫폼',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildPlatformRow('🤖 Android', 'Flutter standard minimum'),
                  const SizedBox(height: 12),
                  _buildPlatformRow('🍎 iOS', 'iOS 11.0+'),
                  const SizedBox(height: 12),
                  _buildPlatformRow('🌐 Web', 'Modern browsers'),
                  const SizedBox(height: 12),
                  _buildPlatformRow('🐧 Linux', 'GTK 3.0+'),
                  const SizedBox(height: 12),
                  _buildPlatformRow('🍏 macOS', 'macOS 10.11+'),
                  const SizedBox(height: 12),
                  _buildPlatformRow('🪟 Windows', 'Windows 7+'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 법적 정보
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              alignment: Alignment.centerLeft,
              child: const Text(
                '법적 정보',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              leading: const Icon(Icons.description, color: Colors.grey),
              title: const Text(
                '이용약관',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: const Icon(Icons.open_in_new, color: Colors.grey, size: 18),
              onTap: () {
                _showTermsDialog(context);
              },
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              leading: const Icon(Icons.privacy_tip, color: Colors.grey),
              title: const Text(
                '개인정보 처리방침',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: const Icon(Icons.open_in_new, color: Colors.grey, size: 18),
              onTap: () {
                _showPrivacyDialog(context);
              },
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              leading: const Icon(Icons.gavel, color: Colors.grey),
              title: const Text(
                '라이센스',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: const Icon(Icons.open_in_new, color: Colors.grey, size: 18),
              onTap: () {
                _showLicenseDialog(context);
              },
            ),
            const SizedBox(height: 20),

            // 지원 연락처
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '문제가 있으신가요?',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '이메일: support@agora.com\n전화: 1234-5678 (평일 9-18시)',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        '문의하기',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 저작권 정보
            Container(
              padding: const EdgeInsets.all(16),
              child: Text(
                '© 2024 Agora. All rights reserved.\n\n이 앱은 개인 프로젝트로 제작되었습니다.',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Icon(icon, color: Colors.grey),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          color: Colors.grey,
        ),
      ),
      trailing: Text(
        value,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPlatformRow(String platform, String requirement) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          platform,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          requirement,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('이용약관'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '제1조 목적\n'
                '본 약관은 Agora 서비스의 이용과 관련하여 회사와 이용자 간의 권리, 의무 및 기타 필요한 사항을 규정하는 것을 목적으로 합니다.\n\n'
                '제2조 용어의 정의\n'
                '"서비스"란 회사가 제공하는 Agora 메신저 및 관련 서비스를 의미합니다.\n\n'
                '제3조 서비스 이용\n'
                '1. 이용자는 본 약관에 동의함으로써 서비스를 이용할 수 있습니다.\n'
                '2. 이용자는 관련 법규를 준수해야 합니다.\n\n'
                '제4조 이용자의 의무\n'
                '1. 이용자는 다른 사용자에게 해를 끼치는 행동을 하지 않아야 합니다.\n'
                '2. 스팸 및 광고성 메시지는 금지됩니다.',
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.8,
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

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('개인정보 처리방침'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '제1조 개인정보의 수집\n'
                'Agora는 서비스 제공을 위해 다음의 개인정보를 수집합니다:\n'
                '- 이름, 이메일 주소\n'
                '- 휴대폰 번호\n'
                '- 프로필 정보\n\n'
                '제2조 개인정보의 이용\n'
                '수집된 정보는 다음의 목적으로 이용됩니다:\n'
                '- 서비스 제공\n'
                '- 계정 관리\n'
                '- 고객 지원\n\n'
                '제3조 개인정보 보호\n'
                'Agora는 고객의 개인정보를 안전하게 보호합니다.\n\n'
                '제4조 개인정보 제3자 제공\n'
                'Agora는 사용자 동의 없이 개인정보를 제3자에게 제공하지 않습니다.',
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.8,
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

  void _showLicenseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('라이센스'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'MIT License\n\n'
                'Copyright (c) 2024 Agora\n\n'
                'Permission is hereby granted, free of charge, to any person obtaining a copy\n'
                'of this software and associated documentation files (the "Software"), to deal\n'
                'in the Software without restriction, including without limitation the rights\n'
                'to use, copy, modify, merge, publish, distribute, sublicense, and/or sell\n'
                'copies of the Software...\n\n'
                '제3자 라이센스:\n'
                '- Flutter: BSD License\n'
                '- Material Design Icons: MIT License\n'
                '- 기타 오픈소스 라이브러리들은 각각의 라이센스를 따릅니다.',
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.6,
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
}
