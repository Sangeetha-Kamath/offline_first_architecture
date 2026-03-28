import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../posts/data/model/post_model.dart';

class DbHelper {
 static Isar? _isar;
  static Future<void> openDB()async{
    if(_isar!=null){
      return;
    }
    final path = await getApplicationDocumentsDirectory();
     _isar = await Isar.open([PostModelSchema], directory: path.path);
  }
 static Isar get isar{
  final isar =_isar;
  

   if(isar!=null){    
    return isar;}else{
      throw StackOverflowError();
    }

  }
  void close(){
    isar.close();
  }
  Future<void> cachePost(List<PostModel> data)async{
  
   await  isar.writeTxn(()async{
   await isar.postModels.putAll(data);
    });
  
    
  }
  Future<List<PostModel>> getCachedPosts(int page)async{
 
  try{
    const int postsPerPage = 30;
    final offset = page * postsPerPage;
    
    final posts = await isar.postModels
        .where()
        .sortByIdDesc()
        .offset(offset)
        .limit(postsPerPage)
        .findAll();

    return posts;
  }catch(e){
    throw Exception(e);
  }
  }
  Future<void> deleteAll()async{
    await isar.writeTxn(()async{
 await isar.postModels.where().sortById().deleteAll();
  });
   
    
  }

}