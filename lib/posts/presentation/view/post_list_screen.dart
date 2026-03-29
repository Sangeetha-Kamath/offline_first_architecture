import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:practice_flutter_coding/posts/presentation/bloc/post_bloc.dart';
import 'package:practice_flutter_coding/posts/presentation/bloc/post_event.dart';

import '../bloc/post_state.dart';

class PostListScreen extends StatelessWidget {
  const PostListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final postBloc = context.read<PostBloc>();
    if (postBloc.state.status == PostStatus.initial) {
      postBloc.add(const GetPostEvent());
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Post List')),
      body: Column(
        children: [
          BlocBuilder<PostBloc, PostState>(
            buildWhen: (previous, current) =>
                previous.isOffline != current.isOffline,
            builder: (context, state) {
              if (state.isOffline) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 16,
                  ),
                  color: Colors.orange[700],
                  child: Row(
                    children: [
                      const Icon(Icons.cloud_off, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Offline - ${state.error ?? "Showing cached posts"}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification.metrics.pixels ==
                        notification.metrics.maxScrollExtent &&
                    postBloc.state.status != PostStatus.isLoading &&
                    postBloc.state.status != PostStatus.isFetching &&
                    !postBloc.state.isOffline) {
                  postBloc.add(GetPostEvent());
                }
                return true;
              },
              child: BlocConsumer<PostBloc, PostState>(
                listener: (context, state) {
                  if (state.status == PostStatus.initial) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("post list initial state")),
                    );
                  }
                },
                builder: (context, state) {
                  if (state.status == PostStatus.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state.postList!.isEmpty &&
                      state.status != PostStatus.isLoading &&
                      state.status != PostStatus.isFetching) {
                    return const Center(child: Text("No items found"));
                  }

                  final list = state.postList ?? <dynamic>[];
                  final showingBottomLoading =
                      state.status == PostStatus.isFetching;
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    itemCount: list.length + (showingBottomLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == list.length && showingBottomLoading) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                              ),
                            ),
                          ),
                        );
                      }

                      final post = list[index] as dynamic;
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        clipBehavior: Clip.hardEdge,
                        child: InkWell(
                          onTap: () {
                            // TODO: handle row tap if needed
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Post #${post.id}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.blueGrey,
                                          ),
                                    ),
                                    Icon(
                                      Icons.article,
                                      color: Colors.blueGrey[300],
                                      size: 18,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  post.title ?? '',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  post.body ?? '',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
