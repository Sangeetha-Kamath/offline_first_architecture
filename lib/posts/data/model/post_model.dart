
import 'package:isar/isar.dart';

import '../../domain/entities/post.dart';

part 'post_model.g.dart';
 @collection
class  PostModel  {
  Id? idData = Isar.autoIncrement;

  int? userId;

  int? id;

  String? title;

  String? body;
  late int page;
  late DateTime createdAt;
  late DateTime updatedAt;
  
 
  PostModel({
    this.userId,
    this.id,
    this.title,
    this.body,
    this.page = 0,
  }) {
    createdAt = DateTime.now();
    updatedAt = DateTime.now();
  }

 factory PostModel.fromJson(Map<String, dynamic> json) {
    final model = PostModel(
      userId: json['userId'],
      id: json['id'],
      title: json['title'],
      body: json['body'],
      page: json['page'] ?? 0,
    );
    if (json['createdAt'] != null) {
      model.createdAt = DateTime.parse(json['createdAt']);
    }
    if (json['updatedAt'] != null) {
      model.updatedAt = DateTime.parse(json['updatedAt']);
    }
    return model;
  }
    
  
  factory PostModel.fromEntity(Post post){
    return PostModel(body: post.body??"",
    id: post.id,
title: post.title,
page: 0,

    );
  }
  Post toEntity(){
    return Post(body: body??'',
    title: title??"",
    id:id,
   
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userId'] = userId;
    data['id'] = id;
    data['title'] = title;
    data['body'] = body;
    return data;
  }
  
 
}
