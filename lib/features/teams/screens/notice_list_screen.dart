import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/team/team.dart';
import '../../../data/services/team_service.dart';

class NoticeListScreen extends StatefulWidget {
  final String teamId;
  final String teamName;

  const NoticeListScreen({
    Key? key,
    required this.teamId,
    required this.teamName,
  }) : super(key: key);

  @override
  State<NoticeListScreen> createState() => _NoticeListScreenState();
}

class _NoticeListScreenState extends State<NoticeListScreen> {
  List<Notice> _notices = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadNotices();
  }

  Future<void> _loadNotices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final teamService = TeamService();
    final result = await teamService.getNotices(widget.teamId);

    if (mounted) {
      result.when(
        success: (notices) {
          setState(() {
            _notices = notices;
            _isLoading = false;
          });
        },
        failure: (error) {
          setState(() {
            _errorMessage = error.displayMessage;
            _isLoading = false;
          });
        },
      );
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy.MM.dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('공지사항'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              '공지사항을 불러올 수 없습니다',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _loadNotices,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (_notices.isEmpty) {
      return const Center(
        child: Text(
          '등록된 공지사항이 없습니다.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNotices,
      child: ListView.separated(
        itemCount: _notices.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final notice = _notices[index];
          return ExpansionTile(
            title: Row(
              children: [
                if (notice.isPinned)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '고정',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                Expanded(
                  child: Text(
                    notice.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            subtitle: Text(
              '${_formatDate(notice.createdAt)} · ${notice.authorName}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.grey.shade50,
                child: Text(
                  notice.content,
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
