

import 'package:flutter_riverpod/legacy.dart';
import 'package:nexus_frontend/models/taskModel.dart';
import 'package:nexus_frontend/repository/taskRepository.dart';

class TaskController extends StateNotifier<List<TaskModel>?>{
  TaskRepository taskRepository;

  TaskController(this.taskRepository) : super([]);

  Future<void> getAllTasks() async
  {
    state = await taskRepository.getAllTasks();
  }




}

final taskControllerProvider = StateNotifierProvider<TaskController, List<TaskModel>?>((ref) {
  return TaskController(ref.read(taskRepositoryProvider));
});