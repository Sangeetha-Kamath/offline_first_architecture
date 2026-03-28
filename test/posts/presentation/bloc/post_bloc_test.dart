
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:practice_flutter_coding/posts/domain/entities/post.dart';
import 'package:practice_flutter_coding/posts/domain/repositories/post_repository.dart';
import 'package:practice_flutter_coding/posts/presentation/bloc/post_bloc.dart';
import 'package:practice_flutter_coding/posts/presentation/bloc/post_event.dart';
import 'package:practice_flutter_coding/posts/presentation/bloc/post_state.dart';
import 'package:practice_flutter_coding/service/connectivity_service.dart';

class MockPostRepository extends Mock implements PostRepository {}

class MockConnectivityService extends Mock implements ConnectivityService {}

void main() {
  late MockPostRepository mockPostRepository;
  late MockConnectivityService mockConnectivityService;
  late PostBloc bloc;

  setUp(() {
    mockPostRepository = MockPostRepository();
    mockConnectivityService = MockConnectivityService();
    when(() => mockConnectivityService.isOnline).thenReturn(true);
    when(() => mockConnectivityService.statusStream).thenAnswer((_) => Stream.empty());
    bloc = PostBloc(
      repo: mockPostRepository,
      connectivityService: mockConnectivityService,
    );
  });

  tearDown(() {
    bloc.close();
  });

  test('initial state', () {
    expect(bloc.state, PostState.initial());
  });

  test('cache empty, online, api returns posts', () async {
    final tposts = [Post(body: '', title: '', id: 1, userId: 1)];

    when(() => mockPostRepository.getCachedPosts(0)).thenAnswer((_) async => []);
    when(() => mockPostRepository.getPosts(0)).thenAnswer((_) async => tposts);
    when(() => mockPostRepository.cachePost(tposts)).thenAnswer((_) async => {});

    final states = <PostState>[];
    bloc.stream.listen(states.add);

    bloc.add(GetPostEvent());
    await Future.delayed(const Duration(milliseconds: 500));

    expect(states.length, equals(2));
    expect(states[0].status, PostStatus.isLoading);
    expect(states[1].status, PostStatus.isSuccess);
    expect(states[1].postList, tposts);
    expect(states[1].page, 1);
    expect(states[1].isOffline, isFalse);

    verify(() => mockPostRepository.getCachedPosts(0)).called(1);
    verify(() => mockPostRepository.getPosts(0)).called(1);
    verify(() => mockPostRepository.cachePost(tposts)).called(1);
  });

  test('cached data exists, online, then fetch more posts', () async {
    final cachedPost = [Post(body: '', title: '', id: 1, userId: 1)];
    final apiPost = [Post(body: '', title: '', id: 2, userId: 1)];

    when(() => mockPostRepository.getCachedPosts(0)).thenAnswer((_) async => cachedPost);
    when(() => mockPostRepository.getCachedPosts(1)).thenAnswer((_) async => []);
    when(() => mockPostRepository.getPosts(1)).thenAnswer((_) async => apiPost);
    when(() => mockPostRepository.cachePost(apiPost)).thenAnswer((_) async => {});

    final states = <PostState>[];
    bloc.stream.listen(states.add);

    bloc.add(GetPostEvent());
    await Future.delayed(const Duration(milliseconds: 500));

    expect(states.length, equals(3));
    expect(states[0].status, PostStatus.isSuccess);
    expect(states[0].postList, cachedPost);
    expect(states[0].page, 1);

    expect(states[1].status, PostStatus.isFetching);

    expect(states[2].status, PostStatus.isSuccess);
    expect(states[2].postList, [...cachedPost, ...apiPost]);
    expect(states[2].page, 2);

    verify(() => mockPostRepository.getCachedPosts(0)).called(1);
    verify(() => mockPostRepository.getCachedPosts(1)).called(1);
    verify(() => mockPostRepository.getPosts(1)).called(1);
    verify(() => mockPostRepository.cachePost(apiPost)).called(1);
  });

  test('api fails and cached fetch throws: state failed', () async {
    when(() => mockPostRepository.getCachedPosts(any())).thenThrow(Exception('cached posts error'));
    when(() => mockPostRepository.getPosts(any())).thenThrow(Exception('api get posts error'));

    final states = <PostState>[];
    bloc.stream.listen(states.add);

    bloc.add(GetPostEvent());
    await Future.delayed(const Duration(milliseconds: 500));

    expect(states.any((s) => s.status == PostStatus.failed), isTrue);
    expect(states.last.error, contains('cached posts error'));

    verify(() => mockPostRepository.getCachedPosts(any())).called(1);
    verifyNever(() => mockPostRepository.getPosts(any()));
  });
}


  

  
