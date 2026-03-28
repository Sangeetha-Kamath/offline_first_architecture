// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:practice_flutter_coding/posts/data/model/post_model.dart';

// class HiveDataSource {
//   final box = Hive.box("post_cache");
//   final key = "post_key";

//   void putCachedPost(List<Post> posts){
//     box.put(key,jsonEncode(posts.map((e) => e.toJson(),).toList()));
//     debugPrint("offline posts length:${box.values}");
//   }

//   List<Post> getCahedPost(){
//     final data = box.get(key);
//     if(data == null)return [];
//     final dataList = jsonDecode(data);
//    final posts = (dataList as List).map<Post>((e)=>Post.fromJson(e)).toList();
//    debugPrint("post length offline:${posts.length}");
//    return posts;
//   }
// }