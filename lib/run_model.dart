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
        ).then((value) => simplifyResult(value?.asMap()));
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    Tflite.close();
  }

  void simplifyResult(Map<int, dynamic>? res) {
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
    debugPrint('Got: ' + resMap.toString());
    checkResult(resMap);
  }

  void checkResult(Map resultMap) {
    List<Map<String, dynamic>> resultDataset = [
      {'name': '0_ELAADEN_CACHE_FLOW', 'E': 2, 'F': 2, 'O': 1, 'Y': 1},
      {'name': '1_ELAADEN_DATA_CORES', 'D': 2, 'W': 4, 'X': 2},
      {
        'name': '2_ELAADEN_REMNANT_DERELICT',
        'AA': 2,
        'C': 3,
        'F': 2,
        'O': 1,
        'OO': 2
      },
      {
        'name': '3_ELAADEN_TAMING_A_DESERT',
        'D': 2,
        'E': 2,
        'O': 2,
        'OO': 2,
        'X': 2
      },
      {'name': '4_ELAADEN_VAULT', 'AA': 2, 'D': 1, 'U': 1, 'YY': 1},
      {'name': '5_EOS_A_BETTER_BEGINNING', 'AA': 3, 'E': 2, 'W': 1, 'X': 3},
      {'name': '6_EOS_FREE_ROAM_01', '8': 1, 'F': 2, 'R': 2, 'U': 1},
      {'name': '7_EOS_FREE_ROAM_02', 'A': 2, 'AA': 2, 'D': 2, 'X': 3},
      {'name': '8_EOS_VAULT_2F', 'A': 2, 'J': 1, 'W': 3, 'X': 2},
      {'name': '9_H047C', '8': 1, 'C': 1, 'J': 1, 'W': 1},
      {'name': '10_HAVARL_FREE_ROAM_01', 'AA': 1, 'C': 2, 'X': 2, 'YY': 1},
      {'name': '11_HAVARL_HELPING_SCIENTISTS', 'A': 2, 'D': 1, 'OO': 1, 'Y': 2},
      {'name': '12_HAVARL_VAULT', '8': 1, 'C': 1, 'J': 1, 'W': 1},
      {'name': '13_KADARA_HEALING', 'C': 1, 'OO': 1, 'Y': 4, 'YY': 1},
      {'name': '14_KADARA_VAULT', 'E': 1, 'F': 1, 'O': 1, 'Y': 1},
      {'name': '15_KHI_TASIRA', 'AA': 1, 'D': 2, 'U': 1, 'Y': 1},
      {'name': '16_VOELD_PEEBEE_SECRET_PROJECT', 'A': 1, 'AA': 3, 'E': 3},
      {
        'name': '17_VOELD_RESTORING_A_WORLD_01',
        'C': 3,
        'OO': 2,
        'Y': 2,
        'YY': 2
      },
      {
        'name': '18_VOELD_RESTORING_A_WORLD_02',
        'A': 1,
        'AA': 1,
        'F': 2,
        'W': 3,
        'Y': 2
      },
      {
        'name': '19_VOELD_RESTORING_A_WORLD_03',
        'AA': 3,
        'C': 2,
        'OO': 1,
        'U': 2,
        'X': 3
      },
      {'name': '20_VOELD_SUBJUGATION', 'AA': 2, 'E': 2, 'R': 1, 'W': 2},
      {'name': '21_VOELD_VAULT', 'E': 1, 'F': 1, 'O': 2}
    ];

    int lowestPoints = 100;
    Map mostSimilarSet = {};

    for (var set in resultDataset) {
      int points = 0;
      for (var key in resultMap.keys) {
        int resultMapValue = resultMap[key] as int;

        if (set.containsKey(key)) {
          int setValue = (set[key]);
          points = points + (resultMapValue - setValue).abs();
        } else {
          points = points + resultMapValue;
        }
      }
      for (var key in set.keys) {
        if (key != 'name') {
          if (resultMap.containsKey(key) == false) {
            int setValue = set[key];
            points = points + setValue;
          }
        }
      }
      if (lowestPoints > points) {
        lowestPoints = points;
        mostSimilarSet = set;
      }
    }
    debugPrint('Most similar: ' + mostSimilarSet.toString());
    debugPrint("Score: " + lowestPoints.toString()); //lower is better
  }

  loadModel() async {
    await Tflite.loadModel(
      model: "assets/yolov2_28_12_2021_22_40.tflite",
      labels: "assets/yolov2-tiny.txt",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Image.file(widget.file);
  }
}
