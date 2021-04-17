import 'package:flutter/material.dart';
import 'package:pink_fluffy_unicorns/Chat/ChatAppBar.dart';
import 'package:pink_fluffy_unicorns/Chat/ChatInput.dart';
import 'package:pink_fluffy_unicorns/Chat/Message.dart';

import '../MessageSender.dart';
import '../User.dart';

class Chat extends StatefulWidget {
  static const String routeName = "/Chat";
  final User chatPartner;

  Chat(this.chatPartner);

  @override
  _ChatState createState() {
    return new _ChatState(chatPartner);
  }
}

class _ChatState extends State<StatefulWidget> {
  final User chatPartner;
  late final ChatService _chatService;
  late Future<List<Message>> messages;
  late final ScrollController _scrollController;
  bool _userInfoOpened = false;

  _ChatState(this.chatPartner) {
    _chatService = ChatService(user: chatPartner, additionCallback: addMessage);
    messages = _chatService.readChat();

    _scrollController = ScrollController(keepScrollOffset: false);
  }

  void addMessage(Message message) async {
    //this._needsScroll = true;

    (await messages).add(message);
    this.setState(() {
      _scrollToEnd();
    });
    _chatService
        .sendMessage(message)
        .then((value) => message.status = value)
        .then((_) => this.setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    /*/ automatically scroll ListView
    if (_needsScroll) {
      WidgetsBinding.instance!.addPostFrameCallback((_) => _scrollToEnd());
      _needsScroll = false;
    }
     */

    return Scaffold(
        appBar: ChatAppBar(
          onTapCallback: toggleUserInfo,
          onPopCallback: dispose,
          chatPartner: chatPartner,
          isExpanded: _userInfoOpened,
        ),
        body: FutureBuilder(
            future: messages,
            builder: (ctx, AsyncSnapshot<List<Message>> snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data!.isNotEmpty)
                  WidgetsBinding.instance!
                      .addPostFrameCallback((_) => _scrollToEnd());

                return Column(children: [
                  Expanded(
                      child: ListView(
                    controller: _scrollController,
                    physics: AlwaysScrollableScrollPhysics(),
                    children: snapshot.data!.map((message) {
                      var insets;
                      var totalWidth = MediaQuery.of(context).size.width;
                      if (message.isOwn) {
                        insets = EdgeInsets.fromLTRB(
                            totalWidth * 0.2, 0, totalWidth * 0.01, 0);
                      } else {
                        insets = EdgeInsets.fromLTRB(
                            totalWidth * 0.01, 0, totalWidth * 0.2, 0);
                      }
                      return Padding(
                          child: MessageCard(message), padding: insets);
                    }).toList(),
                    shrinkWrap: true,
                  )),
                  // Custom input widget
                  ChatInput(messageSender: _chatService)
                ]);
              }
              // if the future hasn't computed yet
              return snapshot.hasError
                  ? Center(child: Text("Error"))
                  : Center(child: CircularProgressIndicator());
            }));
  }

  _scrollToEnd() {
    _scrollController.animateTo(_scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 200), curve: Curves.easeInOut);
  }

  void toggleUserInfo() {
    _userInfoOpened = !_userInfoOpened;
    setState(() {});
  }

  // cleanup tasks and serialization
  // for some reason this gets called twice but I have no clue why.
  // It throws an error but it's caught so.... alright I guess?
  void dispose() {
    _chatService.writeChat(messages);
    super.dispose();
  }
}
