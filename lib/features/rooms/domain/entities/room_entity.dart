class RoomEntity {
  final String id;
  final String code;
  final String name;
  final String creatorId;
  final List<RoomMemberEntity> members;
  final DateTime createdAt;

  const RoomEntity({
    required this.id,
    required this.code,
    required this.name,
    required this.creatorId,
    required this.members,
    required this.createdAt,
  });

  int get memberCount => members.length;

  RoomMemberEntity? getMember(String userId) {
    try {
      return members.firstWhere((m) => m.userId == userId);
    } catch (_) {
      return null;
    }
  }

  List<RoomMemberEntity> get sortedMembers {
    final sorted = List<RoomMemberEntity>.from(members);
    sorted.sort((a, b) => b.totalPoints.compareTo(a.totalPoints));
    return sorted;
  }

  int getRank(String userId) {
    final sorted = sortedMembers;
    final index = sorted.indexWhere((m) => m.userId == userId);
    return index == -1 ? 0 : index + 1;
  }
}

class RoomMemberEntity {
  final String userId;
  final String displayName;
  final String? photoUrl;
  final int totalPoints;
  final DateTime joinedAt;

  const RoomMemberEntity({
    required this.userId,
    required this.displayName,
    this.photoUrl,
    required this.totalPoints,
    required this.joinedAt,
  });

  String get initials {
    final parts = displayName
        .split(' ')
        .where((s) => s.isNotEmpty)
        .toList();

    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (parts.length == 1 && parts[0].isNotEmpty) {
      return parts[0]
          .substring(0, parts[0].length >= 2 ? 2 : 1)
          .toUpperCase();
    }
    return 'MB';
  }

  // Retourne le premier mot non vide du displayName
  String get firstName {
    return displayName
        .split(' ')
        .firstWhere((s) => s.isNotEmpty, orElse: () => 'Membre');
  }
}