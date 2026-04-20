/// Centralised API endpoint constants.
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://backend.124559.xyz/api';
  static const String wsUrl = 'https://backend.124559.xyz';

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String registrationStatus = '/auth/status';

  // Students
  static const String students = '/students';

  // Profile (authenticated student)
  static const String myProfile = '/students/me/profile';
  static const String myProfilePhoto = '/students/me/profile-photo';

  // Posts
  static const String posts = '/posts';
  static String postReplies(int postId) => '/posts/$postId/replies';

  // Market
  static const String market = '/market';

  // Bus
  static const String busReport = '/bus/report';
  static const String busActive = '/bus/active';

  // Chat
  static const String chatRoom = '/chat/room';
  static const String chatRooms = '/chat/rooms';
  static String chatMessages(int roomId) => '/chat/rooms/$roomId/messages';

  // Moderator
  static const String moderatorApply = '/moderator/apply';
  static const String moderatorApplications = '/moderator/applications';
  static String moderatorApprove(int id) => '/moderator/applications/$id/approve';
  static String moderatorReject(int id) => '/moderator/applications/$id/reject';

  // Communities
  static const String communities = '/communities';
  static String communityDetail(int id) => '/communities/$id';
  static String communityJoin(int id) => '/communities/$id/join';
  static String communityLeave(int id) => '/communities/$id/leave';
  static String communityPosts(int id) => '/communities/$id/posts';
}
