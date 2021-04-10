import 'package:flutter/material.dart';
import 'package:pink_fluffy_unicorns/Chat/ChatAppBar.dart';
import 'package:pink_fluffy_unicorns/Chat/ChatInput.dart';
import 'package:pink_fluffy_unicorns/Chat/Message.dart';

import '../MessageSender.dart';
import '../User.dart';

class Chat extends StatefulWidget {
  final User chatPartner;
  final ChatService _messageSender;

  Chat(this.chatPartner, this._messageSender);

  @override
  _ChatState createState() {
    return new _ChatState(chatPartner, _messageSender);
  }
}

class _ChatState extends State<StatefulWidget> {
  final User chatPartner;
  final ChatService _messageSender;
  late Future<List<Message>> messages;
  late final ScrollController _scrollController;
  bool _needsScroll = false;
  bool _userInfoOpened = false;

  _ChatState(this.chatPartner, this._messageSender) {
    messages = ChatService.readChat(chatPartner.email);
    _messageSender.additionCallback = addMessage;

    _scrollController = ScrollController(keepScrollOffset: false);
  }

  void addMessage(Message message) async {
    this._needsScroll = true;
    (await messages).add(message);
    this.setState(() {});
    _messageSender
        .sendMessage(message)
        .then((value) => message.status = value)
        .then((_) => this.setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    // automatically scroll ListView
    if (_needsScroll) {
      WidgetsBinding.instance!.addPostFrameCallback((_) => _scrollToEnd());
      _needsScroll = false;
    }

    return Scaffold(
        appBar: ChatAppBar(
          onTapCallback: toggleUserInfo,
          chatPartner: chatPartner,
          isExpanded: _userInfoOpened,
        ),
        body: FutureBuilder(
            future: messages,
            builder: (ctx, AsyncSnapshot<List<Message>> snapshot) =>
                snapshot.hasData
                    ? Column(children: [
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
                        ChatInput(messageSender: _messageSender)
                      ])
                    // if the future hasn't computed yet
                    : CircularProgressIndicator()));
  }

  _scrollToEnd() {
    _scrollController.animateTo(_scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 200), curve: Curves.easeInOut);
  }

/*
  void _addMessageCard(Message message) {
    var insets;
    var totalWidth = MediaQuery.of(context).size.width;
    if (message.isOwn) {
      insets = EdgeInsets.fromLTRB(totalWidth * 0.2, 0, totalWidth * 0.01, 0);
    } else {
      insets = EdgeInsets.fromLTRB(
          totalWidth * 0.01, 0, totalWidth * 0.2, 0);
    }

    this
        ._messageCards
        .add(Padding(child: MessageCard(message), padding: insets));
  }
  */

  void toggleUserInfo() {
    _userInfoOpened = !_userInfoOpened;
    setState(() {});
  }
}
