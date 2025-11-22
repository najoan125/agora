// 친구 목록의 개별 친구 표시 위젯
import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class FriendTile extends StatelessWidget {
  final Map<String, dynamic> friend;
  final VoidCallback onTap;
  final VoidCallback? onFavoriteToggle;

  const FriendTile({
    Key? key,
    required this.friend,
    required this.onTap,
    this.onFavoriteToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final name = friend['name'] ?? 'Unknown';
    final statusMessage = friend['statusMessage'] ?? '';
    final avatar = friend['avatar'] ?? '👤';
    final image = friend['image'] as String?;
    final isFavorite = friend['isFavorite'] as bool? ?? false;
    final isBirthday = friend['isBirthday'] as bool? ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 1), // minimal spacing for modern look
      color: AppTheme.surfaceColor,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Stack(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
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
                      child: Text(avatar, style: const TextStyle(fontSize: 24)),
                    )
                  : null,
            ),
            if (isBirthday)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.birthdayColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.cake, size: 10, color: Colors.white),
                ),
              ),
          ],
        ),
        title: Text(
          name,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: statusMessage.isNotEmpty
            ? Text(
                statusMessage,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              )
            : null,
        trailing: onFavoriteToggle != null
            ? IconButton(
                icon: Icon(
                  isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: isFavorite ? AppTheme.favoriteColor : AppTheme.textSecondary,
                  size: 28,
                ),
                onPressed: onFavoriteToggle,
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}
