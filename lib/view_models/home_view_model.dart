import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_realtime_object_detection/app/base/base_view_model.dart';
import 'package:flutter_realtime_object_detection/speed/providers/speedometer_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '/models/recognition.dart';
import 'package:flutter_realtime_object_detection/services/tensorflow_service.dart';
import 'package:flutter_realtime_object_detection/view_states/home_view_state.dart';
import 'dart:collection';
import 'package:audioplayers/audio_cache.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomeViewModel extends BaseViewModel<HomeViewState> {
  bool _isLoadModel = false;
  bool _isDetecting = false;
  bool detectedflag=false;
  int countingcardetected=0;
  String first = "";
  double firstcardetectedvalue=0.0;
  String second = "";
  String third = "";
  double threshold=0.5;
  String fourth = "";
  bool cardetected=false;
  String fifth = "";
  double firstp = 0;
  double secondp = 0;
  double thirdp = 0;
  double fourthp = 0;
  double fifthp = 0;
  double _sized=0.0;
  String _cardetected="not detected";
   double firstcar=0;
          double secondcar=0;
          double thirdcar=0;
          double fourthcar=0;
          double fifthcar=0.0;
          double sixthcar=0;
          double seventhcar=0;
          double eighthcar=0;
          double ninethcar=0;
          double tenthcar=0;
          
  AudioCache player = new AudioCache();
  ListQueue<String> variable_name = ListQueue<String>();
  ListQueue<double> variable_nameposible = ListQueue<double>();
  ListQueue<double> cararray = ListQueue<double>();
  late TensorFlowService _tensorFlowService;
  String _recognitionsColor = ""; // 색깔
  String currentTraffic="";
  String _currentColor="";
  String _cColor = ""; // 색깔
  String get getRecognitionsColor => _recognitionsColor;
  String get currentColor => _cColor;

  double get getboxSize => _sized;
  String get cc => _currentColor;
  String get detectedCar=>_cardetected;
  void setRecognitionsColor(String recognitionsColor) {
    _recognitionsColor = recognitionsColor;
    this.notifyListeners();
  }
  
void setBoxSized(double boxsize){
  _sized=boxsize;
  this.notifyListeners();
}
void setCurrentColor(String cColor) {
    _cColor = cColor;
    this.notifyListeners();
  }
void setCarDetectedflag(String fifth){
    _cardetected = fifth;
    this.notifyListeners();
}
void setCC(String cColor) {
    _currentColor = cColor;
    this.notifyListeners();
  }
  HomeViewModel(BuildContext context, this._tensorFlowService)
      : super(context, HomeViewState(_tensorFlowService.type));

  Future startLocation() async {
    print("gggg");
  }

  Future switchCamera() async {
    state.cameraIndex = state.cameraIndex == 0 ? 1 : 0;
    this.notifyListeners();
  }

