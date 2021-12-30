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

  @override
  Widget build(BuildContext context) {
    String filePath = "assets/result/0_ELAADEN_CACHE_FLOW.jpg";
    Future<File> loadFile() async {
      final byteData = await rootBundle.load(filePath);
      List pieces = filePath.split('/');
      File _file =
          File('${(await getTemporaryDirectory()).path}/' + pieces.last);
      return await _file.writeAsBytes(byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    }

    return FutureBuilder(
        future: loadFile(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return snapshot.hasData
              ? RunModel(file: snapshot.data)
              : const Text("Fail to Load");
        });
  }
}
