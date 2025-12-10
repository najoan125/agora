import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:agora/core/theme.dart';
import 'package:agora/features/chat/screens/select_members_screen.dart';
import 'package:agora/shared/providers/friend_provider.dart';
import 'package:agora/shared/providers/chat_provider.dart';
import 'package:agora/shared/providers/file_provider.dart';
import 'package:agora/data/models/friend/friend.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  final TextEditingController _nameController = TextEditingController();
  List<int> _selectedMemberIds = [];
  File? _groupImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 1024,
    );
    if (image != null) {
      setState(() {
        _groupImage = File(image.path);
      });
    }
  }

  Future<void> _selectMembers() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SelectMembersScreen(),
      ),
    );

    if (result != null && result is List<int>) {
      setState(() {
        _selectedMemberIds = result;
      });
    }
  }

  Future<void> _createGroup() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('그룹 이름을 입력해주세요.')),
      );
      return;
    }

    if (_selectedMemberIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('그룹 멤버를 선택해주세요.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? fileId;

      // 이미지 업로드
      if (_groupImage != null) {
        final fileService = ref.read(fileServiceProvider);
        final uploadResult = await fileService.uploadImage(_groupImage!);
        
        uploadResult.when(
          success: (response) {
            fileId = response.id;
          },
          failure: (error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('이미지 업로드 오류: ${error.displayMessage}. 기본 이미지로 생성합니다.')),
            );
          },
        );
      }

      // 그룹 생성 요청
      final chatAction = ref.read(chatActionProvider.notifier);
      final chat = await chatAction.createGroupChat(
        name: _nameController.text,
        memberIds: _selectedMemberIds,
        fileId: fileId,
      );

      if (chat != null) {
        if (!mounted) return;
        Navigator.pop(context, chat);
      } else {
        if (!mounted) return;
        final error = ref.read(chatActionProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error ?? '그룹 생성에 실패했습니다.')),
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
    // 친구 목록을 가져와서 선택된 멤버의 정보를 표시하는 데 사용
    final friendsAsync = ref.watch(friendListProvider);
    final friends = friendsAsync.valueOrNull ?? [];

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
          '그룹 생성',
          style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(35),
                    ),
                    child: _groupImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(35),
                            child: Image.file(
                              _groupImage!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Center(
                            child: Icon(
                              Icons.add_photo_alternate_outlined,
                              color: AppTheme.textSecondary,
                              size: 30,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  '그룹 이름',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Container(
                    height: 52,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF5F5F5),
                    ),
                    child: TextField(
                      controller: _nameController,
                      enabled: !_isLoading,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        hintText: '그룹 이름을 입력하세요',
                        hintStyle: TextStyle(color: AppTheme.textSecondary),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  '멤버',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _isLoading ? null : _selectMembers,
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        '+ 그룹 인원 추가',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                if (_selectedMemberIds.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _selectedMemberIds.length,
                      itemBuilder: (context, index) {
                        final memberId = _selectedMemberIds[index];
                        // 친구 목록에서 해당 ID를 가진 친구 찾기
                        final member = friends.firstWhere(
                          (f) => f.id == memberId,
                          orElse: () => Friend(
                            id: memberId,
                            agoraId: '',
                            displayName: '알 수 없는 사용자',
                            createdAt: DateTime.now(),
                          ),
                        );

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  image: member.profileImageUrl != null
                                      ? DecorationImage(
                                          image: NetworkImage(member.profileImageUrl!),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                  color: Colors.grey[200],
                                ),
                                child: member.profileImageUrl == null
                                    ? Center(
                                        child: Text(
                                          member.displayName.isNotEmpty
                                              ? member.displayName[0]
                                              : '?',
                                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                member.displayName,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ] else
                  const Spacer(),
                
                SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _createGroup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD9D9D9),
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              '그룹 생성',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
