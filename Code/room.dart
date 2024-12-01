import "plant.dart";
// import "package:hive/hive.dart";

// part "room.g.dart";

// @HiveType(typeId: 0)
class Room {
  // @HiveField(0)
  List<Plant> plants = [];
  // @HiveField(1)
  String name = "";

  Room(this.name);
}