import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../shared/providers/profile_provider.dart';
import '../../../core/theme.dart';
import '../../main/main_screen.dart';

class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({Key? key}) : super(key: key);

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _agoraIdController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _statusMessageController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  
  File? _selectedImage;
  String? _selectedImagePath;
  bool _isCheckingId = false;
  bool? _isIdAvailable;

  @override
  void dispose() {
    _agoraIdController.dispose();
    _displayNameController.dispose();
    _statusMessageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImagePath = image.path;
        if (!kIsWeb) {
          _selectedImage = File(image.path);
        }
      });
    }
  }

  Future<void> _checkAgoraId() async {
    if (_agoraIdController.text.isEmpty) return;

    setState(() {
      _isCheckingId = true;
      _isIdAvailable = null;
    });

    final provider = context.read<ProfileProvider>();
    final available = await provider.checkAgoraIdAvailable(_agoraIdController.text);

    setState(() {
      _isCheckingId = false;
      _isIdAvailable = available;
    });
  }

  Future<void> _createProfile() async {
    if (!_formKey.currentState!.validate()) return;

    // TODO: 백엔드에서 /api/agora/profile/check-id 엔드포인트를 인증 없이 접근 가능하도록 설정 후 주석 해제
    // if (_isIdAvailable != true) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Agora ID 중복 확인을 해주세요.')),
    //   );
    //   return;
    // }


    final provider = context.read<ProfileProvider>();
    
    final success = await provider.createProfile(
      agoraId: _agoraIdController.text,
      displayName: _displayNameController.text,
      statusMessage: _statusMessageController.text.isEmpty 
          ? null 
          : _statusMessageController.text,
    );

    if (success) {
      // 이미지가 있으면 업로드
      if (_selectedImage != null) {
        await provider.updateProfileImage(_selectedImage!);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('프로필이 생성되었습니다.')),
        );
        // 메인 화면으로 이동 (이전 화면들을 모두 제거)
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainScreen()),
          (route) => false,
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.error ?? '프로필 생성에 실패했습니다.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo Area
                  Container(
                    child: SvgPicture.asset(
                      'assets/images/logo.original.svg',
                      width: 120,
                      height: 120,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Title Text
                  const Text(
                    '프로필 생성',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Agora에서 사용할 프로필을 설정해주세요',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Profile Creation Card
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Consumer<ProfileProvider>(
                      builder: (context, provider, child) {
                        return Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // 프로필 이미지
                              Center(
                                child: GestureDetector(
                                  onTap: _pickImage,
                                  child: Stack(
                                    children: [
                                      Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.grey.shade200,
                                            width: 2,
                                          ),
                                        ),
                                        child: _selectedImagePath != null
                                            ? ClipOval(
                                                child: kIsWeb
                                                    ? Image.network(
                                                        _selectedImagePath!,
                                                        fit: BoxFit.cover,
                                                        width: 100,
                                                        height: 100,
                                                      )
                                                    : Image.file(
                                                        _selectedImage!,
                                                        fit: BoxFit.cover,
                                                      ),
                                              )
                                            : Icon(
                                                Icons.person,
                                                size: 50,
                                                color: Colors.grey.shade400,
                                              ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primaryColor,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 2,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.camera_alt,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Center(
                                child: TextButton(
                                  onPressed: _pickImage,
                                  child: Text(
                                    _selectedImagePath != null ? '이미지 변경' : '이미지 선택',
                                    style: TextStyle(
                                      color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Agora ID
                              TextFormField(
                                controller: _agoraIdController,
                                decoration: InputDecoration(
                                  labelText: 'Agora ID',
                                  hintText: '영문, 숫자 조합',
                                  prefixIcon: const Icon(Icons.alternate_email),
                                  suffixIcon: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (_isIdAvailable == true)
                                        const Padding(
                                          padding: EdgeInsets.only(right: 8.0),
                                          child: Icon(Icons.check_circle, color: Colors.green),
                                        ),
                                      if (_isIdAvailable == false)
                                        const Padding(
                                          padding: EdgeInsets.only(right: 8.0),
                                          child: Icon(Icons.cancel, color: Colors.red),
                                        ),
                                      TextButton(
                                        onPressed: _isCheckingId ? null : _checkAgoraId,
                                        child: _isCheckingId
                                            ? const SizedBox(
                                                width: 16,
                                                height: 16,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                ),
                                              )
                                            : const Text('중복확인'),
                                      ),
                                    ],
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey.shade200),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Agora ID를 입력해주세요.';
                                  }
                                  if (value.length < 3) {
                                    return 'Agora ID는 최소 3글자 이상이어야 합니다.';
                                  }
                                  if (value.length > 50) {
                                    return 'Agora ID는 최대 50글자까지 가능합니다.';
                                  }
                                  if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
                                    return '영문과 숫자만 사용 가능합니다.';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  setState(() {
                                    _isIdAvailable = null;
                                  });
                                },
                              ),
                              if (_isIdAvailable == false)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4, left: 12),
                                  child: Text(
                                    '이미 사용 중인 ID입니다.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.red.shade600,
                                    ),
                                  ),
                                ),
                              if (_isIdAvailable == true)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4, left: 12),
                                  child: Text(
                                    '사용 가능한 ID입니다.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.green.shade600,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 16),

                              // Display Name
                              TextFormField(
                                controller: _displayNameController,
                                decoration: InputDecoration(
                                  labelText: '표시 이름',
                                  hintText: '다른 사용자에게 보여질 이름',
                                  prefixIcon: const Icon(Icons.badge_outlined),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey.shade200),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return '표시 이름을 입력해주세요.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Status Message
                              TextFormField(
                                controller: _statusMessageController,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  labelText: '상태 메시지 (선택)',
                                  hintText: '나를 표현하는 한마디',
                                  alignLabelWithHint: true,
                                  prefixIcon: const Padding(
                                    padding: EdgeInsets.only(bottom: 48),
                                    child: Icon(Icons.chat_bubble_outline),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey.shade200),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                ),
                              ),
                              const SizedBox(height: 32),

                              // Create Button
                              SizedBox(
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: provider.isLoading ? null : _createProfile,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 8,
                                    shadowColor: AppTheme.primaryColor.withOpacity(0.4),
                                  ),
                                  child: provider.isLoading
                                      ? const SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          '프로필 생성 완료',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
