import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';

import '../MessageSender.dart';

@JsonSerializable()
class Message {
  final String textContent;
  late final DateTime dateTimeSent;
  late final int id;

  late final bool isOwn;
  final String sender;
  MessageStatus status = MessageStatus.Pending;

  Message({required this.textContent, required this.sender}) {
    id = Random().nextInt(1 << 31);
    isOwn = ChatService.ownEMail() == sender;
    dateTimeSent = DateTime.now();
  }

  Message.fromData(
      {required this.textContent,
      required this.sender,
      required this.dateTimeSent,
      required this.id,
      MessageStatus? status}) {
    isOwn = sender == ChatService.ownEMail();
    this.status = status ?? this.status;
  }

  factory Message.fromJson(Map<String, dynamic> json) => Message.fromData(
      textContent: json["textContent"] as String,
      sender: json["sender"] as String,
      dateTimeSent: DateTime.parse(json["sent"] as String),
      id: json["id"] as int,
      status: MessageStatus.values[json["status"]]);
  Map<String, dynamic> toJson() => {
        "textContent": textContent,
        "sender": sender,
        "sent": dateTimeSent.toIso8601String(),
        "id": id,
        "status": status.index
      };
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
                Icon(icon, size: message.isOwn ? 10.0 : 0.0),
              ])),
        ],
        mainAxisSize: MainAxisSize.min,
      ),
      color: color,
    );
  }
}
