// import 'package:flutter/material.dart';
// import 'package:flutter_realtime_object_detection/speed/providers/speedometer_provider.dart';
// import 'package:segment_display/segment_display.dart';
// import 'package:provider/provider.dart';

// class SpeedometerWidget extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final providerData = Provider.of<SpeedometerProvider>(context);
//     providerData.getSpeedUpdates();
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           "Car Speedometer",
//           style: TextStyle(color: Colors.white, fontSize: 30),
//         ),
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Center(
//                     child: Column(children: <Widget>[
//                   Text("Current Speed",
//                       style: Theme.of(context).textTheme.bodyText1),
//                   SevenSegmentDisplay(
//                       value:
//                           '${providerData.speedometer.currentSpeed.toStringAsFixed(2)}',
//                       size: 8,
//                       backgroundColor: Colors.white,
//                       segmentStyle: HexSegmentStyle(
//                           enabledColor: Colors.green,
//                           disabledColor: Colors.white)),
//                   Text("Km/h", style: Theme.of(context).textTheme.bodyText1)
//                 ])),
//               ),
//             ]),
//       ),
//     );
//   }
// }

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
