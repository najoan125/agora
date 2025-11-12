import 'package:flutter/material.dart';

// 이용약관 및 개인정보처리방침을 표시하는 페이지

class PolicyScreen extends StatelessWidget {
  final String title;
  final String content;

  const PolicyScreen({
    Key? key,
    required this.title,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.centerRight,
          child: Scrollbar(
            thumbVisibility: true,
            thickness: 8,
            radius: const Radius.circular(4),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  content,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.6,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 이용약관 내용
const String termsOfServiceContent = '''
이용약관

1. 총칙
본 이용약관은 Agora 서비스(이하 "서비스")를 이용함에 있어 회사와 이용자의 권리, 의무 및 책임사항을 규정합니다.

2. 서비스의 이용
2.1 서비스는 만 14세 이상의 이용자만 이용할 수 있습니다.
2.2 이용자는 본 약관에 동의함으로써 서비스 이용 계약이 성립됩니다.
2.3 회사는 서비스의 내용을 변경할 수 있으며, 변경 시 이용자에게 통보합니다.

3. 이용자의 의무
3.1 이용자는 타인의 개인정보를 무단으로 사용할 수 없습니다.
3.2 이용자는 서비스를 불법적인 목적으로 이용할 수 없습니다.
3.3 이용자는 타인을 괴롭히거나 명예를 훼손하는 행위를 할 수 없습니다.

4. 회사의 책임
4.1 회사는 서비스 제공 중 발생하는 직접적인 피해에 대해 책임집니다.
4.2 회사는 이용자의 부주의로 인한 피해에 대해 책임지지 않습니다.
4.3 회사는 천재지변, 전쟁, 테러 등 불가항력적 사유로 인한 서비스 중단에 대해 책임지지 않습니다.

5. 서비스 이용의 제한 및 중지
5.1 회사는 이용자가 본 약관을 위반할 경우 서비스 이용을 제한할 수 있습니다.
5.2 서비스 이용 제한은 위반의 정도에 따라 임시 제한 또는 영구 차단될 수 있습니다.

6. 계약의 해지
6.1 이용자는 언제든지 서비스 이용을 중단할 수 있습니다.
6.2 회사는 이용자의 요청에 따라 계정을 삭제할 수 있습니다.

7. 준거법 및 관할
본 약관은 대한민국 법에 따라 해석되며, 분쟁은 대한민국 법원의 관할에 따릅니다.

부칙
본 이용약관은 2025년 11월 12일부터 시행됩니다.
''';

// 개인정보처리방침 내용
const String privacyPolicyContent = '''
개인정보처리방침

1. 총칙
Agora는 개인정보 보호를 중요하게 생각하며, 개인정보처리방침에 따라 개인정보를 처리합니다.

2. 수집하는 개인정보의 항목 및 수집방법
2.1 수집하는 항목
- 필수항목: 이름, 이메일, 비밀번호, 휴대폰번호
- 선택항목: 프로필 사진, 자기소개

2.2 수집방법
- 회원가입 시 직접 입력
- 서비스 이용 과정에서 자동 수집

3. 개인정보의 이용목적
3.1 회원 관리 및 서비스 제공
3.2 서비스 개선 및 개발
3.3 사용자 지원 및 고객센터 운영
3.4 마케팅 및 광고 (동의한 경우)
3.5 법적 의무 이행

4. 개인정보의 보유 및 이용 기간
4.1 원칙적으로 개인정보 수집 및 이용 목적이 달성되면 즉시 파기합니다.
4.2 관계 법령에서 정한 기간 동안 보관해야 하는 경우 해당 기간 동안 보관합니다.

5. 개인정보의 제3자 제공
5.1 Agora는 개인의 동의 없이 개인정보를 제3자에게 제공하지 않습니다.
5.2 법령의 규정에 의거하거나 수사기관의 요청이 있는 경우는 예외입니다.

6. 개인정보의 안전성 확보 조치
6.1 비밀번호 암호화
6.2 보안 서버 운영
6.3 전송 데이터 암호화
6.4 접근권한 관리

7. 이용자의 권리
7.1 이용자는 개인정보에 대한 접근권, 수정권, 삭제권을 가집니다.
7.2 이용자는 개인정보 처리에 대해 거부할 수 있습니다.

8. 개인정보 보호 담당자
8.1 개인정보 보호에 대한 문의는 support@agora.com으로 연락 바랍니다.

9. 정책 변경
9.1 본 개인정보처리방침은 사전 공지 후 변경될 수 있습니다.

시행일자: 2025년 11월 12일
''';
