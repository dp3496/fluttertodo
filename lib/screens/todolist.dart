import 'package:flutter/material.dart';
import 'package:todo_app/util/dbhelper.dart';
import 'package:todo_app/model/todo.dart';
import 'package:todo_app/screens/tododetail.dart';

class TodoList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => PageViewApp();
}

class PageViewApp extends State {
  static PageController _pagecontroller = new PageController(
    initialPage: 1
  );
  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pagecontroller,
      children: <Widget>[
        ListView(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(5.0),
              child: Text("Hello page"),
            )
          ],
        ),
        PageViewState()
      ],
    );
  }
}

class PageViewState extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => TodoListState();
}

class TodoListState extends State {
  DBHelper helper = DBHelper();
  List<Todo> todos;
  int count = 0;

  @override
  Widget build(BuildContext context) {
    if (todos == null) {
      todos = List<Todo>();
      getData();
    }
    return Scaffold(
      body: todoListItems(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navigateToDetail(new Todo('', 3, ''));
        },
        tooltip: "Add new Todo App",
        child: Icon(Icons.add),
      ),
    );
  }

  ListView todoListItems() {
    return ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext context, int position) {
        return Card(
          color: Colors.white,
          elevation: 2.0,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: getColor(this.todos[position].priority),
              child: Text(this.todos[position].title[0].toUpperCase()),
            ),
            title: Text(this.todos[position].title),
            subtitle: Text(this.todos[position].date),
            onTap: () {
              debugPrint("Tapped on" + this.todos[position].id.toString());
              navigateToDetail(this.todos[position]);
            },
          ),
        );
      },
    );
  }

  void getData() {
    final dbFuture = helper.initializeDb();
    dbFuture.then((result) {
      final todosFuture = helper.getTodos();
      todosFuture.then((result) {
        List<Todo> todoList = List<Todo>();
        count = result.length;
        for (var i = 0; i < count; i++) {
          todoList.add(Todo.fromObject(result[i]));
          debugPrint(todoList[i].title);
        }
        setState(() {
          todos = todoList;
          count = count;
        });
        debugPrint("Items " + count.toString());
      });
    });
  }

  Color getColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
        break;
      case 2:
        return Colors.orange;
        break;
      case 3:
        return Colors.green;
        break;
      default:
        return Colors.green;
        break;
    }
  }

  void navigateToDetail(Todo todo) async {
    bool result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TodoDetail(todo),
        ));

    if (result == true) {
      getData();
    }
  }
}
