import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../shared/providers/riverpod_profile_provider.dart';
import '../../../core/theme.dart';

class EditAgoraProfileScreen extends ConsumerStatefulWidget {
  const EditAgoraProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<EditAgoraProfileScreen> createState() => _EditAgoraProfileScreenState();
}

class _EditAgoraProfileScreenState extends ConsumerState<EditAgoraProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _agoraIdController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _phoneController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;
  DateTime? _selectedBirthday;
  String? _originalAgoraId;
  bool _isAgoraIdChanged = false;
  bool _isCheckingAgoraId = false;
  bool? _isAgoraIdAvailable;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileAsync = ref.read(myProfileProvider);
      profileAsync.whenData((profile) {
        if (profile != null && mounted) {
          _originalAgoraId = profile.agoraId;
          _agoraIdController.text = profile.agoraId;
          _displayNameController.text = profile.displayName;
          _bioController.text = profile.bio ?? '';
          _phoneController.text = profile.phone ?? '';
          if (profile.birthday != null) {
            try {
              _selectedBirthday = DateTime.parse(profile.birthday!);
            } catch (e) {
              print('Birthday parse error: $e');
            }
          }
          setState(() {});
        }
      });
    });
  }

  @override
  void dispose() {
    _agoraIdController.dispose();
    _displayNameController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
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

  Future<void> _selectBirthday() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthday ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedBirthday = picked;
      });
    }
  }

  Future<void> _checkAgoraIdAvailability() async {
    final newAgoraId = _agoraIdController.text.trim();
    if (newAgoraId.isEmpty || newAgoraId == _originalAgoraId) {
      setState(() {
        _isAgoraIdAvailable = null;
        _isAgoraIdChanged = false;
      });
      return;
    }

    setState(() {
      _isCheckingAgoraId = true;
      _isAgoraIdChanged = true;
    });

    try {
      final service = ref.read(profileServiceProvider);
      final available = await service.checkAgoraIdAvailable(newAgoraId);
      if (mounted) {
        setState(() {
          _isAgoraIdAvailable = available;
          _isCheckingAgoraId = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAgoraIdAvailable = false;
          _isCheckingAgoraId = false;
        });
      }
    }
  }

  String _formatBirthday(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    // Agora ID 변경 시 중복 확인
    if (_isAgoraIdChanged && _isAgoraIdAvailable != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agora ID 중복 확인이 필요합니다.')),
      );
      return;
    }

    final notifier = ref.read(profileActionProvider.notifier);

    // 프로필 정보 업데이트
    final success = await notifier.updateProfile(
      agoraId: _isAgoraIdChanged ? _agoraIdController.text.trim() : null,
      displayName: _displayNameController.text.trim(),
      bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      birthday: _selectedBirthday != null ? _formatBirthday(_selectedBirthday!) : null,
    );

    // 이미지가 선택되었으면 이미지도 업데이트
    if (_selectedImage != null && success) {
      await notifier.updateProfileImage(_selectedImage!);
    }

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('프로필이 업데이트되었습니다.')),
        );
        Navigator.pop(context);
      } else {
        final errorMessage = ref.read(profileActionProvider).error ?? '프로필 업데이트에 실패했습니다.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    Widget? suffix,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            suffixIcon: suffix,
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          validator: validator,
        ),
      ],
    );
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
                return const Center(child: Text('프로필을 불러올 수 없습니다.'));
              }

              // 프로필 데이터가 로드되면 컨트롤러 초기화
              if (_agoraIdController.text.isEmpty) {
                _originalAgoraId = profile.agoraId;
                _agoraIdController.text = profile.agoraId;
                _displayNameController.text = profile.displayName;
                _bioController.text = profile.bio ?? '';
                _phoneController.text = profile.phone ?? '';
                if (profile.birthday != null) {
                  try {
                    _selectedBirthday = DateTime.parse(profile.birthday!);
                  } catch (e) {
                    // ignore
                  }
                }
              }

              return Stack(
                children: [
                  SingleChildScrollView(
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

                          // Agora ID (수정 가능)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Agora ID',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _agoraIdController,
                                onChanged: (value) {
                                  setState(() {
                                    _isAgoraIdChanged = value != _originalAgoraId;
                                    _isAgoraIdAvailable = null;
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: '3-50자, 영문/숫자/_만 가능',
                                  hintStyle: TextStyle(color: Colors.grey.shade400),
                                  suffixIcon: _isAgoraIdChanged
                                      ? _isCheckingAgoraId
                                          ? const Padding(
                                              padding: EdgeInsets.all(12),
                                              child: SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(strokeWidth: 2),
                                              ),
                                            )
                                          : IconButton(
                                              icon: Icon(
                                                _isAgoraIdAvailable == true
                                                    ? Icons.check_circle
                                                    : Icons.search,
                                                color: _isAgoraIdAvailable == true
                                                    ? Colors.green
                                                    : Colors.blue,
                                              ),
                                              onPressed: _checkAgoraIdAvailability,
                                            )
                                      : null,
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
                                    return 'Agora ID를 입력해주세요.';
                                  }
                                  if (value.length < 3 || value.length > 50) {
                                    return '3-50자 사이로 입력해주세요.';
                                  }
                                  if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                                    return '영문, 숫자, 언더스코어(_)만 사용 가능합니다.';
                                  }
                                  return null;
                                },
                              ),
                              if (_isAgoraIdChanged && _isAgoraIdAvailable != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    _isAgoraIdAvailable!
                                        ? '사용 가능한 ID입니다.'
                                        : '이미 사용 중인 ID입니다.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _isAgoraIdAvailable! ? Colors.green : Colors.red,
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // 표시 이름
                          _buildTextField(
                            controller: _displayNameController,
                            label: '표시 이름',
                            hint: '다른 사용자에게 보여질 이름',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '표시 이름을 입력해주세요.';
                              }
                              if (value.length > 100) {
                                return '100자 이하로 입력해주세요.';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          // 상태 메시지 (bio)
                          _buildTextField(
                            controller: _bioController,
                            label: '상태 메시지',
                            hint: '상태 메시지를 입력하세요',
                            maxLines: 3,
                          ),

                          const SizedBox(height: 20),

                          // 전화번호
                          _buildTextField(
                            controller: _phoneController,
                            label: '전화번호',
                            hint: '010-1234-5678',
                            keyboardType: TextInputType.phone,
                          ),

                          const SizedBox(height: 20),

                          // 생일
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '생일',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: _selectBirthday,
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _selectedBirthday != null
                                            ? _formatBirthday(_selectedBirthday!)
                                            : '생일을 선택하세요',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: _selectedBirthday != null
                                              ? Colors.black
                                              : Colors.grey.shade400,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          if (_selectedBirthday != null)
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _selectedBirthday = null;
                                                });
                                              },
                                              child: Icon(
                                                Icons.close,
                                                size: 20,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          const SizedBox(width: 8),
                                          Icon(
                                            Icons.calendar_today,
                                            size: 20,
                                            color: Colors.grey.shade600,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                  if (actionState.isLoading)
                    Container(
                      color: Colors.black.withOpacity(0.3),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
