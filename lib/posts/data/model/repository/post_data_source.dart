import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:practice_flutter_coding/service/dio_service.dart';

import '../../../../utils/url_resources.dart';
import '../post_model.dart';

class PostDataSource { 
  final DioService dio;
  
  PostDataSource({required this.dio});

   Future<List<PostModel>> getPosts(int page)async{
    try{
      late final  Response response;
      response =await dio.dio.get(UrlResources.getPosts,queryParameters: {
        "_start" :page,
        "_limit":10
      });
      if(response.statusCode == 200){
       final List<PostModel> list =  response.data.map<PostModel>((e)=>PostModel.fromJson(e)).toList();
        debugPrint("list response:${list.runtimeType}");
          return list;
      }
    else{
    throw Exception("Failed to fetch posts: ${response.statusCode}");
    }
      
    }  on DioException catch(e){
      throw Exception("exception from dio:$e");

      }
    catch(e){
      throw Exception("Something went wrong:$e");
    }

  }
}