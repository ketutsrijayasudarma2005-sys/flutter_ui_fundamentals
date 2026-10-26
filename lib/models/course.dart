class Course {
  final int? id;
  final String code;
  final String title;
  final int credits;
  final String status;
  final String category;
  final String? createdAt;

  const Course({
    this.id,
    required this.code,
    required this.title,
    required this.credits,
    this.status = 'planned',
    this.category = 'General',
    this.createdAt,
  });

  // 18, 19, 20. fromJson mendukung id nullable, default status 'planned', dan mapping field JSON API
  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as int?,
      code: json['code'] as String,
      title: json['title'] as String,
      credits: json['credits'] as int,
      status: (json['status'] as String?) ?? 'planned',
      category: (json['category'] as String?) ?? 'General',
      createdAt: json['created_at'] as String?,
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
  };
}
