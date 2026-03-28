import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:practice_flutter_coding/posts/domain/entities/post.dart';
import 'package:practice_flutter_coding/posts/domain/repositories/post_repository.dart';
import 'package:practice_flutter_coding/posts/domain/usecase/get_posts.dart';

class MockPostRepository extends Mock implements PostRepository{

}


void main() {
  late MockPostRepository mockPostRepository;
  late GetPosts getPosts;

  setUp(() {
    mockPostRepository = MockPostRepository();
    getPosts = GetPosts(repository: mockPostRepository);
  });
final tPage=0;
  final tPosts = [
    Post(id: 1, title: 'Test Post 1', body: 'This is a test post.'),
    Post(id: 2, title: 'Test Post 2', body: 'This is another test post.'),
  ];
//should return a list of posts from the local cache if available and then fetch from api and update the state accordingly
test('should return list of posts from the local cache if available and then fetch from api and update the state accordingly', () async {
    // Arrange
   
    when(() => mockPostRepository.getPosts(any())).thenAnswer((_) async => tPosts);

    // Act
    final result = await getPosts(tPage);

    // Assert
    expect(result, tPosts);
   
    verify(() => mockPostRepository.getPosts(any())).called(1);
    verifyNoMoreInteractions(mockPostRepository);
  });

  test('should return list of posts from the repository', () async {
    // Arrange
    when(() => mockPostRepository.getPosts(tPage)).thenAnswer((_) async => tPosts);

    // Act
    final result = await getPosts(tPage);

    // Assert
    expect(result, tPosts);
    verify(() => mockPostRepository.getPosts(tPage)).called(1);
    verifyNoMoreInteractions(mockPostRepository);
  });
  test('should throw an exception when the repository fails', () async {
    // Arrange
    when(() => mockPostRepository.getPosts(tPage)).thenThrow(Exception('Failed to fetch posts'));

    // Act
    final call = getPosts(tPage);

    // Assert
    expect(() => call, throwsA(isA<Exception>()));
    verify(() => mockPostRepository.getPosts(tPage)).called(1);
    verifyNoMoreInteractions(mockPostRepository);
  });
  test('should return an empty list when there are no posts', () async {
    // Arrange
    when(() => mockPostRepository.getPosts(tPage)).thenAnswer((_) async => []);

    // Act
    final result = await getPosts(tPage);

    // Assert
    expect(result, []);
    verify(() => mockPostRepository.getPosts(tPage)).called(1);
    verifyNoMoreInteractions(mockPostRepository);
  });
test('should return a list of posts with correct data', () async {
    // Arrange
    when(() => mockPostRepository.getPosts(tPage)).thenAnswer((_) async => tPosts);

    // Act
    final result = await getPosts(tPage);

    // Assert
    expect(result.length, tPosts.length);
    for (int i = 0; i < result.length; i++) {
      expect(result[i].id, tPosts[i].id);
      expect(result[i].title, tPosts[i].title);
      expect(result[i].body, tPosts[i].body);
    }
    verify(() => mockPostRepository.getPosts(tPage)).called(1);
    verifyNoMoreInteractions(mockPostRepository);
  });

}