import 'package:dio/dio.dart';
import 'package:practice_flutter_coding/utils/url_resources.dart';

class DioService{
  static final DioService _instance = DioService._internal();
  factory DioService()=>_instance;
  DioService._internal();
  late final Dio dio;
  void initialize(){
    dio = Dio(BaseOptions(
      baseUrl: UrlResources.baseUrl,
      connectTimeout: Duration(milliseconds: 30000),
      receiveTimeout: Duration(milliseconds: 30000),
      headers: {
        "content-type":"application/json",
      }
      
    )
    )..interceptors.add(LogInterceptor(requestUrl: true,error: true,));

    
  }
  

}