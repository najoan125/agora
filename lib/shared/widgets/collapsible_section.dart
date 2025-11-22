// 접고 펼칠 수 있는 섹션 위젯
import 'package:flutter/material.dart';
import '../../core/theme.dart';

class CollapsibleSection extends StatefulWidget {
  final String title;
  final int count;
  final Widget? minimizedChild;
  final Widget child;
  final bool isInitiallyExpanded;

  const CollapsibleSection({
    Key? key,
    required this.title,
    required this.count,
    required this.child,
    this.minimizedChild,
    this.isInitiallyExpanded = true,
  }) : super(key: key);

  @override
  State<CollapsibleSection> createState() => _CollapsibleSectionState();
}

class _CollapsibleSectionState extends State<CollapsibleSection> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isInitiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(height: 1, thickness: 1, color: Color(0xFFCCCCCC)),
        InkWell(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${widget.count}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const Spacer(),
                Icon(
                  _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: AppTheme.textSecondary,
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded)
          widget.child
        else if (widget.minimizedChild != null)
          widget.minimizedChild!,
      ],
    );
  }
}
