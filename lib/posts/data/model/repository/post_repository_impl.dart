import 'package:practice_flutter_coding/posts/data/model/repository/post_data_source.dart';
import 'package:practice_flutter_coding/posts/domain/repositories/post_repository.dart';
import 'package:practice_flutter_coding/service/db_helper.dart';

import '../../../domain/entities/post.dart';
import '../post_model.dart';

class PostRepositoryImpl extends PostRepository{
  final PostDataSource dataSource;
  final DbHelper dbHelper;
  PostRepositoryImpl({required this.dataSource, required this.dbHelper});
 
 
 

  //this is done using isar
  @override
  Future<void> cachePost(List<Post> posts)async{
    final list = posts.map((e)=>PostModel.fromEntity(e)).toList();
   await dbHelper.cachePost(list);

  }
  @override
  Future<void> deleteAllFromCache()async{
  await  dbHelper.deleteAll();
  }
  @override
  Future<List<Post>> getCachedPosts(int page)async{
    try{
   
final list = await dbHelper.getCachedPosts(page);

    return list.map<Post>((e)=>e.toEntity()).toList();
    }catch(e){
      throw Exception(e);
    }

  }

@override
  Future<List<Post>> getPosts(int page)async{
   
    final list =  await dataSource.getPosts(page);
   return list.map<Post>((e)=>e.toEntity()).toList();
     
}
}