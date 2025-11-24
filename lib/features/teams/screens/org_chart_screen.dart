import 'package:flutter/material.dart';
import '../../../data/data_manager.dart';

class OrgChartScreen extends StatefulWidget {
  final String teamName;

  const OrgChartScreen({
    Key? key,
    required this.teamName,
  }) : super(key: key);

  @override
  State<OrgChartScreen> createState() => _OrgChartScreenState();
}

class _OrgChartScreenState extends State<OrgChartScreen> {
  List<Map<String, dynamic>> _sortedRoles = [];
  Map<String, List<String>> _membersByRole = {};

  @override
  void initState() {
    super.initState();
    _loadOrgData();
  }

  void _loadOrgData() {
    final roleDefinitions = DataManager().getRoleDefinitions(widget.teamName);
    final members = DataManager().teams.firstWhere((t) => t['name'] == widget.teamName)['members'] as List<dynamic>;
    
    // Sort roles by permission count (descending) as a proxy for authority
    // In a real app, you might have an explicit 'level' field
    _sortedRoles = List<Map<String, dynamic>>.from(roleDefinitions);
    _sortedRoles.sort((a, b) {
      final permsA = (a['permissions'] as List).length;
      final permsB = (b['permissions'] as List).length;
      return permsB.compareTo(permsA); // Descending
    });

    // Group members
    _membersByRole = {};
    for (var role in _sortedRoles) {
      _membersByRole[role['id']] = [];
    }

    for (var member in members) {
      final roleId = DataManager().getTeamRole(widget.teamName, member as String);
      if (_membersByRole.containsKey(roleId)) {
        _membersByRole[roleId]!.add(member);
      } else {
         // Fallback
         if (_sortedRoles.isNotEmpty) {
           final lastRole = _sortedRoles.last['id'];
           if (_membersByRole.containsKey(lastRole)) {
             _membersByRole[lastRole]!.add(member);
           }
         }
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('조직도'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _sortedRoles.isEmpty
          ? const Center(child: Text('직급 정보가 없습니다.'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Title / Header
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.apartment,
                            size: 40,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.teamName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '전체 조직 구성원',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Tree Visualization
                  ..._sortedRoles.asMap().entries.map((entry) {
                    final index = entry.key;
                    final role = entry.value;
                    final members = _membersByRole[role['id']] ?? [];
                    final isLast = index == _sortedRoles.length - 1;

                    return _buildOrgNode(
                      roleName: role['name'],
                      members: members,
                      isLast: isLast,
                      level: index,
                    );
                  }).toList(),
                ],
              ),
            ),
    );
  }

  Widget _buildOrgNode({
    required String roleName,
    required List<String> members,
    required bool isLast,
    required int level,
  }) {
    return Column(
      children: [
        // Node Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: level == 0 ? Colors.blue.shade200 : Colors.grey.shade200,
              width: level == 0 ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                roleName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: level == 0 ? Colors.blue.shade700 : Colors.black87,
                ),
              ),
              if (members.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: members.map((member) => _buildMemberChip(member)).toList(),
                ),
              ] else ...[
                 const SizedBox(height: 8),
                 Text(
                   '(공석)',
                   style: TextStyle(
                     fontSize: 12,
                     color: Colors.grey.shade400,
                   ),
                 ),
              ],
            ],
          ),
        ),
        
        // Connector Line
        if (!isLast)
          Container(
            width: 2,
            height: 30,
            color: Colors.grey.shade300,
          ),
      ],
    );
  }

  Widget _buildMemberChip(String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 8,
            backgroundImage: NetworkImage(DataManager().getMemberImage(name)),
          ),
          const SizedBox(width: 6),
          Text(
            name,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
