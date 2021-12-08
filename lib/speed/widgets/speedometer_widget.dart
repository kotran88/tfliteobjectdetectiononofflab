import 'package:flutter/material.dart';
import 'package:flutter_realtime_object_detection/speed/providers/speedometer_provider.dart';
import 'package:segment_display/segment_display.dart';
import 'package:provider/provider.dart';

class SpeedometerWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final providerData = Provider.of<SpeedometerProvider>(context);
    providerData.getSpeedUpdates();
    return Text(
        '${providerData.speedometer.currentSpeed.toStringAsFixed(2)}km/h');
  }
}
