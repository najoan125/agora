// 친구 추가 및 검색 화면
import 'package:flutter/material.dart';

class AddFriendScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onFriendAdded;

  const AddFriendScreen({
    Key? key,
    required this.onFriendAdded,
  }) : super(key: key);

  @override
  State<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _searchController;
  String _searchQuery = '';
  bool _isSearching = false;
  List<Map<String, dynamic>> _searchResults = [];
  String _selectedCountryCode = '+82';

  final Map<String, String> _countryCodes = {
    '대한민국': '+82',
    '일본': '+81',
    '중국': '+86',
    '미국': '+1',
    '영국': '+44',
    '호주': '+61',
  };

  // 모의 친구 데이터베이스
  final List<Map<String, dynamic>> _availableFriends = [
    {
      'name': '김철수',
      'phone': '010-1234-5678',
      'id': 'kim_cs',
      'avatar': '👨',
      'image': 'https://picsum.photos/id/1011/200/200',
      'isBirthday': false
    },
    {
      'name': '이영희',
      'phone': '010-2345-6789',
      'id': 'lee_yh',
      'avatar': '👩',
      'image': 'https://picsum.photos/id/1027/200/200',
      'isBirthday': true
    },
    {
      'name': '박민준',
      'phone': '010-3456-7890',
      'id': 'park_mj',
      'avatar': '👨',
      'image': 'https://picsum.photos/id/1005/200/200',
      'isBirthday': false
    },
    {
      'name': '최수진',
      'phone': '010-4567-8901',
      'id': 'choi_sj',
      'avatar': '👩',
      'image': 'https://picsum.photos/id/1014/200/200',
      'isBirthday': true
    },
    {
      'name': '정준호',
      'phone': '010-5678-9012',
      'id': 'jung_jh',
      'avatar': '👨',
      'image': 'https://picsum.photos/id/1012/200/200',
      'isBirthday': false
    },
    {
      'name': '홍길동',
      'phone': '010-6789-0123',
      'id': 'hong_gd',
      'avatar': '👨',
      'image': 'https://picsum.photos/id/1015/200/200',
      'isBirthday': true
    },
    {
      'name': '유미영',
      'phone': '010-7890-1234',
      'id': 'yu_my',
      'avatar': '👩',
      'image': 'https://picsum.photos/id/1025/200/200',
      'isBirthday': false
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _searchFriend() {
    if (_searchQuery.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchResults = [];
    });

    // 검색 시뮬레이션 (0.5초 딜레이)
    Future.delayed(const Duration(milliseconds: 500), () {
      final results = _availableFriends
          .where((friend) =>
              (friend['phone'] as String).contains(_searchQuery) ||
              (friend['id'] as String)
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              (friend['name'] as String)
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()))
          .toList();

      setState(() {
        _isSearching = false;
        _searchResults = results;
      });
    });
  }

  void _addFriend(Map<String, dynamic> friend) {
    widget.onFriendAdded(friend);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${friend['name']}을(를) 친구로 추가했습니다'),
        duration: const Duration(seconds: 2),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '친구추가',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.black,
              indicatorWeight: 2,
              indicatorSize: TabBarIndicatorSize.label,
              tabs: const [
                Tab(
                  icon: Icon(Icons.phone, size: 20),
                  text: '연락처',
                ),
                Tab(
                  icon: Icon(Icons.person, size: 20),
                  text: '아이디',
                ),
                Tab(
                  icon: Icon(Icons.qr_code, size: 20),
                  text: 'QR 코드',
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPhoneSearchTab(),
          _buildIdSearchTab(),
          _buildQrCodeTab(),
        ],
      ),
    );
  }

  Widget _buildPhoneSearchTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '전화번호로 친구 찾기',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        setState(() {
                          _selectedCountryCode = value;
                        });
                      },
                      itemBuilder: (BuildContext context) {
                        return _countryCodes.entries.map((entry) {
                          return PopupMenuItem<String>(
                            value: entry.value,
                            child: Text('${entry.key} ${entry.value}'),
                          );
                        }).toList();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 16),
                        child: Row(
                          children: [
                            Text(
                              _selectedCountryCode,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_drop_down, size: 18),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: 1,
                      color: Colors.grey.shade300,
                    ),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        onSubmitted: (_) => _searchFriend(),
                        decoration: InputDecoration(
                          hintText: '010-1234-5678',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 16),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: IconButton(
                        icon: const Icon(Icons.search,
                            color: Colors.grey, size: 20),
                        onPressed: _searchFriend,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _buildSearchResultsList(),
        ),
      ],
    );
  }

  Widget _buildIdSearchTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '아이디로 친구 찾기',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                onSubmitted: (_) => _searchFriend(),
                decoration: InputDecoration(
                  hintText: 'abcd',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  prefixIcon: const Icon(Icons.person_outline,
                      color: Colors.grey, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                              _searchResults = [];
                            });
                          },
                          child: const Icon(Icons.close,
                              color: Colors.grey, size: 20),
                        )
                      : IconButton(
                          icon: const Icon(Icons.search,
                              color: Colors.grey, size: 20),
                          onPressed: _searchFriend,
                        ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _buildSearchResultsList(),
        ),
      ],
    );
  }

  Widget _buildQrCodeTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300, width: 2),
            ),
            child: Icon(
              Icons.qr_code_2,
              size: 100,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'QR 코드로 친구 추가',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '친구의 QR 코드를 스캔하면\n친구를 추가할 수 있습니다',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: 200,
            child: ElevatedButton.icon(
              onPressed: () {
                _showQrScanDialog();
              },
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('QR 코드 스캔'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade400,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultsList() {
    if (_searchQuery.isEmpty) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '추천 친구',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _availableFriends.take(4).length,
              itemBuilder: (context, index) {
                final friend = _availableFriends[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(12),
                          image: friend['image'] != null
                              ? DecorationImage(
                                  image: NetworkImage(friend['image'] as String),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: friend['image'] == null
                            ? Center(
                                child: Text(
                                  friend['avatar'] as String,
                                  style: const TextStyle(fontSize: 28),
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              friend['name'] as String,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              friend['phone'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _addFriend(friend),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade400,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.person_add,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      );
    }

    if (_isSearching) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation(Colors.blue.shade400),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '검색 중...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_off_outlined,
              size: 60,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              '검색 결과가 없습니다',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final friend = _searchResults[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                  image: friend['image'] != null
                      ? DecorationImage(
                          image: NetworkImage(friend['image'] as String),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: friend['image'] == null
                    ? Center(
                        child: Text(
                          friend['avatar'] as String,
                          style: const TextStyle(fontSize: 28),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      friend['name'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      friend['phone'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _addFriend(friend as Map<String, String>),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade400,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.person_add,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showQrScanDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('QR 코드 스캔'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300, width: 2),
              ),
              child: Icon(
                Icons.qr_code_2,
                size: 120,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'QR 코드를 카메라에 맞춰주세요',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              // 모의 QR 코드 스캔 결과
              final scannedId = 'kim_cs';
              final friend = _availableFriends
                  .firstWhere((f) => f['id'] == scannedId, orElse: () => {});

              Navigator.pop(context);

              if (friend.isNotEmpty) {
                _addFriend(friend as Map<String, String>);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('등록되지 않은 사용자입니다')),
                );
              }
            },
            icon: const Icon(Icons.check),
            label: const Text('스캔 완료'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade400,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
