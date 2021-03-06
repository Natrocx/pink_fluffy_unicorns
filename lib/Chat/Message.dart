import 'package:flutter/material.dart';

class Message {
  late final MessageType? messageType;
  final String textContent;

  final bool isOwn;
  MessageStatus status = MessageStatus.Pending;

  Message(this.textContent, this.isOwn) {
    messageType = MessageType.Text;
  }
}

enum MessageType {
  Text,
}

enum MessageStatus {
  Pending,
  Failed,
  Successful
}

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
      child: Padding(
          padding: EdgeInsets.all(8.0), child: Text(message.textContent)),
      color: color,
    );
  }
}
