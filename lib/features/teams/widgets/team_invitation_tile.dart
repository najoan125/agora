// 팀 초대 수락/거절 위젯
import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../data/models/team/team.dart';

class TeamInvitationTile extends StatelessWidget {
  final TeamInvitation invitation;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const TeamInvitationTile({
    Key? key,
    required this.invitation,
    required this.onAccept,
    required this.onDecline,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      color: AppTheme.surfaceColor,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            image: invitation.teamProfileImage != null
                ? DecorationImage(
                    image: NetworkImage(invitation.teamProfileImage!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: invitation.teamProfileImage == null
              ? Center(
                  child: Text(
                    invitation.teamName.isNotEmpty
                        ? invitation.teamName[0]
                        : '?',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                )
              : null,
        ),
        title: Text(
          invitation.teamName,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          '${invitation.fromEffectiveDisplayName}님이 초대했습니다',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 거절 버튼
            OutlinedButton(
              onPressed: onDecline,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.textSecondary,
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                minimumSize: const Size(80, 36),
              ),
              child: const Text(
                '거절',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(width: 12),
            // 수락 버튼
            ElevatedButton(
              onPressed: onAccept,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                minimumSize: const Size(80, 36),
              ),
              child: const Text(
                '수락',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
