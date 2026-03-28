//writing testcase for the repo implementation
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:practice_flutter_coding/posts/data/model/post_model.dart';
import 'package:practice_flutter_coding/posts/data/model/repository/post_data_source.dart';
import 'package:practice_flutter_coding/posts/data/model/repository/post_repository_impl.dart';
import 'package:practice_flutter_coding/posts/domain/entities/post.dart';
import 'package:practice_flutter_coding/service/db_helper.dart';
class MockPostDataSource extends Mock implements PostDataSource {}
class MockDbHelper extends Mock implements DbHelper{}
void main(){
  late MockPostDataSource mockPostDataSource;
  late MockDbHelper mockDbHelper;
  late PostRepositoryImpl postRepositoryImpl;
  setUp(() {
    mockPostDataSource=MockPostDataSource();
    mockDbHelper=MockDbHelper();
    postRepositoryImpl = PostRepositoryImpl(dataSource:mockPostDataSource, dbHelper:mockDbHelper);
    
  });
  test('should return post list from the data source',()async{
    int tPage=0;
   final tPosts = [PostModel(body: "test1",title: "post",userId: 1,id:1)];
when(() =>  mockPostDataSource.getPosts(tPage),).thenAnswer((_)async=>tPosts);
final result = await postRepositoryImpl.getPosts(tPage);
expect(result,tPosts.map<Post>((e)=>e.toEntity()).toList());
verify(()=>mockPostDataSource.getPosts(tPage)).called(1);
verifyNoMoreInteractions( mockPostDataSource);

  });
  test('should cahe the data to the local storage',(){
   final tPosts=[
    Post(body:"",title: "",id:1,userId: 1)
   ];
   when(()=>mockDbHelper.cachePost(any())).thenAnswer((_)async{

   });
 postRepositoryImpl.cachePost(tPosts);
   verify(() => mockDbHelper.cachePost(any()),).called(1);
    verifyNoMoreInteractions(mockDbHelper);


  });
  test('should return cached posts from local db',()async{
    final tPosts = [PostModel(body: "",title: "",id:1,userId: 1)];
    when(() => mockDbHelper.getCachedPosts(any()),).thenAnswer((_)async=> tPosts);
    final result =await postRepositoryImpl.getCachedPosts(0);
    expect(result,tPosts.map<Post>((e) => e.toEntity()).toList(),);
    verify(() =>mockDbHelper.getCachedPosts(0)).called(1);
    verifyNoMoreInteractions(mockDbHelper);

  });
   test('should call dbHelper.deleteAll', () async {
    when(() => mockDbHelper.deleteAll())
        .thenAnswer((_) async {});

    await postRepositoryImpl.deleteAllFromCache();

    verify(() => mockDbHelper.deleteAll()).called(1);
  });

}
