import 'Chat/Message.dart';

class MessageSender {
  /// Callback do be registered dynamically for adding data to the UI
  late Function(Message) additionCallback;

  MessageSender() {
    additionCallback = (_) => throw UnimplementedError();
  }

  Future<bool> sendMessage(Message message) async {
    return true;
  }
}
