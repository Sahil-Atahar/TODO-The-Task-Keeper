import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  final _dbName = 'Todo_Record.db';
  final _dbVersion = 1;

  final tableNames = 'tableNames';

  final idColumn = 'id';
  final titleColumn = 'title';
  final descriptionColumn = 'description';
  final dateTimeColumn = 'datetime';
  final fgColorColumn = 'fgColor';
  final isCompleted = 'isCompleted';
  final isImportant = 'isImportant';
  final isPinned = 'isPinned';
  final isHidden = 'isHidden';
  final bgColor = 'bgColor';


  static Database? _database;

  DBHelper._privateConstructor();
  static final instance = DBHelper._privateConstructor();

  Future<Database?> get database async {
    if (_database != null) return _database;

    _database = await createDatabase();
    return _database;
  }

  Future<Database> createDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, _dbName);
    return await openDatabase(path, version: _dbVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await _createTableToStoreTableNames(db, version);
  }

  Future _createTableToStoreTableNames(Database db, int version) async {
    await db.execute('''
      create table $tableNames (
      $idColumn INTEGER PRIMARY KEY,
      'tableName',
      'color');
      ''');
  }

  Future updateNamesTable(row, id) async {
    Database? db = await instance.database;
    return await db!.update(tableNames, row, where: 'id == ?', whereArgs: [id]);
  }

  Future createTable(String newTableName) async {
    newTableName = newTableName.replaceAll(' ', '_');
    var db = await DBHelper.instance.database;
    await db!.execute('''
        create table if not exists $newTableName(
        $idColumn INTEGER PRIMARY KEY,
        $titleColumn,
        $descriptionColumn,
        $dateTimeColumn,
        $fgColorColumn,
        $isCompleted,
        $isImportant,
        $isPinned,
        $isHidden,
        $bgColor)
        ''');
  }

  Future deleteTable(String tableName) async {
    tableName = tableName.replaceAll(' ', '_');
    var db = await DBHelper.instance.database;
    await db!.execute('''
      drop table if exists $tableName 
      ''');
  }

  Future deleteTableName(String tableName) async {
    Database? db = await instance.database;
    await db!
        .delete(tableNames, where: "tableName = ?", whereArgs: [tableName]);
  }

  Future<int> insertTableName(Map<String, dynamic> row) async {
    Database? db = await instance.database;
    return await db!.insert(tableNames, row);
  }

  Future updateTableNames(Map<String, dynamic> row, id) async {
    Database? db = await instance.database;
    return await db!.update(tableNames, row, where: 'id == ?', whereArgs: [id]);
  }

  Future renameTable({required String oldName, required String newName}) async {
    oldName = oldName.replaceAll(' ', '_');
    newName = newName.replaceAll(' ', '_');
    Database? db = await instance.database;
    return await db!.execute('''
    ALTER TABLE $oldName RENAME TO $newName;
    ''');
  }

  Future<List<Map<String, dynamic>>> specialQuerryForTableNme(id) async {
    Database? db = await instance.database;
    return await db!.query(tableNames, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> queryAllForTableName() async {
    Database? db = await instance.database;
    return await db!.query(tableNames);
  }

  Future specialDeleteFromTableName(id) async {
    Database? db = await instance.database;
    await db!.delete(tableNames, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insert(tableName, Map<String, dynamic> row) async {
    tableName = tableName.replaceAll(' ', '_');
    Database? db = await instance.database;
    return await db!.insert(tableName, row);
  }

  Future<List<Map<String, dynamic>>> specialQuerry(tableName, id) async {
    tableName = tableName.replaceAll(' ', '_');
    Database? db = await instance.database;
    return await db!.query(tableName, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> queryAll(String tableName) async {
    tableName = tableName.replaceAll(' ', '_');
    Database? db = await instance.database;
    return await db!.query(tableName);
  }

  Future update(tableName, String id, task) async {
    tableName = tableName.replaceAll(' ', '_');
    Database? db = await instance.database;
    return await db!.update(tableName, task, where: 'id = ?', whereArgs: [id]);
  }

  Future specialDelete(tableName, id) async {
    tableName = tableName.replaceAll(' ', '_');
    Database? db = await instance.database;
    await db!.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }
}
