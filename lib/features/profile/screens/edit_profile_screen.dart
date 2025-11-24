import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../data/data_manager.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const EditProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final DataManager _dataManager = DataManager();
  late TextEditingController _nameController;
  late TextEditingController _statusController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user['name']);
    _statusController = TextEditingController(text: widget.user['statusMessage']);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    // In a real app, this would update the server.
    // For now, we'll just update the local mock data if possible, 
    // but DataManager might not expose a direct update method for currentUser easily 
    // without a specific method. 
    // Looking at DataManager, it has currentUser. 
    // We might need to add a method to DataManager to update profile if it doesn't exist,
    // or just update the map directly since it's a reference in memory (mock).
    
    setState(() {
      _dataManager.currentUser['name'] = _nameController.text;
      _dataManager.currentUser['statusMessage'] = _statusController.text;
    });

    Navigator.pop(context, true); // Return true to indicate changes
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('프로필 편집'),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildProfileImage(),
            const SizedBox(height: 32),
            _buildTextField(
              controller: _nameController,
              label: '이름',
              hint: '이름을 입력하세요',
            ),
            const SizedBox(height: 24),
            _buildTextField(
              controller: _statusController,
              label: '상태 메시지',
              hint: '상태 메시지를 입력하세요',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Stack(
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
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
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
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AppTheme.surfaceColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }
}
