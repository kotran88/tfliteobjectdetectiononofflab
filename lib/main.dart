import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:trafficawareness/app/app_router.dart';
import 'package:trafficawareness/services/navigation_service.dart';
import 'package:trafficawareness/services/tensorflow_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:download_assets/download_assets.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(MultiProvider(
    providers: <SingleChildWidget>[
      Provider<AppRoute>(create: (_) => AppRoute()),
      Provider<NavigationService>(create: (_) => NavigationService()),
      Provider<TensorFlowService>(create: (_) => TensorFlowService())
    ],
    child: Application(),
  ));
}

//./data/user/0/com.onofflab.traffic/app_flutter/assets
///data/user/0/com.onofflab.traffic/app_flutter/assets
//flutter_ass fets/assets/models/quantized22.tflite


// 1. 1km 5km간ㅡ 극 차
// 2. 1km되고 나서 지우고, 평균을 q낸 크기를 start로 삼아야...
// 3. 화면에 80%가 얼마인지 알려줘서 임계치를 알려주기. 
// 4. 
class Application extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AppRoute appRoute = Provider.of<AppRoute>(context, listen: false);
    return ScreenUtilInit(
        designSize: Size(375, 812),
        builder: () {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData.dark(),
            onGenerateRoute: appRoute.generateRoute,
            initialRoute: AppRoute.splashScreen,
            navigatorKey: NavigationService.navigationKey,
            navigatorObservers: <NavigatorObserver>[
              NavigationService.routeObserver
            ],
          );
        });
  }
}
