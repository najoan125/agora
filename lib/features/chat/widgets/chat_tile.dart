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
    final message = chat['message'] as String? ?? '';
    final time = chat['time'] as String? ?? '';
    final avatar = chat['avatar'] ?? '👤';
    final image = chat['image'] as String?;
    final unread = chat['unread'] as int? ?? 0;
    final isTeam = chat['isTeam'] as bool? ?? false;

    // 메시지가 없을 때 표시할 텍스트
    final displayMessage = message.isEmpty ? '대화를 시작해보세요' : message;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).dividerColor,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 프로필 이미지
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isTeam 
                    ? AppTheme.friendRequestColor.withOpacity(0.1) 
                    : AppTheme.primaryColor.withOpacity(0.1),
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
                      child: Text(
                        avatar,
                        style: TextStyle(
                          fontSize: 22,
                          color: isTeam 
                              ? AppTheme.friendRequestColor 
                              : AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            
            // 텍스트 및 정보 영역
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 상단: 이름 + 시간
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        // 시간이 없으면 빈 문자열이지만, 레이아웃 확인을 위해 날짜가 없으면 빈 공간 유지
                        time,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  
                  // 하단: 메시지 + 배지
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          displayMessage,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.textSecondary,
                                fontSize: 14,
                                height: 1.3,
                              ),
                        ),
                      ),
                      if (unread > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.errorColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(minWidth: 18),
                          alignment: Alignment.center,
                          child: Text(
                            unread > 999 ? '999+' : unread.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              height: 1.1,
                            ),
                          ),
                        ),
                      ],
                    ],
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
