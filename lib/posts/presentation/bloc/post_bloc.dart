import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/post.dart';
import '../../domain/repositories/post_repository.dart';
import '../../../service/connectivity_service.dart';
import 'post_event.dart';
import 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final PostRepository repo;
  final ConnectivityService connectivityService;

  PostBloc({required this.repo, required this.connectivityService})
    : super(PostState.initial()) {
    on<GetPostEvent>(_getPost);
  }

  //write _getPost function fetch the posts from the cache first if available and then fetch from the api if online and then sync the cache with the new data. If offline and no cache, show error message. If offline but cache available, show cached posts with offline message. Handle pagination and loading states appropriately.
  Future<void> _getPost(GetPostEvent event, Emitter<PostState> emit) async {
    debugPrint("page value:${state.page},${state.status}");

    if (state.status == PostStatus.isLoading ||
        state.status == PostStatus.isFetching ||
        state.status == PostStatus.isLastPage) {
      return;
    }

    final isOnline = connectivityService.isOnline;
    int requestPage = state.page ?? 0;
    List<Post> accumulatedPosts = state.postList ?? [];

    try {
      if (requestPage == 0) {
        // Load all available cached pages sequentially.
        int p = 0;
        final allCached = <Post>[];
        while (true) {
          final pageCache = await repo.getCachedPosts(p);
          if (pageCache.isEmpty) {
            break;
          }
          allCached.addAll(pageCache);
          emit(
            state.copyWith(
              postList: List<Post>.from(allCached),
              status: PostStatus.isSuccess,
              error: null,
              page: p + 1,
              isOffline: !isOnline,
            ),
          );
          p += 1;
        }

        accumulatedPosts = allCached;
        requestPage = p;
      }

      if (!isOnline) {
        // If offline and we already have some pages loaded, just stay with them;
        // otherwise try to load the requested page from cache.
        final pageCache = await repo.getCachedPosts(requestPage);

        if (pageCache.isNotEmpty) {
          final nextList = <Post>[...accumulatedPosts, ...pageCache];
          emit(
            state.copyWith(
              postList: nextList,
              status: PostStatus.isSuccess,
              page: requestPage + 1,
              error: null,
              isOffline: true,
            ),
          );
          return;
        }

        if (accumulatedPosts.isNotEmpty) {
          emit(
            state.copyWith(
              postList: accumulatedPosts,
              status: PostStatus.isLastPage,
              page: requestPage,
              error: 'Offline - no further cached pages',
              isOffline: true,
            ),
          );
          return;
        }

        emit(
          state.copyWith(
            status: PostStatus.failed,
            error: 'No internet connection and no cached posts available',
            isOffline: true,
          ),
        );
        return;
      }

      // Online path: fetch next page from API and cache it.
      final nextStatus = (requestPage == 0 && accumulatedPosts.isEmpty)
          ? PostStatus.isLoading
          : PostStatus.isFetching;

      emit(state.copyWith(status: nextStatus, isOffline: false, error: null));

      final apiPosts = await repo.getPosts(requestPage);
      if (apiPosts.isNotEmpty) {
        await repo.cachePost(apiPosts);
      }

      final merged = requestPage == 0
          ? apiPosts
          : <Post>[...accumulatedPosts, ...apiPosts];
      final nextPage = apiPosts.isNotEmpty ? requestPage + 1 : requestPage;
      final isLastPage = requestPage >= 5 || apiPosts.isEmpty;

      if (apiPosts.isEmpty && accumulatedPosts.isNotEmpty) {
        emit(
          state.copyWith(
            postList: accumulatedPosts,
            status: PostStatus.isLastPage,
            page: nextPage,
            error: 'No more posts available',
            isOffline: false,
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          postList: merged,
          status: isLastPage ? PostStatus.isLastPage : PostStatus.isSuccess,
          page: nextPage,
          error: null,
          isOffline: false,
        ),
      );
    } catch (e) {
      debugPrint("error fetching posts: $e");

      if (!isOnline) {
        final offlineCache = await repo.getCachedPosts(requestPage);
        if (offlineCache.isNotEmpty) {
          final nextList = <Post>[...accumulatedPosts, ...offlineCache];
          emit(
            state.copyWith(
              postList: nextList,
              status: PostStatus.isSuccess,
              error: 'Offline - showing cached posts',
              page: requestPage + 1,
              isOffline: true,
            ),
          );
          return;
        }

        if (accumulatedPosts.isNotEmpty) {
          emit(
            state.copyWith(
              postList: accumulatedPosts,
              status: PostStatus.isLastPage,
              error: 'Offline - partial cached data',
              isOffline: true,
            ),
          );
          return;
        }

        emit(
          state.copyWith(
            status: PostStatus.failed,
            error: e.toString(),
            isOffline: true,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: PostStatus.failed,
            error: e.toString(),
            isOffline: false,
          ),
        );
      }
    }
  }
}
