import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../MessageSender.dart';
import 'Message.dart';

class ChatInput extends StatefulWidget {
  final ChatService messageSender;

  const ChatInput({Key? key, required this.messageSender}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ChatInputState(this.messageSender);
  }
}

class _ChatInputState extends State<ChatInput> {
  final textFieldValueHolder = TextEditingController();
  final ChatService messageSender;

  String result = '';

  _ChatInputState(this.messageSender);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.black38,
        child: Padding(
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
        ));
  }

  void sendTextMessage() async {
    result = textFieldValueHolder.text.trim();
    textFieldValueHolder.clear();
    Future<MessageStatus> sendSuccessful;
    Message message, pingpongMessage;

    if (result.isNotEmpty) {
      message = Message(textContent: result, isOwn: true);
      messageSender.sendMessage(message);

      pingpongMessage = Message(textContent: result, isOwn: false);
    } else {
      return;
    }

    messageSender.additionCallback(message);
    messageSender.additionCallback(pingpongMessage);

    // the message status is updated by messageSender.sendMessage
  }
}
