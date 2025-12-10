import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme.dart';
import '../../../data/services/team_service.dart';
import '../../../data/services/file_service.dart';
import '../../../data/models/team/team.dart';

class EditTeamScreen extends ConsumerStatefulWidget {
  final Team team;

  const EditTeamScreen({
    Key? key,
    required this.team,
  }) : super(key: key);

  @override
  ConsumerState<EditTeamScreen> createState() => _EditTeamScreenState();
}

class _EditTeamScreenState extends ConsumerState<EditTeamScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;
  String? _selectedImagePath;
  bool _isLoading = false;
  bool _imageChanged = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.team.name);
    _descriptionController =
        TextEditingController(text: widget.team.description ?? '');
    _selectedImagePath = widget.team.profileImageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
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

  Future<void> _updateTeam() async {
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
          success: (agoraFile) {
            uploadedImageUrl = agoraFile.downloadUrl;
          },
          failure: (error) {
            throw Exception('이미지 업로드 실패: ${error.displayMessage}');
          },
        );
      }

      // 2. 팀 정보 수정
      final teamResult = await teamService.updateTeam(
        widget.team.id.toString(),
        name: _nameController.text != widget.team.name
            ? _nameController.text
            : null,
        description:
            _descriptionController.text != (widget.team.description ?? '')
                ? _descriptionController.text
                : null,
        profileImage: _imageChanged ? uploadedImageUrl : null,
      );

      teamResult.when(
        success: (updatedTeam) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('팀 정보가 수정되었습니다.')),
            );
            Navigator.pop(context, updatedTeam);
          }
        },
        failure: (error) => throw Exception(error.displayMessage),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('팀 정보 수정에 실패했습니다: $e')),
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
          '팀 정보 수정',
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
              // 팀 설명
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
                            '팀 정보',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            '팀의 기본 정보를 수정합니다',
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

              // 팀 프로필 이미지
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
                                            width: 120,
                                            height: 120,
                                          ))
                                    : Image.network(
                                        _selectedImagePath!,
                                        fit: BoxFit.cover,
                                        width: 120,
                                        height: 120,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Icon(
                                            Icons.groups,
                                            size: 60,
                                            color: Colors.grey.shade400,
                                          );
                                        },
                                      ),
                              )
                            : Icon(
                                Icons.groups,
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

              // 팀 이름
              const Text(
                '팀 이름',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: '팀 이름을 입력하세요',
                  prefixIcon: const Icon(Icons.badge_outlined),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: AppTheme.primaryColor, width: 2),
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
                maxLength: 50,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '팀 이름을 입력해주세요.';
                  }
                  if (value.length > 50) {
                    return '팀 이름은 최대 50자까지 가능합니다.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // 팀 설명
              const Text(
                '팀 설명',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  hintText: '팀에 대한 설명을 입력하세요 (선택사항)',
                  prefixIcon: const Icon(Icons.info_outline),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: AppTheme.primaryColor, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                maxLength: 200,
                maxLines: 3,
                validator: (value) {
                  if (value != null && value.length > 200) {
                    return '팀 설명은 최대 200자까지 가능합니다.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 48),

              // 수정 버튼
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateTeam,
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
                          '팀 정보 수정',
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
