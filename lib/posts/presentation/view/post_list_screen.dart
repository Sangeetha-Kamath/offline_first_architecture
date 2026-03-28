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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (postBloc.state.status == PostStatus.initial) {
        postBloc.add(GetPostEvent());
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Post List"),
      ),
      body: Column(
        children: [
          BlocBuilder<PostBloc, PostState>(
            buildWhen: (previous, current) => previous.isOffline != current.isOffline,
            builder: (context, state) {
              if (state.isOffline) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
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

                  return ListView.builder(
                    itemCount: state.postList?.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          const SizedBox(height: 30),
                          Text(state.postList![index].id.toString()),
                          Text(state.postList![index].title ?? "")
                        ],
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