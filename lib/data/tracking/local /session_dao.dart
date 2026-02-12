import 'package:floor/floor.dart';
import 'session_entity.dart';

@dao
abstract class SessionDao {
  @Query('SELECT * FROM sessions ORDER BY startTime DESC')
  Future<List<SessionEntity>> getAll();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> upsert(SessionEntity s);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> upsertAll(List<SessionEntity> list);

  @Query(
      'UPDATE sessions '
          'SET status = :status, stopTime = :stopTime '
          'WHERE sessionId = :sessionId'
  )
  Future<void> markStopped(
      String sessionId,
      String status,
      String stopTime,
      );

  @Query('DELETE FROM sessions')
  Future<void> clear();
}
