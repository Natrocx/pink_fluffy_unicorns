import 'dart:collection';

import 'package:pink_fluffy_unicorns/User.dart';

import 'Chat/Message.dart';

class ChatService {
  /// Callback do be registered dynamically for adding data to the UI
  late Function(Message) additionCallback;
  static late HashMap<String, List<Message>> chats;
  final User user;

  ChatService({required this.user, Function(Message)? additionCallback}) {
    this.additionCallback =
        additionCallback ?? (_) => throw UnimplementedError();
    chats = HashMap();
  }

  Future<MessageStatus> sendMessage(Message message) async {
    await Future.delayed(Duration(seconds: 4));
    //messages.add(message);
    return MessageStatus.Successful;
  }

  static Future<List<Message>> readChat(String name) async {
    if (chats[name] == null) {
      /*
    var dir = await _dir;
    var _file = await dir
        .list()
        .where((element) => basename(element.path) == name + ".dat")
        .isEmpty;

    var file = File.fromRawPath(utf8.encoder.convert(dir.path + name + ".dat"));
    await file.create();

    chats.putIfAbsent(name, () => temp);
    return temp;
    */
      chats[name] = [];
    }
    return chats[name]!; // can't ever be null but dart does not know
  }
}
