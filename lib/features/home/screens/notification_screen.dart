import 'package:flutter/material.dart';
import 'package:agora/core/theme.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock notices
    final notices = [
      {
        'title': '2025년 상반기 워크샵 안내',
        'date': '2025.05.20',
        'content': '이번 상반기 워크샵은 제주도에서 진행됩니다. 자세한 일정은 첨부파일을 확인해주세요.',
        'isNew': true,
      },
      {
        'title': '사내 보안 정책 업데이트',
        'date': '2025.05.15',
        'content': '개인정보 보호법 개정에 따라 사내 보안 정책이 업데이트 되었습니다.',
        'isNew': false,
      },
      {
        'title': '5월 가정의 달 휴무 안내',
        'date': '2025.05.01',
        'content': '5월 5일 어린이날 대체 공휴일 휴무 안내드립니다.',
        'isNew': false,
      },
      {
        'title': '신규 입사자 환영회',
        'date': '2025.04.28',
        'content': '4월 신규 입사자 환영회가 이번 주 금요일 라운지에서 열립니다.',
        'isNew': false,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '알림',
          style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: notices.length,
        separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFEEEEEE)),
        itemBuilder: (context, index) {
          final notice = notices[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            title: Row(
              children: [
                if (notice['isNew'] as bool)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'NEW',
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                Expanded(
                  child: Text(
                    notice['title'] as String,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notice['content'] as String,
                    style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notice['date'] as String,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF999999)),
                  ),
                ],
              ),
            ),
            onTap: () {
              // Detail view navigation (mock)
            },
          );
        },
      ),
    );
  }
}
