class Posts {
  final String id;
  final String userId;
  final String content;
  final List<String> images;
  final String? nickname;
  final DateTime createdAt;

  Posts({
    required this.id,
    required this.userId,
    required this.nickname,
    required this.content,
    required this.images,
    required this.createdAt,
  });
  factory Posts.fromFirestore(
    String id,
    Map<String, dynamic> data, {
    Map<String, dynamic>? userData,
  }) {
    return Posts(
      id: id,
      userId: data['user_id'],
      nickname: userData != null ? userData['nickname'] as String? : null,
      content: data['content'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      createdAt: (data['created_at'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }
}
