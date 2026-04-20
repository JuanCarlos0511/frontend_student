with open('lib/features/communities/data/repositories/community_repository.dart', 'r') as f:
    text = f.read()

method = """
  Future<ApiResponse> fetchMembers(int communityId) async {
    try {
      final response = await _api.get('/api/communities/$communityId/members');
      return ApiResponse.fromJson(response.data);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }
"""

if "fetchMembers" not in text:
    pos = text.find('Future<ApiResponse> fetchPosts')
    text = text[:pos] + method + '\n  ' + text[pos:]
    with open('lib/features/communities/data/repositories/community_repository.dart', 'w') as f:
        f.write(text)
