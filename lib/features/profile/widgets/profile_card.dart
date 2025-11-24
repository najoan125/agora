// 프로필 요약 카드 위젯
import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class ProfileCard extends StatelessWidget {
  final String name;
  final String statusMessage;
  final String avatarUrl;
  final VoidCallback? onTap;

  const ProfileCard({
    Key? key,
    required this.name,
    required this.statusMessage,
    required this.avatarUrl,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              backgroundImage: avatarUrl.startsWith('http') 
                  ? NetworkImage(avatarUrl) 
                  : null,
              child: !avatarUrl.startsWith('http')
                  ? Text(
                      avatarUrl, // Assuming avatarUrl is emoji if not http
                      style: const TextStyle(fontSize: 24),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    statusMessage,
                    style: AppTheme.lightTheme.textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}
