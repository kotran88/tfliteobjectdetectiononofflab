import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as UI;
import 'dart:io';
import 'package:screen/screen.dart';
import 'dart:collection';
import 'dart:math';
import 'dart:async';
import 'package:wakelock/wakelock.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:restart_app/restart_app.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:share/share.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:exif/exif.dart';
import 'package:intl/intl.dart'; 
import 'package:trafficawareness/speed/providers/speedometer_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:trafficawareness/app/app_resources.dart';
import 'package:trafficawareness/app/app_router.dart';
import 'package:trafficawareness/app/base/base_stateful.dart';
import 'package:trafficawareness/main.dart';
import 'package:trafficawareness/services/navigation_service.dart';
import 'package:trafficawareness/services/tensorflow_service.dart';
import 'package:trafficawareness/speed/Body.dart';
import 'package:trafficawareness/view_models/home_view_model.dart';
import 'package:trafficawareness/widgets/aperture/aperture_widget.dart';
import 'package:trafficawareness/widgets/confidence_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:download_assets/download_assets.dart';


enum SingingCharacter { screenon, screenoff }
enum SingingCharacterSleep { sleepon, sleepoff }

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends BaseStateful<HomeScreen, HomeViewModel>
    with WidgetsBindingObserver {
      SingingCharacter? _character;
      SingingCharacterSleep? _character_sleep;

bool sleepflag=false;
 String videoDirectory="";
  ListQueue<double> speedarray = ListQueue<double>();
  DownloadAssetsController downloadAssetsController = DownloadAssetsController();
  String message = "Press the download button to start the download";
  bool downloaded = false;
  late CameraController _cameraController;
  late CameraController _cameraController2;
  late Future<void> _initializeControllerFuture;
  late Future<void> _initializeControllerFuture2;
  int refreshcount=0;
  late StreamController<Map> apertureController;
  double fv=0;
  double sv=0;
  double tv=0;
  double ffv=0;
  int countposible=0;
  double fffv=0;
  double ssv=0;
  double sssv=0;
  double ev=0;
  double nv=0;
  double ttv=0;
  int cameraType=0;

bool videorecordflag=false;
  late ScreenshotController screenshotController;

  late TensorFlowService _tensorFlowService;
  late Uint8List _imageFile;
String? token;
String? token_sleep;
  TextEditingController searchController = TextEditingController();
  bool captureflag=false;
  @override
  bool get wantKeepAlive => true;
 
  @override
  void afterFirstBuild(BuildContext context) {
    super.afterFirstBuild(context);
    WidgetsBinding.instance?.addObserver(this);
  }
   Future changeddetect(flag) async {
     print("wake ${flag}");
     final prefs = await SharedPreferences.getInstance();
     if(flag=="on"){

     Wakelock.enable();
    prefs.setString('screen', "on");
     }else{

     Wakelock.disable();
    prefs.setString('screen', "off");
     }
   }
      Future changeddetect2(flag) async {
     print("sleeppp ${flag}");
     final prefs = await SharedPreferences.getInstance();
     if(flag=="on"){
        token_sleep="on";
    prefs.setString('sleep', "on");
     }else{

        token_sleep="off";
    prefs.setString('sleep', "off");
     }
   }
 Future _init() async {
 Directory appDirectory = await getApplicationDocumentsDirectory();
      videoDirectory = '${appDirectory.path}/flutter_Videos';
    await Directory(videoDirectory).create(recursive: true);
   try{
print("!!!!init!!!!${viewModel.state.cameraIndex}");
//  _cameraController2 = CameraController(
//         cameras[2], ResolutionPreset.high);

//        _cameraController2.initialize().then((_) {

// print("!!!!init22222!!!!");
//     }); 
   } catch(e){
     print("!!!init${e}");
   }

    await downloadAssetsController.init();
    final prefs = await SharedPreferences.getInstance();
     token = prefs.getString('screen');
     token_sleep = prefs.getString('sleep');
    print("wakeup${token}");
    print("sleep token${token_sleep}");
    if(token==null){
      token="on";
    }
    if(token=="on"){

 _character = SingingCharacter.screenon;
     Wakelock.enable();
     }else{

 _character = SingingCharacter.screenoff;
     Wakelock.disable();
     }

     if(token_sleep==null){
      token_sleep="on";
    }
    if(token_sleep=="on"){

 _character_sleep = SingingCharacterSleep.sleepon;
     }else{

 _character_sleep = SingingCharacterSleep.sleepoff;
     }

  
    downloaded = await downloadAssetsController.assetsDirAlreadyExists();
        print("render..."+downloaded.toString());
    
bool filedownloaded = await downloadAssetsController.assetsFileExists("ble.jpeg");
print(downloadAssetsController.assetsDir.toString()+"render... ddownload asset come"+filedownloaded.toString());

bool filedownloaded2 = await downloadAssetsController.assetsFileExists("quantized.tflite");
print("render... ddownload asset comeeeeee"+filedownloaded2.toString());
try {
  
File f=File("${downloadAssetsController.assetsDir}/jkj.jpeg");
print("render... f"+f.toString());
} catch (e) {
  print("render... er file : "+e.toString());
}

  }
  @override
  void initState() {
    super.initState();
    _init();

    loadModel(viewModel.state.type);
 
    initCamera();
// _pickVideo=ImagePicker.pickVideo(source: ImageSource.camera);
    apertureController = StreamController<Map>.broadcast();
    screenshotController = ScreenshotController();



    Timer.periodic(new Duration(seconds: 60*60*3), (timer) {


            Fluttertoast.showToast(
                        msg: "두시간에 한번씩 리스타트 합니다. ",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
 Restart.restartApp();
    });
    Timer.periodic(new Duration(seconds: 25), (timer) {
   debugPrint(timer.tick.toString());
   print(speedarray.toString()+"render tttriggered for 11111min");
   speedarray.add(SpeedometerProvider.speedCar);
   if(sleepflag&&SpeedometerProvider.speedCar>10){


                    initCamera();
        Screen.setBrightness(5);
                    sleepflag=false;
                    
        }
   if(speedarray.length>10){
     speedarray.removeFirst();
      speedarray.forEach((element) {
 countposible++;

  if (countposible == 1) {
            fv = element;
          }
          if (countposible == 2) {
            sv = element;
          }
          if (countposible == 3) {
            tv = element;
          }
          if (countposible == 4) {
            ffv = element;
          }
          if (countposible == 5) {
            fffv = element;
          }


          if (countposible == 6) {
            ssv = element;
          }
          if (countposible == 7) {
            sssv = element;
          }
          if (countposible == 8) {
            ev = element;
          }
          if (countposible == 9) {
            nv = element;
          }
          if (countposible == 10) {
            ttv = element;

            String mv=( (fv+sv+tv+ffv+fffv+ssv+sssv+ev+nv+ttv) /10 ).toString();

      if( (fv+sv+tv+ffv+fffv+ssv+sssv+ev+nv+ttv) /10 <1){
        //go to sleep mode
        if(token_sleep=="on"){
          if(!sleepflag){
Fluttertoast.showToast(
            msg: "휴대전화의 배터리 보호를 위해 슬립모드로 전환합니다. !"+mv,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        sleepflag=true;
        Screen.setBrightness(0);

// initCamera();
       _cameraController.dispose();
          }
       
        }else{

        }

      }else{
        
        

      }

 //judge finish so initialized....
          }
      });
      countposible=0;
      speedarray.clear();

   }
  refreshcount=refreshcount+1;

        // handleSwitchCameraClick();

          return;


});
  }
 void initCameraNormal()  {
   print("renderrr"+cameras[viewModel.state.cameraIndex].toString());
    _cameraController = CameraController(
        cameras[cameraType], ResolutionPreset.low);
    _initializeControllerFuture = _cameraController.initialize().then((_) {

      print("renderedandsaveim initialized done");
      if (!mounted) {
        return;
      }
      _cameraController.setFlashMode(FlashMode.off);

      /// TODO: Run Model
      setState(() {});
//       if(!captureflag){
// _cameraController.startImageStream((image) async {
//         if (!mounted) {
//           return;
//         }
//         await viewModel.runModel(image);
//       });
//       }
      
    });
  }

//   void initCameraRemote()  {
//    print("renderrr"+cameras[2].toString());
//     _cameraController = CameraController(
//         cameras[cameraType], ResolutionPreset.high);
//     _initializeControllerFuture = _cameraController.initialize().then((_) {

//       print("renderedandsaveim initialized done");
//       if (!mounted) {
//         return;
//       }
//       _cameraController.setFlashMode(FlashMode.off);

//       /// TODO: Run Model
//       setState(() {});
// //       if(!captureflag){
// _cameraController.startImageStream((image) async {
//         if (!mounted) {
//           return;
//         }
//         await viewModel.runModel(image);
//       });
//       }
      
//     });
//   }

  void recordstarting() {
    print("recordstarting renderrrrrrr init cameracome1");
  Fluttertoast.showToast(
          msg: "1분동안 녹화 되며, 갤러리에저장됩니다.!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
 _cameraController = CameraController(
        cameras[cameraType], ResolutionPreset.low);

  
    if(_cameraController!=null){

    print("renderrrrrrr init cameracome is not null"+_cameraController.toString());
    }else{

    print("renderrrrrrr init cameracome is  null");
    }


   try {
     print("renderrrrrrr init initialize come"+mounted.toString());

           _initializeControllerFuture = _cameraController.initialize().then((_) {

      print("renderrrrrrr init  initialized done");
      _cameraController.setFlashMode(FlashMode.off);

      /// TODO: Run Model
      setState(() {});
//       if(!captureflag){
  // _cameraController.

      print("renderrrrrrr startVideoRecording");
_cameraController.startImageStream((image) async {
        if (!mounted) {
          return;
        }
        await viewModel.runModel(image);
      });

      
      
    
      final String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
    
      final String filePath = '$videoDirectory/${currentTime}.mp4';
    
_cameraController.startVideoRecording();
//       }
      
    }); 
   } catch (e) {
     print("render init error is :"+e.toString());
   }


      videorecordflag=true;
      
    }
  void initCamera() {
    print("render init cameracome1");

 _cameraController = CameraController(
        cameras[cameraType], ResolutionPreset.low);

  
//  _cameraController2= CameraController(
//         cameras[cameraType], ResolutionPreset.high);

    if(_cameraController!=null){

    print("render init cameracome is not null"+_cameraController.toString());
    }else{

    print("render init cameracome is  null");
    }


    // if(_cameraController2!=null){

    // print("render init cameracome2222 is not null"+_cameraController2.toString());
    // }else{

    // print("render init cameracome2222 is  null");
    // }
   try {
     print("render init initialize come"+mounted.toString());




           _initializeControllerFuture = _cameraController.initialize().then((_) {

      print("render init  initialized done");
      if (!mounted) {
        return;
      }
      _cameraController.setFlashMode(FlashMode.off);

      /// TODO: Run Model
      setState(() {});
//       if(!captureflag){
  // _cameraController.startVideoRecording();

      print("render init  startVideoRecording done");
_cameraController.startImageStream((image) async {
        if (!mounted) {
          return;
        }
        await viewModel.runModel(image);
      });
//       }
      
    }); 
   } catch (e) {
     print("render init error is :"+e.toString());
   }


      
    }

  void loadModel(ModelType type) async {
    await viewModel.loadModel(type);
  }
   void loadModelagain(ModelType type) async {
    await viewModel.loadModelagain(type);
  }
  void loadModell(DownloadAssetsController dc) async {
    print("render...loadmodel done");
    await viewModel.loadModela(dc);
  }
  Future<void> runModel(CameraImage image) async {
    if (mounted) {
      print("render... runmodel started");
      await viewModel.runModel(image);
    }
  }
  
  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance?.removeObserver(this);
    viewModel.close();
    apertureController.close();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
 print("render didchange"+state.toString());
    /// TODO: Check Camera
    if (!_cameraController.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      print("render didchange inactive!");
      _cameraController.dispose();
    } else {
      print("render didchange initCamera come");
      initCamera();
    }
  }

  @override
  Widget buildPageWidget(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: false,
        appBar: buildAppBarWidget(context),
        body: buildBodyWidget(context),
        drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Version 0.1'),
            ),
            ListTile(
              title: const Text('화면 켜짐 지속 여부'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                // Navigator.pop(context);
              },
            ),
              RadioListTile<SingingCharacter>(
          title: const Text('화면 계속 켜짐 유지'),
          value: SingingCharacter.screenon,
          groupValue: _character,
          onChanged: (SingingCharacter? value) {
            setState(() {
              changeddetect("on");
              
              print("ccccchange ${value}");
              // prefs.setString('screen', "on");
              _character = value;
            });
          },
        ),
         RadioListTile<SingingCharacter>(
          title: const Text('화면 켜짐 유지 안함'),
          value: SingingCharacter.screenoff,
          groupValue: _character,
          onChanged: (SingingCharacter? value) {
            setState(() {

              changeddetect("off");
              // prefs.setString('screen', "off");
              print("ccccchange ${value}");
              Wakelock.disable();
              _character = value;
            });
          },
        ),






 ListTile(
              title: const Text('슬립 전환 여부'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                // Navigator.pop(context);
              },
            ),
              RadioListTile<SingingCharacterSleep>(
          title: const Text('슬립 전환 켜기'),
          value: SingingCharacterSleep.sleepon,
          groupValue: _character_sleep,
          onChanged: (SingingCharacterSleep? value) {
            setState(() {
              changeddetect2("on");
              
              print("ccccchange ${value}");
              // prefs.setString('screen', "on");
              _character_sleep = value;
            });
          },
        ),
         RadioListTile<SingingCharacterSleep>(
          title: const Text('슬립 전환 끄기'),
          value: SingingCharacterSleep.sleepoff,
          groupValue: _character_sleep,
          onChanged: (SingingCharacterSleep? value) {
            setState(() {

              changeddetect2("off");
              // prefs.setString('screen', "off");
              print("ccccchange ${value}");
              _character_sleep = value;
            });
          },
        ),
          ],
        ),
      ),
        floatingActionButton: buildFloatingActionButton(context),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat);
  }

  Widget buildFloatingActionButton(BuildContext context) {
    return Container(

 margin:EdgeInsets.fromLTRB(10,0,0,10),
      padding: EdgeInsets.symmetric(vertical: 2, horizontal: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          FloatingActionButton(
            heroTag: null,
            onPressed: handleCaptureClick,
            tooltip: "Capture",
            backgroundColor: AppColors.white,
           
            child: Icon(
              Icons.send,
              color: AppColors.blue,
            ),
          ),


           if(videorecordflag==(false) )...[
                 FloatingActionButton(
            heroTag: null,
            onPressed: videorecordingflag,
            tooltip: "Switch Camera",
            backgroundColor: AppColors.white,
            child: Icon(
              Icons.videocam,
              color: AppColors.blue,
            ),
          ),
            ]else if( videorecordflag==(true)   )...[

 FloatingActionButton(
            heroTag: null,
            onPressed: videorecordingflag,
            tooltip: "Switch Camera",
            backgroundColor: AppColors.white,
            child: Icon(
              Icons.stop,
              color: AppColors.black,
            ),
          ),

            ]

         



        ],
      ),
    );
  }
