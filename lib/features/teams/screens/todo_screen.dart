import 'package:flutter/material.dart';
import 'package:agora/core/theme.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  // Mock todos
  final List<Map<String, dynamic>> _todos = [
    {'title': '주간 보고서 작성', 'isDone': false, 'tag': '업무'},
    {'title': '디자인 시안 검토', 'isDone': true, 'tag': '디자인'},
    {'title': '팀 회식 장소 예약', 'isDone': false, 'tag': '기타'},
    {'title': 'Flutter 3.0 마이그레이션', 'isDone': false, 'tag': '개발'},
    {'title': '서버 API 연동 테스트', 'isDone': true, 'tag': '개발'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '할일',
          style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppTheme.textPrimary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('할일 추가 기능은 준비 중입니다.')),
              );
            },
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _todos.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final todo = _todos[index];
          return _buildTodoItem(todo, index);
        },
      ),
    );
  }

  Widget _buildTodoItem(Map<String, dynamic> todo, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          todo['isDone'] = !todo['isDone'];
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: todo['isDone'] ? Colors.transparent : const Color(0xFFE0E0E0),
          ),
          boxShadow: [
            if (!todo['isDone'])
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: todo['isDone'] ? AppTheme.primaryColor : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: todo['isDone'] ? AppTheme.primaryColor : const Color(0xFFCCCCCC),
                  width: 2,
                ),
              ),
              child: todo['isDone']
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    todo['title'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: todo['isDone'] ? AppTheme.textSecondary : AppTheme.textPrimary,
                      decoration: todo['isDone'] ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      todo['tag'],
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
