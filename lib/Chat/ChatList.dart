import 'package:flutter/material.dart';
import 'package:pink_fluffy_unicorns/QueryService.dart';
import 'package:pink_fluffy_unicorns/pink_fluffy_unicorns_fonts_icons.dart';

import '../ChatService.dart';
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

class _ChatListState extends State<ChatList> with WidgetsBindingObserver {
  late Future<List<User>> usersWithChats;
  final _scrollController = ScrollController(keepScrollOffset: false);
  final TextEditingController _addChatController = TextEditingController();
  final Key _addChatSubmit = Key("_addChatSubmitKey");

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

          if ((snapshot.data!.length) > 0)
            WidgetsBinding.instance!.addPostFrameCallback((_) =>
                _scrollController.animateTo(
                    _scrollController.position.maxScrollExtent,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.fastOutSlowIn));

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
                  controller: _scrollController,
                );
          return new Scaffold(
              appBar: AppBar(
                title: Text("Chats"),
                leading: Builder(builder: (ctx) => Text("")),
              ),
              body: child,
              floatingActionButton: Stack(children: [
                IconButton(
                  onPressed: () {
                    showDialog(context: context, builder: _addRandomChatDialog);
                  },
                  icon: Icon(PinkFluffyUnicornsFonts.random),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
                  child: IconButton(
                    onPressed: () {
                      showDialog(
                          context: context, builder: _buildAddChatDialog);
                    },
                    icon: Icon(Icons.add),
                  ),
                ),
              ]));
        });
  }

  Widget _buildAddChatDialog(BuildContext context) {
    return AlertDialog(
      title: Text("Neuen Chat eröffnen"),
      content: Row(children: [
        Padding(
            padding: EdgeInsets.fromLTRB(0.0, 0.0, 8.0, 0.0),
            child: Text("E-Mail:")),
        Expanded(
            child: TextField(
          controller: _addChatController,
        )),
      ]),
      actions: [
        TextButton(
            onPressed: Navigator.of(context).pop, child: Text("Abbrechen")),
        TextButton(
            key: _addChatSubmit,
            onPressed: () {
              _addChat(context);
            },
            child: Text("Chat eröffnen")),
      ],
    );
  }

  Future<bool> _addChat(BuildContext context) async {
    User user;
    try {
      user = await QueryService.getUserInfo(_addChatController.text);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text("Dieser Nutzer ist nicht registriert." + error.toString())));
      Navigator.pop(context);
      return false;
    }

    _addChatInternal(user);
    return true;
  }

  void _addChatInternal(User user) async {
    (await usersWithChats).add(user);
    var scroll = (await usersWithChats).length > 1;

    setState(() {
      if (scroll) _addChatController.clear();
      Navigator.popAndPushNamed(context, ExtractArgumentsChatScreen.routeName,
          arguments: ChatScreenArguments(user));
    });

    ChatService.writeAllChatPartners(usersWithChats);
    _addChatController.clear();
  }

  Widget _addRandomChatDialog(BuildContext context) {
    return AlertDialog(
      title: Text("Zufälligen Chat Starten"),
      actions: [
        TextButton(
            onPressed: Navigator.of(context).pop, child: Text("Abbrechen"))
      ],
    );
  }

  Future<void> _addRandomChat() async {
    User user;
    try {
      user = await QueryService.getRandomUserSuggestion();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Der Server hat die Anfrage abgelehnt.")));
      Navigator.pop(context);
      return;
    }

    _addChatInternal(user);
    return;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  /// This should theoretically call writeAllChatPartners when the App is closed
  /// but it appears to be bugged so it doesn't so it will be done at _addChatInternal
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        {
          ChatService.writeAllChatPartners(usersWithChats);
        }
        break;
      case AppLifecycleState.resumed:
        // TODO: Maybe fetch updates from Server?
        break;
    }
  }
}

class ChatScreenArguments {
  final User chatPartner;

  ChatScreenArguments(this.chatPartner);
}

// A Widget that extracts the necessary arguments from
// the ModalRoute.
class ExtractArgumentsChatScreen extends StatelessWidget {
  static const routeName = '/Chat/fromUser';

  @override
  Widget build(BuildContext context) {
    // Extract the arguments from the current ModalRoute
    // settings and cast them as ScreenArguments.
    final ChatScreenArguments args =
        ModalRoute.of(context)!.settings.arguments as ChatScreenArguments;

    return Chat(args.chatPartner);
  }
}
