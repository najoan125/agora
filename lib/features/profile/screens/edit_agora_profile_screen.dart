import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../shared/providers/profile_provider.dart';
import '../../../core/theme.dart';

class EditAgoraProfileScreen extends StatefulWidget {
  const EditAgoraProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditAgoraProfileScreen> createState() => _EditAgoraProfileScreenState();
}

class _EditAgoraProfileScreenState extends State<EditAgoraProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _statusMessageController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileProvider>().myProfile;
    if (profile != null) {
      _displayNameController.text = profile.displayName;
      _statusMessageController.text = profile.statusMessage ?? '';
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _statusMessageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    print('🟢 [EditProfile] 프로필 저장 시작');
    print('📝 표시 이름: ${_displayNameController.text}');
    print('📝 상태 메시지: ${_statusMessageController.text}');
    print('🖼️ 이미지 선택됨: ${_selectedImage != null}');

    final provider = context.read<ProfileProvider>();
    
    // 프로필 정보 업데이트
    print('🔄 [EditProfile] 프로필 정보 업데이트 요청...');
    final success = await provider.updateProfile(
      displayName: _displayNameController.text,
      statusMessage: _statusMessageController.text.isEmpty 
          ? null 
          : _statusMessageController.text,
    );

    print('📊 [EditProfile] 프로필 정보 업데이트 결과: $success');

    // 이미지가 선택되었으면 이미지도 업데이트
    if (_selectedImage != null && success) {
      print('🔄 [EditProfile] 프로필 이미지 업데이트 요청...');
      await provider.updateProfileImage(_selectedImage!);
      print('📊 [EditProfile] 프로필 이미지 업데이트 완료');
    }

    if (mounted) {
      if (success) {
        print('✅ [EditProfile] 프로필 저장 성공!');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('프로필이 업데이트되었습니다.')),
        );
        Navigator.pop(context);
      } else {
        print('❌ [EditProfile] 프로필 저장 실패: ${provider.error}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.error ?? '프로필 업데이트에 실패했습니다.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Agora 프로필 수정',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text(
              '저장',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final profile = provider.myProfile;
          if (profile == null) {
            return const Center(child: Text('프로필을 불러올 수 없습니다.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  
                  // 프로필 이미지
                  GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 2,
                            ),
                          ),
                          child: ClipOval(
                            child: _selectedImage != null
                                ? Image.file(
                                    _selectedImage!,
                                    fit: BoxFit.cover,
                                  )
                                : (profile.profileImageUrl != null
                                    ? Image.network(
                                        profile.profileImageUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Center(
                                            child: Icon(
                                              Icons.person,
                                              size: 50,
                                              color: AppTheme.textSecondary,
                                            ),
                                          );
                                        },
                                      )
                                    : const Center(
                                        child: Icon(
                                          Icons.person,
                                          size: 50,
                                          color: AppTheme.textSecondary,
                                        ),
                                      )),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade400,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _pickImage,
                    child: Text(
                      '이미지 변경',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Agora ID (읽기 전용)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Agora ID',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      profile.agoraId,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // 표시 이름
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '표시 이름',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _displayNameController,
                    decoration: InputDecoration(
                      hintText: '다른 사용자에게 보여질 이름',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue.shade400),
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
                  
                  const SizedBox(height: 20),
                  
                  // 상태 메시지
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '상태 메시지',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _statusMessageController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: '상태 메시지를 입력하세요',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue.shade400),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
