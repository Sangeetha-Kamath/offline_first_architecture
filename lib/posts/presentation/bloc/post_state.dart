
import 'package:equatable/equatable.dart';

import '../../domain/entities/post.dart';
enum PostStatus{
  initial,
  isLoading,
  isFetching,
  isLastPage,
  isSuccess,
  failed
}
class PostState extends Equatable{
  final List<Post>? postList;
  final PostStatus? status;
  final String? error;
  final int? page;
  final bool isOffline;
  
  const PostState({
    this.postList,
    this.page,
    this.status,
    this.error,
    this.isOffline = false
  });
  
  factory PostState.initial() => PostState(
    postList: [],
    page: 0,
    status: PostStatus.initial,
    error: "",
    isOffline: false
  );

  
  @override
  List<Object?> get props => [
    postList,
    page,
    status,
    isOffline
  ];

  PostState copyWith({
    final List<Post>? postList,
    final PostStatus? status,
    final String? error,
    final int? page,
    final bool? isOffline
  }) {
    return PostState(
      postList: postList ?? this.postList,
      page: page ?? this.page,
      status: status ?? this.status,
      error: error ?? this.error,
      isOffline: isOffline ?? this.isOffline
    );
  }
}