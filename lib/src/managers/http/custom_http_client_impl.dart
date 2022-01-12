import 'dart:io';

import 'package:dio/dio.dart';
import 'package:trafficawareness/src/managers/http/custom_http_client.dart';

class CustomHttpClientImpl implements CustomHttpClient {
  @override
  Future<Response> download(
    String urlPath,
    String savePath, {
    ProgressCallback? onReceiveProgress,
  }) async {
    return await Dio().download(
      urlPath,
      savePath,
      options: Options(
        headers: {HttpHeaders.acceptEncodingHeader: "*"},
        responseType: ResponseType.bytes,
      ),
      onReceiveProgress: onReceiveProgress,
    );
  }
}
