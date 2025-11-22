// 그룹 채팅 타일 위젯
import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class GroupChatTile extends StatelessWidget {
  final String name;
  final String? image;
  final VoidCallback? onTap;

  const GroupChatTile({
    Key? key,
    required this.name,
    this.image,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          width: 64,
          margin: const EdgeInsets.only(right: 16),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0), // Placeholder gray
                  borderRadius: BorderRadius.circular(16),
                  image: image != null
                      ? DecorationImage(
                          image: NetworkImage(image!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
