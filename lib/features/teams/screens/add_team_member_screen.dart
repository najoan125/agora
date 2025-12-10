// 팀원 초대 및 추가 화면
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers/riverpod_profile_provider.dart';
import '../../../data/models/agora_profile_response.dart';

class AddTeamMemberScreen extends ConsumerStatefulWidget {
  final Function(List<Map<String, dynamic>>) onMembersAdded;

  const AddTeamMemberScreen({Key? key, required this.onMembersAdded})
      : super(key: key);

  @override
  ConsumerState<AddTeamMemberScreen> createState() => _AddTeamMemberScreenState();
}

class _AddTeamMemberScreenState extends ConsumerState<AddTeamMemberScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _searchController;
  String _searchQuery = '';
  bool _isSearching = false;
  bool _hasSearched = false;
  List<AgoraProfileResponse> _searchResults = [];
  final Set<AgoraProfileResponse> _selectedMembers = {};
  String _selectedCountryCode = '+82';

  final Map<String, String> _countryCodes = {
    '대한민국': '+82',
    '일본': '+81',
    '중국': '+86',
    '미국': '+1',
    '영국': '+44',
    '호주': '+61',
  };

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

  void _searchMember() async {
    final query = _searchQuery.trim();

    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    // API는 최소 2글자를 요구함
    if (query.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('2글자 이상 입력해주세요')),
      );
      return;
    }

    setState(() {
      _isSearching = true;
      _hasSearched = true;
      _searchResults = [];
    });

    try {
      // ProfileService를 통해 사용자 검색
      final profileService = ref.read(profileServiceProvider);
      print('🔍 [AddTeamMember] Searching for: $query');
      final results = await profileService.searchUsers(keyword: query);
      print('📥 [AddTeamMember] Search results: ${results.length} users found');

      if (mounted) {
        setState(() {
          _isSearching = false;
          _searchResults = results;
        });
      }
    } catch (e) {
      print('❌ [AddTeamMember] Error searching users: $e');
      if (mounted) {
        setState(() {
          _isSearching = false;
          _searchResults = [];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('사용자 검색 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  void _toggleMemberSelection(AgoraProfileResponse member) {
    setState(() {
      if (_selectedMembers.any((m) => m.userId == member.userId)) {
        _selectedMembers.removeWhere((m) => m.userId == member.userId);
      } else {
        _selectedMembers.add(member);
      }
    });
  }

  void _addSelectedMembers() {
    if (_selectedMembers.isEmpty) return;

    // AgoraProfileResponse를 Map으로 변환
    final membersData = _selectedMembers.map((profile) {
      return {
        'name': profile.displayName,
        'phone': profile.phone ?? '',
        'id': profile.agoraId,
        'image': profile.profileImage ?? '',
      };
    }).toList();

    widget.onMembersAdded(membersData);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_selectedMembers.length}명을 팀원으로 추가했습니다'),
        duration: const Duration(seconds: 2),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          '팀원 추가',
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
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPhoneSearchTab(),
                _buildIdSearchTab(),
                _buildQrCodeTab(),
              ],
            ),
          ),
          if (_selectedMembers.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _addSelectedMembers,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      '${_selectedMembers.length}명 초대하기',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
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
                '전화번호로 팀원 찾기',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
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
                        onSubmitted: (_) => _searchMember(),
                        decoration: InputDecoration(
                          hintText: '010-1234-5678',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          border: InputBorder.none,
                          filled: false,
                          fillColor: Colors.transparent,
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
                        onPressed: _searchMember,
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
                '아이디로 팀원 찾기',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  onSubmitted: (_) => _searchMember(),
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
                                _hasSearched = false;
                              });
                            },
                            child: const Icon(Icons.close,
                                color: Colors.grey, size: 20),
                          )
                        : IconButton(
                            icon: const Icon(Icons.search,
                                color: Colors.grey, size: 20),
                            onPressed: _searchMember,
                          ),
                    border: InputBorder.none,
                    filled: false,
                    fillColor: Colors.transparent,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                  ),
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
              color: Colors.grey.shade200,
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
            'QR 코드로 팀원 추가',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '팀원의 QR 코드를 스캔하면\n팀원으로 추가할 수 있습니다',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultsList() {
    if (_searchQuery.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 60,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              '사용자를 검색하세요',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '아이디, 이름, 전화번호로 검색할 수 있습니다',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
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

    // 검색을 실행하지 않았으면 안내 메시지 표시
    if (!_hasSearched) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 60,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              '검색 버튼을 눌러주세요',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '2글자 이상 입력 후 검색하세요',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade400,
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
        final member = _searchResults[index];
        final isSelected = _selectedMembers.any((m) => m.userId == member.userId);

        return GestureDetector(
          onTap: () => _toggleMemberSelection(member),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue.withOpacity(0.05) : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.grey.shade200,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20),
                    image: member.profileImage != null
                        ? DecorationImage(
                            image: NetworkImage(member.profileImage!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: member.profileImage == null
                      ? const Icon(Icons.person, size: 32, color: Colors.grey)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '@${member.agoraId}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      if (member.phone != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          member.phone!,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? Colors.blue : Colors.white,
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey.shade400,
                      width: 1.5,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check,
                          size: 16, color: Colors.white)
                      : null,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
