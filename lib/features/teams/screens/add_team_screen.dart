import 'dart:io';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'add_team_member_screen.dart';
import '../../../data/services/team_service.dart';
import '../../../data/services/file_service.dart';
import '../../../data/models/team/team.dart';

class AddTeamScreen extends ConsumerStatefulWidget {
  const AddTeamScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<AddTeamScreen> createState() => _AddTeamScreenState();
}

class _AddTeamScreenState extends ConsumerState<AddTeamScreen> {
  late TextEditingController _teamNameController;
  late TextEditingController _teamDescriptionController;
  
  // Image selection
  final ImagePicker _picker = ImagePicker();
  XFile? _pickedFile;
  String? _selectedImage; // No default image

  final List<Map<String, dynamic>> _selectedMembers = [];

  bool _isLoading = false;



  @override
  void initState() {
    super.initState();
    _teamNameController = TextEditingController();
    _teamDescriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _teamNameController.dispose();
    _teamDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _pickedFile = image;
        _selectedImage = image.path; // Update selected image path
      });
    }
  }

  Future<void> _addTeam() async {
    if (_teamNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('팀 이름을 입력해주세요')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final teamService = TeamService();
      final fileService = FileService();

      // 1. 이미지 업로드 (선택한 경우)
      String? uploadedImageUrl;
      if (_pickedFile != null) {
        final imageResult = await fileService.uploadImage(File(_pickedFile!.path));
        imageResult.when(
          success: (fileResponse) => uploadedImageUrl = fileResponse.file.downloadUrl,
          failure: (_) {}, // 이미지 업로드 실패는 무시
        );
      }

      // 2. 팀 생성 API 호출
      final teamResult = await teamService.createTeam(
        name: _teamNameController.text,
        description: _teamDescriptionController.text.isNotEmpty
            ? _teamDescriptionController.text
            : null,
        profileImage: uploadedImageUrl,
      );

      Team? createdTeam;
      teamResult.when(
        success: (team) => createdTeam = team,
        failure: (error) => throw Exception(error.displayMessage),
      );

      // 3. 팀원 초대 (선택된 멤버가 있는 경우)
      if (createdTeam != null && _selectedMembers.isNotEmpty) {
        final teamId = createdTeam!.id.toString();
        for (final member in _selectedMembers) {
          final agoraId = member['id'] as String?;
          if (agoraId != null && agoraId.isNotEmpty) {
            await teamService.inviteMember(teamId, agoraId);
          }
        }
      }

      // 4. 성공 처리
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_teamNameController.text}을 생성했습니다')),
        );
        Navigator.pop(context, true); // true 반환하여 목록 새로고침 트리거
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('팀 생성에 실패했습니다: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('팀 만들기'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 팀 이미지 선택
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: _pickedFile != null
                        ? (kIsWeb
                            ? Image.network(
                                _pickedFile!.path,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Icon(Icons.error_outline,
                                        color: Colors.red),
                                  );
                                },
                              )
                            : Image.file(
                                File(_pickedFile!.path),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Icon(Icons.error_outline,
                                        color: Colors.red),
                                  );
                                },
                              ))
                        : (_selectedImage != null && _selectedImage!.startsWith('http')
                            ? Image.network(
                                _selectedImage!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Icon(Icons.error_outline,
                                        color: Colors.red),
                                  );
                                },
                              )
                            : Center(
                                child: Icon(Icons.add_photo_alternate,
                                    size: 40, color: Colors.grey.shade400),
                              )),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: _pickImage,
                child: Text(
                  _pickedFile != null || (_selectedImage != null && _selectedImage!.startsWith('http'))
                      ? '이미지 변경'
                      : '이미지 선택',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.blue.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
            
            // 팀 이름 입력
            Text(
              '팀 이름',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _teamNameController,
              decoration: InputDecoration(
                hintText: '팀 이름을 입력하세요',
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
            const SizedBox(height: 20),
            // 팀 설명 입력
            Text(
              '팀 설명 (선택)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _teamDescriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: '팀 설명을 입력하세요',
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
            const SizedBox(height: 20),

            // 선택된 팀원 표시
            if (_selectedMembers.isNotEmpty) ...[
              Text(
                '추가된 팀원',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _selectedMembers.map((member) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Column(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              image: DecorationImage(
                                image: NetworkImage(member['image']),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            member['name'],
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 32),
            ] else
              const SizedBox(height: 32),

            // 버튼들
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _addTeam,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.add),
                    label: Text(_isLoading ? '생성 중...' : '팀 만들기'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade400,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddTeamMemberScreen(
                            onMembersAdded: (members) {
                              setState(() {
                                for (var member in members) {
                                  if (!_selectedMembers
                                      .any((m) => m['id'] == member['id'])) {
                                    _selectedMembers.add(member);
                                  }
                                }
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${members.length}명을 추가했습니다'),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.person_add),
                    label: const Text('팀원 추가'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade400,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
