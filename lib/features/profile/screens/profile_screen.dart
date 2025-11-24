// 상대방 프로필 상세 화면
import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../data/data_manager.dart';
import '../../chat/screens/conversation_screen.dart';
import 'edit_profile_screen.dart';
import '../../settings/screens/more_screen.dart';

class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const ProfileScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final DataManager _dataManager = DataManager();
  late bool _isCurrentUser;
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isCurrentUser = widget.user['name'] == _dataManager.currentUser['name'];
    _isFavorite = widget.user['isFavorite'] ?? false;
  }

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
              onPressed: () {
                setState(() {
                  _isFavorite = !_isFavorite;
                  _dataManager.toggleFavorite(widget.user['name']);
                });
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
              TextButton(
                onPressed: () {
                  _dataManager.blockUser(widget.user['name']);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('사용자가 차단되었습니다.')),
                  );
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
                  builder: (context) => EditProfileScreen(user: widget.user),
                ),
              );
              if (result == true) {
                setState(() {
                  // Refresh data if needed, though DataManager update should reflect if we rebuild or re-fetch
                  // Since widget.user is passed by reference/value, we might need to update it or rely on parent rebuild.
                  // For now, let's assume DataManager update is enough if we re-read or if widget.user is a reference to the map in DataManager.
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
          onTap: () {
             Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ConversationScreen(
                    userName: widget.user['name'],
                    userImage: widget.user['image'] ?? '',
                  ),
                ),
              );
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
      child: Column(
        children: [
          _buildInfoRow(Icons.phone_outlined, widget.user['phone'] ?? '010-0000-0000'),
          const Divider(height: 24),
          _buildInfoRow(Icons.email_outlined, widget.user['email'] ?? 'user@example.com'),
          const Divider(height: 24),
          _buildInfoRow(Icons.badge_outlined, widget.user['id'] ?? '@seona_123'),
          if (!_isCurrentUser) ...[
             const Divider(height: 24),
             _buildInfoRow(Icons.cake_outlined, widget.user['birthdate'] ?? '1월 1일'),
          ]
        ],
      ),
    );
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
