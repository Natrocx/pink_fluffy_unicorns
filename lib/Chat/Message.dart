import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Message {
  final String textContent;
  late final DateTime dateTimeSent;
  late final int id;

  final bool isOwn;
  MessageStatus status = MessageStatus.Pending;

  Message({required this.textContent, required this.isOwn}) {
    id = Random().nextInt(0xffffffff);
    dateTimeSent = DateTime.now();
  }

  Message.fromData(
      {required this.textContent,
      required this.isOwn,
      required this.dateTimeSent,
      required this.id});
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
    IconData icon;
    switch (message.status) {
      case MessageStatus.Pending:
        {
          icon = Icons.access_time_sharp;
        }
        break;
      case MessageStatus.Successful:
        {
          icon = Icons.check;
        }
        break;
      case MessageStatus.Failed:
        {
          icon = Icons.error;
        }
    }
    return Card(
      child: Column(
        children: [
          Container(
            child: Padding(
                padding: EdgeInsets.all(8.0), child: Text(message.textContent)),
            alignment: Alignment.centerRight,
          ),
          Padding(
              padding: EdgeInsets.all(2.0),
              child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Text(
                    DateFormat("dd.MM.yyyy hh:mm")
                        .format(message.dateTimeSent.toLocal()),
                    style: TextStyle(fontSize: 8)),
                Icon(icon, size: 10.0),
              ])),
        ],
        mainAxisSize: MainAxisSize.min,
      ),
      color: color,
    );
  }
}
