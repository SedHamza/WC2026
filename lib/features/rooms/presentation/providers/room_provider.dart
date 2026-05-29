import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/room_repository_impl.dart';
import '../../domain/entities/room_entity.dart';
import '../../domain/repositories/room_repository.dart';

final roomRepositoryProvider = Provider<RoomRepository>((ref) {
  return RoomRepositoryImpl();
});

final userRoomsProvider = FutureProvider<List<RoomEntity>>((ref) async {
  final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
  if (userId.isEmpty) return [];
  return ref.watch(roomRepositoryProvider).getUserRooms(userId);
});

final roomDetailProvider =
    StreamProvider.family<RoomEntity, String>((ref, roomId) {
  return ref.watch(roomRepositoryProvider).watchRoom(roomId);
});