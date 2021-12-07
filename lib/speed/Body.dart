import 'package:flutter/material.dart';
import 'package:flutter_realtime_object_detection/speed/providers/speedometer_provider.dart';
import 'package:flutter_realtime_object_detection/speed/widgets/speedometer_widget.dart';
import 'package:provider/provider.dart';

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => SpeedometerProvider(),
      child: SpeedometerWidget(),
    );
  }
}
