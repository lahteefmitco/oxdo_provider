
import 'package:oxdo_provider/models/person/person.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {

  // Declare database variable as private, static, and late
  static late Database _db;


  /// Init database
  static Future<void> initDatabase() async {
    // Get path of the database
    final String path = join(await getDatabasesPath(), "my_database.db");
    // Assign value to _db
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // create person table
        await db.execute('''
          CREATE TABLE IF NOT EXISTS person(
            id INTEGER  PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            age INTEGER
          )''',
        );
      },
    );
  }

  static Future<int> insertPerson(Person person) async {
    try {
      return _db.insert(
        "person",
        person.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception("Person insert exception:$e");
    }
  }

  static Future<List<Person>> getAllPersons() async {
    try {
      final List<Map<String, dynamic>> list = await _db.query("person");
      return list.map((element) => Person.fromJson(element)).toList();
    } catch (e) {
      throw Exception("Get all exception:$e");
    }
  }

  static Future updatePerson(Person person) async {
    try {
      await _db.update("person", (person.toJson()),
          where: "id=?", whereArgs: [person.id]);
    } catch (e) {
      throw Exception("Person update exception:$e");
    }
  }

  static Future deletePerson(int id) async {
    try {
      await _db.delete("person", where: "id=?", whereArgs: [id]);
    } catch (e) {
      throw Exception("Person delete exception:$e");
    }
  }

  /// To close database
  static void closeDatabase() {
    _db.close();
  }
}
