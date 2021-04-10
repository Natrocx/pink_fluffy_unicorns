import 'package:flutter/material.dart';

import '../User.dart';
import 'Chat.dart';

class ChatList extends StatefulWidget {
  final List<User>? usersWithChats;

  const ChatList({Key? key, required this.usersWithChats}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ChatListState(usersWithChats ?? []);
  }
}

class _ChatListState extends State<ChatList> {
  List<User> usersWithChats;

  _ChatListState(this.usersWithChats);

  @override
  Widget build(BuildContext context) {
    var child = usersWithChats.isEmpty
        ? Center(child: Text("Sie haben noch keine Chats."))
        : ListView(
            children: usersWithChats
                .map((user) => GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Chat(user)),
                      );
                    },
                    child: Center(
                        child: Padding(
                            padding: EdgeInsets.all(15),
                            child: Text(user.displayName)))))
                .toList(),
            shrinkWrap: true,
            reverse: true,
          );
    return new Scaffold(
      appBar: AppBar(title: Text("Chats")),
      body: child,
      floatingActionButton: IconButton(
        onPressed: addChat,
        icon: Icon(Icons.add),
      ),
    );
  }

  void addChat() {
    usersWithChats
        .add(User("s200297@student.dhbw-mannheim.de", "Jonas Lauschke", 0));
    setState(() {});
  }
}
