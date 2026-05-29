import '../entities/room_entity.dart';

abstract class RoomRepository {
  Future<RoomEntity> createRoom(String name, String userId, String displayName);
  Future<RoomEntity?> joinRoom(String code, String userId, String displayName);
  Future<List<RoomEntity>> getUserRooms(String userId);
  Future<RoomEntity?> getRoomById(String roomId);
  Future<void> leaveRoom(String roomId, String userId);
  Future<void> updateMemberPoints(String userId, int totalPoints);
  Stream<RoomEntity> watchRoom(String roomId);
}