import 'package:flutter/material.dart';
import 'package:agora/core/theme.dart';

class OrgChartScreen extends StatelessWidget {
  const OrgChartScreen({super.key});

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
          '조직도',
          style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildOrgNode('CEO', '김대표', 'https://picsum.photos/id/1005/200/200', isRoot: true),
            _buildConnector(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    _buildOrgNode('CTO', '이기술', 'https://picsum.photos/id/1012/200/200'),
                    _buildConnector(),
                    _buildOrgNode('개발팀장', '박팀장', 'https://picsum.photos/id/1025/200/200'),
                    _buildConnector(),
                    Row(
                      children: [
                        _buildOrgNode('팀원', '김철수', null, isSmall: true),
                        const SizedBox(width: 8),
                        _buildOrgNode('팀원', '이영희', null, isSmall: true),
                      ],
                    )
                  ],
                ),
                Column(
                  children: [
                    _buildOrgNode('CPO', '최기획', 'https://picsum.photos/id/1027/200/200'),
                    _buildConnector(),
                    _buildOrgNode('기획팀장', '정팀장', 'https://picsum.photos/id/1035/200/200'),
                    _buildConnector(),
                    _buildOrgNode('팀원', '홍길동', null, isSmall: true),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrgNode(String role, String name, String? image, {bool isRoot = false, bool isSmall = false}) {
    return Container(
      padding: EdgeInsets.all(isSmall ? 8 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isRoot ? AppTheme.primaryColor : const Color(0xFFE0E0E0), width: isRoot ? 2 : 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: isSmall ? 40 : 60,
            height: isSmall ? 40 : 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[200],
              image: image != null
                  ? DecorationImage(image: NetworkImage(image), fit: BoxFit.cover)
                  : null,
            ),
            child: image == null
                ? Center(child: Text(name[0], style: TextStyle(fontSize: isSmall ? 16 : 24)))
                : null,
          ),
          SizedBox(height: isSmall ? 4 : 8),
          Text(
            name,
            style: TextStyle(
              fontSize: isSmall ? 12 : 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          Text(
            role,
            style: TextStyle(
              fontSize: isSmall ? 10 : 13,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnector() {
    return Container(
      width: 2,
      height: 20,
      color: const Color(0xFFE0E0E0),
    );
  }
}
