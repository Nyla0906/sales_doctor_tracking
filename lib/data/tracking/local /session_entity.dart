import 'package:floor/floor.dart';

@Entity(tableName: 'sessions')
class SessionEntity{
  @primaryKey
  final String sessionId;

  final String startTime;
  final String status;
  final String? stopTime;

  SessionEntity({
    required this.sessionId,
    required this.startTime,
    required this.status,
    required this.stopTime,

});
}