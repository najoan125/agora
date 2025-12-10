import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme.dart';
import '../../../data/services/team_service.dart';
import '../../../data/services/file_service.dart';
import '../../../data/models/team/team.dart';

class EditTeamProfileScreen extends ConsumerStatefulWidget {
  final TeamProfile teamProfile;

  const EditTeamProfileScreen({
    Key? key,
    required this.teamProfile,
  }) : super(key: key);

  @override
  ConsumerState<EditTeamProfileScreen> createState() =>
      _EditTeamProfileScreenState();
}

class _EditTeamProfileScreenState
    extends ConsumerState<EditTeamProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _displayNameController;
  late final TextEditingController _bioController;
  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;
  String? _selectedImagePath;
  bool _isLoading = false;
  bool _imageChanged = false;

  @override
  void initState() {
    super.initState();
    // 기존 프로필 데이터로 초기화
    _displayNameController = TextEditingController(text: widget.teamProfile.displayName);
    _bioController = TextEditingController(text: widget.teamProfile.bio ?? '');
    _selectedImagePath = widget.teamProfile.profileImageUrl;
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImagePath = image.path;
        _imageChanged = true;
        if (!kIsWeb) {
          _selectedImage = File(image.path);
        }
      });
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final teamService = TeamService();
      final fileService = FileService();

      String? uploadedImageUrl;

      // 1. 이미지가 변경된 경우 업로드
      if (_imageChanged && _selectedImage != null) {
        final imageResult = await fileService.uploadImage(_selectedImage!);
        imageResult.when(
          success: (fileResponse) {
            uploadedImageUrl = fileResponse.file.downloadUrl;
          },
          failure: (_) {}, // 이미지 업로드 실패는 무시 (선택사항)
        );
      }

      // 2. 팀 프로필 수정
      final profileResult = await teamService.updateTeamProfile(
        displayName: _displayNameController.text != widget.teamProfile.displayName
            ? _displayNameController.text
            : null,
        profileImage: _imageChanged ? uploadedImageUrl : null,
        bio: _bioController.text != (widget.teamProfile.bio ?? '')
            ? _bioController.text
            : null,
      );

      profileResult.when(
        success: (_) {},
        failure: (error) => throw Exception(error.displayMessage),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('팀 프로필이 수정되었습니다.')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('팀 프로필 수정에 실패했습니다: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '팀 프로필 수정',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 프로필 설명
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.groups, color: AppTheme.primaryColor, size: 24),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '팀 프로필',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            '팀원들에게 보여질 프로필입니다',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // 프로필 이미지
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
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
                                child: _imageChanged
                                    ? (kIsWeb
                                        ? Image.network(
                                            _selectedImagePath!,
                                            fit: BoxFit.cover,
                                            width: 120,
                                            height: 120,
                                          )
                                        : Image.file(
                                            _selectedImage!,
                                            fit: BoxFit.cover,
                                          ))
                                    : Image.network(
                                        _selectedImagePath!,
                                        fit: BoxFit.cover,
                                        width: 120,
                                        height: 120,
                                      ),
                              )
                            : Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.grey.shade400,
                              ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 3,
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
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: _pickImage,
                  child: Text(
                    '이미지 변경',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Display Name
              const Text(
                '팀 내 표시 이름',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _displayNameController,
                decoration: InputDecoration(
                  hintText: '팀에서 사용할 닉네임을 입력하세요',
                  prefixIcon: const Icon(Icons.badge_outlined),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                maxLength: 100,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '표시 이름을 입력해주세요.';
                  }
                  if (value.length > 100) {
                    return '표시 이름은 최대 100자까지 가능합니다.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              Text(
                '팀원들에게 표시될 이름입니다.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),

              // Bio
              const Text(
                '소개',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _bioController,
                decoration: InputDecoration(
                  hintText: '자기소개를 입력하세요 (선택사항)',
                  prefixIcon: const Icon(Icons.info_outline),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                maxLength: 200,
                maxLines: 3,
                validator: (value) {
                  if (value != null && value.length > 200) {
                    return '소개는 최대 200자까지 가능합니다.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 48),

              // Update Button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 8,
                    shadowColor: AppTheme.primaryColor.withOpacity(0.4),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          '프로필 수정',
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
        ),
      ),
    );
  }
}
