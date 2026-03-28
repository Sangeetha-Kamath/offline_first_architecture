import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:practice_flutter_coding/posts/data/model/repository/post_data_source.dart';
import 'package:practice_flutter_coding/posts/data/model/repository/post_repository_impl.dart';
import 'package:practice_flutter_coding/posts/presentation/view/post_list_screen.dart';
import 'package:practice_flutter_coding/posts/presentation/bloc/post_bloc.dart';
import 'package:practice_flutter_coding/service/db_helper.dart';
import 'package:practice_flutter_coding/service/dio_service.dart';
import 'package:practice_flutter_coding/service/connectivity_service.dart';

import 'posts/domain/repositories/post_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DioService().initialize();
  await DbHelper.openDB();
  await ConnectivityService().initialize();
  
  runApp(
    MultiBlocProvider(
      providers: [
        RepositoryProvider(create: (context)=>DioService()),
        RepositoryProvider(create: (context) => PostDataSource(dio:context.read<DioService>())),
        RepositoryProvider(create: (context) => DbHelper()),
        
        RepositoryProvider(create: (context) => ConnectivityService()),
        RepositoryProvider<PostRepository>(
          create: (context) => PostRepositoryImpl(
            dataSource: context.read<PostDataSource>(),
            dbHelper: context.read<DbHelper>(),

          ),
        ),
        BlocProvider(
          create: (context) => PostBloc(
            repo: context.read<PostRepository>(),
            connectivityService: context.read<ConnectivityService>(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowMaterialGrid: false,
      showPerformanceOverlay: false,
      debugShowCheckedModeBanner: true,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const PostListScreen(),
    );
  }
}

