import 'package:flutter/material.dart';
import '../../../data/data_manager.dart';

class NoticeListScreen extends StatefulWidget {
  final String teamName;

  const NoticeListScreen({
    Key? key,
    required this.teamName,
  }) : super(key: key);

  @override
  State<NoticeListScreen> createState() => _NoticeListScreenState();
}

class _NoticeListScreenState extends State<NoticeListScreen> {
  List<Map<String, String>> _notices = [];

  @override
  void initState() {
    super.initState();
    _loadNotices();
  }

  void _loadNotices() {
    setState(() {
      _notices = DataManager().getNotices(widget.teamName);
    });
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
      body: _notices.isEmpty
          ? const Center(
              child: Text(
                '등록된 공지사항이 없습니다.',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.separated(
              itemCount: _notices.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final notice = _notices[index];
                return ExpansionTile(
                  title: Text(
                    notice['title'] ?? '제목 없음',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    '${notice['date']} · ${notice['author']}',
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
                        notice['content'] ?? '',
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
