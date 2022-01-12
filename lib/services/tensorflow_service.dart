import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:tflite/tflite.dart';
import 'package:path/path.dart' as path;
import 'package:download_assets/download_assets.dart';
enum ModelType { RedtoGreen,RedtoRedLeft, YOLO, SSDMobileNet, MobileNet, PoseNet }
enum Modelboolean { RedtoGreen,RedtoRedLeft }

class TensorFlowService {
  ModelType _type = ModelType.SSDMobileNet;
  bool _isboolean=false;

  DownloadAssetsController? dc;
  ModelType get type => _type;

  set type(type) {
    _type = type;
  }
set ttype(type) {
    dc = type;
  }

Future<File> moveFile(File sourceFile, String newPath) async {
    try {
      /// prefer using rename as it is probably faster
      /// if same directory path
      return await sourceFile.rename(newPath);
    } catch (e) {
      print("renderr... error ${e}");
      print("renderr... ${sourceFile}");
      /// if rename fails, copy the source file 
      final newFile = await sourceFile.copy(newPath);
      return newFile;
    }
  }
  bool get redtogreen => _isboolean;

  set redtogreen(type) {
    print("handleswitch setting red to green to "+type.toString());
    _isboolean = type;
  }
loadModell(DownloadAssetsController a) async{
  print("renderr... loadModell");
dc=a;
loadModel(_type);
}

  loadModel(ModelType type) async {
    print(type.toString()+"rrrenderr...loadModel result is...${dc?.assetsDir}");



// bool? filedownloaded = await dc?.assetsFileExists("ble.jpeg");
// print("renderr... 11ddownload asset come"+filedownloaded.toString());

// bool? filedownloaded2 = await dc?.assetsFileExists("quantized.tflite");
// print("renderr... 222ddownload asset comeeeeee"+filedownloaded2.toString());
// try {
//   final file = await File('assets/models/ble.jpeg').create(recursive: true);
// // var file =  await moveFile(File("/data/user/0/com.onofflab.traffic/app_flutter/assets/ble.jpeg"),"flutter_assets/assets/models/ble.jpeg");
// } catch (e) {
//   print("renderr...${e}");
// }
    try {
      Tflite.close();
      String? res;
      switch (type) {
        case ModelType.YOLO:
          break;
        case ModelType.SSDMobileNet:
          print("renderr... come!!!!");
          try {
             res = await Tflite.loadModel(
              model: 'assets/models/quantized.tflite',
              labels: 'assets/models/newmobnet.txt'); 
          } catch ( e) {
            print("renderr... error:"+e.toString());
          }
        
          print("renderr... load done final"+res.toString());
          break;
        case ModelType.MobileNet:
          break;
        case ModelType.PoseNet:
          break;
        default:
      }
      print('renderr... loadModel: $res - $_type');
    } on PlatformException {
      print('renderr... Failed to load model.');
    }
  }

  close() async {
     print('renderr... close.');
    await Tflite.close();
  }

  Future<List<dynamic>?> runModelOnFrame(CameraImage image) async {
    List<dynamic>? recognitions = <dynamic>[];
    switch (_type) {
      case ModelType.YOLO:
        recognitions = await Tflite.detectObjectOnFrame(
          bytesList: image.planes.map((plane) {
            return plane.bytes;
          }).toList(),
          model: "YOLO",
          imageHeight: image.height,
          imageWidth: image.width,
          imageMean: 0,
          imageStd: 255.0,
          threshold: 0.2,
          numResultsPerClass: 1,
        );
        break;
      case ModelType.SSDMobileNet:
        print("render...  a SSDMOBILENET");
        recognitions = await Tflite.detectObjectOnFrame(
          bytesList: image.planes.map((plane) {
            return plane.bytes;
          }).toList(),
          model: "SSDMobileNet",
          imageHeight: image.height,
          imageWidth: image.width,
          imageMean: 127.5,
          imageStd: 127.5,
          threshold: 0.4,
          numResultsPerClass: 1,
        );
        break;
      case ModelType.MobileNet:
        print("mobile net come!");
        recognitions = await Tflite.runModelOnFrame(
          bytesList: image.planes.map((plane) {
            return plane.bytes;
          }).toList(),
          imageHeight: image.height,
          imageWidth: image.width,
          numResults: 5
        );
        break;
      case ModelType.PoseNet:
        recognitions = await Tflite.runPoseNetOnFrame(
            bytesList: image.planes.map((plane) {
              return plane.bytes;
            }).toList(),
            imageHeight: image.height,
            imageWidth: image.width,
            numResults: 5
        );
        break;
      default:
    }
    return recognitions;
  }

  Future<List<dynamic>?> runModelOnImage(File image) async {
    var recognitions = await Tflite.detectObjectOnImage(
        path: image.path,
        model: "SSDMobileNet",
        threshold: 0.3,
        imageMean: 0.0,
        imageStd: 127.5,
        numResultsPerClass: 1);
    return recognitions;
  }
}
