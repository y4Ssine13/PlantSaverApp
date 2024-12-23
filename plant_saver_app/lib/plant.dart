import "dart:convert";

import "package:http/http.dart" as http;

class Plant {
  String name = "";
  String type = "";
  String thumbnail = "";
  String accessToken = "";
  double potDiam = 0;
  double potDepth = 0;
  String id = "";
  String deviceId = "";
  Map<String, dynamic> data = {};

  Plant(this.name);

  Plant.withoutName(this.thumbnail, this.type, this.accessToken);

  Plant.withAll({required this.name, required this.type, required this.thumbnail, 
    required this.accessToken, required this.potDiam, required this.potDepth, required this.id,
    required this.deviceId});

  factory Plant.fromJson(Map<String, dynamic> json){
    return Plant.withAll(
      name: json["name"],
      type: json["type"],
      thumbnail: json["thumbnail"],
      accessToken: json["accessToken"],
      potDiam: json["potDiam"],
      potDepth: json["potDepth"],
      id: json["id"],
      deviceId: json["deviceId"]
    );
  }

  Map<String, dynamic> toJson(){
    return {
      "name": name,
      "type": type,
      "thumbnail": thumbnail,
      "accessToken": accessToken,
      "potDiam": potDiam,
      "potDepth": potDepth,
      "id": id,
      "deviceId": deviceId
    };
  }

  Future<void> fetchLiveData(String apikey) async {
    try{
      final response = await http.get(Uri.parse("https://api.thingspeak.com/channels/$deviceId/feeds.json?api_key=$apikey&results=1"));

      if(response.statusCode == 200) {
        String responseBody = response.body;
        var jsonData = jsonDecode(responseBody);
        if(jsonData is Map && jsonData.containsKey("feeds")){
            data = jsonData["feeds"][0];
        }
        else{
          print("No plant names found in the response !!!!!!!");
        }
      }else{
        print("Failed to load plants: ${response.statusCode} - ${response.reasonPhrase}");
      }
    }
    catch(error){
      print("Error fetching plant: $error");
    }
  }
}