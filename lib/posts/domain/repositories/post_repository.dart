
import '../entities/post.dart';

abstract class PostRepository {
Future<List<Post>> getPosts(int page);
 Future<List<Post>> getCachedPosts(int page);
 Future<void> deleteAllFromCache();
Future<void> cachePost(List<Post> posts);
}