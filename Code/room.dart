import "plant.dart";

class Room {
  List<Plant> plants = [];
  String name = "";

  Room(this.name);

  Room.withPlantList({ required this.name, required this.plants});

  factory Room.fromJson(Map<String, dynamic> json){
    List<Plant> plants = List<Plant>.from((json["plants"] as List).map((plant) => Plant.fromJson(plant)));
    return Room.withPlantList(name : json["name"], plants : plants);
  }

  Map<String, dynamic> toJson(){
    return {
      "name" : name,
      "plants" : plants.map((plant) => plant.toJson()).toList(),
    };
  }
}