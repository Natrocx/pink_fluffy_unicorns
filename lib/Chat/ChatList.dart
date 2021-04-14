import 'package:flutter/material.dart';

import '../MessageSender.dart';
import '../User.dart';
import 'Chat.dart';

class ChatList extends StatefulWidget {
  static const String routeName = "/ChatList";
  const ChatList({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ChatListState();
  }
}

class _ChatListState extends State<ChatList> {
  late Future<List<User>> usersWithChats;

  _ChatListState() {
    usersWithChats = ChatService.readAllChatPartners();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: usersWithChats,
        builder: (context, AsyncSnapshot<List<User>> snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          var usersWithChats = snapshot.data ?? [];
          var child = usersWithChats.isEmpty
              ? Center(child: Text("Sie haben noch keine Chats."))
              : ListView(
                  children: usersWithChats
                      .map((user) => GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Chat(user)),
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
            appBar: AppBar(
              title: Text("Chats"),
              leading: Builder(builder: (ctx) => Text("")),
            ),
            body: child,
            floatingActionButton: IconButton(
              onPressed: addChat,
              icon: Icon(Icons.add),
            ),
          );
        });
  }

  Future<void> addChat() async {
    (await usersWithChats)
        .add(User("s200297@student.dhbw-mannheim.de", "Jonas Lauschke", 0));
    setState(() {});
  }
}

class ChatListScreenArguments {
  final String chatPartner;

  ChatListScreenArguments(this.chatPartner);
}

// A Widget that extracts the necessary arguments from
// the ModalRoute.
class ExtractArgumentsChatListScreen extends StatelessWidget {
  static const routeName = '/ChatList/args';

  @override
  Widget build(BuildContext context) {
    // Extract the arguments from the current ModalRoute
    // settings and cast them as ScreenArguments.
    final ChatListScreenArguments args =
        ModalRoute.of(context)!.settings.arguments as ChatListScreenArguments;

    return ChatList();
  }
}
