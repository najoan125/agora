import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme.dart';
import '../../../shared/providers/riverpod_profile_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _statusController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  
  File? _selectedImage;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final profileAsync = ref.read(myProfileProvider);
      profileAsync.whenData((profile) {
        if (profile != null && mounted) {
          _nameController.text = profile.displayName;
          _statusController.text = profile.statusMessage ?? '';
        }
      });
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    print('🖼️ [EditProfile] 이미지 선택 시작');
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
      print('✅ [EditProfile] 이미지 선택됨: ${image.path}');
    } else {
      print('⚠️ [EditProfile] 이미지 선택 취소');
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    print('🟢 [EditProfile] 프로필 저장 시작');
    print('📝 이름: ${_nameController.text}');
    print('📝 상태 메시지: ${_statusController.text}');
    print('🖼️ 이미지 선택됨: ${_selectedImage != null}');

    final notifier = ref.read(profileActionProvider.notifier);

    // 프로필 정보 업데이트
    print('🔄 [EditProfile] 프로필 정보 업데이트 요청...');
    final success = await notifier.updateProfile(
      displayName: _nameController.text,
      bio: _statusController.text.isEmpty
          ? null
          : _statusController.text,
    );

    print('📊 [EditProfile] 프로필 정보 업데이트 결과: $success');

    // 이미지가 선택되었으면 이미지도 업데이트
    if (_selectedImage != null && success) {
      print('🔄 [EditProfile] 프로필 이미지 업데이트 요청...');
      await notifier.updateProfileImage(_selectedImage!);
      print('📊 [EditProfile] 프로필 이미지 업데이트 완료');
    }

    if (mounted) {
      if (success) {
        print('✅ [EditProfile] 프로필 저장 성공!');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('프로필이 업데이트되었습니다.')),
        );
        Navigator.pop(context, true);
      } else {
        print('❌ [EditProfile] 프로필 저장 실패: ${ref.read(profileActionProvider).error}');
        final errorMessage = ref.read(profileActionProvider).error ?? '프로필 업데이트에 실패했습니다.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '프로필 편집',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text(
              '완료',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          final profileAsync = ref.watch(myProfileProvider);
          final actionState = ref.watch(profileActionProvider);

          return profileAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text('프로필을 불러올 수 없습니다: $error'),
            ),
            data: (profile) {
              if (profile == null) {
                // 프로필이 없으면 안내 메시지와 프로필 생성 버튼 표시
                return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.person_off_outlined,
                      size: 80,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Agora 프로필이 없습니다',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '먼저 Agora 프로필을 생성해주세요.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // 프로필 생성 화면으로 이동
                        Navigator.pushNamed(context, '/create-profile');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '프로필 생성하기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
                );
              }

              // 프로필 데이터가 로드되면 컨트롤러 초기화
              if (_nameController.text.isEmpty) {
                _nameController.text = profile.displayName;
                _statusController.text = profile.statusMessage ?? '';
              }

              return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildProfileImage(profile),
                  const SizedBox(height: 32),
                  _buildTextField(
                    controller: _nameController,
                    label: '이름',
                    hint: '이름을 입력하세요',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '이름을 입력해주세요.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildTextField(
                    controller: _statusController,
                    label: '상태 메시지',
                    hint: '상태 메시지를 입력하세요',
                    maxLines: 3,
                  ),
                ],
              ),
            ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildProfileImage(dynamic profile) {
    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.surfaceColor, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
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
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AppTheme.surfaceColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }
}
