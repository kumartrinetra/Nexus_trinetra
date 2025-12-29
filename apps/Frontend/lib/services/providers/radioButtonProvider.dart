import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';


import '../../models/taskModel.dart';

class AddTaskScreenController extends StateNotifier<AddTaskScreenState> {
  AddTaskScreenController() : super(AddTaskScreenState(normalTask: TaskModel(title: ""), selectedPriority: "low", tempSubtasks: [], dueDate: DateTime(0), urgencyScore: .5));

  void changePriority(String label) {
    state = state.copyWith(label.toLowerCase(), null, null, null, null);
  }

  void addNewSubtask()
  {
    final newTempSubtask = TempSubtaskModel(title: "", saved: false);
    state = state.copyWith(null, [...state.tempSubtasks, newTempSubtask], null, null, null);
  }

  void saveASubtask(String title, int index)
  {
    List<TempSubtaskModel> myTempSubtaskList = state.tempSubtasks;
    myTempSubtaskList[index].title = title;
    myTempSubtaskList[index].saved = true;
    state = state.copyWith(null, [...myTempSubtaskList], null, null, null);
  }

  void deleteSubtask(int index)
  {
    List<TempSubtaskModel> myTempSubtaskList = state.tempSubtasks;
    myTempSubtaskList.removeAt(index);
    state = state.copyWith(null, [...myTempSubtaskList], null, null, null);
  }

  void editTask(int index)
  {
    List<TempSubtaskModel> myTempSubtaskList = state.tempSubtasks;
    myTempSubtaskList[index].saved = false;
    state = state.copyWith(null, [...myTempSubtaskList], null, null, null);
  }



  Future<void> selectDate(BuildContext context) async
  {
    final DateTime? picked = await showDatePicker(context: context, firstDate: DateTime.now(), lastDate: DateTime(2030));
    if(picked != null && picked != DateTime.now())
      {

        state = state.copyWith(null, null, null, picked, null);
      }
  }

  void changeUrgencyScore(double urgencyScore)
  {
    state = state.copyWith(null, null, null, null, urgencyScore);
  }


}

class TempSubtaskModel {
  String title;
  bool saved;

  TempSubtaskModel({required this.title, required this.saved});
}

class AddTaskScreenState {
  final String selectedPriority;
  final List<TempSubtaskModel> tempSubtasks;
  final TaskModel normalTask;
  final DateTime dueDate;
  final double urgencyScore;

  AddTaskScreenState({
    required this.normalTask,
    required this.selectedPriority,
    required this.tempSubtasks,
    required this.dueDate,
    required this.urgencyScore
  });

  AddTaskScreenState copyWith(
    String? selectedPriority,
    List<TempSubtaskModel>? tempSubtasks,
    TaskModel? normalTask,
      DateTime? dueDate,
      double? urgencyScore
  ) {
    return AddTaskScreenState(
      normalTask: normalTask ?? this.normalTask,
      selectedPriority: selectedPriority ?? this.selectedPriority,
      tempSubtasks: tempSubtasks ?? this.tempSubtasks,
      dueDate: dueDate ?? this.dueDate,
      urgencyScore: urgencyScore ?? this.urgencyScore
    );
  }
}

final addTaskScreenSateProvider =
    StateNotifierProvider<AddTaskScreenController, AddTaskScreenState>((ref) {
      return AddTaskScreenController();
    });
