// 앱 전체에서 사용되는 데이터 관리 및 모의 데이터 제공

class DataManager {
  static final DataManager _instance = DataManager._internal();

  factory DataManager() {
    return _instance;
  }

  DataManager._internal();

  // Mock Data - Friends
  final List<Map<String, dynamic>> _friends = [
    {
      'name': '김철수',
      'phone': '010-1111-1111',
      'avatar': '👨',
      'image': 'https://picsum.photos/id/1011/200/200',
      'statusMessage': '안녕하세요!',
      'isFavorite': true,
      'isBirthday': false,
      'email': 'kim@example.com',
    },
    {
      'name': '이영희',
      'phone': '010-2222-2222',
      'avatar': '👩',
      'image': 'https://picsum.photos/id/1027/200/200',
      'statusMessage': '열심히 일하는 중...',
      'isFavorite': true,
      'isBirthday': true,
      'email': 'lee@example.com',
    },
    {
      'name': '박지성',
      'phone': '010-3333-3333',
      'avatar': '👨',
      'image': 'https://picsum.photos/id/1005/200/200',
      'statusMessage': '',
      'isFavorite': false,
      'isBirthday': false,
      'email': 'park@example.com',
    },
    {
      'name': '최민호',
      'phone': '010-4444-4444',
      'avatar': '👨',
      'image': 'https://picsum.photos/id/1012/200/200',
      'statusMessage': '긍정의 힘',
      'isFavorite': false,
      'isBirthday': false,
      'email': 'choi@example.com',
    },
    {
      'name': '손흥민',
      'phone': '010-5555-5555',
      'avatar': '👨',
      'image': 'https://picsum.photos/id/1003/200/200',
      'statusMessage': '축구왕',
      'isFavorite': true,
      'isBirthday': false,
      'email': 'son@example.com',
    },
    {
      'name': '차범근',
      'phone': '010-6666-6666',
      'avatar': '👨',
      'image': 'https://picsum.photos/id/1004/200/200',
      'statusMessage': '레전드',
      'isFavorite': false,
      'isBirthday': false,
      'email': 'cha@example.com',
    },
  ];

  // Mock Data - Friend Requests
  final List<Map<String, dynamic>> _friendRequests = [
    {
      'name': '박민수',
      'phone': '010-1234-5678',
      'avatar': '👨',
      'image': 'https://picsum.photos/id/1001/200/200',
      'requestDate': '2024.01.20'
    },
    {
      'name': '이서연',
      'phone': '010-2345-6789',
      'avatar': '👩',
      'image': 'https://picsum.photos/id/1014/200/200',
      'requestDate': '2024.01.18'
    },
  ];

  // Mock Data - Chats
  final List<Map<String, dynamic>> _chats = [
    {
      'id': '1',
      'name': '김진규',
      'message': '내일 회의 시간이 변경되었습니다.',
      'time': '방금 전',
      'avatar': '👨',
      'image': 'https://picsum.photos/id/1025/200/200',
      'unread': 2,
      'isTeam': false,
    },
    {
      'id': '2',
      'name': '이영희',
      'message': '프로젝트 파일을 업로드했습니다.',
      'time': '1시간 전',
      'avatar': '👩',
      'image': 'https://picsum.photos/id/1027/200/200',
      'unread': 0,
      'isTeam': false,
    },
    {
      'id': '3',
      'name': '개발팀',
      'message': '김: 이번 주 스프린트 종료',
      'time': '방금 전',
      'avatar': '👥',
      'image': 'https://picsum.photos/id/1005/200/200',
      'unread': 5,
      'isTeam': true,
    },
    {
      'id': '4',
      'name': '박지성',
      'message': '주말에 시간 되시나요?',
      'time': '2시간 전',
      'avatar': '👨',
      'image': 'https://picsum.photos/id/1005/200/200',
      'unread': 1,
      'isTeam': false,
    },
    {
      'id': '5',
      'name': '최민호',
      'message': '감사합니다!',
      'time': '어제',
      'avatar': '👨',
      'image': 'https://picsum.photos/id/1012/200/200',
      'unread': 0,
      'isTeam': false,
    },
    {
      'id': '6',
      'name': '디자인팀',
      'message': '이: 시안 확인 부탁드립니다.',
      'time': '어제',
      'avatar': '👥',
      'image': 'https://picsum.photos/id/1027/200/200',
      'unread': 0,
      'isTeam': true,
    },
    {
      'id': '7',
      'name': '정민지',
      'message': '점심 같이 드실래요?',
      'time': '그저께',
      'avatar': '👩',
      'image': 'https://picsum.photos/id/1011/200/200',
      'unread': 0,
      'isTeam': false,
    },
  ];

