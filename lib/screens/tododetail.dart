import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:todo_app/model/todo.dart';
import 'package:todo_app/util/dbhelper.dart';
import 'package:intl/intl.dart';

DBHelper helper = DBHelper();
final List<String> choices = const <String>[
  'Save Todo & Back',
  'Delete Todo',
  'Back to List'
];

const mnuSave = 'Save Todo & Back';
const mnuDelete = 'Delete Todo';
const mnuBack = 'Back to List';

class TodoDetail extends StatefulWidget {
  final Todo todo;
  TodoDetail(this.todo);

  @override
  State<StatefulWidget> createState() => TodoDetailState(todo);
}

class TodoDetailState extends State<TodoDetail> {
  Todo todo;
  TodoDetailState(this.todo);
  final _priorities = ["High", "Medium", "Low"];
  TextEditingController titlecontroller = TextEditingController();
  TextEditingController descriptioncontroller = TextEditingController();
  FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  @override
  void initState() {
    var initializationSettingsAndroid = new AndroidInitializationSettings('@mipmap/ic_launcher'); 
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(initializationSettingsAndroid, initializationSettingsIOS);
    _flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    _flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: onSelectNotification);
    super.initState();
  }

  Future onSelectNotification(String payload) async {
    showDialog(
      context: context,
      builder: (_) {
        return new AlertDialog(
          title: Text("PayLoad"),
          content: Text("Payload : $payload"),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    titlecontroller.text = todo.title;
    descriptioncontroller.text = todo.description;
    TextStyle textStyle = Theme.of(context).textTheme.title;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(todo.title),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: select,
            itemBuilder: (BuildContext context) {
              return choices.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 35.0, left: 10.0, right: 10.0),
        child: ListView(
          children: <Widget>[
            Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: TextField(
                    controller: titlecontroller,
                    style: textStyle,
                    onChanged: (value) => this.UpdateTitle(),
                    decoration: InputDecoration(
                        labelStyle: textStyle,
                        labelText: "Title",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        )),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: TextField(
                    controller: descriptioncontroller,
                    style: textStyle,
                    onChanged: (value) => this.UpdateDescription(),
                    decoration: InputDecoration(
                        labelStyle: textStyle,
                        labelText: "Descrition",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        )),
                  ),
                ),
                ListTile(
                  title: DropdownButton<String>(
                    items: _priorities.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    style: textStyle,
                    value: retrievePriority(todo.priority),
                    onChanged: (value) => updatePriority(value),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: [
          BottomNavigationBarItem(
            icon: new Icon(Icons.save),
            title: Text("Save"),
          ),
          BottomNavigationBarItem(
              icon: new Icon(Icons.delete), title: Text("Delte"))
        ],
        onTap: bottomselect,
      ),
    );
  }

  void select(String value) async {
    switch (value) {
      case mnuSave:
        save();
        var sv = Navigator.pop(context, true);
        debugPrint("output from save nav : " + sv.toString());
        break;
      case mnuDelete:
        if (todo.id == null) {
          return;
        }
        showDialog(context: context, builder: (_) => dialogConfirm());
        break;
      case mnuBack:
        Navigator.pop(context, true);
        break;
      default:
    }
  }

  AlertDialog dialogConfirm() {
    TextStyle textStyle = Theme.of(context).textTheme.title;
    AlertDialog alertDialog = AlertDialog(
      title: Text("Delete Todo"),
      content: Text("Your current task is going to deleted."),
      actions: <Widget>[
        RaisedButton(
          child: Text(
            "Yes",
            style: textStyle,
          ),
          elevation: 2.0,
          color: Theme.of(context).primaryColorDark,
          onPressed: () {
            delete();
            Navigator.pop(context, true);
            Navigator.pop(context, true);
          },
        )
      ],
    );
    return alertDialog;
  }

  void bottomselect(int i) async {
    switch (i) {
      case 0:
        save();
        Navigator.pop(context, true);
        break;
      case 1:
        if (todo.id == null) {
          return;
        }
        showDialog(context: context, builder: (_) => dialogConfirm());
        break;
      default:
    }
  }

  void save() {
    todo.date = DateFormat.yMd().format(DateTime.now());
    if (todo.id != null) {
      helper.updateTodo(todo);
    } else {
      if (saveHelper(todo)) {
        helper.insertTodo(todo);
      }
    }

    var androidChannelSpecifics = new AndroidNotificationDetails('channelId', 'channelName', 'channelDescription', importance: Importance.Max, priority: Priority.High);
    var iosChannelSpecifics = new IOSNotificationDetails();

    var channelSpecifics = new NotificationDetails(androidChannelSpecifics, iosChannelSpecifics);

    _flutterLocalNotificationsPlugin.show(0, 'New Post', 'body', channelSpecifics, payload: 'test');
  }

  bool saveHelper(Todo todo) {
    return validator(todo.title) &&
        validator(todo.description) &&
        validator(todo.date) &&
        validator(todo.priority);
  }

  bool validator(var value) {
    return (value != null && value != '');
  }

  Future<int> delete() async {
    return await helper.deleteTodo(todo.id);
  }

  void updatePriority(String value) {
    switch (value) {
      case "High":
        todo.priority = 1;
        break;
      case "Medium":
        todo.priority = 2;
        break;
      case "Low":
        todo.priority = 3;
        break;
    }
    setState(() {
    });
  }

  String retrievePriority(int value) {
    return _priorities[value - 1];
  }

  void UpdateTitle() {
    todo.title = titlecontroller.text;
  }

  void UpdateDescription() {
    todo.description = descriptioncontroller.text;
  }
}
