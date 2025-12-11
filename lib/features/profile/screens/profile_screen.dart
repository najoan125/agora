// 상대방 프로필 상세 화면
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../../../data/data_manager.dart';
import '../../../data/models/agora_profile_response.dart';
import '../../chat/screens/conversation_screen.dart';
import 'edit_profile_screen.dart';
import '../../settings/screens/more_screen.dart';
import '../../../shared/providers/chat_provider.dart';
import '../../../shared/providers/friend_provider.dart';
import '../../../shared/providers/riverpod_profile_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> user;

  const ProfileScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final DataManager _dataManager = DataManager();
  late bool _isCurrentUser;
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isCurrentUser = widget.user['name'] == _dataManager.currentUser['name'];
    _isFavorite = widget.user['isFavorite'] ?? false;
  }

  String? get _agoraId => widget.user['agoraId']?.toString();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!_isCurrentUser)
            IconButton(
              icon: Icon(
                _isFavorite ? Icons.star : Icons.star_border,
                color: _isFavorite ? AppTheme.favoriteColor : AppTheme.textSecondary,
                size: 28,
              ),
              onPressed: () async {
                final newState = !_isFavorite;
                setState(() {
                  _isFavorite = newState;
                });
                
                final id = widget.user['id']?.toString();
                if (id != null) {
                   await ref.read(friendActionProvider.notifier).toggleFavorite(id, !newState);
                }
              },
            ),

        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildProfileHeader(),
            const SizedBox(height: 32),
            _buildActionButtons(),
            const SizedBox(height: 32),
            _buildInfoSection(),
            if (!_isCurrentUser) ...[
              const SizedBox(height: 24),
              // 친구 삭제 버튼
              TextButton(
                onPressed: () async {
                  final shouldDelete = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('친구 삭제'),
                      content: Text('${widget.user['name']}님을 친구 목록에서 삭제하시겠습니까?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('취소', style: TextStyle(color: Colors.grey)),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('삭제', style: TextStyle(color: AppTheme.errorColor)),
                        ),
                      ],
                    ),
                  );

                  if (shouldDelete == true) {
                    final notifier = ref.read(friendActionProvider.notifier);
                    // ID가 없으면 에러 처리
                    final id = widget.user['id']?.toString();
                    if (id == null) {
                       ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('친구 정보를 찾을 수 없습니다.')),
                      );
                      return;
                    }

                    final success = await notifier.deleteFriend(id);
                    if (success && mounted) {
                      Navigator.pop(context); // Close profile screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('친구가 삭제되었습니다.')),
                      );
                    }
                  }
                },
                child: const Text(
                  '친구 삭제',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
              const SizedBox(height: 8),
              // 사용자 차단 버튼
              TextButton(
                onPressed: () async {
                  final shouldBlock = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('사용자 차단'),
                      content: Text('${widget.user['name']}님을 차단하시겠습니까?\n차단하면 친구 목록에서도 삭제됩니다.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('취소', style: TextStyle(color: Colors.grey)),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('차단', style: TextStyle(color: AppTheme.errorColor)),
                        ),
                      ],
                    ),
                  );

                  if (shouldBlock == true) {
                    final notifier = ref.read(friendActionProvider.notifier);
                    final id = widget.user['id']?.toString();
                    if (id == null) return;
                    
                    final success = await notifier.blockUser(id);
                    // blockUser가 성공하면 친구목록도 갱신됨 (Provider 내부 구현)
                    
                    if (success && mounted) {
                       Navigator.pop(context); // Close profile
                       ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('사용자가 차단되었습니다.')),
                      );
                    } else if (mounted) {
                       ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('차단에 실패했습니다.')),
                      );
                    }
                  }
                },
                child: const Text(
                  '사용자 차단',
                  style: TextStyle(color: AppTheme.errorColor, fontSize: 16),
                ),
              ),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
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
            image: widget.user['image'] != null
                ? DecorationImage(
                    image: NetworkImage(widget.user['image']),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: widget.user['image'] == null
              ? Center(
                  child: Text(
                    widget.user['avatar'] ?? '👤',
                    style: const TextStyle(fontSize: 60),
                  ),
                )
              : null,
        ),
        const SizedBox(height: 24),
        Text(
          widget.user['name'] ?? 'Unknown',
          style: Theme.of(context).textTheme.displayMedium,
        ),
        const SizedBox(height: 8),
        Text(
          widget.user['statusMessage'] ?? '',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
                fontSize: 16,
              ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    if (_isCurrentUser) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildCircleButton(
            icon: Icons.edit,
            label: '프로필 편집',
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfileScreen(),
                ),
              );
              if (result == true) {
                setState(() {
                  // 프로필이 업데이트되었으므로 화면 새로고침
                });
              }
            },
          ),
          const SizedBox(width: 32),
          _buildCircleButton(
            icon: Icons.settings,
            label: '설정',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MoreScreen()),
              );
            },
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildCircleButton(
          icon: Icons.chat_bubble_outline,
          label: '1:1 채팅',
          onTap: () async {
            // agoraId로 채팅방 생성/조회
            final agoraId = widget.user['agoraId']?.toString() ?? '';
            if (agoraId.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('채팅을 시작할 수 없습니다.')),
              );
              return;
            }

            final notifier = ref.read(chatActionProvider.notifier);
            final chat = await notifier.startDirectChat(agoraId);

            if (chat != null && mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ConversationScreen(
                    chatId: chat.id.toString(),
                    userName: widget.user['name'] ?? '',
                    userImage: widget.user['image'] ?? '',
                  ),
                ),
              );
            } else if (mounted) {
              final error = ref.read(chatActionProvider).error;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(error ?? '채팅방 생성에 실패했습니다.')),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: AppTheme.textPrimary, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    // agoraId가 있으면 API에서 상세 프로필 가져오기
    if (_agoraId != null && _agoraId!.isNotEmpty && !_isCurrentUser) {
      final profileAsync = ref.watch(userProfileProvider(_agoraId!));

      return profileAsync.when(
        loading: () => _buildInfoContainer(
          children: [
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            ),
          ],
        ),
        error: (_, __) => _buildInfoContainer(
          children: [
            _buildInfoRow(Icons.badge_outlined, '@$_agoraId'),
          ],
        ),
        data: (profile) {
          if (profile == null) {
            return _buildInfoContainer(
              children: [
                _buildInfoRow(Icons.badge_outlined, '@$_agoraId'),
              ],
            );
          }
          return _buildProfileInfo(profile);
        },
      );
    }

    // 본인 프로필이거나 agoraId가 없는 경우 기본 표시
    return _buildInfoContainer(
      children: [
        _buildInfoRow(Icons.badge_outlined, '@${_agoraId ?? '-'}'),
      ],
    );
  }

  Widget _buildProfileInfo(AgoraProfileResponse profile) {
    return _buildInfoContainer(
      children: [
        // agoraId
        _buildInfoRow(Icons.badge_outlined, '@${profile.agoraId}'),

        // 전화번호 (있는 경우에만 표시)
        if (profile.phone != null && profile.phone!.isNotEmpty) ...[
          const Divider(height: 24),
          _buildInfoRow(Icons.phone_outlined, profile.phone!),
        ],

        // 생년월일 (있는 경우에만 표시)
        if (profile.birthday != null && profile.birthday!.isNotEmpty) ...[
          const Divider(height: 24),
          _buildInfoRow(Icons.cake_outlined, _formatBirthday(profile.birthday!)),
        ],
      ],
    );
  }

  Widget _buildInfoContainer({required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  String _formatBirthday(String birthday) {
    // birthday 형식: "1990-01-15" → "1월 15일"
    try {
      final parts = birthday.split('-');
      if (parts.length >= 3) {
        final month = int.parse(parts[1]);
        final day = int.parse(parts[2]);
        return '$month월 $day일';
      }
    } catch (_) {}
    return birthday;
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.textSecondary, size: 20),
        const SizedBox(width: 16),
        Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
