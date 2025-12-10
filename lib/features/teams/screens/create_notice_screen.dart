import 'package:flutter/material.dart';
import '../../../data/services/team_service.dart';

class CreateNoticeScreen extends StatefulWidget {
  final String teamId;
  final String teamName;

  const CreateNoticeScreen({
    Key? key,
    required this.teamId,
    required this.teamName,
  }) : super(key: key);

  @override
  State<CreateNoticeScreen> createState() => _CreateNoticeScreenState();
}

class _CreateNoticeScreenState extends State<CreateNoticeScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _registerNotice() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목과 내용을 모두 입력해주세요')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final teamService = TeamService();
      final result = await teamService.createNotice(
        widget.teamId,
        title: title,
        content: content,
        isPinned: false,
      );

      result.when(
        success: (_) {
          if (mounted) {
            Navigator.pop(context, true);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('공지사항이 등록되었습니다')),
            );
          }
        },
        failure: (error) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('공지사항 등록 실패: ${error.displayMessage}')),
            );
          }
        },
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('공지사항 등록'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          _isLoading
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : TextButton(
                  onPressed: _registerNotice,
                  child: const Text(
                    '완료',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: '제목',
                hintStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
                border: InputBorder.none,
              ),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 30, thickness: 1),
            Expanded(
              child: TextField(
                controller: _contentController,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  hintText: '공지사항 내용을 입력하세요.',
                  hintStyle: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  border: InputBorder.none,
                ),
                style: const TextStyle(fontSize: 16, height: 1.5),
                maxLines: null,
                expands: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
