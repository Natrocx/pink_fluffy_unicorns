import 'dart:collection';

import 'package:localstorage/localstorage.dart';
import 'package:pink_fluffy_unicorns/User.dart';

import 'Chat/Message.dart';

class ChatService {
  /// Callback do be registered dynamically for adding data to the UI
  late Function(Message) additionCallback;
  static late HashMap<String, List<Message>> chats = HashMap();
  //late List<Message> messages;
  final User user;
  late final LocalStorage _localStorage;
  static String? _ownEMail;
  static final LocalStorage _ownStorage = LocalStorage("own");

  ChatService({required this.user, required this.additionCallback}) {
    _localStorage = LocalStorage(user.email);
  }

  Future<MessageStatus> sendMessage(Message message) async {
    return MessageStatus.Successful;
  }

  Future<List<Message>> readChat() async {
    if (!chats.containsKey(user.email)) {
      var _ready = await _localStorage.ready;

      List<Message> temp =
          ((_localStorage.getItem("messages") ?? []) as List<dynamic>)
              .map((e) => Message.fromJson(e))
              .toList();
      chats[user.email] = temp;
    }
    return chats[user.email]!; // can't ever be null but dart does not know
  }

  Future<void> writeChat(Future<List<Message>> messages) async {
    await _localStorage.ready;
    _localStorage.setItem("messages", await messages);
  }

  static Future<List<User>> readAllChatPartners() async {
    await _ownStorage.ready;
    return ((_ownStorage.getItem("chats") ?? []) as List<dynamic>)
        .map((e) => User.fromJson(e))
        .toList();
  }

  static Future<void> writeAllChatPartners(List<User> users) async {
    await _ownStorage.ready;
    _ownStorage.setItem("chats", users);
  }

  static String ownEMail() {
    // we trust that _ownStorage will be ready when this is first called
    if (_ownEMail == null) {
      _ownEMail = _ownStorage.getItem("email")!;
    }
    return _ownEMail!;
  }

  static void writeOwn({required String email}) {
    _ownStorage.ready.then((value) => _ownStorage.setItem("email", email));
  }
}
