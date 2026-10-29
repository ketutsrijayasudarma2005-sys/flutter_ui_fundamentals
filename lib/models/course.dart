class Course {
  final int? id;
  final String code;
  final String title;
  final int credits;
  final String status;
  final String category;
  final String? createdAt;
  final String? description;
  final int? userId;

  const Course({
    this.id,
    required this.code,
    required this.title,
    required this.credits,
    this.status = 'planned',
    this.category = 'General',
    this.createdAt,
    this.description,
    this.userId,
  });

  // 18, 19, 20. fromJson mendukung id nullable, default status 'planned', dan mapping field JSON API
  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as int?,
      code: (json['code'] as String?) ??
          (json['id'] != null ? 'POST-${json['id']}' : 'UNKNOWN'),
      title: (json['title'] as String?) ?? '',
      credits: (json['credits'] as int?) ?? 1,
      status: (json['status'] as String?) ?? 'planned',
      category: (json['category'] as String?) ??
          (json['userId'] != null ? 'UserID: ${json['userId']}' : 'General'),
      createdAt: json['created_at'] as String?,
      description: (json['body'] as String?) ?? (json['description'] as String?),
      userId: json['userId'] as int?,
    );
  }

  // 18. Method toJson()
  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'code': code,
    'title': title,
    'credits': credits,
    'status': status,
    'category': category,
    if (createdAt != null) 'created_at': createdAt,
    if (description != null) 'description': description,
    if (userId != null) 'userId': userId,
  };
}
