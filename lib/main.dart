import 'package:flutter/material.dart';
import 'package:todo_app/model/todo.dart';
import 'package:todo_app/screens/tododetail.dart';
import 'package:todo_app/screens/todolist.dart';
import 'package:quick_actions/quick_actions.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
     //DBHelper helper = DBHelper();
     //List<Todo> todos = List<Todo>();
     //helper.initializeDb().then((result) => helper.getTodos().then((result) => todos = result));

    // DateTime today = DateTime.now();
    // Todo todo =
    //     Todo("Buy Apples", today.toString(), 1, "And make sure they are good");
    // helper.insertTodo(todo);
    //helper.deleteEntireTodo();
    return new MaterialApp(
      title: 'Todos',
      theme: new ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: new MyHomePage(title: 'Todo Tasks'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  void initState() {
    super.initState();

    final QuickActions quickActions = new QuickActions();
    quickActions.initialize((shortcutType) {
      if (shortcutType == 'action_main')
      {
        navigateToDetail(new Todo('', 3, '_date'));
      }
    });

    quickActions.setShortcutItems(<ShortcutItem>[
      const ShortcutItem(type: 'action_main', localizedTitle: 'Create Todo', icon: 'create'),
    ]);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: Text(
          widget.title
        ),
      ),
      body: TodoList(),
    );
  }

  void navigateToDetail(Todo todo) async {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TodoDetail(todo),
        ));
  }
}