// Future<void> getPosition() async {
//     var currentPosition = await Geolocator()
//         .getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
//     // var lastPosition = await Geolocator()
//     //     .getLastKnownPosition(desiredAccuracy: LocationAccuracy.low);
//     print(currentPosition);
//     // print(lastPosition);
//   }
  Future<void> loadModel(ModelType type) async {
    state.type = type;
    //if (type != this._tensorFlowService.type) {
    await this._tensorFlowService.loadModel(type);

    //}
    this._isLoadModel = true;
  }

  void addInRemoveFirst(e, int size) {
    for (var i = 0; i < size; i++) {
      e.add(i);
    }
    while (e.isNotEmpty) {
      e.removeFirst();
    }
  }

  Future<void> runModel(CameraImage cameraImage) async {
    if (_isLoadModel && mounted) {
      if (!this._isDetecting && mounted) {
        this._isDetecting = true;
        int startTime = new DateTime.now().millisecondsSinceEpoch;

        print("================================================");
        print(SpeedometerProvider.speedCar.toString());
        print("================================================");
        // 2021.12.06.월요일........... 김형태 아래코드 3줄 추가 했습니다.
        // update 2021.12.08.수요일 ...... 김형태 주석 처리 했습니다...
        // final providerData = Provider.of<SpeedometerProvider>(context);

        if (SpeedometerProvider.speedCar > 5) {
          countingcardetected=0;
          // Fluttertoast.showToast(
          //   msg: "속도가 5를 넘었습니다.",
          //   toastLength: Toast.LENGTH_SHORT,
          //   gravity: ToastGravity.BOTTOM,
          //   timeInSecForIosWeb: 1,
          //   backgroundColor: Colors.red,
          //   textColor: Colors.white,
          //   fontSize: 16.0,
          // );
          // print("속도가 5를 넘었습니다.");
          // return;

          print("showresult clear come!");
          variable_name.clear();
          variable_nameposible.clear();
           cararray.clear();
          first = "";
          second = "";
          third = "";
          fourth = "";
          fifth = "";
          firstp = 0;
          secondp = 0;
          thirdp = 0;
          fourthp = 0;
          fifthp = 0;
          cardetected=false;
          _cardetected="not detectedww";
          firstcardetectedvalue=0.0;

 setCarDetectedflag(_cardetected);
           setRecognitionsColor("");
          setCurrentColor("" );
          setBoxSized(0.0);
           setCC( "");

          
          
        }
        // ================
       


                 var recognitions =
            await this._tensorFlowService.runModelOnFrame(cameraImage);
        int endTime = new DateTime.now().millisecondsSinceEpoch;
        // try{
        if (recognitions?.length == 1) {
          print("showresultadding-1-1-1-1-1-" +
              recognitions?[0]["detectedClass"]);
          if (recognitions?[0]["confidenceInClass"]>threshold&&  ( (recognitions?[0]["detectedClass"] == "car") || (recognitions?[0]["detectedClass"] == "truck") ||(recognitions?[0]["detectedClass"] == "motor") || (recognitions?[0]["detectedClass"] == "bus") ) ){
double num1 = double.parse( (recognitions?[0]["rect"]["w"]*recognitions?[0]["rect"]["h"]).toStringAsFixed(4));
           setBoxSized(num1*100);
            cararray.add(num1*100);
          }
          //  setBoxSized(recognitions?[0]["rect"].w);
          
          if (recognitions?[0]["confidenceInClass"]>threshold&& (recognitions?[0]["detectedClass"] == "red" ||
              recognitions?[0]["detectedClass"] == "green" ||
              recognitions?[0]["detectedClass"] == "redleft" ||
              recognitions?[0]["detectedClass"] == "greenleft") ) {
            variable_name.add(recognitions?[0]["detectedClass"]);
            variable_nameposible.add(recognitions?[0]["confidenceInClass"]);
            // recognitionsColor = recognitions?[0]["detectedClass"]; // update 2021.12.08.수요일 김형태 코드추가
            // setRecognitionsColor(recognitions?[0]
            //     ["detectedClass"]); // update 2021.12.08.수요일 김형태 코드추가
          }
        } else if (recognitions?.length == 2) {
          if (recognitions?[0]["confidenceInClass"]>threshold&& ( (recognitions?[0]["detectedClass"] == "car") || (recognitions?[0]["detectedClass"] == "truck")  ||(recognitions?[0]["detectedClass"] == "motor") || (recognitions?[0]["detectedClass"] == "bus") ) ){
double num1 = double.parse((recognitions?[0]["rect"]["w"]*recognitions?[0]["rect"]["h"]).toStringAsFixed(4));
          setBoxSized(num1*100);
           cararray.add(num1*100);
          }
          if (recognitions?[1]["confidenceInClass"]>threshold&& ( (recognitions?[1]["detectedClass"] == "car") || (recognitions?[1]["detectedClass"] == "truck")  ||(recognitions?[1]["detectedClass"] == "motor") || (recognitions?[1]["detectedClass"] == "bus") ) ){
double num1 = double.parse((recognitions?[1]["rect"]["w"]*recognitions?[1]["rect"]["h"]).toStringAsFixed(4));
           setBoxSized(num1*100);
            cararray.add(num1*100);
          }
          if (recognitions?[1]["confidenceInClass"]>threshold&& (recognitions?[1]["detectedClass"] == "red" ||
              recognitions?[1]["detectedClass"] == "green" ||
              recognitions?[1]["detectedClass"] == "redleft" ||
              recognitions?[1]["detectedClass"] == "greenleft") ) {
            print("showresultadding1111" + recognitions?[1]["detectedClass"]);
            variable_name.add(recognitions?[1]["detectedClass"]);
            variable_nameposible.add(recognitions?[1]["confidenceInClass"]);
            // recognitionsColor = recognitions?[1]["detectedClass"]; // update 2021.12.08.수요일 김형태 코드추가
            // setRecognitionsColor(recognitions?[1]
            //     ["detectedClass"]); // update 2021.12.08.수요일 김형태 코드추가
          }
          if (recognitions?[0]["confidenceInClass"]>threshold&& (recognitions?[0]["detectedClass"] == "red" ||
              recognitions?[0]["detectedClass"] == "green" ||
              recognitions?[0]["detectedClass"] == "redleft" ||
              recognitions?[0]["detectedClass"] == "greenleft") ) {
            print("showresultadding0000" + recognitions?[0]["detectedClass"]);
            variable_name.add(recognitions?[0]["detectedClass"]);
            variable_nameposible.add(recognitions?[0]["confidenceInClass"]);
            // recognitionsColor = recognitions?[0]["detectedClass"];// update 2021.12.08.수요일 김형태 코드추가
            // setRecognitionsColor(recognitions?[0]
            //     ["detectedClass"]); // update 2021.12.08.수요일 김형태 코드추가
          }
          // print(recognitions?[1]["detectedClass"] );
          // print(recognitions?[1]["confidenceInClass"]);
          // print("two detected...");
          // print(recognitions?[0]["detectedClass"] );
          // print(recognitions?[0]["confidenceInClass"]);
        } else if(recognitions?.length == 3) {

 if (recognitions?[0]["confidenceInClass"]>threshold&& ( (recognitions?[0]["detectedClass"] == "car") || (recognitions?[0]["detectedClass"] == "truck")  ||(recognitions?[0]["detectedClass"] == "motor") || (recognitions?[0]["detectedClass"] == "bus") ) ){
double num1 = double.parse((recognitions?[0]["rect"]["w"]*recognitions?[0]["rect"]["h"]).toStringAsFixed(4) );
           setBoxSized(num1*100);
            cararray.add(num1*100);
          }
          if (recognitions?[1]["confidenceInClass"]>threshold&& ( (recognitions?[1]["detectedClass"] == "car") || (recognitions?[1]["detectedClass"] == "truck")  ||(recognitions?[1]["detectedClass"] == "motor") || (recognitions?[1]["detectedClass"] == "bus")) ){
double num1 = double.parse((recognitions?[1]["rect"]["w"]*recognitions?[1]["rect"]["h"]).toStringAsFixed(4) );
           setBoxSized(num1*100);
            cararray.add(num1*100);
          }  
          if (recognitions?[2]["confidenceInClass"]>threshold&& ( (recognitions?[2]["detectedClass"] == "car") || (recognitions?[2]["detectedClass"] == "truck")  ||(recognitions?[2]["detectedClass"] == "motor") || (recognitions?[2]["detectedClass"] == "bus") ) ){
double num1 = double.parse((recognitions?[2]["rect"]["w"]*recognitions?[2]["rect"]["h"]).toStringAsFixed(4) );
 cararray.add(num1*100);
         setBoxSized(num1*100);
          }
          

          if (recognitions?[1]["confidenceInClass"]>threshold&& (recognitions?[1]["detectedClass"] == "red" ||
              recognitions?[1]["detectedClass"] == "green" ||
              recognitions?[1]["detectedClass"] == "redleft" ||
              recognitions?[1]["detectedClass"] == "greenleft") ) {
            print("showresultadding1111" + recognitions?[1]["detectedClass"]);
            variable_name.add(recognitions?[1]["detectedClass"]);
            variable_nameposible.add(recognitions?[1]["confidenceInClass"]);
            // recognitionsColor = recognitions?[1]["detectedClass"]; // update 2021.12.08.수요일 김형태 코드추가
            // setRecognitionsColor(recognitions?[1]
            //     ["detectedClass"]); // update 2021.12.08.수요일 김형태 코드추가
          }
          if (recognitions?[0]["confidenceInClass"]>threshold&&(recognitions?[0]["detectedClass"] == "red" ||
              recognitions?[0]["detectedClass"] == "green" ||
              recognitions?[0]["detectedClass"] == "redleft" ||
              recognitions?[0]["detectedClass"] == "greenleft") ) {
            print("showresultadding0000" + recognitions?[0]["detectedClass"]);
            variable_name.add(recognitions?[0]["detectedClass"]);
            variable_nameposible.add(recognitions?[0]["confidenceInClass"]);
          }
          if (recognitions?[2]["confidenceInClass"]>threshold&& (recognitions?[2]["detectedClass"] == "red" ||
              recognitions?[2]["detectedClass"] == "green" ||
              recognitions?[2]["detectedClass"] == "redleft" ||
              recognitions?[2]["detectedClass"] == "greenleft")  ){
            print("showresultadding0000" + recognitions?[2]["detectedClass"]);
            variable_name.add(recognitions?[2]["detectedClass"]);
            variable_nameposible.add(recognitions?[2]["confidenceInClass"]);
          }
        }else{
          // variable_name.clear();
          // variable_nameposible.clear();
        }
        print(variable_name.length);
        int count = 0;
        int countcar = 0;
        int countposible = 0;

        print("showresult variable_name" + variable_name.toString());
        variable_nameposible.forEach((element) {
          
          countposible++;
          if (countposible == 1) {
            firstp = element;
          }
          if (countposible == 2) {
            secondp = element;
          }
          if (countposible == 3) {
            thirdp = element;
          }
          if (countposible == 4) {
            fourthp = element;
          }
          if (countposible == 5) {
            fifthp = element;
          }
        });
        variable_name.forEach((element) {
          if(element=="greenleft"){
            element="green";
          }
          count++;
          if (count == 1) {
            first = element;
          }
          if (count == 2) {
            second = element;
          }
          if (count == 3) {
            third = element;
          }
          if (count == 4) {
            fourth = element;
          }
          if (count == 5) {
            fifth = element;
          }
        });
print("cararray is"+cararray.toString());

        if(SpeedometerProvider.speedCar < 1){
           cararray.forEach((element) {
         
          countcar++;
          print("cararray is count come"+countcar.toString());
          if (countcar == 1) {
            firstcar = element;
          }
          if (countcar == 2) {
            secondcar = element;
          }
          if (countcar == 3) {
            thirdcar = element;
          }
          if (countcar == 4) {
            fourthcar = element;
          }
          if (countcar == 5) {
            fifthcar = element;
          }
          if (countcar == 6) {
            sixthcar = element;
          }
          if (countcar == 7) {
            seventhcar = element;
          }
          if (countcar == 8) {
            eighthcar = element;
          }
          if (countcar == 9) {
            ninethcar = element;
          }
          if (countcar == 10) {
            tenthcar = element;
          }
        });
        if(cararray.length!=0){
// print("cararray is ring count is : "+countcar.toString()+"first: "+firstcar.toString()+"second :"+secondcar.toString()+"fourth :"+fourthcar.toString()+"fifth :"+fifthcar.toString());
       
        }
        if(fifthcar!=0.0){
          if(!cardetected){
//처음 차가 디텍트 된다.
print("cararray is ring carrrrr detected!!!!");
 firstcardetectedvalue=fifthcar;
 setCarDetectedflag(fifthcar.toString());
          cardetected=true;
          }
         //차가 디텍트 된 시점의 크기를 표시 
        }
        if(fifthcar <firstcardetectedvalue*0.85&&firstcardetectedvalue!=0.0){
if(cardetected){
  countingcardetected++;
  if(countingcardetected==1){
print(countingcardetected.toString()+"cararray is ring ring!!!!!!!!!!!!!!!!!!!!");
  const alarm = "quack.mp3";
                     player.play(alarm);
  }
                  
                    //  firstcardetectedvalue=fourthcar;
}else{
  countingcardetected=0;
}
        }
         if(fifthcar<firstcar*0.85&&fifthcar!=0.0){
         
          if(!cardetected){
//              print("cararray is ring!!!!!!!!!!!!!!!!!!!!!!!!!"+fifthcar.toString()+"///"+firstcar.toString());
// cardetected=true;
//   const alarm = "quack.mp3";
//                      player.play(alarm);
          }
          
          
        }
setRecognitionsColor(first +
            "("+firstp.toStringAsFixed(2)+")/" +
            second +
             "("+secondp.toStringAsFixed(2)+")/" +
            third +
             "("+thirdp.toStringAsFixed(2)+")/" +
            fourth +
            "("+fourthp.toStringAsFixed(2)+")/" +
            fifth+
             "("+fifthp.toStringAsFixed(2)+")/" 
             );
        if(first==second&&first==third&&first==fourth&&first==fifth){
          setCurrentColor(first );
           setCC(first+"/"+( (firstp+secondp+thirdp+fourthp+fifthp)/5).toStringAsFixed(2) );

          if(currentTraffic!=first){
            if(currentTraffic=="red"){
              if(first=="redleft"||first=="green"){

  const alarm = "click1.mp3";
                     player.play(alarm);
              }
            }

            if(currentTraffic=="redleft"){
              if(first=="green"){

  const alarm = "click1.mp3";
                     player.play(alarm);
              }
            }
             
          }
          // currentTraffic=first;
            print("before change"+currentTraffic+"///after change"+first);
            
        // if(SpeedometerProvider.speedCar < 5){
        //   //detectedflag 가 false면 울릴준비가 됨. 
        //       if(first=="red"){
        //         detectedflag=false;
        //       }
              
        //       if(first=="green"||first=="redleft"){
        //           if(!detectedflag){
        //              const alarm = "click1.mp3";
        //              player.play(alarm);
        //              detectedflag=true;
        //           }
        //       }
           
        // }else{
        //   detectedflag=false;
        // }
    
          // }
          currentTraffic=first;
        }
        }else{
          cardetected=false;
        }
        
//red -> redleft , green , greenleft
        print("showresult" +
            first +
            "//" +
            second +
            "////" +
            third +
            '/' +
            fourth +
            "??????" +
            fifth);
        if (first == "red" &&
            second == "red" &&
            ((fourth == "green" && fifth == "green") ||
                (fourth == "greenleft" || fifth == "greenleft") ||
                (fourth == "redleft" && fifth == "redleft"))) {
          print("showresult sound alarm");
           
// variable_name.removeFirst();

        }

//green -> greenleft
//         if (first == "green" &&
//             second == "green" &&
//             (fourth == "greenleft" || fifth == "greenleft")) {
//           print("showresult sound qqqqqqqqqqquack larm");

//           if(SpeedometerProvider.speedCar < 5){
// const alarm = "quack.mp3";
//           player.play(alarm);
//           }
          
// // variable_name.removeFirst();
//         }
if(cararray.length>4){
  cararray.removeFirst();
}

        if (variable_name.length > 4) {
// variable_name.clear();
          while (variable_name.length > 4) {
            print("showresult clear come!");
            variable_name.removeFirst();
            variable_nameposible.removeFirst();
            
          }
          first = "";
          second = "";
          third = "";
          fourth = "";
          fifth = "";
          firstp = 0;
          secondp = 0;
          thirdp = 0;
          fourthp = 0;
          fifthp = 0;
          // print("first and last value is");
          // print(variable_name.first+"///"+variable_name.last);

          //    int lookingFor = 0;

          // int counter = 0;
          // for (String number : variable_name) {
          //     if (number == lookingFor) {
          //         System.out.println(lookingFor + " is at position " + counter + " in the queue.");
          //         break;
          //     }
          //     else counter++;
          // }
        } else {}
        // }on Exception {
        //   print("error!!!!");
        // }
        if (recognitions != null && mounted) {
          state.recognitions = List<Recognition>.from(
              recognitions.map((model) => Recognition.fromJson(model)));
          state.widthImage = cameraImage.width;
          state.heightImage = cameraImage.height;
          notifyListeners();
        }
        this._isDetecting = false;



      }
    } else {
      print(
          'Please run `loadModel(type)` before running `runModel(cameraImage)`');
    }
  }

  /*  ===  원본  ===
  Future<void> runModel(CameraImage cameraImage) async {
    if (_isLoadModel && mounted) {
      if (!this._isDetecting && mounted) {
        this._isDetecting = true;
        int startTime = new DateTime.now().millisecondsSinceEpoch;
        
        var recognitions =
            await this._tensorFlowService.runModelOnFrame(cameraImage);
        int endTime = new DateTime.now().millisecondsSinceEpoch;
        // try{
        if (recognitions?.length == 1) {
          print("showresultadding-1-1-1-1-1-" +
              recognitions?[0]["detectedClass"]);
          if (recognitions?[0]["detectedClass"] == "red" ||
              recognitions?[0]["detectedClass"] == "green" ||
              recognitions?[0]["detectedClass"] == "redleft" ||
              recognitions?[0]["detectedClass"] == "greenleft") {
            variable_name.add(recognitions?[0]["detectedClass"]);
          }
        } else if (recognitions?.length == 2) {
          if (recognitions?[1]["detectedClass"] == "red" ||
              recognitions?[1]["detectedClass"] == "green" ||
              recognitions?[1]["detectedClass"] == "redleft" ||
              recognitions?[1]["detectedClass"] == "greenleft") {
            print("showresultadding1111" + recognitions?[1]["detectedClass"]);
            variable_name.add(recognitions?[1]["detectedClass"]);
          }
          if (recognitions?[0]["detectedClass"] == "red" ||
              recognitions?[0]["detectedClass"] == "green" ||
              recognitions?[0]["detectedClass"] == "redleft" ||
              recognitions?[0]["detectedClass"] == "greenleft") {
            print("showresultadding0000" + recognitions?[0]["detectedClass"]);
            variable_name.add(recognitions?[0]["detectedClass"]);
          }
          // print(recognitions?[1]["detectedClass"] );
          // print(recognitions?[1]["confidenceInClass"]);
          // print("two detected...");
          // print(recognitions?[0]["detectedClass"] );
          // print(recognitions?[0]["confidenceInClass"]);
        } else {}
        print(variable_name.length);
        int count = 0;
        String first = "";
        String second = "";
        String third = "";
        String fourth = "";
        String fifth = "";
        print("showresult variable_name" + variable_name.toString());
        variable_name.forEach((element) {
          count++;
          if (count == 1) {
            first = element;
          }
          if (count == 2) {
            second = element;
          }
          if (count == 3) {
            third = element;
          }
          if (count == 4) {
            fourth = element;
          }
          if (count == 5) {
            fifth = element;
          }
        });

//red -> redleft , green , greenleft
        print("showresult" +
            first +
            "//" +
            second +
            "////" +
            third +
            '/' +
            fourth +
            "??????${speed}" +
            fifth);
        if (first == "red" &&
            second == "red" &&
            ((fourth == "green" && fifth == "green") ||
                (fourth == "greenleft" && fifth == "greenleft") ||
                (fourth == "redleft" && fifth == "redleft"))) {
          print("showresult sound alarm");
          const alarm = "click1.mp3";
          player.play(alarm);
// variable_name.removeFirst();

        }

//green -> greenleft
        if (first == "green" &&
            second == "green" &&
            (fourth == "greenleft" && fifth == "greenleft")) {
          print("showresult sound qqqqqqqqqqquack larm");
          const alarm = "quack.mp3";
          player.play(alarm);
// variable_name.removeFirst();
        }
        if (variable_name.length > 4) {
// variable_name.clear();
          while (variable_name.length > 4) {
            print("showresult clear come!");
            variable_name.removeFirst();
          }
          first = "";
          second = "";
          third = "";
          fourth = "";
          fifth = "";
          // print("first and last value is");
          // print(variable_name.first+"///"+variable_name.last);

          //    int lookingFor = 0;

          // int counter = 0;
          // for (String number : variable_name) {
          //     if (number == lookingFor) {
          //         System.out.println(lookingFor + " is at position " + counter + " in the queue.");
          //         break;
          //     }
          //     else counter++;
          // }
        } else {}
        // }on Exception {
        //   print("error!!!!");
        // }
        if (recognitions != null && mounted) {
          state.recognitions = List<Recognition>.from(
              recognitions.map((model) => Recognition.fromJson(model)));
          state.widthImage = cameraImage.width;
          state.heightImage = cameraImage.height;
          notifyListeners();
        }
        this._isDetecting = false;
      }
    } else {
      print(
          'Please run `loadModel(type)` before running `runModel(cameraImage)`');
    }
  }
  */

  Future<void> close() async {
    await this._tensorFlowService.close();
  }

  void updateTypeTfLite(ModelType item) {
    this._tensorFlowService.type = item;
  }

    bool updateRedtoGreen(bool flag) {
      print("handleswitch ccccc"+flag.toString());
    return this._tensorFlowService.redtogreen = flag;

  }
}
