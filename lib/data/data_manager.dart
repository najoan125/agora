// 앱 전체에서 사용되는 데이터 관리 및 모의 데이터 제공
import 'package:flutter/material.dart';

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
      'members': ['김철수', '이영희', '박지성', '손흥민', '차범근']
    },
    {
      'name': '마케팅팀',
      'member': '3명',
      'icon': '📊',
      'image': 'https://picsum.photos/id/1011/200/200',
      'members': ['이서연', '정민지', '최수진']
    },
  ];

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
}
