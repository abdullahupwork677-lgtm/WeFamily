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
    String? name,
    String? phone,
    String? photoUrl,
    DateTime? birthDate,
    String? gender,
    String? language,
  }) {
    return AppUser(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      language: language ?? this.language,
    );
  }
}

class FamilyCircle {
  const FamilyCircle({
    required this.id,
    required this.name,
    required this.ownerUid,
    required this.inviteCode,
    required this.memberUids,
  });

  final String id;
  final String name;
  final String ownerUid;
  final String inviteCode;
  final List<String> memberUids;
}

class CircleMember {
  const CircleMember({
    required this.uid,
    required this.name,
    required this.relation,
    this.photoUrl,
    this.role = 'member',
    this.sharingLocation = true,
    this.ghostMode = false,
    this.lat,
    this.lng,
    this.batteryLevel,
    this.placeLabel,
    this.lastUpdated,
    this.isMoving = false,
    this.speedKmh,
    this.headingDeg,
    this.sinceAt,
  });

  final String uid;
  final String name;
  final String relation;
  final String? photoUrl;
  final String role;
  final bool sharingLocation;
  final bool ghostMode;
  final double? lat;
  final double? lng;
  final int? batteryLevel;
  final String? placeLabel;
  final DateTime? lastUpdated;
  final bool isMoving;
  final double? speedKmh;
  final double? headingDeg;

  /// When the member arrived at the current place (drives "Here for").
  final DateTime? sinceAt;

  CircleMember copyWith({
    bool? sharingLocation,
    bool? ghostMode,
    double? lat,
    double? lng,
    int? batteryLevel,
    String? placeLabel,
    DateTime? lastUpdated,
    bool? isMoving,
    double? speedKmh,
    double? headingDeg,
    DateTime? sinceAt,
  }) {
    return CircleMember(
      uid: uid,
      name: name,
      relation: relation,
      photoUrl: photoUrl,
      role: role,
      sharingLocation: sharingLocation ?? this.sharingLocation,
      ghostMode: ghostMode ?? this.ghostMode,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      placeLabel: placeLabel ?? this.placeLabel,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isMoving: isMoving ?? this.isMoving,
      speedKmh: speedKmh ?? this.speedKmh,
      headingDeg: headingDeg ?? this.headingDeg,
      sinceAt: sinceAt ?? this.sinceAt,
    );
  }
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.senderUid,
    required this.senderName,
    required this.type,
    this.text,
    this.lat,
    this.lng,
    required this.createdAt,
  });

  final String id;
  final String senderUid;
  final String senderName;
  final String type; // text | location
  final String? text;
  final double? lat;
  final double? lng;
  final DateTime createdAt;
}

class TreePerson {
  const TreePerson({
    required this.id,
    required this.name,
    this.photoUrl,
    this.birthDate,
    this.gender = 'other',
    this.linkedUid,
    this.generation = 0,
  });

  final String id;
  final String name;
  final String? photoUrl;
  final DateTime? birthDate;
  final String gender;
  final String? linkedUid;
  final int generation;
}

class TreeRelation {
  const TreeRelation({
    required this.fromPersonId,
    required this.toPersonId,
    required this.type, // parent | child | spouse | sibling
    required this.label,
  });

  final String fromPersonId;
  final String toPersonId;
  final String type;
  final String label;
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    this.icon = 'notifications',
  });

  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final String icon;
}
