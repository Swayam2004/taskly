import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:taskly/models/task.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  late double _deviceHeight, _deviceWidth;

  String? _newTaskContent;

  Box? _box;

  _HomePageState();

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        toolbarHeight: _deviceHeight * 0.15,
        title: const Text(
          "Taskly!",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 35,
          ),
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 69, 64, 64),
      body: _taskView(),
      floatingActionButton: _addTaskButton(),
    );
  }

  Widget _taskView() {
    return FutureBuilder(
      future: Hive.openBox("tasks"),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          _box = snapshot.data;
          return _taskList();
        } else {
          return const Center(
              child: CircularProgressIndicator(
            backgroundColor: Colors.grey,
            color: Colors.yellowAccent,
          ));
        }
      },
    );
  }

  Widget _taskList() {
    List tasks = _box!.values.toList();

    // Task task = Task(
    //   content: "Hello, Let's see if this is working or not",
    //   timestamp: DateTime.now(),
    //   isDone: false,
    // );

    // _box?.add(task.toMap());

    // return ListView(
    //   children: [
    //     ListTile(
    //       tileColor: const Color.fromARGB(255, 0, 228, 118),
    //       title: const Text(
    //         "Do Homework!",
    //         style: TextStyle(
    //           decoration: TextDecoration.lineThrough,
    //         ),
    //       ),
    //       subtitle: Text(
    //         DateTime.now().toString(),
    //       ),
    //       trailing: const Icon(
    //         Icons.check_box_outlined,
    //         color: Color.fromARGB(255, 47, 125, 49),
    //       ),
    //     ),
    //   ],
    // );

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (BuildContext context, int index) {
        Task currentTask = Task.fromMap(tasks[index]);

        return ListTile(
          tileColor: currentTask.isDone
              ? const Color.fromARGB(255, 0, 228, 118)
              : const Color.fromARGB(255, 229, 61, 31),
          title: Text(
            currentTask.content,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              decoration:
                  currentTask.isDone ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Text(
            currentTask.timestamp.toString(),
          ),
          trailing: Icon(
            currentTask.isDone
                ? Icons.check_box_outlined
                : Icons.check_box_outline_blank,
            color: currentTask.isDone
                ? const Color.fromARGB(255, 47, 125, 49)
                : const Color.fromARGB(255, 167, 33, 23),
          ),
          onTap: () {
            currentTask.isDone = !currentTask.isDone;

            _box?.putAt(index, currentTask.toMap());

            setState(() {});
          },
          onLongPress: () {
            _box?.deleteAt(index);

            setState(() {});
          },
        );
      },
    );
  }

  Widget _addTaskButton() {
    return FloatingActionButton(
      onPressed: _taskDisplayPopup,
      backgroundColor: Colors.blue,
      child: const Icon(
        Icons.add_task,
        color: Colors.white,
      ),
    );
  }

  void _taskDisplayPopup() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Add new Task!"),
            titleTextStyle: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 25,
            ),
            contentTextStyle: const TextStyle(
              fontSize: 20,
            ),
            backgroundColor: Colors.white70,
            shadowColor: Colors.black,
            surfaceTintColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            content: TextField(
              onSubmitted: (_) {
                if (_newTaskContent != null) {
                  Task task = Task(
                    content: _newTaskContent!,
                    timestamp: DateTime.now(),
                    isDone: false,
                  );

                  _box?.add(task.toMap());

                  setState(() {
                    _newTaskContent = null;

                    Navigator.pop(context);
                  });
                }
              },
              onChanged: (value) {
                setState(() {
                  _newTaskContent = value;
                });
              },
            ),
          );
        });
  }
}
