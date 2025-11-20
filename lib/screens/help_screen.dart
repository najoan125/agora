import 'package:flutter/material.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final List<FAQItem> faqs = [
    FAQItem(
      question: '계정을 어떻게 생성하나요?',
      answer:
          '로그인 화면에서 "회원가입" 버튼을 클릭하고 이메일과 비밀번호를 입력하면 계정이 생성됩니다. 유효한 이메일 주소와 8자 이상의 비밀번호가 필요합니다.',
    ),
    FAQItem(
      question: '비밀번호를 잊어버렸어요.',
      answer:
          '로그인 화면에서 "비밀번호 찾기" 버튼을 클릭하세요. 등록된 이메일 주소를 입력하면 비밀번호 재설정 링크를 받을 수 있습니다.',
    ),
    FAQItem(
      question: '친구를 어떻게 추가하나요?',
      answer:
          '홈 화면의 "친구 추가" 버튼을 클릭하고 친구의 이메일이나 사용자명을 입력하세요. 친구 요청이 전송되고 상대방이 수락하면 친구가 됩니다.',
    ),
    FAQItem(
      question: '그룹 채팅을 어떻게 만드나요?',
      answer:
          '채팅 화면에서 "+" 버튼을 클릭하고 "그룹 채팅 생성"을 선택하세요. 그룹 이름을 입력하고 참여할 친구들을 선택하면 그룹이 생성됩니다.',
    ),
    FAQItem(
      question: '메시지를 삭제할 수 있나요?',
      answer:
          '메시지를 길게 눌러 더보기 메뉴를 열고 "삭제"를 선택하세요. 삭제된 메시지는 복구할 수 없습니다.',
    ),
    FAQItem(
      question: '누군가를 차단하려면 어떻게 하나요?',
      answer:
          '상대방의 프로필을 열고 "차단" 버튼을 클릭하세요. 차단한 사용자는 당신에게 메시지를 보낼 수 없으며, 보안 설정에서 차단 목록을 관리할 수 있습니다.',
    ),
    FAQItem(
      question: '알림을 어떻게 설정하나요?',
      answer:
          '더보기 > 알림 설정에서 알림 옵션을 관리할 수 있습니다. 전체 알림, 메시지 알림, 소리, 진동 등을 개별적으로 활성화/비활성화할 수 있습니다.',
    ),
    FAQItem(
      question: '프로필 정보를 어떻게 변경하나요?',
      answer:
          '더보기 > 프로필 수정에서 이름, 프로필 사진, 상태 메시지 등을 변경할 수 있습니다.',
    ),
    FAQItem(
      question: '계정을 어떻게 삭제하나요?',
      answer:
          '더보기 > 보안 > 계정 삭제에서 계정을 삭제할 수 있습니다. 계정 삭제는 되돌릴 수 없으므로 신중하게 결정하세요.',
    ),
    FAQItem(
      question: '앱이 작동하지 않아요.',
      answer:
          '1. 앱을 완전히 종료하고 다시 실행해보세요.\n2. 인터넷 연결을 확인하세요.\n3. 앱 캐시를 삭제해보세요.\n4. 문제가 계속되면 고객 지원팀에 문의하세요.',
    ),
  ];

  List<FAQItem> filteredFaqs = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    filteredFaqs = faqs;
  }

  void _filterFAQs(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredFaqs = faqs;
      } else {
        filteredFaqs = faqs
            .where((faq) =>
                faq.question.toLowerCase().contains(query.toLowerCase()) ||
                faq.answer.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '도움말',
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
            // 검색창
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                onChanged: _filterFAQs,
                decoration: InputDecoration(
                  hintText: '검색...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),

            // FAQ 섹션 제목
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              alignment: Alignment.centerLeft,
              child: Text(
                '자주 묻는 질문 (${filteredFaqs.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // FAQ 목록
            if (filteredFaqs.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredFaqs.length,
                itemBuilder: (context, index) {
                  return _buildFAQItem(filteredFaqs[index]);
                },
              )
            else
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    const Icon(
                      Icons.search_off,
                      size: 48,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '검색 결과가 없습니다',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // 문의 섹션
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '더 많은 도움이 필요하신가요?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '위에서 찾지 못한 답변이 있으면 저희에게 문의하세요.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _showContactDialog(context);
                      },
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

            // 유용한 링크
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              alignment: Alignment.centerLeft,
              child: const Text(
                '유용한 링크',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              leading: const Icon(Icons.language, color: Colors.blue),
              title: const Text('공식 웹사이트'),
              trailing: const Icon(Icons.open_in_new, color: Colors.grey),
              onTap: () {},
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              leading: const Icon(Icons.bug_report, color: Colors.blue),
              title: const Text('버그 신고'),
              trailing: const Icon(Icons.open_in_new, color: Colors.grey),
              onTap: () {},
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              leading: const Icon(Icons.feedback, color: Colors.blue),
              title: const Text('피드백 보내기'),
              trailing: const Icon(Icons.open_in_new, color: Colors.grey),
              onTap: () {},
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(FAQItem faq) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
      ),
      child: ExpansionTile(
        title: Text(
          faq.question,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(height: 1),
                const SizedBox(height: 12),
                Text(
                  faq.answer,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('문의하기'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '문의 주제',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              items: ['버그 신고', '피드백', '기술 지원', '기타']
                  .map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? value) {},
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '상세 내용',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: '문의 내용을 입력하세요',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(12),
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
                const SnackBar(content: Text('문의가 전송되었습니다. 감사합니다!')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
            child: const Text('전송'),
          ),
        ],
      ),
    );
  }
}

class FAQItem {
  final String question;
  final String answer;

  FAQItem({required this.question, required this.answer});
}
