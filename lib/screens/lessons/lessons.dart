import 'package:flutter/material.dart';
import 'package:student_project_bitirme_flutter/authentication/core/auth_manager.dart';

import 'package:student_project_bitirme_flutter/screens/lessons/lesson.dart';
import 'package:student_project_bitirme_flutter/screens/lessons/lesson_actions/lesson_create.dart';
import 'dart:convert';
import '../../models/lesson.dart';
import '../../apis/lesson_api.dart';

class LessonApp extends StatelessWidget {
  const LessonApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LessonsList(),
    );
  }
}

class LessonsList extends StatefulWidget {
  const LessonsList({Key? key}) : super(key: key);

  @override
  _LessonsListState createState() => _LessonsListState();
}

enum Choice { Create, Delete }

class _LessonsListState extends State<LessonsList> {
  List<Lesson> lessonList = <Lesson>[];
  List<Lesson> lessonNotJoinList = <Lesson>[];
  List student = [];
  List studentId = [];

  bool? userTeacher;
  int? userId;

  bool lessonJoin = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(
            "Tum Dersler",
          ),
          actions: [
            if (userTeacher == true)
              PopupMenuButton<Choice>(
                  onSelected: (Choice choice) {
                    select(choice);
                  },
                  itemBuilder: (context) => <PopupMenuEntry<Choice>>[
                        PopupMenuItem<Choice>(
                          value: Choice.Create,
                          child: Text("Yeni Ders Ekle"),
                        )
                      ])
          ]),
      body: SingleChildScrollView(
        child: lessonJoined(),
      ),
    );
  }

  Widget lessonJoined() {
    getLesson();
    setState(() {
      if (lessonList.isNotEmpty) {
        for (var list in lessonList) {
          for (int i = 0; i < list.students.length; i++) {
            if (list.students[i]['id'] == userId) {
              setState(() {
                lessonJoin = true;
              });
            }
            if (lessonJoin) {
              setState(() {
                lessonNotJoinList.add(list);
                lessonJoin = false;
              });
            }
          }
        }
      }
    });
    if (lessonList.isNotEmpty && lessonNotJoinList.isNotEmpty) {
      for (var list in lessonNotJoinList) lessonList.remove(list);
    }

    return Column(
      children: [
        for (var list in lessonList)
          Card(
            child: ListTile(
              leading: const FlutterLogo(),
              title: Text(list.name + " " + list.id.toString()),
              subtitle: Text(list.description ?? ''),
              trailing: TextButton(
                onPressed: () {
                  lessonUserList(list.id);
                },
                style: TextButton.styleFrom(backgroundColor: Colors.green),
                child: Text(
                  "Kayit Ol",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              // onTap: () {
              //   goToDetail(list);
              // },
            ),
          )
      ],
    );
  }

  lessonUserList(int lessonId) {
    for (var list1 in lessonList) {
      if (list1.id == lessonId) {
        for (var list2 in list1.students) {
          student.add(list2);
        }
      }
    }
    for (var listId in student) {
      studentId.add(listId["id"]);
    }
    setState(() {
      studentId.add(userId);
      LessonApi.putLessonJoin(lessonId, studentId);
    });
  }

  getLesson() {
    LessonApi.getLesson().then((response) {
      setState(() {
        Iterable list = json.decode(response.body);
        lessonList = list.map((lesson) => Lesson.fromJson(lesson)).toList();
      });
    });
  }

  getUserTeacher() async {
    AuthenticationManager authManager = AuthenticationManager(context: context);
    Future<bool?> isStaff = authManager.fetchUserIsStaff();
    userTeacher = await isStaff;
  }

  getUserId() async {
    AuthenticationManager authManager = AuthenticationManager(context: context);
    Future<int?> id = authManager.fetchUserId();
    userId = await id;
  }

  @override
  void initState() {
    getLesson();
    lessonJoined();
    getUserTeacher();
    getUserId();

    super.initState();
  }

  void goToDetail(Lesson lesson) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => LessonDetail(lesson, userTeacher!)));
  }

  void select(Choice choice) async {
    switch (choice) {
      case Choice.Create:
        await Navigator.push(
            context, MaterialPageRoute(builder: (context) => LessonCreate()));

        break;
      case Choice.Delete:
        // TODO: Handle this case.
        break;
    }
  }
}
