import 'package:flutter/material.dart';
import 'package:pink_fluffy_unicorns/Chat/ChatInput.dart';
import 'package:pink_fluffy_unicorns/Chat/Message.dart';

import '../MessageSender.dart';

class Chat extends StatefulWidget {
  final String chatPartner;
  final MessageSender _messageSender;

  Chat(this.chatPartner, this._messageSender);

  @override
  _ChatState createState() {
    return new _ChatState(chatPartner, _messageSender);
  }
}

class _ChatState extends State<StatefulWidget> {
  final String chatPartner;
  final MessageSender _messageSender;
  late List<Message> messages;
  late final ScrollController _scrollController;
  bool _needsScroll = true;

  _ChatState(this.chatPartner, this._messageSender) {
    messages = [];
    _messageSender.additionCallback = addMessage;

    _scrollController = ScrollController(keepScrollOffset: false);
  }

  void addMessage(Message message) {
    messages.add(message);

    _needsScroll = true;
    this.setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // automatically scroll ListView
    if (_needsScroll) {
      WidgetsBinding.instance!.addPostFrameCallback((_) => _scrollToEnd());
      _needsScroll = false;
    }

    var messageCards = messages.map((message) {
      var insets;
      var totalWidth = MediaQuery.of(context).size.width;
      if (message.isOwn) {
        insets = EdgeInsets.fromLTRB(totalWidth * 0.2, 0, totalWidth * 0.01, 0);
      } else {
        insets = EdgeInsets.fromLTRB(totalWidth * 0.01, 0, totalWidth * 0.2, 0);
      }
      return Padding(child: MessageCard(message), padding: insets);
    }).toList();

    return Scaffold(
        appBar: AppBar(
          title: Text(chatPartner),
        ),
        body: Column(children: [
          Expanded(
              child: ListView(
            controller: _scrollController,
            physics: AlwaysScrollableScrollPhysics(),
            children: messageCards,
            shrinkWrap: true,
          )),
          // Custom input widget
          ChatInput(messageSender: _messageSender)
        ]));
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

}
