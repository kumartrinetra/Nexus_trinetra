import 'package:flutter/material.dart';
import 'package:nexus_frontend/widgets/sliverAppBar.dart';

class TaskView extends StatefulWidget {
  const TaskView({super.key});

  @override
  State<TaskView> createState() => _TaskViewState();
}

class _TaskViewState extends State<TaskView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff8f9fa),
      body: CustomScrollView(
        slivers: [
          myAppBar("Tasks", "All Tasks & Categories", "assets/images/loginIcon.png"),


        ],
      ),
    );
  }
}



