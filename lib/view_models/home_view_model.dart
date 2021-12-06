import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_realtime_object_detection/app/base/base_view_model.dart';
import '/models/recognition.dart';
import 'package:flutter_realtime_object_detection/services/tensorflow_service.dart';
import 'package:flutter_realtime_object_detection/view_states/home_view_state.dart';
import 'dart:collection';
import 'package:audioplayers/audio_cache.dart';
class HomeViewModel extends BaseViewModel<HomeViewState> {
  bool _isLoadModel = false;
  bool _isDetecting = false;
  AudioCache player=new AudioCache();
  ListQueue<String> variable_name =  ListQueue<String>();
  late TensorFlowService _tensorFlowService;

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
        var recognitions =
            await this._tensorFlowService.runModelOnFrame(cameraImage);
        int endTime = new DateTime.now().millisecondsSinceEpoch;
        // try{
          if(recognitions?.length==1){
              
              print("showresultadding-1-1-1-1-1-"+recognitions?[0]["detectedClass"]);
             if(recognitions?[0]["detectedClass"]=="red"||recognitions?[0]["detectedClass"]=="green"||recognitions?[0]["detectedClass"]=="redleft" ||recognitions?[0]["detectedClass"]=="greenleft"){

variable_name.add(recognitions?[0]["detectedClass"]);
            }
          }else if(recognitions?.length==2){
            if(recognitions?[1]["detectedClass"]=="red"||recognitions?[1]["detectedClass"]=="green"||recognitions?[1]["detectedClass"]=="redleft" ||recognitions?[1]["detectedClass"]=="greenleft"){
              print("showresultadding1111"+recognitions?[1]["detectedClass"]);
variable_name.add(recognitions?[1]["detectedClass"]);
            }
                     if(recognitions?[0]["detectedClass"]=="red"||recognitions?[0]["detectedClass"]=="green"||recognitions?[0]["detectedClass"]=="redleft" ||recognitions?[0]["detectedClass"]=="greenleft"){

              print("showresultadding0000"+recognitions?[0]["detectedClass"]);
variable_name.add(recognitions?[0]["detectedClass"]);
            }
            // print(recognitions?[1]["detectedClass"] );
            // print(recognitions?[1]["confidenceInClass"]);
            // print("two detected...");
            // print(recognitions?[0]["detectedClass"] );
            // print(recognitions?[0]["confidenceInClass"]);
          }else{
          }
          print(variable_name.length);
          int count=0;         
          String first="";
          String second="";
          String third="";
          String fourth="";
          String fifth="";
          print("showresult variable_name"+variable_name.toString());
          variable_name.forEach((element) {
            count++;
            if(count==1){
              first=element;
            }
            if(count==2){
              second=element;
            }
            if(count==3){
              third=element;
            }
            if(count==4){
              fourth=element;
            }
            if(count==5){
              fifth=element;
            }
           
          });
 
//red -> redleft , green , greenleft
          print("showresult"+first+"//"+second+"////"+third+'/'+fourth+"??????"+fifth);
      if(first=="red"&&second=="red"&&( (  fourth=="green"&&fifth=="green" )|| (fourth=="greenleft"&&fifth=="greenleft") || (fourth=="redleft"&&fifth=="redleft") ) ){
              print("showresult sound alarm");
const alarm="click1.mp3";
player.play(alarm);
// variable_name.removeFirst();

            }


//green -> greenleft 
              if(first=="green"&&second=="green"&&(  fourth=="greenleft"&&fifth=="greenleft" )){
               print("showresult sound qqqqqqqqqqquack larm");
const alarm="quack.mp3";
player.play(alarm);
// variable_name.removeFirst();
            }
          if(variable_name.length>4){

// variable_name.clear();
while(variable_name.length>4){

print("showresult clear come!");
   variable_name.removeFirst();
}
            first="";
            second="";
            third="";
            fourth="";
            fifth="";
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
          }else{
          }
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
      print('Please run `loadModel(type)` before running `runModel(cameraImage)`');
    }
  }

  Future<void> close() async {
    await this._tensorFlowService.close();
  }

  void updateTypeTfLite(ModelType item) {
    this._tensorFlowService.type = item;
  }

}
