import 'package:flutter/material.dart';
import 'conversation_screen.dart';

class ProfileScreen extends StatelessWidget {
  final String userName;
  final String userImage;
  final String status;

  const ProfileScreen({
    Key? key,
    required this.userName,
    required this.userImage,
    this.status = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('상대 프로필'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              CircleAvatar(
                radius: 64,
                backgroundImage: NetworkImage(userImage),
                backgroundColor: Colors.grey[200],
              ),
              const SizedBox(height: 16),
              Text(
                userName,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                status.isNotEmpty ? status : '소개 문구가 없습니다',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.message),
                    label: const Text('메시지'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ConversationScreen(
                            userName: userName,
                            userImage: userImage,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.block),
                    label: const Text('차단'),
                    onPressed: () {
                      // 임시 다이얼로그
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('차단 확인'),
                          content: Text('$userName님을 차단하시겠습니까?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('취소'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('차단되었습니다')),
                                );
                              },
                              child: const Text('차단'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('상세 정보'),
                subtitle: const Text('추가 프로필 정보나 상태 메시지를 여기에 표시할 수 있습니다.'),
              ),
              ListTile(
                leading: const Icon(Icons.report),
                title: const Text('신고하기'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('신고'),
                      content: Text('$userName님을 신고하시겠습니까?'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('취소')),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('신고가 접수되었습니다')),
                            );
                          },
                          child: const Text('신고'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
