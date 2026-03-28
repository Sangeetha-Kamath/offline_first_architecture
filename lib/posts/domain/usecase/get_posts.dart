
import 'package:practice_flutter_coding/posts/domain/repositories/post_repository.dart';

import '../entities/post.dart';

class GetPosts {
final PostRepository repository;
GetPosts({required this.repository});

Future<List<Post>> call(int page)async{
  return  repository.getPosts(page);

}
}