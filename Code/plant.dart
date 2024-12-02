// import "package:hive/hive.dart";

// part "plant.g.dart";

// @HiveType(typeId: 1)
class Plant {
  // @HiveField(0)
  String name = "";
  // @HiveField(1)
  String type = "";
  // @HiveField(2)
  String thumbnail = "";
  // @HiveField(3)
  String accessToken = "";
  // @HiveField(4)
  double potDiam = 0;
  // @HiveField(5)
  double potDepth = 0;
  // @HiveField(6)
  String id = "";
  String deviceId = "";
  Plant(this.name);

  Plant.withoutName(this.thumbnail, this.type, this.accessToken);


}