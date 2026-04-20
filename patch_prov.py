with open('lib/features/communities/logic/community_provider.dart', 'r') as f:
    text = f.read()

method = """
  List<CommunityMemberModel> _members = [];
  bool _isLoadingMembers = false;
  List<CommunityMemberModel> get members => _members;
  bool get isLoadingMembers => _isLoadingMembers;

  Future<void> loadMembers(int communityId) async {
    _isLoadingMembers = true;
    _members = [];
    notifyListeners();

    final response = await _repository.fetchMembers(communityId);
    if (response.success && response.data != null) {
      final list = response.data as List;
      _members = list.map((m) => CommunityMemberModel.fromJson(m as Map<String, dynamic>)).toList();
    } else {
      _errorMessage = response.message;
    }
    _isLoadingMembers = false;
    notifyListeners();
  }
"""

if "_members" not in text:
    pos = text.find('Future<void> loadPosts(int communityId) async {')
    text = text[:pos] + method + '\n  ' + text[pos:]
    with open('lib/features/communities/logic/community_provider.dart', 'w') as f:
        f.write(text)
