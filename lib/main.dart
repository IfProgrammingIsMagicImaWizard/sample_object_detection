import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

import './run_model.dart';

void main() {
  runApp(
    const MaterialApp(
      home: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  Future<File> loadFile() async {
    final byteData = await rootBundle.load('assets/2.png');

    File _file = File('${(await getTemporaryDirectory()).path}/2.png');
    return await _file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: loadFile(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return snapshot.hasData
              ? RunModel(file: snapshot.data)
              : const Text("Fail to Load");
        });
  }
}
