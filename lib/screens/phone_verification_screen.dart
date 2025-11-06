import 'package:flutter/material.dart';

class PhoneVerificationScreen extends StatefulWidget {
  final String initialCountry;
  final String initialPhone;
  final Function(String country, String phone) onVerified;

  const PhoneVerificationScreen({
    Key? key,
    this.initialCountry = '한국 (+82)',
    this.initialPhone = '',
    required this.onVerified,
  }) : super(key: key);

  @override
  State<PhoneVerificationScreen> createState() =>
      _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  late TextEditingController _phoneController;
  late TextEditingController _verificationCodeController;
  String _selectedCountry = '한국 (+82)';
  bool _isVerificationSent = false;
  bool _isVerified = false;
  bool _isLoading = false;

  final Map<String, String> countryList = {
    '한국 (+82)': '82',
    '미국 (+1)': '1',
    '일본 (+81)': '81',
    '중국 (+86)': '86',
    '대만 (+886)': '886',
    '홍콩 (+852)': '852',
    '싱가포르 (+65)': '65',
    '태국 (+66)': '66',
    '베트남 (+84)': '84',
    '필리핀 (+63)': '63',
    '영국 (+44)': '44',
    '프랑스 (+33)': '33',
    '독일 (+49)': '49',
    '스페인 (+34)': '34',
    '캐나다 (+1)': '1',
    '호주 (+61)': '61',
  };

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.initialPhone);
    _verificationCodeController = TextEditingController();
    _selectedCountry = widget.initialCountry;
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _verificationCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '전화번호 인증',
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
            // 진행 상황 표시
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildProgressStep(1, '전화번호', true),
                      _buildProgressLine(_isVerificationSent),
                      _buildProgressStep(
                        2,
                        '인증',
                        _isVerificationSent,
                      ),
                      _buildProgressLine(_isVerified),
                      _buildProgressStep(3, '완료', _isVerified),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 단계 1: 전화번호 입력
            if (!_isVerified) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                alignment: Alignment.centerLeft,
                child: const Text(
                  '전화번호 입력',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),

              // 국가 선택
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '국가/지역',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedCountry,
                      items: countryList.keys.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedCountry = newValue;
                          });
                        }
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 전화번호 입력
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '전화번호',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      enabled: !_isVerificationSent,
                      decoration: InputDecoration(
                        hintText: '전화번호를 입력하세요',
                        prefixText: '${countryList[_selectedCountry]} ',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 인증 코드 전송 버튼
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isVerificationSent || _isLoading
                        ? null
                        : () {
                            _sendVerificationCode();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            '인증 코드 전송',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],

            // 단계 2: 인증 코드 입력
            if (_isVerificationSent && !_isVerified) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                alignment: Alignment.centerLeft,
                child: const Text(
                  '인증 코드 입력',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),

              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '전송된 6자리 코드를 입력하세요',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _verificationCodeController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 24),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 인증 확인 버튼
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            _verifyCode();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            '인증 확인',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 코드 재전송
              Center(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _isVerificationSent = false;
                      _verificationCodeController.clear();
                    });
                  },
                  child: const Text(
                    '다시 전송',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],

            // 단계 3: 인증 완료
            if (_isVerified) ...[
              Container(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 48,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '인증 완료',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${countryList[_selectedCountry]}-${_phoneController.text}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onVerified(_selectedCountry, _phoneController.text);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      '완료',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],

            // 정보 박스
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '• 전화번호는 SMS로 인증 코드를 전송받습니다\n'
                '• 통신사 요금이 부과될 수 있습니다\n'
                '• 인증 코드는 10분 이내에 입력해주세요',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue,
                  height: 1.6,
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressStep(int step, String label, bool isActive) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isActive ? Colors.blue : Colors.grey[300],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: isActive
                  ? Text(
                      step.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : const SizedBox(),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isActive ? Colors.blue : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressLine(bool isActive) {
    return Container(
      height: 2,
      margin: const EdgeInsets.only(top: 18),
      color: isActive ? Colors.blue : Colors.grey[300],
    );
  }

  void _sendVerificationCode() {
    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
        _isVerificationSent = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('인증 코드가 전송되었습니다'),
          duration: Duration(seconds: 2),
        ),
      );
    });
  }

  void _verifyCode() {
    if (_verificationCodeController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('6자리 코드를 입력해주세요'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
        _isVerified = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('인증되었습니다'),
          duration: Duration(seconds: 2),
        ),
      );
    });
  }
}
