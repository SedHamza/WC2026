import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/room_entity.dart';
import '../../domain/repositories/room_repository.dart';
import '../models/room_model.dart';

class RoomRepositoryImpl implements RoomRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Génère un code unique WC26-XXXX ────────────────────────────────────────
  Future<String> _generateUniqueCode() async {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rand = Random.secure();

    while (true) {
      final code =
          List.generate(4, (_) => chars[rand.nextInt(chars.length)]).join();
      final fullCode = 'WC26-$code';

      // Vérifie que ce code n'existe pas déjà en Firestore
      final existing = await _db
          .collection('rooms')
          .where('code', isEqualTo: fullCode)
          .limit(1)
          .get();

      if (existing.docs.isEmpty) return fullCode;
      // Sinon on régénère un nouveau code
    }
  }

  // ── Crée une room ──────────────────────────────────────────────────────────
  @override
  Future<RoomEntity> createRoom(
      String name, String userId, String displayName) async {
    final code = await _generateUniqueCode();
    final docRef = _db.collection('rooms').doc();

    final room = RoomEntity(
      id: docRef.id,
      code: code,
      name: name,
      creatorId: userId,
      members: [
        RoomMemberEntity(
          userId: userId,
          displayName: displayName,
          totalPoints: 0,
          joinedAt: DateTime.now(),
        ),
      ],
      createdAt: DateTime.now(),
    );

    await docRef.set(RoomModel.toFirestore(room));

    // Ajoute la room dans le profil utilisateur
    await _db.collection('users').doc(userId).set({
      'rooms': FieldValue.arrayUnion([docRef.id]),
    }, SetOptions(merge: true));

    return room;
  }

  // ── Rejoindre une room ────────────────────────────────────────────────────
  @override
  Future<RoomEntity?> joinRoom(
      String code, String userId, String displayName) async {
    // Cherche la room par code
    final snapshot = await _db
        .collection('rooms')
        .where('code', isEqualTo: code.toUpperCase())
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    final doc = snapshot.docs.first;
    final room = RoomModel.fromFirestore(doc.id, doc.data());

    // Vérifie si déjà membre
    if (room.getMember(userId) != null) return room;

    // Ajoute le membre dans la room
    await doc.reference.update({
      'members.$userId': {
        'displayName': displayName,
        'photoUrl': null,
        'totalPoints': 0,
        'joinedAt': DateTime.now().toIso8601String(),
      },
    });

    // Ajoute la room dans le profil utilisateur
    await _db.collection('users').doc(userId).set({
      'rooms': FieldValue.arrayUnion([doc.id]),
    }, SetOptions(merge: true));

    return RoomModel.fromFirestore(doc.id, (await doc.reference.get()).data()!);
  }

  // ── Récupère les rooms d'un utilisateur ───────────────────────────────────
  @override
  Future<List<RoomEntity>> getUserRooms(String userId) async {
    final userDoc = await _db.collection('users').doc(userId).get();
    if (!userDoc.exists) return [];

    final roomIds = List<String>.from(userDoc.data()?['rooms'] as List? ?? []);
    if (roomIds.isEmpty) return [];

    final rooms = await Future.wait(
      roomIds.map((id) async {
        final doc = await _db.collection('rooms').doc(id).get();
        if (!doc.exists) return null;
        return RoomModel.fromFirestore(doc.id, doc.data()!);
      }),
    );

    return rooms.whereType<RoomEntity>().toList();
  }

  // ── Récupère une room par ID ──────────────────────────────────────────────
  @override
  Future<RoomEntity?> getRoomById(String roomId) async {
    final doc = await _db.collection('rooms').doc(roomId).get();
    if (!doc.exists) return null;
    return RoomModel.fromFirestore(doc.id, doc.data()!);
  }

  // ── Quitter une room ──────────────────────────────────────────────────────
  @override
  Future<void> leaveRoom(String roomId, String userId) async {
    final roomDoc = await _db.collection('rooms').doc(roomId).get();
    if (!roomDoc.exists) return;

    final members = (roomDoc.data()?['members'] as Map?)?.keys.toList() ?? [];

    if (members.length <= 1) {
      // Dernier membre → supprimer toute la room
      await _db.collection('rooms').doc(roomId).delete();
    } else {
      // Il reste d'autres membres → juste retirer ce membre
      await _db.collection('rooms').doc(roomId).update({
        'members.$userId': FieldValue.delete(),
      });
    }

    // Dans tous les cas, retirer la room du profil utilisateur
    await _db.collection('users').doc(userId).set({
      'rooms': FieldValue.arrayRemove([roomId]),
    }, SetOptions(merge: true));
  }

  // ── Met à jour les points dans toutes les rooms ───────────────────────────
  @override
  Future<void> updateMemberPoints(String userId, int totalPoints) async {
    final userDoc = await _db.collection('users').doc(userId).get();
    if (!userDoc.exists) return;

    final roomIds = List<String>.from(userDoc.data()?['rooms'] as List? ?? []);
    if (roomIds.isEmpty) return;

    // Tous les writes en une seule requête atomique
    final batch = _db.batch();
    for (final roomId in roomIds) {
      batch.update(
        _db.collection('rooms').doc(roomId),
        {'members.$userId.totalPoints': totalPoints},
      );
    }
    await batch.commit();
  }

  // ── Stream temps réel d'une room ──────────────────────────────────────────
  @override
  Stream<RoomEntity> watchRoom(String roomId) {
    return _db
        .collection('rooms')
        .doc(roomId)
        .snapshots()
        .where((doc) => doc.exists)
        .map((doc) => RoomModel.fromFirestore(doc.id, doc.data()!));
  }
}
