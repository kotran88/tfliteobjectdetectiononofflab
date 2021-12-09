import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as UI;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_realtime_object_detection/app/app_resources.dart';
import 'package:flutter_realtime_object_detection/app/app_router.dart';
import 'package:flutter_realtime_object_detection/app/base/base_stateful.dart';
import 'package:flutter_realtime_object_detection/main.dart';
import 'package:flutter_realtime_object_detection/services/navigation_service.dart';
import 'package:flutter_realtime_object_detection/services/tensorflow_service.dart';
import 'package:flutter_realtime_object_detection/speed/Body.dart';
import 'package:flutter_realtime_object_detection/view_models/home_view_model.dart';
import 'package:flutter_realtime_object_detection/widgets/aperture/aperture_widget.dart';
import 'package:flutter_realtime_object_detection/widgets/confidence_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends BaseStateful<HomeScreen, HomeViewModel>
    with WidgetsBindingObserver {
  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;

  late StreamController<Map> apertureController;

  late ScreenshotController screenshotController;

  late Uint8List _imageFile;

  TextEditingController searchController = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  void afterFirstBuild(BuildContext context) {
    super.afterFirstBuild(context);
    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void initState() {
    super.initState();
    loadModel(viewModel.state.type);
    initCamera();

    apertureController = StreamController<Map>.broadcast();
    screenshotController = ScreenshotController();
  }

  void initCamera() {
    _cameraController = CameraController(
        cameras[viewModel.state.cameraIndex], ResolutionPreset.high);
    _initializeControllerFuture = _cameraController.initialize().then((_) {
      if (!mounted) {
        return;
      }
      _cameraController.setFlashMode(FlashMode.off);

      /// TODO: Run Model
      setState(() {});
      _cameraController.startImageStream((image) async {
        if (!mounted) {
          return;
        }
        await viewModel.runModel(image);
      });
    });
  }

  void loadModel(ModelType type) async {
    await viewModel.loadModel(type);
  }

  Future<void> runModel(CameraImage image) async {
    if (mounted) {
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

    /// TODO: Check Camera
    if (!_cameraController.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      // _cameraController.dispose();
    } else {
      initCamera();
    }
  }

  @override
  Widget buildPageWidget(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: false,
        appBar: buildAppBarWidget(context),
        body: buildBodyWidget(context),
        floatingActionButton: buildFloatingActionButton(context),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat);
  }

  Widget buildFloatingActionButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          FloatingActionButton(
            heroTag: null,
            onPressed: handleCaptureClick,
            tooltip: "Capture",
            backgroundColor: AppColors.white,
            child: Icon(
              Icons.cut_outlined,
              color: AppColors.blue,
            ),
          ),
          FloatingActionButton(
            heroTag: null,
            onPressed: handleSwitchCameraClick,
            tooltip: "Switch Camera",
            backgroundColor: AppColors.white,
            child: Icon(
              viewModel.state.isBackCamera()
                  ? Icons.camera_front
                  : Icons.camera_rear,
              color: AppColors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> handleSwitchCameraClick() async {
    apertureController.sink.add({});
    // viewModel.switchCamera();

    viewModel.startLocation();
    initCamera();
    return true;
  }

  handleSwitchSource(ModelType item) {
    viewModel.dispose();
    viewModel.updateTypeTfLite(item);
    Provider.of<NavigationService>(context, listen: false).pushReplacementNamed(
        AppRoute.homeScreen,
        args: {'isWithoutAnimation': true});
  }

  Future<bool> handleCaptureClick() async {
    print("handleCaptureClick 1 ");
    screenshotController.capture().then((value) async {

    print("handleCaptureClick 12 ");
      if (value != null) {

    print("handleCaptureClick 13 ");
        // final cameraImage = await _cameraController.takePicture();

        try {
      XFile file = await _cameraController.takePicture();
      return file;
    } on CameraException catch (e) {
          print(e.toString()+"handleCaptureClick 144 ");
      return null;
    }
    print("handleCaptureClick 1455 ");
        // await renderedAndSaveImage(value, cameraImage);
      }
    });
    return true;
  }

  Future<bool> renderedAndSaveImage(Uint8List draw, XFile camera) async {
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
 print("renderedandsaveimage 15 ");
    codec = await UI.instantiateImageCodec(draw,
        targetWidth: scaleWidth.toInt(), targetHeight: scaleHeight.toInt());
    detectionImage = (await codec.getNextFrame()).image;

    canvas.drawImage(detectionImage, Offset(difW.abs(), difH.abs()), Paint());
 print("renderedandsaveimage 16 ");
    canvas.save();
    canvas.restore();
 print("renderedandsaveimage 17 ");
    final picture = recorder.endRecording();

    var img = await picture.toImage(scaleWidth.toInt(), scaleHeight.toInt());

    final pngBytes = await img.toByteData(format: UI.ImageByteFormat.png);

    final result2 = await ImageGallerySaver.saveImage(
        Uint8List.view(pngBytes!.buffer),
        quality: 100,
        name: 'realtime_object_detection_${DateTime.now()}');
    print(result2);
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
        //               enabled: !viewModel.state.isYolo(),
        //               child: Row(
        //                 children: <Widget>[
        //                   Icon(Icons.api,
        //                       color: !viewModel.state.isYolo()
        //                           ? AppColors.black
        //                           : AppColors.grey),
        //                   Text(' YOLO',
        //                       style: AppTextStyles.regularTextStyle(
        //                           color: !viewModel.state.isYolo()
        //                               ? AppColors.black
        //                               : AppColors.grey)),
        //                 ],
        //               ),
        //               value: ModelType.YOLO),
        //           PopupMenuItem(
        //               enabled: !viewModel.state.isSSDMobileNet(),
        //               child: Row(
        //                 children: <Widget>[
        //                   Icon(Icons.api,
        //                       color: !viewModel.state.isSSDMobileNet()
        //                           ? AppColors.black
        //                           : AppColors.grey),
        //                   Text(' SSD MobileNet',
        //                       style: AppTextStyles.regularTextStyle(
        //                           color: !viewModel.state.isSSDMobileNet()
        //                               ? AppColors.black
        //                               : AppColors.grey)),
        //                 ],
        //               ),
        //               value: ModelType.SSDMobileNet),
        //           PopupMenuItem(
        //               enabled: !viewModel.state.isMobileNet(),
        //               child: Row(
        //                 children: <Widget>[
        //                   Icon(Icons.api,
        //                       color: !viewModel.state.isMobileNet()
        //                           ? AppColors.black
        //                           : AppColors.grey),
        //                   Text(' MobileNet',
        //                       style: AppTextStyles.regularTextStyle(
        //                           color: !viewModel.state.isMobileNet()
        //                               ? AppColors.black
        //                               : AppColors.grey)),
        //                 ],
        //               ),
        //               value: ModelType.MobileNet),
        //           PopupMenuItem(
        //               enabled: !viewModel.state.isPoseNet(),
        //               child: Row(
        //                 children: <Widget>[
        //                   Icon(Icons.api,
        //                       color: !viewModel.state.isPoseNet()
        //                           ? AppColors.black
        //                           : AppColors.grey),
        //                   Text(' PoseNet',
        //                       style: AppTextStyles.regularTextStyle(
        //                           color: !viewModel.state.isPoseNet()
        //                               ? AppColors.black
        //                               : AppColors.grey)),
        //                 ],
        //               ),
        //               value: ModelType.PoseNet),
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

    final Size previewSize =
        isInitialized ? _cameraController.value.previewSize! : Size(100, 100);
    final double previewHeight = max(previewSize.height, previewSize.width);
    final double previewWidth = min(previewSize.height, previewSize.width);

    final double screenRatio = screenHeight / screenWidth;
    final double previewRatio = previewHeight / previewWidth;
    final maxHeight =
        screenRatio > previewRatio ? screenHeight : screenWidth * previewRatio;
    final maxWidth =
        screenRatio > previewRatio ? screenHeight / previewRatio : screenWidth;

    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
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
            height: MediaQuery.of(context).size.height * 0.3,
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
                            ? "공백입니다."
                            : value.getRecognitionsColor.toString(),
                      ),
                    ),

                    Container(
                      color: Colors.blue,
                      child: Text(
                        value.getRecognitionsColor.toString() == ""
                            ? "공백"
                            : value.currentColor.toString(),
                      ),
                    ),
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