  // Mock Data - Teams
  final List<Map<String, dynamic>> _teams = [
    {
      'name': '개발팀',
      'member': '5명',
      'icon': '👨‍💻',
      'image': 'https://picsum.photos/id/1005/200/200',
      'members': ['나', '김철수', '이영희', '박지성', '손흥민'],
      'isMain': true,
      'roles': {'나': 'leader'},
      'roleDefinitions': [
        {'id': 'leader', 'name': '팀장', 'permissions': ['notice', 'add_member', 'manage_roles']},
        {'id': 'member', 'name': '팀원', 'permissions': []}
      ],
      'notices': [
        {
          'title': '이번 주 스프린트 계획 회의',
          'content': '이번 주 스프린트 계획 회의는 월요일 오전 10시에 진행됩니다. 모두 참석 부탁드립니다.',
          'date': '2024-03-10',
          'author': '나',
        },
        {
          'title': '코드 리뷰 가이드라인 준수 요망',
          'content': '최근 코드 리뷰에서 스타일 가이드 준수가 미흡합니다. 다시 한 번 확인 부탁드립니다.',
          'date': '2024-03-08',
          'author': '나',
        }
      ],
    },
    {
      'name': '마케팅팀',
      'member': '3명',
      'icon': '📊',
      'image': 'https://picsum.photos/id/1011/200/200',
      'members': ['이서연', '정민지', '최수진'],
      'isMain': false,
      'roles': {'이서연': 'leader'},
      'roleDefinitions': [
        {'id': 'leader', 'name': '팀장', 'permissions': ['notice', 'add_member', 'manage_roles']},
        {'id': 'member', 'name': '팀원', 'permissions': []}
      ],
    },
    {
      'name': '기획팀',
      'member': '4명',
      'icon': '📝',
      'image': 'https://picsum.photos/id/1015/200/200',
      'members': ['강호동', '유재석', '신동엽', '이경규'],
      'isMain': false,
      'roles': {'강호동': 'leader'},
      'roleDefinitions': [
        {'id': 'leader', 'name': '팀장', 'permissions': ['notice', 'add_member', 'manage_roles']},
        {'id': 'member', 'name': '팀원', 'permissions': []}
      ],
    },
    {
      'name': '디자인팀',
      'member': '6명',
      'icon': '🎨',
      'image': 'https://picsum.photos/id/1025/200/200',
      'members': ['김태희', '전지현', '송혜교', '한가인', '손예진', '이영애'],
      'isMain': false,
      'roles': {'김태희': 'leader'},
      'roleDefinitions': [
        {'id': 'leader', 'name': '팀장', 'permissions': ['notice', 'add_member', 'manage_roles']},
        {'id': 'member', 'name': '팀원', 'permissions': []}
      ],
    },
    {
      'name': '인사팀',
      'member': '2명',
      'icon': '👥',
      'image': 'https://picsum.photos/id/1035/200/200',
      'members': ['박보검', '송중기'],
      'isMain': false,
      'roles': {'박보검': 'leader'},
      'roleDefinitions': [
        {'id': 'leader', 'name': '팀장', 'permissions': ['notice', 'add_member', 'manage_roles']},
        {'id': 'member', 'name': '팀원', 'permissions': []}
      ],
    },
  ];

  // ... (existing code) ...

  // Role Management
  String getTeamRole(String teamName, String memberName) {
    final team = _teams.firstWhere((t) => t['name'] == teamName, orElse: () => {});
    if (team.isNotEmpty) {
      final roles = team['roles'] as Map<String, dynamic>?;
      if (roles != null && roles.containsKey(memberName)) {
        return roles[memberName] as String;
      }
      // Default: First member is leader if no roles defined, otherwise member
      final members = team['members'] as List<dynamic>;
      if (members.isNotEmpty && members.first == memberName && roles == null) {
         return 'leader';
      }
    }
    return 'member';
  }

