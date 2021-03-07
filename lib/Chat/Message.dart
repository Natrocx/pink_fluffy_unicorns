import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Message {
  late final MessageType? messageType;
  final String textContent;
  late final DateTime dateTimeSent;

  final bool isOwn;
  MessageStatus status = MessageStatus.Pending;

  Message(
      {required this.textContent,
      required this.isOwn,
      this.messageType = MessageType.Text,
      required this.dateTimeSent});
}

enum MessageType {
  Text,
}

enum MessageStatus { Pending, Failed, Successful }

class MessageCard extends StatelessWidget {
  final Message message;

  MessageCard(this.message);

  @override
  Widget build(BuildContext context) {
    var color;
    if (!message.isOwn) {
      color = Colors.red[300];
    }
    return Card(
      child: Column(
        children: [
          Container(
            child: Padding(
                padding: EdgeInsets.all(8.0), child: Text(message.textContent)),
            alignment: Alignment.centerRight,
          ),
          Container(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.all(2.0),
                child: Text(
                    DateFormat("dd.MM.yyyy hh:mm")
                        .format(message.dateTimeSent.toLocal()),
                    style: TextStyle(fontSize: 8)),
              )),
        ],
        mainAxisSize: MainAxisSize.min,
      ),
      color: color,
    );
  }
}
