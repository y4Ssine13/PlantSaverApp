import "package:flutter/material.dart";
import "plant.dart";

class PlantDetailsPage extends StatefulWidget {
  final Plant plant;
  const PlantDetailsPage({super.key, required this.plant});
  @override
  PlantDetailsPageState createState() => PlantDetailsPageState();
}

class PlantDetailsPageState extends State<PlantDetailsPage>{
  Map<String, bool> expansionStates = {"infos" : false, "Soil Moisture" : true, "Temperature" : true, "Light" : true };

  Widget buildRetractableWidget(String title, {double height = 150 }){
    bool isExpanded = expansionStates[title] ?? false;
    double width = MediaQuery.of(context).size.width - 20;
    return Container(
      width: width ,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 161, 231, 163),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap : () {
              setState(() {
                expansionStates[title] = !isExpanded;
                isExpanded = expansionStates[title] ?? false;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.vertical(
                  top: const Radius.circular(20),
                  bottom: isExpanded ? Radius.zero : const Radius.circular(20),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children:[
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Icon(
                      isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedContainer(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 161, 231, 163),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: isExpanded ? height : 0,
            width: width,
            child: isExpanded 
              ? Center(child: Text(title))
              :null,
          ),
        ], 
      ),
    );
  }

  Widget buildBody(){
    return ListView(
      padding: const EdgeInsets.all(10),  
      children: [
        buildRetractableWidget("infos", height: 350),
        const Divider(color: Colors.transparent),
        buildRetractableWidget("Soil Moisture"),
        const Divider(color: Colors.transparent),
        buildRetractableWidget("Temperature"),
        const Divider(color: Colors.transparent),
        buildRetractableWidget("Light"),
      ],
    );
  }

  @override
  Widget build (BuildContext context){
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: scheme.primary,
        title : Text(widget.plant.name, 
          style: TextStyle(
            color: scheme.onPrimary,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: buildBody(),
    );
  }
}