  void setTeamRole(String teamName, String memberName, String roleId) {
    final teamIndex = _teams.indexWhere((t) => t['name'] == teamName);
    if (teamIndex != -1) {
      final Map<String, dynamic> roles = Map<String, dynamic>.from(_teams[teamIndex]['roles'] ?? {});
      roles[memberName] = roleId;
      _teams[teamIndex]['roles'] = roles;
    }
  }

  void addTeamRole(String teamName, String roleName, List<String> permissions) {
    final teamIndex = _teams.indexWhere((t) => t['name'] == teamName);
    if (teamIndex != -1) {
      final List<Map<String, dynamic>> definitions = 
          List<Map<String, dynamic>>.from(_teams[teamIndex]['roleDefinitions'] ?? []);
      
      final newRoleId = 'role_${DateTime.now().millisecondsSinceEpoch}';
      definitions.add({
        'id': newRoleId,
        'name': roleName,
        'permissions': permissions,
      });
      
      _teams[teamIndex]['roleDefinitions'] = definitions;
    }
  }

  List<Map<String, dynamic>> getRoleDefinitions(String teamName) {
    final team = _teams.firstWhere((t) => t['name'] == teamName, orElse: () => {});
    if (team.isNotEmpty) {
      return List<Map<String, dynamic>>.from(team['roleDefinitions'] ?? []);
    }
    return [];
  }

  bool checkPermission(String teamName, String memberName, String permission) {
    final roleId = getTeamRole(teamName, memberName);
    final definitions = getRoleDefinitions(teamName);
    
    final roleDef = definitions.firstWhere(
      (d) => d['id'] == roleId, 
      orElse: () => {'permissions': []}
    );
    
    final permissions = List<String>.from(roleDef['permissions'] ?? []);
    return permissions.contains(permission);
  }

  // Blocked Users
  final Set<String> _blockedUsers = {};

  // Current User
  final Map<String, dynamic> _currentUser = {
    'name': '나',
    'email': 'user@agora.com',
    'avatar': '🧑',
    'image': 'https://picsum.photos/id/1005/200/200',
    'statusMessage': '상태 메시지를 설정하세요',
  };

  // Getters
  Map<String, dynamic> get currentUser => _currentUser;

  List<Map<String, dynamic>> get friends => 
      _friends.where((f) => !_blockedUsers.contains(f['name'])).toList();
  
  List<Map<String, dynamic>> get friendRequests => _friendRequests;
  
  List<Map<String, dynamic>> get chats => _chats;
  
  List<Map<String, dynamic>> get teams => _teams;

  List<Map<String, dynamic>> get blockedUsers => _blockedUsers.map((name) => {
    'name': name,
    'avatar': '👤', // Default avatar for blocked users
  }).toList();

  // Actions
  void addFriend(Map<String, dynamic> friend) {
    if (!_friends.any((f) => f['phone'] == friend['phone'])) {
      _friends.add({
        ...friend,
        'statusMessage': '',
        'isFavorite': false,
        'isBirthday': false,
        'email': '',
      });
    }
  }

  void removeFriendRequest(int index) {
    if (index >= 0 && index < _friendRequests.length) {
      _friendRequests.removeAt(index);
    }
  }

  void acceptFriendRequest(int index) {
    if (index >= 0 && index < _friendRequests.length) {
      final request = _friendRequests[index];
      addFriend({
        'name': request['name'],
        'phone': request['phone'],
        'avatar': request['avatar'],
        'image': request['image'],
      });
      removeFriendRequest(index);
    }
  }

  void toggleFavorite(String name) {
    final index = _friends.indexWhere((f) => f['name'] == name);
    if (index != -1) {
      _friends[index]['isFavorite'] = !(_friends[index]['isFavorite'] as bool);
    }
  }

  void blockUser(String name) {
    _blockedUsers.add(name);
  }

  void unblockUser(String name) {
    _blockedUsers.remove(name);
  }

  bool isBlocked(String name) => _blockedUsers.contains(name);

  void addTeam(Map<String, dynamic> team) {
    _teams.add(team);
  }

  void setMainTeam(String teamName) {
    for (var team in _teams) {
      if (team['name'] == teamName) {
        team['isMain'] = true;
      } else {
        team['isMain'] = false;
      }
    }
    
    // Reorder: Main team first
    _teams.sort((a, b) {
      if (a['isMain'] == true) return -1;
      if (b['isMain'] == true) return 1;
      return 0;
    });
  }

