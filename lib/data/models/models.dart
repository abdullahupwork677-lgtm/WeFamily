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
    this.presenceMode,
    this.sosActive = false,
    this.sosLat,
    this.sosLng,
    this.sosAt,
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

  /// Optional mode picked by the member (driving/home/work/outside/event).
  final PresenceMode? presenceMode;

  /// Active emergency alert. Coordinates stay at the moment SOS was pressed.
  final bool sosActive;
  final double? sosLat;
  final double? sosLng;
  final DateTime? sosAt;

  bool get hasActiveSos => sosActive && sosLat != null && sosLng != null;

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
    PresenceMode? presenceMode,
    bool clearPresenceMode = false,
    bool? sosActive,
    double? sosLat,
    double? sosLng,
    DateTime? sosAt,
    bool clearSos = false,
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
      presenceMode: clearPresenceMode
          ? null
          : (presenceMode ?? this.presenceMode),
      sosActive: sosActive ?? this.sosActive,
      sosLat: clearSos ? null : (sosLat ?? this.sosLat),
      sosLng: clearSos ? null : (sosLng ?? this.sosLng),
      sosAt: clearSos ? null : (sosAt ?? this.sosAt),
    );
  }
}

/// What a member is currently doing, derived from their speed.
enum MemberActivity { driving, walking, cycling, stationary, offline }

/// A mode the member explicitly chooses to show on the family map.
enum PresenceMode { driving, home, work, outside, event }

PresenceMode? presenceModeFromString(String? value) {
  if (value == null || value.isEmpty) return null;
  for (final mode in PresenceMode.values) {
    if (mode.name == value) return mode;
  }
  return null;
}

extension CircleMemberActivity on CircleMember {
  /// True when the last location fix is older than 3 minutes.
  bool get isStale {
    final updated = lastUpdated;
    if (updated == null) return false;
    return DateTime.now().difference(updated).inMinutes > 3;
  }

  /// True when the member is actively sharing a fresh location.
  bool get isLive => sharingLocation && !ghostMode && !isStale;

  MemberActivity get activity {
    if (!sharingLocation || ghostMode || isStale) {
      return MemberActivity.offline;
    }
    final speed = speedKmh ?? 0;
    if (!isMoving || speed < 1.5) return MemberActivity.stationary;
    if (speed >= 18) return MemberActivity.driving;
    if (speed >= 7) return MemberActivity.cycling;
    return MemberActivity.walking;
  }
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.senderUid,
    required this.senderName,
    required this.type,
    this.text,
    this.mediaUrl,
    this.thumbUrl,
    this.width,
    this.height,
    this.durationMs,
    this.lat,
    this.lng,
    required this.createdAt,
    this.status = 'sent',
    this.localPath,
  });

  final String id;
  final String senderUid;
  final String senderName;
  final String type; // text | image | voice | location
  final String? text;
  final String? mediaUrl;
  final String? thumbUrl;
  final double? width;
  final double? height;
  final int? durationMs;
  final double? lat;
  final double? lng;
  final DateTime createdAt;
  final String status; // sending | sent | failed

  /// Local file path for an attachment that has not finished uploading.
  final String? localPath;

  ChatMessage copyWith({String? status}) => ChatMessage(
    id: id,
    senderUid: senderUid,
    senderName: senderName,
    type: type,
    text: text,
    mediaUrl: mediaUrl,
    thumbUrl: thumbUrl,
    width: width,
    height: height,
    durationMs: durationMs,
    lat: lat,
    lng: lng,
    createdAt: createdAt,
    status: status ?? this.status,
    localPath: localPath,
  );
}

class TreePerson {
  const TreePerson({
    required this.id,
    required this.name,
    this.photoUrl,
    this.about,
    this.birthDate,
    this.gender = 'other',
    this.linkedUid,
    this.generation = 0,
    this.relation = 'other',
    this.relatedToId,
    this.parentIds = const <String>[],
    this.spouseId,
    this.createdAt,
  });

  final String id;
  final String name;
  final String? photoUrl;
  final String? about;
  final DateTime? birthDate;
  final String gender;
  final String? linkedUid;
  final int generation;

  /// Relation label relative to [relatedToId], e.g. `father` or `wife`.
  final String relation;

  /// Person this node was originally added against.
  final String? relatedToId;

  /// Graph edges used by the relatives tab and tree layout.
  final List<String> parentIds;
  final String? spouseId;
  final DateTime? createdAt;

  TreePerson copyWith({
    String? name,
    String? photoUrl,
    String? about,
    DateTime? birthDate,
    String? gender,
    String? linkedUid,
    int? generation,
    String? relation,
    String? relatedToId,
    List<String>? parentIds,
    String? spouseId,
    bool clearSpouse = false,
    bool clearBirthDate = false,
    bool clearPhoto = false,
    bool clearAbout = false,
  }) {
    return TreePerson(
      id: id,
      name: name ?? this.name,
      photoUrl: clearPhoto ? null : (photoUrl ?? this.photoUrl),
      about: clearAbout ? null : (about ?? this.about),
      birthDate: clearBirthDate ? null : (birthDate ?? this.birthDate),
      gender: gender ?? this.gender,
      linkedUid: linkedUid ?? this.linkedUid,
      generation: generation ?? this.generation,
      relation: relation ?? this.relation,
      relatedToId: relatedToId ?? this.relatedToId,
      parentIds: parentIds ?? this.parentIds,
      spouseId: clearSpouse ? null : (spouseId ?? this.spouseId),
      createdAt: createdAt,
    );
  }
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
