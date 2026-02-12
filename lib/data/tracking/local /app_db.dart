import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'session_entity.dart';
import 'session_dao.dart';

part 'app_db.g.dart';

@Database(version: 1, entities: [SessionEntity])
abstract class AppDatabase extends FloorDatabase {
  SessionDao get sessionDao;
}
