import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

void main() {
  runApp(const MaterialApp(
    home: PaperCounterApp(),
  ));
}

class PaperCounterApp extends StatefulWidget {
  const PaperCounterApp({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PaperCounterAppState createState() => _PaperCounterAppState();
}

class _PaperCounterAppState extends State<PaperCounterApp> {
  String arduinoIP = "http://192.168.1.100"; // Replace with your Arduino's IP
  int paperCount = 0;

  // Controllers for X and Y input fields
  TextEditingController xController = TextEditingController();
  TextEditingController yController = TextEditingController();

  // Send command to Arduino
  void sendCommand(String command) async {
    try {
      var response = await http.get(Uri.parse("$arduinoIP/$command"));
      if (response.statusCode == 200) {
        if (command == "reset") {
          setState(() => paperCount = 0);
        }
      } else {}
      // ignore: empty_catches
    } catch (e) {}
  }

  // Get paper count from Arduino
  void getPaperCount() async {
    var response = await http.get(Uri.parse("$arduinoIP/count"));
    setState(() {
      paperCount = int.tryParse(response.body) ?? 0;
    });
  }

  @override
  void initState() {
    super.initState();
    getPaperCount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Paper Counter")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Paper Count: $paperCount",
              style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 20),

          // Input fields for X and Y
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: xController,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: "Enter X movement (cm)"),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: yController,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: "Enter Y movement (cm)"),
            ),
          ),
          const SizedBox(height: 20),

          // Button to move the stamp
          ElevatedButton(
            onPressed: () {
              String xValue = xController.text;
              String yValue = yController.text;
              if (xValue.isNotEmpty && yValue.isNotEmpty) {
                sendCommand("move_stamp?x=$xValue&y=$yValue");
              }
            },
            child: const Text("Move Stamp"),
          ),

          const SizedBox(height: 20),

          // Control buttons for start, stop, and reset
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: () => sendCommand("start"),
                  child: const Text("Start")),
              const SizedBox(width: 10),
              ElevatedButton(
                  onPressed: () => sendCommand("stop"),
                  child: const Text("Stop")),
              const SizedBox(width: 10),
              ElevatedButton(
                  onPressed: () => sendCommand("reset"),
                  child: const Text("Reset")),
            ],
          ),
        ],
      ),
    );
  }
}
