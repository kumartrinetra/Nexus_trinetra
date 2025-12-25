

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexus_frontend/models/taskModel.dart';
import 'package:nexus_frontend/services/dioProvider.dart';

class TaskRepository{
  final Dio dio;

  TaskRepository(this.dio);

  Future<List<TaskModel>?> getAllTasks() async
  {
    try{
      final response = await dio.get("/tasks/getalltasks/");

      final data = response.data;

      final allTasks = data["data"]["tasks"];

      List<TaskModel>? myTasks = List<TaskModel>.from(allTasks.map((task) => task.fromJson(task)));

      return myTasks;
    }
        on DioException catch(err)
    {
      print(err.response?.data);
      return null;
    }
  }
}

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository(ref.read(dioProvider));
});