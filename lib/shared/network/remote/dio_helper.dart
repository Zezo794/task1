import 'package:dio/dio.dart';

class DioHelper {
  static late Dio dio;

  static init() {
    dio = Dio(
      BaseOptions(
        baseUrl: '',
        headers: {
          'Content-Type': 'application/json',
        },
        receiveDataWhenStatusError: true,
      ),
    );
  }

  // to get data from url
  static Future<Response> getData(
      {required String url, Map<String, dynamic>? query}) async {
    return await dio.get(url, queryParameters: query);
  }

  // post data
  static Future<Response> postData(
      {required String url,
        required Map<String, dynamic>? data,
        Map<String, dynamic>? query}) async {
    return await dio.post(url, data: data, queryParameters: query);
  }

}