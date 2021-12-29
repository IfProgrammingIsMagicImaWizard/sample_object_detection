import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';

class RunModel extends StatefulWidget {
  final File file;
  const RunModel({Key? key, required this.file}) : super(key: key);

  @override
  _RunModelState createState() => _RunModelState();
}

class _RunModelState extends State<RunModel> {
//  @override
  // void initState() {
  // super.initState();
  //  loadModel().then((value) {
  //  setState(() {
  //   Tflite.detectObjectOnImage(
  //    path: widget.file.path,
  //   model: "SSDMobileNet",
  //   ).then((value) => checkResult(value?.asMap()));
  //  });
  //  });
  // }

  @override
  void initState() {
    super.initState();
    loadModel().then((value) {
      setState(() {
        Tflite.detectObjectOnImage(
          path: widget.file.path,
          model: "YOLO",
          threshold: 0.0,
          imageMean: 0.0,
          imageStd: 255.0,
          numResultsPerClass: 20,
        ).then((value) => checkResult(value?.asMap()));
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    Tflite.close();
  }

  void checkResult(Map<int, dynamic>? res) {
    debugPrint(res.toString());
    Map resMap = {};

    res ??= {
      0: {'confidenceInClass': 0.78515625, 'detectedClass': 'couch'}
    };

    res.forEach((i, value) {
      if (value['confidenceInClass'] >= 0.85) {
        String key = value['detectedClass'];
        if (resMap.containsKey(key)) {
          resMap[key] = resMap[key] + 1;
        } else {
          resMap[key] = 1;
        }
      }
    });
    debugPrint(resMap.toString());
  }

  loadModel() async {
    await Tflite.loadModel(
      model: "assets/yolov2_28_12_2021_22_40.tflite",
      labels: "assets/label.txt",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Image.file(widget.file);
  }
}