  void unsetMainTeam(String teamName) {
    final index = _teams.indexWhere((t) => t['name'] == teamName);
    if (index != -1) {
      _teams[index]['isMain'] = false;
    }
  }

  // Persistent Member Images
  final Map<String, String> _memberImages = {};

  String getMemberImage(String name) {
    if (!_memberImages.containsKey(name)) {
      _memberImages[name] = 'https://picsum.photos/seed/${name.hashCode}/200/200';
    }
    return _memberImages[name]!;
  }

  void updateTeamMemberName(String teamName, String oldName, String newName) {
    final teamIndex = _teams.indexWhere((t) => t['name'] == teamName);
    if (teamIndex != -1) {
      final List<String> members = List<String>.from(_teams[teamIndex]['members']);
      final memberIndex = members.indexOf(oldName);
      if (memberIndex != -1) {
        members[memberIndex] = newName;
        _teams[teamIndex]['members'] = members;
        
        // Update roles if exists
        final Map<String, String> roles = Map<String, String>.from(_teams[teamIndex]['roles'] ?? {});
        if (roles.containsKey(oldName)) {
          roles[newName] = roles[oldName]!;
          roles.remove(oldName);
          _teams[teamIndex]['roles'] = roles;
        }

        // Migrate image to new name
        if (_memberImages.containsKey(oldName)) {
          _memberImages[newName] = _memberImages[oldName]!;
        }
      }
    }
  }

  void removeTeamMember(String teamName, String memberName) {
    final teamIndex = _teams.indexWhere((t) => t['name'] == teamName);
    if (teamIndex != -1) {
      final List<String> members = List<String>.from(_teams[teamIndex]['members']);
      members.remove(memberName);
      _teams[teamIndex]['members'] = members;

      // Remove role if exists
      final Map<String, dynamic> roles = Map<String, dynamic>.from(_teams[teamIndex]['roles'] ?? {});
      roles.remove(memberName);
      _teams[teamIndex]['roles'] = roles;
    }
  }

  // Notice Management
  void addNotice(String teamName, String title, String content) {
    final teamIndex = _teams.indexWhere((t) => t['name'] == teamName);
    if (teamIndex != -1) {
      final List<Map<String, String>> notices = 
          List<Map<String, String>>.from(_teams[teamIndex]['notices'] ?? []);
      
      notices.insert(0, {
        'title': title,
        'content': content,
        'date': DateTime.now().toString().substring(0, 10), // YYYY-MM-DD
        'author': _currentUser['name'],
      }); 
      
      _teams[teamIndex]['notices'] = notices;
    }
  }

  List<Map<String, String>> getNotices(String teamName) {
    final team = _teams.firstWhere((t) => t['name'] == teamName, orElse: () => {});
    if (team.isNotEmpty) {
      return List<Map<String, String>>.from(team['notices'] ?? []);
    }
    return [];
  }

  void clearUnread(String chatId) {
    final index = _chats.indexWhere((c) => c['id'] == chatId);
    if (index != -1) {
      _chats[index]['unread'] = 0;
    }
  }

  void addChat(Map<String, dynamic> chatData) {
    // Generate a new ID
    final newId = (int.parse(_chats.map((c) => c['id']).reduce((a, b) => int.parse(a) > int.parse(b) ? a : b)) + 1).toString();
    
    final newChat = {
      'id': newId,
      'name': chatData['name'],
      'message': '새로운 대화가 시작되었습니다.',
      'time': '방금 전',
      'avatar': '👥', // Default group avatar
      'image': chatData['image'],
      'unread': 0,
      'isTeam': false, // Assuming group chats created this way are not "Teams" in the strict sense, or adjust as needed
      ...chatData, // Include other data like members
    };
    
    _chats.insert(0, newChat);
  }

  void receiveMockMessage() {
    // Simulate a message from the first chat (Kim Jin-gyu) for demo purposes
    // In a real app, this would handle push notifications or socket events
    if (_chats.isNotEmpty) {
      final chat = _chats[0];
      final currentUnread = chat['unread'] as int? ?? 0;
      
      chat['message'] = '새로운 메시지가 도착했습니다! (${DateTime.now().minute}분)';
      chat['time'] = '방금 전';
      chat['unread'] = currentUnread + 1;
      
      // Move to top
      _chats.removeAt(0);
      _chats.insert(0, chat);
    }
  }
}
