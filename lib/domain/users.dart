
/// Model sederhana untuk User Data
class AppUser {
  final String uid;
  final String? email;
  final String? username;
  final String? nickname;
  final bool isGuest;

  AppUser({
    required this.uid,
    this.email,
    this.username,
    this.nickname,
    required this.isGuest,
  });

  factory AppUser.fromFirestore(String uid, Map<String, dynamic> data) {
    return AppUser(
      uid: uid,
      email: data['email'],
      username: data['username'],
      nickname: data['nickname'],
      isGuest: data['is_guest'] ?? false,
    );
  }
}