class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.phone,
    this.photoUrl,
    this.birthDate,
    this.gender,
    this.language = 'en',
  });

  final String id;
  final String name;
  final String phone;
  final String? photoUrl;
  final DateTime? birthDate;
  final String? gender;
  final String language;

  AppUser copyWith({
    String? id,
    String? name,
    String? phone,
    String? photoUrl,
    DateTime? birthDate,
    String? gender,
    String? language,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      language: language ?? this.language,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'phone': phone,
        'photoUrl': photoUrl,
        'birthDate': birthDate?.toIso8601String(),
        'gender': gender,
        'language': language,
      };

  factory AppUser.fromMap(Map<String, dynamic> map) => AppUser(
        id: map['id'] as String,
        name: map['name'] as String,
        phone: map['phone'] as String,
        photoUrl: map['photoUrl'] as String?,
        birthDate: map['birthDate'] != null ? DateTime.parse(map['birthDate'] as String) : null,
        gender: map['gender'] as String?,
        language: map['language'] as String? ?? 'en',
      );
}
