import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../MessageSender.dart';
import 'Message.dart';

class ChatInput extends StatefulWidget {
  final MessageSender messageSender;

  const ChatInput({Key? key, required this.messageSender}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ChatInputState(this.messageSender);
  }
}

class _ChatInputState extends State<ChatInput> {
  final textFieldValueHolder = TextEditingController();
  final MessageSender messageSender;

  String result = '';

  _ChatInputState(this.messageSender);

  @override
  Widget build(BuildContext context) {
    return Padding(
      child: Row(
        children: [
          Expanded(
            child: TextField(
                controller: textFieldValueHolder,
                autocorrect: true,
                decoration: InputDecoration(
                    border: InputBorder.none, hintText: 'Enter a Message'),
                onSubmitted: (_) {
                  sendTextMessage();
                }),
          ),
          ElevatedButton(
            onPressed: sendTextMessage,
            child: Icon(Icons.message),
          ),
        ],
      ),
      padding: EdgeInsets.all(5.0),
    );
  }

  void sendTextMessage() async {
    result = textFieldValueHolder.text.trim();
    textFieldValueHolder.clear();
    var sendSuccessful;
    Message message, pingpongMessage;

    if (result.isNotEmpty) {
      message = Message(result, true);
      sendSuccessful = messageSender.sendMessage(message);

      pingpongMessage = Message(result, false);
    } else {
      return;
    }

    messageSender.additionCallback(message);
    messageSender.additionCallback(pingpongMessage);

    if (await sendSuccessful) {
      message.status = MessageStatus.Successful;
    } else {
      message.status = MessageStatus.Failed;
    }
  }
}