//refresh camera and model ! 
  Future<bool> handleSwitchCameraClick() async {
    // apertureController.sink.add({});
    // // viewModel.switchCamera();

      print("render 111handleSwitchCameraClick initCamera come");
    // viewModel.startLocation();
    // initCamera();
    //  WidgetsBinding.instance?.removeObserver(this);
    // viewModel.close();
    // apertureController.close();

// _cameraController.dispose();
try {
  // loadModelagain(viewModel.state.type);

      print("render 222handleSwitchCameraClick initCamera come");
    // initCamera();

} catch (e) {
  print("render error ${e}");
}
 

      // initCamera();

      print("render 333handleSwitchCameraClick initCamera come");

// _pickVideo=ImagePicker.pickVideo(source: ImageSource.camera);
    // apertureController = StreamController<Map>.broadcast();
    //   print("render 444handleSwitchCameraClick initCamera come");

    // screenshotController = ScreenshotController();
    //   print("render 555handleSwitchCameraClick initCamera come");

//  _cameraController.dispose();
//       initCamera();
// XFile videoFile = await _cameraController.stopVideoRecording();
//       print("renderrr path is "+videoFile.path.toString());

//       await GallerySaver.saveVideo(videoFile.path);
// File(videoFile.path).deleteSync();

    if(!videorecordflag){
//         print("rrrenderrr start ");
// final Directory appDirectory = await getApplicationDocumentsDirectory();
//       final String videoDirectory = '${appDirectory.path}/Videos';
//       await Directory(videoDirectory).create(recursive: true);
//       final String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
//       final String filePath = '$videoDirectory/${currentTime}.mp4';
  
//         print("rrrenderrr start"+currentTime+"renderrrrr"+filePath.toString());
//       try {
      
//         await _cameraController2.startVideoRecording();
//         print("renerrrr startvideo recording...");
//         // videoPath = filePath;
//       } on CameraException catch (e) {
//         print("renderrrrr"+e.toString());
//         // _showCameraException(e);
    
//       }
cameraType=2;
      initCamera();
      videorecordflag=true;
    }else{
      cameraType=0;
      initCamera();
//       print("rrrenderrr stop ");
videorecordflag=false;
// XFile videoFile = await _cameraController2.stopVideoRecording();
//       print("renderrr path is "+videoFile.path.toString());

//       await GallerySaver.saveVideo(videoFile.path);
// File(videoFile.path).deleteSync();
    }
 
  

    // _pickVideo=ImagePicker.pickVideo(source: ImageSource.camera,maxDuration: Duration(seconds:10));

    return true;
  }





  Future<bool> videorecordingflag() async {
   
//            Fluttertoast.showToast(
//           msg: "녹화 끝 !",
//           toastLength: Toast.LENGTH_SHORT,
//           gravity: ToastGravity.CENTER,
//           timeInSecForIosWeb: 1,
//           backgroundColor: Colors.red,
//           textColor: Colors.white,
//           fontSize: 16.0
//       );

//       print("render init  stopVideoRecording starterd");
//       XFile videoFile = await _cameraController.stopVideoRecording();
//             print("render init  stopVideoRecording done");
//       print("renderrr path is "+videoFile.path.toString());

//       await GallerySaver.saveVideo(videoFile.path);
// File(videoFile.path).deleteSync();

    if(!videorecordflag){
//         print("rrrenderrr start ");
// final Directory appDirectory = await getApplicationDocumentsDirectory();
//       final String videoDirectory = '${appDirectory.path}/Videos';
//       await Directory(videoDirectory).create(recursive: true);
//       final String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
//       final String filePath = '$videoDirectory/${currentTime}.mp4';
  
//         print("rrrenderrr start"+currentTime+"renderrrrr"+filePath.toString());
//       try {
      
//         await _cameraController2.startVideoRecording();
//         print("renerrrr startvideo recording...");
//         // videoPath = filePath;
//       } on CameraException catch (e) {
//         print("renderrrrr"+e.toString());
//         // _showCameraException(e);
    
//       }


recordstarting();
final Directory appDirectory = await getApplicationDocumentsDirectory();
      final String videoDirectory = '${appDirectory.path}/myvideos';
      await Directory(videoDirectory).create(recursive: true);
      final String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
      final String filePath = '$videoDirectory/${currentTime}.mp4';
      print("renderrrr init ${filePath}");



      //  var externalDirectoryPath = await ExtStorage.getExternalStorageDirectory();
// final directory = await getApplicationDocumentsDirectory();
//     // String imagesDirectory = directory + "/images/pets/";
//     print("directory"+directory.toString());
//     print("externalDirectoryPath directory"+externalDirectoryPath.toString());
//     // print(imagesDirectory);
//     var status = await Permission.storage.status;
//                   if (!status.isGranted) {
//                     await Permission.storage.request();
//                   }
// var externalDirectoryPath = await ExtStorage.getExternalStorageDirectory();

// //      var externalDirectoryPath = await ExtStorage.getExternalStorageDirectory();
// final directory = (await getApplicationDocumentsDirectory ()).path; //from path_provide package

//     print("directory is handleCaptureClick 145522 ");
// String fileName = "abc.png";
// try {
//   new Directory(externalDirectoryPath +'/DCIM/abc')
//     .create()
//     .then((Directory directory) 
//     {
//       print("directory is done! : ");
//     });
// } catch (e) {

//   print("directory is ${e}");
// }
    

//  final Directory _appDocDir = await getApplicationDocumentsDirectory();
// final Directory _appDocDirFolder = Directory("/storage/emulated/0/DCIM/CCd2/");
// print("directory is to create ${_appDocDirFolder}");
// if(await _appDocDirFolder.exists()){ 
//   print("directory is exsixt");
//  }else{
//    final Directory _appDocDirNewFolder=await _appDocDirFolder.create(recursive: true); 
//    print("directory is  created!");
//  }
// var externalDir;
// externalDir = await getApplicationDocumentsDirectory();
// print("${externalDirectoryPath} directory is extdir : "+externalDir.toString());
//     new Directory('/storage/emulated/0/DCIM/newflutter')
//     .create()
//     .then((Directory directory) 
//     {
//       print("directory is.........."+directory.toString());
//       // _fetchFiles(directory);
//       print("directory is!!!!!"+directory.path);
//     });;
print("directory is ....finished!");
//녹화 시작후 60분 단위후 자동 종료 
 Timer.periodic(new Duration(seconds: 10), (timer) {
finishrec();
    Timer(Duration(seconds: 5), () {
        
recordstarting();

      });


 });
    //  Fluttertoast.showToast(
    //       msg: "녹화 시작!",
    //       toastLength: Toast.LENGTH_SHORT,
    //       gravity: ToastGravity.CENTER,
    //       timeInSecForIosWeb: 1,
    //       backgroundColor: Colors.red,
    //       textColor: Colors.white,
    //       fontSize: 16.0
    //   );
// _cameraController.startVideoRecording();

      print("renderrrrrrr startvvvvrrrrrr...");
// _cameraController.startImageStream((image) async {
//         if (!mounted) {
//           return;
//         }
//         await viewModel.runModel(image);
//       });

    }else{
           finishrec();
// XFile videoFile = await _cameraController2.stopVideoRecording();
//       print("renderrr path is "+videoFile.path.toString());

//       await GallerySaver.saveVideo(videoFile.path);
// File(videoFile.path).deleteSync();
    }
 
  


    return true;
  }
  Future finishrec() async{
    Fluttertoast.showToast(
          msg: "녹화 끝 저장완료!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
      XFile videoFile = await _cameraController.stopVideoRecording();

      File videoFile2 = File(videoFile.path);

// changeFileNameOnly(videoFile2,"hihihi");
//       print("renderrrrrrr path is "+videoFile.path.toString());
//       await GallerySaver.saveVideo(videoFile.path);
// File(videoFile.path).deleteSync();

var status = await Permission.storage.status;
                  if (!status.isGranted) {
                    await Permission.storage.request();
                  }


     var externalDirectoryPath = await ExtStorage.getExternalStorageDirectory();
final directory = (await getApplicationDocumentsDirectory ()).path; //from path_provide package

    print("directory is handleCaptureClick 145522 ");
String fileName = "abc23232.png";
 new Directory(externalDirectoryPath +'/DCIM/CCd3')
    .create()
    .then((Directory directory) 
    {

           
        // final cameraImage =  _cameraController.takePicture();
      print("directory isisisisis.........."+directory.toString());
      // _fetchFiles(directory);
    //   screenshotController.captureAndSave(
    // '/storage/emulated/0/DCIM/CCd3', //set path where screenshot will be saved
    // fileName:fileName 
      print("directory is!!!!!"+directory.path);
    });
    print("directory is ${videoFile.path}");
   
if(await videoFile2.exists()){ 
  print("directory is exists");
 }else{
   await videoFile2.create(recursive: true); 
   print("directory is  ccccreated!");

 

 }
    try {
      var now = new DateTime.now(); //반드시 다른 함수에서 해야함, Mypage같은 클래스에서는 사용 불가능
      String formatDate = DateFormat('yy/MM/dd/HH:mm:ss').format(now);
   await videoFile2.copy(externalDirectoryPath +'/DCIM/CCd3/testinggg.mp4');
    } catch (e) {

    print("directory is...!comeee"+e.toString());
    }
    print("directory is...!come");
//  moveFile(videoFile2,externalDirectoryPath +'/DCIM/CCd3/test.mp4');
// int currentUnix = DateTime.now().millisecondsSinceEpoch;

//             final directory = await getApplicationDocumentsDirectory();
//             String fileFormat = videoFile2.path.split('.').last;


// Directory appDirectory = await getApplicationDocumentsDirectory();
//       videoDirectory = '${appDirectory.path}/flutter_Videos';
//     await Directory(videoDirectory).create(recursive: true);

_cameraController.stopImageStream();
initCamera();

//       print("rrrenderrr stop ");
videorecordflag=false;

  }

  Future<File> moveFile(File sourceFile, String newPath) async {
    try {
      /// prefer using rename as it is probably faster
      /// if same directory path
      return await sourceFile.rename(newPath);
    } catch (e) {
      /// if rename fails, copy the source file 
      final newFile = await sourceFile.copy(newPath);
      return newFile;
    }
  }

Future<File> changeFileNameOnly(File file, String newFileName) {
  var path = file.path;
  var lastSeparator = path.lastIndexOf(Platform.pathSeparator);
  var newPath = path.substring(0, lastSeparator + 1) + newFileName;
  return file.rename(newPath);
}
  handleSwitchSource(ModelType item) {
    print("handleswitch source");
    print("handleswitch"+item.toString());
    print("handleswitchㅗㅗㅗㅗㅗ"+viewModel.state.isRedtoGreen().toString());
    viewModel.dispose();
    print("handleswitch result "+viewModel.updateRedtoGreen(true).toString() );
    // Provider.of<NavigationService>(context, listen: false).pushReplacementNamed(
    //     AppRoute.homeScreen,
    //     args: {'isWithoutAnimation': true});
  }

double? gpsValuesToFloat(IfdValues? values) {
  if (values == null || values is! IfdRatios) {
    return null;
  }

  double sum = 0.0;
  double unit = 1.0;

  for (final v in values.ratios) {
    sum += v.toDouble() * unit;
    unit /= 60.0;
  }

  return sum;
}
Future<void> getUserOrder() {
  // Imagine that this function is fetching user info from another service or database
  return Future.delayed( Duration(seconds: 1), () => 
  {
    screenshotController.capture().then((value) async {
        print("handleCaptureClick 1455666 ");
      if (value != null) {
        print("renderedandsaveimage111 1455777 "+captureflag.toString());
      try {
          final cameraImage = await _cameraController.takePicture();
          print("renderedandsaveimagee 222222332111 ");
          await renderedAndSaveImage(value, cameraImage);
      } catch (e) {
        print("renderedandsaveimageee"+e.toString());
      }
        print("renderedandsaveimage33eeee 14557778888 ");
      }
    })

  });
  
  
  


}
  Future<bool> handleCaptureClick() async  {
//     await _cameraController.dispose();
// if(SpeedometerProvider.speedCar < 1){

initCameraNormal();
  getUserOrder();
// }else{
//    handleSwitchCameraClick();
// }

    print("renderedandsaveimag handleCaptureClick 1 ");

    print("handleCaptureClick 12 ");
captureflag=true;
//  final fileBytes = File('/storage/emulated/0/DCIM/Camera/20211218_234840.jpg').readAsBytesSync();
//   final data =  await readExifFromBytes(fileBytes);
//   print("renderedandsaveimag gogo");
//    if (data.isEmpty) {
//     print("No EXIF information found");
//   }
// /var/mobile/Containers/Data/Application/D2752D62-AA06-4D4D-8166-E1F5A8045DA7/Documents/camera/pictures/CAP_BB18FB69-6C3A-4202-8DE8-CC577B905C52.jpg
///var/mobile/Containers/Data/Application/4AA0F63E-8B8E-49A1-9294-1366F0280D45/Documents
  // for (final entry in data.entries) {
  //   print("renderedandsaveimag ${entry.key}: ${entry.value}");
  // }

  //  final latRef = data['GPS GPSLatitudeRef']?.toString();
  //   var latVal = gpsValuesToFloat(data['GPS GPSLatitude']?.values);
  //   final lngRef = data['GPS GPSLongitudeRef']?.toString();
  //   var lngVal = gpsValuesToFloat(data['GPS GPSLongitude']?.values);

  //   if (latRef == null || latVal == null || lngRef == null || lngVal == null) {
  //     print("renderedandsaveimag GPS information not found");
  //   }

  //   if (latRef == 'S') {
  //   }

  //   if (lngRef == 'W') {
  //   }

  //   print("renderedandsaveimag lat = $latVal");
  //   print("renderedandsaveimag lng = $lngVal");
// print(data);
//   if (data.isEmpty) {
//     print("No EXIF information found");
//     return;
//   }

//   for (final entry in data.entries) {
//     print("${entry.key}: ${entry.value}");
//   }


    print("handleCaptureClick 13 ");
    // try {
    //   // Ensure that the camera is initialized.
    //   // Attempt to take a picture and then get the location
    //   // where the image file is saved.
    //   final image = await _cameraController.takePicture();

    // print("handleCaptureClick done!!!!! ");
    // print("handleCaptureClick image.path"+image.path.toString());
    // } catch (e) {
    //   print("error...");
    //   // If an error occurs, log the error to the console.
    //   print(e);
    // }
    //  var externalDirectoryPath = await ExtStorage.getExternalStorageDirectory();
// final directory = await getApplicationDocumentsDirectory();
//     // String imagesDirectory = directory + "/images/pets/";
//     print("directory"+directory.toString());
//     print("externalDirectoryPath directory"+externalDirectoryPath.toString());
//     // print(imagesDirectory);
//     var status = await Permission.storage.status;
//                   if (!status.isGranted) {
//                     await Permission.storage.request();
//                   }
var externalDir;
externalDir = await getApplicationDocumentsDirectory();
print("directory is extdir : "+externalDir.toString());
//     // print(externalDirectoryPath);
//     new Directory(externalDirectoryPath +'/DCIM/Camera')
//     .create()
//     .then((Directory directory) 
//     {
//       print("directory is.........."+directory.toString());
//       _fetchFiles(directory);
//       print("directory is!!!!!"+directory.path);
//     });;
    

//     var image = await ImagePicker.pickImage(source: ImageSource.camera);
// var bytes = await image.readAsBytes();
// var tags = await readExifFromBytes(bytes);
// try {
// }catch(e){
//    print("noexif");
// }finally{
//   tags.forEach((key, value) {
//   print({"$key":"$value"});
// });

//      try {
//             // Ensure that the camera is initialized.
//             await _initializeControllerFuture;

//     print("handleCaptureClick 14 ");
//             // Attempt to take a picture and get the file `image`
//             // where it was saved.
//             final image = await _cameraController.takePicture();

// print(image.path);
//     print("handleCaptureClick 15 ");
//             // If the picture was taken, display it on a new screen.
//             // await Navigator.of(context).push(
//             //   MaterialPageRoute(
//             //     builder: (context) => DisplayPictureScreen(
//             //       // Pass the automatically generated path to
//             //       // the DisplayPictureScreen widget.
//             //       print("image path is"+image.path);
//             //       imagePath: image.path,
//             //     ),
//             //   ),
//             // );
//           } catch (e) {
//             // If an error occurs, log the error to the console.
//             print(e);
//           }

    //     try {
    //   XFile file = await _cameraController.takePicture();
    //   return file;
    // } on CameraException catch (e) {
    //       print(e.toString()+"handleCaptureClick 144 ");
    //   return null;
    // }
    print("handleCaptureClick 1455 ");


//      var externalDirectoryPath = await ExtStorage.getExternalStorageDirectory();
// final directory = (await getApplicationDocumentsDirectory ()).path; //from path_provide package

//     print("handleCaptureClick 145522 ");
// String fileName = "abc.png";
//  new Directory(externalDirectoryPath +'/DCIM/CCd')
//     .create()
//     .then((Directory directory) 
//     {

//         final cameraImage =  _cameraController.takePicture();
//       print("directory isisisisis.........."+directory.toString());
//       // _fetchFiles(directory);
//       screenshotController.captureAndSave(
//     '/storage/emulated/0/DCIM/CCd', //set path where screenshot will be saved
//     fileName:fileName 
// );
//       print("directory is!!!!!"+directory.path);
//     });;

    // await screenshotController.capture(delay: const Duration(milliseconds: 10)).then((Uint8List? image) async {
    //   if (image != null) {
    //     final directory = await getApplicationDocumentsDirectory();
    //     final imagePath = await File('${directory.path}/image.png').create();
    //   print("handleCaptureClick"+imagePath.toString());
    //     await imagePath.writeAsBytes(image);
    //     /// Share Plugin
    //     await Share.shareFiles([imagePath.path]);
    //   }
    // });

    return true;
        // await renderedAndSaveImage(value, cameraImage);
  }

// Future takePicture(String path) async {
// //FIXME hacky technique to avoid having black screen on some android devices
// await _cameraController.takePicture(path);
// }
  _fetchFiles(Directory dir) async {
    print("directory :fetch file come");
    File file=new File('/storage/emulated/0/DCIM/Camera/20211218_234840.jpg');
    print("directoryyy : 2222");
      print("directoryyy done");
//       // final exif =
//       //       dd.FlutterExif.fromBytes( file.readAsBytesSync());
      print("directoryyy : 3333333333");

     




  // if (data.isEmpty) {
  //   print("No EXIF information found");
  //   return;
  // }

  // for (final entry in data.entries) {
  //   print("${entry.key}: ${entry.value}");
  // }

    // try {
      
    // Map<String, IfdTag> imgTags =  readExifFromBytes( file.readAsBytesSync() );
    // print("directoryyy: 44444555444");
    // print(imgTags);
    // if (imgTags.containsKey('GPS GPSLongitude')) {
    //   setState(() {
    //     _imgHasLocation = true;
    //     _imgLocation = exifGPSToGeoFirePoint(imgTags);
    //   });
    // }
    // } catch (e) {
    //   print("directoryyy error "+e.toString());
    // }

       
    // List<dynamic> listImage = List<dynamic>();
//     dir.list().forEach((element) {
//       print("directoryyy11 "+element.toString());
//       String splited=element.toString().split(" '")[1].split("'")[0];
//       //'/storage/emulated/0/DCIM/Camera/20161125_192033.jpg'
//          print("directoryyy22"+splited);
//       File file=new File(splited);
//       print("directoryyy33 done");

 
//       print("directoryyy44 : 33334444");
// // for (final entry in data) {
// //       print("${entry.key}: ${entry.value}");
// //     }
// // Map<String, String> mTags = HashMap();
//   });
  }

  // detectObject(File image) async {
  //     var recognitions =
  //           await this._tensorFlowService.runModelOnImage(image);
  //   // var recognitions = await Tflite.detectObjectOnImage(
  //   //   path: image.path,       // required
  //   //   model: "SSDMobileNet",
  //   //   imageMean: 127.5,     
  //   //   imageStd: 127.5,      
  //   //   threshold: 0.4,       // defaults to 0.1
  //   //   numResultsPerClass: 10,// defaults to 5
  //   //   asynch: true          // defaults to true
  //   // );
  //   // FileImage(image)
  //   //     .resolve(ImageConfiguration())
  //   //     .addListener((ImageStreamListener((ImageInfo info, bool _) {
  //   //       setState(() {
  //   //         _imageWidth = info.image.width.toDouble();
  //   //         _imageHeight = info.image.height.toDouble();
  //   //       });
  //   //     }))); 
  //   // setState(() {
  //   //   _recognitions = recognitions;
  //   // });
  // }

  Future _downloadAssets() async {
    bool assetsDownloaded = await downloadAssetsController.assetsDirAlreadyExists();
    // if (assetsDownloaded) {
    //   setState(() {
    //     message = "Click in refresh button to force download";
    //     print(message);
    //   });
    //   return;
    // }
print("renderr...downloadassets");
    try {

    final String nodeEndPoint = 'https://firebasestorage.googleapis.com/v0/b/labour-1ee26.appspot.com/o/assetfolder%2Fassets.zip';
      var response = await http.get(Uri.parse(nodeEndPoint));
    var statusCode = response.statusCode; 
  var responseHeaders = response.headers;
  var responseBody = response.body.split(",")[0];
  var responsLength = response.body.length;
  var responseBody2 = response.body.toString().split("downloadTokens\": \"")[1].split("\"")[0];

  var responseBody3 = response.body.toString();

  print("renderr... asssssstatusCode: ${statusCode}");
  print("renderr...  responseHeaders: ${responseHeaders}");
  print("renderr...  rrrrresponseBody: ${responseBody}");
  print("renderr...  rrrrresponseBody2: ${responsLength}");
  print("renderr...  rrrrresponseBody3: ${responseBody2}");
  
    // sModel(viewModel.state.type);
      await downloadAssetsController.startDownload(
        assetsUrl: "https://firebasestorage.googleapis.com/v0/b/labour-1ee26.appspot.com/o/assetfolder%2Fassets.zip?alt=media&token=${responseBody2}",
        onProgress: (progressValue) {
          downloaded = false;
          setState(() {
            if (progressValue < 100) {
              message = "Downloading - ${progressValue.toStringAsFixed(2)}";

            } else {
              message = "Download completed\nClick in refresh button to force download";
              print(message);
              downloaded = true;

        print("renderr...222"+message);

loadModell(downloadAssetsController);

            }
          });
        },
      );
    } on DownloadAssetsException catch (e) {
      print(e.toString());
      print("renderr... downloadEx"+e.toString());
      setState(() {
        downloaded = false;
        message = "Error: ${e.toString()}";
        print("renderr...333"+message);
      });
    }
  }

  Future<bool> renderedAndSaveImage(Uint8List draw, XFile camera) async {
   CircularProgressIndicator();
    UI.Image cameraImage =
        await decodeImageFromList(await camera.readAsBytes());
    print("renderedandsaveimage 1 ");
    UI.Codec codec = await UI.instantiateImageCodec(draw);
    var detectionImage = (await codec.getNextFrame()).image;

    var cameraRatio = cameraImage.height / cameraImage.width;
    var previewRatio = detectionImage.height / detectionImage.width;
 print("renderedandsaveimage 12 ");
    double scaleWidth, scaleHeight;
    if (cameraRatio > previewRatio) {
      scaleWidth = cameraImage.width.toDouble();
      scaleHeight = cameraImage.width * previewRatio;
    } else {
      scaleWidth = cameraImage.height.toDouble() / previewRatio;
      scaleHeight = cameraImage.height.toDouble();
    }
    var difW = (scaleWidth - cameraImage.width) / 2;
    var difH = (scaleHeight - cameraImage.height) / 2;
 print("renderedandsaveimage 13 ");
    final recorder = UI.PictureRecorder();
    final canvas = new Canvas(
        recorder,
        Rect.fromPoints(
            new Offset(0.0, 0.0),
            new Offset(
                cameraImage.width.toDouble(), cameraImage.height.toDouble())));
 print("renderedandsaveimage 14 ");
    canvas.drawImage(cameraImage, Offset.zero, Paint());
 print("renderedandsaveimage 151551515151515 ");
    // codec = await UI.instantiateImageCodec(draw,
    //     targetWidth: scaleWidth.toInt(), targetHeight: scaleHeight.toInt());
    // detectionImage = (await codec.getNextFrame()).image;

//     canvas.drawImage(detectionImage, Offset(difW.abs(), difH.abs()), Paint());
//  print("renderedandsaveimage 16 ");
//     canvas.save();
//     canvas.restore();
//  print("renderedandsaveimage 17 ");
    final picture = recorder.endRecording();
    var img = await picture.toImage(scaleWidth.toInt(), scaleHeight.toInt());


    final pngBytes = await img.toByteData(format: UI.ImageByteFormat.png);
    final imgBase64 = base64.encode(pngBytes!.buffer.asUint8List());
    print("renderedandsaveimage rrrrrrrrrrrresult is "+imgBase64.toString());
    final result2 = await ImageGallerySaver.saveImage(
        Uint8List.view(pngBytes!.buffer),
        quality: 100,
        name: 'realtime_object_detection_${DateTime.now()}');
    print(result2);
    captureflag=false;

    final String nodeEndPoint = 'http://202.31.237.173/ionic';
    //  http.post(Uri.parse(nodeEndPoint), body: {
    //  "image": imgBase64,
    //  "name": "thisisfilename",
    //     }).then((res) {
    //       print("renderedandsaveimage"+res.statusCode.toString());
    //     }).catchError((err) {
    //       print("renderedandsaveimage"+err.toString());
    //     });
    DateTime now = new DateTime.now();
    print("renderedandsaveimage"+now.toString());
    print("renderedandsaveimage ssssssending image to server");
   String newnow=now.toString().replaceAll(":", "");
   newnow=newnow.toString().replaceAll(".", "");
   newnow=newnow.toString().replaceAll(" ", "");
   print("renderedandsaveimage rrrrrrrrrrreplaced : "+newnow.toString());
   try {
     print("rendersave try come");

// await _cameraController.dispose();
initCamera();
      http.Response response = await http.post(
      Uri.parse(nodeEndPoint),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      }, // this header is essential to send json data
      body: jsonEncode([
        {'image': '$imgBase64',"name":newnow.toString()}
      ]),
    );

    print("renderedandsaveimage result "+response.statusCode.toString());
    if(response.statusCode.toString()=="200"){

      Fluttertoast.showToast(
          msg: "서버로 이미지가 전송되었습니다. 감사합니다.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }else{

    Fluttertoast.showToast(
        msg: "전송오류 발생 ! "+response.statusCode.toString()+"내장메모리/Pictures 에 저장되었습니다.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
    );
    }
   } catch (e) {
     print("render"+e.toString());
      Fluttertoast.showToast(
        msg: "전송오류 발생 ! "+e.toString()+"내장메모리/Pictures 에 저장되었습니다.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
    );
   }
   print("render dispose come");
  
    
 
    return true;
  }

  _gotoRepo() async {
    if (await canLaunch(AppStrings.urlRepo)) {
      await launch(AppStrings.urlRepo);
    } else {}
  }

  @override
  AppBar buildAppBarWidget(BuildContext context) {
    return AppBar(
      elevation: 0.0,
      centerTitle: true,
      actions: [
        // IconButton(
        //     onPressed: () {
        //       _gotoRepo();
        //     },
        //     icon: Icon(AppIcons.linkOption, semanticLabel: 'Repo')),
        // PopupMenuButton<ModelType>(
        //     onSelected: (item) => handleSwitchSource(item),
        //     color: AppColors.white,
        //     itemBuilder: (context) => [
        //           PopupMenuItem(
        //               child: Row(
        //                 children: <Widget>[
        //                   Icon(Icons.api,
        //                       color: viewModel.state.isRedtoGreen()
        //                           ? AppColors.black
        //                           : AppColors.grey),
        //                   Text(' Red - > g ',
        //                       style: AppTextStyles.regularTextStyle(
        //                           color: viewModel.state.isRedtoGreen()
        //                               ? AppColors.black
        //                               : AppColors.grey)),
        //                 ],
        //               ),
        //               value: ModelType.RedtoGreen),
        //                PopupMenuItem(
        //               child: Row(
        //                 children: <Widget>[
        //                   Icon(Icons.api,
        //                       color: viewModel.state.isRedToRedLeft()
        //                           ? AppColors.black
        //                           : AppColors.grey),
        //                   Text('Red - > RedLeft',
        //                       style: AppTextStyles.regularTextStyle(
        //                           color: viewModel.state.isRedToRedLeft()
        //                               ? AppColors.black
        //                               : AppColors.grey)),
        //                 ],
        //               ),
        //               value: ModelType.RedtoRedLeft)
        //         ]),
      ],
      backgroundColor: AppColors.blue,
      /*
      title: Text(
        AppStrings.title,
        style: AppTextStyles.boldTextStyle(
            color: AppColors.white, fontSize: AppFontSizes.large),
      ),
      */
      title: Body(), // 여기 수정.
    );
  }

  @override
  Widget buildBodyWidget(BuildContext context) {
    double heightAppBar = AppBar().preferredSize.height;

    bool isInitialized = _cameraController.value.isInitialized;

    final Size screen = MediaQuery.of(context).size;
    final double screenHeight = max(screen.height, screen.width);
    final double screenWidth = min(screen.height, screen.width);


//

    final Size previewSize =
        isInitialized ? _cameraController.value.previewSize! : Size(100, 100);
    final double previewHeight = max(previewSize.height, previewSize.width);
    final double previewWidth = min(previewSize.height, previewSize.width);
viewModel.setScreenSize(screenWidth,screenHeight);
    final double screenRatio = screenHeight / screenWidth;
    final double previewRatio = previewHeight / previewWidth;
    final maxHeight =
        screenRatio > previewRatio ? screenHeight : screenWidth * previewRatio;
    final maxWidth =
        screenRatio > previewRatio ? screenHeight / previewRatio : screenWidth;
    
return GestureDetector(
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        color: Colors.grey.shade900,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Screenshot(
              controller: screenshotController,
              child: Stack(
                children: <Widget>[
                  OverflowBox(
                    maxHeight: maxHeight,
                    maxWidth: maxWidth,
                    child: FutureBuilder<void>(
                        future: _initializeControllerFuture,
                        builder: (_, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return CameraPreview(_cameraController);
                          } else {
                            return const Center(
                                child: CircularProgressIndicator(
                                    color: AppColors.blue));
                          }
                        }),
                  ),

         Consumer<HomeViewModel>(builder: (_, homeViewModel, __) {
                    return ConfidenceWidget(
                      heightAppBar: heightAppBar,
                      entities: homeViewModel.state.recognitions,
                      previewHeight: max(homeViewModel.state.heightImage,
                          homeViewModel.state.widthImage),
                      previewWidth: min(homeViewModel.state.heightImage,
                          homeViewModel.state.widthImage),
                      screenWidth: MediaQuery.of(context).size.width,
                      screenHeight: MediaQuery.of(context).size.height,
                      type: homeViewModel.state.type,
                    );
                  }),
                    OverflowBox(
                    maxHeight: maxHeight,
                    maxWidth: maxWidth,
                    child: ApertureWidget(
                      apertureController: apertureController,
                    ),
                  ),
                 
                
                  // Container(
                  //   decoration: BoxDecoration(
                  //     border: Border.all(color: Colors.red, width: 2)
                  //   ),
                  // )
                  getSearchBox(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
                  
    
  }

  Widget getSearchBox() {
    return Consumer<HomeViewModel>(
      builder: (BuildContext context, value, Widget? child) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.25,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                color: Colors.white,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: <Widget>[
                          // ClipRRect(
                          //   borderRadius: BorderRadius.circular(8),
                          //   child: Container(
                          //     child: SizedBox(
                          //       width: MediaQuery.of(context).size.width * 0.7,
                          //       child: TextFormField(
                          //         controller: searchController,
                          //         decoration: InputDecoration(
                          //           hintText: "Search",
                          //           labelText: "Search",
                          //           labelStyle: TextStyle(
                          //             fontSize: 13,
                          //             color: Colors.black,
                          //           ),
                          //           floatingLabelBehavior:
                          //               FloatingLabelBehavior.always,
                          //           border: UnderlineInputBorder(),
                          //         ),
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          // ClipRRect(
                          //   borderRadius: BorderRadius.circular(8),
                          //   child: Container(
                          //     color: Colors.grey[300],
                          //     padding: EdgeInsets.symmetric(
                          //       vertical:
                          //           MediaQuery.of(context).size.width * 0.01,
                          //     ),
                          //     child: SizedBox(
                          //       width: MediaQuery.of(context).size.width * 0.2,
                          //       child: TextButton(
                          //         onPressed: submit,
                          //         child: Text(
                          //           "submit",
                          //         ),
                          //       ),
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                    // update 2021.12.08.수요일 김형태 코드추가
                    // HomeViewModel클래스의 _recognitionsColor을 가져와서 뿌려줍니다.
                    Container(
                      color: Colors.red,
                      child: Text(
                        value.getRecognitionsColor.toString() == ""
                            ? ""
                            : value.getRecognitionsColor.toString(),
                      ),
                    ),

//                    if(value.currentColor==("redleft") )...[
//                          Container(
//                            padding:EdgeInsets.all(10),
//                         child: Image.asset("assets/redleft.png",width: 150, height: 50)
//                          )
//                       ]else if(value.currentColor==("red") )...[
//                          Container(
//                            padding:EdgeInsets.all(10),
//                         child: Image.asset("assets/red.png",width: 150, height: 50)
//                          )
//                       ]else if(value.currentColor=="green" ) ...[
//  Container(
//                            padding:EdgeInsets.all(10),
//                         child: Image.asset("assets/green.png",width: 150, height: 50)
//                          )
//                       ]else ...[
//                          Container(
//                          )
//                       ],
                      Container(
                      color: Colors.blue,
                      child: Text(
                        value.cc.toString() == ""
                            ? ""
                            : value.cc.toString(),
                      ),
                      ),
                      Container(
                      color: Colors.red ,
                      child: Text(
                        refreshcount.toString()
                      ),
                      ),
                      Container(
                      color: Colors.blue ,
                      child: Text(
                        value.getboxSize.toString()
                      ),
                      ),
                      Container(
                      color: Colors.blue ,
                      child: Text(
                        value.getboxSize2.toString()
                      ),
                      ),
                      
                      Container(
                      color: Colors.black ,
                      //not detected
                      child: Text(

                        value.detectedCar.toString()
                      ),
                      ),
                      // if (downloaded)
                      //   Container(
                      //   color: Colors.black ,
                      //   //not detected
                      //   child: Text(

                      //     "download done"
                      //   ),
                      //   Container(
                      //     width: 150,
                      //     height: 150,
                      //     decoration: BoxDecoration(
                      //       image: DecorationImage(
                      //         image: FileImage(File("${downloadAssetsController.assetsDir}/ble.jpeg")),
                      //         fit: BoxFit.fitWidth,
                      //       ),
                      //     ),
                      //   )
                      // if(value.detectedCar==("not detected") )...[
                      //    Container(
                      //    )
                      // ]else ...[
                      //    Container(
                      //      margin:EdgeInsets.all(5),
                      //   child: Image.asset("assets/car.png",width: 50, height: 50)
                      //    )
                      // ],





                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void submit() {
    String message = searchController.text;
    if (message == "" || message.length == 0) {
      return;
    }
    searchController.clear();

    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
