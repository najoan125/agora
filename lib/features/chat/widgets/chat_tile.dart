// 채팅 목록의 개별 아이템 위젯
import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class ChatTile extends StatelessWidget {
  final Map<String, dynamic> chat;
  final VoidCallback onTap;

  const ChatTile({
    Key? key,
    required this.chat,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final name = chat['name'] ?? 'Unknown';
    final message = chat['message'] ?? '';
    final time = chat['time'] ?? '';
    final avatar = chat['avatar'] ?? '👤';
    final image = chat['image'] as String?;
    final unread = chat['unread'] as int? ?? 0;
    final isTeam = chat['isTeam'] as bool? ?? false;

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: isTeam ? Colors.orange.withOpacity(0.1) : AppTheme.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
            image: image != null
                ? DecorationImage(
                    image: NetworkImage(image),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: image == null
              ? Center(
                  child: Text(avatar, style: const TextStyle(fontSize: 26)),
                )
              : null,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              time,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: unread > 0
                      ? Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w500,
                        )
                      : Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              if (unread > 0)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    unread.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
