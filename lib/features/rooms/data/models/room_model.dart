import '../../domain/entities/room_entity.dart';

class RoomModel {
  static RoomEntity fromFirestore(String id, Map<String, dynamic> json) {
    final membersData = json['members'] as Map<String, dynamic>? ?? {};
    final members = membersData.entries.map((e) {
      final data = e.value as Map<String, dynamic>;
      return RoomMemberEntity(
        userId: e.key,
        displayName: data['displayName'] ?? 'Utilisateur',
        photoUrl: data['photoUrl'],
        totalPoints: data['totalPoints'] ?? 0,
        joinedAt: DateTime.tryParse(data['joinedAt'] ?? '') ?? DateTime.now(),
      );
    }).toList();

    return RoomEntity(
      id: id,
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      creatorId: json['creatorId'] ?? '',
      members: members,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  static Map<String, dynamic> toFirestore(RoomEntity room) {
    return {
      'code': room.code,
      'name': room.name,
      'creatorId': room.creatorId,
      'createdAt': room.createdAt.toIso8601String(),
      'members': {
        for (final m in room.members)
          m.userId: {
            'displayName': m.displayName,
            'photoUrl': m.photoUrl,
            'totalPoints': m.totalPoints,
            'joinedAt': m.joinedAt.toIso8601String(),
          },
      },
    };
  }
}